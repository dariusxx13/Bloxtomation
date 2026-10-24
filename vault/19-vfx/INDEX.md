---
title: VFX
date: 2026-10-24
tags: [index, vfx]
aliases: [VFX section, Visual effects deep dive]
summary: Index of the VFX deep dive - engine toolkit and limits, particles, beams, trails, highlights, textures, flipbooks, meshes, lighting and screen effects, timing, combat and reward effects, ambience, architecture, performance, tools and recipes.
audience: [human, agent]
---

# VFX

A deep dive into building visual effects on Roblox, from engine limits to anime ultimates. Start with the toolkit reference, then read by need. The overview note [VFX and particles](../07-characters-vfx-and-assets/vfx-and-particles.md) remains the one-page summary.

## Foundations

- [VFX toolkit reference](vfx-toolkit-reference.md): every effect object, what it is for, and the hard engine limits; read before designing any effect.
- [Particle emitters in depth](particle-emitters-in-depth.md): every ParticleEmitter property and the combinations behind smoke, sparks, fire, magic and rain.
- [Beams, trails and highlights](beams-trails-and-highlights.md): lasers, lightning, slashes, dashes, footprints, outlines and their traps.
- [Textures and flipbooks](textures-and-flipbooks.md): authoring effect textures and animated sprite sheets, with memory budgets.
- [Mesh VFX](mesh-vfx.md): rings, domes, slashes, swirls and craters from Blender to tweens and pools.
- [Lighting and screen effects for VFX](lighting-and-screen-effects.md): lights, bloom, color correction, grading, overlays, and comfort settings.

## Craft

- [VFX timing and choreography](vfx-timing-and-choreography.md): anticipation, impact, follow-through, hitstop, impact frames, camera shake, markers, tier escalation.
- [Combat and anime VFX](combat-and-anime-vfx.md): M1 hits to ultimates, auras, transformations, domains, readability and budgets per move.
- [Reward, UI and hatch VFX](reward-ui-and-hatch-vfx.md): coins flying to counters, level-ups, GUI shines and rays, rarity reveals.
- [Environment and ambient VFX](environment-and-ambient-vfx.md): zone identity, weather, fog, wind, water, fire, magic places, day-night accents.
- [VFX recipes](vfx-recipes.md): twenty-four effects with layers, settings and timing.

## Production

- [VFX architecture and replication](vfx-architecture-and-replication.md): server decides, clients draw; descriptors, markers, pooling, culling, security.
- [VFX performance budgets](vfx-performance-budgets.md): fill rate, overdraw, counts, memory, device budgets and the stress test.
- [VFX tools and workflow](vfx-tools-and-workflow.md): Studio tools, community plugins, external tools, the effect library, buying packs.
- [Learning and hiring for VFX](learning-and-hiring-vfx.md): an eight-week learning path, portfolios, commissions, briefs and reviews.

Related: [Game feel and juice](../02-core-loop/game-feel-and-juice.md) · [Anime games](../20-anime-games/INDEX.md) · [Characters, VFX and assets](../07-characters-vfx-and-assets/INDEX.md)
