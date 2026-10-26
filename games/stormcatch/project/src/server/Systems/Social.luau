--!strict
-- Social: who is friends with whom in this server (vault: 10-retention-and-social/social-systems.md).
-- The prototype has no friend coin or luck bonus (brief req. 5); friendships only raise a Stormborn's Charged
-- chance (+5% per friend of the angler among the active helpers, brief req. 9.5).
-- Public: areFriends(a, b).

local Players = game:GetService("Players")

local PlayerData = require(script.Parent.PlayerData)

local Social = {}

-- friendships[a][b] = true when a and b are friends (both directions stored)
local friendships: { [Player]: { [Player]: boolean } } = {}

function Social.areFriends(a: Player, b: Player): boolean
	local friends = friendships[a]
	return friends ~= nil and friends[b] == true
end

local function onLoaded(player: Player)
	friendships[player] = friendships[player] or {}
	for _, other in Players:GetPlayers() do
		if other ~= player then
			local ok, isFriend = pcall(function()
				return player:IsFriendsWithAsync(other.UserId)
			end)
			if ok and isFriend and player.Parent and other.Parent then
				friendships[player][other] = true
				friendships[other] = friendships[other] or {}
				friendships[other][player] = true
			end
		end
	end
end

local function onRemoving(player: Player)
	local friends = friendships[player]
	friendships[player] = nil
	if friends then
		for other in friends do
			local theirs = friendships[other]
			if theirs then
				theirs[player] = nil
			end
		end
	end
end

function Social.init() end

function Social.start()
	PlayerData.Loaded:Connect(onLoaded)
	Players.PlayerRemoving:Connect(onRemoving)
end

return Social
