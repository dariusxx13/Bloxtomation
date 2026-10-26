--!strict
-- The prototype world as data: Pebble Cove's harbour edge (world plan v2 §6.1, §6.5, §9, §12; brief req. 2).
-- Studs: +X east, +Z south (north is -Z), water surface at Y = 0, decks at Y 4, the arms at Y 5.
-- Pure module: World.luau builds placeholder parts from it, the client reads spot positions from it (so
-- nothing depends on streaming), and tests/WorldLayout.spec.luau re-checks the cozy rules on every build.
-- Placeholder parts only: SmoothPlastic and Neon, no meshes, no textures, at most 3 lights (pier lanterns).

export type Vec = { number } -- { x, y, z }

export type PartSpec = {
	name: string,
	-- Block: size x, y, z. Ball: diameter in size[1]. Column: vertical cylinder { diameter, height, diameter }.
	-- Truss: a ladder (TrussPart; sizes in 2-stud steps).
	shape: "Block" | "Ball" | "Column" | "Truss",
	size: Vec,
	pos: Vec,
	yaw: number?, -- degrees about Y
	color: Vec,
	material: "SmoothPlastic" | "Neon",
	transparency: number?,
	collide: boolean?, -- default true
	tag: string?,
	light: boolean?, -- pier lanterns: a disabled PointLight the client turns on during the storm
	text: string?, -- a sign: SurfaceGui text on the front and back faces
}

export type SpotSpec = {
	id: string,
	name: string,
	stand: Vec, -- CastPoint: where the player stands to cast (deck surface)
	ripple: Vec, -- ripple centre on the water
	sheltered: boolean,
	callable: boolean,
	stormEye: boolean,
}

-- Palette (art direction §2)
local NIGHT_INK = { 24, 32, 58 }
local STORM_SLATE = { 46, 63, 92 }
local SQUALL_TEAL = { 63, 127, 140 }
local SEAFOAM = { 168, 220, 209 }
local MOSS = { 107, 170, 117 }
local SHELL_CREAM = { 255, 248, 236 }
local EMBER_CORAL = { 255, 122, 89 }
local LANTERN_GOLD = { 255, 196, 46 }

local Spots: { SpotSpec } = {
	{
		id = "cove_dock",
		name = "Dock Ripple",
		stand = { 0, 4, -3 },
		ripple = { -5, 0, -10 },
		sheltered = true,
		callable = false,
		stormEye = false,
	},
	{
		id = "cove_shallows",
		name = "Cove Shallows",
		stand = { -37, 5, -52 },
		ripple = { -20, 0, -52 },
		sheltered = false,
		callable = true,
		stormEye = false,
	},
	{
		id = "pier_head",
		name = "Open Pier",
		stand = { 20, 4, -89 },
		ripple = { 20, 0, -104 },
		sheltered = false,
		callable = true,
		stormEye = true,
	},
}

local function block(name: string, size: Vec, pos: Vec, color: Vec, extra: { [string]: any }?): PartSpec
	local spec: any =
		{ name = name, shape = "Block", size = size, pos = pos, color = color, material = "SmoothPlastic" }
	if extra then
		for key, value in extra do
			spec[key] = value
		end
	end
	return spec
end

local function column(
	name: string,
	diameter: number,
	height: number,
	base: Vec,
	color: Vec,
	extra: { [string]: any }?
): PartSpec
	local spec: any = {
		name = name,
		shape = "Column",
		size = { diameter, height, diameter },
		pos = { base[1], base[2] + height / 2, base[3] },
		color = color,
		material = "SmoothPlastic",
	}
	if extra then
		for key, value in extra do
			spec[key] = value
		end
	end
	return spec
end

local function ball(name: string, diameter: number, pos: Vec, color: Vec, extra: { [string]: any }?): PartSpec
	local spec: any = {
		name = name,
		shape = "Ball",
		size = { diameter, diameter, diameter },
		pos = pos,
		color = color,
		material = "SmoothPlastic",
	}
	if extra then
		for key, value in extra do
			spec[key] = value
		end
	end
	return spec
end

local function ladder(name: string, x: number, z: number, top: number): PartSpec
	local height = 2 * math.ceil((top + 6) / 2)
	return {
		name = name,
		shape = "Truss",
		size = { 2, height, 2 },
		pos = { x, top - height / 2, z },
		color = SHELL_CREAM,
		material = "SmoothPlastic",
	}
end

local NO_COLLIDE = { collide = false }

-- Scenery and walkways. Decks: top surface at Y 4 (quay, pier) or Y 5 (Pebble Point, Gull Point).
local Parts: { PartSpec } = {
	-- Harbour quay and village (behind spawn, out of the first frame)
	block("Quay", { 91, 6, 28.5 }, { 14.5, 1, 9.75 }, SHELL_CREAM),
	block("VillageGround", { 180, 6, 46 }, { 20, 1, 47 }, MOSS),
	block("CottageWest", { 12, 8, 10 }, { -30, 8, 40 }, SHELL_CREAM),
	block("CottageWestRoof", { 14, 3, 12 }, { -30, 13.5, 40 }, EMBER_CORAL),
	block("CottageMid", { 12, 8, 10 }, { 4, 8, 44 }, SHELL_CREAM),
	block("CottageMidRoof", { 14, 3, 12 }, { 4, 13.5, 44 }, EMBER_CORAL),
	block("CottageEast", { 12, 8, 10 }, { 40, 8, 40 }, SHELL_CREAM),
	block("CottageEastRoof", { 14, 3, 12 }, { 40, 13.5, 40 }, EMBER_CORAL),

	-- The harbour canopy over the dock: posts behind spawn (Z +6), underside at Y 22, out to Z -12
	block("CanopyRoof", { 30, 1, 18 }, { 0, 22.5, -3 }, EMBER_CORAL),
	block("CanopyTrim", { 30, 1.2, 0.6 }, { 0, 22.4, -12.2 }, SHELL_CREAM, NO_COLLIDE),
	block("CanopyPostWest", { 1.2, 18, 1.2 }, { -13, 13, 6 }, SHELL_CREAM),
	block("CanopyPostEast", { 1.2, 18, 1.2 }, { 13, 13, 6 }, SHELL_CREAM),

	-- Pebble Point (west arm) with the bridge-1 tip, and Gull Point (east arm)
	block("PebblePoint", { 39, 8, 94 }, { -50.5, 1, -23 }, MOSS),
	block("PebblePointTip", { 24, 8, 20 }, { -50, 1, -80 }, MOSS),
	block("GullPoint", { 50, 8, 109 }, { 85, 1, -30.5 }, MOSS),

	-- The Open Pier: a 10-stud deck from the quay at X 20 to the 36 x 20 head (X 2..38, Z -70..-90)
	block("PierDeck", { 10, 2, 65.5 }, { 20, 3, -37.25 }, SHELL_CREAM),
	block("PierHead", { 36, 2, 20 }, { 20, 3, -80 }, SHELL_CREAM),
	block("PierRailWest", { 0.6, 2.5, 65.5 }, { 15.3, 5.25, -37.25 }, EMBER_CORAL),
	block("PierRailEast", { 0.6, 2.5, 65.5 }, { 24.7, 5.25, -37.25 }, EMBER_CORAL),
	block("HeadRailWest", { 0.6, 2.5, 20 }, { 2.3, 5.25, -80 }, EMBER_CORAL),
	block("HeadRailEast", { 0.6, 2.5, 20 }, { 37.7, 5.25, -80 }, EMBER_CORAL),
	block("HeadRailFront", { 36, 2.5, 0.6 }, { 20, 5.25, -89.7 }, EMBER_CORAL),
	column("PilingA", 1.6, 10, { 20, -6, -20 }, STORM_SLATE),
	column("PilingB", 1.6, 10, { 20, -6, -45 }, STORM_SLATE),
	column("PilingC", 1.6, 10, { 5, -6, -88 }, STORM_SLATE),
	column("PilingD", 1.6, 10, { 35, -6, -88 }, STORM_SLATE),

	-- Lookout on the head's west side: a 22-stud mast and the Rumblefin weathervane
	block("Lookout", { 8, 1, 8 }, { 7, 4.5, -76 }, SHELL_CREAM),
	column("LookoutMast", 1, 22, { 7, 5, -76 }, SHELL_CREAM),
	ball("VaneBody", 3, { 7, 28, -76 }, SQUALL_TEAL, NO_COLLIDE),
	ball("VaneBelly", 2, { 7, 27.3, -75.2 }, EMBER_CORAL, NO_COLLIDE),
	ball("VaneFin", 1.4, { 7, 29.6, -76 }, SHELL_CREAM, NO_COLLIDE),

	-- Pier lanterns (the prototype's only lights, storm only) and string lights
	column("LanternPostWest", 0.8, 6, { 3.5, 4, -71 }, NIGHT_INK),
	ball(
		"LanternWest",
		1.6,
		{ 3.5, 10.6, -71 },
		LANTERN_GOLD,
		{ material = "Neon", collide = false, tag = "PierLantern", light = true }
	),
	column("LanternPostEast", 0.8, 6, { 36.5, 4, -71 }, NIGHT_INK),
	ball(
		"LanternEast",
		1.6,
		{ 36.5, 10.6, -71 },
		LANTERN_GOLD,
		{ material = "Neon", collide = false, tag = "PierLantern", light = true }
	),
	column("LanternPostFront", 0.8, 6, { 33, 4, -88.5 }, NIGHT_INK),
	ball(
		"LanternFront",
		1.6,
		{ 33, 10.6, -88.5 },
		LANTERN_GOLD,
		{ material = "Neon", collide = false, tag = "PierLantern", light = true }
	),
	block(
		"StringLightsWest",
		{ 0.3, 0.3, 19 },
		{ 2.3, 7.2, -80 },
		LANTERN_GOLD,
		{ material = "Neon", collide = false }
	),
	block(
		"StringLightsEast",
		{ 0.3, 0.3, 19 },
		{ 37.7, 7.2, -80 },
		LANTERN_GOLD,
		{ material = "Neon", collide = false }
	),

	-- Bridge 1 stub (scenery, no ZoneGate): broken, with a "Lantern Reef" sign and no price
	block("BridgeStubNear", { 8, 1, 24 }, { -58.9, 4.5, -96.1 }, SHELL_CREAM, { yaw = 47.9 }),
	block("BridgeStubFar", { 8, 1, 20 }, { -94.6, 4.5, -128.3 }, SHELL_CREAM, { yaw = 47.9 }),
	column("BridgePilingNear", 1.4, 10, { -64.8, -6, -101.5 }, STORM_SLATE),
	column("BridgePilingFar", 1.4, 10, { -89.4, -6, -123.6 }, STORM_SLATE),
	column("BridgeSignPost", 0.8, 8, { -50, 5, -76 }, NIGHT_INK),
	block("BridgeSign", { 12, 4, 0.4 }, { -50, 12, -76 }, STORM_SLATE, { text = "Lantern Reef" }),

	-- The near edge of Lantern Reef and a block-out Great Lantern (110 studs)
	block("ReefRimSouth", { 40, 8, 24 }, { -110, 1, -142 }, MOSS),
	block("ReefRimWest", { 40, 8, 20 }, { -145, 1, -160 }, MOSS),
	block("GreatLanternBase", { 24, 8, 24 }, { -153, 1, -222 }, MOSS),
	column("GreatLanternTower", 8, 105, { -153, 5, -222 }, SHELL_CREAM),
	ball("GreatLanternLamp", 10, { -153, 113, -222 }, LANTERN_GOLD, { material = "Neon", collide = false }),

	-- Thunder Spire under its anvil cloud, north-east across the lagoon (the Great Storm's home)
	block("ThunderBase", { 40, 8, 40 }, { 115, 1, -217 }, STORM_SLATE),
	column("ThunderSpire", 10, 105, { 115, 5, -217 }, STORM_SLATE),
	block("AnvilCloud", { 90, 24, 60 }, { 115, 128, -217 }, NIGHT_INK, NO_COLLIDE),
	ball("AnvilCloudBelly", 46, { 115, 92, -217 }, STORM_SLATE, NO_COLLIDE),
	ball("AnvilCloudFoot", 30, { 115, 66, -217 }, STORM_SLATE, NO_COLLIDE),

	-- Ways out of the water (TrussPart ladders) along the quay, pier and arms
	ladder("LadderQuayWest", -20, -5.5, 4),
	ladder("LadderQuayEast", 42, -5.5, 4),
	ladder("LadderPierWest", 14, -30, 4),
	ladder("LadderPierEast", 26, -55, 4),
	ladder("LadderHeadWest", 1, -84, 4),
	ladder("LadderHeadEast", 39, -76, 4),
	ladder("LadderPebbleNorth", -30, -70, 5),
	ladder("LadderPebbleSouth", -30, -30, 5),
	ladder("LadderGull", 59, -40, 5),
	ladder("LadderTip", -40, -91, 5),
}

-- Invisible boundary walls (collide on, query off) about 40 studs past the outermost ripple: no one swims off.
local Walls: { PartSpec } = {
	block("WallNorth", { 262, 46, 2 }, { 10, 7, -150 }, NIGHT_INK, { transparency = 1 }),
	block("WallSouth", { 262, 46, 2 }, { 10, 7, 72 }, NIGHT_INK, { transparency = 1 }),
	block("WallWest", { 2, 46, 222 }, { -121, 7, -39 }, NIGHT_INK, { transparency = 1 }),
	block("WallEast", { 2, 46, 222 }, { 141, 7, -39 }, NIGHT_INK, { transparency = 1 }),
}

return table.freeze({
	zoneId = "pebble_cove",
	spots = Spots,
	parts = Parts,
	walls = Walls,

	spawn = { pos = { 0, 4, 0 } :: Vec, size = { 8, 1, 8 } :: Vec, color = SHELL_CREAM },
	-- Path lengths along the walkways between stands (world plan §4 and §12, measured by its model).
	walks = {
		{ from = "cove_dock", to = "cove_shallows", studs = 89 },
		{ from = "cove_dock", to = "pier_head", studs = 110 },
		{ from = "cove_shallows", to = "pier_head", studs = 193 },
	},
	cellRadius = 36, -- around the midpoint of each stand and ripple
	rippleDiameter = 10,
	rippleColor = LANTERN_GOLD,
	rimColor = NIGHT_INK,
	standRootHeight = 3, -- the root part stands 3 studs above the deck

	stormHome = { 115, 50, -217 } :: Vec, -- anvil cloud anchor (StormHome tag)
	eyeHeight = 60, -- the storm eye sits this far above the eye cell centre
	fogBank = { -80, 0, -110 } :: Vec, -- Sea Fog enters from off the Lantern Reef edge
	showersEntry = { 20, 0, -170 } :: Vec, -- Showers drifts in from the open sea north of the pier
	-- ZoneBounds for pebble_cove: Y -16 to 0, covering the harbour and its water
	bounds = { pos = { 10, -8, -39 } :: Vec, size = { 262, 16, 222 } :: Vec },
	-- Terrain water over the cove and lagoon (Y -12 to 0) on a sand floor
	water = { pos = { -30, -6, -80 } :: Vec, size = { 460, 12, 420 } :: Vec },
	floor = { pos = { -30, -14, -80 } :: Vec, size = { 460, 4, 420 } :: Vec },

	colors = table.freeze({
		nightInk = NIGHT_INK,
		stormSlate = STORM_SLATE,
		squallTeal = SQUALL_TEAL,
		seafoam = SEAFOAM,
		moss = MOSS,
		shellCream = SHELL_CREAM,
		emberCoral = EMBER_CORAL,
		lanternGold = LANTERN_GOLD,
	}),
	partBudget = 400,
	lightBudget = 3,
})
