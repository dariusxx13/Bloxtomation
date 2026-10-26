--!strict
-- Characters: applies derived stats to the character (walk speed), gives every avatar its rod (brief req. 8:
-- 5 studs plus 0.4 per Rod level, a new colour every 3 levels; a server part so everyone sees it), and keeps
-- players out of zones they have not unlocked (the prototype has one free zone, so this never fires).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local FishingConfig = require(Shared.Config.Fishing)
local Net = require(Shared.Net)
local Stats = require(Shared.Util.Stats)

local PlayerData = require(script.Parent.PlayerData)
local World = require(script.Parent.World)

local Characters = {}

local CHECK_SECONDS = 2
local STAT_KEYS = { upgrades = true }
local ROD_NAME = "FishingRod"

local function humanoidOf(player: Player): Humanoid?
	local character = player.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

-- Rod length and colour for a Rod level.
function Characters.rodLook(level: number): (number, Color3)
	local rod = FishingConfig.rod
	local length = rod.baseLength + rod.lengthPerLevel * level
	local colors = rod.colors
	local index = (level // rod.levelsPerColor) % #colors + 1
	local rgb = colors[index]
	return length, Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

local function updateRod(player: Player)
	local data = PlayerData.get(player)
	local character = player.Character
	if not data or not character then
		return
	end
	local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	if not hand or not hand:IsA("BasePart") then
		return
	end
	local length, color = Characters.rodLook(Stats.rodLevel(data))
	local existing = character:FindFirstChild(ROD_NAME)
	local rod: Part
	if existing and existing:IsA("Part") then
		rod = existing
	else
		rod = Instance.new("Part")
		rod.Name = ROD_NAME
		rod.Material = Enum.Material.SmoothPlastic
		rod.CanCollide = false
		rod.CanTouch = false
		rod.CanQuery = false
		rod.Massless = true
		rod.CastShadow = false
		local tip = Instance.new("Attachment")
		tip.Name = "Tip"
		tip.Parent = rod
		local weld = Instance.new("Weld")
		weld.Name = "Grip"
		weld.Part0 = hand
		weld.Part1 = rod
		weld.Parent = rod
		rod.Parent = character
	end
	rod.Size = Vector3.new(0.3, 0.3, length)
	rod.Color = color
	rod:SetAttribute("RodLevel", Stats.rodLevel(data))
	local tip = rod:FindFirstChild("Tip")
	if tip and tip:IsA("Attachment") then
		tip.Position = Vector3.new(0, 0, -length / 2)
	end
	local grip = rod:FindFirstChild("Grip")
	if grip and grip:IsA("Weld") then
		-- Held in the hand, pointing forward and up at 40 degrees.
		grip.C0 = CFrame.new(0, -0.3, 0) * CFrame.Angles(math.rad(40), 0, 0) * CFrame.new(0, 0, -length / 2)
	end
end

function Characters.applyStats(player: Player)
	local derived = PlayerData.derived(player)
	local humanoid = humanoidOf(player)
	if derived and humanoid then
		humanoid.WalkSpeed = derived.walkSpeed
	end
	updateRod(player)
end

local function checkTrespass(player: Player)
	local data = PlayerData.get(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not data or not character or not root or not root:IsA("BasePart") then
		return
	end
	local zoneId = World.zoneAt(root.Position)
	if zoneId and not data.zonesUnlocked[zoneId] then
		character:PivotTo(World.spawnCFrame())
		Net.toClient(player, "Toast", { text = "That island opens later!", kind = "info" })
	end
end

function Characters.init() end

function Characters.start()
	local function onPlayer(player: Player)
		player.CharacterAdded:Connect(function(character: Model)
			character:WaitForChild("Humanoid", 10)
			character:WaitForChild("RightHand", 5)
			Characters.applyStats(player)
		end)
	end
	Players.PlayerAdded:Connect(onPlayer)
	for _, player in Players:GetPlayers() do
		onPlayer(player)
	end
	PlayerData.Loaded:Connect(Characters.applyStats)
	PlayerData.Changed:Connect(function(player: Player, key: string)
		if STAT_KEYS[key] then
			Characters.applyStats(player)
		end
	end)
	task.spawn(function()
		while true do
			task.wait(CHECK_SECONDS)
			for _, player in Players:GetPlayers() do
				checkTrespass(player)
			end
		end
	end)
end

return Characters
