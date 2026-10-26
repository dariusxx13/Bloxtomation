--!strict
-- Weather (client): mirrors the server's WeatherState and draws the placeholder weather (prototype brief req. 6
-- and 9.1-9.2; art direction §6, §11). It never decides weather: the server sends the state on every change and
-- this module counts down from server time. Visuals: a weather icon over each spot; a dark cloud with rain over
-- a Showers cell (rain only within 150 studs of the camera, falling over the front's own cell); a grey fog volume
-- (radius 30) over a Sea Fog cell, with Atmosphere raised while the camera is inside; lighting presets tweened
-- over 3 s; the Great Storm's cloud rolling from StormHome to the eye in the last minute, darker lighting, light
-- rain over every spot, the pier lanterns and a storm swell; lightning flashes at the server's flash times.
-- Public: state(), at(spot), now(), scheduleTime(), stormVisible(), Changed, FlashSoon, Flash, bolt().

local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local Signal = require(Shared.Util.Signal)
local Types = require(Shared.Types)
local WeatherConfig = require(Shared.Config.Weather)
local WeatherLook = require(Shared.Config.WeatherLook)
local WorldLayout = require(Shared.Config.WorldLayout)

local UI = script.Parent.Parent.UI
local Builder = require(UI.Builder)
local Fx = require(UI.Fx)
local Sounds = require(UI.Sounds)
local Theme = require(UI.Theme)

local Weather = {}

-- (payload)
Weather.Changed = Signal.new() :: Signal.Signal<Types.WeatherStatePayload>
-- (flashAt) fired glowSeconds before a flash, and at the flash
Weather.FlashSoon = Signal.new() :: Signal.Signal<number>
Weather.Flash = Signal.new() :: Signal.Signal<number>

type FrontKind = "showers" | "fog"
type FrontVisual = { kind: FrontKind, root: Part, rain: ParticleEmitter?, cell: string? }

local FRONT_KINDS: { FrontKind } = { "showers", "fog" }

local ICONS: { [string]: { text: string, color: Color3 } } = {
	clear = { text = "Sun", color = Color3.fromRGB(255, 205, 60) },
	showers = { text = "Rain", color = Color3.fromRGB(111, 195, 217) },
	fog = { text = "Fog", color = Color3.fromRGB(212, 217, 210) },
	storm = { text = "Storm", color = Color3.fromRGB(46, 63, 92) },
}

local current: Types.WeatherStatePayload? = nil
local pullsActive = false
local folder: Folder
local icons: { [string]: { frame: Frame, label: TextLabel } } = {}
local visuals: { FrontVisual } = {}
local stormRain: { ParticleEmitter } = {}
local stormCloud: Model
local stormCloudParts: { BasePart } = {}
local stormSwell: Sound? = nil
local atmosphere: Atmosphere
local colorCorrection: ColorCorrectionEffect
local bloom: BloomEffect
local appliedPreset = ""
local stormShown = false

local function vec(values: { number }): Vector3
	return Vector3.new(values[1], values[2], values[3])
end

local function rgb(values: { number }): Color3
	return Color3.fromRGB(values[1], values[2], values[3])
end

local cellCentres: { [string]: Vector3 } = {}
for _, spec in WorldLayout.spots do
	cellCentres[spec.id] = (vec(spec.stand) + vec(spec.ripple)) / 2
end
local EYE = cellCentres[WeatherConfig.storm.eye] + Vector3.new(0, WorldLayout.eyeHeight, 0)
local STORM_HOME = vec(WorldLayout.stormHome) + Vector3.new(0, 40, 0)

function Weather.now(): number
	return Workspace:GetServerTimeNow()
end

function Weather.state(): Types.WeatherStatePayload?
	return current
end

-- Timetable time (server time + the QA offset), for countdown maths with Util/WeatherSchedule.
function Weather.scheduleTime(): number
	local state = current
	return Weather.now() + (if state then state.offset else 0)
end

function Weather.at(spot: string): Types.Weather
	local state = current
	return if state and state.spots[spot] then state.spots[spot] else "clear"
end

-- True while the storm is on or a giant is still being pulled (the storm lingers over the pier).
function Weather.stormVisible(): boolean
	local state = current
	return (state ~= nil and state.storm.active and Weather.now() < state.storm.endsAt) or pullsActive
end

function Weather.setPullsActive(active: boolean)
	pullsActive = active
end

-- The nearest cell to a position within the cell radius (horizontal plane).
local function cellAt(position: Vector3): string?
	local best: string? = nil
	local bestDistance = WorldLayout.cellRadius
	for id, centre in cellCentres do
		local distance = Vector2.new(position.X - centre.X, position.Z - centre.Z).Magnitude
		if distance <= bestDistance then
			best = id
			bestDistance = distance
		end
	end
	return best
end

local function makePart(name: string, props: { [string]: any }): Part
	local part: Part = Builder.make("Part", {
		Name = name,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		CastShadow = false,
		Material = Enum.Material.SmoothPlastic,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
	})
	for key, value in props do
		(part :: any)[key] = value
	end
	part.Parent = folder
	return part
end

local function rainEmitter(parent: BasePart, rate: number): ParticleEmitter
	return Builder.make("ParticleEmitter", {
		Name = "Rain",
		EmissionDirection = Enum.NormalId.Bottom,
		Rate = rate,
		Lifetime = NumberRange.new(0.45, 0.55),
		Speed = NumberRange.new(55, 60),
		Size = NumberSequence.new(0.12),
		Color = ColorSequence.new(rgb(WorldLayout.colors.seafoam)),
		Transparency = NumberSequence.new(0.35),
		LightEmission = 0.2,
		Squash = NumberSequence.new(3),
		Enabled = false,
		Parent = parent,
	})
end

local function newVisual(kind: FrontKind): FrontVisual
	if kind == "showers" then
		-- The cloud's bottom face is the rain area: drops fall over the front's own cell, never around a
		-- camera standing outside it.
		local root = makePart("ShowersCloud", {
			Size = Vector3.new(WeatherLook.rainAreaStuds, 6, WeatherLook.rainAreaStuds),
			Color = rgb(WorldLayout.colors.stormSlate),
			Transparency = 1,
		})
		return { kind = kind, root = root, rain = rainEmitter(root, WeatherLook.rainRate), cell = nil }
	end
	local root = makePart("FogVolume", {
		Shape = Enum.PartType.Ball,
		Size = Vector3.one * WeatherLook.fogRadius * 2,
		Color = Color3.fromRGB(212, 217, 210),
		Transparency = 1,
	})
	return { kind = kind, root = root, rain = nil, cell = nil }
end

local function visualTarget(visual: FrontVisual, cell: string): Vector3
	local centre = cellCentres[cell]
	if visual.kind == "showers" then
		return centre + Vector3.new(0, WeatherLook.cloudHeight, 0)
	end
	return Vector3.new(centre.X, 4, centre.Z)
end

local function entryPoint(kind: FrontKind): Vector3
	if kind == "showers" then
		return vec(WorldLayout.showersEntry) + Vector3.new(0, WeatherLook.cloudHeight, 0)
	end
	return vec(WorldLayout.fogBank) + Vector3.new(0, 4, 0)
end

local function shownTransparency(kind: FrontKind): number
	return if kind == "showers" then 0.35 else 0.55
end

-- Moves front visuals to the cells now under each front: drift from the old cell, or in from the entry.
local function updateFronts(state: Types.WeatherStatePayload)
	local tween = TweenInfo.new(WeatherLook.driftSeconds, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	for index = 1, #FRONT_KINDS do
		local kind: FrontKind = FRONT_KINDS[index]
		local wanted: { string } = {}
		for _, spot in WeatherConfig.spots do
			if state.spots[spot] == kind then
				table.insert(wanted, spot)
			end
		end
		local free: { FrontVisual } = {}
		local placed: { [string]: boolean } = {}
		for _, visual in visuals do
			if visual.kind == kind then
				if visual.cell and table.find(wanted, visual.cell) then
					placed[visual.cell] = true
				else
					table.insert(free, visual)
				end
			end
		end
		for _, cell in wanted do
			if not placed[cell] then
				local reused: FrontVisual? = table.remove(free, 1)
				local visual: FrontVisual
				if reused then
					visual = reused
					if visual.cell == nil then
						visual.root.Position = entryPoint(kind)
					end
				else
					visual = newVisual(kind)
					table.insert(visuals, visual)
					visual.root.Position = entryPoint(kind)
				end
				local target = visualTarget(visual, cell)
				visual.cell = cell
				TweenService:Create(visual.root, tween, {
					Position = target,
					Transparency = shownTransparency(kind),
				}):Play()
			end
		end
		for _, visual in free do
			if visual.cell ~= nil then
				visual.cell = nil
				TweenService:Create(visual.root, TweenInfo.new(3), { Transparency = 1 }):Play()
			end
		end
	end
end

local function updateIcons(state: Types.WeatherStatePayload)
	for spot, icon in icons do
		local weather = state.spots[spot] or "clear"
		local look = ICONS[weather] or ICONS.clear
		icon.frame.BackgroundColor3 = look.color
		icon.label.Text = look.text
		icon.label.TextColor3 = if weather == "storm" then Theme.colors.text else Theme.colors.stroke
	end
end

local function applyPreset(name: string)
	if appliedPreset == name then
		return
	end
	appliedPreset = name
	local preset = WeatherLook.presets[name] or WeatherLook.presets.clear
	local info = TweenInfo.new(WeatherLook.tweenSeconds, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	TweenService:Create(Lighting, info, {
		ClockTime = preset.clockTime,
		Brightness = preset.brightness,
		ExposureCompensation = preset.exposure,
		OutdoorAmbient = rgb(preset.outdoorAmbient),
		Ambient = rgb(preset.ambient),
	}):Play()
	TweenService:Create(atmosphere, info, {
		Density = preset.atmosphereDensity,
		Haze = preset.atmosphereHaze,
		Color = rgb(preset.atmosphereColor),
		Decay = rgb(preset.atmosphereDecay),
	}):Play()
	TweenService:Create(colorCorrection, info, {
		Saturation = preset.saturation,
		Contrast = preset.contrast,
		TintColor = rgb(preset.tint),
	}):Play()
	TweenService:Create(bloom, info, { Intensity = preset.bloomIntensity, Threshold = preset.bloomThreshold })
		:Play()
	TweenService:Create(Workspace.Terrain, info, { WaterColor = rgb(preset.water) }):Play()
end

local function setLanterns(on: boolean)
	for _, lantern in CollectionService:GetTagged("PierLantern") do
		local light = lantern:FindFirstChildOfClass("PointLight")
		if light then
			light.Enabled = on
		end
	end
end

local function setStorm(on: boolean)
	if stormShown == on then
		return
	end
	stormShown = on
	setLanterns(on)
	for _, emitter in stormRain do
		emitter.Enabled = on
	end
	local swell = stormSwell
	if swell then
		if on then
			if Sounds.enabled then
				swell:Play()
			end
			TweenService:Create(swell, TweenInfo.new(WeatherLook.stormAudioSwellSeconds), { Volume = 0.35 })
				:Play()
		else
			local fade = TweenService:Create(swell, TweenInfo.new(4), { Volume = 0 })
			fade:Play()
			fade.Completed:Once(function()
				if not stormShown then
					swell:Stop()
				end
			end)
		end
	end
end

-- Storm cloud position: home, rolling in over cycleTime 840-900, at the eye during the storm and any pull,
-- rolling home over the first minute after it.
local function stormCloudPosition(): (Vector3, number)
	if Weather.stormVisible() then
		return EYE, 0.1
	end
	local ct = Weather.scheduleTime() % WeatherConfig.cycleSeconds
	local approach = WeatherConfig.storm.approachFrom
	if ct >= approach then
		local alpha = (ct - approach) / (WeatherConfig.cycleSeconds - approach)
		return STORM_HOME:Lerp(EYE, alpha), 0.1
	end
	local after = ct - WeatherConfig.storm.to
	if after >= 0 and after < 60 then
		return EYE:Lerp(STORM_HOME, after / 60), 0.1 + 0.9 * (after / 60)
	end
	return STORM_HOME, 1
end

local function moveStormCloud()
	local position, transparency = stormCloudPosition()
	stormCloud:PivotTo(CFrame.new(position))
	for _, part in stormCloudParts do
		part.Transparency = transparency
	end
end

-- Rain emitters run only near the camera; the preset follows the weather at the camera's cell.
local function perFrame()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local cameraPosition = camera.CFrame.Position
	for _, visual in visuals do
		local rain = visual.rain
		if rain then
			local live = visual.cell ~= nil
				and (visual.root.Position - cameraPosition).Magnitude <= WeatherLook.rainLiveDistance
			rain.Enabled = live
		end
	end
	moveStormCloud()
	local storming = Weather.stormVisible()
	setStorm(storming)
	if storming then
		applyPreset("storm")
	else
		local cell = cellAt(cameraPosition)
		local weather = if cell then Weather.at(cell) else "clear"
		local ct = Weather.scheduleTime() % WeatherConfig.cycleSeconds
		if weather == "clear" and ct >= WeatherConfig.storm.approachFrom then
			applyPreset("showers") -- the sky darkens toward the storm
		else
			applyPreset(if weather == "showers" or weather == "fog" then weather else "clear")
		end
	end
end

-- A lightning bolt from the storm cloud to `target` (gold, 0.15 s). Half opacity under reduce motion.
function Weather.bolt(target: Vector3)
	local from = EYE + Vector3.new(0, -8, 0)
	local length = (from - target).Magnitude
	local bolt = makePart("Bolt", {
		Size = Vector3.new(0.6, 0.6, length),
		CFrame = CFrame.lookAt((from + target) / 2, target),
		Material = Enum.Material.Neon,
		Color = Color3.fromRGB(255, 196, 46),
		Transparency = if Fx.reduceMotion() then 0.5 else 0,
	})
	task.delay(WeatherLook.flashSeconds, function()
		bolt:Destroy()
	end)
end

local function onFlash(flashAt: number)
	Weather.Flash:Fire(flashAt)
	if Fx.reduceMotion() then
		Sounds.play("rumble", 0.35, 0.05)
		return
	end
	colorCorrection.Brightness = WeatherLook.flashBrightness
	TweenService:Create(colorCorrection, TweenInfo.new(WeatherLook.flashSeconds), { Brightness = 0 }):Play()
	Weather.bolt(EYE + Vector3.new(30, -EYE.Y, -20))
	Sounds.play("rumble", 0.4, 0.05)
end

local function onStormState(payload: any)
	if type(payload) ~= "table" or type(payload.flashAt) ~= "number" then
		return
	end
	local flashAt = payload.flashAt :: number
	local glowAt = flashAt - WeatherConfig.flashes.glowSeconds
	task.delay(math.max(0, glowAt - Weather.now()), function()
		Weather.FlashSoon:Fire(flashAt)
	end)
	task.delay(math.max(0, flashAt - Weather.now()), function()
		if Weather.stormVisible() then
			onFlash(flashAt)
		end
	end)
end

local function onWeatherState(payload: any)
	if type(payload) ~= "table" or type(payload.spots) ~= "table" or type(payload.storm) ~= "table" then
		return
	end
	local state = payload :: Types.WeatherStatePayload
	current = state
	updateIcons(state)
	updateFronts(state)
	Weather.Changed:Fire(state)
end

local function buildIcons()
	for _, spec in WorldLayout.spots do
		local anchor = makePart(`Icon_{spec.id}`, {
			Size = Vector3.one,
			Transparency = 1,
			Position = vec(spec.ripple) + Vector3.new(0, 13, 0),
		})
		local billboard: BillboardGui = Builder.make("BillboardGui", {
			Size = UDim2.fromOffset(84, 40),
			MaxDistance = 220,
			LightInfluence = 0,
			AlwaysOnTop = false,
			Parent = anchor,
		})
		local frame: Frame = Builder.make("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = ICONS.clear.color,
			Parent = billboard,
		}, { Builder.corner(UDim.new(1, 0)), Builder.stroke(3, Theme.colors.stroke) })
		local label = Builder.label({
			Text = "Sun",
			Size = UDim2.fromScale(1, 1),
			TextColor3 = Theme.colors.stroke,
			Parent = frame,
		}, 26)
		icons[spec.id] = { frame = frame, label = label }
	end
end

local function buildStorm()
	stormCloud = Instance.new("Model")
	stormCloud.Name = "GreatStormCloud"
	local shapes = {
		{ Vector3.new(0, 0, 0), Vector3.new(60, 16, 44) },
		{ Vector3.new(-22, 6, 10), Vector3.new(34, 18, 30) },
		{ Vector3.new(24, 4, -8), Vector3.new(36, 16, 30) },
	}
	for index, shape in shapes do
		local part = makePart(`StormCloud{index}`, {
			Size = shape[2],
			Color = rgb(if index == 1 then WorldLayout.colors.nightInk else WorldLayout.colors.stormSlate),
			Transparency = 1,
		})
		part.Position = shape[1]
		part.Parent = stormCloud
		table.insert(stormCloudParts, part)
		if index == 1 then
			stormCloud.PrimaryPart = part
		end
	end
	-- The warm eye halo (art direction §6): a ring of light in the clouds over the Open Pier.
	local halo = makePart("EyeHalo", {
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.5, 26, 26),
		Material = Enum.Material.Neon,
		Color = Color3.fromRGB(255, 210, 122),
		Transparency = 1,
	})
	halo.CFrame = CFrame.new(0, -8.5, 0) * CFrame.Angles(0, 0, math.rad(90))
	halo.Parent = stormCloud
	table.insert(stormCloudParts, halo)
	stormCloud.Parent = folder
	for _, spec in WorldLayout.spots do
		local area = makePart(`StormRain_{spec.id}`, {
			Size = Vector3.new(WeatherLook.rainAreaStuds, 1, WeatherLook.rainAreaStuds),
			Transparency = 1,
			Position = cellCentres[spec.id] + Vector3.new(0, WeatherLook.cloudHeight, 0),
		})
		table.insert(stormRain, rainEmitter(area, WeatherLook.stormRainRate))
	end
	stormSwell = Sounds.loop("storm", 0.3)
end

local function ensureLightingObjects()
	local existing = Lighting:FindFirstChildOfClass("Atmosphere")
	atmosphere = if existing then existing else Builder.make("Atmosphere", { Parent = Lighting })
	colorCorrection = Builder.make("ColorCorrectionEffect", { Name = "WeatherColor", Parent = Lighting })
	bloom = Builder.make("BloomEffect", { Name = "WeatherBloom", Size = 24, Parent = Lighting })
end

function Weather.init()
	folder = Instance.new("Folder")
	folder.Name = "WeatherFx"
	folder.Parent = Workspace
	ensureLightingObjects()
	buildIcons()
	buildStorm()
	applyPreset("clear")
	Net.on("WeatherState", onWeatherState)
	Net.on("StormState", onStormState)
end

function Weather.start()
	RunService.RenderStepped:Connect(perFrame)
end

return Weather
