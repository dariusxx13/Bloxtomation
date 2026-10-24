---
title: Merge and number games playbook
date: 2026-10-24
tags: [genre, merge, incremental, numbers, idle, playbook]
aliases: [Merge games, Number-go-up games, Incremental merge]
summary: How to build merge and "number goes up" games on Roblox - combining items into stronger ones, big-number progression, rebirths and commanders, readable huge numbers, idle and active balance, social show-off, monetization, and the risk of shallow copies - with a dated example from the 2026 charts.
audience: [human, agent]
---

# Merge and number games playbook

Merge games ask players to combine two of the same thing into one better thing, again and again, while numbers climb into the absurd. They are a branch of incremental games ([Simulator and incremental playbook](simulator-incremental.md)). In June 2026, Merge a Nuke! climbed from a low of about 4.5K to a high of about 49.7K daily average players as it added rebirths and commander features (Bloxodes, June 2026).

Roblox genre: Simulation.

## The loop

```
Moment:  buy or spawn a level-1 item -> drag two together -> a level-2 item pops out (satisfying merge feedback)
Session: fill the board -> merge up -> unlock the next tier -> income grows -> bigger purchases
Long:    rebirth for multipliers -> new boards or worlds -> rare and special merges -> leaderboards
```

## Core mechanics

- **The board:** a grid or plot with limited slots; space pressure forces merging decisions.
- **Spawning:** items appear on a timer, by tapping, or by purchase with soft currency.
- **Merging:** two identical items become one of the next tier; chains of merges are the dopamine.
- **Income:** items generate currency by tier; higher tiers grow income steeply.
- **Special items:** wildcards, boosters, and rare spawns that skip tiers.
- **Rebirth or prestige:** reset the board for a permanent multiplier and a new unlock (a commander, a new board) ([Rebirth and prestige](../04-progression-and-economy/rebirth-and-prestige.md)).

## Big numbers

- Use short notation (1.2K, 3.4M, 5.6B, then named suffixes or scientific notation) consistently; the template's `Format.short` handles this.
- Show the **rate** ("+12.4M/s") as well as the total.
- Make each new tier visibly bigger and flashier, so number growth is felt, not just read ([Reward, UI and hatch VFX](../19-vfx/reward-ui-and-hatch-vfx.md)).
- Watch for floating-point limits at extreme values; store very large values with care (for example as mantissa and exponent) if the design goes beyond about 10^308.

## Idle and active balance

- Offline earnings capped to a few hours, with a clear "while you were away" summary ([Idle and offline progression](../04-progression-and-economy/idle-and-offline-progression.md)).
- Active play (merging, tapping boosts) clearly beats idle per minute.
- Auto-merge as a later unlock or pass, slightly less efficient than manual merging early on.

## Social and show-off

- A visible board or base other players can see and admire.
- Server announcements for top-tier merges.
- Leaderboards for highest tier reached and income per second, server-validated.
- Gifting or trading of special items only with proper policy checks ([Inventory and trading systems](../13-building-it-right/inventory-and-trading-systems.md)).

## Engineering notes

- Board state lives on the server; clients request merges (slot A + slot B); the server validates both items exist, are identical and mergeable, then applies the merge.
- Income is computed on the server from the board state, not counted by the client.
- Use attributes or compact snapshots to replicate the board; avoid one remote event per income tick.
- The economy sheet must model tier income growth, spawn rates and rebirth multipliers ([Worked economy example](../04-progression-and-economy/worked-economy-example.md)).

## Monetization

Board expansions, auto-merge, faster spawners, offline-earnings extensions, cosmetic item skins and board themes, boosts measured in minutes of income. Luck or rare-spawn boosts that change odds must disclose the effect ([Monetization compliance](../09-monetization/monetization-compliance.md)).

## Retention

Daily spawn bonuses, weekly special items, limited-time event boards, rebirth milestones with new mechanics.

## Clip moments

Chain merges that cascade, the first item of a new tier, absurd numbers, huge rebirths.

## Traps

| Trap | Fix |
|---|---|
| Copies with nothing new | A twist: a theme, a merge rule or a social layer that changes play ([Trend lifecycle](../15-market-research/trend-lifecycle.md)) |
| Numbers that stop feeling meaningful | New mechanics per rebirth, not only bigger multipliers |
| Client-side merging | Server validation of every merge |
| Board UI unusable on phones | Large slots, drag with snapping, tap-to-merge alternative |

## For agents

- [ ] Merges and income are server-computed; the client only requests and renders.
- [ ] The economy sheet models tiers, spawns, offline caps and rebirths.
- [ ] The pitch names a twist beyond the base merge loop.

Sources: Bloxodes June 2026 report (accessed 2026-10-24).

Related: [Simulator and incremental playbook](simulator-incremental.md) · [Rebirth and prestige](../04-progression-and-economy/rebirth-and-prestige.md) · [Idle and offline progression](../04-progression-and-economy/idle-and-offline-progression.md) · [Economy math](../04-progression-and-economy/economy-math.md) · [AFK, idle and short-session games](../21-hits-and-trends/afk-idle-and-short-session-games.md)
