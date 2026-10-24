---
title: Shop UX and contextual offers
date: 2026-10-24
tags: [monetization, shop, ux, offers]
aliases: [Contextual purchases, Offers, Shop placement]
summary: Where and when to present purchases so they feel helpful instead of pushy: integrated shops, contextual offers, lobby offers, Roblox's Shop surfaces, and the purchase flow.
audience: [human, agent]
---

# Shop UX and contextual offers

The same product can feel like a gift or an insult depending on when it appears. A "+20 slots" offer the moment your inventory fills up feels helpful. The same offer as a popup on spawn feels like a toll booth.

## Three ways players meet products

1. **The integrated shop**: a menu the player opens on purpose. Always available, never pushy. See [Menus, shops and inventories](../05-ui-and-hud/menus-shops-inventories.md).
2. **Contextual offers**: shown at the moment a product would help or delight. The highest-converting placement, and the easiest to abuse.
3. **World and lobby presence**: products shown as physical things (a VIP door, a pass podium, an egg that costs gems), noticed while playing.

Roblox also surfaces your products itself: a personalized in-game **Shop** (with an optional global Shop button you enable in Creator Hub), and external surfaces such as the home page, search and the page after a player buys Robux, where listed passes and developer products can be bought outside your game. Players can arrive already owning something. Handle purchases in a way that never depends on your UI being open.

## Good contextual moments

| Moment | Offer | Why it works |
|---|---|---|
| Inventory or storage full | More slots | Solves a real, felt problem |
| Standing at a premium egg | Luck potion, x3 hatch | Desire is at its peak |
| Just failed at a boss or obby stage | Revive, skip stage (cheap) | The player wants to continue now |
| End of a round with a great result | Double rewards | Celebration, generous framing |
| Saw another player's rare pet or aura | The egg or roll that contains it | Social desire |
| Unlocked a new zone | Zone-themed bundle | New excitement |
| Returned after days away | Welcome-back bundle | Fresh start |
| Rebirth just completed | Rebirth boost | Momentum |

## Rules for contextual offers

- **One offer per moment**, dismissible in one tap, never blocking movement or combat.
- **Frequency caps**: the same offer at most once per session or a few times per day; back off after repeated dismissals.
- **No offers in the first minutes of a new player's first session** (except a visible shop button).
- **Honest framing**: show the real benefit and the real price; no fake timers or "only 2 left" unless true.
- **Neutral wording** for young audiences: "View offer", "See price", not "BUY NOW!!!".
- **Free alternative visible** where one exists ("Or keep playing to earn it in about 8 minutes").
- **Measure**: log impressions, clicks and purchases for each offer (a recurring funnel), and compare retention of players who saw offers against those who did not (with Experiments if possible).

## The purchase flow

1. Player taps a product.
2. Client calls `MarketplaceService:PromptProductPurchase` (developer products) or `PromptGamePassPurchase` (passes). Subscriptions and Roblox Plus have their own prompt functions.
3. Roblox shows its purchase dialog. You cannot customize it.
4. On success, Roblox calls your server's `ProcessReceipt` callback (developer products). Grant the item, save, then return `PurchaseGranted`. For passes, listen for the purchase finished event and re-check ownership on the server.
5. Client shows a celebration when the server confirms the grant.

Rules:

- **Grant only on the server**, in `ProcessReceipt` for products, idempotently (the same receipt can be delivered more than once).
- **Never grant from `PromptProductPurchaseFinished`**; that event is not proof of payment.
- **Handle offline and external purchases**: if the player bought an item outside your game or `ProcessReceipt` fires while they are loading, grant it once their data is ready (return `NotProcessedYet` until it is).
- **Show the grant**: purchases must feel instant and celebrated.
- **Product intelligence**: `RecommendTopProductsAsync` (needs at least one sale in 28 days) and `RankProductsAsync` (rate-limited, call at join) help pick which offer to show each player.

See [Data persistence](../13-building-it-right/data-persistence.md) for the receipt pattern.

## Shop layout reminders

- Separate soft-currency progression from Robux offers.
- Lead with benefits; show prices fetched at runtime.
- Keep owned items visible as "Owned".
- Offer a "+" on the premium currency counter that opens the right tab.

## For agents

- [ ] Contextual offers mapped to specific moments with frequency caps and dismissal back-off.
- [ ] No offers in a new player's first session apart from the shop button.
- [ ] Purchases granted only via server receipt handling, idempotent, saved before acknowledging.
- [ ] Purchases made outside the game or while loading are granted correctly.
- [ ] Offer funnels logged; retention impact checked.

Related: [Product catalog](product-catalog.md) · [Menus, shops and inventories](../05-ui-and-hud/menus-shops-inventories.md) · [Monetization compliance](monetization-compliance.md) · [Data persistence](../13-building-it-right/data-persistence.md)
