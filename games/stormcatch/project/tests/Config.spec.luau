--!strict
-- Config integrity: ids unique, references valid, values sane.
local TestKit = require("./TestKit")
local Eggs = require("../src/shared/Config/Eggs")
local Pets = require("../src/shared/Config/Pets")
local Zones = require("../src/shared/Config/Zones")
local Products = require("../src/shared/Config/Products")
local Rewards = require("../src/shared/Config/Rewards")
local Onboarding = require("../src/shared/Config/Onboarding")
local Remotes = require("../src/shared/Config/Remotes")
local Codes = require("../src/shared/Config/Codes")

return function(test: TestKit.Test)
	test("every egg references existing pets and zones with positive weights", function()
		local zoneIds: { [string]: boolean } = {}
		for _, zone in Zones do
			zoneIds[zone.id] = true
		end
		for _, egg in Eggs.list do
			TestKit.truthy(zoneIds[egg.zoneId], `egg {egg.id} zone`)
			TestKit.truthy(egg.price > 0, `egg {egg.id} price`)
			for _, entry in egg.entries do
				TestKit.truthy(Pets.byKind[entry.kind] ~= nil, `egg {egg.id} pet {entry.kind}`)
				TestKit.truthy(entry.weight > 0, `egg {egg.id} weight`)
			end
		end
	end)

	test("zones are ordered with increasing gate costs and multipliers", function()
		for i = 2, #Zones do
			TestKit.truthy(Zones[i].gateCost > Zones[i - 1].gateCost, Zones[i].id)
			TestKit.truthy(Zones[i].valueMultiplier > Zones[i - 1].valueMultiplier, Zones[i].id)
			TestKit.equal(Zones[i].order, i)
		end
		TestKit.equal(Zones[1].gateCost, 0, "first zone is free")
		for _, zone in Zones do
			if zone.eggId then
				TestKit.truthy(Eggs.byId[zone.eggId] ~= nil, `zone {zone.id} egg`)
			end
		end
	end)

	test("pet kinds are unique and rarities exist", function()
		local seen: { [string]: boolean } = {}
		for _, pet in Pets.Catalog do
			TestKit.truthy(not seen[pet.kind], `duplicate {pet.kind}`)
			seen[pet.kind] = true
			TestKit.truthy(Pets.rarityById[pet.rarity] ~= nil, pet.kind)
		end
	end)

	test("products and passes have unique keys; non-zero ids are unique", function()
		local keys: { [string]: boolean } = {}
		local ids: { [number]: boolean } = {}
		for _, def in Products.Passes do
			TestKit.truthy(not keys[def.key], def.key)
			keys[def.key] = true
			if def.id ~= 0 then
				TestKit.truthy(not ids[def.id], `duplicate id {def.id}`)
				ids[def.id] = true
			end
		end
		for _, def in Products.Products do
			TestKit.truthy(not keys[def.key], def.key)
			keys[def.key] = true
			if def.id ~= 0 then
				TestKit.truthy(not ids[def.id], `duplicate id {def.id}`)
				ids[def.id] = true
			end
		end
	end)

	test("daily calendar has 7 days and the last is the best", function()
		TestKit.equal(#Rewards.daily, 7)
		local last = Rewards.daily[7]
		for i = 1, 6 do
			TestKit.truthy((last.coinsMinutes or 0) >= (Rewards.daily[i].coinsMinutes or 0), `day {i}`)
		end
		local previous = 0
		for _, gift in Rewards.playtime do
			TestKit.truthy(gift.minutes > previous, "playtime gifts ordered")
			previous = gift.minutes
		end
	end)

	test("onboarding steps are numbered 1..n without gaps", function()
		for i, step in Onboarding.steps do
			TestKit.equal(step.step, i)
		end
		TestKit.equal(Onboarding.lastStep, #Onboarding.steps)
	end)

	test("client-to-server remotes all declare rate limits", function()
		for name, def in Remotes do
			if def.kind == "function" or (def.kind == "event" and def.rate ~= nil) then
				TestKit.truthy(def.rate ~= nil and def.burst ~= nil, name)
			end
		end
	end)

	test("codes are uppercase-unique and within length", function()
		for _, def in Codes.list do
			TestKit.truthy(#def.code <= Codes.maxLength, def.code)
			TestKit.truthy(Codes.byCode[string.upper(def.code)] == def, def.code)
		end
	end)
end
