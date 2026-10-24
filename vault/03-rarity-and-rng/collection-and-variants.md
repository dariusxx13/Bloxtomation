---
title: Collection and variants
date: 2026-10-24
tags: [rng, collection, retention, progression]
aliases: [Collection index, Mutations, Variants, Shiny]
summary: How to design collection books, variants and mutations that multiply content, give long-term goals and keep duplicates useful.
audience: [human, agent]
---

# Collection and variants

Collections turn random drops into long-term goals. A player with 41 of 50 pets in the index has a reason to come back tomorrow. Variants (golden, shiny, giant, rainbow, mutated) multiply the size of a collection without multiplying the art budget.

## The collection index

An index (pet book, fish journal, aura list, bestiary) shows every collectible in the game, including the ones the player has not found yet.

Design rules:

- **Show silhouettes of undiscovered items**, with their rarity color and where they come from ("Volcano Egg", "Night only"). Mystery drives collection; hints reduce frustration.
- **Track completion per set** (per egg, per zone, per biome) and overall. Sets of 6-15 items feel completable; a single 300-item list does not.
- **Reward set completion**: a permanent boost (luck, coin multiplier), a title, a badge, an exclusive cosmetic. Rewards for completing a set should be visible to others.
- **Count variants separately** in the index so variants become collection goals too.
- **Record "first found" dates** and how many exist server-wide or game-wide for rare items. It turns the index into a trophy cabinet.

## Variants and mutations

A variant is a modified version of an existing item. Each variant adds a new collectible for the cost of a shader, material change or effect.

| Variant | Typical chance | Typical effect | Look |
|---|---|---|---|
| Golden | 1-5% or crafted from duplicates | x2-x3 stats | Gold material or gradient |
| Shiny | 0.1-1% | Bonus stats, prestige | Sparkle particles, color shift |
| Giant or Huge | very rare | Large stat boost, size | Scaled-up model |
| Rainbow | very rare or crafted | Large boost | Animated color cycle |
| Mutations (weather, element) | event-based | Thematic bonus | Overlay effects: frozen, burning, electric |

Rules of thumb:

- **Variants stack carefully.** A "Shiny Rainbow Huge" should be possible but extremely rare. Decide whether variant chances multiply (rarest) or whether only one variant applies per item.
- **Visible at a distance.** A variant that looks the same as the normal item is worthless for show-off.
- **Crafting paths**: let players turn duplicates into variants (5 normal → 1 golden, 5 golden → 1 rainbow). This gives every duplicate a purpose and creates a smooth, deterministic progression alongside the random one.
- **Event mutations** (a "Frozen" mutation during a snow event, "Moonlit" during a full-moon hour) create urgency and give events collectible rewards without new models.

> [!IMPORTANT]
> If players can pay (directly or through Robux-bought currency) to roll or improve variants, the variant chances are paid random items and must be disclosed with numeric odds before purchase.

## Duplicates are a feature

Every collection game produces duplicates. Give them value:

1. **Merge / fuse** into higher variants (see crafting paths).
2. **Recycle** into currency or "essence" used for upgrades.
3. **Feed** to other items for XP.
4. **Trade** (if trading exists; see [Trading economies](../04-progression-and-economy/trading-economies.md)).
5. **Auto-delete filters** so players can choose to discard commons automatically.

## Inventory management

Big collections need good inventory UX. Without it, collection games drown in clutter.

- **Equip best** button (by the stat that matters most).
- **Sort and filter** by rarity, stat, variant, newest.
- **Lock** favorite items so they cannot be deleted or traded accidentally.
- **Mass delete** with confirmation, never including locked or rare items by default.
- **Capacity upgrades** as a soft-currency progression and a product. Never make the starting capacity so small that players are forced to buy.
- **Teams or loadouts** for games with several equipped items.

See [Menus, shops and inventories](../05-ui-and-hud/menus-shops-inventories.md).

## Data shape

Collections and variants are a frequent source of data bloat and corruption. Keep the saved data small and stable:

```lua
-- One entry per owned unit. Keep keys short; store ids, not names.
type OwnedPet = {
	id: string,        -- unique instance id (GUID)
	kind: string,      -- catalog id, e.g. "inferno_dragon"
	variant: string?,  -- "golden" | "rainbow" | nil
	level: number,
	locked: boolean?,
}

type CollectionData = {
	pets: { OwnedPet },
	index: { [string]: number }, -- catalog key ("inferno_dragon:golden") -> first-found unix time
}
```

- Store catalog ids, never display names or full stat blocks. Stats come from config so they can be rebalanced.
- Cap inventory size in data as well as UI.
- Keep the index as a set of discovered keys, which never shrinks even when items are deleted.

## For agents

- [ ] Index shows undiscovered silhouettes with rarity and source hints.
- [ ] Sets of 6-15 items with visible completion rewards.
- [ ] Variants have distinct visuals, documented chances and a stacking rule.
- [ ] Every duplicate has at least one use.
- [ ] Inventory has equip-best, sort, lock and safe mass delete.
- [ ] Saved data stores ids and variants only; stats come from config.

Related: [Rarity tiers and odds](rarity-tiers-and-odds.md) · [RNG systems and pity](rng-systems-and-pity.md) · [Trading economies](../04-progression-and-economy/trading-economies.md) · [Endgame and long-term goals](../10-retention-and-social/endgame-and-long-term-goals.md)
