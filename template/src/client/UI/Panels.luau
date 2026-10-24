--!strict
-- Modal panels: one open at a time, a dimmed backdrop that closes on tap, open/close motion,
-- and a UiEvent report so the server can count panel opens (funnels, onboarding).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Net = require(ReplicatedStorage.Shared.Net)
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

local Builder = require(script.Parent.Builder)
local Root = require(script.Parent.Root)
local Theme = require(script.Parent.Theme)

export type Panel = {
	name: string,
	frame: Frame,
	content: Frame,
	scale: UIScale,
	title: TextLabel,
}

local Panels = {}

-- (name)
Panels.Opened = Signal.new() :: Signal.Signal<string>
-- (name)
Panels.Closed = Signal.new() :: Signal.Signal<string>

-- Set by the Settings controller; skips scale animations.
Panels.reduceMotion = false

local panels: { [string]: Panel } = {}
local current: string? = nil

-- Panels that report "open" to the server (must match ClientEvents.PANELS on the server).
local REPORTED =
	{ shop = true, pets = true, rebirth = true, daily = true, settings = true, codes = true, index = true }

local backdrop: TextButton = Builder.make("TextButton", {
	Name = "Backdrop",
	Text = "",
	AutoButtonColor = false,
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.55,
	Size = UDim2.fromScale(1, 1),
	Visible = false,
	Parent = Root.layer("panels"),
})

function Panels.create(name: string, titleText: string, size: Vector2): Panel
	local frame: Frame = Builder.make("Frame", {
		Name = name,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.52),
		Size = UDim2.fromOffset(size.X, size.Y),
		BackgroundColor3 = Theme.colors.panel,
		Visible = false,
		ZIndex = 2,
		Parent = Root.layer("panels"),
	}, { Builder.corner(UDim.new(0, 18)), Builder.stroke(3) })
	local scale: UIScale = Builder.make("UIScale", { Parent = frame })
	local title = Builder.label({
		Name = "Title",
		Text = titleText,
		Size = UDim2.new(1, -120, 0, 48),
		Position = UDim2.fromOffset(20, 8),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	}, 36)
	Builder.button({
		text = "X",
		color = Theme.colors.bad,
		size = UDim2.fromOffset(Theme.touchTarget, Theme.touchTarget - 8),
		position = UDim2.new(1, -12, 0, 8),
		anchor = Vector2.new(1, 0),
		parent = frame,
		onClick = function()
			Panels.close()
		end,
	})
	local content: Frame = Builder.make("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 64),
		Size = UDim2.new(1, -32, 1, -80),
		Parent = frame,
	})
	local panel: Panel = { name = name, frame = frame, content = content, scale = scale, title = title }
	panels[name] = panel
	return panel
end

function Panels.isOpen(name: string): boolean
	return current == name
end

function Panels.current(): string?
	return current
end

function Panels.close()
	local name = current
	if not name then
		return
	end
	current = nil
	backdrop.Visible = false
	local panel = panels[name]
	if panel then
		if Panels.reduceMotion then
			panel.frame.Visible = false
		else
			local tween = TweenService:Create(panel.scale, Theme.motion.close, { Scale = 0.85 })
			tween.Completed:Connect(function()
				if current ~= name then
					panel.frame.Visible = false
				end
			end)
			tween:Play()
		end
	end
	Panels.Closed:Fire(name)
end

function Panels.open(name: string)
	local panel = panels[name]
	if not panel or current == name then
		return
	end
	Panels.close()
	current = name
	backdrop.Visible = true
	panel.frame.Visible = true
	if Panels.reduceMotion then
		panel.scale.Scale = 1
	else
		panel.scale.Scale = 0.85
		TweenService:Create(panel.scale, Theme.motion.open, { Scale = 1 }):Play()
	end
	if REPORTED[name] then
		Net.fire("UiEvent", "open", name)
	end
	Panels.Opened:Fire(name)
end

function Panels.toggle(name: string)
	if current == name then
		Panels.close()
	else
		Panels.open(name)
	end
end

backdrop.Activated:Connect(function()
	Panels.close()
end)

return Panels
