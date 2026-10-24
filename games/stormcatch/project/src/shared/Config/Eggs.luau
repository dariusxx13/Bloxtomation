--!strict
-- Eggs and their drop tables. Weights, not percentages: probability = weight / total.
-- The odds shown to players are computed from these same tables (Util/Odds.luau).
-- Coins can be bought with Robux, so these eggs count as paid random items under Roblox policy:
-- odds are always displayed, and Robux paths to coins are hidden for restricted players.

export type EggEntry = { kind: string, weight: number }

export type EggDef = {
	id: string,
	name: string,
	zoneId: string,
	price: number,
	entries: { EggEntry },
	pity: { rarity: string, afterRolls: number }?, -- hard pity: guaranteed `rarity` or better
}

local Eggs: { EggDef } = {
	{
		id = "meadow_egg",
		name = "Meadow Egg",
		zoneId = "meadow",
		price = 120,
		entries = {
			{ kind = "pebble_pup", weight = 60 },
			{ kind = "leaf_bunny", weight = 28 },
			{ kind = "dew_drake", weight = 9 },
			{ kind = "bloom_owl", weight = 2.6 },
			{ kind = "sunbeam_fox", weight = 0.4 },
		},
		pity = { rarity = "Legendary", afterRolls = 600 },
	},
	{
		id = "desert_egg",
		name = "Desert Egg",
		zoneId = "desert",
		price = 4500,
		entries = {
			{ kind = "dune_beetle", weight = 60 },
			{ kind = "cactus_cub", weight = 28 },
			{ kind = "mirage_cat", weight = 9 },
			{ kind = "sandstorm_hawk", weight = 2.6 },
			{ kind = "pharaoh_serpent", weight = 0.4 },
		},
		pity = { rarity = "Legendary", afterRolls = 600 },
	},
	{
		id = "glacier_egg",
		name = "Glacier Egg",
		zoneId = "glacier",
		price = 300000,
		entries = {
			{ kind = "frost_seal", weight = 60 },
			{ kind = "snow_lynx", weight = 28 },
			{ kind = "aurora_moth", weight = 9.5 },
			{ kind = "glacier_golem", weight = 2.4 },
			{ kind = "crystal_phoenix", weight = 0.1 },
		},
		pity = { rarity = "Epic", afterRolls = 100 },
	},
	{
		id = "volcano_egg",
		name = "Volcano Egg",
		zoneId = "volcano",
		price = 6000000,
		entries = {
			{ kind = "ember_newt", weight = 62 },
			{ kind = "magma_ram", weight = 28 },
			{ kind = "cinder_wolf", weight = 9.6 },
			{ kind = "lava_wyrm", weight = 0.38 },
			{ kind = "core_titan", weight = 0.02 },
		},
		pity = { rarity = "Legendary", afterRolls = 650 },
	},
	{
		id = "nebula_egg",
		name = "Nebula Egg",
		zoneId = "nebula",
		price = 120000000,
		entries = {
			{ kind = "star_jelly", weight = 80 },
			{ kind = "comet_kit", weight = 19.5 },
			{ kind = "void_ray", weight = 0.49 },
			{ kind = "galaxy_dragon", weight = 0.0099 },
			{ kind = "the_last_light", weight = 0.0001 },
		},
		pity = nil,
	},
}

local byId: { [string]: EggDef } = {}
for _, egg in Eggs do
	byId[egg.id] = egg
end

return table.freeze({
	list = Eggs,
	byId = byId,
	maxHatchCount = 3, -- 1 normally; 3 with the Triple Hatch pass
	hatchRange = 18, -- studs from the egg stand
})
