--!strict
-- Economy sheet: prints the numbers a designer balances against (vault: 04-progression-and-economy/economy-math.md).
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

local Economy = require("../src/shared/Config/Economy")
local EconomyMath = require("../src/shared/Util/EconomyMath")
local Eggs = require("../src/shared/Config/Eggs")
local Format = require("../src/shared/Util/Format")
local Odds = require("../src/shared/Util/Odds")
local Pets = require("../src/shared/Config/Pets")
local Upgrades = require("../src/shared/Config/Upgrades")
local Zones = require("../src/shared/Config/Zones")

local SIM_MINUTES = 240
local lines: { string } = {}

local function out(text: string?)
	table.insert(lines, text or "")
end

local function minutes(value: number?): string
	if value == nil then
		return "-"
	end
	return Format.trimZeros(string.format("%.1f", value))
end

out("# Economy sheet")
out()
out(`Generated from config. Simulation horizon: {SIM_MINUTES} minutes of active play, greedy Power upgrades.`)
out()

-- Pacing per model player ---------------------------------------------------------------------------
out("## Pacing by player model")
out()
local header = { "Model", "Hits/s", "First upgrade (s)" }
for i = 2, #Zones do
	table.insert(header, `{Zones[i].name} (min)`)
end
table.insert(header, "Rebirth 1 (min)")
table.insert(header, "Rebirth 1 (day)")
table.insert(header, "Power level at end")
out("| " .. table.concat(header, " | ") .. " |")
out("|" .. string.rep(" --- |", #header))
local modelNames = {}
for name in Economy.playerModels do
	table.insert(modelNames, name)
end
table.sort(modelNames)
for _, name in modelNames do
	local model = (Economy.playerModels :: any)[name]
	local result = EconomyMath.simulatePacing(model.hitsPerSecond, SIM_MINUTES)
	local row = { name, tostring(model.hitsPerSecond), tostring(result.firstUpgradeSeconds) }
	for i = 1, #Zones - 1 do
		table.insert(row, minutes(result.zoneMinutes[i]))
	end
	table.insert(row, minutes(result.rebirthMinutes))
	local playMinutesPerDay = model.sessionMinutes * model.sessionsPerDay
	local rebirthMinutes = result.rebirthMinutes
	table.insert(row, if rebirthMinutes then tostring(math.ceil(rebirthMinutes / playMinutesPerDay)) else "-")
	table.insert(row, tostring(result.powerLevelAtEnd))
	out("| " .. table.concat(row, " | ") .. " |")
end
out()
out("Days assume each model's play minutes per day (sessionMinutes x sessionsPerDay in Config/Economy).")
out()

-- Upgrade costs ---------------------------------------------------------------------------------------
out("## Upgrade costs")
out()
local levels = { 0, 1, 5, 10, 20, 40, 80, 160 }
local upgradeHeader = { "Upgrade" }
for _, level in levels do
	table.insert(upgradeHeader, `Lv {level}`)
end
out("| " .. table.concat(upgradeHeader, " | ") .. " |")
out("|" .. string.rep(" --- |", #upgradeHeader))
for _, def in Upgrades do
	local row = { `{def.name} (max {def.maxLevel})` }
	for _, level in levels do
		table.insert(
			row,
			if level < def.maxLevel then Format.short(EconomyMath.upgradeCost(def, level)) else "-"
		)
	end
	out("| " .. table.concat(row, " | ") .. " |")
end
out()
out(
	`Power multiplier: Lv 10 = x{Format.short(EconomyMath.powerMultiplier(10))}, `
		.. `Lv 50 = x{Format.short(EconomyMath.powerMultiplier(50))}, Lv 100 = x{Format.short(
			EconomyMath.powerMultiplier(100)
		)}`
)
out()

-- Zones ---------------------------------------------------------------------------------------------
out("## Zones")
out()
out("| Zone | Gate cost | Value multiplier | Egg |")
out("| --- | --- | --- | --- |")
for _, zone in Zones do
	out(`| {zone.name} | {Format.short(zone.gateCost)} | x{zone.valueMultiplier} | {zone.eggId or "-"} |`)
end
out()

-- Rebirths --------------------------------------------------------------------------------------------
out("## Rebirths")
out()
out("| Rebirth # | Cost | Multiplier after |")
out("| --- | --- | --- |")
for rebirths = 0, 9 do
	out(
		`| {rebirths + 1} | {Format.short(EconomyMath.rebirthCost(rebirths))} | x{EconomyMath.rebirthMultiplier(
			rebirths + 1
		)} |`
	)
end
out()

-- Egg odds ------------------------------------------------------------------------------------------------
out("## Egg odds (luck x1 and x2)")
out()
for _, egg in Eggs.list do
	out(`### {egg.name} ({Format.short(egg.price)} coins)`)
	out()
	out("| Pet | Rarity | Chance (x1) | 1 in | Chance (x2) | Hatches for 50% chance | Coins for 50% |")
	out("| --- | --- | --- | --- | --- | --- | --- |")
	local base = Odds.effective(egg, 1)
	local lucky = Odds.effective(egg, 2)
	for index, outcome in base do
		local pet = Pets.byKind[outcome.kind]
		local tries = math.max(1, math.ceil(Odds.triesForChance(outcome.probability, 0.5)))
		out(
			`| {pet and pet.name or outcome.kind} | {outcome.rarity} | {Format.percent(outcome.probability)} | `
				.. `{Format.oneIn(outcome.probability)} | {Format.percent(lucky[index].probability)} | {Format.commas(
					tries
				)} | `
				.. `{Format.short(tries * egg.price)} |`
		)
	end
	if egg.pity then
		out()
		out(`Hard pity: guaranteed {egg.pity.rarity} or better within {egg.pity.afterRolls} hatches.`)
	end
	out()
end

local text = table.concat(lines, "\n")
print(text)
local target = args[1]
if target then
	fs.writeFile(target, text .. "\n")
	print(`\nWrote {target}`)
end
