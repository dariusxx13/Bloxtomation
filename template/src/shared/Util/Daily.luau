--!strict
-- Daily calendar rules, shared by the server (authoritative) and the client (display). Pure module.
-- Rule: missing a day resets the streak bonus, never the calendar position (vault: 10-retention-and-social/retention-systems.md).

local Rewards = require("../Config/Rewards")
local Types = require("../Types")

local Daily = {}

Daily.SECONDS_PER_DAY = 86400

-- UTC day number for a unix time.
function Daily.dayNumber(unixTime: number): number
	return math.floor(unixTime) // Daily.SECONDS_PER_DAY
end

function Daily.available(state: Types.DailyState, today: number): boolean
	return state.lastClaimDay < today
end

-- Coin multiplier for a streak: +streakCoinBonusPerDay per day after the first, capped.
function Daily.streakBonus(streak: number): number
	local extraDays = math.max(streak - 1, 0)
	return 1 + math.min(extraDays * Rewards.streakCoinBonusPerDay, Rewards.maxStreakBonus)
end

-- Claims on `today`. Returns the new state, the calendar day that was claimed (1..7) and the coin
-- multiplier; returns nil when today's reward was already claimed.
function Daily.claim(state: Types.DailyState, today: number): (Types.DailyState?, number, number)
	if not Daily.available(state, today) then
		return nil, 0, 1
	end
	local continued = state.lastClaimDay == today - 1
	local streak = if continued then state.streak + 1 else 1
	local day = math.clamp(state.calendarDay, 1, #Rewards.daily)
	local nextState: Types.DailyState = {
		streak = streak,
		lastClaimDay = today,
		calendarDay = day % #Rewards.daily + 1,
	}
	return nextState, day, Daily.streakBonus(streak)
end

return Daily
