--!strict
-- Guide: shows the next onboarding step as a hint plus a pointer: a beam to a world target (a spot) or a
-- pulsing outline on a button (vault: 01-first-five-minutes/onboarding-patterns.md; prototype brief req. 10).
-- Guide kinds: node (the nearest spot, and the Cast button), shop, upgradePower (the Rod's buy button) and
-- weather (the spot under Showers now, or the next one due, with its ETA). Whatever the step, while no spot is
-- in cast range the beam points to the nearest spot (req. 3.1). A profile past step 7 shows no hint.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Shared
local OnboardingConfig = require(Shared.Config.Onboarding)
local WeatherConfig = require(Shared.Config.Weather)

local UI = script.Parent.Parent.UI
local Builder = require(UI.Builder)
local Panels = require(UI.Panels)
local Root = require(UI.Root)
local Theme = require(UI.Theme)

local HUD = require(script.Parent.HUD)
local Interact = require(script.Parent.Interact)
local Reel = require(script.Parent.Reel)
local Shop = require(script.Parent.Shop)
local State = require(script.Parent.State)
local Weather = require(script.Parent.Weather)

local Guide = {}

local UPDATE_SECONDS = 0.25

local player = Players.LocalPlayer
local hint: TextLabel
local beam: Beam
local targetAttachment: Attachment
local anchorPart: Part
local outline: UIStroke
local outlinedButton: GuiObject? = nil
local pulse: Tween? = nil

local function clock(seconds: number): string
	local s = math.max(0, math.floor(seconds))
	return string.format("%d:%02d", s // 60, s % 60)
end

local function setOutline(target: GuiObject?)
	if outlinedButton == target then
		return
	end
	outlinedButton = target
	if pulse then
		pulse:Cancel()
		pulse = nil
	end
	if target then
		outline.Parent = target
		outline.Thickness = 3
		local tween = TweenService:Create(
			outline,
			TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Thickness = 7 }
		)
		tween:Play()
		pulse = tween
	else
		outline.Parent = nil
	end
end

local function setWorldTarget(position: Vector3?)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local rootAttachment = root and root:FindFirstChild("RootAttachment")
	if position and rootAttachment and rootAttachment:IsA("Attachment") then
		anchorPart.Position = position + Vector3.new(0, 1, 0)
		beam.Attachment0 = rootAttachment
		beam.Enabled = true
	else
		beam.Enabled = false
	end
end

-- The spot under Showers now, or the next Showers arrival, and the seconds until it (0 if now).
local function rainTarget(): (string?, number)
	local state = Weather.state()
	if not state then
		return nil, 0
	end
	for _, spot in WeatherConfig.spots do
		if state.spots[spot] == "showers" then
			return spot, 0
		end
	end
	local now = Weather.now()
	for _, arrival in state.arrivals do
		if arrival.weather == "showers" and arrival.at > now then
			return arrival.spot, arrival.at - now
		end
	end
	return nil, 0
end

local function update()
	local data = State.data
	if not data then
		return
	end
	local stepDef = OnboardingConfig.steps[data.onboardingStep + 1]
	local guide = if stepDef then stepDef.guide else "none"
	local hintText = if stepDef then stepDef.hint else ""

	local worldTarget: Vector3? = nil
	local uiTarget: GuiObject? = nil
	if guide == "node" then
		local spot = Interact.nearestSpot()
		worldTarget = if spot then Interact.spotPosition(spot) else nil
		uiTarget = Reel.castButton
	elseif guide == "shop" then
		uiTarget = HUD.buttons.shop
	elseif guide == "upgradePower" then
		uiTarget = if Panels.isOpen("shop")
			then Shop.upgradeButtons[OnboardingConfig.upgradeForStep6]
			else HUD.buttons.shop
	elseif guide == "weather" then
		local spot, eta = rainTarget()
		if spot then
			worldTarget = Interact.spotPosition(spot)
			if eta > 0 then
				hintText = `{hintText} Rain at {Interact.spotName(spot)} in {clock(eta)}`
			end
		end
	end
	-- Out of cast range with nothing on the line: point at the nearest ripple whatever the step.
	if worldTarget == nil and Reel.state() == "idle" and Reel.outOfRange() then
		local spot = Interact.nearestSpot()
		worldTarget = if spot then Interact.spotPosition(spot) else nil
	end
	if Panels.current() ~= nil then
		worldTarget = nil
	end
	hint.Visible = hintText ~= "" and Panels.current() == nil
	hint.Text = hintText
	setWorldTarget(worldTarget)
	setOutline(uiTarget)
end

function Guide.init()
	hint = Builder.label({
		Name = "GuideHint",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -24),
		Size = UDim2.fromOffset(620, 52),
		TextColor3 = Theme.colors.accent,
		Visible = false,
		Parent = Root.layer("hud"),
	}, 36)
	outline = Builder.make("UIStroke", {
		Name = "GuideOutline",
		Color = Theme.colors.accent,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
	anchorPart = Builder.make("Part", {
		Name = "GuideTarget",
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Transparency = 1,
		Size = Vector3.one,
		Parent = Workspace,
	})
	targetAttachment = Builder.make("Attachment", { Parent = anchorPart })
	beam = Builder.make("Beam", {
		Attachment1 = targetAttachment,
		Color = ColorSequence.new(Theme.colors.accent),
		Width0 = 0.6,
		Width1 = 0.6,
		FaceCamera = true,
		LightEmission = 1,
		Transparency = NumberSequence.new(0.2),
		Enabled = false,
		Parent = anchorPart,
	})
end

function Guide.start()
	task.spawn(function()
		while true do
			task.wait(UPDATE_SECONDS)
			update()
		end
	end)
end

return Guide
