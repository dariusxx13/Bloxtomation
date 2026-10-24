--!strict
-- Rebirth panel: shows exactly what is reset and what is kept before the player confirms
-- (vault: 04-progression-and-economy/rebirth-and-prestige.md).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage.Shared
local Economy = require(Shared.Config.Economy)
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

local RebirthPanel = {}

local info: TextLabel
local fill: Frame
local progressText: TextLabel
local button: TextButton

local function refresh()
	local data = State.data
	if not data then
		return
	end
	local cost = EconomyMath.rebirthCost(data.rebirths)
	local now = EconomyMath.rebirthMultiplier(data.rebirths)
	local nextMultiplier = EconomyMath.rebirthMultiplier(data.rebirths + 1)
	info.Text = `Rebirths: {data.rebirths}    Coin multiplier: x{Format.trimZeros(string.format("%.2f", now))}`
		.. ` -> x{Format.trimZeros(string.format("%.2f", nextMultiplier))}`
	local progress = math.clamp(data.coins / cost, 0, 1)
	TweenService:Create(fill, Theme.motion.fast, { Size = UDim2.fromScale(progress, 1) }):Play()
	progressText.Text = `{Format.short(data.coins)} / {Format.short(cost)} Coins`
	Builder.setEnabled(button, data.coins >= cost, Color3.fromRGB(190, 110, 255))
end

function RebirthPanel.init()
	local panel = Panels.create("rebirth", "Rebirth", Vector2.new(640, 460))
	local content = panel.content
	info = Builder.label({ Size = UDim2.new(1, 0, 0, 40), Parent = content }, 26)
	local bar = Builder.card({
		Size = UDim2.new(1, 0, 0, 44),
		Position = UDim2.fromOffset(0, 54),
		BackgroundColor3 = Theme.colors.backdrop,
		ClipsDescendants = true,
		Parent = content,
	})
	fill = Builder.make("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Color3.fromRGB(190, 110, 255),
		BorderSizePixel = 0,
		Parent = bar,
	}, { Builder.corner() })
	progressText = Builder.label({ Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = bar }, 24)

	local resets = { "coins" }
	local keeps = { "pets", "gems", "passes" }
	if Economy.rebirthKeepsZones then
		table.insert(keeps, "zones")
	else
		table.insert(resets, "zones")
	end
	for _, def in UpgradeConfig do
		table.insert(if def.resetsOnRebirth then resets else keeps, `{def.name} upgrades`)
	end
	Builder.label({
		Text = `Resets: {table.concat(resets, ", ")}.\nKeeps: {table.concat(keeps, ", ")}.`,
		Size = UDim2.new(1, 0, 0, 90),
		Position = UDim2.fromOffset(0, 112),
		TextColor3 = Theme.colors.textDim,
		Font = Theme.fonts.body,
		Parent = content,
	}, 24)
	button = Builder.button({
		text = "Rebirth!",
		color = Color3.fromRGB(190, 110, 255),
		size = UDim2.fromOffset(260, 70),
		position = UDim2.new(0.5, 0, 1, -8),
		anchor = Vector2.new(0.5, 1),
		textSize = 34,
		sound = "reward",
		parent = content,
		onClick = function()
			if button:GetAttribute("Disabled") then
				return
			end
			local result = Net.invoke("Rebirth")
			if result.ok then
				Toasts.show(`Rebirth {result.rebirths}! Your coins are worth more forever.`, "reward")
				Panels.close()
			end
		end,
	})
end

function RebirthPanel.start()
	Panels.Opened:Connect(function(name: string)
		if name == "rebirth" then
			refresh()
		end
	end)
	State.Changed:Connect(function(key: string)
		if Panels.isOpen("rebirth") and (key == "*" or key == "coins" or key == "rebirths") then
			refresh()
		end
	end)
end

return RebirthPanel
