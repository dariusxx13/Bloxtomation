--!strict
-- Reel: the moment loop on the client (prototype brief req. 3 and 4). It only draws and requests: the Cast
-- button in the right thumb zone, the bobber and line, each weather's bite signal, the ring (drawn from the
-- server's start time, lap and arc on the shared server clock), the catch card and the juice. The server owns
-- the bite, every roll, the ring judgement and the coins (Systems/Fishing).
-- Signals by weather: Clear and Storm "!" and a splash; Showers a big splash and "!"; Sea Fog no "!": the
-- bobber dips under, a low chime and a vibration, then a Hook! tap within 3 s brings up a faint ring and the
-- fish stays a silhouette until it lands.
-- Juice (vault game-feel layers 1-4 on every catch; Rare and Epic add 5-8): pitched tick and splash sounds,
-- bobber and fish reacting, a "+N" popup flying to the coin counter, the counter bump; particles, a cheer,
-- a tiny camera shake and a soft flash (the last two off under reduce motion).
-- Public: castButton, state(), outOfRange().

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Shared
local Fishing = require(Shared.Config.Fishing)
local Format = require(Shared.Util.Format)
local Net = require(Shared.Net)
local Rarities = require(Shared.Config.Rarities)
local Ring = require(Shared.Util.Ring)
local Types = require(Shared.Types)
local WeatherConfig = require(Shared.Config.Weather)

local UI = script.Parent.Parent.UI
local Builder = require(UI.Builder)
local Fx = require(UI.Fx)
local Panels = require(UI.Panels)
local Root = require(UI.Root)
local Sounds = require(UI.Sounds)
local Theme = require(UI.Theme)
local Thumb = require(UI.Thumb)

local HUD = require(script.Parent.HUD)
local Interact = require(script.Parent.Interact)
local Toasts = require(script.Parent.Toasts)
local Weather = require(script.Parent.Weather)

local Reel = {}

type ReelPhase = "idle" | "casting" | "waiting" | "hooking" | "reeling" | "giant" | "cooldown"

local RING_RADIUS = 92
local DOTS = 48
local GREEN = Color3.fromRGB(76, 214, 108)
local DIM = Color3.fromRGB(176, 182, 214)
local CARD_SECONDS = 2.2
local CARD_SECONDS_RARE = 3.2
local MARK_STYLE: { [string]: { text: string, color: Color3 } } = {
	drizzled = { text = "Drizzled", color = Color3.fromRGB(111, 195, 217) },
	misty = { text = "Misty", color = Color3.fromRGB(230, 236, 234) },
	charged = { text = "CHARGED", color = Color3.fromRGB(255, 196, 46) },
}
local FISH_SIZE: { [string]: number } = { Common = 1.4, Uncommon = 1.8, Rare = 2.4, Epic = 3.2, Mythic = 9 }

local player = Players.LocalPlayer
local rng = Random.new()
local phase: ReelPhase = "idle"
local lineId = 0
local spot: string? = nil
local bite: Types.BitePayload? = nil
local ringParams: Ring.Params? = nil
local stepsDone = 0
local lastTap = 0
local splashFlip = false
local glowUntil = 0

-- UI
local button: TextButton
local ringFrame: Frame
local ringStroke: UIStroke
local dots: { Frame } = {}
local marker: Frame
local silhouette: Frame
local pips: TextLabel
local card: Frame
local cardTitle: TextLabel
local cardDetail: TextLabel
local cardCoins: TextLabel
local cardMark: TextLabel
local cardNew: TextLabel
local cardScale: UIScale
local cardToken = 0

-- World (client-only, pooled)
local folder: Folder
local bobber: Part
local bobberAttachment: Attachment
local splash: ParticleEmitter
local burst: ParticleEmitter
local alert: BillboardGui
local line: Beam
local fish: Part

Reel.castButton = nil :: TextButton?

function Reel.state(): ReelPhase
	return phase
end

function Reel.outOfRange(): boolean
	local nearest = Interact.nearestSpot(Fishing.castRange)
	return nearest == nil
end

local function rarityColor(tier: string): Color3
	local def = Rarities.byId[tier]
	return if def then Builder.rgb(def.color) else Theme.colors.text
end

local function setPhase(value: ReelPhase)
	phase = value
	Thumb.lineActive = value == "waiting" or value == "hooking" or value == "reeling" or value == "giant"
end

-- Bobber and line ----------------------------------------------------------------------------------------

local function rodTip(): Attachment?
	local character = player.Character
	local rod = character and character:FindFirstChild("FishingRod")
	local tip = rod and rod:FindFirstChild("Tip")
	return if tip and tip:IsA("Attachment") then tip else nil
end

local function showBobber(position: Vector3)
	bobber.Position = position
	bobber.Transparency = 0
	line.Attachment0 = rodTip()
	line.Enabled = line.Attachment0 ~= nil
end

local function hideBobber()
	bobber.Transparency = 1
	line.Enabled = false
	alert.Enabled = false
end

local function popBobber(amount: number)
	if Fx.reduceMotion() then
		return
	end
	local base = bobber.Position
	bobber.Position = base + Vector3.new(0, amount, 0)
	TweenService:Create(bobber, Theme.motion.pop, { Position = base }):Play()
end

local function playSplash(pitch: number)
	splashFlip = not splashFlip
	Sounds.play(if splashFlip then "splashA" else "splashB", pitch, 0.10)
end

-- Ring -----------------------------------------------------------------------------------------------------

local function circularDistance(a: number, b: number): number
	local d = math.abs((a - b) % 360)
	return math.min(d, 360 - d)
end

local function paintArc()
	local params = ringParams
	if not params then
		return
	end
	for index, dot in dots do
		local angle = (index - 1) / DOTS * 360
		local onArc = circularDistance(angle, params.arcCenter) <= params.arcWidth / 2
		dot.BackgroundColor3 = if onArc then GREEN else DIM
	end
end

local function showRing(payload: Types.BitePayload, start: number)
	ringParams =
		{ start = start, lap = payload.lap, arcCenter = payload.arcCenter, arcWidth = payload.arcWidth }
	local transparency = 1 - payload.opacity
	for _, dot in dots do
		dot.BackgroundTransparency = transparency
	end
	ringStroke.Transparency = transparency
	-- The tier glow (never in Sea Fog, where the fish stays a mystery until it lands).
	ringStroke.Color = if payload.mode == "fog" then Theme.colors.stroke else rarityColor(payload.tier)
	silhouette.Visible = payload.mode == "fog"
	silhouette.Size = UDim2.fromOffset(34, 18)
	paintArc()
	ringFrame.Visible = true
	-- In Sea Fog the step count would hint at the tier, so only the growing silhouette shows progress.
	pips.Visible = payload.mode ~= "fog"
	pips.Text = `0/{payload.steps}`
end

local function hideRing()
	ringFrame.Visible = false
	ringParams = nil
end

local function updatePips()
	local payload = bite
	if payload then
		pips.Text = `{stepsDone}/{payload.steps}`
	end
end

-- Card and juice ------------------------------------------------------------------------------------------

local function showCard(
	title: string,
	color: Color3,
	detail: string,
	coins: number,
	mark: string?,
	isNew: boolean,
	rare: boolean
)
	cardToken += 1
	local token = cardToken
	cardTitle.Text = title
	cardTitle.TextColor3 = color
	cardDetail.Text = detail
	cardCoins.Text = if coins > 0 then `+{Format.short(coins)} Coins` else ""
	local style = if mark then MARK_STYLE[mark] else nil
	cardMark.Visible = style ~= nil
	if style then
		cardMark.Text = style.text
		cardMark.TextColor3 = style.color
	end
	cardNew.Visible = isNew
	card.Visible = true
	cardScale.Scale = 0.6
	TweenService:Create(cardScale, Theme.motion.pop, { Scale = 1 }):Play()
	task.delay(if rare then CARD_SECONDS_RARE else CARD_SECONDS, function()
		if cardToken == token then
			card.Visible = false
		end
	end)
end

local function leapFish(tier: string, from: Vector3)
	local root = Interact.rootPart()
	local size = FISH_SIZE[tier] or 1.6
	fish.Size = Vector3.new(size * 1.6, size, size)
	fish.Color = rarityColor(tier)
	fish.CFrame = CFrame.new(from)
	fish.Transparency = 0
	local top = from + Vector3.new(0, 6 + size, 0)
	local landing = if root then root.Position + Vector3.new(0, 4 + size / 2, 0) else top
	local up = TweenService:Create(
		fish,
		TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ CFrame = CFrame.new(top) * CFrame.Angles(0, 0, math.rad(40)) }
	)
	up:Play()
	up.Completed:Once(function()
		local over = TweenService:Create(
			fish,
			TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ CFrame = CFrame.new(landing), Transparency = 1 }
		)
		over:Play()
	end)
end

local function cheer()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	local ok, played = pcall(function()
		return humanoid:PlayEmote("cheer")
	end)
	if not ok or played ~= true then
		humanoid.Jump = true
	end
end

local function payJuice(coins: number, color: Color3)
	if coins <= 0 then
		return
	end
	local from = Fx.worldToDesign(bobber.Position + Vector3.new(0, 3, 0)) or Root.canvasSize() / 2
	Fx.popup(`+{Format.short(coins)}`, color, from, HUD.coinTarget(), function()
		HUD.bumpCoins()
		Sounds.play("reward", 1.3, 0.10)
	end)
end

local function onCatch(payload: any)
	if type(payload) ~= "table" or type(payload.species) ~= "string" then
		return
	end
	local result = payload :: Types.CatchPayload
	local color = rarityColor(result.tier)
	if result.kind == "witnessed" then
		showCard(
			`Witnessed: {result.name}`,
			color,
			`{Format.commas(result.kg)} kg`,
			result.coins,
			result.mark,
			false,
			true
		)
		payJuice(result.coins, Theme.colors.coins)
		Sounds.play("reward", 1.1, 0.10)
		return
	end
	if result.lineId ~= lineId then
		return
	end
	local rare = result.tier ~= "Common" and result.tier ~= "Uncommon"
	-- Layers 1-4: splash, fish leap and bobber, popup to the counter, counter bump.
	playSplash(0.5)
	leapFish(result.tier, bobber.Position)
	popBobber(1.2)
	splash:Emit(if rare then 10 else 6)
	payJuice(result.coins, Theme.colors.coins)
	local kg = if result.kg >= 10
		then string.format("%.0f kg", result.kg)
		else string.format("%.1f kg", result.kg)
	showCard(result.name, color, `{result.tier}  ·  {kg}`, result.coins, result.mark, result.isNew, rare)
	-- Layers 5-8 for Rare and up: particles, a cheer, a tiny shake, a soft flash (shake and flash honour
	-- reduce motion).
	if rare then
		burst.Color = ColorSequence.new(color)
		burst:Emit(if result.tier == "Mythic" then 60 else 12)
		cheer()
		Fx.shake(if result.tier == "Mythic" then 0.3 else 0.18)
		Fx.flash(if result.tier == "Mythic" then 0.5 else 0.3)
		Sounds.play("reward", 0.8, 0.05)
	end
	hideRing()
	hideBobber()
	setPhase("cooldown")
	task.delay(Fishing.castCooldown + 0.1, function()
		if phase == "cooldown" then
			setPhase("idle")
		end
	end)
end

-- Server events ----------------------------------------------------------------------------------------

local function onBite(payload: any)
	if type(payload) ~= "table" or payload.lineId ~= lineId then
		return
	end
	local data = payload :: Types.BitePayload
	bite = data
	stepsDone = 0
	lastTap = 0
	if data.mode == "fog" then
		-- No "!". The bobber dips under (large and clear), a low chime, a vibration where supported.
		setPhase("hooking")
		local base = bobber.Position
		TweenService:Create(
			bobber,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = base - Vector3.new(0, 1.4, 0) }
		):Play()
		splash:Emit(4)
		Sounds.play("biteChime", 0.55, 0.05)
		Fx.haptic(0.3)
		hideRing()
		return
	end
	setPhase("reeling")
	alert.Enabled = true
	local big = data.mode == "showers"
	alert.Size = if big then UDim2.fromOffset(90, 90) else UDim2.fromOffset(60, 60)
	splash:Emit(if big then 10 else 5)
	playSplash(if big then 0.45 else 0.7)
	popBobber(if big then 1.4 else 0.8)
	task.delay(0.8, function()
		alert.Enabled = false
	end)
	showRing(data, data.ringStart or Weather.now())
end

local function onReelState(payload: any)
	if type(payload) ~= "table" or payload.lineId ~= lineId then
		return
	end
	local state = payload :: Types.ReelStatePayload
	local current = bite
	if state.event == "hooked" and current then
		setPhase("reeling")
		local base = bobber.Position
		TweenService:Create(bobber, Theme.motion.pop, { Position = base + Vector3.new(0, 1.4, 0) }):Play()
		showRing(current, state.ringStart or Weather.now())
	elseif state.event == "good" then
		stepsDone = state.stepsDone
		local params = ringParams
		if params and state.arcCenter then
			params.arcCenter = state.arcCenter
			paintArc()
		end
		if silhouette.Visible then
			local grow = 34 + 22 * stepsDone
			TweenService:Create(silhouette, Theme.motion.pop, { Size = UDim2.fromOffset(grow, grow * 0.55) })
				:Play()
		end
		updatePips()
	elseif state.event == "miss" then
		-- No red, no X: the ring just keeps going.
		updatePips()
	elseif state.event == "escaped" then
		-- The fish swims off: its silhouette slides away with one small ripple. No cost; Cast is back at once.
		silhouette.Visible = true
		TweenService:Create(silhouette, TweenInfo.new(0.6), { Position = UDim2.new(0.5, 120, 0.5, 0) }):Play()
		splash:Emit(3)
		task.delay(0.6, function()
			silhouette.Position = UDim2.fromScale(0.5, 0.5)
			hideRing()
		end)
		hideBobber()
		setPhase("cooldown")
		task.delay(Fishing.castCooldown + 0.1, function()
			if phase == "cooldown" then
				setPhase("idle")
			end
		end)
	elseif state.event == "nibbled" then
		-- Missed the hook: the fish nibbles off silently and a new bite comes after a fresh wait.
		setPhase("waiting")
		local base = bobber.Position
		TweenService:Create(bobber, Theme.motion.pop, { Position = base + Vector3.new(0, 1.4, 0) }):Play()
	elseif state.event == "giant" then
		setPhase("giant")
		hideRing()
		alert.Enabled = true
		alert.Size = UDim2.fromOffset(110, 110)
		splash:Emit(30)
		playSplash(0.35)
		Fx.shake(0.25, 0.4)
	end
end

-- Input ----------------------------------------------------------------------------------------------------

local function cast()
	local spotId = Interact.nearestSpot(Fishing.castRange)
	if not spotId then
		local nearest = Interact.nearestSpot()
		if nearest then
			Interact.walkTo(nearest)
		end
		return
	end
	setPhase("casting")
	local result = Net.invoke("Cast", spotId)
	if not result.ok or type(result.lineId) ~= "number" then
		setPhase("idle")
		if result.reason == "far" then
			Toasts.show("Walk closer to the ripple", "info")
		end
		return
	end
	lineId = result.lineId
	spot = spotId
	bite = nil
	stepsDone = 0
	setPhase("waiting")
	local ripple = Interact.spotPosition(spotId) or Vector3.zero
	local landing = ripple + Vector3.new(rng:NextNumber(-2, 2), 0.35, rng:NextNumber(-2, 2))
	local tip = rodTip()
	showBobber(if tip then tip.WorldPosition else landing)
	TweenService:Create(
		bobber,
		TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = landing }
	):Play()
	task.delay(0.35, function()
		Sounds.play("click", 0.6, 0.10) -- the plop
		splash:Emit(3)
	end)
end

local function reelTap()
	local now = Weather.now()
	if now - lastTap < Fishing.tapSpacing then
		return
	end
	lastTap = now
	Net.fire("ReelTap")
	-- Instant feedback predicted with the same ring maths; the server's judgement decides the step.
	local params = ringParams
	if params and Ring.judge(params, now, Fishing.latencyExtra) then
		Sounds.play("reelTick", 1.3, 0.10)
		popBobber(0.5)
		marker.Size = UDim2.fromOffset(26, 26)
		TweenService:Create(marker, Theme.motion.pop, { Size = UDim2.fromOffset(20, 20) }):Play()
	else
		Sounds.play("click", 0.55, 0.05)
	end
end

local function onPress()
	if Panels.current() ~= nil then
		Panels.close()
	end
	if phase == "idle" then
		cast()
	elseif phase == "hooking" then
		Net.fire("HookTap")
		Sounds.play("reelTick", 1.1, 0.10)
	elseif phase == "reeling" then
		reelTap()
	end
end

-- Per frame -------------------------------------------------------------------------------------------------

local function buttonText(): (string, boolean)
	if phase == "idle" then
		if Reel.outOfRange() then
			return "Walk to a ripple", true
		end
		return "Cast", true
	elseif phase == "casting" or phase == "waiting" then
		return "Wait...", false
	elseif phase == "hooking" then
		return "Hook!", true
	elseif phase == "reeling" then
		return "Reel!", true
	elseif phase == "giant" then
		return "Pulling!", false
	end
	return "Cast", false
end

local function render()
	local right, bottom = Thumb.offsets()
	button.Position = UDim2.new(1, -right, 1, -bottom)
	-- Pull! replaces Cast for a player with no line out (StormHUD draws it).
	button.Visible = not (Thumb.pullShown and not Thumb.lineActive)
	local text, enabled = buttonText()
	button.Text = text
	Builder.setEnabled(
		button,
		enabled,
		if phase == "reeling" or phase == "hooking" then GREEN else Theme.colors.accent
	)
	ringFrame.Position = UDim2.new(1, -(right + Thumb.SIZE / 2), 1, -(bottom + Thumb.SIZE + 16))
	local params = ringParams
	if params and ringFrame.Visible then
		local angle = math.rad(Ring.markerAngle(params, Weather.now()))
		marker.Position = UDim2.new(0.5, math.sin(angle) * RING_RADIUS, 0.5, -math.cos(angle) * RING_RADIUS)
	end
	-- The line glows gold before and through a storm flash (and is the whole flash under reduce motion).
	line.Color = ColorSequence.new(
		if os.clock() < glowUntil then Theme.colors.accent else Color3.fromRGB(255, 248, 236)
	)
	line.Width0 = if os.clock() < glowUntil then 0.22 else 0.08
	if bobber.Transparency < 1 and not line.Enabled then
		line.Attachment0 = rodTip()
		line.Enabled = line.Attachment0 ~= nil
	end
end

-- Build -----------------------------------------------------------------------------------------------------

local function buildWorld()
	folder = Instance.new("Folder")
	folder.Name = "ReelFx"
	folder.Parent = Workspace
	bobber = Builder.make("Part", {
		Name = "Bobber",
		Shape = Enum.PartType.Ball,
		Size = Vector3.one * 1.4,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		CastShadow = false,
		Material = Enum.Material.SmoothPlastic,
		Color = Color3.fromRGB(255, 248, 236),
		Transparency = 1,
		Parent = folder,
	})
	Builder.make("SelectionSphere", {
		Adornee = bobber,
		Color3 = Color3.fromRGB(255, 122, 89),
		SurfaceColor3 = Color3.fromRGB(24, 32, 58),
		SurfaceTransparency = 1,
		Transparency = 0.4,
		Parent = bobber,
	})
	bobberAttachment = Builder.make("Attachment", { Parent = bobber })
	splash = Builder.make("ParticleEmitter", {
		Name = "Splash",
		Enabled = false,
		Rate = 0,
		Lifetime = NumberRange.new(0.3, 0.5),
		Speed = NumberRange.new(8, 14),
		SpreadAngle = Vector2.new(35, 35),
		Acceleration = Vector3.new(0, -40, 0),
		Size = NumberSequence.new(0.35),
		Color = ColorSequence.new(Color3.fromRGB(168, 220, 209)),
		Transparency = NumberSequence.new(0.2),
		EmissionDirection = Enum.NormalId.Top,
		Parent = bobber,
	})
	burst = Builder.make("ParticleEmitter", {
		Name = "Burst",
		Enabled = false,
		Rate = 0,
		Lifetime = NumberRange.new(0.5, 0.9),
		Speed = NumberRange.new(10, 18),
		SpreadAngle = Vector2.new(180, 180),
		Size = NumberSequence.new(0.5, 0),
		LightEmission = 0.6,
		Parent = bobber,
	})
	alert = Builder.make("BillboardGui", {
		Name = "Alert",
		Size = UDim2.fromOffset(60, 60),
		StudsOffset = Vector3.new(0, 3, 0),
		AlwaysOnTop = true,
		Enabled = false,
		Parent = bobber,
	})
	Builder.label(
		{ Text = "!", Size = UDim2.fromScale(1, 1), TextColor3 = Theme.colors.accent, Parent = alert },
		80
	)
	line = Builder.make("Beam", {
		Name = "Line",
		Attachment1 = bobberAttachment,
		Width0 = 0.08,
		Width1 = 0.05,
		FaceCamera = true,
		LightEmission = 0.4,
		Segments = 6,
		CurveSize0 = 0,
		CurveSize1 = -2,
		Enabled = false,
		Parent = bobber,
	})
	fish = Builder.make("Part", {
		Name = "LeapingFish",
		Shape = Enum.PartType.Ball,
		Size = Vector3.one,
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Material = Enum.Material.SmoothPlastic,
		Transparency = 1,
		Parent = folder,
	})
end

local function buildUi()
	local layer = Root.layer("hud")
	button = Builder.button({
		text = "Cast",
		size = UDim2.fromOffset(Thumb.SIZE, Thumb.SIZE),
		anchor = Thumb.ANCHOR,
		textSize = 40,
		sound = "click",
		parent = layer,
		onClick = onPress,
	})
	button.Name = "CastButton"
	local corner = button:FindFirstChildOfClass("UICorner")
	if corner then
		corner.CornerRadius = UDim.new(1, 0)
	end
	Reel.castButton = button

	local diameter = RING_RADIUS * 2 + 40
	ringFrame = Builder.make("Frame", {
		Name = "Ring",
		AnchorPoint = Vector2.new(0.5, 1),
		Size = UDim2.fromOffset(diameter, diameter),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = layer,
	})
	local backing = Builder.make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(RING_RADIUS * 2 + 24, RING_RADIUS * 2 + 24),
		BackgroundColor3 = Theme.colors.backdrop,
		BackgroundTransparency = 0.65,
		Parent = ringFrame,
	}, { Builder.corner(UDim.new(1, 0)) })
	ringStroke = Builder.make("UIStroke", { Thickness = 4, Color = Theme.colors.stroke, Parent = backing })
	for index = 1, DOTS do
		local angle = math.rad((index - 1) / DOTS * 360)
		dots[index] = Builder.make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, math.sin(angle) * RING_RADIUS, 0.5, -math.cos(angle) * RING_RADIUS),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = DIM,
			Parent = ringFrame,
		}, { Builder.corner(UDim.new(1, 0)) })
	end
	marker = Builder.make("Frame", {
		Name = "Marker",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = Theme.colors.accent,
		ZIndex = 3,
		Parent = ringFrame,
	}, { Builder.corner(UDim.new(1, 0)), Builder.stroke(3) })
	silhouette = Builder.make("Frame", {
		Name = "Silhouette",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(34, 18),
		BackgroundColor3 = Theme.colors.stroke,
		BackgroundTransparency = 0.15,
		Visible = false,
		Parent = ringFrame,
	}, { Builder.corner(UDim.new(1, 0)) })
	pips = Builder.label({
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 1, -18),
		Size = UDim2.fromOffset(160, 26),
		Text = "",
		Parent = ringFrame,
	}, 22)

	card = Builder.card({
		Name = "CatchCard",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.34),
		Size = UDim2.fromOffset(440, 150),
		BackgroundColor3 = Theme.colors.panel,
		Visible = false,
		Parent = Root.layer("overlay"),
	})
	cardScale = Builder.make("UIScale", { Parent = card })
	cardTitle = Builder.label(
		{ Size = UDim2.new(1, -24, 0, 46), Position = UDim2.fromOffset(12, 8), Parent = card },
		40
	)
	cardDetail = Builder.label({
		Size = UDim2.new(1, -24, 0, 30),
		Position = UDim2.fromOffset(12, 56),
		Font = Theme.fonts.body,
		TextColor3 = Theme.colors.textDim,
		Parent = card,
	}, 26)
	cardCoins = Builder.label({
		Size = UDim2.new(0.6, 0, 0, 40),
		Position = UDim2.fromOffset(12, 96),
		TextColor3 = Theme.colors.coins,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	}, 34)
	cardMark = Builder.label({
		AnchorPoint = Vector2.new(1, 0),
		Size = UDim2.fromOffset(160, 36),
		Position = UDim2.new(1, -12, 0, 98),
		Rotation = -6,
		Visible = false,
		Parent = card,
	}, 30)
	cardNew = Builder.label({
		AnchorPoint = Vector2.new(1, 0),
		Size = UDim2.fromOffset(90, 34),
		Position = UDim2.new(1, -8, 0, -14),
		Rotation = 8,
		Text = "NEW!",
		TextColor3 = Theme.colors.accent,
		Visible = false,
		Parent = card,
	}, 32)
end

function Reel.init()
	buildWorld()
	buildUi()
end

function Reel.start()
	Net.on("Bite", onBite)
	Net.on("ReelState", onReelState)
	Net.on("CatchResult", onCatch)
	Weather.FlashSoon:Connect(function(flashAt: number)
		-- Only a line at the eye in a storm reels for Charged.
		if
			spot == WeatherConfig.storm.eye
			and (phase == "reeling" or phase == "waiting" or phase == "hooking")
		then
			glowUntil = os.clock() + (flashAt - Weather.now()) + WeatherConfig.flashes.windowSeconds
		end
	end)
	player.CharacterAdded:Connect(function()
		-- The server keeps the line through a respawn; only the line beam needs the new rod tip.
		line.Enabled = false
	end)
	RunService.RenderStepped:Connect(render)
end

return Reel
