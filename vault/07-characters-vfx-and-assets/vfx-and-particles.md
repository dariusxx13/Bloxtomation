---
title: VFX and particles
date: 2026-10-24
tags: [vfx, particles, effects, game-feel, performance]
aliases: [Visual effects, Particles, VFX]
summary: The Roblox VFX toolkit (particles, beams, trails, highlights, flipbooks, screen effects), a visual language for effects, and how to keep effects cheap.
audience: [human, agent]
---

# VFX and particles

Visual effects tell the player what happened, how important it was and what to do next. In anime, RNG and fighting games, VFX is also the product: auras and ability effects are what players chase, show off and clip.

## The toolkit

| Instance | Best for | Notes |
|---|---|---|
| `ParticleEmitter` | Sparks, dust, magic, fire, smoke, confetti | Use `Emit(n)` for bursts; flipbook textures for animated particles |
| `Beam` | Lasers, guide paths, lightning, energy links | Between two attachments; scrolling textures |
| `Trail` | Sword swipes, dashes, speed lines | Attach to moving parts |
| `Highlight` | Outlines and fills on models | Great for "interact with this" and rarity glows; limited number visible at once |
| Neon material + bloom | Glowing objects cheaply | Combine with `BloomEffect` |
| `PointLight` / `SpotLight` | Light from effects | Disable shadows on effect lights |
| Screen effects (UI frames, `ColorCorrectionEffect`, `BlurEffect`) | Flashes, vignettes, slow-motion feel | Client only; keep brief |
| Mesh effects | Shockwaves, slashes, domes | Scale and fade meshes with tweens |
| `Explosion` | Physics explosions | Usually replaced by custom visuals plus server-side damage logic |

## A visual language for effects

Decide what colors and shapes mean, and apply them everywhere:

- **Element colors**: fire orange, ice cyan, poison green, lightning yellow, void purple.
- **Rarity colors**: the tier colors from [Rarity tiers and odds](../03-rarity-and-rng/rarity-tiers-and-odds.md).
- **Good vs bad**: healing and buffs rise and sparkle; damage and debuffs fall and pulse red.
- **Shape language**: circles for areas of effect (show the danger zone before it hits), lines for directional attacks, spirals for transformations.

## Building good effects

1. **Start with the gameplay read.** What must the player understand? ("This area will explode in one second.")
2. **Timing in three parts**: anticipation (charge-up), impact (the burst), dissipation (fade).
3. **Layer cheaply**: a core flash + a few large particles + some small sparks + a light flicker reads as rich, without hundreds of particles.
4. **Color and contrast** against the zone's lighting. Effects that work in a bright world can vanish in a dark one; test in every zone.
5. **Scale with importance**: common actions get small effects; ultimates and rare drops get the full stack. See [Game feel and juice](../02-core-loop/game-feel-and-juice.md).

## Auras (show-off effects)

Auras around the character are a whole genre (RNG aura games) and a common cosmetic product.

- Recognizable at a distance and from behind.
- Rarer auras have more layers, more motion, unique sounds and light.
- Offer a "hide others' auras" or "reduce effects" setting; big servers with dozens of auras get expensive.
- Attach aura emitters to `Attachment`s on the character, created and destroyed by the client renderer from replicated state.

## Performance rules

- **Effects run on the client.** The server tells clients what happened; clients play effects. Never create effect instances on the server for replication.
- **Cap rates and lifetimes**. Particle count = rate × lifetime. A rate of 200 with a 5-second lifetime is 1,000 particles from one emitter.
- **Burst with `Emit()`** on disabled emitters instead of enabling and disabling.
- **Pool** reusable effect objects (slashes, impact meshes).
- **Cull by distance**: skip or simplify effects far from the camera.
- **Do not parent particle emitters inside unions** (they will not render); use a normal invisible, non-collidable part or an attachment.
- **Preview in Play mode.** Some particle behaviors only show correctly when the game runs.
- **Low-graphics mode** reduces particle rates for players who choose it, and you can read the player's graphics quality level on the client to scale effects automatically.

## Readability checklist for combat effects

- [ ] The danger zone is visible before damage happens.
- [ ] Your own effects and enemy effects use different colors or shapes.
- [ ] Effects do not hide the character or the enemy during the important moment.
- [ ] Heavy effects (screen flashes) are short and optional.

## For agents

- [ ] Effect language (element, rarity, good vs bad colors) documented and applied.
- [ ] All effects created on clients from server events; none replicated from the server.
- [ ] Every emitter has a capped rate and lifetime; bursts use `Emit()`.
- [ ] Distance culling and a reduce-effects setting exist.
- [ ] Effects checked in every zone's lighting and in Play mode.

Related: [Game feel and juice](../02-core-loop/game-feel-and-juice.md) · [Lighting and atmosphere](../06-world-and-look/lighting-and-atmosphere.md) · [Build budgets](../06-world-and-look/build-budgets.md) · [Anime battlegrounds](../14-genre-playbooks/anime-battlegrounds.md)
