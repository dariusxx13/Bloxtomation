"""Stage gates (vault: 16-ai-studio-operations/quality-gates.md, machine copy in agents/gates/criteria.json).

A gate review is a JSON file with a verdict and evidence for every criterion of one stage:

    {
      "game": "crystal-tap", "stage": "build", "build": "3f2a9c1",
      "results": {
        "BUILD-01": {"verdict": "pass", "evidence": "games/crystal-tap/checks/20261024T101500Z-3f2a9c1.json"},
        "BUILD-05": {"verdict": "fail", "evidence": "...", "needed": "server-side price check in Shop.buy"},
        "BUILD-12": {"verdict": "waived", "evidence": "...", "reason": "no external assets yet"}
      }
    }

Mechanical criteria (build, lint, tests) must cite a passing check record for the same build, produced by
``studioctl.py check``: the Gatekeeper re-runs them instead of trusting reports.
"""

from __future__ import annotations

import json
import re
from functools import lru_cache
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

from .store import STAGES, repo_root

VERDICTS = ("pass", "fail", "waived")
BUILD_STAGES = {"build", "polish", "rc"}
CHECK_PATH = re.compile(r"games/[A-Za-z0-9_-]+/checks/[A-Za-z0-9_.-]+\.json")


@lru_cache(maxsize=1)
def load() -> Dict[str, Any]:
    return json.loads((repo_root() / "agents" / "gates" / "criteria.json").read_text(encoding="utf-8"))


def all_ids() -> List[str]:
    return [c["id"] for c in load()["criteria"]]


def criteria_for(stage: str) -> List[Dict[str, Any]]:
    if stage not in STAGES:
        raise ValueError(f"unknown stage {stage}")
    return [c for c in load()["criteria"] if c["stage"] == stage]


def template(game: str, stage: str, build: Optional[str]) -> Dict[str, Any]:
    results: Dict[str, Dict[str, str]] = {}
    for criterion in criteria_for(stage):
        results[criterion["id"]] = {"verdict": "", "evidence": "", "criterion": criterion["text"]}
    review: Dict[str, Any] = {"game": game, "stage": stage, "results": results}
    if stage in BUILD_STAGES:
        review["build"] = build or ""
    return review


def _load_check(path_text: str) -> Optional[Dict[str, Any]]:
    path = repo_root() / path_text
    if not path.exists():
        return None
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return None


def _cited_passing_check(evidence: str, build: str, release: bool) -> bool:
    for match in CHECK_PATH.finditer(evidence):
        record = _load_check(match.group(0))
        if record and record.get("passed") is True and record.get("build") == build:
            if not release or record.get("release") is True:
                return True
    return False


def validate_review(review: Dict[str, Any], game: str, stage: str) -> Tuple[List[str], Dict[str, Any]]:
    """Returns (problems, summary). Problems mean the review itself is malformed and is not recorded."""
    problems: List[str] = []
    if review.get("game") != game:
        problems.append(f"review is for game '{review.get('game')}', expected '{game}'")
    if review.get("stage") != stage:
        problems.append(f"review is for stage '{review.get('stage')}', expected '{stage}'")
    build = str(review.get("build") or "")
    if stage in BUILD_STAGES and not build:
        problems.append("'build' (git hash from `studioctl.py check`) is required for this stage")

    expected = {c["id"] for c in criteria_for(stage)}
    results: Dict[str, Any] = review.get("results") or {}
    for cid in sorted(expected - set(results)):
        problems.append(f"{cid}: missing (every criterion needs pass, fail or waived)")
    for cid in sorted(set(results) - expected):
        problems.append(f"{cid}: not a {stage} criterion")

    failed: List[str] = []
    waived: List[str] = []
    passed: List[str] = []
    mechanical = load().get("mechanical", {})
    for cid in sorted(expected & set(results)):
        entry = results[cid] or {}
        verdict = str(entry.get("verdict", "")).lower()
        evidence = str(entry.get("evidence", "")).strip()
        if verdict not in VERDICTS:
            problems.append(f"{cid}: verdict must be pass, fail or waived")
            continue
        if verdict == "pass":
            if not evidence:
                problems.append(f"{cid}: pass needs evidence")
            elif cid in mechanical and not _cited_passing_check(evidence, build, release=False):
                problems.append(
                    f"{cid}: cite a passing check record for build {build or '?'} (run `studioctl.py check <game>`)"
                )
            passed.append(cid)
        elif verdict == "fail":
            if not str(entry.get("needed", "")).strip():
                problems.append(f"{cid}: a failure must say what evidence would pass ('needed')")
            failed.append(cid)
        else:
            if not str(entry.get("reason", "")).strip():
                problems.append(f"{cid}: a waiver needs a written 'reason' (and human acceptance)")
            waived.append(cid)

    if stage == "rc" and "RC-04" in passed:
        evidence = str((results.get("RC-04") or {}).get("evidence", ""))
        if not _cited_passing_check(evidence, build, release=True):
            problems.append("RC-04: cite a passing `studioctl.py check <game> --release` record for this exact build")

    verdict = "fail" if failed else "pass"
    summary = {"verdict": verdict, "passed": passed, "failed": failed, "waived": waived, "build": build}
    return problems, summary


def failure_stats(records: List[Dict[str, Any]]) -> List[Tuple[str, int]]:
    counts: Dict[str, int] = {}
    for record in records:
        for cid in record.get("failed", []):
            counts[cid] = counts.get(cid, 0) + 1
    return sorted(counts.items(), key=lambda item: (-item[1], item[0]))


def criterion_text(cid: str) -> str:
    for criterion in load()["criteria"]:
        if criterion["id"] == cid:
            return criterion["text"]
    return ""


def review_path(game: str, stage: str, number: int) -> Path:
    return repo_root() / "games" / game / "gates" / f"{stage}-{number:02d}.json"
