#!/usr/bin/env python3
"""PreToolUse guard for the studio's house rules (configured in .claude/settings.json).

Blocks, for every agent and the main session:
  - publishing a place (Open Cloud versionType=Published, `rojo upload`, `mantle deploy`)
  - running human-only checkpoints (`studioctl.py human ...`)
  - hand edits to the studio state file (use studioctl instead)
Exit code 2 blocks the tool call and shows the reason to the agent. Anything else is allowed.
"""

from __future__ import annotations

import json
import re
import sys
from typing import Any, Dict, Optional

PUBLISH_PATTERNS = [
    (re.compile(r"versiontype\s*[=:]\s*[\"']?published", re.I), "Open Cloud publish (versionType=Published)"),
    (re.compile(r"\brojo\s+upload\b", re.I), "`rojo upload` (it publishes the place)"),
    (re.compile(r"\bmantle\s+deploy\b", re.I), "`mantle deploy` (it publishes)"),
]
HUMAN_ONLY = re.compile(r"studioctl(\.py)?[\"']?\s+(--json\s+)?human\b")
STATE_FILE = re.compile(r"(^|[\\/])workspace[\\/]state\.json$")
STATE_WRITE_IN_SHELL = re.compile(
    r"(>>?\s*|\btee\s+(-a\s+)?|\bsed\s+-i\b[^|;&]*?|\b(mv|cp)\s+[^|;&]*?\s)[\"']?[^\s\"'|;&]*workspace[\\/]state\.json"
)


def decide(event: Dict[str, Any]) -> Optional[str]:
    """Returns a block reason, or None to allow."""
    tool = event.get("tool_name", "")
    tool_input = event.get("tool_input") or {}
    if tool == "Bash":
        command = str(tool_input.get("command", ""))
        for pattern, label in PUBLISH_PATTERNS:
            if pattern.search(command):
                return (
                    f"Blocked: {label}. House rule: automation never publishes. Upload a Saved version with "
                    "template/scripts/upload-place.luau and put the publish on the human's list "
                    "(studioctl.py escalate --kind publish)."
                )
        if HUMAN_ONLY.search(command):
            return (
                "Blocked: `studioctl.py human ...` records a human decision. Agents never approve their own work; "
                "put the decision on the board and let the person run it."
            )
        if STATE_WRITE_IN_SHELL.search(command):
            return "Blocked: workspace/state.json is written only by studioctl.py."
    if tool in ("Edit", "Write", "MultiEdit", "NotebookEdit"):
        path = str(tool_input.get("file_path", "") or tool_input.get("notebook_path", ""))
        if STATE_FILE.search(path):
            return "Blocked: workspace/state.json is written only by studioctl.py (it holds the lock and validates)."
    return None


def main() -> int:
    try:
        event = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0  # never break the session on unexpected input
    reason = decide(event)
    if reason:
        print(reason, file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
