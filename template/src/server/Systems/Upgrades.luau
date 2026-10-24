--!strict
-- Upgrades: buys soft-currency upgrade levels. Price always comes from server config.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local EconomyMath = require(Shared.Util.EconomyMath)
local Net = require(Shared.Net)
local Signal = require(Shared.Util.Signal)
local Types = require(Shared.Types)
local Validate = require(Shared.Util.Validate)

local Currency = require(script.Parent.Currency)
local PlayerData = require(script.Parent.PlayerData)

local Upgrades = {}

-- (player, upgradeId, newLevel)
Upgrades.Bought = Signal.new() :: Signal.Signal<Player, string, number>

local function onBuy(player: Player, upgradeId: unknown): Types.ActionResult
	if not Validate.identifier(upgradeId, 32) then
		return { ok = false, reason = "invalid" }
	end
	local id = upgradeId :: string
	local def = EconomyMath.upgradeDef(id)
	local data = PlayerData.get(player)
	if not def or not data then
		return { ok = false, reason = "invalid" }
	end
	local level = data.upgrades[id] or 0
	if level >= def.maxLevel then
		return { ok = false, reason = "max" }
	end
	local cost = EconomyMath.upgradeCost(def, level)
	if
		not Currency.trySpend(
			player,
			"Coins",
			cost,
			Enum.AnalyticsEconomyTransactionType.Shop.Name,
			`upgrade_{id}`
		)
	then
		return { ok = false, reason = "funds" }
	end
	data.upgrades[id] = level + 1
	PlayerData.changed(player, "upgrades")
	Upgrades.Bought:Fire(player, id, level + 1)
	return { ok = true, level = level + 1 }
end

function Upgrades.init() end

function Upgrades.start()
	Net.handle("BuyUpgrade", onBuy)
end

return Upgrades
