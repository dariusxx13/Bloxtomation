--!strict
-- Guide: shows the next onboarding step as a hint plus a pointer: a beam to world targets
-- (nodes, eggs, gates) or a pulsing outline on UI targets (buttons)
-- (vault: 01-first-five-minutes/onboarding-patterns.md). Steps come from Config/Onboarding.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local OnboardingConfig = require(ReplicatedStorage.Shared.Config.Onboarding)

local UI = script.Parent.Parent.UI
local Builder = require(UI.Builder)
local Panels = require(UI.Panels)
local Root = require(UI.Root)
local Theme = require(UI.Theme)

local Gates = require(script.Parent.Gates)
local HUD = require(script.Parent.HUD)
local Interact = require(script.Parent.Interact)
local PetsPanel = require(script.Parent.PetsPanel)
local Shop = require(script.Parent.Shop)
local State = require(script.Parent.State)

local Guide = {}

local UPDATE_SECONDS = 0.4

local player = Players.LocalPlayer
local hint: TextLabel
local beam: Beam
local targetAttachment: Attachment
local anchorPart: Part
local outline: UIStroke
local outlinedButton: GuiObject? = nil
local pulse: Tween? = nil

local function nearestEggStand(): BasePart?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local data = State.data
	if not root or not root:IsA("BasePart") or not data then
		return nil
	end
	local best: BasePart? = nil
	local bestDistance = math.huge
	for _, stand in CollectionService:GetTagged("EggStand") do
		local zoneId = stand:GetAttribute("ZoneId")
		if stand:IsA("BasePart") and type(zoneId) == "string" and data.zonesUnlocked[zoneId] then
			local distance = (stand.Position - root.Position).Magnitude
			if distance < bestDistance then
				best = stand
				bestDistance = distance
			end
		end
	end
	return best
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

local function setWorldTarget(part: BasePart?)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local rootAttachment = root and root:FindFirstChild("RootAttachment")
	if part and rootAttachment and rootAttachment:IsA("Attachment") then
		anchorPart.Position = part.Position + Vector3.new(0, part.Size.Y / 2 + 1, 0)
		beam.Attachment0 = rootAttachment
		beam.Enabled = true
	else
		beam.Enabled = false
	end
end

local function update()
	local data = State.data
	if not data then
		return
	end
	local stepDef = OnboardingConfig.steps[data.onboardingStep + 1]
	local guide = if stepDef then stepDef.guide else "none"
	hint.Visible = stepDef ~= nil and stepDef.hint ~= "" and Panels.current() ~= "hatch"
	hint.Text = if stepDef then stepDef.hint else ""

	local worldTarget: BasePart? = nil
	local uiTarget: GuiObject? = nil
	if guide == "node" then
		worldTarget = Interact.nearestUsableNode()
	elseif guide == "egg" then
		worldTarget = nearestEggStand()
	elseif guide == "gate" then
		worldTarget = Gates.nextGate()
	elseif guide == "shop" then
		uiTarget = HUD.buttons.shop
	elseif guide == "upgradePower" then
		uiTarget = if Panels.isOpen("shop") then Shop.upgradeButtons.power else HUD.buttons.shop
	elseif guide == "pets" then
		uiTarget = if Panels.isOpen("pets") then PetsPanel.equipBestButton else HUD.buttons.pets
	end
	if Panels.current() ~= nil then
		worldTarget = nil
	end
	setWorldTarget(worldTarget)
	setOutline(uiTarget)
end

function Guide.init()
	hint = Builder.label({
		Name = "GuideHint",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -24),
		Size = UDim2.fromOffset(560, 52),
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
