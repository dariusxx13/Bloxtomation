---
title: Physics and network ownership
date: 2026-10-24
tags: [engineering, physics, network-ownership, vehicles, ragdoll, performance, security]
aliases: [Network ownership, Distributed physics, Physics performance, Vehicles and ownership]
summary: How Roblox's distributed physics works and how to use it safely - assemblies and root parts, automatic and manual network ownership, the exploit risks of client-owned parts, vehicles, ragdolls and thrown objects, constraints versus setting velocity, adaptive timestepping, the sleep system, collision groups, and debugging tools.
audience: [human, agent]
---

# Physics and network ownership

Roblox splits physics simulation between the server and players' clients. That makes physics feel responsive and saves server time, but it also means clients control some physical objects, which exploiters can abuse. This note explains the rules and the safe patterns. Combat-specific ownership questions are in [Combat systems and hitboxes](combat-systems-and-hitboxes.md); general optimisation in [Performance optimization](performance-optimization.md).

## Assemblies (Fact, physics docs, accessed 2026-10-24)

- An **assembly** is one or more parts joined by rigid welds or movable joints (such as `Motor6D`); physically it is one rigid body. Forces applied to any part apply to the whole assembly.
- Joints only work inside `Workspace` or another `WorldModel`.
- Assembly properties (`AssemblyLinearVelocity`, `AssemblyAngularVelocity`, `AssemblyMass`, `AssemblyCenterOfMass`, `AssemblyRootPart`) are the same for every part in the assembly.
- Every assembly has a **root part**, used for replication and network ownership. You cannot set it directly; anchored parts always win, then non-massless parts, then higher `RootPriority`, then size (with seats, `HumanoidRootPart` and `Torso` favoured).
- The docs recommend constraints (`LinearVelocity`, `VectorForce`, `AngularVelocity`, `Torque`) or impulses (`ApplyImpulse`, `ApplyAngularImpulse`) over setting velocities directly, which can look unrealistic.

## Network ownership (Fact, physics docs)

- The **server always owns anchored parts**; their ownership cannot be changed.
- For unanchored parts, the engine assigns ownership automatically, favouring the client whose character is near and whose hardware can handle it.
- `BasePart:SetNetworkOwner(player)` (server-side) assigns ownership to a client; `SetNetworkOwner(nil)` assigns it to the server; `SetNetworkOwnershipAuto()` returns to automatic handling. The docs advise using server ownership conservatively, because it can make interactions jittery for clients.
- Setting ownership on one assembly of a mechanism without anchored parts sets it for every assembly in the mechanism. Anchoring a lone assembly moves it to the server; unanchoring loses the previous manual setting.
- Studio can outline parts by ownership during playtests (green: your client owns and simulates it; red: buffer zone).

### The security consequence

**A client that owns a part can move it anywhere**, and the movement replicates. Players own their own characters by default. Therefore:

- Never trust positions of client-owned parts for anything valuable (a ball crossing a goal line, a kart passing a checkpoint, a player standing in a reward zone) without server-side plausibility checks.
- Gameplay-critical objects (NPCs, balls in competitive sports, keys, loot) should be server-owned or validated.
- Speed and teleport hacks on characters are detected on the server by comparing movement over time with the maximum legitimate speed ([Security and anti-exploit](security-and-anti-exploit.md)).
- For competitive games, the server authority model removes this class of cheating by keeping characters and gameplay objects server-owned with client prediction ([Combat systems and hitboxes](combat-systems-and-hitboxes.md)).

## Common situations

| Situation | Pattern |
|---|---|
| Vehicles | Give ownership to the driver when they sit (`VehicleSeat.Occupant` changes), return to automatic when they leave; give loose parts on the vehicle to the same client. The docs show this fixes passengers accidentally owning the car |
| Balls in sports games | Server-owned or server-authoritative with prediction; client-owned balls make goals forgeable ([Sports games playbook](../14-genre-playbooks/sports-games.md)) |
| Thrown objects and projectiles | Visual-only clones on clients; the server simulates or validates the real trajectory |
| Ragdolls | Brief server ownership during a ragdoll or grab, then return to the player; or let the victim's client ragdoll itself while the server validates |
| NPCs | `SetNetworkOwner(nil)` on the NPC root so ownership does not flip to nearby players ([NPC AI and pathfinding](npc-ai-and-pathfinding.md)) |
| Physics puzzles and destruction | Server-owned for shared state; client-only debris for decoration |
| Doors and platforms | Anchored and tweened, or constraints owned by the server |

## Constraints instead of scripts

Mover constraints (`AlignPosition`, `AlignOrientation`, `LinearVelocity`, `AngularVelocity`, `VectorForce`) and mechanical constraints (hinges, springs, prismatic, rope) let the physics engine do the work smoothly and efficiently. Prefer them to updating `CFrame` every frame for physically moving objects. For purely visual motion, anchor the part and tween it on the client.

## Performance tools (Fact, physics docs)

### Adaptive timestepping

Roblox simulates physics at 240 Hz by default (about four worldsteps per 60 fps frame). With `Workspace.PhysicsSteppingMethod` set to **Adaptive**, the engine assigns assemblies to 240, 120 or 60 Hz "solver islands", which can improve physics performance by up to 2.5 times. The docs recommend **Fixed** (240 Hz) for games that need highly accurate, stable simulation, such as racing, destruction, or complex mechanisms like tanks, and when most parts would end up at 240 Hz anyway. Studio can outline parts by their simulation rate (Studio Settings, Physics, "Are Timesteps Shown").

### Sleep system

Assemblies that are not moving or accelerating fall asleep and are not simulated. The thresholds are small (for example, linear velocity below about 0.33 studs per second). An object that should keep moving but stops may be moving too slowly and has fallen asleep; apply a force or impulse to wake it.

### Other practices

- Anchor everything that does not need to move ([Build budgets](../06-world-and-look/build-budgets.md)).
- Turn off `CanCollide`, `CanTouch` and `CanQuery` on decorative parts and effects.
- Use **collision groups** so effects, pets and players ignore each other where appropriate.
- Use simple collision fidelity (`Box` or `Hull`) for meshes that do not need precise collision.
- Keep unanchored part counts low; debris is client-side and capped ([Mesh VFX](../19-vfx/mesh-vfx.md)).
- Use the MicroProfiler (Ctrl+F6) to see physics cost (`physicsStepped`, `worldStep`).

## Testing physics

- Test with two or more clients and simulated latency; ownership hand-offs and jitter only show in multiplayer.
- Turn on ownership and assembly visualisations while testing vehicles, ragdolls and puzzles.
- Run an exploit test: on a test client, move an owned part far away and confirm the server rejects any reward or state change that depends on it.

## For agents

- [ ] Every physically simulated gameplay object has a stated owner (server, a specific client, or automatic) and a reason.
- [ ] Positions of client-owned parts never directly grant rewards or decide outcomes without server checks.
- [ ] Vehicles assign ownership to the driver; NPCs and competitive balls are server-owned or server-authoritative.
- [ ] Physics stepping mode is chosen deliberately (Adaptive by default, Fixed for racing or destruction).
- [ ] Decorative parts have collisions and queries off.

Sources: [Network ownership](https://create.roblox.com/docs/physics/network-ownership) · [Assemblies](https://create.roblox.com/docs/physics/assemblies) · [Adaptive timestepping](https://create.roblox.com/docs/physics/adaptive-timestepping) · [Sleep system](https://create.roblox.com/docs/physics/sleep-system) · [Mover constraints](https://create.roblox.com/docs/physics/mover-constraints) · [Server authority model](https://create.roblox.com/docs/projects/server-authority)

Related: [Combat systems and hitboxes](combat-systems-and-hitboxes.md) · [Security and anti-exploit](security-and-anti-exploit.md) · [Performance optimization](performance-optimization.md) · [Driving and vehicles playbook](../14-genre-playbooks/driving-and-vehicles.md) · [NPC AI and pathfinding](npc-ai-and-pathfinding.md)
