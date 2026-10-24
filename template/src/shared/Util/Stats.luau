--!strict
-- Derives gameplay numbers from persisted data + session state. Pure module used by both sides:
-- the server result is authoritative; the client uses it only for display and prediction.

local Economy = require("../Config/Economy")
local Pets = require("../Config/Pets")
local Products = require("../Config/Products")
local Upgrades = require("../Config/Upgrades")
local Zones = require("../Config/Zones")
local Types = require("../Types")
local EconomyMath = require("./EconomyMath")

local Stats = {}

local function upgradeLevel(data: Types.ProfileData, kind: Upgrades.UpgradeKind): number
	for _, def in Upgrades do
		if def.kind == kind then
			return data.upgrades[def.id] or 0
		end
	end
	return 0
end

local function upgradeEffect(kind: Upgrades.UpgradeKind): number
	for _, def in Upgrades do
		if def.kind == kind then
			return def.effect
		end
	end
	return 0
end

local function boostActive(data: Types.ProfileData, boost: string, now: number): boolean
	local expiry = data.boosts[boost]
	return expiry ~= nil and expiry > now
end

function Stats.petMultiplier(data: Types.ProfileData): number
	local byId: { [string]: Types.OwnedPet } = {}
	for _, pet in data.pets do
		byId[pet.id] = pet
	end
	local total = 1
	for _, id in data.equipped do
		local pet = byId[id]
		local def = pet and Pets.byKind[pet.kind]
		if def then
			total += def.bonus
		end
	end
	return math.min(total, Economy.maxPetMultiplier)
end

function Stats.zoneMultiplier(zoneId: string): number
	for _, zone in Zones do
		if zone.id == zoneId then
			return zone.valueMultiplier
		end
	end
	return 1
end

function Stats.derive(data: Types.ProfileData, session: Types.SessionState?, now: number): Types.DerivedStats
	local passes = if session then session.passes else {}
	local coinMultiplier = 1
	if passes.x2Coins then
		coinMultiplier *= Products.passEffects.x2CoinsMultiplier
	end
	if boostActive(data, "coins2x", now) then
		coinMultiplier *= Products.boostEffects.coins2x.coins
	end
	-- Additive bonuses (VIP, friends, streak) share one category
	local additive = 0
	if passes.vip then
		additive += Products.passEffects.vipCoinBonus
	end
	if session then
		additive += session.friendBonus
	end
	coinMultiplier *= 1 + additive

	local rebirthMultiplier = EconomyMath.rebirthMultiplier(data.rebirths)
	local petMultiplier = Stats.petMultiplier(data)
	local power = EconomyMath.powerMultiplier(upgradeLevel(data, "power"))
	local coinsPerHit = Economy.baseCoinsPerHit * power * petMultiplier * rebirthMultiplier * coinMultiplier

	-- Luck: additive inside the category, multiplied by boosts, capped (vault: rng-systems-and-pity)
	local luck = 1 + upgradeLevel(data, "luck") * upgradeEffect("luck")
	local restricted = session ~= nil and session.randomItemsRestricted
	if passes.lucky and not restricted then
		luck += Products.passEffects.luckyLuckBonus
	end
	if boostActive(data, "luck2x", now) and not restricted then
		luck *= Products.boostEffects.luck2x.luck
	end
	if session and session.serverLuckUntil > now and not restricted then
		luck *= Products.boostEffects.serverLuck.luck
	end
	luck = math.min(luck, Economy.maxLuck)

	local petSlots = Pets.baseEquipSlots + (if passes.petSlots then Products.passEffects.extraPetSlots else 0)
	local petCapacity = Pets.baseCapacity + upgradeLevel(data, "storage") * upgradeEffect("storage")
	local walkSpeed = 16 + upgradeLevel(data, "speed") * upgradeEffect("speed")

	return {
		coinsPerHit = coinsPerHit,
		coinMultiplier = coinMultiplier,
		luck = luck,
		petSlots = petSlots,
		petCapacity = petCapacity,
		walkSpeed = walkSpeed,
		rebirthMultiplier = rebirthMultiplier,
		petMultiplier = petMultiplier,
	}
end

-- Converts "minutes of income" rewards into coins for the player's best unlocked zone.
function Stats.coinsForMinutes(data: Types.ProfileData, derived: Types.DerivedStats, minutes: number, hitsPerMinute: number): number
	local best = 1
	for _, zone in Zones do
		if data.zonesUnlocked[zone.id] then
			best = math.max(best, zone.valueMultiplier)
		end
	end
	return math.floor(derived.coinsPerHit * best * hitsPerMinute * minutes)
end

return Stats
