--!strict
-- Rarity tiers and the pet catalog. Original placeholder pets; replace with your game's own.
-- `bonus` is added to the pet multiplier: total = 1 + sum(equipped bonuses), capped in Economy.

local Types = require("../Types")

export type RarityDef = {
	id: Types.RarityId,
	order: number,
	color: { number },
	luckApplies: boolean, -- luck multiplies this tier's weight (vault: 03-rarity-and-rng/rng-systems-and-pity.md)
	announce: "none" | "server" | "global",
}

export type PetDef = {
	kind: string,
	name: string,
	rarity: Types.RarityId,
	bonus: number,
	color: { number },
	shape: "Ball" | "Block" | "Cylinder",
}

local Rarities: { RarityDef } = {
	{ id = "Common", order = 1, color = { 200, 200, 200 }, luckApplies = false, announce = "none" },
	{ id = "Uncommon", order = 2, color = { 90, 210, 100 }, luckApplies = false, announce = "none" },
	{ id = "Rare", order = 3, color = { 70, 150, 255 }, luckApplies = true, announce = "none" },
	{ id = "Epic", order = 4, color = { 170, 90, 255 }, luckApplies = true, announce = "none" },
	{ id = "Legendary", order = 5, color = { 255, 190, 40 }, luckApplies = true, announce = "server" },
	{ id = "Mythic", order = 6, color = { 255, 70, 110 }, luckApplies = true, announce = "server" },
	{ id = "Secret", order = 7, color = { 30, 30, 30 }, luckApplies = true, announce = "global" },
}

local Catalog: { PetDef } = {
	-- Meadow
	{
		kind = "pebble_pup",
		name = "Pebble Pup",
		rarity = "Common",
		bonus = 0.10,
		color = { 170, 160, 150 },
		shape = "Ball",
	},
	{
		kind = "leaf_bunny",
		name = "Leaf Bunny",
		rarity = "Uncommon",
		bonus = 0.20,
		color = { 120, 200, 90 },
		shape = "Ball",
	},
	{
		kind = "dew_drake",
		name = "Dew Drake",
		rarity = "Rare",
		bonus = 0.40,
		color = { 80, 170, 255 },
		shape = "Cylinder",
	},
	{
		kind = "bloom_owl",
		name = "Bloom Owl",
		rarity = "Epic",
		bonus = 0.80,
		color = { 230, 120, 200 },
		shape = "Ball",
	},
	{
		kind = "sunbeam_fox",
		name = "Sunbeam Fox",
		rarity = "Legendary",
		bonus = 1.60,
		color = { 255, 200, 60 },
		shape = "Block",
	},
	-- Desert
	{
		kind = "dune_beetle",
		name = "Dune Beetle",
		rarity = "Common",
		bonus = 0.40,
		color = { 200, 170, 100 },
		shape = "Block",
	},
	{
		kind = "cactus_cub",
		name = "Cactus Cub",
		rarity = "Uncommon",
		bonus = 0.80,
		color = { 80, 160, 80 },
		shape = "Cylinder",
	},
	{
		kind = "mirage_cat",
		name = "Mirage Cat",
		rarity = "Rare",
		bonus = 1.6,
		color = { 250, 220, 160 },
		shape = "Ball",
	},
	{
		kind = "sandstorm_hawk",
		name = "Sandstorm Hawk",
		rarity = "Epic",
		bonus = 3.2,
		color = { 190, 130, 70 },
		shape = "Block",
	},
	{
		kind = "pharaoh_serpent",
		name = "Golden Serpent",
		rarity = "Legendary",
		bonus = 6.4,
		color = { 255, 215, 0 },
		shape = "Cylinder",
	},
	-- Glacier
	{
		kind = "frost_seal",
		name = "Frost Seal",
		rarity = "Common",
		bonus = 1.6,
		color = { 220, 240, 255 },
		shape = "Ball",
	},
	{
		kind = "snow_lynx",
		name = "Snow Lynx",
		rarity = "Uncommon",
		bonus = 3.2,
		color = { 240, 240, 255 },
		shape = "Block",
	},
	{
		kind = "aurora_moth",
		name = "Aurora Moth",
		rarity = "Rare",
		bonus = 6.4,
		color = { 120, 255, 200 },
		shape = "Ball",
	},
	{
		kind = "glacier_golem",
		name = "Glacier Golem",
		rarity = "Epic",
		bonus = 12.8,
		color = { 140, 190, 255 },
		shape = "Block",
	},
	{
		kind = "crystal_phoenix",
		name = "Crystal Phoenix",
		rarity = "Mythic",
		bonus = 40,
		color = { 160, 230, 255 },
		shape = "Cylinder",
	},
	-- Volcano
	{
		kind = "ember_newt",
		name = "Ember Newt",
		rarity = "Common",
		bonus = 6.4,
		color = { 255, 120, 60 },
		shape = "Ball",
	},
	{
		kind = "magma_ram",
		name = "Magma Ram",
		rarity = "Uncommon",
		bonus = 12.8,
		color = { 200, 70, 40 },
		shape = "Block",
	},
	{
		kind = "cinder_wolf",
		name = "Cinder Wolf",
		rarity = "Rare",
		bonus = 25.6,
		color = { 90, 60, 60 },
		shape = "Block",
	},
	{
		kind = "lava_wyrm",
		name = "Lava Wyrm",
		rarity = "Legendary",
		bonus = 100,
		color = { 255, 90, 0 },
		shape = "Cylinder",
	},
	{
		kind = "core_titan",
		name = "Core Titan",
		rarity = "Mythic",
		bonus = 200,
		color = { 255, 40, 40 },
		shape = "Block",
	},
	-- Nebula
	{
		kind = "star_jelly",
		name = "Star Jelly",
		rarity = "Common",
		bonus = 25.6,
		color = { 200, 150, 255 },
		shape = "Ball",
	},
	{
		kind = "comet_kit",
		name = "Comet Kit",
		rarity = "Rare",
		bonus = 100,
		color = { 150, 220, 255 },
		shape = "Ball",
	},
	{
		kind = "void_ray",
		name = "Void Ray",
		rarity = "Legendary",
		bonus = 400,
		color = { 60, 0, 120 },
		shape = "Cylinder",
	},
	{
		kind = "galaxy_dragon",
		name = "Galaxy Dragon",
		rarity = "Mythic",
		bonus = 900,
		color = { 255, 120, 255 },
		shape = "Cylinder",
	},
	{
		kind = "the_last_light",
		name = "The Last Light",
		rarity = "Secret",
		bonus = 5000,
		color = { 255, 255, 255 },
		shape = "Ball",
	},
}

local byKind: { [string]: PetDef } = {}
for _, def in Catalog do
	byKind[def.kind] = def
end

local rarityById: { [string]: RarityDef } = {}
for _, rarity in Rarities do
	rarityById[rarity.id] = rarity
end

return table.freeze({
	Rarities = Rarities,
	Catalog = Catalog,
	byKind = byKind,
	rarityById = rarityById,
	baseEquipSlots = 3,
	baseCapacity = 60,
})
