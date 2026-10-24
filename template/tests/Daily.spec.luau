--!strict
-- Daily calendar rules (Util/Daily): streaks, gentle resets, wrap-around, one claim per UTC day.
local TestKit = require("./TestKit")
local Daily = require("../src/shared/Util/Daily")
local Rewards = require("../src/shared/Config/Rewards")
local Types = require("../src/shared/Types")

local function fresh(): Types.DailyState
	return { streak = 0, lastClaimDay = 0, calendarDay = 1 }
end

return function(test: TestKit.Test)
	test("day number is UTC midnight-based", function()
		TestKit.equal(Daily.dayNumber(0), 0)
		TestKit.equal(Daily.dayNumber(86399.9), 0)
		TestKit.equal(Daily.dayNumber(86400), 1)
	end)

	test("first claim gives day 1 with no streak bonus", function()
		local state, day, bonus = Daily.claim(fresh(), 20000)
		assert(state)
		TestKit.equal(day, 1)
		TestKit.equal(bonus, 1)
		TestKit.equal(state.streak, 1)
		TestKit.equal(state.calendarDay, 2)
		TestKit.equal(state.lastClaimDay, 20000)
	end)

	test("only one claim per day", function()
		local state = Daily.claim(fresh(), 20000)
		assert(state)
		TestKit.equal(Daily.available(state, 20000), false)
		TestKit.equal((Daily.claim(state, 20000)), nil)
		TestKit.equal(Daily.available(state, 20001), true)
	end)

	test("consecutive days build the streak and its bonus", function()
		local state: Types.DailyState = fresh()
		local bonus = 1
		for today = 1, 5 do
			local nextState, _, nextBonus = Daily.claim(state, 20000 + today)
			assert(nextState)
			state = nextState
			bonus = nextBonus
		end
		TestKit.equal(state.streak, 5)
		TestKit.near(bonus, 1 + 4 * Rewards.streakCoinBonusPerDay, 1e-9)
	end)

	test("a missed day resets the streak but not the calendar", function()
		local state = Daily.claim(fresh(), 100)
		assert(state)
		state = Daily.claim(state, 101)
		assert(state)
		TestKit.equal(state.calendarDay, 3)
		local afterGap, day = Daily.claim(state, 105)
		assert(afterGap)
		TestKit.equal(afterGap.streak, 1)
		TestKit.equal(day, 3, "calendar continues where the player left off")
	end)

	test("the calendar wraps after the last day", function()
		local state: Types.DailyState = { streak = 6, lastClaimDay = 99, calendarDay = #Rewards.daily }
		local nextState, day = Daily.claim(state, 100)
		assert(nextState)
		TestKit.equal(day, #Rewards.daily)
		TestKit.equal(nextState.calendarDay, 1)
	end)

	test("streak bonus is capped", function()
		TestKit.near(Daily.streakBonus(1000), 1 + Rewards.maxStreakBonus, 1e-9)
		TestKit.equal(Daily.streakBonus(0), 1)
	end)

	test("a corrupted calendar position is clamped", function()
		local _, day = Daily.claim({ streak = 0, lastClaimDay = 0, calendarDay = 99 }, 10)
		TestKit.equal(day, #Rewards.daily)
	end)
end
