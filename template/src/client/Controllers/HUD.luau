--!strict
-- HUD: currencies (with count-up), active boosts, and the menu buttons. Everything is driven by State.
-- Layout keeps the thumb zones clear on phones: menu on the left edge, currencies top-left.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage.Shared
local Format = require(Shared.Util.Format)

local UI = script.Parent.Parent.UI
local Builder = require(UI.Builder)
local Panels = require(UI.Panels)
local Root = require(UI.Root)
local Theme = require(UI.Theme)

local State = require(script.Parent.State)

local HUD = {}

HUD.buttons = {} :: { [string]: TextButton }

local MENU = {
	{ panel = "shop", text = "Shop", color = Theme.colors.accent },
	{ panel = "pets", text = "Pets", color = Theme.colors.info },
	{ panel = "rebirth", text = "Rebirth", color = Color3.fromRGB(190, 110, 255) },
	{ panel = "daily", text = "Rewards", color = Theme.colors.good },
	{ panel = "settings", text = "Settings", color = Theme.colors.panelLight },
}

local BOOST_NAMES: { [string]: string } =
	{ coins2x = "2x Coins", luck2x = "2x Luck", serverLuck = "Server Luck" }

local badges: { [string]: Frame } = {}
local coinsValue: NumberValue
local gemsValue: NumberValue
local boostLabel: TextLabel

local function pill(parent: Instance, position: UDim2, color: Color3, symbol: string): TextLabel
	local frame = Builder.card({
		Size = UDim2.fromOffset(230, 52),
		Position = position,
		BackgroundColor3 = Theme.colors.panel,
		Parent = parent,
	})
	local icon = Builder.make("Frame", {
		Size = UDim2.fromOffset(40, 40),
		Position = UDim2.fromOffset(6, 6),
		BackgroundColor3 = color,
		Parent = frame,
	}, { Builder.corner(UDim.new(1, 0)), Builder.stroke(2) })
	Builder.label({ Text = symbol, Size = UDim2.fromScale(1, 1), Parent = icon }, 26)
	return Builder.label({
		Text = "0",
		Size = UDim2.new(1, -60, 1, -8),
		Position = UDim2.fromOffset(54, 4),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	}, 32)
end

local function countUp(value: NumberValue, target: number)
	TweenService:Create(value, Theme.motion.countUp, { Value = target }):Play()
end

function HUD.setBadge(panel: string, visible: boolean)
	local badge = badges[panel]
	if badge then
		badge.Visible = visible
	end
end

local function refreshBoosts()
	local parts: { string } = {}
	for _, boost in State.activeBoosts() do
		table.insert(parts, `{BOOST_NAMES[boost.id] or boost.id} {Format.duration(boost.secondsLeft)}`)
	end
	boostLabel.Text = table.concat(parts, "   ")
	boostLabel.Visible = #parts > 0
end

function HUD.init()
	local layer = Root.layer("hud")

	local coinsLabel = pill(layer, UDim2.fromOffset(16, 16), Theme.colors.coins, "C")
	local gemsLabel = pill(layer, UDim2.fromOffset(16, 76), Theme.colors.gems, "G")
	coinsValue = Builder.make("NumberValue", { Parent = coinsLabel })
	gemsValue = Builder.make("NumberValue", { Parent = gemsLabel })
	coinsValue.Changed:Connect(function(value: number)
		coinsLabel.Text = Format.short(value)
	end)
	gemsValue.Changed:Connect(function(value: number)
		gemsLabel.Text = Format.short(value)
	end)

	boostLabel = Builder.label({
		Name = "Boosts",
		Text = "",
		Size = UDim2.fromOffset(420, 30),
		Position = UDim2.fromOffset(18, 134),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Theme.colors.accent,
		Visible = false,
		Parent = layer,
	}, 22)

	local menu = Builder.make("Frame", {
		Name = "Menu",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 16, 0.55, 0),
		Size = UDim2.fromOffset(150, (Theme.touchTarget + 10) * #MENU),
		Parent = layer,
	}, { Builder.list(Enum.FillDirection.Vertical, 10) })
	for index, entry in MENU do
		local button = Builder.button({
			text = entry.text,
			color = entry.color,
			size = UDim2.fromOffset(150, Theme.touchTarget),
			layoutOrder = index,
			parent = menu,
			onClick = function()
				Panels.toggle(entry.panel)
			end,
		})
		HUD.buttons[entry.panel] = button
		badges[entry.panel] = Builder.make("Frame", {
			Name = "Badge",
			Size = UDim2.fromOffset(22, 22),
			Position = UDim2.new(1, -12, 0, -8),
			BackgroundColor3 = Theme.colors.bad,
			Visible = false,
			ZIndex = 3,
			Parent = button,
		}, { Builder.corner(UDim.new(1, 0)), Builder.stroke(2) })
	end
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
		if key == "*" or key == "gems" then
			countUp(gemsValue, data.gems)
		end
		if key == "*" or key == "boosts" or key == "session.serverLuckUntil" then
			refreshBoosts()
		end
	end)
	task.spawn(function()
		while true do
			task.wait(1)
			if State.isReady() then
				refreshBoosts()
			end
		end
	end)
end

return HUD
