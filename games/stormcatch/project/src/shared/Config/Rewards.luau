--!strict
-- Daily calendar and in-session playtime gifts (vault: 10-retention-and-social/retention-systems.md).
-- Coin rewards are expressed in "minutes of the player's current income" so they stay meaningful.

export type Reward = { coinsMinutes: number?, gems: number?, boost: string?, boostSeconds: number? }

local Rewards = {
	daily = {
		{ coinsMinutes = 3 },
		{ coinsMinutes = 5, gems = 10 },
		{ coinsMinutes = 6, gems = 15 },
		{ coinsMinutes = 8, boost = "coins2x", boostSeconds = 600 },
		{ coinsMinutes = 10, gems = 25 },
		{ coinsMinutes = 12, gems = 30 },
		{ coinsMinutes = 20, gems = 75, boost = "luck2x", boostSeconds = 900 }, -- day 7: the best
	} :: { Reward },
	streakCoinBonusPerDay = 0.02, -- +2% coins per streak day
	maxStreakBonus = 0.3,

	playtime = {
		{ minutes = 5, reward = { coinsMinutes = 2 } },
		{ minutes = 10, reward = { gems = 10 } },
		{ minutes = 15, reward = { coinsMinutes = 4 } },
		{ minutes = 25, reward = { boost = "coins2x", boostSeconds = 600 } },
		{ minutes = 40, reward = { gems = 25 } },
		{ minutes = 60, reward = { coinsMinutes = 15, gems = 50 } }, -- last gift is the best
	} :: { { minutes: number, reward: Reward } },

	-- Typical hits per minute used to convert "coinsMinutes" into coins.
	assumedHitsPerMinute = 90,
}

return table.freeze(Rewards)
