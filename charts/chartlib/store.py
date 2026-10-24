"""Snapshot files: gzipped JSON, one per collection run, under <data>/snapshots/YYYY/MM/DD/.

A snapshot keeps only what analysis needs (ids, names, genres, counts, ranks, dates). It stores no
descriptions, thumbnails or other creative content of the games it lists.
"""

from __future__ import annotations

import gzip
import json
import os
from datetime import datetime, timedelta, timezone
from functools import lru_cache
from pathlib import Path
from typing import Any, Dict, List, Optional

SCHEMA = 1


def default_data_dir() -> Path:
    """$CHARTS_DATA_DIR, else a `.chart-data` worktree of the chart-data branch, else charts/data."""
    override = os.environ.get("CHARTS_DATA_DIR")
    if override:
        return Path(override)
    charts_dir = Path(__file__).resolve().parents[1]
    branch_worktree = charts_dir.parent / ".chart-data"
    if (branch_worktree / "snapshots").exists():
        return branch_worktree
    return charts_dir / "data"


def parse_time(text: str) -> datetime:
    return datetime.strptime(text, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)


def format_time(moment: datetime) -> str:
    return moment.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def snapshot_path(data_dir: Path, taken: datetime, device: str, country: str) -> Path:
    stamp = taken.strftime("%Y%m%dT%H%M%SZ")
    return data_dir / "snapshots" / taken.strftime("%Y/%m/%d") / f"{stamp}-{device}-{country}.json.gz"


def build_snapshot(
    taken: datetime,
    device: str,
    country: str,
    sorts: List[Dict[str, Any]],
    details: Dict[int, Dict[str, Any]],
) -> Dict[str, Any]:
    games: Dict[str, Dict[str, Any]] = {}
    out_sorts: List[Dict[str, Any]] = []
    for sort in sorts:
        entries = []
        for rank, game in enumerate(sort.get("games") or [], start=1):
            uid = game.get("universeId")
            if uid is None:
                continue
            entries.append(
                {
                    "u": int(uid),
                    "r": rank,
                    "p": int(game.get("playerCount") or 0),
                    "up": int(game.get("totalUpVotes") or 0),
                    "down": int(game.get("totalDownVotes") or 0),
                    "ad": bool(game.get("isSponsored")),
                }
            )
            meta = games.setdefault(str(uid), {})
            meta.setdefault("name", game.get("name") or "")
            meta.setdefault("rootPlaceId", game.get("rootPlaceId"))
            meta.setdefault("genre", game.get("genreL1") or "")
            meta.setdefault("maturity", game.get("contentMaturity") or "")
            meta.setdefault("minimumAge", game.get("minimumAge") or 0)
            meta["players"] = max(meta.get("players", 0), int(game.get("playerCount") or 0))
        out_sorts.append({"id": sort.get("sortId") or sort.get("id"), "name": sort.get("sortDisplayName") or "", "games": entries})
    for uid, meta in games.items():
        detail = details.get(int(uid))
        if not detail:
            continue
        creator = detail.get("creator") or {}
        meta.update(
            {
                "visits": detail.get("visits"),
                "favorites": detail.get("favoritedCount"),
                "playing": detail.get("playing"),
                "created": detail.get("created"),
                "updated": detail.get("updated"),
                "maxPlayers": detail.get("maxPlayers"),
                "detailGenre": detail.get("genre_l1") or detail.get("genre"),
                "creator": creator.get("name"),
                "creatorType": creator.get("type"),
                "creatorId": creator.get("id"),
                "price": detail.get("price"),
            }
        )
    return {
        "schema": SCHEMA,
        "takenAt": format_time(taken),
        "device": device,
        "country": country,
        "source": "explore-api get-sorts + games API (unofficial, public)",
        "sorts": out_sorts,
        "games": games,
    }


def write_snapshot(data_dir: Path, snapshot: Dict[str, Any]) -> Path:
    taken = parse_time(snapshot["takenAt"])
    path = snapshot_path(data_dir, taken, snapshot["device"], snapshot["country"])
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(".tmp")
    with gzip.open(tmp, "wt", encoding="utf-8") as handle:
        json.dump(snapshot, handle, separators=(",", ":"), sort_keys=True)
    tmp.replace(path)
    return path


def list_snapshots(
    data_dir: Path,
    device: Optional[str] = "computer",
    country: Optional[str] = "all",
    since: Optional[datetime] = None,
) -> List[Path]:
    root = data_dir / "snapshots"
    if not root.exists():
        return []
    paths = []
    for path in sorted(root.rglob("*.json.gz")):
        parts = path.name[: -len(".json.gz")].split("-")
        if len(parts) < 3:
            continue
        stamp, path_device, path_country = parts[0], "-".join(parts[1:-1]), parts[-1]
        if device and path_device != device:
            continue
        if country and path_country != country:
            continue
        if since:
            taken = datetime.strptime(stamp, "%Y%m%dT%H%M%SZ").replace(tzinfo=timezone.utc)
            if taken < since:
                continue
        paths.append(path)
    return paths


@lru_cache(maxsize=4096)
def _load_cached(path: str, mtime: float) -> Dict[str, Any]:
    with gzip.open(path, "rt", encoding="utf-8") as handle:
        return json.load(handle)


def load(path: Path) -> Dict[str, Any]:
    return _load_cached(str(path), path.stat().st_mtime)


def load_window(data_dir: Path, days: float, device: str, country: str, now: Optional[datetime] = None) -> List[Dict[str, Any]]:
    """Snapshots from the last `days` days before the newest one (or `now`), oldest first."""
    paths = list_snapshots(data_dir, device, country)
    if not paths:
        return []
    snapshots = [load(p) for p in paths]
    end = now or parse_time(snapshots[-1]["takenAt"])
    start = end - timedelta(days=days)
    return [s for s in snapshots if start <= parse_time(s["takenAt"]) <= end]


def latest_time(data_dir: Path, device: str, country: str) -> Optional[datetime]:
    paths = list_snapshots(data_dir, device, country)
    if not paths:
        return None
    return parse_time(load(paths[-1])["takenAt"])


def _combo(path: Path) -> tuple:
    parts = path.name[: -len(".json.gz")].split("-")
    return parts[0][:8], "-".join(parts[1:-1]), parts[-1]


def merge_day(snapshots: List[Dict[str, Any]], day: str, device: str, country: str) -> Dict[str, Any]:
    """One synthetic snapshot for a UTC day: peak players, best rank per sort, last visits."""
    best: Dict[str, Dict[int, Dict[str, Any]]] = {}
    names: Dict[str, str] = {}
    games: Dict[str, Dict[str, Any]] = {}
    for snapshot in snapshots:
        for sort in snapshot.get("sorts", []):
            names[sort["id"]] = sort.get("name", "")
            entries = best.setdefault(sort["id"], {})
            for entry in sort.get("games", []):
                current = entries.get(entry["u"])
                if current is None:
                    entries[entry["u"]] = dict(entry)
                else:
                    current["r"] = min(current["r"], entry["r"])
                    current["p"] = max(current["p"], entry["p"])
                    current["up"], current["down"] = entry.get("up", 0), entry.get("down", 0)
                    current["ad"] = current.get("ad", False) and entry.get("ad", False)
        for uid, meta in snapshot.get("games", {}).items():
            merged = games.setdefault(uid, {})
            peak_players = max(merged.get("players", 0), meta.get("players", 0) or 0)
            peak_playing = max(merged.get("playing") or 0, meta.get("playing") or 0)
            merged.update({k: v for k, v in meta.items() if v is not None})
            merged["players"] = peak_players
            merged["playing"] = peak_playing
    sorts = [
        {"id": sort_id, "name": names.get(sort_id, ""), "games": sorted(entries.values(), key=lambda e: e["r"])}
        for sort_id, entries in best.items()
    ]
    return {
        "schema": SCHEMA,
        "takenAt": f"{day[:4]}-{day[4:6]}-{day[6:8]}T12:00:00Z",
        "device": device,
        "country": country,
        "source": f"daily compaction of {len(snapshots)} snapshots (peak players, best ranks, last visits)",
        "compacted": True,
        "sorts": sorts,
        "games": games,
    }


def compact(data_dir: Path, keep_days: float = 14, now: Optional[datetime] = None) -> List[str]:
    """Rolls snapshots older than `keep_days` into one snapshot per UTC day. Returns the days compacted."""
    cutoff = (now or datetime.now(timezone.utc)) - timedelta(days=keep_days)
    groups: Dict[tuple, List[Path]] = {}
    for path in list_snapshots(data_dir, None, None):
        day, device, country = _combo(path)
        day_start = datetime.strptime(day, "%Y%m%d").replace(tzinfo=timezone.utc)
        if day_start + timedelta(days=1) <= cutoff:
            groups.setdefault((day, device, country), []).append(path)
    done: List[str] = []
    for (day, device, country), paths in sorted(groups.items()):
        snapshots = [load(p) for p in paths]
        if len(snapshots) == 1 and snapshots[0].get("compacted"):
            continue
        merged = merge_day(snapshots, day, device, country)
        target = write_snapshot(data_dir, merged)
        for path in paths:
            if path != target:
                path.unlink()
        done.append(f"{day} {device}/{country} ({len(paths)} -> 1)")
    return done
