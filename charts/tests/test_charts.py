"""Chart tracker tests on synthetic data (no network)."""

from __future__ import annotations

import gzip
import io
import json
import shutil
import sys
import tempfile
import unittest
import urllib.error
from contextlib import redirect_stdout
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Dict, List, Optional
from unittest import mock

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from chartlib import analysis, cli, report, store  # noqa: E402
from chartlib.api import Client, FetchError  # noqa: E402

T0 = datetime(2026, 10, 1, 12, 0, tzinfo=timezone.utc)


def api_game(uid: int, players: int, genre: str = "Simulation", ad: bool = False) -> Dict:
    return {
        "universeId": uid,
        "rootPlaceId": uid * 10,
        "name": f"Game {uid}",
        "playerCount": players,
        "totalUpVotes": 100,
        "totalDownVotes": 10,
        "isSponsored": ad,
        "genreL1": genre,
        "contentMaturity": "minimal",
        "minimumAge": 0,
    }


def snap(at: datetime, sorts: Dict[str, List[Dict]], details: Optional[Dict[int, Dict]] = None) -> Dict:
    api_sorts = [{"sortId": sid, "sortDisplayName": sid, "contentType": "Games", "games": games} for sid, games in sorts.items()]
    return store.build_snapshot(at, "computer", "all", api_sorts, details or {})


class Fixture(unittest.TestCase):
    def setUp(self) -> None:
        self.dir = Path(tempfile.mkdtemp(prefix="charts-test-"))

    def tearDown(self) -> None:
        shutil.rmtree(self.dir, ignore_errors=True)

    def write_series(self, hours: int, step: int = 6) -> List[Dict]:
        """Game 1 grows 3x, game 2 flat, game 3 appears in the last day, game 4 is sponsored in top-trending."""
        out = []
        for h in range(0, hours + 1, step):
            at = T0 + timedelta(hours=h)
            growth = 1 + 2 * h / hours
            trending = [api_game(4, 500, "Action", ad=True), api_game(1, int(10000 * growth)), api_game(2, 20000, "Action")]
            if h >= hours - 12:
                trending.insert(1, api_game(3, 8000, "Simulation"))
            details = {
                1: {"id": 1, "visits": 1000 + h * 100, "playing": int(10000 * growth), "created": "2026-09-20T10:00:00.123Z"},
                2: {"id": 2, "visits": 50000 + h * 10, "playing": 20000, "created": "2020-01-01T00:00:00Z"},
            }
            snapshot = snap(at, {"top-trending": trending, "top-playing-now": list(reversed(trending))}, details)
            store.write_snapshot(self.dir, snapshot)
            out.append(snapshot)
        return out


class SnapshotFormatTests(Fixture):
    def test_build_snapshot_keeps_only_analysis_fields(self) -> None:
        s = snap(T0, {"top-trending": [api_game(1, 500)]}, {1: {"id": 1, "visits": 7, "description": "long text"}})
        self.assertEqual(s["games"]["1"]["visits"], 7)
        self.assertNotIn("description", json.dumps(s))
        self.assertEqual(s["sorts"][0]["games"][0], {"u": 1, "r": 1, "p": 500, "up": 100, "down": 10, "ad": False})

    def test_write_and_list_filter_by_device(self) -> None:
        store.write_snapshot(self.dir, snap(T0, {"top-trending": [api_game(1, 5)]}))
        phone = snap(T0, {"top-trending": [api_game(1, 5)]})
        phone["device"] = "high_end_phone"
        store.write_snapshot(self.dir, phone)
        self.assertEqual(len(store.list_snapshots(self.dir, "computer", "all")), 1)
        self.assertEqual(len(store.list_snapshots(self.dir, "high_end_phone", "all")), 1)
        self.assertEqual(len(store.list_snapshots(self.dir, None, None)), 2)
        path = store.list_snapshots(self.dir, "computer", "all")[0]
        with gzip.open(path, "rt") as handle:
            self.assertEqual(json.load(handle)["schema"], store.SCHEMA)


class AnalysisTests(Fixture):
    def test_organic_ranks_skip_sponsored(self) -> None:
        games = analysis.build_games(self.write_series(48))
        self.assertEqual(games[1].points[0].ranks["top-trending"], 1)
        self.assertIn("top-trending", games[4].points[0].sponsoredIn)
        self.assertNotIn("top-trending", games[4].points[0].ranks)

    def test_daily_change_and_peak_growth(self) -> None:
        snapshots = self.write_series(48)
        games = analysis.build_games(snapshots)
        now = store.parse_time(snapshots[-1]["takenAt"])
        start = store.parse_time(snapshots[0]["takenAt"])
        self.assertAlmostEqual(analysis.change(games[1], 24, now), 30000 / 20000, places=2)
        self.assertAlmostEqual(analysis.change(games[2], 24, now), 1.0)
        # peak of the first 24h (hour 24: 20K) versus the last 24h (hour 48: 30K)
        self.assertAlmostEqual(analysis.peak_growth(games[1], start, now), 1.5)
        self.assertIsNone(analysis.peak_growth(games[1], start, start + timedelta(hours=24)))

    def test_visits_per_day_and_age(self) -> None:
        snapshots = self.write_series(48)
        games = analysis.build_games(snapshots)
        self.assertAlmostEqual(analysis.visits_per_day(games[1]), 2400, places=0)
        now = store.parse_time(snapshots[-1]["takenAt"])
        self.assertEqual(analysis.age_days(games[1], now), 13)

    def test_new_entries_need_a_long_enough_window(self) -> None:
        snapshots = self.write_series(48)
        games = analysis.build_games(snapshots)
        now = store.parse_time(snapshots[-1]["takenAt"])
        start = store.parse_time(snapshots[0]["takenAt"])
        self.assertEqual([g.universe_id for g in analysis.new_entries(games, now, start)], [3])
        self.assertEqual(analysis.new_entries(games, now, now - timedelta(hours=12)), [])

    def test_rank_moves_show_new_entries_first(self) -> None:
        snapshots = self.write_series(48)
        games = analysis.build_games(snapshots)
        now = store.parse_time(snapshots[-1]["takenAt"])
        moves = analysis.rank_moves(games, "top-trending", now)
        self.assertEqual(moves[0][0].universe_id, 3)
        self.assertIsNone(moves[0][1])

    def test_genre_stats_and_phase(self) -> None:
        snapshots = self.write_series(48)
        games = analysis.build_games(snapshots)
        now = store.parse_time(snapshots[-1]["takenAt"])
        start = store.parse_time(snapshots[0]["takenAt"])
        stats = {s.genre: s for s in analysis.genre_stats(games, now, start, 1000)}
        self.assertGreater(stats["Simulation"].growth, 1.3)
        self.assertTrue(stats["Simulation"].phase.startswith("early"))
        self.assertEqual(analysis.phase_for(None, 3, 0).split()[0], "unknown")
        self.assertEqual(analysis.phase_for(0.7, 3, 0), "declining")
        self.assertEqual(analysis.phase_for(1.2, 20, 5), "rising (growing, crowding)")

    def test_like_ratio_and_breakout_candidates(self) -> None:
        snapshots = self.write_series(48)
        games = analysis.build_games(snapshots)
        now = store.parse_time(snapshots[-1]["takenAt"])
        start = store.parse_time(snapshots[0]["takenAt"])
        self.assertAlmostEqual(games[1].latest.like, 100 / 110)
        ids = [game.universe_id for game, _ in analysis.breakout_candidates(games, now, start, 1000)]
        self.assertIn(1, ids, "young and rising")
        self.assertNotIn(2, ids, "old, 50K visits but flat: low visits alone is not enough without growth")

    def test_dates_with_fractions_and_offsets_parse(self) -> None:
        self.assertEqual(analysis._date("2026-09-20T10:00:00.123Z").day, 20)
        self.assertEqual(analysis._date("2026-09-20T10:00:00.5+02:00").hour, 10)
        self.assertIsNone(analysis._date("not a date"))


class CompactTests(Fixture):
    def test_compact_rolls_old_days_into_one_snapshot_with_peaks(self) -> None:
        self.write_series(72)
        before = len(store.list_snapshots(self.dir))
        days = store.compact(self.dir, keep_days=1, now=T0 + timedelta(hours=72))
        self.assertTrue(days)
        after = store.list_snapshots(self.dir)
        self.assertLess(len(after), before)
        first_day = store.load(after[0])
        self.assertTrue(first_day["compacted"])
        self.assertEqual(first_day["takenAt"], "2026-10-01T12:00:00Z")
        # day 1 covers hours 0..6 of growth for game 1: peak is the later point
        self.assertEqual(first_day["games"]["1"]["playing"], int(10000 * (1 + 2 * 6 / 72)))
        self.assertEqual(store.compact(self.dir, keep_days=1, now=T0 + timedelta(hours=72)), [])


class ReportTests(Fixture):
    def test_market_report_sections(self) -> None:
        snapshots = self.write_series(48)
        text = report.market_report(snapshots, "computer", "all", 1000)
        for heading in ("Breakouts (24h)", "Risers over the window", "New on the charts", "Breakout candidates", "Genres"):
            self.assertIn(heading, text)
        self.assertIn("Game 1 (1)", text.split("## Risers")[0], "game 1 is a 24h breakout")
        self.assertIn("Game 3 (3)", text.split("## New on the charts")[1].split("##")[0])

    def test_evidence_states_dates_and_staleness(self) -> None:
        snapshots = self.write_series(48)
        text = report.evidence_block(snapshots, "computer", "all", 1000, genre="Simulation", queries=["Game 2"])
        self.assertIn("2026-10-01T12:00:00Z", text)
        self.assertIn("STALE", text)
        self.assertIn("Game 2 (2)", text)

    def test_cli_report_writes_file(self) -> None:
        self.write_series(48)
        out = io.StringIO()
        with redirect_stdout(out):
            code = cli.main(["--data-dir", str(self.dir), "report"])
        self.assertEqual(code, 0)
        self.assertTrue(list((self.dir / "reports").glob("*.md")))

    def test_cli_export(self) -> None:
        self.write_series(12)
        target = self.dir / "out.csv"
        with redirect_stdout(io.StringIO()):
            cli.main(["--data-dir", str(self.dir), "export", "--out", str(target)])
        self.assertTrue(target.read_text().startswith("takenAt,sort,rank"))


class FakeResponse(io.BytesIO):
    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False


class ClientTests(unittest.TestCase):
    def test_retries_on_429_then_succeeds(self) -> None:
        calls = []

        def opener(request, timeout):
            calls.append(request.full_url)
            if len(calls) == 1:
                raise urllib.error.HTTPError(request.full_url, 429, "Too Many", {"Retry-After": "1"}, None)
            return FakeResponse(json.dumps({"ok": True}).encode())

        sleeps = []
        client = Client(delay=0, opener=opener, sleep=sleeps.append)
        self.assertEqual(client.get_json("https://example.test/x"), {"ok": True})
        self.assertEqual(len(calls), 2)
        self.assertIn(1.0, sleeps)

    def test_client_errors_are_not_retried(self) -> None:
        def opener(request, timeout):
            raise urllib.error.HTTPError(request.full_url, 404, "Nope", {}, None)

        client = Client(delay=0, opener=opener, sleep=lambda s: None)
        with self.assertRaises(FetchError):
            client.get_json("https://example.test/x")
        self.assertEqual(client.requests, 1)

    def test_paginates_sorts_and_batches_details(self) -> None:
        pages = {
            None: {"sorts": [{"contentType": "Filters"}, {"sortId": "a", "contentType": "Games", "games": [api_game(1, 5)]}], "nextSortsPageToken": "t2"},
            "t2": {"sorts": [{"sortId": "b", "contentType": "Games", "games": [api_game(2, 5)]}], "nextSortsPageToken": None},
        }
        seen_batches = []

        def opener(request, timeout):
            url = request.full_url
            self.assertIn("Bloxtomation-charts", request.get_header("User-agent"))
            if "get-sorts" in url:
                token = url.split("sortsPageToken=")[1] if "sortsPageToken=" in url else None
                return FakeResponse(json.dumps(pages[token]).encode())
            ids = url.split("universeIds=")[1].split(",")
            seen_batches.append(len(ids))
            return FakeResponse(json.dumps({"data": [{"id": int(i)} for i in ids]}).encode())

        client = Client(delay=0, opener=opener, sleep=lambda s: None)
        sorts = client.sorts()
        self.assertEqual([s["sortId"] for s in sorts], ["a", "b"])
        details = client.details(range(1, 121))
        self.assertEqual(seen_batches, [50, 50, 20])
        self.assertEqual(len(details), 120)


class SnapshotCommandTests(Fixture):
    def test_minimum_interval_is_enforced(self) -> None:
        recent = snap(datetime.now(timezone.utc).replace(microsecond=0) - timedelta(minutes=5), {"x": [api_game(1, 5)]})
        store.write_snapshot(self.dir, recent)
        with mock.patch.object(cli, "Client") as fake, redirect_stdout(io.StringIO()) as out:
            code = cli.main(["--data-dir", str(self.dir), "snapshot"])
        self.assertEqual(code, 0)
        fake.assert_not_called()
        self.assertIn("minimum interval", out.getvalue())

    def test_snapshot_saves_with_mocked_client(self) -> None:
        with mock.patch.object(cli, "Client") as fake, redirect_stdout(io.StringIO()):
            instance = fake.return_value
            instance.sorts.return_value = [{"sortId": "top-trending", "contentType": "Games", "games": [api_game(9, 50)]}]
            instance.details.return_value = {9: {"id": 9, "visits": 3}}
            instance.requests = 2
            code = cli.main(["--data-dir", str(self.dir), "snapshot", "--delay", "0"])
        self.assertEqual(code, 0)
        self.assertEqual(fake.call_args.kwargs["delay"], 0.5, "delay is clamped to at least 0.5 s")
        self.assertEqual(len(store.list_snapshots(self.dir)), 1)


if __name__ == "__main__":
    unittest.main()
