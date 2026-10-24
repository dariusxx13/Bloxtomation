--!strict
-- Zone chain. Each zone multiplies node value; gates cost soft currency.
-- Colors are RGB arrays so this module stays free of Roblox globals (testable in Lune).

export type ZoneDef = {
	id: string,
	name: string,
	order: number,
	gateCost: number,
	valueMultiplier: number,
	nodeCount: number,
	color: { number },
	nodeColor: { number },
	eggId: string?,
}

local Zones: { ZoneDef } = {
	{
		id = "meadow",
		name = "Meadow",
		order = 1,
		gateCost = 0,
		valueMultiplier = 1,
		nodeCount = 10,
		color = { 112, 191, 98 },
		nodeColor = { 120, 200, 255 },
		eggId = "meadow_egg",
	},
	{
		id = "desert",
		name = "Desert",
		order = 2,
		gateCost = 3000,
		valueMultiplier = 4,
		nodeCount = 10,
		color = { 232, 200, 124 },
		nodeColor = { 255, 140, 60 },
		eggId = "desert_egg",
	},
	{
		id = "glacier",
		name = "Glacier",
		order = 3,
		gateCost = 240000,
		valueMultiplier = 16,
		nodeCount = 10,
		color = { 200, 230, 255 },
		nodeColor = { 90, 160, 255 },
		eggId = "glacier_egg",
	},
	{
		id = "volcano",
		name = "Volcano",
		order = 4,
		gateCost = 4800000,
		valueMultiplier = 64,
		nodeCount = 10,
		color = { 90, 60, 60 },
		nodeColor = { 255, 80, 40 },
		eggId = "volcano_egg",
	},
	{
		id = "nebula",
		name = "Nebula",
		order = 5,
		gateCost = 96000000,
		valueMultiplier = 256,
		nodeCount = 10,
		color = { 60, 40, 110 },
		nodeColor = { 220, 120, 255 },
		eggId = "nebula_egg",
	},
}

return table.freeze(Zones)
