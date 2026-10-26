--!strict
-- Shop: the Upgrades list only (prototype brief req. 1 and 8): the Rod, bought with coins at a price from
-- server config. The prototype sells nothing, so this panel has no other tab.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local EconomyMath = require(Shared.Util.EconomyMath)
local Format = require(Shared.Util.Format)
local Net = require(Shared.Net)
local UpgradeConfig = require(Shared.Config.Upgrades)

local UI = script.Parent.Parent.UI
local Builder = require(UI.Builder)
local Panels = require(UI.Panels)
local Theme = require(UI.Theme)

local State = require(script.Parent.State)
local Toasts = require(script.Parent.Toasts)

local Shop = {}

type Row = { frame: Frame, title: TextLabel, subtitle: TextLabel, button: TextButton }

local list: ScrollingFrame
local upgradeRows: { [string]: Row } = {}

-- Exposed so the onboarding guide can point at the Rod's buy button.
Shop.upgradeButtons = {} :: { [string]: TextButton }

local function row(order: number): Row
	local frame = Builder.card({
		Size = UDim2.new(1, -12, 0, 84),
		LayoutOrder = order,
		Parent = list,
	})
	local title = Builder.label({
		Size = UDim2.new(1, -230, 0, 36),
		Position = UDim2.fromOffset(14, 6),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	}, 28)
	local subtitle = Builder.label({
		Size = UDim2.new(1, -230, 0, 30),
		Position = UDim2.fromOffset(14, 44),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Theme.colors.textDim,
		Font = Theme.fonts.body,
		Parent = frame,
	}, 20)
	local button = Builder.button({
		text = "",
		color = Theme.colors.good,
		size = UDim2.fromOffset(200, 60),
		position = UDim2.new(1, -12, 0.5, 0),
		anchor = Vector2.new(1, 0.5),
		parent = frame,
	})
	return { frame = frame, title = title, subtitle = subtitle, button = button }
end

local function refreshUpgrades()
	local data = State.data
	if not data then
		return
	end
	for _, def in UpgradeConfig do
		local entry = upgradeRows[def.id]
		if entry then
			local level = data.upgrades[def.id] or 0
			entry.title.Text = `{def.name}  Lv {level}/{def.maxLevel}`
			if level >= def.maxLevel then
				entry.button.Text = "MAX"
				Builder.setEnabled(entry.button, false)
			else
				local cost = EconomyMath.upgradeCost(def, level)
				entry.button.Text = `{Format.short(cost)} Coins`
				Builder.setEnabled(entry.button, data.coins >= cost, Theme.colors.good)
			end
		end
	end
end

local function build()
	for index, def in UpgradeConfig do
		local entry = row(index)
		entry.subtitle.Text = `{def.description} (x{def.effect} coins per fish each level)`
		entry.button.Activated:Connect(function()
			if entry.button:GetAttribute("Disabled") then
				return
			end
			local result = Net.invoke("BuyUpgrade", def.id)
			if result.ok then
				Toasts.show(`{def.name} level {result.level}!`, "reward")
				if result.level == 1 then
					Panels.close() -- the guided first Rod: back to fishing (GDD v3.1 §3.1)
				end
			elseif result.reason ~= "funds" then
				Toasts.show("Couldn't buy that right now.", "error")
			end
		end)
		upgradeRows[def.id] = entry
		Shop.upgradeButtons[def.id] = entry.button
	end
	refreshUpgrades()
end

function Shop.init()
	local panel = Panels.create("shop", "Shop: Upgrades", Vector2.new(700, 300))
	list = Builder.make("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 8,
		Parent = panel.content,
	}, { Builder.list(Enum.FillDirection.Vertical, 8), Builder.padding(4) })
	build()
end

function Shop.start()
	State.Changed:Connect(function(key: string)
		if key == "*" or key == "coins" or key == "upgrades" then
			refreshUpgrades()
		end
	end)
	Panels.Opened:Connect(function(name: string)
		if name == "shop" then
			refreshUpgrades()
		end
	end)
end

return Shop
