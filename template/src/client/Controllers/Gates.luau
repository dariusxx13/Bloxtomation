--!strict
-- Gates: zone gates are solid for this player until they unlock the zone, then vanish locally.
-- The server still checks zone access on every action and returns trespassers to spawn.

local CollectionService = game:GetService("CollectionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Format = require(Shared.Util.Format)
local Net = require(Shared.Net)
local ZoneConfig = require(Shared.Config.Zones)

local UI = script.Parent.Parent.UI
local Sounds = require(UI.Sounds)

local State = require(script.Parent.State)
local Toasts = require(script.Parent.Toasts)

local Gates = {}

local GATE_TAG = "ZoneGate"

local gates: { [string]: BasePart } = {}

local function zoneDef(zoneId: string): ZoneConfig.ZoneDef?
	for _, zone in ZoneConfig do
		if zone.id == zoneId then
			return zone
		end
	end
	return nil
end

local function apply(gate: BasePart)
	local zoneId = gate:GetAttribute("ZoneId")
	local data = State.data
	if type(zoneId) ~= "string" or not data then
		return
	end
	local unlocked = data.zonesUnlocked[zoneId] == true
	gate.CanCollide = not unlocked
	gate.LocalTransparencyModifier = if unlocked then 1 else 0
	for _, descendant in gate:GetDescendants() do
		if descendant:IsA("ProximityPrompt") or descendant:IsA("SurfaceGui") then
			(descendant :: any).Enabled = not unlocked
		end
	end
end

-- The gate of the first zone the player has not unlocked yet (for the guide).
function Gates.nextGate(): BasePart?
	local data = State.data
	if not data then
		return nil
	end
	for _, zone in ZoneConfig do
		if not data.zonesUnlocked[zone.id] then
			return gates[zone.id]
		end
	end
	return nil
end

local function addGate(instance: Instance)
	if not instance:IsA("BasePart") then
		return
	end
	local zoneId = instance:GetAttribute("ZoneId")
	if type(zoneId) == "string" then
		gates[zoneId] = instance
		apply(instance)
	end
end

local function unlock(zoneId: string)
	local zone = zoneDef(zoneId)
	local data = State.data
	if not zone or not data then
		return
	end
	if data.coins < zone.gateCost then
		Toasts.show(`You need {Format.short(zone.gateCost - data.coins)} more Coins for {zone.name}.`, "info")
		return
	end
	local result = Net.invoke("UnlockZone", zoneId)
	if result.ok then
		Sounds.play("reward")
		Toasts.show(`{zone.name} unlocked! Coins here are worth x{zone.valueMultiplier}.`, "reward")
	elseif result.reason == "locked" then
		Toasts.show("Unlock the previous zone first.", "info")
	end
end

function Gates.init() end

function Gates.start()
	for _, instance in CollectionService:GetTagged(GATE_TAG) do
		addGate(instance)
	end
	CollectionService:GetInstanceAddedSignal(GATE_TAG):Connect(addGate)
	CollectionService:GetInstanceRemovedSignal(GATE_TAG):Connect(function(instance: Instance)
		local zoneId = instance:GetAttribute("ZoneId")
		if type(zoneId) == "string" and gates[zoneId] == instance then
			gates[zoneId] = nil
		end
	end)
	State.Changed:Connect(function(key: string)
		if key == "*" or key == "zonesUnlocked" then
			for _, gate in gates do
				apply(gate)
			end
		end
	end)
	ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt)
		if prompt.Name ~= "UnlockPrompt" then
			return
		end
		local gate = prompt:FindFirstAncestorWhichIsA("BasePart")
		local zoneId = gate and gate:GetAttribute("ZoneId")
		if type(zoneId) == "string" then
			unlock(zoneId)
		end
	end)
end

return Gates
