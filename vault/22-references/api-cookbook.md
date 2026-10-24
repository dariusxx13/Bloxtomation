---
title: API cookbook
date: 2026-10-24
tags: [reference, luau, api, recipes, engineering]
aliases: [Luau recipes, Roblox code snippets, How do I in Roblox]
summary: Short, strict Luau recipes for tasks that come up in every Roblox game - player and character setup, tagged objects, prompts, doors, server-synced countdowns, cooldowns, raycasts from the screen, world-to-screen rewards, area queries, badges, policy checks, system chat messages, invites, event RSVPs, feedback prompts and number formatting - each pointing to the template module that already does it where one exists.
audience: [human, agent]
---

# API cookbook

Small, correct building blocks. Each recipe is strict Luau, server or client as labelled, and follows the vault's rules: the server owns state, remotes are validated, nothing deprecated. Where the game template already contains a production version, use that instead (paths given). API names were checked against the engine reference on 2026-10-24. For a one-page list of services see [API quick reference](../99-reference/api-quick-reference.md); for mistakes to avoid see [Common Luau mistakes](../13-building-it-right/common-luau-mistakes.md).

## Players and characters (server)

```lua
--!strict
local Players = game:GetService("Players")

local function onCharacter(player: Player, character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid or not humanoid:IsA("Humanoid") then
		return
	end
	-- apply stats from the player's profile here (server-owned values)
end

local function onPlayer(player: Player)
	player.CharacterAdded:Connect(function(character)
		onCharacter(player, character)
	end)
	if player.Character then
		onCharacter(player, player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayer, player)
end
```

Template: `template/src/server/Systems/Characters.luau`.

## Tagged objects with one manager (server or client)

```lua
--!strict
local CollectionService = game:GetService("CollectionService")

local cleanup: { [Instance]: () -> () } = {}

local function attach(instance: Instance)
	if not instance:IsA("BasePart") then
		return
	end
	local connection = instance.Touched:Connect(function(_hit) end)
	cleanup[instance] = function()
		connection:Disconnect()
	end
end

local function detach(instance: Instance)
	local fn = cleanup[instance]
	if fn then
		fn()
		cleanup[instance] = nil
	end
end

for _, instance in CollectionService:GetTagged("Hazard") do
	attach(instance)
end
CollectionService:GetInstanceAddedSignal("Hazard"):Connect(attach)
CollectionService:GetInstanceRemovedSignal("Hazard"):Connect(detach)
```

## Proximity prompt with server validation (server)

```lua
--!strict
local MAX_DISTANCE = 12

local function onTriggered(prompt: ProximityPrompt, player: Player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local part = prompt.Parent
	if not root or not root:IsA("BasePart") or not part or not part:IsA("BasePart") then
		return
	end
	if (root.Position - part.Position).Magnitude > MAX_DISTANCE then
		return -- too far: ignore
	end
	-- perform the action through the owning system (shop, chest, door)
end

local prompt = Instance.new("ProximityPrompt")
prompt.ObjectText = "Chest"
prompt.ActionText = "Open"
prompt.HoldDuration = 0.5
prompt.Triggered:Connect(function(player)
	onTriggered(prompt, player)
end)
```

Template: `template/src/client/Controllers/Interact.luau` (client side) and the systems it calls. Defaults are in [Discoverability defaults](../01-first-five-minutes/discoverability-defaults.md).

## Tweened door (client for visuals, server for state)

```lua
--!strict
local TweenService = game:GetService("TweenService")

local OPEN_INFO = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function setDoor(door: BasePart, closedCFrame: CFrame, open: boolean)
	local goal = if open then closedCFrame * CFrame.new(0, door.Size.Y, 0) else closedCFrame
	TweenService:Create(door, OPEN_INFO, { CFrame = goal }):Play()
end
```

The server stores whether the door is open (an attribute such as `Open`); each client tweens when the attribute changes. Collision for gameplay doors is decided on the server.

## Server-synced countdown (server sets, clients display)

```lua
--!strict
-- Server: publish the end time once.
local function startCountdown(holder: Instance, seconds: number)
	holder:SetAttribute("EndsAt", workspace:GetServerTimeNow() + seconds)
end

-- Client: display remaining time every frame or every 0.1 s.
local function remaining(holder: Instance): number
	local endsAt = holder:GetAttribute("EndsAt")
	if typeof(endsAt) ~= "number" then
		return 0
	end
	return math.max(0, endsAt - workspace:GetServerTimeNow())
end
```

One attribute change instead of a value every second; every client shows the same time.

## Cooldowns (server)

```lua
--!strict
local readyAt: { [Player]: { [string]: number } } = {}

local function tryUse(player: Player, key: string, cooldown: number): boolean
	local now = workspace:GetServerTimeNow()
	local perPlayer = readyAt[player]
	if not perPlayer then
		perPlayer = {}
		readyAt[player] = perPlayer
	end
	if (perPlayer[key] or 0) > now then
		return false
	end
	perPlayer[key] = now + cooldown
	return true
end

game:GetService("Players").PlayerRemoving:Connect(function(player)
	readyAt[player] = nil
end)
```

For remote spam use the template's token bucket: `template/src/shared/Util/RateLimiter.luau`.

## Raycast from the pointer or touch (client)

```lua
--!strict
local UserInputService = game:GetService("UserInputService")

local function worldHitUnderPointer(maxDistance: number, params: RaycastParams): RaycastResult?
	local camera = workspace.CurrentCamera
	local location = UserInputService:GetMouseLocation() -- viewport coordinates
	local ray = camera:ViewportPointToRay(location.X, location.Y)
	return workspace:Raycast(ray.Origin, ray.Direction * maxDistance, params)
end
```

For touch, pass the touch position from `InputBegan` instead of the mouse location. The server must re-validate anything this chooses (range, line of sight).

## World position to screen for reward effects (client)

```lua
--!strict
local function screenPoint(worldPosition: Vector3): Vector2?
	local camera = workspace.CurrentCamera
	local point, onScreen = camera:WorldToViewportPoint(worldPosition)
	if not onScreen then
		return nil
	end
	return Vector2.new(point.X, point.Y)
end
```

Spawn a UI icon at that point and tween it to the currency counter ([Reward, UI and hatch VFX](../19-vfx/reward-ui-and-hatch-vfx.md)).

## Area query (server)

```lua
--!strict
local function charactersInRadius(center: Vector3, radius: number): { Model }
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { workspace:FindFirstChild("Characters") or workspace }
	local found: { [Model]: boolean } = {}
	local result: { Model } = {}
	for _, part in workspace:GetPartBoundsInRadius(center, radius, params) do
		local model = part:FindFirstAncestorOfClass("Model")
		if model and not found[model] and model:FindFirstChildOfClass("Humanoid") then
			found[model] = true
			table.insert(result, model)
		end
	end
	return result
end
```

## Award a badge (server)

```lua
--!strict
local BadgeService = game:GetService("BadgeService")

local function awardOnce(player: Player, badgeId: number)
	local okHas, has = pcall(BadgeService.UserHasBadgeAsync, BadgeService, player.UserId, badgeId)
	if okHas and has then
		return
	end
	local ok, err = pcall(BadgeService.AwardBadgeAsync, BadgeService, player.UserId, badgeId)
	if not ok then
		warn(`Badge award failed: {err}`)
	end
end
```

`AwardBadge` and `UserHasBadge` are deprecated; use the `Async` versions. Creating more than five badges a day costs Robux (a money decision).

## Policy check with caching (server)

```lua
--!strict
local PolicyService = game:GetService("PolicyService")

local cache: { [Player]: { [string]: any } } = {}

local function policy(player: Player): { [string]: any }?
	local cached = cache[player]
	if cached then
		return cached
	end
	local ok, info = pcall(PolicyService.GetPolicyInfoForPlayerAsync, PolicyService, player)
	if ok and typeof(info) == "table" then
		cache[player] = info
		return info
	end
	return nil -- treat as restricted until known
end

local function paidRandomAllowed(player: Player): boolean
	local info = policy(player)
	return info ~= nil and info.ArePaidRandomItemsRestricted == false
end
```

Template: `template/src/server/Services/Policy.luau` caches these flags for the systems that sell paid items. Rules in [Monetization compliance](../09-monetization/monetization-compliance.md).

## Purchases

Grant developer products only in `MarketplaceService.ProcessReceipt`, record the purchase id in the profile, save, then return `PurchaseGranted`. Do not re-implement this: use `template/src/server/Systems/Purchases.luau` ([Data persistence](../13-building-it-right/data-persistence.md)).

## System message in chat (client)

```lua
--!strict
local TextChatService = game:GetService("TextChatService")

local function systemMessage(text: string)
	local channels = TextChatService:FindFirstChild("TextChannels")
	local general = channels and channels:FindFirstChild("RBXGeneral")
	if general and general:IsA("TextChannel") then
		general:DisplaySystemMessage(text)
	end
end
```

Use for server-wide announcements delivered by a remote ("Alex hatched a Secret pet!"). Any player-provided text must be filtered.

## Invite friends (client)

```lua
--!strict
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")

local function promptInvite()
	local player = Players.LocalPlayer
	local ok, canInvite = pcall(SocialService.CanSendGameInviteAsync, SocialService, player)
	if not ok or not canInvite then
		return
	end
	local options = Instance.new("ExperienceInviteOptions")
	options.PromptMessage = "Bring a friend to the raid!"
	SocialService:PromptGameInvite(player, options)
end
```

Read referral data on join with `GetJoinData()` ([Viral and social mechanics](../21-hits-and-trends/viral-and-social-mechanics.md)).

## Event RSVP and feedback prompts (client)

`SocialService` also offers `PromptRsvpToEventAsync` (lets a player get notified about an upcoming experience event created on the Creator Dashboard) and `PromptFeedbackSubmissionAsync` (an in-game feedback form). Wrap both in `pcall`, call them at natural moments (after a session milestone, in the events board), never on a timer ([Anime community, updates and codes](../20-anime-games/anime-community-updates-and-codes.md)).

## Formatting numbers (shared)

Use `template/src/shared/Util/Format.luau`: `Format.short(1530000)` gives "1.53M", `Format.commas`, `Format.duration`, `Format.percent` and `Format.oneIn` for odds displays.

## For agents

- [ ] Prefer template modules over new code when a recipe points to one.
- [ ] Recipes that touch state run on the server; client recipes only display or request.
- [ ] Deprecated APIs are not used; check the engine reference when unsure.

Sources: [Players](https://create.roblox.com/docs/reference/engine/classes/Players) · [CollectionService](https://create.roblox.com/docs/reference/engine/classes/CollectionService) · [ProximityPrompt](https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt) · [TweenService](https://create.roblox.com/docs/reference/engine/classes/TweenService) · [Workspace](https://create.roblox.com/docs/reference/engine/classes/Workspace) · [Camera](https://create.roblox.com/docs/reference/engine/classes/Camera) · [BadgeService](https://create.roblox.com/docs/reference/engine/classes/BadgeService) · [PolicyService](https://create.roblox.com/docs/reference/engine/classes/PolicyService) · [TextChannel](https://create.roblox.com/docs/reference/engine/classes/TextChannel) · [SocialService](https://create.roblox.com/docs/reference/engine/classes/SocialService)

Related: [API quick reference](../99-reference/api-quick-reference.md) · [Common Luau mistakes](../13-building-it-right/common-luau-mistakes.md) · [Engine limits reference](engine-limits-reference.md) · [Project architecture](../13-building-it-right/project-architecture.md) · [Luau standards](../13-building-it-right/luau-standards.md)
