--!strict
-- Game identity and global settings. Pure module: replicated to clients, never put secrets here.
-- BUILD-10: change `name`, set `isTemplateDefault = false`, and set real ids before shipping.

local Game = {
	name = "Reel the Storm", -- store title (decisions D3); the game id stays `stormcatch`
	isTemplateDefault = false,

	-- Data
	dataStoreName = "PlayerData_v1",
	autosaveSeconds = 90,
	maxReceiptsKept = 200,
	sessionLockStaleSeconds = 600, -- a lock older than this is considered abandoned

	-- Community
	groupId = 0, -- your Roblox group id (0: none; the prototype has no group bonus)

	-- QA: user ids allowed to use QA commands in live servers (Studio is always allowed). Empty: only the
	-- human adds ids (their own) before a private-place playtest needs twistStats/exportLog live.
	qaUserIds = {} :: { number },

	-- Currencies
	softCurrency = "Coins",
	premiumCurrency = "Gems",

	-- Built-in Roblox client sounds only (the template's two built-in files; nothing enters the asset index).
	-- The fishing names reuse them at other pitches (UI/Sounds and Controllers/Reel set the pitch).
	sounds = {
		hit = "rbxasset://sounds/electronicpingshort.wav",
		click = "rbxasset://sounds/button.wav",
		reward = "rbxasset://sounds/electronicpingshort.wav",
		reelTick = "rbxasset://sounds/button.wav",
		splashA = "rbxasset://sounds/electronicpingshort.wav",
		splashB = "rbxasset://sounds/button.wav",
		biteChime = "rbxasset://sounds/electronicpingshort.wav",
		rumble = "rbxasset://sounds/button.wav",
		storm = "rbxasset://sounds/electronicpingshort.wav",
	},
}

return table.freeze(Game)
