---
title: Parallel Luau and profiling
date: 2026-10-24
tags: [engineering, performance, profiling, parallel-luau, actors, devices, memory]
aliases: [Parallel Luau, Actors, MicroProfiler, Scene Analysis, Device testing, Performance tools]
summary: How to find and fix performance problems on Roblox - the official diagnostic tools (Developer Console, MicroProfiler, Scene Analysis, Performance Dashboard), what real player devices look like, a profiling workflow, and when and how to use Parallel Luau (actors, desynchronize, ConnectParallel, thread safety, actor messaging, SharedTable) with a compute-then-apply pattern.
audience: [human, agent]
---

# Parallel Luau and profiling

Performance problems are found with tools, not guesses. Most Roblox players use low-spec phones, so a game that runs well on a developer PC can still fail most of its audience. This note covers the official tools, the device reality, a profiling workflow and Parallel Luau for the rare cases where computation itself is the bottleneck. General practices are in [Performance optimization](performance-optimization.md); mobile budgets in [Mobile and cross-platform](../08-mobile-and-cross-platform/INDEX.md).

## The devices players actually use (Fact, creator docs, accessed 2026-10-24)

Roblox's guidance on testing with real hardware gives these general statistics:

- **Android is roughly 65%** of a typical game's players.
- Of those Android players, about **60% have 2-4 GB of RAM**, about 35% have 4-8 GB, and about 5% have more than 8 GB.
- **Over half of all Roblox players** use devices scoring between 10,000 and 20,000 on the Passmark benchmark.
- Studio's device emulator checks aspect ratios and controls but is **not accurate for memory**; frame rate, thermal throttling and input latency also differ on real devices.

Pick at least one low-end Android baseline device for the studio and test every release on it ([Testing and QA](testing-and-qa.md)).

## The diagnostic tools (Fact, creator docs)

| Tool | What it shows | How to open |
|---|---|---|
| Developer Console | Logs, errors, memory by category, network, script performance; launches client or server MicroProfiler | F9 (in Studio and live games) |
| MicroProfiler | Time spent on each task per frame; dumps for detailed analysis; client or server | Ctrl+Alt+F6 (Cmd+Option+F6) |
| Scene Analysis | Treemaps of script memory, unparented instances held by scripts, instance composition, audio and animation memory, triangle breakdown, for client and server | Window > Performance Summary > Scene Analysis (Studio, during play) |
| Performance Stats | Memory, CPU, GPU, network and ping toolbar | Ctrl+Alt+F7 (Cmd+Option+F7) |
| Performance Dashboard | Live client and server performance of the published game over time, including crash rates and memory | Creator Dashboard analytics |
| Luau heap tool | Individual allocations for memory leak hunting | Studio memory tools |

## A profiling workflow

1. **Watch the dashboard.** After each release, check the Performance Dashboard for crash rate, memory and frame rate changes, and correlate with business metrics ([Analytics instrumentation](analytics-instrumentation.md)).
2. **Reproduce on the baseline device** with a full server and long sessions; many leaks only show after 30+ minutes.
3. **Classify the problem:** frame rate (compute), memory, or load time.
4. **Frame rate:** capture MicroProfiler dumps on client and server; find the tallest scopes (scripts, physics, rendering, animation).
5. **Memory:** use Scene Analysis and the console's memory categories; look for script memory that grows with interactions (tables never cleaned) and instance counts that grow (effects never destroyed).
6. **Load time:** check asset sizes, instance counts and streaming settings.
7. **Fix the biggest item first,** re-measure, record before and after numbers in the handoff.

The official monitoring example describes exactly this pattern: a crash rate rising after an update, traced through the dashboard and the console's script memory breakdown to a script that added data to a table and never cleaned it up.

## Common findings and fixes

| Finding | Typical cause | Fix |
|---|---|---|
| Script memory rising over a session | Tables keyed by player or instance never cleared | Clear on `PlayerRemoving` and `Destroying` ([Performance optimization](performance-optimization.md)) |
| Many unparented instances held | Effects or UI cached forever | Pool with a cap, or release references |
| Heavy `Heartbeat` scopes | Per-frame work for many objects | Tick budgets, event-driven updates, distance tiers |
| Physics spikes | Many unanchored parts, debris | Anchor, cap debris, client-side visuals ([Physics and network ownership](physics-and-network-ownership.md)) |
| Rendering spikes on phones | Overdraw from particles, big transparent meshes | VFX budgets and quality tiers ([VFX performance budgets](../19-vfx/vfx-performance-budgets.md)) |
| Network spikes | Large remote payloads, frequent property changes | Compact payloads, unreliable remotes for cosmetic data ([Networking and remotes](networking-and-remotes.md)) |
| Long loads | Huge maps, uncompressed audio and textures | Streaming, asset budgets ([Build budgets](../06-world-and-look/build-budgets.md)) |

## Parallel Luau (Fact, creator docs)

Parallel Luau lets code run on several threads at once. It helps when **computation** is the bottleneck (many NPC perception checks, raycast validation for many players, procedural generation), not when the problem is instance count, rendering or memory.

### The model

- Scripts must sit under **`Actor`** instances. Scripts in the same actor run sequentially with respect to each other; separate actors can run in parallel.
- Code under an actor still runs serially until it calls **`task.desynchronize()`**, which resumes it in the next parallel phase; **`task.synchronize()`** returns to the serial phase.
- **`RBXScriptSignal:ConnectParallel()`** runs a callback directly in a parallel phase (no `desynchronize` needed).
- **`require()` cannot be called in a parallel phase**; require modules first in serial code.
- Most instance **writes are not allowed in parallel**. API members have thread safety levels: Unsafe (no access), Read Parallel (read only), Local Safe (within the same actor), Safe. Members without a label are Unsafe.

### Communication between actors

- **Actor messaging:** `Actor:SendMessage(topic, ...)` sends asynchronously to one actor; the receiver binds with `BindToMessage` (serial) or `BindToMessageParallel` (parallel).
- **`SharedTable`:** a table-like structure shared across actors with atomic updates visible to all, without copying; good for large shared state.
- **Data model properties and attributes:** possible, with the write restrictions above.

### The compute-then-apply pattern

```lua
--!strict
-- Inside a script under an Actor: compute in parallel, then apply in serial.
local RunService = game:GetService("RunService")

local results: { [Model]: Vector3 } = {}

RunService.Heartbeat:ConnectParallel(function(_dt: number)
	-- Parallel phase: read positions, do expensive math or raycasts, store results.
	-- No instance writes here.
	table.clear(results)
	-- ... fill results[npc] = desiredMoveTarget ...

	task.synchronize()

	-- Serial phase: apply the results to instances.
	for npc, target in results do
		local humanoid = npc:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:MoveTo(target)
		end
	end
end)
```

Split work across several actors (for example one actor per group of NPCs) so the engine can spread them across cores. One actor doing everything gains nothing.

### When not to bother

- When the MicroProfiler shows rendering, physics or replication as the bottleneck.
- When the work is small; the serial-parallel switching has overhead.
- When the logic mostly writes to instances; it will spend its time in serial phases anyway.

## Performance budgets in briefs

Every build brief should state budgets the QA tester can check (Rule of thumb starting points; tune per game):

| Budget | Target on the baseline device |
|---|---|
| Frame rate | 30 fps minimum in a full server with maximum effects |
| Client memory | Stable over a 30-minute session (no steady growth) |
| Server heartbeat | Steady near 60 Hz with a full server |
| Load to first action | Under 20 seconds on a mid-range phone |

See [Build briefs](../16-ai-studio-operations/build-briefs.md) and [Quality gates](../16-ai-studio-operations/quality-gates.md).

## For agents

- [ ] Each release is checked on the Performance Dashboard and on the baseline low-end device.
- [ ] Performance handoffs include MicroProfiler or Scene Analysis evidence with before and after numbers.
- [ ] Parallel Luau is used only when profiling shows computation as the bottleneck, with work split across several actors.
- [ ] No `require()` in parallel phases; no instance writes in parallel.

Sources: [Identify performance issues](https://create.roblox.com/docs/performance-optimization/identify) · [Monitor performance](https://create.roblox.com/docs/performance-optimization/monitor) · [Scene Analysis](https://create.roblox.com/docs/performance-optimization/scene-analysis) · [Test on hardware](https://create.roblox.com/docs/performance-optimization/test-on-hardware) · [MicroProfiler](https://create.roblox.com/docs/performance-optimization/microprofiler) · [Parallel Luau](https://create.roblox.com/docs/scripting/multithreading)

Related: [Performance optimization](performance-optimization.md) · [Testing and QA](testing-and-qa.md) · [NPC AI and pathfinding](npc-ai-and-pathfinding.md) · [VFX performance budgets](../19-vfx/vfx-performance-budgets.md) · [Mobile and cross-platform](../08-mobile-and-cross-platform/INDEX.md)
