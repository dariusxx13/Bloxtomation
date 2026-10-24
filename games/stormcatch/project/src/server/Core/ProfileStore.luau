--!strict
-- Session-locked player profile storage on DataStoreService (vault: 13-building-it-right/data-persistence.md).
-- Guarantees: UpdateAsync only, one server owns a profile at a time (lock with session id + time),
-- retries with backoff, migrations on load, corrupted or newer data refused instead of overwritten.
-- In Studio without API access it falls back to an in-memory backend (data is not persisted).
-- A battle-tested alternative is ProfileStore by loleris (see wally.toml); this module shows every rule explicitly.

local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.Shared
local Game = require(Shared.Config.Game)
local Migrations = require(Shared.Data.Migrations)
local Schema = require(Shared.Data.Schema)
local TableUtil = require(Shared.Util.TableUtil)
local Types = require(Shared.Types)

local MAX_ATTEMPTS = 5
local LOCK_RETRY_SECONDS = 5

type Meta = { lockId: string?, lockTime: number, updated: number }
type Stored = { data: Types.ProfileData, meta: Meta }
type Transform = (old: any) -> any

export type Backend = {
	kind: "datastore" | "memory",
	update: (self: Backend, key: string, transform: Transform) -> (),
}

export type Profile = {
	userId: number,
	key: string,
	data: Types.ProfileData,
	active: boolean,
	lastSaveClock: number,
}

export type LoadFailure = "locked" | "corrupt" | "newer_version" | "error"

local ProfileStore = {}
ProfileStore.__index = ProfileStore

export type ProfileStore = typeof(setmetatable({} :: { backend: Backend, sessionId: string }, ProfileStore))

-- Backends -----------------------------------------------------------------------------------------

local function dataStoreBackend(store: DataStore): Backend
	local backend = { kind = "datastore" } :: any
	function backend.update(_self: Backend, key: string, transform: Transform)
		store:UpdateAsync(key, function(old: any)
			return transform(old)
		end)
	end
	return backend
end

local function memoryBackend(): Backend
	local values: { [string]: any } = {}
	local backend = { kind = "memory" } :: any
	function backend.update(_self: Backend, key: string, transform: Transform)
		local result = transform(TableUtil.deepCopy(values[key]))
		if result ~= nil then
			values[key] = TableUtil.deepCopy(result)
		end
	end
	return backend
end

local function chooseBackend(storeName: string): Backend
	local ok, store = pcall(function()
		return DataStoreService:GetDataStore(storeName)
	end)
	if ok and store then
		if RunService:IsStudio() then
			-- Probe: Studio without "Enable Studio Access to API Services" throws on any request.
			local probeOk = pcall(function()
				store:GetAsync("__probe")
			end)
			if not probeOk then
				warn(
					"[ProfileStore] Studio has no DataStore access: using an in-memory store (nothing is saved)."
				)
				return memoryBackend()
			end
		end
		return dataStoreBackend(store)
	end
	warn("[ProfileStore] DataStoreService unavailable: using an in-memory store (nothing is saved).")
	return memoryBackend()
end

-- Store --------------------------------------------------------------------------------------------

function ProfileStore.new(storeName: string, backend: Backend?): ProfileStore
	local sessionId = if game.JobId ~= "" then game.JobId else HttpService:GenerateGUID(false)
	return setmetatable({
		backend = backend or chooseBackend(storeName),
		sessionId = sessionId,
	}, ProfileStore)
end

local function keyFor(userId: number): string
	return `user_{userId}`
end

-- Loads and locks a profile. Returns (profile, nil) or (nil, failure).
function ProfileStore.load(self: ProfileStore, userId: number): (Profile?, LoadFailure?)
	local key = keyFor(userId)
	local delay = 1
	local lastFailure: LoadFailure = "error"
	for attempt = 1, MAX_ATTEMPTS do
		local outcome: LoadFailure? = nil
		local loaded: Types.ProfileData? = nil
		local ok, err = pcall(function()
			self.backend:update(key, function(old: any): any
				outcome = nil
				loaded = nil
				local now = os.time()
				local stored: Stored
				if old == nil then
					stored = { data = Schema.new(now), meta = { lockId = nil, lockTime = 0, updated = now } }
				elseif type(old) ~= "table" or type(old.data) ~= "table" then
					outcome = "corrupt"
					return nil
				else
					stored = old :: Stored
				end
				local meta: Meta = stored.meta or { lockId = nil, lockTime = 0, updated = 0 }
				local lockedByOther = meta.lockId ~= nil
					and meta.lockId ~= self.sessionId
					and now - (meta.lockTime or 0) < Game.sessionLockStaleSeconds
				if lockedByOther then
					outcome = "locked"
					return nil -- abort the write; another server still owns this profile
				end
				local migrateOk, migrated = pcall(Migrations.migrate, stored.data)
				if not migrateOk then
					outcome = if string.find(tostring(migrated), "newer", 1, true)
						then "newer_version"
						else "corrupt"
					return nil
				end
				meta.lockId = self.sessionId
				meta.lockTime = now
				meta.updated = now
				loaded = migrated
				return { data = migrated, meta = meta }
			end)
		end)
		if ok and outcome == nil and loaded then
			return {
				userId = userId,
				key = key,
				data = loaded,
				active = true,
				lastSaveClock = os.clock(),
			},
				nil
		end
		if ok and (outcome == "corrupt" or outcome == "newer_version") then
			warn(`[ProfileStore] refusing to load {key}: {outcome}`)
			return nil, outcome
		end
		if outcome == "locked" then
			lastFailure = "locked"
			task.wait(LOCK_RETRY_SECONDS)
		else
			lastFailure = "error"
			warn(`[ProfileStore] load attempt {attempt}/{MAX_ATTEMPTS} for {key} failed: {err}`)
			task.wait(delay)
			delay = math.min(delay * 2, 16)
		end
	end
	return nil, lastFailure
end

export type SaveResult = "saved" | "lost" | "invalid" | "error"

-- Saves the profile. With `release`, also clears the lock (player left or server closing).
-- Returns "lost" if another server took the lock (this server must stop using the profile).
function ProfileStore.save(self: ProfileStore, profile: Profile, release: boolean): SaveResult
	if not profile.active then
		return "lost"
	end
	local problem = Schema.check(profile.data)
	if problem then
		warn(`[ProfileStore] not saving {profile.key}: {problem}`)
		return "invalid"
	end
	local delay = 1
	for attempt = 1, MAX_ATTEMPTS do
		local lost = false
		local ok, err = pcall(function()
			self.backend:update(profile.key, function(old: any): any
				lost = false
				local now = os.time()
				if type(old) == "table" and type(old.meta) == "table" then
					local lockId = old.meta.lockId
					if lockId ~= nil and lockId ~= self.sessionId then
						lost = true
						return nil
					end
				end
				local meta: Meta = {
					lockId = if release then nil else self.sessionId,
					lockTime = now,
					updated = now,
				}
				return { data = profile.data, meta = meta }
			end)
		end)
		if ok then
			if lost then
				profile.active = false
				warn(`[ProfileStore] session for {profile.key} was taken by another server`)
				return "lost"
			end
			profile.lastSaveClock = os.clock()
			if release then
				profile.active = false
			end
			return "saved"
		end
		warn(`[ProfileStore] save attempt {attempt}/{MAX_ATTEMPTS} for {profile.key} failed: {err}`)
		task.wait(delay)
		delay = math.min(delay * 2, 16)
	end
	return "error"
end

function ProfileStore.backendKind(self: ProfileStore): string
	return self.backend.kind
end

return ProfileStore
