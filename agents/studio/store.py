"""Studio state: one JSON file guarded by an exclusive file lock.

Several agents run ``studioctl`` at the same time, so every read-modify-write happens inside
``Store.open()``, which holds the lock, loads ``workspace/state.json`` and writes it back atomically.
Never edit state.json by hand (the guard hook blocks agents from doing it).
"""

from __future__ import annotations

import contextlib
import json
import os
import tempfile
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Iterator, List, Optional

SCHEMA_VERSION = 1

STAGES: List[str] = ["pitch", "design", "prototype", "build", "polish", "rc", "live", "review"]
HUMAN_STAGES = {"pitch", "prototype", "rc"}
TASK_STATUSES = ["draft", "queued", "working", "needs_review", "done", "dropped"]
ROLES: List[str] = [
    "director",
    "scout",
    "designer",
    "economist",
    "monetization-designer",
    "engineer",
    "interface-designer",
    "worldbuilder",
    "artist",
    "storefront",
    "qa-tester",
    "newcomer",
    "security-reviewer",
    "gatekeeper",
    "analyst",
]
# Roles that need a Roblox Studio instance for most of their work.
STUDIO_ROLES = {"engineer", "worldbuilder", "interface-designer", "qa-tester", "newcomer", "artist"}
ESCALATION_KINDS = ["money", "publish", "policy", "data", "decision"]


class StudioError(Exception):
    """A user-facing error: printed without a traceback, exit code 1."""


def repo_root() -> Path:
    override = os.environ.get("STUDIO_ROOT")
    if override:
        return Path(override).resolve()
    return Path(__file__).resolve().parents[2]


def workspace_dir() -> Path:
    return repo_root() / "workspace"


def games_dir() -> Path:
    return repo_root() / "games"


def now_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def now_epoch() -> float:
    return time.time()


def new_state(studio_instances: int = 1, lease_minutes: int = 45) -> Dict[str, Any]:
    return {
        "version": SCHEMA_VERSION,
        "created": now_iso(),
        "config": {
            "studioInstances": [f"studio-{i}" for i in range(1, studio_instances + 1)],
            "leaseMinutes": lease_minutes,
        },
        "counters": {"task": 0, "escalation": 0, "gate": 0},
        "games": {},
        "tasks": {},
        "leases": {},
        "gates": [],
        "escalations": {},
        "log": [],
    }


@contextlib.contextmanager
def _locked(path: Path) -> Iterator[None]:
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "a+") as handle:
        if os.name == "nt":  # pragma: no cover - exercised on Windows only
            import msvcrt

            handle.seek(0)
            while True:
                try:
                    msvcrt.locking(handle.fileno(), msvcrt.LK_LOCK, 1)
                    break
                except OSError:
                    time.sleep(0.05)
            try:
                yield
            finally:
                handle.seek(0)
                msvcrt.locking(handle.fileno(), msvcrt.LK_UNLCK, 1)
        else:
            import fcntl

            fcntl.flock(handle.fileno(), fcntl.LOCK_EX)
            try:
                yield
            finally:
                fcntl.flock(handle.fileno(), fcntl.LOCK_UN)


def _atomic_write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=str(path.parent), prefix=".state-", suffix=".tmp")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            handle.write(text)
        os.replace(tmp, path)
    except BaseException:
        if os.path.exists(tmp):
            os.unlink(tmp)
        raise


class Store:
    """Access to the state file. Use ``with Store.open() as state:`` for every change."""

    @staticmethod
    def state_path() -> Path:
        return workspace_dir() / "state.json"

    @staticmethod
    def exists() -> bool:
        return Store.state_path().exists()

    @staticmethod
    @contextlib.contextmanager
    def open(create: bool = False, **create_args: Any) -> Iterator[Dict[str, Any]]:
        path = Store.state_path()
        with _locked(workspace_dir() / ".lock"):
            if path.exists():
                state = json.loads(path.read_text(encoding="utf-8"))
                if state.get("version") != SCHEMA_VERSION:
                    raise StudioError(
                        f"state.json has schema version {state.get('version')}, this tool expects {SCHEMA_VERSION}"
                    )
            elif create:
                state = new_state(**create_args)
            else:
                raise StudioError("No studio workspace yet. Run: python3 agents/studioctl.py init")
            before = json.dumps(state, sort_keys=True)
            yield state
            after = json.dumps(state, sort_keys=True)
            if after != before or not path.exists():
                _atomic_write(path, json.dumps(state, indent=2, sort_keys=True) + "\n")

    @staticmethod
    def read() -> Dict[str, Any]:
        """Read-only snapshot (no lock held after return)."""
        with Store.open() as state:
            return json.loads(json.dumps(state))


def log(state: Dict[str, Any], actor: str, message: str) -> None:
    """Appends to the bounded activity log shown on the board."""
    entries: List[Dict[str, str]] = state.setdefault("log", [])
    entries.append({"at": now_iso(), "by": actor, "message": message})
    del entries[:-200]


def next_id(state: Dict[str, Any], counter: str, prefix: str) -> str:
    state["counters"][counter] = state["counters"].get(counter, 0) + 1
    return f"{prefix}-{state['counters'][counter]:04d}"


def require_role(role: str) -> str:
    if role not in ROLES:
        raise StudioError(f"Unknown role '{role}'. Roles: {', '.join(ROLES)}")
    return role


def require_game(state: Dict[str, Any], game_id: str) -> Dict[str, Any]:
    game = state["games"].get(game_id)
    if not game:
        raise StudioError(f"Unknown game '{game_id}'. Create it with: studioctl.py game new {game_id} --title ...")
    return game


def require_task(state: Dict[str, Any], task_id: str) -> Dict[str, Any]:
    task = state["tasks"].get(task_id)
    if not task:
        raise StudioError(f"Unknown task '{task_id}'")
    return task


def relative(path: Path) -> str:
    try:
        return str(path.resolve().relative_to(repo_root()))
    except ValueError:
        return str(path)


def optional_text(path: Optional[str]) -> Optional[str]:
    if path is None:
        return None
    if path == "-":
        import sys

        return sys.stdin.read()
    file = Path(path)
    if not file.exists():
        raise StudioError(f"File not found: {path}")
    return file.read_text(encoding="utf-8")
