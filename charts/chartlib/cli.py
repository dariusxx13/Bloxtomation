"""charts: snapshot the Roblox discovery sorts and turn them into market evidence."""

from __future__ import annotations

import argparse
import csv
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import List, Optional

from . import analysis, report
from .api import Client, FetchError
from .store import build_snapshot, compact, default_data_dir, latest_time, list_snapshots, load, load_window, write_snapshot


def _window(args: argparse.Namespace) -> List[dict]:
    snapshots = load_window(Path(args.data_dir), args.days, args.device, args.country)
    if not snapshots:
        raise SystemExit(
            f"No snapshots for device={args.device} country={args.country} in {args.data_dir}. "
            "Run: python3 charts/charts.py snapshot"
        )
    return snapshots


def cmd_snapshot(args: argparse.Namespace) -> int:
    data_dir = Path(args.data_dir)
    last = latest_time(data_dir, args.device, args.country)
    now = datetime.now(timezone.utc).replace(microsecond=0)
    if last and not args.force and now - last < timedelta(minutes=args.min_interval):
        minutes = (now - last).total_seconds() / 60
        print(f"Latest snapshot is {minutes:.0f} min old (minimum interval {args.min_interval} min). Use --force to override.")
        return 0
    client = Client(delay=args.delay)
    try:
        sorts = client.sorts(args.device, args.country)
        ids = {int(g["universeId"]) for s in sorts for g in s.get("games") or [] if g.get("universeId") is not None}
        details = {} if args.no_details else client.details(ids)
    except FetchError as error:
        print(f"Snapshot failed: {error}", file=sys.stderr)
        return 1
    if not sorts:
        print("The charts endpoint returned no game sorts; nothing saved (the endpoint may have changed).", file=sys.stderr)
        return 1
    snapshot = build_snapshot(now, args.device, args.country, sorts, details)
    path = write_snapshot(data_dir, snapshot)
    placements = sum(len(s["games"]) for s in snapshot["sorts"])
    print(
        f"Saved {path} : {len(snapshot['sorts'])} sorts, {placements} placements, {len(snapshot['games'])} games, "
        f"{len(details)} with details, {client.requests} requests."
    )
    return 0


def cmd_status(args: argparse.Namespace) -> int:
    data_dir = Path(args.data_dir)
    paths = list_snapshots(data_dir, None, None)
    if not paths:
        print(f"No snapshots in {data_dir}.")
        return 0
    size = sum(p.stat().st_size for p in paths)
    combos = {}
    for path in paths:
        parts = path.name[: -len(".json.gz")].split("-")
        combos.setdefault(f"{'-'.join(parts[1:-1])}/{parts[-1]}", []).append(path)
    print(f"{len(paths)} snapshots, {size / 1e6:.1f} MB in {data_dir}")
    for combo, items in sorted(combos.items()):
        first = load(items[0])["takenAt"]
        last = load(items[-1])["takenAt"]
        print(f"  {combo:<24} {len(items):>5} snapshots  {first} .. {last}")
    return 0


def cmd_report(args: argparse.Namespace) -> int:
    snapshots = _window(args)
    text = report.market_report(snapshots, args.device, args.country, args.min_players)
    if args.stdout:
        print(text)
        return 0
    out = Path(args.out) if args.out else Path(args.data_dir) / "reports" / f"{snapshots[-1]['takenAt'][:10]}-{args.device}-{args.country}.md"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(text, encoding="utf-8")
    print(f"Wrote {out}")
    print("\n".join(text.splitlines()[:30]))
    return 0


def cmd_game(args: argparse.Namespace) -> int:
    snapshots = _window(args)
    games = analysis.build_games(snapshots)
    found = analysis.find_games(games, args.query)
    if not found:
        print(f"No game matching '{args.query}' in the last {args.days} days of snapshots.")
        return 1
    if len(found) > 1 and not args.query.isdigit():
        print("Several matches; showing the biggest. Others: " + ", ".join(report.label(g) for g in found[1:6]))
    print(report.game_history(found[0], snapshots))
    return 0


def cmd_evidence(args: argparse.Namespace) -> int:
    if not args.genre and not args.game:
        raise SystemExit("Give --genre and/or --game (name or universe id).")
    snapshots = _window(args)
    print(report.evidence_block(snapshots, args.device, args.country, args.min_players, args.genre, args.game))
    return 0


def cmd_genres(args: argparse.Namespace) -> int:
    snapshots = _window(args)
    print(report.window_line(snapshots, args.device, args.country))
    print(report.genre_table(snapshots, args.min_players))
    return 0


def cmd_export(args: argparse.Namespace) -> int:
    snapshots = _window(args)
    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    rows = 0
    with open(out, "w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(["takenAt", "sort", "rank", "universeId", "name", "genre", "players", "upVotes", "downVotes", "sponsored", "visits", "favorites", "created"])
        for snapshot in snapshots:
            games = snapshot.get("games", {})
            for sort in snapshot.get("sorts", []):
                for entry in sort.get("games", []):
                    meta = games.get(str(entry["u"]), {})
                    writer.writerow(
                        [
                            snapshot["takenAt"], sort["id"], entry["r"], entry["u"], meta.get("name", ""), meta.get("genre", ""),
                            entry["p"], entry.get("up", 0), entry.get("down", 0), int(bool(entry.get("ad"))),
                            meta.get("visits", ""), meta.get("favorites", ""), meta.get("created", ""),
                        ]
                    )
                    rows += 1
    print(f"Wrote {rows} rows to {out}")
    return 0


def cmd_compact(args: argparse.Namespace) -> int:
    days = compact(Path(args.data_dir), args.keep_days)
    print("\n".join(days) if days else "Nothing to compact.")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="charts", description="Roblox chart tracker (discovery sorts).")
    parser.add_argument("--data-dir", default=str(default_data_dir()), help="snapshot folder (default charts/data or $CHARTS_DATA_DIR)")
    sub = parser.add_subparsers(dest="command", required=True)

    def scope(p: argparse.ArgumentParser, days: Optional[float] = 7) -> None:
        p.add_argument("--device", default="computer", help="computer, high_end_phone, low_end_phone, high_end_tablet, low_end_tablet, console, vr")
        p.add_argument("--country", default="all", help="all, or a country code like us")
        if days is not None:
            p.add_argument("--days", type=float, default=days)
            p.add_argument("--min-players", type=int, default=1000, help="threshold for 'big' games")

    p = sub.add_parser("snapshot", help="collect one snapshot (about 25 polite requests)")
    scope(p, None)
    p.add_argument("--min-interval", type=float, default=60, help="minutes; refuse to snapshot more often")
    p.add_argument("--force", action="store_true")
    p.add_argument("--no-details", action="store_true", help="skip the games API (no visits, created dates)")
    p.add_argument("--delay", type=float, default=1.0, help="seconds between requests (minimum 0.5)")
    p.set_defaults(func=cmd_snapshot)

    p = sub.add_parser("compact", help="roll snapshots older than --keep-days into one per day")
    p.add_argument("--keep-days", type=float, default=14)
    p.set_defaults(func=cmd_compact)

    p = sub.add_parser("status", help="what data is stored")
    p.set_defaults(func=cmd_status)

    p = sub.add_parser("report", help="market report: breakouts, risers, new entries, rank movers, genres")
    scope(p)
    p.add_argument("--out")
    p.add_argument("--stdout", action="store_true")
    p.set_defaults(func=cmd_report)

    p = sub.add_parser("game", help="one game's history (name or universe id)")
    scope(p, 30)
    p.add_argument("query")
    p.set_defaults(func=cmd_game)

    p = sub.add_parser("evidence", help="pitch-ready evidence block for a genre and/or comparables")
    scope(p)
    p.add_argument("--genre")
    p.add_argument("--game", action="append", help="name or universe id; repeatable")
    p.set_defaults(func=cmd_evidence)

    p = sub.add_parser("genres", help="genre shares, growth and phase")
    scope(p)
    p.set_defaults(func=cmd_genres)

    p = sub.add_parser("export", help="flat CSV of placements for spreadsheets")
    scope(p)
    p.add_argument("--out", required=True)
    p.set_defaults(func=cmd_export)
    return parser


def main(argv: Optional[List[str]] = None) -> int:
    args = build_parser().parse_args(argv)
    if getattr(args, "delay", 1.0) < 0.5:
        args.delay = 0.5
    return int(args.func(args) or 0)
