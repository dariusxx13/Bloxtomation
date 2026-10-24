---
title: Anime units, gacha and traits
date: 2026-10-24
tags: [anime, gacha, summons, banners, pity, traits, rerolls, policy, rng]
aliases: [Summon banners, Gacha design, Trait rerolls, Unit summoning]
summary: How summon banners, rarity ladders, pity, duplicates, traits and rerolls work in anime games, with the probability math, a server-side roll sketch, the summon UX, Roblox's paid random item rules as written in the docs, and the ethical lines a studio should hold.
audience: [human, agent]
---

# Anime units, gacha and traits

Summoning characters ("units") from a banner is the engine of anime tower defense and many anime RPG, dice and card games. Done well, it creates excitement, goals and clips. Done badly, it creates pay walls, policy problems and community anger. This note covers the design, the math and the rules. General RNG patterns are in [RNG systems and pity](../03-rarity-and-rng/rng-systems-and-pity.md); reveal effects in [Reward, UI and hatch VFX](../19-vfx/reward-ui-and-hatch-vfx.md).

## Banner structures

| Banner type | How it works | Purpose |
|---|---|---|
| Standard banner | Always available, full unit pool | Baseline progression |
| Featured (rate-up) banner | A few units have boosted odds within their rarity | Sells the update's new units |
| Rotating shop or banner | Featured units change on a timer (for example hourly) | A reason to check back; creates "my unit is up" moments |
| Limited banner | Available for one update or event only | Urgency; use carefully (see ethics below) |
| Event banner | Pulled with event currency only | Rewards playing the event |

**Rule of thumb:** one standard banner plus one featured banner per update is enough. Too many banners split currency and confuse new players.

## Rarity ladder (example)

| Rarity | Per-pull odds (example) | Role in the roster |
|---|---|---|
| Rare | 70% | Early-game filler, evolution fodder |
| Epic | 24% | Solid mid-game units |
| Legendary | 5% | Team cores |
| Mythic | 0.9% | Stars of the update |
| Secret | 0.1% | Chase units; mostly bragging rights, modest power edge |
| **Total** | **100%** | Odds must sum to exactly 100% when displayed |

Keep the power gap between rarities **smaller than the odds gap.** A Mythic can be 30-50% stronger than a Legendary in its niche; it should not be 5× stronger. When the rarest units are essential, the game becomes a pay wall.

## Pity

Pity guarantees a top result after enough pulls without one.

| Pity type | How it works |
|---|---|
| Hard pity | Guaranteed Mythic (or better) on pull N if none appeared |
| Soft pity | Odds rise each pull after a threshold until a hit |
| Featured guarantee | If a top pull is not the featured unit, the next top pull is |
| Carry-over | Pity progress carries to the next banner (players strongly prefer this) |

### The math

With per-pull probability `p` and hard pity at pull `N`, the expected number of pulls per top result is:

```text
E = (1 - (1 - p)^N) / p
```

For a 0.9% Mythic with hard pity at 100 pulls: `E = (1 - 0.991^100) / 0.009 ≈ 66 pulls`, an **effective rate of about 1.5%**, not 0.9%. About 40% of players reach pity (0.991^100 ≈ 0.405). With hard pity at 150, the expected count is about 82 pulls (effective about 1.2%).

Put these numbers in the economy sheet: "a typical free player earns enough gems for X pulls per week, so they see a Mythic about every Y weeks" ([Economy math](../04-progression-and-economy/economy-math.md)). That sentence decides whether the free path feels fair.

## Duplicates

A duplicate pull should never feel like nothing.

| Duplicate handling | Effect |
|---|---|
| Stars or "constellations" | Each duplicate raises the unit's stars and stats (capped, for example at 5) |
| Shards | Duplicates convert to shards that buy a chosen unit from a shard shop |
| Evolution fodder | Duplicates are consumed to evolve |
| Sell value | Duplicates sell for soft currency |

A shard shop that lets players eventually **choose** a unit is a strong fairness tool: bad luck still progresses toward something specific.

## Traits and rerolls

Traits are random modifiers on a unit (or a player's race, clan or power). They create a second chase after the unit itself.

### Example trait table

| Trait tier | Odds per roll | Example effect |
|---|---|---|
| Common | 60% | +5% damage |
| Uncommon | 25% | +8% range |
| Rare | 10% | +12% attack speed |
| Epic | 4% | +20% damage and +5% range |
| Legendary | 0.9% | Money bonus +15% |
| Unique | 0.1% | A special passive (for example, attacks chain to a second enemy) |

### Reroll math

The chance of getting at least one result with odds `p` in `n` rolls is `1 - (1 - p)^n`:

| Target odds | Rolls for 50% | Rolls for 90% | Rolls for 99% |
|---|---|---|---|
| 1% | 69 | 230 | 459 |
| 0.1% | 693 | 2,302 | 4,603 |

Players hear "1%" and expect it in about 100 rolls; in fact 100 rolls only gives a 63% chance. If reroll items can be bought, these numbers mean real money. Keep top-trait power modest, add trait **locks** or a pity counter for rerolls, and make reroll items earnable in play.

## Server-side roll (sketch)

All rolls happen on the server, use the same tables the client displays, and update pity in the player's profile in the same step.

```lua
--!strict
-- Weighted roll with hard pity (sketch). Weights come from shared config,
-- the same table the odds display reads.
type Entry = { id: string, rarity: string, weight: number }

local rng = Random.new()

local function roll(entries: { Entry }, pityCount: number, pityAt: number, pityRarity: string): Entry
	local pool = entries
	if pityCount + 1 >= pityAt then
		local guaranteed: { Entry } = {}
		for _, e in entries do
			if e.rarity == pityRarity then
				table.insert(guaranteed, e)
			end
		end
		if #guaranteed > 0 then
			pool = guaranteed
		end
	end
	local total = 0
	for _, e in pool do
		total += e.weight
	end
	local pick = rng:NextNumber() * total
	for _, e in pool do
		pick -= e.weight
		if pick <= 0 then
			return e
		end
	end
	return pool[#pool]
end
```

The caller checks and spends the currency first, rolls, writes the result and the new pity counter to the profile, records an analytics event, and only then tells the client what to reveal. The template's hatching system (`template/src/server/Systems/Hatching.luau` with odds in `template/src/shared/Config/Eggs.luau`) follows this shape.

## Roblox's paid random item rules (Fact, creator docs, accessed 2026-10-24)

From the paid random items guidelines:

- Random items bought **directly or indirectly** with Robux are paid random items. That includes items bought with in-game currency that can be bought with Robux, and keys, reroll tokens or spin tickets bought with Robux.
- The docs list item types that count: capsule items (spins, eggs, chests), enhancement items (upgrades with a chance of working), combination items, and **probability modifier items such as luck boosts, pity systems, enhanced drops and rate-up scrolls**.
- You must show **all possible outcomes and their numerical odds** as percentages that sum to exactly 100% (rounding rules and a disclaimer are allowed for long decimals). If there are too many outcomes for the screen, a clickable pop-up with a descriptive word such as "Details" or "Info" is acceptable; a bare (i) symbol is not.
- Paid items that change odds (lucky potions, rate-up items) must explain their effect numerically, and displayed odds must update while they are active.
- If a player can only get one copy of an outcome, the remaining odds must be updated for that player.
- `PolicyService:GetPolicyInfoForPlayerAsync()` returns `ArePaidRandomItemsRestricted`. When it is true, the player cannot use paid random item generators, and the game must apply one of the documented treatments: a free earnable path, a pre-determined disclosed order, direct purchase of specific outcomes priced on expected value, removing or hiding the item, blocking the purchase with a message, or removing the player from that part of the game.
- `IsPaidItemTradingAllowed` decides whether a player may trade items obtained with Robux or paid currency.
- Random rewards for actions that involve no Robux or paid currency do not require odds disclosure.

The studio's agents draft compliance answers but do not decide policy questions; those go to the human through `studioctl.py escalate --kind policy` ([Monetization compliance](../09-monetization/monetization-compliance.md)).

## Summon UX

- **1× and 10× pulls**, with the 10× giving a small bonus (for example one guaranteed Epic) rather than a discount that pressures spending.
- **Skip animation** after the first few pulls; experienced players hate waiting.
- **Escalating reveal**: the reveal gets bigger as rarity rises (color, sound, camera, screen effects), so a Mythic is a clip moment ([Reveal and hatch design](../03-rarity-and-rng/reveal-and-hatch-design.md)).
- **Results summary** after a 10×: new units flagged "NEW", duplicates shown with what they converted to.
- **Odds button labelled "Details"** next to every banner, showing every unit's odds and the pity rules.
- **Pity counter visible**: "Mythic guaranteed in 34 pulls."
- **Server-wide announcements** for Secret pulls (opt-out for the player) feed social proof.

## Ethics: lines to hold

These go beyond the policy minimum, because the audience is young.

| Do | Do not |
|---|---|
| Show odds and pity clearly | Fake near-misses (showing a Mythic flash before a Rare) |
| Make premium currency earnable in play | Make essential units Robux-only |
| Carry pity across banners | Reset pity silently |
| Keep limited banners rare and announced | Run back-to-back "last chance" banners to create constant urgency |
| Offer shard shops for bad luck | Hide the effective cost of a chase unit |
| Give a free 10× at launch and in events | Use countdown timers on purchase prompts |

## For agents

- [ ] Every banner has a Details button with all outcomes and odds summing to 100%, plus pity rules.
- [ ] Rolls happen on the server from the same tables the client displays; pity is saved with the result.
- [ ] `ArePaidRandomItemsRestricted` and `IsPaidItemTradingAllowed` are checked and a documented treatment is applied.
- [ ] The economy sheet states expected pulls per top result with pity and the free player's weekly pull count.
- [ ] Power gaps between rarities are smaller than odds gaps.
- [ ] Policy questions are escalated to the human, not answered by an agent.

Sources: [Paid random items policy guidelines](https://create.roblox.com/docs/production/monetization/paid-random-items) · [PolicyService](https://create.roblox.com/docs/reference/engine/classes/PolicyService) · [Random](https://create.roblox.com/docs/reference/engine/datatypes/Random)

Related: [RNG systems and pity](../03-rarity-and-rng/rng-systems-and-pity.md) · [Rarity tiers and odds](../03-rarity-and-rng/rarity-tiers-and-odds.md) · [Anime tower defense deep dive](anime-tower-defense.md) · [Anime monetization](anime-monetization.md) · [Monetization compliance](../09-monetization/monetization-compliance.md)
