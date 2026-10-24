---
title: Economy math
date: 2026-10-24
tags: [economy, math, formulas, balance, progression]
aliases: [Balancing formulas, Cost curves, Time to goal]
summary: The formulas behind cost curves, income curves, time-to-goal, zone gates, rebirth multipliers, luck and revenue estimates, with worked examples and a spreadsheet layout.
audience: [human, agent]
---

# Economy math

You do not need advanced math to balance a Roblox economy, but you do need to compute time-to-goal before you build content. Most economies that "feel wrong" are wrong in one of five places: the first upgrade gap, the second goal, the zone jump, the rebirth cycle, or runaway multipliers. This note gives the formulas and worked examples.

> [!IMPORTANT]
> Every number in a design should state its target and its comparable (a measured game, a previous update), or be labelled "first-pass estimate". Show the formula, not just the resulting table.

## 1. Exponential costs and income

The standard shape: each level costs a constant factor `r` more than the last, and each level multiplies income by a factor `g`.

```
cost(L)   = C0 * r^L
income(L) = I0 * g^L                (per minute)
time(L)   = cost(L) / income(L) = (C0 / I0) * (r / g)^L
```

- If `r = g`, every upgrade takes the same time: progress feels flat but steady.
- If `r > g`, each upgrade takes a little longer: a natural slowdown that pushes players to the next zone or a rebirth. This is the normal design.
- If `r < g`, upgrades get faster forever: the economy runs away. Avoid.

Rules of thumb for early-game upgrade lines: `r` between 1.15 and 1.6; `r / g` between 1.03 and 1.15.

### Worked example

`C0 = 15` coins, `r = 1.35`, `I0 = 60` coins per minute (one coin per click at one click per second), `g = 1.25`. Then `r / g = 1.08`: each upgrade takes 8% longer than the last.

| Level | Cost | Income per minute | Minutes to afford | Cumulative minutes |
|---|---|---|---|---|
| 0 | 15 | 60 | 0.25 | 0.2 |
| 5 | 67 | 183 | 0.37 | 1.8 |
| 10 | 302 | 559 | 0.54 | 4.2 |
| 15 | 1,352 | 1,705 | 0.79 | 7.6 |

Fifteen upgrades in under eight minutes, each under a minute apart: a healthy first-session pace. By level 30 the gap is about 2.5 minutes and growing, which is the signal for a new zone or a new upgrade line.

## 2. Time to goal

The one formula to compute for every goal:

```
minutes_to_goal = (goal_cost - current_balance) / income_per_minute
```

Compute it for a **non-paying player playing normally** (not optimally), at the point in their life when they will see the goal. Do this for at least the first five goals.

Targets (rules of thumb, see [Progression architecture](progression-architecture.md)):

| Goal | Target time from previous goal |
|---|---|
| First upgrade | under 1 minute |
| First named goal (zone 2, first rare) | 10-15 minutes from join |
| Second named goal | another 10-15 minutes |
| First rebirth | 30-60 minutes from join |
| Each later rebirth | gradually longer, typically 20-90 minutes |

## 3. Zone gates

A zone gate is a one-time large cost that unlocks a big income multiplier.

```
gate_cost(z)       = income_at_arrival(z) * target_minutes(z)
income_multiplier  = value of zone z resources / value of zone z-1 resources
```

Design steps:

1. Decide the target minutes to save for the gate (for example 3 minutes of income at the expected arrival point).
2. Set the gate cost from the income the player will have when they arrive.
3. Give the new zone a resource multiplier large enough that the first upgrades in the new zone feel fast again (commonly 3-10x the previous zone).

The result is the "sawtooth": slowing down near the end of a zone, then a jump.

## 4. Rebirth (prestige) math

A rebirth resets progress (coins, upgrades, sometimes zones) in exchange for a permanent multiplier.

```
multiplier(n) = 1 + k * n              (additive; easy to read)
multiplier(n) = m^n                    (multiplicative; explosive, needs caps)
rebirth_cost(n) = R0 * q^n
time_to_rebirth(n) ≈ rebirth_cost(n) / (base_income * multiplier(n))
```

With additive multipliers, `time_to_rebirth` grows roughly like `q^n / n`. With `q = 2` and `k = 0.5`, the second rebirth (n = 1) needs twice the coins of the first (n = 0) but earns 1.5x faster; at n = 10 it needs 1,024x the coins of the first and earns 6x faster, so it takes about 170x longer than the first rebirth did. That growth is why games add **rebirth upgrades, multiple rebirth tiers ("super rebirth") or rebirth buttons that do several at once** to keep the cycle length sane.

Rules of thumb:

- The first rebirth should take 30-60 minutes and roughly double the speed of early progress.
- After a rebirth, the player should regain their pre-rebirth position in about a quarter to a third of the time it originally took. Faster than that makes rebirths trivial; slower makes them punishing.
- Show the next multiplier and the time savings before the player confirms. See [Rebirth and prestige](rebirth-and-prestige.md).

## 5. Multipliers and runaway growth

Multipliers come from everywhere: rebirths, pets, passes, potions, friends, events. If they all multiply each other, the late-game number explodes and every price you set becomes wrong.

```
total = (1 + a1 + a2 + ...)            additive inside a category
      * (1 + b1 + b2 + ...)            next category
      * ...
```

Rules:

- **Additive inside categories, multiplicative across a few categories.** For example, all pets add together, all potions add together, and the categories multiply.
- **Cap each category** and show the cap ("Pet bonus: 340% / max 500%").
- **Check the maximum**: compute the total multiplier for a maxed paying player. If it is 1,000 times a free player's, progression for free players will feel pointless in shared spaces (leaderboards, PvP).
- **"2x Coins" pass**: count it as a category multiplier of 2, not a multiplier on top of all others, unless you have balanced for it.

## 6. Luck math

Probability of getting at least one hit in `n` tries: `1 - (1 - p)^n`. Expected tries: `1 / p`. For 50%: about `0.69 / p`. For 90%: about `2.3 / p`.

With luck `L` applied as a weight multiplier on a tier with base weight `w` out of total weight `W`:

```
p_lucky = (w * L) / (W - w_affected + w_affected * L)
```

where `w_affected` is the total weight of all tiers luck applies to. For very rare tiers this is close to `p * L`; for common tiers it is not, so always compute the real displayed odds. See [Rarity tiers and odds](../03-rarity-and-rng/rarity-tiers-and-odds.md).

## 7. Revenue math

The core monetization metrics (all visible in Creator Analytics):

```
payer conversion rate (PCR) = paying users / active users
ARPPU = Robux revenue / paying users
ARPDAU = Robux revenue / DAU = PCR * ARPPU
```

Rough earnings estimate:

```
daily Robux earned ≈ DAU * ARPDAU * 0.7      (your ~70% share on passes, products, Robux subscriptions)
daily USD at DevEx ≈ daily Robux earned * 0.0038
```

(Use 0.0054 for the eligible share of US 18+ purchases in qualifying games. Add Creator Rewards, Plus incentives and ad revenue separately. See [Platform payouts](../09-monetization/platform-payouts.md).)

Worked example: 20,000 DAU, PCR 2%, ARPPU 300 Robux:

- ARPDAU = 0.02 × 300 = 6 Robux of player spend per DAU per day
- Robux earned per day ≈ 20,000 × 6 × 0.7 = 84,000
- USD per day ≈ 84,000 × 0.0038 ≈ $319, about $9,600 per 30 days, before Creator Rewards and other income

PCR and ARPPU vary enormously by genre and audience age. Compare against the benchmark games in your analytics, not against this example.

## 8. A spreadsheet layout for any economy

Build this before building content. One row per level or goal:

| Column | Formula |
|---|---|
| Level or goal | 0, 1, 2, ... |
| Cost | `C0 * r^L` or hand-set |
| Income per minute at this point | from the income model, including expected pets and multipliers for a typical player |
| Minutes to afford | `cost / income` |
| Cumulative minutes | running sum |
| Session marker | which session (1, 2, 3...) this level falls in, assuming a typical session length |
| Day marker | which day, assuming typical sessions per day |
| Notes | zone gate, rebirth, new system unlock |

Make three versions: a **casual free player** (plays slowly, buys nothing), a **typical player**, and a **paying player** (has the main passes). The game must work for the first, feel great for the second, and not break for the third.

## For agents

- [ ] Every cost curve states `C0`, `r`, and the income model it was balanced against.
- [ ] Time-to-goal computed for the first five goals for a casual free player.
- [ ] Rebirth cycle lengths computed for rebirths 1, 5, 10 and 25.
- [ ] Maximum total multiplier computed for a maxed paying player, with caps per category.
- [ ] Luck odds computed with the real formula, not approximations, for the display.
- [ ] The economy sheet (three player types) is attached to the design.

Related: [Economy design](economy-design.md) · [Progression architecture](progression-architecture.md) · [Rebirth and prestige](rebirth-and-prestige.md) · [Rarity tiers and odds](../03-rarity-and-rng/rarity-tiers-and-odds.md) · [Economy sheet template](../18-templates-and-checklists/economy-sheet-template.md)
