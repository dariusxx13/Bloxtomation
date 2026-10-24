--!strict
-- THE server entry point (vault: 13-building-it-right/project-architecture.md).
-- 1. Remotes are created before anything can register a handler.
-- 2. Every system's init() runs (synchronous wiring), then every start() runs (handlers, loops).
-- 3. PlayerData starts LAST so every Loaded listener is connected before the first profile loads.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)
Net.initServer()

local LiveConfig = require(script.Services.LiveConfig)
LiveConfig.start()

type System = { init: (() -> ())?, start: (() -> ())? }

-- Explicit order keeps startup deterministic. Add new systems here (the check below warns if you forget).
local ORDER = {
	"World",
	"Currency",
	"Grants",
	"Nodes",
	"Upgrades",
	"Zones",
	"Hatching",
	"PetInventory",
	"Rebirth",
	"Rewards",
	"Codes",
	"ClientEvents",
	"Onboarding",
	"Purchases",
	"Social",
	"Leaderstats",
	"Characters",
	"QA",
	"PlayerData",
}

local systems: { { name: string, module: System } } = {}
local listed: { [string]: boolean } = {}
for _, name in ORDER do
	listed[name] = true
	local moduleScript = script.Systems:FindFirstChild(name)
	assert(moduleScript and moduleScript:IsA("ModuleScript"), `missing system {name}`)
	table.insert(systems, { name = name, module = require(moduleScript) :: any })
end
for _, child in script.Systems:GetChildren() do
	if child:IsA("ModuleScript") and not listed[child.Name] then
		warn(`[Server] system {child.Name} is not in the startup ORDER and will not run`)
	end
end

for _, entry in systems do
	local init = entry.module.init
	if init then
		init()
	end
end
for _, entry in systems do
	local start = entry.module.start
	if start then
		start()
	end
end

print(`[Server] started {#systems} systems`)
