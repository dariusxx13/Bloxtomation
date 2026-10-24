---
title: Playtest report template
date: 2026-10-24
tags: [template, qa, playtest]
aliases: [Playtest template, QA report]
summary: Template for reporting a playtest (human or agent, newcomer or QA) with timestamps, confusion points, bugs and evidence.
audience: [human, agent]
---

# Playtest report template

```markdown
---
title: Playtest: <game> <build/version> <type>
date: <YYYY-MM-DD>
tester: <name or agent role>
type: newcomer | golden-path | multi-client | device | regression
build: <place version or git commit>
device: <phone model / simulator size / PC>
---

## Goal of this playtest
<What we wanted to learn or verify.>

## Setup
- Fresh data: yes/no
- Players: <n>
- Conditions: <latency simulation, QA state applied>

## Timeline
| Time | What I did | What I expected | What happened | Feeling (bored / confused / excited) |
|---|---|---|---|---|
| 0:00 | | | | |

## Confusion points
1. <time> — <what was unclear> — <screenshot link> — suggested fix

## Bugs
| Severity (blocker/major/minor) | Steps to reproduce | Expected | Actual | Evidence |
|---|---|---|---|---|

## Checks (for golden-path / QA)
| Check | Result | Evidence |
|---|---|---|
| Core action within 30 s | pass/fail | |
| First reward animated and audible | | |
| First upgrade affordable within 3 min | | |
| Data persists after rejoin | | |
| No errors in console | | |

## Metrics observed
- Time to first action / first reward / first upgrade / first goal: <...>

## Summary
- Top 3 problems:
- Top 3 good moments:
- Recommendation:
```

Related: [Testing and QA](../13-building-it-right/testing-and-qa.md) · [Studio MCP playbook](../16-ai-studio-operations/studio-mcp-playbook.md) · [First-session killers](../01-first-five-minutes/first-session-killers.md)
