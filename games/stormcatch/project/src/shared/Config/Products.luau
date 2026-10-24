--!strict
-- Passes and developer products. Ids of 0 mean "not created yet": the product is hidden and disabled.
-- Create them in Creator Hub, paste the ids here, and never hard-code prices in UI (prices are fetched at runtime).

export type PassDef = {
	key: string,
	id: number,
	name: string,
	description: string,
	probabilityModifier: boolean, -- true if it changes random odds (hidden for restricted players)
}

export type ProductGrant =
	{ kind: "coinsMinutes", minutes: number }
	| { kind: "gems", amount: number }
	| { kind: "boost", boost: string, seconds: number }
	| { kind: "serverBoost", boost: string, seconds: number }
	| { kind: "bundle", grants: { ProductGrant } }

export type ProductDef = {
	key: string,
	id: number,
	name: string,
	description: string,
	oncePerPlayer: boolean,
	grant: ProductGrant,
	fundsRandomItems: boolean, -- true if it grants currency usable on eggs (hidden for restricted players)
	probabilityModifier: boolean,
}

local Passes: { PassDef } = {
	{
		key = "x2Coins",
		id = 0,
		name = "2x Coins",
		description = "Double coins from every hit, forever",
		probabilityModifier = false,
	},
	{
		key = "autoHit",
		id = 0,
		name = "Auto Hit",
		description = "Hits the nearest node for you",
		probabilityModifier = false,
	},
	{
		key = "petSlots",
		id = 0,
		name = "+3 Pet Slots",
		description = "Equip three more pets",
		probabilityModifier = false,
	},
	{
		key = "tripleHatch",
		id = 0,
		name = "Triple Hatch",
		description = "Hatch three eggs at once",
		probabilityModifier = false,
	},
	{
		key = "lucky",
		id = 0,
		name = "Lucky",
		description = "+50% luck on every egg (odds shown update)",
		probabilityModifier = true,
	},
	{
		key = "vip",
		id = 0,
		name = "VIP",
		description = "VIP tag and +10% coins",
		probabilityModifier = false,
	},
}

local Products: { ProductDef } = {
	{
		key = "starterPack",
		id = 0,
		name = "Starter Pack",
		description = "10 minutes of coins, 100 gems and a 15-minute 2x coins boost",
		oncePerPlayer = true,
		grant = {
			kind = "bundle",
			grants = {
				{ kind = "coinsMinutes", minutes = 10 },
				{ kind = "gems", amount = 100 },
				{ kind = "boost", boost = "coins2x", seconds = 900 },
			},
		},
		fundsRandomItems = true,
		probabilityModifier = false,
	},
	{
		key = "coinsSmall",
		id = 0,
		name = "Coin Pouch",
		description = "15 minutes of coins at your current rate",
		oncePerPlayer = false,
		grant = { kind = "coinsMinutes", minutes = 15 },
		fundsRandomItems = true,
		probabilityModifier = false,
	},
	{
		key = "coinsLarge",
		id = 0,
		name = "Coin Chest",
		description = "2 hours of coins at your current rate",
		oncePerPlayer = false,
		grant = { kind = "coinsMinutes", minutes = 120 },
		fundsRandomItems = true,
		probabilityModifier = false,
	},
	{
		key = "luckPotion",
		id = 0,
		name = "Luck Potion",
		description = "2x luck for 15 minutes (odds shown update)",
		oncePerPlayer = false,
		grant = { kind = "boost", boost = "luck2x", seconds = 900 },
		fundsRandomItems = false,
		probabilityModifier = true,
	},
	{
		key = "serverLuck",
		id = 0,
		name = "Server Luck",
		description = "2x luck for everyone in the server for 10 minutes",
		oncePerPlayer = false,
		grant = { kind = "serverBoost", boost = "serverLuck", seconds = 600 },
		fundsRandomItems = false,
		probabilityModifier = true,
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
	-- Boost effects (multipliers) by boost id
	boostEffects = table.freeze({
		coins2x = { coins = 2 },
		luck2x = { luck = 2 },
		serverLuck = { luck = 2 },
	}),
	passEffects = table.freeze({
		x2CoinsMultiplier = 2,
		vipCoinBonus = 0.1,
		luckyLuckBonus = 0.5,
		extraPetSlots = 3,
	}),
})
