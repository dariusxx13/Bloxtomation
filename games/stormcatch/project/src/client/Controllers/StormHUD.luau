--!strict
-- StormHUD: the co-op pull on the client (prototype brief req. 9.4-9.8). When a Stormborn is hooked, a big
-- Pull! button replaces Cast for every player within 40 studs of the angler (above the reel button if their
-- own line is out). Each tap sends PullTap; the server decides who counts, the meter, the landing, Charged and
-- every coin. This draws the meter (extrapolated from the server's rate between updates), the giant's taut
-- line and shadow, the "Help pull!" tip, and the bolt on a Charged landing.
-- Public: pulling() -> true while the local player is an angler.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Shared
local Fishing = require(Shared.Config.Fishing)
local Net = require(Shared.Net)
local Types = require(Shared.Types)
local WeatherConfig = require(Shared.Config.Weather)

local UI = script.Parent.Parent.UI
local Builder = require(UI.Builder)
local Root = require(UI.Root)
local Sounds = require(UI.Sounds)
local Theme = require(UI.Theme)
local Thumb = require(UI.Thumb)

local Interact = require(script.Parent.Interact)
local Weather = require(script.Parent.Weather)

local StormHUD = {}

local PULL_TAP_SPACING = 0.17 -- keeps taps under the PullTap limit (6/s)

local player = Players.LocalPlayer
local lastPullTap = 0
local pulls: { Types.PullInfo } = {}
local pullButton: TextButton
local tip: TextLabel
local meter: Frame
local meterFill: Frame
local meterLabel: TextLabel
local folder: Folder
local lines: { [number]: { beam: Beam, target: Part, shadow: Part } } = {}

local function rootOf(userId: number): BasePart?
	local other = Players:GetPlayerByUserId(userId)
	local character = other and other.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root else nil
end

function StormHUD.pulling(): boolean
	for _, info in pulls do
		if info.anglerUserId == player.UserId then
			return true
		end
	end
	return false
end

-- The pull this client would help: the nearest whose angler is within the pull radius (display only; the
-- server re-checks distance on every tap).
local function nearestPull(): Types.PullInfo?
	local me = Interact.rootPart()
	if not me then
		return nil
	end
	local best: Types.PullInfo? = nil
	local bestDistance = Fishing.pull.radius
	for _, info in pulls do
		if info.anglerUserId ~= player.UserId then
			local root = rootOf(info.anglerUserId)
			if root then
				local distance = (root.Position - me.Position).Magnitude
				if distance <= bestDistance then
					best = info
					bestDistance = distance
				end
			end
		end
	end
	return best
end

local function progressNow(info: Types.PullInfo): number
	return math.clamp(info.progress + info.rate * (Weather.now() - info.at), 0, Fishing.pull.points)
end

local function lineFor(info: Types.PullInfo)
	if lines[info.id] then
		return
	end
	local ripple = Interact.spotPosition(info.spot) or Vector3.zero
	local target: Part = Builder.make("Part", {
		Name = "GiantLineEnd",
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		Transparency = 1,
		Size = Vector3.one,
		Position = ripple,
		Parent = folder,
	})
	local shadow: Part = Builder.make("Part", {
		Name = "GiantShadow",
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
		CastShadow = false,
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(22, 3, 10),
		Color = Color3.fromRGB(24, 32, 58),
		Transparency = 0.35,
		Position = ripple - Vector3.new(0, 1.2, 0),
		Parent = folder,
	})
	local attachment = Builder.make("Attachment", { Parent = target })
	local beam: Beam = Builder.make("Beam", {
		Attachment1 = attachment,
		Color = ColorSequence.new(Theme.colors.accent),
		Width0 = 0.25,
		Width1 = 0.25,
		FaceCamera = true,
		LightEmission = 1,
		Parent = target,
	})
	lines[info.id] = { beam = beam, target = target, shadow = shadow }
end

local function clearLines(keep: { [number]: boolean })
	for id, entry in lines do
		if not keep[id] then
			entry.target:Destroy()
			entry.shadow:Destroy()
			lines[id] = nil
		end
	end
end

local function onPullState(payload: any)
	if type(payload) ~= "table" or type(payload.pulls) ~= "table" then
		return
	end
	local state = payload :: Types.PullStatePayload
	pulls = state.pulls
	local keep: { [number]: boolean } = {}
	for _, info in pulls do
		keep[info.id] = true
		lineFor(info)
	end
	clearLines(keep)
	Weather.setPullsActive(#pulls > 0)
	local landed = state.landed
	if landed and landed.charged then
		Weather.bolt(Interact.spotPosition(WeatherConfig.storm.eye) or Vector3.zero)
		Sounds.play("rumble", 0.5, 0.05)
	end
end

local function render()
	-- Taut lines from each angler's rod tip, and the giant thrashing under the water.
	local t = os.clock()
	for _, info in pulls do
		local entry = lines[info.id]
		if entry then
			local other = Players:GetPlayerByUserId(info.anglerUserId)
			local character = other and other.Character
			local rod = character and character:FindFirstChild("FishingRod")
			local rodTip = rod and rod:FindFirstChild("Tip")
			entry.beam.Attachment0 = if rodTip and rodTip:IsA("Attachment") then rodTip else nil
			local base = entry.target.Position
			entry.shadow.CFrame = CFrame.new(
				base + Vector3.new(math.sin(t * 3) * 3, -1.2, math.cos(t * 2) * 2)
			) * CFrame.Angles(0, math.sin(t * 1.7) * 0.6, 0)
		end
	end

	local helping = nearestPull()
	local mine: Types.PullInfo? = nil
	for _, info in pulls do
		if info.anglerUserId == player.UserId then
			mine = info
		end
	end
	local shown = helping ~= nil and mine == nil
	Thumb.pullShown = shown
	pullButton.Visible = shown
	tip.Visible = shown
	if shown then
		local right, bottom = Thumb.offsets()
		local lift = if Thumb.lineActive then Thumb.SIZE + 20 else 0
		pullButton.Position = UDim2.new(1, -right, 1, -(bottom + lift))
		tip.Position = UDim2.new(1, -right, 1, -(bottom + lift + Thumb.SIZE + 50))
	end
	local watched = mine or helping
	meter.Visible = watched ~= nil
	if watched then
		local progress = progressNow(watched)
		meterFill.Size = UDim2.fromScale(progress / Fishing.pull.points, 1)
		local who = if mine then "You hooked a Rumblefin! Hold on" else `Help {watched.anglerName} pull!`
		meterLabel.Text = `{who}  ({watched.helpers} helping)`
	end
end

function StormHUD.init()
	local layer = Root.layer("hud")
	folder = Instance.new("Folder")
	folder.Name = "PullFx"
	folder.Parent = Workspace
	pullButton = Builder.button({
		text = "Pull!",
		color = Theme.colors.accent,
		size = UDim2.fromOffset(Thumb.SIZE + 10, Thumb.SIZE + 10),
		anchor = Thumb.ANCHOR,
		textSize = 48,
		sound = "reelTick",
		parent = layer,
		onClick = function()
			if os.clock() - lastPullTap >= PULL_TAP_SPACING then
				lastPullTap = os.clock()
				Net.fire("PullTap")
			end
		end,
	})
	local corner = pullButton:FindFirstChildOfClass("UICorner")
	if corner then
		corner.CornerRadius = UDim.new(1, 0)
	end
	pullButton.Visible = false
	tip = Builder.label({
		Text = "Help pull!",
		AnchorPoint = Thumb.ANCHOR,
		Size = UDim2.fromOffset(240, 40),
		TextColor3 = Theme.colors.accent,
		Visible = false,
		Parent = layer,
	}, 30)
	meter = Builder.card({
		Name = "PullMeter",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 112),
		Size = UDim2.fromOffset(520, 44),
		BackgroundColor3 = Theme.colors.panel,
		ClipsDescendants = true,
		Visible = false,
		Parent = layer,
	})
	meterFill = Builder.make("Frame", {
		BackgroundColor3 = Theme.colors.accent,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0, 1),
		Parent = meter,
	}, { Builder.corner() })
	meterLabel = Builder.label({
		Size = UDim2.new(1, -16, 1, -8),
		Position = UDim2.fromOffset(8, 4),
		ZIndex = 2,
		Parent = meter,
	}, 24)
end

function StormHUD.start()
	Net.on("PullState", onPullState)
	RunService.RenderStepped:Connect(render)
end

return StormHUD
