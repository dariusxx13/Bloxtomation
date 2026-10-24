---
title: Data persistence
date: 2026-10-24
tags: [engineering, datastores, saving, receipts, session-locking]
aliases: [DataStores, Saving data, ProcessReceipt, Session locking]
summary: How to save player data without ever losing or duplicating it: session locking, UpdateAsync, retries, autosave, shutdown handling, schema migrations, and correct purchase receipts.
audience: [human, agent]
---

# Data persistence

Lost progress is the fastest way to lose a player forever, and duplication bugs destroy economies. DataStore calls fail regularly (throttling, outages, servers shutting down mid-save), so saving must be designed as a system, not a single function call.

## Non-negotiables

1. **Every DataStore call is wrapped in `pcall`**, with retries and exponential backoff.
2. **Read-modify-write uses `UpdateAsync`**, never `GetAsync` followed by `SetAsync` (that races with other servers).
3. **Session locking**: only one server owns a player's data at a time.
4. **Save on three triggers**: periodic autosave, player leaving, and server shutdown (`game:BindToClose`).
5. **A failed load never becomes a new profile.** If loading fails, kick the player with a friendly message ("Your data couldn't load. Please rejoin.") instead of letting them play on default data that would overwrite their real save.
6. **Store plain, JSON-compatible data**: numbers, strings, booleans, arrays and string-keyed tables. Convert Vector3, CFrame, Color3 and enums at the boundary. No instances.

> [!TIP]
> Use a proven library such as **ProfileStore** (the successor to ProfileService) for production games. It implements session locking, retries and safe release. The rest of this note explains what such a library does, so you can review it or build your own when needed.

## Session locking

- On load, claim the profile inside an `UpdateAsync`: if there is no active lock (or the lock is stale, for example older than a few autosave intervals), write your server's `JobId` and a timestamp into a lock field and continue.
- If another server holds a fresh lock (the player just left another server that is still saving), wait and retry a few times; if still locked, kick with a "data is still saving, please rejoin" message. Never load anyway.
- Every autosave refreshes the lock timestamp; on leave or shutdown the final save clears the lock.
- A crashed server's lock goes stale and heals by itself.

## The profile lifecycle

```text
PlayerAdded -> claim lock + load + migrate -> in-memory profile (the only source of truth)
             gameplay reads and writes ONLY the in-memory profile
             autosave every 60-120 s, staggered per player
PlayerRemoving -> final save + release lock
BindToClose -> final save + release for every remaining player, in parallel, then wait (up to ~25 s)
```

- Gameplay code never calls DataStores directly. One data module owns persistence.
- Stagger autosaves so a full server does not save all players in the same second.
- Writes to the same key are throttled (about one write per key every few seconds); never save in a loop or on every coin.
- In Studio, keep `BindToClose` waits short so stopping a playtest is quick.

## Schema versions and migrations

- Store a `version` number in every profile from day one.
- On load, run migration steps from the stored version up to the current one (inside the load transaction).
- Never remove or rename fields without a migration; during a rolling update, old and new servers run at the same time.
- Build new profiles from a deep copy of the default template (a shared table reference corrupts data across players).

## Size and shape

- One key per player, in one DataStore for profiles.
- Each value has a size limit (around 4 MB); cap unbounded lists (logs, histories) to a fixed size.
- Arrays must not contain `nil` holes.
- Keep keys short in big tables (inventories), store ids not names, and derive stats from config.

## Purchases: ProcessReceipt done right

Developer products are only safe if `ProcessReceipt` is correct. Roblox may call it more than once for the same purchase and keeps retrying until you return `PurchaseGranted`.

```lua
-- Server sketch: idempotent receipt handling against a session-locked profile
local MarketplaceService = game:GetService("MarketplaceService")

MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet -- grant when they return
	end
	local profile = PlayerData.getLoaded(player)
	if not profile then
		return Enum.ProductPurchaseDecision.NotProcessedYet -- data not ready yet
	end
	if profile.data.receipts[receiptInfo.PurchaseId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted -- already granted
	end
	local grant = Products.handlers[receiptInfo.ProductId]
	if not grant then
		warn("Unknown product", receiptInfo.ProductId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local ok = pcall(grant, player, profile, receiptInfo)
	if not ok then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	Receipts.remember(profile, receiptInfo.PurchaseId) -- bounded history
	local saved = PlayerData.saveNow(player)             -- persist before acknowledging
	if not saved then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end
```

Rules:

- Grant only here, never from `PromptProductPurchaseFinished`.
- Record the `PurchaseId` in the profile to make granting idempotent, and keep a bounded history (most games keep the last few hundred receipts).
- Save before returning `PurchaseGranted`. If anything fails, return `NotProcessedYet`; Roblox will retry.
- Purchases can arrive from outside your game (Roblox Shop and external surfaces) or while the player's data is still loading; the pattern above handles both.
- Passes: check ownership with `MarketplaceService:UserOwnsGamePassAsync` (cache the result per session, refresh on `PromptGamePassPurchaseFinished`) and apply the benefit; passes are not delivered through `ProcessReceipt`.
- Roblox checks your receipt handling for listed developer products and removes faulty ones from external surfaces until fixed.

## Other storage

- **MemoryStoreService**: fast, temporary, cross-server data (matchmaking queues, global event state, short leaderboards). Data expires; not for permanent saves.
- **OrderedDataStore**: global leaderboards (top N by a number).
- **MessagingService**: cross-server messages (global announcements, admin events), not storage.
- **Open Cloud**: read and write DataStores from outside Roblox (support tools, backups, GDPR deletion).

## Privacy and deletion

Roblox may send right-to-erasure requests for users. Have a way to delete a user's data from your DataStores (Open Cloud scripts or webhook automation). See [Privacy and data](../17-policy-and-business/privacy-and-data.md).

## For agents

- [ ] Data module uses a proven library or implements session locking, `UpdateAsync`, retries, staggered autosave, leave and shutdown saves.
- [ ] Load failure kicks the player; never plays on default data.
- [ ] Profiles versioned with migrations; defaults deep-copied.
- [ ] `ProcessReceipt` idempotent with receipt history, saves before granting, handles missing players and unloaded data.
- [ ] Unbounded lists capped; data shape documented in shared types.
- [ ] A data deletion path exists for erasure requests.

Related: [Security and anti-exploit](security-and-anti-exploit.md) · [Trading economies](../04-progression-and-economy/trading-economies.md) · [Testing and QA](testing-and-qa.md) · [Privacy and data](../17-policy-and-business/privacy-and-data.md)
