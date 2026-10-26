--!strict
-- Passes and developer products for Reel the Storm (catalog: games/stormcatch/docs/catalog.md, T-0009).
-- Ids of 0 mean "not created yet": the product is hidden and disabled. The human creates every item in
-- Creator Hub at the build stage and the ids are pasted here. Prices are never stored here and never
-- hard-coded in UI: the client reads each player's own price at runtime (MarketplaceService).
-- Coin grants ("coinsMinutes") use economy sheet v2's one basis (§3.1, §19.2) in Util/Stats coinsForMinutes:
-- permanent multipliers only, never timed boosts, friends or the 2x Coins pass (catalog v2, T-0018).

export type PassDef = {
	key: string,
	id: number,
	name: string,
	description: string,
	cosmetic: boolean, -- style only: no effect on coins, luck, odds, capacity or time
	probabilityModifier: boolean, -- changes fish odds (hidden for restricted players; their paid luck is ignored)
	fundsRandomItems: boolean, -- adds Robux-bought coins that can be spent on nests (hidden for restricted players)
	shownFromStep: number, -- onboarding step from which the shop lists it (GDD §3.3; 12 = after the first bridge)
}

export type Weather = "Showers" | "SeaFog" | "Gusts"

export type ProductGrant =
	{ kind: "coinsMinutes", minutes: number }
	| { kind: "boost", boost: string, seconds: number }
	| { kind: "skyCall", weather: Weather } -- adds one saved Sky Call credit (GDD §4.10)
	| { kind: "cosmetic", items: { string } }
	| { kind: "bundle", grants: { ProductGrant } }

export type ProductDef = {
	key: string,
	id: number,
	name: string,
	description: string,
	oncePerPlayer: boolean,
	grant: ProductGrant,
	fundsRandomItems: boolean,
	probabilityModifier: boolean,
	shownFromStep: number,
}

local AFTER_FIRST_BRIDGE = 12 -- "Played 10 Minutes", which follows step 11 (bridge to Lantern Reef)

local Passes: { PassDef } = {
	{
		key = "x2Coins",
		id = 0,
		name = "2x Coins",
		description = "Double coins from every catch, starting once you fix the bridge to Lantern Reef. "
			.. "Adds to timed coin boosts (3x at most).",
		cosmetic = false,
		probabilityModifier = false,
		fundsRandomItems = false,
		shownFromStep = AFTER_FIRST_BRIDGE,
	},
	{
		key = "autoReel",
		id = 0,
		name = "Auto Reel",
		description = "Reels for you in Clear water after you cast, landing about two-thirds as many fish "
			.. "as you would. Showers, Sea Fog, Gusts and storms you reel yourself.",
		cosmetic = false,
		probabilityModifier = false,
		fundsRandomItems = false,
		shownFromStep = AFTER_FIRST_BRIDGE,
	},
	{
		key = "luckyBobber",
		id = 0,
		name = "Lucky Bobber",
		description = "+25% luck on Rare and rarer fish (the odds you see update). All paid luck together "
			.. "is capped at +25%. No extra luck in Sea Fog, on nests or on Stormborn.",
		cosmetic = false,
		probabilityModifier = true,
		fundsRandomItems = false,
		shownFromStep = AFTER_FIRST_BRIDGE,
	},
	{
		key = "palPouchPlus",
		id = 0,
		name = "Big Pal Pouch",
		description = "Room for 50 more companions, on top of your Pal Pouch upgrades.",
		cosmetic = false,
		probabilityModifier = false,
		fundsRandomItems = false,
		shownFromStep = AFTER_FIRST_BRIDGE,
	},
	{
		key = "tidePot3",
		id = 0,
		name = "Third Tide Pot",
		description = "A third Tide Pot slot. It fills at the same speed as your others: full in 8 hours.",
		cosmetic = false,
		probabilityModifier = false,
		fundsRandomItems = false,
		shownFromStep = AFTER_FIRST_BRIDGE,
	},
	{
		key = "rainGear",
		id = 0,
		name = "Rain Gear",
		description = "4 raincoat-and-hat colours and 2 umbrellas that open when it rains. Worn in this game. Style only.",
		cosmetic = true,
		probabilityModifier = false,
		fundsRandomItems = false,
		shownFromStep = AFTER_FIRST_BRIDGE,
	},
	{
		key = "bobberBox",
		id = 0,
		name = "Bobber Box",
		description = "6 bobber designs that everyone fishing near you can see. Style only.",
		cosmetic = true,
		probabilityModifier = false,
		fundsRandomItems = false,
		shownFromStep = AFTER_FIRST_BRIDGE,
	},
	{
		key = "lanternKeeper",
		id = 0,
		name = "Lantern Keeper Set",
		description = "A lantern coat and hat that glow softly in Sea Fog, a lantern bobber and a lantern "
			.. "umbrella. Worn in this game. Style only.",
		cosmetic = true,
		probabilityModifier = false,
		fundsRandomItems = false,
		shownFromStep = AFTER_FIRST_BRIDGE,
	},
}

local Products: { ProductDef } = {
	{
		key = "skyCallShowers",
		id = 0,
		name = "Sky Bell: Showers",
		description = "Calls Showers over the harbour for 3 minutes, on everyone's Sky Dial 1 minute ahead. "
			.. "Everyone in this server shares it, with +25% luck on Rare and rarer fish.",
		oncePerPlayer = false,
		grant = { kind = "skyCall", weather = "Showers" },
		fundsRandomItems = false,
		probabilityModifier = true,
		shownFromStep = AFTER_FIRST_BRIDGE,
	},
	{
		key = "skyCallSeaFog",
		id = 0,
		name = "Sky Bell: Sea Fog",
		description = "Calls Sea Fog over the harbour for 3 minutes, on everyone's Sky Dial 1 minute ahead. "
			.. "Everyone in this server shares it. Fog already doubles luck, so the bell adds none.",
		oncePerPlayer = false,
		grant = { kind = "skyCall", weather = "SeaFog" },
		fundsRandomItems = false,
		probabilityModifier = true,
		shownFromStep = AFTER_FIRST_BRIDGE,
	},
	{
		key = "skyCallGusts",
		id = 0,
		name = "Sky Bell: Gusts",
		description = "Calls Gusts over the harbour for 3 minutes, on everyone's Sky Dial 1 minute ahead. "
			.. "Everyone in this server shares it, with +25% luck on Rare and rarer fish.",
		oncePerPlayer = false,
		grant = { kind = "skyCall", weather = "Gusts" },
		fundsRandomItems = false,
		probabilityModifier = true,
		shownFromStep = AFTER_FIRST_BRIDGE,
	},
	{
		key = "starterPack",
		id = 0,
		name = "Starter Pack",
		description = "Coins worth about 30 minutes of fishing, a 15-minute 2x Coins boost and a raincoat "
			.. "colour found only here. Once per player.",
		oncePerPlayer = true,
		grant = {
			kind = "bundle",
			grants = {
				{ kind = "coinsMinutes", minutes = 30 },
				{ kind = "boost", boost = "coins2x", seconds = 900 },
				{ kind = "cosmetic", items = { "coat_starter" } },
			},
		},
		fundsRandomItems = true,
		probabilityModifier = false,
		shownFromStep = AFTER_FIRST_BRIDGE,
	},
	{
		key = "coinPouch",
		id = 0,
		name = "Coin Pouch",
		description = "Coins worth about 15 minutes of fishing, sized to your progress. Boosts and 2x Coins "
			.. "do not change the amount.",
		oncePerPlayer = false,
		grant = { kind = "coinsMinutes", minutes = 15 },
		fundsRandomItems = true,
		probabilityModifier = false,
		shownFromStep = AFTER_FIRST_BRIDGE,
	},
	{
		key = "coinCrate",
		id = 0,
		name = "Coin Crate",
		description = "Coins worth about 60 minutes of fishing, sized to your progress. Boosts and 2x Coins "
			.. "do not change the amount.",
		oncePerPlayer = false,
		grant = { kind = "coinsMinutes", minutes = 60 },
		fundsRandomItems = true,
		probabilityModifier = false,
		shownFromStep = AFTER_FIRST_BRIDGE,
	},
	{
		key = "coinChest",
		id = 0,
		name = "Coin Chest",
		description = "Coins worth about 3 hours of fishing, sized to your progress. Boosts and 2x Coins "
			.. "do not change the amount.",
		oncePerPlayer = false,
		grant = { kind = "coinsMinutes", minutes = 180 },
		fundsRandomItems = true,
		probabilityModifier = false,
		shownFromStep = AFTER_FIRST_BRIDGE,
	},
}

local passByKey: { [string]: PassDef } = {}
for _, pass in Passes do
	passByKey[pass.key] = pass
end

local productByKey: { [string]: ProductDef } = {}
local productById: { [number]: ProductDef } = {}
for _, product in Products do
	productByKey[product.key] = product
	if product.id ~= 0 then
		productById[product.id] = product
	end
end

return table.freeze({
	Passes = Passes,
	Products = Products,
	passByKey = passByKey,
	productByKey = productByKey,
	productById = productById,
	-- Timed boosts by boost id. Coin boosts add to the 2x Coins pass; the boost category is capped at x3
	-- (economy sheet §11). luckyTide is a free reward (calendar day 7, codes), never sold.
	boostEffects = table.freeze({
		coins2x = { coinsBonus = 1 },
		luckyTide = { freeSkyLuck = 0.25 },
	}),
	passEffects = table.freeze({
		x2CoinsBonus = 1, -- additive with coins2x (economy sheet §11)
		x2CoinsFromZone = "lantern_reef", -- no 2x Coins before the first bridge (economist, T-0008)
		autoReelSuccess = 0.70, -- fixed; no perk or upgrade raises it
		autoReelTimeFactor = 2, -- each auto reel takes twice as long as the weather's ring
		autoReelWeathers = table.freeze({ "Clear", "Rainbow", "Aurora" }), -- Clear-ring water only
		luckyBobberSkyLuck = 0.25, -- paid Sky luck, inside the +25% paid cap (economy sheet §10)
		palPouchPlusCapacity = 50,
		extraTidePots = 1,
	}),
	-- Cosmetic item ids per pass (names and looks: Artist; no gameplay effect anywhere).
	passCosmetics = table.freeze({
		rainGear = table.freeze({ "coat_a", "coat_b", "coat_c", "coat_d", "umbrella_a", "umbrella_b" }),
		bobberBox = table.freeze({ "bobber_a", "bobber_b", "bobber_c", "bobber_d", "bobber_e", "bobber_f" }),
		lanternKeeper = table.freeze({ "coat_lantern", "bobber_lantern", "umbrella_lantern" }),
		luckyBobber = table.freeze({ "bobber_clover" }),
	}),
})
