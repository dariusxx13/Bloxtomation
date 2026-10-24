---
title: Mounts and rideables
date: 2026-10-24
tags: [characters, mounts, pets, vehicles, collection, engineering]
aliases: [Mounts, Rideable pets, Riding systems, Bikes and boards]
summary: How to design and build mounts and rideables - pets you ride, bikes, boards and creatures - as both collection and movement, with speed as progression, seat and weld setups, animation, network ownership, anti-cheat, performance for many riders, and monetization, with dated 2026 examples.
audience: [human, agent]
---

# Mounts and rideables

Riding what you collect is a strong 2026 pattern. Ride A Pet (hatch eggs, then ride what you hatched; faster mounts reach rarer eggs) reached about 208K players and a 97% rating within weeks of launch (StudioKrew, September 2026), and young bike games charted in October 2026 (studio snapshot). Mounts turn a collection into **movement**, which makes every new pet feel useful immediately. Pets that only follow are covered in [Characters, NPCs and pets](characters-npcs-and-pets.md); vehicles in the [Driving and vehicles playbook](../14-genre-playbooks/driving-and-vehicles.md).

## Design

### Speed as progression

- Each mount has a speed (and sometimes jump, flight or swim abilities); faster mounts reach farther or harder areas.
- The world is laid out by **travel requirement**: an island that needs a flying mount, a volcano that needs a heat-proof one (Ride A Pet's volcano update added an egg that needs a flying pet, StudioKrew, September 2026).
- One stat doing two jobs (power and travel) is a clean design: every upgrade is felt the moment you ride.

### Collection

- Rarity tiers with visibly better mounts at the top ([Rarity tiers and odds](../03-rarity-and-rng/rarity-tiers-and-odds.md)).
- Variants (colours, mutations, weather forms) multiply the collection ([Collection and variants](../03-rarity-and-rng/collection-and-variants.md)).
- A stable or garage to show off owned mounts.

### Feel

- Acceleration and turning tuned per mount type (heavy mounts slow to turn, light ones twitchy).
- A dismount and remount that takes under a second.
- Trails, dust and sound that scale with speed ([VFX recipes](../19-vfx/vfx-recipes.md)).

## Building rideables

| Approach | How | Use for |
|---|---|---|
| Humanoid seat on a model | A `Seat` or `VehicleSeat` welded to the mount; the player's character sits; the mount moves by constraints or `Humanoid` movement | Creatures and bikes with physics |
| Character speed swap | The mount is a cosmetic model welded to the character; the server raises `WalkSpeed` and sets jump power from the mount's stats | Simple, cheap, robust; most collection games |
| Custom controller | A dedicated movement controller for flying or swimming mounts | Flight and special movement |

**Rule of thumb:** start with the speed-swap approach (cosmetic model plus server-set movement stats). It is the cheapest, replicates well, and avoids most physics bugs. Move to seats and constraints only when the mount must behave like a vehicle.

### Animation

- Rider pose animation at `Action` priority on the character; mount gait animations (idle, walk, run, jump) on the mount's `Animator` ([Animation systems](../13-building-it-right/animation-systems.md)).
- Sync gait speed with movement speed (`AdjustSpeed`).
- Custom creature rigs can use Adaptive Animation if they are humanoid-like; quadrupeds need their own animation set.

### Ownership and security

- The player's client simulates its own character, so a rider can speed-hack. The server owns the **stats** (speed, abilities) and checks movement plausibility against the mount's maximum speed ([Security and anti-exploit](../13-building-it-right/security-and-anti-exploit.md)).
- Area gates (needs flying, needs heat resistance) are checked on the server when entering, not only by collision.
- With seat-based mounts, give network ownership to the rider while seated and return it afterwards ([Physics and network ownership](../13-building-it-right/physics-and-network-ownership.md)).

### Performance

- Many players riding detailed mounts multiplies parts, bones and effects. Budget triangles per mount, simplify distant mounts, and cap trail effects ([VFX performance budgets](../19-vfx/vfx-performance-budgets.md)).
- Other players' mount effects can be reduced or hidden through a setting ([Accessibility and player settings](../05-ui-and-hud/accessibility-and-player-settings.md)).
- Small servers (Ride A Pet reportedly caps at six) reduce load and increase social visibility.

## Monetization

Mount skins and colour variants, exclusive cosmetic mounts that are balanced with earnable ones, stable slots, speed boosts measured in minutes, saddles and trails. Any paid egg or random mount is a paid random item with odds disclosure and policy gating ([Anime units, gacha and traits](../20-anime-games/anime-units-gacha-and-traits.md)).

## For agents

- [ ] Mount stats live on the server; movement plausibility is checked against them.
- [ ] Area requirements are validated on entry by the server.
- [ ] Each mount has a triangle and effect budget and a low-detail mode.
- [ ] Paid random mounts follow the paid random item rules.

Sources: StudioKrew September 2026 board; the studio's chart snapshot of 2026-10-24 (accessed 2026-10-24) · [VehicleSeat](https://create.roblox.com/docs/reference/engine/classes/VehicleSeat) · [Network ownership](https://create.roblox.com/docs/physics/network-ownership)

Related: [Characters, NPCs and pets](characters-npcs-and-pets.md) · [Driving and vehicles playbook](../14-genre-playbooks/driving-and-vehicles.md) · [Hits of 2026](../21-hits-and-trends/hits-2026.md) · [Collection and variants](../03-rarity-and-rng/collection-and-variants.md) · [Animation systems](../13-building-it-right/animation-systems.md)
