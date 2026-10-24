--!strict
-- ClientEvents: low-trust client reports. Settings changes, panel opens and purchase prompts.
-- Nothing here grants value: these only drive settings, onboarding progress and analytics funnels.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local AnalyticsConfig = require(Shared.Config.Analytics)
local Net = require(Shared.Net)
local Products = require(Shared.Config.Products)
local Signal = require(Shared.Util.Signal)
local Validate = require(Shared.Util.Validate)

local Analytics = require(script.Parent.Parent.Services.Analytics)
local PlayerData = require(script.Parent.PlayerData)

local ClientEvents = {}

-- (player, panel)
ClientEvents.PanelOpened = Signal.new() :: Signal.Signal<Player, string>

-- Panels the client may report. Anything else is ignored.
ClientEvents.PANELS = table.freeze({
	shop = true,
	pets = true,
	rebirth = true,
	daily = true,
	settings = true,
	codes = true,
	index = true,
})

local SETTINGS = table.freeze({
	music = true,
	sfx = true,
	reduceMotion = true,
	hideOthersPets = true,
})

local function onSetSetting(player: Player, key: unknown, value: unknown)
	if type(key) ~= "string" or not SETTINGS[key] or not Validate.boolean(value) then
		return
	end
	local data = PlayerData.get(player)
	if not data then
		return
	end
	if (data.settings :: any)[key] ~= value then
		(data.settings :: any)[key] = value
		PlayerData.changed(player, "settings")
	end
end

local function onUiEvent(player: Player, kind: unknown, arg: unknown)
	if kind == "open" then
		if type(arg) ~= "string" or not ClientEvents.PANELS[arg] then
			return
		end
		Analytics.custom(player, AnalyticsConfig.customEvents.uiOpened, 1, { arg :: string })
		if arg == "shop" then
			Analytics.shopFunnel(player, 1, "Opened")
		end
		ClientEvents.PanelOpened:Fire(player, arg :: string)
	elseif kind == "prompt" then
		if type(arg) ~= "string" or not (Products.productByKey[arg] or Products.passByKey[arg]) then
			return
		end
		Analytics.shopFunnel(player, 2, "Prompted")
	end
end

function ClientEvents.init() end

function ClientEvents.start()
	Net.handle("SetSetting", onSetSetting)
	Net.handle("UiEvent", onUiEvent)
end

return ClientEvents
