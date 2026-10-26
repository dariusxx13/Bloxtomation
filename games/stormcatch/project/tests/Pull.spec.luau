--!strict
-- The Great Storm pull (prototype brief req. 9.4-9.7 and 14): the pull meter from contributors over time to
-- the landing time (solo 45 s, 3 helpers 12.4 s), the helper share (10%, at most 3 per storm), the Charged
-- chance, and the angler's payout being identical with or without helpers.
local TestKit = require("./TestKit")
local Catch = require("../src/shared/Util/Catch")
local Pull = require("../src/shared/Util/Pull")

-- Tap times for `count` helpers tapping every `interval` seconds from `from` until `to`.
local function tappers(count: number, interval: number, from: number, to: number): { { number } }
	local result: { { number } } = {}
	for h = 1, count do
		local taps: { number } = {}
		local t = from + (h - 1) * 0.01
		while t <= to do
			table.insert(taps, t)
			t += interval
		end
		result[h] = taps
	end
	return result
end

return function(test: TestKit.Test)
	test("landing time = 45 / (1 + 0.875 x helpers): 45 s solo, 12.4 s with 3, 10 s with 4", function()
		TestKit.near(Pull.landingSeconds(0), 45, 1e-9, "solo")
		TestKit.near(Pull.landingSeconds(3), 45 / 3.625, 1e-9, "3 helpers")
		TestKit.near(Pull.landingSeconds(3), 12.4, 0.05, "3 helpers, brief value")
		TestKit.near(Pull.landingSeconds(4), 10, 1e-9, "4 helpers")
		TestKit.near(Pull.landingSeconds(7), 45 / 7.125, 1e-9, "7 helpers")
		TestKit.near(Pull.landingSeconds(12), Pull.landingSeconds(7), 1e-9, "at most 7 helpers counted")
		TestKit.near(Pull.anglerRate(), 100 / 45, 1e-12, "angler rate")
	end)

	test("the meter integrated over time: solo lands at 45 s, 3 steady helpers at 12.4 s", function()
		local dt = 1 / 60
		TestKit.near(Pull.simulate({}, dt), 45, 0.05, "solo")
		TestKit.near(
			Pull.simulate(tappers(3, 0.5, 0, 60), dt),
			12.41,
			0.05,
			"3 helpers tapping twice a second"
		)
		TestKit.near(Pull.simulate(tappers(4, 0.3, 0, 60), dt), 10, 0.05, "4 helpers")
		-- helpers who stop tapping stop counting after 1.0 s
		local late = Pull.simulate(tappers(3, 0.5, 0, 5), dt)
		TestKit.truthy(late > 13 and late < 45, `helpers stopping at 5 s: {late}`)
		-- taps further apart than 1.0 s leave gaps where the helper is not active
		local slow = Pull.simulate(tappers(3, 1.5, 0, 60), dt)
		TestKit.truthy(slow > 12.5, `slow tappers: {slow}`)
	end)

	test("active helpers: a tap counts for 1.0 s", function()
		local taps = { { 0.0 }, { 0.5 }, { 2.0 } }
		TestKit.equal(Pull.activeHelpers(taps, 0.9), 2)
		TestKit.equal(Pull.activeHelpers(taps, 1.4), 1)
		TestKit.equal(Pull.activeHelpers(taps, 1.6), 0)
		TestKit.equal(Pull.activeHelpers(taps, 2.5), 1)
	end)

	test("Charged chance: 25%, +5% per friend among the active helpers, capped at 50%", function()
		TestKit.near(Pull.chargedChance(0), 0.25, 1e-12)
		TestKit.near(Pull.chargedChance(1), 0.30, 1e-12)
		TestKit.near(Pull.chargedChance(3), 0.40, 1e-12)
		TestKit.near(Pull.chargedChance(5), 0.50, 1e-12)
		TestKit.near(Pull.chargedChance(7), 0.50, 1e-12)
	end)

	test(
		"helpers get 10% of the giant's value at their own Rod level, minted on top, 3 paid helps a storm",
		function()
			local giant: Pull.Giant = { baseCoins = 250, size = 1.2, mark = nil }
			local angler, shares = Pull.payouts(giant, 4, {
				{ rodLevel = 0, paidHelpsThisStorm = 0 },
				{ rodLevel = 10, paidHelpsThisStorm = 2 },
				{ rodLevel = 10, paidHelpsThisStorm = 3 },
			})
			TestKit.equal(angler, Catch.value(250, 1.2, nil, 4))
			TestKit.equal(shares[1], 30, "10% of 300 at Rod 0")
			TestKit.equal(shares[2], math.floor(250 * 1.2 * 1.14 ^ 10 * 0.10 + 0.5), "own Rod level")
			TestKit.equal(shares[3], 0, "a fourth help in one storm pays nothing (Witnessed only)")
			local charged = { baseCoins = 250, size = 1, mark = "charged" :: any }
			local _, chargedShares = Pull.payouts(charged, 0, { { rodLevel = 0, paidHelpsThisStorm = 0 } })
			TestKit.equal(chargedShares[1], 75, "the share includes the Charged x3")
			-- one helper helping five pulls in one storm is paid three times
			local paid = 0
			for help = 0, 4 do
				local _, s = Pull.payouts(giant, 0, { { rodLevel = 0, paidHelpsThisStorm = help } })
				if s[1] > 0 then
					paid += 1
				end
			end
			TestKit.equal(paid, 3)
		end
	)

	test("the angler's payout is identical with or without helpers", function()
		for _, giant in
			{
				{ baseCoins = 250, size = 0.7, mark = nil },
				{ baseCoins = 250, size = 1.9, mark = "charged" :: any },
			}
		do
			for _, rod in { 0, 7, 30 } do
				local solo = Pull.payouts(giant, rod, {})
				local helpers: { Pull.Helper } = {}
				for h = 1, 7 do
					table.insert(helpers, { rodLevel = h * 3, paidHelpsThisStorm = h % 4 })
					local withHelpers = Pull.payouts(giant, rod, helpers)
					TestKit.equal(withHelpers, solo, `angler with {h} helpers, rod {rod}`)
				end
			end
		end
	end)
end
