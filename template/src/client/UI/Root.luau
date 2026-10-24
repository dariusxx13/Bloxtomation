--!strict
-- The single ScreenGui every controller draws into, with named layers and resolution scaling.
-- Layers (back to front): world-space helpers, hud, panels, overlay (hatch reveal), toasts.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Builder = require(script.Parent.Builder)
local Theme = require(script.Parent.Theme)

local Root = {}

local player = Players.LocalPlayer

local gui: ScreenGui = Builder.make("ScreenGui", {
	Name = "Main",
	ResetOnSpawn = false,
	IgnoreGuiInset = false,
	ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local scaled: Frame = Builder.make("Frame", {
	Name = "Scaled",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(Theme.designSize.X, Theme.designSize.Y),
	Parent = gui,
})
local uiScale: UIScale = Builder.make("UIScale", { Parent = scaled })

Root.gui = gui
Root.scale = 1

local layers: { [string]: Frame } = {}
local LAYER_ORDER = { "hud", "panels", "overlay", "toasts" }
for index, name in LAYER_ORDER do
	layers[name] = Builder.make("Frame", {
		Name = name,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = index,
		Parent = scaled,
	})
end

-- Fits the design canvas into the current viewport (letterboxing the logical canvas, not the screen):
-- the canvas stretches to the viewport aspect so HUD corners stay in the screen corners.
local function fit()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local inset = gui.AbsoluteSize
	local viewport = if inset.X > 0 then inset else camera.ViewportSize
	local scale = math.clamp(
		math.min(viewport.X / Theme.designSize.X, viewport.Y / Theme.designSize.Y),
		Theme.minScale,
		Theme.maxScale
	)
	Root.scale = scale
	uiScale.Scale = scale
	scaled.Size = UDim2.fromOffset(viewport.X / scale, viewport.Y / scale)
end

function Root.layer(name: string): Frame
	local layer = layers[name]
	assert(layer, `unknown UI layer {name}`)
	return layer
end

-- Design-space size of the canvas (use for layout math, e.g. centering).
function Root.canvasSize(): Vector2
	return scaled.AbsoluteSize / Root.scale
end

function Root.mount()
	gui.Parent = player:WaitForChild("PlayerGui")
	fit()
	gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
end

return Root
