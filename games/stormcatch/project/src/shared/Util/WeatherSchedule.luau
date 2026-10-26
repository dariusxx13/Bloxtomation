--!strict
-- WeatherSchedule: the deterministic prototype timetable (prototype brief req. 6; GDD v3.1 §13.2).
-- Pure module. The state depends only on the time t you pass (UTC seconds; callers add the QA offset), so
-- every server and every client computes the same weather for the same moment. Intervals are
-- start-inclusive and end-exclusive. QA overrides (forceWeather, forceStorm) are applied by `effective`.
--   stateAt(t)          -> { [spot]: Weather }
--   weatherAt(t, spot)  -> Weather
--   arrivalsAfter(t, n) -> the next n front arrivals (a spot turning to Showers or Sea Fog), strictly after t
--   stormAt(t)          -> { active, startsAt, endsAt } (the current storm, or the next one)
--   coverage(t0, t1)    -> time-weighted share of the three spots under Showers or Sea Fog, storm time excluded
--   nextChangeAfter(t)  -> the next timetable boundary strictly after t

local Types = require("../Types")
local WeatherConfig = require("../Config/Weather")

local WeatherSchedule = {}

export type Override = {
	spot: string?, -- nil: a forced storm over every spot
	weather: Types.Weather,
	from: number,
	to: number,
}

local CYCLE = WeatherConfig.cycleSeconds
local ROWS = WeatherConfig.timetable
local SPOTS = WeatherConfig.spots

type Arrival = Types.Arrival

local function isFront(weather: Types.Weather): boolean
	return weather == "showers" or weather == "fog"
end
WeatherSchedule.isFront = isFront

local function rowWeather(row: WeatherConfig.Row, spot: string): Types.Weather
	return (row :: any)[spot] :: Types.Weather
end

-- Arrivals inside one cycle, precomputed: (cycle offset, spot, weather), sorted by offset then spot order.
local CYCLE_ARRIVALS: { Arrival } = {}
for index, row in ROWS do
	local previous = ROWS[if index == 1 then #ROWS else index - 1]
	for _, spot in SPOTS do
		local weather: Types.Weather = rowWeather(row, spot)
		if isFront(weather) and rowWeather(previous, spot) ~= weather then
			table.insert(CYCLE_ARRIVALS, { at = row.from, spot = spot, weather = weather })
		end
	end
end

function WeatherSchedule.cycleTime(t: number): number
	return t % CYCLE
end

function WeatherSchedule.cycleStart(t: number): number
	return t - (t % CYCLE)
end

local function rowAt(t: number): WeatherConfig.Row
	local ct = t % CYCLE
	for _, row in ROWS do
		if ct >= row.from and ct < row.to then
			return row
		end
	end
	return ROWS[#ROWS] -- unreachable while the timetable covers [0, CYCLE)
end

function WeatherSchedule.weatherAt(t: number, spot: string): Types.Weather
	return rowWeather(rowAt(t), spot)
end

function WeatherSchedule.stateAt(t: number): { [string]: Types.Weather }
	local row = rowAt(t)
	local state: { [string]: Types.Weather } = {}
	for _, spot in SPOTS do
		state[spot] = rowWeather(row, spot)
	end
	return state
end

function WeatherSchedule.stormAt(t: number): Types.StormInfo
	local start = t - (t % CYCLE)
	local ct = t - start
	local storm = WeatherConfig.storm
	if ct >= storm.from and ct < storm.to then
		return { active = true, startsAt = start + storm.from, endsAt = start + storm.to }
	end
	local nextStart = if ct < storm.from then start + storm.from else start + CYCLE + storm.from
	return { active = false, startsAt = nextStart, endsAt = nextStart + (storm.to - storm.from) }
end

function WeatherSchedule.arrivalsAfter(t: number, n: number): { Arrival }
	local result: { Arrival } = {}
	if n <= 0 or #CYCLE_ARRIVALS == 0 then
		return result
	end
	local start = t - (t % CYCLE)
	while #result < n do
		for _, arrival in CYCLE_ARRIVALS do
			local at = start + arrival.at
			if at > t then
				table.insert(result, { at = at, spot = arrival.spot, weather = arrival.weather })
				if #result >= n then
					break
				end
			end
		end
		start += CYCLE
	end
	return result
end

function WeatherSchedule.nextChangeAfter(t: number): number
	local start = t - (t % CYCLE)
	local ct = t - start
	for _, row in ROWS do
		if row.from > ct then
			return start + row.from
		end
	end
	return start + CYCLE
end

-- Calls fn(from, to, row) for every timetable interval overlapping [t0, t1), clipped to it.
local function forEachRow(t0: number, t1: number, fn: (number, number, WeatherConfig.Row) -> ())
	if t1 <= t0 then
		return
	end
	local start = t0 - (t0 % CYCLE)
	while start < t1 do
		for _, row in ROWS do
			local a = math.max(t0, start + row.from)
			local b = math.min(t1, start + row.to)
			if b > a then
				fn(a, b, row)
			end
		end
		start += CYCLE
	end
end

-- Spot-seconds under a front and non-storm seconds in [t0, t1). coverage = front / (#spots * nonStorm).
function WeatherSchedule.coverageParts(t0: number, t1: number): (number, number)
	local frontSpotSeconds = 0
	local nonStormSeconds = 0
	forEachRow(t0, t1, function(a: number, b: number, row: WeatherConfig.Row)
		local stormRow = false
		local fronts = 0
		for _, spot in SPOTS do
			local weather: Types.Weather = rowWeather(row, spot)
			if weather == "storm" then
				stormRow = true
			elseif isFront(weather) then
				fronts += 1
			end
		end
		if not stormRow then
			nonStormSeconds += b - a
			frontSpotSeconds += (b - a) * fronts
		end
	end)
	return frontSpotSeconds, nonStormSeconds
end

function WeatherSchedule.coverage(t0: number, t1: number): number
	local front, nonStorm = WeatherSchedule.coverageParts(t0, t1)
	if nonStorm <= 0 then
		return 0
	end
	return front / (#SPOTS * nonStorm)
end

-- The weather in effect at a spot at server time `now`, with the QA schedule offset and QA overrides: a forced
-- spot weather wins over a forced storm, which wins over the timetable (read at now + offset). Overrides are
-- in server time. Returns the weather and whether an override produced it.
function WeatherSchedule.effective(
	now: number,
	offset: number,
	spot: string,
	overrides: { Override }?
): (Types.Weather, boolean)
	if overrides then
		local storm = false
		for _, override in overrides do
			if now >= override.from and now < override.to then
				if override.spot == spot then
					return override.weather, true
				elseif override.spot == nil then
					storm = true
				end
			end
		end
		if storm then
			return "storm", true
		end
	end
	return WeatherSchedule.weatherAt(now + offset, spot), false
end

function WeatherSchedule.spots(): { string }
	return table.clone(SPOTS)
end

return WeatherSchedule
