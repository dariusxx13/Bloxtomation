--!strict
-- Economy formulas and a pacing simulator (vault: 04-progression-and-economy/economy-math.md).
-- Pure module: used by the server (costs), the client (display) and tests/scripts (balance checks).

local Economy = require("../Config/Economy")
local Upgrades = require("../Config/Upgrades")
local Zones = require("../Config/Zones")

local EconomyMath = {}

local upgradeById: { [string]: Upgrades.UpgradeDef } = {}
for _, def in Upgrades do
	upgradeById[def.id] = def
end

function EconomyMath.upgradeDef(id: string): Upgrades.UpgradeDef?
	return upgradeById[id]
end

-- Cost to buy the next level when currently at `level`.
function EconomyMath.upgradeCost(def: Upgrades.UpgradeDef, level: number): number
	return math.floor(def.baseCost * def.costGrowth ^ level + 0.5)
end

-- Power multiplier on coins per hit for a power level.
function EconomyMath.powerMultiplier(level: number): number
	local def = upgradeById.power
	return if def then def.effect ^ level else 1
end

function EconomyMath.rebirthCost(rebirths: number): number
	return math.floor(Economy.rebirthBaseCost * Economy.rebirthCostGrowth ^ rebirths + 0.5)
end

function EconomyMath.rebirthMultiplier(rebirths: number): number
	return 1 + Economy.rebirthMultiplierPerRebirth * rebirths
end

function EconomyMath.minutesToAfford(cost: number, balance: number, incomePerMinute: number): number
	if balance >= cost then
		return 0
	end
	if incomePerMinute <= 0 then
		return math.huge
	end
	return (cost - balance) / incomePerMinute
end

export type PacingResult = {
	firstUpgradeSeconds: number,
	zoneMinutes: { number }, -- minutes at which zone 2, 3, ... were unlocked
	rebirthMinutes: number?, -- minutes at which the first rebirth became affordable
	powerLevelAtEnd: number,
}

-- Simulates a non-paying player without pets who taps at `hitsPerSecond`, buys Power whenever the next
-- zone gate is still further away than the upgrade, and saves for gates otherwise.
-- Deliberately conservative (no pets, no rewards) so real players progress at least this fast.
function EconomyMath.simulatePacing(hitsPerSecond: number, maxMinutes: number): PacingResult
	local powerDef = upgradeById.power
	assert(powerDef, "power upgrade missing")
	local t = 0
	local coins = 0
	local level = 0
	local zoneIndex = 1
	local result: PacingResult = {
		firstUpgradeSeconds = -1,
		zoneMinutes = {},
		rebirthMinutes = nil,
		powerLevelAtEnd = 0,
	}
	local rebirthCost = EconomyMath.rebirthCost(0)
	while t < maxMinutes * 60 do
		local zone = Zones[zoneIndex]
		local income = hitsPerSecond
			* Economy.baseCoinsPerHit
			* EconomyMath.powerMultiplier(level)
			* zone.valueMultiplier
		coins += income
		t += 1
		if result.rebirthMinutes == nil and coins >= rebirthCost then
			result.rebirthMinutes = t / 60
		end
		local nextZone = Zones[zoneIndex + 1]
		if nextZone and coins >= nextZone.gateCost then
			coins -= nextZone.gateCost
			zoneIndex += 1
			table.insert(result.zoneMinutes, t / 60)
		else
			local cost = EconomyMath.upgradeCost(powerDef, level)
			local gateSeconds = if nextZone then (nextZone.gateCost - coins) / income else math.huge
			if coins >= cost and level < powerDef.maxLevel and gateSeconds > cost / income then
				coins -= cost
				level += 1
				if result.firstUpgradeSeconds < 0 then
					result.firstUpgradeSeconds = t
				end
			end
		end
	end
	result.powerLevelAtEnd = level
	return result
end

return EconomyMath
