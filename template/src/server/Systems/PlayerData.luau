--!strict
-- PlayerData: owns every loaded profile and the per-session state, saves them safely, and replicates
-- each player's own state to their client as a snapshot plus batched deltas.
-- Gameplay systems never touch DataStores: they read/write PlayerData.get(player) and call PlayerData.changed().

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.Shared
local Game = require(Shared.Config.Game)
local Net = require(Shared.Net)
local Signal = require(Shared.Util.Signal)
local Stats = require(Shared.Util.Stats)
local Types = require(Shared.Types)

local ProfileStore = require(script.Parent.Parent.Core.ProfileStore)

local PlayerData = {}

-- Fired after a player's profile is loaded and their session exists.
PlayerData.Loaded = Signal.new() :: Signal.Signal<Player, Types.ProfileData>
-- Fired before the final save when a player leaves (systems flush pending work here).
PlayerData.Removing = Signal.new() :: Signal.Signal<Player, Types.ProfileData>
-- Fired whenever a data or session key is marked changed.
PlayerData.Changed = Signal.new() :: Signal.Signal<Player, string>

local store: ProfileStore.ProfileStore
local profiles: { [Player]: ProfileStore.Profile } = {}
local sessions: { [Player]: Types.SessionState } = {}
local dirtyData: { [Player]: { [string]: boolean } } = {}
local dirtySession: { [Player]: { [string]: boolean } } = {}
local closing = false

local FLUSH_INTERVAL = 0.1

function PlayerData.get(player: Player): Types.ProfileData?
	local profile = profiles[player]
	return if profile and profile.active then profile.data else nil
end

function PlayerData.session(player: Player): Types.SessionState?
	return sessions[player]
end

function PlayerData.isLoaded(player: Player): boolean
	return PlayerData.get(player) ~= nil
end

function PlayerData.derived(player: Player): Types.DerivedStats?
	local data = PlayerData.get(player)
	if not data then
		return nil
	end
	return Stats.derive(data, sessions[player], os.time())
end

-- Marks profile keys as changed so they replicate on the next flush.
function PlayerData.changed(player: Player, ...: string)
	local set = dirtyData[player]
	if not set then
		return
	end
	for _, key in { ... } do
		set[key] = true
		PlayerData.Changed:Fire(player, key)
	end
end

-- Marks session keys as changed.
function PlayerData.sessionChanged(player: Player, ...: string)
	local set = dirtySession[player]
	if not set then
		return
	end
	for _, key in { ... } do
		set[key] = true
		PlayerData.Changed:Fire(player, "session." .. key)
	end
end

local function snapshotFor(player: Player): { [string]: any }?
	local data = PlayerData.get(player)
	local session = sessions[player]
	if not data or not session then
		return nil
	end
	return {
		data = data,
		session = session,
		derived = Stats.derive(data, session, os.time()),
		serverTime = os.time(),
	}
end

function PlayerData.sendSnapshot(player: Player)
	local snapshot = snapshotFor(player)
	if snapshot then
		Net.toClient(player, "StateSnapshot", snapshot)
	end
end

local function flush()
	for player, keys in dirtyData do
		local sessionKeys = dirtySession[player]
		local hasData = next(keys) ~= nil
		local hasSession = sessionKeys ~= nil and next(sessionKeys) ~= nil
		if hasData or hasSession then
			local data = PlayerData.get(player)
			local session = sessions[player]
			if data and session then
				local patch: { [string]: any } = { serverTime = os.time() }
				if hasData then
					local values = {}
					for key in keys do
						values[key] = (data :: any)[key]
					end
					patch.data = values
				end
				if hasSession and sessionKeys then
					local values = {}
					for key in sessionKeys do
						values[key] = (session :: any)[key]
					end
					patch.session = values
				end
				patch.derived = Stats.derive(data, session, os.time())
				Net.toClient(player, "StateDelta", patch)
			end
			table.clear(keys)
			if sessionKeys then
				table.clear(sessionKeys)
			end
		end
	end
end

-- Saves immediately (used after purchases). Returns true if the profile was written.
function PlayerData.saveNow(player: Player): boolean
	local profile = profiles[player]
	if not profile or not profile.active then
		return false
	end
	local result = store:save(profile, false)
	if result == "lost" then
		player:Kick("Your session moved to another server. Please rejoin.")
	end
	return result == "saved"
end

local function newSession(): Types.SessionState
	return {
		passes = {},
		serverLuckUntil = 0,
		socialBonus = 0,
		playtimeClaimed = {},
		sessionStart = os.time(),
		joinedAt = os.time(),
		randomItemsRestricted = true, -- safe default until Policy loads
	}
end

local function onPlayerAdded(player: Player)
	local profile, failure = store:load(player.UserId)
	if not player:IsDescendantOf(Players) then
		-- Left while loading: release the lock right away.
		if profile then
			store:save(profile, true)
		end
		return
	end
	if not profile then
		local message = if failure == "locked"
			then "Your data is still saving from another server. Please rejoin in a moment."
			else "Your data couldn't load. Please rejoin in a minute."
		player:Kick(message) -- never play on a default profile: it would overwrite the real save
		return
	end
	-- Stagger autosaves by user id so a full server does not save everyone in the same second.
	profile.lastSaveClock = os.clock() - (player.UserId % Game.autosaveSeconds)
	profiles[player] = profile
	sessions[player] = newSession()
	dirtyData[player] = {}
	dirtySession[player] = {}

	local data = profile.data
	data.stats.sessions += 1
	PlayerData.sendSnapshot(player)
	PlayerData.Loaded:Fire(player, data)
end

local function releasePlayer(player: Player)
	local profile = profiles[player]
	if not profile then
		return
	end
	local session = sessions[player]
	PlayerData.Removing:Fire(player, profile.data)
	task.wait() -- let Removing handlers run (they are spawned)
	if session then
		profile.data.stats.playSeconds += math.max(0, os.time() - session.sessionStart)
	end
	profile.data.stats.lastLogout = os.time()
	store:save(profile, true)
	profiles[player] = nil
	sessions[player] = nil
	dirtyData[player] = nil
	dirtySession[player] = nil
end

local saving: { [Player]: boolean } = {}

local function autosaveLoop()
	while not closing do
		task.wait(5)
		for player, profile in profiles do
			if
				profile.active
				and not saving[player]
				and os.clock() - profile.lastSaveClock >= Game.autosaveSeconds
			then
				local session = sessions[player]
				if session then
					-- Checkpoint play time so a crash loses at most one autosave interval.
					local now = os.time()
					profile.data.stats.playSeconds += math.max(0, now - session.sessionStart)
					session.sessionStart = now
				end
				saving[player] = true
				task.spawn(function()
					if store:save(profile, false) == "lost" then
						player:Kick("Your session moved to another server. Please rejoin.")
					end
					saving[player] = nil
				end)
			end
		end
	end
end

local function onClose()
	closing = true
	local pending = 0
	for player in profiles do
		pending += 1
		task.spawn(function()
			releasePlayer(player)
			pending -= 1
		end)
	end
	local deadline = os.clock() + (if RunService:IsStudio() then 3 else 25)
	while pending > 0 and os.clock() < deadline do
		task.wait(0.1)
	end
end

function PlayerData.init()
	store = ProfileStore.new(Game.dataStoreName)
end

function PlayerData.start()
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
	Players.PlayerRemoving:Connect(function(player)
		if not closing then
			releasePlayer(player)
		end
	end)
	game:BindToClose(onClose)
	task.spawn(autosaveLoop)
	Net.handle("RequestSnapshot", function(player: Player)
		PlayerData.sendSnapshot(player)
		return { ok = true }
	end)
	local accumulator = 0
	RunService.Heartbeat:Connect(function(dt: number)
		accumulator += dt
		if accumulator >= FLUSH_INTERVAL then
			accumulator = 0
			flush()
		end
	end)
	print(`[PlayerData] using {store:backendKind()} storage`)
end

return PlayerData
