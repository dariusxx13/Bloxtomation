---
title: Speed and escape courses playbook
date: 2026-10-24
tags: [genre, plus-one-speed, escape, obby, short-sessions, rebirth, playbook]
aliases: [+1 Speed games, Escape games, Speed obby, Every step faster]
summary: How to build "+1 speed" and escape-course games - speed that grows with every step, courses with visible milestones, falls and instant restarts, rebirth multipliers, sensory feedback, short-session monetization, live boost tags, saturation by copies, and how to add a twist that lasts.
audience: [human, agent]
---

# Speed and escape courses playbook

In 2026 a simple format reached the top of the charts: **every step makes you faster**. +1 Speed Keyboard Escape (released January 2026) reached an all-time high of about 7.28M concurrent players with admin events and held a 97% rating from about 9.1M votes; +1 Speed Monkey Escape reached about 1.09M; by October the snapshot still showed 21 charting titles containing "+1" (StudioKrew, August 2026; studio snapshot). The format is a cousin of the obby ([Obby and platformer playbook](obby-and-platformer.md)) built for short, frequent sessions ([AFK, idle and short-session games](../21-hits-and-trends/afk-idle-and-short-session-games.md)).

Roblox genre: Simulation or Obby & Platformer.

## The loop

```
Moment:  run -> speed number climbs -> reach a farther marker (constant feedback)
Run:     sprint through sections -> a fall or obstacle sends you back -> try again, faster
Long:    rebirth for a multiplier -> new courses or worlds -> cosmetics and trails -> leaderboards
```

## Core mechanics

- **Speed per step:** each step (or each second moving) adds speed; show the number big and always visible.
- **Course with milestones:** colour zones or numbered stages so every run has "I got further"; signs with the distance.
- **Obstacles that scale with speed:** gaps, turns and moving hazards that are easy at low speed and dramatic at high speed.
- **Falling back:** a fall returns you to the start or a checkpoint; speed stays (or partly stays) so the next run is faster.
- **Instant restart:** no menus between attempts.
- **Rebirth:** reset speed for a permanent multiplier and a cosmetic badge ([Rebirth and prestige](../04-progression-and-economy/rebirth-and-prestige.md)).
- **Wins or trophies** at the end of each course as a second currency.

## Feel and presentation

- Camera field of view widens and speed lines appear as speed rises ([Lighting and screen effects for VFX](../19-vfx/lighting-and-screen-effects.md)).
- Satisfying footstep and surface sounds; one top game was described by trackers as having an ASMR-like keyboard-click presentation players leave running (StudioKrew, July-August 2026).
- Trails and auras that grow with speed ([VFX recipes](../19-vfx/vfx-recipes.md)).
- Readable course art at high speed: big shapes, strong colours, clear edges.

## Technical notes

- Movement speed is set by the server (`Humanoid.WalkSpeed`) from the player's saved speed stat; the client never sets its own speed.
- Very high speeds break physics: cap the effective `WalkSpeed`, scale course size, or switch to a custom movement model at high tiers.
- Server-side checks reject positions that exceed the player's legitimate speed (speed exploits are the obvious cheat here) ([Security and anti-exploit](../13-building-it-right/security-and-anti-exploit.md)).
- Stage completion and wins are validated on the server (touching end zones within plausible time).
- Leaderboards (top speed, fastest course time) use server data ([MemoryStore and cross-server systems](../13-building-it-right/memorystore-and-cross-server.md)).

## Monetization (short-session)

| Product | Notes |
|---|---|
| 2x speed gain (timed or permanent) | The core purchase; fair if free players progress fine |
| Auto-run or auto-train | Convenience; keep manual play rewarding |
| Trails, auras, skins | Visible at speed |
| Server boosts | One player buys, everyone benefits (social and generous) |
| Skip a stage | Use sparingly; it undercuts the challenge |
| Private servers | Practice and friends |

Live multipliers can be advertised in the title tag (for example "[X2]") only while they are actually active ([Naming, icon and title trends](../21-hits-and-trends/naming-icon-and-title-trends.md)).

## Retention

Daily speed bonuses, weekly new courses or themes, rebirth goals, leaderboards, events with admin boosts ([Live events and admin events](../21-hits-and-trends/live-events-and-admin-events.md)).

## Saturation and twists

The format has a tiny content floor, so copies arrive within weeks. By August 2026 two near-identical games from unrelated studios were in the top 10, and the leader's players fell about 60% from August to September (StudioKrew). Entering late needs a real twist. Twist directions:

| Twist | Example idea (original) |
|---|---|
| Change the verb | Every swing, jump, stroke or skip adds power instead of steps (the October 2026 snapshot showed a "+1 Stone Skipping" game) |
| Add consequence | Races against other players where collisions steal speed |
| Add collection | Speed opens areas with collectibles or pets ([Collection and variants](../03-rarity-and-rng/collection-and-variants.md)) |
| Add co-op | Teams relay speed or carry each other |
| Add building | Players build their own courses for others |

## Clip moments

Absurd speeds, near misses, falling from the final stage, record runs, admin-boost chaos.

## Traps

| Trap | Fix |
|---|---|
| Physics breaking at high speed | Caps, scaled courses, custom movement |
| Speed exploiters on leaderboards | Server validation of movement and times |
| Identical to ten other games | A twist that changes play ([Trend lifecycle](../15-market-research/trend-lifecycle.md)) |
| Boredom after the first rebirth | New courses, cosmetics and goals per rebirth tier |

## For agents

- [ ] Speed is server-owned and capped; movement and times are validated.
- [ ] Every run shows progress against milestones; restarts are instant.
- [ ] The pitch names its twist and the wave's phase with chart evidence.
- [ ] Title boost tags are true at all times.

Sources: StudioKrew boards (July-September 2026, citing GGAID and Rolimon's); the studio's chart snapshot of 2026-10-24. Accessed 2026-10-24.

Related: [Obby and platformer playbook](obby-and-platformer.md) · [AFK, idle and short-session games](../21-hits-and-trends/afk-idle-and-short-session-games.md) · [Trend waves](../21-hits-and-trends/trend-waves.md) · [Simulator and incremental playbook](simulator-incremental.md) · [Rebirth and prestige](../04-progression-and-economy/rebirth-and-prestige.md)
