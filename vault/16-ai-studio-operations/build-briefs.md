---
title: Build briefs
date: 2026-10-24
tags: [ai, agents, process, briefs, tasks]
aliases: [Task briefs, Writing tasks for agents]
summary: How to write task briefs that an agent (or a contractor) can execute without guessing: structure, acceptance criteria, evidence, and examples.
audience: [human, agent]
---

# Build briefs

A brief is the instruction for one task. Agents do their best work when briefs are specific about the outcome, the constraints and how success will be checked. Vague briefs produce plausible-looking work that misses the point.

## The brief template

```
Title: <verb + object, under 60 characters>
Owner: <agent role>
Game / stage: <game id> / <stage>
Outcome: <which of click / stay / return / spend / safety this serves, and how>
Context: <what exists now; links to GDD sections, vault notes, previous tasks>
Requirements:
  1. <concrete, testable requirement>
  2. ...
Out of scope: <what not to touch>
Constraints: <platform rules, budgets, house rules, files to avoid>
Acceptance criteria:
  - <observable check, e.g. "first upgrade affordable within 60 s on a fresh profile">
  - <gate criterion ids this task must satisfy, e.g. BUILD-04, BUILD-07>
Evidence to return: <build log, test output, screenshots, playtest notes, numbers>
Dependencies: <tasks that must finish first>
Hand off to: <next agent and what they need>
```

## Good vs bad

| Bad | Good |
|---|---|
| "Make the shop better" | "Reduce shop drop-off: add a guided first purchase when the player first has 25+ coins; success = Opened Shop step conversion above 75% in a Studio newcomer test" |
| "Add pets" | "Implement pet equip system: 3 slots, equip best, multiplier per rarity from config `Pets.luau`; data shape per `Types.PetEntry`; UI per mock in GDD 4.2" |
| "Fix lag" | "Profile the lobby with 12 test clients; report top 3 frame-time costs; reduce lobby client memory below the current level without removing gameplay features" |

## Writing requirements

- One requirement, one check. If you cannot say how to check it, rewrite it.
- Numbers come from the GDD or economy sheet, never invented in the brief.
- Name files and modules when the location matters.
- Include platform rules that apply (for example "prices fetched at runtime", "odds displayed").

## Evidence agents return

| Task type | Evidence |
|---|---|
| Code | Build and lint output, unit test results, playtest steps and console output |
| UI | Screenshots at phone, tablet and desktop |
| World and art | Screenshots from player height and overview; budget numbers |
| Design and economy | Tables with formulas, sources and comparables |
| Research | Snapshots with dates and numbers, links |
| QA | Steps, pass/fail per check, captures, reproduction steps for bugs |

## For agents

- [ ] Do not start a task whose brief lacks acceptance criteria; ask the Director.
- [ ] Return evidence for each acceptance criterion.
- [ ] State clearly anything you could not verify.

Related: [Agent team workflow](agent-team-workflow.md) · [Quality gates](quality-gates.md) · [GDD template](../18-templates-and-checklists/gdd-template.md)
