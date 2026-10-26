--!strict
-- HUD: the coin counter (count-up and bump), the "Better Rod" bar, and the Shop and Settings buttons.
-- Progressive reveal (GDD v3.1 §3.2): spawn shows the Cast button only; the coin counter and Rod bar appear
-- with the first catch; the Shop button when the Rod is affordable (or onboarding reaches step 4). Settings is
-- always there (sound, reduce motion and, in Studio, the QA tools). Everything is driven by State.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage.Shared
local EconomyMath = require(Shared.Util.EconomyMath)
local Format = require(Shared.Util.Format)

local UI = script.Parent.Parent.UI
local Builder = require(UI.Builder)
local Panels = require(UI.Panels)
local Root = require(UI.Root)
local Theme = require(UI.Theme)

local State = require(script.Parent.State)

local HUD = {}

HUD.buttons = {} :: { [string]: TextButton }

local coinsPill: Frame
local coinsValue: NumberValue
local coinsScale: UIScale
local rodBar: Frame
local rodFill: Frame
local rodText: TextLabel
local menu: Frame

local function countUp(value: NumberValue, target: number)
	TweenService:Create(value, Theme.motion.countUp, { Value = target }):Play()
end

-- The coin counter, the target the "+N" popups fly to.
function HUD.coinTarget(): GuiObject
	return coinsPill
end

-- Juice layer 4: the counter scales 1.0 -> 1.15 -> 1.0.
function HUD.bumpCoins()
	coinsScale.Scale = 1.15
	TweenService:Create(coinsScale, Theme.motion.pop, { Scale = 1 }):Play()
end

local function refresh()
	local data = State.data
	if not data then
		return
	end
	local caught = data.stats.catches > 0 or data.coins > 0
	coinsPill.Visible = caught
	rodBar.Visible = caught
	local rod = EconomyMath.upgradeDef("rod")
	local level = data.upgrades.rod or 0
	if rod then
		if level >= rod.maxLevel then
			rodText.Text = "Rod MAX"
			rodFill.Size = UDim2.fromScale(1, 1)
		else
			local cost = EconomyMath.upgradeCost(rod, level)
			local share = math.clamp(data.coins / cost, 0, 1)
			rodText.Text = `Better Rod  {Format.short(math.min(data.coins, cost))}/{Format.short(cost)}`
			TweenService:Create(rodFill, Theme.motion.fast, { Size = UDim2.fromScale(share, 1) }):Play()
			rodFill.BackgroundColor3 = if share >= 1 then Theme.colors.good else Theme.colors.accent
		end
		local affordable = level < rod.maxLevel and data.coins >= EconomyMath.upgradeCost(rod, level)
		HUD.buttons.shop.Visible = affordable or level > 0 or data.onboardingStep >= 4
	end
end

function HUD.init()
	local layer = Root.layer("hud")

	coinsPill = Builder.card({
		Name = "Coins",
		Size = UDim2.fromOffset(230, 52),
		Position = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Theme.colors.panel,
		Visible = false,
		Parent = layer,
	})
	coinsScale = Builder.make("UIScale", { Parent = coinsPill })
	local icon = Builder.make("Frame", {
		Size = UDim2.fromOffset(40, 40),
		Position = UDim2.fromOffset(6, 6),
		BackgroundColor3 = Theme.colors.coins,
		Parent = coinsPill,
	}, { Builder.corner(UDim.new(1, 0)), Builder.stroke(2) })
	Builder.label({ Text = "C", Size = UDim2.fromScale(1, 1), Parent = icon }, 26)
	local coinsLabel = Builder.label({
		Text = "0",
		Size = UDim2.new(1, -60, 1, -8),
		Position = UDim2.fromOffset(54, 4),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = coinsPill,
	}, 32)
	coinsValue = Builder.make("NumberValue", { Parent = coinsLabel })
	coinsValue.Changed:Connect(function(value: number)
		coinsLabel.Text = Format.short(math.floor(value + 0.5))
	end)

	rodBar = Builder.card({
		Name = "RodBar",
		Size = UDim2.fromOffset(230, 30),
		Position = UDim2.fromOffset(16, 74),
		BackgroundColor3 = Theme.colors.panel,
		ClipsDescendants = true,
		Visible = false,
		Parent = layer,
	})
	rodFill = Builder.make("Frame", {
		Name = "Fill",
		BackgroundColor3 = Theme.colors.accent,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0, 1),
		Parent = rodBar,
	}, { Builder.corner() })
	rodText = Builder.label({
		Text = "Better Rod",
		Size = UDim2.new(1, -12, 1, -4),
		Position = UDim2.fromOffset(6, 2),
		ZIndex = 2,
		Parent = rodBar,
	}, 20)

	menu = Builder.make("Frame", {
		Name = "Menu",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 116),
		Size = UDim2.fromOffset(150, (Theme.touchTarget + 10) * 2),
		Parent = layer,
	}, { Builder.list(Enum.FillDirection.Vertical, 10) })
	local entries = {
		{ panel = "shop", text = "Shop", color = Theme.colors.accent },
		{ panel = "settings", text = "Settings", color = Theme.colors.panelLight },
	}
	for index, entry in entries do
		HUD.buttons[entry.panel] = Builder.button({
			text = entry.text,
			color = entry.color,
			size = UDim2.fromOffset(150, Theme.touchTarget),
			layoutOrder = index,
			parent = menu,
			onClick = function()
				Panels.toggle(entry.panel)
			end,
		})
	end
	HUD.buttons.shop.Visible = false
end

function HUD.start()
	State.Changed:Connect(function(key: string)
		local data = State.data
		if not data then
			return
		end
		if key == "*" or key == "coins" then
			countUp(coinsValue, data.coins)
		end
		if key == "*" or key == "coins" or key == "upgrades" or key == "stats" or key == "onboardingStep" then
			refresh()
		end
	end)
end

return HUD
