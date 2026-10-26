--!strict
-- Config gate: catches broken references and unsafe values before they reach Studio, and, with
-- --release, blocks shipping template defaults (vault: 18-templates-and-checklists/pre-launch-checklist.md).
--   lune run scripts/check-config             -- integrity errors only
--   lune run scripts/check-config --release  -- also fail on release blockers
-- Exit code 1 if anything fails.

local process = require("@lune/process")

-- Arguments without a literal "--" separator (both `lune run x a` and `lune run x -- a` work).
local args: { string } = {}
for _, arg in process.args do
	if arg ~= "--" then
		table.insert(args, arg)
	end
end

local Catch = require("../src/shared/Util/Catch")
local Fishing = require("../src/shared/Config/Fishing")
local Game = require("../src/shared/Config/Game")
local Odds = require("../src/shared/Util/Odds")
local Onboarding = require("../src/shared/Config/Onboarding")
local Products = require("../src/shared/Config/Products")
local Rarities = require("../src/shared/Config/Rarities")
local Remotes = require("../src/shared/Config/Remotes")
local Species = require("../src/shared/Config/Species")
local Upgrades = require("../src/shared/Config/Upgrades")
local WeatherConfig = require("../src/shared/Config/Weather")
local WorldLayout = require("../src/shared/Config/WorldLayout")
local Zones = require("../src/shared/Config/Zones")

local release = table.find(args, "--release") ~= nil

local errors: { string } = {}
local blockers: { string } = {}
local notes: { string } = {}

local function check(condition: boolean, message: string)
	if not condition then
		table.insert(errors, message)
	end
end

local function positive(value: number): boolean
	return value == value and value > 0 and value < math.huge
end

-- Species, tables and marks ------------------------------------------------------------------------------
local ids: { [string]: boolean } = {}
for _, def in Species.list do
	check(not ids[def.id], `duplicate species {def.id}`)
	ids[def.id] = true
	check(Rarities.byId[def.tier] ~= nil, `species {def.id} has unknown tier {def.tier}`)
	check(positive(def.baseCoins) and positive(def.baseKg), `species {def.id} values must be positive`)
	if not def.stormborn then
		check(positive(def.weight), `species {def.id} weight must be positive`)
	end
end
check(Species.byId[Species.stormborn.id] ~= nil, "the Stormborn id must be a species")
check(
	Species.stormborn.hookChance > 0 and Species.stormborn.hookChance < 1,
	"Stormborn hook chance must be in (0, 1)"
)
for _, weather in { "clear", "showers", "fog" } do
	local total = Odds.total(Catch.outcomes(weather :: any))
	check(math.abs(total - 1) < 1e-9, `{weather} table probabilities sum to {total}`)
end
for _, mark in Species.marks do
	check(
		mark.multiplier >= 1 and mark.multiplier <= 5,
		`mark {mark.id} multiplier must be 1..5 (sheet §9.4 cap)`
	)
	check(mark.chance >= 0 and mark.chance <= 1, `mark {mark.id} chance must be 0..1`)
end
check(Species.sizeRoll.min > 0 and Species.sizeRoll.max > Species.sizeRoll.min, "size clamp must be ordered")

-- Fishing, ring and pull -------------------------------------------------------------------------------------
for mode, ring in Fishing.ring do
	check(positive(ring.lap) and ring.arc > 0 and ring.arc < 360, `ring {mode} lap and arc`)
	check(ring.missBudget >= 1, `ring {mode} needs a miss budget`)
	local range = Fishing.biteWait[mode]
	check(range ~= nil and range.min > 0 and range.max >= range.min, `bite wait for {mode}`)
end
check(Fishing.tapSpacing >= 0.1, "tap spacing below 0.1 s invites auto-clicker abuse")
check(
	Fishing.pull.chargedCap <= 1 and Fishing.pull.chargedBase <= Fishing.pull.chargedCap,
	"Charged chance caps"
)
check(Fishing.pull.helperShare > 0 and Fishing.pull.helperShare < 1, "helper share must be a fraction")
check(Species.byId[Fishing.firstCatch.species] ~= nil, "first catch species exists")
check(Species.byId[Fishing.firstRainCatch.species] ~= nil, "first rain catch species exists")

-- Weather timetable ------------------------------------------------------------------------------------------
local covered = 0
for _, row in WeatherConfig.timetable do
	check(row.from == covered, `timetable gap or overlap at {covered}`)
	covered = row.to
	for _, spot in WeatherConfig.spots do
		local weather = (row :: any)[spot]
		check(
			weather == "clear" or weather == "showers" or weather == "fog" or weather == "storm",
			`timetable {row.from}-{row.to} {spot}: {tostring(weather)}`
		)
	end
	check((row :: any).cove_dock == "clear" or (row :: any).cove_dock == "storm", "cove_dock is sheltered")
end
check(covered == WeatherConfig.cycleSeconds, "timetable must cover the whole cycle")

-- World layout ----------------------------------------------------------------------------------------------
local sheltered = 0
for _, spot in WorldLayout.spots do
	check(table.find(WeatherConfig.spots, spot.id) ~= nil, `spot {spot.id} is not in the timetable`)
	if spot.sheltered then
		sheltered += 1
		check(not spot.callable, `sheltered spot {spot.id} must not be callable`)
	end
	local root = { spot.stand[1], spot.stand[2] + WorldLayout.standRootHeight, spot.stand[3] }
	local d = math.sqrt(
		(root[1] - spot.ripple[1]) ^ 2 + (root[2] - spot.ripple[2]) ^ 2 + (root[3] - spot.ripple[3]) ^ 2
	)
	check(
		d <= Fishing.castRange,
		`spot {spot.id} stand is {d} studs from its ripple (cast range {Fishing.castRange})`
	)
end
check(sheltered == 1, "exactly one sheltered spot")

-- Zones and upgrades -------------------------------------------------------------------------------------------
for index, zone in Zones do
	check(zone.order == index, `zone {zone.id} order must be {index}`)
end
check(Zones[1] ~= nil and Zones[1].gateCost == 0, "the first zone must be free")
local upgradeIds: { [string]: boolean } = {}
for _, def in Upgrades do
	check(not upgradeIds[def.id], `duplicate upgrade {def.id}`)
	upgradeIds[def.id] = true
	check(positive(def.baseCost) and def.costGrowth > 1, `upgrade {def.id} cost curve must grow`)
	check(def.maxLevel >= 1, `upgrade {def.id} needs a max level`)
end
check(upgradeIds[Onboarding.upgradeForStep6] == true, "onboarding step 6 names an upgrade that exists")

-- Products and passes (the prototype sells nothing: every id must stay 0) --------------------------------------
local productKeys: { [string]: boolean } = {}
local function claimId(id: number, owner: string)
	check(id == 0, `{owner} has a Roblox id ({id}): the prototype sells nothing (prototype brief req. 1)`)
	if release then
		table.insert(blockers, `{owner} has no Roblox id (0): create it in Creator Hub or remove it`)
	end
end
for _, pass in Products.Passes do
	check(not productKeys[pass.key], `duplicate pass/product key {pass.key}`)
	productKeys[pass.key] = true
	claimId(pass.id, `pass {pass.key}`)
end
for _, product in Products.Products do
	check(not productKeys[product.key], `duplicate pass/product key {product.key}`)
	productKeys[product.key] = true
	claimId(product.id, `product {product.key}`)
end

-- Onboarding and remotes ------------------------------------------------------------------------------------
for index, step in Onboarding.steps do
	check(
		step.step == index,
		`onboarding step {step.name} must be number {index} (never renumber after launch)`
	)
end
for name, def in Remotes do
	local clientToServer = def.rate ~= nil or def.burst ~= nil or def.kind == "function"
	if clientToServer then
		check(
			def.rate ~= nil and def.burst ~= nil and (def.rate :: number) > 0 and (def.burst :: number) >= 1,
			`remote {name} needs rate and burst`
		)
	end
end

-- Release blockers ------------------------------------------------------------------------------------------
if release then
	if Game.isTemplateDefault then
		table.insert(
			blockers,
			"Config/Game.isTemplateDefault is still true (rename the game and set it to false)"
		)
	end
	if #Game.qaUserIds > 0 then
		table.insert(notes, `{#Game.qaUserIds} QA user id(s) can run QA commands in live servers`)
	end
end
if Game.groupId == 0 then
	table.insert(notes, "no community group configured (Config/Game.groupId = 0)")
end
if #Game.qaUserIds == 0 then
	table.insert(
		notes,
		"no QA user ids: twistStats and exportLog work in Studio only until the human adds theirs"
	)
end

-- Report ---------------------------------------------------------------------------------------------------
for _, message in errors do
	print(`ERROR    {message}`)
end
for _, message in blockers do
	print(`BLOCKER  {message}`)
end
for _, message in notes do
	print(`note     {message}`)
end
local failed = #errors > 0 or #blockers > 0
local mode = if release then " (release mode)" else ""
local verdict = if failed then "FAIL" else "OK"
print(`\n{#errors} errors, {#blockers} release blockers, {#notes} notes{mode}: {verdict}`)
process.exit(if failed then 1 else 0)
