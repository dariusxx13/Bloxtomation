"""Keyword routing: suggests which role should own a piece of work (agents/routing.json)."""

from __future__ import annotations

import json
import re
from functools import lru_cache
from typing import Any, Dict, List, Tuple

from .store import repo_root


@lru_cache(maxsize=1)
def table() -> Dict[str, Any]:
    return json.loads((repo_root() / "agents" / "routing.json").read_text(encoding="utf-8"))


def _matches(text: str, keyword: str) -> int:
    # Whole-word-ish match at the start of a word; keywords may contain spaces or end mid-word ("priorit").
    pattern = r"(?<![a-z0-9])" + re.escape(keyword.lower())
    return len(re.findall(pattern, text))


def rank(text: str) -> List[Tuple[str, int]]:
    """Roles with a positive score, best first (ties keep table order)."""
    lowered = text.lower()
    scored: List[Tuple[str, int, int]] = []
    for order, entry in enumerate(table()["roles"]):
        score = sum(weight * _matches(lowered, keyword) for keyword, weight in entry["keywords"].items())
        if score > 0:
            scored.append((entry["role"], score, order))
    scored.sort(key=lambda item: (-item[1], item[2]))
    return [(role, score) for role, score, _ in scored]


def route(text: str) -> str:
    ranked = rank(text)
    return ranked[0][0] if ranked else table()["default"]
