--!strict
-- The player profile schema: current version and defaults. Pure module.
-- Rules (vault: 13-building-it-right/data-persistence.md): bump VERSION for any shape change and
-- add a step in Migrations.luau; never remove or rename fields without a migration.

local Types = require("../Types")
local TableUtil = require("../Util/TableUtil")

local Schema = {}

Schema.VERSION = 1

local DEFAULT: Types.ProfileData = {
	version = 1,
	coins = 0,
	gems = 0,
	upgrades = {},
	zonesUnlocked = { meadow = true },
	pets = {},
	equipped = {},
	index = {},
	pity = {},
	rebirths = 0,
	daily = { streak = 0, lastClaimDay = 0, calendarDay = 1 },
	onboardingStep = 0,
	codesRedeemed = {},
	receipts = {},
	oneTimeProducts = {},
	boosts = {},
	settings = { music = true, sfx = true, reduceMotion = false, hideOthersPets = false },
	stats = {
		hits = 0,
		hatches = 0,
		sessions = 0,
		firstJoin = 0,
		lastLogout = 0,
		totalCoinsEarned = 0,
		playSeconds = 0,
	},
}

-- A fresh profile. Always a deep copy: never hand out the shared default table.
function Schema.new(now: number): Types.ProfileData
	local data = TableUtil.deepCopy(DEFAULT)
	data.version = Schema.VERSION
	data.stats.firstJoin = now
	return data
end

-- Adds any fields missing from older saves (after migrations ran).
function Schema.reconcile(data: Types.ProfileData)
	TableUtil.reconcile(data :: any, DEFAULT :: any)
end

-- Structural sanity check used before saving. Returns an error message or nil.
function Schema.check(data: any): string?
	if type(data) ~= "table" then
		return "profile is not a table"
	end
	if type(data.version) ~= "number" then
		return "missing version"
	end
	for _, field in { "coins", "gems", "rebirths", "onboardingStep" } do
		local value = data[field]
		if type(value) ~= "number" or value ~= value or value == math.huge or value < 0 then
			return `invalid number field {field}`
		end
	end
	if type(data.pets) ~= "table" or type(data.equipped) ~= "table" then
		return "invalid pets"
	end
	return nil
end

return Schema
