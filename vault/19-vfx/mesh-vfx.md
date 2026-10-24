---
title: Mesh VFX
date: 2026-10-24
tags: [vfx, meshes, blender, slashes, shockwaves, technique]
aliases: [Mesh effects, Slash meshes, Shockwaves, 3D VFX]
summary: Building effects from textured meshes - slashes, shockwave rings, domes, swirls, pillars and ground cracks - from Blender modelling and UV layout to animating them in Roblox with tweens, scrolling textures and pooling.
audience: [human, agent]
---

# Mesh VFX

Particles cannot draw a crisp crescent, a perfect expanding ring or a spinning tornado. **Meshes** can. Most of the striking combat effects in battlegrounds and anime games are a few simple meshes with transparent textures, scaled, rotated and faded over a fraction of a second, layered with particles.

## The core idea

1. Model a simple shape (ring, half-sphere, crescent, cylinder, spiral) in Blender.
2. Give it UVs so a texture can stretch or scroll across it.
3. Import it as a `MeshPart` with a transparent texture (or use `SpecialMesh` with a `TextureId`).
4. At runtime, clone it on the client, place it, then **tween size, transparency, rotation and color** over 0.2-1 s, then return it to a pool.

That is the whole technique. The art is in the shapes, the textures and the timing.

## The essential mesh library

| Mesh | Animation | Used for |
|---|---|---|
| Flat ring (disc with a hole) | Scale from 0.2× to 3× while fading | Shockwaves on the ground, landing impacts, area reveals |
| Vertical ring / torus | Scale and fade, sometimes spin | Air shockwaves, sonic booms, charge pulses |
| Half-sphere (dome) | Scale up fast, fade out slower | Explosions, barriers, domain expansions |
| Crescent / slash arc | Short scale-up along the arc, then fade; or texture scroll along the arc | Sword slashes, claw swipes, wind blades |
| Cylinder (open) | Stretch upward, spin, fade | Pillars of light, beams from the sky, tornado cores |
| Spiral / helix | Spin fast while scaling | Tornadoes, drills, charge swirls |
| Cone | Scale along the length, fade | Directional blasts, shotgun-style cones, breath attacks |
| Low-poly rock chunks | Physics or tweened arcs, then sink and fade | Debris, ground slams |
| Crack decal plane | Fade in, hold, fade out | Ground cracks under heavy hits |
| Star / spike burst | Instant scale-in, fast fade | Hit flashes, critical hits |

Keep meshes very low poly (tens to a few hundred triangles); the texture carries the detail.

## Modelling and UVs in Blender (overview)

- **Rings and domes:** start from a circle or UV sphere, delete the bottom or inner faces, unwrap so that U runs around the circumference and V runs from inside to outside (or bottom to top). A texture that fades along V then fades the edge of the ring.
- **Slashes:** model a thin curved strip (part of a ring), unwrap so U runs along the arc. A texture with a bright leading edge and transparent tail gives the classic anime slash. Some artists animate slashes by authoring several meshes for different phases, or by using one mesh and moving texture offsets.
- **Normals:** effects are often seen from both sides; either duplicate faces with flipped normals or rely on double-sided rendering settings where available.
- **Scale and pivot:** put the pivot at the point the effect grows from (the ring's center, the slash's handle) so scaling in Roblox looks right.
- **Export** as FBX or glTF (or send it straight from Blender with the Roblox Blender plugin), import it, and check the mesh's `RenderFidelity` and collision settings: effect meshes should have `CanCollide`, `CanTouch` and `CanQuery` off and `CastShadow` off.

## Animating meshes in Roblox

| What changes | How |
|---|---|
| Size | `TweenService` on `Size` (MeshPart) or `Scale` (SpecialMesh); use `Quad`/`Quart` Out easing for explosive growth |
| Fade | Tween `Transparency` from about 0.2 to 1; add a slight delay so growth reads before fading |
| Spin | Tween `CFrame` orientation, or update on `RenderStepped` for continuous spin |
| Color shift | Tween `Color` (works best on light, grayscale textures) |
| Texture flow | Use a `Texture` object (with `OffsetStudsU/V`) on part faces, or beams across the mesh for scrolling energy |
| Glow | Neon material for solid glowing meshes; additive look comes from bright textures plus bloom |

**Rule of thumb timings** (60 fps; see [VFX timing and choreography](vfx-timing-and-choreography.md)):

| Effect | Grow | Hold | Fade |
|---|---|---|---|
| Hit flash star | 0.03 s | 0 | 0.1 s |
| Slash arc | 0.05-0.08 s | 0.03 s | 0.15-0.25 s |
| Ground shockwave ring | 0.25-0.4 s (with fade overlapping) | 0 | overlaps growth |
| Explosion dome | 0.15 s | 0.05 s | 0.4 s |
| Pillar of light | 0.2 s | 0.3-1 s | 0.3 s |

## Ground impacts and craters

Heavy hits sell weight by changing the ground:

1. **Shockwave ring** on the ground plane, slightly above it to avoid z-fighting.
2. **Dust burst** particles from a disc emitter at ground level.
3. **Debris:** several small rock parts launched in arcs, or a circle of rock slabs pushed up around the impact and sunk back after a second. Copy the material and color of the surface under the impact (raycast downward first) so rocks match grass, sand or stone. Community crater modules work this way.
4. **Crack decal** under the impact point.
5. **Camera shake** proportional to distance.

Debris should be client-side, unanchored only if physics is needed, with collisions off against characters, and cleaned up within a few seconds. Cap debris per hit (for example 8-16 pieces) and per second globally.

## Pooling

Creating and destroying meshes for every hit causes garbage and hitches. Keep a pool per mesh type:

```lua
--!strict
-- Client-side pool for one effect mesh (sketch)
local Pool = {}
Pool.__index = Pool

function Pool.new(template: BasePart, size: number)
	local self = setmetatable({ template = template, free = {} :: { BasePart } }, Pool)
	for _ = 1, size do
		local part = template:Clone()
		part.Parent = nil
		table.insert(self.free, part)
	end
	return self
end

function Pool.take(self: any): BasePart
	local part = table.remove(self.free) or self.template:Clone()
	part.Transparency = 0
	return part
end

function Pool.give(self: any, part: BasePart)
	part.Parent = nil
	table.insert(self.free, part)
end

return Pool
```

Parent effect parts to a dedicated client folder (for example `workspace.ClientFX`) so they are easy to clear, ignore in raycasts and exclude from collision groups.

## Combining meshes with other effects

A single slash in a polished battlegrounds game is often:

- 1 crescent mesh (the shape),
- 1 trail on the weapon (the motion),
- 1 burst of streak particles at the contact point (the impact),
- 1 hit flash star mesh or particle (the moment),
- 1 short white highlight flash on the victim,
- a camera nudge and a sound.

Each layer is simple. Together they read as one rich effect.

## Mistakes to avoid

- **Collidable effect meshes** that trip players or block projectiles.
- **Shadow-casting effects**: a glowing dome casting a dark shadow looks wrong and costs performance.
- **Meshes that intersect the ground** and flicker; lift them a little.
- **Huge transparent meshes** close to the camera: fill-rate heavy, especially on mobile.
- **Server-side meshes** for cosmetic effects: they replicate late and cost bandwidth.

## For agents

- [ ] Effect meshes have collisions, touch, query and shadows off.
- [ ] Pivots sit where the effect grows from.
- [ ] Effect meshes are pooled and parented to a client-only folder.
- [ ] Debris matches the ground material and is capped per hit and per second.

Sources: [Roblox Blender plugin](https://create.roblox.com/docs/art/modeling/roblox-blender-plugin) · [Export requirements](https://create.roblox.com/docs/art/modeling/export-requirements) · [TweenService](https://create.roblox.com/docs/reference/engine/classes/TweenService) · [Textures and decals](https://create.roblox.com/docs/parts/textures-decals)

Related: [Combat and anime VFX](combat-and-anime-vfx.md) · [VFX architecture and replication](vfx-architecture-and-replication.md) · [VFX recipes](vfx-recipes.md) · [Asset pipeline](../07-characters-vfx-and-assets/asset-pipeline.md)
