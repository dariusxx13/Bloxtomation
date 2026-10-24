"""studioctl: the studio's task queue, Studio leases, stage gates, human checkpoints and board.

Run ``python3 agents/studioctl.py --help``. Every command is safe to run from several agents at once.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional

from . import docs, gates, routing
from .store import (
    ESCALATION_KINDS,
    HUMAN_STAGES,
    ROLES,
    STAGES,
    STUDIO_ROLES,
    Store,
    StudioError,
    games_dir,
    log,
    next_id,
    now_epoch,
    now_iso,
    optional_text,
    relative,
    repo_root,
    require_game,
    require_role,
    require_task,
    workspace_dir,
)

EXIT_UNAVAILABLE = 3
GAME_ID = re.compile(r"^[a-z0-9][a-z0-9-]{1,40}$")
GAME_SUBDIRS = ["docs", "tasks", "handoffs", "gates", "checks", "playtests"]
TEMPLATE_IGNORE = shutil.ignore_patterns(".tools", "*.rbxl", "*.rbxlx", "sourcemap.json", "economy-sheet.md", "*.lock")
HASH_SKIP = {".tools", "build.rbxl", "sourcemap.json", "economy-sheet.md"}


def emit(args: argparse.Namespace, text: str, data: Any = None) -> None:
    if getattr(args, "json", False) and data is not None:
        print(json.dumps(data, indent=2, sort_keys=True))
    else:
        print(text)


def game_path(game_id: str) -> Path:
    return games_dir() / game_id


# --- init -------------------------------------------------------------------------------------------


def cmd_init(args: argparse.Namespace) -> int:
    created = not Store.exists()
    with Store.open(create=True, studio_instances=args.studios, lease_minutes=args.lease_minutes) as state:
        if not created:
            if args.studios_set:
                state["config"]["studioInstances"] = [f"studio-{i}" for i in range(1, args.studios + 1)]
            if args.lease_minutes_set:
                state["config"]["leaseMinutes"] = args.lease_minutes
        log(state, "human", "workspace initialised" if created else "workspace config updated")
        config = state["config"]
    write_board()
    print(
        f"{'Created' if created else 'Updated'} {relative(Store.state_path())}: "
        f"{len(config['studioInstances'])} Studio instance(s), {config['leaseMinutes']}-minute leases."
    )
    return 0


# --- games ------------------------------------------------------------------------------------------


def cmd_game_new(args: argparse.Namespace) -> int:
    game_id = args.game
    if not GAME_ID.match(game_id):
        raise StudioError("Game ids are lowercase letters, digits and dashes (2-41 chars), e.g. crystal-tap")
    root = game_path(game_id)
    with Store.open() as state:
        if game_id in state["games"]:
            raise StudioError(f"Game '{game_id}' already exists")
        state["games"][game_id] = {
            "id": game_id,
            "title": args.title,
            "genre": args.genre or "",
            "stage": "pitch",
            "status": "active",
            "awaitingHuman": None,
            "created": now_iso(),
            "history": [{"stage": "pitch", "at": now_iso()}],
        }
        log(state, args.by, f"created game {game_id} ({args.title})")
    for sub in GAME_SUBDIRS:
        (root / sub).mkdir(parents=True, exist_ok=True)
    card = root / "README.md"
    if not card.exists():
        card.write_text(
            f"# {args.title}\n\n"
            f"Game id `{game_id}`. Stage and tasks live in the studio board (`workspace/BOARD.md`).\n\n"
            "| Folder | Contents |\n|---|---|\n"
            "| `docs/` | pitch.md, gdd.md, economy-sheet.md, catalog.md, art-direction.md, asset-index.md, launch-plan.md |\n"
            "| `tasks/` | one brief per task (`T-0001.md`) |\n"
            "| `handoffs/` | one handoff note per finished task |\n"
            "| `gates/` | gate reviews (`build-01.json`) |\n"
            "| `checks/` | mechanical check records and logs from `studioctl.py check` |\n"
            "| `playtests/` | QA and newcomer playtest reports with screenshots |\n"
            "| `project/` | the Rojo project (a copy of `template/`) |\n",
            encoding="utf-8",
        )
    project = root / "project"
    if args.from_template and not project.exists():
        shutil.copytree(repo_root() / "template", project, ignore=TEMPLATE_IGNORE)
    write_board()
    print(f"Created game {game_id} at {relative(root)} (stage: pitch).")
    if args.from_template:
        print(f"Project copied from template/ to {relative(project)}.")
    return 0


def cmd_game_list(args: argparse.Namespace) -> int:
    state = Store.read()
    rows = sorted(state["games"].values(), key=lambda g: g["created"])
    if not rows:
        print("No games yet. Create one: studioctl.py game new <id> --title \"...\" --from-template")
        return 0
    data = [{k: g[k] for k in ("id", "title", "stage", "status", "awaitingHuman")} for g in rows]
    text = "\n".join(
        f"{g['id']:<24} {g['stage']:<10} {g['status']:<8} {g['title']}"
        + (f"  [waiting for human: {g['awaitingHuman']}]" if g.get("awaitingHuman") else "")
        for g in rows
    )
    emit(args, text, data)
    return 0


def cmd_game_show(args: argparse.Namespace) -> int:
    state = Store.read()
    game = require_game(state, args.game)
    tasks = [t for t in state["tasks"].values() if t["game"] == args.game]
    gate_records = [g for g in state["gates"] if g["game"] == args.game]
    lines = [
        f"{game['title']} ({game['id']})",
        f"stage: {game['stage']}   status: {game['status']}   genre: {game.get('genre') or '-'}",
    ]
    if game.get("awaitingHuman"):
        lines.append(f"waiting for a human decision on: {game['awaitingHuman']}")
    counts: Dict[str, int] = {}
    for task in tasks:
        counts[task["status"]] = counts.get(task["status"], 0) + 1
    lines.append("tasks: " + (", ".join(f"{k} {v}" for k, v in sorted(counts.items())) or "none"))
    for record in gate_records[-5:]:
        lines.append(f"gate {record['stage']}: {record['verdict']} ({record['at']}) {record['path']}")
    emit(args, "\n".join(lines), {"game": game, "tasks": tasks, "gates": gate_records})
    return 0


def cmd_game_status(args: argparse.Namespace) -> int:
    with Store.open() as state:
        game = require_game(state, args.game)
        game["status"] = args.status
        log(state, args.by, f"{args.game} status -> {args.status}")
    write_board()
    print(f"{args.game} is now {args.status}.")
    return 0


# --- tasks ------------------------------------------------------------------------------------------


def _split_ids(value: Optional[str]) -> List[str]:
    return [item.strip() for item in (value or "").split(",") if item.strip()]


def _brief_path(game: str, task_id: str) -> Path:
    return game_path(game) / "tasks" / f"{task_id}.md"


def _handoff_path(game: str, task_id: str) -> Path:
    return game_path(game) / "handoffs" / f"{task_id}.md"


def _check_brief(text: str) -> List[str]:
    problems, _ = docs.validate_brief(text, gates.all_ids())
    return problems


def cmd_task_add(args: argparse.Namespace) -> int:
    brief = optional_text(args.brief)
    owner = args.owner
    if owner:
        require_role(owner)
    else:
        owner = routing.route(f"{args.title}\n{brief or ''}")
    problems = _check_brief(brief) if brief is not None else ["no brief yet"]
    if brief is not None and problems and not args.draft:
        raise StudioError("Brief is not executable yet:\n  - " + "\n  - ".join(problems) + "\n(use --draft to save it anyway)")
    gate_ids = sorted(set(_split_ids(args.gates)) | set(docs.criteria_in(brief or "")))
    unknown = [cid for cid in gate_ids if cid not in gates.all_ids()]
    if unknown:
        raise StudioError(f"Unknown gate criteria: {', '.join(unknown)}")
    with Store.open() as state:
        game = require_game(state, args.game)
        deps = _split_ids(args.after)
        for dep in deps:
            require_task(state, dep)
        stage = args.stage or game["stage"]
        if stage not in STAGES:
            raise StudioError(f"Unknown stage {stage}")
        task_id = next_id(state, "task", "T")
        status = "queued" if not problems else "draft"
        task = {
            "id": task_id,
            "title": args.title,
            "owner": owner,
            "game": args.game,
            "stage": stage,
            "status": status,
            "deps": deps,
            "gates": gate_ids,
            "brief": None,
            "handoff": None,
            "created": now_iso(),
            "updated": now_iso(),
            "notes": [],
        }
        if brief is not None:
            path = _brief_path(args.game, task_id)
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(brief, encoding="utf-8")
            task["brief"] = relative(path)
        state["tasks"][task_id] = task
        log(state, args.by, f"added {task_id} '{args.title}' for {owner} ({status})")
    write_board()
    routed = "" if args.owner else " (routed by keywords)"
    print(f"{task_id} -> {owner}{routed}: {status}")
    if status == "draft":
        print(f"Draft until it has an executable brief: studioctl.py task brief {task_id} --brief <file>")
    return 0


def cmd_task_brief(args: argparse.Namespace) -> int:
    brief = optional_text(args.brief) or ""
    problems = _check_brief(brief)
    if problems:
        raise StudioError("Brief is not executable yet:\n  - " + "\n  - ".join(problems))
    with Store.open() as state:
        task = require_task(state, args.task)
        if task["status"] not in ("draft", "queued"):
            raise StudioError(f"{args.task} is {task['status']}; briefs change only before work starts")
        path = _brief_path(task["game"], task["id"])
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(brief, encoding="utf-8")
        task["brief"] = relative(path)
        task["gates"] = sorted(set(task["gates"]) | set(docs.criteria_in(brief)))
        task["status"] = "queued"
        task["updated"] = now_iso()
        log(state, args.by, f"brief attached to {args.task}")
    write_board()
    print(f"{args.task} is queued.")
    return 0


def _deps_done(state: Dict[str, Any], task: Dict[str, Any]) -> bool:
    return all(state["tasks"].get(dep, {}).get("status") == "done" for dep in task["deps"])


def _task_line(task: Dict[str, Any]) -> str:
    return f"{task['id']}  {task['status']:<12} {task['owner']:<22} {task['game']:<18} {task['title']}"


def cmd_task_list(args: argparse.Namespace) -> int:
    state = Store.read()
    tasks = sorted(state["tasks"].values(), key=lambda t: t["id"])
    if args.game:
        tasks = [t for t in tasks if t["game"] == args.game]
    if args.owner:
        tasks = [t for t in tasks if t["owner"] == args.owner]
    if args.status:
        tasks = [t for t in tasks if t["status"] == args.status]
    elif not args.all:
        tasks = [t for t in tasks if t["status"] not in ("done", "dropped")]
    emit(args, "\n".join(_task_line(t) for t in tasks) or "No matching tasks.", tasks)
    return 0


def cmd_task_show(args: argparse.Namespace) -> int:
    state = Store.read()
    task = require_task(state, args.task)
    lines = [_task_line(task), f"stage: {task['stage']}   deps: {', '.join(task['deps']) or '-'}"]
    lines.append(f"gate criteria: {', '.join(task['gates']) or '-'}")
    lines.append(f"brief: {task['brief'] or '(none)'}")
    lines.append(f"handoff: {task['handoff'] or '(none)'}")
    for note in task["notes"]:
        lines.append(f"note {note['at']} {note['by']}: {note['text']}")
    emit(args, "\n".join(lines), task)
    return 0


def cmd_task_next(args: argparse.Namespace) -> int:
    role = require_role(args.owner)
    with Store.open() as state:
        working = [t for t in state["tasks"].values() if t["owner"] == role and t["status"] == "working"]
        if working:
            task = sorted(working, key=lambda t: t["id"])[0]
            emit(args, f"Finish {task['id']} first: {task['title']} (brief: {task['brief']})", {"task": task, "claimed": False})
            return 0
        candidates = sorted(
            (
                t
                for t in state["tasks"].values()
                if t["owner"] == role
                and t["status"] == "queued"
                and state["games"].get(t["game"], {}).get("status") == "active"
            ),
            key=lambda t: t["id"],
        )
        runnable = [t for t in candidates if _deps_done(state, t)]
        if not runnable:
            blocked = ", ".join(t["id"] for t in candidates) or "none"
            emit(args, f"No runnable tasks for {role} (queued but blocked: {blocked}).", {"task": None, "claimed": False})
            return 0
        task = runnable[0]
        task["status"] = "working"
        task["started"] = now_iso()
        task["updated"] = now_iso()
        log(state, role, f"started {task['id']}")
        claimed = json.loads(json.dumps(task))
    write_board()
    studio_hint = " This role usually needs Studio: acquire a lease first." if role in STUDIO_ROLES else ""
    emit(args, f"Claimed {claimed['id']}: {claimed['title']}\nbrief: {claimed['brief']}{studio_hint}", {"task": claimed, "claimed": True})
    return 0


def cmd_task_submit(args: argparse.Namespace) -> int:
    text = optional_text(args.handoff) or ""
    problems, _ = docs.validate_handoff(text, gates.all_ids())
    if problems:
        raise StudioError("Handoff is incomplete:\n  - " + "\n  - ".join(problems))
    with Store.open() as state:
        task = require_task(state, args.task)
        if task["status"] != "working":
            raise StudioError(f"{args.task} is {task['status']}; only working tasks can be submitted")
        path = _handoff_path(task["game"], task["id"])
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
        task["handoff"] = relative(path)
        task["status"] = "needs_review"
        task["submitted"] = now_iso()
        task["updated"] = now_iso()
        held = [name for name, lease in state["leases"].items() if lease["holder"] == task["owner"]]
        log(state, task["owner"], f"submitted {task['id']} for review")
    write_board()
    print(f"{args.task} submitted for review ({relative(path)}).")
    if held:
        print(f"Reminder: {task['owner']} still holds Studio lease {', '.join(held)}. Release it when finished.")
    return 0


def _set_status(task_id: str, status: str, actor: str, note: Optional[str], allowed: List[str]) -> Dict[str, Any]:
    with Store.open() as state:
        task = require_task(state, task_id)
        if task["status"] not in allowed:
            raise StudioError(f"{task_id} is {task['status']}; expected one of {', '.join(allowed)}")
        task["status"] = status
        task["updated"] = now_iso()
        if note:
            task["notes"].append({"at": now_iso(), "by": actor, "text": note})
        log(state, actor, f"{task_id} -> {status}" + (f": {note}" if note else ""))
        result = json.loads(json.dumps(task))
    write_board()
    return result


def cmd_task_done(args: argparse.Namespace) -> int:
    allowed = ["needs_review", "working"] if args.force else ["needs_review"]
    _set_status(args.task, "done", args.by, args.note, allowed)
    print(f"{args.task} done.")
    return 0


def cmd_task_return(args: argparse.Namespace) -> int:
    _set_status(args.task, "queued", args.by, f"returned: {args.reason}", ["needs_review", "working"])
    print(f"{args.task} returned to the queue with your reason.")
    return 0


def cmd_task_drop(args: argparse.Namespace) -> int:
    _set_status(args.task, "dropped", args.by, f"dropped: {args.reason}", ["draft", "queued", "working", "needs_review"])
    print(f"{args.task} dropped.")
    return 0


def cmd_task_note(args: argparse.Namespace) -> int:
    with Store.open() as state:
        task = require_task(state, args.task)
        task["notes"].append({"at": now_iso(), "by": args.by, "text": args.text})
        task["updated"] = now_iso()
    print(f"Note added to {args.task}.")
    return 0


def cmd_route(args: argparse.Namespace) -> int:
    ranked = routing.rank(args.text)
    if not ranked:
        print(f"{routing.table()['default']} (no keywords matched)")
        return 0
    emit(args, "\n".join(f"{role:<22} {score}" for role, score in ranked), ranked)
    return 0


# --- Studio leases ----------------------------------------------------------------------------------


def _expire_leases(state: Dict[str, Any]) -> List[str]:
    expired = [name for name, lease in state["leases"].items() if lease["expires"] < now_epoch()]
    for name in expired:
        log(state, "studioctl", f"lease {name} expired (held by {state['leases'][name]['holder']})")
        del state["leases"][name]
    return expired


def _lease_view(name: str, lease: Dict[str, Any], config: Dict[str, Any]) -> Dict[str, Any]:
    mapping = config.get("studioIds", {}).get(name, {})
    return {
        "instance": name,
        "holder": lease["holder"],
        "task": lease.get("task"),
        "expires": datetime.fromtimestamp(lease["expires"], timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "studioId": mapping.get("studioId"),
        "place": mapping.get("place"),
    }


def cmd_lease_acquire(args: argparse.Namespace) -> int:
    role = require_role(args.agent)
    with Store.open() as state:
        _expire_leases(state)
        config = state["config"]
        minutes = args.minutes or config["leaseMinutes"]
        for name, lease in state["leases"].items():
            if lease["holder"] == role:
                lease["expires"] = now_epoch() + minutes * 60
                if args.task:
                    lease["task"] = args.task
                view = _lease_view(name, lease, config)
                emit(args, f"{role} already holds {name}; extended to {view['expires']}.", view)
                return 0
        free = [name for name in config["studioInstances"] if name not in state["leases"]]
        if not free:
            holders = ", ".join(f"{n} ({l['holder']})" for n, l in state["leases"].items())
            emit(args, f"No Studio instance free: {holders}. Wait, or ask the Director to reprioritise.", {"instance": None})
            return EXIT_UNAVAILABLE
        name = free[0]
        state["leases"][name] = {"holder": role, "task": args.task, "acquired": now_epoch(), "expires": now_epoch() + minutes * 60}
        log(state, role, f"acquired Studio lease {name}")
        view = _lease_view(name, state["leases"][name], config)
    write_board()
    hint = (
        f" Use studio_id {view['studioId']} ({view['place']})."
        if view["studioId"]
        else " Call list_roblox_studios, pick your instance, then record it: studioctl.py lease map "
        f"{name} --studio-id <id> --place <name>."
    )
    emit(args, f"{role} holds {name} until {view['expires']}.{hint}", view)
    return 0


def cmd_lease_release(args: argparse.Namespace) -> int:
    role = require_role(args.agent)
    with Store.open() as state:
        held = [name for name, lease in state["leases"].items() if lease["holder"] == role]
        for name in held:
            del state["leases"][name]
            log(state, role, f"released Studio lease {name}")
    write_board()
    print(f"Released: {', '.join(held)}." if held else f"{role} held no lease.")
    return 0


def cmd_lease_list(args: argparse.Namespace) -> int:
    with Store.open() as state:
        _expire_leases(state)
        config = state["config"]
        views = [_lease_view(n, l, config) for n, l in sorted(state["leases"].items())]
        free = [n for n in config["studioInstances"] if n not in state["leases"]]
    lines = [f"{v['instance']:<10} {v['holder']:<22} task {v['task'] or '-':<8} until {v['expires']}" for v in views]
    lines.append(f"free: {', '.join(free) or 'none'}")
    emit(args, "\n".join(lines), {"leases": views, "free": free})
    return 0


def cmd_lease_map(args: argparse.Namespace) -> int:
    with Store.open() as state:
        if args.instance not in state["config"]["studioInstances"]:
            raise StudioError(f"Unknown instance {args.instance}")
        state["config"].setdefault("studioIds", {})[args.instance] = {"studioId": args.studio_id, "place": args.place or ""}
    print(f"{args.instance} -> studio_id {args.studio_id}")
    return 0


# --- gates ------------------------------------------------------------------------------------------


def cmd_gate_criteria(args: argparse.Namespace) -> int:
    rows = gates.criteria_for(args.stage)
    emit(args, "\n".join(f"{c['id']}  {c['text']}" for c in rows), rows)
    return 0


def cmd_gate_template(args: argparse.Namespace) -> int:
    state = Store.read()
    game = require_game(state, args.game)
    stage = args.stage or game["stage"]
    review = gates.template(args.game, stage, args.build)
    out = Path(args.out) if args.out else game_path(args.game) / "gates" / f"{stage}-draft.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(review, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {relative(out)}: fill verdict and evidence for {len(review['results'])} criteria, then gate record.")
    return 0


def _can_review(game: Dict[str, Any], stage: str) -> bool:
    if stage in ("live", "review"):
        return game["stage"] in ("live", "review")
    return stage == game["stage"]


def cmd_gate_record(args: argparse.Namespace) -> int:
    text = optional_text(args.review) or ""
    try:
        review = json.loads(text)
    except json.JSONDecodeError as error:
        raise StudioError(f"Review is not valid JSON: {error}") from error
    stage = str(review.get("stage", ""))
    if stage not in STAGES:
        raise StudioError("Review needs a 'stage'")
    current = require_game(Store.read(), args.game)
    if not _can_review(current, stage):
        raise StudioError(f"{args.game} is in stage {current['stage']}; cannot record a {stage} gate")
    problems, summary = gates.validate_review(review, args.game, stage)
    if problems:
        raise StudioError("Review not recorded:\n  - " + "\n  - ".join(problems))
    with Store.open() as state:
        game = require_game(state, args.game)
        if not _can_review(game, stage):
            raise StudioError(f"{args.game} is in stage {game['stage']}; cannot record a {stage} gate")
        if game.get("awaitingHuman"):
            raise StudioError(f"{args.game} is waiting for a human decision on {game['awaitingHuman']}")
        number = sum(1 for g in state["gates"] if g["game"] == args.game and g["stage"] == stage) + 1
        path = gates.review_path(args.game, stage, number)
        path.parent.mkdir(parents=True, exist_ok=True)
        stored = dict(review)
        stored["summary"] = summary
        stored["by"] = args.by
        stored["recorded"] = now_iso()
        path.write_text(json.dumps(stored, indent=2) + "\n", encoding="utf-8")
        record = {
            "id": next_id(state, "gate", "G"),
            "game": args.game,
            "stage": stage,
            "verdict": summary["verdict"],
            "failed": summary["failed"],
            "waived": summary["waived"],
            "build": summary["build"],
            "by": args.by,
            "at": now_iso(),
            "path": relative(path),
        }
        state["gates"].append(record)
        outcome = ""
        if summary["verdict"] == "pass" and stage not in ("live", "review"):
            if stage in HUMAN_STAGES or summary["waived"]:
                game["awaitingHuman"] = stage
                reason = "human checkpoint" if stage in HUMAN_STAGES else "waivers need human acceptance"
                outcome = f"Passed. Waiting for the human ({reason})."
            else:
                _advance(game)
                outcome = f"Passed. {args.game} moves to {game['stage']}."
        elif summary["verdict"] == "pass":
            outcome = "Passed."
        else:
            outcome = "Failed: " + ", ".join(summary["failed"])
        log(state, args.by, f"gate {stage} for {args.game}: {summary['verdict']}")
    write_board()
    print(f"Recorded {relative(path)}. {outcome}")
    for cid in summary["failed"]:
        needed = review["results"][cid].get("needed", "")
        print(f"  {cid} {gates.criterion_text(cid)}\n    needed: {needed}")
    return 0


def _advance(game: Dict[str, Any], to: Optional[str] = None) -> None:
    index = STAGES.index(game["stage"])
    target = to or STAGES[min(index + 1, len(STAGES) - 1)]
    game["stage"] = target
    game["history"].append({"stage": target, "at": now_iso()})


def cmd_gate_stats(args: argparse.Namespace) -> int:
    state = Store.read()
    stats = gates.failure_stats(state["gates"])
    if not stats:
        print("No gate failures recorded.")
        return 0
    emit(args, "\n".join(f"{cid:<10} {count:>3}  {gates.criterion_text(cid)}" for cid, count in stats), stats)
    return 0


# --- human checkpoints and escalations ------------------------------------------------------------


def cmd_human_approve(args: argparse.Namespace) -> int:
    with Store.open() as state:
        game = require_game(state, args.game)
        stage = game.get("awaitingHuman")
        if not stage:
            raise StudioError(f"{args.game} is not waiting for a human decision")
        if stage == "prototype":
            if args.decision not in ("continue", "pivot", "stop"):
                raise StudioError("The prototype checkpoint needs --decision continue|pivot|stop")
            if args.decision == "continue":
                _advance(game)
            elif args.decision == "pivot":
                _advance(game, "design")
            else:
                game["status"] = "stopped"
        else:
            _advance(game)
        game["awaitingHuman"] = None
        log(state, "human", f"approved {stage} for {args.game}" + (f" ({args.decision})" if args.decision else "") + (f": {args.note}" if args.note else ""))
        result = f"{args.game}: stage {game['stage']}, status {game['status']}."
    write_board()
    print(result)
    return 0


def cmd_human_reject(args: argparse.Namespace) -> int:
    with Store.open() as state:
        game = require_game(state, args.game)
        stage = game.get("awaitingHuman")
        if not stage:
            raise StudioError(f"{args.game} is not waiting for a human decision")
        game["awaitingHuman"] = None
        log(state, "human", f"rejected {stage} for {args.game}: {args.note}")
    write_board()
    print(f"{args.game} stays in {stage}; the Director plans rework from your note.")
    return 0


def cmd_human_resolve(args: argparse.Namespace) -> int:
    with Store.open() as state:
        escalation = state["escalations"].get(args.escalation)
        if not escalation:
            raise StudioError(f"Unknown escalation {args.escalation}")
        escalation["status"] = "resolved"
        escalation["resolution"] = args.note
        escalation["resolved"] = now_iso()
        log(state, "human", f"resolved {args.escalation}: {args.note}")
    write_board()
    print(f"{args.escalation} resolved.")
    return 0


def cmd_escalate(args: argparse.Namespace) -> int:
    with Store.open() as state:
        if args.game:
            require_game(state, args.game)
        escalation_id = next_id(state, "escalation", "E")
        state["escalations"][escalation_id] = {
            "id": escalation_id,
            "game": args.game,
            "kind": args.kind,
            "note": args.note,
            "by": args.by,
            "status": "open",
            "created": now_iso(),
        }
        log(state, args.by, f"escalated {escalation_id} ({args.kind})")
    write_board()
    print(f"{escalation_id} is on the human's list. Do not proceed with the escalated action until it is resolved.")
    return 0


# --- mechanical checks ------------------------------------------------------------------------------


def content_hash(project: Path) -> str:
    digest = hashlib.sha256()
    for path in sorted(project.rglob("*")):
        rel = path.relative_to(project)
        if any(part in HASH_SKIP for part in rel.parts) or not path.is_file():
            continue
        digest.update(str(rel).replace(os.sep, "/").encode())
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()[:12]


def cmd_check(args: argparse.Namespace) -> int:
    if args.game == "template":
        project = repo_root() / "template"
        records = repo_root() / "workspace" / "checks"
    else:
        state = Store.read()
        require_game(state, args.game)
        project = game_path(args.game) / "project"
        records = game_path(args.game) / "checks"
    if not (project / "scripts" / "check.sh").exists():
        raise StudioError(f"No project at {relative(project)} (create the game with --from-template)")
    if not (project / ".tools" / "bin").exists() and sys.platform.startswith("linux") and not shutil.which("rojo"):
        print("Installing pinned tools (scripts/install-tools.sh)...")
        subprocess.run(["bash", "scripts/install-tools.sh"], cwd=project, check=True)
    build = content_hash(project)
    command = ["bash", "scripts/check.sh"] + (["--release"] if args.release else [])
    started = now_iso()
    result = subprocess.run(command, cwd=project, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    output = result.stdout
    stamp = started.replace("-", "").replace(":", "")
    records.mkdir(parents=True, exist_ok=True)
    log_path = records / f"{stamp}-{build}.log"
    log_path.write_text(output, encoding="utf-8")
    passed = result.returncode == 0
    record = {
        "game": args.game,
        "build": build,
        "release": bool(args.release),
        "passed": passed,
        "exitCode": result.returncode,
        "started": started,
        "finished": now_iso(),
        "command": " ".join(command),
        "log": relative(log_path),
    }
    record_path = records / f"{stamp}-{build}.json"
    record_path.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    tail = "\n".join(output.strip().splitlines()[-12:])
    print(tail)
    print(f"\n{'PASSED' if passed else 'FAILED'} build {build}. Evidence: {relative(record_path)}")
    return 0 if passed else 1


def cmd_validate(args: argparse.Namespace) -> int:
    text = optional_text(args.path) or ""
    if args.kind == "brief":
        problems, _ = docs.validate_brief(text, gates.all_ids())
    else:
        problems, _ = docs.validate_handoff(text, gates.all_ids())
    if problems:
        print("Problems:\n  - " + "\n  - ".join(problems))
        return 1
    print(f"OK: the {args.kind} is complete.")
    return 0


# --- board ------------------------------------------------------------------------------------------


def render_board(state: Dict[str, Any]) -> str:
    lines = ["# Studio board", "", f"Updated {now_iso()} by studioctl. Do not edit: run `python3 agents/studioctl.py board`.", ""]
    needs: List[str] = []
    for game in state["games"].values():
        stage = game.get("awaitingHuman")
        if stage:
            label = gates.load()["humanCheckpoints"].get(stage, "Accept the gate waivers")
            waivers = [g for g in state["gates"] if g["game"] == game["id"] and g["stage"] == stage]
            waived = waivers[-1]["waived"] if waivers else []
            extra = f" (waived: {', '.join(waived)})" if waived else ""
            decision = " --decision continue|pivot|stop" if stage == "prototype" else ""
            needs.append(
                f"- **{game['title']}** ({game['id']}), {stage}: {label}{extra}. "
                f"Review `games/{game['id']}/gates/`, then `python3 agents/studioctl.py human approve {game['id']}{decision}` "
                f"or `human reject {game['id']} --note \"...\"`."
            )
    for escalation in sorted(state["escalations"].values(), key=lambda e: e["id"]):
        if escalation["status"] == "open":
            needs.append(
                f"- {escalation['id']} **{escalation['kind']}** from {escalation['by']}"
                f"{' on ' + escalation['game'] if escalation.get('game') else ''}: {escalation['note']} "
                f"(`human resolve {escalation['id']} --note \"...\"`)"
            )
    lines += ["## Needs you", ""] + (needs or ["Nothing right now."]) + [""]

    lines += ["## Games", "", "| Game | Title | Stage | Status | Last gate |", "|---|---|---|---|---|"]
    for game in sorted(state["games"].values(), key=lambda g: g["created"]):
        records = [g for g in state["gates"] if g["game"] == game["id"]]
        last = f"{records[-1]['stage']} {records[-1]['verdict']}" if records else "-"
        lines.append(f"| {game['id']} | {game['title']} | {game['stage']} | {game['status']} | {last} |")
    if not state["games"]:
        lines.append("| - | - | - | - | - |")
    lines.append("")

    sections = [("Working", "working"), ("Needs review", "needs_review"), ("Queued", "queued"), ("Draft (needs a brief)", "draft")]
    lines += ["## Tasks", ""]
    for title, status in sections:
        tasks = sorted((t for t in state["tasks"].values() if t["status"] == status), key=lambda t: t["id"])
        lines += [f"### {title} ({len(tasks)})", ""]
        if tasks:
            lines += ["| Task | Owner | Game | Title | Waiting on |", "|---|---|---|---|---|"]
            for task in tasks:
                waiting = ", ".join(d for d in task["deps"] if state["tasks"].get(d, {}).get("status") != "done") or "-"
                lines.append(f"| {task['id']} | {task['owner']} | {task['game']} | {task['title']} | {waiting} |")
        lines.append("")

    lines += ["## Studio leases", ""]
    config = state["config"]
    for name in config["studioInstances"]:
        lease = state["leases"].get(name)
        if lease and lease["expires"] >= now_epoch():
            view = _lease_view(name, lease, config)
            lines.append(f"- {name}: {view['holder']} (task {view['task'] or '-'}) until {view['expires']}")
        else:
            lines.append(f"- {name}: free")
    lines.append("")

    lines += ["## Recent activity", ""]
    for entry in state.get("log", [])[-15:][::-1]:
        lines.append(f"- {entry['at']} {entry['by']}: {entry['message']}")
    return "\n".join(lines) + "\n"


def write_board() -> Path:
    path = workspace_dir() / "BOARD.md"
    state = Store.read()
    path.write_text(render_board(state), encoding="utf-8")
    return path


def cmd_board(args: argparse.Namespace) -> int:
    path = write_board()
    if args.quiet:
        print(f"Wrote {relative(path)}")
    else:
        print(path.read_text(encoding="utf-8"))
    return 0


# --- parser -----------------------------------------------------------------------------------------


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="studioctl", description="Studio task queue, leases, gates and board.")
    parser.add_argument("--json", action="store_true", help="machine-readable output where supported")
    sub = parser.add_subparsers(dest="command", required=True)

    def by(p: argparse.ArgumentParser, default: str = "director") -> None:
        p.add_argument("--by", default=default, help=f"acting role (default {default})")

    p = sub.add_parser("init", help="create or reconfigure the workspace")
    p.add_argument("--studios", type=int, default=1, help="number of Roblox Studio instances to share")
    p.add_argument("--lease-minutes", type=int, default=45)
    p.set_defaults(func=cmd_init)

    game = sub.add_parser("game", help="games").add_subparsers(dest="game_command", required=True)
    p = game.add_parser("new")
    p.add_argument("game")
    p.add_argument("--title", required=True)
    p.add_argument("--genre")
    p.add_argument("--from-template", action="store_true", help="copy template/ into games/<id>/project")
    by(p)
    p.set_defaults(func=cmd_game_new)
    p = game.add_parser("list")
    p.set_defaults(func=cmd_game_list)
    p = game.add_parser("show")
    p.add_argument("game")
    p.set_defaults(func=cmd_game_show)
    p = game.add_parser("status")
    p.add_argument("game")
    p.add_argument("status", choices=["active", "paused", "stopped", "live"])
    by(p)
    p.set_defaults(func=cmd_game_status)

    task = sub.add_parser("task", help="tasks").add_subparsers(dest="task_command", required=True)
    p = task.add_parser("add")
    p.add_argument("--game", required=True)
    p.add_argument("--title", required=True)
    p.add_argument("--owner", help="role; omitted = keyword routing")
    p.add_argument("--stage")
    p.add_argument("--brief", help="brief file, or - for stdin")
    p.add_argument("--after", help="comma-separated task ids that must be done first")
    p.add_argument("--gates", help="comma-separated gate criterion ids this task must satisfy")
    p.add_argument("--draft", action="store_true", help="save an incomplete brief as a draft")
    by(p)
    p.set_defaults(func=cmd_task_add)
    p = task.add_parser("brief")
    p.add_argument("task")
    p.add_argument("--brief", required=True)
    by(p)
    p.set_defaults(func=cmd_task_brief)
    p = task.add_parser("list")
    p.add_argument("--game")
    p.add_argument("--owner")
    p.add_argument("--status", choices=["draft", "queued", "working", "needs_review", "done", "dropped"])
    p.add_argument("--all", action="store_true", help="include done and dropped")
    p.set_defaults(func=cmd_task_list)
    p = task.add_parser("show")
    p.add_argument("task")
    p.set_defaults(func=cmd_task_show)
    p = task.add_parser("next", help="claim your next runnable task (one at a time)")
    p.add_argument("--owner", required=True)
    p.set_defaults(func=cmd_task_next)
    p = task.add_parser("submit", help="hand off a working task for review")
    p.add_argument("task")
    p.add_argument("--handoff", required=True, help="handoff file, or - for stdin")
    p.set_defaults(func=cmd_task_submit)
    p = task.add_parser("done")
    p.add_argument("task")
    p.add_argument("--note")
    p.add_argument("--force", action="store_true", help="allow from working (Director only)")
    by(p)
    p.set_defaults(func=cmd_task_done)
    p = task.add_parser("return")
    p.add_argument("task")
    p.add_argument("--reason", required=True)
    by(p)
    p.set_defaults(func=cmd_task_return)
    p = task.add_parser("drop")
    p.add_argument("task")
    p.add_argument("--reason", required=True)
    by(p)
    p.set_defaults(func=cmd_task_drop)
    p = task.add_parser("note")
    p.add_argument("task")
    p.add_argument("text")
    by(p)
    p.set_defaults(func=cmd_task_note)

    p = sub.add_parser("route", help="suggest the owner role for a piece of work")
    p.add_argument("text")
    p.set_defaults(func=cmd_route)

    lease = sub.add_parser("lease", help="Roblox Studio leases").add_subparsers(dest="lease_command", required=True)
    p = lease.add_parser("acquire")
    p.add_argument("--agent", required=True)
    p.add_argument("--task")
    p.add_argument("--minutes", type=int)
    p.set_defaults(func=cmd_lease_acquire)
    p = lease.add_parser("release")
    p.add_argument("--agent", required=True)
    p.set_defaults(func=cmd_lease_release)
    p = lease.add_parser("list")
    p.set_defaults(func=cmd_lease_list)
    p = lease.add_parser("map", help="record which Studio MCP studio_id an instance name refers to")
    p.add_argument("instance")
    p.add_argument("--studio-id", required=True)
    p.add_argument("--place")
    p.set_defaults(func=cmd_lease_map)

    gate = sub.add_parser("gate", help="stage gates").add_subparsers(dest="gate_command", required=True)
    p = gate.add_parser("criteria")
    p.add_argument("stage", choices=STAGES)
    p.set_defaults(func=cmd_gate_criteria)
    p = gate.add_parser("template")
    p.add_argument("game")
    p.add_argument("--stage", choices=STAGES)
    p.add_argument("--build")
    p.add_argument("--out")
    p.set_defaults(func=cmd_gate_template)
    p = gate.add_parser("record")
    p.add_argument("game")
    p.add_argument("--review", required=True, help="review JSON file, or - for stdin")
    by(p, "gatekeeper")
    p.set_defaults(func=cmd_gate_record)
    p = gate.add_parser("stats", help="failure counts per criterion (learning loop)")
    p.set_defaults(func=cmd_gate_stats)

    human = sub.add_parser("human", help="human checkpoints (people only)").add_subparsers(dest="human_command", required=True)
    p = human.add_parser("approve")
    p.add_argument("game")
    p.add_argument("--decision", choices=["continue", "pivot", "stop"])
    p.add_argument("--note")
    p.set_defaults(func=cmd_human_approve)
    p = human.add_parser("reject")
    p.add_argument("game")
    p.add_argument("--note", required=True)
    p.set_defaults(func=cmd_human_reject)
    p = human.add_parser("resolve")
    p.add_argument("escalation")
    p.add_argument("--note", required=True)
    p.set_defaults(func=cmd_human_resolve)

    p = sub.add_parser("escalate", help="put money, publish, policy, data or decision items on the human's list")
    p.add_argument("--kind", required=True, choices=ESCALATION_KINDS)
    p.add_argument("--note", required=True)
    p.add_argument("--game")
    by(p)
    p.set_defaults(func=cmd_escalate)

    p = sub.add_parser("check", help="run the project's quality gate and store a check record")
    p.add_argument("game", help="game id, or 'template'")
    p.add_argument("--release", action="store_true")
    p.set_defaults(func=cmd_check)

    p = sub.add_parser("validate", help="validate a brief or handoff file")
    p.add_argument("kind", choices=["brief", "handoff"])
    p.add_argument("path")
    p.set_defaults(func=cmd_validate)

    p = sub.add_parser("board", help="render workspace/BOARD.md")
    p.add_argument("--quiet", action="store_true")
    p.set_defaults(func=cmd_board)
    return parser


def main(argv: Optional[List[str]] = None) -> int:
    raw = list(sys.argv[1:] if argv is None else argv)
    parser = build_parser()
    args = parser.parse_args(raw)
    args.studios_set = "--studios" in raw
    args.lease_minutes_set = "--lease-minutes" in raw
    try:
        for name in ("agent", "owner", "by"):
            value = getattr(args, name, None)
            if value and value not in ("human", "studioctl"):
                require_role(value)
        return int(args.func(args) or 0)
    except StudioError as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
