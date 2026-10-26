--!strict
-- The prototype world data (brief req. 2; world plan §4, §7, §9, §12): cast distances, the cozy walking
-- rules, the sheltered Dock Ripple, cells, visual clearances and the part, material and light budgets.
-- World.luau builds the place from exactly this data, so a later layout edit cannot quietly break a rule.
local TestKit = require("./TestKit")
local WeatherLook = require("../src/shared/Config/WeatherLook")
local WorldLayout = require("../src/shared/Config/WorldLayout")

local function dist(a: { number }, b: { number }): number
	return math.sqrt((a[1] - b[1]) ^ 2 + (a[2] - b[2]) ^ 2 + (a[3] - b[3]) ^ 2)
end

local function flat(a: { number }, b: { number }): number
	return math.sqrt((a[1] - b[1]) ^ 2 + (a[3] - b[3]) ^ 2)
end

local function cellCentre(spot: WorldLayout.SpotSpec): { number }
	return {
		(spot.stand[1] + spot.ripple[1]) / 2,
		(spot.stand[2] + spot.ripple[2]) / 2,
		(spot.stand[3] + spot.ripple[3]) / 2,
	}
end

local function spot(id: string): WorldLayout.SpotSpec
	for _, s in WorldLayout.spots do
		if s.id == id then
			return s
		end
	end
	error("no spot " .. id)
end

-- Shortest distance from point p to segment a-b in the horizontal plane.
local function toSegment(p: { number }, a: { number }, b: { number }): number
	local dx, dz = b[1] - a[1], b[3] - a[3]
	local lengthSq = dx * dx + dz * dz
	local t = if lengthSq > 0
		then math.clamp(((p[1] - a[1]) * dx + (p[3] - a[3]) * dz) / lengthSq, 0, 1)
		else 0
	return flat(p, { a[1] + t * dx, 0, a[3] + t * dz })
end

return function(test: TestKit.Test)
	test("three spots with the brief's stands, ripples and flags", function()
		TestKit.equal(#WorldLayout.spots, 3)
		local dock = spot("cove_dock")
		TestKit.equal(dock.name, "Dock Ripple")
		TestKit.truthy(dock.sheltered and not dock.callable and not dock.stormEye)
		local shallows = spot("cove_shallows")
		TestKit.truthy(shallows.callable and not shallows.sheltered and not shallows.stormEye)
		local pier = spot("pier_head")
		TestKit.truthy(pier.stormEye and pier.callable and not pier.sheltered)
		TestKit.equal(pier.stand[1], 20)
		TestKit.equal(pier.ripple[3], -104)
	end)

	test("every stand casts within 28 studs (root 3 studs above the deck): 11.1, 18.8, 16.6", function()
		local expected = { cove_dock = 11.1, cove_shallows = 18.8, pier_head = 16.6 }
		for _, s in WorldLayout.spots do
			local root = { s.stand[1], s.stand[2] + WorldLayout.standRootHeight, s.stand[3] }
			local d = dist(root, s.ripple)
			TestKit.near(d, expected[s.id], 0.05, s.id)
			TestKit.truthy(d <= 28, `{s.id} in cast range`)
		end
	end)

	test("the Dock Ripple sits 10 studs ahead of spawn and 5 to the left, in cast range of spawn", function()
		local spawn = WorldLayout.spawn.pos
		local dock = spot("cove_dock")
		TestKit.equal(dock.ripple[1] - spawn[1], -5)
		TestKit.equal(dock.ripple[3] - spawn[3], -10)
		TestKit.equal(WorldLayout.spawn.size[1], 8)
		TestKit.equal(WorldLayout.spawn.size[2], 1)
		TestKit.equal(spawn[2], 4)
		-- Cast works from the spawn point: the root (pad top + 3) is about 13.5 studs from the Dock Ripple.
		local root =
			{ spawn[1], spawn[2] + WorldLayout.spawn.size[2] / 2 + WorldLayout.standRootHeight, spawn[3] }
		local fromSpawn = dist(root, dock.ripple)
		TestKit.near(fromSpawn, 13.5, 0.05, "spawn root to the Dock Ripple")
		TestKit.truthy(fromSpawn <= 28, "the Dock Ripple is in cast range at spawn")
	end)

	test("walks: nearest neighbour within 160 studs (10 s) and every pair within 240 (15 s)", function()
		local nearest: { [string]: number } = {}
		for _, walk in WorldLayout.walks do
			TestKit.truthy(walk.studs <= 240, `{walk.from}-{walk.to} {walk.studs}`)
			local straight = flat(spot(walk.from).stand, spot(walk.to).stand)
			TestKit.truthy(straight <= walk.studs, `{walk.from}-{walk.to} path shorter than a straight line`)
			nearest[walk.from] = math.min(nearest[walk.from] or math.huge, walk.studs)
			nearest[walk.to] = math.min(nearest[walk.to] or math.huge, walk.studs)
		end
		for id, studs in nearest do
			TestKit.truthy(studs <= 160, `{id} nearest {studs}`)
		end
	end)

	test("exactly one sheltered spot (cove_dock), and no callable spot is sheltered", function()
		local sheltered = 0
		for _, s in WorldLayout.spots do
			if s.sheltered then
				sheltered += 1
				TestKit.equal(s.id, "cove_dock")
				TestKit.truthy(not s.callable, "sheltered spots are never callable")
			end
		end
		TestKit.equal(sheltered, 1)
	end)

	test("each stand and ripple lies in its own cell and nearest to its own cell centre", function()
		for _, s in WorldLayout.spots do
			for _, point in { s.stand, s.ripple } do
				local own = flat(point, cellCentre(s))
				TestKit.truthy(own <= WorldLayout.cellRadius, `{s.id} inside its cell`)
				for _, other in WorldLayout.spots do
					if other.id ~= s.id then
						TestKit.truthy(own < flat(point, cellCentre(other)), `{s.id} nearest its own centre`)
					end
				end
			end
		end
		TestKit.near(
			flat(cellCentre(spot("cove_dock")), cellCentre(spot("cove_shallows"))),
			52,
			0.5,
			"closest pair"
		)
	end)

	test(
		"front visuals keep clear of the Dock Ripple (no drift leg within 52 studs; fog edge 14 or more)",
		function()
			local dockCentre = cellCentre(spot("cove_dock"))
			local dockRipple = spot("cove_dock").ripple
			local pier = cellCentre(spot("pier_head"))
			local shallows = cellCentre(spot("cove_shallows"))
			local legs = {
				{ WorldLayout.showersEntry, pier },
				{ pier, shallows },
				{ WorldLayout.fogBank, shallows },
				{ shallows, pier },
			}
			for index, leg in legs do
				TestKit.truthy(toSegment(dockCentre, leg[1], leg[2]) >= 52, `drift leg {index}`)
			end
			for _, s in { spot("cove_shallows"), spot("pier_head") } do
				local edge = flat(cellCentre(s), dockRipple) - WeatherLook.fogRadius
				TestKit.truthy(edge >= 14, `fog over {s.id}: edge {edge} from the Dock Ripple`)
				local rainHalfDiagonal = WeatherLook.rainAreaStuds / 2 * math.sqrt(2)
				TestKit.truthy(flat(cellCentre(s), dockRipple) - rainHalfDiagonal > 5, `rain over {s.id}`)
			end
		end
	)

	test("part, material and light budgets: 400 parts, SmoothPlastic and Neon only, 3 lights", function()
		local parts = #WorldLayout.parts + #WorldLayout.walls
		parts += #WorldLayout.spots * 3 -- ripple, rim and stand per spot
		parts += #WorldLayout.spots -- weather cells
		parts += 3 -- spawn, zone bounds, StormHome anchor
		TestKit.truthy(parts <= WorldLayout.partBudget, `{parts} parts`)
		local lights = 0
		for _, list in { WorldLayout.parts, WorldLayout.walls } do
			for _, spec in list do
				TestKit.truthy(spec.material == "SmoothPlastic" or spec.material == "Neon", spec.name)
				if spec.light then
					lights += 1
					TestKit.equal(spec.tag, "PierLantern", spec.name)
				end
			end
		end
		TestKit.truthy(lights <= WorldLayout.lightBudget, `{lights} lights`)
		TestKit.truthy(WeatherLook.rainRate <= 60, "rain rate 60 or less")
		TestKit.equal(WeatherLook.fogRadius, 30)
		TestKit.equal(WeatherLook.rainLiveDistance, 150)
	end)

	test("the bridge sign reads Lantern Reef with no price", function()
		local found = false
		for _, spec in WorldLayout.parts do
			if spec.text then
				TestKit.equal(spec.text, "Lantern Reef")
				TestKit.truthy(string.find(spec.text :: string, "%d") == nil, "no price")
				found = true
			end
		end
		TestKit.truthy(found, "sign present")
	end)
end
