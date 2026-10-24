---
title: Competitor teardown
date: 2026-10-24
tags: [market-research, analysis, competitors, method]
aliases: [Teardown, Game analysis, Reverse engineering a hit]
summary: A repeatable method to analyze a successful Roblox game (first session, loops, economy, monetization, retention, live ops, store page) and extract lessons without copying it.
audience: [human, agent]
---

# Competitor teardown

A teardown is a structured analysis of another game: what it does, why it works, what it earns from, and what it does badly. Done well, it turns "that game is popular" into specific, testable lessons. It never means copying assets, names or code.

## Before you start

- Pick 1-3 games: the genre leader, a fast-rising newcomer, and optionally a game that failed with a similar idea.
- Collect public data: chart positions over time, players, visits per day, like ratio, creation and update dates, genre, store page (icon, thumbnails, title, description), passes and products listed on the store tab, events listed, group size.
- Play on a phone and on a PC, with a fresh account if possible.

## The teardown template

Fill each section with observations and timestamps.

### 1. Store page and first impression

- Icon, thumbnails, title, description: what promise do they make?
- Does the first frame of the game match the promise?

### 2. First session (record it)

| Time | What happened | What the game wanted me to do | How it told me |
|---|---|---|---|
| 0:00 | | | |
| 0:30 | | | |
| ... | | | |

Note: time to first action, first reward, first upgrade, first named goal, first "wow", first purchase prompt, first return hook.

### 3. Loops

- Moment loop, session loop, long loop (see [Core loop design](../02-core-loop/core-loop-design.md)).
- One sentence: "You ___ to get ___ so you can ___."
- What makes the moment loop feel good (feedback layers)?

### 4. Progression and economy

- Currencies and their jobs.
- Upgrade costs and gaps (time between upgrades at minute 5, 15, 30, 60).
- Zones or tiers and their gates.
- Rebirth or prestige structure.

### 5. Randomness

- Drop tables and displayed odds; luck sources; pity; reveal design.

### 6. Monetization

- Every pass and product with price and benefit.
- Where offers appear (contextual moments) and how pushy they are.
- The cheapest entry purchase; the best value; the whale sinks.
- Compliance: odds disclosure, honest discounts.

### 7. Retention and social

- Daily rewards, streaks, quests, timers, notifications prompts.
- Friend features, trading, leaderboards, show-off.
- Update cadence (from update dates and update logs) and events.

### 8. Tech and feel

- Performance on a phone; load time; bugs seen.
- Controls on touch.

### 9. What players say

- Like ratio; common praise and complaints in reviews, community channels and comments.

### 10. Verdict

- Top 3 reasons it succeeds (with evidence).
- Top 3 weaknesses we could do better.
- What would *not* transfer to our game (luck, timing, existing community).
- Lessons as testable hypotheses for our design.

## Rules

- **Observe, do not copy.** Learn structures, pacing and principles. Never reuse names, art, audio, UI layouts so closely that they look like the original, or any code.
- **Separate cause from coincidence.** A game's success can come from timing, creators or an existing audience. State what you can and cannot explain.
- **Quantify where possible.** "First upgrade at 0:42" beats "first upgrade is fast."
- **Date everything.** Games change weekly; a teardown is a snapshot.

## For agents

- [ ] Teardown uses the ten sections; first session recorded with timestamps.
- [ ] Monetization list includes prices and placement observations.
- [ ] Verdict lists success reasons with evidence and explicit non-transferable factors.
- [ ] Lessons phrased as testable hypotheses, not as copied features.

Related: [Reading the charts](reading-the-charts.md) · [Trend lifecycle](trend-lifecycle.md) · [Pitch and greenlight](pitch-and-greenlight.md) · [First session blueprint](../01-first-five-minutes/first-session-blueprint.md)
