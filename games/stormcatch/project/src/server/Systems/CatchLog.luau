--!strict
-- CatchLog: the server's session catch log for the playtests (prototype brief req. 11). One row per line, with
-- a per-server alias (P1, P2, ...) and never a name or user id. Line time is split by the spot's weather as
-- it happens (Fishing samples it every frame), so QA overrides and offsets are classified when they apply.
-- Pure parts (segments, the twist window, twistStats, CSV) live in Util/TwistLog.
-- Public: alias(player), joinedAt(player), markStep(player, step), markFirstCatch(player), add(row),
-- rows(), twistStats(), csv().

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local OnboardingConfig = require(Shared.Config.Onboarding)
local TwistLog = require(Shared.Util.TwistLog)
local WeatherConfig = require(Shared.Config.Weather)
local WeatherSchedule = require(Shared.Util.WeatherSchedule)

local PlayerData = require(script.Parent.PlayerData)
local Weather = require(script.Parent.Weather)

local CatchLog = {}

local MAX_ROWS = 20000 -- a long playtest is a few thousand lines; this only stops unbounded growth

local rows: { TwistLog.Row } = {}
local infos: { [Player]: TwistLog.PlayerInfo } = {}
local everyone: { TwistLog.PlayerInfo } = {} -- kept after players leave, for pooled stats
local aliasCount = 0

local function register(player: Player, data: any)
	if infos[player] then
		return
	end
	aliasCount += 1
	local now = Weather.now()
	local info: TwistLog.PlayerInfo = { alias = `P{aliasCount}`, joinedAt = now }
	if type(data) == "table" and type(data.onboardingStep) == "number" then
		if data.onboardingStep >= OnboardingConfig.lastStep then
			info.step7At = now -- passed before this session: the window opens 300 s after join
		end
	end
	infos[player] = info
	table.insert(everyone, info)
	print(`[CatchLog] {info.alias} joined`)
end

function CatchLog.alias(player: Player): string
	local info = infos[player]
	return if info then info.alias else "P?"
end

function CatchLog.joinedAt(player: Player): number
	local info = infos[player]
	return if info then info.joinedAt else Weather.now()
end

function CatchLog.markStep(player: Player, step: number, at: number)
	local info = infos[player]
	if not info then
		return
	end
	if step == 6 and info.step6At == nil then
		info.step6At = at
	elseif step == OnboardingConfig.lastStep and info.step7At == nil then
		info.step7At = at
	end
end

function CatchLog.markFirstCatch(player: Player, at: number)
	local info = infos[player]
	if info and info.firstCatchAt == nil then
		info.firstCatchAt = at
	end
end

function CatchLog.add(row: TwistLog.Row)
	if #rows >= MAX_ROWS then
		table.remove(rows, 1)
	end
	table.insert(rows, row)
end

function CatchLog.rows(): { TwistLog.Row }
	return rows
end

-- twistStats for this server session: per alias and pooled (twist test B inputs, GDD v3.1 §2.4).
function CatchLog.twistStats(): { [string]: any }
	local now = Weather.now()
	local offset = Weather.offset()
	local forcedStorms = Weather.forcedStormIntervals()
	-- Timetable coverage over a window, with forceStorm time removed (it is excluded from line time too).
	local function coverageParts(t0: number, t1: number): (number, number)
		local front, nonStorm = WeatherSchedule.coverageParts(t0 + offset, t1 + offset)
		for _, interval in forcedStorms do
			local a = math.max(t0, interval.from)
			local b = math.min(t1, interval.to)
			if b > a then
				local forcedFront, forcedNonStorm = WeatherSchedule.coverageParts(a + offset, b + offset)
				front -= forcedFront
				nonStorm -= forcedNonStorm
			end
		end
		return front, nonStorm
	end
	local stats = TwistLog.stats(everyone, rows, now, coverageParts, #WeatherConfig.spots)
	return {
		players = stats.players,
		pooled = stats.pooled,
		lines = #rows,
		scheduleOffset = offset,
		offsetChanged = Weather.offsetChanged(),
		forcedStorms = #forcedStorms,
		note = "share = under-front / counted line seconds in max(join+300 s, step 7)..now; storm, giant-pull "
			.. "and forced seconds excluded; coverage = timetable share of the 3 spots under fronts, storm and "
			.. "forceStorm time excluded; forceWeather rows are excluded from the share, not from coverage",
	}
end

function CatchLog.csv(): { string }
	return TwistLog.csv(rows)
end

function CatchLog.init() end

function CatchLog.start()
	PlayerData.Loaded:Connect(register)
end

return CatchLog
