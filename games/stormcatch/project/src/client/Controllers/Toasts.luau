--!strict
-- Toasts: short messages from the server (rewards, errors, nudges) and rare-hatch announcements.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)

local UI = script.Parent.Parent.UI
local Builder = require(UI.Builder)
local Panels = require(UI.Panels)
local Root = require(UI.Root)
local Sounds = require(UI.Sounds)
local Theme = require(UI.Theme)

local Toasts = {}

local MAX_VISIBLE = 4
local TOAST_SECONDS = 3.2
local ANNOUNCE_SECONDS = 5

local KIND_COLORS: { [string]: Color3 } = {
	reward = Theme.colors.good,
	error = Theme.colors.bad,
	info = Theme.colors.info,
}

local stack: Frame
local banner: TextLabel
local bannerToken = 0

local function trim()
	local items = {}
	for _, child in stack:GetChildren() do
		if child:IsA("GuiObject") then
			table.insert(items, child)
		end
	end
	table.sort(items, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)
	while #items > MAX_VISIBLE do
		local oldest = table.remove(items, 1)
		if oldest then
			oldest:Destroy()
		end
	end
end

local order = 0

-- Shows a toast. `kind` is "reward" | "error" | "info"; `panel` makes the toast open that panel on tap.
function Toasts.show(text: string, kind: string?, panel: string?)
	order += 1
	local color = KIND_COLORS[kind or "info"] or Theme.colors.info
	local toast: TextButton = Builder.make("TextButton", {
		Name = "Toast",
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(460, 48),
		BackgroundColor3 = Theme.colors.panel,
		LayoutOrder = order,
		Parent = stack,
	}, { Builder.corner(), Builder.stroke(2.5, color) })
	Builder.label({
		Text = text,
		TextColor3 = color,
		Size = UDim2.new(1, -20, 1, -8),
		Position = UDim2.fromOffset(10, 4),
		Parent = toast,
	}, 24)
	local scale: UIScale = Builder.make("UIScale", { Scale = 0.6, Parent = toast })
	TweenService:Create(scale, Theme.motion.pop, { Scale = 1 }):Play()
	if panel then
		toast.Activated:Connect(function()
			Panels.open(panel)
			toast:Destroy()
		end)
	end
	if kind == "error" then
		Sounds.play("click", 0.7)
	end
	trim()
	task.delay(TOAST_SECONDS, function()
		if toast.Parent then
			local tween = TweenService:Create(scale, Theme.motion.close, { Scale = 0 })
			tween.Completed:Connect(function()
				toast:Destroy()
			end)
			tween:Play()
		end
	end)
end

local function onToast(payload: any)
	if type(payload) == "table" and type(payload.text) == "string" then
		Toasts.show(payload.text, payload.kind, payload.panel)
	end
end

-- The server-wide Stormborn banner (prototype brief req. 9.8; juice layer 10).
local function onAnnounce(payload: any)
	if type(payload) ~= "table" or payload.kind ~= "giant" then
		return
	end
	local name = if type(payload.name) == "string" then payload.name else "Someone"
	local helpers = if type(payload.helpers) == "number" then math.floor(payload.helpers) else 0
	local species = if type(payload.species) == "string" then payload.species else "Stormborn"
	local kg = if type(payload.kg) == "number" then math.floor(payload.kg) else 0
	local charged = if payload.charged == true then "CHARGED " else ""
	local who = if helpers > 0 then `{name} and {helpers} angler{if helpers == 1 then "" else "s"}` else name
	bannerToken += 1
	local token = bannerToken
	banner.Text = `{who} landed a {charged}{species}, {kg} kg!`
	banner.TextColor3 = Theme.colors.accent
	banner.Visible = true
	Sounds.play("reward", 1.2)
	task.delay(ANNOUNCE_SECONDS, function()
		if bannerToken == token then
			banner.Visible = false
		end
	end)
end

function Toasts.init()
	local layer = Root.layer("toasts")
	stack = Builder.make("Frame", {
		Name = "ToastStack",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 164),
		Size = UDim2.fromOffset(460, 240),
		Parent = layer,
	}, { Builder.list(Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Center) })
	banner = Builder.label({
		Name = "Announcement",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 58),
		Size = UDim2.fromOffset(820, 48),
		Visible = false,
		Parent = layer,
	}, 34)
end

function Toasts.start()
	Net.on("Toast", onToast)
	Net.on("Announce", onAnnounce)
end

return Toasts
