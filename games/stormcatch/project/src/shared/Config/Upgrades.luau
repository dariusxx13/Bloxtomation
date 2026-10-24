--!strict
-- Soft-currency upgrade lines. cost(level) = baseCost * costGrowth ^ level.
-- `effect` meaning depends on `kind` (see Util/Stats.luau).

export type UpgradeKind = "power" | "speed" | "luck" | "storage"

export type UpgradeDef = {
	id: string,
	kind: UpgradeKind,
	name: string,
	description: string,
	baseCost: number,
	costGrowth: number,
	effect: number,
	maxLevel: number,
	resetsOnRebirth: boolean,
	order: number,
}

local Upgrades: { UpgradeDef } = {
	{
		id = "power",
		kind = "power",
		name = "Power",
		description = "More coins per hit",
		baseCost = 15,
		costGrowth = 1.28,
		effect = 1.14, -- coins per hit multiplied by this per level
		maxLevel = 400,
		resetsOnRebirth = true,
		order = 1,
	},
	{
		id = "speed",
		kind = "speed",
		name = "Speed",
		description = "Walk faster",
		baseCost = 60,
		costGrowth = 1.55,
		effect = 1, -- +1 walk speed per level
		maxLevel = 16,
		resetsOnRebirth = true,
		order = 2,
	},
	{
		id = "luck",
		kind = "luck",
		name = "Luck",
		description = "Better odds on eggs",
		baseCost = 400,
		costGrowth = 1.6,
		effect = 0.05, -- +5% luck per level
		maxLevel = 20,
		resetsOnRebirth = false,
		order = 3,
	},
	{
		id = "storage",
		kind = "storage",
		name = "Pet Storage",
		description = "Hold more pets",
		baseCost = 1000,
		costGrowth = 1.8,
		effect = 10, -- +10 pet capacity per level
		maxLevel = 10,
		resetsOnRebirth = false,
		order = 4,
	},
}

return table.freeze(Upgrades)
