---
title: Product catalog
date: 2026-10-24
tags: [monetization, passes, developer-products, subscriptions, catalog]
aliases: [What to sell, Passes and products, Starter packs]
summary: The Roblox product types, what sells in each genre, how to design passes, products, bundles, season passes and subscriptions, and a starter catalog to copy.
audience: [human, agent]
---

# Product catalog

This note covers what to sell. For prices see [Pricing and price ladders](pricing-and-price-ladders.md); for where and when to offer it see [Shop UX and contextual offers](shop-ux-and-contextual-offers.md).

## Product types (platform facts, 2026)

| Type | Bought | Typical uses | Key facts |
|---|---|---|---|
| **Pass** | Once, owned forever | x2 Coins, VIP, auto-collect, extra slots, permanent abilities | Check ownership with `UserOwnsGamePassAsync`; listed passes can be sold outside your game |
| **Developer product** | Repeatedly | Currency packs, potions, revives, luck boosts, starter packs | Must be granted through `ProcessReceipt`; price 1 to 1 billion Robux |
| **Subscription** | Monthly, auto-renewing | VIP monthly, daily currency, season access | Robux price ≥ 49 (70% payout) or local currency $2.99/$4.99/$7.99/$9.99/$14.99 (70% first month, 100% after, needs verified account); benefits must be the same on every platform |
| **Private server** | Monthly | Play with friends only | Changing the price cancels all existing private server subscriptions |
| **Paid access** | Once, to enter the game | Closed betas, premium games | 25-1,000 Robux; cannot combine with private servers |
| **Avatar items** | Once | In-game catalog of UGC items | You earn a commission as the game owner when sold in your game |

Cross-game pass and developer product sales were disabled in May 2026; use Robux transfers for any cross-game mechanics.

## Passes that sell (by genre)

| Genre | Classic passes |
|---|---|
| Simulator / incremental | x2 Coins, x2 Gems, Auto-collect / Auto-click, +Pet equip slots, +Storage, Faster hatch, x3 / x8 hatch, Lucky (luck boost), VIP |
| Tycoon | x2 Cash, Auto-collect, Faster droppers, VIP area, Extra floor |
| RNG / aura | Quick roll, Auto roll, x2 Luck, Extra inventory, Skip cutscene |
| Obby | Skip stage (product), Gravity coil / speed coil, Rainbow trail, VIP |
| Tower defense | Extra unit slot, x2 Speed, Auto-skip waves, Exclusive unit |
| Fighting / battlegrounds | Exclusive moveset skin, Emotes, Private server, VIP |
| Steal and defend | Extra base floor or slot, Better lock time, x2 Money, VIP |
| Roleplay | Premium house, Vehicles, Pets, Job perks, Name colors |
| Horror co-op | Revives (product), Cosmetic skins, Extra lives in lobby, Private server |
| Fishing / collection | Better rod tiers (often soft-currency gated), Luck, Extra bait, Auto-fish |

Rules:

- **The x2 currency pass** is the most universal Roblox pass. Make it obvious and fair (it doubles base income, not every multiplier in the game unless balanced for it).
- **Passes must make the game more fun, not just faster.** Auto-collect after the player has done the action many times is fun; a pass that unlocks the second zone instantly destroys the progression the free players feel.
- **Visible passes** (a VIP tag, a trail, a pet slot others can see) also advertise themselves.

## Developer products that sell

- **Currency packs** at several sizes with increasing bonus percentages ("+20%", "+50%").
- **Starter pack**: a one-time-per-player product (enforce on the server) with a pet, a boost and some currency, priced cheap and obviously great value. Offer it after the player has had fun (end of first session or start of second), not on spawn.
- **Consumable boosts**: 15-minute x2 luck or x2 coins potions; stackable duration.
- **Revives / continues** at moments of loss (horror, obby, roguelike), priced low and limited per round so they never become pay-to-win.
- **Skips** in obbies (skip stage): accepted by players when cheap.
- **Event products**: event currency packs and event eggs during events.
- **Server-wide boosts** ("Buy x2 luck for the whole server for 10 minutes"): social, generous, and players love the buyer for it. Show who bought it.
- **Gifting**: buy an item for another player (watch regional pricing levels for gifts; see [Pricing and price ladders](pricing-and-price-ladders.md)).

## Bundles and value framing

- Bundle a pass with a consumable and some currency at a discount compared with buying separately. State the comparison truthfully.
- Limited-time bundles tied to events, ending when the event ends (and genuinely not returning, if you say so).
- Never show a fake "original price".

## Season (battle) pass

A season pass is a track of rewards earned by playing (XP from missions and play), with a free track and a premium track.

- **Season length**: commonly 4-8 weeks, aligned with your update cadence.
- **Tiers**: 30-100, each reachable in a reasonable amount of play (design so a regular player completes the free track and a premium buyer completes the premium track without excessive grinding).
- **Missions**: daily and weekly missions that steer players toward varied content and social play.
- **Rewards**: the premium track gives cosmetics, boosts, currency and an exclusive top reward; the free track must feel worth playing.
- **Sell it as a product or a subscription.** Roblox's subscription rules allow battle passes to be marketed as subscriptions.
- Show the next reward and progress on the HUD.

## Subscriptions (game subscriptions)

- Best for recurring value: daily currency or gems, VIP perks, a monthly exclusive item, season pass access.
- Roblox rules: subscriptions in one game cannot be mutually exclusive tiers (no Bronze/Silver/Gold where only one can be held); honor the benefits for the full term; do not require extra tasks to receive paid benefits; same benefits on every platform.
- Show subscription status and next billing benefits in-game; deliver daily perks automatically on join.

## A starter catalog (copy and adapt)

For a new simulator-like game at launch:

| Item | Type | Purpose |
|---|---|---|
| x2 Coins | Pass | Universal speed |
| Auto-collect | Pass | Convenience after mastery |
| +3 Pet slots | Pass | Collection depth |
| VIP | Pass | Status, chat tag, small bonus, VIP lounge |
| Lucky | Pass | Luck boost (disclosed odds) |
| Starter pack | Product (once) | Cheap first purchase |
| Small, medium, large gem packs | Products | Repeatable spend |
| x2 Luck potion (15 min) | Product | Repeatable, contextual near eggs |
| Server luck boost | Product | Social, generous |

Launch with fewer, better products. Add more with updates.

## For agents

- [ ] Each product has: type, motivation, price tier, where it is offered, and why it is fair.
- [ ] Starter pack enforced once per player on the server.
- [ ] Every developer product granted through `ProcessReceipt`; passes checked with ownership APIs and cached.
- [ ] Subscriptions follow Roblox's rules (distinct, honored, same everywhere).
- [ ] Season pass math (XP per day vs tiers) computed for free and premium players.

Related: [Monetization strategy](monetization-strategy.md) · [Pricing and price ladders](pricing-and-price-ladders.md) · [Shop UX and contextual offers](shop-ux-and-contextual-offers.md) · [Events and seasons](../12-live-ops-and-launch/events-and-seasons.md) · [Monetization compliance](monetization-compliance.md)
