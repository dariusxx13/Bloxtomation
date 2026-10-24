--!strict
-- The single client/server API layer (vault: 13-building-it-right/networking-and-remotes.md).
-- Server: Net.initServer() creates every remote from Config/Remotes; Net.handle() wraps handlers with
-- a per-player rate limit and a protected call. Client: Net.fire / Net.invoke / Net.on.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Definitions = require("./Config/Remotes")
local RateLimiter = require("./Util/RateLimiter")

local FOLDER_NAME = "Remotes"

local Net = {}

local folder: Folder? = nil
local limiter = RateLimiter.new(os.clock)

local function getFolder(): Folder
	if folder then
		return folder
	end
	if RunService:IsServer() then
		error("Net.initServer() must run before using remotes on the server")
	end
	local found = ReplicatedStorage:WaitForChild(FOLDER_NAME, 30)
	assert(found and found:IsA("Folder"), "Remotes folder missing")
	folder = found
	return found
end

local function getRemote(name: string): Instance
	local def = Definitions[name]
	assert(def, `unknown remote {name}`)
	local remote = getFolder():WaitForChild(name, 30)
	assert(remote, `remote {name} not found`)
	return remote
end

-- Server: create all remotes once, at startup (before any system registers handlers).
function Net.initServer()
	assert(RunService:IsServer(), "server only")
	if folder then
		return
	end
	local newFolder = Instance.new("Folder")
	newFolder.Name = FOLDER_NAME
	for name, def in Definitions do
		local remote: Instance
		if def.kind == "function" then
			remote = Instance.new("RemoteFunction")
		elseif def.kind == "unreliable" then
			remote = Instance.new("UnreliableRemoteEvent")
		else
			remote = Instance.new("RemoteEvent")
		end
		remote.Name = name
		remote.Parent = newFolder
	end
	newFolder.Parent = ReplicatedStorage
	folder = newFolder
	Players.PlayerRemoving:Connect(function(player)
		limiter:forget(player)
	end)
end

-- Server: register the handler for a client -> server remote.
-- Handlers receive raw `unknown` arguments and must validate them (Util/Validate).
-- Function remotes return a table; rate-limited or failed calls return { ok = false, reason = ... }.
function Net.handle(name: string, handler: (Player, ...any) -> any)
	local def = Definitions[name]
	assert(def and def.rate and def.burst, `remote {name} has no rate limit`)
	local rate = def.rate :: number
	local burst = def.burst :: number
	local remote = getRemote(name)
	if remote:IsA("RemoteFunction") then
		remote.OnServerInvoke = function(player: Player, ...: any): any
			if not limiter:allow(player, name, rate, burst) then
				return { ok = false, reason = "rate" }
			end
			local results = table.pack(pcall(handler, player, ...))
			if not results[1] then
				warn(`[Net] {name} handler error: {results[2]}`)
				return { ok = false, reason = "error" }
			end
			return results[2]
		end
	elseif remote:IsA("RemoteEvent") then
		remote.OnServerEvent:Connect(function(player: Player, ...: any)
			if not limiter:allow(player, name, rate, burst) then
				return
			end
			local ok, err = pcall(handler, player, ...)
			if not ok then
				warn(`[Net] {name} handler error: {err}`)
			end
		end)
	else
		error(`remote {name} cannot be handled on the server`)
	end
end

function Net.violations(player: Player): number
	return limiter:violationCount(player)
end

-- Server -> one client
function Net.toClient(player: Player, name: string, ...: any)
	local remote = getRemote(name)
	if remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent") then
		(remote :: any):FireClient(player, ...)
	end
end

-- Server -> all clients
function Net.toAll(name: string, ...: any)
	local remote = getRemote(name)
	if remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent") then
		(remote :: any):FireAllClients(...)
	end
end

-- Server -> clients whose character is within `radius` studs of `position`, except `exclude`
function Net.toNearby(position: Vector3, radius: number, exclude: Player?, name: string, ...: any)
	for _, player in Players:GetPlayers() do
		if player ~= exclude then
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root and root:IsA("BasePart") and (root.Position - position).Magnitude <= radius then
				Net.toClient(player, name, ...)
			end
		end
	end
end

-- Client -> server event
function Net.fire(name: string, ...: any)
	local remote = getRemote(name)
	if remote:IsA("RemoteEvent") then
		remote:FireServer(...)
	end
end

-- Client -> server function; never throws, returns { ok = false } on failure
function Net.invoke(name: string, ...: any): any
	local remote = getRemote(name)
	if not remote:IsA("RemoteFunction") then
		return { ok = false, reason = "not a function remote" }
	end
	local args = table.pack(...)
	local ok, result = pcall(function()
		return remote:InvokeServer(table.unpack(args, 1, args.n))
	end)
	if not ok or type(result) ~= "table" then
		return { ok = false, reason = "network" }
	end
	return result
end

-- Client: listen to a server -> client remote
function Net.on(name: string, handler: (...any) -> ()): RBXScriptConnection
	local remote = getRemote(name)
	if remote:IsA("RemoteEvent") then
		return remote.OnClientEvent:Connect(handler)
	elseif remote:IsA("UnreliableRemoteEvent") then
		return remote.OnClientEvent:Connect(handler)
	end
	error(`remote {name} cannot be listened to on the client`)
end

return Net
