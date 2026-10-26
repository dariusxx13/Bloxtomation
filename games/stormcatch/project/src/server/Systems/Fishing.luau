--!strict
-- Fishing: the moment loop on the server (prototype brief req. 3, 5, 9.1-9.3; GDD v3.1 §4.1).
-- Clients send Cast(spotId), HookTap() and ReelTap(); the server decides everything: range and cooldown, the
-- bite wait for the weather at cast time, species, size and mark for the weather at bite time, the ring (it
-- owns start time, lap and arc, and judges each tap on its own clock with a latency allowance), escapes, the
-- Stormborn hook at the eye, Charged flash taps, and the payout. The client only draws and requests.
-- Line time is sampled by the spot's weather every frame for the catch log (twist test B).
-- Signals: CastAccepted(player, spot), Caught(player, info). QA: forceStormborn(player).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.Shared
local AnalyticsConfig = require(Shared.Config.Analytics)
local Catch = require(Shared.Util.Catch)
local FishingConfig = require(Shared.Config.Fishing)
local Net = require(Shared.Net)
local Ring = require(Shared.Util.Ring)
local Signal = require(Shared.Util.Signal)
local Species = require(Shared.Config.Species)
local Stats = require(Shared.Util.Stats)
local TwistLog = require(Shared.Util.TwistLog)
local Types = require(Shared.Types)
local Validate = require(Shared.Util.Validate)
local WeatherSchedule = require(Shared.Util.WeatherSchedule)
local WorldLayout = require(Shared.Config.WorldLayout)

local Analytics = require(script.Parent.Parent.Services.Analytics)
local CatchLog = require(script.Parent.CatchLog)
local Currency = require(script.Parent.Currency)
local PlayerData = require(script.Parent.PlayerData)
local StormPull = require(script.Parent.StormPull)
local Weather = require(script.Parent.Weather)
local World = require(script.Parent.World)

local Fishing = {}

export type CaughtInfo = {
	species: string,
	tier: Types.RarityId,
	weather: Types.Weather,
	mark: Types.MarkId?,
	coins: number,
	kg: number,
	first: boolean,
	giant: boolean,
}

-- (player, spotId) when the server accepts a cast (onboarding step 2)
Fishing.CastAccepted = Signal.new() :: Signal.Signal<Player, string>
-- (player, info) when a fish lands (onboarding steps 3, 4 and 7)
Fishing.Caught = Signal.new() :: Signal.Signal<Player, CaughtInfo>

type LineState = "waiting" | "hooking" | "reeling" | "giant"

type Line = {
	id: number,
	player: Player,
	spot: string,
	isEye: boolean,
	castAt: number,
	state: LineState,
	biteAt: number,
	first: boolean,
	forced: boolean,
	weather: Types.Weather?, -- at bite
	firstBiteAt: number?,
	mode: Types.RingMode,
	species: Species.SpeciesDef?,
	size: number,
	mark: Types.MarkId?,
	steps: number,
	stepsDone: number,
	misses: number,
	missBudget: number,
	taps: number,
	ring: Ring.Params?,
	hookDeadline: number,
	escapeAt: number?,
	lastTapAt: number,
	allowance: number,
	lastSample: number,
	segments: { TwistLog.Segment },
}

local rng = Random.new()
local lines: { [Player]: Line } = {}
local lastEnd: { [Player]: number } = {}
local forcedStormborn: { [Player]: boolean } = {}
local nextLineId = 0

local GAMEPLAY = Enum.AnalyticsEconomyTransactionType.Gameplay.Name

local function allowanceFor(player: Player): number
	local ok, ping = pcall(function()
		return player:GetNetworkPing()
	end)
	return Ring.allowance(if ok and type(ping) == "number" then ping else 0)
end

-- Line-time sampling: what kind of second this was at the line's spot (catch log, twist test B).
local function sampleKind(line: Line, now: number): TwistLog.SegmentKind
	if line.state == "giant" then
		return "storm"
	end
	local weather: Types.Weather, forced: boolean = Weather.effective(line.spot, now)
	if forced then
		return "forced"
	elseif weather == "storm" then
		return "storm"
	elseif WeatherSchedule.isFront(weather) then
		return "front"
	end
	return "clear"
end

local function sample(line: Line, now: number)
	if now > line.lastSample then
		local kind: TwistLog.SegmentKind = sampleKind(line, now)
		if kind == "forced" then
			line.forced = true
		end
		TwistLog.add(line.segments, line.lastSample, now, kind)
		line.lastSample = now
	end
end

local function reelState(line: Line, event: Types.ReelEvent)
	local payload: Types.ReelStatePayload = {
		lineId = line.id,
		event = event,
		stepsDone = line.stepsDone,
		misses = line.misses,
		arcCenter = if line.ring then line.ring.arcCenter else nil,
		ringStart = if line.ring then line.ring.start else nil,
		escapeAt = line.escapeAt,
	}
	Net.toClient(line.player, "ReelState", payload)
end

-- Closes a line and writes its catch-log row.
local function endLine(
	line: Line,
	now: number,
	result: string,
	coins: number,
	kg: number,
	mark: Types.MarkId?
)
	sample(line, now)
	if lines[line.player] == line then
		lines[line.player] = nil
	end
	lastEnd[line.player] = now
	local totals = TwistLog.totals(line.segments)
	local def = line.species
	local landed = result == "landed" or result == "giant"
	CatchLog.add({
		alias = CatchLog.alias(line.player),
		sinceJoin = math.floor((line.castAt - CatchLog.joinedAt(line.player)) * 10 + 0.5) / 10,
		spot = line.spot,
		weather = line.weather or "",
		mode = if line.weather ~= nil then line.mode else "",
		biteSeconds = if line.firstBiteAt then line.firstBiteAt - line.castAt else 0,
		underFront = line.weather ~= nil and WeatherSchedule.isFront(line.weather :: Types.Weather),
		lineSeconds = now - line.castAt,
		frontSeconds = totals.front,
		clearSeconds = totals.clear,
		stormSeconds = totals.storm,
		forcedSeconds = totals.forced,
		result = result,
		species = if def and landed then def.id else "",
		tier = if def and landed then def.tier else "",
		mark = if landed and mark then mark else "",
		kg = if landed then kg else 0,
		coins = coins,
		misses = line.misses,
		forced = line.forced or totals.forced > 0,
		segments = line.segments,
	})
end

local function escape(line: Line, now: number)
	reelState(line, "escaped")
	Analytics.custom(
		line.player,
		AnalyticsConfig.customEvents.reelResult,
		line.taps,
		{ line.mode :: string, "escaped", tostring(line.misses) }
	)
	endLine(line, now, "escaped", 0, 0, nil)
end

-- Pays a landed fish, updates stats and the collection, and tells the client (the card and its juice).
local function finishCatch(
	line: Line,
	now: number,
	mark: Types.MarkId?,
	coins: number,
	kg: number,
	result: string
)
	local player = line.player
	local data = PlayerData.get(player)
	local def = line.species
	if not data or not def then
		endLine(line, now, "left", 0, 0, nil)
		return
	end
	local weather: Types.Weather = line.weather or "clear"
	Currency.add(player, "Coins", coins, GAMEPLAY, "catch", true)
	data.stats.catches += 1
	if weather == "showers" and not line.first then
		data.stats.rainCatches += 1
	end
	if def.stormborn then
		data.stats.giantsLanded += 1
	end
	local before = data.index[def.id] or 0
	data.index[def.id] = before + 1
	PlayerData.changed(player, "stats", "index")

	local payload: Types.CatchPayload = {
		lineId = line.id,
		kind = "catch",
		species = def.id,
		name = def.name,
		tier = def.tier,
		kg = kg,
		mark = mark,
		coins = coins,
		isNew = before == 0,
		weather = weather,
	}
	Net.toClient(player, "CatchResult", payload)
	Analytics.custom(
		player,
		AnalyticsConfig.customEvents.catch,
		coins,
		{ def.id, weather :: string, if mark then mark :: string else "none" }
	)
	if not def.stormborn then
		Analytics.custom(
			player,
			AnalyticsConfig.customEvents.reelResult,
			line.taps,
			{ line.mode :: string, "landed", tostring(line.misses) }
		)
	end
	CatchLog.markFirstCatch(player, now)
	endLine(line, now, result, coins, kg, mark)
	Fishing.Caught:Fire(player, {
		species = def.id,
		tier = def.tier,
		weather = weather,
		mark = mark,
		coins = coins,
		kg = kg,
		first = line.first,
		giant = def.stormborn,
	})
end

local function land(line: Line, now: number)
	local data = PlayerData.get(line.player)
	local def = line.species
	if not data or not def then
		endLine(line, now, "left", 0, 0, nil)
		return
	end
	local mark: Types.MarkId? = line.mark
	-- Storm ring at the eye: a landing tap inside a flash window gives the Charged mark (req. 3.4, 9.5).
	if line.mode == "storm" and StormPull.flashTap(now, line.allowance) then
		mark = "charged"
	end
	local coins: number
	local kg: number
	if line.first then
		coins = FishingConfig.firstCatch.coins
		kg = FishingConfig.firstCatch.kg
	else
		coins = Catch.value(def.baseCoins, line.size, mark, Stats.rodLevel(data))
		kg = Catch.kg(def.baseKg, line.size)
	end
	finishCatch(line, now, mark, coins, kg, "landed")
end

local function startGiant(line: Line)
	local def = Species.byId[Species.stormborn.id]
	line.state = "giant"
	line.species = def
	line.mode = "storm"
	line.size = Catch.sizeFactor(Catch.sigmaFor(def), Catch.normal(1 - rng:NextNumber(), rng:NextNumber()))
	line.escapeAt = nil
	local kg = Catch.kg(def.baseKg, line.size)
	reelState(line, "giant")
	StormPull.begin(line.player, line.spot, line.size, kg, function(result: StormPull.LandedResult)
		if lines[line.player] == line then
			finishCatch(line, Weather.now(), result.mark, result.coins, kg, "giant")
		end
	end)
end

local function bite(line: Line, now: number)
	local player = line.player
	local data = PlayerData.get(player)
	if not data then
		endLine(line, now, "left", 0, 0, nil)
		return
	end
	local weather: Types.Weather, forced: boolean = Weather.effective(line.spot, now)
	line.weather = weather
	line.forced = line.forced or forced
	line.firstBiteAt = line.firstBiteAt or now
	line.allowance = allowanceFor(player)

	-- The Stormborn: eye bites during the storm only, 4% (or QA forceStormborn), 1 per player per storm.
	if not line.first and Catch.canHookStormborn(weather, line.isEye) then
		local forcedHook = forcedStormborn[player] == true
		if StormPull.rollHook(player, rng:NextNumber(), forcedHook) then
			if forcedHook then
				forcedStormborn[player] = nil
				line.forced = true
			end
			startGiant(line)
			return
		end
	end

	local def: Species.SpeciesDef
	local mark: Types.MarkId? = nil
	if line.first then
		-- Scripted first catch (req. 3.6): Pebble Minnow, 0.8 kg, one step, no escape, Clear ring.
		def = Species.byId[FishingConfig.firstCatch.species]
		line.size = FishingConfig.firstCatch.kg / def.baseKg
		line.mode = "clear"
	elseif weather == "showers" and data.stats.rainCatches == 0 then
		-- First catch under Showers (req. 3.7): a guaranteed Pitterpike with the Drizzled mark.
		def = Species.byId[FishingConfig.firstRainCatch.species]
		mark = FishingConfig.firstRainCatch.mark
		line.size =
			Catch.sizeFactor(Catch.sigmaFor(def), Catch.normal(1 - rng:NextNumber(), rng:NextNumber()))
		line.mode = Catch.mode(weather, line.isEye)
	else
		def = Catch.rollSpecies(weather, rng:NextNumber())
		mark = Catch.rollMark(weather, rng:NextNumber())
		line.size =
			Catch.sizeFactor(Catch.sigmaFor(def), Catch.normal(1 - rng:NextNumber(), rng:NextNumber()))
		line.mode = Catch.mode(weather, line.isEye)
	end
	line.species = def
	line.mark = mark
	line.steps = if line.first then FishingConfig.firstCatch.steps else Catch.steps(line.mode, def.tier)
	line.missBudget = FishingConfig.ring[line.mode].missBudget
	line.stepsDone = 0
	line.misses = 0
	local arcCenter = rng:NextNumber() * 360
	local ringDef = FishingConfig.ring[line.mode]

	local payload: Types.BitePayload
	if ringDef.hook then
		-- Sea Fog: no "!"; the bobber dips and the player has 3.0 s to hook before the ring appears.
		line.state = "hooking"
		line.hookDeadline = now + FishingConfig.hookWindow
		line.ring = nil
		line.escapeAt = nil
		payload = Catch.bitePayload({
			lineId = line.id,
			mode = line.mode,
			tier = def.tier,
			steps = line.steps,
			arcCenter = arcCenter,
			hookDeadline = line.hookDeadline,
		})
		line.ring = { start = 0, lap = ringDef.lap, arcCenter = arcCenter, arcWidth = ringDef.arc }
	else
		line.state = "reeling"
		line.ring = { start = now, lap = ringDef.lap, arcCenter = arcCenter, arcWidth = ringDef.arc }
		line.escapeAt = if line.first then nil else now + FishingConfig.escapeSeconds
		line.lastTapAt = now - FishingConfig.tapSpacing
		payload = Catch.bitePayload({
			lineId = line.id,
			mode = line.mode,
			tier = def.tier,
			steps = line.steps,
			arcCenter = arcCenter,
			ringStart = now,
			escapeAt = line.escapeAt,
		})
	end
	Net.toClient(player, "Bite", payload)
end

-- Sea Fog: the hook window passed without a hook tap. The fish nibbles off silently; a new bite comes after
-- a fresh wait for the spot's weather now, at no cost (req. 3.3).
local function nibble(line: Line, now: number)
	local weather: Types.Weather = Weather.effective(line.spot, now)
	line.state = "waiting"
	line.ring = nil
	line.species = nil
	line.biteAt = now + Catch.biteWait(Catch.mode(weather, line.isEye), rng:NextNumber())
	reelState(line, "nibbled")
end

local function onCast(player: Player, spotArg: unknown): Types.ActionResult
	if not Validate.identifier(spotArg, 32) then
		return { ok = false, reason = "invalid" }
	end
	local spotId = spotArg :: string
	local spec = World.spot(spotId)
	local ripple = World.ripplePosition(spotId)
	local data = PlayerData.get(player)
	if not spec or not ripple or not data then
		return { ok = false, reason = "invalid" }
	end
	if not data.zonesUnlocked[WorldLayout.zoneId] then
		return { ok = false, reason = "locked" }
	end
	if lines[player] or StormPull.isAngler(player) then
		return { ok = false, reason = "busy" }
	end
	local now = Weather.now()
	local previous = lastEnd[player]
	if previous and now - previous < FishingConfig.castCooldown then
		return { ok = false, reason = "cooldown" }
	end
	if World.distanceTo(player, ripple) > FishingConfig.castRange + FishingConfig.castRangeMargin then
		return { ok = false, reason = "far" }
	end
	local weather: Types.Weather, forced: boolean = Weather.effective(spotId, now)
	local first = data.stats.catches == 0
	local mode: Types.RingMode = Catch.mode(weather, spec.stormEye)
	local wait = if first
		then FishingConfig.firstCatch.biteSeconds
		else Catch.biteWait(mode, rng:NextNumber())
	nextLineId += 1
	local line: Line = {
		id = nextLineId,
		player = player,
		spot = spotId,
		isEye = spec.stormEye,
		castAt = now,
		state = "waiting",
		biteAt = now + wait,
		first = first,
		forced = forced,
		weather = nil,
		firstBiteAt = nil,
		mode = mode,
		species = nil,
		size = 1,
		mark = nil,
		steps = 1,
		stepsDone = 0,
		misses = 0,
		missBudget = 3,
		taps = 0,
		ring = nil,
		hookDeadline = 0,
		escapeAt = nil,
		lastTapAt = 0,
		allowance = allowanceFor(player),
		lastSample = now,
		segments = {},
	}
	lines[player] = line
	if spec.stormEye and weather == "storm" then
		StormPull.join(player, "eye")
	end
	Analytics.custom(player, AnalyticsConfig.customEvents.cast, 1, { spotId, weather :: string })
	Fishing.CastAccepted:Fire(player, spotId)
	return { ok = true, lineId = line.id, spot = spotId, castAt = now }
end

local function onHookTap(player: Player)
	local line = lines[player]
	if not line or line.state ~= "hooking" then
		return
	end
	local now = Weather.now()
	line.allowance = allowanceFor(player)
	if now > line.hookDeadline + line.allowance then
		return -- too late: the loop lets the fish nibble off
	end
	local ring = line.ring
	if not ring then
		return
	end
	ring.start = now
	line.state = "reeling"
	line.escapeAt = now + FishingConfig.escapeSeconds
	line.lastTapAt = now
	reelState(line, "hooked")
end

local function onReelTap(player: Player)
	local line = lines[player]
	if not line or line.state ~= "reeling" then
		return
	end
	local ring = line.ring
	if not ring then
		return
	end
	local now = Weather.now()
	if now - line.lastTapAt < FishingConfig.tapSpacing then
		return -- taps under 0.15 s apart are ignored
	end
	line.lastTapAt = now
	line.taps += 1
	line.allowance = allowanceFor(player)
	if Ring.judge(ring, now, line.allowance) then
		line.stepsDone += 1
		if line.stepsDone >= line.steps then
			land(line, now)
			return
		end
		ring.arcCenter = Ring.nextArcCenter(Ring.markerAngle(ring, now), rng:NextNumber())
		reelState(line, "good")
	else
		line.misses += 1
		if not line.first and line.misses > line.missBudget then
			escape(line, now)
			return
		end
		reelState(line, "miss")
	end
end

-- QA: the caller's next bite at pier_head during the storm hooks a Rumblefin (rows marked forced).
function Fishing.forceStormborn(player: Player)
	forcedStormborn[player] = true
end

function Fishing.hasLine(player: Player): boolean
	return lines[player] ~= nil
end

function Fishing.init() end

function Fishing.start()
	Net.handle("Cast", onCast)
	Net.handle("HookTap", onHookTap)
	Net.handle("ReelTap", onReelTap)
	PlayerData.Removing:Connect(function(player: Player)
		local line = lines[player]
		if line then
			if line.state == "giant" then
				StormPull.cancel(player)
			end
			endLine(line, Weather.now(), "left", 0, 0, nil)
		end
		lastEnd[player] = nil
		forcedStormborn[player] = nil
	end)
	RunService.Heartbeat:Connect(function()
		local now = Weather.now()
		for player, line in lines do
			if not player.Parent then
				continue
			end
			sample(line, now)
			if line.state == "waiting" and now >= line.biteAt then
				bite(line, now)
			elseif line.state == "hooking" and now > line.hookDeadline + line.allowance then
				nibble(line, now)
			elseif line.state == "reeling" and line.escapeAt ~= nil and now >= line.escapeAt then
				escape(line, now)
			end
		end
	end)
end

return Fishing
