--!strict
-- Rebirth: trades coins and resettable upgrades for a permanent multiplier (vault: 04-progression-and-economy/rebirth-and-prestige.md).
-- Never resets pets, the collection index, gems, purchases or zones (zones are configurable).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local AnalyticsConfig = require(Shared.Config.Analytics)
local Economy = require(Shared.Config.Economy)
local EconomyMath = require(Shared.Util.EconomyMath)
local Net = require(Shared.Net)
local Signal = require(Shared.Util.Signal)
local Types = require(Shared.Types)
local UpgradeConfig = require(Shared.Config.Upgrades)
local ZoneConfig = require(Shared.Config.Zones)

local Analytics = require(script.Parent.Parent.Services.Analytics)
local Currency = require(script.Parent.Currency)
local PlayerData = require(script.Parent.PlayerData)

local Rebirth = {}

-- (player, newRebirthCount)
Rebirth.Done = Signal.new() :: Signal.Signal<Player, number>

local function onRebirth(player: Player): Types.ActionResult
	local data = PlayerData.get(player)
	if not data then
		return { ok = false, reason = "invalid" }
	end
	local cost = EconomyMath.rebirthCost(data.rebirths)
	if data.coins < cost then
		return { ok = false, reason = "funds" }
	end
	Currency.resetCoins(player, Enum.AnalyticsEconomyTransactionType.Gameplay.Name, "rebirth")
	for _, def in UpgradeConfig do
		if def.resetsOnRebirth then
			data.upgrades[def.id] = nil
		end
	end
	if not Economy.rebirthKeepsZones then
		data.zonesUnlocked = { [ZoneConfig[1].id] = true }
		PlayerData.changed(player, "zonesUnlocked")
	end
	data.rebirths += 1
	PlayerData.changed(player, "upgrades", "rebirths")
	Analytics.custom(player, AnalyticsConfig.customEvents.rebirth, data.rebirths)
	Rebirth.Done:Fire(player, data.rebirths)
	return { ok = true, rebirths = data.rebirths }
end

function Rebirth.init() end

function Rebirth.start()
	Net.handle("Rebirth", onRebirth)
end

return Rebirth
