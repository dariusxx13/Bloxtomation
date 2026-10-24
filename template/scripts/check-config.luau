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

local Codes = require("../src/shared/Config/Codes")
local Economy = require("../src/shared/Config/Economy")
local Eggs = require("../src/shared/Config/Eggs")
local Game = require("../src/shared/Config/Game")
local Onboarding = require("../src/shared/Config/Onboarding")
local Pets = require("../src/shared/Config/Pets")
local Products = require("../src/shared/Config/Products")
local Remotes = require("../src/shared/Config/Remotes")
local Rewards = require("../src/shared/Config/Rewards")
local Upgrades = require("../src/shared/Config/Upgrades")
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

-- Pets and rarities ------------------------------------------------------------------------------
local kinds: { [string]: boolean } = {}
for _, pet in Pets.Catalog do
	check(not kinds[pet.kind], `duplicate pet kind {pet.kind}`)
	kinds[pet.kind] = true
	check(Pets.rarityById[pet.rarity] ~= nil, `pet {pet.kind} has unknown rarity {pet.rarity}`)
	check(pet.bonus >= 0, `pet {pet.kind} has a negative bonus`)
	check(#pet.color == 3, `pet {pet.kind} color must be {"{"}r, g, b{"}"}`)
end
for index, rarity in Pets.Rarities do
	check(rarity.order == index, `rarity {rarity.id} order must be {index}`)
end

-- Eggs ------------------------------------------------------------------------------------------------
local zoneIds: { [string]: boolean } = {}
for _, zone in Zones do
	zoneIds[zone.id] = true
end
for _, egg in Eggs.list do
	check(zoneIds[egg.zoneId] == true, `egg {egg.id} references unknown zone {egg.zoneId}`)
	check(positive(egg.price), `egg {egg.id} price must be positive`)
	check(#egg.entries > 0, `egg {egg.id} has no entries`)
	local seen: { [string]: boolean } = {}
	for _, entry in egg.entries do
		check(kinds[entry.kind] == true, `egg {egg.id} references unknown pet {entry.kind}`)
		check(positive(entry.weight), `egg {egg.id} weight for {entry.kind} must be positive`)
		check(not seen[entry.kind], `egg {egg.id} lists {entry.kind} twice`)
		seen[entry.kind] = true
	end
	if egg.pity then
		check(Pets.rarityById[egg.pity.rarity] ~= nil, `egg {egg.id} pity rarity {egg.pity.rarity} unknown`)
		check(egg.pity.afterRolls >= 10, `egg {egg.id} pity is suspiciously low`)
		local reachable = false
		for _, entry in egg.entries do
			local pet = Pets.byKind[entry.kind]
			local petRarity = pet and Pets.rarityById[pet.rarity]
			local pityRarity = Pets.rarityById[egg.pity.rarity]
			if petRarity and pityRarity and petRarity.order >= pityRarity.order then
				reachable = true
			end
		end
		check(reachable, `egg {egg.id} pity rarity {egg.pity.rarity} is not in its drop table`)
	end
end

-- Zones -----------------------------------------------------------------------------------------------------
for index, zone in Zones do
	check(zone.order == index, `zone {zone.id} order must be {index}`)
	if index == 1 then
		check(zone.gateCost == 0, "the first zone must be free")
	else
		check(
			zone.gateCost > Zones[index - 1].gateCost,
			`zone {zone.id} gate must cost more than the previous one`
		)
		check(
			zone.valueMultiplier > Zones[index - 1].valueMultiplier,
			`zone {zone.id} must pay more than the previous one`
		)
	end
	if zone.eggId then
		check(Eggs.byId[zone.eggId] ~= nil, `zone {zone.id} references unknown egg {zone.eggId}`)
	end
end

-- Upgrades ---------------------------------------------------------------------------------------------------
local upgradeIds: { [string]: boolean } = {}
for _, def in Upgrades do
	check(not upgradeIds[def.id], `duplicate upgrade {def.id}`)
	upgradeIds[def.id] = true
	check(positive(def.baseCost) and def.costGrowth > 1, `upgrade {def.id} cost curve must grow`)
	check(def.maxLevel >= 1, `upgrade {def.id} needs a max level`)
end

-- Products and passes -------------------------------------------------------------------------------------
local boostIds = Products.boostEffects :: any
local productKeys: { [string]: boolean } = {}
local robloxIds: { [number]: string } = {}
local function claimId(id: number, owner: string)
	if id ~= 0 then
		check(robloxIds[id] == nil, `id {id} used by both {robloxIds[id]} and {owner}`)
		robloxIds[id] = owner
	elseif release then
		table.insert(blockers, `{owner} has no Roblox id (0): create it in Creator Hub or remove it`)
	end
end
for _, pass in Products.Passes do
	check(not productKeys[pass.key], `duplicate pass/product key {pass.key}`)
	productKeys[pass.key] = true
	claimId(pass.id, `pass {pass.key}`)
end
local function checkGrant(owner: string, grant: Products.ProductGrant)
	if grant.kind == "boost" or grant.kind == "serverBoost" then
		check(boostIds[grant.boost] ~= nil, `{owner} grants unknown boost {grant.boost}`)
		check(positive(grant.seconds), `{owner} boost seconds must be positive`)
	elseif grant.kind == "coinsMinutes" then
		check(positive(grant.minutes), `{owner} minutes must be positive`)
	elseif grant.kind == "gems" then
		check(positive(grant.amount), `{owner} gem amount must be positive`)
	elseif grant.kind == "bundle" then
		for _, inner in grant.grants do
			checkGrant(owner, inner)
		end
	end
end
for _, product in Products.Products do
	check(not productKeys[product.key], `duplicate pass/product key {product.key}`)
	productKeys[product.key] = true
	claimId(product.id, `product {product.key}`)
	checkGrant(`product {product.key}`, product.grant)
	if product.grant.kind == "boost" and boostIds[(product.grant :: any).boost] then
		local effect = boostIds[(product.grant :: any).boost]
		if effect.luck then
			check(
				product.probabilityModifier,
				`product {product.key} changes luck but is not marked probabilityModifier`
			)
		end
	end
end

-- Rewards and codes ----------------------------------------------------------------------------------------
local function checkReward(owner: string, reward: Rewards.Reward)
	if reward.boost then
		check(boostIds[reward.boost] ~= nil, `{owner} grants unknown boost {reward.boost}`)
		check(
			reward.boostSeconds ~= nil and positive(reward.boostSeconds),
			`{owner} boost needs boostSeconds`
		)
	end
end
check(#Rewards.daily == 7, "the daily calendar should have 7 days")
for index, reward in Rewards.daily do
	checkReward(`daily day {index}`, reward)
end
local lastMinutes = 0
for index, gift in Rewards.playtime do
	check(gift.minutes > lastMinutes, `playtime gift {index} must come after the previous one`)
	lastMinutes = gift.minutes
	checkReward(`playtime gift {index}`, gift.reward)
end
for _, def in Codes.list do
	check(#def.code <= Codes.maxLength, `code {def.code} is longer than {Codes.maxLength}`)
	check(
		string.match(def.code, "^[%w_%-]+$") ~= nil,
		`code {def.code} has characters players can't type reliably`
	)
	checkReward(`code {def.code}`, def :: any)
	if def.expiresAt == 0 then
		table.insert(notes, `code {def.code} never expires`)
	end
end

-- Onboarding and remotes ------------------------------------------------------------------------------------
for index, step in Onboarding.steps do
	check(
		step.step == index,
		`onboarding step {step.name} must be number {index} (never renumber after launch)`
	)
end
for name, def in Remotes do
	local clientToServer = def.rate ~= nil or def.burst ~= nil
	if clientToServer then
		check(
			def.rate ~= nil and def.burst ~= nil and def.rate > 0 and def.burst >= 1,
			`remote {name} needs rate and burst`
		)
	end
end

-- Economy caps ---------------------------------------------------------------------------------------------
check(Economy.maxLuck >= 1 and Economy.maxPetMultiplier >= 1, "multiplier caps must be at least 1")
check(Economy.hitCooldownSeconds >= 0.1, "hit cooldown below 0.1s invites auto-clicker abuse")

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
