--!strict
-- Live tuning through Roblox configs (vault: 12-live-ops-and-launch/experiments-and-configs.md).
-- Every value has a local default and a type check, so a missing or mistyped config never breaks the game.
-- House rule: new features ship behind a boolean flag here so they can be switched off without publishing.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ConfigServiceAvailable, ConfigService = pcall(function()
	return game:GetService("ConfigService")
end)

local LiveConfig = {}

-- Declare every live key with its default. Create the same keys in Creator Hub > Configs to override them.
local DEFAULTS: { [string]: any } = {
	featureStormPull = true, -- kill switch for Stormborn hooks (the Great Storm itself always runs on time)
}

-- Keys the client may read (to hide disabled features). Published as attributes on
-- ReplicatedStorage.LiveConfig. Never list anything secret here.
local PUBLIC_KEYS = { "featureStormPull" }

local REFRESH_SECONDS = 60

local snapshot: any = nil
local publicFolder: Folder? = nil

local function refresh()
	if not ConfigServiceAvailable then
		return
	end
	local ok, result = pcall(function()
		return (ConfigService :: any):GetConfigAsync()
	end)
	if ok then
		snapshot = result
	end
end

local function getPublicFolder(): Folder
	local existing = publicFolder
	if existing then
		return existing
	end
	local folder = Instance.new("Folder")
	folder.Name = "LiveConfig"
	folder.Parent = ReplicatedStorage
	publicFolder = folder
	return folder
end

local function publish()
	local folder = getPublicFolder()
	for _, key in PUBLIC_KEYS do
		folder:SetAttribute(key, LiveConfig.get(key))
	end
end

function LiveConfig.start()
	refresh()
	publish()
	task.spawn(function()
		while true do
			task.wait(REFRESH_SECONDS)
			refresh()
			publish()
		end
	end)
end

-- Global value (same for every player). Falls back to the default when unset or of the wrong type.
function LiveConfig.get(key: string): any
	local default = DEFAULTS[key]
	assert(default ~= nil, `LiveConfig key {key} has no default`)
	if snapshot then
		local ok, value = pcall(function()
			return snapshot:GetValue(key)
		end)
		if ok and value ~= nil and type(value) == type(default) then
			if type(value) ~= "number" or (value == value and value ~= math.huge and value ~= -math.huge) then
				return value
			end
		end
	end
	return default
end

-- Player-specific value (targeting and experiments). Yields; call when the player joins and cache the result.
function LiveConfig.getForPlayer(player: Player, key: string): any
	local default = DEFAULTS[key]
	assert(default ~= nil, `LiveConfig key {key} has no default`)
	if not ConfigServiceAvailable then
		return default
	end
	local ok, value = pcall(function()
		local playerSnapshot = (ConfigService :: any):GetConfigForPlayerAsync(player)
		return playerSnapshot:GetValue(key)
	end)
	if ok and value ~= nil and type(value) == type(default) then
		return value
	end
	return default
end

function LiveConfig.flag(key: string): boolean
	return LiveConfig.get(key) == true
end

return LiveConfig
