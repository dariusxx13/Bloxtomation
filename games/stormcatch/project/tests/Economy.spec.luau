--!strict
-- Rod pacing regression tests (economy sheet v2 §4 and §14): they fail if a config change breaks the
-- prototype's first-session targets.
local TestKit = require("./TestKit")
local Catch = require("../src/shared/Util/Catch")
local EconomyMath = require("../src/shared/Util/EconomyMath")
local Fishing = require("../src/shared/Config/Fishing")
local Upgrades = require("../src/shared/Config/Upgrades")

return function(test: TestKit.Test)
	local rod = EconomyMath.upgradeDef("rod")
	assert(rod, "rod missing")

	test("Rod costs: 15 first, then 19, 25, 31 ... (round(15 x 1.28^L))", function()
		TestKit.equal(EconomyMath.upgradeCost(rod, 0), 15)
		TestKit.equal(EconomyMath.upgradeCost(rod, 1), 19)
		TestKit.equal(EconomyMath.upgradeCost(rod, 2), 25)
		TestKit.equal(EconomyMath.upgradeCost(rod, 3), 31)
		TestKit.equal(EconomyMath.upgradeCost(rod, 29), math.floor(15 * 1.28 ^ 29 + 0.5))
	end)

	test("the first Rod is bought from the second catch (first catch 12 + any catch >= 15)", function()
		local second = Catch.value(5, 0.5, nil, 0) -- the cheapest possible second catch
		TestKit.truthy(Fishing.firstCatch.coins + second >= EconomyMath.upgradeCost(rod, 0))
	end)

	test("upgrade costs grow faster than their effect (natural slowdown)", function()
		TestKit.truthy(rod.costGrowth > rod.effect, "r must exceed g")
		TestKit.truthy(rod.costGrowth / rod.effect < 1.2, "slowdown too steep")
	end)

	test("all upgrade costs are positive and increasing up to the max level", function()
		for _, def in Upgrades do
			local last = 0
			for level = 0, def.maxLevel - 1 do
				local cost = EconomyMath.upgradeCost(def, level)
				TestKit.truthy(cost > last, `{def.id} level {level}`)
				last = cost
			end
		end
	end)

	test("each Rod level needs more catches than the last (cost grows faster than value)", function()
		local previous = 0
		for level = 0, rod.maxLevel - 1 do
			local catches = EconomyMath.upgradeCost(rod, level) / Catch.expectedClearValue(level)
			TestKit.truthy(catches > previous, `level {level}: {catches} catches`)
			previous = catches
		end
	end)
end
