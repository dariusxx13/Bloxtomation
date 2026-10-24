---
title: Textures and flipbooks
date: 2026-10-24
tags: [vfx, textures, flipbooks, sprite-sheets, art-pipeline]
aliases: [Particle textures, Sprite sheets, Flipbook textures, VFX textures]
summary: How to author textures for particles, beams and trails - grayscale, alpha, soft edges, additive-friendly images - and how to build, import and budget animated flipbook sprite sheets.
audience: [human, agent]
---

# Textures and flipbooks

The texture is half of every effect. A great texture with simple settings beats elaborate settings on the default sparkle. This note covers static textures for particles, beams and trails, and **flipbooks**: animated sprite sheets that play inside each particle.

## Principles for effect textures

1. **Author in grayscale.** Let the effect's `Color` property tint the texture. One grayscale smoke texture becomes fire smoke, poison gas and holy mist just by changing the color sequence. This is also how you keep the texture library small.
2. **Transparent background (PNG with alpha).** Black backgrounds only work with additive blending (`LightEmission` 1), and they waste memory.
3. **Soft edges.** Hard-edged circles look like stickers. Blur the edge or use a radial gradient; even "solid" shapes like shards benefit from a one-pixel soft edge.
4. **Bright center, dark falloff for glows.** Additive particles add their brightness to whatever is behind them; a bright core with a long soft falloff reads as light.
5. **Shape tells the story.** Round puffs for smoke, streaks for sparks and speed, shards for impacts, crescents for slashes, rings for shockwaves, noisy wisps for magic.
6. **Small and reusable.** A 256×256 smoke puff is plenty for most particles; the engine scales it. Save 512 and 1024 for flipbooks and hero effects.

## A starter texture set (Rule of thumb)

A studio-quality library starts with about twenty textures, all grayscale:

| Texture | Used for |
|---|---|
| Soft round puff | Smoke, dust, steam, clouds |
| Hard dot with soft edge | Sparkles, motes, stars |
| Glow (radial gradient) | Cores, flashes, light blobs |
| Streak (thin line, soft ends) | Sparks, rain, speed lines |
| Star / cross flare | Rarity sparkles, hit flashes |
| Ring (soft) | Shockwaves on particles, ripples |
| Crescent / slash arc | Sword and claw slashes |
| Shard / triangle | Debris, glass, ice, crystal impacts |
| Wispy noise | Magic, spirit energy, auras |
| Electric zigzag | Lightning on particles, short-circuits |
| Flame tongue | Fire on particles |
| Square with soft edge | Pixel or digital themes |
| Scrolling energy (tileable, horizontal) | Beams and trails |
| Gradient strip (white to transparent) | Trails, beam fades |
| Leaf, petal, coin, heart, note | Themed bursts |

## Flipbooks: animated textures

A flipbook is one image containing a grid of frames. The particle steps through the frames over its life.

### Layouts and limits (Fact, 2026-10-24)

- `FlipbookLayout`: `None`, `Grid2x2` (4 frames), `Grid4x4` (16), `Grid8x8` (64) or `Custom` with `FlipbookSizeX` and `FlipbookSizeY`.
- The texture size must be an exact multiple of the layout; textures are square and power-of-two, up to 1024×1024.
- `FlipbookFramerate` is a range with a maximum of 30 frames per second.
- `FlipbookMode`: `Loop`, `OneShot` (plays once over the particle's lifetime; framerate is ignored and frames are spread evenly across the lifetime), `PingPong`, `Random` (random order, crossfading).
- `FlipbookStartRandom` starts each particle on a random frame. With framerate 0, every particle becomes a random still frame: a cheap way to vary debris or leaves from one sheet.
- `FlipbookBlendFrames` crossfades between frames instead of swapping instantly; smoother for slow animations.
- Clients disable flipbooks when low on memory, which is likely on older phones.

### Frame budgets

| Layout at 1024×1024 | Frame size | Good for |
|---|---|---|
| 2×2 | 512×512 | Large hero frames with little motion (a pulsing rune) |
| 4×4 | 256×256 | Most impacts, flames and smoke |
| 8×8 | 128×128 | Fast, small animations (sparks, flickers), long loops |

For an explosion that lasts 0.5 s with `OneShot`, a 4×4 sheet shows 16 frames in half a second: 32 fps-equivalent and smooth. For a looping torch at 15 fps, 16 frames is a one-second loop.

### Authoring a flipbook

1. **Make the animation.** Options: hand-drawn frames (Krita, Photoshop, Procreate, Aseprite for pixel styles), rendered frames from Blender (smoke and fire simulations, or animated shader noise), or dedicated real-time simulation tools that export sprite sheets. Hand-drawn 2D frames suit anime effects best: bold shapes, few frames, strong timing.
2. **Render frames to a grid.** Each frame centred, nothing crossing the cell boundary.
3. **Leave spacing.** The documentation explicitly asks for transparent spacing around each frame because texture filtering and mipmaps sample neighbouring pixels; without it, edges of the next frame bleed in. Two to four pixels of empty border per cell at 256-pixel cells is a safe start.
4. **Convert to grayscale with alpha** unless the colors are essential to the frames.
5. **Check the loop.** For `Loop` mode, the last frame must flow into the first.
6. **Import** with the Asset Manager, copy the asset id into `Texture`, set the layout, then tune `Lifetime`, `FlipbookMode` and framerate.

### Flipbook design tips

- Combine a flipbook "hero" particle (the explosion fireball) with cheap non-animated secondary particles (sparks, smoke). One animated layer is usually enough.
- Use `OneShot` for things that happen once (impacts, explosions, smoke puffs). Use `Loop` for things that persist (fire, auras).
- Randomise `Rotation` so repeated flipbooks do not look stamped.
- Keep flipbook counts per scene small; reuse one flame sheet for torches, fireballs and burning debris with different colors and sizes.

## Textures for beams and trails

- **Tileable horizontally** so `Wrap` mode and `TextureSpeed` scroll seamlessly.
- **Soft top and bottom edges** to avoid hard ribbon borders.
- Electric and energy textures with a bright center line and noisy falloff sell lasers and lightning.
- A gradient from opaque to transparent along the length makes trails taper without a `WidthScale` curve.

## Importing, ownership and safety

- Upload textures through the Asset Manager or bulk import; each becomes an image asset in your account or group. Use the **group** that owns the game so assets do not depend on one person's account.
- Moderation reviews uploaded images; avoid anything that could be mistaken for inappropriate content, including suggestive shapes in abstract textures.
- Textures from the Creator Store or other creators must be recorded in the asset index with source and license ([Asset pipeline](../07-characters-vfx-and-assets/asset-pipeline.md)). Large open-source flipbook libraries exist in community plugins; check the license of each pack before shipping.
- Never ship textures ripped from other games or from anime screenshots. Draw your own or license them.

## Memory budget (Rule of thumb)

| Texture | Approximate GPU memory |
|---|---|
| 256×256 RGBA | About 0.25 MB (plus mipmaps, roughly a third more) |
| 512×512 RGBA | About 1 MB |
| 1024×1024 RGBA | About 4 MB |

Ten unique 1024 flipbooks on screen is around 50 MB of texture memory, which a low-end phone may refuse, so it switches flipbooks off. Prefer fewer, reused, smaller sheets.

## For agents

- [ ] Every new effect texture is grayscale on transparent background unless color is essential.
- [ ] Flipbook sheets have empty spacing around each frame and match their layout exactly.
- [ ] No more than one animated flipbook layer per effect unless the effect is a hero moment.
- [ ] Every non-owned texture is in the asset index with its license.

Sources: [Particle emitters, flipbooks](https://create.roblox.com/docs/effects/particle-emitters#flipbooks) · [ParticleEmitter API](https://create.roblox.com/docs/reference/engine/classes/ParticleEmitter) · [Asset Manager](https://create.roblox.com/docs/projects/assets/manager)

Related: [Particle emitters in depth](particle-emitters-in-depth.md) · [VFX tools and workflow](vfx-tools-and-workflow.md) · [VFX performance budgets](vfx-performance-budgets.md) · [AI asset generation](../16-ai-studio-operations/ai-asset-generation.md)
