---
title: World and level design
date: 2026-10-24
tags: [world, level-design, navigation, zones]
aliases: [Level design, Map design, Zones]
summary: How to lay out Roblox worlds so players always know where to go, zones feel distinct, and the map supports the core loop instead of fighting it.
audience: [human, agent]
---

# World and level design

The world is where the core loop happens. A good map makes the next goal visible, keeps players near each other, and makes every new area feel like a reward. A bad map hides the action, spreads players thin and costs frame rate.

## Principles

1. **Function first.** Every space exists to support the loop: gathering, fighting, building, trading, socializing. Decoration without function is a cost.
2. **Always see the next goal.** From any point, the player can see where to go next: a locked gate, a giant landmark, a glowing path.
3. **Short trips.** Time spent walking without doing anything is dead time. Keep travel between loop steps short, or add things to do on the way.
4. **Players near players.** On a social platform, empty corners are lonely. Funnel players through shared spaces (the hub, the sell area, the boss arena).
5. **Each zone feels new.** Different palette, lighting, music, resources and silhouette, so unlocking it is a reward.

## Map structures that work on Roblox

| Structure | Description | Good for |
|---|---|---|
| Hub and spokes | Central hub with zones branching out | Simulators, RPGs, social games |
| Linear chain | Zone 1 → 2 → 3 with gates | Simulators, obbies, adventure |
| Plots | Each player has a personal plot around a shared center | Tycoons, farms, steal-and-defend |
| Vertical tower | Stages stacked upward | Tower obbies, climbing games |
| Arena with lobby | Lobby plus round maps loaded or teleported | Round-based PvP, horror, minigames |
| Open world | Large continuous map with points of interest | RPGs, survival (needs streaming and good navigation) |

## Navigation and wayfinding

- **Landmarks**: one huge, unique object per zone visible from far away (a volcano, a giant tree, a castle).
- **Paths**: visible paths, roads or lights lead from the spawn to the main activities.
- **Gates with prices**: show the requirement on the gate itself ("50K coins") and show the next zone through or over it.
- **Teleport pads** to unlocked zones once the walk is no longer interesting. Unlocked teleports are a reward, not a convenience to sell.
- **Guide beam** from the goal tracker to the current objective (see [Onboarding patterns](../01-first-five-minutes/onboarding-patterns.md)).
- **Minimap or zone list** only for big worlds.

## Zones and progression

- Each zone introduces something new: a new resource, a new enemy type, a new mechanic, a new pet egg. Not just bigger numbers.
- Visual escalation: early zones are calm and familiar (grass, beach); later zones are dramatic (lava, space, candy, void).
- The gate to the next zone is visible from the current zone's busiest area.
- Optional secrets (hidden areas, easter eggs, secret items) reward exploration and generate community content ("how to find the secret pet").

## Plot-based maps (tycoons, farms, bases)

- Plots arranged around a shared center (market, sell area, event zone) so players see each other's progress.
- Plot assignment on join is automatic; the player's plot is marked with their name and a beam on spawn.
- Plot size and layout planned for the *final* state: a tycoon that grows upward or outward must have room.
- In steal-and-defend games, plot distances and paths decide the whole balance (how long a thief is exposed). Treat them as tuning values.

## Round-based maps

- Rotate 3-6 maps to keep rounds fresh; vote or random selection.
- Each map has clear lanes or zones, cover where relevant, and no spots where players can get stuck.
- Lobby during intermission must have something to do (see [Lobby and hub design](lobby-and-hub-design.md)).
- Load round maps from `ServerStorage` or stream them, so idle maps do not cost memory.

## Scale and the Roblox character

- The default avatar is about 5 studs tall. Doors at least 8-10 studs tall and corridors 8+ studs wide feel comfortable; tighter spaces feel claustrophobic (useful in horror).
- Default walk speed is 16 studs per second; jump height about 7 studs (with default settings). Gaps and platforms in obbies are tuned to these values; if you change walk speed or jump power, retune everything.
- Big landmarks should be 100+ studs tall to read as landmarks from across a zone.

## Common mistakes

- **Beautiful but empty.** Big maps with nothing to do between points of interest.
- **Spawn in a dead end.** The first view should face the action.
- **Hidden gates.** Players cannot find the next zone.
- **Too many paths.** Choice paralysis in the first minutes.
- **Collision traps.** Players stuck in geometry: test with the character's real collision, and walk every edge.
- **Huge unstreamed worlds** that crash phones. See [Build budgets](build-budgets.md).

## For agents

- [ ] Map structure chosen and justified for the genre.
- [ ] From the spawn, the first activity and the next goal are visible.
- [ ] Each zone has a landmark, a palette, and at least one new mechanic or resource.
- [ ] Walk time between core loop steps measured (target: a few seconds in the early game).
- [ ] Collision walk-through done; no stuck spots or out-of-bounds exploits.
- [ ] Streaming configured and the map stays within build budgets.

Related: [Art direction](art-direction.md) · [Lobby and hub design](lobby-and-hub-design.md) · [Build budgets](build-budgets.md) · [Progression architecture](../04-progression-and-economy/progression-architecture.md)
