---
title: Combat systems and hitboxes
date: 2026-10-24
tags: [engineering, combat, hitboxes, netcode, lag-compensation, server-authority, security]
aliases: [Hit detection, Hitboxes, Lag compensation, Server authority model, Combat netcode]
summary: How to build fair, responsive combat on Roblox - hit detection methods, who detects hits, server validation, lag compensation with position history, a server-side combat state machine and damage pipeline, projectiles, knockback and ragdoll ownership, and Roblox's server authority model with prediction, rollback, input actions and its rules for animations and effects.
audience: [human, agent]
---

# Combat systems and hitboxes

Combat must feel instant to the attacker, fair to the victim and impossible to cheat. Those goals pull against each other because of network latency. This note shows the standard architecture, the code patterns and Roblox's newer server authority model. Design-level guidance is in [Anime battlegrounds and fighting deep dive](../20-anime-games/anime-battlegrounds-and-fighting.md); effects in [Combat and anime VFX](../19-vfx/combat-and-anime-vfx.md); general security in [Security and anti-exploit](security-and-anti-exploit.md).

## Two architectures

| | Classic (default physics ownership) | Server authority model |
|---|---|---|
| Who simulates a player's character | The player's own client (network owner) | The server, with client prediction |
| Responsiveness | Instant for own movement | Instant through prediction; corrections on mispredictions |
| Cheating risk | Movement hacks possible; must be detected server-side | Movement hacks prevented by design |
| Code shape | Remotes for actions; server validates | Core logic in simulation callbacks run on both sides |
| Best for | Most games, simulators, casual combat | Competitive combat, shooters, racing, sports |

Most of this note applies to both. The server authority section explains what changes.

## Hit detection methods

| Method | How | Use for | Avoid because |
|---|---|---|---|
| `Touched` events | Fire when parts touch | Almost nothing in combat | Unreliable timing, fires many times, depends on physics ownership |
| Raycast | `workspace:Raycast(origin, direction, params)` | Hitscan guns, line-of-sight checks | A line misses wide attacks |
| Shapecast | `workspace:Blockcast` or `workspace:Spherecast` along a direction | Sweeping a sword arc or a fast projectile between frames | Slightly more cost |
| Overlap query | `workspace:GetPartBoundsInBox`, `GetPartBoundsInRadius`, `GetPartsInPart` with `OverlapParams` | Melee hitboxes at the hit frame, area attacks | Only checks one moment unless repeated |
| Data-only hit test | Compare positions with math (distance, angle) | Large numbers of simple attacks, tower defense | Needs care with shapes |

**Rule of thumb:** melee uses an overlap query (box or sphere) at the animation marker frame; fast weapons use shapecasts between the previous and current position; guns use raycasts. Always filter with `OverlapParams` or `RaycastParams` (exclude the attacker, effect folders and non-hittable parts; or include only a hitbox collision group).

## Who detects the hit

| Approach | Flow | Pros | Cons |
|---|---|---|---|
| **Server detects** | Client says "I used move X"; server waits until the hit frame and queries around the attacker's server position | Simple trust model | Attacker sees hits land late or miss on high ping |
| **Client suggests, server validates** | Client detects hits locally and sends target ids; server checks plausibility | Feels right to the attacker | More validation work; exploiters will send fake targets |
| **Server detects with lag compensation** | Server queries targets at their past positions, rewound by the attacker's latency | Fair to the attacker; still server-decided | Victims may be hit "around corners" on high ping; needs position history |

Competitive combat usually combines the last two: the client suggests, the server validates against rewound positions.

## Server validation checklist

For every attack request, in this order (first failure drops the request):

1. **Rate limit** the remote ([Networking and remotes](networking-and-remotes.md)).
2. **Types and ranges** of every argument (move id is a known string; target ids are real players or NPCs).
3. **State:** the attacker is alive, not stunned, owns the move, the move is off cooldown (server time), and not mid-animation of another move.
4. **Geometry:** each target is within the move's reach from the attacker's server-side position, plus a latency allowance; within the move's angle; with line of sight if required.
5. **Timing:** the request arrives within a plausible window of the move's hit frame.
6. **Caps:** the number of targets does not exceed the move's maximum.
7. **Apply** damage, stun and knockback from **server data** for the move; never from client numbers.

Log rejections per player; repeated impossible requests are evidence for moderation, but do not auto-ban on a single signal.

## Lag compensation with position history

Record each character's root position a few times per second and keep about one second of history. When validating, look up where the target was at `now - attackerLatency` (capped).

```lua
--!strict
-- PositionHistory (sketch): a ring buffer of timestamped positions per character.
export type Sample = { t: number, pos: Vector3 }

local HISTORY_SECONDS = 1
local SAMPLE_RATE = 20 -- samples per second
local SIZE = HISTORY_SECONDS * SAMPLE_RATE
local MAX_REWIND = 0.25 -- seconds; cap rewind so victims are not hit far in the past

local PositionHistory = {}
local buffers: { [Model]: { samples: { Sample }, head: number } } = {}

function PositionHistory.record(character: Model, now: number, pos: Vector3)
	local buf = buffers[character]
	if not buf then
		buf = { samples = table.create(SIZE), head = 0 }
		buffers[character] = buf
	end
	buf.head = buf.head % SIZE + 1
	buf.samples[buf.head] = { t = now, pos = pos }
end

-- Returns the recorded position closest to `now - rewind`, or nil if none.
function PositionHistory.at(character: Model, now: number, rewind: number): Vector3?
	local buf = buffers[character]
	if not buf then
		return nil
	end
	local target = now - math.clamp(rewind, 0, MAX_REWIND)
	local best: Sample? = nil
	for _, s in buf.samples do
		if not best or math.abs(s.t - target) < math.abs(best.t - target) then
			best = s
		end
	end
	return if best then best.pos else nil
end

function PositionHistory.forget(character: Model)
	buffers[character] = nil
end

return PositionHistory
```

Use `workspace:GetServerTimeNow()` or `os.clock()` consistently on the server for timestamps, and `Player:GetNetworkPing()` as the latency estimate. Remove buffers when characters are removed (leaks otherwise; see [Performance optimization](performance-optimization.md)).

## Server-side melee query (sketch)

```lua
--!strict
-- At the hit frame, query a box in front of the attacker's server position.
local function queryMelee(attackerRoot: BasePart, reach: number, width: number, exclude: { Instance }): { Model }
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = exclude
	local boxCFrame = attackerRoot.CFrame * CFrame.new(0, 0, -reach / 2)
	local parts = workspace:GetPartBoundsInBox(boxCFrame, Vector3.new(width, 6, reach), params)
	local hit: { [Model]: boolean } = {}
	local result: { Model } = {}
	for _, part in parts do
		local model = part:FindFirstAncestorOfClass("Model")
		if model and not hit[model] and model:FindFirstChildOfClass("Humanoid") then
			hit[model] = true
			table.insert(result, model)
		end
	end
	return result
end
```

With lag compensation, use the rewound position of each candidate rather than its current parts, or validate client-suggested targets against rewound positions with a distance and angle check.

## The combat state machine

Keep combat state on the server per character:

| Field | Purpose |
|---|---|
| `state` | Idle, Attacking, Blocking, Stunned, Ragdolled, Dashing, Dead |
| `stateUntil` | Server time when the state ends |
| `cooldowns[moveId]` | Server time when each move is ready |
| `comboCount`, `comboExpires` | For combo scaling and anti-infinite rules |
| `invulnerableUntil` | Dash frames, wake-up protection, ultimates |
| `meter` | Awakening or ultimate charge |

Transitions happen only on the server. Clients receive state changes (attributes on the character or compact remote events) to drive animations and effects. Anti-infinite rules (stun decay, combo damage scaling, hit caps, evasive meters) are enforced here; design guidance is in [Anime battlegrounds and fighting deep dive](../20-anime-games/anime-battlegrounds-and-fighting.md).

## Damage pipeline

```text
move data (shared config) -> base damage
  × attacker modifiers (level, buffs, awakening)
  × combo scaling
  × target modifiers (block, armor, resistances)
  + crit roll (server Random)
  -> clamp, apply to server health
  -> broadcast "hit" event (attacker, target, move, amount, crit) to nearby clients for VFX and numbers
```

Damage numbers and hit effects are cosmetic; send them with an unreliable remote if dropping one is acceptable ([VFX architecture and replication](../19-vfx/vfx-architecture-and-replication.md)).

## Projectiles

| Projectile type | Approach |
|---|---|
| Hitscan | Raycast on the server at fire time (with lag compensation), clients draw tracers |
| Fast (bullets, arrows) | Server steps a ray or shapecast per tick along the trajectory; clients draw a visual copy |
| Slow (fireballs, grenades) | Server simulates as data (position, velocity) with fixed steps; clients render and interpolate |
| Hundreds at once (bullet hell, tower defense) | Pure data on the server; batched updates; client-only visuals ([Anime tower defense deep dive](../20-anime-games/anime-tower-defense.md)) |

Never let clients report "my projectile hit X" without validation against the server's own trajectory.

## Knockback, ragdoll and ownership

In the classic model, a player's character is physically simulated by that player's client. A force applied by the server to that character can be overridden by the owner. Practical patterns:

- **Victim applies its own knockback:** the server decides direction and strength, tells the victim's client, and the victim's client applies it; the server checks afterwards that the character moved plausibly.
- **Temporary server ownership:** for ragdolls and grabs, the server can take network ownership of the character's parts for the duration, then hand it back. Ownership changes cost a moment of jitter; use them for dramatic moments, not every hit ([Physics and network ownership](physics-and-network-ownership.md)).
- **NPCs** are server-owned by default when you set ownership explicitly; keep it that way for combat NPCs.

Under the server authority model, characters are server-owned and predicted, so knockback is applied inside the simulation on both sides.

## The server authority model (Fact, creator docs, accessed 2026-10-24)

Roblox's server authority model makes the server the single source of truth and lets clients **predict** the results of their inputs, then **roll back and resimulate** when the server disagrees.

### Setup

Set `Workspace.AuthorityMode` to `Server`. This automatically sets the other required properties: `NextGenerationReplication`, `PlayerScriptsUseInputActionSystem`, `SignalBehavior` (Deferred), `UseFixedSimulation` and `StreamingEnabled`.

### How code changes

- **Core logic runs in simulation callbacks** bound with `RunService:BindToSimulation()`, in a ModuleScript initialised on both client and server. During resimulation the engine re-runs these callbacks.
- **Use `time()`** inside simulation logic; it is synchronised and uses fixed-step simulation time. `tick()`, `os.time()` and `os.clock()` are local and do not roll back.
- **Inputs come through the Input Action System** (`InputAction`, `InputContext` under the player), which sends inputs to the server and replays them during resimulation. Do not use `UserInputService.InputBegan` for core simulation inputs; sanity-check inputs before processing.
- **Custom state goes in attributes** on predicted instances; mismatches trigger rollback. Attributes replicate only if they are among the first 64 on the instance, their names are at most 50 characters, and string values at most 50 characters. Write them only inside simulation callbacks.
- **Only properties and methods labelled "Simulation Access"** can be used inside simulation callbacks. `task.spawn` from a callback stays inside the simulation's restrictions; use `task.defer` to run outside them.
- **Remote events still work** for discrete messages (scoring, pickups), but may arrive out of order relative to property and attribute updates.
- `RunService:SetPredictionMode()` forces prediction on or off for an instance; by default, instances with simulation access near the local character are predicted.

### Rendering a predicted simulation

- **Effects and sounds may be mispredicted.** Drive them from a synchronised state machine (for example Idle, Lit, Exploded, Defused) and render changes in `RenderStepped`, so a mispredicted explosion can be hidden or undone.
- **Do not cache `AnimationTrack` objects** across frames; rollback can invalidate them. Mirror animation logic on both sides inside the simulation.
- **Instance stitching:** instances created inside simulation callbacks on both sides (with `Instance.new`, `Clone` or `Instance.fromExisting`) get matching ids and merge, so a fired rocket appears immediately. They must be parented in the same frame.
- **Position smoothing:** render a visual-only copy that smoothly follows the invisible simulated object (for example with `TweenService:SmoothDamp`) to hide corrections.

### Designing for latency

The docs recommend mechanics that hide latency: slower acceleration hides position differences; a short fuse before an explosion moves the correction onto the fuse effect. Other players' inputs are not forwarded by default, so remote characters render slightly in the past; for racing-style games, store inputs in attributes so clients can predict others.

### Debugging and examples

Studio's server authority visualizer opens with Ctrl+Shift+F6 (Cmd+Shift+F6 on Mac). Roblox publishes Racing, Soccer and Laser Tag example projects built on this model.

### When to use it

Use the server authority model for new competitive games (shooters, battlegrounds with ranked modes, racing, sports) where fairness matters more than the cost of restructuring code. For existing games and casual combat, the classic model with server validation remains simpler.

## Testing combat

- Multi-client playtests in Studio with two to four clients ([Testing and QA](testing-and-qa.md)).
- Simulate latency with Studio's network settings (incoming replication lag) and test at 100, 200 and 300 ms.
- Automated tests for pure functions: damage formulas, combo scaling, state transitions.
- Exploit tests: fire attack remotes with wrong types, impossible targets, huge rates and stale timestamps.

## For agents

- [ ] Hits are decided on the server; clients never set damage, stun or knockback strength.
- [ ] Melee uses overlap queries at marker frames; fast weapons use sweeps; `Touched` is not used for combat.
- [ ] Lag compensation, if used, caps rewind and cleans up history on character removal.
- [ ] Combat state and cooldowns live on the server with server time.
- [ ] Under server authority: logic in `BindToSimulation`, inputs via Input Actions, state in attributes within limits, no cached animation tracks.
- [ ] Combat is tested at 100-300 ms simulated latency with multiple clients.

Sources: [Server authority model](https://create.roblox.com/docs/projects/server-authority) · [Server authority techniques](https://create.roblox.com/docs/projects/server-authority/techniques) · [WorldRoot spatial queries](https://create.roblox.com/docs/reference/engine/classes/WorldRoot) · [OverlapParams](https://create.roblox.com/docs/reference/engine/datatypes/OverlapParams) · [Network ownership](https://create.roblox.com/docs/physics/network-ownership)

Related: [Security and anti-exploit](security-and-anti-exploit.md) · [Networking and remotes](networking-and-remotes.md) · [Physics and network ownership](physics-and-network-ownership.md) · [Animation systems](animation-systems.md) · [Anime battlegrounds and fighting deep dive](../20-anime-games/anime-battlegrounds-and-fighting.md)
