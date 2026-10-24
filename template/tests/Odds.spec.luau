--!strict
local TestKit = require("./TestKit")
local Odds = require("../src/shared/Util/Odds")
local Eggs = require("../src/shared/Config/Eggs")

return function(test: TestKit.Test)
	test("displayed probabilities sum to 1 for every egg and luck level", function()
		for _, egg in Eggs.list do
			for _, luck in { 1, 1.5, 2, 5, 10 } do
				TestKit.near(Odds.total(Odds.effective(egg, luck)), 1, 1e-9, `{egg.id} luck {luck}`)
			end
		end
	end)

	test("luck raises rare odds and lowers common odds", function()
		local egg = Eggs.byId.meadow_egg
		local base = Odds.effective(egg, 1)
		local lucky = Odds.effective(egg, 2)
		TestKit.truthy(lucky[1].probability < base[1].probability, "common should drop")
		TestKit.truthy(lucky[#lucky].probability > base[#base].probability, "legendary should rise")
	end)

	test("one million rolls match designed odds (server pick function)", function()
		local egg = Eggs.byId.meadow_egg
		local outcomes = Odds.effective(egg, 1)
		local counts: { [string]: number } = {}
		local rng = TestKit.rng(12345)
		local n = 1000000
		for _ = 1, n do
			local outcome = Odds.pick(outcomes, rng())
			counts[outcome.kind] = (counts[outcome.kind] or 0) + 1
		end
		for _, outcome in outcomes do
			local observed = (counts[outcome.kind] or 0) / n
			-- within 3% relative or 0.0003 absolute, whichever is larger
			local tolerance = math.max(outcome.probability * 0.03, 0.0003)
			TestKit.near(observed, outcome.probability, tolerance, outcome.kind)
		end
	end)

	test("pickAtLeast only returns the pity rarity or better", function()
		local egg = Eggs.byId.meadow_egg
		local outcomes = Odds.effective(egg, 1)
		local rng = TestKit.rng(7)
		for _ = 1, 1000 do
			local outcome = Odds.pickAtLeast(outcomes, "Legendary", rng())
			TestKit.truthy(Odds.meetsRarity(outcome.rarity, "Legendary"), outcome.rarity)
		end
	end)

	test("tries for chance matches the closed form", function()
		TestKit.near(Odds.triesForChance(0.01, 0.5), 68.97, 0.05)
		TestKit.near(Odds.atLeastOnce(0.01, 100), 0.634, 0.001)
	end)

	test("hard pity is 2-3x the expected rolls for the pity tier", function()
		for _, egg in Eggs.list do
			local pity = egg.pity
			if pity then
				local p = 0
				for _, outcome in Odds.effective(egg, 1) do
					if Odds.meetsRarity(outcome.rarity, pity.rarity) then
						p += outcome.probability
					end
				end
				local expected = 1 / p
				TestKit.truthy(
					pity.afterRolls >= expected * 1.8 and pity.afterRolls <= expected * 3.2,
					`{egg.id}: pity {pity.afterRolls} vs expected {expected}`
				)
			end
		end
	end)
end
