---
title: NPC AI and pathfinding
date: 2026-10-24
tags: [engineering, npc, ai, pathfinding, performance, bosses, state-machines]
aliases: [NPC AI, Enemy AI, PathfindingService, Boss AI, Mob AI]
summary: How to build NPCs and enemies that feel smart and cost little - architectures (state machines, behaviour trees, utility scoring), perception, movement with Humanoids, PathfindingService facts and limits (modifiers, links, streaming), scaling to many NPCs, network ownership, boss design, client-side companions, and a strict Luau state machine sketch.
audience: [human, agent]
---

# NPC AI and pathfinding

Enemies, shopkeepers, bosses, pets and monsters make worlds feel alive. On Roblox they also cost server time, memory and network bandwidth. This note covers how to make NPCs that read as intelligent while staying cheap. Character design and animation are in [Characters, NPCs and pets](../07-characters-vfx-and-assets/characters-npcs-and-pets.md); combat in [Combat systems and hitboxes](combat-systems-and-hitboxes.md).

## Choose an architecture

| Architecture | How it works | Good for |
|---|---|---|
| **Finite state machine** | A few states (Idle, Patrol, Chase, Attack, Return, Dead) with transition rules | Most enemies, mobs, guards; easy to debug |
| **Behaviour tree** | A tree of conditions and actions evaluated from the top | Bosses and complex NPCs with many behaviours |
| **Utility scoring** | Each possible action gets a score from the situation; the best wins | Companions, smart enemies choosing among many options |
| **Scripted sequence** | A timeline of actions | Cutscenes, tutorials, boss intros |
| **Data-only agents** | No Humanoid; position and state are numbers on the server | Hundreds of tower defense enemies ([Anime tower defense deep dive](../20-anime-games/anime-tower-defense.md)) |

**Rule of thumb:** start with a state machine. Move to a behaviour tree only when the state machine's transition rules become hard to follow.

## A state machine NPC (sketch)

```lua
--!strict
-- Mob (sketch): a server-side state machine ticked at a low rate.
type State = "Idle" | "Chase" | "Attack" | "Return"

export type Mob = {
	model: Model,
	humanoid: Humanoid,
	root: BasePart,
	home: Vector3,
	state: State,
	target: Model?,
	nextAttackAt: number,
}

local AGGRO_RANGE = 40
local ATTACK_RANGE = 6
local LEASH_RANGE = 80
local ATTACK_COOLDOWN = 1.5

local function nearestTarget(mob: Mob, candidates: { Model }): Model?
	local best: Model? = nil
	local bestDist = AGGRO_RANGE
	for _, character in candidates do
		local root = character:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") then
			local d = (root.Position - mob.root.Position).Magnitude
			if d < bestDist then
				best, bestDist = character, d
			end
		end
	end
	return best
end

local function tick(mob: Mob, now: number, candidates: { Model })
	local fromHome = (mob.root.Position - mob.home).Magnitude
	if mob.state == "Idle" then
		mob.target = nearestTarget(mob, candidates)
		if mob.target then
			mob.state = "Chase"
		end
	elseif mob.state == "Chase" or mob.state == "Attack" then
		local target = mob.target
		local targetRoot = target and target:FindFirstChild("HumanoidRootPart")
		if not targetRoot or not targetRoot:IsA("BasePart") or fromHome > LEASH_RANGE then
			mob.state, mob.target = "Return", nil
			mob.humanoid:MoveTo(mob.home)
			return
		end
		local d = (targetRoot.Position - mob.root.Position).Magnitude
		if d <= ATTACK_RANGE then
			mob.state = "Attack"
			if now >= mob.nextAttackAt then
				mob.nextAttackAt = now + ATTACK_COOLDOWN
				-- Start the attack animation; the hit is validated at its marker (see combat note).
			end
		else
			mob.state = "Chase"
			mob.humanoid:MoveTo(targetRoot.Position)
		end
	elseif mob.state == "Return" then
		if fromHome < 4 then
			mob.state = "Idle"
		end
	end
end

return { tick = tick }
```

A manager ticks all mobs at 5-10 times per second (not every frame), spreading them across frames, and only ticks mobs near players.

## Perception

| Sense | Cheap implementation |
|---|---|
| Sight range | Squared-distance check to candidate players |
| Line of sight | One raycast from eyes to target, only when in range |
| Vision cone | Dot product between the NPC's look vector and the direction to the target |
| Hearing | Players emit "noise" events (running, attacking) with a radius; NPCs within it react |
| Memory | Remember the last seen position for a few seconds and search there |

Check cheap senses first and expensive ones (raycasts) only when cheap ones pass. Do perception on the server for anything that affects gameplay.

## Movement with Humanoids

- `Humanoid:MoveTo(position)` walks toward a point; `MoveToFinished` fires on arrival or when the attempt times out (after about 8 seconds), so long walks need repeated calls or waypoints.
- `Humanoid:Move(direction)` sets a walking direction each step, which the official path-following example uses between waypoints.
- Set `WalkSpeed` per state (patrol slow, chase fast) for readable behaviour.
- For non-humanoid creatures, use constraints (`AlignPosition`, `AlignOrientation`, `LinearVelocity`) or animate an anchored model along computed positions.

## PathfindingService (Fact, creator docs, accessed 2026-10-24)

- Create a path with `PathfindingService:CreatePath(params)`; agent parameters include `AgentRadius` (default 2), `AgentHeight` (default 5), `AgentCanJump` (default true), `AgentCanClimb` (default false), `WaypointSpacing` and `Costs`.
- Compute with `Path:ComputeAsync(start, goal)`, read `Path:GetWaypoints()`; each waypoint has a position and an action (walk or jump) and may carry a label.
- Connect `Path.Blocked` and recompute only when the blocked waypoint is ahead of the agent.
- **Costs**: materials default to cost 1; set higher costs to avoid them, `math.huge` to forbid them. `PathfindingModifier` parts label regions (for example "DangerZone") that can be given costs, or set `PassThrough` to path through obstacles such as doors.
- **PathfindingLink** connects two attachments for custom traversal (boats, teleporters, ladders), with a label you handle in code.
- **Limits:** the straight-line distance must not exceed 3,000 studs; computations can fail when they exceed a 20,000-node budget; agent parameters that cannot be satisfied fail; waypoints beyond ±65,536 studs vertically are ignored.
- **Streaming:** paths can be blocked or unblocked as content streams in; recompute on `Blocked`; client-side destinations should use persistent models.
- Studio can visualise the navigation mesh, modifiers and links from the viewport's visualization options.

### Pathfinding practice

- Compute paths on the server for enemies; cache and reuse a path while the target has not moved far.
- Recompute on a timer (for example every 0.5-1 s while chasing) or when the target moves more than a few studs, never every frame.
- For very long routes, path to intermediate waypoints (a hand-placed graph of key points) to stay under limits.
- When many enemies chase the same target, compute one path and offset followers, or use simple steering when the target is in direct line of sight.

## Scaling to many NPCs

| Technique | Effect |
|---|---|
| Tick budget | Update a fixed number of NPCs per frame; queue the rest |
| Distance tiers | Full AI near players, simplified AI at mid range, frozen or despawned far away |
| Spawn caps | Per area and per server ([Build budgets](../06-world-and-look/build-budgets.md)) |
| Pooling | Reuse NPC models instead of creating and destroying them |
| Data-only crowds | For tower defense and bullet hell, no Humanoids at all; clients render |
| Simple rigs | Fewer parts and bones for common mobs; detailed rigs only for bosses |
| Parallel Luau | Move perception math into actors when it becomes a hotspot ([Parallel Luau and profiling](parallel-luau-and-profiling.md)) |

Measure with the MicroProfiler and Script Profiler before optimizing ([Performance optimization](performance-optimization.md)).

## Network ownership for NPCs

Unanchored NPC parts are, by default, owned automatically by the server or by a nearby player's client. Ownership flipping near players causes stutter and lets exploiters move NPCs they own. For gameplay NPCs, call `BasePart:SetNetworkOwner(nil)` on the NPC's root assembly so the server always simulates it ([Physics and network ownership](physics-and-network-ownership.md)).

## Bosses

- **Phases** at health thresholds (100%, 66%, 33%) with new attacks and a visual change.
- **Telegraphs:** wind-up animations and ground markers before every damaging attack; the player must be able to learn and react ([VFX timing and choreography](../19-vfx/vfx-timing-and-choreography.md)).
- **Patterns with variation:** a fixed cycle with occasional random choices keeps fights learnable but not trivial.
- **Targeting rules:** switch targets on threat (damage dealt) or periodically so one player is not focused forever.
- **Reward fairness:** track damage contribution per player on the server for reward shares.
- **Enrage timers** prevent stalling.

## Friendly NPCs and companions

- Shopkeepers and quest givers: `ProximityPrompt` to interact, a short line of dialogue, a clear icon above their head (discoverability matters; see [Onboarding and discoverability](../01-first-five-minutes/INDEX.md)).
- Pets and companions that only follow their owner can be **client-side** (each client animates followers), with the server owning only the pet's data; the template's `PetFollow` controller works this way.
- Allies that fight need server logic like enemies.

## For agents

- [ ] Each NPC type has a written state diagram and tick rate.
- [ ] Perception uses cheap checks before raycasts; AI ticks are budgeted and tiered by distance.
- [ ] Paths are computed on the server, reused, and recomputed on `Blocked` or target movement, within the documented limits.
- [ ] Gameplay NPCs have server network ownership.
- [ ] Bosses telegraph every damaging attack and track damage contribution for rewards.

Sources: [Pathfinding](https://create.roblox.com/docs/characters/pathfinding) · [PathfindingService](https://create.roblox.com/docs/reference/engine/classes/PathfindingService) · [Humanoid](https://create.roblox.com/docs/reference/engine/classes/Humanoid) · [Network ownership](https://create.roblox.com/docs/physics/network-ownership)

Related: [Characters, NPCs and pets](../07-characters-vfx-and-assets/characters-npcs-and-pets.md) · [Combat systems and hitboxes](combat-systems-and-hitboxes.md) · [Performance optimization](performance-optimization.md) · [Anime RPGs deep dive](../20-anime-games/anime-rpgs.md) · [Survival and horror co-op playbook](../14-genre-playbooks/survival-horror-coop.md)
