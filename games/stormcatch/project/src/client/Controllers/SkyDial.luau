--!strict
-- SkyDial (minimal; prototype brief req. 7): a strip at top centre that appears after the first Rod purchase.
-- It always shows the Great Storm countdown ("Storm m:ss", highlighted from 5:00; "Storm now m:ss" while it
-- runs), then the next three front arrivals as "<icon> Rain → Cove Shallows 0:40". Times come from the server's
-- WeatherState; this counts down locally from server time and never decides anything.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Types = require(Shared.Types)

local UI = script.Parent.Parent.UI
local Builder = require(UI.Builder)
local Root = require(UI.Root)
local Theme = require(UI.Theme)

local Interact = require(script.Parent.Interact)
local State = require(script.Parent.State)
local Weather = require(script.Parent.Weather)

local SkyDial = {}

local UPDATE_SECONDS = 0.25
local HIGHLIGHT_SECONDS = 300
local NAMES: { [string]: string } = { showers = "Rain", fog = "Fog" }
local COLORS: { [string]: Color3 } = {
	showers = Color3.fromRGB(111, 195, 217),
	fog = Color3.fromRGB(212, 217, 210),
}

type Cell = { frame: Frame, icon: Frame?, label: TextLabel }

local strip: Frame
local stormCell: Cell
local arrivalCells: { Cell } = {}

local function clock(seconds: number): string
	local s = math.max(0, math.floor(seconds))
	return string.format("%d:%02d", s // 60, s % 60)
end

local function cell(order: number, width: number, withIcon: boolean): Cell
	local frame = Builder.card({
		Size = UDim2.fromOffset(width, 44),
		LayoutOrder = order,
		BackgroundColor3 = Theme.colors.panel,
		Parent = strip,
	})
	local icon: Frame? = nil
	if withIcon then
		icon = Builder.make("Frame", {
			Size = UDim2.fromOffset(28, 28),
			Position = UDim2.fromOffset(8, 8),
			BackgroundColor3 = COLORS.showers,
			Parent = frame,
		}, { Builder.corner(UDim.new(1, 0)), Builder.stroke(2) })
	end
	local label = Builder.label({
		Size = UDim2.new(1, if withIcon then -48 else -16, 1, -8),
		Position = UDim2.fromOffset(if withIcon then 42 else 8, 4),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	}, 22)
	return { frame = frame, icon = icon, label = label }
end

-- The text of each part of the dial at server time `now` (also used by the Guide for the rain ETA).
function SkyDial.describe(state: Types.WeatherStatePayload, now: number): (string, boolean, { Types.Arrival })
	local storm = state.storm
	local stormText: string
	local highlight: boolean
	if storm.active and now < storm.endsAt then
		stormText = `Storm now {clock(storm.endsAt - now)}`
		highlight = true
	else
		local untilStorm = storm.startsAt - now
		stormText = `Storm {clock(untilStorm)}`
		highlight = untilStorm <= HIGHLIGHT_SECONDS
	end
	local upcoming: { Types.Arrival } = {}
	for _, arrival in state.arrivals do
		if arrival.at > now then
			table.insert(upcoming, arrival)
		end
	end
	return stormText, highlight, upcoming
end

local function update()
	local data = State.data
	local state = Weather.state()
	strip.Visible = data ~= nil and (data.upgrades.rod or 0) >= 1 and state ~= nil
	if not strip.Visible or not state then
		return
	end
	local now = Weather.now()
	local stormText, highlight, upcoming = SkyDial.describe(state, now)
	stormCell.label.Text = stormText
	stormCell.frame.BackgroundColor3 = if highlight then Theme.colors.accent else Theme.colors.panel
	stormCell.label.TextColor3 = if highlight then Theme.colors.stroke else Theme.colors.text
	for index, entry in arrivalCells do
		local arrival = upcoming[index]
		entry.frame.Visible = arrival ~= nil
		if arrival then
			local name = NAMES[arrival.weather] or arrival.weather
			entry.label.Text = `{name} → {Interact.spotName(arrival.spot)} {clock(arrival.at - now)}`
			local icon = entry.icon
			if icon then
				icon.BackgroundColor3 = COLORS[arrival.weather] or Theme.colors.info
			end
		end
	end
end

function SkyDial.init()
	strip = Builder.make("Frame", {
		Name = "SkyDial",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 6),
		Size = UDim2.fromOffset(764, 44), -- 170 + 3 x 190 + gaps: clears the coin counter on a 1280-wide canvas
		BackgroundTransparency = 1,
		Visible = false,
		Parent = Root.layer("hud"),
	}, { Builder.list(Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Center) })
	stormCell = cell(1, 170, false)
	for index = 1, 3 do
		arrivalCells[index] = cell(index + 1, 190, true)
	end
end

function SkyDial.start()
	task.spawn(function()
		while true do
			task.wait(UPDATE_SECONDS)
			update()
		end
	end)
end

return SkyDial
