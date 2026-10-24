--!strict
-- Shared types. Pure module (no Roblox globals) so it can be required from Lune tests.
-- Anything that crosses the client/server boundary or is saved to a DataStore is typed here.

export type RarityId = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Mythic" | "Secret"

export type OwnedPet = {
	id: string, -- unique instance id (GUID)
	kind: string, -- catalog id from Config/Pets
	locked: boolean?,
}

export type DailyState = {
	streak: number, -- consecutive days claimed
	lastClaimDay: number, -- UTC day number of the last claim (0 = never)
	calendarDay: number, -- 1..7 position in the reward calendar
}

export type Settings = {
	music: boolean,
	sfx: boolean,
	reduceMotion: boolean,
	hideOthersPets: boolean,
}

export type Stats = {
	hits: number,
	hatches: number,
	sessions: number,
	firstJoin: number,
	lastLogout: number,
	totalCoinsEarned: number,
	playSeconds: number,
}

-- The persisted player profile. Keep it plain JSON-compatible data.
export type ProfileData = {
	version: number,
	coins: number,
	gems: number,
	upgrades: { [string]: number },
	zonesUnlocked: { [string]: boolean },
	pets: { OwnedPet },
	equipped: { string },
	index: { [string]: number },
	pity: { [string]: number },
	rebirths: number,
	daily: DailyState,
	onboardingStep: number,
	codesRedeemed: { [string]: boolean },
	receipts: { string },
	oneTimeProducts: { [string]: boolean },
	boosts: { [string]: number }, -- boost id -> unix expiry
	settings: Settings,
	stats: Stats,
}

-- Values derived from the profile, passes and boosts. Computed by Util/Stats on both sides.
export type DerivedStats = {
	coinsPerHit: number,
	coinMultiplier: number,
	luck: number,
	petSlots: number,
	petCapacity: number,
	walkSpeed: number,
	rebirthMultiplier: number,
	petMultiplier: number,
}

-- Runtime (not persisted) state the server replicates to the owning client.
export type SessionState = {
	passes: { [string]: boolean },
	serverLuckUntil: number,
	socialBonus: number,
	playtimeClaimed: { [number]: boolean },
	sessionStart: number, -- start of the current play-time accounting window (moves on autosave)
	joinedAt: number, -- unix time this session began (never moves; playtime gifts count from here)
	randomItemsRestricted: boolean,
}

export type HatchResult = {
	id: string,
	kind: string,
	rarity: RarityId,
	isNew: boolean,
}

-- What every client -> server function remote returns. Extra fields (results, text, ...) are per remote.
export type ActionResult = {
	ok: boolean,
	reason: string?,
	[string]: any,
}

return nil
