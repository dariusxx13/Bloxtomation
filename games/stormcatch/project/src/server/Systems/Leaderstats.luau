--!strict
-- Leaderstats: the player-list column. Display only: values are written from the profile and never read back.
-- Coins is a short string so big numbers stay readable.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Format = require(ReplicatedStorage.Shared.Util.Format)

local PlayerData = require(script.Parent.PlayerData)

local Leaderstats = {}

local values: { [Player]: { coins: StringValue } } = {}

local function update(player: Player)
	local data = PlayerData.get(player)
	local entry = values[player]
	if not data or not entry then
		return
	end
	entry.coins.Value = Format.short(data.coins)
end

local function create(player: Player)
	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"
	local coins = Instance.new("StringValue")
	coins.Name = "Coins"
	coins.Parent = folder
	values[player] = { coins = coins }
	update(player)
	folder.Parent = player
end

function Leaderstats.init() end

function Leaderstats.start()
	PlayerData.Loaded:Connect(create)
	PlayerData.Changed:Connect(function(player: Player, key: string)
		if key == "coins" then
			update(player)
		end
	end)
	PlayerData.Removing:Connect(function(player: Player)
		values[player] = nil
	end)
end

return Leaderstats
