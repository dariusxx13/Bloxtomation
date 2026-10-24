--!strict
-- Rewards: the 7-day calendar (with a gentle streak) and in-session playtime gifts
-- (vault: 10-retention-and-social/retention-systems.md).
-- Calendar rules live in Util/Daily (shared with the client and unit-tested).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local AnalyticsConfig = require(Shared.Config.Analytics)
local Daily = require(Shared.Util.Daily)
local Net = require(Shared.Net)
local RewardConfig = require(Shared.Config.Rewards)
local Types = require(Shared.Types)
local Validate = require(Shared.Util.Validate)

local Analytics = require(script.Parent.Parent.Services.Analytics)
local LiveConfig = require(script.Parent.Parent.Services.LiveConfig)
local Grants = require(script.Parent.Grants)
local PlayerData = require(script.Parent.PlayerData)

local Rewards = {}

-- UTC day number (Util/Daily). The client uses the same formula with the server's clock.
function Rewards.today(): number
	return Daily.dayNumber(os.time())
end

function Rewards.dailyAvailable(player: Player): boolean
	local data = PlayerData.get(player)
	return data ~= nil and Daily.available(data.daily, Rewards.today())
end

local function onClaimDaily(player: Player): Types.ActionResult
	if not LiveConfig.flag("featureDailyRewards") then
		return { ok = false, reason = "disabled" }
	end
	local data = PlayerData.get(player)
	if not data then
		return { ok = false, reason = "invalid" }
	end
	local nextState, day, streakBonus = Daily.claim(data.daily, Rewards.today())
	if not nextState then
		return { ok = false, reason = "claimed" }
	end
	data.daily = nextState
	PlayerData.changed(player, "daily")

	local reward = RewardConfig.daily[day]
	local summary = Grants.reward(
		player,
		reward,
		Enum.AnalyticsEconomyTransactionType.TimedReward.Name,
		`daily_{day}`,
		streakBonus
	)
	Analytics.custom(player, AnalyticsConfig.customEvents.dailyClaimed, nextState.streak, { tostring(day) })
	return {
		ok = true,
		day = day,
		streak = nextState.streak,
		summary = summary,
		text = Grants.describe(summary),
	}
end

local function onClaimPlaytime(player: Player, indexArg: unknown): Types.ActionResult
	if not LiveConfig.flag("featurePlaytimeRewards") then
		return { ok = false, reason = "disabled" }
	end
	if not Validate.integerInRange(indexArg, 1, #RewardConfig.playtime) then
		return { ok = false, reason = "invalid" }
	end
	local index = indexArg :: number
	local session = PlayerData.session(player)
	if not session or not PlayerData.isLoaded(player) then
		return { ok = false, reason = "invalid" }
	end
	if session.playtimeClaimed[index] then
		return { ok = false, reason = "claimed" }
	end
	local gift = RewardConfig.playtime[index]
	if os.time() - session.joinedAt < gift.minutes * 60 then
		return { ok = false, reason = "early" }
	end
	session.playtimeClaimed[index] = true
	PlayerData.sessionChanged(player, "playtimeClaimed")
	local summary = Grants.reward(
		player,
		gift.reward,
		Enum.AnalyticsEconomyTransactionType.TimedReward.Name,
		`playtime_{index}`
	)
	Analytics.custom(player, AnalyticsConfig.customEvents.playtimeClaimed, index, { tostring(gift.minutes) })
	return { ok = true, summary = summary, text = Grants.describe(summary) }
end

function Rewards.init() end

function Rewards.start()
	Net.handle("ClaimDaily", onClaimDaily)
	Net.handle("ClaimPlaytime", onClaimPlaytime)
	PlayerData.Loaded:Connect(function(player: Player)
		if LiveConfig.flag("featureDailyRewards") and Rewards.dailyAvailable(player) then
			task.wait(4) -- let the player land before the first message
			if player.Parent then
				Net.toClient(
					player,
					"Toast",
					{ text = "Your daily reward is ready!", kind = "reward", panel = "daily" }
				)
			end
		end
	end)
end

return Rewards
