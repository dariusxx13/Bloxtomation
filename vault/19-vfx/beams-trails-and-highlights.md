---
title: Beams, trails and highlights
date: 2026-10-24
tags: [vfx, beams, trails, highlights, technique]
aliases: [Beam effects, Trail effects, Lightning, Outlines]
summary: How to get the most out of Beam, Trail and Highlight - curved and scrolling beams, lightning, slashes and dashes with trails, footprints, outlines and silhouettes - with the properties that matter and the common traps.
audience: [human, agent]
---

# Beams, trails and highlights

Particles are clouds of points. Beams, trails and highlights draw **shapes**: lines, ribbons and outlines. They are cheap, crisp and readable at a distance, which makes them the backbone of combat effects, guidance arrows and interaction hints.

## Beams

A `Beam` draws a textured ribbon between `Attachment0` and `Attachment1`. If either attachment is missing, nothing renders.

### Properties that shape a beam

| Property | Effect |
|---|---|
| `Width0`, `Width1` | Width in studs at each end. A wide start and zero end makes a spike or a tapering slash |
| `CurveSize0`, `CurveSize1` | Pull the beam into a cubic Bézier curve. Each control point sits that many studs along the attachment's X axis (positive at the start, negative at the end). Rotate the attachments to bend the curve |
| `Segments` | Straight pieces used to draw the curve (default 10). More for smooth arcs, fewer (3-6) for jagged electricity |
| `FaceCamera` | Turns the ribbon to face the camera so it never disappears edge-on. Needed for lasers and lightning |
| `Texture`, `TextureMode`, `TextureLength` | `Wrap`/`Static`: repeats every `TextureLength` studs. `Stretch`: repeats `TextureLength` times across the whole beam |
| `TextureSpeed` | Texture cycles per second; positive values flow from Attachment0 to Attachment1 |
| `SetTextureOffset(offset)` | Sets the texture animation phase; pass 0 to restart a flow cleanly |
| `Color`, `Transparency` | Sequences along the beam's length, not over time |
| `LightEmission`, `LightInfluence`, `Brightness` | Same meaning as particles: additive glow, sensitivity to world light, brightness of unlit beams |
| `ZOffset` | Render order against other transparent effects |

### What beams do best

- **Lasers and energy streams.** Two beams on the same attachments: a thin, bright, additive core and a wide, faint glow. Animate `TextureSpeed` for flow, flicker `Transparency` slightly.
- **Lightning.** Several attachments along a path with small random offsets, a beam between each pair, low segment counts, re-randomised every 0.05-0.1 s for a short time, then faded. Add a `PointLight` flash at the target.
- **Waterfalls and shields.** Wide beams with scrolling, tiling textures; static, in the map.
- **Guidance.** A beam from the player to an objective, texture of arrows scrolling toward the target. The template's onboarding guide uses this pattern ([Onboarding patterns](../01-first-five-minutes/onboarding-patterns.md)).
- **Telegraphs.** A beam marking where an attack will travel, appearing half a second before damage.

### Animating beams over time

Beams have no lifetime of their own. You animate them by tweening their numeric properties (`Width0`, `Width1`, `CurveSize0`, `CurveSize1`, `TextureSpeed`) or by moving their attachments. Sequence properties (`Color`, `Transparency`) cannot be tweened directly; rebuild the sequence each frame for short fades or fade a `NumberValue` and apply it.

## Trails

A `Trail` creates a ribbon behind two attachments as they move. The distance between the attachments sets the trail's width.

| Property | Effect |
|---|---|
| `Lifetime` | How long each segment lasts. Short (0.1-0.3 s) for snappy sword swings, long (1-2 s) for flowing magic |
| `WidthScale` | Sequence (0-1) that scales width over the trail's life; taper to 0 for a sharp tail |
| `MinLength` | Minimum movement before a new segment is created; raise it to cut segment count on slow movement |
| `MaxLength` | Maximum trail length in studs (0 = unlimited, segments expire by lifetime) |
| `TextureMode` | `Stretch` stretches the texture with the trail; `Wrap` tiles it in place; `Static` "stamps" it where drawn |
| `FaceCamera` | Keep visible from every angle |
| `Enabled` and `Clear()` | Turn on just for the active frames of a swing, then clear to avoid ghost streaks when a weapon teleports |

### What trails do best

- **Weapon swings.** Attachments at the base and tip of the blade, enabled only during the swing's active frames. A bright additive inner trail plus a softer wider outer trail.
- **Dashes and movement abilities.** Attachments on the torso or feet; enable for the dash only.
- **Projectiles.** A tapering trail behind a fireball reads direction better than particles alone.
- **Footprints and tire marks.** `TextureMode` Static with a footprint texture and a long lifetime.
- **Speed and luck boosts.** Subtle trails behind a running character signal "you are fast now".

### Common trail traps

- **Teleport streaks.** If attachments jump (a respawn, a teleport, a weapon unequipped and re-equipped), the trail draws a line across the map. Disable and `Clear()` before moving.
- **Too many segments.** Very short lifetimes with high frame rates are fine; long lifetimes on fast objects create many segments. Use `MinLength` and `MaxLength`.
- **Width from scale.** Trails do not scale with the character automatically; place attachments relative to the rig size.

## Highlights

A `Highlight` draws an outline (`OutlineColor`, `OutlineTransparency`) and a fill (`FillColor`, `FillTransparency`) on a model or part. `DepthMode` chooses between `AlwaysOnTop` (visible through walls) and `Occluded`.

### Uses

| Use | Settings |
|---|---|
| "You can interact with this" | White outline, fill fully transparent, `Occluded`; enable when the player is close or hovering |
| Rarity glow on a dropped item | Rarity color outline, fill transparency 0.8 |
| Teammates through walls | Team color outline, `AlwaysOnTop` |
| Hit flash | White fill at transparency 0.2 for 2-4 frames, then back to 1 |
| Silhouette for impact frames | Black fill at 0, outline off, `AlwaysOnTop` (see [VFX timing and choreography](vfx-timing-and-choreography.md)) |
| Selection in build modes | Accent outline on the object under the cursor |

### Performance facts (2026-10-24)

- Up to **255** highlights render at once on a client; more are silently ignored. A disabled highlight still uses a slot, so destroy highlights you will not reuse.
- Adding or removing highlights can trigger a geometry rebuild; changing properties on an existing highlight is cheap. **Reuse** one highlight per purpose and move its `Adornee` instead of creating new ones.
- The first visible highlight carries most of the cost (up to about 1 ms of GPU time on mobile). Off-screen or fully transparent highlights cost nothing.
- Avoid nesting highlighted objects inside other highlighted objects; draw order can produce artefacts.

## Choosing between them

| Need | Pick |
|---|---|
| Line between two fixed or moving points | Beam |
| Record of where something went | Trail |
| Draw attention to an existing object | Highlight |
| Area or volume | Particles or mesh |

## For agents

- [ ] Beams that must be seen from any angle have `FaceCamera` on.
- [ ] Trails are enabled only during the motion that should leave a trail, and cleared before teleports.
- [ ] Highlights are reused by moving `Adornee`; the effect never creates and destroys highlights every hit.
- [ ] Telegraph beams appear before damage, never with it.

Sources: [Beams](https://create.roblox.com/docs/effects/beams) · [Trails](https://create.roblox.com/docs/effects/trails) · [Highlighting](https://create.roblox.com/docs/effects/highlighting) · [Beam API](https://create.roblox.com/docs/reference/engine/classes/Beam) · [Trail API](https://create.roblox.com/docs/reference/engine/classes/Trail)

Related: [VFX toolkit reference](vfx-toolkit-reference.md) · [Combat and anime VFX](combat-and-anime-vfx.md) · [Mesh VFX](mesh-vfx.md) · [VFX recipes](vfx-recipes.md)
