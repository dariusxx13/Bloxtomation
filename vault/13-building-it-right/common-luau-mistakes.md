---
title: Common Luau mistakes
date: 2026-10-24
tags: [engineering, luau, code-review, bugs, deprecated, ai-generated-code]
aliases: [Roblox scripting mistakes, Code review red flags, AI code mistakes, Deprecated Roblox APIs]
summary: The mistakes that appear again and again in beginner and AI-generated Roblox code - wrong instance hierarchy, undefined variables in generated scripts, deprecated wait and spawn, scripts inside parts, Touched without debounce, client-trusted rewards, missing data saving, string-built code and more - each with why it breaks and the corrected strict Luau.
audience: [human, agent]
---

# Common Luau mistakes

AI models and tutorials often produce Roblox code that "works in the demo" and fails in a real game. The studio reviewed the example code shipped with a popular community AI bridge in October 2026 and found most of the classics in a few hundred lines ([AI tooling landscape](../22-references/ai-tooling-landscape.md)). This note lists the mistakes, why they break, and what to write instead. Standards are in [Luau standards](luau-standards.md); architecture in [Project architecture](project-architecture.md).

## 1. Looking in the wrong place in the hierarchy

**Mistake:** finding `leaderstats` from a touching part with `hit.Parent.Parent`.

**Why it breaks:** `hit.Parent` is the character model; its parent is `Workspace`. `leaderstats` lives under the **Player** object, not the character, so the lookup always fails and nothing is awarded.

**Fix:**

```lua
--!strict
local Players = game:GetService("Players")

local function playerFromHit(hit: BasePart): Player?
	local character = hit:FindFirstAncestorOfClass("Model")
	return if character then Players:GetPlayerFromCharacter(character) else nil
end
```

Better still, never award from `Touched` on the client side or through `leaderstats` values; call a server system that owns the currency (see 5).

## 2. Variables that do not exist in generated scripts

**Mistake:** creating a part in one script, then writing a new script's `Source` that refers to the first script's local variable (for example a `coin` variable that only existed in the creator script).

**Why it breaks:** each script has its own scope. In the new script the name is an undefined global (`nil`), so loops guarded by it never run and indexing it errors.

**Fix:** reference the instance through `script.Parent` or, better, do not generate scripts at runtime at all. Use one manager module with `CollectionService` tags ([Project architecture](project-architecture.md)):

```lua
--!strict
local CollectionService = game:GetService("CollectionService")

local function attachCoin(coin: Instance)
	if not coin:IsA("BasePart") then
		return
	end
	-- set up the coin's behaviour here, referring to `coin` directly
end

for _, coin in CollectionService:GetTagged("Coin") do
	attachCoin(coin)
end
CollectionService:GetInstanceAddedSignal("Coin"):Connect(attachCoin)
```

## 3. Deprecated `wait`, `spawn` and `delay`

**Mistake:** `wait(0.03)`, `spawn(function() ... end)`, `delay(1, f)`.

**Why it breaks:** the legacy functions are deprecated, throttle unpredictably and can delay far longer than asked under load.

**Fix:** `task.wait`, `task.spawn`, `task.defer`, `task.delay`. For per-frame motion, use `RunService` events or tweens instead of tight wait loops.

## 4. Spinning and animating with loops on the server

**Mistake:** a server loop that rotates a coin with `CFrame` every 0.03 seconds.

**Why it breaks:** it costs server time and network bandwidth for something purely cosmetic, and it stutters for players.

**Fix:** animate cosmetics on the client (a tween or a `RenderStepped` update in a client controller), or use a constraint for physical motion ([VFX architecture and replication](../19-vfx/vfx-architecture-and-replication.md)).

## 5. Rewards decided by the client or by loose touches

**Mistake:** awarding currency from a client script, or from `Touched` without checks.

**Why it breaks:** exploiters can fire touches and remotes freely; `Touched` fires many times per contact.

**Fix:** the server validates and grants once:

```lua
--!strict
local debounce: { [Player]: number } = {}

local function onCoinTouched(coin: BasePart, hit: BasePart, grant: (Player, number) -> ())
	local character = hit:FindFirstAncestorOfClass("Model")
	local player = character and game:GetService("Players"):GetPlayerFromCharacter(character)
	if not player or coin:GetAttribute("Collected") then
		return
	end
	local now = os.clock()
	if (debounce[player] or 0) > now then
		return
	end
	debounce[player] = now + 0.2
	coin:SetAttribute("Collected", true) -- one collection only
	grant(player, 1) -- server-side currency module
	coin:Destroy()
end
```

Clear `debounce[player]` on `PlayerRemoving`. See [Security and anti-exploit](security-and-anti-exploit.md).

## 6. Scripts inside every part

**Mistake:** one `Script` per coin, door or checkpoint.

**Why it breaks:** hundreds of scripts, duplicated logic, uncontrolled start order, and changes that must be made in every copy.

**Fix:** one system per behaviour, tags or attributes on instances, two entry scripts per game ([Project architecture](project-architecture.md)).

## 7. Checkpoints that point to the wrong place

**Mistake:** on touching a checkpoint, setting `player.RespawnLocation` to the main `SpawnLocation`.

**Why it breaks:** players respawn at the start, not at the checkpoint.

**Fix:** make each checkpoint a `SpawnLocation` (neutral, not a team spawn) and set `RespawnLocation` to **that checkpoint**, and save the player's stage in their profile so it survives rejoining ([Obby and platformer playbook](../14-genre-playbooks/obby-and-platformer.md)).

## 8. No data saving, or naive saving

**Mistake:** currencies in `leaderstats` with no saving, or `SetAsync` on leave only.

**Why it breaks:** progress is lost; naive saving races between servers and duplicates or loses items.

**Fix:** session-locked profiles, `UpdateAsync`, autosave, `BindToClose`, retries ([Data persistence](data-persistence.md)). `leaderstats` only **displays** values owned by the data system.

## 9. Styling with legacy properties

**Mistake:** `BrickColor.new("Bright red")` everywhere.

**Why it matters:** `BrickColor` is a limited legacy palette. `Color = Color3.fromRGB(...)` gives exact colours and matches an art direction palette ([Art direction](../06-world-and-look/art-direction.md)). Not a bug, but a sign of outdated code.

## 10. Code built from strings at runtime

**Mistake:** creating scripts by setting `Source` strings, or running code with `loadstring`.

**Why it breaks:** `Source` can only be set by plugins and the command bar, not by game scripts; `loadstring` is disabled by default on servers and is an injection risk. Generated code also escapes linting, typing and review.

**Fix:** write modules on disk (Rojo), require them, and pass data, not code ([Tooling and CI](tooling-and-ci.md)).

## 11. Yielding in the wrong places

**Mistake:** `WaitForChild` without a timeout in loops, `:Wait()` on events that may never fire, or yielding inside `UpdateAsync` transforms.

**Fix:** use timeouts and handle `nil`; never yield inside DataStore transform functions; structure startup with `init` and `start` phases ([Project architecture](project-architecture.md)).

## 12. Forgetting players who already joined

**Mistake:** connecting `Players.PlayerAdded` after some players may already be in the server (common in Studio tests and in late-required modules).

**Fix:**

```lua
--!strict
local Players = game:GetService("Players")

local function onPlayer(player: Player)
	-- set up the player
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayer, player)
end
```

## 13. Leaking connections and tables

**Mistake:** connecting events per player or per object and never disconnecting; tables keyed by players never cleared.

**Fix:** disconnect on `PlayerRemoving` and `Destroying`; clear per-player tables; use a cleanup helper ([Performance optimization](performance-optimization.md), [Parallel Luau and profiling](parallel-luau-and-profiling.md)).

## 14. Hard-coded prices and missing purchase handling

**Mistake:** prices typed into UI; granting purchases in `PromptProductPurchaseFinished`.

**Fix:** read prices from `MarketplaceService`; grant only in `ProcessReceipt`, idempotently, after saving ([Pricing and price ladders](../09-monetization/pricing-and-price-ladders.md), [Data persistence](data-persistence.md)).

## 15. Untyped, unformatted, unlinted code

**Mistake:** no `--!strict`, inconsistent style, unused variables, shadowed globals.

**Fix:** strict mode, StyLua formatting, Selene linting and the template's quality gate (`bash template/scripts/check.sh`) before any handoff ([Luau standards](luau-standards.md)).

## Reviewing AI-generated code

| Check | Red flag |
|---|---|
| Hierarchy | `Parent.Parent` chains, `FindFirstChild` without type checks |
| Scope | Names used but never defined in that script |
| APIs | `wait(`, `spawn(`, `delay(`, `BrickColor`, client `Teleport` |
| Authority | Client-side rewards, prices or damage |
| Structure | Scripts inside parts; generated `Source` strings |
| Data | No saving, `SetAsync` for profiles, no `BindToClose` |
| Quality | Missing `--!strict`; fails StyLua or Selene |

## For agents

- [ ] Every code handoff passes the quality gate and the review table above.
- [ ] No runtime script generation or `loadstring` in game code.
- [ ] Rewards, prices, damage and progress are server-owned and saved through the data system.

Sources: [task library](https://create.roblox.com/docs/reference/engine/libraries/task) · [Players](https://create.roblox.com/docs/reference/engine/classes/Players) · [CollectionService](https://create.roblox.com/docs/reference/engine/classes/CollectionService) · [Data stores](https://create.roblox.com/docs/cloud-services/data-stores) · Review of [Bbasche/roblox-ai](https://github.com/Bbasche/roblox-ai) example code (read-only, 2026-10-24).

Related: [Luau standards](luau-standards.md) · [Security and anti-exploit](security-and-anti-exploit.md) · [Project architecture](project-architecture.md) · [Testing and QA](testing-and-qa.md) · [AI tooling landscape](../22-references/ai-tooling-landscape.md)
