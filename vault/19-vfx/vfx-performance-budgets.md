---
title: VFX performance budgets
date: 2026-10-24
tags: [vfx, performance, mobile, optimization, budgets]
aliases: [Effect performance, Particle budgets, Fill rate, Overdraw]
summary: Why effects slow games down (fill rate, overdraw, particle counts, texture memory, instance churn), the budgets to set per device class, and how to measure effect cost with Studio's tools.
audience: [human, agent]
---

# VFX performance budgets

Effects are the easiest way to make a game beautiful and the easiest way to make it unplayable on a phone. Most of the audience plays on mobile, often on mid-range or older devices, so effect budgets are a design constraint from day one, not a polish task.

## What actually costs performance

| Cost | Cause | Symptom |
|---|---|---|
| **Fill rate / overdraw** | Large transparent particles and meshes covering the screen, especially stacked on top of each other | Frame drops when the camera is close to an effect; worse on high-resolution phones |
| **Particle count** | Rate × lifetime across all emitters | Steady frame cost; particles flicker or vanish when limits are hit |
| **Texture memory** | Many unique textures, especially 1024 flipbooks | Flipbooks switched off on low-memory devices; crashes on old phones |
| **Instance churn** | Creating and destroying parts, emitters and highlights every hit | Hitches, garbage collection spikes, highlight geometry rebuilds |
| **Lights** | Many dynamic lights, especially with shadows | GPU cost; shadows are the expensive part |
| **Post-processing** | Bloom, blur, depth of field at full resolution | GPU cost on every frame they are active |
| **Script cost** | Per-frame loops updating many effects in Luau | CPU frame time; leaked connections accumulate |
| **Replication** | Server-created effect instances | Network usage and late effects (see [VFX architecture and replication](vfx-architecture-and-replication.md)) |

The official documentation calls out the two biggest particle costs directly: particle **size** affects fill rate (the more screen pixels particles cover, the more expensive they are on the GPU), and particle **count** affects overdraw when transparent particles overlap.

## Budgets by device class (Rule of thumb)

Set budgets for the **worst device you support** and measure on it. Mid-range Android phones a few years old are a good reference.

| Budget | Low-end phone | Mid-range phone | Desktop |
|---|---|---|---|
| Live particles on screen (whole scene) | 300-500 | 800-1,200 | 3,000+ |
| Unique flipbook textures loaded | 2-4 | 6-10 | 15+ |
| Dynamic lights near the camera | 4-6, no shadows | 8-12 | 20+ |
| Effect meshes alive at once | 20 | 50 | 150 |
| Full-screen transparent layers at once | 1-2 | 2-3 | 4+ |
| Effect-related frame time | under 2 ms | under 3 ms | under 4 ms |

Remember the engine's own cap: 400 particles per second per emitter, 100 per second on mobile.

## Design techniques that save the most

1. **Bigger, fewer particles.** One large soft particle often looks better than ten small ones and costs less overdraw if it is not huge on screen.
2. **Short lifetimes.** Particle count is rate × lifetime. Halving lifetime halves the count.
3. **Burst, then stop.** `Emit(n)` once per event instead of enabling emitters for a while.
4. **Distance tiers.** Full detail near the camera, one layer far away, nothing beyond the view distance.
5. **Self first.** The local player's effects at full quality; others' effects at a lower tier.
6. **Reuse textures.** One grayscale texture tinted many ways instead of one texture per color.
7. **Avoid screen-filling transparent quads.** Put full-screen tints on post-processing or GUI, not on world meshes in front of the camera.
8. **Pool.** No create-and-destroy per hit.
9. **No shadows** on effect lights; short light ranges.
10. **Settings.** A "reduce effects" option, honoured everywhere.

## Measuring

| Tool | What to look at |
|---|---|
| **MicroProfiler** (Ctrl+F6 in Studio and in the client) | Frame time spikes when effects play; render and particle labels; script time in your effect modules |
| **Developer Console** (F9) | Client memory by category (graphics textures, particles), script errors from effect code |
| **Render stats** (Shift+F2) | Draw calls, triangles, frame time on the device |
| **Studio Editor Quality Level** | Preview effects at low and high quality |
| **Real devices** | The only truth for mobile; test the worst-case scene (full server, all ultimates) on a mid-range phone |

### A repeatable effect stress test

1. A test place with 20 dummy characters (or a multi-client Studio test).
2. A script that plays every effect in a loop near the camera, then all of them at once.
3. Record frame time and memory on a phone with the MicroProfiler or developer console.
4. Compare with the budget table; any effect over budget gets a reduced tier or a redesign.
5. Repeat after every major effect change. QA can run this as part of the polish gate (POLISH-03 in [Quality gates](../16-ai-studio-operations/quality-gates.md)).

## Warning signs in code review

- `Instance.new("ParticleEmitter")` inside a hit handler.
- `while true do ... task.wait() end` loops per effect instead of one manager.
- Effects parented to `workspace` with no cleanup timer.
- `Highlight` created and destroyed per hit.
- `Rate` values in the hundreds on continuous emitters.
- Effects created by the server for cosmetic purposes.

## For agents

- [ ] Effect budgets are written down per device class and checked on a real mid-range phone.
- [ ] Effects have distance tiers and honour the reduce-effects setting.
- [ ] Unique flipbooks and large textures are counted and kept within budget.
- [ ] The stress test runs before the polish gate, with numbers in the report.

Sources: [Particle emitters (performance notes)](https://create.roblox.com/docs/effects/particle-emitters) · [Performance optimization](https://create.roblox.com/docs/performance-optimization) · [MicroProfiler](https://create.roblox.com/docs/performance-optimization/microprofiler)

Related: [Performance optimization](../13-building-it-right/performance-optimization.md) · [Device performance](../08-mobile-and-cross-platform/device-performance.md) · [VFX toolkit reference](vfx-toolkit-reference.md) · [Build budgets](../06-world-and-look/build-budgets.md)
