--!strict
-- Core economy tuning. Balanced with scripts/economy-sheet.luau (see vault: 04-progression-and-economy/economy-math.md).
-- Targets (casual free player, ~1.5 hits/s): first upgrade < 1 min, zone 2 at ~10-15 min,
-- zone 3 at ~30-45 min, first rebirth at ~30-60 min.

local Economy = {
	-- Hits
	baseCoinsPerHit = 1,
	hitCooldownSeconds = 0.18, -- server-enforced minimum time between hits (human tapping speed)
	hitRange = 28, -- studs from the player's root part to the node
	autoHitInterval = 0.45, -- seconds between automatic hits with the Auto Hit pass

	-- Resource nodes
	nodeHitsToBreak = 12, -- hits before a node breaks and pays a bonus
	nodeBreakBonusHits = 6, -- bonus = coinsPerHit * this
	nodeRespawnSeconds = 4,

	-- Rebirth
	rebirthBaseCost = 250000,
	rebirthCostGrowth = 3,
	rebirthMultiplierPerRebirth = 0.5, -- total multiplier = 1 + 0.5 * rebirths
	rebirthKeepsZones = true,

	-- Multiplier caps (vault rule: cap every category)
	maxPetMultiplier = 25, -- 1 + sum(pet bonuses) is capped here
	maxLuck = 10,
	friendBonusPerFriend = 0.1,
	maxFriendBonus = 0.5,

	-- Model players for the economy sheet and pacing tests
	playerModels = {
		casual = { hitsPerSecond = 1.5, sessionMinutes = 10, sessionsPerDay = 1 },
		typical = { hitsPerSecond = 2, sessionMinutes = 20, sessionsPerDay = 2 },
		paying = { hitsPerSecond = 2.2, sessionMinutes = 30, sessionsPerDay = 3 },
	},
}

return table.freeze(Economy)
