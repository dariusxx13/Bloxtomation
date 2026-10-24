---
title: Device performance
date: 2026-10-24
tags: [performance, mobile, memory, optimization]
aliases: [Low-end devices, Mobile performance]
summary: How to keep a Roblox game smooth on low-end phones: what costs the most, how to measure it, and a release checklist.
audience: [human, agent]
---

# Device performance

Performance problems on phones show up in analytics as boredom: short sessions, high early bounce, low D1. Players do not report "frame drops"; they just leave. This note is the player-facing view of performance. Engineering details are in [Performance optimization](../13-building-it-right/performance-optimization.md) and world budgets in [Build budgets](../06-world-and-look/build-budgets.md).

## What hurts phones most

| Cost | Typical cause | Fix |
|---|---|---|
| Memory | Big textures, many unique meshes, unstreamed maps, huge UI images | Streaming, texture size limits, reuse meshes, sprite sheets |
| GPU | Many particles, shadow-casting lights, transparency layers, big post-processing | Cap emitters, few lights, reduce effects setting |
| CPU (client) | Per-frame scripts, many humanoids, physics on many unanchored parts, UI rebuilt every frame | Event-driven code, fewer humanoids, anchor parts |
| Network | Frequent large remote messages, replicating many moving parts | Batch and compress messages, client-side visuals |
| Load time | Too much content needed at spawn, many preloads | Stream, preload only the first minute |

## The low-end profile

Define a "worst supported device" (an older, budget Android phone) and test the full first session on it before launch and before every big update. Watch:

- Time from join to first input.
- Frame rate in the busiest moments (full lobby, boss fight, mass hatching).
- Memory over a 30-minute session (rising memory means a leak).
- Device temperature and battery drain over 20 minutes.

## Quality scaling

Read the player's graphics quality on the client and scale optional costs:

- Particle rates and counts.
- Others' pets, auras and trails (hide beyond a short distance or entirely).
- Post-processing effects.
- Decorative props (a "low detail" setting that removes clutter).

Also offer explicit settings ("Reduce effects", "Hide other players' pets") because some players will choose smoothness over looks.

## Measuring after launch

Creator Analytics provides performance dashboards: frame rate, memory usage, crash rates, server health and errors, segmented by platform and device. Set up alerts for spikes in crashes or errors after an update. See [Analytics instrumentation](../13-building-it-right/analytics-instrumentation.md).

## Release checklist

- [ ] First session played on the worst supported device without stutters at spawn.
- [ ] Memory stable over a 30-minute session (no steady climb).
- [ ] Frame rate acceptable in the busiest scene with a full server.
- [ ] Effects and pets scale down at low graphics quality; settings exist to hide others' effects.
- [ ] Crash and error rates compared to the previous version after release.

Related: [Mobile-first design](mobile-first-design.md) · [Build budgets](../06-world-and-look/build-budgets.md) · [Performance optimization](../13-building-it-right/performance-optimization.md) · [First-session killers](../01-first-five-minutes/first-session-killers.md)
