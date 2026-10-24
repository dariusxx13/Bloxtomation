---
title: VFX toolkit reference
date: 2026-10-24
tags: [vfx, particles, beams, trails, highlights, lighting, reference]
aliases: [Effect instances, Roblox VFX objects, VFX limits]
summary: Every Roblox object you build visual effects from, what each is good at, and the hard engine limits (rates, lifetimes, texture sizes, highlight counts) as documented on 2026-10-24.
audience: [human, agent]
---

# VFX toolkit reference

Roblox gives you a small set of effect objects. Almost every effect you have admired in a top game, from a sword slash to a planet-sized ultimate, is a combination of these pieces, timed well. This note lists each piece, what it is for, and the limits the engine enforces. Read it before you design an effect so you do not plan something the engine cannot draw.

> [!NOTE]
> Limits marked **Fact** come from the Roblox Creator Documentation as of 2026-10-24 (links at the end). Everything marked **Rule of thumb** is studio practice: a sensible default, not a law.

## The building blocks

| Object | Lives under | What it draws | Typical uses |
|---|---|---|---|
| `ParticleEmitter` | `Attachment` or `BasePart` | Camera-facing (or velocity-aligned) 2D images spawned over time or in bursts | Sparks, smoke, fire, dust, magic motes, confetti, hit flashes, rain |
| `Beam` | Anywhere, pointing at two `Attachment`s | A textured ribbon between two attachments, optionally curved | Lasers, lightning, energy links, waterfalls, guide arrows, slashes drawn between points |
| `Trail` | Anywhere, pointing at two `Attachment`s | A ribbon left behind as two attachments move | Sword swings, dash streaks, projectile tails, tire marks, footprints |
| `Highlight` | A `Model` or `BasePart` (or with `Adornee`) | An outline and a fill overlay on an object | Interactable hints, rarity glows, "you are hit" flashes, silhouettes for impact frames |
| `PointLight`, `SpotLight`, `SurfaceLight` | `Attachment` or `BasePart` | Real-time local light | Glow cast by fireballs, muzzle flashes, lamps, screens |
| Post-processing (`BloomEffect`, `BlurEffect`, `ColorCorrectionEffect`, `DepthOfFieldEffect`, `SunRaysEffect`, `ColorGradingEffect`) | `Lighting` (everyone) or `Camera` (one player) | Full-screen filters | Glow, flashes, low-health tint, menu blur, mood, retro look |
| `Atmosphere`, `Clouds`, `Sky` | `Lighting` / `Terrain` | Haze, fog, volumetric clouds, sky | Mood, depth, weather |
| Meshes (`MeshPart`, `SpecialMesh`) with textures | `Workspace` | Any 3D shape, animated by tweening size, transparency, color or texture offset | Shockwave rings, domes, swirls, crescent slashes, craters, tornadoes |
| `Decal` / `Texture` on parts | A face of a `BasePart` | Images on surfaces; `Texture` can scroll via `OffsetStudsU/V` | Scrolling energy, magic circles on the ground, cracks |
| GUI objects (`ImageLabel`, `UIGradient`, `CanvasGroup`, `ViewportFrame`) | `ScreenGui`, `BillboardGui`, `SurfaceGui` | 2D effects on screen or in the world | Reward bursts, shines, rarity frames, impact overlays, speed lines |
| Legacy `Fire`, `Smoke`, `Sparkles`, `Explosion` | `BasePart` | Fixed-look effects | Quick prototypes only; `Explosion` also applies physics, which you rarely want |

Neon material plus a `BloomEffect` is the cheapest "glow" in the engine, and it is behind many energy weapons, auras and portals you see in popular games.

## Hard limits worth memorising (Fact, 2026-10-24)

| Limit | Value | Why it matters |
|---|---|---|
| Particle emission rate | Up to 400 particles per second per emitter; **100 per second on mobile** | A design that needs more uses several emitters or bigger particles |
| Particle lifetime | Capped at 20 seconds | Long-lived effects are built from repeated emission or meshes |
| Flipbook framerate | Up to 30 frames per second | Faster animation means more frames used per second of lifetime, not a higher rate |
| Flipbook layouts | 2×2, 4×4, 8×8 or custom (`FlipbookSizeX`/`FlipbookSizeY`) | The texture size must be an exact multiple of the layout |
| Flipbook textures | Square, power-of-two, up to 1024×1024 (from the flipbook release announcement) | An 8×8 sheet at 1024 gives 64 frames of 128×128 pixels |
| Flipbooks under memory pressure | Clients disable flipbooks automatically when low on memory | Old phones may show the first frame or nothing; reuse textures |
| Highlights on screen | 255 simultaneous `Highlight` instances per client; extras are silently ignored | Disabled highlights still use a slot, so delete instead of disabling permanently |
| Highlight cost | The first visible highlight costs the most (up to about 1 ms of GPU on mobile); highlights off-screen or fully transparent cost nothing | One outline system is cheap; dozens are fine after the first |
| Beam curve | Cubic Bézier from `CurveSize0`/`CurveSize1` and attachment orientation; 10 straight `Segments` by default | More segments for smooth curves, fewer for jagged lightning |
| Emitters in unions | Particles parented inside a `UnionOperation` do not render | Parent to an attachment or a plain part instead |
| Sphere and cylinder shapes | Do not display correctly when the emitter is under an `Attachment` | Use a `BasePart` parent for shaped emission |
| Post-processing placement | In `Lighting`: seen by every player. In `Camera`: seen only by that client | Per-player flashes and blurs go in the camera |

## What runs where

Effects are cosmetic, so they belong on the client. The server decides what happened (a hit, a hatch, a level-up) and tells clients; each client builds its own copy of the effect. Server-created effect instances replicate as instances, cost bandwidth and arrive late. See [VFX architecture and replication](vfx-architecture-and-replication.md).

Exceptions where server-side objects are reasonable:

- Static, permanent world effects placed in Studio (a waterfall, torches, a portal). They replicate once as part of the map.
- Effects that must be identical for every player and never change after placement.

## Quality levels and devices

Every effect is drawn differently depending on the player's graphics quality. The documentation recommends previewing effects at both the lowest and highest **Editor Quality Level** in Studio settings before you call them finished. In practice:

- Particles may be thinned on low quality; your effect must still read with fewer of them.
- Post-processing may be reduced or skipped on low-end devices; never put critical gameplay information only in a bloom or blur.
- Mobile is the majority platform (see [Mobile-first design](../08-mobile-and-cross-platform/mobile-first-design.md)); the 100 particles per second mobile cap is the one that bites first.

## Choosing the right tool (Rule of thumb)

| You want | Reach for | Not |
|---|---|---|
| Lots of small moving bits | `ParticleEmitter` | Dozens of tweened parts |
| A shape that grows or spins (ring, dome, slash arc) | Mesh + tweens | Particles trying to fake a solid shape |
| A line between two points (laser, lightning) | `Beam` | A stretched part (no texture motion, no curve) |
| A streak behind motion | `Trail` | Particles with `LockedToPart` |
| "This object matters" | `Highlight` or a slow pulse | A flashing neon box |
| A flash that fills the screen for one player | `ColorCorrectionEffect` under the camera, or a GUI frame | A giant neon part in front of the camera |
| Light cast onto the world | A `PointLight` with shadows off, short range | Bloom alone (bloom does not light surroundings) |

## For agents

- [ ] Check every planned effect against the limits table before building it.
- [ ] Effects are created on clients from server events; only static map effects live in the place.
- [ ] Preview at the lowest and highest Editor Quality Level; the effect must still communicate on low.
- [ ] No emitters inside unions; shaped emission uses a part parent.

Sources: [Particle emitters](https://create.roblox.com/docs/effects/particle-emitters) · [Beams](https://create.roblox.com/docs/effects/beams) · [Trails](https://create.roblox.com/docs/effects/trails) · [Highlighting](https://create.roblox.com/docs/effects/highlighting) · [Light sources](https://create.roblox.com/docs/effects/light-sources) · [Post-processing effects](https://create.roblox.com/docs/environment/post-processing-effects) · [Global lighting](https://create.roblox.com/docs/environment/lighting)

Related: [Particle emitters in depth](particle-emitters-in-depth.md) · [Beams, trails and highlights](beams-trails-and-highlights.md) · [VFX performance budgets](vfx-performance-budgets.md) · [VFX and particles](../07-characters-vfx-and-assets/vfx-and-particles.md)
