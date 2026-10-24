--!strict
-- Hatching: server-side egg rolls with luck, hard pity, odds identical to the displayed ones,
-- results saved BEFORE the client plays the reveal, and rare-pull announcements.
-- (vault: 03-rarity-and-rng/*.md and 09-monetization/monetization-compliance.md)

local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local AnalyticsConfig = require(Shared.Config.Analytics)
local Eggs = require(Shared.Config.Eggs)
local Net = require(Shared.Net)
local Odds = require(Shared.Util.Odds)
local Pets = require(Shared.Config.Pets)
local Signal = require(Shared.Util.Signal)
local Types = require(Shared.Types)
local Validate = require(Shared.Util.Validate)

local Analytics = require(script.Parent.Parent.Services.Analytics)
local LiveConfig = require(script.Parent.Parent.Services.LiveConfig)
local Currency = require(script.Parent.Currency)
local PlayerData = require(script.Parent.PlayerData)
local World = require(script.Parent.World)

local Hatching = {}

-- (player, eggId, results)
Hatching.Hatched = Signal.new() :: Signal.Signal<Player, string, { Types.HatchResult }>

local GLOBAL_TOPIC = "RareHatch"
local GLOBAL_MIN_INTERVAL = 10 -- seconds between cross-server announcements from this server
local RANGE_MARGIN = 6

local rng = Random.new()
local lastGlobalPublish = 0

local function rarityOrder(rarity: string): number
	local def = Pets.rarityById[rarity]
	return if def then def.order else 0
end

local function announce(player: Player, results: { Types.HatchResult })
	local minRarity = LiveConfig.get("announceMinRarity") :: string
	for _, result in results do
		local rarity = Pets.rarityById[result.rarity]
		if rarity and rarity.announce ~= "none" and rarityOrder(result.rarity) >= rarityOrder(minRarity) then
			local payload = {
				userId = player.UserId,
				name = player.DisplayName,
				kind = result.kind,
				rarity = result.rarity,
				global = false,
			}
			Net.toAll("Announce", payload)
			if rarity.announce == "global" and os.clock() - lastGlobalPublish >= GLOBAL_MIN_INTERVAL then
				lastGlobalPublish = os.clock()
				task.spawn(function()
					pcall(function()
						MessagingService:PublishAsync(GLOBAL_TOPIC, {
							jobId = game.JobId,
							name = player.DisplayName,
							kind = result.kind,
							rarity = result.rarity,
						})
					end)
				end)
			end
		end
	end
end

local function onHatch(player: Player, eggIdArg: unknown, countArg: unknown): Types.ActionResult
	if
		not Validate.identifier(eggIdArg, 32) or not Validate.integerInRange(countArg, 1, Eggs.maxHatchCount)
	then
		return { ok = false, reason = "invalid" }
	end
	local eggId = eggIdArg :: string
	local count = countArg :: number
	local egg = Eggs.byId[eggId]
	local data = PlayerData.get(player)
	local session = PlayerData.session(player)
	local derived = PlayerData.derived(player)
	if not egg or not data or not session or not derived then
		return { ok = false, reason = "invalid" }
	end
	if not data.zonesUnlocked[egg.zoneId] then
		return { ok = false, reason = "locked" }
	end
	if count > 1 and not session.passes.tripleHatch then
		return { ok = false, reason = "pass" }
	end
	local stand = World.eggStand(eggId)
	if not stand or World.distanceTo(player, stand.Position) > Eggs.hatchRange + RANGE_MARGIN then
		return { ok = false, reason = "far" }
	end
	if #data.pets + count > derived.petCapacity then
		return { ok = false, reason = "full" }
	end
	local price = math.floor(egg.price * count * (LiveConfig.get("hatchPriceMultiplier") :: number) + 0.5)
	if
		not Currency.trySpend(
			player,
			"Coins",
			price,
			Enum.AnalyticsEconomyTransactionType.Shop.Name,
			`egg_{eggId}`
		)
	then
		return { ok = false, reason = "funds" }
	end

	local outcomes = Odds.effective(egg, derived.luck)
	local results: { Types.HatchResult } = {}
	for _ = 1, count do
		local pityCount = (data.pity[eggId] or 0) + 1
		local outcome
		local pity = egg.pity
		if pity and pityCount >= pity.afterRolls then
			outcome = Odds.pickAtLeast(outcomes, pity.rarity, rng:NextNumber())
		else
			outcome = Odds.pick(outcomes, rng:NextNumber())
		end
		if pity and Odds.meetsRarity(outcome.rarity, pity.rarity) then
			pityCount = 0
		end
		data.pity[eggId] = pityCount

		local isNew = data.index[outcome.kind] == nil
		if isNew then
			data.index[outcome.kind] = os.time()
		end
		local owned: Types.OwnedPet = { id = HttpService:GenerateGUID(false), kind = outcome.kind }
		table.insert(data.pets, owned)
		table.insert(results, {
			id = owned.id,
			kind = outcome.kind,
			rarity = outcome.rarity :: any,
			isNew = isNew,
		})
		Analytics.custom(player, AnalyticsConfig.customEvents.hatch, 1, { eggId, outcome.rarity })
	end
	data.stats.hatches += count
	-- Results are in the profile before the client starts the reveal: leaving mid-animation loses nothing.
	PlayerData.changed(player, "pets", "index", "pity", "stats")
	announce(player, results)
	Hatching.Hatched:Fire(player, eggId, results)
	return { ok = true, results = results }
end

function Hatching.init() end

function Hatching.start()
	Net.handle("Hatch", onHatch)
	task.spawn(function()
		pcall(function()
			MessagingService:SubscribeAsync(GLOBAL_TOPIC, function(message)
				local payload = message.Data
				if type(payload) == "table" and payload.jobId ~= game.JobId and #Players:GetPlayers() > 0 then
					Net.toAll("Announce", {
						userId = 0,
						name = tostring(payload.name),
						kind = tostring(payload.kind),
						rarity = tostring(payload.rarity),
						global = true,
					})
				end
			end)
		end)
	end)
end

return Hatching
