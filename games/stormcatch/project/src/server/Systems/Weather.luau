--!strict
-- Weather: runs the prototype timetable (Util/WeatherSchedule) for this server, with the QA schedule offset and
-- QA overrides (forceWeather, forceStorm), and tells clients the current state and the next front arrivals
-- on every change (WeatherState). Clients count down locally from server time. Logs FrontEntered when a
-- player walks into a cell under a front (prototype brief req. 6, 11, 12).
-- Public: now(), effective(spot), storm(), isEyeStorm(), stormId(), payload(), forceWeather(), forceStorm(),
-- setOffset(), offset(), offsetChanged(), Changed signal.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Shared
local AnalyticsConfig = require(Shared.Config.Analytics)
local Net = require(Shared.Net)
local Signal = require(Shared.Util.Signal)
local Types = require(Shared.Types)
local WeatherConfig = require(Shared.Config.Weather)
local WeatherSchedule = require(Shared.Util.WeatherSchedule)

local Analytics = require(script.Parent.Parent.Services.Analytics)
local PlayerData = require(script.Parent.PlayerData)
local World = require(script.Parent.World)

local Weather = {}

-- (payload) after any spot's weather or the storm changes
Weather.Changed = Signal.new() :: Signal.Signal<Types.WeatherStatePayload>

local POLL_SECONDS = 0.2
local FRONT_CHECK_SECONDS = 1
local RESEND_SECONDS = 30 -- a periodic resend, so a client that missed the join message catches up
local ARRIVALS_SHOWN = 3

local offset = 0
local offsetEverChanged = false
local overrides: { WeatherSchedule.Override } = {}
local forcedStorms: { { from: number, to: number } } = {} -- every forceStorm this session (twistStats)
local lastKey = ""
local loggedFronts: { [Player]: { [string]: boolean } } = {}
local cellEpoch: { [string]: number } = {}
local cellLast: { [string]: string } = {}

function Weather.now(): number
	return Workspace:GetServerTimeNow()
end

function Weather.offset(): number
	return offset
end

function Weather.offsetChanged(): boolean
	return offsetEverChanged
end

-- The weather at a spot now (or at `at`), and whether a QA override produced it.
function Weather.effective(spot: string, at: number?): (Types.Weather, boolean)
	return WeatherSchedule.effective(at or Weather.now(), offset, spot, overrides)
end

-- The current or next Great Storm in server time, and whether it is a QA forceStorm.
function Weather.storm(at: number?): (Types.StormInfo, boolean)
	local now = at or Weather.now()
	for _, override in overrides do
		if override.spot == nil and now >= override.from and now < override.to then
			return { active = true, startsAt = override.from, endsAt = override.to }, true
		end
	end
	local storm = WeatherSchedule.stormAt(now + offset)
	return { active = storm.active, startsAt = storm.startsAt - offset, endsAt = storm.endsAt - offset },
		false
end

-- True while the eye (pier_head) fishes as Storm.
function Weather.isEyeStorm(at: number?): boolean
	local weather: Types.Weather = Weather.effective(WeatherConfig.storm.eye, at)
	return weather == "storm"
end

-- An id for the current storm (its start second), for the per-storm caps.
function Weather.stormId(at: number?): number
	local storm = Weather.storm(at)
	return math.floor(storm.startsAt)
end

function Weather.payload(): Types.WeatherStatePayload
	local now = Weather.now()
	local spots: { [string]: Types.Weather } = {}
	local forced: { [string]: boolean } = {}
	for _, spot in WeatherConfig.spots do
		local weather: Types.Weather, isForced: boolean = Weather.effective(spot, now)
		spots[spot] = weather
		forced[spot] = isForced
	end
	local storm, stormForced = Weather.storm(now)
	local arrivals: { Types.Arrival } = {}
	for _, arrival in WeatherSchedule.arrivalsAfter(now + offset, ARRIVALS_SHOWN) do
		table.insert(arrivals, { at = arrival.at - offset, spot = arrival.spot, weather = arrival.weather })
	end
	return {
		serverTime = now,
		offset = offset,
		spots = spots,
		forced = forced,
		storm = storm,
		stormForced = stormForced,
		arrivals = arrivals,
	}
end

local function keyOf(payload: Types.WeatherStatePayload): string
	local parts: { string } = {}
	for _, spot in WeatherConfig.spots do
		table.insert(parts, `{spot}={payload.spots[spot]}{if payload.forced[spot] then "!" else ""}`)
	end
	table.insert(parts, `storm={payload.storm.active}@{math.floor(payload.storm.startsAt)}`)
	table.insert(parts, `offset={offset}`)
	return table.concat(parts, ";")
end

local function broadcastIfChanged(force: boolean?)
	local now = Weather.now()
	for index = #overrides, 1, -1 do
		if overrides[index].to <= now then
			table.remove(overrides, index)
		end
	end
	local payload = Weather.payload()
	local key = keyOf(payload)
	if key == lastKey and not force then
		return
	end
	lastKey = key
	for spot, weather in payload.spots do
		if cellLast[spot] ~= weather then
			cellLast[spot] = weather
			cellEpoch[spot] = (cellEpoch[spot] or 0) + 1
		end
	end
	Net.toAll("WeatherState", payload)
	Weather.Changed:Fire(payload)
end

-- QA: force a spot's weather for at most maxForceSeconds (logged by the QA system; lines there are "forced").
function Weather.forceWeather(spot: string, weather: Types.Weather, seconds: number)
	local now = Weather.now()
	for index = #overrides, 1, -1 do
		if overrides[index].spot == spot then
			table.remove(overrides, index)
		end
	end
	if weather ~= "clear" or seconds > 0 then
		table.insert(overrides, { spot = spot, weather = weather, from = now, to = now + seconds })
	end
	broadcastIfChanged(true)
end

-- QA: a Great Storm over every spot now, in this server only (excluded from twist test B).
function Weather.forceStorm(seconds: number?)
	local now = Weather.now()
	local to = now + (seconds or WeatherConfig.storm.forcedSeconds)
	table.insert(overrides, { spot = nil, weather = "storm", from = now, to = to })
	table.insert(forcedStorms, { from = now, to = to })
	broadcastIfChanged(true)
end

-- Forced storm intervals so far (server time), merged, for excluding them from twist test B.
function Weather.forcedStormIntervals(): { { from: number, to: number } }
	local sorted = table.clone(forcedStorms)
	table.sort(sorted, function(a, b)
		return a.from < b.from
	end)
	local merged: { { from: number, to: number } } = {}
	for _, interval in sorted do
		local last = merged[#merged]
		if last and interval.from <= last.to then
			last.to = math.max(last.to, interval.to)
		else
			table.insert(merged, { from = interval.from, to = interval.to })
		end
	end
	return merged
end

-- QA: shift the timetable for this server (seconds added to the clock before reading the schedule).
function Weather.setOffset(seconds: number)
	offset = seconds
	offsetEverChanged = true
	broadcastIfChanged(true)
end

function Weather.overrideCount(): number
	return #overrides
end

local function checkFronts()
	for _, player in Players:GetPlayers() do
		local position = World.rootPosition(player)
		local cell = position and World.cellAt(position)
		if cell then
			local weather: Types.Weather, forced: boolean = Weather.effective(cell)
			if WeatherSchedule.isFront(weather) then
				local key = `{cell}:{weather}:{cellEpoch[cell] or 0}`
				local logged = loggedFronts[player]
				if not logged then
					logged = {}
					loggedFronts[player] = logged
				end
				if not logged[key] then
					logged[key] = true
					Analytics.custom(
						player,
						AnalyticsConfig.customEvents.frontEntered,
						1,
						{ weather :: string, cell, if forced then "forced" else "natural" }
					)
				end
			end
		end
	end
end

function Weather.init() end

function Weather.start()
	PlayerData.Loaded:Connect(function(player: Player)
		Net.toClient(player, "WeatherState", Weather.payload())
	end)
	Players.PlayerRemoving:Connect(function(player: Player)
		loggedFronts[player] = nil
	end)
	local pollAccumulator = 0
	local frontAccumulator = 0
	local resendAccumulator = 0
	RunService.Heartbeat:Connect(function(dt: number)
		pollAccumulator += dt
		frontAccumulator += dt
		resendAccumulator += dt
		if resendAccumulator >= RESEND_SECONDS then
			resendAccumulator = 0
			pollAccumulator = 0
			broadcastIfChanged(true)
		elseif pollAccumulator >= POLL_SECONDS then
			pollAccumulator = 0
			broadcastIfChanged()
		end
		if frontAccumulator >= FRONT_CHECK_SECONDS then
			frontAccumulator = 0
			checkFronts()
		end
	end)
	broadcastIfChanged(true)
end

return Weather
