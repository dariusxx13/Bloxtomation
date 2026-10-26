--!strict
-- TwistLog: the pure half of the playtest catch log (prototype brief req. 11; GDD v3.1 §2.4 twist test B).
-- The server (Systems/CatchLog) samples each line's spot weather while the line is out and stores segments;
-- this module merges segments, measures line time inside the twist window, builds `twistStats` and CSV.
-- Kinds: "front" (Showers or Sea Fog), "clear", "storm" (the Great Storm or a giant's pull) and "forced"
-- (any QA override). Twist test B excludes storm and forced seconds.

local TwistLog = {}

export type SegmentKind = "front" | "clear" | "storm" | "forced"
export type Segment = { from: number, to: number, kind: SegmentKind }
export type Totals = { front: number, clear: number, storm: number, forced: number }

export type Row = {
	alias: string,
	sinceJoin: number, -- seconds from join to the cast
	spot: string,
	weather: string, -- at bite ("" if it never bit)
	mode: string, -- the ring mode it reeled in ("" if it never bit); the storm away from the eye reels "clear"
	biteSeconds: number, -- cast to the first bite (0 if it never bit)
	underFront: boolean, -- Showers or Sea Fog at bite
	lineSeconds: number, -- cast to land, escape or leave
	frontSeconds: number,
	clearSeconds: number,
	stormSeconds: number,
	forcedSeconds: number,
	result: string, -- landed | escaped | left | giant
	species: string,
	tier: string,
	mark: string,
	kg: number,
	coins: number,
	misses: number,
	forced: boolean, -- a QA override applied to this line
	segments: { Segment },
}

export type PlayerInfo = {
	alias: string,
	joinedAt: number,
	firstCatchAt: number?,
	step6At: number?,
	step7At: number?, -- server time; equal to joinedAt when the profile had passed step 7 before this session
}

export type PlayerStats = {
	alias: string,
	windowStart: number?, -- seconds since join; nil until step 7
	windowSeconds: number,
	frontLineSeconds: number,
	lineSeconds: number,
	share: number?,
	coverage: number?,
	frontSpotSeconds: number,
	nonStormSeconds: number,
	catchesByWeather: { [string]: number },
	firstCatch: number?,
	step6: number?,
	step7: number?,
}

export type Stats = {
	players: { PlayerStats },
	pooled: {
		frontLineSeconds: number,
		lineSeconds: number,
		share: number?,
		coverage: number?,
		catchesByWeather: { [string]: number },
	},
}

TwistLog.COLUMNS = {
	"alias",
	"sinceJoin",
	"spot",
	"weather",
	"mode",
	"biteSeconds",
	"underFront",
	"lineSeconds",
	"frontSeconds",
	"clearSeconds",
	"stormSeconds",
	"forcedSeconds",
	"result",
	"species",
	"tier",
	"mark",
	"kg",
	"coins",
	"misses",
	"forced",
}

TwistLog.TWIST_WINDOW_DELAY = 300 -- the window opens at max(join + 300 s, the step 7 time)

-- Appends [from, to) of `kind`, merging with the last segment when it continues it.
function TwistLog.add(segments: { Segment }, from: number, to: number, kind: SegmentKind)
	if to <= from then
		return
	end
	local last = segments[#segments]
	if last and last.kind == kind and math.abs(last.to - from) < 1e-6 then
		last.to = to
	else
		table.insert(segments, { from = from, to = to, kind = kind })
	end
end

-- Seconds of each kind in the segments.
function TwistLog.totals(segments: { Segment }): Totals
	local totals: Totals = { front = 0, clear = 0, storm = 0, forced = 0 }
	for _, segment in segments do
		local length = segment.to - segment.from
		if segment.kind == "front" then
			totals.front += length
		elseif segment.kind == "clear" then
			totals.clear += length
		elseif segment.kind == "storm" then
			totals.storm += length
		else
			totals.forced += length
		end
	end
	return totals
end

-- Front seconds and counted line seconds inside [w0, w1), excluding storm and forced seconds.
function TwistLog.windowSeconds(segments: { Segment }, w0: number, w1: number): (number, number)
	local front = 0
	local counted = 0
	for _, segment in segments do
		if segment.kind == "front" or segment.kind == "clear" then
			local overlap = math.min(segment.to, w1) - math.max(segment.from, w0)
			if overlap > 0 then
				counted += overlap
				if segment.kind == "front" then
					front += overlap
				end
			end
		end
	end
	return front, counted
end

function TwistLog.windowStart(info: PlayerInfo): number?
	if info.step7At == nil then
		return nil
	end
	return math.max(info.joinedAt + TwistLog.TWIST_WINDOW_DELAY, info.step7At)
end

local function round(value: number, places: number): number
	local scale = 10 ^ places
	return math.floor(value * scale + 0.5) / scale
end

local function since(info: PlayerInfo, t: number?): number?
	return if t then round(t - info.joinedAt, 1) else nil
end

-- twistStats. `coverageParts(t0, t1)` returns the timetable's front spot-seconds and non-storm seconds in
-- [t0, t1) (server times; the caller applies the schedule offset); `spotCount` is 3 in the prototype.
function TwistLog.stats(
	players: { PlayerInfo },
	rows: { Row },
	now: number,
	coverageParts: (number, number) -> (number, number),
	spotCount: number
): Stats
	local result: Stats = {
		players = {},
		pooled = { frontLineSeconds = 0, lineSeconds = 0, catchesByWeather = {} },
	}
	local pooledFrontSpot = 0
	local pooledNonStorm = 0
	for _, info in players do
		local entry: PlayerStats = {
			alias = info.alias,
			windowSeconds = 0,
			frontLineSeconds = 0,
			lineSeconds = 0,
			frontSpotSeconds = 0,
			nonStormSeconds = 0,
			catchesByWeather = {},
			firstCatch = since(info, info.firstCatchAt),
			step6 = since(info, info.step6At),
			step7 = since(info, info.step7At),
		}
		local w0 = TwistLog.windowStart(info)
		for _, row in rows do
			if row.alias == info.alias then
				if row.result == "landed" or row.result == "giant" then
					entry.catchesByWeather[row.weather] = (entry.catchesByWeather[row.weather] or 0) + 1
					result.pooled.catchesByWeather[row.weather] = (
						result.pooled.catchesByWeather[row.weather] or 0
					) + 1
				end
				if w0 and now > w0 then
					local front, counted = TwistLog.windowSeconds(row.segments, w0, now)
					entry.frontLineSeconds += front
					entry.lineSeconds += counted
				end
			end
		end
		if w0 and now > w0 then
			entry.windowStart = round(w0 - info.joinedAt, 1)
			entry.windowSeconds = round(now - w0, 1)
			local frontSpot, nonStorm = coverageParts(w0, now)
			entry.frontSpotSeconds = frontSpot
			entry.nonStormSeconds = nonStorm
			entry.coverage = if nonStorm > 0 then round(frontSpot / (spotCount * nonStorm), 4) else nil
			pooledFrontSpot += frontSpot
			pooledNonStorm += nonStorm
		end
		entry.share = if entry.lineSeconds > 0
			then round(entry.frontLineSeconds / entry.lineSeconds, 4)
			else nil
		result.pooled.frontLineSeconds += entry.frontLineSeconds
		result.pooled.lineSeconds += entry.lineSeconds
		entry.frontLineSeconds = round(entry.frontLineSeconds, 1)
		entry.lineSeconds = round(entry.lineSeconds, 1)
		table.insert(result.players, entry)
	end
	local pooled = result.pooled
	pooled.share = if pooled.lineSeconds > 0
		then round(pooled.frontLineSeconds / pooled.lineSeconds, 4)
		else nil
	pooled.coverage = if pooledNonStorm > 0
		then round(pooledFrontSpot / (spotCount * pooledNonStorm), 4)
		else nil
	pooled.frontLineSeconds = round(pooled.frontLineSeconds, 1)
	pooled.lineSeconds = round(pooled.lineSeconds, 1)
	return result
end

local function cell(value: any): string
	if type(value) == "number" then
		return tostring(round(value, 2))
	elseif type(value) == "boolean" then
		return if value then "true" else "false"
	end
	local text = tostring(value)
	if string.find(text, '[,"\n]') then
		text = '"' .. string.gsub(text, '"', '""') .. '"'
	end
	return text
end

-- The log as CSV lines, header first.
function TwistLog.csv(rows: { Row }): { string }
	local lines = { table.concat(TwistLog.COLUMNS, ",") }
	for _, row in rows do
		local cells: { string } = {}
		for _, column in TwistLog.COLUMNS do
			table.insert(cells, cell((row :: any)[column]))
		end
		table.insert(lines, table.concat(cells, ","))
	end
	return lines
end

return TwistLog
