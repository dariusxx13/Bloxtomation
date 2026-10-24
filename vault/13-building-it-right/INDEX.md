---
title: 13 Building it right
date: 2026-10-24
tags: [index, engineering]
summary: Engineering standards: architecture, networking, security, data, performance, testing, tooling, analytics and code style.
---

# 13 Building it right

- [Project architecture](project-architecture.md): Rojo layout, two entry points, init/start startup, module communication, where code goes.
- [Networking and remotes](networking-and-remotes.md): one Net module, validation order, rate limits, state replication.
- [Security and anti-exploit](security-and-anti-exploit.md): threat model, server authority, combat and movement checks, backdoors, audit checklist.
- [Data persistence](data-persistence.md): session locking, UpdateAsync, autosave and shutdown, migrations, correct ProcessReceipt.
- [Performance optimization](performance-optimization.md): measuring, event-driven code, leaks, allocations, physics, replication.
- [Testing and QA](testing-and-qa.md): test layers, unit tests, multi-client playtests, QA tools, Studio CLI and MCP automation, release checklist.
- [Tooling and CI](tooling-and-ci.md): Script Sync vs Rojo, the toolchain, CI pipeline, Open Cloud saved uploads.
- [Analytics instrumentation](analytics-instrumentation.md): event types and limits, naming, the minimum event plan, a wrapper module.
- [Luau standards](luau-standards.md): strict typing, naming, module shape, error handling, review flags.

## Deep dives

- [Combat systems and hitboxes](combat-systems-and-hitboxes.md): hit detection methods, validation, lag compensation, combat state, projectiles, and the server authority model.
- [NPC AI and pathfinding](npc-ai-and-pathfinding.md): state machines, perception, PathfindingService limits and modifiers, scaling, bosses.
- [Physics and network ownership](physics-and-network-ownership.md): assemblies, ownership rules and exploits, vehicles, ragdolls, timestepping, sleep.
- [Parallel Luau and profiling](parallel-luau-and-profiling.md): real player devices, diagnostic tools, a profiling workflow, actors and thread safety.
- [Animation systems](animation-systems.md): Animator, priorities, markers, replication, Animation Graph Editor, IK, Adaptive Animation.
- [Audio systems](audio-systems.md): modular audio objects, 2D and 3D wiring, effects, buses and ducking, import limits, a sound module.
- [MemoryStore and cross-server systems](memorystore-and-cross-server.md): choosing services, sorted maps, queues, hash maps, quotas, sharding, patterns.
- [Matchmaking and teleports](matchmaking-and-teleports.md): server matchmaking signals, TeleportService, reserved servers, lobby-to-match flows.
- [Inventory and trading systems](inventory-and-trading-systems.md): item model, server operations, trade state machine, atomic swaps, policy checks.

Up: [Vault home](../README.md)
