--!strict
-- Pets panel: inventory grid, equip/unequip, equip best, lock, and multi-delete. Every action is a
-- request; the grid re-renders from State when the server confirms.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local Pets = require(Shared.Config.Pets)
local Types = require(Shared.Types)

local UI = script.Parent.Parent.UI
local Builder = require(UI.Builder)
local Panels = require(UI.Panels)
local Theme = require(UI.Theme)

local State = require(script.Parent.State)
local Toasts = require(script.Parent.Toasts)

local PetsPanel = {}

local MAX_DELETE = 50
local CELL = Vector2.new(118, 138)

local grid: ScrollingFrame
local summary: TextLabel
local actionBar: Frame
local selectedLabel: TextLabel
local equipButton: TextButton
local lockButton: TextButton
local deleteModeButton: TextButton
local confirmDeleteButton: TextButton

local selected: string? = nil
local deleteMode = false
local deleteSet: { [string]: boolean } = {}
local renderQueued = false

-- Exposed for the onboarding guide.
PetsPanel.equipBestButton = nil :: TextButton?

local function isEquipped(data: Types.ProfileData, id: string): boolean
	return table.find(data.equipped, id) ~= nil
end

local function findPet(data: Types.ProfileData, id: string): Types.OwnedPet?
	for _, pet in data.pets do
		if pet.id == id then
			return pet
		end
	end
	return nil
end

local function countKeys(set: { [string]: boolean }): number
	local n = 0
	for _ in set do
		n += 1
	end
	return n
end

local function render()
	renderQueued = false
	local data = State.data
	local derived = State.derived
	if not data or not derived or not Panels.isOpen("pets") then
		return
	end
	for _, child in grid:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
	local indexCount = 0
	for _ in data.index do
		indexCount += 1
	end
	summary.Text =
		`Equipped {#data.equipped}/{derived.petSlots}   Storage {#data.pets}/{derived.petCapacity}   Index {indexCount}/{#Pets.Catalog}`

	local sorted = table.clone(data.pets)
	table.sort(sorted, function(a, b)
		local ea = isEquipped(data, a.id)
		local eb = isEquipped(data, b.id)
		if ea ~= eb then
			return ea
		end
		local da = Pets.byKind[a.kind]
		local db = Pets.byKind[b.kind]
		return (da and da.bonus or 0) > (db and db.bonus or 0)
	end)

	for order, pet in sorted do
		local def = Pets.byKind[pet.kind]
		local rarity = def and Pets.rarityById[def.rarity]
		if def and rarity then
			local rarityColor = Builder.rgb(rarity.color)
			local marked = deleteMode and deleteSet[pet.id] == true
			local card: TextButton = Builder.make("TextButton", {
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = order,
				BackgroundColor3 = if marked then Theme.colors.bad else Theme.colors.panelLight,
				Parent = grid,
			}, {
				Builder.corner(),
				Builder.stroke(if selected == pet.id then 4 else 2.5, rarityColor),
			})
			Builder.make("Frame", {
				Size = UDim2.fromOffset(62, 62),
				Position = UDim2.new(0.5, 0, 0, 10),
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Builder.rgb(def.color),
				Parent = card,
			}, {
				Builder.corner(if def.shape == "Block" then UDim.new(0, 10) else UDim.new(1, 0)),
				Builder.stroke(2),
			})
			Builder.label({
				Text = def.name,
				Size = UDim2.new(1, -8, 0, 24),
				Position = UDim2.fromOffset(4, 76),
				Parent = card,
			}, 18)
			Builder.label({
				Text = `+{math.floor(def.bonus * 100 + 0.5)}%`,
				TextColor3 = rarityColor,
				Size = UDim2.new(1, -8, 0, 22),
				Position = UDim2.fromOffset(4, 102),
				Parent = card,
			}, 18)
			if isEquipped(data, pet.id) then
				Builder.label({
					Text = "E",
					TextColor3 = Theme.colors.good,
					Size = UDim2.fromOffset(24, 24),
					Position = UDim2.fromOffset(6, 4),
					Parent = card,
				}, 22)
			end
			if pet.locked then
				Builder.label({
					Text = "L",
					TextColor3 = Theme.colors.accent,
					Size = UDim2.fromOffset(24, 24),
					Position = UDim2.new(1, -30, 0, 4),
					Parent = card,
				}, 22)
			end
			card.Activated:Connect(function()
				if deleteMode then
					local protected = pet.locked == true or isEquipped(data, pet.id)
					if protected then
						Toasts.show("Locked and equipped pets can't be deleted.", "info")
					elseif deleteSet[pet.id] then
						deleteSet[pet.id] = nil
					elseif countKeys(deleteSet) < MAX_DELETE then
						deleteSet[pet.id] = true
					end
				else
					selected = if selected == pet.id then nil else pet.id
				end
				PetsPanel.refresh()
			end)
		end
	end

	-- Action bar
	local pet = selected and findPet(data, selected)
	if not pet then
		selected = nil
	end
	if deleteMode then
		selectedLabel.Text = `Select pets to delete ({countKeys(deleteSet)})`
		equipButton.Visible = false
		lockButton.Visible = false
		confirmDeleteButton.Visible = true
		Builder.setEnabled(confirmDeleteButton, next(deleteSet) ~= nil, Theme.colors.bad)
		deleteModeButton.Text = "Cancel"
	else
		local def = pet and Pets.byKind[pet.kind]
		selectedLabel.Text = if def then `{def.name} ({def.rarity})` else "Tap a pet"
		equipButton.Visible = pet ~= nil
		lockButton.Visible = pet ~= nil
		confirmDeleteButton.Visible = false
		deleteModeButton.Text = "Delete..."
		if pet then
			equipButton.Text = if isEquipped(data, pet.id) then "Unequip" else "Equip"
			lockButton.Text = if pet.locked then "Unlock" else "Lock"
		end
	end
end

function PetsPanel.refresh()
	if not renderQueued then
		renderQueued = true
		task.defer(render)
	end
end

local function invoke(remote: string, ...: any)
	local result = Net.invoke(remote, ...)
	if not result.ok then
		local reason = result.reason
		local text = if reason == "slots"
			then "All pet slots are full. Unequip one or get more slots."
			else "That didn't work. Try again."
		Toasts.show(text, "error")
	end
	return result
end

function PetsPanel.init()
	local panel = Panels.create("pets", "Pets", Vector2.new(820, 580))
	summary = Builder.label({
		Size = UDim2.new(1, -330, 0, 40),
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Theme.fonts.body,
		Parent = panel.content,
	}, 22)
	PetsPanel.equipBestButton = Builder.button({
		text = "Equip Best",
		color = Theme.colors.good,
		size = UDim2.fromOffset(150, 46),
		position = UDim2.new(1, -170, 0, 0),
		anchor = Vector2.new(1, 0),
		parent = panel.content,
		onClick = function()
			invoke("EquipBest")
		end,
	})
	deleteModeButton = Builder.button({
		text = "Delete...",
		color = Theme.colors.bad,
		size = UDim2.fromOffset(150, 46),
		position = UDim2.fromScale(1, 0),
		anchor = Vector2.new(1, 0),
		parent = panel.content,
		onClick = function()
			deleteMode = not deleteMode
			table.clear(deleteSet)
			selected = nil
			PetsPanel.refresh()
		end,
	})
	grid = Builder.make("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 54),
		Size = UDim2.new(1, 0, 1, -130),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 8,
		Parent = panel.content,
	}, { Builder.grid(CELL, 10), Builder.padding(6) })

	actionBar = Builder.make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 1, -66),
		Size = UDim2.new(1, 0, 0, 62),
		Parent = panel.content,
	})
	selectedLabel = Builder.label({
		Size = UDim2.new(1, -360, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = actionBar,
	}, 26)
	equipButton = Builder.button({
		text = "Equip",
		color = Theme.colors.good,
		size = UDim2.fromOffset(170, 56),
		position = UDim2.new(1, -180, 0.5, 0),
		anchor = Vector2.new(1, 0.5),
		parent = actionBar,
		onClick = function()
			local data = State.data
			local id = selected
			if not data or not id then
				return
			end
			invoke(if isEquipped(data, id) then "UnequipPet" else "EquipPet", id)
		end,
	})
	lockButton = Builder.button({
		text = "Lock",
		color = Theme.colors.accent,
		size = UDim2.fromOffset(170, 56),
		position = UDim2.fromScale(1, 0.5),
		anchor = Vector2.new(1, 0.5),
		parent = actionBar,
		onClick = function()
			local data = State.data
			local id = selected
			local pet = data and id and findPet(data, id)
			if pet then
				invoke("LockPet", pet.id, not pet.locked)
			end
		end,
	})
	confirmDeleteButton = Builder.button({
		text = "Delete selected",
		color = Theme.colors.bad,
		size = UDim2.fromOffset(240, 56),
		position = UDim2.fromScale(1, 0.5),
		anchor = Vector2.new(1, 0.5),
		parent = actionBar,
		onClick = function()
			local ids = {}
			for id in deleteSet do
				table.insert(ids, id)
			end
			if #ids > 0 then
				local result = invoke("DeletePets", ids)
				if result.ok then
					Toasts.show(`Deleted {result.removed or 0} pets`, "info")
				end
			end
			deleteMode = false
			table.clear(deleteSet)
			PetsPanel.refresh()
		end,
	})
end

function PetsPanel.start()
	Panels.Opened:Connect(function(name: string)
		if name == "pets" then
			PetsPanel.refresh()
		end
	end)
	Panels.Closed:Connect(function(name: string)
		if name == "pets" then
			deleteMode = false
			table.clear(deleteSet)
			selected = nil
		end
	end)
	State.Changed:Connect(function(key: string)
		if key == "*" or key == "pets" or key == "equipped" or key == "index" or key == "derived" then
			PetsPanel.refresh()
		end
	end)
end

return PetsPanel
