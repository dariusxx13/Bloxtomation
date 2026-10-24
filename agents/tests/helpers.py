"""Shared helpers: every test runs against a throwaway studio root (STUDIO_ROOT)."""

from __future__ import annotations

import contextlib
import io
import json
import os
import shutil
import sys
import tempfile
import unittest
from pathlib import Path
from typing import List, Tuple

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "agents"))

from studio import cli  # noqa: E402

BRIEF = """Title: Build the shop
Owner: engineer
Game / stage: demo / build
Outcome: spend: players can buy upgrades
Context: GDD section 4
Requirements:
  1. Server-side prices
Out of scope: art
Constraints: prices from config
Acceptance criteria:
  - buying deducts coins on the server (BUILD-05)
Evidence to return: test output
Dependencies: none
Hand off to: qa-tester
"""

HANDOFF = """## Summary
Built it.

## Evidence
- tests passed: 47 passed, 0 failed

## Next
QA plays it.

## Open questions
None
"""


class StudioTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self.root = Path(tempfile.mkdtemp(prefix="studio-test-"))
        (self.root / "agents" / "gates").mkdir(parents=True)
        shutil.copy(REPO / "agents" / "gates" / "criteria.json", self.root / "agents" / "gates" / "criteria.json")
        shutil.copy(REPO / "agents" / "routing.json", self.root / "agents" / "routing.json")
        self._env = os.environ.get("STUDIO_ROOT")
        os.environ["STUDIO_ROOT"] = str(self.root)

    def tearDown(self) -> None:
        if self._env is None:
            os.environ.pop("STUDIO_ROOT", None)
        else:
            os.environ["STUDIO_ROOT"] = self._env
        shutil.rmtree(self.root, ignore_errors=True)

    def run_cli(self, *args: str, stdin: str = "") -> Tuple[int, str]:
        out = io.StringIO()
        err = io.StringIO()
        old_stdin = sys.stdin
        sys.stdin = io.StringIO(stdin)
        try:
            with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
                code = cli.main(list(args))
        finally:
            sys.stdin = old_stdin
        return code, out.getvalue() + err.getvalue()

    def ok(self, *args: str, stdin: str = "") -> str:
        code, text = self.run_cli(*args, stdin=stdin)
        self.assertEqual(code, 0, text)
        return text

    def state(self) -> dict:
        return json.loads((self.root / "workspace" / "state.json").read_text())

    def write(self, name: str, text: str) -> str:
        path = self.root / name
        path.write_text(text)
        return str(path)

    def new_game(self, game: str = "demo") -> None:
        self.ok("init")
        self.ok("game", "new", game, "--title", "Demo")

    def queued_task(self, owner: str = "engineer", after: List[str] = ()) -> str:
        args = ["task", "add", "--game", "demo", "--title", "Build the shop", "--owner", owner, "--brief", "-"]
        if after:
            args += ["--after", ",".join(after)]
        text = self.ok(*args, stdin=BRIEF)
        return text.split()[0]
