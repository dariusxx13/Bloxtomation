--!strict
-- Onboarding: advances the persisted funnel step when each condition is met, in order, and logs every
-- step once per player (vault: 01-first-five-minutes/measuring-onboarding.md).
-- The client reads data.onboardingStep and points the guide at the next step's target.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local OnboardingConfig = require(Shared.Config.Onboarding)
local ZoneConfig = require(Shared.Config.Zones)
local Types = require(Shared.Types)

local Analytics = require(script.Parent.Parent.Services.Analytics)
local ClientEvents = require(script.Parent.ClientEvents)
local Currency = require(script.Parent.Currency)
local Hatching = require(script.Parent.Hatching)
local Nodes = require(script.Parent.Nodes)
local PetInventory = require(script.Parent.PetInventory)
local PlayerData = require(script.Parent.PlayerData)
local Upgrades = require(script.Parent.Upgrades)
local Zones = require(script.Parent.Zones)

local Onboarding = {}

local MOVE_DISTANCE = 8
local POLL_SECONDS = 1

local spawnPositions: { [Player]: Vector3 } = {}
local moved: { [Player]: boolean } = {}
local shopOpened: { [Player]: boolean } = {}

local function anyUpgrade(data: Types.ProfileData): boolean
	for _, level in data.upgrades do
		if level > 0 then
			return true
		end
	end
	return false
end

local function playedSeconds(data: Types.ProfileData, session: Types.SessionState): number
	return data.stats.playSeconds + math.max(0, os.time() - session.sessionStart)
end

-- Whether the condition for reaching `step` holds right now.
local function conditionMet(
	player: Player,
	data: Types.ProfileData,
	session: Types.SessionState,
	step: number
): boolean
	if step == 1 then
		return true
	elseif step == 2 then
		return moved[player] == true
	elseif step == 3 then
		return data.stats.hits >= 1
	elseif step == 4 then
		return data.stats.totalCoinsEarned >= OnboardingConfig.coinsForStep4
	elseif step == 5 then
		return shopOpened[player] == true
	elseif step == 6 then
		return anyUpgrade(data)
	elseif step == 7 then
		return data.stats.hits >= OnboardingConfig.hitsForStep7
	elseif step == 8 then
		return data.stats.hatches >= 1
	elseif step == 9 then
		return #data.equipped >= 1
	elseif step == 10 then
		local second = ZoneConfig[2]
		return second == nil or data.zonesUnlocked[second.id] == true
	elseif step == 11 then
		return playedSeconds(data, session) >= OnboardingConfig.minutesForStep11 * 60
	end
	return false
end

function Onboarding.advance(player: Player)
	local data = PlayerData.get(player)
	local session = PlayerData.session(player)
	if not data or not session then
		return
	end
	local advanced = false
	while data.onboardingStep < OnboardingConfig.lastStep do
		local nextStep = data.onboardingStep + 1
		if not conditionMet(player, data, session, nextStep) then
			break
		end
		data.onboardingStep = nextStep
		advanced = true
		Analytics.onboardingStep(player, nextStep, OnboardingConfig.steps[nextStep].name)
	end
	if advanced then
		PlayerData.changed(player, "onboardingStep")
	end
end

local function trackCharacter(player: Player, character: Model)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if root and root:IsA("BasePart") then
		spawnPositions[player] = root.Position
	end
end

local function pollMovement()
	while true do
		task.wait(POLL_SECONDS)
		for _, player in Players:GetPlayers() do
			local data = PlayerData.get(player)
			if data and data.onboardingStep < OnboardingConfig.lastStep then
				if not moved[player] then
					local origin = spawnPositions[player]
					local character = player.Character
					local root = character and character:FindFirstChild("HumanoidRootPart")
					if
						origin
						and root
						and root:IsA("BasePart")
						and (root.Position - origin).Magnitude > MOVE_DISTANCE
					then
						moved[player] = true
					end
				end
				Onboarding.advance(player)
			end
		end
	end
end

function Onboarding.init() end

function Onboarding.start()
	local function advanceFor(player: Player)
		Onboarding.advance(player)
	end
	PlayerData.Loaded:Connect(advanceFor)
	Nodes.Hit:Connect(advanceFor)
	Currency.Changed:Connect(advanceFor)
	Upgrades.Bought:Connect(advanceFor)
	Hatching.Hatched:Connect(advanceFor)
	PetInventory.EquipChanged:Connect(advanceFor)
	Zones.Unlocked:Connect(advanceFor)
	ClientEvents.PanelOpened:Connect(function(player: Player, panel: string)
		if panel == "shop" then
			shopOpened[player] = true
			Onboarding.advance(player)
		end
	end)

	local function onPlayer(player: Player)
		player.CharacterAdded:Connect(function(character)
			trackCharacter(player, character)
		end)
		if player.Character then
			task.spawn(trackCharacter, player, player.Character)
		end
	end
	Players.PlayerAdded:Connect(onPlayer)
	for _, player in Players:GetPlayers() do
		onPlayer(player)
	end
	Players.PlayerRemoving:Connect(function(player: Player)
		spawnPositions[player] = nil
		moved[player] = nil
		shopOpened[player] = nil
	end)
	task.spawn(pollMovement)
end

return Onboarding
