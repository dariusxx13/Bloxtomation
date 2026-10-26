--!strict
-- Ring: the server-owned reel ring (prototype brief req. 3.4). Pure module.
-- A marker goes round the ring once per `lap` seconds from `start` (0 degrees at the top, clockwise). A tap
-- is good when the marker was on the green arc at some moment between (tap time - allowance) and the tap
-- time, both on the server clock. allowance = min(player ping, 0.25 s) + 0.06 s.

local Fishing = require("../Config/Fishing")

local Ring = {}

export type Params = {
	start: number, -- server time the marker left 0 degrees
	lap: number,
	arcCenter: number, -- degrees
	arcWidth: number, -- degrees
}

local function wrap(angle: number): number
	return angle % 360
end

-- Whether `angle` lies on the circular arc that starts at `from` and runs `length` degrees clockwise.
local function onArc(angle: number, from: number, length: number): boolean
	return wrap(angle - from) <= length
end

function Ring.markerAngle(params: Params, t: number): number
	return wrap((t - params.start) / params.lap * 360)
end

function Ring.allowance(ping: number): number
	local p = if ping == ping and ping > 0 then ping else 0
	return math.min(p, Fishing.latencyMaxPing) + Fishing.latencyExtra
end

-- True when the marker crossed or sat on the green arc during [tapTime - allowance, tapTime].
function Ring.judge(params: Params, tapTime: number, allowance: number): boolean
	if tapTime < params.start then
		return false
	end
	local from = math.max(params.start, tapTime - math.max(allowance, 0))
	local sweep = (tapTime - from) / params.lap * 360
	if sweep >= 360 then
		return true
	end
	local sweepStart = Ring.markerAngle(params, from)
	local arcStart = wrap(params.arcCenter - params.arcWidth / 2)
	return onArc(arcStart, sweepStart, sweep) or onArc(sweepStart, arcStart, params.arcWidth)
end

-- Where the green arc moves after a good step: `jump` degrees ahead of the marker (a roll in [0, 1) picks
-- the jump between Fishing.arcJumpMin and Fishing.arcJumpMax).
function Ring.nextArcCenter(markerAngle: number, roll: number): number
	local jump = Fishing.arcJumpMin + (Fishing.arcJumpMax - Fishing.arcJumpMin) * roll
	return wrap(markerAngle + jump)
end

-- True when any flash window [flash, flash + window] overlaps [tapTime - allowance, tapTime].
function Ring.onFlash(flashTimes: { number }, window: number, tapTime: number, allowance: number): boolean
	local from = tapTime - math.max(allowance, 0)
	for _, flash in flashTimes do
		if flash <= tapTime and flash + window >= from then
			return true
		end
	end
	return false
end

return Ring
