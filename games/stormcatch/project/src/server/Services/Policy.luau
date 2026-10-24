--!strict
-- Per-player compliance rules from PolicyService (vault: 09-monetization/monetization-compliance.md).
-- If the policy lookup fails, the player is treated as RESTRICTED (the safe default).

local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")

export type PolicyInfo = {
	paidRandomItemsRestricted: boolean,
	paidItemTradingAllowed: boolean,
	loaded: boolean,
}

local Policy = {}

local cache: { [Player]: PolicyInfo } = {}

local SAFE_DEFAULT: PolicyInfo = {
	paidRandomItemsRestricted = true,
	paidItemTradingAllowed = false,
	loaded = false,
}

function Policy.load(player: Player): PolicyInfo
	for attempt = 1, 3 do
		local ok, result = pcall(function()
			return PolicyService:GetPolicyInfoForPlayerAsync(player)
		end)
		if ok and type(result) == "table" then
			local info: PolicyInfo = {
				paidRandomItemsRestricted = result.ArePaidRandomItemsRestricted == true,
				paidItemTradingAllowed = result.IsPaidItemTradingAllowed == true,
				loaded = true,
			}
			cache[player] = info
			return info
		end
		task.wait(attempt)
	end
	warn(`[Policy] could not load policy for {player.UserId}; treating as restricted`)
	cache[player] = table.clone(SAFE_DEFAULT)
	return cache[player]
end

function Policy.get(player: Player): PolicyInfo
	return cache[player] or SAFE_DEFAULT
end

function Policy.randomItemsRestricted(player: Player): boolean
	return Policy.get(player).paidRandomItemsRestricted
end

Players.PlayerRemoving:Connect(function(player)
	cache[player] = nil
end)

return Policy
