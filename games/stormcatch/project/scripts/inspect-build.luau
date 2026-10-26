--!strict
-- Opens a built place file and checks what `rojo build` produced (no Studio needed):
--   lune run scripts/inspect-build build.rbxl
-- Verifies the bootstrap ORDER lists against the modules in the place, that the out-of-scope template
-- modules are gone, the Workspace streaming and Lighting settings, and prints a summary. Exit 1 on a problem.

local fs = require("@lune/fs")
local process = require("@lune/process")
local roblox = require("@lune/roblox")

local args: { string } = {}
for _, arg in process.args do
	if arg ~= "--" then
		table.insert(args, arg)
	end
end
local path = args[1] or "build.rbxl"
local game = roblox.deserializePlace(fs.readFile(path))

local problems: { string } = {}
local function expect(condition: boolean, message: string)
	if not condition then
		table.insert(problems, message)
	end
end

local function orderList(source: string): { string }
	local block = string.match(source, "local ORDER = {(.-)}")
	local names: { string } = {}
	if block then
		for name in string.gmatch(block, '"([%w_]+)"') do
			table.insert(names, name)
		end
	end
	return names
end

local function children(instance: any, className: string): { string }
	local names: { string } = {}
	for _, child in instance:GetChildren() do
		if child.ClassName == className then
			table.insert(names, child.Name)
		end
	end
	table.sort(names)
	return names
end

local server = game:GetService("ServerScriptService"):FindFirstChild("Server")
local shared = game:GetService("ReplicatedStorage"):FindFirstChild("Shared")
local starter = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
local client = starter and starter:FindFirstChild("Client")
expect(server ~= nil and server.ClassName == "Script", "ServerScriptService.Server is the server Script")
expect(shared ~= nil, "ReplicatedStorage.Shared exists")
expect(client ~= nil and client.ClassName == "LocalScript", "StarterPlayerScripts.Client is the LocalScript")

local systems = children(server:FindFirstChild("Systems"), "ModuleScript")
local controllers = children(client:FindFirstChild("Controllers"), "ModuleScript")
local serverOrder = orderList(server.Source)
local clientOrder = orderList(client.Source)
for _, name in serverOrder do
	expect(table.find(systems, name) ~= nil, `server ORDER names missing system {name}`)
end
for _, name in systems do
	expect(table.find(serverOrder, name) ~= nil, `system {name} is not in the server ORDER`)
end
for _, name in clientOrder do
	expect(table.find(controllers, name) ~= nil, `client ORDER names missing controller {name}`)
end
for _, name in controllers do
	expect(table.find(clientOrder, name) ~= nil, `controller {name} is not in the client ORDER`)
end
for _, gone in { "Nodes", "Zones", "Hatching", "PetInventory", "Rebirth", "Rewards", "Codes" } do
	expect(table.find(systems, gone) == nil, `out-of-scope system {gone} is still in the place`)
end
for _, gone in { "Hatch", "Gates", "PetFollow", "PetsPanel", "RebirthPanel", "RewardsPanel" } do
	expect(table.find(controllers, gone) == nil, `out-of-scope controller {gone} is still in the place`)
end

local ws = game:GetService("Workspace")
expect(ws.StreamingEnabled == true, "StreamingEnabled")
expect(ws.StreamingMinRadius == 96, "StreamingMinRadius 96")
expect(ws.StreamingTargetRadius == 384, "StreamingTargetRadius 384")
expect(ws:FindFirstChild("World") == nil, "no authored World: the server builds it from Config/WorldLayout")
local lighting = game:GetService("Lighting")

local moduleCount = 0
for _, descendant in game:GetDescendants() do
	if descendant.ClassName == "ModuleScript" then
		moduleCount += 1
	end
end

print(`place: {path} ({#fs.readFile(path)} bytes)`)
print(`server systems ({#systems}): {table.concat(serverOrder, ", ")}`)
print(`client controllers ({#controllers}): {table.concat(clientOrder, ", ")}`)
print(`shared config: {table.concat(children(shared:FindFirstChild("Config"), "ModuleScript"), ", ")}`)
print(`shared util: {table.concat(children(shared:FindFirstChild("Util"), "ModuleScript"), ", ")}`)
print(
	`module scripts: {moduleCount}; Lighting ClockTime {lighting.ClockTime}, Brightness {lighting.Brightness}`
)
for _, message in problems do
	print(`PROBLEM  {message}`)
end
print(if #problems == 0 then "build inspection: OK" else `build inspection: {#problems} problem(s)`)
process.exit(if #problems == 0 then 0 else 1)
