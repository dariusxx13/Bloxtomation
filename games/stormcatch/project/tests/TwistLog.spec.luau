--!strict
-- The catch log's pure half (prototype brief req. 11): segments, the twist window, twistStats with storm and
-- forced seconds excluded, and the CSV with every field the brief lists.
local TestKit = require("./TestKit")
local TwistLog = require("../src/shared/Util/TwistLog")
local WeatherSchedule = require("../src/shared/Util/WeatherSchedule")

local BASE = 1793016000 -- 2026-10-26T12:00:00Z, a cycle start

local function row(
	alias: string,
	weather: string,
	result: string,
	segments: { TwistLog.Segment }
): TwistLog.Row
	local totals = TwistLog.totals(segments)
	return {
		alias = alias,
		sinceJoin = 0,
		spot = "cove_shallows",
		weather = weather,
		mode = weather,
		biteSeconds = 2,
		underFront = weather == "showers" or weather == "fog",
		lineSeconds = totals.front + totals.clear + totals.storm + totals.forced,
		frontSeconds = totals.front,
		clearSeconds = totals.clear,
		stormSeconds = totals.storm,
		forcedSeconds = totals.forced,
		result = result,
		species = "pebble_minnow",
		tier = "Common",
		mark = "",
		kg = 0.8,
		coins = 5,
		misses = 0,
		forced = totals.forced > 0,
		segments = segments,
	}
end

return function(test: TestKit.Test)
	test("segments merge when they continue, and totals add up", function()
		local segments: { TwistLog.Segment } = {}
		TwistLog.add(segments, 0, 1, "front")
		TwistLog.add(segments, 1, 2.5, "front")
		TwistLog.add(segments, 2.5, 3, "clear")
		TwistLog.add(segments, 3, 3, "storm") -- empty: ignored
		TestKit.equal(#segments, 2)
		local totals = TwistLog.totals(segments)
		TestKit.near(totals.front, 2.5, 1e-9)
		TestKit.near(totals.clear, 0.5, 1e-9)
	end)

	test("window seconds exclude storm and forced time and clip to the window", function()
		local segments: { TwistLog.Segment } = {
			{ from = 0, to = 10, kind = "storm" },
			{ from = 10, to = 20, kind = "front" },
			{ from = 20, to = 30, kind = "forced" },
			{ from = 30, to = 40, kind = "clear" },
		}
		local front, counted = TwistLog.windowSeconds(segments, 0, 100)
		TestKit.near(front, 10, 1e-9)
		TestKit.near(counted, 20, 1e-9)
		front, counted = TwistLog.windowSeconds(segments, 15, 35)
		TestKit.near(front, 5, 1e-9)
		TestKit.near(counted, 10, 1e-9)
	end)

	test("the twist window opens at max(join + 300 s, step 7)", function()
		TestKit.equal(TwistLog.windowStart({ alias = "P1", joinedAt = 100 }), nil, "no step 7 yet")
		TestKit.equal(TwistLog.windowStart({ alias = "P1", joinedAt = 100, step7At = 200 }), 400)
		TestKit.equal(TwistLog.windowStart({ alias = "P1", joinedAt = 100, step7At = 650 }), 650)
	end)

	test("twistStats: per alias and pooled share, time-weighted coverage, catches by weather", function()
		local join = BASE + 180 -- joins as the storm ends
		local players: { TwistLog.PlayerInfo } = {
			{
				alias = "P1",
				joinedAt = join,
				firstCatchAt = join + 12,
				step6At = join + 50,
				step7At = join + 130,
			},
			{ alias = "P2", joinedAt = join, firstCatchAt = join + 20 },
		}
		local w0 = join + 300 -- cycleTime 480: cove_shallows fog
		local rows = {
			row("P1", "fog", "landed", { { from = w0, to = w0 + 30, kind = "front" } }),
			row("P1", "clear", "landed", { { from = w0 + 40, to = w0 + 50, kind = "clear" } }),
			row("P1", "showers", "landed", { { from = w0 + 60, to = w0 + 70, kind = "forced" } }),
			row("P1", "clear", "escaped", { { from = join + 10, to = join + 20, kind = "clear" } }), -- before window
			row("P2", "clear", "landed", { { from = w0, to = w0 + 100, kind = "clear" } }),
		}
		local now = w0 + 120
		local stats = TwistLog.stats(players, rows, now, WeatherSchedule.coverageParts, 3)
		local p1 = stats.players[1]
		TestKit.equal(p1.alias, "P1")
		TestKit.equal(p1.windowStart, 300)
		TestKit.equal(p1.windowSeconds, 120)
		TestKit.equal(p1.frontLineSeconds, 30)
		TestKit.equal(p1.lineSeconds, 40, "forced seconds and pre-window seconds excluded")
		TestKit.equal(p1.share, 0.75)
		-- timetable over cycleTime 480-600: fog on one spot for 40 s (to 520), then fog on the pier 80 s
		TestKit.near(p1.coverage :: number, 120 / (3 * 120), 1e-4)
		TestKit.equal(p1.catchesByWeather.fog, 1)
		TestKit.equal(p1.catchesByWeather.clear, 1, "escapes are not catches")
		TestKit.equal(p1.firstCatch, 12)
		TestKit.equal(p1.step6, 50)
		TestKit.equal(p1.step7, 130)
		local p2 = stats.players[2]
		TestKit.equal(p2.windowStart, nil, "no step 7: no window")
		TestKit.equal(p2.lineSeconds, 0)
		TestKit.equal(p2.share, nil)
		TestKit.equal(stats.pooled.share, 0.75)
		TestKit.equal(stats.pooled.catchesByWeather.clear, 2)
		TestKit.near(stats.pooled.coverage :: number, 1 / 3, 1e-4)
	end)

	test("CSV has a header with every field the brief lists and one line per row", function()
		local lines = TwistLog.csv({ row("P1", "fog", "landed", { { from = 0, to = 5, kind = "front" } }) })
		TestKit.equal(#lines, 2)
		for _, field in
			{
				"alias",
				"sinceJoin",
				"spot",
				"weather",
				"underFront",
				"lineSeconds",
				"result",
				"species",
				"tier",
				"mark",
				"kg",
				"coins",
				"misses",
				"forced",
			}
		do
			TestKit.truthy(string.find(lines[1], field, 1, true) ~= nil, `header lacks {field}`)
		end
		TestKit.truthy(string.find(lines[2], "P1,0,cove_shallows,fog,fog,2,true,5,", 1, true) == 1, lines[2])
	end)
end
