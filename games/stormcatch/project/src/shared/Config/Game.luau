--!strict
-- Game identity and global settings. Pure module: replicated to clients, never put secrets here.
-- BUILD-10: change `name`, set `isTemplateDefault = false`, and set real ids before shipping.

local Game = {
	name = "Starter Simulator",
	isTemplateDefault = true,

	-- Data
	dataStoreName = "PlayerData_v1",
	autosaveSeconds = 90,
	maxReceiptsKept = 200,
	sessionLockStaleSeconds = 600, -- a lock older than this is considered abandoned

	-- Community
	groupId = 0, -- your Roblox group id (0 disables group rewards)
	groupCoinBonus = 0.1, -- +10% coins for group members

	-- QA: user ids allowed to use QA commands in live servers (Studio is always allowed)
	qaUserIds = {} :: { number },

	-- Currencies
	softCurrency = "Coins",
	premiumCurrency = "Gems",

	-- Built-in Roblox client sounds (replace with your own uploaded assets)
	sounds = {
		hit = "rbxasset://sounds/electronicpingshort.wav",
		click = "rbxasset://sounds/button.wav",
		reward = "rbxasset://sounds/electronicpingshort.wav",
	},
}

return table.freeze(Game)
