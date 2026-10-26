--!strict
-- Derives gameplay numbers from persisted data + session state. Pure module used by both sides:
-- the server result is authoritative; the client uses it only for display.
-- Prototype rule (brief req. 5): coins = base x size x mark x 1.14^(Rod level). There is no other coin
-- multiplier and no luck besides natural Sea Fog's (in Util/Catch), so passes and boosts change nothing here.

local Catch = require("./Catch")
local Economy = require("../Config/Economy")
local Types = require("../Types")

local Stats = {}

function Stats.rodLevel(data: Types.ProfileData): number
	return data.upgrades.rod or 0
end

function Stats.derive(
	data: Types.ProfileData,
	_session: Types.SessionState?,
	_now: number
): Types.DerivedStats
	local rodLevel = Stats.rodLevel(data)
	return {
		rodLevel = rodLevel,
		rodMultiplier = Catch.rodMultiplier(rodLevel),
		luck = 1,
		walkSpeed = Economy.baseWalkSpeed,
	}
end

-- Converts "minutes of income" (product grants; none are sold in the prototype) into coins: the expected
-- Clear catch at the player's Rod level x catches per minute x minutes (economy sheet §3.1).
function Stats.coinsForMinutes(
	_data: Types.ProfileData,
	derived: Types.DerivedStats,
	minutes: number,
	catchesPerMinute: number
): number
	return math.floor(Catch.expectedClearValue(derived.rodLevel) * catchesPerMinute * minutes)
end

return Stats
