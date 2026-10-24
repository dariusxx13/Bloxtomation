--!strict
-- Zones: unlocks the next zone in order when the player pays the gate price.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local AnalyticsConfig = require(Shared.Config.Analytics)
local Net = require(Shared.Net)
local Signal = require(Shared.Util.Signal)
local Types = require(Shared.Types)
local Validate = require(Shared.Util.Validate)
local ZoneConfig = require(Shared.Config.Zones)

local Analytics = require(script.Parent.Parent.Services.Analytics)
local Currency = require(script.Parent.Currency)
local PlayerData = require(script.Parent.PlayerData)

local Zones = {}

-- (player, zoneId)
Zones.Unlocked = Signal.new() :: Signal.Signal<Player, string>

local byId: { [string]: ZoneConfig.ZoneDef } = {}
for _, zone in ZoneConfig do
	byId[zone.id] = zone
end

function Zones.isUnlocked(player: Player, zoneId: string): boolean
	local data = PlayerData.get(player)
	return data ~= nil and data.zonesUnlocked[zoneId] == true
end

local function onUnlock(player: Player, zoneId: unknown): Types.ActionResult
	if not Validate.identifier(zoneId, 32) then
		return { ok = false, reason = "invalid" }
	end
	local id = zoneId :: string
	local zone = byId[id]
	local data = PlayerData.get(player)
	if not zone or not data then
		return { ok = false, reason = "invalid" }
	end
	if data.zonesUnlocked[id] then
		return { ok = false, reason = "owned" }
	end
	local previous = ZoneConfig[zone.order - 1]
	if previous and not data.zonesUnlocked[previous.id] then
		return { ok = false, reason = "locked" }
	end
	if
		not Currency.trySpend(
			player,
			"Coins",
			zone.gateCost,
			Enum.AnalyticsEconomyTransactionType.Shop.Name,
			`zone_{id}`
		)
	then
		return { ok = false, reason = "funds" }
	end
	data.zonesUnlocked[id] = true
	PlayerData.changed(player, "zonesUnlocked")
	Analytics.custom(player, AnalyticsConfig.customEvents.zoneUnlocked, zone.order, { id })
	Zones.Unlocked:Fire(player, id)
	return { ok = true }
end

function Zones.init() end

function Zones.start()
	Net.handle("UnlockZone", onUnlock)
end

return Zones
