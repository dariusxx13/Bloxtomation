---
title: Particle emitters in depth
date: 2026-10-24
tags: [vfx, particles, particleemitter, reference, technique]
aliases: [ParticleEmitter properties, Particle settings, Emitter cookbook]
summary: Every ParticleEmitter property explained by what it does to the look of an effect, with the combinations that produce smoke, sparks, fire, magic, rain and bursts, and the mistakes that make particles look cheap.
audience: [human, agent]
---

# Particle emitters in depth

The `ParticleEmitter` is the workhorse of Roblox VFX. It has about forty properties, and most beginners touch five of them. This note walks through all of them in the order you should think about them: **where** particles come from, **how** they move, **how** they look, and **how** they change over their life. Engine limits are in [VFX toolkit reference](vfx-toolkit-reference.md).

## 1. Where particles come from

| Property | What it does | How to use it |
|---|---|---|
| Parent | Under an `Attachment`, particles spawn at a point. Under a `BasePart`, they spawn inside the part's volume or on its surface | Attachments for precise sources (a hand, a muzzle). Parts for areas (a pool, a ring) |
| `EmissionDirection` | Which face of the parent part particles fly out of (`Top`, `Bottom`, `Front`...) | With attachments, rotate the attachment instead |
| `Shape` | `Box`, `Sphere`, `Cylinder` or `Disc` emission volume (part parents only) | Disc for ground rings, sphere for explosions, cylinder for pillars |
| `ShapeStyle` | `Volume` (anywhere inside) or `Surface` (only on the outside) | Surface + sphere = a shell of sparks; surface + disc edge = a ring |
| `ShapeInOut` | `Outward`, `Inward` or `InAndOut` | Inward makes particles converge: the classic charge-up |
| `ShapePartial` | Shrinks a cylinder's radius on one side, a disc's inner radius, or a sphere's angle | Disc with a high partial value = a thin ring; sphere with 0.5 = a hemisphere dome |
| `SpreadAngle` | Random angle around the emission direction on X and Y | `(0, 0)` = a laser-straight stream; `(180, 180)` = everywhere |
| `VelocitySpread` | Extra random offset, in degrees, from the emitter direction | Fine variation on top of `SpreadAngle` |
| `Rate` | Particles per second while `Enabled` | Keep low; prefer bigger particles to more particles |
| `Enabled` | Continuous emission on or off; existing particles finish their life | Off for burst emitters; trigger with `Emit(n)` |
| `Emit(n)` (method) | Spawns `n` particles instantly | The standard way to do bursts |
| `Clear()` (method) | Removes all live particles | Instant cleanup when an effect is cancelled |

**Rule of thumb:** a burst effect is a disabled emitter plus `Emit(n)`. A continuous effect (a torch, an aura) is an enabled emitter with a modest rate. Toggling `Enabled` on and off to make bursts gives uneven results because emission is time-based.

## 2. How particles move

| Property | What it does | Feel |
|---|---|---|
| `Speed` (range) | Initial speed in studs per second, chosen per particle | A wide range (2-15) looks organic; a narrow range looks mechanical |
| `Acceleration` | Constant change in velocity per second (X, Y, Z) | Negative Y = gravity for sparks and debris; positive Y = rising smoke and embers |
| `Drag` | Seconds for a particle to lose half its speed (exponential) | High speed + drag = a fast burst that slows and hangs: the most satisfying explosion shape |
| `VelocityInheritance` | Fraction of the parent's velocity added at spawn (0-1) | Lets exhaust and dust follow a moving object naturally |
| `LockedToPart` | Live particles move rigidly with the parent | Auras and shields that must stay on a moving character |
| `WindAffectsDrag` | Particles follow global wind when drag is above 0 | Leaves, snow, smoke drifting with the weather |
| `Rotation` (range) | Starting rotation of each particle in degrees | Randomise 0-360 so identical textures do not line up |
| `RotSpeed` (range) | Spin in degrees per second, negative for counter-clockwise | Small random spin brings smoke and debris to life |
| `TimeScale` | 0 to 1 playback speed of the whole emitter; 0 freezes it | Slow motion, and **freezing particles during hitstop** |

The most useful motion combination in all of VFX is **fast start, strong drag**. Set `Speed` to 30-60 and `Drag` to 2-6: particles explode outward, decelerate and linger. Real explosions, hit sparks and magic bursts all have this shape. Constant-speed particles look like a screensaver.

## 3. How particles look

| Property | What it does | Notes |
|---|---|---|
| `Texture` | The image each particle shows | Grayscale on transparent background, so `Color` controls the tint (see [Textures and flipbooks](textures-and-flipbooks.md)) |
| `Color` (constant or `ColorSequence`) | Tint over the particle's life | Hot-to-cold sequences (white → yellow → orange → dark) read as fire |
| `LightEmission` | 0 = normal blending, 1 = additive blending | Additive makes particles glow and hides dark texture regions; use it for energy, fire, magic. Use 0 for smoke and dust |
| `LightInfluence` | 0-1, how much world lighting tints particles | 0 for glowing effects that should look the same at night; 1 for smoke, dust, rain |
| `Brightness` | Scales emitted light when `LightInfluence` is 0 | Push above 1 for hot cores that bloom |
| `Orientation` | `FacingCamera`, `FacingCameraWorldUp`, `VelocityParallel`, `VelocityPerpendicular` | VelocityParallel turns sparks into streaks; FacingCameraWorldUp keeps flames upright |
| `Squash` (constant or sequence) | Non-uniform scaling; positive = taller and thinner, negative = wider and flatter | Streaks, raindrops, speed lines, ground-hugging shockwaves |
| `ZOffset` | Moves particles toward or away from the camera without changing their screen size | Layer a core in front of smoke, or push particles in front of the character so they are not hidden |
| `Flipbook*` | Animated textures (layout, mode, framerate, random start, blending between frames) | See [Textures and flipbooks](textures-and-flipbooks.md) |

## 4. How particles change over life

`Size`, `Transparency`, `Color` and `Squash` can all be sequences over the particle's lifetime, and `Size` and `Transparency` sequences can have an **envelope**: a random range around each keypoint.

| Curve | Good default |
|---|---|
| Transparency | Fade in over the first 5-10% of life, hold, fade out over the last 30-50%. Never pop in or out at full opacity |
| Size, smoke | Start small, grow 2-4× |
| Size, sparks | Start at full size, shrink to 0 |
| Size, impact flash | Grow very fast in the first 10%, then fade (not shrink) |
| Color, fire | White core → yellow → orange → deep red or grey at the end |
| Squash, falling debris | Slight positive squash to suggest motion blur |

`Lifetime` is a range; randomising it (for example 0.4-0.9 s) is one of the cheapest ways to make an effect feel natural, because particles stop dying in lockstep.

## Recipes by look

Values are starting points to tune by eye. Combine several emitters for anything important (see [Recipes](vfx-recipes.md)).

| Look | Key settings |
|---|---|
| Rising smoke | Soft round texture, `LightEmission` 0, `LightInfluence` 1, size 2 → 8, transparency 0.6 → 1, speed 2-4, acceleration (0, 2, 0), rotspeed -20 to 20, lifetime 2-4 |
| Hit sparks | Small streak texture, `Orientation` VelocityParallel, speed 30-60, drag 4, acceleration (0, -30, 0), lifetime 0.2-0.4, `LightEmission` 1, `Emit(12)` |
| Ground dust burst | Soft texture, disc shape, `ShapeStyle` Surface, `ShapeInOut` Outward, speed 8-15, drag 3, size 1 → 4, transparency 0.4 → 1, `LightInfluence` 1 |
| Magic motes | Tiny glow dot, rate 6-12, speed 0.5-1, `Acceleration` (0, 0.5, 0), lifetime 2-4, `LightEmission` 1, transparency flicker sequence |
| Charge-up | Sphere shape, surface style, `ShapeInOut` Inward, speed 6-10, lifetime 0.5, size shrinking to 0 |
| Rain | Default or thin texture, emitter part above the area, `EmissionDirection` Bottom, `Squash` about 3 (negative if `Orientation` is VelocityParallel), speed 50-80, darker color, `LightInfluence` 1 |
| Confetti | Small rectangles, several colors via multiple emitters, speed 20-35, drag 1.5, acceleration (0, -15, 0), rotspeed -360 to 360, lifetime 2-3 |

## Mistakes that make particles look cheap

1. **One emitter for everything.** Real effects are layers: a bright core, a body, secondary debris, a lingering trace. Three small emitters beat one large one.
2. **No fade.** Particles that pop into existence at full opacity and vanish at full opacity look like a 2008 game.
3. **Uniform everything.** Same size, same speed, same lifetime, same rotation. Randomise ranges.
4. **Additive smoke.** Smoke with `LightEmission` 1 glows like a lamp and disappears on bright backgrounds.
5. **Huge particle counts to fake volume.** Use bigger particles with soft textures; fill rate, not count, is usually the real cost (see [VFX performance budgets](vfx-performance-budgets.md)).
6. **Ignoring `ZOffset`.** Effects that sink into the character or the ground lose half their impact.
7. **Testing only in edit mode.** Several particle behaviors only show correctly in Play mode.

## For agents

- [ ] Every burst emitter is disabled and fired with `Emit(n)`.
- [ ] Every emitter fades in and out through its `Transparency` sequence.
- [ ] Speed, size, lifetime and rotation use ranges, not single values.
- [ ] Glowing effects use `LightEmission` 1 and `LightInfluence` 0; smoke and dust use the reverse.
- [ ] Each important effect has at least three layers (core, body, secondary).

Sources: [Particle emitters](https://create.roblox.com/docs/effects/particle-emitters) · [ParticleEmitter API](https://create.roblox.com/docs/reference/engine/classes/ParticleEmitter) · [Custom particle effects tutorial](https://create.roblox.com/docs/tutorials/use-case-tutorials/vfx/custom-particle-effects)

Related: [VFX toolkit reference](vfx-toolkit-reference.md) · [Textures and flipbooks](textures-and-flipbooks.md) · [VFX recipes](vfx-recipes.md) · [VFX timing and choreography](vfx-timing-and-choreography.md)
