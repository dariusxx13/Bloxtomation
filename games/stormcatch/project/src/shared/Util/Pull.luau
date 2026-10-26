--!strict
-- Pull: the pure rules of the Great Storm co-op pull (prototype brief req. 9.4-9.7; economy sheet v2 §8, §14).
-- The angler always pulls at points/soloSeconds per second; each active helper (a Pull tap within the last
-- activeSeconds) adds helperFactor of that rate, at most maxHelpers counted. Landing time =
-- soloSeconds / (1 + helperFactor x helpers): 45 s alone, 12.4 s with 3, 10 s with 4.
-- Helpers' coins are minted on top: the angler's payout never depends on who helped.

local Catch = require("./Catch")
local Fishing = require("../Config/Fishing")
local Types = require("../Types")

local Pull = {}

local P = Fishing.pull

function Pull.anglerRate(): number
	return P.points / P.soloSeconds
end

-- Meter points per second with `helpers` active helpers.
function Pull.rate(helpers: number): number
	local counted = math.clamp(math.floor(helpers), 0, P.maxHelpers)
	return Pull.anglerRate() * (1 + P.helperFactor * counted)
end

function Pull.landingSeconds(helpers: number): number
	return P.points / Pull.rate(helpers)
end

-- How many helpers are active at time t, given each helper's tap times.
function Pull.activeHelpers(tapTimes: { { number } }, t: number): number
	local active = 0
	for _, taps in tapTimes do
		for _, tap in taps do
			if tap <= t and t - tap <= P.activeSeconds then
				active += 1
				break
			end
		end
	end
	return active
end

-- Integrates the meter from t = 0 with step dt until it lands; returns the landing time (math.huge after
-- `limit` seconds). This is the same per-tick update the server runs (StormPull).
function Pull.simulate(tapTimes: { { number } }, dt: number, limit: number?): number
	local progress = 0
	local t = 0
	local stop = limit or 120
	while t < stop do
		local rate = Pull.rate(Pull.activeHelpers(tapTimes, t))
		progress += rate * dt
		t += dt
		if progress >= P.points then
			return t
		end
	end
	return math.huge
end

-- Stormborn Charged chance: base + perFriend x friends among the active helpers, capped.
function Pull.chargedChance(friendHelpers: number): number
	return math.min(P.chargedBase + P.chargedPerFriend * math.max(0, friendHelpers), P.chargedCap)
end

export type Giant = { baseCoins: number, size: number, mark: Types.MarkId? }
export type Helper = { rodLevel: number, paidHelpsThisStorm: number }

-- Coins for the angler and for each helper. A helper earns helperShare of the giant's value at their own
-- Rod level, for at most maxPaidHelpsPerStorm helps per storm (0 after that: the Witnessed card only).
function Pull.payouts(giant: Giant, anglerRod: number, helpers: { Helper }): (number, { number })
	local angler = Catch.value(giant.baseCoins, giant.size, giant.mark, anglerRod)
	local shares: { number } = {}
	for index, helper in helpers do
		if helper.paidHelpsThisStorm < P.maxPaidHelpsPerStorm then
			local value = giant.baseCoins
				* giant.size
				* Catch.markMultiplier(giant.mark)
				* Catch.rodMultiplier(helper.rodLevel)
			shares[index] = math.max(1, math.floor(value * P.helperShare + 0.5))
		else
			shares[index] = 0
		end
	end
	return angler, shares
end

return Pull
