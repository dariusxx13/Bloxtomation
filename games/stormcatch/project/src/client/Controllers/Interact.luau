--!strict
-- Interact: the fishing spots on the client. Tapping a ripple walks the avatar to that spot's CastPoint (the
-- stand), never to the ripple in the water (prototype brief req. 3.1; world plan §9 rule 6): a path that
-- treats water as impassable, with a straight MoveTo as the fallback. Spot positions come from
-- Config/WorldLayout (pure data), so nothing waits on streaming; ripples get a soft bob here.
-- Public: nearestSpot(maxDistance?), spotPosition(id), castPoint(id), walkTo(id), rootPart(), spots().

local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Shared
local WorldLayout = require(Shared.Config.WorldLayout)

local UI = script.Parent.Parent.UI
local Panels = require(UI.Panels)

local Interact = {}

local NODE_TAG = "ResourceNode"
local RAY_DISTANCE = 300
local ARRIVE_DISTANCE = 2.5
local BOB_HEIGHT = 0.15
local BOB_SECONDS = 2.4

local player = Players.LocalPlayer
local ripples: { [string]: BasePart } = {}
local baseHeights: { [BasePart]: number } = {}
local walkToken = 0

local spotById: { [string]: WorldLayout.SpotSpec } = {}
for _, spec in WorldLayout.spots do
	spotById[spec.id] = spec
end

local function vec(values: { number }): Vector3
	return Vector3.new(values[1], values[2], values[3])
end

function Interact.rootPart(): BasePart?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root else nil
end

function Interact.spots(): { WorldLayout.SpotSpec }
	return WorldLayout.spots
end

function Interact.spotPosition(spotId: string): Vector3?
	local spec = spotById[spotId]
	return if spec then vec(spec.ripple) else nil
end

function Interact.castPoint(spotId: string): Vector3?
	local spec = spotById[spotId]
	return if spec then vec(spec.stand) else nil
end

function Interact.spotName(spotId: string): string
	local spec = spotById[spotId]
	return if spec then spec.name else spotId
end

-- The closest spot to the avatar (by ripple centre), optionally within `maxDistance` studs.
function Interact.nearestSpot(maxDistance: number?): (string?, number)
	local root = Interact.rootPart()
	if not root then
		return nil, math.huge
	end
	local best: string? = nil
	local bestDistance = maxDistance or math.huge
	for _, spec in WorldLayout.spots do
		local distance = (root.Position - vec(spec.ripple)).Magnitude
		if distance <= bestDistance then
			best = spec.id
			bestDistance = distance
		end
	end
	return best, bestDistance
end

local function humanoid(): Humanoid?
	local character = player.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

-- Walks to the spot's CastPoint along a path that avoids water; falls back to a straight MoveTo.
function Interact.walkTo(spotId: string)
	local target = Interact.castPoint(spotId)
	local root = Interact.rootPart()
	local hum = humanoid()
	if not target or not root or not hum then
		return
	end
	if
		(Vector2.new(root.Position.X, root.Position.Z) - Vector2.new(target.X, target.Z)).Magnitude
		<= ARRIVE_DISTANCE
	then
		return
	end
	walkToken += 1
	local token = walkToken
	local walker: Humanoid = hum
	task.spawn(function()
		local path = PathfindingService:CreatePath({
			AgentRadius = 2,
			AgentHeight = 5,
			AgentCanJump = true,
			Costs = { Water = math.huge },
		})
		local ok = pcall(function()
			path:ComputeAsync(root.Position, target)
		end)
		if not ok or path.Status ~= Enum.PathStatus.Success then
			walker:MoveTo(target)
			return
		end
		for _, waypoint in path:GetWaypoints() do
			if token ~= walkToken or walker.Health <= 0 then
				return
			end
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				walker.Jump = true
			end
			walker:MoveTo(waypoint.Position)
			local reached = walker.MoveToFinished:Wait()
			if not reached then
				walker:MoveTo(target)
				return
			end
		end
	end)
end

-- Cancels a tap-to-walk when the player steers by hand.
function Interact.cancelWalk()
	walkToken += 1
end

local function spotFromInstance(instance: Instance?): string?
	local current = instance
	while current and current ~= Workspace do
		if current:IsA("BasePart") and CollectionService:HasTag(current, NODE_TAG) then
			local id = current:GetAttribute("NodeId")
			return if type(id) == "string" then id else nil
		end
		current = current.Parent
	end
	return nil
end

local function onInput(input: InputObject, gameProcessed: boolean)
	if gameProcessed or Panels.current() ~= nil then
		return
	end
	local isPointer = input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
	if not isPointer then
		return
	end
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local ray = camera:ViewportPointToRay(input.Position.X, input.Position.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = if player.Character then { player.Character } else {}
	params.IgnoreWater = true
	local result = Workspace:Raycast(ray.Origin, ray.Direction * RAY_DISTANCE, params)
	local spotId = result and spotFromInstance(result.Instance)
	if spotId then
		Interact.walkTo(spotId)
	end
end

local function addRipple(instance: Instance)
	if not instance:IsA("BasePart") then
		return
	end
	local id = instance:GetAttribute("NodeId")
	if type(id) == "string" then
		ripples[id] = instance
		baseHeights[instance] = instance.Position.Y
	end
end

local function removeRipple(instance: Instance)
	local id = instance:GetAttribute("NodeId")
	if type(id) == "string" and ripples[id] == instance then
		ripples[id] = nil
	end
	if instance:IsA("BasePart") then
		baseHeights[instance] = nil
	end
end

function Interact.init() end

function Interact.start()
	for _, instance in CollectionService:GetTagged(NODE_TAG) do
		addRipple(instance)
	end
	CollectionService:GetInstanceAddedSignal(NODE_TAG):Connect(addRipple)
	CollectionService:GetInstanceRemovedSignal(NODE_TAG):Connect(removeRipple)
	UserInputService.InputBegan:Connect(onInput)
	-- A hand on the thumbstick or keys cancels the walk.
	UserInputService.InputBegan:Connect(function(input: InputObject)
		if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Thumbstick1 then
			Interact.cancelWalk()
		end
	end)
	-- The soft bob of every ripple (client-only cosmetic).
	RunService.RenderStepped:Connect(function()
		local offset = math.sin(os.clock() * 2 * math.pi / BOB_SECONDS) * BOB_HEIGHT
		for _, ripple in ripples do
			local base = baseHeights[ripple]
			if base and ripple.Parent then
				local position = ripple.Position
				ripple.Position = Vector3.new(position.X, base + offset, position.Z)
			end
		end
	end)
end

return Interact
