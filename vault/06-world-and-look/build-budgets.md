---
title: Build budgets
date: 2026-10-24
tags: [performance, world, streaming, optimization]
aliases: [Performance budgets, World budgets, Streaming]
summary: Practical limits for parts, meshes, textures, effects and scripts so worlds run on low-end phones, plus how to configure streaming.
audience: [human, agent]
---

# Build budgets

A budget is a limit you set before building, so performance is designed in instead of patched later. Roblox runs on cheap Android phones with little memory; a world that runs at 60 frames per second on a gaming PC can stutter or crash there. Since a stutter in the first minute looks like boredom in your analytics, budgets are a retention tool.

## Set budgets per area

Rules of thumb for a game targeting low-end phones (measure your own game; these are starting limits, not platform rules):

| Resource | Budget guideline | Notes |
|---|---|---|
| Client memory (total) | Stay well under what low-end phones handle; watch the Developer Console memory view on a low-end device profile | Phones crash or reload when memory runs out |
| Visible parts near the player | A few thousand at most in busy areas | Merge decorative parts, use meshes for complex shapes |
| Unique meshes | Reuse heavily | Each unique mesh and texture costs memory |
| Texture resolution | 512 px or less for most props; 1024 only for hero assets | Big textures are the most common memory hog |
| Moving (unanchored) parts | Keep low; anchor everything static | Physics costs CPU and network |
| Particle emitters active at once | Dozens, not hundreds; cap `Rate` and `Lifetime` | Particles are drawn every frame |
| Shadow-casting local lights | A handful near the player | Each costs GPU |
| Always-on `BillboardGui`s | Limit with `MaxDistance` | Many billboards cost both CPU and GPU |
| Sounds playing at once | Keep low; stop distant sounds | Mixing cost and noise |

## Streaming

Instance streaming (`Workspace.StreamingEnabled`) loads and unloads parts of the world around the player. It is the single most important setting for big worlds on phones.

Key settings (platform facts):

- `StreamingMinRadius`: the area always kept loaded around the player.
- `StreamingTargetRadius`: how far out the engine tries to stream content. It should be larger than the minimum radius.
- `StreamOutBehavior`: with the default `LowMemory`, content streams out only when memory is low; `Opportunistic` streams out content beyond the target radius more aggressively.
- Model streaming modes per model: **Atomic** (whole model streams in and out together), **Persistent** (always loaded for everyone), **PersistentPerPlayer** (always loaded for specific players), and **Nonatomic** (default; parts stream individually). Setting `Workspace.ModelStreamingBehavior` to `Improved` changes how nonatomic models stream.

Design rules:

- Client code must never assume a part exists. Use `WaitForChild` with timeouts carefully, listen for streaming events, or make models Atomic or Persistent when scripts depend on their completeness.
- Mark small essential models (a player's plot sign, the shop counter) Atomic; mark tiny always-needed things Persistent sparingly.
- Use `Player:RequestStreamAroundAsync(position)` before teleporting a player far within the same place.
- Physics and client-side simulation only happen in streamed areas.

## Assembly and part tips

- **Anchor everything static.** Unanchored decorative parts waste physics time.
- **Collisions**: disable `CanCollide`, `CanQuery` and `CanTouch` on decorative parts that do not need them. Fewer collision checks and touch events.
- **Simple collision geometry**: use box or hull collision fidelity on complex meshes when exact collision is not needed.
- **Unions and meshes**: complex unions can be expensive; convert repeated complex shapes to meshes.
- **Level of detail**: `RenderFidelity` and model level-of-detail settings reduce distant detail.
- **Instance count**: big folders of small parts (thousands of grass blades) are costly; use terrain decoration, textures or meshes.

## Scripts and effects budgets

- No per-frame loops on the server for every object; batch updates (one loop handles all enemies) and lower frequency where possible.
- Effects on the client only, culled by distance.
- Pool frequently created objects (projectiles, popups, particles).

See [Performance optimization](../13-building-it-right/performance-optimization.md).

## Measuring

- **Developer Console** (F9): memory by category, network, scripts, server stats.
- **MicroProfiler**: frame time breakdown on client and server.
- **Device Simulator** for screen layouts (it does not simulate a phone's CPU; test real devices or use performance-limited settings for CPU checks).
- **Performance dashboard** in Creator Analytics: frame rate, memory, crash rate and errors by device after launch.
- **Scene analysis**: Studio's scene analysis tools report rendering cost, memory and instance composition.

## For agents

- [ ] Budgets written for the game (memory, visible parts, texture sizes, emitters, lights).
- [ ] Streaming enabled with radii chosen and tested; scripts handle streamed-out instances.
- [ ] Static parts anchored; decorative parts have collision, query and touch disabled.
- [ ] A low-end device test is part of every release checklist.
- [ ] Memory and frame time recorded before and after major content additions.

Related: [World and level design](world-and-level-design.md) · [Performance optimization](../13-building-it-right/performance-optimization.md) · [Device performance](../08-mobile-and-cross-platform/device-performance.md) · [VFX and particles](../07-characters-vfx-and-assets/vfx-and-particles.md)
