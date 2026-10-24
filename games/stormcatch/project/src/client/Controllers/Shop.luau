--!strict
-- Shop: soft-currency upgrades and Robux passes/products (vault: 09-monetization/*.md).
-- Robux prices are fetched at runtime (never hard-coded), products that change odds or fund eggs are
-- hidden for players whose policy restricts paid random items, and unconfigured ids (0) are hidden.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.Shared
local EconomyMath = require(Shared.Util.EconomyMath)
local Format = require(Shared.Util.Format)
local Net = require(Shared.Net)
local Products = require(Shared.Config.Products)
local RewardConfig = require(Shared.Config.Rewards)
local Stats = require(Shared.Util.Stats)
local Types = require(Shared.Types)
local UpgradeConfig = require(Shared.Config.Upgrades)

local UI = script.Parent.Parent.UI
local Builder = require(UI.Builder)
local Panels = require(UI.Panels)
local Theme = require(UI.Theme)

local State = require(script.Parent.State)
local Toasts = require(script.Parent.Toasts)

local Shop = {}

local player = Players.LocalPlayer

type Row = { frame: Frame, title: TextLabel, subtitle: TextLabel, button: TextButton }
type Tab = "upgrades" | "passes" | "products"

local list: ScrollingFrame
local tabButtons: { [Tab]: TextButton } = {}
local currentTab: Tab = "upgrades"
local upgradeRows: { [string]: Row } = {}
local prices: { [string]: number } = {}

-- Exposed so the onboarding guide can point at the Power upgrade button.
Shop.upgradeButtons = {} :: { [string]: TextButton }

local function liveFlag(key: string): boolean
	local folder = ReplicatedStorage:FindFirstChild("LiveConfig")
	if not folder then
		return true
	end
	return folder:GetAttribute(key) ~= false
end

local function row(order: number, buttonColor: Color3): Row
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
		color = buttonColor,
		size = UDim2.fromOffset(200, 60),
		position = UDim2.new(1, -12, 0.5, 0),
		anchor = Vector2.new(1, 0.5),
		parent = frame,
	})
	return { frame = frame, title = title, subtitle = subtitle, button = button }
end

local function clearList()
	for _, child in list:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
	table.clear(upgradeRows)
	table.clear(Shop.upgradeButtons)
end

local function effectText(def: UpgradeConfig.UpgradeDef): string
	if def.kind == "power" then
		return `x{def.effect} coins per hit each level`
	elseif def.kind == "speed" then
		return `+{def.effect} walk speed each level`
	elseif def.kind == "luck" then
		return `+{math.floor(def.effect * 100 + 0.5)}% luck each level`
	end
	return `+{def.effect} pet storage each level`
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

local function buildUpgrades()
	local defs = table.clone(UpgradeConfig)
	table.sort(defs, function(a, b)
		return a.order < b.order
	end)
	for index, def in defs do
		local entry = row(index, Theme.colors.good)
		entry.subtitle.Text = `{def.description} ({effectText(def)})`
		entry.button.Activated:Connect(function()
			if entry.button:GetAttribute("Disabled") then
				return
			end
			local result = Net.invoke("BuyUpgrade", def.id)
			if not result.ok and result.reason ~= "funds" then
				Toasts.show("Couldn't buy that right now.", "error")
			end
		end)
		upgradeRows[def.id] = entry
		Shop.upgradeButtons[def.id] = entry.button
	end
	refreshUpgrades()
end

local function fetchPrice(key: string, id: number, infoType: Enum.InfoType, onPrice: (number) -> ())
	local cached = prices[key]
	if cached then
		onPrice(cached)
		return
	end
	task.spawn(function()
		local ok, info = pcall(function()
			return MarketplaceService:GetProductInfoAsync(id, infoType)
		end)
		if ok and type(info) == "table" and type(info.PriceInRobux) == "number" then
			prices[key] = info.PriceInRobux
			onPrice(info.PriceInRobux)
		end
	end)
end

local function restricted(): boolean
	local session = State.session
	return session == nil or session.randomItemsRestricted
end

local function emptyNote(text: string)
	Builder.label({
		Text = text,
		Size = UDim2.new(1, -12, 0, 80),
		TextColor3 = Theme.colors.textDim,
		Font = Theme.fonts.body,
		Parent = list,
	}, 24)
end

local function notConfiguredText(): string
	return if RunService:IsStudio()
		then "No ids yet: create these in Creator Hub and paste the ids into Config/Products.luau"
		else "Coming soon!"
end

local function buildPasses()
	local session = State.session
	local shown = 0
	for index, pass in Products.Passes do
		if pass.id ~= 0 and not (pass.probabilityModifier and restricted()) then
			shown += 1
			local entry = row(index, Theme.colors.robux)
			entry.title.Text = pass.name
			entry.subtitle.Text = pass.description
			if session and session.passes[pass.key] then
				entry.button.Text = "Owned"
				Builder.setEnabled(entry.button, false)
			else
				entry.button.Text = "..."
				fetchPrice(`pass_{pass.key}`, pass.id, Enum.InfoType.GamePass, function(price)
					if entry.button.Parent then
						entry.button.Text = `R$ {price}`
					end
				end)
				entry.button.Activated:Connect(function()
					if entry.button:GetAttribute("Disabled") then
						return
					end
					Net.fire("UiEvent", "prompt", pass.key)
					MarketplaceService:PromptGamePassPurchase(player, pass.id)
				end)
			end
		end
	end
	if shown == 0 then
		emptyNote(notConfiguredText())
	end
end

local function coinsPreview(product: Products.ProductDef): string?
	local grant = product.grant
	local minutes = 0
	if grant.kind == "coinsMinutes" then
		minutes = grant.minutes
	elseif grant.kind == "bundle" then
		for _, inner in grant.grants do
			if inner.kind == "coinsMinutes" then
				minutes += inner.minutes
			end
		end
	end
	local data = State.data
	local derived = State.derived
	if minutes == 0 or not data or not derived then
		return nil
	end
	local coins =
		Stats.coinsForMinutes(data :: Types.ProfileData, derived, minutes, RewardConfig.assumedHitsPerMinute)
	return `about {Format.short(coins)} Coins right now`
end

local function buildProducts()
	local data = State.data
	local shown = 0
	for index, product in Products.Products do
		local hidden = product.id == 0
			or ((product.fundsRandomItems or product.probabilityModifier) and restricted())
			or (product.oncePerPlayer and data ~= nil and data.oneTimeProducts[product.key] == true)
			or (product.grant.kind == "serverBoost" and not liveFlag("featureServerLuck"))
		if not hidden then
			shown += 1
			local entry = row(index, Theme.colors.robux)
			entry.title.Text = product.name
			local preview = coinsPreview(product)
			entry.subtitle.Text = if preview then `{product.description} ({preview})` else product.description
			entry.button.Text = "..."
			fetchPrice(`product_{product.key}`, product.id, Enum.InfoType.Product, function(price)
				if entry.button.Parent then
					entry.button.Text = `R$ {price}`
				end
			end)
			entry.button.Activated:Connect(function()
				Net.fire("UiEvent", "prompt", product.key)
				MarketplaceService:PromptProductPurchase(player, product.id)
			end)
		end
	end
	if shown == 0 then
		emptyNote(notConfiguredText())
	end
end

local function showTab(tab: Tab)
	currentTab = tab
	for name, button in tabButtons do
		button.BackgroundColor3 = if name == tab then Theme.colors.accent else Theme.colors.panelLight
	end
	clearList()
	if tab == "upgrades" then
		buildUpgrades()
	elseif tab == "passes" then
		buildPasses()
	else
		buildProducts()
	end
end

function Shop.init()
	local panel = Panels.create("shop", "Shop", Vector2.new(760, 540))
	local tabs = Builder.make("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 52),
		Parent = panel.content,
	}, { Builder.list(Enum.FillDirection.Horizontal, 10) })
	local tabDefs: { { id: Tab, text: string } } = {
		{ id = "upgrades", text = "Upgrades" },
		{ id = "passes", text = "Passes" },
		{ id = "products", text = "Boosts" },
	}
	for index, def in tabDefs do
		tabButtons[def.id] = Builder.button({
			text = def.text,
			color = Theme.colors.panelLight,
			size = UDim2.fromOffset(180, 50),
			layoutOrder = index,
			parent = tabs,
			onClick = function()
				showTab(def.id)
			end,
		})
	end
	list = Builder.make("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 62),
		Size = UDim2.new(1, 0, 1, -62),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 8,
		Parent = panel.content,
	}, { Builder.list(Enum.FillDirection.Vertical, 8), Builder.padding(4) })
end

function Shop.start()
	Panels.Opened:Connect(function(name: string)
		if name == "shop" then
			showTab(currentTab)
		end
	end)
	State.Changed:Connect(function(key: string)
		if not Panels.isOpen("shop") then
			return
		end
		if currentTab == "upgrades" and (key == "*" or key == "coins" or key == "upgrades") then
			refreshUpgrades()
		elseif
			currentTab ~= "upgrades"
			and (
				key == "session.passes"
				or key == "session.randomItemsRestricted"
				or key == "oneTimeProducts"
			)
		then
			showTab(currentTab)
		end
	end)
end

-- Opens the shop on a tab (used by the guide and by "not enough coins" nudges).
function Shop.openTab(tab: Tab)
	currentTab = tab
	if Panels.isOpen("shop") then
		showTab(tab)
	else
		Panels.open("shop")
	end
end

return Shop
