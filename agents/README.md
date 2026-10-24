# Agent team

Fifteen Claude Code agents that take a game from idea to a release candidate and keep improving it after launch, coordinated through a file-based task queue with stage gates, Studio leases and human checkpoints. The vault is their shared knowledge; the template is their starting codebase.

## What you get

| Part | Where | What it does |
|---|---|---|
| Role agents | [`.claude/agents/studio/`](../.claude/agents/studio/) | One definition per role (Director, Scout, Designer, Economist, Monetization Designer, Engineer, Interface Designer, Worldbuilder, Artist, Storefront, QA Tester, Newcomer, Security Reviewer, Gatekeeper, Analyst). Claude Code loads them automatically. |
| Commands | [`.claude/skills/`](../.claude/skills/) | `/studio <goal>` (run the studio as Director), `/studio-status`, `/studio-gate <game>`, `/studio-playtest <game> [golden\|newcomer\|devices]`. |
| Shared rules | [`CLAUDE.md`](../CLAUDE.md) | House rules, the task protocol and the handoff format every agent follows. |
| studioctl | [`studioctl.py`](studioctl.py), [`studio/`](studio/) | Task queue with briefs and dependencies, handoffs, Studio leases, keyword routing, stage gates, human checkpoints, escalations, mechanical check records, the board. Python 3.9+, standard library only. |
| Gate criteria | [`gates/criteria.json`](gates/criteria.json) | Machine copy of the vault's [quality gates](../vault/16-ai-studio-operations/quality-gates.md): 54 criteria with stable ids. |
| Routing table | [`routing.json`](routing.json) | Keywords that suggest the owner role for a task. |
| Guard hook | [`hooks/guard.py`](hooks/guard.py), [`.claude/settings.json`](../.claude/settings.json) | Blocks publishing, human-only commands and hand edits to the state file, for every agent. |
| Templates | [`templates/`](templates/) | Brief and handoff skeletons. |
| Tests | [`tests/`](tests/) | `python3 -m unittest discover -s agents/tests` (task lifecycle, leases, gates, validation, routing, guard, and sync with the vault). |

## Quick start

1. Open this repository in Claude Code (CLI, desktop or web).
2. Optional but recommended: connect Roblox Studio (below) so the Engineer, QA Tester, Newcomer, Worldbuilder, Artist and Interface Designer can playtest and build.
3. Type `/studio make a cozy fishing game where you catch glowing fish to decorate an aquarium`.
4. The Director creates the game (`games/<id>/`, with `project/` copied from the template), queues the pitch stage, dispatches the Scout and the Designer, reviews their handoffs, runs the pitch gate, and stops when it needs you.
5. Look at `workspace/BOARD.md` (or `/studio-status`). Decisions that are yours appear under **Needs you** with the command to run, for example:

```bash
python3 agents/studioctl.py human approve fishing-glow                       # approve the pitch
python3 agents/studioctl.py human approve fishing-glow --decision continue   # prototype: continue|pivot|stop
python3 agents/studioctl.py human reject fishing-glow --note "twist is too weak"
python3 agents/studioctl.py human resolve E-0003 --note "yes, buy the sound pack"
```

6. Type `/studio continue fishing-glow` to run the next stage.

## How the studio runs

```text
idea ─▶ PITCH ─▶ DESIGN ─▶ PROTOTYPE ─▶ BUILD ─▶ POLISH ─▶ RELEASE CANDIDATE ─▶ LIVE ─▶ REVIEW
        human            human                                 human publishes
        approves         decides                               (agents upload Saved only)
```

- **Tasks.** Every unit of work has an owner role, a brief (outcome, requirements, acceptance criteria, evidence to return), dependencies and gate criterion ids. A task without an executable brief stays a `draft` and cannot be claimed. Each role works one task at a time: `task next --owner <role>` claims the next runnable one.
- **Handoffs.** A task is submitted with a handoff note (Summary, Evidence, Next, Open questions); the CLI refuses notes without evidence. The Director reviews and marks it done or returns it with criterion ids.
- **Gates.** The Gatekeeper fills a review JSON with pass, fail or waived and evidence for every criterion of the stage. Mechanical criteria (build, lint, tests) must cite a passing check record that the Gatekeeper produced for the exact build (`studioctl.py check <game>` hashes the project); release candidates need a `--release` check. Failures must say what evidence would pass. Pitch, prototype and release candidate gates, and any waiver, wait for a human decision.
- **Studio leases.** Roblox Studio is shared: `lease acquire` hands out instances (`init --studios N`), leases expire automatically, and `lease map` records which Studio MCP `studio_id` each instance is so agents never act on the wrong window.
- **Escalations.** Money, publishing, policy, data incidents and open decisions go to the human's list with `escalate`, and agents wait for them.
- **Learning loop.** `gate stats` counts failures per criterion; the Analyst proposes vault edits backed by data.

## Roster

| Role | Owns | Studio |
|---|---|---|
| director | Plans, briefs, dispatch, review, human communication | no |
| scout | Charts, trends, teardowns, pitches | no |
| designer | GDD, loops, first session, onboarding, feature specs, fun verdict | no |
| economist | Economy sheet, pacing, curves, drop tables, balance passes | no |
| monetization-designer | Catalog, pricing, offers, compliance notes | no |
| engineer | Systems, controllers, data, purchases, analytics, Saved uploads | yes |
| interface-designer | HUD, menus, shop and inventory UI, device checks | yes |
| worldbuilder | Maps, zones, lobby, lighting, budgets | yes |
| artist | Art direction, models, VFX, animation, audio, asset index | yes |
| storefront | Icon, thumbnails, title, description, ad creatives | sometimes |
| qa-tester | Golden path, acceptance checks, edge cases, devices, performance | yes |
| newcomer | First-time-player test with no context | yes |
| security-reviewer | Exploits, data safety, receipts, compliance review | sometimes |
| gatekeeper | Stage gates with evidence, re-runs checks | sometimes |
| analyst | Launch and rollback plans, metrics, experiments, postmortems | no |

## Connect Roblox Studio (Studio MCP server)

1. Install the latest Roblox Studio. In Studio open **Assistant**, then **... > Manage MCP Servers**, and turn on **Enable Studio as MCP server**.
2. Connect Claude Code, either with Studio's quick connect or manually (stdio):
   - macOS: `claude mcp add roblox-studio -- /Applications/RobloxStudio.app/Contents/MacOS/StudioMCP`
   - Windows: `claude mcp add roblox-studio -- cmd.exe /c %LOCALAPPDATA%\Roblox\mcp.bat`
3. Check the green connected indicator in Studio, then tell the studio how many Studio windows it may use: `python3 agents/studioctl.py init --studios 2`.
4. Sync a game's code into Studio with Rojo: `cd games/<id>/project && rojo serve`, then connect with the Rojo plugin. Code is always edited on disk; Studio is for playing, building worlds and capturing.

Only connect clients you trust: an MCP client can read and change the places you have open. Cloud sessions (Claude Code on the web) have no Studio; there the studio runs every non-Studio role and the playtest tasks wait for a session on a computer with Studio.

## studioctl reference

```text
init [--studios N] [--lease-minutes M]
game new <id> --title T [--genre G] [--from-template] | game list | game show <id> | game status <id> active|paused|stopped|live
task add --game G --title T [--owner ROLE] [--stage S] [--brief FILE|-] [--after T-0001,T-0002] [--gates BUILD-04,...] [--draft]
task brief <task> --brief FILE|-     task next --owner ROLE      task submit <task> --handoff FILE|-
task done <task> [--force]           task return <task> --reason R      task drop <task> --reason R
task list [--game G] [--owner R] [--status S] [--all]    task show <task>    task note <task> "text"
route "<text>"                       # which role should own this?
lease acquire --agent ROLE [--task T] [--minutes M]   lease release --agent ROLE   lease list   lease map studio-1 --studio-id ID [--place NAME]
gate criteria <stage>   gate template <game> [--stage S] [--build HASH]   gate record <game> --review FILE   gate stats
check <game|template> [--release]    # run the project's quality gate and store a check record
escalate --kind money|publish|policy|data|decision --note N [--game G] --by ROLE
human approve <game> [--decision continue|pivot|stop]   human reject <game> --note N   human resolve <E-id> --note N   (people only)
validate brief|handoff <file>        board [--quiet]
```

Add `--json` before the command for machine-readable output (`studioctl.py --json task next --owner engineer`).

## Files the studio writes

| Path | Content |
|---|---|
| `workspace/state.json` | Games, tasks, leases, gate records, escalations, activity log (written only by studioctl, under a file lock) |
| `workspace/BOARD.md` | The human-readable board, refreshed on every change |
| `games/<id>/docs/` | Pitch, GDD, economy sheet, catalog, art direction, asset index, store copy, reviews |
| `games/<id>/tasks/`, `handoffs/` | Briefs and handoff notes per task |
| `games/<id>/gates/` | Gate reviews (`build-01.json` ...) |
| `games/<id>/checks/` | Check records (`<time>-<buildhash>.json`) and full logs |
| `games/<id>/playtests/` | QA and Newcomer reports |
| `games/<id>/project/` | The game's Rojo project |

Commit these: they are the studio's memory, and cloud sessions start from a fresh clone.

## Changing the team

- **Add a role:** write `.claude/agents/studio/<role>.md`, add the role to `ROLES` in `studio/store.py` and to `routing.json`, and add it to the roster table in `vault/16-ai-studio-operations/agent-team-workflow.md`. The sync test checks all four.
- **Change a gate criterion:** edit `vault/16-ai-studio-operations/quality-gates.md` and `gates/criteria.json` together; never reuse an id for a new meaning.
- **Tune routing:** edit keyword weights in `routing.json`; `python3 agents/studioctl.py route "<text>"` shows the ranking.
