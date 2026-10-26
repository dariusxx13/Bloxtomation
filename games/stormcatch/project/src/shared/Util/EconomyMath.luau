--!strict
-- Economy formulas (vault: 04-progression-and-economy/economy-math.md). Pure module: used by the server
-- (costs), the client (display) and tests/scripts (balance checks).

local Upgrades = require("../Config/Upgrades")

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

function EconomyMath.minutesToAfford(cost: number, balance: number, incomePerMinute: number): number
	if balance >= cost then
		return 0
	end
	if incomePerMinute <= 0 then
		return math.huge
	end
	return (cost - balance) / incomePerMinute
end

return EconomyMath
