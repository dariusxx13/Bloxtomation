--!strict
-- Catch rules (prototype brief req. 3 and 5): the species tables match req. 5 within 0.01 percentage points,
-- modes and bite waits by weather, the size roll, marks, coin values, the first Rod on the second catch,
-- Stormborn only at the eye during the storm, and no species in a bite payload.
local TestKit = require("./TestKit")
local Catch = require("../src/shared/Util/Catch")
local Fishing = require("../src/shared/Config/Fishing")
local Odds = require("../src/shared/Util/Odds")
local Species = require("../src/shared/Config/Species")
local Upgrades = require("../src/shared/Config/Upgrades")

-- prototype.md req. 5 table (percent): Clear (and the storm away from the eye), Showers, Sea Fog
local BRIEF_PERCENT: { [string]: { [string]: number } } = {
	clear = {
		pebble_minnow = 27.08,
		bobblefin = 22.92,
		sandskipper = 18.75,
		tidetail = 13.54,
		kelpnibbler = 11.46,
		copperscale = 6.25,
	},
	showers = {
		pebble_minnow = 22.13,
		bobblefin = 18.72,
		sandskipper = 15.32,
		tidetail = 11.06,
		kelpnibbler = 9.36,
		copperscale = 5.11,
		splashkin = 12.77,
		pitterpike = 5.53,
	},
	fog = {
		pebble_minnow = 21.96,
		bobblefin = 18.58,
		sandskipper = 15.20,
		tidetail = 10.98,
		kelpnibbler = 9.29,
		copperscale = 10.14,
		hushgill = 10.14,
		lanternfin = 3.72,
	},
}

return function(test: TestKit.Test)
	test("every species table sums to 1 and matches req. 5 within 0.01 percentage points", function()
		for weather, expected in BRIEF_PERCENT do
			local outcomes = Catch.outcomes(weather :: any)
			TestKit.near(Odds.total(outcomes), 1, 1e-12, `{weather} total`)
			local seen = 0
			for _, outcome in outcomes do
				local want = expected[outcome.kind]
				TestKit.truthy(want ~= nil, `{weather} has unexpected {outcome.kind}`)
				TestKit.near(outcome.probability * 100, want, 0.01, `{weather} {outcome.kind}`)
				seen += 1
			end
			local count = 0
			for _ in expected do
				count += 1
			end
			TestKit.equal(seen, count, `{weather} row count`)
		end
		-- the storm rolls the Clear table (away from the eye, and every non-Stormborn eye bite)
		TestKit.equal(Catch.tableFor("storm"), "clear")
	end)

	test("200,000 rolls of the Sea Fog table match its odds (the server's pick function)", function()
		local rng = TestKit.rng(99)
		local counts: { [string]: number } = {}
		local n = 200000
		for _ = 1, n do
			local def = Catch.rollSpecies("fog", rng())
			counts[def.id] = (counts[def.id] or 0) + 1
		end
		for _, outcome in Catch.outcomes("fog") do
			local observed = (counts[outcome.kind] or 0) / n
			TestKit.near(
				observed,
				outcome.probability,
				math.max(outcome.probability * 0.05, 0.001),
				outcome.kind
			)
		end
		TestKit.equal(counts.rumblefin, nil, "the Stormborn is never in a table")
	end)

	test("ring mode and bite wait follow the weather; the storm fishes as Storm at the eye only", function()
		TestKit.equal(Catch.mode("clear", false), "clear")
		TestKit.equal(Catch.mode("showers", false), "showers")
		TestKit.equal(Catch.mode("fog", true), "fog")
		TestKit.equal(Catch.mode("storm", true), "storm")
		TestKit.equal(Catch.mode("storm", false), "clear", "cove_dock and cove_shallows in the storm")
		for mode, range in Fishing.biteWait do
			TestKit.near(Catch.biteWait(mode, 0), range.min, 1e-12, `{mode} min`)
			TestKit.truthy(Catch.biteWait(mode, 0.999999) < range.max, `{mode} max`)
		end
		TestKit.near(
			Catch.biteWait(Catch.mode("storm", false), 0),
			2.0,
			1e-12,
			"storm away from the eye: Clear wait"
		)
		TestKit.truthy(Catch.canHookStormborn("storm", true), "eye in the storm")
		TestKit.truthy(not Catch.canHookStormborn("storm", false), "storm away from the eye")
		TestKit.truthy(not Catch.canHookStormborn("showers", true), "eye outside the storm")
	end)

	test(
		"size roll: clamp 0.5-3.0, mean 1.00, median about 0.97, about 4% at 1.5x or more (sheet §9.3)",
		function()
			local rng = TestKit.rng(4242)
			local n = 200000
			local sum = 0
			local big = 0
			local values: { number } = {}
			for i = 1, n do
				local z = Catch.normal(1 - rng(), rng())
				local factor = Catch.sizeFactor(Species.sizeRoll.sigma, z)
				TestKit.truthy(factor >= 0.5 and factor <= 3.0, "clamped")
				sum += factor
				if factor >= 1.5 then
					big += 1
				end
				values[i] = factor
			end
			table.sort(values)
			TestKit.near(sum / n, 1.0, 0.01, "mean")
			TestKit.near(values[n // 2], 0.969, 0.01, "median")
			TestKit.near(big / n, 0.0401, 0.004, "share at 1.5x or more")
			TestKit.equal(Catch.sizeFactor(0.25, -100), 0.5, "lower clamp")
			TestKit.equal(Catch.sizeFactor(0.25, 100), 3.0, "upper clamp")
			TestKit.equal(Catch.sigmaFor(Species.byId.rumblefin), 0.30, "Stormborn sigma")
			TestKit.equal(Catch.kg(0.8, 1), 0.8)
			TestKit.equal(Catch.kg(180, 1.2345), 222.2)
		end
	)

	test(
		"marks: Drizzled 20% of Showers catches, Misty 15% of Sea Fog, none in Clear or the storm",
		function()
			TestKit.equal(Catch.rollMark("showers", 0.199), "drizzled")
			TestKit.equal(Catch.rollMark("showers", 0.2), nil)
			TestKit.equal(Catch.rollMark("fog", 0.149), "misty")
			TestKit.equal(Catch.rollMark("fog", 0.15), nil)
			TestKit.equal(Catch.rollMark("clear", 0), nil)
			TestKit.equal(Catch.rollMark("storm", 0), nil, "Charged comes from a flash tap or the giant roll")
			TestKit.equal(Catch.markMultiplier("drizzled"), 1.5)
			TestKit.equal(Catch.markMultiplier("misty"), 2)
			TestKit.equal(Catch.markMultiplier("charged"), 3)
			TestKit.equal(Catch.markMultiplier(nil), 1)
		end
	)

	test("value = base x size x mark x 1.14^Rod, nearest whole coin, at least 1", function()
		TestKit.equal(Catch.value(5, 1, nil, 0), 5)
		TestKit.equal(Catch.value(5, 0.5, nil, 0), 3, "2.5 rounds to 3")
		TestKit.equal(Catch.value(5, 1, nil, 1), 6, "5.7 rounds to 6")
		TestKit.equal(Catch.value(20, 1, "drizzled", 0), 30)
		TestKit.equal(Catch.value(20, 1.1, "misty", 2), math.floor(20 * 1.1 * 2 * 1.14 ^ 2 + 0.5))
		TestKit.equal(Catch.value(250, 1, "charged", 0), 750, "a Charged Rumblefin")
		TestKit.equal(Catch.value(0.1, 0.5, nil, 0), 1, "at least 1")
		TestKit.near(Catch.expectedClearValue(0), 690 / 96, 1e-9, "Clear table mean base value")
	end)

	test(
		"the first catch pays 12 and makes the Rod affordable on the second catch, whatever it is",
		function()
			local rod = Upgrades[1]
			TestKit.equal(rod.id, "rod")
			local cheapest = math.huge
			for _, def in Species.list do
				if not def.stormborn then
					cheapest = math.min(cheapest, Catch.value(def.baseCoins, Species.sizeRoll.min, nil, 0))
				end
			end
			TestKit.equal(Fishing.firstCatch.coins, 12)
			TestKit.equal(cheapest, 3, "the smallest possible regular catch at Rod 0")
			TestKit.truthy(Fishing.firstCatch.coins + cheapest >= rod.baseCost, "12 + 3 >= 15")
			TestKit.truthy(
				Fishing.firstCatch.coins < rod.baseCost,
				"not affordable after the first catch alone"
			)
		end
	)

	test("ring steps by tier per mode (req. 3.4)", function()
		TestKit.equal(Catch.steps("clear", "Common"), 1)
		TestKit.equal(Catch.steps("clear", "Uncommon"), 2)
		TestKit.equal(Catch.steps("clear", "Rare"), 3)
		TestKit.equal(Catch.steps("clear", "Epic"), 3)
		TestKit.equal(Catch.steps("showers", "Uncommon"), 1)
		TestKit.equal(Catch.steps("showers", "Epic"), 2)
		TestKit.equal(Catch.steps("fog", "Rare"), 3)
		TestKit.equal(Catch.steps("storm", "Uncommon"), 2)
	end)

	test(
		"a bite payload carries the tier but never the species, size or mark; fog has no ring yet",
		function()
			local fog = Catch.bitePayload({
				lineId = 1,
				mode = "fog",
				tier = "Epic",
				steps = 3,
				arcCenter = 90,
				hookDeadline = 10,
				escapeAt = nil,
			})
			local clear = Catch.bitePayload({
				lineId = 2,
				mode = "clear",
				tier = "Rare",
				steps = 3,
				arcCenter = 200,
				ringStart = 5,
				escapeAt = 17,
			})
			for _, payload in { fog :: any, clear :: any } do
				for _, secret in { "species", "kind", "name", "size", "kg", "mark", "coins" } do
					TestKit.equal(payload[secret], nil, `payload has {secret}`)
				end
			end
			TestKit.equal(fog.ringStart, nil, "Sea Fog: the ring appears only after the hook tap")
			TestKit.equal(fog.opacity, 0.4)
			TestKit.equal(fog.missBudget, 4)
			TestKit.equal(clear.lap, 1.6)
			TestKit.equal(clear.arcWidth, 90)
		end
	)
end
