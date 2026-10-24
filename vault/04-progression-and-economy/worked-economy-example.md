---
title: Worked economy example
date: 2026-10-24
tags: [economy, math, pacing, simulator, worked-example]
aliases: [Economy worked example, Simulator economy numbers, Pacing example]
summary: A complete, simulated economy for a small tap simulator - action income, an upgrade cost curve, zone gates, a rebirth, and a 2x coins pass - with time-to-goal for casual, typical and paying players, how the numbers were tuned to hit the first goal at 10-15 minutes and the first rebirth at 30-60 minutes, the sources and sinks table, and the checks a designer runs before shipping.
audience: [human, agent]
---

# Worked economy example

The formulas in [Economy math](economy-math.md) are easier to trust once you see them produce a full pacing table. This note builds a small simulator economy from scratch, simulates three player types, and tunes it until the first goal lands in the 10-15 minute window the DESIGN gate asks for. All numbers are illustrative (Rule of thumb); the method is the point. The template's own economy lives in `template/src/shared/Config/` with helpers in `template/src/shared/Util/EconomyMath.luau`.

## The design

| Element | Rule |
|---|---|
| Core action | Tap a resource node; each tap gives `coins = 1 × powerMultiplier × zoneMultiplier × passMultiplier` |
| Tap rate | Casual 2 taps per second, typical 3 (auto-tap later is a separate upgrade) |
| Power upgrade | Level `L` multiplies income by `1 + 0.25 × L`; costs `10 × 1.35^L` coins |
| Zones | Zone 1 ×1 (free), Zone 2 ×4 (5,000 coins), Zone 3 ×15 (80,000), Zone 4 ×50 (1,500,000 coins and Rebirth 1) |
| Rebirth | Available at 300,000 coins while in Zone 3; resets coins, power and zones for a permanent multiplier and unlocks the path to Zone 4 |
| Pass | "2x Coins" doubles all coin income |

### Why these shapes

- **Upgrade costs grow faster (1.35× per level) than their benefit (+0.25 per level).** Each level is a smaller relative gain, so upgrades slow down naturally and zones become the big jumps.
- **Zones multiply income in large steps** (×4, then ×3.75, then ×3.33), giving three clear "new place" moments.
- **The first rebirth sits in Zone 3**, and Zone 4 requires it, so rebirthing is both a reset and the key to the next place ([Rebirth and prestige](rebirth-and-prestige.md)).

Reference values: level 10 costs about 201 coins, level 20 about 4,043, level 30 about 81,285; the power multiplier is 3.5 at level 10, 6.0 at level 20 and 8.5 at level 30.

## The simulation

A simple model of a sensible player, stepped one second at a time:

1. Earn `taps per second × coins per tap`.
2. If the next zone is affordable, buy it.
3. Otherwise buy power levels while each costs no more than one minute of current income.
4. Record when each milestone happens.

### Results (minutes of active play)

| Milestone | Casual (2 taps/s) | Typical (3 taps/s) | Payer (3 taps/s, 2x Coins) |
|---|---|---|---|
| Power level 10 | 1.9 | 1.2 | 0.6 |
| Zone 2 (first goal) | 13.9 | 9.8 | 6.6 |
| Power level 20 | 45.9 | 12.1 | 7.2 |
| Zone 3 | 45.6 | 30.8 | 17.3 |
| First rebirth available | 72.0 | 48.6 | 26.8 |

### In days

Assume casual players play 15 minutes a day and typical players 25 minutes:

| Milestone | Casual | Typical |
|---|---|---|
| Zone 2 | Day 1 | Day 1 |
| Zone 3 | Day 4 | Day 2 |
| First rebirth | Day 5 | Day 2 |

### How it was tuned

The first version priced Zone 2 at 2,500 coins: typical players reached it in about 7 minutes, before they had learned the upgrade loop. Raising it to 4,000 moved it to about 8.6 minutes; 5,000 put it at about 9.8 minutes for typical players and 13.9 for casual players, inside the 10-15 minute target ([First session blueprint](../01-first-five-minutes/first-session-blueprint.md)). Zone 3 was raised from 60,000 to 80,000 at the same time to keep the gap between zones similar.

The first version also placed the rebirth after Zone 4, at 1,000,000 coins: typical players needed about 123 minutes, outside the vault's 30-60 minute rule of thumb for a first rebirth ([Key numbers](../99-reference/key-numbers.md)). Moving the rebirth into Zone 3 at 300,000 coins, and gating Zone 4 behind it, brought the first rebirth to about 49 minutes for typical players (thresholds of 200,000 and 400,000 gave about 44 and 54 minutes).

That is the normal workflow: change one number, re-run, compare the table, repeat.

## Reading the table

- **First goal:** Zone 2 at 10-14 minutes for casual and typical players meets DESIGN-03.
- **Session arc:** a typical player sees two zone unlocks in the first two sessions; a strong reason to come back.
- **Long goal:** the first rebirth in the second session for typical players and within the first week for casual players; Zone 4 is then the post-rebirth goal. Weekly events and daily rewards fill the gaps ([Retention systems](../10-retention-and-social/retention-systems.md)).
- **Pass impact:** the 2x Coins pass roughly halves time to each goal. That is a time saver, not a wall: casual free players still reach every zone. If a pass shortened only one player type's path dramatically, or made a goal unreachable without it, the pass would fail the fairness table ([Monetization strategy](../09-monetization/monetization-strategy.md)).

## Sources and sinks

| Currency flow | Source or sink | Notes |
|---|---|---|
| Tapping nodes | Source | Main income; scales with power and zone |
| Daily reward and codes | Source | Sized in minutes of income, not fixed numbers ([Anime community, updates and codes](../20-anime-games/anime-community-updates-and-codes.md)) |
| Power upgrades | Sink | Exponential cost |
| Zone unlocks | Sink | Large one-time costs |
| Rebirth | Sink (resets everything) | Converts progress into a permanent multiplier |
| Eggs and pets (if added) | Sink | Pets add multipliers; recheck the table ([Collection and variants](../03-rarity-and-rng/collection-and-variants.md)) |

Rewards sized "in minutes of income" (for example "a code worth 3 minutes of income") stay meaningful at every stage, which the template's `Grants.coinsForMinutes` helper implements.

## Checks before shipping

- [ ] The first goal lands at 10-15 minutes and the first rebirth at 30-60 minutes for a typical player in the simulation, then in real playtests ([Playtest report template](../18-templates-and-checklists/playtest-report-template.md)).
- [ ] No milestone needs more than about one session for a typical player in the first three days.
- [ ] Passes shorten paths without making any goal unreachable for free players.
- [ ] Every source and sink is listed; event rewards are capped.
- [ ] After adding any multiplier (pets, boosts, events), the simulation is re-run and the table updated.
- [ ] Real playtest times are compared with the simulation; the economy sheet records both ([Economy sheet template](../18-templates-and-checklists/economy-sheet-template.md)).

## For agents

- [ ] Economy proposals include a simulated pacing table for three player types and the script or sheet that produced it.
- [ ] Tuning changes one number at a time and records before and after.
- [ ] Rewards are expressed in minutes of income where possible.

Related: [Economy math](economy-math.md) · [Economy design](economy-design.md) · [Progression architecture](progression-architecture.md) · [Rebirth and prestige](rebirth-and-prestige.md) · [Simulator and incremental playbook](../14-genre-playbooks/simulator-incremental.md)
