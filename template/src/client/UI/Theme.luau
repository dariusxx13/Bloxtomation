--!strict
-- Visual tokens for the whole UI: one palette, two fonts, one motion vocabulary (vault: 05-ui-and-hud/ui-principles.md).
-- Restyle the game by editing this file, not individual screens.

local Theme = {}

Theme.colors = table.freeze({
	backdrop = Color3.fromRGB(14, 15, 26),
	panel = Color3.fromRGB(32, 35, 58),
	panelLight = Color3.fromRGB(48, 52, 84),
	stroke = Color3.fromRGB(10, 10, 18),
	text = Color3.fromRGB(255, 255, 255),
	textDim = Color3.fromRGB(176, 182, 214),
	accent = Color3.fromRGB(255, 196, 46),
	good = Color3.fromRGB(76, 214, 108),
	bad = Color3.fromRGB(240, 80, 80),
	info = Color3.fromRGB(80, 170, 255),
	coins = Color3.fromRGB(255, 205, 60),
	gems = Color3.fromRGB(90, 230, 255),
	robux = Color3.fromRGB(0, 176, 111),
	disabled = Color3.fromRGB(90, 92, 110),
})

Theme.fonts = table.freeze({
	display = Enum.Font.FredokaOne,
	body = Enum.Font.BuilderSansBold,
})

Theme.motion = table.freeze({
	fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	pop = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	open = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	close = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	countUp = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	float = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
})

Theme.corner = UDim.new(0, 14)

-- The UI is designed at this resolution and scaled with UIScale (clamped) for every screen.
Theme.designSize = Vector2.new(1280, 720)
Theme.minScale = 0.62
Theme.maxScale = 1.35

-- Minimum touch target in design pixels (vault: 08-mobile-and-cross-platform/mobile-first-design.md).
Theme.touchTarget = 56

return Theme
