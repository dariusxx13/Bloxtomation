---
title: Tower defense playbook
date: 2026-10-24
tags: [genre, tower-defense, strategy, playbook]
aliases: [Tower defense, TD]
summary: How to build Roblox tower defense games: lanes and waves, unit design and summoning, co-op matches, difficulty modes, meta-progression and fair monetization.
audience: [human, agent]
---

# Tower defense playbook

Tower defense (TD) games ask players to place units along a path to stop waves of enemies. On Roblox, the successful formula is co-op TD with collectible units (often themed after a popular style, but original characters are required unless licensed), meta-progression between matches, and frequent unit updates.

Roblox genre: Strategy, subgenre Tower Defense.

## Audience

Players who enjoy strategy and collection; skews slightly older than simulators. Sessions are match-based (10-30 minutes per match).

## The loop

```
Moment:  place or upgrade a unit -> enemies pop -> money
Match:   waves get harder -> place and upgrade units -> boss waves -> win or lose -> rewards
Long:    summon or unlock units -> level and evolve them -> harder maps and modes -> events
```

## Match design

- **Maps** with clear paths, placement zones and a distinct theme; several maps with different path shapes.
- **Waves**: escalate gradually with variety (fast, armored, flying, splitting, healing enemies), boss waves every 5-10 waves.
- **Economy in match**: money per kill and per wave; upgrade costs that create choices (more units vs upgrading existing ones).
- **Unit roles**: single-target damage, area damage, slow and control, support (money, buffs), anti-air or detection for special enemies.
- **Difficulty modes**: easy, normal, hard, nightmare; endless or challenge modes for veterans.
- **Speed controls**: 2x speed (often a pass or unlock), auto-skip waves.
- **Co-op**: 1-4 players share a map, each with their own money and placements; voting on difficulty and skips.

## Meta-progression

- **Unit acquisition**: summons (random, with rarity) and fixed unlocks; if summons can be bought with Robux or Robux-bought currency, disclose odds and gate with `PolicyService`.
- **Unit leveling, evolution and traits** (random modifiers; disclose odds if paid).
- **Loadouts** of a limited number of units per match.
- **Player level** and rewards for completing maps and modes.
- **Battle pass and daily challenges**.

## Balance

- Every unit has a clear niche. Avoid a single best unit that makes others irrelevant.
- New units in updates should be interesting, not simply stronger (power creep kills older content).
- Test boss waves with typical free loadouts; a mode that only paid units can beat is a pay wall.

## Monetization

Extra unit slots, 2x speed, auto-skip, VIP, premium currency packs for summons (with disclosure), battle pass, exclusive cosmetic skins. Avoid exclusive Robux-only units that dominate.

## Retention

New units and maps every update, limited-time event units and modes, daily challenges, raids or boss events, leaderboards for endless mode.

## Social

Co-op matchmaking, party queue with friends, trading units (if economy supports), helping newcomers through hard maps (carry rewards).

## Clip moments

Last-second boss defeats, absurd high waves in endless mode, rare summons.

## Traps

| Trap | Fix |
|---|---|
| Matches too long for mobile sessions | Shorter maps, 2x speed, save-and-resume is hard so keep matches 10-20 min |
| Power creep each update | New niches and mechanics instead of bigger numbers |
| Using copyrighted characters | Original designs only, unless licensed |
| Server lag with many enemies and projectiles | Server simulates enemy positions along the path mathematically; clients render; pool projectiles |

Related: [RNG systems and pity](../03-rarity-and-rng/rng-systems-and-pity.md) · [Session structure](../02-core-loop/session-structure.md) · [IP and licensing](../17-policy-and-business/ip-and-licensing.md) · [Performance optimization](../13-building-it-right/performance-optimization.md)
