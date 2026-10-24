"""Turns snapshots into time series and market signals (vault: 15-market-research/reading-the-charts.md).

Conventions:
- Players for a game at a snapshot = the games API `playing` count when present, else the highest
  playerCount shown in any sort.
- Ranks are organic: sponsored placements are removed before ranking, so ads never look like momentum.
- Comparisons over a day use the snapshot nearest the same time of day (player counts swing with time zones);
  weekly comparisons use daily peaks.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Iterable, List, Optional, Tuple

from .store import parse_time

KEY_SORTS = ["top-trending", "up-and-coming", "top-playing-now", "top-earning", "top-revisited", "fun-with-friends"]
NEAREST_TOLERANCE = timedelta(hours=4)


@dataclass
class Point:
    at: datetime
    players: int
    visits: Optional[int]
    favorites: Optional[int]
    ranks: Dict[str, int] = field(default_factory=dict)
    sponsoredIn: List[str] = field(default_factory=list)
    like: Optional[float] = None


@dataclass
class Game:
    universe_id: int
    name: str = ""
    genre: str = ""
    created: Optional[datetime] = None
    updated: Optional[datetime] = None
    creator: str = ""
    root_place_id: Optional[int] = None
    points: List[Point] = field(default_factory=list)

    @property
    def latest(self) -> Point:
        return self.points[-1]

    @property
    def first_seen(self) -> datetime:
        return self.points[0].at


def _date(text: Any) -> Optional[datetime]:
    if not text or not isinstance(text, str):
        return None
    cleaned = text.replace("Z", "+00:00")
    if "." in cleaned:
        head, _, tail = cleaned.partition(".")
        zone = ""
        for marker in ("+", "-"):
            if marker in tail:
                zone = marker + tail.split(marker, 1)[1]
                break
        cleaned = head + zone
    try:
        moment = datetime.fromisoformat(cleaned)
    except ValueError:
        return None
    return moment if moment.tzinfo else moment.replace(tzinfo=timezone.utc)


def build_games(snapshots: Iterable[Dict[str, Any]]) -> Dict[int, Game]:
    games: Dict[int, Game] = {}
    for snapshot in snapshots:
        at = parse_time(snapshot["takenAt"])
        organic: Dict[int, Dict[str, int]] = {}
        sponsored: Dict[int, List[str]] = {}
        likes: Dict[int, float] = {}
        for sort in snapshot.get("sorts", []):
            rank = 0
            for entry in sort.get("games", []):
                uid = int(entry["u"])
                votes = (entry.get("up") or 0) + (entry.get("down") or 0)
                if votes > 0 and uid not in likes:
                    likes[uid] = (entry.get("up") or 0) / votes
                if entry.get("ad"):
                    sponsored.setdefault(uid, []).append(sort["id"])
                    continue
                rank += 1
                organic.setdefault(uid, {})[sort["id"]] = rank
        for uid_text, meta in snapshot.get("games", {}).items():
            uid = int(uid_text)
            game = games.get(uid)
            if game is None:
                game = Game(universe_id=uid)
                games[uid] = game
            game.name = meta.get("name") or game.name
            game.genre = meta.get("genre") or meta.get("detailGenre") or game.genre
            game.created = _date(meta.get("created")) or game.created
            game.updated = _date(meta.get("updated")) or game.updated
            game.creator = meta.get("creator") or game.creator
            game.root_place_id = meta.get("rootPlaceId") or game.root_place_id
            playing = meta.get("playing")
            players = int(playing) if isinstance(playing, int) and playing > 0 else int(meta.get("players") or 0)
            game.points.append(
                Point(
                    at=at,
                    players=players,
                    visits=meta.get("visits"),
                    favorites=meta.get("favorites"),
                    ranks=organic.get(uid, {}),
                    sponsoredIn=sponsored.get(uid, []),
                    like=likes.get(uid),
                )
            )
    return games


def nearest(points: List[Point], target: datetime, tolerance: timedelta = NEAREST_TOLERANCE) -> Optional[Point]:
    best: Optional[Point] = None
    for point in points:
        if best is None or abs(point.at - target) < abs(best.at - target):
            best = point
    if best is None or abs(best.at - target) > tolerance:
        return None
    return best


def change(game: Game, hours: float, now: datetime) -> Optional[float]:
    """Ratio of players now versus the snapshot nearest `hours` ago (same time of day for 24h multiples)."""
    latest = game.latest
    if latest.at < now - NEAREST_TOLERANCE:
        return None  # not on the charts in the newest snapshots
    base = nearest(game.points, latest.at - timedelta(hours=hours))
    if base is None or base is latest or base.players <= 0:
        return None
    return latest.players / base.players


def daily_peaks(game: Game) -> Dict[str, int]:
    peaks: Dict[str, int] = {}
    for point in game.points:
        key = point.at.strftime("%Y-%m-%d")
        peaks[key] = max(peaks.get(key, 0), point.players)
    return peaks


def peak_growth(game: Game, window_start: datetime, window_end: datetime) -> Optional[float]:
    """Last 24h peak versus first 24h peak of the window (robust to time-of-day swings)."""
    first = [p.players for p in game.points if p.at <= window_start + timedelta(hours=24)]
    last = [p.players for p in game.points if p.at >= window_end - timedelta(hours=24)]
    if not first or not last or max(first) <= 0 or window_end - window_start < timedelta(hours=36):
        return None
    return max(last) / max(first)


def visits_per_day(game: Game) -> Optional[float]:
    with_visits = [p for p in game.points if isinstance(p.visits, int)]
    if len(with_visits) < 2:
        return None
    first, last = with_visits[0], with_visits[-1]
    days = (last.at - first.at).total_seconds() / 86400
    if days < 0.25:
        return None
    return max(0, last.visits - first.visits) / days


def days_since_update(game: Game, now: datetime) -> Optional[int]:
    if not game.updated:
        return None
    return max(0, (now - game.updated).days)


def breakout_candidates(
    games: Dict[int, Game], now: datetime, window_start: datetime, min_players: int, max_age_days: int = 60, max_visits: int = 1_000_000
) -> List[Tuple[Game, float]]:
    """Vault definition: young or low lifetime visits, meaningful concurrency, rising. Returns (game, momentum)."""
    found: List[Tuple[Game, float]] = []
    fresh = {g.universe_id for g in new_entries(games, now, window_start)}
    for game in games.values():
        latest = game.latest
        if latest.at < now - NEAREST_TOLERANCE or latest.players < min_players:
            continue
        young = game.created is not None and (now - game.created).days <= max_age_days
        small = isinstance(latest.visits, int) and latest.visits < max_visits
        if not (young or small):
            continue
        day = change(game, 24, now)
        window = peak_growth(game, window_start, now)
        momentum = max(day or 0, window or 0, 1.5 if game.universe_id in fresh else 0)
        rising = momentum >= 1.1 or (day is None and window is None)
        if rising:
            found.append((game, momentum))
    found.sort(key=lambda item: (-item[1], -item[0].latest.players))
    return found


def age_days(game: Game, now: datetime) -> Optional[int]:
    if not game.created:
        return None
    return max(0, (now - game.created).days)


@dataclass
class GenreStat:
    genre: str
    players: int
    share: float
    games: int
    big_games: int
    growth: Optional[float]
    rising: int
    phase: str


def phase_for(growth: Optional[float], big_games: int, rising: int) -> str:
    """Heuristic trend phase (vault: 15-market-research/trend-lifecycle.md). Label it as a heuristic."""
    if growth is None:
        return "unknown (needs 36h+ of data)"
    if growth >= 1.3 and big_games <= 10:
        return "early (growing, few big games)"
    if growth >= 1.1:
        return "rising (growing, crowding)" if big_games > 10 else "rising"
    if growth <= 0.85:
        return "declining"
    if rising >= 3:
        return "churning (flat total, several risers)"
    return "stable or saturated"


def genre_stats(games: Dict[int, Game], now: datetime, window_start: datetime, min_players: int) -> List[GenreStat]:
    current = [g for g in games.values() if g.latest.at >= now - NEAREST_TOLERANCE]
    total = sum(g.latest.players for g in current) or 1
    by_genre: Dict[str, List[Game]] = {}
    for game in current:
        by_genre.setdefault(game.genre or "Unknown", []).append(game)
    stats: List[GenreStat] = []
    for genre, members in by_genre.items():
        players = sum(g.latest.players for g in members)
        first_total = 0
        last_total = 0
        for game in members:
            first = [p.players for p in game.points if p.at <= window_start + timedelta(hours=24)]
            last = [p.players for p in game.points if p.at >= now - timedelta(hours=24)]
            first_total += max(first) if first else 0
            last_total += max(last) if last else 0
        long_enough = now - window_start >= timedelta(hours=36)
        growth = last_total / first_total if long_enough and first_total > 0 else None
        rising = sum(1 for g in members if (peak_growth(g, window_start, now) or 0) >= 1.3 and g.latest.players >= min_players)
        big = sum(1 for g in members if g.latest.players >= min_players)
        stats.append(
            GenreStat(
                genre=genre,
                players=players,
                share=players / total,
                games=len(members),
                big_games=big,
                growth=growth,
                rising=rising,
                phase=phase_for(growth, big, rising),
            )
        )
    stats.sort(key=lambda s: -s.players)
    return stats


def new_entries(games: Dict[int, Game], now: datetime, window_start: datetime, hours: float = 24) -> List[Game]:
    """Games first seen in the last `hours` that are still charting now (window must be longer than `hours`)."""
    if now - window_start <= timedelta(hours=hours):
        return []
    cutoff = now - timedelta(hours=hours)
    return sorted(
        (g for g in games.values() if g.first_seen >= cutoff and g.latest.at >= now - NEAREST_TOLERANCE),
        key=lambda g: -g.latest.players,
    )


def rank_moves(games: Dict[int, Game], sort_id: str, now: datetime, hours: float = 24) -> List[Tuple[Game, Optional[int], int]]:
    """(game, rank then or None if absent, rank now) for games in the sort now, biggest climbs first."""
    moves: List[Tuple[Game, Optional[int], int]] = []
    for game in games.values():
        latest = game.latest
        if latest.at < now - NEAREST_TOLERANCE or sort_id not in latest.ranks:
            continue
        base = nearest(game.points, latest.at - timedelta(hours=hours))
        before = base.ranks.get(sort_id) if base and base is not latest else None
        moves.append((game, before, latest.ranks[sort_id]))

    def climb(item: Tuple[Game, Optional[int], int]) -> Tuple[int, int]:
        game, before, after = item
        gained = (before - after) if before is not None else 1000 - after
        return (-gained, after)

    moves.sort(key=climb)
    return moves


def find_games(games: Dict[int, Game], query: str) -> List[Game]:
    if query.isdigit() and int(query) in games:
        return [games[int(query)]]
    lowered = query.lower()
    return sorted((g for g in games.values() if lowered in g.name.lower()), key=lambda g: -g.latest.players)
