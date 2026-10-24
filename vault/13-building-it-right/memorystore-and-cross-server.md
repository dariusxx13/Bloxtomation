---
title: MemoryStore and cross-server systems
date: 2026-10-24
tags: [engineering, memorystore, messaging, leaderboards, cross-server, queues, scaling]
aliases: [MemoryStoreService, Cross-server systems, Global leaderboards, Shared state between servers]
summary: How to build systems that span servers - choosing between DataStores, MemoryStores and MessagingService; sorted maps, queues and hash maps; quotas, partitions, expiration and sharding with the documented numbers; patterns for global leaderboards, matchmaking queues, cross-server events, global announcements and caches; and failure handling.
audience: [human, agent]
---

# MemoryStore and cross-server systems

Many features need more than one server: global leaderboards, matchmaking queues, server-wide events, cross-server trading, "a player just found a Secret pet" announcements. Roblox offers three services for this, each with different guarantees. Choosing the wrong one causes lost data or throttling. Persistent player data is in [Data persistence](data-persistence.md); live events in [Live events and admin events](../21-hits-and-trends/live-events-and-admin-events.md).

## Which service (Rule of thumb, from the docs' guidance)

| Need | Use | Why |
|---|---|---|
| Player progress, purchases, anything that must survive | **DataStoreService** | Durable; session-locked profiles ([Data persistence](data-persistence.md)) |
| Fast shared state that changes often and may expire | **MemoryStoreService** | In-memory, low latency, shared across all servers of the game |
| A message to all servers right now, where a loss is acceptable | **MessagingService** | Real-time topics, typically 1-2 seconds, best effort |
| Ordered all-time leaderboards that must persist | **OrderedDataStore** (persistent) with a MemoryStore cache for the hot top list | Durable ranking plus fast reads |

Never use MemoryStore for data that must not be lost; items expire and can be evicted.

## MemoryStore data structures (Fact, creator docs, accessed 2026-10-24)

| Structure | Behaviour | Typical uses |
|---|---|---|
| **Sorted map** | Key-value items kept in order by key and an optional sort key; range reads | Leaderboards, auctions sorted by price, short-lived rankings |
| **Queue** | Items added and read in order, with invisibility timeouts while processing | Matchmaking queues, job queues between servers |
| **Hash map** | Key-value items spread across partitions; scans possible | Shared inventories, caches of persistent data, server registries |

The docs' decision guide: if data must be ordered, use a sorted map; if you need to scan all items, a hash map (or a sorted map below about 1,000 keys); if you access by key, a hash map; if you process in order, a queue.

## Quotas and limits (Fact, creator docs)

| Limit | Value |
|---|---|
| Memory quota per game | 64 KB + 1.2 KB × number of users (reevaluated downward only after an eight-day traceback when users leave) |
| Request units per minute per game | 1,000 + 120 × concurrent users |
| Range reads and queue reads | Cost one unit per returned item (queue reads also cost extra while waiting) |
| Hash map `UpdateAsync` | At least two units |
| Single sorted map or queue | Up to 1,000,000 items and 100 MB |
| Throttling per partition | Begins at roughly 30,000 request units per minute |
| Per hash map key | About 5,000 write and 15,000 read units per minute |
| Default expiration | 45 days for queue adds and sorted map sets; set the shortest useful time |

Sorted maps and queues each live on **one partition**; hash maps spread across many. A popular sorted map or queue is therefore a single hotspot; **shard** it into several (for example by `userId % 4`) when throughput grows. Studio and live MemoryStores are separate. Paying for more capacity through Extended Services is a money decision for the human.

## Patterns

### Global leaderboard (top 100, refreshed)

```text
Each server, every 60 s per player (staggered): sorted map SetAsync(userId, score, expiration)
One elected server (or every server, cheaply): GetRangeAsync(descending, 100) every 30-60 s
Cache the top 100 in the server; replicate to clients via a value or remote
Persist season results to an OrderedDataStore at season end
```

Expirations make inactive players fall off automatically. Shard the sorted map when many servers write often, and merge the top N from each shard when reading.

### Matchmaking queue

```text
Lobby server: queue:AddAsync({userId, rating, joinedAt}, expiration)
Matchmaker (one lobby server elected by a MemoryStore lock): queue:ReadAsync(n) -> group by rating
  -> ReserveServer / TeleportOptions.ShouldReserveServer -> TeleportAsync the group
  -> queue:RemoveAsync(readId) after a successful teleport
If the matchmaker fails, unremoved items become visible again after the invisibility timeout
```

Details of teleporting groups are in [Matchmaking and teleports](matchmaking-and-teleports.md).

### Server registry and cross-server browser

Each server writes `{jobId, players, mode, region}` to a hash map key with a short expiration (for example 90 s) and refreshes it every 30-60 s. Lobby UIs scan or read a sharded sorted map to list servers. Dead servers vanish by expiry.

### Electing one server for a job

Use `UpdateAsync` on a hash map or sorted map key containing `{jobId, expiresAt}`: a server claims the job if the key is empty or expired, and refreshes it while alive. Only the holder runs the job (matchmaker, season roll-over, global event announcer).

### Cross-server announcements

Use **MessagingService** for "someone found a Secret item" or "an admin event starts now". It is best effort: limited to 1 KB messages and rate limits that grow with server and player counts ([Live events and admin events](../21-hits-and-trends/live-events-and-admin-events.md)). For anything that must happen reliably, combine it with a schedule or a MemoryStore flag that servers poll.

### Cross-server trading or auctions

Sorted maps can hold listings ordered by price with expirations. Item ownership must still be **transferred in DataStores**, atomically, with session-locked profiles on both sides; the MemoryStore is only the marketplace view ([Inventory and trading systems](inventory-and-trading-systems.md)).

### Cache in front of DataStores

A hash map can cache rarely changing but frequently read data (for example global config or a guild's shared data) with a short expiration, cutting DataStore reads.

## Handling failure

- Wrap every call in `pcall` and retry transient failures with backoff, as with DataStores ([Data persistence](data-persistence.md)).
- Prefer `UpdateAsync` over `SetAsync` for read-modify-write.
- Stagger recurring requests across servers and players (do not refresh everything on the same second).
- Treat throttling (`PartitionRequestsOverLimit`) as a signal to shard or slow down.
- Use the MemoryStore observability dashboard and alerts to watch memory, requests and errors.
- Design for MessagingService messages that never arrive.

## Testing

- Test in Studio with the Studio-scoped store, then in a private live server group; TeleportService and some cross-server flows only work in published games.
- Simulate failures (force errors in a wrapper) to confirm retries and fallbacks.
- Load-test request rates against the per-game formula before a big event.

## For agents

- [ ] The service choice for every cross-server feature is justified (DataStore, MemoryStore or MessagingService).
- [ ] MemoryStore items have the shortest useful expiration; nothing that must persist lives only there.
- [ ] Hot sorted maps and queues are sharded; request budgets are calculated for peak players.
- [ ] Every call is wrapped with retries and backoff; MessagingService is never the only path for critical actions.
- [ ] Extended Services or any paid capacity is escalated as a money decision.

Sources: [Memory stores](https://create.roblox.com/docs/cloud-services/memory-stores) · [Memory store best practices](https://create.roblox.com/docs/cloud-services/memory-stores/best-practices) · [Partitions](https://create.roblox.com/docs/cloud-services/memory-stores/per-partition-limits) · [Data stores versus memory stores](https://create.roblox.com/docs/cloud-services/data-stores-vs-memory-stores) · [MessagingService](https://create.roblox.com/docs/reference/engine/classes/MessagingService)

Related: [Data persistence](data-persistence.md) · [Matchmaking and teleports](matchmaking-and-teleports.md) · [Live events and admin events](../21-hits-and-trends/live-events-and-admin-events.md) · [Inventory and trading systems](inventory-and-trading-systems.md) · [Networking and remotes](networking-and-remotes.md)
