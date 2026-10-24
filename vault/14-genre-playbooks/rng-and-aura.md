---
title: RNG and aura playbook
date: 2026-10-24
tags: [genre, rng, aura, collection, playbook]
aliases: [RNG games, Aura games, Rolling games]
summary: How to build "roll for rare things" games: the roll loop, "1 in X" rarity, luck systems, auras as show-off, auto-roll, biomes and events, monetization and compliance.
audience: [human, agent]
---

# RNG and aura playbook

RNG games strip the collection genre to its core: press roll, get something random with a "1 in X" rarity, equip it, show it off, and keep rolling for something rarer. Auras (visual effects around the character), titles, items and characters are common rewards. The genre lives on anticipation, spectacle and status.

Roblox genre: often Simulation (Incremental) or Entertainment, depending on design.

## Audience

Young and teen players; strong appeal for collectors and for watching rare pulls (huge streaming and short-video content). Sessions can be long because of auto-roll.

## The loop

```
Moment:  roll -> build-up -> reveal "1 in 4,096" -> equip or store
Session: roll many times -> luck boosts (potions, biomes, events) -> rare pull -> show off
Long:    collection index, rarest-ever pulls, crafting (gauntlets, machines), new auras each update
```

## "1 in X" rarity

Each item has a rarity written as "1 in X" (1 in 2, 1 in 16, 1 in 1,000, 1 in 1,000,000+). Players understand it instantly and it makes large numbers exciting.

- With luck `L`, a common implementation divides X by L (rarity 1 in 1,000,000 becomes 1 in 100,000 at 10x luck), then picks the rarest item whose threshold the roll passes. Whatever the method, compute the true resulting probability for display when Robux is involved.
- Spread items across magnitudes so every session has a "rare for me" moment and the top of the table is almost mythical.
- Add new top-end items with every update.

See [Rarity tiers and odds](../03-rarity-and-rng/rarity-tiers-and-odds.md) and [RNG systems and pity](../03-rarity-and-rng/rng-systems-and-pity.md).

## Systems checklist

- [ ] Roll button with satisfying reveal scaling by rarity (see [Reveal and hatch design](../03-rarity-and-rng/reveal-and-hatch-design.md)).
- [ ] Roll cooldown and quick-roll upgrades; auto-roll with "stop on rarity" setting.
- [ ] Luck sources: permanent upgrades, potions, biomes or weather events (time-limited world states with luck bonuses and exclusive items), friends, passes, events. Additive stacking, displayed and capped.
- [ ] Inventory with storage, lock, equip, delete filters.
- [ ] Collection index with "1 in X" and discovery dates.
- [ ] Crafting: combine items or materials into equipment that boosts luck or roll speed.
- [ ] Global announcements for ultra-rare pulls (rate-limited, cross-server for the rarest).
- [ ] Settings: hide others' auras, reduce effects.

## Auras as the product

- Auras must be gorgeous, distinct and readable at distance; rarer means bigger and more animated.
- Performance: client-rendered, culled by distance, with a hide option. A server full of top auras is a stress test.
- Equipped aura plus title above the head is the status display.

## Monetization

Quick roll, auto roll, x2 luck pass, more storage, luck potions (products), server luck boosts, cosmetic effects. Rolls themselves are usually free (time-based); if any random outcome is obtained with Robux or Robux-bought items (paid rolls, paid luck), odds disclosure and `PolicyService` rules apply. See [Monetization compliance](../09-monetization/monetization-compliance.md).

## Retention

Biome or weather rotations with exclusive items (come back to catch the rare biome), daily rewards with potions, weekly updates adding new top-tier auras, events with exclusive items, index completion rewards.

## Social

Visible auras and titles, server announcements, friend luck bonus, competitive "rarest pull" leaderboards, trading if the economy supports it.

## Clip moments

Ultra-rare reveal with server reaction, first-ever pull of a new item after an update, a rare biome starting.

## Traps

| Trap | Fix |
|---|---|
| Uncapped luck breaks the top tiers | Additive stacking with caps |
| Reveals too slow for auto-roll | Fast mode; only rare results interrupt |
| Paid luck without odds disclosure | Display true odds with boosts active |
| Aura lag in full servers | Distance culling, low-effects setting |
| Content runs dry | Each update adds new top items and a new mechanic |

Related: [Rarity tiers and odds](../03-rarity-and-rng/rarity-tiers-and-odds.md) · [RNG systems and pity](../03-rarity-and-rng/rng-systems-and-pity.md) · [VFX and particles](../07-characters-vfx-and-assets/vfx-and-particles.md) · [Simulator and incremental playbook](simulator-incremental.md)
