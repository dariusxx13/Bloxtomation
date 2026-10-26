--!strict
-- World: builds the prototype's placeholder world from Config/WorldLayout (Pebble Cove's harbour edge) when the
-- place has no authored "World" folder, and keeps the registry other systems use for server-side lookups.
-- Contract (world plan v2 §9): ResourceNode spots (NodeId, ZoneId, SpotKind, CellId, CastPoint, Sheltered,
-- Callable, StormEye), WeatherCell parts (CellId, ZoneId, Radius, flags), StormHome, ZoneBounds (ZoneId) and a
-- SpawnLocation named PlayerSpawn. Everything generated carries the attribute Placeholder = true.
-- Public: node(id), allNodes(), spot(id), castPoint(id), ripplePosition(id), zoneAt(pos), spawnCFrame(),
-- distanceTo(player, pos), rootPosition(player).

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Shared
local WorldLayout = require(Shared.Config.WorldLayout)

local World = {}

World.TAGS = table.freeze({
	node = "ResourceNode",
	bounds = "ZoneBounds",
	cell = "WeatherCell",
	stormHome = "StormHome",
})

local nodes: { [string]: BasePart } = {}
local spots: { [string]: WorldLayout.SpotSpec } = {}
local bounds: { { part: BasePart, zoneId: string } } = {}
local spawnPart: BasePart? = nil

for _, spec in WorldLayout.spots do
	spots[spec.id] = spec
end

local function vec(values: { number }): Vector3
	return Vector3.new(values[1], values[2], values[3])
end

local function rgb(values: { number }): Color3
	return Color3.fromRGB(values[1], values[2], values[3])
end

local function label(parent: BasePart, text: string, face: Enum.NormalId)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 20
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.TextColor3 = rgb(WorldLayout.colors.shellCream)
	textLabel.Text = text
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = rgb(WorldLayout.colors.nightInk)
	stroke.Parent = textLabel
	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MaxTextSize = 120 -- 6-stud letters: readable at 101 studs on a phone (world plan §5)
	constraint.Parent = textLabel
	textLabel.Parent = gui
	gui.Parent = parent
end

local function nameBoard(parent: BasePart, text: string)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "SpotName"
	billboard.Size = UDim2.fromOffset(200, 36)
	billboard.StudsOffset = Vector3.new(0, 9, 0)
	billboard.MaxDistance = 140
	billboard.LightInfluence = 0
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.TextColor3 = rgb(WorldLayout.colors.shellCream)
	textLabel.Text = text
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = rgb(WorldLayout.colors.nightInk)
	stroke.Parent = textLabel
	textLabel.Parent = billboard
	billboard.Parent = parent
end

local function newPart(spec: WorldLayout.PartSpec): BasePart
	local part: BasePart
	if spec.shape == "Truss" then
		part = Instance.new("TrussPart")
	else
		local p = Instance.new("Part")
		if spec.shape == "Ball" then
			p.Shape = Enum.PartType.Ball
		elseif spec.shape == "Column" then
			p.Shape = Enum.PartType.Cylinder
		end
		part = p
	end
	part.Name = spec.name
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Material = if spec.material == "Neon" then Enum.Material.Neon else Enum.Material.SmoothPlastic
	part.Color = rgb(spec.color)
	part.Transparency = spec.transparency or 0
	local collide = spec.collide ~= false
	part.CanCollide = collide
	part.CanTouch = false
	part.CanQuery = collide and (spec.transparency or 0) < 1
	part.CastShadow = (spec.transparency or 0) < 1
	local position = vec(spec.pos)
	if spec.shape == "Column" then
		-- Roblox cylinders run along X: stand them up.
		part.Size = Vector3.new(spec.size[2], spec.size[1], spec.size[3])
		part.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	else
		part.Size = vec(spec.size)
		part.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(spec.yaw or 0), 0)
	end
	if spec.tag then
		CollectionService:AddTag(part, spec.tag)
	end
	if spec.light then
		local light = Instance.new("PointLight")
		light.Enabled = false -- storm only; the client switches it on
		light.Shadows = false
		light.Range = 16
		light.Brightness = 2
		light.Color = rgb(WorldLayout.colors.lanternGold)
		light.Parent = part
	end
	if spec.text then
		label(part, spec.text, Enum.NormalId.Front)
		label(part, spec.text, Enum.NormalId.Back)
	end
	part:SetAttribute("Placeholder", true)
	return part
end

-- A flat vertical-axis disc (cylinder) of the given diameter and thickness.
local function disc(name: string, diameter: number, thickness: number, center: Vector3): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Shape = Enum.PartType.Cylinder
	p.Anchored = true
	p.Size = Vector3.new(thickness, diameter, diameter)
	p.CFrame = CFrame.new(center) * CFrame.Angles(0, 0, math.rad(90))
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p:SetAttribute("Placeholder", true)
	return p
end

local function cellCentre(spec: WorldLayout.SpotSpec): Vector3
	return (vec(spec.stand) + vec(spec.ripple)) / 2
end

local function buildSpot(spec: WorldLayout.SpotSpec, parent: Instance, cells: Instance)
	local model = Instance.new("Model")
	model.Name = spec.id
	model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	local ripplePos = vec(spec.ripple) + Vector3.new(0, 0.15, 0)

	local ripple = disc("Ripple", WorldLayout.rippleDiameter, 0.4, ripplePos)
	ripple.Material = Enum.Material.Neon
	ripple.Color = rgb(WorldLayout.rippleColor)
	ripple.Transparency = 0.25
	ripple.CanCollide = false
	ripple.CanTouch = false
	ripple.CanQuery = true -- the tap raycast needs it
	ripple.CastShadow = false
	ripple:SetAttribute("NodeId", spec.id)
	ripple:SetAttribute("ZoneId", WorldLayout.zoneId)
	ripple:SetAttribute("SpotKind", "regular")
	ripple:SetAttribute("CellId", spec.id)
	ripple:SetAttribute("CastPoint", vec(spec.stand))
	ripple:SetAttribute("SpotName", spec.name)
	if spec.sheltered then
		ripple:SetAttribute("Sheltered", true)
	end
	if spec.callable then
		ripple:SetAttribute("Callable", true)
	end
	if spec.stormEye then
		ripple:SetAttribute("StormEye", true)
	end
	CollectionService:AddTag(ripple, World.TAGS.node)
	nameBoard(ripple, spec.name)
	ripple.Parent = model

	local rim = disc("Rim", WorldLayout.rippleDiameter * 1.15, 0.3, ripplePos - Vector3.new(0, 0.1, 0))
	rim.Material = Enum.Material.SmoothPlastic
	rim.Color = rgb(WorldLayout.rimColor)
	rim.CanCollide = false
	rim.CanTouch = false
	rim.CanQuery = false
	rim.CastShadow = false
	rim.Parent = model

	local stand = Instance.new("Part")
	stand.Name = "Stand"
	stand.Anchored = true
	stand.Size = Vector3.new(4, 0.2, 4)
	stand.Position = vec(spec.stand) + Vector3.new(0, 0.1, 0)
	stand.Material = Enum.Material.SmoothPlastic
	stand.Color = rgb(WorldLayout.colors.lanternGold)
	stand.CanCollide = false
	stand.CanTouch = false
	stand.CanQuery = false
	stand:SetAttribute("Placeholder", true)
	stand.Parent = model
	model.Parent = parent

	local cell = disc(`Cell_{spec.id}`, WorldLayout.cellRadius * 2, 1, cellCentre(spec))
	cell.Transparency = 1
	cell.CanCollide = false
	cell.CanTouch = false
	cell.CanQuery = false
	cell.CastShadow = false
	cell:SetAttribute("CellId", spec.id)
	cell:SetAttribute("ZoneId", WorldLayout.zoneId)
	cell:SetAttribute("Radius", WorldLayout.cellRadius)
	if spec.sheltered then
		cell:SetAttribute("Sheltered", true)
	end
	if spec.callable then
		cell:SetAttribute("Callable", true)
	end
	if spec.stormEye then
		cell:SetAttribute("StormEye", true)
	end
	CollectionService:AddTag(cell, World.TAGS.cell)
	cell.Parent = cells
end

local function buildPlaceholder(): Folder
	local root = Instance.new("Folder")
	root.Name = "World"
	root:SetAttribute("Placeholder", true)

	-- Terrain water over the cove and lagoon on a sand floor (swimming is safe: no damage, ladders out).
	local terrain = Workspace.Terrain
	terrain:FillBlock(CFrame.new(vec(WorldLayout.floor.pos)), vec(WorldLayout.floor.size), Enum.Material.Sand)
	terrain:FillBlock(
		CFrame.new(vec(WorldLayout.water.pos)),
		vec(WorldLayout.water.size),
		Enum.Material.Water
	)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "PlayerSpawn"
	spawn.Anchored = true
	spawn.Size = vec(WorldLayout.spawn.size)
	spawn.CFrame = CFrame.new(vec(WorldLayout.spawn.pos)) -- orientation (0, 0, 0): faces north
	spawn.Color = rgb(WorldLayout.spawn.color)
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.Neutral = true
	spawn.Duration = 0
	spawn:SetAttribute("Placeholder", true)
	spawn.Parent = root

	local scenery = Instance.new("Folder")
	scenery.Name = "Scenery"
	for _, spec in WorldLayout.parts do
		newPart(spec).Parent = scenery
	end
	for _, spec in WorldLayout.walls do
		local wall = newPart(spec)
		wall.CanQuery = false
		wall.CastShadow = false
		wall.Parent = scenery
	end
	scenery.Parent = root

	-- Weather cells and the storm's home are always streamed (world plan §10: Persistent, sparingly).
	local cells = Instance.new("Model")
	cells.Name = "WeatherCells"
	cells.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	local stormHome = Instance.new("Part")
	stormHome.Name = "StormHome"
	stormHome.Anchored = true
	stormHome.Size = Vector3.one
	stormHome.Position = vec(WorldLayout.stormHome)
	stormHome.Transparency = 1
	stormHome.CanCollide = false
	stormHome.CanTouch = false
	stormHome.CanQuery = false
	stormHome:SetAttribute("Placeholder", true)
	CollectionService:AddTag(stormHome, World.TAGS.stormHome)
	stormHome.Parent = cells

	local spotFolder = Instance.new("Folder")
	spotFolder.Name = "Spots"
	for _, spec in WorldLayout.spots do
		buildSpot(spec, spotFolder, cells)
	end
	spotFolder.Parent = root
	cells.Parent = root

	local zone = Instance.new("Part")
	zone.Name = "Bounds_" .. WorldLayout.zoneId
	zone.Anchored = true
	zone.Size = vec(WorldLayout.bounds.size)
	zone.Position = vec(WorldLayout.bounds.pos)
	zone.Transparency = 1
	zone.CanCollide = false
	zone.CanTouch = false
	zone.CanQuery = false
	zone:SetAttribute("ZoneId", WorldLayout.zoneId)
	zone:SetAttribute("Placeholder", true)
	CollectionService:AddTag(zone, World.TAGS.bounds)
	zone.Parent = root

	root.Parent = Workspace
	return root
end

local function register(root: Instance)
	for _, instance in root:GetDescendants() do
		if instance:IsA("BasePart") then
			if CollectionService:HasTag(instance, World.TAGS.node) then
				local id = instance:GetAttribute("NodeId")
				if type(id) == "string" then
					nodes[id] = instance
				end
			elseif CollectionService:HasTag(instance, World.TAGS.bounds) then
				local zoneId = instance:GetAttribute("ZoneId")
				if type(zoneId) == "string" then
					table.insert(bounds, { part = instance, zoneId = zoneId })
				end
			end
			if instance:IsA("SpawnLocation") and instance.Name == "PlayerSpawn" then
				spawnPart = instance
			end
		end
	end
end

function World.node(nodeId: string): BasePart?
	return nodes[nodeId]
end

function World.allNodes(): { [string]: BasePart }
	return nodes
end

-- The layout entry for a spot (pure data, never streamed out).
function World.spot(spotId: string): WorldLayout.SpotSpec?
	return spots[spotId]
end

function World.ripplePosition(spotId: string): Vector3?
	local spec = spots[spotId]
	return if spec then vec(spec.ripple) else nil
end

function World.castPoint(spotId: string): Vector3?
	local spec = spots[spotId]
	return if spec then vec(spec.stand) else nil
end

-- The cell whose centre is nearest to `position`, if it is within the cell radius (horizontal plane).
function World.cellAt(position: Vector3): string?
	local best: string? = nil
	local bestDistance = WorldLayout.cellRadius
	for id, spec in spots do
		local centre = cellCentre(spec)
		local distance = Vector2.new(position.X - centre.X, position.Z - centre.Z).Magnitude
		if distance <= bestDistance then
			best = id
			bestDistance = distance
		end
	end
	return best
end

-- The zone whose bounds part contains `position` in the horizontal plane (nil outside every zone).
function World.zoneAt(position: Vector3): string?
	for _, entry in bounds do
		local localPos = entry.part.CFrame:PointToObjectSpace(position)
		local half = entry.part.Size / 2
		if
			math.abs(localPos.X) <= half.X
			and math.abs(localPos.Z) <= half.Z
			and localPos.Y >= -half.Y - 4
		then
			return entry.zoneId
		end
	end
	return nil
end

function World.spawnCFrame(): CFrame
	local spawn = spawnPart
	if spawn then
		return spawn.CFrame + Vector3.new(0, spawn.Size.Y / 2 + 3, 0)
	end
	return CFrame.new(0, 10, 0)
end

function World.rootPosition(player: Player): Vector3?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		return nil
	end
	return root.Position
end

-- Distance from the player's character root to a world position (math.huge if no character).
function World.distanceTo(player: Player, position: Vector3): number
	local root = World.rootPosition(player)
	return if root then (root - position).Magnitude else math.huge
end

function World.init()
	local existing = Workspace:FindFirstChild("World")
	local root = existing or buildPlaceholder()
	register(root)
end

function World.start() end

return World
