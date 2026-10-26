--!strict
-- WeatherSchedule (prototype brief req. 6 and its acceptance criterion): determinism, every timetable
-- boundary, 60 s arrival lead, coverage 0.2778, the sheltered Dock Ripple, storm timing and QA overrides.
-- The expected timetable is typed in here from the brief, independently of Config/Weather, so a config
-- typo fails this test.
local TestKit = require("./TestKit")
local WeatherSchedule = require("../src/shared/Util/WeatherSchedule")

-- prototype.md req. 6 (and GDD v3.1 §13.2), row by row: from, to, cove_dock, cove_shallows, pier_head
local BRIEF = {
	{ 0, 180, "storm", "storm", "storm" },
	{ 180, 200, "clear", "clear", "clear" },
	{ 200, 300, "clear", "clear", "showers" },
	{ 300, 400, "clear", "showers", "clear" },
	{ 400, 420, "clear", "clear", "clear" },
	{ 420, 520, "clear", "fog", "clear" },
	{ 520, 620, "clear", "clear", "fog" },
	{ 620, 640, "clear", "clear", "clear" },
	{ 640, 740, "clear", "clear", "showers" },
	{ 740, 840, "clear", "showers", "clear" },
	{ 840, 900, "clear", "clear", "clear" },
}
local SPOTS = { "cove_dock", "cove_shallows", "pier_head" }

-- A real UTC base: 2026-10-26T12:00:00Z (divisible by 900, so a :00/:15/:30/:45 cycle start).
local BASE = 1793016000

local function expected(ct: number): { string }
	for _, row in BRIEF do
		if ct >= row[1] and ct < row[2] then
			return { row[3] :: string, row[4] :: string, row[5] :: string }
		end
	end
	error("no row for " .. ct)
end

-- Front arrivals computed from the brief's table: a spot turns to showers or fog.
local function briefArrivals(): { { at: number, spot: string } }
	local list = {}
	for index, row in BRIEF do
		local previous = BRIEF[if index == 1 then #BRIEF else index - 1]
		for k = 1, 3 do
			local weather = row[k + 2]
			if (weather == "showers" or weather == "fog") and previous[k + 2] ~= weather then
				table.insert(list, { at = row[1] :: number, spot = SPOTS[k] })
			end
		end
	end
	return list
end

return function(test: TestKit.Test)
	test("cycle starts are clock-aligned at :00, :15, :30 and :45 UTC", function()
		TestKit.equal(BASE % 900, 0, "base is a cycle start")
		TestKit.equal(WeatherSchedule.cycleTime(BASE + 125.5), 125.5)
		TestKit.equal(WeatherSchedule.cycleStart(BASE + 899.9), BASE)
		local storm = WeatherSchedule.stormAt(BASE + 10)
		TestKit.truthy(storm.active, "storm at :00 + 10 s")
		TestKit.equal(storm.startsAt, BASE)
		TestKit.equal(storm.endsAt, BASE + 180)
	end)

	test("the same t gives the same state (pure, periodic, no hidden state)", function()
		local rng = TestKit.rng(2026)
		for _ = 1, 20000 do
			local t = BASE + rng() * 86400 * 3
			local a = WeatherSchedule.stateAt(t)
			local b = WeatherSchedule.stateAt(t)
			local c = WeatherSchedule.stateAt(t + 900 * 37)
			for _, spot in SPOTS do
				TestKit.equal(a[spot], b[spot], `repeat at {t}`)
				TestKit.equal(a[spot], c[spot], `period at {t}`)
				TestKit.equal(a[spot], WeatherSchedule.weatherAt(t, spot), `weatherAt at {t}`)
			end
		end
	end)

	test("every timetable boundary matches the brief (start-inclusive, end-exclusive)", function()
		for _, cycle in { 0, 1, 2 } do
			for _, row in BRIEF do
				local from = BASE + cycle * 900 + (row[1] :: number)
				local to = BASE + cycle * 900 + (row[2] :: number)
				for _, t in { from, from + 0.001, (from + to) / 2, to - 0.001 } do
					local state = WeatherSchedule.stateAt(t)
					local want = expected((t - BASE) % 900)
					for k, spot in SPOTS do
						TestKit.equal(state[spot], want[k], `{spot} at cycleTime {(t - BASE) % 900}`)
					end
				end
			end
		end
		-- 1 s sweep over two cycles against the brief
		for s = 0, 1799 do
			local state = WeatherSchedule.stateAt(BASE + s)
			local want = expected(s % 900)
			for k, spot in SPOTS do
				TestKit.equal(state[spot], want[k], `{spot} at {s}`)
			end
		end
	end)

	test("arrivalsAfter lists exactly the front arrivals, in order", function()
		local brief = briefArrivals()
		TestKit.equal(#brief, 6, "six arrivals per cycle (3 fronts x 2 spots)")
		local listed = WeatherSchedule.arrivalsAfter(BASE - 0.5, 6)
		for i, arrival in brief do
			TestKit.equal(listed[i].at, BASE + arrival.at, `arrival {i} time`)
			TestKit.equal(listed[i].spot, arrival.spot, `arrival {i} spot`)
			local weather = WeatherSchedule.weatherAt(listed[i].at, arrival.spot)
			TestKit.equal(listed[i].weather, weather, `arrival {i} weather`)
		end
		local next = WeatherSchedule.arrivalsAfter(BASE + 740, 3)
		TestKit.equal(next[1].at, BASE + 900 + 200, "strictly after t, wraps to the next cycle")
	end)

	test("every arrival is returned by arrivalsAfter at least 60 s before it happens", function()
		for _, cycle in { 0, 1 } do
			for _, arrival in briefArrivals() do
				local at = BASE + cycle * 900 + arrival.at
				local t = at - 60
				while t < at do
					local found = false
					for _, listed in WeatherSchedule.arrivalsAfter(t, 3) do
						if listed.at == at and listed.spot == arrival.spot then
							found = true
						end
					end
					TestKit.truthy(found, `arrival {arrival.spot} at {at - BASE} missing at t-{at - t}`)
					t += 0.25
				end
			end
		end
	end)

	test("coverage over cycleTime 180-900 is 0.2778 within 0.001", function()
		TestKit.near(WeatherSchedule.coverage(BASE + 180, BASE + 900), 600 / 2160, 1e-9, "exact")
		TestKit.near(WeatherSchedule.coverage(BASE + 180, BASE + 900), 0.2778, 0.001, "brief value")
		-- whole cycles: storm time is excluded, so it is the same share
		TestKit.near(WeatherSchedule.coverage(BASE, BASE + 900 * 8), 0.2778, 0.001, "eight cycles")
		local front, nonStorm = WeatherSchedule.coverageParts(BASE, BASE + 900)
		TestKit.near(front, 600, 1e-9, "front spot-seconds")
		TestKit.near(nonStorm, 720, 1e-9, "non-storm seconds")
		TestKit.equal(WeatherSchedule.coverage(BASE, BASE + 180), 0, "storm only")
	end)

	test("cove_dock is clear or storm at every t", function()
		local t = BASE
		while t < BASE + 1800 do
			local weather = WeatherSchedule.weatherAt(t, "cove_dock")
			TestKit.truthy(weather == "clear" or weather == "storm", `cove_dock {weather} at {t - BASE}`)
			t += 0.25
		end
		for _, arrival in WeatherSchedule.arrivalsAfter(BASE, 60) do
			TestKit.truthy(arrival.spot ~= "cove_dock", "no front arrives at the Dock Ripple")
		end
	end)

	test("the storm runs 0-180 s of every cycle and stormAt points at the next one outside it", function()
		TestKit.truthy(WeatherSchedule.stormAt(BASE + 179.9).active, "179.9 s")
		local after = WeatherSchedule.stormAt(BASE + 180)
		TestKit.truthy(not after.active, "180 s is clear")
		TestKit.equal(after.startsAt, BASE + 900)
		TestKit.equal(after.endsAt, BASE + 1080)
		TestKit.equal(WeatherSchedule.nextChangeAfter(BASE + 850), BASE + 900)
		TestKit.equal(WeatherSchedule.nextChangeAfter(BASE + 180), BASE + 200)
	end)

	test("the longest wait for rain from any join second is 260 s (GDD §13.2)", function()
		local worst = 0
		for join = 0, 899 do
			local t = BASE + 900 + join
			local wait = 0
			while
				WeatherSchedule.weatherAt(t + wait, "cove_shallows") ~= "showers"
				and WeatherSchedule.weatherAt(t + wait, "pier_head") ~= "showers"
			do
				wait += 1
			end
			worst = math.max(worst, wait)
		end
		TestKit.equal(worst, 260)
	end)

	test(
		"QA overrides: forced spot weather beats a forced storm, which beats the timetable and offset",
		function()
			local now = BASE + 250 -- pier_head showers in the timetable
			local w, forced = WeatherSchedule.effective(now, 0, "pier_head", nil)
			TestKit.equal(w, "showers")
			TestKit.equal(forced, false)
			w = WeatherSchedule.effective(now, 100, "pier_head", nil) -- schedule time 350: pier clear
			TestKit.equal(w, "clear", "offset moves the schedule")
			local overrides: { WeatherSchedule.Override } = {
				{ spot = nil, weather = "storm", from = now - 1, to = now + 179 },
				{ spot = "cove_shallows", weather = "fog", from = now - 1, to = now + 119 },
			}
			w, forced = WeatherSchedule.effective(now, 0, "pier_head", overrides)
			TestKit.equal(w, "storm", "forced storm")
			TestKit.equal(forced, true)
			w = WeatherSchedule.effective(now, 0, "cove_shallows", overrides)
			TestKit.equal(w, "fog", "forced spot wins")
			w, forced = WeatherSchedule.effective(now + 200, 0, "pier_head", overrides)
			TestKit.equal(forced, false, "overrides expire (end-exclusive)")
		end
	)
end
