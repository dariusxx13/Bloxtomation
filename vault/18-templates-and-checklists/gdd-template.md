---
title: GDD template
date: 2026-10-24
tags: [template, design, gdd]
aliases: [Game design document template]
summary: Copy-paste game design document template covering loops, first session, systems, economy, monetization, retention, art, tech and analytics, sized for a Roblox game.
audience: [human, agent]
---

# GDD template

A Roblox GDD should be short enough to read in 20 minutes and precise enough to build from. Link to the economy sheet and catalog rather than pasting huge tables.

```markdown
---
title: GDD: <game name>
date: <YYYY-MM-DD>
version: <n>
status: draft | in review | approved
---

# <Game name>

## 1. Summary
- One-liner: You <verb> to get <reward> so you can <goal>.
- Genre / subgenre, target tier, devices, maturity target.
- Pillars (3): <e.g., "satisfying click", "collect and show off", "better with friends">

## 2. Loops
- Moment loop: <action -> feedback -> resource>
- Session loop: <resource -> upgrade/unlock -> how the action changes> (gap targets)
- Long loop: <reset / collection / social goal>
- Loop tests plan (seven tests): <how each will be checked>

## 3. First session
| Phase | Time | What happens | Target metric |
|---|---|---|---|
| Load | 0-10 s | | |
| First action | 10-30 s | | step 3 >= 90% |
| First reward | 30-90 s | | |
| First choice | 1-3 min | | |
| First loop | 3-5 min | | |
| First goal | 5-15 min | | |
| First wow | 5-20 min | | |
| Return hook | | | |
Onboarding funnel steps: <numbered list with names>

## 4. Systems
For each system: purpose, rules, data stored, server/client split, config keys, UI, analytics events.
- 4.1 Core action
- 4.2 Upgrades
- 4.3 Zones / maps
- 4.4 Collection / randomness (drop tables link, odds display, pity, luck stacking)
- 4.5 Rebirth / prestige
- 4.6 Daily systems (rewards, streaks, quests, timers)
- 4.7 Social (friend bonus, invites, leaderboards, trading)
- 4.8 Events framework

## 5. Economy
- Currencies and jobs
- Sources and sinks table
- Link to economy sheet (three player types)
- Time-to-goal for first five goals
- Multiplier categories and caps

## 6. Monetization
- Catalog link (products, prices, motivations, placements)
- Contextual offer moments and frequency caps
- Compliance notes (odds, PolicyService, honest discounts)

## 7. Art and audio direction
- Style guide link (palette, shapes, materials, references)
- Zone looks and lighting presets
- VFX language and rarity colors
- Sound and music list

## 8. UI
- HUD layout sketch (phone landscape)
- Menus list with mock links
- Visual language table

## 9. Tech
- Architecture notes (systems, controllers, remotes list)
- Data schema (types) and version
- Performance budgets
- Risks

## 10. Analytics
- Funnels, economy events, custom events (names and fields)
- Experiments planned (hypotheses)

## 11. Launch and live ops
- Store page plan (icon, thumbnails, title, description)
- Launch plan (16+ trial, evaluation, timing)
- First 4 weekly updates (themes)

## 12. Open questions
- <question> — owner — due
```

Related: [Core loop design](../02-core-loop/core-loop-design.md) · [First session blueprint](../01-first-five-minutes/first-session-blueprint.md) · [Economy sheet template](economy-sheet-template.md) · [Build briefs](../16-ai-studio-operations/build-briefs.md)
