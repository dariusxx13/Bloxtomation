--!strict
-- Interact: the core action on the client. Tap/click a node to hit it (or walk to it if far),
-- predicted feedback instantly (pop, floating number, sound), and the Auto Hit pass loop.
-- The server decides the real reward; this file only requests and decorates.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Shared
local Economy = require(Shared.Config.Economy)
local Format = require(Shared.Util.Format)
local Net = require(Shared.Net)
local Stats = require(Shared.Util.Stats)

local UI = script.Parent.Parent.UI
local Builder = require(UI.Builder)
local Panels = require(UI.Panels)
local Root = require(UI.Root)
local Sounds = require(UI.Sounds)
local Theme = require(UI.Theme)

local State = require(script.Parent.State)
local Toasts = require(script.Parent.Toasts)

local Interact = {}

local NODE_TAG = "ResourceNode"
local RAY_DISTANCE = 250
local FAR_TOAST_COOLDOWN = 3

local player = Players.LocalPlayer
local nodes: { [string]: BasePart } = {}
local lastHit = 0
local lastFarToast = 0
local autoEnabled = true
local autoButton: TextButton

local function rootPart(): BasePart?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root else nil
end

local function canUseNode(node: BasePart): boolean
	local data = State.data
	local zoneId = node:GetAttribute("ZoneId")
	return data ~= nil
		and type(zoneId) == "string"
		and data.zonesUnlocked[zoneId] == true
		and node:GetAttribute("Broken") ~= true
end

local function floatingText(position: Vector3, text: string, color: Color3)
	if Panels.reduceMotion then
		return
	end
	local anchor: Part = Builder.make("Part", {
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Transparency = 1,
		Size = Vector3.one,
		Position = position + Vector3.new(0, 4, 0),
		Parent = Workspace,
	})
	local billboard: BillboardGui = Builder.make("BillboardGui", {
		Size = UDim2.fromOffset(160, 50),
		AlwaysOnTop = true,
		MaxDistance = 120,
		Parent = anchor,
	})
	local label = Builder.label(
		{ Text = text, TextColor3 = color, Size = UDim2.fromScale(1, 1), Parent = billboard },
		34
	)
	TweenService:Create(anchor, Theme.motion.float, { Position = anchor.Position + Vector3.new(0, 4, 0) })
		:Play()
	TweenService:Create(label, Theme.motion.float, { TextTransparency = 1 }):Play()
	task.delay(0.85, function()
		anchor:Destroy()
	end)
end

local function pop(node: BasePart)
	if Panels.reduceMotion then
		return
	end
	local original = node:GetAttribute("BaseSize")
	if typeof(original) ~= "Vector3" then
		node:SetAttribute("BaseSize", node.Size)
		original = node.Size
	end
	local base = original :: Vector3
	node.Size = base * 0.86
	TweenService:Create(node, Theme.motion.pop, { Size = base }):Play()
end

-- Requests a hit; returns true if the request was sent.
function Interact.tryHit(node: BasePart, fromTap: boolean): boolean
	local nodeId = node:GetAttribute("NodeId")
	local root = rootPart()
	local derived = State.derived
	if type(nodeId) ~= "string" or not root or not derived or not canUseNode(node) then
		return false
	end
	local now = os.clock()
	if now - lastHit < Economy.hitCooldownSeconds then
		return false
	end
	if (root.Position - node.Position).Magnitude > Economy.hitRange then
		if fromTap then
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:MoveTo(node.Position)
			end
			if now - lastFarToast > FAR_TOAST_COOLDOWN then
				lastFarToast = now
				Toasts.show("Walking closer...", "info")
			end
		end
		return false
	end
	lastHit = now
	Net.fire("Hit", nodeId)
	local zoneId = node:GetAttribute("ZoneId") :: string
	local predicted = derived.coinsPerHit * Stats.zoneMultiplier(zoneId)
	pop(node)
	floatingText(node.Position, `+{Format.short(predicted)}`, Theme.colors.coins)
	Sounds.play("hit")
	return true
end

local function nodeFromInstance(instance: Instance?): BasePart?
	local current = instance
	while current and current ~= Workspace do
		if current:IsA("BasePart") and CollectionService:HasTag(current, NODE_TAG) then
			return current
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
	local result = Workspace:Raycast(ray.Origin, ray.Direction * RAY_DISTANCE, params)
	local node = result and nodeFromInstance(result.Instance)
	if node then
		Interact.tryHit(node, true)
	end
end

-- Closest node the player may hit (unlocked zone, not broken), optionally within `maxDistance`.
function Interact.nearestUsableNode(maxDistance: number?): BasePart?
	local root = rootPart()
	if not root then
		return nil
	end
	local best: BasePart? = nil
	local bestDistance = maxDistance or math.huge
	for _, node in nodes do
		if canUseNode(node) then
			local distance = (root.Position - node.Position).Magnitude
			if distance < bestDistance then
				best = node
				bestDistance = distance
			end
		end
	end
	return best
end

local function updateNodeLook(node: BasePart)
	node.Transparency = if node:GetAttribute("Broken") == true then 0.85 else 0
end

local function addNode(instance: Instance)
	if not instance:IsA("BasePart") then
		return
	end
	local nodeId = instance:GetAttribute("NodeId")
	if type(nodeId) ~= "string" then
		return
	end
	nodes[nodeId] = instance
	updateNodeLook(instance)
	instance:GetAttributeChangedSignal("Broken"):Connect(function()
		updateNodeLook(instance)
		if instance:GetAttribute("Broken") == true then
			Sounds.play("reward", 1.4)
		end
	end)
end

local function removeNode(instance: Instance)
	local nodeId = instance:GetAttribute("NodeId")
	if type(nodeId) == "string" and nodes[nodeId] == instance then
		nodes[nodeId] = nil
	end
end

local function refreshAutoButton()
	local session = State.session
	local owned = session ~= nil and session.passes.autoHit == true
	autoButton.Visible = owned
	autoButton.Text = if autoEnabled then "Auto: ON" else "Auto: OFF"
	autoButton.BackgroundColor3 = if autoEnabled then Theme.colors.good else Theme.colors.disabled
end

function Interact.init()
	autoButton = Builder.button({
		text = "Auto: ON",
		color = Theme.colors.good,
		size = UDim2.fromOffset(170, Theme.touchTarget),
		position = UDim2.new(1, -16, 1, -16),
		anchor = Vector2.new(1, 1),
		parent = Root.layer("hud"),
		onClick = function()
			autoEnabled = not autoEnabled
			refreshAutoButton()
		end,
	})
	autoButton.Visible = false
end

function Interact.start()
	for _, instance in CollectionService:GetTagged(NODE_TAG) do
		addNode(instance)
	end
	CollectionService:GetInstanceAddedSignal(NODE_TAG):Connect(addNode)
	CollectionService:GetInstanceRemovedSignal(NODE_TAG):Connect(removeNode)
	UserInputService.InputBegan:Connect(onInput)

	Net.on("HitEffect", function(nodeId: any, broke: any)
		local node = if type(nodeId) == "string" then nodes[nodeId] else nil
		if node then
			pop(node)
			if broke == true then
				Sounds.play("reward", 1.4)
			end
		end
	end)

	State.Changed:Connect(function(key: string)
		if key == "*" or key == "session.passes" then
			refreshAutoButton()
		end
	end)

	task.spawn(function()
		while true do
			task.wait(Economy.autoHitInterval)
			local session = State.session
			if autoEnabled and session and session.passes.autoHit then
				local node = Interact.nearestUsableNode(Economy.hitRange)
				if node then
					Interact.tryHit(node, false)
				end
			end
		end
	end)
end

return Interact
