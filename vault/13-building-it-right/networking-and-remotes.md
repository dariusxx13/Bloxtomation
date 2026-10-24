---
title: Networking and remotes
date: 2026-10-24
tags: [engineering, networking, remotes, security, performance]
aliases: [Remotes, RemoteEvents, Net module]
summary: How to design the client-server API of a Roblox game: one Net module, typed payloads, validation and rate limits on every handler, efficient state replication.
audience: [human, agent]
---

# Networking and remotes

Remotes (`RemoteEvent`, `RemoteFunction`, `UnreliableRemoteEvent`) are the only way clients and server talk. They are also the main attack surface: an exploiter can fire any remote with any arguments at any rate. Treat remotes as a public API.

## House rule: one Net module

All remotes are declared in one list in `shared/Net`, created by the server at startup in one folder, and used through a small wrapper:

```lua
-- shared/Net/Definitions.luau (sketch)
return {
	-- name             kind        rate/sec  burst
	RequestHatch   = { kind = "function", rate = 4,  burst = 6 },
	BuyUpgrade     = { kind = "function", rate = 6,  burst = 10 },
	EquipPet       = { kind = "event",    rate = 8,  burst = 12 },
	StateSnapshot  = { kind = "event" },             -- server -> client
	StateDelta     = { kind = "event" },             -- server -> client
	Effect         = { kind = "unreliable" },        -- server -> client, cosmetic
}
```

The wrapper:

- `Net.handle(name, validator, handler)` on the server: applies the rate limit, runs the validator, then calls the handler in a protected call. Returns a small result table for functions.
- `Net.fire(name, ...)` / `Net.invoke(name, ...)` on the client.
- `Net.toClient(player, name, ...)` / `Net.toAll(name, ...)` on the server.

Adding a remote is one line in one file. Every handler automatically gets validation and rate limiting.

## Validation order

For every argument, check in this order and silently drop the request on failure (optionally log):

1. **Type**: `typeof(x) == "string"`; never index an argument before its type is checked.
2. **Range**: no `NaN` (`x ~= x`), no infinity, integers where integers are expected, bounded lengths for strings and tables.
3. **Existence and permission**: the item id exists in the server catalog; this player owns it or may buy it; the target object is the kind expected and the player may act on it.
4. **Plausibility**: distance to the target, cooldowns, state (the egg is unlocked, the chest is not already open, the enemy is alive), and server-side prices and balances.

Prefer sending **ids and scalars**, not tables or instances. If a table is needed, validate every field you read and reject unexpected shapes.

## Rate limits

Use a token bucket per player per remote (rate per second plus burst). Typical values: UI actions 5-10 per second, core actions at human speed (for example clicks capped at 10-20 per second), heavy actions (hatching, trading) a few per second. Track repeat offenders as telemetry; do not auto-ban on rate limits alone (lag and retries cause false positives).

## RemoteFunction rules

- Client to server functions (`InvokeServer`) are fine when the client needs a result (purchase success, hatch results). The server handler must never yield for long.
- **Never** use `InvokeClient` for anything that matters: a client can never respond and hang the server thread. Use events with server-side timeouts.
- Return only what the client should know.

## Replicating state efficiently

- **Snapshot plus deltas**: on join, send the player's full relevant state once; then send small changes ("Coins = 1250", "PetAdded {id, kind}").
- **Batch**: combine many changes in a frame into one message. Do not fire a remote per coin.
- **Throttle cosmetic traffic**: for frequent cosmetic events (other players' hit effects), use `UnreliableRemoteEvent` and drop or merge when busy.
- **Per-player relevance**: send other players' events only to clients that can see them (nearby).
- **Attributes and replicated values** are fine for simple shared state (a door's open state), but avoid replicating large or rapidly changing tables through instances.
- **Never put authoritative state in replicated Value objects that the server later reads back**; the server keeps its own state in modules.

## Latency and feel

- Client predicts cosmetic results immediately (animation, sound, a provisional number) and corrects if the server disagrees.
- The server timestamps actions and uses its own clock for cooldowns.
- For competitive physics games, consider Roblox's server authority model with client prediction and rollback (it requires the Input Action System and other workspace settings). See [Security and anti-exploit](security-and-anti-exploit.md).

## For agents

- [ ] Every remote declared in the single Net definitions list with kind and rate limit.
- [ ] Every server handler has a validator covering type, range, existence/permission and plausibility.
- [ ] No `InvokeClient` usage.
- [ ] State replicated as snapshot plus batched deltas; cosmetic events unreliable and relevance-filtered.
- [ ] No handler trusts client-provided prices, amounts, damage or results.

Related: [Security and anti-exploit](security-and-anti-exploit.md) · [Project architecture](project-architecture.md) · [Performance optimization](performance-optimization.md) · [Luau standards](luau-standards.md)
