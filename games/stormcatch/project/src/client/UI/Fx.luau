--!strict
-- Fx: pooled, client-only feedback (vault: 02-core-loop/game-feel-and-juice.md; art direction §11, §12).
-- Popups ("+N" flying to the coin counter; at most 10 at once), a soft screen flash, a tiny camera shake and a
-- haptic pulse. Shake and flash are off under the reduce-motion setting (and the OS reduced-motion flag).

local GuiService = game:GetService("GuiService")
local HapticService = game:GetService("HapticService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Builder = require(script.Parent.Builder)
local Panels = require(script.Parent.Panels)
local Root = require(script.Parent.Root)
local Theme = require(script.Parent.Theme)

local Fx = {}

local MAX_POPUPS = 10
local FLY_SECONDS = 0.7

local rng = Random.new()

local popups: { TextLabel } = {}
local busy: { [TextLabel]: boolean } = {}
local flashFrame: Frame? = nil

function Fx.reduceMotion(): boolean
	local osReduced = false
	pcall(function()
		osReduced = (GuiService :: any).ReducedMotionEnabled == true
	end)
	return Panels.reduceMotion or osReduced
end

local function popupLayer(): Frame
	return Root.layer("toasts")
end

local function getPopup(): TextLabel?
	for _, label in popups do
		if not busy[label] then
			return label
		end
	end
	if #popups >= MAX_POPUPS then
		return nil
	end
	local label = Builder.label({
		Name = "Popup",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(200, 54),
		TextColor3 = Theme.colors.coins,
		Visible = false,
		ZIndex = 5,
		Parent = popupLayer(),
	}, 46)
	table.insert(popups, label)
	return label
end

-- Design-space point of a world position on screen (nil when behind the camera).
function Fx.worldToDesign(position: Vector3): Vector2?
	local camera = Workspace.CurrentCamera
	if not camera then
		return nil
	end
	local point, onScreen = camera:WorldToViewportPoint(position)
	if not onScreen then
		return nil
	end
	-- Viewport space includes the top bar; GUI space starts below it (GetGuiInset's top-left).
	local topLeft = GuiService:GetGuiInset()
	local layer = popupLayer()
	return (Vector2.new(point.X, point.Y) - topLeft - layer.AbsolutePosition) / Root.scale
end

-- Design-space centre of a GuiObject.
function Fx.guiToDesign(object: GuiObject): Vector2
	local layer = popupLayer()
	return (object.AbsolutePosition + object.AbsoluteSize / 2 - layer.AbsolutePosition) / Root.scale
end

-- "+N" from `from` flying to `target` (the coin counter); calls onArrive when it lands (the counter bump).
function Fx.popup(text: string, color: Color3, from: Vector2, target: GuiObject?, onArrive: (() -> ())?)
	local label = getPopup()
	if not label then
		if onArrive then
			onArrive()
		end
		return
	end
	busy[label] = true
	label.Text = text
	label.TextColor3 = color
	label.TextTransparency = 0
	label.Position = UDim2.fromOffset(from.X, from.Y)
	label.Visible = true
	local rise = TweenService:Create(
		label,
		TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Position = UDim2.fromOffset(from.X, from.Y - 50) }
	)
	rise:Play()
	rise.Completed:Once(function()
		local destination = if target then Fx.guiToDesign(target) else Vector2.new(from.X, from.Y - 120)
		local fly = TweenService:Create(
			label,
			TweenInfo.new(FLY_SECONDS, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Position = UDim2.fromOffset(destination.X, destination.Y), TextTransparency = 0.3 }
		)
		fly:Play()
		fly.Completed:Once(function()
			label.Visible = false
			busy[label] = nil
			if onArrive then
				onArrive()
			end
		end)
	end)
end

-- Soft white flash (Rare and up). Off under reduce motion.
function Fx.flash(strength: number?)
	if Fx.reduceMotion() then
		return
	end
	local frame = flashFrame
	if not frame then
		frame = Builder.make("Frame", {
			Name = "Flash",
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1,
			Parent = Root.layer("overlay"),
		})
		flashFrame = frame
	end
	if frame then
		frame.BackgroundTransparency = 1 - (strength or 0.35)
		TweenService:Create(frame, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
	end
end

-- A tiny camera shake through the humanoid's CameraOffset (Rare and up). Off under reduce motion.
function Fx.shake(magnitude: number?, seconds: number?)
	if Fx.reduceMotion() then
		return
	end
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	local amount = magnitude or 0.18
	local duration = seconds or 0.25
	task.spawn(function()
		local started = os.clock()
		while os.clock() - started < duration do
			local fade = 1 - (os.clock() - started) / duration
			humanoid.CameraOffset =
				Vector3.new(rng:NextNumber(-1, 1) * amount * fade, rng:NextNumber(-1, 1) * amount * fade, 0)
			task.wait()
		end
		humanoid.CameraOffset = Vector3.zero
	end)
end

-- A short vibration where the device supports it (the Sea Fog dip, req. 3.3).
function Fx.haptic(seconds: number?)
	task.spawn(function()
		pcall(function()
			for _, input in { Enum.UserInputType.Gamepad1, Enum.UserInputType.Touch } do
				if
					HapticService:IsVibrationSupported(input)
					and HapticService:IsMotorSupported(input, Enum.VibrationMotor.Large)
				then
					HapticService:SetMotor(input, Enum.VibrationMotor.Large, 0.8)
					task.wait(seconds or 0.25)
					HapticService:SetMotor(input, Enum.VibrationMotor.Large, 0)
					return
				end
			end
		end)
	end)
end

return Fx
