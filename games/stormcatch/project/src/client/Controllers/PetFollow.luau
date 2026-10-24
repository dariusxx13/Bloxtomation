--!strict
-- PetFollow: renders every player's equipped pets locally (cheap parts, no physics, no replication),
-- in an arc behind the owner with a gentle bob. Respects "hide other players' pets" and only renders
-- owners near the camera (vault: 13-building-it-right/performance-optimization.md).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local Pets = require(Shared.Config.Pets)

local UI = script.Parent.Parent.UI
local Builder = require(UI.Builder)

local State = require(script.Parent.State)

local PetFollow = {}

local RENDER_DISTANCE = 160
local FOLLOW_DISTANCE = 6
local SPACING = 4
local LERP_SPEED = 10
local MAX_PER_PLAYER = 12

local localPlayer = Players.LocalPlayer
local folder: Folder
-- userId -> rendered pet parts in equip order
local rendered: { [number]: { BasePart } } = {}
local kindsByUser: { [number]: { string } } = {}

local function clear(userId: number)
	local parts = rendered[userId]
	if parts then
		for _, part in parts do
			part:Destroy()
		end
	end
	rendered[userId] = nil
end

local function build(userId: number)
	clear(userId)
	local kinds = kindsByUser[userId]
	local data = State.data
	local hideOthers = data ~= nil and data.settings.hideOthersPets
	if not kinds or (hideOthers and userId ~= localPlayer.UserId) then
		return
	end
	local parts: { BasePart } = {}
	for index, kind in kinds do
		if index > MAX_PER_PLAYER then
			break
		end
		local def = Pets.byKind[kind]
		if def then
			local shape = if def.shape == "Block"
				then Enum.PartType.Block
				elseif def.shape == "Cylinder" then Enum.PartType.Cylinder
				else Enum.PartType.Ball
			local part: Part = Builder.make("Part", {
				Name = def.name,
				Shape = shape,
				Size = Vector3.new(2.2, 2.2, 2.2),
				Color = Builder.rgb(def.color),
				Material = Enum.Material.SmoothPlastic,
				Anchored = true,
				CanCollide = false,
				CanQuery = false,
				CanTouch = false,
				CastShadow = false,
				Parent = folder,
			})
			local rarity = Pets.rarityById[def.rarity]
			if rarity and rarity.order >= 5 then
				Builder.make("PointLight", {
					Color = Builder.rgb(rarity.color),
					Range = 8,
					Brightness = 1.5,
					Parent = part,
				})
			end
			table.insert(parts, part)
		end
	end
	rendered[userId] = parts
end

local function onPetsChanged(userId: any, kinds: any)
	if type(userId) ~= "number" or type(kinds) ~= "table" then
		return
	end
	local clean: { string } = {}
	for _, kind in kinds do
		if type(kind) == "string" then
			table.insert(clean, kind)
		end
	end
	kindsByUser[userId] = clean
	build(userId)
end

local function step(dt: number)
	local camera = Workspace.CurrentCamera
	local cameraPosition = if camera then camera.CFrame.Position else Vector3.zero
	local now = os.clock()
	local alpha = math.min(1, dt * LERP_SPEED)
	for userId, parts in rendered do
		local owner = Players:GetPlayerByUserId(userId)
		local character = owner and owner.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local visible = root ~= nil
			and root:IsA("BasePart")
			and (root.Position - cameraPosition).Magnitude <= RENDER_DISTANCE
		for index, part in parts do
			if visible and root and root:IsA("BasePart") then
				local count = #parts
				local offsetX = (index - (count + 1) / 2) * SPACING
				local bob = math.sin(now * 3 + index) * 0.4
				local target = root.CFrame
					* CFrame.new(offsetX, bob - 0.5, FOLLOW_DISTANCE + math.abs(offsetX) * 0.3)
				part.CFrame = part.CFrame:Lerp(target, alpha)
				part.LocalTransparencyModifier = 0
			else
				part.LocalTransparencyModifier = 1
			end
		end
	end
end

function PetFollow.init()
	folder = Builder.make("Folder", { Name = "LocalPets", Parent = Workspace })
end

function PetFollow.start()
	Net.on("PetsChanged", onPetsChanged)
	Players.PlayerRemoving:Connect(function(player: Player)
		clear(player.UserId)
		kindsByUser[player.UserId] = nil
	end)
	State.Changed:Connect(function(key: string)
		if key == "settings" or key == "*" then
			for userId in kindsByUser do
				build(userId)
			end
		end
	end)
	RunService.RenderStepped:Connect(step)
end

return PetFollow
