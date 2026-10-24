---
title: Combat and anime VFX
date: 2026-10-24
tags: [vfx, combat, anime, battlegrounds, abilities, technique]
aliases: [Anime VFX, Ability effects, Battlegrounds VFX, Skill effects]
summary: How the effects in battlegrounds, anime fighting and ability games are built - M1 hits, slashes, dashes, projectiles, beams, auras, transformations, domains and ultimates - with layering recipes, readability rules and per-move budgets.
audience: [human, agent]
---

# Combat and anime VFX

In anime-inspired games the effects are not decoration; they are the product. Players choose characters, grind for skills and record clips because of how moves **look and feel**. The best-performing battlegrounds games combine readable, punchy everyday hits with a few spectacular ultimates. This note breaks down each kind of combat effect into layers you can build from the rest of this section.

## The moveset effect hierarchy

| Move type | Frequency | Effect budget | Goal |
|---|---|---|---|
| Basic attack (M1) chain | Many per second | Tiny: 1-3 layers, under 0.3 s | Rhythm and confirmation; never clutter |
| Dash / evade | Often | Small: trail + dust | Show direction and invulnerability frames |
| Skill (cooldown 5-20 s) | Every few seconds | Medium: 3-6 layers, 0.5-1.5 s | Recognisable silhouette; show hit area |
| Heavy / finisher | Occasionally | Medium-large, hitstop | Weight and punctuation |
| Ultimate / awakening | Rarely (meter or long cooldown) | Large: 6-12 layers, cinematic | Spectacle, clip-worthy, announces itself to the server |
| Passive aura | Always on | Small and subtle by default | Identity; must not tank performance in a full server |

**Rule of thumb:** spend about 70% of your VFX effort on the 5% of moments that are ultimates and finishers, and keep basic hits lean. A server of 20 players spamming M1 chains is where performance dies.

## Building each effect

### Basic hits (M1 chain)

- **Swing trail** on the weapon or limb, enabled only for the swing.
- **Contact spark:** `Emit(6-12)` streak particles with velocity-parallel orientation at the hit point.
- **Victim flash:** reused `Highlight` fill white for 2-3 frames.
- Last hit of the chain: add a small shockwave ring, a 4-6 frame hitstop and a knockback dust burst.

### Slashes

- Crescent mesh scaled and faded along the swing ([Mesh VFX](mesh-vfx.md)), angled to match the animation.
- Two trails: thin bright core, wider soft glow.
- Spark burst at the far end of the arc.
- For "flying slash" projectiles, move the crescent forward with a trail behind it and detonate it on contact.

### Dashes and teleports

- Afterimage: clone the character's parts as unanchored-free, non-collidable, translucent copies tinted with the move color, fade over 0.2-0.4 s. Cap at 3-5 afterimages.
- Ground dust at the start, wind lines (beam or streak particles) along the path.
- Teleport: implosion particles at the origin (`ShapeInOut` Inward), flash and outward burst at the destination, same color.

### Projectiles

- Core: a glowing sphere (neon mesh or flipbook particle) with a `PointLight`.
- Body: a trail behind it plus a low-rate particle wake.
- Impact: explosion stack (flash, fireball flipbook, sparks, smoke, ring, light spike, shake by distance).
- The **server** owns the projectile's path and hit check; clients draw it from the start position, direction, speed and start time the server sends, so it looks smooth without the server streaming positions. See [VFX architecture and replication](vfx-architecture-and-replication.md).

### Beams and lasers

- Charge-up: converging particles, glow growth, rising pitch (0.3-0.8 s).
- Beam: two `Beam` objects (core and glow) between the hand and the end point, `FaceCamera` on, scrolling texture.
- End point: continuous spark emitter and a scorch decal.
- Shut-off: widen the beam quickly while fading for a satisfying end.

### Ground slams and stomps

- Anticipation: character rises or crouches; dust gathers.
- Impact: ground shockwave ring, crater rocks matching the floor material, dust disc burst, crack decal, heavy camera shake within range, 6-10 frames of hitstop.
- Follow-through: dust hanging in the air, small debris settling.

### Auras

- Built from 2-4 layers attached to the character: a body glow (low-rate wispy particles, `LockedToPart`), rising motes, an optional ground ring, and a subtle `PointLight`.
- Tier escalation: rarer auras add motion layers, color shifts, unique sounds and finally unique meshes.
- Hide or reduce other players' auras at a distance, and offer a setting to hide them entirely. A full server of max-tier auras must still run on a phone.

### Transformations and awakenings

- 1-2 s cinematic beat: camera moves to frame the character (only for the transforming player, or briefly for nearby players), screen desaturates, energy converges, flash, then the new form appears with a burst and a persistent aura.
- Lock the transforming player's input during the beat and grant invulnerability for its duration, or opponents will punish a mandatory animation.

### Domains, zones and ultimates

- An expanding dome or ring defines the area clearly (players must know whether they are inside).
- Inside the area, change the environment for affected players: `Atmosphere` density and color, a ground texture or decal, ambient particles, a music sting.
- Short cutscene camera for the caster only, or a brief shared one under 2 s; never take control of other players' cameras for long.
- Announce in chat or with a banner so the whole server knows something big happened (social proof and clips).

## Readability rules for combat

1. **Telegraph before damage.** Area attacks show their zone (a ground decal, a ring, a beam path) before they hit. Players accept losing to what they could see.
2. **Silhouette first.** Each skill should be recognisable by shape and color alone, even in a screenshot.
3. **Own vs enemy.** Use subtly different colors or outlines for allies and enemies in team modes.
4. **Never cover the target.** Effects that bury the opponent in particles hide the information players need (are they blocking? stunned?).
5. **Show state.** Stun, block, counter-ready, armor and invulnerability each need a distinct, consistent indicator.
6. **Respect distance.** Spectacle up close, a simplified version far away (distance culling).

## Color and style

- Each character, element or skill family gets a palette of 2-3 colors: a bright core (often near white), a saturated main color, and a dark accent for contrast.
- Anime style favours bold shapes, hard-edged hand-drawn textures, strong timing and sudden changes; realism favours soft simulation flipbooks. Pick one style per game.
- Black and white accents (ink lines, impact frames) feel anime even with simple particles.
- Avoid copying a specific anime's signature effects, colors and names together; take inspiration from the style, not the IP. See [Anime IP and legal](../20-anime-games/anime-ip-and-legal.md).

## Budgets per move (Rule of thumb, mid-range phone)

| Move | Max live particles (local view) | Meshes | Lights | Post-processing |
|---|---|---|---|---|
| M1 hit | 30 | 0-1 | 0 | none |
| Skill | 120 | 1-3 | 1 | optional tint |
| Ultimate | 300 for under 2 s | 3-8 | 1-2 | color correction, bloom spike |
| Aura (per player) | 40 | 0-1 | 0-1 | none |

Measure on a real device: see [VFX performance budgets](vfx-performance-budgets.md).

## For agents

- [ ] Every move has a tier and an effect budget; basic hits stay lean.
- [ ] Area attacks telegraph before damage.
- [ ] Effects spawn from animation markers on every client; the server only validates and tells clients what to play.
- [ ] Auras and ultimates scale down with distance and respect the reduce-effects setting.
- [ ] Each skill is recognisable by silhouette and color in a still screenshot.

Related: [VFX timing and choreography](vfx-timing-and-choreography.md) · [Mesh VFX](mesh-vfx.md) · [Anime battlegrounds](../14-genre-playbooks/anime-battlegrounds.md) · [Combat systems and hitboxes](../13-building-it-right/combat-systems-and-hitboxes.md) · [VFX recipes](vfx-recipes.md)
