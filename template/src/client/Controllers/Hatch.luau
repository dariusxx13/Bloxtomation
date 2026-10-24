--!strict
-- Hatch: egg panel with the live odds (same Odds module the server rolls with, including the player's
-- current luck), the request, and the reveal: anticipation shake, flash, then the cards
-- (vault: 03-rarity-and-rng/reveal-and-hatch-design.md).

local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage.Shared
local Eggs = require(Shared.Config.Eggs)
local Format = require(Shared.Util.Format)
local Net = require(Shared.Net)
local Odds = require(Shared.Util.Odds)
local Pets = require(Shared.Config.Pets)

local UI = script.Parent.Parent.UI
local Builder = require(UI.Builder)
local Panels = require(UI.Panels)
local Root = require(UI.Root)
local Sounds = require(UI.Sounds)
local Theme = require(UI.Theme)

local Shop = require(script.Parent.Shop)
local State = require(script.Parent.State)
local Toasts = require(script.Parent.Toasts)

local Hatch = {}

local panel: Panels.Panel
local oddsList: Frame
local priceLabel: TextLabel
local luckLabel: TextLabel
local hatchOne: TextButton
local hatchThree: TextButton
local overlay: Frame
local currentEgg: string? = nil
local busy = false

local REASONS: { [string]: string } = {
	far = "Move closer to the egg.",
	full = "Pet storage is full. Delete some pets or upgrade Storage.",
	locked = "Unlock this zone first.",
	pass = "Triple Hatch needs the Triple Hatch pass.",
	rate = "Slow down a little!",
}

local function refreshOdds()
	local egg = currentEgg and Eggs.byId[currentEgg]
	local derived = State.derived
	local data = State.data
	if not egg or not derived or not data then
		return
	end
	panel.title.Text = egg.name
	for _, child in oddsList:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
	for order, outcome in Odds.effective(egg, derived.luck) do
		local pet = Pets.byKind[outcome.kind]
		local rarity = Pets.rarityById[outcome.rarity]
		local owned = data.index[outcome.kind] ~= nil
		Builder.label({
			Text = `{if owned then "" else "? "}{pet and pet.name or outcome.kind}  {outcome.rarity}  {Format.percent(
				outcome.probability
			)}`,
			TextColor3 = if rarity then Builder.rgb(rarity.color) else Theme.colors.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 30),
			LayoutOrder = order,
			Parent = oddsList,
		}, 22)
	end
	local pity = egg.pity
	local pityText = ""
	if pity then
		local count = data.pity[egg.id] or 0
		pityText = `   Guaranteed {pity.rarity}+ in {math.max(pity.afterRolls - count, 1)} hatches`
	end
	priceLabel.Text = `{Format.short(egg.price)} Coins each`
	luckLabel.Text = `Luck x{Format.trimZeros(string.format("%.2f", derived.luck))}{pityText}`
	Builder.setEnabled(hatchOne, data.coins >= egg.price, Theme.colors.good)
	local session = State.session
	local hasTriple = session ~= nil and session.passes.tripleHatch == true
	hatchThree.Text = if hasTriple then "Hatch 3" else "Hatch 3 (Pass)"
	Builder.setEnabled(hatchThree, not hasTriple or data.coins >= egg.price * 3, Theme.colors.info)
end

local function reveal(results: { any })
	overlay.Visible = true
	for _, child in overlay:GetChildren() do
		if child:IsA("GuiObject") and child.Name ~= "Flash" then
			child:Destroy()
		end
	end
	local flash = overlay:FindFirstChild("Flash") :: Frame
	local row = Builder.make("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(200 * #results + 20 * (#results - 1), 260),
		Parent = overlay,
	}, {
		Builder.make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 20),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
	})

	-- Anticipation: eggs wobble before the result (shortened when reduce motion is on).
	local eggs: { Frame } = {}
	for index in results do
		local egg = Builder.make("Frame", {
			Size = UDim2.fromOffset(150, 190),
			BackgroundColor3 = Color3.fromRGB(255, 245, 220),
			LayoutOrder = index,
			Parent = row,
		}, { Builder.corner(UDim.new(0.5, 0)), Builder.stroke(4) })
		table.insert(eggs, egg)
	end
	if not Panels.reduceMotion then
		for step = 1, 8 do
			for _, egg in eggs do
				egg.Rotation = if step % 2 == 0 then -10 else 10
			end
			Sounds.play("click", 0.8 + step * 0.08)
			task.wait(0.09)
		end
	end
	Sounds.play("reward")
	flash.BackgroundTransparency = 0
	TweenService:Create(flash, Theme.motion.float, { BackgroundTransparency = 1 }):Play()
	for _, egg in eggs do
		egg:Destroy()
	end

	for index, result in results do
		local pet = Pets.byKind[result.kind]
		local rarity = Pets.rarityById[result.rarity]
		if pet and rarity then
			local color = Builder.rgb(rarity.color)
			local card = Builder.card({
				Size = UDim2.fromOffset(200, 250),
				LayoutOrder = index,
				BackgroundColor3 = Theme.colors.panel,
				Parent = row,
			})
			local stroke = card:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Color = color
				stroke.Thickness = 5
			end
			Builder.make("Frame", {
				Size = UDim2.fromOffset(100, 100),
				Position = UDim2.new(0.5, 0, 0, 20),
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Builder.rgb(pet.color),
				Parent = card,
			}, {
				Builder.corner(if pet.shape == "Block" then UDim.new(0, 14) else UDim.new(1, 0)),
				Builder.stroke(3),
			})
			Builder.label({
				Text = pet.name,
				Size = UDim2.new(1, -10, 0, 40),
				Position = UDim2.fromOffset(5, 130),
				Parent = card,
			}, 30)
			Builder.label({
				Text = result.rarity,
				TextColor3 = color,
				Size = UDim2.new(1, -10, 0, 34),
				Position = UDim2.fromOffset(5, 170),
				Parent = card,
			}, 28)
			if result.isNew then
				Builder.label({
					Text = "NEW!",
					TextColor3 = Theme.colors.accent,
					Size = UDim2.new(1, -10, 0, 30),
					Position = UDim2.fromOffset(5, 208),
					Parent = card,
				}, 26)
			end
			local scale =
				Builder.make("UIScale", { Scale = if Panels.reduceMotion then 1 else 0.3, Parent = card })
			TweenService:Create(scale, Theme.motion.pop, { Scale = 1 }):Play()
		end
	end
	task.wait(if Panels.reduceMotion then 1.2 else 2.2)
	overlay.Visible = false
	row:Destroy()
end

local function hatch(count: number)
	local eggId = currentEgg
	if busy or not eggId then
		return
	end
	local session = State.session
	if count > 1 and not (session and session.passes.tripleHatch) then
		Shop.openTab("passes")
		return
	end
	local egg = Eggs.byId[eggId]
	local data = State.data
	if egg and data and data.coins < egg.price * count then
		Toasts.show(`You need {Format.short(egg.price * count - data.coins)} more Coins.`, "info")
		return
	end
	busy = true
	local result = Net.invoke("Hatch", eggId, count)
	if result.ok and type(result.results) == "table" then
		Panels.close()
		reveal(result.results)
	elseif not result.ok and result.reason ~= "funds" then
		Toasts.show(REASONS[result.reason] or "Couldn't hatch right now.", "error")
	end
	busy = false
end

function Hatch.open(eggId: string)
	if not Eggs.byId[eggId] then
		return
	end
	currentEgg = eggId
	Panels.open("hatch")
	refreshOdds()
end

function Hatch.init()
	panel = Panels.create("hatch", "Egg", Vector2.new(620, 560))
	local content = panel.content
	priceLabel = Builder.label({
		Size = UDim2.new(1, 0, 0, 36),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Theme.colors.coins,
		Parent = content,
	}, 28)
	luckLabel = Builder.label({
		Size = UDim2.new(1, 0, 0, 28),
		Position = UDim2.fromOffset(0, 38),
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Theme.fonts.body,
		TextColor3 = Theme.colors.textDim,
		Parent = content,
	}, 22)
	oddsList = Builder.make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 74),
		Size = UDim2.new(1, 0, 1, -150),
		Parent = content,
	}, { Builder.list(Enum.FillDirection.Vertical, 4) })
	hatchOne = Builder.button({
		text = "Hatch 1",
		color = Theme.colors.good,
		size = UDim2.fromOffset(250, 64),
		position = UDim2.fromScale(0, 1),
		anchor = Vector2.new(0, 1),
		textSize = 30,
		parent = content,
		onClick = function()
			hatch(1)
		end,
	})
	hatchThree = Builder.button({
		text = "Hatch 3",
		color = Theme.colors.info,
		size = UDim2.fromOffset(250, 64),
		position = UDim2.fromScale(1, 1),
		anchor = Vector2.new(1, 1),
		textSize = 30,
		parent = content,
		onClick = function()
			hatch(Eggs.maxHatchCount)
		end,
	})

	overlay = Builder.make("Frame", {
		Name = "HatchReveal",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.35,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = Root.layer("overlay"),
	})
	Builder.make("Frame", {
		Name = "Flash",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 5,
		Parent = overlay,
	})
end

function Hatch.start()
	ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt)
		if prompt.Name ~= "HatchPrompt" then
			return
		end
		local stand = prompt.Parent
		local eggId = stand and stand:GetAttribute("EggId")
		if type(eggId) == "string" then
			Hatch.open(eggId)
		end
	end)
	State.Changed:Connect(function(key: string)
		if
			Panels.isOpen("hatch") and (key == "coins" or key == "derived" or key == "pity" or key == "index")
		then
			refreshOdds()
		end
	end)
end

return Hatch
