---
title: Pricing and price ladders
date: 2026-10-24
tags: [monetization, pricing, regional-pricing, price-optimization]
aliases: [Pricing, Price points, Managed pricing]
summary: How to set Robux prices, build a price ladder from cheap entry to high value, display prices correctly, and use Roblox managed pricing and price tests.
audience: [human, agent]
---

# Pricing and price ladders

Pricing on Roblox has two parts: choosing good default prices, and letting Roblox's managed pricing localize and test them. Both only work if your game reads prices at runtime instead of hard-coding them.

## What a Robux is worth to a player

Players buy Robux in packages; very roughly, a player pays about one US cent per Robux (packages, platforms and promotions vary). So a 400 Robux pass feels like a few dollars to a US player, which is a lot of pocket money for a child. Keep that in mind: cheap items convert many more players than expensive ones.

You keep about 70% of the Robux price on passes, developer products and Robux subscriptions, and convert at the DevEx rate (see [Platform payouts](platform-payouts.md)).

## The price ladder

A healthy catalog spans price tiers so every player has a sensible next purchase. Common Roblox price points (Robux): 25, 49, 75, 99, 149, 199, 249, 299, 399, 499, 699, 799, 999, 1,499, 1,999, 2,499 and up.

| Tier | Price range (Robux) | Role | Examples |
|---|---|---|---|
| Impulse | 15-99 | First purchase, small boosts | Skip stage, 15-minute potion, small gem pack, revive |
| Core | 100-499 | Main passes and starter packs | x2 Coins, Auto-collect, VIP, starter pack, medium pack |
| Premium | 500-1,499 | Big permanent value | Large packs, top passes, bundles |
| High-end | 1,500+ | Collectors and big spenders | Huge packs, exclusive cosmetics, mega bundles |

Rules of thumb:

- **The first purchase is cheap.** Most first-time buyers start in the impulse or low core tier. A starter pack around 49-199 Robux is common.
- **Value increases with size.** Bigger currency packs give a higher bonus percentage; show it truthfully.
- **Anchor with a premium item.** A visible high-end option makes core items look reasonable, but it must still be real value.
- **Price by value to the player, not by your effort.** A pass that doubles income for the whole game life is worth more than a cosmetic you spent a week on.
- **Avoid too many similar prices.** Clear steps between tiers.

## Display prices at runtime (non-negotiable)

Platform facts (2026):

- Managed pricing can change the price a player sees through regional pricing (30% to 100% of your default price, based on their economic location) and price optimization tests (different groups see different prices).
- Roblox Plus subscribers get a 10% discount (20% from their third month) on eligible purchases, paid for by Roblox; the discounted price is what they are charged.
- Therefore, read prices with `MarketplaceService:GetProductInfoAsync(id, Enum.InfoType.Product or Enum.InfoType.GamePass)` (or `GetDeveloperProductsAsync` for lists) **on the client**, so each player sees their own price. `PriceInRobux` is what the player pays; discount details are available in the returned info.
- Never hard-code a price in UI text. Managed pricing flags hard-coded prices and asks you to fix them, and Plus subscribers would otherwise see the wrong price.
- The receipt (`receiptInfo` in `ProcessReceipt`) contains the exact Robux paid, which is useful for analytics during tests.

## Managed pricing

Managed pricing combines regional pricing and price optimization under one opt-in in Creator Hub (Monetization > Managed Pricing):

- New games and new items are enrolled by default; you can opt items in or out.
- Subscriptions, private servers and developer servers are regionalized automatically (subscriptions are not included in price tests).
- **Price optimization tests** split players into groups seeing different prices, measure conversion and revenue, and apply new prices only if they increase total revenue. A test needs substantial volume (Roblox suggests about 60,000 transactions over the previous 30 days), runs about three weeks, and repeats at least every 90 days.
- A **dynamic price check** tool shows which of your items still have hard-coded prices (it changes prices for test accounts so you can see which UI updates).
- You cannot change a product's price while it is in a test.

Small games without enough transactions should still enable regional pricing (it is about accessibility and fairness for global players) and set sensible defaults by hand.

## Protecting trades and gifts

When players in different regions pay different prices, gifting and trading of priced items can be abused (buy cheap in one region, gift to another). Use `MarketplaceService:GetUsersPriceLevelsAsync` to compare players' price levels and restrict gifts or trades of Robux-priced items accordingly.

## Changing prices

- Lowering prices is easy; raising them causes complaints, especially for items players were saving for. Announce increases in advance.
- Subscriptions priced in Robux can only change price once every 60 days, and increases require at least 30 days' notice to subscribers (Roblox handles the notice). Local-currency subscriptions cannot change price (you recreate them).
- Changing a private server price cancels all existing private server subscriptions. Treat it as a last resort.

## For agents

- [ ] Catalog spans impulse, core, premium and high-end tiers, with a cheap first purchase.
- [ ] Every Robux price displayed in UI is fetched at runtime on the client.
- [ ] Managed pricing enabled; dynamic price check shows no hard-coded prices.
- [ ] Gifts and trades of priced items check price levels.
- [ ] Price changes to subscriptions and private servers reviewed for their side effects before applying.

Related: [Product catalog](product-catalog.md) · [Monetization strategy](monetization-strategy.md) · [Platform payouts](platform-payouts.md) · [Localization and global players](../08-mobile-and-cross-platform/localization-and-global-players.md) · [Experiments and configs](../12-live-ops-and-launch/experiments-and-configs.md)
