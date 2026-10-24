--!strict
-- State: the client's read-only mirror of its own profile and session, kept current by the server's
-- snapshot + delta stream. Controllers render from here and never invent state.
-- Derived stats are recomputed locally once per second with the same pure Stats module, so boost
-- timers expire on screen at the same moment they expire on the server.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local Signal = require(Shared.Util.Signal)
local Stats = require(Shared.Util.Stats)
local Types = require(Shared.Types)

local State = {}

-- (key) for each changed data key, "session.<key>" for session keys, and "derived"
State.Changed = Signal.new() :: Signal.Signal<string>
State.Ready = Signal.new() :: Signal.Signal<>

State.data = nil :: Types.ProfileData?
State.session = nil :: Types.SessionState?
State.derived = nil :: Types.DerivedStats?

local readyFired = false

-- Server unix time (synchronised clock).
function State.now(): number
	return Workspace:GetServerTimeNow()
end

function State.isReady(): boolean
	return State.data ~= nil
end

-- Yields until the first snapshot arrived.
function State.waitReady()
	while not State.data do
		task.wait(0.1)
	end
end

local function recompute(): boolean
	local data = State.data
	if not data then
		return false
	end
	local derived = Stats.derive(data, State.session, State.now())
	local previous = State.derived
	State.derived = derived
	if not previous then
		return true
	end
	for key, value in derived :: any do
		if (previous :: any)[key] ~= value then
			return true
		end
	end
	return false
end

local function onSnapshot(snapshot: any)
	if type(snapshot) ~= "table" then
		return
	end
	State.data = snapshot.data
	State.session = snapshot.session
	State.derived = snapshot.derived
	State.Changed:Fire("*")
	if not readyFired then
		readyFired = true
		State.Ready:Fire()
	end
end

local function onDelta(patch: any)
	if type(patch) ~= "table" or not State.data then
		return
	end
	local data = State.data :: any
	local session = State.session :: any
	if type(patch.data) == "table" then
		for key, value in patch.data do
			data[key] = value
			State.Changed:Fire(key)
		end
	end
	if type(patch.session) == "table" and session then
		for key, value in patch.session do
			session[key] = value
			State.Changed:Fire("session." .. key)
		end
	end
	if type(patch.derived) == "table" then
		State.derived = patch.derived
		State.Changed:Fire("derived")
	end
end

-- Boosts with an expiry in the future, sorted by time left: { { id, secondsLeft } }
function State.activeBoosts(): { { id: string, secondsLeft: number } }
	local list = {}
	local now = State.now()
	local data = State.data
	if data then
		for id, expiry in data.boosts do
			if expiry > now then
				table.insert(list, { id = id, secondsLeft = expiry - now })
			end
		end
	end
	local session = State.session
	if session and session.serverLuckUntil > now then
		table.insert(list, { id = "serverLuck", secondsLeft = session.serverLuckUntil - now })
	end
	table.sort(list, function(a, b)
		return a.secondsLeft < b.secondsLeft
	end)
	return list
end

function State.init()
	Net.on("StateSnapshot", onSnapshot)
	Net.on("StateDelta", onDelta)
end

function State.start()
	task.spawn(function()
		-- Ask once in case the snapshot was sent before our listener connected.
		task.wait(1)
		if not State.data then
			Net.invoke("RequestSnapshot")
		end
	end)
	task.spawn(function()
		while true do
			task.wait(1)
			if recompute() then
				State.Changed:Fire("derived")
			end
		end
	end)
end

return State
