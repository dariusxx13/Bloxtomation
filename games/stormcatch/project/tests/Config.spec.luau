--!strict
-- Config integrity: ids unique, references valid, values sane.
local TestKit = require("./TestKit")
local Onboarding = require("../src/shared/Config/Onboarding")
local Products = require("../src/shared/Config/Products")
local Rarities = require("../src/shared/Config/Rarities")
local Remotes = require("../src/shared/Config/Remotes")
local Species = require("../src/shared/Config/Species")
local Upgrades = require("../src/shared/Config/Upgrades")
local WeatherConfig = require("../src/shared/Config/Weather")
local WorldLayout = require("../src/shared/Config/WorldLayout")
local Zones = require("../src/shared/Config/Zones")

return function(test: TestKit.Test)
	test("species ids are unique, tiers exist, pools are known, weights and values are positive", function()
		local seen: { [string]: boolean } = {}
		local stormborn = 0
		for _, def in Species.list do
			TestKit.truthy(not seen[def.id], `duplicate {def.id}`)
			seen[def.id] = true
			TestKit.truthy(Rarities.byId[def.tier] ~= nil, `{def.id} tier`)
			TestKit.truthy(def.baseCoins > 0 and def.baseKg > 0, `{def.id} values`)
			if def.stormborn then
				stormborn += 1
				TestKit.equal(def.pool, "storm", def.id)
			else
				TestKit.truthy(def.weight > 0, `{def.id} weight`)
				TestKit.truthy(def.pool ~= "storm", `{def.id} pool`)
			end
		end
		TestKit.equal(stormborn, 1, "Rumblefin is the only Stormborn")
		TestKit.truthy(Species.byId[Species.stormborn.id] ~= nil, "stormborn id")
	end)

	test("one free zone (Pebble Cove) and the layout uses it", function()
		TestKit.equal(#Zones, 1)
		TestKit.equal(Zones[1].id, WorldLayout.zoneId)
		TestKit.equal(Zones[1].gateCost, 0, "first zone is free")
		TestKit.equal(Zones[1].nodeCount, #WorldLayout.spots)
	end)

	test("products and passes have unique keys; every id is 0 so nothing can be bought", function()
		local keys: { [string]: boolean } = {}
		for _, def in Products.Passes do
			TestKit.truthy(not keys[def.key], def.key)
			keys[def.key] = true
			TestKit.equal(def.id, 0, `pass {def.key} id`)
		end
		for _, def in Products.Products do
			TestKit.truthy(not keys[def.key], def.key)
			keys[def.key] = true
			TestKit.equal(def.id, 0, `product {def.key} id`)
		end
		TestKit.equal(next(Products.productById), nil, "no product can match a receipt")
	end)

	test("onboarding steps are numbered 1..n without gaps and use known guides", function()
		local guides = { none = true, node = true, shop = true, upgradePower = true, weather = true }
		for i, step in Onboarding.steps do
			TestKit.equal(step.step, i)
			TestKit.truthy(guides[step.guide], step.name)
		end
		TestKit.equal(Onboarding.lastStep, #Onboarding.steps)
		TestKit.truthy(Upgrades[1].id == Onboarding.upgradeForStep6, "step 6 names the Rod")
	end)

	test("client-to-server remotes all declare rate limits; the fishing limits are the brief's", function()
		for name, def in Remotes do
			if def.kind == "function" or (def.kind == "event" and def.rate ~= nil) then
				TestKit.truthy(def.rate ~= nil and def.burst ~= nil, name)
			end
		end
		local expected = { Cast = { 2, 3 }, HookTap = { 4, 6 }, ReelTap = { 8, 12 }, PullTap = { 6, 10 } }
		for name, limits in expected do
			TestKit.equal(Remotes[name].rate, limits[1], `{name} rate`)
			TestKit.equal(Remotes[name].burst, limits[2], `{name} burst`)
		end
		TestKit.equal(Remotes.Hit, nil, "the template's Hit remote is retired")
	end)

	test("the weather timetable covers the whole cycle without gaps and names every spot", function()
		local t = 0
		for _, row in WeatherConfig.timetable do
			TestKit.equal(row.from, t, "contiguous")
			TestKit.truthy(row.to > row.from, "positive length")
			t = row.to
			for _, spotId in WeatherConfig.spots do
				TestKit.truthy((row :: any)[spotId] ~= nil, spotId)
			end
		end
		TestKit.equal(t, WeatherConfig.cycleSeconds)
		for _, s in WorldLayout.spots do
			TestKit.truthy(table.find(WeatherConfig.spots, s.id) ~= nil, s.id)
		end
	end)
end
