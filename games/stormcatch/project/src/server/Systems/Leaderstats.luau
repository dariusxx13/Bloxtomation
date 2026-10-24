--!strict
-- Leaderstats: the player-list columns. Display only: values are written from the profile and never read back.
-- Rebirths comes first (the list sorts by the first stat); Coins is a short string so huge numbers stay readable.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Format = require(ReplicatedStorage.Shared.Util.Format)

local PlayerData = require(script.Parent.PlayerData)

local Leaderstats = {}

local values: { [Player]: { rebirths: IntValue, coins: StringValue } } = {}

local function update(player: Player)
	local data = PlayerData.get(player)
	local entry = values[player]
	if not data or not entry then
		return
	end
	entry.rebirths.Value = data.rebirths
	entry.coins.Value = Format.short(data.coins)
end

local function create(player: Player)
	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"
	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Parent = folder
	local coins = Instance.new("StringValue")
	coins.Name = "Coins"
	coins.Parent = folder
	values[player] = { rebirths = rebirths, coins = coins }
	update(player)
	folder.Parent = player
end

function Leaderstats.init() end

function Leaderstats.start()
	PlayerData.Loaded:Connect(create)
	PlayerData.Changed:Connect(function(player: Player, key: string)
		if key == "coins" or key == "rebirths" then
			update(player)
		end
	end)
	PlayerData.Removing:Connect(function(player: Player)
		values[player] = nil
	end)
end

return Leaderstats
