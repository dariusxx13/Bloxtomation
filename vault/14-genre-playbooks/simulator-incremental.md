---
title: Simulator and incremental playbook
date: 2026-10-24
tags: [genre, simulator, incremental, playbook]
aliases: [Simulator, Clicker, Incremental]
summary: How to build a Roblox simulator or incremental game: the loop, first session, zones, pets, rebirths, monetization, retention, and the traps that kill most simulators.
audience: [human, agent]
---

# Simulator and incremental playbook

Simulators are one of Roblox's defining genres: perform a simple action, earn currency, upgrade, unlock new zones, hatch pets, rebirth, repeat. They are easy to understand, great on phones and monetize well, which also makes them crowded. Success depends on a satisfying moment loop, a sharp first session, a clever theme or twist, and relentless updates.

Roblox genre: Simulation, subgenre Incremental Simulator (or Idle for low-input variants).

## Audience

Mostly younger players (roughly 8-14), heavily mobile, motivated by visible growth, collecting and showing off. Sessions of 15-30 minutes; many return daily.

## The loop

```
Moment:  click / swing / walk into resource -> pop + number -> currency
Session: currency -> upgrades (power, speed, capacity) -> next zone gate -> new resources (x multiplier)
         currency or gems -> eggs -> pets (multipliers) -> faster everything
Long:    rebirth (reset for permanent multiplier) -> rebirth layers, collection index, leaderboards, events
```

Common variants: "lift weights to get stronger", "collect and sell" (backpack capacity then sell area), "mine and dig", "click to grow", "race and train speed".

## First session (target)

| Time | Beat |
|---|---|
| 0-15 s | Spawn facing the first resource; tool auto-equipped; tap prompt |
| 15-60 s | First currency with juicy feedback; counter appears |
| 1-3 min | First upgrade (guided); action visibly faster or stronger |
| 3-8 min | First egg (guaranteed good pet); pet follows and boosts |
| 8-15 min | Zone 2 gate opens with a dramatic reveal |
| 15-30 min | Second egg, more upgrades, first leaderboard glimpse |
| 30-60 min | First rebirth explained and taken |

## Systems checklist

- [ ] Core action with strong juice (see [Game feel and juice](../02-core-loop/game-feel-and-juice.md)).
- [ ] Upgrade lines: power, speed, capacity (if collect-and-sell), luck.
- [ ] Zone chain with visible gates and per-zone multipliers (see [Progression architecture](../04-progression-and-economy/progression-architecture.md)).
- [ ] Eggs per zone with clear odds (see [Rarity tiers and odds](../03-rarity-and-rng/rarity-tiers-and-odds.md)).
- [ ] Pets: equip slots, equip best, multipliers, variants (golden, rainbow), index.
- [ ] Rebirth with preview and celebration (see [Rebirth and prestige](../04-progression-and-economy/rebirth-and-prestige.md)).
- [ ] Daily rewards, playtime gifts, daily quests.
- [ ] Leaderboards in the world (power, rebirths).
- [ ] Server events (2x luck hour, meteor shower, boss).
- [ ] Codes and group reward.

## Economy notes

- Use exponential costs and multipliers; compute time-to-goal for the first five goals (see [Economy math](../04-progression-and-economy/economy-math.md)).
- Short number formats with suffixes; numbers will reach enormous values.
- Cap multiplier categories; check a maxed paying player's total multiplier.
- Add sinks with every update (new eggs are the classic sink).

## Monetization

Classic passes: x2 Coins, Auto-click / Auto-collect, +Pet equip slots, +Storage, x3 / x8 hatch, faster hatch, Lucky, VIP. Products: gem packs, starter pack, luck potions, server luck boost, rebirth boosts. See [Product catalog](../09-monetization/product-catalog.md).

Fairness: free players reach every zone; pets from Robux eggs follow odds disclosure rules.

## Retention

Daily rewards with a strong day 7, streak bonuses, daily quests, weekly updates with a new egg or zone, events with exclusive pets, rebirth rhythm, index completion rewards.

## Social

Friend luck bonus, visible pets and auras, leaderboards, trading (later, once the economy is stable; see [Trading economies](../04-progression-and-economy/trading-economies.md)), server-wide boosts.

## Clip moments

Secret pet hatches with server announcements, absurd numbers, giant pets, huge rebirth counts.

## What kills simulators

| Trap | Fix |
|---|---|
| Boring moment loop hidden behind numbers | Invest in feel; add crits, combos, random bonus drops |
| Second zone wall at minute 20 | Compute time-to-goal for goals 1-5 |
| Generic theme that looks like 100 other simulators | A twist in theme or mechanic; distinct art; see [Trend lifecycle](../15-market-research/trend-lifecycle.md) |
| Runaway multipliers after a few updates | Category caps, new dimensions instead of bigger numbers |
| Update drought | Weekly egg or zone; content backlog |
| Pay-to-progress walls | Free path to every zone; sell speed and convenience |

## Build order for an agent team

1. Moment loop prototype with juice (1-2 days of work).
2. Upgrades + zone 2 + economy sheet.
3. Eggs + pets + odds UI.
4. Rebirth.
5. Data, receipts, analytics, onboarding funnel.
6. Passes and starter pack.
7. Daily systems, leaderboards, events framework.
8. Content: zones 3-6, eggs, pets.

Related: [Core loop design](../02-core-loop/core-loop-design.md) · [Economy math](../04-progression-and-economy/economy-math.md) · [Rebirth and prestige](../04-progression-and-economy/rebirth-and-prestige.md) · [Collection and variants](../03-rarity-and-rng/collection-and-variants.md) · [RNG and aura playbook](rng-and-aura.md)
