---
title: Steal and defend playbook
date: 2026-10-24
tags: [genre, steal, base, pvp, playbook]
aliases: [Steal games, Heist games, Base raiding]
summary: How to build "collect valuable things in your base, steal from others, defend yours" games, the loop behind several of the biggest hits of 2025-2026, with balance, protection and fairness rules.
audience: [human, agent]
---

# Steal and defend playbook

The steal-and-defend loop drove some of Roblox's largest concurrency records in 2025 and 2026: players collect valuable things (creatures, eggs, items) into their base, where those things generate income, and other players can sneak in and steal them. It combines collection, idle income, social tension and constant clip moments.

Roblox genre: varies (often Simulation or Action); pick by the dominant activity.

## Audience

Young players love the drama and humor; older players enjoy the strategy and the chase. Very social and very clip-friendly.

## The loop

```
Moment:  grab a valuable thing -> carry it home under threat -> it earns money in your base
Session: buy or catch new valuables -> place them -> upgrade base defenses -> raid others -> defend
Long:    rarer valuables (mutations, secrets), bigger base, rebirths, events, trading
```

## Core mechanics

- **Sources of valuables**: a conveyor or spawn area where items appear for purchase or capture, with random rarities; eggs that hatch over time; catching in the world.
- **Base**: each player has a plot with slots; placed valuables generate income per second based on rarity.
- **Stealing**: a player picks up an item from another base and must carry it back to their own base (carrying slows them or prevents other actions); the owner can chase, hit or stop them.
- **Defense**: locks or shields with timers (lock your base for N seconds, with cooldowns), traps, defenders, base upgrades.
- **Counterplay**: getting hit while carrying drops the item; stolen items can be stolen back.

## Balance levers (tune these carefully)

| Lever | Effect |
|---|---|
| Distance between bases and paths | How long thieves are exposed |
| Carry speed penalty | How easy escapes are |
| Lock duration and cooldown | How safe owners are |
| Income per rarity | How much a single steal matters |
| Respawn and re-entry rules | How fast thieves can retry |
| Protection for new players | Whether newcomers survive their first minutes |

Use configs for all of them so you can tune live (see [Experiments and configs](../12-live-ops-and-launch/experiments-and-configs.md)).

## Fairness and protecting newcomers

The biggest risk in the genre is veterans farming newcomers, which destroys first-session retention.

- New-player protection for the first minutes or until a progression threshold.
- Steal targets scaled by progression (you cannot steal from players far below you, or steals from them yield little).
- Starting items that are not worth stealing.
- Offline protection: bases of absent players are locked or not present.
- A visible alarm and chase music when someone enters your base.

## Monetization

Extra base slots or floors, longer locks or faster lock cooldowns (keep fair), x2 money, luck for rare spawns, cosmetic base themes, server-wide events (rare item rain). Robux-bought random items follow disclosure rules. Avoid selling invulnerability: if paying makes you unstealable, the loop dies for everyone.

## Retention

Rare spawns at scheduled times (a reason to be online), events with limited valuables, mutations and secrets, base progression, daily rewards. Offline income (capped) brings players back.

## Social

Friends defending together, revenge mechanics, alliances, trading valuables, spectating chases. Chat drama is part of the fun; protect against harassment (newcomer protection, block options).

## Clip moments

Last-second steals, epic chases, a secret item being stolen, betrayal between friends, huge income numbers.

## Traps

| Trap | Fix |
|---|---|
| Veterans grief newcomers | Protection, scaled targets, starting items not worth stealing |
| Paying makes you unstealable | Sell convenience, not immunity |
| Items duplicated during steals | Server-authoritative ownership transfer with unique ids, atomic updates |
| Exploiters teleporting with items | Server checks carry path, speed and distance |
| Copying the top game's look and name | Discovery demotes non-unique games; twist the theme |

Related: [Social systems](../10-retention-and-social/social-systems.md) · [Security and anti-exploit](../13-building-it-right/security-and-anti-exploit.md) · [Idle and offline progression](../04-progression-and-economy/idle-and-offline-progression.md) · [Trend lifecycle](../15-market-research/trend-lifecycle.md)
