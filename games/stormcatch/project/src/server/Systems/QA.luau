--!strict
-- QA: test commands for playtests (vault: 13-building-it-right/testing-and-qa.md; prototype brief req. 11).
-- Allowed in Studio for everyone, and in live servers ONLY for user ids in Config/Game.qaUserIds
-- (empty by default, so live servers reject every command). Every use is logged.
-- Automation (Studio MCP) calls these through the real remote from the Client data model, e.g.
--   game.ReplicatedStorage.Remotes.QACommand:InvokeServer("forceWeather", "cove_shallows fog 120")
-- because requiring server modules from execute_luau creates separate module instances.
-- Commands: state, addCoins <n>, setOnboarding <0..7>, wipeData (Studio only), forceWeather
-- "<spot> <clear|showers|fog> <seconds <= 120>", forceStorm, forceStormborn, setScheduleOffset <seconds>,
-- twistStats, exportLog.

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.Shared
local Format = require(Shared.Util.Format)
local Game = require(Shared.Config.Game)
local Net = require(Shared.Net)
local OnboardingConfig = require(Shared.Config.Onboarding)
local Schema = require(Shared.Data.Schema)
local Stats = require(Shared.Util.Stats)
local Types = require(Shared.Types)
local Validate = require(Shared.Util.Validate)
local WeatherConfig = require(Shared.Config.Weather)

local CatchLog = require(script.Parent.CatchLog)
local Currency = require(script.Parent.Currency)
local Fishing = require(script.Parent.Fishing)
local PlayerData = require(script.Parent.PlayerData)
local Weather = require(script.Parent.Weather)

local QA = {}

type Result = { ok: boolean, text: string? }
type Command = { studioOnly: boolean, run: (Player, unknown) -> Result }

local MAX_AMOUNT = 1e15
local MAX_OFFSET = 7 * 86400
local FORCEABLE: { [string]: Types.Weather } = { clear = "clear", showers = "showers", fog = "fog" }

function QA.allowed(player: Player): boolean
	return RunService:IsStudio() or table.find(Game.qaUserIds, player.UserId) ~= nil
end

local function amountArg(arg: unknown): number?
	if Validate.isFiniteNumber(arg) and (arg :: number) >= 1 and (arg :: number) <= MAX_AMOUNT then
		return math.floor(arg :: number)
	end
	return nil
end

-- Splits "a b c" into at most `max` identifier-safe tokens.
local function tokens(arg: unknown, max: number): { string }?
	if type(arg) ~= "string" or #arg > 80 then
		return nil
	end
	local list: { string } = {}
	for token in string.gmatch(arg, "%S+") do
		if #list >= max or not Validate.identifier(token, 32) then
			return nil
		end
		table.insert(list, token)
	end
	return list
end

local Commands: { [string]: Command } = {
	-- Read-only summary of the caller's server-side state, for automated playtest assertions.
	state = {
		studioOnly = false,
		run = function(player)
			local data = PlayerData.get(player)
			local session = PlayerData.session(player)
			if not data or not session then
				return { ok = false, text = "not loaded" }
			end
			return {
				ok = true,
				text = HttpService:JSONEncode({
					alias = CatchLog.alias(player),
					coins = data.coins,
					onboardingStep = data.onboardingStep,
					rodLevel = Stats.rodLevel(data),
					catches = data.stats.catches,
					rainCatches = data.stats.rainCatches,
					stormsJoined = data.stats.stormsJoined,
					giantsLanded = data.stats.giantsLanded,
					helps = data.stats.helps,
					index = data.index,
					lineOut = Fishing.hasLine(player),
					weather = Weather.payload(),
				}),
			}
		end,
	},
	addCoins = {
		studioOnly = false,
		run = function(player, arg)
			local amount = amountArg(arg)
			if not amount then
				return { ok = false, text = "amount 1..1e15" }
			end
			Currency.add(player, "Coins", amount, "QA", "qa")
			return { ok = true, text = `+{Format.short(amount)} Coins` }
		end,
	},
	setOnboarding = {
		studioOnly = false,
		run = function(player, arg)
			local data = PlayerData.get(player)
			if not data or not Validate.integerInRange(arg, 0, OnboardingConfig.lastStep) then
				return { ok = false, text = `step 0..{OnboardingConfig.lastStep}` }
			end
			data.onboardingStep = arg :: number
			PlayerData.changed(player, "onboardingStep")
			return { ok = true, text = `Onboarding step {arg}` }
		end,
	},
	-- forceWeather "<spot> <clear|showers|fog> <seconds, at most 120>" (this server; lines marked forced)
	forceWeather = {
		studioOnly = false,
		run = function(_player, arg)
			local list = tokens(arg, 3)
			if not list or #list ~= 3 then
				return { ok = false, text = 'usage: forceWeather "<spot> <clear|showers|fog> <seconds>"' }
			end
			local spot, weatherName = list[1], list[2]
			local seconds = tonumber(list[3])
			local found: Types.Weather? = FORCEABLE[weatherName]
			if table.find(WeatherConfig.spots, spot) == nil or found == nil then
				return { ok = false, text = "unknown spot or weather" }
			end
			local weather: Types.Weather = found
			if seconds == nil or not Validate.integerInRange(seconds, 1, WeatherConfig.maxForceSeconds) then
				return { ok = false, text = `seconds 1..{WeatherConfig.maxForceSeconds}` }
			end
			Weather.forceWeather(spot, weather, seconds :: number)
			return { ok = true, text = `{spot} is {weather} for {seconds} s (forced)` }
		end,
	},
	-- A 180 s Great Storm now, in this server only (excluded from twist test B).
	forceStorm = {
		studioOnly = false,
		run = function()
			Weather.forceStorm()
			return { ok = true, text = `Great Storm for {WeatherConfig.storm.forcedSeconds} s (forced)` }
		end,
	},
	-- The caller's next bite at pier_head during a storm hooks a Rumblefin.
	forceStormborn = {
		studioOnly = false,
		run = function(player)
			Fishing.forceStormborn(player)
			return { ok = true, text = "Next storm bite at the Open Pier hooks a Rumblefin" }
		end,
	},
	setScheduleOffset = {
		studioOnly = false,
		run = function(_player, arg)
			if not Validate.integerInRange(arg, -MAX_OFFSET, MAX_OFFSET) then
				return { ok = false, text = `whole seconds, -{MAX_OFFSET}..{MAX_OFFSET}` }
			end
			Weather.setOffset(arg :: number)
			return { ok = true, text = `Schedule offset {arg} s` }
		end,
	},
	twistStats = {
		studioOnly = false,
		run = function()
			local text = HttpService:JSONEncode(CatchLog.twistStats())
			print(`[QA] twistStats {text}`)
			return { ok = true, text = text }
		end,
	},
	exportLog = {
		studioOnly = false,
		run = function()
			local lines = CatchLog.csv()
			print("[QA] exportLog begin")
			for _, line in lines do
				print(line)
			end
			print(`[QA] exportLog end ({#lines - 1} rows)`)
			return { ok = true, text = table.concat(lines, "\n") }
		end,
	},
	wipeData = {
		studioOnly = true,
		run = function(player)
			local data = PlayerData.get(player)
			if not data then
				return { ok = false }
			end
			local fresh = Schema.new(os.time())
			for key in data :: any do
				(data :: any)[key] = nil
			end
			for key, value in fresh :: any do
				(data :: any)[key] = value
			end
			PlayerData.sendSnapshot(player)
			return { ok = true, text = "Profile reset to defaults (rejoin for a fresh onboarding run)" }
		end,
	},
}

local function onCommand(player: Player, name: unknown, arg: unknown): Result
	if not QA.allowed(player) then
		return { ok = false, text = "not allowed" }
	end
	if type(name) ~= "string" then
		return { ok = false, text = "bad command" }
	end
	local command = Commands[name]
	if not command then
		return { ok = false, text = "unknown command" }
	end
	if command.studioOnly and not RunService:IsStudio() then
		return { ok = false, text = "studio only" }
	end
	print(`[QA] {player.Name} ({player.UserId}) ran {name} {tostring(arg)}`)
	return command.run(player, arg)
end

function QA.commandNames(): { string }
	local names = {}
	for name in Commands do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

function QA.init() end

function QA.start()
	Net.handle("QACommand", onCommand)
end

return QA
