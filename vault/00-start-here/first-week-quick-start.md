---
title: First week quick start
date: 2026-10-24
tags: [start-here, quick-start, onboarding, process]
aliases: [Quick start, Day one, Getting started with the studio]
summary: A seven-day plan for a new person (or a new agent operator) to go from cloning the repository to a playtested change in a game - tools, the template, the vault notes to read each day, the studio protocol, the chart tracker, and what "done" looks like at the end of the week.
audience: [human, agent]
---

# First week quick start

This repository is a whole studio: a knowledge vault, a game template, an agent team and a chart tracker. That is a lot to take in. This plan gets a newcomer productive in seven days by doing one real thing each day. Longer role-based plans are in [Learning paths](../22-references/learning-paths.md).

## Day 1: tools and the template

- Read [How to use this vault](how-to-use-this-vault.md) and the repository's `CLAUDE.md` house rules (never publish, never spend money or accept terms, never answer policy questions for the owner).
- Install the toolchain and run the template's quality gate:

```text
bash template/scripts/install-tools.sh
bash template/scripts/check.sh
```

- Open the template in Studio with Rojo and play it. Write down three things you noticed as a new player.

**Done when:** the quality gate passes on your machine and you have played the template.

## Day 2: what makes games work

- Read [The hit formula](hit-formula.md), [Anatomy of a Roblox hit](../21-hits-and-trends/anatomy-of-a-hit.md) and [First session blueprint](../01-first-five-minutes/first-session-blueprint.md).
- Replay the template's first five minutes with a timer. When does the first goal land?

**Done when:** you can state the template's loop in one sentence and its first-goal time.

## Day 3: the market

- Read [Reading the charts](../15-market-research/reading-the-charts.md) and the [October 2026 chart snapshot](../21-hits-and-trends/chart-snapshot-2026-10.md).
- Take a snapshot and read the report:

```text
python3 charts/charts.py snapshot
python3 charts/charts.py report
```

- Pick one breakout candidate and play it for ten minutes. Write its loop, first goal and twist.

**Done when:** you have a dated note on one rising game with evidence from the tracker.

## Day 4: code the right way

- Read [Project architecture](../13-building-it-right/project-architecture.md), [Common Luau mistakes](../13-building-it-right/common-luau-mistakes.md) and [API cookbook](../22-references/api-cookbook.md).
- Make a small change in the template (for example a new upgrade in `template/src/shared/Config/Upgrades.luau` or a new code in `template/src/shared/Config/Codes.luau`), keeping strict typing and the server-owns-state rule.
- Run the quality gate again.

**Done when:** your change passes the gate.

## Day 5: the studio protocol

- Read [Agent team workflow](../16-ai-studio-operations/agent-team-workflow.md), [Build briefs](../16-ai-studio-operations/build-briefs.md) and [Quality gates](../16-ai-studio-operations/quality-gates.md).
- Look at the board and the protocol:

```text
python3 agents/studioctl.py board
python3 agents/studioctl.py route "add a daily quest board"
python3 agents/studioctl.py gate criteria build
```

- Write a handoff note for your Day 4 change in the format from `CLAUDE.md` (Summary, Evidence, Gate criteria, Next, Open questions) and validate it with `python3 agents/studioctl.py validate handoff <file>`.

**Done when:** your handoff validates.

## Day 6: playtest and evidence

- Read [Testing and QA](../13-building-it-right/testing-and-qa.md) and [Discoverability defaults](../01-first-five-minutes/discoverability-defaults.md).
- Playtest your change with one other person (or as the Newcomer agent describes), on a phone if possible. Capture screenshots.
- Run the studio check record: `python3 agents/studioctl.py check <game>` for a game folder if one exists.

**Done when:** the handoff includes screenshots and a check record.

## Day 7: pick your path

- Read [Learning paths](../22-references/learning-paths.md) and choose a role path.
- Skim the section indexes for your role (for example [VFX](../19-vfx/INDEX.md), [Anime games](../20-anime-games/INDEX.md), [Hits and trends](../21-hits-and-trends/INDEX.md)).
- Write three questions you still have; check the [FAQ for new developers](../22-references/faq-for-new-developers.md) first.

**Done when:** you have a path and next week's first task.

## Rules to remember from day one

1. A person publishes; agents upload Saved versions only.
2. The server owns everything of value; every remote is validated and rate-limited.
3. Evidence, not claims: every handoff shows proof.
4. Original work only; record the source and license of every asset.
5. Facts carry dates and sources; rules of thumb are labelled.

Related: [How to use this vault](how-to-use-this-vault.md) · [For AI agents](for-ai-agents.md) · [Learning paths](../22-references/learning-paths.md) · [FAQ for new developers](../22-references/faq-for-new-developers.md) · [Agent team workflow](../16-ai-studio-operations/agent-team-workflow.md)
