--!strict
-- The moment loop and the Great Storm pull: cast, bite, ring, land, pull (prototype brief req. 3 and 9).
-- Numbers are economy sheet v2 §3.2, §8 and §14 and the GDD v3.1 §4.1/§4.3 design values the brief copies.
-- Pure module; the server judges with these values and the client only draws them.

local Types = require("../Types")

export type RingDef = {
	lap: number, -- seconds for the marker to go once round the ring
	arc: number, -- green arc width in degrees
	steps: { [Types.RarityId]: number }, -- good taps needed per tier
	missBudget: number, -- misses allowed; one more and the fish swims off
	opacity: number, -- ring opacity on the client (the marker is always drawn at full opacity)
	hook: boolean, -- Sea Fog: the ring appears only after a hook tap
}

local function steps(
	common: number,
	uncommon: number,
	rare: number,
	epic: number
): { [Types.RarityId]: number }
	return { Common = common, Uncommon = uncommon, Rare = rare, Epic = epic }
end

local Fishing = {
	-- Cast (req. 3.1). castRange is the template's Economy.hitRange.
	castRange = 28, -- studs from the root part to the ripple centre
	castRangeMargin = 8, -- server-side latency margin
	castCooldown = 0.5, -- seconds since the last line ended

	-- Bite waits, uniform, by the weather at the spot at cast time (sheet §3.2). The storm wait applies at the
	-- eye only; the other spots during the storm use the Clear wait.
	biteWait = {
		clear = { min = 2.0, max = 5.0 },
		showers = { min = 1.0, max = 2.5 },
		fog = { min = 2.8, max = 7.0 },
		storm = { min = 2.0, max = 4.0 },
	} :: { [Types.RingMode]: { min: number, max: number } },

	-- Ring modes (req. 3.4)
	ring = {
		clear = { lap = 1.6, arc = 90, steps = steps(1, 2, 3, 3), missBudget = 3, opacity = 1, hook = false },
		showers = {
			lap = 1.1,
			arc = 150,
			steps = steps(1, 1, 2, 2),
			missBudget = 3,
			opacity = 1,
			hook = false,
		},
		fog = { lap = 1.8, arc = 90, steps = steps(1, 2, 3, 3), missBudget = 4, opacity = 0.4, hook = true },
		storm = { lap = 1.6, arc = 90, steps = steps(1, 2, 3, 3), missBudget = 3, opacity = 1, hook = false },
	} :: { [Types.RingMode]: RingDef },

	hookWindow = 3.0, -- Sea Fog: seconds from the dip to hook
	escapeSeconds = 12, -- from the ring start without landing
	tapSpacing = 0.15, -- taps closer than this are ignored
	latencyMaxPing = 0.25, -- allowance = min(ping, latencyMaxPing) + latencyExtra
	latencyExtra = 0.06,
	-- After a good step the green arc moves this far ahead of the marker (degrees). Engineering value: the
	-- brief fixes lap, arc and steps; a moving arc stops one held rhythm from landing every step.
	arcJumpMin = 120,
	arcJumpMax = 240,

	-- Scripted moments (req. 3.6, 3.7; sheet §3.1, §14)
	firstCatch = {
		species = "pebble_minnow",
		kg = 0.8,
		biteSeconds = 2.0,
		steps = 1,
		coins = 12,
	},
	firstRainCatch = { species = "pitterpike", mark = "drizzled" :: Types.MarkId },

	-- Great Storm co-op pull (req. 9; sheet §8, §14)
	pull = {
		radius = 40, -- studs from the angler where Pull! shows and taps count
		points = 100, -- meter points to land
		soloSeconds = 45, -- the angler alone pulls at points / soloSeconds per second
		helperFactor = 0.875, -- each active helper adds this share of the angler's rate
		maxHelpers = 7,
		activeSeconds = 1.0, -- a helper is active if they tapped Pull! within this many seconds
		helperShare = 0.10, -- of the giant's value at the helper's own Rod level, minted on top
		maxPaidHelpsPerStorm = 3,
		chargedBase = 0.25, -- Stormborn Charged chance, rolled at landing
		chargedPerFriend = 0.05, -- per friend of the angler among the active helpers
		chargedCap = 0.50,
		maxLingerSeconds = 45, -- storm visuals stay over the pier until the last pull lands
		holdPoseSeconds = 3,
	},

	-- The rod held by the avatar (req. 8): 5 studs plus 0.4 per level, a new colour every 3 levels.
	rod = {
		baseLength = 5,
		lengthPerLevel = 0.4,
		levelsPerColor = 3,
		colors = {
			{ 255, 248, 236 }, -- Shell Cream
			{ 255, 122, 89 }, -- Ember Coral
			{ 63, 127, 140 }, -- Squall Teal
			{ 168, 220, 209 }, -- Seafoam
			{ 255, 196, 46 }, -- Lantern Gold
			{ 46, 63, 92 }, -- Storm Slate
		} :: { { number } },
	},
}

return table.freeze(Fishing)
