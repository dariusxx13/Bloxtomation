--!strict
-- World: builds a PLACEHOLDER world from config (zones, resource nodes, gates, egg stands) when the place has
-- no authored "World" folder, and keeps a registry the other systems use for server-side lookups.
-- Worldbuilders replace it by authoring Workspace.World with the same tags and attributes:
--   ResourceNode (attributes NodeId, ZoneId), ZoneGate (ZoneId), EggStand (EggId), ZoneBounds (ZoneId),
--   and a SpawnLocation named PlayerSpawn.
-- Everything generated is tagged with the attribute Placeholder = true.

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Shared
local Eggs = require(Shared.Config.Eggs)
local Format = require(Shared.Util.Format)
local Odds = require(Shared.Util.Odds)
local Pets = require(Shared.Config.Pets)
local Zones = require(Shared.Config.Zones)

local World = {}

World.TAGS = table.freeze({
	node = "ResourceNode",
	gate = "ZoneGate",
	egg = "EggStand",
	bounds = "ZoneBounds",
})

local ZONE_SPACING = 150
local PLATFORM_SIZE = 120

local nodes: { [string]: BasePart } = {}
local gates: { [string]: BasePart } = {}
local eggs: { [string]: BasePart } = {}
local bounds: { { part: BasePart, zoneId: string } } = {}
local spawnPart: BasePart? = nil

local function rgb(values: { number }): Color3
	return Color3.fromRGB(values[1], values[2], values[3])
end

local function part(props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props do
		(p :: any)[key] = value
	end
	return p
end

local function label(parent: BasePart, text: string, face: Enum.NormalId, textSize: number)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 20
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.Text = text
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Parent = textLabel
	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MaxTextSize = textSize
	constraint.Parent = textLabel
	textLabel.Parent = gui
	gui.Parent = parent
end

-- Odds board above each egg stand, generated from the same tables the server rolls from.
local function oddsBoard(stand: BasePart, eggId: string)
	local egg = Eggs.byId[eggId]
	if not egg then
		return
	end
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Odds"
	billboard.Size = UDim2.fromOffset(220, 40 + 22 * #egg.entries)
	billboard.StudsOffset = Vector3.new(0, 9, 0)
	billboard.MaxDistance = 60
	billboard.AlwaysOnTop = false
	local list = Instance.new("Frame")
	list.Size = UDim2.fromScale(1, 1)
	list.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	list.BackgroundTransparency = 0.25
	local corner = Instance.new("UICorner")
	corner.Parent = list
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 2)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = list
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 30)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.FredokaOne
	title.TextScaled = true
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Text = `{egg.name}: {Format.short(egg.price)} Coins`
	title.Parent = list
	for _, outcome in Odds.effective(egg, 1) do
		local pet = Pets.byKind[outcome.kind]
		local rarity = Pets.rarityById[outcome.rarity]
		local row = Instance.new("TextLabel")
		row.Size = UDim2.new(1, -10, 0, 20)
		row.BackgroundTransparency = 1
		row.Font = Enum.Font.GothamBold
		row.TextScaled = true
		row.TextColor3 = if rarity then rgb(rarity.color) else Color3.new(1, 1, 1)
		row.Text =
			`{pet and pet.name or outcome.kind} ({outcome.rarity}): {Format.percent(outcome.probability)}`
		row.Parent = list
	end
	list.Parent = billboard
	billboard.Parent = stand
end

local function buildPlaceholder(): Folder
	local root = Instance.new("Folder")
	root.Name = "World"
	root:SetAttribute("Placeholder", true)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "PlayerSpawn"
	spawn.Anchored = true
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.Position = Vector3.new(0, 2.5, -40)
	spawn.Transparency = 0.5
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = root

	for index, zone in Zones do
		local zoneFolder = Instance.new("Folder")
		zoneFolder.Name = zone.id
		local centerZ = (index - 1) * ZONE_SPACING
		local ground = part({
			Name = "Ground",
			Size = Vector3.new(PLATFORM_SIZE, 4, PLATFORM_SIZE + 30),
			Position = Vector3.new(0, 0, centerZ),
			Color = rgb(zone.color),
			Material = Enum.Material.SmoothPlastic,
			Parent = zoneFolder,
		})
		ground:SetAttribute("ZoneId", zone.id)
		CollectionService:AddTag(ground, World.TAGS.bounds)
		-- Resource nodes in a ring, facing the player path
		for i = 1, zone.nodeCount do
			local angle = (i / zone.nodeCount) * math.pi * 2
			local node = part({
				Name = `Node{i}`,
				Size = Vector3.new(5, 7, 5),
				Position = Vector3.new(math.cos(angle) * 32, 5.5, centerZ + math.sin(angle) * 32),
				Color = rgb(zone.nodeColor),
				Material = Enum.Material.Glass,
				Parent = zoneFolder,
			})
			local nodeId = `{zone.id}_{i}`
			node:SetAttribute("NodeId", nodeId)
			node:SetAttribute("ZoneId", zone.id)
			CollectionService:AddTag(node, World.TAGS.node)
		end
		-- Egg stand
		if zone.eggId then
			local stand = part({
				Name = "EggStand",
				Shape = Enum.PartType.Ball,
				Size = Vector3.new(7, 9, 7),
				Position = Vector3.new(40, 6.5, centerZ - 40),
				Color = Color3.fromRGB(255, 245, 220),
				Material = Enum.Material.SmoothPlastic,
				Parent = zoneFolder,
			})
			stand:SetAttribute("EggId", zone.eggId)
			stand:SetAttribute("ZoneId", zone.id)
			CollectionService:AddTag(stand, World.TAGS.egg)
			local prompt = Instance.new("ProximityPrompt")
			prompt.Name = "HatchPrompt"
			prompt.ActionText = "Hatch"
			prompt.ObjectText = Eggs.byId[zone.eggId] and Eggs.byId[zone.eggId].name or "Egg"
			prompt.HoldDuration = 0
			prompt.MaxActivationDistance = Eggs.hatchRange - 2
			prompt.RequiresLineOfSight = false
			prompt.Parent = stand
			oddsBoard(stand, zone.eggId)
		end
		-- Gate at the entrance of every zone after the first
		if zone.gateCost > 0 then
			local gate = part({
				Name = "Gate",
				Size = Vector3.new(PLATFORM_SIZE, 30, 2),
				Position = Vector3.new(0, 17, centerZ - (PLATFORM_SIZE + 30) / 2 - 1),
				Color = rgb(zone.nodeColor),
				Material = Enum.Material.ForceField,
				Transparency = 0.3,
				Parent = zoneFolder,
			})
			gate:SetAttribute("ZoneId", zone.id)
			CollectionService:AddTag(gate, World.TAGS.gate)
			label(gate, `{zone.name}\n{Format.short(zone.gateCost)} Coins`, Enum.NormalId.Front, 80)
			label(gate, `{zone.name}`, Enum.NormalId.Back, 80)
			local prompt = Instance.new("ProximityPrompt")
			prompt.Name = "UnlockPrompt"
			prompt.ActionText = `Unlock ({Format.short(zone.gateCost)})`
			prompt.ObjectText = zone.name
			prompt.HoldDuration = 0
			prompt.MaxActivationDistance = 14
			prompt.RequiresLineOfSight = false
			local attachment = Instance.new("Attachment")
			attachment.Position = Vector3.new(0, -12, 0)
			attachment.Parent = gate
			prompt.Parent = attachment
		end
		zoneFolder.Parent = root
	end
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
					instance:SetAttribute("Hp", 0)
					instance:SetAttribute("Broken", false)
				end
			elseif CollectionService:HasTag(instance, World.TAGS.gate) then
				local zoneId = instance:GetAttribute("ZoneId")
				if type(zoneId) == "string" then
					gates[zoneId] = instance
				end
			elseif CollectionService:HasTag(instance, World.TAGS.egg) then
				local eggId = instance:GetAttribute("EggId")
				if type(eggId) == "string" then
					eggs[eggId] = instance
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

function World.gate(zoneId: string): BasePart?
	return gates[zoneId]
end

function World.eggStand(eggId: string): BasePart?
	return eggs[eggId]
end

function World.allNodes(): { [string]: BasePart }
	return nodes
end

-- The zone whose bounds part contains `position` in the horizontal plane (nil outside every zone).
-- Bounds extend upward so jumping does not leave the zone.
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

-- Distance from the player's character root to a world position (math.huge if no character).
function World.distanceTo(player: Player, position: Vector3): number
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		return math.huge
	end
	return (root.Position - position).Magnitude
end

function World.init()
	local existing = Workspace:FindFirstChild("World")
	local root = existing or buildPlaceholder()
	register(root)
end

function World.start() end

return World
