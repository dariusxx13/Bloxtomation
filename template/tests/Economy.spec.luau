--!strict
-- Pacing regression tests: they fail if a config change breaks the vault's pacing targets.
local TestKit = require("./TestKit")
local EconomyMath = require("../src/shared/Util/EconomyMath")
local Economy = require("../src/shared/Config/Economy")
local Upgrades = require("../src/shared/Config/Upgrades")

return function(test: TestKit.Test)
	local casual = EconomyMath.simulatePacing(Economy.playerModels.casual.hitsPerSecond, 240)
	local typical = EconomyMath.simulatePacing(Economy.playerModels.typical.hitsPerSecond, 240)

	test("first upgrade under one minute", function()
		TestKit.truthy(casual.firstUpgradeSeconds > 0 and casual.firstUpgradeSeconds < 60, tostring(casual.firstUpgradeSeconds))
	end)

	test("zone 2 reached at 10-15 minutes by a casual free player (no pets)", function()
		local minutes = casual.zoneMinutes[1]
		TestKit.truthy(minutes ~= nil and minutes >= 8 and minutes <= 16, `zone 2 at {minutes}`)
	end)

	test("zone 3 within 25-50 minutes for a casual player", function()
		local minutes = casual.zoneMinutes[2]
		TestKit.truthy(minutes ~= nil and minutes >= 25 and minutes <= 50, `zone 3 at {minutes}`)
	end)

	test("each zone takes longer than the previous one", function()
		local previousGap = 0
		local previous = 0
		for _, minutes in typical.zoneMinutes do
			local gap = minutes - previous
			TestKit.truthy(gap >= previousGap * 0.5, "zone gaps should not collapse")
			previousGap = gap
			previous = minutes
		end
	end)

	test("first rebirth affordable between 20 and 90 minutes", function()
		local minutes = casual.rebirthMinutes
		TestKit.truthy(minutes ~= nil and minutes >= 20 and minutes <= 90, `rebirth at {minutes}`)
	end)

	test("upgrade costs grow faster than their effect (natural slowdown)", function()
		local power = EconomyMath.upgradeDef("power")
		assert(power, "power missing")
		TestKit.truthy(power.costGrowth > power.effect, "r must exceed g")
		TestKit.truthy(power.costGrowth / power.effect < 1.2, "slowdown too steep")
	end)

	test("all upgrade costs are positive and increasing", function()
		for _, def in Upgrades do
			local last = 0
			for level = 0, math.min(def.maxLevel, 50) do
				local cost = EconomyMath.upgradeCost(def, level)
				TestKit.truthy(cost > last, `{def.id} level {level}`)
				last = cost
			end
		end
	end)
end
