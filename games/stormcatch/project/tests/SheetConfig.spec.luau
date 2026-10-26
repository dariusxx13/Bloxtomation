--!strict
-- Config equals economy sheet v2 §14 and prototype brief req. 3-5 and 9 (the brief's acceptance criterion:
-- "Config values equal requirement 5 and economy sheet §14 ..."). Every expected value below is typed in from
-- games/stormcatch/docs/economy-sheet.md §14 (with §3.2, §8, §9.3, §9.4) and specs/prototype.md, so any
-- config drift from the sheet fails here. `lune run scripts/economy-sheet` prints the same values side by side.
local TestKit = require("./TestKit")
local Fishing = require("../src/shared/Config/Fishing")
local Onboarding = require("../src/shared/Config/Onboarding")
local Species = require("../src/shared/Config/Species")
local Upgrades = require("../src/shared/Config/Upgrades")
local WeatherConfig = require("../src/shared/Config/Weather")

-- id, tier, table, weight, base coins, base kg (sheet §14 "Config/Species.luau (prototype)")
local SHEET_SPECIES = {
	{ "pebble_minnow", "Common", "clear", 26, 5, 0.8 },
	{ "bobblefin", "Common", "clear", 22, 5, 0.8 },
	{ "sandskipper", "Common", "clear", 18, 5, 0.8 },
	{ "tidetail", "Uncommon", "clear", 13, 10, 2 },
	{ "kelpnibbler", "Uncommon", "clear", 11, 10, 2 },
	{ "copperscale", "Rare", "clear", 6, 20, 5 },
	{ "splashkin", "Uncommon", "showers", 15, 10, 2 },
	{ "pitterpike", "Rare", "showers", 6.5, 20, 5 },
	{ "hushgill", "Rare", "fog", 6, 20, 5 },
	{ "lanternfin", "Epic", "fog", 2.2, 50, 12 },
	{ "rumblefin", "Mythic", "storm", 0, 250, 180 },
}

return function(test: TestKit.Test)
	test("species rows equal sheet §14 (tier, table, weight, base coins, base kg)", function()
		TestKit.equal(
			#Species.list,
			#SHEET_SPECIES,
			"species count (11: 6 Clear, 2 Showers, 2 Sea Fog, 1 Stormborn)"
		)
		for _, row in SHEET_SPECIES do
			local id = row[1] :: string
			local def = Species.byId[id]
			TestKit.truthy(def ~= nil, `missing {id}`)
			TestKit.equal(def.tier, row[2], `{id} tier`)
			TestKit.equal(def.pool, row[3], `{id} table`)
			TestKit.equal(def.weight, row[4], `{id} weight`)
			TestKit.equal(def.baseCoins, row[5], `{id} base coins`)
			TestKit.equal(def.baseKg, row[6], `{id} base kg`)
			TestKit.equal(def.stormborn, id == "rumblefin", `{id} stormborn`)
		end
		TestKit.equal(Species.tableLuck.fog, 2, "Sea Fog doubles Rare-and-up weights")
		TestKit.equal(Species.tableLuck.clear, 1)
		TestKit.equal(Species.tableLuck.showers, 1)
	end)

	test("bite waits equal sheet §3.2 / §14", function()
		local expected = {
			clear = { 2.0, 5.0 },
			showers = { 1.0, 2.5 },
			fog = { 2.8, 7.0 },
			storm = { 2.0, 4.0 },
		}
		for mode, range in expected do
			TestKit.equal(Fishing.biteWait[mode].min, range[1], `{mode} min`)
			TestKit.equal(Fishing.biteWait[mode].max, range[2], `{mode} max`)
		end
	end)

	test("marks, size roll and scripted catches equal sheet §9.3, §9.4 and §14", function()
		TestKit.equal(Species.markById.drizzled.weather, "showers")
		TestKit.equal(Species.markById.drizzled.chance, 0.20)
		TestKit.equal(Species.markById.drizzled.multiplier, 1.5)
		TestKit.equal(Species.markById.misty.weather, "fog")
		TestKit.equal(Species.markById.misty.chance, 0.15)
		TestKit.equal(Species.markById.misty.multiplier, 2)
		TestKit.equal(Species.markById.charged.multiplier, 3)
		TestKit.equal(Species.sizeRoll.sigma, 0.25)
		TestKit.equal(Species.sizeRoll.stormbornSigma, 0.30)
		TestKit.equal(Species.sizeRoll.min, 0.5)
		TestKit.equal(Species.sizeRoll.max, 3.0)
		TestKit.equal(Fishing.firstCatch.species, "pebble_minnow")
		TestKit.equal(Fishing.firstCatch.kg, 0.8)
		TestKit.equal(Fishing.firstCatch.coins, 12)
		TestKit.equal(Fishing.firstCatch.biteSeconds, 2.0)
		TestKit.equal(Fishing.firstCatch.steps, 1)
		TestKit.equal(Fishing.firstRainCatch.species, "pitterpike")
		TestKit.equal(Fishing.firstRainCatch.mark, "drizzled")
	end)

	test("Stormborn, pull, helper share and Charged equal sheet §8 / §14 and brief req. 9", function()
		TestKit.equal(Species.stormborn.id, "rumblefin")
		TestKit.equal(Species.stormborn.hookChance, 0.04)
		TestKit.equal(Species.stormborn.maxPerPlayerPerStorm, 1)
		local pull = Fishing.pull
		TestKit.equal(pull.radius, 40)
		TestKit.equal(pull.points, 100)
		TestKit.equal(pull.soloSeconds, 45)
		TestKit.equal(pull.helperFactor, 0.875)
		TestKit.equal(pull.maxHelpers, 7)
		TestKit.equal(pull.activeSeconds, 1.0)
		TestKit.equal(pull.helperShare, 0.10)
		TestKit.equal(pull.maxPaidHelpsPerStorm, 3)
		TestKit.equal(pull.chargedBase, 0.25)
		TestKit.equal(pull.chargedPerFriend, 0.05)
		TestKit.equal(pull.chargedCap, 0.50)
		TestKit.equal(pull.maxLingerSeconds, 45)
		TestKit.equal(pull.holdPoseSeconds, 3)
		TestKit.equal(WeatherConfig.flashes.minGap, 6)
		TestKit.equal(WeatherConfig.flashes.maxGap, 9)
		TestKit.equal(WeatherConfig.flashes.glowSeconds, 0.5)
		TestKit.equal(WeatherConfig.flashes.windowSeconds, 0.8)
		TestKit.equal(WeatherConfig.storm.from, 0)
		TestKit.equal(WeatherConfig.storm.to, 180)
		TestKit.equal(WeatherConfig.storm.eye, "pier_head")
		TestKit.equal(WeatherConfig.cycleSeconds, 900)
	end)

	test("Rod equals 15 / 1.28 / 1.14 / max 30 and coinsForStep4 = 15 (sheet §4, §14)", function()
		TestKit.equal(#Upgrades, 1, "only the Rod line exists")
		local rod = Upgrades[1]
		TestKit.equal(rod.id, "rod")
		TestKit.equal(rod.name, "Rod")
		TestKit.equal(rod.baseCost, 15)
		TestKit.equal(rod.costGrowth, 1.28)
		TestKit.equal(rod.effect, 1.14)
		TestKit.equal(rod.maxLevel, 30)
		TestKit.equal(Onboarding.coinsForStep4, 15)
		TestKit.equal(Onboarding.lastStep, 7)
	end)

	test("ring modes, hook window, escape, tap spacing and latency allowance equal brief req. 3", function()
		local ring = Fishing.ring
		local expected = {
			clear = { 1.6, 90, 1, 2, 3, 3, 3, 1 },
			showers = { 1.1, 150, 1, 1, 2, 2, 3, 1 },
			fog = { 1.8, 90, 1, 2, 3, 3, 4, 0.4 },
			storm = { 1.6, 90, 1, 2, 3, 3, 3, 1 },
		}
		for mode, row in expected do
			local def = ring[mode]
			TestKit.equal(def.lap, row[1], `{mode} lap`)
			TestKit.equal(def.arc, row[2], `{mode} arc`)
			TestKit.equal(def.steps.Common, row[3], `{mode} Common steps`)
			TestKit.equal(def.steps.Uncommon, row[4], `{mode} Uncommon steps`)
			TestKit.equal(def.steps.Rare, row[5], `{mode} Rare steps`)
			TestKit.equal(def.steps.Epic, row[6], `{mode} Epic steps`)
			TestKit.equal(def.missBudget, row[7], `{mode} miss budget`)
			TestKit.equal(def.opacity, row[8], `{mode} opacity`)
			TestKit.equal(def.hook, mode == "fog", `{mode} hook`)
		end
		TestKit.equal(Fishing.hookWindow, 3.0)
		TestKit.equal(Fishing.escapeSeconds, 12)
		TestKit.equal(Fishing.tapSpacing, 0.15)
		TestKit.equal(Fishing.latencyMaxPing, 0.25)
		TestKit.equal(Fishing.latencyExtra, 0.06)
		TestKit.equal(Fishing.castRange, 28)
		TestKit.equal(Fishing.castRangeMargin, 8)
		TestKit.equal(Fishing.castCooldown, 0.5)
		TestKit.equal(Fishing.rod.baseLength, 5)
		TestKit.equal(Fishing.rod.lengthPerLevel, 0.4)
		TestKit.equal(Fishing.rod.levelsPerColor, 3)
	end)
end
