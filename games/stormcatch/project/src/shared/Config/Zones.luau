--!strict
-- Islands. The prototype is Pebble Cove's harbour edge only (prototype brief req. 1-2; world plan §9, §12):
-- one zone, free, with its 3 regular spots. Bridges and islands 2-4 come at the build stage.
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
		id = "pebble_cove",
		name = "Pebble Cove",
		order = 1,
		gateCost = 0,
		valueMultiplier = 1, -- economy sheet §3.1: Pebble Cove x1
		nodeCount = 3,
		color = { 107, 170, 117 }, -- Moss
		nodeColor = { 255, 196, 46 }, -- Lantern Gold ripples with a Night Ink rim
		eggId = nil,
	},
}

return table.freeze(Zones)
