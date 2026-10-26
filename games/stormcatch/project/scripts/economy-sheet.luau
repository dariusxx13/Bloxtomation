--!strict
-- Prototype economy sheet: prints the live config next to economy sheet v2 §14 so the two can be diffed
-- (vault: 04-progression-and-economy/economy-math.md; prototype brief req. 5 acceptance criterion).
--   lune run scripts/economy-sheet            -- print Markdown to stdout
--   lune run scripts/economy-sheet out.md   -- also write it to a file
-- Pure: reads only the shared config and math modules, so it always matches the game.

local fs = require("@lune/fs")
local process = require("@lune/process")

-- Arguments without a literal "--" separator (both `lune run x a` and `lune run x -- a` work).
local args: { string } = {}
for _, arg in process.args do
	if arg ~= "--" then
		table.insert(args, arg)
	end
end

local Catch = require("../src/shared/Util/Catch")
local EconomyMath = require("../src/shared/Util/EconomyMath")
local Fishing = require("../src/shared/Config/Fishing")
local Onboarding = require("../src/shared/Config/Onboarding")
local Pull = require("../src/shared/Util/Pull")
local Species = require("../src/shared/Config/Species")
local Upgrades = require("../src/shared/Config/Upgrades")
local WeatherConfig = require("../src/shared/Config/Weather")
local WeatherSchedule = require("../src/shared/Util/WeatherSchedule")

local lines: { string } = {}

local function out(text: string?)
	table.insert(lines, text or "")
end

local function pct(p: number?): string
	return if p then string.format("%.2f%%", p * 100) else "-"
end

local function chance(weather: string, id: string): number?
	for _, outcome in Catch.outcomes(weather :: any) do
		if outcome.kind == id then
			return outcome.probability
		end
	end
	return nil
end

out("# Reel the Storm prototype: live config (compare with economy sheet v2 §14)")
out()
out("## Config/Species.luau")
out()
out("| id | Name | Tier | Table | Weight | Base coins | Base kg | Clear | Showers | Sea Fog |")
out("|---|---|---|---|---|---|---|---|---|---|")
for _, def in Species.list do
	out(
		`| {def.id} | {def.name} | {def.tier} | {def.pool} | {def.weight} | {def.baseCoins} | {def.baseKg} | `
			.. `{pct(chance("clear", def.id))} | {pct(chance("showers", def.id))} | {pct(
				chance("fog", def.id)
			)} |`
	)
end
out()
out(
	`Sea Fog luck on Rare and up: x{Species.tableLuck.fog}. Size: sigma {Species.sizeRoll.sigma} `
		.. `(Stormborn {Species.sizeRoll.stormbornSigma}), clamp {Species.sizeRoll.min}-{Species.sizeRoll.max}.`
)
local markParts: { string } = {}
for _, mark in Species.marks do
	table.insert(markParts, `{mark.name} {mark.weather} {pct(mark.chance)} x{mark.multiplier}`)
end
out(`Marks: {table.concat(markParts, "; ")} (Charged by flash tap or the giant roll).`)
out(
	`Stormborn: {Species.stormborn.id}, {pct(Species.stormborn.hookChance)} of eye bites, `
		.. `at most {Species.stormborn.maxPerPlayerPerStorm} per player per storm.`
)
out()
out("## Config/Fishing.luau")
out()
out("| Mode | Bite wait (s) | Lap (s) | Arc | Steps C/U/R/E | Miss budget | Ring opacity |")
out("|---|---|---|---|---|---|---|")
for _, mode in { "clear", "showers", "fog", "storm" } do
	local ring = Fishing.ring[mode :: any]
	local wait = Fishing.biteWait[mode :: any]
	out(
		`| {mode} | {wait.min}-{wait.max} | {ring.lap} | {ring.arc} | {ring.steps.Common}/{ring.steps.Uncommon}/`
			.. `{ring.steps.Rare}/{ring.steps.Epic} | {ring.missBudget} | {ring.opacity} |`
	)
end
out()
out(
	`First catch: {Fishing.firstCatch.species} {Fishing.firstCatch.kg} kg, bite {Fishing.firstCatch.biteSeconds} s, `
		.. `{Fishing.firstCatch.steps} step, {Fishing.firstCatch.coins} coins. First Showers catch: `
		.. `{Fishing.firstRainCatch.species} + {Fishing.firstRainCatch.mark}.`
)
local P = Fishing.pull
out(
	`Pull: radius {P.radius}, solo {P.soloSeconds} s, helper factor {P.helperFactor}, at most {P.maxHelpers} `
		.. `helpers, active {P.activeSeconds} s; landing 0/3/4/7 helpers = `
		.. `{string.format("%.1f", Pull.landingSeconds(0))} / {string.format("%.1f", Pull.landingSeconds(3))} / `
		.. `{string.format("%.1f", Pull.landingSeconds(4))} / {string.format("%.1f", Pull.landingSeconds(7))} s.`
)
out(
	`Helper share {pct(P.helperShare)}, {P.maxPaidHelpsPerStorm} paid helps per storm. Charged `
		.. `{pct(P.chargedBase)} + {pct(P.chargedPerFriend)} per friend, cap {pct(P.chargedCap)}.`
)
out()
out("## Config/Upgrades.luau")
out()
for _, def in Upgrades do
	local costs: { string } = {}
	for level = 0, 9 do
		table.insert(costs, tostring(EconomyMath.upgradeCost(def, level)))
	end
	out(
		`{def.name} ({def.id}): base {def.baseCost}, growth {def.costGrowth}, effect x{def.effect}, `
			.. `max {def.maxLevel}. Costs L0-L9: {table.concat(costs, ", ")}.`
	)
end
out(`Onboarding coinsForStep4 = {Onboarding.coinsForStep4}.`)
out()
out("## Weather timetable")
out()
local front, nonStorm = WeatherSchedule.coverageParts(180, 900)
out(
	`Cycle {WeatherConfig.cycleSeconds} s, storm {WeatherConfig.storm.from}-{WeatherConfig.storm.to} s at `
		.. `{WeatherConfig.storm.eye}; front coverage outside the storm = `
		.. `{string.format("%.4f", front / (3 * nonStorm))}.`
)

local text = table.concat(lines, "\n")
print(text)
if args[1] then
	fs.writeFile(args[1], text .. "\n")
end
