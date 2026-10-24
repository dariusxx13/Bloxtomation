--!strict
-- Grants: the one place rewards are paid out (daily, playtime, codes, purchases, QA).
-- Coin rewards are "minutes of income" so they scale with progress (vault: 04-progression-and-economy/economy-math.md).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Format = require(Shared.Util.Format)
local Products = require(Shared.Config.Products)
local RewardConfig = require(Shared.Config.Rewards)
local Stats = require(Shared.Util.Stats)

local Currency = require(script.Parent.Currency)
local PlayerData = require(script.Parent.PlayerData)

export type Reward = RewardConfig.Reward

-- What was actually granted, for toasts and analytics.
export type GrantSummary = { coins: number, gems: number, boost: string?, boostSeconds: number? }

local Grants = {}

function Grants.coinsForMinutes(player: Player, minutes: number): number
	local data = PlayerData.get(player)
	local derived = PlayerData.derived(player)
	if not data or not derived then
		return 0
	end
	return Stats.coinsForMinutes(data, derived, minutes, RewardConfig.assumedHitsPerMinute)
end

-- Extends a personal boost. Stacking adds time instead of multiplying the effect.
function Grants.boost(player: Player, boostId: string, seconds: number): boolean
	local data = PlayerData.get(player)
	if not data or (Products.boostEffects :: any)[boostId] == nil or seconds <= 0 then
		return false
	end
	local now = os.time()
	data.boosts[boostId] = math.max(data.boosts[boostId] or 0, now) + math.floor(seconds)
	PlayerData.changed(player, "boosts")
	return true
end

-- Pays a reward table. `coinBonus` multiplies only the coin part (e.g. daily streak bonus).
function Grants.reward(
	player: Player,
	reward: Reward,
	transactionType: string,
	sku: string,
	coinBonus: number?
): GrantSummary
	local summary: GrantSummary = { coins = 0, gems = 0 }
	if reward.coinsMinutes and reward.coinsMinutes > 0 then
		local coins = math.floor(Grants.coinsForMinutes(player, reward.coinsMinutes) * (coinBonus or 1))
		coins = math.max(coins, 1)
		if Currency.add(player, "Coins", coins, transactionType, sku) then
			summary.coins = coins
		end
	end
	if reward.gems and reward.gems > 0 then
		if Currency.add(player, "Gems", reward.gems, transactionType, sku) then
			summary.gems = reward.gems
		end
	end
	if reward.boost and reward.boostSeconds then
		if Grants.boost(player, reward.boost, reward.boostSeconds) then
			summary.boost = reward.boost
			summary.boostSeconds = reward.boostSeconds
		end
	end
	return summary
end

-- Short player-facing text, e.g. "+1.2K Coins, +25 Gems, 2x Coins 10m".
function Grants.describe(summary: GrantSummary): string
	local parts: { string } = {}
	if summary.coins > 0 then
		table.insert(parts, `+{Format.short(summary.coins)} Coins`)
	end
	if summary.gems > 0 then
		table.insert(parts, `+{Format.short(summary.gems)} Gems`)
	end
	if summary.boost and summary.boostSeconds then
		table.insert(parts, `{Grants.boostName(summary.boost)} {Format.duration(summary.boostSeconds)}`)
	end
	return table.concat(parts, ", ")
end

function Grants.boostName(boostId: string): string
	if boostId == "coins2x" then
		return "2x Coins"
	elseif boostId == "luck2x" then
		return "2x Luck"
	elseif boostId == "serverLuck" then
		return "Server Luck"
	end
	return boostId
end

-- Drops expired boosts so profiles stay small.
local function pruneBoosts(player: Player)
	local data = PlayerData.get(player)
	if not data then
		return
	end
	local now = os.time()
	local changed = false
	for boostId, expiry in data.boosts do
		if expiry <= now then
			data.boosts[boostId] = nil
			changed = true
		end
	end
	if changed then
		PlayerData.changed(player, "boosts")
	end
end

function Grants.init() end

function Grants.start()
	PlayerData.Loaded:Connect(pruneBoosts)
end

return Grants
