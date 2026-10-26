--!strict
-- The prototype weather timetable and Great Storm timing (prototype brief req. 6 and 9; GDD v3.1 §13.2).
-- The state depends only on UTC time (plus the QA offset), so every server agrees. The cycle is 900 s long
-- and starts at each :00, :15, :30 and :45 UTC. Intervals are start-inclusive and end-exclusive.
-- Pure module: Util/WeatherSchedule reads it; nothing here may depend on a server's own state.

local Types = require("../Types")

export type Row = {
	from: number,
	to: number,
	cove_dock: Types.Weather,
	cove_shallows: Types.Weather,
	pier_head: Types.Weather,
}

local Timetable: { Row } = {
	{ from = 0, to = 180, cove_dock = "storm", cove_shallows = "storm", pier_head = "storm" },
	{ from = 180, to = 200, cove_dock = "clear", cove_shallows = "clear", pier_head = "clear" },
	{ from = 200, to = 300, cove_dock = "clear", cove_shallows = "clear", pier_head = "showers" },
	{ from = 300, to = 400, cove_dock = "clear", cove_shallows = "showers", pier_head = "clear" },
	{ from = 400, to = 420, cove_dock = "clear", cove_shallows = "clear", pier_head = "clear" },
	{ from = 420, to = 520, cove_dock = "clear", cove_shallows = "fog", pier_head = "clear" },
	{ from = 520, to = 620, cove_dock = "clear", cove_shallows = "clear", pier_head = "fog" },
	{ from = 620, to = 640, cove_dock = "clear", cove_shallows = "clear", pier_head = "clear" },
	{ from = 640, to = 740, cove_dock = "clear", cove_shallows = "clear", pier_head = "showers" },
	{ from = 740, to = 840, cove_dock = "clear", cove_shallows = "showers", pier_head = "clear" },
	{ from = 840, to = 900, cove_dock = "clear", cove_shallows = "clear", pier_head = "clear" },
}

return table.freeze({
	cycleSeconds = 900,
	spots = { "cove_dock", "cove_shallows", "pier_head" } :: { string },
	timetable = Timetable,

	storm = table.freeze({
		from = 0, -- cycleTime the Great Storm starts
		to = 180, -- and ends
		eye = "pier_head", -- the only spot that fishes as Storm
		approachFrom = 840, -- the storm cloud rolls from StormHome to the eye from here to the cycle end
		forcedSeconds = 180, -- QA forceStorm length
	}),

	-- Lightning (req. 9.2): server-timed, the same for every client.
	flashes = table.freeze({
		minGap = 6,
		maxGap = 9,
		glowSeconds = 0.5, -- glow on the line before each flash
		windowSeconds = 0.8, -- from the flash, a landing tap in here counts as "on a flash"
	}),

	announceLeadSeconds = 60, -- every front arrival is on the Sky Dial at least this far ahead
	maxForceSeconds = 120, -- QA forceWeather limit
})
