---
title: Tycoon playbook
date: 2026-10-24
tags: [genre, tycoon, playbook]
aliases: [Tycoon, Base builder]
summary: How to build a Roblox tycoon: plot assignment, buy pads, droppers and collectors, pacing the build-out, rebirth, monetization and social show-off.
audience: [human, agent]
---

# Tycoon playbook

In a tycoon, each player gets a plot, buys producers (droppers, machines, workers) that generate money, collects it, and buys more until the plot becomes something impressive: a factory, a restaurant, a theme park, a city. Tycoons are among Roblox's oldest genres and still work when the theme is fresh and the build-out feels spectacular.

Roblox genre: Simulation, subgenre Tycoon.

## Audience

Broad, younger-leaning, mobile-heavy. Players love watching their creation grow and showing it to others. Sessions of 15-35 minutes.

## The loop

```
Moment:  step on buy pad -> structure builds with animation -> money starts flowing
Session: collect money -> buy next pads (producers, upgrades, decorations) -> income grows
Long:    complete the tycoon -> rebirth (new theme or multiplier) -> premium areas, events, customization
```

## Core mechanics

- **Plot assignment**: on join, claim a free plot automatically, mark it with the player's name and a beam on spawn. Release on leave (and save progress so the plot rebuilds on rejoin).
- **Buy pads**: physical buttons with price labels that appear in sequence as previous ones are bought. The next 2-3 pads are always visible.
- **Producers**: droppers that drop money parts onto conveyors into a collector, or simpler income-per-second machines. Physical dropped parts are charming but expensive; at scale, simulate income on the server and show cheap client-side visuals.
- **Collection**: walk-over collector pad or automatic income (auto-collect is a classic pass).
- **Build animations**: each purchase builds visibly (parts rise and assemble, sparkles). This is the genre's core juice.

## Pacing the build-out

- First pad affordable immediately; first dropper produces within seconds.
- Early pads every 15-45 seconds; the plot visibly transforms within 5 minutes.
- Milestones every 5-10 minutes (a new floor, a new section, a major machine).
- Completing the full tycoon should take hours across several sessions (for a free player); then rebirth.
- Compute pad prices against income with the formulas in [Economy math](../04-progression-and-economy/economy-math.md).

## Rebirth and depth

- Rebirth resets the plot for a permanent income multiplier, and often unlocks new themes, decorations or a second plot style.
- Optional depth: workers or managers, upgrades per machine, research trees, decoration and customization (status), mini-games inside the tycoon.

## Saving tycoon state

Save which pads are bought (ids), upgrade levels, money and rebirths, not the built parts. On rejoin, rebuild instantly (no slow animations for already-bought pads) and grant capped offline earnings.

## Monetization

x2 Cash, Auto-collect, faster droppers, VIP room (cosmetic), exclusive decoration sets, premium machines (with fair free alternatives), cash packs, starter pack, rebirth boosts. See [Product catalog](../09-monetization/product-catalog.md).

## Social and show-off

- Plots arranged around a shared center so players see each other's progress.
- Visiting and rating other players' builds.
- Leaderboards by income and rebirths.
- Co-op tycoons (two friends share one plot) can boost co-play.

## Clip moments

The final big build completing, a massive income number, a ridiculous themed creation, a friend's tycoon being visited.

## Traps

| Trap | Fix |
|---|---|
| Physics-heavy droppers lag servers | Simulate income on the server; visual drops on clients only |
| Plot too small for late-game | Plan the final layout first |
| Silent purchases | Build animation and sound for every pad |
| Long waits between pads | Pace with the time-to-goal sheet |
| Plot lost on rejoin | Save bought pad ids; rebuild instantly |

Related: [Idle and offline progression](../04-progression-and-economy/idle-and-offline-progression.md) · [World and level design](../06-world-and-look/world-and-level-design.md) · [Simulator and incremental playbook](simulator-incremental.md) · [Grow and farm playbook](grow-and-farm.md)
