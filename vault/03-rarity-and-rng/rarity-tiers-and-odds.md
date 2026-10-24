---
title: Rarity tiers and odds
date: 2026-10-24
tags: [rng, rarity, odds, math, economy]
aliases: [Rarity tiers, Drop tables, Odds math]
summary: How to build rarity ladders and drop tables, the probability math behind them, color conventions players expect, and how to check a table before shipping.
audience: [human, agent]
---

# Rarity tiers and odds

Rarity is the backbone of most Roblox collection games: pets, auras, fish, crops, weapons, units. A good rarity ladder gives every roll a chance of excitement, makes the top tiers legendary, and keeps the economy healthy. A bad one either floods players with "rare" items or hides everything good behind odds nobody ever hits.

## Tier ladders players already understand

Roblox players carry rarity conventions from game to game. Use them unless you have a reason not to.

| Tier | Typical color | Feeling |
|---|---|---|
| Common | Grey or white | Filler, quantity |
| Uncommon | Green | Small upgrade |
| Rare | Blue | First excitement |
| Epic | Purple | Good pull, worth showing |
| Legendary | Gold or orange | Big moment, announce it |
| Mythic | Red or pink | Server-wide moment |
| Secret, Divine, Celestial (top tiers) | Rainbow, animated, black-and-gold | Clip-worthy, near-mythical |

Rules of thumb:

- **5 to 8 tiers** is the sweet spot. Fewer feels flat; more blurs the colors together.
- **Name and color stay consistent everywhere**: in the egg odds panel, inventory, chat announcements, the item's glow and the reveal animation.
- **The top tier gets animated treatment** (rainbow gradient, particles), so it is recognizable at a glance in a clip.

## Building a drop table

A drop table lists each outcome and its probability. Probabilities must add up to exactly 100%.

### Step 1: choose the tier weights

A common starting shape is a geometric ladder where each tier is roughly 3 to 10 times rarer than the one below:

| Tier | Example weight | Probability | "One in" |
|---|---|---|---|
| Common | 60 | 60% | 1.7 |
| Uncommon | 25 | 25% | 4 |
| Rare | 10 | 10% | 10 |
| Epic | 4 | 4% | 25 |
| Legendary | 0.9 | 0.9% | 111 |
| Mythic | 0.1 | 0.1% | 1,000 |

Use **weights**, not percentages, in code: probability = weight / sum of weights. That way you can add an item without recomputing everything. The displayed odds must still be the true percentages (see below).

### Step 2: split tiers into items

If the Epic tier has four items with equal chances, each has 1% (4% / 4). Items within a tier do not need equal weights, but if they differ, the odds panel must show each item's own probability.

### Step 3: check the experience

For each tier, compute how long it takes a typical player to see one:

- **Expected rolls to the first hit** for a probability p is 1/p.
- **Chance to get at least one in n rolls** is `1 - (1 - p)^n`.
- **Rolls needed for a 50% chance** is about `0.69 / p`. For 90%, about `2.3 / p`.

Example: a Legendary at 0.9% (p = 0.009). Average 111 rolls; 50% of players get one within about 77 rolls; 90% within about 255 rolls.

Now convert rolls into time. If a player can roll once every 10 seconds in their first hour, 77 rolls is about 13 minutes: half of new players see a Legendary in their first session. That is a strong first session. If rolls cost 30 seconds of grinding each, it is nearly 40 minutes, and most players never see one on day 1.

> [!TIP]
> Design rarity by **time to see**, not by percentage. Decide when the median player should first see each tier (for example: Rare in the first minute, Epic by minute 5, Legendary by minute 20, Mythic in the first week, Secret maybe never), then derive the odds from the roll rate.

### Step 4: account for luck multipliers

If players can boost luck (potions, passes, upgrades, friends nearby), the effective odds change. A "2x luck" boost usually multiplies the weights of rare tiers, which also lowers common odds so the total stays 100%. Decide exactly how luck applies:

- **Multiply rare weights, renormalize.** Common: 60, Legendary: 0.9 becomes 1.8, then all weights are divided by the new total. Simple, honest, and easy to display.
- **Apply luck only above a tier** (for example Rare and above). Keeps commons stable.
- **Cap stacked luck** (for example, maximum 10x) or the top tiers become cheap and the economy inflates.

Paid luck boosts are "probability modifier items" under Roblox policy: you must explain their effect numerically before purchase and update displayed odds while they are active. See [Monetization compliance](../09-monetization/monetization-compliance.md).

## Displaying odds (required for paid randomness)

Platform fact (Roblox paid random items policy, 2026): if a random outcome can be obtained with Robux, or with anything bought with Robux (gems, tickets, keys), you must show **every possible outcome and its numeric probability** before the purchase.

- Percentages must add up to exactly 100%. Very small values may be rounded to a few significant decimals with a note that the displayed values may not sum to exactly 100% due to rounding.
- If there are too many outcomes to show in the world, a button with a **descriptive label** ("Odds", "Details") opening a list is fine. A bare (i) icon is not enough.
- When a boost changes the odds, the displayed odds must update to the player's true odds.
- If a player can only get an outcome once (for example, unique items), the odds must update for the remaining outcomes.
- Free random rewards (no Robux involved at any step) do not require disclosure, but showing odds anyway builds trust.

Show odds in the world, on the egg or crate itself (a `BillboardGui` listing each item with its percentage), and in the hatch menu. Players actually read these and compare games.

## Keeping the economy healthy

- **Supply grows with players.** A 0.1% item in a game with 50,000 daily players rolling 200 times each appears about 10,000 times a day. If it is tradable, it will not stay rare. Decide whether rarity should be "rare to get" (untradable or bound) or "rare to own" (supply-limited, tradable).
- **Retire old tops.** When you add a new top tier in an update, older top items become mid-tier. That is fine and expected, but keep them useful (collection index, crafting, trade value).
- **Duplicates need a use.** Merge into a stronger version, convert into currency, feed into an upgrade, or count toward an index. Useless duplicates make rolling feel bad.
- **Log every roll** as an economy or custom event with the tier as a custom field, so you can compare actual drop rates with the design. A bug in a weighted pick is easy to miss and expensive (see the check below).

## Checking a table before shipping

1. Sum all weights in code; assert the displayed percentages sum to 100% (within rounding).
2. Simulate one million rolls with the actual picking function. Every tier's observed frequency should be within a fraction of a percent (relative) of its designed probability.
3. Simulate with every luck boost and stacked boosts. Check the caps.
4. Compute median time-to-first for each tier at the roll rate of a new player, a mid-game player and a top player.
5. Confirm the odds UI reads from the same table the server rolls from. Never maintain two copies.

## A correct weighted pick (Luau)

```lua
--!strict
export type Entry = { id: string, weight: number }

local function pickWeighted(entries: { Entry }, rng: Random): string
	local total = 0
	for _, entry in entries do
		total += entry.weight
	end
	local roll = rng:NextNumber() * total
	for _, entry in entries do
		roll -= entry.weight
		if roll < 0 then
			return entry.id
		end
	end
	return entries[#entries].id -- floating point safety net
end
```

Use one `Random` object per server (seeded by default), never `math.random` in hot paths shared with other systems. Rolls always happen on the server.

## For agents

- [ ] Tier names and colors are consistent across odds panel, inventory, reveal and chat.
- [ ] Each tier has a designed median time-to-first-see at new, mid and late game roll rates.
- [ ] Weights live in one shared config used by both the server roll and the odds display.
- [ ] One-million-roll simulation passes for base odds and every luck state.
- [ ] Paid paths show all outcomes with percentages summing to 100% and update with boosts.
- [ ] Duplicates have a use.

Related: [RNG systems and pity](rng-systems-and-pity.md) · [Reveal and hatch design](reveal-and-hatch-design.md) · [Collection and variants](collection-and-variants.md) · [Monetization compliance](../09-monetization/monetization-compliance.md) · [Economy math](../04-progression-and-economy/economy-math.md)
