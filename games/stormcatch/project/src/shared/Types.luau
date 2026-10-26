--!strict
-- Shared types. Pure module (no Roblox globals) so it can be required from Lune tests.
-- Anything that crosses the client/server boundary or is saved to a DataStore is typed here.

export type RarityId = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Mythic" | "Secret"

-- Weather at one spot. "storm" is the Great Storm (every spot; only the eye fishes as Storm).
export type Weather = "clear" | "showers" | "fog" | "storm"

-- The ring mode a bite is reeled in (prototype brief req. 3.4). Storm away from the eye reels as "clear".
export type RingMode = "clear" | "showers" | "fog" | "storm"

export type MarkId = "drizzled" | "misty" | "charged"

export type OwnedPet = {
	id: string, -- unique instance id (GUID)
	kind: string, -- catalog id (no companions in the prototype; kept so the saved shape never changes)
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
	-- Schema v2 (Reel the Storm prototype)
	catches: number, -- fish landed (onboarding step 3)
	rainCatches: number, -- fish landed with Showers at bite, excluding the scripted first catch (step 7)
	stormsJoined: number, -- Great Storms this player fished at the eye or helped a pull in
	giantsLanded: number, -- Stormborn landed as the angler
	helps: number, -- Stormborn pulls helped (taps counted)
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
	index: { [string]: number }, -- species id -> times landed ("NEW!" on the first)
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

-- Values derived from the profile. Computed by Util/Stats on both sides.
export type DerivedStats = {
	rodLevel: number,
	rodMultiplier: number, -- 1.14 ^ rod level (economy sheet §14)
	luck: number, -- always 1 in the prototype (no Lure, companions, friend bonus or paid luck)
	walkSpeed: number,
}

-- Runtime (not persisted) state the server replicates to the owning client.
export type SessionState = {
	passes: { [string]: boolean },
	serverLuckUntil: number,
	sessionStart: number, -- start of the current play-time accounting window (moves on autosave)
	joinedAt: number, -- unix time this session began (never moves)
	randomItemsRestricted: boolean,
}

-- What every client -> server function remote returns. Extra fields are per remote.
export type ActionResult = {
	ok: boolean,
	reason: string?,
	[string]: any,
}

-- Server -> client payloads -------------------------------------------------------------------------

export type Arrival = { at: number, spot: string, weather: Weather }

export type StormInfo = { active: boolean, startsAt: number, endsAt: number }

-- Sent on every weather change and on join. Times are server unix seconds (Workspace:GetServerTimeNow()).
export type WeatherStatePayload = {
	serverTime: number,
	offset: number, -- QA schedule offset (seconds) in effect on this server
	spots: { [string]: Weather },
	forced: { [string]: boolean }, -- spots whose weather comes from a QA override
	storm: StormInfo,
	stormForced: boolean,
	arrivals: { Arrival }, -- the next three front arrivals
}

-- A bite. The species is never sent before landing; in Sea Fog the ring only starts after a hook tap.
export type BitePayload = {
	lineId: number,
	mode: RingMode,
	tier: RarityId,
	steps: number,
	missBudget: number,
	lap: number,
	arcWidth: number,
	arcCenter: number,
	ringStart: number?, -- nil in Sea Fog until hooked
	hookDeadline: number?, -- Sea Fog only
	escapeAt: number?, -- nil when no escape is possible (the scripted first catch)
	opacity: number,
}

export type ReelEvent = "hooked" | "good" | "miss" | "escaped" | "nibbled" | "giant"

export type ReelStatePayload = {
	lineId: number,
	event: ReelEvent,
	stepsDone: number,
	misses: number,
	arcCenter: number?,
	ringStart: number?,
	escapeAt: number?,
}

export type CatchPayload = {
	lineId: number,
	kind: "catch" | "witnessed",
	species: string,
	name: string,
	tier: RarityId,
	kg: number,
	mark: MarkId?,
	coins: number,
	isNew: boolean,
	weather: Weather,
}

export type PullInfo = {
	id: number,
	anglerUserId: number,
	anglerName: string,
	spot: string,
	progress: number, -- 0..100 meter points
	rate: number, -- points per second right now
	helpers: number, -- active helpers counted
	at: number, -- server time of this sample
}

export type PullStatePayload = {
	pulls: { PullInfo },
	landed: { id: number, charged: boolean, kg: number, anglerUserId: number }?,
}

return nil
