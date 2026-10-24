---
title: Performance optimization
date: 2026-10-24
tags: [engineering, performance, memory, profiling]
aliases: [Optimization, Lag, Memory leaks]
summary: The engineering patterns that keep Roblox games fast on client and server: event-driven code, connection hygiene, batching, pooling, physics and replication costs, and how to profile.
audience: [human, agent]
---

# Performance optimization

Performance on Roblox has three budgets: client frame time (smooth play on phones), server frame time (all players' physics and logic in one process), and network (what moves between them). Memory sits under all three. This note covers code-level patterns; world budgets are in [Build budgets](../06-world-and-look/build-budgets.md).

## Measure first

- **MicroProfiler** (client and server): what takes time each frame. Look for script labels, physics, rendering and replication spikes.
- **Developer Console** (F9): memory by category, network usage, script performance, server stats, errors.
- **Script Profiler**: which functions use the most CPU.
- **Creator Analytics performance dashboards**: frame rate, memory, crashes and server health in the live game, by device.
- **Scene analysis**: rendering cost, memory, instance composition and leaked unparented instances in a place.

Optimize the biggest measured cost first. Do not guess.

## Event-driven, not polling

- React to events (`Changed`, signals, remote messages) instead of checking every frame.
- When a loop is needed, use one loop for many objects (one enemy manager loop, not one per enemy), at the lowest frequency that feels right (AI decisions at 5-10 Hz are usually enough; rendering-related updates on the client at frame rate).
- Use `task.wait`, `task.spawn`, `task.defer`; avoid the deprecated `wait`, `spawn` and `delay`.
- Use `RunService.Heartbeat` / `PreSimulation` / `PreRender` carefully: code bound there runs every frame.

## Connection and memory hygiene

Memory leaks are the most common cause of games that run well at first and degrade over a long session.

- Every `:Connect` that outlives its owner must be disconnected. Collect connections per object or per player in a cleanup helper (a "maid" or "trove" pattern) and clean up on destroy or `PlayerRemoving`.
- `Instance:Destroy()` disconnects the instance's own events and allows garbage collection; setting `Parent = nil` does not.
- Remove per-player tables on `PlayerRemoving` (rate-limit buckets, caches, state).
- Avoid storing references to destroyed instances in long-lived tables.
- Watch the Developer Console's memory over a 30-60 minute session; steady growth is a leak.

## Allocation discipline in hot paths

- Do not create tables, closures, `Vector3`s or strings in per-frame code if they can be reused.
- Cache service lookups and frequently used instances in locals.
- Pool frequently created objects (projectiles, effects, popups, NPCs).
- Use `table.clear` to reuse tables; `table.create` to presize arrays.
- Turn on Luau's native code generation (`--!native` at the top of a script) for hot numeric modules where profiling shows benefit.

## Physics

- Anchor everything that does not need to move.
- Disable `CanCollide`, `CanTouch` and `CanQuery` on decorative parts.
- `Touched` events are expensive and unreliable for gameplay at scale; prefer spatial queries (`GetPartBoundsInBox`, `GetPartBoundsInRadius`, raycasts) on a timer or on demand.
- Use collision groups to skip unnecessary collision pairs (players vs pets, effects vs everything).
- Set network ownership deliberately for unanchored parts that matter.
- Prefer constraint-based or CFrame-based movement for many NPCs over many full `Humanoid`s.

## Replication and network

- Move only what is needed. Batch remote messages; send ids and numbers, not big tables.
- Use `UnreliableRemoteEvent` for frequent cosmetic updates.
- Client-only visuals (effects, pets, popups) never get created on the server.
- Streaming reduces both memory and replication for big worlds.
- Avoid replicating rapidly changing properties of many parts from the server (for example animating hundreds of coins on the server). Animate locally.

## Server-specific

- One server hosts every player in it: a 50-player server with expensive per-player loops multiplies costs.
- Watch server heartbeat (frame rate) in the Developer Console and dashboards; a slow server makes everything feel laggy for everyone.
- Spread expensive work across frames (process 10 players per frame instead of 50 at once).
- DataStore and HTTP calls are asynchronous; never block important threads on them.

## UI

See [UI implementation](../05-ui-and-hud/ui-implementation.md): update on state changes only, pool popups, limit viewports and big images.

## Review checklist

- [ ] No per-object loops; managers update collections at chosen frequencies.
- [ ] All connections tracked and cleaned on destroy and player leave.
- [ ] No allocations in per-frame hot paths that can be reused.
- [ ] Decorative parts anchored with collision, touch and query disabled.
- [ ] Spatial queries instead of `Touched` for scaled gameplay checks.
- [ ] Remote traffic batched; cosmetics on unreliable remotes and client-side.
- [ ] 30-60 minute soak test shows stable memory on client and server.

Related: [Build budgets](../06-world-and-look/build-budgets.md) · [Device performance](../08-mobile-and-cross-platform/device-performance.md) · [Networking and remotes](networking-and-remotes.md) · [Testing and QA](testing-and-qa.md)
