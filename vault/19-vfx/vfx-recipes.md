---
title: VFX recipes
date: 2026-10-24
tags: [vfx, recipes, particles, beams, meshes, cookbook]
aliases: [Effect recipes, VFX cookbook, Particle presets]
summary: Twenty-four ready-to-build effect recipes with layers, key property values and timing - from coin pickups and hit sparks to fireballs, lightning, portals, auras, level-ups and legendary reveals.
audience: [human, agent]
---

# VFX recipes

Each recipe lists its **layers** (build each as its own emitter, mesh or beam), the **key settings** that define the look, and the **timing**. Values are starting points for a typical Roblox scale (a character is about 5 studs tall) and must be tuned by eye in Play mode. Unless noted, emitters are disabled and fired with `Emit(n)`, textures are grayscale and tinted by `Color`, and everything runs on the client.

Notation: `size 1→3` means a Size sequence from 1 at birth to 3 at death; `T 0.2→1` is a Transparency sequence; `life 0.3-0.6` is a Lifetime range.

---

## Pickups and rewards

### 1. Coin pickup

- **Sparkle burst:** star texture, `Emit(8)`, speed 6-10, drag 4, size 0.6→0, life 0.3-0.5, `LightEmission` 1, gold color.
- **Ring pop:** flat ring mesh at the coin, scale 0.5→2.5 over 0.2 s, transparency 0.3→1.
- **UI:** coin icon flies to the counter (see [Reward, UI and hatch VFX](reward-ui-and-hatch-vfx.md)), counter bounce.
- **Sound:** short bright tick, pitch +3% per consecutive pickup, reset after 1 s.

### 2. Gem or premium pickup

As the coin, plus a short vertical beam (width 0.8→0, height 6 studs) fading over 0.4 s and a cyan or purple palette. Premium currency should always look more special than soft currency.

### 3. Level-up

- **Pillar:** open cylinder mesh around the character, height 0→12 over 0.25 s, transparency 0.2→1 over 0.8 s, gold or accent color, neon.
- **Rising motes:** dot texture, rate 40 for 0.6 s (then disable), speed 4-8 upward, acceleration (0, 6, 0), life 0.8-1.2.
- **Ground ring:** flat ring scale 1→6, transparency 0.2→1 over 0.5 s.
- **Screen:** banner "LEVEL 12!" with scale overshoot; brief bloom spike.
- **Timing:** total 1.2 s; the banner holds 1.5 s.

### 4. Confetti celebration

- Three emitters (three colors), rectangle texture, `Emit(25)` each, spread 35°, speed 20-35, drag 1.5, acceleration (0, -15, 0), `RotSpeed` -360-360, `Orientation` FacingCamera, life 2-3, `LightInfluence` 1.
- Fire from two points left and right of the camera target for a "cannon" look.

### 5. Legendary reveal (hatch)

- **Anticipation (2 s):** wobble with growing amplitude, background dims (`BlurEffect` size 0→12, saturation -0.3), converging particles (`ShapeInOut` Inward) in the rarity color, rising sound.
- **Burst:** white flash (GUI frame transparency 0→1 over 0.25 s), egg shards (6-10 images or meshes flung outward), confetti in rarity colors.
- **Reveal:** item card scale 0.3→1.08→1, rotating rays behind it, shine sweep every 2 s, bloom spike.
- **Social:** server banner, sound sting heard by nearby players.

---

## Combat

### 6. Hit spark (M1)

- **Streaks:** thin streak texture, `Orientation` VelocityParallel, `Emit(10)`, speed 35-60, drag 5, acceleration (0, -25, 0), size 0.3→0, life 0.15-0.3, `LightEmission` 1, white→yellow.
- **Flash:** soft glow, `Emit(1)`, size 3→4, T 0.1→1, life 0.08.
- **Victim:** reused white `Highlight` fill for 3 frames.
- **Timing:** everything under 0.3 s.

### 7. Heavy punch impact

As the hit spark, plus:

- **Air ring:** vertical ring mesh facing the attack direction, scale 0.5→4 over 0.15 s, fade over 0.2 s.
- **Dust:** disc emitter at the victim's feet, `Emit(12)`, speed 8-14, drag 3, size 1→4, T 0.4→1, `LightInfluence` 1.
- **Hitstop:** 6-8 frames; **camera kick** toward the hit direction.

### 8. Sword slash

- **Crescent mesh** along the swing plane, scale 0.6→1.1 over 0.06 s, transparency 0.1→1 over 0.2 s.
- **Trails:** core (white, life 0.12, width tapered) and glow (color, life 0.2, wider).
- **Tip sparks:** `Emit(6)` at the end of the arc.
- **Timing:** enable trails on the "SwingStart" marker, disable on "SwingEnd".

### 9. Dash afterimages

- On "DashStart": every 0.05 s for 0.2 s, clone the visible character parts (or a pre-built silhouette model), anchor them, set color to the move color, transparency 0.4→1 over 0.3 s, then return to the pool.
- **Ground dust** at the start; **wind streaks** (streak particles, VelocityParallel) along the path.

### 10. Fireball projectile

- **Core:** looping flame flipbook (4×4), `LockedToPart`, rate 25, size 2.5→1.5, life 0.3, `LightEmission` 1, white→orange.
- **Trail:** 0.3 s life, orange→red, tapered.
- **Wake:** smoke puffs, rate 10, size 1→3, T 0.5→1, life 0.6-1, `LightEmission` 0, `LightInfluence` 1.
- **Light:** `PointLight` orange, range 12, brightness 3.
- **Impact:** recipe 12.

### 11. Ice shard volley

- **Shard projectiles:** small crystal meshes (glass or neon light blue), trail with white→cyan.
- **Impact:** shard texture burst (`Emit(10)`, speed 15-25, gravity), frost ring decal on the ground fading over 2 s, mist puff, cracking sound.

### 12. Explosion

- **Flash:** glow `Emit(1)`, size 8→12, T 0→1, life 0.1.
- **Fireball:** explosion flipbook (4×4, `OneShot`), `Emit(4)`, size 6-9, life 0.5-0.7, rotation 0-360.
- **Sparks:** `Emit(20)`, VelocityParallel, speed 40-70, drag 3, gravity.
- **Smoke:** `Emit(8)`, size 5→12, T 0.3→1, life 1.5-2.5, `LightInfluence` 1, slight upward acceleration.
- **Shockwave:** ground ring scale 1→14 over 0.35 s.
- **Light:** brightness 6→0 over 0.35 s, range 30.
- **Camera:** shake scaled by distance (strong within 20 studs, none beyond 80).

### 13. Lightning strike

- **Telegraph:** ground circle decal glowing for 0.5 s.
- **Bolt:** 6-8 attachments from sky to ground with random horizontal offsets; beams between them, `Segments` 3, `FaceCamera`, white core + blue glow; re-randomise offsets twice over 0.15 s, then fade.
- **Impact:** flash, sparks, scorch decal, light flicker (3 pulses).
- **Sound:** crack at strike, thunder rumble delayed by distance.

### 14. Energy beam

- **Charge (0.5 s):** inward sphere emitter at the hand, glow growth, rising whine.
- **Beam:** core beam (width 0.6, white, `TextureSpeed` 3) + glow beam (width 2.5, color, transparency 0.4) between hand and target.
- **End:** continuous sparks and a light at the hit point.
- **Close:** widen both beams ×1.5 while fading over 0.15 s.

### 15. Ground slam

- **Wind-up:** dust gathering (inward disc emitter), character rises.
- **Impact:** ground ring, crater rocks matching the floor (raycast for material), dust burst, crack decal, 8-10 frames hitstop, heavy shake within range.
- **Follow-through:** hanging dust (low speed, long life), rocks sink and fade after 2 s.

### 16. Shield / block

- Dome mesh (half-sphere) around the player, transparency 0.6, fresnel-like texture brighter at edges, slow rotation.
- On blocked hit: dome flash (transparency to 0.2 for 2 frames), hexagon sparkle burst at the contact point.
- On break: dome shatters into shard particles, a glass-break sound.

### 17. Aura (tier 3)

- **Body wisps:** wispy texture, `LockedToPart`, rate 12, size 1.5→2.5, T 0.6→1, upward speed 2-4, life 0.6-1, `LightEmission` 1.
- **Motes:** dot texture, rate 6, slow rising, life 1.5.
- **Ground ring:** subtle rotating ring under the feet, transparency 0.7.
- **Light:** `PointLight` brightness 0.8, range 8.
- **Scaling:** others' auras drop the motes and light beyond 60 studs.

### 18. Transformation

- **Beat (1.5 s):** camera zoom on the player (own camera only), saturation down, converging particles, rising tone.
- **Release:** flash, outward burst, ring, the new aura appears, music sting.
- **Lock input and grant invulnerability** for the beat.

---

## World

### 19. Portal

- Spinning ring mesh with scrolling texture (rotation one turn per 3 s), inward particles from a disc emitter with `ShapeInOut` Inward, center glow, `PointLight`, ambient hum.
- When a player is near: increase rate and light brightness to invite interaction.

### 20. Campfire

- Looping flame flipbook, rate 8, size 2→1, life 0.6-0.9; embers (dot, rate 5, upward acceleration, life 1.5-2.5, flicker transparency); smoke (rate 3, `LightInfluence` 1); `PointLight` with brightness and range tweened randomly every 0.1-0.2 s by ±10%.

### 21. Waterfall

- Wide beam with tileable water texture, `TextureSpeed` 1.5-2.5, transparency 0.2.
- Mist at the base: soft puffs, rate 10, size 4→8, T 0.6→1, `LightInfluence` 1.
- Foam ring: flat ring mesh pulsing slowly.

### 22. Rain around the camera

- A client part following the camera 25 studs above it, 60×60 studs; rain emitter (recipe in [Environment and ambient VFX](environment-and-ambient-vfx.md)), rate near the mobile limit, life tuned so drops vanish at ground level.

### 23. Rare drop beacon

- Vertical beam of the rarity color from the item up 40 studs, width 1→0, slow texture scroll upward; sparkles around the item; visible from far away so players can find drops.

### 24. Zone unlock

- Gate dissolves: transparency 0→1 over 0.6 s with sparkle particles rising from its surface (`ShapeStyle` Surface on the gate part), rumble sound, a beam guiding into the new zone, banner "Desert unlocked! x4 coins".

---

## Using these recipes with the template

The template's effects (hit feedback, hatch reveal, gates, guide beam) are deliberately minimal. Upgrade them in a game copy by adding effect modules for these recipes to the client and triggering them from existing events: `HitEffect` broadcasts for hits, hatch results for reveals, zone unlock results for gates.

## For agents

- [ ] Every recipe used is tuned in Play mode in the zone where it appears.
- [ ] Recipes keep their tier budgets ([Combat and anime VFX](combat-and-anime-vfx.md)).
- [ ] All textures and meshes come from the shared library or the asset index.

Related: [Particle emitters in depth](particle-emitters-in-depth.md) · [Mesh VFX](mesh-vfx.md) · [Beams, trails and highlights](beams-trails-and-highlights.md) · [VFX timing and choreography](vfx-timing-and-choreography.md)
