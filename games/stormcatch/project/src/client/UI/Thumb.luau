--!strict
-- Thumb: where the one big action button (Cast / Reel / Hook / Pull!) sits: bottom right, in the right thumb's
-- zone, above Roblox's jump button and clear of the thumbstick (prototype brief req. 3.1 and the phone layout
-- criterion). Positions are offsets in the UI design space of UI/Root, measured from the canvas's bottom-right
-- corner. When the touch controls exist, the button sits 16 px above the real JumpButton; before they appear it
-- uses Roblox's documented touch layout for the screen size; with no touch at all, 24 px from the corner.

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Root = require(script.Parent.Root)

local Thumb = {}

Thumb.SIZE = 150 -- design px: at least 93 px on screen on every phone (UI/Root never scales below 0.62)
Thumb.ANCHOR = Vector2.new(1, 1)

-- Shared between Reel (the line) and StormHUD (Pull!), so the two buttons never sit on top of each other.
Thumb.lineActive = false
Thumb.pullShown = false

local GAP = 16 -- screen px between the button and the jump button
local EDGE = 24 -- screen px from the canvas edge

local function jumpButton(): GuiObject?
	local gui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local touch = gui and gui:FindFirstChild("TouchGui")
	local frame = touch and touch:FindFirstChild("TouchControlFrame")
	local jump = frame and frame:FindFirstChild("JumpButton")
	if jump and jump:IsA("GuiObject") and jump.Visible and jump.AbsoluteSize.X > 0 then
		return jump
	end
	return nil
end

-- (right, bottom) offsets in design px for the main button's bottom-right corner.
function Thumb.offsets(): (number, number)
	local scale = Root.scale
	local layer = Root.layer("hud")
	local canvasBottomRight = layer.AbsolutePosition + layer.AbsoluteSize
	local jump = jumpButton()
	local rightPx: number
	local bottomPx: number
	if jump then
		local jumpRight = jump.AbsolutePosition.X + jump.AbsoluteSize.X
		rightPx = math.max(EDGE, canvasBottomRight.X - jumpRight)
		bottomPx = canvasBottomRight.Y - jump.AbsolutePosition.Y + GAP
	elseif GuiService.TouchControlsEnabled and UserInputService.TouchEnabled then
		-- Roblox's touch layout: a 70 px jump button 90 px from the bottom on small screens, else 120 px at 210.
		local camera = Workspace.CurrentCamera
		local viewport = if camera then camera.ViewportSize else Vector2.new(1280, 720)
		local small = math.min(viewport.X, viewport.Y) <= 500
		rightPx = if small then 25 else 50
		bottomPx = (if small then 90 else 210) + GAP
	else
		rightPx = EDGE
		bottomPx = EDGE
	end
	return rightPx / scale, bottomPx / scale
end

function Thumb.position(): UDim2
	local right, bottom = Thumb.offsets()
	return UDim2.new(1, -right, 1, -bottom)
end

return Thumb
