---
title: Characters, NPCs and pets
date: 2026-10-24
tags: [characters, npcs, pets, avatars, ai]
aliases: [NPC design, Pets, Avatars]
summary: How to handle player avatars, design NPCs and enemies, and build pets and companions that perform well and sell.
audience: [human, agent]
---

# Characters, NPCs and pets

Characters are what players look at most: their own avatar, the enemies they fight, the pets that follow them. Each needs different handling.

## Player avatars

Roblox players care deeply about their avatars. Most games should respect them.

- **Default: use the player's avatar.** Players spend real money on avatar items and like seeing them in games.
- **R15 vs R6.** R15 is the modern rig (15 parts, smoother animation, layered clothing). R6 is the classic 6-part rig some competitive and nostalgic games still use. Platform fact (2026): games where players can be R6 at any time are not eligible for the higher US 18+ DevEx rate; that rate needs R15 (or qualifying custom human-form or non-human) player characters. Set avatar settings to R15-only unless R6 is central to your game.
- **Avatar scaling and accessories** can break hitboxes and doors. Use the avatar settings to clamp scales if your gameplay depends on body size, and give gameplay a consistent collision shape.
- **Morphs and custom characters** (playing as a monster, an animal, a brainrot) are a genre in themselves. They work when the transformation *is* the fun. Keep the player's identity visible (name tag, color) so friends can find each other.

## NPCs and enemies

### Design

- **Readable roles at a glance**: shape, color and size tell the player whether something is friendly, an enemy or a boss.
- **Telegraphs**: enemies wind up before attacking (a glow, a pose, a sound). Unreadable attacks feel unfair.
- **Families with variants**: one base enemy, recolored and scaled for zones and elite versions. A boss is a big variant with new attacks and a health bar.
- **Personality**: shopkeepers and quest givers with a name, a portrait and a one-line voice make the world memorable.

### Implementation

- **Server owns enemy state** (health, damage, death, loot). Clients animate and show effects.
- **Simple AI is enough.** Most Roblox enemies need: idle, chase the nearest valid target, attack in range, return home if too far. Use `PathfindingService` only where the terrain needs it; straight-line chase with obstacle checks is cheaper.
- **One manager loop, not one script per enemy.** A single server module updates all enemies at a modest frequency (for example 5-10 times per second for decisions), instead of hundreds of scripts with their own loops.
- **Use `Humanoid` sparingly.** Humanoids are expensive. Many games use simpler rigs without Humanoids for crowds of enemies, moved with `AlignPosition`/`AlignOrientation` or by setting `CFrame` on anchored models, and keep Humanoids for players and a few important NPCs.
- **Network ownership**: if enemies are unanchored physics objects, set network ownership deliberately (usually the server) so exploiters cannot move them.
- **Spawn and despawn by area** so empty zones cost nothing.

See [Performance optimization](../13-building-it-right/performance-optimization.md).

## Pets and companions

Pets are one of Roblox's most successful systems: they show progress, give stat bonuses, and are endlessly collectible.

### Design

- **Clear silhouettes and personality**: big heads, simple shapes, idle bounce. Pets must read at small size, in large groups.
- **Rarity visible on the pet**: glow, particles or a colored base by tier; variants (golden, rainbow) clearly different. See [Collection and variants](../03-rarity-and-rng/collection-and-variants.md).
- **Equip slots** as progression (start with 3, upgrade to 8, pass for more).
- **Pets do something**: collect coins, attack enemies, boost stats. Pets that only follow are weaker sellers than pets that help.

### Implementation

- **Pets are client-side visuals.** The server stores which pets a player has equipped (data) and computes their stat effects. Each client renders pet models for nearby players and animates them locally (follow with a smoothed offset, bob up and down). Do not simulate pet physics on the server for every player.
- **Stream and cull**: render pets only for players within a certain distance; offer a "hide other players' pets" setting.
- **Lightweight models**: few parts or a single mesh with a texture; no scripts inside pet models.
- **Pooling** pet models as players move in and out of range.

## Character animation

See [Animation](animation.md) for animation rules and asset ownership.

## For agents

- [ ] Avatar settings chosen deliberately (R15-only unless R6 is required), with scale clamps if gameplay depends on size.
- [ ] Enemy roles readable by shape and color; every attack has a telegraph.
- [ ] One server manager updates all enemies; no per-enemy loops.
- [ ] Humanoids used only where needed.
- [ ] Pets rendered on clients from server-replicated equip data, culled by distance, with a hide option.

Related: [Animation](animation.md) · [VFX and particles](vfx-and-particles.md) · [Collection and variants](../03-rarity-and-rng/collection-and-variants.md) · [Performance optimization](../13-building-it-right/performance-optimization.md)
