--!strict
-- Social: rewards playing together. Friends in the same server and group membership add a coin bonus
-- (vault: 10-retention-and-social/social-systems.md). Co-play is also a ranking signal on Roblox.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Economy = require(Shared.Config.Economy)
local Game = require(Shared.Config.Game)

local PlayerData = require(script.Parent.PlayerData)

local Social = {}

local inGroup: { [Player]: boolean } = {}
-- friendships[a][b] = true when a and b are friends (both directions stored)
local friendships: { [Player]: { [Player]: boolean } } = {}

local function friendCount(player: Player): number
	local count = 0
	local friends = friendships[player]
	if not friends then
		return 0
	end
	for other in friends do
		if other.Parent then
			count += 1
		end
	end
	return count
end

local function refresh(player: Player)
	local session = PlayerData.session(player)
	if not session then
		return
	end
	local friendBonus = math.min(friendCount(player) * Economy.friendBonusPerFriend, Economy.maxFriendBonus)
	local groupBonus = if inGroup[player] then Game.groupCoinBonus else 0
	local bonus = friendBonus + groupBonus
	if session.socialBonus ~= bonus then
		session.socialBonus = bonus
		PlayerData.sessionChanged(player, "socialBonus")
	end
end

local function checkGroup(player: Player)
	if Game.groupId == 0 then
		return
	end
	local ok, result = pcall(function()
		return player:IsInGroupAsync(Game.groupId)
	end)
	inGroup[player] = ok and result == true
end

local function onLoaded(player: Player)
	friendships[player] = friendships[player] or {}
	checkGroup(player)
	for _, other in Players:GetPlayers() do
		if other ~= player then
			local ok, isFriend = pcall(function()
				return player:IsFriendsWithAsync(other.UserId)
			end)
			if ok and isFriend then
				friendships[player][other] = true
				friendships[other] = friendships[other] or {}
				friendships[other][player] = true
				refresh(other)
			end
		end
	end
	refresh(player)
end

local function onRemoving(player: Player)
	local friends = friendships[player]
	friendships[player] = nil
	inGroup[player] = nil
	if friends then
		for other in friends do
			local theirs = friendships[other]
			if theirs then
				theirs[player] = nil
			end
			refresh(other)
		end
	end
end

function Social.bonus(player: Player): number
	local session = PlayerData.session(player)
	return if session then session.socialBonus else 0
end

function Social.init() end

function Social.start()
	PlayerData.Loaded:Connect(onLoaded)
	Players.PlayerRemoving:Connect(onRemoving)
end

return Social
