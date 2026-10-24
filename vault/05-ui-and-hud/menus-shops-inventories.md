---
title: Menus, shops and inventories
date: 2026-10-24
tags: [ui, shop, inventory, menus, monetization]
aliases: [Shop UI, Inventory UI, Menus]
summary: How to lay out the screens players open most (shop, inventory, upgrades, daily rewards, settings) so they are fast, clear and honest.
audience: [human, agent]
---

# Menus, shops and inventories

Players open the same few menus hundreds of times. Every extra tap, every unclear icon and every slow transition is multiplied by that count.

## General menu rules

- **One tap to open, one tap to close.** Close with an X in a consistent corner (top right is the most common on Roblox), by tapping outside, and with the same button that opened it. On gamepad, B closes.
- **One menu at a time.** Opening a new menu closes the old one, except for confirmation dialogs.
- **Remember the last tab** within a session.
- **Tabs with icons** across the top or down the left side. Five tabs maximum before you need sub-navigation.
- **Responsive grids**: `UIGridLayout` (or flex layouts) inside a `ScrollingFrame` with automatic canvas size, so adding items never breaks the layout.
- **Fast**: the menu opens in about 0.2-0.3 seconds. Do not load data on open; keep the client's copy of the player's state up to date and render from it.

## The shop

The shop has two jobs: let players spend soft currency on progression, and present Robux offers honestly. Keep them clearly separated.

### Layout

| Area | Content |
|---|---|
| Tabs | Upgrades (soft currency), Items or Eggs, Passes (Robux), Currency packs (Robux), Limited / Event |
| Item card | Icon or 3D preview, name, short benefit ("x2 Coins forever"), price with currency icon, state (Buy / Owned / Equipped / Locked) |
| Highlight slot | One featured offer per tab: best value, event item or personalized pick |

### Card design

- Lead with the **benefit**, not the name. "Auto-collect coins" beats "Magnet Pass".
- Show the price with the right icon. For Robux items, read the price from `MarketplaceService` (never hard-code) so regional pricing, price tests and Roblox Plus discounts display correctly. See [Pricing and price ladders](../09-monetization/pricing-and-price-ladders.md).
- Owned passes show "Owned" and stay visible (they advertise the value to others and confirm the purchase).
- Show value comparisons honestly ("Best value: +40% gems"), computed from real amounts.

### Personalized picks

Roblox offers product intelligence APIs on `MarketplaceService`: `RecommendTopProductsAsync` returns up to 50 items a player is most likely to buy (it needs at least one sale in the last 28 days), and `RankProductsAsync` orders a list you provide. Call them once when the player joins (they are rate-limited) and use them for a "Top picks" row.

### Roblox's own Shop

Roblox also provides a personalized in-game Shop surface that lists your passes and listed developer products, with a global Shop button you can enable in Creator Hub. Items listed there can also appear outside your game (home page, search, after a Robux purchase). This means purchases can arrive while the player is not in your UI, or before they join. Your purchase handling must not depend on your own shop being open. See [Shop UX and contextual offers](../09-monetization/shop-ux-and-contextual-offers.md).

## Upgrade menus

- Show the current level, the next level's effect and the cost on one line: "Speed Lv 7 → 8: 24 → 26 studs/s, 1.2K coins".
- A "Max" or "Buy x10" button for long upgrade lines.
- Grey out unaffordable upgrades but keep them visible with progress toward the price.

## The inventory

See also [Collection and variants](../03-rarity-and-rng/collection-and-variants.md).

- Default sort: equipped first, then by the stat that matters most, then rarity.
- **Equip best** as a prominent button.
- Filters by rarity, type and variant; search for big collections.
- **Lock** toggle on each item; locked items cannot be deleted, sold or traded.
- Mass delete with a confirmation that lists the rarities affected; never include locked items or high rarities by default.
- Capacity shown ("124 / 150") with a clear path to more (progression or a product).
- A 3D preview of the selected item in a `ViewportFrame` (one shared preview viewport, not one per grid cell).

## Daily rewards and calendars

- A strip or grid of days with today's reward highlighted and a big "Claim" button.
- Future rewards visible (the best one at day 7 or a monthly milestone) to pull players back.
- Show the streak and what happens if it breaks. See [Retention systems](../10-retention-and-social/retention-systems.md).

## Settings

At minimum: music volume, sound effects volume, reduce motion / camera shake toggle, hide other players' pets or effects (performance), and a low-graphics option for heavy games. Save settings in player data.

## Confirmation dialogs

Use confirmations for anything destructive or expensive:

- Show exactly what happens ("Delete 12 pets: 10 Common, 2 Rare").
- Make the safe choice the default and visually distinct.
- Never place a confirm button where the previous screen's close button was (accidental taps).

## Codes menu

A Roblox tradition. A text box and a "Redeem" button, with clear success and error messages ("Code expired", "Already redeemed"). Validate on the server, one redemption per player, with expiry dates in config.

## For agents

- [ ] Every menu opens and closes in one tap with a consistent close position; one menu at a time.
- [ ] Shop separates soft-currency progression from Robux offers.
- [ ] All Robux prices come from `MarketplaceService` at runtime.
- [ ] Purchases granted by the server receipt flow regardless of which UI (or no UI) started them.
- [ ] Inventory has equip best, sort, filter, lock, safe mass delete and capacity display.
- [ ] Settings include audio, motion and performance options and are saved.

Related: [UI principles for Roblox](ui-principles.md) · [Shop UX and contextual offers](../09-monetization/shop-ux-and-contextual-offers.md) · [Collection and variants](../03-rarity-and-rng/collection-and-variants.md) · [UI implementation](ui-implementation.md)
