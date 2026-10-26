--!strict
-- Fish species, drop tables, size roll and marks for the prototype.
-- Every number is economy sheet v2 §14 (prototype subset), with §8, §9.3 and §9.4 where named; copied into
-- games/stormcatch/docs/specs/prototype.md req. 5. If the sheet changes, the sheet wins.
-- Pure module. Probability = weight / table total (Util/Odds, the same code the server rolls with).

local Types = require("../Types")

export type Pool = "clear" | "showers" | "fog" | "storm"

export type SpeciesDef = {
	id: string,
	name: string,
	tier: Types.RarityId,
	pool: Pool, -- which table row group it belongs to
	weight: number, -- 0 for the Stormborn (hooked by chance at the eye, req. 9.3)
	baseCoins: number,
	baseKg: number,
	stormborn: boolean,
}

export type MarkDef = {
	id: Types.MarkId,
	name: string,
	weather: Types.Weather, -- where it can roll
	chance: number, -- per catch in that weather; Charged is decided by a flash tap or the giant roll instead
	multiplier: number,
}

local List: { SpeciesDef } = {
	{
		id = "pebble_minnow",
		name = "Pebble Minnow",
		tier = "Common",
		pool = "clear",
		weight = 26,
		baseCoins = 5,
		baseKg = 0.8,
		stormborn = false,
	},
	{
		id = "bobblefin",
		name = "Bobblefin",
		tier = "Common",
		pool = "clear",
		weight = 22,
		baseCoins = 5,
		baseKg = 0.8,
		stormborn = false,
	},
	{
		id = "sandskipper",
		name = "Sandskipper",
		tier = "Common",
		pool = "clear",
		weight = 18,
		baseCoins = 5,
		baseKg = 0.8,
		stormborn = false,
	},
	{
		id = "tidetail",
		name = "Tidetail",
		tier = "Uncommon",
		pool = "clear",
		weight = 13,
		baseCoins = 10,
		baseKg = 2,
		stormborn = false,
	},
	{
		id = "kelpnibbler",
		name = "Kelpnibbler",
		tier = "Uncommon",
		pool = "clear",
		weight = 11,
		baseCoins = 10,
		baseKg = 2,
		stormborn = false,
	},
	{
		id = "copperscale",
		name = "Copperscale",
		tier = "Rare",
		pool = "clear",
		weight = 6,
		baseCoins = 20,
		baseKg = 5,
		stormborn = false,
	},
	{
		id = "splashkin",
		name = "Splashkin",
		tier = "Uncommon",
		pool = "showers",
		weight = 15,
		baseCoins = 10,
		baseKg = 2,
		stormborn = false,
	},
	{
		id = "pitterpike",
		name = "Pitterpike",
		tier = "Rare",
		pool = "showers",
		weight = 6.5,
		baseCoins = 20,
		baseKg = 5,
		stormborn = false,
	},
	{
		id = "hushgill",
		name = "Hushgill",
		tier = "Rare", -- sheet §14 (the brief's first draft said Uncommon; the sheet wins)
		pool = "fog",
		weight = 6,
		baseCoins = 20,
		baseKg = 5,
		stormborn = false,
	},
	{
		id = "lanternfin",
		name = "Lanternfin",
		tier = "Epic",
		pool = "fog",
		weight = 2.2,
		baseCoins = 50,
		baseKg = 12,
		stormborn = false,
	},
	{
		id = "rumblefin",
		name = "Rumblefin",
		tier = "Mythic", -- the only Stormborn; 250 = its Mythic tier value at half (sheet §8)
		pool = "storm",
		weight = 0,
		baseCoins = 250,
		baseKg = 180,
		stormborn = true,
	},
}

local Marks: { MarkDef } = {
	{ id = "drizzled", name = "Drizzled", weather = "showers", chance = 0.20, multiplier = 1.5 },
	{ id = "misty", name = "Misty", weather = "fog", chance = 0.15, multiplier = 2 },
	{ id = "charged", name = "Charged", weather = "storm", chance = 0, multiplier = 3 },
}

local byId: { [string]: SpeciesDef } = {}
for _, def in List do
	byId[def.id] = def
end

local markById: { [string]: MarkDef } = {}
for _, mark in Marks do
	markById[mark.id] = mark
end

return table.freeze({
	list = List,
	byId = byId,
	marks = Marks,
	markById = markById,

	-- Row groups per weather table. Showers adds its two rows to Clear; Sea Fog adds its two rows.
	-- The storm away from the eye, and every non-Stormborn eye bite, rolls the Clear table.
	tables = table.freeze({
		clear = { "clear" } :: { Pool },
		showers = { "clear", "showers" } :: { Pool },
		fog = { "clear", "fog" } :: { Pool },
	}),
	-- Multiplier on Rare-and-up weights per weather: natural Sea Fog's +100% Sky luck. No other luck exists.
	tableLuck = table.freeze({ clear = 1, showers = 1, fog = 2 }),

	-- Size roll (sheet §9.3): factor = clamp(exp(N(-sigma^2/2, sigma)), min, max); kg = base kg * factor.
	sizeRoll = table.freeze({ sigma = 0.25, stormbornSigma = 0.30, min = 0.5, max = 3.0 }),

	-- The Stormborn hook at the eye (sheet §8, §14). The launch pity (60 eye bites) is not built (brief req. 9.3).
	stormborn = table.freeze({ id = "rumblefin", hookChance = 0.04, maxPerPlayerPerStorm = 1 }),
})
