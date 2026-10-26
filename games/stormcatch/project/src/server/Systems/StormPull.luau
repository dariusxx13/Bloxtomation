--!strict
-- StormPull: the Great Storm's lightning and co-op pull (prototype brief req. 9; GDD v3.1 §4.3).
-- Lightning: server-timed flashes every 6-9 s while the eye is in storm, announced to every client ahead of
-- time (StormState) so all see the same flash; Fishing asks flashTap() whether a landing tap was on a flash.
-- Pull: when Fishing hooks a Stormborn, the meter fills from the angler (always) and active helpers within
-- 40 studs (PullTap in the last 1.0 s). A giant hooked before the storm ends always lands. On landing the
-- Charged chance is rolled (25% + 5% per friend among the active helpers, cap 50%), the angler is paid by
-- Fishing's callback, helpers get 10% at their own Rod level (3 paid helps a storm) and a Witnessed card,
-- and the whole server gets one banner. Every rule's maths is Util/Pull (unit-tested).
-- Public: rollHook(), begin(), cancel(), isAngler(), flashTap(), join(), activePulls().

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.Shared
local AnalyticsConfig = require(Shared.Config.Analytics)
local Fishing = require(Shared.Config.Fishing)
local Net = require(Shared.Net)
local Pull = require(Shared.Util.Pull)
local Ring = require(Shared.Util.Ring)
local Signal = require(Shared.Util.Signal)
local Species = require(Shared.Config.Species)
local Stats = require(Shared.Util.Stats)
local Types = require(Shared.Types)
local WeatherConfig = require(Shared.Config.Weather)

local Analytics = require(script.Parent.Parent.Services.Analytics)
local LiveConfig = require(script.Parent.Parent.Services.LiveConfig)
local CatchLog = require(script.Parent.CatchLog)
local Currency = require(script.Parent.Currency)
local PlayerData = require(script.Parent.PlayerData)
local Social = require(script.Parent.Social)
local Weather = require(script.Parent.Weather)
local World = require(script.Parent.World)

local StormPull = {}

export type LandedResult = { mark: Types.MarkId?, coins: number, helpers: number, charged: boolean }

-- (angler, helpers, charged)
StormPull.Landed = Signal.new() :: Signal.Signal<Player, number, boolean>

type Helper = { lastTap: number, counted: boolean }

type PullRecord = {
	id: number,
	angler: Player,
	spot: string,
	startedAt: number,
	progress: number,
	rate: number,
	active: number,
	size: number,
	kg: number,
	stormId: number,
	helpers: { [Player]: Helper },
	onLanded: (LandedResult) -> (),
}

local P = Fishing.pull
local FLASHES = WeatherConfig.flashes
local BROADCAST_SECONDS = 0.25
local KEEP_FLASHES = 8

local rng = Random.new()
local pulls: { [number]: PullRecord } = {}
local nextPullId = 0
local hookedStorm: { [Player]: number } = {} -- storm id of each player's last Stormborn (1 per storm)
local joinedStorm: { [Player]: number } = {}
local paidHelps: { [Player]: { storm: number, count: number } } = {}
local recentFlashes: { number } = {}
local nextFlashAt: number? = nil
local hadPulls = false

local function anglerPull(player: Player): PullRecord?
	for _, record in pulls do
		if record.angler == player then
			return record
		end
	end
	return nil
end

function StormPull.isAngler(player: Player): boolean
	return anglerPull(player) ~= nil
end

function StormPull.activePulls(): number
	local count = 0
	for _ in pulls do
		count += 1
	end
	return count
end

-- Whether an eye bite during the storm hooks a Stormborn: 4% (sheet §8), at most 1 per player per storm.
-- `forced` (QA forceStormborn) always hooks. The caller checks the eye is in storm (Catch.canHookStormborn).
function StormPull.rollHook(player: Player, roll: number, forced: boolean): boolean
	if not LiveConfig.flag("featureStormPull") then
		return false
	end
	if forced then
		return true
	end
	if hookedStorm[player] == Weather.stormId() then
		return false
	end
	return roll < Species.stormborn.hookChance
end

-- Records that a player took part in this storm (fished at the eye, hooked or helped).
function StormPull.join(player: Player, role: "eye" | "helper", storm: number?)
	local stormId = storm or Weather.stormId()
	if joinedStorm[player] == stormId then
		return
	end
	joinedStorm[player] = stormId
	local data = PlayerData.get(player)
	if not data then
		return
	end
	data.stats.stormsJoined += 1
	PlayerData.changed(player, "stats")
	local minutes = math.floor(math.max(0, os.time() - data.stats.firstJoin) / 60)
	Analytics.custom(player, AnalyticsConfig.customEvents.stormJoined, minutes, { role :: string })
end

-- True when a landing tap at server time `tapTime` falls in a flash window (with the latency allowance).
function StormPull.flashTap(tapTime: number, allowance: number): boolean
	return Ring.onFlash(recentFlashes, FLASHES.windowSeconds, tapTime, allowance)
end

local function pullInfo(record: PullRecord, now: number): Types.PullInfo
	return {
		id = record.id,
		anglerUserId = record.angler.UserId,
		anglerName = record.angler.DisplayName,
		spot = record.spot,
		progress = math.min(record.progress, P.points),
		rate = record.rate,
		helpers = record.active,
		at = now,
	}
end

local function broadcast(landed: { id: number, charged: boolean, kg: number, anglerUserId: number }?)
	local now = Weather.now()
	local list: { Types.PullInfo } = {}
	for _, record in pulls do
		table.insert(list, pullInfo(record, now))
	end
	local payload: Types.PullStatePayload = { pulls = list, landed = landed }
	Net.toAll("PullState", payload)
end

-- Hooks a Stormborn for `angler`. `onLanded` pays the angler and closes their line (Fishing).
function StormPull.begin(
	angler: Player,
	spot: string,
	size: number,
	kg: number,
	onLanded: (LandedResult) -> ()
): number
	nextPullId += 1
	local now = Weather.now()
	local stormId = Weather.stormId()
	hookedStorm[angler] = stormId
	StormPull.join(angler, "eye", stormId)
	pulls[nextPullId] = {
		id = nextPullId,
		angler = angler,
		spot = spot,
		startedAt = now,
		progress = 0,
		rate = Pull.rate(0),
		active = 0,
		size = size,
		kg = kg,
		stormId = stormId,
		helpers = {},
		onLanded = onLanded,
	}
	print(
		`[StormPull] pull {nextPullId} hooked by {CatchLog.alias(angler)} at storm second {math.floor(
			now - stormId
		)}`
	)
	broadcast()
	return nextPullId
end

-- Ends a pull without landing (the angler left). Helpers get nothing; nobody is charged anything.
function StormPull.cancel(angler: Player)
	local record = anglerPull(angler)
	if record then
		pulls[record.id] = nil
		broadcast()
	end
end

local function onPullTap(player: Player)
	local data = PlayerData.get(player)
	local position = World.rootPosition(player)
	if not data or not position or anglerPull(player) then
		return
	end
	-- A helper helps the nearest active pull within range (server positions).
	local best: PullRecord? = nil
	local bestDistance = P.radius
	for _, record in pulls do
		local anglerPosition = World.rootPosition(record.angler)
		if anglerPosition then
			local distance = (anglerPosition - position).Magnitude
			if distance <= bestDistance then
				best = record
				bestDistance = distance
			end
		end
	end
	if not best then
		return
	end
	local helper = best.helpers[player]
	if not helper then
		helper = { lastTap = 0, counted = false }
		best.helpers[player] = helper
	end
	helper.lastTap = Weather.now()
	if not helper.counted then
		helper.counted = true
		StormPull.join(player, "helper", best.stormId)
	end
end

local function holdPose(angler: Player)
	local character = angler.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not character or not root or not root:IsA("BasePart") then
		return
	end
	local fish = Instance.new("Part")
	fish.Name = "HeldRumblefin"
	fish.Shape = Enum.PartType.Ball
	fish.Size = Vector3.new(14, 9, 9)
	fish.Color = Color3.fromRGB(63, 127, 140) -- Squall Teal back
	fish.Material = Enum.Material.SmoothPlastic
	fish.CanCollide = false
	fish.CanTouch = false
	fish.CanQuery = false
	fish.Massless = true
	local belly = fish:Clone()
	belly.Name = "Belly"
	belly.Size = Vector3.new(11, 6, 7)
	belly.Color = Color3.fromRGB(255, 122, 89) -- Ember Coral belly
	local fin = fish:Clone()
	fin.Name = "Fin"
	fin.Size = Vector3.new(4, 4, 4)
	fin.Color = Color3.fromRGB(255, 248, 236) -- Shell Cream cloud-puff fin
	fish.CFrame = root.CFrame * CFrame.new(0, 10, 0)
	belly.CFrame = fish.CFrame * CFrame.new(0, -2, -1)
	fin.CFrame = fish.CFrame * CFrame.new(0, 4.5, 0)
	for _, part in { belly, fin } do
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = fish
		weld.Part1 = part
		weld.Parent = part
		part.Parent = fish
	end
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = fish
	weld.Parent = fish
	fish.Parent = character
	task.delay(P.holdPoseSeconds, function()
		fish:Destroy()
	end)
end

local function land(record: PullRecord, now: number)
	pulls[record.id] = nil
	local anglerData = PlayerData.get(record.angler)
	-- Charged: rolled at landing; friends of the angler among the active helpers raise the chance.
	local active: { Player } = {}
	local counted: { Player } = {}
	local friends = 0
	for helper, state in record.helpers do
		if helper.Parent and state.counted then
			table.insert(counted, helper)
			if now - state.lastTap <= P.activeSeconds then
				table.insert(active, helper)
				if Social.areFriends(record.angler, helper) then
					friends += 1
				end
			end
		end
	end
	local charged = rng:NextNumber() < Pull.chargedChance(friends)
	local mark: Types.MarkId? = if charged then "charged" else nil
	local rumblefin = Species.byId[Species.stormborn.id]
	local helperInputs: { Pull.Helper } = {}
	for index, helper in counted do
		local data = PlayerData.get(helper)
		local paid = paidHelps[helper]
		local count = if paid and paid.storm == record.stormId then paid.count else 0
		helperInputs[index] =
			{ rodLevel = if data then Stats.rodLevel(data) else 0, paidHelpsThisStorm = count }
	end
	local anglerCoins, shares = Pull.payouts(
		{ baseCoins = rumblefin.baseCoins, size = record.size, mark = mark },
		if anglerData then Stats.rodLevel(anglerData) else 0,
		helperInputs
	)
	print(
		`[StormPull] pull {record.id} landed after {string.format("%.2f", now - record.startedAt)} s at storm `
			.. `second {math.floor(now - record.stormId)}, {#counted} helpers ({#active} active at landing, `
			.. `{friends} friends), charged {charged}, angler {CatchLog.alias(record.angler)} coins {anglerCoins}, `
			.. `kg {record.kg}`
	)
	record.onLanded({ mark = mark, coins = anglerCoins, helpers = #counted, charged = charged })

	for index, helper in counted do
		local share = shares[index]
		local data = PlayerData.get(helper)
		if data then
			if share > 0 then
				Currency.add(
					helper,
					"Coins",
					share,
					Enum.AnalyticsEconomyTransactionType.Gameplay.Name,
					"pull_help"
				)
				local previous = paidHelps[helper]
				local count = if previous and previous.storm == record.stormId then previous.count else 0
				paidHelps[helper] = { storm = record.stormId, count = count + 1 }
			end
			local paidNow = paidHelps[helper]
			print(
				`[StormPull] pull {record.id} helper {CatchLog.alias(helper)} share {share} `
					.. `(paid helps this storm {if paidNow and paidNow.storm == record.stormId
						then paidNow.count
						else 0}/`
					.. `{P.maxPaidHelpsPerStorm})`
			)
			data.stats.helps += 1
			PlayerData.changed(helper, "stats")
			local card: Types.CatchPayload = {
				lineId = 0,
				kind = "witnessed",
				species = rumblefin.id,
				name = rumblefin.name,
				tier = rumblefin.tier,
				kg = record.kg,
				mark = mark,
				coins = share,
				isNew = false,
				weather = "storm",
			}
			Net.toClient(helper, "CatchResult", card)
		end
	end

	Net.toAll("Announce", {
		kind = "giant",
		name = record.angler.DisplayName,
		helpers = #counted,
		charged = charged,
		species = rumblefin.name,
		kg = math.floor(record.kg + 0.5),
	})
	Analytics.custom(
		record.angler,
		AnalyticsConfig.customEvents.stormLanded,
		#counted,
		{ if charged then "charged" else "plain" }
	)
	holdPose(record.angler)
	StormPull.Landed:Fire(record.angler, #counted, charged)
	broadcast({ id = record.id, charged = charged, kg = record.kg, anglerUserId = record.angler.UserId })
end

local function stepFlashes(now: number)
	if not Weather.isEyeStorm(now) then
		nextFlashAt = nil
		return
	end
	local due = nextFlashAt
	if due == nil then
		due = now + rng:NextNumber(FLASHES.minGap, FLASHES.maxGap)
		nextFlashAt = due
		Net.toAll("StormState", { flashAt = due })
		return
	end
	if now >= due then
		table.insert(recentFlashes, due)
		if #recentFlashes > KEEP_FLASHES then
			table.remove(recentFlashes, 1)
		end
		local nextDue = due + rng:NextNumber(FLASHES.minGap, FLASHES.maxGap)
		nextFlashAt = nextDue
		Net.toAll("StormState", { flashAt = nextDue, lastFlashAt = due })
	end
end

function StormPull.init() end

function StormPull.start()
	Net.handle("PullTap", onPullTap)
	Players.PlayerRemoving:Connect(function(player: Player)
		hookedStorm[player] = nil
		joinedStorm[player] = nil
		paidHelps[player] = nil
		for _, record in pulls do
			record.helpers[player] = nil
		end
	end)
	local broadcastAccumulator = 0
	RunService.Heartbeat:Connect(function(dt: number)
		local now = Weather.now()
		stepFlashes(now)
		local any = false
		for _, record in pulls do
			any = true
			local active = 0
			for helper, state in record.helpers do
				if helper.Parent and now - state.lastTap <= P.activeSeconds then
					active += 1
				end
			end
			record.active = active
			record.rate = Pull.rate(active)
			record.progress += record.rate * dt
			if record.progress >= P.points then
				land(record, now)
			end
		end
		broadcastAccumulator += dt
		if any and broadcastAccumulator >= BROADCAST_SECONDS then
			broadcastAccumulator = 0
			broadcast()
		elseif not any and hadPulls then
			broadcast()
		end
		hadPulls = any
	end)
end

return StormPull
