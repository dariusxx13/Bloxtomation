--!strict
-- Onboarding: advances the persisted funnel step when each condition is met, in order, and logs every
-- step once per player (vault: 01-first-five-minutes/measuring-onboarding.md; prototype brief req. 10).
-- The client reads data.onboardingStep and points the guide at the next step's target.
-- Steps: 1 Joined (profile loaded), 2 First Cast (a Cast accepted by the server), 3 First Catch (1 catch or
-- more), 4 Earned Rod Coins (total coins earned >= coinsForStep4), 5 Opened Shop, 6 First Rod Upgrade,
-- 7 Caught in Rain (a catch whose weather was Showers).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local OnboardingConfig = require(Shared.Config.Onboarding)
local Types = require(Shared.Types)

local Analytics = require(script.Parent.Parent.Services.Analytics)
local CatchLog = require(script.Parent.CatchLog)
local ClientEvents = require(script.Parent.ClientEvents)
local Currency = require(script.Parent.Currency)
local Fishing = require(script.Parent.Fishing)
local PlayerData = require(script.Parent.PlayerData)
local Upgrades = require(script.Parent.Upgrades)
local Weather = require(script.Parent.Weather)

local Onboarding = {}

local castAccepted: { [Player]: boolean } = {}
local shopOpened: { [Player]: boolean } = {}

-- Whether the condition for reaching `step` holds right now.
local function conditionMet(player: Player, data: Types.ProfileData, step: number): boolean
	if step == 1 then
		return true
	elseif step == 2 then
		return castAccepted[player] == true or data.stats.catches >= 1
	elseif step == 3 then
		return data.stats.catches >= 1
	elseif step == 4 then
		return data.stats.totalCoinsEarned >= OnboardingConfig.coinsForStep4
	elseif step == 5 then
		return shopOpened[player] == true
	elseif step == 6 then
		return (data.upgrades[OnboardingConfig.upgradeForStep6] or 0) >= 1
	elseif step == 7 then
		return data.stats.rainCatches >= 1
	end
	return false
end

function Onboarding.advance(player: Player)
	local data = PlayerData.get(player)
	if not data then
		return
	end
	local advanced = false
	while data.onboardingStep < OnboardingConfig.lastStep do
		local nextStep = data.onboardingStep + 1
		if not conditionMet(player, data, nextStep) then
			break
		end
		data.onboardingStep = nextStep
		advanced = true
		local stepName = OnboardingConfig.steps[nextStep].name
		Analytics.onboardingStep(player, nextStep, stepName)
		CatchLog.markStep(player, nextStep, Weather.now())
		print(`[Onboarding] {CatchLog.alias(player)} step {nextStep} {stepName}`)
	end
	if advanced then
		PlayerData.changed(player, "onboardingStep")
	end
end

function Onboarding.init() end

function Onboarding.start()
	local function advanceFor(player: Player)
		Onboarding.advance(player)
	end
	PlayerData.Loaded:Connect(advanceFor)
	Fishing.CastAccepted:Connect(function(player: Player)
		castAccepted[player] = true
		Onboarding.advance(player)
	end)
	Fishing.Caught:Connect(advanceFor)
	Currency.Changed:Connect(advanceFor)
	Upgrades.Bought:Connect(advanceFor)
	ClientEvents.PanelOpened:Connect(function(player: Player, panel: string)
		if panel == "shop" then
			shopOpened[player] = true
			Onboarding.advance(player)
		end
	end)
	Players.PlayerRemoving:Connect(function(player: Player)
		castAccepted[player] = nil
		shopOpened[player] = nil
	end)
end

return Onboarding
