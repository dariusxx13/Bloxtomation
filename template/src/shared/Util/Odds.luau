--!strict
-- Drop table math: effective weights with luck, displayed probabilities, weighted picks and pity.
-- Pure module. The server rolls with these functions and the client displays odds with the SAME functions,
-- so displayed odds always match real odds (Roblox paid random items policy).

local Eggs = require("../Config/Eggs")
local Pets = require("../Config/Pets")

local Odds = {}

export type WeightedOutcome = { kind: string, weight: number, probability: number, rarity: string }

local function rarityOrder(rarity: string): number
	local def = Pets.rarityById[rarity]
	return if def then def.order else 0
end

-- Applies luck by multiplying the weights of tiers marked `luckApplies`, then renormalizes.
function Odds.effective(egg: Eggs.EggDef, luck: number): { WeightedOutcome }
	local outcomes: { WeightedOutcome } = {}
	local total = 0
	for _, entry in egg.entries do
		local pet = Pets.byKind[entry.kind]
		assert(pet, `unknown pet kind {entry.kind} in egg {egg.id}`)
		local rarity = Pets.rarityById[pet.rarity]
		local weight = entry.weight
		if rarity and rarity.luckApplies then
			weight *= math.max(1, luck)
		end
		total += weight
		table.insert(
			outcomes,
			{ kind = entry.kind, weight = weight, probability = 0, rarity = pet.rarity :: string }
		)
	end
	for _, outcome in outcomes do
		outcome.probability = outcome.weight / total
	end
	return outcomes
end

-- Picks one outcome. `roll` is a number in [0, 1).
function Odds.pick(outcomes: { WeightedOutcome }, roll: number): WeightedOutcome
	local target = roll
	for _, outcome in outcomes do
		target -= outcome.probability
		if target < 0 then
			return outcome
		end
	end
	return outcomes[#outcomes] -- floating point safety net
end

-- Picks among outcomes at or above a rarity (used when hard pity triggers).
function Odds.pickAtLeast(outcomes: { WeightedOutcome }, minRarity: string, roll: number): WeightedOutcome
	local minOrder = rarityOrder(minRarity)
	local filtered: { WeightedOutcome } = {}
	local total = 0
	for _, outcome in outcomes do
		if rarityOrder(outcome.rarity) >= minOrder then
			table.insert(filtered, outcome)
			total += outcome.weight
		end
	end
	if #filtered == 0 then
		return Odds.pick(outcomes, roll)
	end
	local target = roll * total
	for _, outcome in filtered do
		target -= outcome.weight
		if target < 0 then
			return outcome
		end
	end
	return filtered[#filtered]
end

function Odds.meetsRarity(rarity: string, minRarity: string): boolean
	return rarityOrder(rarity) >= rarityOrder(minRarity)
end

-- Probability of at least one success in n tries.
function Odds.atLeastOnce(probability: number, tries: number): number
	return 1 - (1 - probability) ^ tries
end

-- Number of tries for a given chance of at least one success (e.g. 0.5 -> median).
function Odds.triesForChance(probability: number, chance: number): number
	if probability <= 0 then
		return math.huge
	end
	if probability >= 1 then
		return 1
	end
	return math.log(1 - chance) / math.log(1 - probability)
end

-- Sum of displayed probabilities (should be 1 within floating point error).
function Odds.total(outcomes: { WeightedOutcome }): number
	local sum = 0
	for _, outcome in outcomes do
		sum += outcome.probability
	end
	return sum
end

return Odds
