---
title: RNG systems and pity
date: 2026-10-24
tags: [rng, pity, luck, design, math]
aliases: [Pity systems, Bad luck protection, Luck]
summary: The random-reward mechanics used on Roblox (eggs, rolls, crates, drops, mutations), how to protect players from bad streaks, and how luck systems should stack.
audience: [human, agent]
---

# RNG systems and pity

Randomness keeps a loop exciting, but pure randomness is cruel: some players will go hundreds of rolls without anything good. This note covers the main random mechanics on Roblox and the tools that keep them fair and fun.

## The main random mechanics

| Mechanic | How it works | Typical cost | Notes |
|---|---|---|---|
| Egg or capsule | Pay soft currency per hatch, get a pet or unit | Soft currency; premium eggs with gems | Hatch multiple at once (x3, x8) as an upgrade or pass |
| Roll or spin (RNG games) | Press a button, roll an aura or title; cooldown between rolls | Time | Auto-roll and quick-roll as upgrades or passes |
| Crate, chest or case | Open for a random item | Keys or currency | Common in shooters and fighting games |
| Enemy drops | Defeating enemies has a chance to drop loot | Time and skill | Boss drops are the big moments |
| Gathering drops | Mining, fishing or chopping has a chance of rare results | Time | Fishing games depend on this |
| Mutations or variants | An item rolls a modifier (golden, shiny, giant, rainbow) | Free on any drop | Multiplies collection depth |
| Enchants or rerolls | Pay to reroll a modifier on an owned item | Currency or tokens | Paid rerolls are paid randomness: disclose odds |
| Gacha banners | Limited-time pool with featured items | Premium currency | Highest compliance and trust risk |

## Pity and bad-luck protection

Pity guarantees that a player who has been unlucky for long enough gets something good. Players love it and it makes paid randomness far fairer. Roblox counts pity systems as "probability modifiers", so if pity applies to a paid path, explain it before purchase.

### Hard pity

After N rolls without a tier, the next roll is guaranteed to be that tier or better. Then the counter resets.

- **Choose N** at about 2-3 times the expected number of rolls (1/p). For a 1% Legendary (100 expected rolls), hard pity at 200-300 rolls catches the unlucky tail without changing the average much.
- **Show the counter.** "Legendary guaranteed in 47 rolls" is a strong retention hook and is honest.

### Soft pity

After a threshold, the chance increases each roll until it hits. For example, from roll 150 onward, Legendary chance rises by 1 percentage point per roll.

- Smoother than hard pity and feels more natural.
- More complex to display: show the current chance in the odds panel.

### Streak breakers

Simpler rules for common annoyances:

- "You cannot get three commons in a row" from a premium egg.
- The first premium roll of the day has doubled rare odds.
- A guaranteed Epic in every 10-roll batch.

### Duplicate protection

When a player has already collected an item, reduce its weight for that player or convert duplicates into progress (shards). If the change applies to paid rolls, the displayed odds must show it.

## Luck systems

Luck is a multiplier on the chance of rare outcomes. It is one of the most powerful progression and monetization levers in collection games because players can feel it.

### Where luck comes from

- Permanent upgrades (luck level 1-50)
- Rebirth or prestige bonuses
- Potions (temporary, stackable)
- Passes ("2x Luck")
- Friends in the server ("+10% luck per friend", a great co-play lever)
- Server events ("2x luck for 10 minutes")
- Time of day or weather in the world
- Streaks and daily login bonuses

### How luck should stack

Pick one stacking rule and display it:

- **Additive**: 1 + 0.5 (upgrade) + 1 (pass) + 0.2 (friends) = 2.7x. Easy to understand and to balance. Recommended default.
- **Multiplicative**: 1.5 x 2 x 1.2 = 3.6x. Grows fast and can break the top tiers.
- **Mixed**: additive within a category, multiplicative across categories. Powerful but harder to explain.

Always show the total luck on screen and in the odds panel, and cap it. Uncapped luck is the most common way RNG games break their own economy after a few updates.

### How luck applies to odds

Common, correct approaches:

1. **Weight multiplication.** Multiply the weights of tiers at or above a threshold (for example Rare and up) by the luck value, then renormalize so everything sums to 100%.
2. **Roll threshold ("1 in X" games).** Each item has "1 in X" rarity; luck divides X. An item at 1 in 1,000,000 with 10x luck becomes 1 in 100,000. Pick the rarest item whose threshold the roll passes. Simple and popular in aura games.
3. **Bonus rerolls.** Luck gives extra rolls and keeps the best. Intuitive, but harder to express as a percentage (you must compute and display the resulting odds if paid).

Whatever method you use, compute the real resulting odds for display. Never display "base odds" while the player has a paid boost active.

## Fairness and trust

- **Server-side only.** The client never rolls. The client asks; the server rolls, saves the result and tells the client what to animate.
- **Save before reveal.** Save the outcome to the player's data before (or at the same time as) starting the reveal animation, so leaving mid-animation cannot lose or duplicate an item.
- **No hidden manipulation.** Never lower odds for paying players or raise them secretly for new players on paid paths. Generous *free* early rolls for new players are fine and common ("first egg always gives a Rare or better"), but tell players if it applies to anything paid.
- **Audit logs.** Keep a capped per-player history of recent rolls. It helps support, detects exploits and answers "I was robbed" complaints.

## Policy gates

Platform facts (2026):

- Use `PolicyService:GetPolicyInfoForPlayerAsync(player)` and check `ArePaidRandomItemsRestricted`. If it is true, that player must not be able to buy random outcomes with Robux or Robux-bought currency. Allowed alternatives include: a free, earnable path to the same item; a fixed, disclosed sequence of outcomes; direct purchase of the specific item at a price based on its expected value; hiding the paid random option; a clear "not available in your region" message; or keeping the player out of the area.
- Check `IsPaidItemTradingAllowed` before letting a player trade items obtained with Robux.

See [Monetization compliance](../09-monetization/monetization-compliance.md) for the full requirements.

## For agents

- [ ] Every paid random path has: full odds display, pity rules explained, boosts reflected in displayed odds, and a `PolicyService` gate.
- [ ] Hard pity set to about 2-3 times expected rolls for top tiers players are expected to chase; counter shown.
- [ ] Luck stacking rule documented, displayed and capped.
- [ ] All rolls happen on the server and are saved before the reveal.
- [ ] A rolling simulation (base odds, max luck, pity) is included in the PR or report.

Related: [Rarity tiers and odds](rarity-tiers-and-odds.md) · [Reveal and hatch design](reveal-and-hatch-design.md) · [Monetization compliance](../09-monetization/monetization-compliance.md) · [RNG and aura](../14-genre-playbooks/rng-and-aura.md)
