--!strict
-- QA: test commands for playtests (vault: 13-building-it-right/testing-and-qa.md).
-- Allowed in Studio for everyone, and in live servers ONLY for user ids in Config/Game.qaUserIds
-- (empty by default, so live servers reject every command). Every use is logged.
-- Automation (Studio MCP) calls these through the real remote from the Client data model, e.g.
--   game.ReplicatedStorage.Remotes.QACommand:InvokeServer("addCoins", 1000000)
-- because requiring server modules from execute_luau creates separate module instances.

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.Shared
local EconomyMath = require(Shared.Util.EconomyMath)
local Eggs = require(Shared.Config.Eggs)
local Format = require(Shared.Util.Format)
local Game = require(Shared.Config.Game)
local Net = require(Shared.Net)
local OnboardingConfig = require(Shared.Config.Onboarding)
local Odds = require(Shared.Util.Odds)
local Schema = require(Shared.Data.Schema)
local Validate = require(Shared.Util.Validate)
local ZoneConfig = require(Shared.Config.Zones)

local Currency = require(script.Parent.Currency)
local PlayerData = require(script.Parent.PlayerData)
local Purchases = require(script.Parent.Purchases)

local QA = {}

type Result = { ok: boolean, text: string? }
type Command = { studioOnly: boolean, run: (Player, unknown) -> Result }

local MAX_AMOUNT = 1e15
local MAX_SIM_ROLLS = 100000

function QA.allowed(player: Player): boolean
	return RunService:IsStudio() or table.find(Game.qaUserIds, player.UserId) ~= nil
end

local function amountArg(arg: unknown): number?
	if Validate.isFiniteNumber(arg) and (arg :: number) >= 1 and (arg :: number) <= MAX_AMOUNT then
		return math.floor(arg :: number)
	end
	return nil
end

local Commands: { [string]: Command } = {
	-- Read-only summary of the caller's server-side state, for automated playtest assertions.
	state = {
		studioOnly = false,
		run = function(player)
			local data = PlayerData.get(player)
			local session = PlayerData.session(player)
			local derived = PlayerData.derived(player)
			if not data or not session or not derived then
				return { ok = false, text = "not loaded" }
			end
			local zones = {}
			for zoneId, unlocked in data.zonesUnlocked do
				if unlocked then
					table.insert(zones, zoneId)
				end
			end
			table.sort(zones)
			return {
				ok = true,
				text = HttpService:JSONEncode({
					coins = data.coins,
					gems = data.gems,
					rebirths = data.rebirths,
					zones = zones,
					pets = #data.pets,
					equipped = #data.equipped,
					onboardingStep = data.onboardingStep,
					upgrades = data.upgrades,
					hits = data.stats.hits,
					hatches = data.stats.hatches,
					coinsPerHit = derived.coinsPerHit,
					luck = derived.luck,
					restricted = session.randomItemsRestricted,
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
	addGems = {
		studioOnly = false,
		run = function(player, arg)
			local amount = amountArg(arg)
			if not amount then
				return { ok = false, text = "amount 1..1e15" }
			end
			Currency.add(player, "Gems", amount, "QA", "qa")
			return { ok = true, text = `+{Format.short(amount)} Gems` }
		end,
	},
	unlockZones = {
		studioOnly = false,
		run = function(player)
			local data = PlayerData.get(player)
			if not data then
				return { ok = false }
			end
			for _, zone in ZoneConfig do
				data.zonesUnlocked[zone.id] = true
			end
			PlayerData.changed(player, "zonesUnlocked")
			return { ok = true, text = "All zones unlocked" }
		end,
	},
	rebirthReady = {
		studioOnly = false,
		run = function(player)
			local data = PlayerData.get(player)
			if not data then
				return { ok = false }
			end
			local missing = EconomyMath.rebirthCost(data.rebirths) - data.coins
			if missing > 0 then
				Currency.add(player, "Coins", missing, "QA", "qa")
			end
			return { ok = true, text = "Enough coins to rebirth" }
		end,
	},
	grantPass = {
		studioOnly = false,
		run = function(player, arg)
			if type(arg) ~= "string" or not Purchases.qaGrantPass(player, arg) then
				return { ok = false, text = "unknown pass key" }
			end
			return { ok = true, text = `Pass {arg} active this session` }
		end,
	},
	grantProduct = {
		studioOnly = false,
		run = function(player, arg)
			if type(arg) ~= "string" or not Purchases.qaGrantProduct(player, arg) then
				return { ok = false, text = "unknown product key" }
			end
			return { ok = true, text = `Granted {arg} (no receipt)` }
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
	resetDaily = {
		studioOnly = false,
		run = function(player)
			local data = PlayerData.get(player)
			if not data then
				return { ok = false }
			end
			data.daily.lastClaimDay = os.time() // 86400 - 1
			PlayerData.changed(player, "daily")
			return { ok = true, text = "Daily reward available (streak kept)" }
		end,
	},
	skipPlaytime = {
		studioOnly = false,
		run = function(player)
			local session = PlayerData.session(player)
			if not session then
				return { ok = false }
			end
			session.joinedAt -= 3600
			PlayerData.sessionChanged(player, "joinedAt")
			return { ok = true, text = "Session clock +60 minutes" }
		end,
	},
	setRestricted = {
		studioOnly = false,
		run = function(player, arg)
			local session = PlayerData.session(player)
			if not session or not Validate.boolean(arg) then
				return { ok = false, text = "true/false" }
			end
			session.randomItemsRestricted = arg :: boolean
			PlayerData.sessionChanged(player, "randomItemsRestricted")
			return { ok = true, text = `Paid random items restricted: {arg}` }
		end,
	},
	simulateEgg = {
		studioOnly = false,
		run = function(player, arg)
			if type(arg) ~= "string" or not Eggs.byId[arg] then
				return { ok = false, text = "unknown egg id" }
			end
			local derived = PlayerData.derived(player)
			local outcomes = Odds.effective(Eggs.byId[arg], if derived then derived.luck else 1)
			local rng = Random.new()
			local expected: { [string]: number } = {}
			local observed: { [string]: number } = {}
			local order: { string } = {}
			for _, outcome in outcomes do
				if expected[outcome.rarity] == nil then
					table.insert(order, outcome.rarity)
					expected[outcome.rarity] = 0
				end
				expected[outcome.rarity] += outcome.probability
			end
			for _ = 1, MAX_SIM_ROLLS do
				local outcome = Odds.pick(outcomes, rng:NextNumber())
				observed[outcome.rarity] = (observed[outcome.rarity] or 0) + 1
			end
			local lines: { string } = {}
			for _, rarity in order do
				local seen = (observed[rarity] or 0) / MAX_SIM_ROLLS
				table.insert(
					lines,
					`{rarity} {Format.percent(seen)} (shown {Format.percent(expected[rarity])})`
				)
			end
			return { ok = true, text = table.concat(lines, ", ") }
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
			return { ok = true, text = "Profile reset to defaults" }
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
