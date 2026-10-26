--!strict
-- Settings panel: saved player preferences, applied immediately on this client, plus the QA tools
-- section (Studio and allowlisted testers only; the server re-checks every command).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Shared = ReplicatedStorage.Shared
local Game = require(Shared.Config.Game)
local Net = require(Shared.Net)

local UI = script.Parent.Parent.UI
local Builder = require(UI.Builder)
local Panels = require(UI.Panels)
local Sounds = require(UI.Sounds)
local Theme = require(UI.Theme)

local State = require(script.Parent.State)
local Toasts = require(script.Parent.Toasts)

local SettingsPanel = {}

type SettingKey = "music" | "sfx" | "reduceMotion"

local OPTIONS: { { key: SettingKey, text: string } } = {
	{ key = "music", text = "Music" },
	{ key = "sfx", text = "Sound effects" },
	{ key = "reduceMotion", text = "Reduce motion" },
}

-- Buttons for the QA commands (prototype brief req. 11). The server re-checks every command.
local QA_COMMANDS: { { name: string, text: string, arg: any } } = {
	{ name = "state", text = "Show state" },
	{ name = "addCoins", text = "+100 Coins", arg = 100 },
	{ name = "forceWeather", text = "Shallows: Rain 120s", arg = "cove_shallows showers 120" },
	{ name = "forceWeather", text = "Shallows: Fog 120s", arg = "cove_shallows fog 120" },
	{ name = "forceWeather", text = "Shallows: Clear 120s", arg = "cove_shallows clear 120" },
	{ name = "forceStorm", text = "Storm now" },
	{ name = "forceStormborn", text = "Next eye bite: giant" },
	{ name = "twistStats", text = "Twist stats" },
	{ name = "exportLog", text = "Export log" },
	{ name = "setOnboarding", text = "Restart guide", arg = 0 },
	{ name = "wipeData", text = "Wipe my data" },
}

local toggles: { [string]: TextButton } = {}

local function setting(key: string): boolean
	local data = State.data
	return if data then (data.settings :: any)[key] == true else false
end

local function apply()
	Sounds.enabled = setting("sfx")
	Panels.reduceMotion = setting("reduceMotion")
	local music = SoundService:FindFirstChild("Music")
	if music and music:IsA("Sound") then
		music.Volume = if setting("music") then 0.35 else 0
	end
	for key, button in toggles do
		local on = setting(key)
		button.Text = if on then "ON" else "OFF"
		button.BackgroundColor3 = if on then Theme.colors.good else Theme.colors.disabled
	end
end

local function qaAllowed(): boolean
	return RunService:IsStudio() or table.find(Game.qaUserIds, Players.LocalPlayer.UserId) ~= nil
end

function SettingsPanel.init()
	local panel = Panels.create("settings", "Settings", Vector2.new(700, 560))
	local scroll = Builder.make("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 8,
		Parent = panel.content,
	}, { Builder.list(Enum.FillDirection.Vertical, 8), Builder.padding(4) })

	for index, option in OPTIONS do
		local row = Builder.card({ Size = UDim2.new(1, -12, 0, 64), LayoutOrder = index, Parent = scroll })
		Builder.label({
			Text = option.text,
			Size = UDim2.new(1, -170, 1, -12),
			Position = UDim2.fromOffset(14, 6),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		}, 26)
		toggles[option.key] = Builder.button({
			text = "",
			size = UDim2.fromOffset(130, 50),
			position = UDim2.new(1, -10, 0.5, 0),
			anchor = Vector2.new(1, 0.5),
			parent = row,
			onClick = function()
				Net.fire("SetSetting", option.key, not setting(option.key))
			end,
		})
	end

	if qaAllowed() then
		Builder.label({
			Text = "QA tools (test servers only)",
			Size = UDim2.new(1, -12, 0, 40),
			LayoutOrder = 100,
			TextColor3 = Theme.colors.accent,
			Parent = scroll,
		}, 26)
		local grid = Builder.make("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -12, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 101,
			Parent = scroll,
		}, { Builder.grid(Vector2.new(205, 52), 8) })
		for index, command in QA_COMMANDS do
			Builder.button({
				text = command.text,
				color = Theme.colors.info,
				layoutOrder = index,
				textSize = 20,
				parent = grid,
				onClick = function()
					local result = Net.invoke("QACommand", command.name, command.arg)
					local text = if type(result.text) == "string" then result.text else ""
					if #text > 120 then
						print(`[QA] {command.name}: {text}`)
						text = `{command.name}: done (full text in the output)`
					end
					Toasts.show(
						if text ~= "" then text else (if result.ok then "Done" else "Failed"),
						if result.ok then "info" else "error"
					)
				end,
			})
		end
	end
end

function SettingsPanel.start()
	State.Changed:Connect(function(key: string)
		if key == "*" or key == "settings" then
			apply()
		end
	end)
end

return SettingsPanel
