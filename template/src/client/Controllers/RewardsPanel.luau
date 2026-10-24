--!strict
-- Rewards panel: 7-day calendar, in-session playtime gifts and code redemption, plus the HUD badge
-- that tells the player something is ready (vault: 10-retention-and-social/retention-systems.md).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local CodeConfig = require(Shared.Config.Codes)
local Daily = require(Shared.Util.Daily)
local Format = require(Shared.Util.Format)
local Net = require(Shared.Net)
local RewardConfig = require(Shared.Config.Rewards)

local UI = script.Parent.Parent.UI
local Builder = require(UI.Builder)
local Panels = require(UI.Panels)
local Sounds = require(UI.Sounds)
local Theme = require(UI.Theme)

local HUD = require(script.Parent.HUD)
local State = require(script.Parent.State)
local Toasts = require(script.Parent.Toasts)

local RewardsPanel = {}

local BOOST_NAMES: { [string]: string } = { coins2x = "2x Coins", luck2x = "2x Luck" }

local dayCards: { Frame } = {}
local giftButtons: { TextButton } = {}
local streakLabel: TextLabel
local dailyButton: TextButton
local codesRow: Frame

local function liveFlag(key: string): boolean
	local folder = ReplicatedStorage:FindFirstChild("LiveConfig")
	return folder == nil or folder:GetAttribute(key) ~= false
end

local function today(): number
	return Daily.dayNumber(State.now())
end

local function rewardText(reward: RewardConfig.Reward): string
	local lines: { string } = {}
	if reward.coinsMinutes then
		table.insert(lines, `{reward.coinsMinutes}m of Coins`)
	end
	if reward.gems then
		table.insert(lines, `{reward.gems} Gems`)
	end
	if reward.boost and reward.boostSeconds then
		table.insert(
			lines,
			`{BOOST_NAMES[reward.boost] or reward.boost} {Format.duration(reward.boostSeconds)}`
		)
	end
	return table.concat(lines, "\n")
end

local function dailyAvailable(): boolean
	local data = State.data
	return data ~= nil and liveFlag("featureDailyRewards") and Daily.available(data.daily, today())
end

local function giftState(index: number): ("claimed" | "ready" | "waiting", number)
	local session = State.session
	if not session then
		return "waiting", 0
	end
	if session.playtimeClaimed[index] then
		return "claimed", 0
	end
	local remaining = session.joinedAt + RewardConfig.playtime[index].minutes * 60 - State.now()
	if remaining <= 0 then
		return "ready", 0
	end
	return "waiting", remaining
end

local function anyGiftReady(): boolean
	if not liveFlag("featurePlaytimeRewards") then
		return false
	end
	for index in RewardConfig.playtime do
		if giftState(index) == "ready" then
			return true
		end
	end
	return false
end

local function refresh()
	local data = State.data
	if not data then
		return
	end
	local daily = data.daily
	local available = dailyAvailable()
	-- The card that will be claimed next is calendarDay; once claimed today, highlight the one just claimed.
	local highlight = if available
		then daily.calendarDay
		else ((daily.calendarDay - 2) % #RewardConfig.daily) + 1
	for index, card in dayCards do
		local stroke = card:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Color = if index == highlight then Theme.colors.accent else Theme.colors.stroke
			stroke.Thickness = if index == highlight then 4 else 2
		end
	end
	local bonus = Daily.streakBonus(daily.streak) - 1
	streakLabel.Text = `Streak: {daily.streak} days (+{math.floor(bonus * 100 + 0.5)}% daily coins)`
	if available then
		dailyButton.Text = "Claim!"
		Builder.setEnabled(dailyButton, true, Theme.colors.good)
	else
		local nextIn = (today() + 1) * Daily.SECONDS_PER_DAY - State.now()
		dailyButton.Text = if liveFlag("featureDailyRewards")
			then `Next in {Format.duration(nextIn)}`
			else "Unavailable"
		Builder.setEnabled(dailyButton, false)
	end
	for index, button in giftButtons do
		local state, remaining = giftState(index)
		local gift = RewardConfig.playtime[index]
		if state == "claimed" then
			button.Text = "Claimed"
			Builder.setEnabled(button, false)
		elseif state == "ready" then
			button.Text = `{gift.minutes}m: Open!`
			Builder.setEnabled(button, true, Theme.colors.good)
		else
			button.Text = Format.duration(remaining)
			Builder.setEnabled(button, false)
		end
	end
	codesRow.Visible = liveFlag("featureCodes")
end

local function claimDaily()
	if dailyButton:GetAttribute("Disabled") then
		return
	end
	local result = Net.invoke("ClaimDaily")
	if result.ok then
		Sounds.play("reward")
		Toasts.show(`Day {result.day}: {result.text}`, "reward")
	end
	refresh()
end

local function claimGift(index: number)
	if giftButtons[index]:GetAttribute("Disabled") then
		return
	end
	local result = Net.invoke("ClaimPlaytime", index)
	if result.ok then
		Sounds.play("reward")
		Toasts.show(`Gift: {result.text}`, "reward")
	end
	refresh()
end

local REASONS: { [string]: string } = {
	unknown = "That code doesn't exist.",
	expired = "That code has expired.",
	used = "You already used that code.",
	disabled = "Codes are turned off right now.",
	rate = "Slow down a little!",
}

function RewardsPanel.init()
	local panel = Panels.create("daily", "Rewards", Vector2.new(860, 600))
	local content = panel.content

	-- Daily calendar
	local calendar = Builder.make("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 150),
		Parent = content,
	}, { Builder.list(Enum.FillDirection.Horizontal, 8) })
	for index, reward in RewardConfig.daily do
		local card =
			Builder.card({ Size = UDim2.fromOffset(108, 150), LayoutOrder = index, Parent = calendar })
		Builder.label({ Text = `Day {index}`, Size = UDim2.new(1, 0, 0, 34), Parent = card }, 26)
		Builder.label({
			Text = rewardText(reward),
			Size = UDim2.new(1, -10, 1, -44),
			Position = UDim2.fromOffset(5, 38),
			Font = Theme.fonts.body,
			TextColor3 = Theme.colors.textDim,
			Parent = card,
		}, 18)
		dayCards[index] = card
	end
	streakLabel = Builder.label({
		Size = UDim2.new(1, -260, 0, 50),
		Position = UDim2.fromOffset(0, 158),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = content,
	}, 24)
	dailyButton = Builder.button({
		text = "Claim!",
		color = Theme.colors.good,
		size = UDim2.fromOffset(240, 56),
		position = UDim2.new(1, 0, 0, 156),
		anchor = Vector2.new(1, 0),
		sound = "reward",
		parent = content,
		onClick = claimDaily,
	})

	-- Playtime gifts
	Builder.label({
		Text = "Gifts for playing this session",
		Size = UDim2.new(1, 0, 0, 34),
		Position = UDim2.fromOffset(0, 226),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = content,
	}, 24)
	local gifts = Builder.make("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 120),
		Position = UDim2.fromOffset(0, 266),
		Parent = content,
	}, { Builder.list(Enum.FillDirection.Horizontal, 8) })
	for index, gift in RewardConfig.playtime do
		local card = Builder.card({ Size = UDim2.fromOffset(126, 118), LayoutOrder = index, Parent = gifts })
		Builder.label({
			Text = rewardText(gift.reward),
			Size = UDim2.new(1, -8, 0, 52),
			Position = UDim2.fromOffset(4, 4),
			Font = Theme.fonts.body,
			Parent = card,
		}, 18)
		giftButtons[index] = Builder.button({
			text = "",
			size = UDim2.new(1, -12, 0, 50),
			position = UDim2.new(0.5, 0, 1, -6),
			anchor = Vector2.new(0.5, 1),
			textSize = 20,
			parent = card,
			onClick = function()
				claimGift(index)
			end,
		})
	end

	-- Codes
	codesRow = Builder.make("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 60),
		Position = UDim2.new(0, 0, 1, -62),
		Parent = content,
	})
	local box: TextBox = Builder.make("TextBox", {
		PlaceholderText = "Enter a code",
		Text = "",
		ClearTextOnFocus = false,
		Font = Theme.fonts.display,
		TextScaled = true,
		TextColor3 = Theme.colors.text,
		PlaceholderColor3 = Theme.colors.textDim,
		BackgroundColor3 = Theme.colors.backdrop,
		Size = UDim2.new(1, -230, 1, -4),
		Parent = codesRow,
	}, {
		Builder.corner(),
		Builder.stroke(2),
		Builder.padding(8),
		Builder.make("UITextSizeConstraint", { MaxTextSize = 28 }),
	})
	Builder.button({
		text = "Redeem",
		color = Theme.colors.info,
		size = UDim2.fromOffset(210, 56),
		position = UDim2.fromScale(1, 0),
		anchor = Vector2.new(1, 0),
		parent = codesRow,
		onClick = function()
			local code = string.gsub(box.Text, "%s", "")
			if #code == 0 or #code > CodeConfig.maxLength then
				return
			end
			local result = Net.invoke("RedeemCode", code)
			if result.ok then
				box.Text = ""
				Sounds.play("reward")
				Toasts.show(`Code redeemed: {result.text}`, "reward")
			else
				Toasts.show(REASONS[result.reason] or "That code didn't work.", "error")
			end
		end,
	})
end

function RewardsPanel.start()
	Panels.Opened:Connect(function(name: string)
		if name == "daily" then
			refresh()
		end
	end)
	task.spawn(function()
		while true do
			task.wait(1)
			if State.isReady() then
				HUD.setBadge("daily", dailyAvailable() or anyGiftReady())
				if Panels.isOpen("daily") then
					refresh()
				end
			end
		end
	end)
end

return RewardsPanel
