---
title: Monetization compliance
date: 2026-10-24
tags: [monetization, policy, compliance, paid-random-items, policyservice]
aliases: [Paid random items policy, PolicyService, Fair monetization rules]
summary: The Roblox rules that apply to selling things in games (paid random items, odds disclosure, PolicyService, honest discounts, minors, subscriptions), written as a checklist you can enforce.
audience: [human, agent]
---

# Monetization compliance

Breaking monetization rules can get products removed, games moderated or accounts penalized, and it erodes the player trust that drives your like ratio. This page collects the rules in one place. They are platform facts as of 2026-10-24; check the linked sources before relying on details.

## 1. Paid random items

**What counts.** Any random outcome obtained with Robux, directly or indirectly. Examples:

- Paying Robux to spin a wheel, open a chest or hatch an egg.
- Paying Robux for gems, keys or tickets, then spending them on a random outcome.
- Enhancement items with random results (a potion with a random duration, an upgrade that may fail).
- Combination items (fusing items for a chance at a better result).
- Probability modifiers: luck boosts, pity systems, rate-up items, enhanced drop items.

**What you must do.**

- Show **all possible outcomes** and their **numeric probabilities** (percentages) **before** the purchase or before spending the Robux-bought currency.
- Percentages must sum to **exactly 100%**. Very small probabilities may be rounded (to several decimals past the first non-zero digit) with a note that displayed values may not sum to exactly 100% due to rounding.
- If there are too many outcomes to show in the world, use a clickable list behind a **descriptive label** such as "Odds" or "Details". A standalone (i) icon is not enough.
- If many items share the same odds, you may state "Odds for each item below: X%".
- If unique outcomes can only be obtained once, update the remaining odds for that player.
- **Probability modifiers** (luck potions, lucky rods) must explain numerically how they change odds before purchase, and the displayed odds must update to the player's true odds while the modifier is active.

**Free randomness** (no Robux involved at any point, for example a chest found in the world) does not require disclosure. Disclosing anyway is good practice.

## 2. PolicyService gates

Use `PolicyService:GetPolicyInfoForPlayerAsync(player)` (on the server, cache per session) and respect:

| Field | If restricted | What to do |
|---|---|---|
| `ArePaidRandomItemsRestricted` = true | The player cannot buy random outcomes with Robux or Robux-bought currency | Offer one of: a free earnable path, a fixed disclosed sequence of outcomes, direct purchase of the specific item priced from its expected value, hiding the paid option, a clear "not available in your region" message, or keeping the player out of that area |
| `IsPaidItemTradingAllowed` = false | The player cannot trade items obtained with Robux | Block trading of those items (including paid random outcomes) |
| Other policy fields (ads, subscriptions, commerce, external links, social features) | Feature not allowed for this player | Hide or disable the feature for them |

The Maturity & Compliance Questionnaire asks whether your game respects the paid random items policy and whether it allows paid item trading. Answer accurately.

## 3. Honest presentation

Roblox requires monetization to be transparent, honest and not pressuring:

- **Discounts must be genuine and fair.** An item permanently "on sale" is not a discount. A discount shown only for a very short time to pressure purchases is not fair.
- **No false scarcity.** Do not claim an item is almost gone or only briefly available when it is not.
- **No fake timers.** No countdown that restarts for the same offer, or that is inaccurate.
- **No pressure language toward young players.** Prefer "View item", "See price", "Open shop" over "GET IT NOW", "LAST CHANCE", "BUY BEFORE IT'S GONE".
- **No tricks.** No moving buttons that cause accidental purchases, no purchase prompts disguised as other actions.
- **Describe benefits accurately**, including Premium or Plus benefits.

## 4. Subscriptions

- Clear, distinct names, price and duration shown when merchandising.
- Same benefits on every platform and device.
- No mutually exclusive tiers of the same benefits (Bronze/Silver/Gold that only one can hold is not supported).
- Honor the benefits for the full term; do not revoke them quietly.
- Do not require extra tasks (like social media posts) to receive paid benefits. Battle passes may be marketed and sold as subscriptions.

## 5. Premium and Plus prompts

- Premium or Plus must never be a requirement to enjoy the game; no paywall prompts on entry.
- Do not promise Robux or rewards you do not control.
- Benefits for subscribers should be cosmetic or comfort perks, not overwhelming power over non-subscribers.

## 6. Rewards for ads and engagement

- Rewarded video rewards must be developer products, not Robux, not random.
- Creator Rewards forbids artificial or automated activity, encouraging alt accounts, impersonation and fraud.
- Do not reward players for actions outside Roblox that you cannot verify or that violate other platforms' rules.

## 7. Purchases and data

- Grant developer products only in `ProcessReceipt`, idempotently, after saving.
- Keep a purchase history (receipt ids) in player data to prevent double grants.
- Roblox does not store your game's inventory for you: losing purchased items through data bugs is your responsibility.

## 8. Age and audience

- Your content maturity label affects which age tiers can play. Monetization designed for younger players carries extra care: neutral language, no pressure, honest value.
- Commerce products (real-world goods) have their own eligibility (creators 18+, US buyers only with age limits) and must be gated with `PolicyService`.

## Compliance review checklist

- [ ] Every paid random path: all outcomes listed with percentages summing to 100% before purchase; descriptive "Odds" button.
- [ ] Luck boosts and pity explained numerically before purchase; displayed odds update while active.
- [ ] `ArePaidRandomItemsRestricted` handled with an allowed alternative; `IsPaidItemTradingAllowed` enforced in trading.
- [ ] No permanent sales, fake scarcity, restarting timers or pressure language.
- [ ] Subscriptions distinct, honored, same everywhere.
- [ ] Premium/Plus never required; subscriber perks are fair.
- [ ] Rewarded video rewards are non-random developer products.
- [ ] Receipts processed idempotently with saved history.
- [ ] Questionnaire answers match the game.

Related: [Rarity tiers and odds](../03-rarity-and-rng/rarity-tiers-and-odds.md) · [RNG systems and pity](../03-rarity-and-rng/rng-systems-and-pity.md) · [Trading economies](../04-progression-and-economy/trading-economies.md) · [Age ratings and audience](../17-policy-and-business/age-ratings-and-audience.md) · [Community standards for developers](../17-policy-and-business/community-standards-for-devs.md)

Sources: [Paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items), [Monetization overview and guidelines](https://create.roblox.com/docs/production/monetization), [Subscriptions](https://create.roblox.com/docs/production/monetization/subscriptions), [Content maturity](https://create.roblox.com/docs/production/promotion/content-maturity)
