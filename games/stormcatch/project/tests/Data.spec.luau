--!strict
-- Profile schema and migrations.
local TestKit = require("./TestKit")
local Schema = require("../src/shared/Data/Schema")
local Migrations = require("../src/shared/Data/Migrations")
local Stats = require("../src/shared/Util/Stats")

return function(test: TestKit.Test)
	test("new profiles are independent deep copies", function()
		local a = Schema.new(100)
		local b = Schema.new(200)
		a.upgrades.power = 5
		table.insert(a.pets, { id = "x", kind = "pebble_pup" })
		TestKit.equal(b.upgrades.power, nil, "upgrades shared")
		TestKit.equal(#b.pets, 0, "pets shared")
		TestKit.equal(a.stats.firstJoin, 100)
		TestKit.equal(Schema.check(a), nil)
	end)

	test("reconcile fills missing fields of old saves", function()
		local old: any =
			{ version = 1, coins = 50, gems = 0, rebirths = 0, onboardingStep = 3, pets = {}, equipped = {} }
		local migrated = Migrations.migrate(old)
		TestKit.equal(migrated.coins, 50, "kept existing value")
		TestKit.truthy(migrated.settings and migrated.settings.music == true, "settings filled")
		TestKit.truthy(migrated.daily and migrated.daily.calendarDay == 1, "daily filled")
		TestKit.truthy(migrated.zonesUnlocked.meadow == true, "first zone unlocked")
	end)

	test("migration steps run in order and bump the version", function()
		local steps = {
			[1] = function(data: any)
				data.renamed = data.oldField
				data.oldField = nil
				return data
			end,
			[2] = function(data: any)
				data.added = true
				return data
			end,
		}
		local data: any = {
			version = 1,
			oldField = 7,
			coins = 0,
			gems = 0,
			rebirths = 0,
			onboardingStep = 0,
			pets = {},
			equipped = {},
		}
		local migrated = Migrations.migrate(data, steps, 3)
		TestKit.equal(migrated.version, 3)
		TestKit.equal(migrated.renamed, 7)
		TestKit.equal(migrated.added, true)
	end)

	test("missing migration step and newer versions are refused", function()
		TestKit.throws(function()
			Migrations.migrate({ version = 1 }, {}, 2)
		end)
		TestKit.throws(function()
			Migrations.migrate({ version = 99 })
		end)
	end)

	test("schema check catches corrupted numbers", function()
		local data: any = Schema.new(0)
		data.coins = 0 / 0
		TestKit.truthy(Schema.check(data) ~= nil)
		data.coins = -5
		TestKit.truthy(Schema.check(data) ~= nil)
	end)

	test("derived stats: pets, rebirths and passes multiply coins; caps hold", function()
		local data = Schema.new(0)
		local base = Stats.derive(data, nil, 0)
		TestKit.equal(base.coinsPerHit, 1)
		TestKit.equal(base.petSlots, 3)
		data.rebirths = 2
		table.insert(data.pets, { id = "a", kind = "sunbeam_fox" })
		table.insert(data.equipped, "a")
		local session = {
			passes = { x2Coins = true, petSlots = true, lucky = true },
			serverLuckUntil = 0,
			socialBonus = 0,
			playtimeClaimed = {},
			sessionStart = 0,
			joinedAt = 0,
			randomItemsRestricted = false,
		}
		local derived = Stats.derive(data, session, 0)
		-- 1 * pet (1 + 1.6) * rebirth (1 + 0.5 * 2) * x2
		TestKit.near(derived.coinsPerHit, 2.6 * 2 * 2, 1e-9)
		TestKit.equal(derived.petSlots, 6)
		TestKit.near(derived.luck, 1.5, 1e-9)
	end)

	test("restricted players get no paid luck", function()
		local data = Schema.new(0)
		data.boosts.luck2x = 1000
		local session = {
			passes = { lucky = true },
			serverLuckUntil = 1000,
			socialBonus = 0,
			playtimeClaimed = {},
			sessionStart = 0,
			joinedAt = 0,
			randomItemsRestricted = true,
		}
		TestKit.equal(Stats.derive(data, session, 10).luck, 1)
	end)
end
