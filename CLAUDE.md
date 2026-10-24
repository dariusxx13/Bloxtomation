# Bloxtomation: instructions for Claude

This repository is an AI-assisted Roblox game studio: a knowledge vault, a game template, a team of agents and a chart tracker. Read this file fully before working.

## Repository map

| Path | What it is |
|---|---|
| `vault/` | The studio's knowledge (Obsidian, 130+ notes). Start with `vault/00-start-here/for-ai-agents.md`. Load only the notes your task needs. |
| `template/` | The game template (Rojo, strict Luau). Quality gate: `bash template/scripts/check.sh`. |
| `games/<id>/` | One folder per game: `project/` (a copy of the template), `docs/`, `tasks/`, `handoffs/`, `gates/`, `checks/`, `playtests/`. |
| `agents/` | `studioctl.py` (task queue, Studio leases, gates, board), gate criteria, routing table, guard hook, tests. |
| `.claude/agents/studio/` | The 15 role agents. `.claude/skills/` holds the `/studio` commands. |
| `charts/` | Chart tracker for Roblox discovery sorts (`python3 charts/charts.py --help`). |
| `workspace/` | Studio state (`state.json`, written only by studioctl) and `BOARD.md`. |

## House rules (blocking, for every agent and the main session)

1. **Never publish.** Upload Saved versions only (`template/scripts/upload-place.luau`). A person publishes. The guard hook blocks publish commands; do not look for ways around it.
2. **Never spend money or accept terms** (ads, paid assets, fees, subscriptions). Escalate: `python3 agents/studioctl.py escalate --kind money --note "..." --by <role>`.
3. **Never answer policy questions for the human** (maturity questionnaire, IP, paid random items, age rating). Draft answers, then escalate with `--kind policy`.
4. **Never run `studioctl.py human ...`.** Those commands record a person's decision.
5. **The server owns everything of value; every remote is validated and rate-limited; purchases are granted only in `ProcessReceipt`; player data is never lost.** See `vault/00-start-here/for-ai-agents.md` section 3 for the full list of ten non-negotiable rules.
6. **Evidence, not claims.** Every handoff shows proof: check records, test output, screenshots, numbers with sources and dates.
7. **Original work only.** Do not copy text, code or assets from other games or websites. Every non-owned asset is recorded with source and license.
8. **Rojo-managed code is edited on disk**, never inside Studio.

## Studio protocol (how every task runs)

```text
python3 agents/studioctl.py task next --owner <role>          # claim your next task (one at a time)
# read the brief at games/<id>/tasks/<task>.md and the vault notes for your role
python3 agents/studioctl.py lease acquire --agent <role> --task <task>   # only if you need Roblox Studio
# ... do the work, collect evidence ...
python3 agents/studioctl.py lease release --agent <role>
python3 agents/studioctl.py task submit <task> --handoff <file>   # handoff note (format below)
```

- Do not start a task whose brief lacks acceptance criteria; the CLI keeps such tasks in `draft`. Tell the Director.
- Name the outcome your task serves in your first line of work: click, stay, return, spend or safety.
- Propose follow-up work in your handoff's **Next** section; the Director creates the tasks. Use `studioctl.py route "<text>"` to see who should own something.
- If a lease is unavailable (exit code 3), do non-Studio work or report back; never use a Studio instance you do not hold. Pass the lease's `studio_id` on every Studio MCP call.

### Handoff note format

```markdown
## Summary
What you did, in two to five sentences. Name the outcome served.

## Evidence
- Check record: games/<id>/checks/<file>.json (or test output, screenshots, tables with sources)
- One line per acceptance criterion: criterion -> proof

## Gate criteria
BUILD-04 pass: all remotes in Net.handle (src/server/Systems/*.luau); BUILD-07 ...

## Next
Who should do what next, and what they need.

## Open questions
Decisions you could not make (or "None").
```

## Useful commands

```text
python3 agents/studioctl.py board                    # status board (also workspace/BOARD.md)
python3 agents/studioctl.py check <game> [--release] # run the project's quality gate, store a check record
python3 agents/studioctl.py gate criteria <stage>    # criteria ids for a stage
python3 agents/studioctl.py validate brief|handoff <file>
python3 -m unittest discover -s agents/tests         # orchestrator tests
bash template/scripts/check.sh                       # template quality gate
```

## Working on this repository itself

- Keep `agents/gates/criteria.json` and the roster in sync with `vault/16-ai-studio-operations/`; `agents/tests/test_vault_sync.py` enforces it.
- Vault notes use relative markdown links, frontmatter (`title`, `date`, `tags`, `aliases`, `summary`, `audience`) and end with a `Related:` line.
- Luau follows `vault/13-building-it-right/luau-standards.md`: `--!strict`, StyLua formatting, Selene clean, typed remotes.
