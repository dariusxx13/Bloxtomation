--!strict
-- Catch: the pure rules for one fish (prototype brief req. 3 and 5; economy sheet v2 §3, §9, §14).
-- Ring mode and bite wait by weather, the species roll, the size roll, marks, the coin value, and the bite
-- payload (which never carries the species: the client learns it only at landing). Rolls take numbers in
-- [0, 1) from the caller's seeded Random, so the server owns every roll and tests can replay them.

local Fishing = require("../Config/Fishing")
local Odds = require("./Odds")
local Species = require("../Config/Species")
local Types = require("../Types")
local Upgrades = require("../Config/Upgrades")

local Catch = {}

export type TableKey = "clear" | "showers" | "fog"

local ROD_EFFECT = 1
for _, def in Upgrades do
	if def.id == "rod" then
		ROD_EFFECT = def.effect
	end
end

-- The ring mode a bite reels in: the spot's weather, except that the storm reels as Clear away from the eye.
function Catch.mode(weather: Types.Weather, isEye: boolean): Types.RingMode
	if weather == "storm" then
		return if isEye then "storm" else "clear"
	elseif weather == "showers" then
		return "showers"
	elseif weather == "fog" then
		return "fog"
	end
	return "clear"
end

-- The species table for a weather. The storm (at the eye after the Stormborn roll, and elsewhere) is Clear.
function Catch.tableFor(weather: Types.Weather): TableKey
	if weather == "showers" then
		return "showers"
	elseif weather == "fog" then
		return "fog"
	end
	return "clear"
end

local cache: { [string]: { Odds.WeightedOutcome } } = {}

-- Displayed and rolled odds for a weather (the same table both ways).
function Catch.outcomes(weather: Types.Weather): { Odds.WeightedOutcome }
	local key = Catch.tableFor(weather)
	local cached = cache[key]
	if cached then
		return cached
	end
	local pools: { [string]: boolean } = {}
	for _, pool in Species.tables[key] do
		pools[pool] = true
	end
	local entries: { Odds.Entry } = {}
	for _, def in Species.list do
		if pools[def.pool] and not def.stormborn then
			table.insert(entries, { kind = def.id, weight = def.weight, rarity = def.tier :: string })
		end
	end
	local outcomes = Odds.effective(entries, Species.tableLuck[key])
	cache[key] = outcomes
	return outcomes
end

function Catch.rollSpecies(weather: Types.Weather, roll: number): Species.SpeciesDef
	local outcome = Odds.pick(Catch.outcomes(weather), roll)
	return Species.byId[outcome.kind]
end

-- Uniform bite wait for the ring mode (the storm wait is the eye's; elsewhere the storm reels as Clear).
function Catch.biteWait(mode: Types.RingMode, roll: number): number
	local range = Fishing.biteWait[mode]
	return range.min + (range.max - range.min) * roll
end

-- A standard normal value from two uniforms (Box-Muller). u1 must be in (0, 1].
function Catch.normal(u1: number, u2: number): number
	local safe = math.max(u1, 1e-12)
	return math.sqrt(-2 * math.log(safe)) * math.cos(2 * math.pi * u2)
end

-- Size factor = clamp(exp(N(-sigma^2/2, sigma)), min, max) for a standard normal z (sheet §9.3).
function Catch.sizeFactor(sigma: number, z: number): number
	local roll = Species.sizeRoll
	return math.clamp(math.exp(-sigma * sigma / 2 + sigma * z), roll.min, roll.max)
end

function Catch.sigmaFor(def: Species.SpeciesDef): number
	return if def.stormborn then Species.sizeRoll.stormbornSigma else Species.sizeRoll.sigma
end

function Catch.kg(baseKg: number, size: number): number
	return math.floor(baseKg * size * 10 + 0.5) / 10
end

-- The weather mark for a regular catch (one per fish): Drizzled in Showers, Misty in Sea Fog. Charged is
-- decided by a flash tap (regular eye catches) or by the giant roll, never here.
function Catch.rollMark(weather: Types.Weather, roll: number): Types.MarkId?
	for _, mark in Species.marks do
		if mark.weather == weather and mark.chance > 0 and roll < mark.chance then
			return mark.id
		end
	end
	return nil
end

function Catch.markMultiplier(mark: Types.MarkId?): number
	if mark == nil then
		return 1
	end
	local def = Species.markById[mark]
	return if def then def.multiplier else 1
end

function Catch.rodMultiplier(level: number): number
	return ROD_EFFECT ^ level
end

-- Coins = base coins x size factor x mark x 1.14^(Rod level), to the nearest whole coin and at least 1.
function Catch.value(baseCoins: number, size: number, mark: Types.MarkId?, rodLevel: number): number
	local raw = baseCoins * size * Catch.markMultiplier(mark) * Catch.rodMultiplier(rodLevel)
	return math.max(1, math.floor(raw + 0.5))
end

function Catch.steps(mode: Types.RingMode, tier: Types.RarityId): number
	local steps = Fishing.ring[mode].steps[tier]
	return steps or 3
end

-- Only the eye (pier_head) during the Great Storm can hook a Stormborn.
function Catch.canHookStormborn(weatherAtBite: Types.Weather, isEye: boolean): boolean
	return isEye and weatherAtBite == "storm"
end

-- Expected coins of one Clear catch (no marks, mean size 1) at a Rod level: the "minutes of income" basis.
function Catch.expectedClearValue(rodLevel: number): number
	local sum = 0
	for _, outcome in Catch.outcomes("clear") do
		sum += outcome.probability * Species.byId[outcome.kind].baseCoins
	end
	return sum * Catch.rodMultiplier(rodLevel)
end

export type BiteArgs = {
	lineId: number,
	mode: Types.RingMode,
	tier: Types.RarityId,
	steps: number,
	arcCenter: number,
	ringStart: number?,
	hookDeadline: number?,
	escapeAt: number?,
}

-- What the client may see of a bite: the tier (ring steps and glow), never the species, size or mark.
function Catch.bitePayload(args: BiteArgs): Types.BitePayload
	local ring = Fishing.ring[args.mode]
	return {
		lineId = args.lineId,
		mode = args.mode,
		tier = args.tier,
		steps = args.steps,
		missBudget = ring.missBudget,
		lap = ring.lap,
		arcWidth = ring.arc,
		arcCenter = args.arcCenter,
		ringStart = args.ringStart,
		hookDeadline = args.hookDeadline,
		escapeAt = args.escapeAt,
		opacity = ring.opacity,
	}
end

return Catch
