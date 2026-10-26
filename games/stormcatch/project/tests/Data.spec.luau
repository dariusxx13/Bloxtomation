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
		TestKit.truthy(migrated.zonesUnlocked.pebble_cove == true, "first zone unlocked")
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

	test("migration 1 -> 2 adds the fishing stats and Pebble Cove, keeping existing values", function()
		local old: any = {
			version = 1,
			coins = 75,
			gems = 3,
			rebirths = 0,
			onboardingStep = 4,
			pets = {},
			equipped = {},
			zonesUnlocked = { meadow = true },
			stats = { hits = 9, totalCoinsEarned = 90 },
			upgrades = { power = 2 },
		}
		local migrated = Migrations.migrate(old)
		TestKit.equal(migrated.version, 2)
		TestKit.equal(migrated.coins, 75, "coins kept")
		TestKit.equal(migrated.stats.hits, 9, "old stats kept")
		TestKit.equal(migrated.stats.catches, 0)
		TestKit.equal(migrated.stats.rainCatches, 0)
		TestKit.equal(migrated.stats.stormsJoined, 0)
		TestKit.equal(migrated.stats.giantsLanded, 0)
		TestKit.equal(migrated.stats.helps, 0)
		TestKit.equal(migrated.zonesUnlocked.pebble_cove, true, "Pebble Cove unlocked")
		TestKit.equal(migrated.zonesUnlocked.meadow, true, "nothing removed")
		TestKit.equal(Schema.check(migrated), nil)
	end)

	test("derived stats: the Rod multiplies coins by 1.14 per level; luck stays 1", function()
		local data = Schema.new(0)
		local base = Stats.derive(data, nil, 0)
		TestKit.equal(base.rodLevel, 0)
		TestKit.equal(base.rodMultiplier, 1)
		TestKit.equal(base.walkSpeed, 16)
		data.upgrades.rod = 3
		local derived = Stats.derive(data, nil, 0)
		TestKit.near(derived.rodMultiplier, 1.14 ^ 3, 1e-12)
		TestKit.equal(derived.luck, 1)
	end)

	test("passes and boosts change nothing in the prototype (no paid luck, no coin multipliers)", function()
		local data = Schema.new(0)
		data.boosts.luck2x = 1000
		data.boosts.coins2x = 1000
		local session = {
			passes = { lucky = true, x2Coins = true },
			serverLuckUntil = 1000,
			sessionStart = 0,
			joinedAt = 0,
			randomItemsRestricted = false,
		}
		local derived = Stats.derive(data, session, 10)
		TestKit.equal(derived.luck, 1)
		TestKit.equal(derived.rodMultiplier, 1)
	end)
end
