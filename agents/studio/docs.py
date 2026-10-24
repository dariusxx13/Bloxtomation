"""Validation for briefs and handoff notes (vault: 16-ai-studio-operations/build-briefs.md).

A brief may use ``Field: value`` lines (the vault template) or ``## Field`` headings.
"""

from __future__ import annotations

import re
from typing import Dict, List, Tuple

BRIEF_FIELDS = [
    "Title",
    "Owner",
    "Game / stage",
    "Outcome",
    "Context",
    "Requirements",
    "Out of scope",
    "Constraints",
    "Acceptance criteria",
    "Evidence to return",
    "Dependencies",
    "Hand off to",
]
BRIEF_REQUIRED = ["Outcome", "Requirements", "Acceptance criteria", "Evidence to return"]
OUTCOMES = ["click", "stay", "return", "spend", "safety"]

HANDOFF_FIELDS = ["Summary", "Evidence", "Next", "Open questions", "Gate criteria", "Files"]
HANDOFF_REQUIRED = ["Summary", "Evidence", "Next", "Open questions"]

CRITERION_ID = re.compile(r"\b(PITCH|DESIGN|PROTO|BUILD|POLISH|RC|LIVE|REVIEW)-\d\d\b")


def parse_sections(text: str, fields: List[str]) -> Dict[str, str]:
    """Returns {field: content} for the known fields found in the text (case-insensitive)."""
    lookup = {field.lower(): field for field in fields}
    sections: Dict[str, List[str]] = {}
    current = None
    for raw in text.splitlines():
        line = raw.rstrip()
        heading = re.match(r"^\s*#{1,4}\s*(.+?)\s*:?\s*$", line)
        inline = re.match(r"^\s*([A-Za-z][A-Za-z /]+?)\s*:\s*(.*)$", line)
        if heading and heading.group(1).lower() in lookup:
            current = lookup[heading.group(1).lower()]
            sections.setdefault(current, [])
            continue
        if inline and inline.group(1).lower() in lookup:
            current = lookup[inline.group(1).lower()]
            sections.setdefault(current, [])
            if inline.group(2).strip():
                sections[current].append(inline.group(2).strip())
            continue
        if current is not None:
            sections[current].append(line)
    return {field: "\n".join(lines).strip() for field, lines in sections.items()}


def _meaningful(content: str) -> bool:
    stripped = re.sub(r"[\s\-*>`<>_]+", "", content)
    placeholders = {"", "none", "n/a", "na", "tbd", "todo", "..."}
    return stripped.lower() not in placeholders


def validate_brief(text: str, known_criteria: List[str]) -> Tuple[List[str], Dict[str, str]]:
    """Returns (problems, sections). An empty problem list means the brief can be claimed."""
    sections = parse_sections(text, BRIEF_FIELDS)
    problems: List[str] = []
    for field in BRIEF_REQUIRED:
        if field not in sections or not _meaningful(sections[field]):
            problems.append(f"missing or empty '{field}'")
    outcome = sections.get("Outcome", "").lower()
    if outcome and not any(word in outcome for word in OUTCOMES):
        problems.append("'Outcome' must name one of: click, stay, return, spend, safety")
    criteria = sections.get("Acceptance criteria", "")
    if criteria and not re.search(r"^\s*([-*]|\d+[.)])\s+\S", criteria, re.M):
        problems.append("'Acceptance criteria' needs at least one bullet, one observable check per line")
    for cid in sorted(set(m.group(0) for m in CRITERION_ID.finditer(text))):
        if cid not in known_criteria:
            problems.append(f"unknown gate criterion {cid}")
    return problems, sections


def validate_handoff(text: str, known_criteria: List[str]) -> Tuple[List[str], Dict[str, str]]:
    sections = parse_sections(text, HANDOFF_FIELDS)
    problems: List[str] = []
    for field in HANDOFF_REQUIRED:
        if field not in sections:
            problems.append(f"missing section '{field}'")
    if "Evidence" in sections and not _meaningful(sections["Evidence"]):
        problems.append("'Evidence' is empty: show build output, test results, screenshots, numbers or links")
    if "Summary" in sections and not _meaningful(sections["Summary"]):
        problems.append("'Summary' is empty")
    for cid in sorted(set(m.group(0) for m in CRITERION_ID.finditer(text))):
        if cid not in known_criteria:
            problems.append(f"unknown gate criterion {cid}")
    return problems, sections


def criteria_in(text: str) -> List[str]:
    return sorted(set(m.group(0) for m in CRITERION_ID.finditer(text)))
