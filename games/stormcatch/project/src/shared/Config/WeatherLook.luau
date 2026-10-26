--!strict
-- Lighting presets per weather, stored as data (art direction §6, starting values to tune on phone and PC).
-- The client applies the preset of the weather at the camera and tweens it over `tweenSeconds`.
-- Colours are RGB arrays so this module stays pure. Placeholder visuals budgets: brief req. 6 and
-- art direction §11 (rain rate 60 or less, live only within 150 studs; fog volume radius 30).

export type Preset = {
	clockTime: number,
	brightness: number,
	exposure: number,
	outdoorAmbient: { number },
	ambient: { number },
	saturation: number,
	contrast: number,
	tint: { number },
	bloomIntensity: number,
	bloomThreshold: number,
	atmosphereDensity: number,
	atmosphereHaze: number,
	atmosphereColor: { number },
	atmosphereDecay: { number },
	water: { number },
}

local Presets: { [string]: Preset } = {
	clear = {
		clockTime = 14.5,
		brightness = 2.6,
		exposure = 0,
		outdoorAmbient = { 154, 169, 184 },
		ambient = { 90, 100, 120 },
		saturation = 0.10,
		contrast = 0.05,
		tint = { 255, 248, 238 },
		bloomIntensity = 0.4,
		bloomThreshold = 0.95,
		atmosphereDensity = 0.25,
		atmosphereHaze = 1.0,
		atmosphereColor = { 200, 230, 240 },
		atmosphereDecay = { 143, 191, 216 },
		water = { 63, 159, 176 },
	},
	showers = {
		clockTime = 14.5,
		brightness = 1.8,
		exposure = -0.1,
		outdoorAmbient = { 134, 150, 166 },
		ambient = { 80, 90, 110 },
		saturation = -0.05,
		contrast = 0.05,
		tint = { 242, 246, 255 },
		bloomIntensity = 0.6,
		bloomThreshold = 0.90,
		atmosphereDensity = 0.36,
		atmosphereHaze = 1.8,
		atmosphereColor = { 169, 196, 207 },
		atmosphereDecay = { 110, 140, 154 },
		water = { 78, 143, 163 },
	},
	fog = {
		clockTime = 14.5,
		brightness = 1.5,
		exposure = 0,
		outdoorAmbient = { 167, 174, 173 },
		ambient = { 106, 112, 112 },
		saturation = -0.20,
		contrast = -0.05,
		tint = { 255, 246, 230 },
		bloomIntensity = 0.7,
		bloomThreshold = 0.90,
		atmosphereDensity = 0.55,
		atmosphereHaze = 2.5,
		atmosphereColor = { 212, 217, 210 },
		atmosphereDecay = { 185, 194, 190 },
		water = { 111, 154, 163 },
	},
	storm = {
		clockTime = 17.0,
		brightness = 1.2,
		exposure = -0.25,
		outdoorAmbient = { 110, 127, 160 },
		ambient = { 60, 72, 102 },
		saturation = -0.10,
		contrast = 0.12,
		tint = { 230, 236, 255 },
		bloomIntensity = 0.9,
		bloomThreshold = 0.85,
		atmosphereDensity = 0.42,
		atmosphereHaze = 2.2,
		atmosphereColor = { 93, 110, 140 },
		atmosphereDecay = { 46, 63, 92 },
		water = { 46, 79, 102 },
	},
}

return table.freeze({
	presets = Presets,
	tweenSeconds = 3, -- the storm darkens over 3 s or more (brief req. 9.1)
	stormAudioSwellSeconds = 3.5,
	-- Placeholder front visuals (brief req. 6)
	cloudHeight = 30, -- Showers: a dark translucent cloud 30 studs above the front's cell
	rainRate = 60, -- particles per second, at most 60
	stormRainRate = 30, -- light rain over every spot during the storm
	rainLiveDistance = 150, -- emitters run only while the camera is this close
	rainAreaStuds = 44, -- the rain falls over the front's own cell (a square this wide)
	fogRadius = 30,
	driftSeconds = 4, -- a front's cloud drifts to its next cell over this long
	flashSeconds = 0.15, -- lightning brightness flash
	flashBrightness = 0.3,
})
