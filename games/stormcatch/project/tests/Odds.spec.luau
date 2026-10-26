--!strict
-- Drop-table math on the prototype's species tables (the server rolls and any odds display share it).
local TestKit = require("./TestKit")
local Catch = require("../src/shared/Util/Catch")
local Odds = require("../src/shared/Util/Odds")

return function(test: TestKit.Test)
	test("displayed probabilities sum to 1 for every weather table and luck level", function()
		for _, weather in { "clear", "showers", "fog" } do
			local entries: { Odds.Entry } = {}
			for _, outcome in Catch.outcomes(weather :: any) do
				table.insert(
					entries,
					{ kind = outcome.kind, weight = outcome.weight, rarity = outcome.rarity }
				)
			end
			for _, luck in { 1, 1.5, 2, 5 } do
				TestKit.near(Odds.total(Odds.effective(entries, luck)), 1, 1e-9, `{weather} luck {luck}`)
			end
		end
	end)

	test("luck raises Rare-and-up odds and lowers common odds (Sea Fog's doubled weights)", function()
		local base = Odds.effective({
			{ kind = "a", weight = 90, rarity = "Common" },
			{ kind = "b", weight = 10, rarity = "Rare" },
		}, 1)
		local lucky = Odds.effective({
			{ kind = "a", weight = 90, rarity = "Common" },
			{ kind = "b", weight = 10, rarity = "Rare" },
		}, 2)
		TestKit.truthy(lucky[1].probability < base[1].probability, "common should drop")
		TestKit.truthy(lucky[2].probability > base[2].probability, "rare should rise")
		TestKit.near(lucky[2].probability, 20 / 110, 1e-12)
	end)

	test("one million rolls match designed odds (server pick function, Showers table)", function()
		local outcomes = Catch.outcomes("showers")
		local counts: { [string]: number } = {}
		local rng = TestKit.rng(12345)
		local n = 1000000
		for _ = 1, n do
			local outcome = Odds.pick(outcomes, rng())
			counts[outcome.kind] = (counts[outcome.kind] or 0) + 1
		end
		for _, outcome in outcomes do
			local observed = (counts[outcome.kind] or 0) / n
			local tolerance = math.max(outcome.probability * 0.03, 0.0003)
			TestKit.near(observed, outcome.probability, tolerance, outcome.kind)
		end
	end)

	test("pickAtLeast only returns the requested rarity or better", function()
		local outcomes = Catch.outcomes("fog")
		local rng = TestKit.rng(7)
		for _ = 1, 1000 do
			local outcome = Odds.pickAtLeast(outcomes, "Rare", rng())
			TestKit.truthy(Odds.meetsRarity(outcome.rarity, "Rare"), outcome.rarity)
		end
	end)

	test("tries for chance matches the closed form", function()
		TestKit.near(Odds.triesForChance(0.01, 0.5), 68.97, 0.05)
		TestKit.near(Odds.atLeastOnce(0.01, 100), 0.634, 0.001)
		-- Rumblefin: 4.0% per eye bite; about 15-20 eye bites in a storm
		TestKit.near(Odds.atLeastOnce(0.04, 17), 0.50, 0.01)
	end)
end
