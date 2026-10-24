---
title: Inventory and trading systems
date: 2026-10-24
tags: [engineering, inventory, trading, items, duplication, security, data]
aliases: [Inventory engineering, Trade system implementation, Item duplication prevention, Item model]
summary: How to implement inventories and trades that cannot be duplicated or scammed - item definitions versus owned instances, unique ids and stacks, the data schema, server-only operations, a trade state machine with re-validation and countdowns, atomic swaps inside one server, why cross-server trades need escrow, policy checks (paid item trading, regional price levels), logging and support tooling.
audience: [human, agent]
---

# Inventory and trading systems

Inventories hold the value players care about most. A single duplication bug can flood a trading economy and destroy it in a day. This note is the engineering side; the design side (should you have trading, values, scam prevention UX) is in [Trading economies](../04-progression-and-economy/trading-economies.md).

## The item model

Separate **what an item is** from **what a player owns**.

| Layer | Example | Lives in |
|---|---|---|
| Item definition | `{ id = "pet_ember_fox", rarity = "Legendary", stats = {...}, tradable = true }` | Shared config (read-only) |
| Owned stack | `{ def = "potion_luck", count = 12 }` | Player profile |
| Owned unique | `{ uid = "f3a9...", def = "pet_ember_fox", level = 7, traits = {"Swift"}, obtainedAt = 1729771234, source = "hatch" }` | Player profile |

- **Stackable** items (potions, materials, currency-like tokens) are counts per definition.
- **Unique** items (pets, units, weapons with rolls) each get a **uid** created on the server when granted (for example with `HttpService:GenerateGUID(false)`), never by the client.
- Definitions are versioned; removing a definition requires a migration that converts or compensates owned items ([Data persistence](data-persistence.md)).

### Schema rules

- Inventory is a field in the session-locked player profile, not a separate DataStore key per item.
- Cap inventory size (and sell or offer storage expansion); unbounded arrays grow profiles toward size limits.
- Store only plain data (strings, numbers, booleans, tables); no Instances.
- Record `source` and `obtainedAt` on uniques for support and fraud investigation.

## Server-only operations

All changes happen through a small server module with explicit operations:

```text
Inventory.grant(player, defId, countOrRolls, source)   -- adds; returns uid(s)
Inventory.remove(player, uidOrDef, count, reason)       -- removes; fails if not owned
Inventory.has(player, uidOrDef, count)                  -- ownership check
Inventory.equip(player, uid, slot)                      -- validates ownership and slot rules
```

- Clients send **requests** with uids or definition ids; the server checks ownership every time.
- Operations are **idempotent where possible** (a purchase grant keyed by the receipt's purchase id is applied once; see [Data persistence](data-persistence.md) on `ProcessReceipt`).
- Every grant and removal logs an analytics economy event with a reason ([Analytics instrumentation](analytics-instrumentation.md)).
- Rate-limit inventory remotes ([Networking and remotes](networking-and-remotes.md)).

## Trades inside one server

Both players are in the same server, so their profiles are both loaded, session-locked and in memory. That makes an **atomic swap** possible: change both in-memory profiles in one step on the server, then let normal autosave persist them.

### The trade state machine

```text
Requested -> Open -> (items added/removed: confirmations reset) -> BothReady -> Countdown (e.g. 5 s)
  -> Confirmed (re-validate everything) -> Swap (both profiles, one step) -> Completed
Any change during Countdown -> back to Open, confirmations reset
Either player leaves, disconnects or cancels -> Cancelled (nothing moves)
```

### Validation at confirm time

Right before swapping, re-check everything, because state may have changed since the items were offered:

1. Both players are still in the server and their profiles are loaded and locked.
2. Every offered uid is still owned by the offering player, is tradable, and is not equipped or locked (or unequip it as part of the swap).
3. Stack counts are still available.
4. Both inventories have space for incoming items.
5. Policy checks pass for both players (see below).
6. Neither player is in a trade cooldown or flagged account state.

Then move items in one synchronous block (no yielding between removing from A and adding to B), log the trade with both inventories' affected uids, and mark both profiles changed.

### Sketch: the swap step

```lua
--!strict
-- Swap (sketch): runs only after full re-validation, with no yields inside.
type Offer = { uids: { string }, stacks: { [string]: number } }

local function swap(invA: any, invB: any, offerA: Offer, offerB: Offer)
	-- Remove from both sides first (validation already proved ownership and counts).
	local movedA, movedB = {}, {}
	for _, uid in offerA.uids do
		movedA[uid] = invA.uniques[uid]
		invA.uniques[uid] = nil
	end
	for _, uid in offerB.uids do
		movedB[uid] = invB.uniques[uid]
		invB.uniques[uid] = nil
	end
	for def, n in offerA.stacks do
		invA.stacks[def] -= n
		invB.stacks[def] = (invB.stacks[def] or 0) + n
	end
	for def, n in offerB.stacks do
		invB.stacks[def] -= n
		invA.stacks[def] = (invA.stacks[def] or 0) + n
	end
	-- Add moved uniques to the other side.
	for uid, item in movedA do
		invB.uniques[uid] = item
	end
	for uid, item in movedB do
		invA.uniques[uid] = item
	end
end
```

Because both profiles are session-locked by this server, no other server can write them during the swap, which is what prevents the classic "rejoin during save" duplication ([Data persistence](data-persistence.md)).

## Cross-server trades and marketplaces

Trading between players in different servers (auction houses, global markets, gifting to offline players) cannot use an in-memory swap. Options:

- **Avoid it** unless the design truly needs it.
- **Escrow:** the seller's server removes the item into an escrow record (a DataStore key) with `UpdateAsync`; the buyer's server pays and claims it with `UpdateAsync` on the same key; each step is idempotent and logged; expired listings return items to the seller on their next join.
- Use MemoryStore sorted maps only as the **listing view**, never as the owner of items ([MemoryStore and cross-server systems](memorystore-and-cross-server.md)).

Cross-server trading is a high-risk feature: require a design review and a security review before building it.

## Policy checks (Fact, creator docs, accessed 2026-10-24)

- **Paid item trading:** `PolicyService:GetPolicyInfoForPlayerAsync()` returns `IsPaidItemTradingAllowed`. When it is false, the player must not trade items obtained with Robux or with paid in-game currency, including outcomes of paid random items ([Monetization compliance](../09-monetization/monetization-compliance.md)).
- **Regional price levels:** with managed pricing, the same item can cost different amounts in different regions. `MarketplaceService:GetUsersPriceLevelsAsync` returns a price level from 1 to 1000 (1000 is the full global price) for each user, so the game can block or limit trades and gifts between players with large price-level differences to prevent arbitrage ([Anime monetization](../20-anime-games/anime-monetization.md)).
- Track whether each item was obtained through paid means (a `paid = true` flag on uniques or a separate paid-stack count) so these checks are possible.

## Anti-fraud and support

| Measure | Purpose |
|---|---|
| Trade log (both players, items, time, server) | Investigate scams and dupes |
| Trade cooldowns and new-account limits | Slow down alt-account farming |
| Value warnings (big imbalance) | Reduce scams of young players ([Trading economies](../04-progression-and-economy/trading-economies.md)) |
| Item uid uniqueness check on load | Detect duplicates (two profiles holding the same uid) |
| Support tool (staff-only, server-validated) | Restore items after verified incidents |
| Kill switch for trading (live config flag) | Stop trading instantly if a dupe is suspected ([Experiments and configs](../12-live-ops-and-launch/experiments-and-configs.md)) |

## Testing

- Unit tests for the swap function and validation rules (pure functions where possible).
- Multi-client tests: trade, then leave instantly; trade during autosave; trade while one player is teleporting.
- Exploit tests: offer items you do not own, change the offer during the countdown, fire confirm twice, fire the remote at high rates.
- Recovery test: kill the server mid-trade (in a test place) and confirm nothing duplicated or vanished.

## For agents

- [ ] Item definitions are separate from owned items; uniques have server-generated uids with source and time.
- [ ] Trades run as a server state machine with confirmation resets, a countdown and full re-validation at confirm.
- [ ] Swaps happen in one non-yielding block on session-locked profiles; every trade is logged.
- [ ] `IsPaidItemTradingAllowed` and price-level checks are enforced; paid provenance is tracked per item.
- [ ] A trading kill switch exists; cross-server trading has passed security review before building.

Sources: [PolicyService](https://create.roblox.com/docs/reference/engine/classes/PolicyService) · [Paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items) · [Regional pricing](https://create.roblox.com/docs/production/monetization/regional-pricing) · [Data stores](https://create.roblox.com/docs/cloud-services/data-stores)

Related: [Trading economies](../04-progression-and-economy/trading-economies.md) · [Data persistence](data-persistence.md) · [Security and anti-exploit](security-and-anti-exploit.md) · [MemoryStore and cross-server systems](memorystore-and-cross-server.md) · [Monetization compliance](../09-monetization/monetization-compliance.md)
