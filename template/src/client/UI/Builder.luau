--!strict
-- Small helpers that build consistent UI from code: every button gets a press pop, a sound and a
-- disabled state; every label is scaled text with a size cap (vault: 05-ui-and-hud/*.md).

local TweenService = game:GetService("TweenService")

local Sounds = require(script.Parent.Sounds)
local Theme = require(script.Parent.Theme)

local Builder = {}

export type Props = { [string]: any }

-- Creates an instance, applies properties (Parent last) and parents children.
-- `children` is an array of instances (typed `any` so mixed lists like { corner, stroke } type-check).
function Builder.make(className: string, props: Props?, children: any): any
	local instance = Instance.new(className :: any)
	local parent = nil
	if props then
		for key, value in props do
			if key == "Parent" then
				parent = value
			else
				(instance :: any)[key] = value
			end
		end
	end
	if children then
		for _, child in children do
			(child :: Instance).Parent = instance
		end
	end
	if parent then
		instance.Parent = parent
	end
	return instance
end

-- Decoration helpers return `Instance` so they mix freely in children lists.
function Builder.corner(radius: UDim?): Instance
	return Builder.make("UICorner", { CornerRadius = radius or Theme.corner })
end

function Builder.stroke(thickness: number?, color: Color3?): Instance
	return Builder.make("UIStroke", {
		Thickness = thickness or 2,
		Color = color or Theme.colors.stroke,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

function Builder.textStroke(thickness: number?): Instance
	return Builder.make("UIStroke", { Thickness = thickness or 2, Color = Theme.colors.stroke })
end

function Builder.padding(pixels: number): Instance
	local p = UDim.new(0, pixels)
	return Builder.make("UIPadding", { PaddingTop = p, PaddingBottom = p, PaddingLeft = p, PaddingRight = p })
end

function Builder.list(
	direction: Enum.FillDirection,
	spacing: number,
	align: Enum.HorizontalAlignment?
): Instance
	return Builder.make("UIListLayout", {
		FillDirection = direction,
		Padding = UDim.new(0, spacing),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	})
end

function Builder.grid(cell: Vector2, spacing: number): Instance
	return Builder.make("UIGridLayout", {
		CellSize = UDim2.fromOffset(cell.X, cell.Y),
		CellPadding = UDim2.fromOffset(spacing, spacing),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
end

-- Scaled text label. `maxSize` caps the text size so it never becomes a billboard on big screens.
function Builder.label(props: Props, maxSize: number?): TextLabel
	local label = Builder.make("TextLabel", {
		BackgroundTransparency = 1,
		Font = Theme.fonts.display,
		TextColor3 = Theme.colors.text,
		TextScaled = true,
		Text = "",
	})
	for key, value in props do
		if key ~= "Parent" then
			(label :: any)[key] = value
		end
	end
	Builder.make("UITextSizeConstraint", { MaxTextSize = maxSize or 28, Parent = label })
	Builder.textStroke(1.5).Parent = label
	if props.Parent then
		label.Parent = props.Parent
	end
	return label
end

export type ButtonOptions = {
	text: string,
	color: Color3?,
	size: UDim2?,
	position: UDim2?,
	anchor: Vector2?,
	textSize: number?,
	layoutOrder: number?,
	sound: string?,
	parent: Instance?,
	onClick: (() -> ())?,
}

local pressScales: { [GuiObject]: UIScale } = {}

-- Animated press feedback for any GuiObject that has a UIScale child created by `Builder.button`.
function Builder.pop(object: GuiObject, amount: number?)
	local scale = pressScales[object]
	if not scale then
		return
	end
	scale.Scale = amount or 0.9
	TweenService:Create(scale, Theme.motion.pop, { Scale = 1 }):Play()
end

function Builder.button(options: ButtonOptions): TextButton
	local button: TextButton = Builder.make("TextButton", {
		Size = options.size or UDim2.fromOffset(160, Theme.touchTarget),
		Position = options.position or UDim2.new(),
		AnchorPoint = options.anchor or Vector2.zero,
		BackgroundColor3 = options.color or Theme.colors.accent,
		AutoButtonColor = false,
		Font = Theme.fonts.display,
		Text = options.text,
		TextColor3 = Theme.colors.text,
		TextScaled = true,
		LayoutOrder = options.layoutOrder or 0,
	}, {
		Builder.corner(),
		Builder.stroke(2.5),
		Builder.padding(6),
		Builder.make("UITextSizeConstraint", { MaxTextSize = options.textSize or 26 }),
	})
	Builder.make("UIStroke", {
		Thickness = 1.5,
		Color = Theme.colors.stroke,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
		Parent = button,
	})
	local scale = Builder.make("UIScale", { Parent = button })
	pressScales[button] = scale
	button.Destroying:Connect(function()
		pressScales[button] = nil
	end)
	button.MouseEnter:Connect(function()
		TweenService:Create(scale, Theme.motion.fast, { Scale = 1.04 }):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(scale, Theme.motion.fast, { Scale = 1 }):Play()
	end)
	button.Activated:Connect(function()
		if button:GetAttribute("Disabled") == true then
			return
		end
		Builder.pop(button)
		Sounds.play(options.sound or "click")
		if options.onClick then
			options.onClick()
		end
	end)
	if options.parent then
		button.Parent = options.parent
	end
	return button
end

-- Disabled buttons stay visible (so players learn what exists) but grey out and ignore presses.
function Builder.setEnabled(button: GuiButton, enabled: boolean, enabledColor: Color3?)
	button:SetAttribute("Disabled", not enabled)
	button.BackgroundColor3 = if enabled then (enabledColor or Theme.colors.accent) else Theme.colors.disabled
end

function Builder.rgb(values: { number }): Color3
	return Color3.fromRGB(values[1], values[2], values[3])
end

-- Rounded panel background
function Builder.card(props: Props): Frame
	local frame = Builder.make("Frame", {
		BackgroundColor3 = Theme.colors.panelLight,
		BorderSizePixel = 0,
	}, { Builder.corner(), Builder.stroke(2) })
	for key, value in props do
		if key ~= "Parent" then
			(frame :: any)[key] = value
		end
	end
	if props.Parent then
		frame.Parent = props.Parent
	end
	return frame
end

return Builder
