--!strict
-- Characters: applies derived stats to the character (walk speed) and keeps players out of zones they have
-- not unlocked. Gates are only a client-side barrier (character physics belong to the client), so this
-- server check plus the zone checks in every action are what actually protect progression.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)

local PlayerData = require(script.Parent.PlayerData)
local World = require(script.Parent.World)

local Characters = {}

local CHECK_SECONDS = 2
local STAT_KEYS = { upgrades = true, ["session.passes"] = true, rebirths = true }

local function humanoidOf(player: Player): Humanoid?
	local character = player.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

function Characters.applyStats(player: Player)
	local derived = PlayerData.derived(player)
	local humanoid = humanoidOf(player)
	if derived and humanoid then
		humanoid.WalkSpeed = derived.walkSpeed
	end
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
		Net.toClient(player, "Toast", { text = "Unlock that zone at its gate first!", kind = "error" })
	end
end

function Characters.init() end

function Characters.start()
	local function onPlayer(player: Player)
		player.CharacterAdded:Connect(function(character: Model)
			character:WaitForChild("Humanoid", 10)
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
