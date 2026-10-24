"""Markdown output: the weekly market report, one game's history, and pitch evidence blocks."""

from __future__ import annotations

from datetime import datetime, timedelta, timezone
from typing import List, Optional

from . import analysis
from .analysis import Game
from .store import format_time, parse_time

CAVEAT = (
    "Source: Roblox discovery sorts (explore-api get-sorts) and the public games API. These endpoints are "
    "unofficial and may change. Player counts are concurrent players at snapshot time; sponsored placements "
    "are excluded from ranks. Trend phases are heuristics; check them against the vault's trend lifecycle note."
)


def short(value: Optional[float]) -> str:
    if value is None:
        return "-"
    n = float(value)
    for limit, suffix in ((1e9, "B"), (1e6, "M"), (1e3, "K")):
        if abs(n) >= limit:
            text = f"{n / limit:.1f}".rstrip("0").rstrip(".")
            return f"{text}{suffix}"
    return f"{n:.0f}"


def pct(ratio: Optional[float]) -> str:
    if ratio is None:
        return "-"
    return f"{(ratio - 1) * 100:+.0f}%"


def label(game: Game) -> str:
    name = game.name.replace("|", "/") or "(unnamed)"
    return f"{name} ({game.universe_id})"


def _num(value: Optional[int]) -> str:
    return "-" if value is None else str(value)


def _sorts_text(game: Game) -> str:
    ranks = game.latest.ranks
    parts = [f"{sort} #{ranks[sort]}" for sort in analysis.KEY_SORTS if sort in ranks]
    return ", ".join(parts) or "-"


def like(game: Game) -> str:
    value = game.latest.like
    return "-" if value is None else f"{value * 100:.0f}%"


def window_line(snapshots: List[dict], device: str, country: str) -> str:
    return (
        f"{len(snapshots)} snapshots from {snapshots[0]['takenAt']} to {snapshots[-1]['takenAt']} "
        f"(device {device}, country {country})"
    )


def market_report(snapshots: List[dict], device: str, country: str, min_players: int, limit: int = 15) -> str:
    games = analysis.build_games(snapshots)
    now = parse_time(snapshots[-1]["takenAt"])
    start = parse_time(snapshots[0]["takenAt"])
    current = [g for g in games.values() if g.latest.at >= now - analysis.NEAREST_TOLERANCE]
    lines = [
        f"# Roblox charts report, {now.strftime('%Y-%m-%d')}",
        "",
        f"Data: {window_line(snapshots, device, country)}. Games charting now: {len(current)}. "
        f"Big game threshold: {short(min_players)} players.",
        "",
    ]

    # 24h breakouts
    rows = []
    for game in current:
        if game.latest.players < min_players:
            continue
        day = analysis.change(game, 24, now)
        if day is not None and day >= 1.25:
            rows.append((day, game))
    rows.sort(key=lambda item: -item[0])
    lines += ["## Breakouts (24h)", "", "Games above the threshold with +25% players or more versus the same time yesterday.", ""]
    if rows:
        lines += [
            "| Game | Genre | Players | 24h | Window peak | Visits/day | Like | Age (days) | Updated (days ago) | Ranks now |",
            "|---|---|---|---|---|---|---|---|---|---|",
        ]
        for day, game in rows[:limit]:
            lines.append(
                f"| {label(game)} | {game.genre or '-'} | {short(game.latest.players)} | {pct(day)} | "
                f"{pct(analysis.peak_growth(game, start, now))} | {short(analysis.visits_per_day(game))} | {like(game)} | "
                f"{_num(analysis.age_days(game, now))} | {_num(analysis.days_since_update(game, now))} | {_sorts_text(game)} |"
            )
    else:
        lines.append("None (or less than a day of data).")
    lines.append("")

    # weekly risers
    risers = []
    for game in current:
        growth = analysis.peak_growth(game, start, now)
        if growth is not None and growth >= 1.3 and game.latest.players >= min_players:
            risers.append((growth, game))
    risers.sort(key=lambda item: -item[0])
    lines += ["## Risers over the window (daily peaks)", ""]
    if risers:
        lines += ["| Game | Genre | Peak growth | Players now | Visits/day | Age (days) |", "|---|---|---|---|---|---|"]
        for growth, game in risers[:limit]:
            lines.append(
                f"| {label(game)} | {game.genre or '-'} | {pct(growth)} | {short(game.latest.players)} | "
                f"{short(analysis.visits_per_day(game))} | {analysis.age_days(game, now) if game.created else '-'} |"
            )
    else:
        lines.append("None yet (needs at least 36 hours of snapshots).")
    lines.append("")

    # new entries
    fresh = analysis.new_entries(games, now, start)
    lines += ["## New on the charts (first seen in the last 24h)", ""]
    if fresh:
        lines += ["| Game | Genre | Players | Ranks now | Age (days) |", "|---|---|---|---|---|"]
        for game in fresh[:limit]:
            lines.append(
                f"| {label(game)} | {game.genre or '-'} | {short(game.latest.players)} | {_sorts_text(game)} | "
                f"{analysis.age_days(game, now) if game.created else '-'} |"
            )
    else:
        lines.append("None (or the window is shorter than a day).")
    lines.append("")

    # breakout candidates (vault: 15-market-research/reading-the-charts.md)
    candidates = analysis.breakout_candidates(games, now, start, min_players)
    lines += [
        "## Breakout candidates",
        "",
        f"Created in the last 60 days or under 1M lifetime visits, {short(min_players)}+ players, and rising "
        "(or too little history to tell).",
        "",
    ]
    if candidates:
        lines += [
            "| Game | Genre | Players | Momentum | Visits | Like | Age (days) | Updated (days ago) | Sorts | Creator |",
            "|---|---|---|---|---|---|---|---|---|---|",
        ]
        for game, momentum in candidates[:limit]:
            lines.append(
                f"| {label(game)} | {game.genre or '-'} | {short(game.latest.players)} | "
                f"{pct(momentum) if momentum else 'new data'} | {short(game.latest.visits)} | {like(game)} | "
                f"{_num(analysis.age_days(game, now))} | {_num(analysis.days_since_update(game, now))} | "
                f"{len(game.latest.ranks)} | {game.creator or '-'} |"
            )
    else:
        lines.append("None above the threshold.")
    lines.append("")

    # rank movers
    lines += ["## Rank movers (organic ranks, versus 24h ago)", ""]
    for sort_id in ("top-trending", "up-and-coming", "top-earning"):
        moves = [m for m in analysis.rank_moves(games, sort_id, now) if m[1] is None or m[1] > m[2]]
        lines.append(f"**{sort_id}**: " + (
            "; ".join(
                f"{game.name} {('new' if before is None else f'#{before}')} -> #{after}" for game, before, after in moves[:8]
            )
            or "no climbers"
        ))
        lines.append("")

    # genres
    lines += [
        "## Genres",
        "",
        "| Genre | Players now | Share | Games charting | Big games | Growth (daily peaks) | Risers | Phase (heuristic) |",
        "|---|---|---|---|---|---|---|---|",
    ]
    for stat in analysis.genre_stats(games, now, start, min_players):
        lines.append(
            f"| {stat.genre} | {short(stat.players)} | {stat.share * 100:.1f}% | {stat.games} | {stat.big_games} | "
            f"{pct(stat.growth)} | {stat.rising} | {stat.phase} |"
        )
    lines += ["", CAVEAT, ""]
    return "\n".join(lines)


def game_history(game: Game, snapshots: List[dict]) -> str:
    lines = [
        f"# {label(game)}",
        "",
        f"Genre {game.genre or '-'}, creator {game.creator or '-'}, created {format_time(game.created) if game.created else '-'}, "
        f"updated {format_time(game.updated) if game.updated else '-'}.",
        f"First seen in these snapshots {format_time(game.first_seen)}; {len(game.points)} of {len(snapshots)} snapshots.",
        "",
    ]
    peak = max(game.points, key=lambda p: p.players)
    lines.append(f"Peak {short(peak.players)} players at {format_time(peak.at)}. Visits/day {short(analysis.visits_per_day(game))}.")
    lines += ["", "| Snapshot | Players | Visits | Ranks (organic) | Sponsored in |", "|---|---|---|---|---|"]
    for point in game.points[-60:]:
        ranks = ", ".join(f"{k} #{v}" for k, v in point.ranks.items() if k in analysis.KEY_SORTS) or "-"
        lines.append(
            f"| {format_time(point.at)} | {short(point.players)} | {short(point.visits)} | {ranks} | {', '.join(point.sponsoredIn) or '-'} |"
        )
    lines += ["", CAVEAT, ""]
    return "\n".join(lines)


def evidence_block(
    snapshots: List[dict],
    device: str,
    country: str,
    min_players: int,
    genre: Optional[str] = None,
    queries: Optional[List[str]] = None,
    limit: int = 10,
) -> str:
    """A pitch-ready block: every number with its date range and source (PITCH-01, PITCH-05)."""
    games = analysis.build_games(snapshots)
    now = parse_time(snapshots[-1]["takenAt"])
    start = parse_time(snapshots[0]["takenAt"])
    age_hours = (datetime.now(timezone.utc) - now) / timedelta(hours=1)
    lines = [
        "### Market evidence",
        "",
        f"- Data: {window_line(snapshots, device, country)}.",
        f"- Newest snapshot is {age_hours:.0f} hours old" + (" (STALE: older than 7 days, refresh before deciding)." if age_hours > 168 else "."),
    ]
    selected: List[Game] = []
    if genre:
        stats = {s.genre.lower(): s for s in analysis.genre_stats(games, now, start, min_players)}
        stat = stats.get(genre.lower())
        if stat is None:
            lines.append(f"- Genre '{genre}' has no charting games in this window.")
        else:
            lines.append(
                f"- Genre {stat.genre}: {short(stat.players)} concurrent players across {stat.games} charting games "
                f"({stat.share * 100:.1f}% of charting players); {stat.big_games} games at {short(min_players)}+ players; "
                f"growth of daily peaks {pct(stat.growth)}; {stat.rising} games rising 30%+; phase (heuristic): {stat.phase}."
            )
            selected = sorted(
                (g for g in games.values() if (g.genre or "").lower() == genre.lower() and g.latest.at >= now - analysis.NEAREST_TOLERANCE),
                key=lambda g: -g.latest.players,
            )[:limit]
    for query in queries or []:
        found = analysis.find_games(games, query)
        if not found:
            lines.append(f"- No charting game matches '{query}' in this window.")
        selected += [g for g in found[:3] if g not in selected]
    if selected:
        lines += [
            "",
            "| Comparable | Genre | Players (latest) | 24h | Window peak growth | Visits/day | Like | Age (days) | Updated (days ago) | Ranks |",
            "|---|---|---|---|---|---|---|---|---|---|",
        ]
        for game in selected:
            lines.append(
                f"| {label(game)} | {game.genre or '-'} | {short(game.latest.players)} ({format_time(game.latest.at)}) | "
                f"{pct(analysis.change(game, 24, now))} | {pct(analysis.peak_growth(game, start, now))} | "
                f"{short(analysis.visits_per_day(game))} | {like(game)} | {_num(analysis.age_days(game, now))} | "
                f"{_num(analysis.days_since_update(game, now))} | {_sorts_text(game)} |"
            )
    lines += ["", CAVEAT]
    return "\n".join(lines) + "\n"


def genre_table(snapshots: List[dict], min_players: int) -> str:
    games = analysis.build_games(snapshots)
    now = parse_time(snapshots[-1]["takenAt"])
    start = parse_time(snapshots[0]["takenAt"])
    lines = ["Genre                          Players   Share  Games  Big  Growth  Phase"]
    for stat in analysis.genre_stats(games, now, start, min_players):
        lines.append(
            f"{stat.genre[:30]:<30} {short(stat.players):>8} {stat.share * 100:5.1f}% {stat.games:>6} {stat.big_games:>4} "
            f"{pct(stat.growth):>7}  {stat.phase}"
        )
    return "\n".join(lines)
