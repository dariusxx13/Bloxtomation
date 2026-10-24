--!strict
-- THE client entry point. Mounts the UI root, then runs every controller's init() (build UI, connect
-- remotes) before any start() (loops, input). Controllers render server state; they never own it.

local Root = require(script.UI.Root)
Root.mount()

type Controller = { init: (() -> ())?, start: (() -> ())? }

local ORDER = {
	"State",
	"Toasts",
	"HUD",
	"Shop",
	"PetsPanel",
	"RebirthPanel",
	"RewardsPanel",
	"SettingsPanel",
	"Hatch",
	"Gates",
	"Interact",
	"PetFollow",
	"Guide",
}

local controllers: { Controller } = {}
local listed: { [string]: boolean } = {}
for _, name in ORDER do
	listed[name] = true
	local moduleScript = script.Controllers:FindFirstChild(name)
	assert(moduleScript and moduleScript:IsA("ModuleScript"), `missing controller {name}`)
	table.insert(controllers, require(moduleScript) :: any)
end
for _, child in script.Controllers:GetChildren() do
	if child:IsA("ModuleScript") and not listed[child.Name] then
		warn(`[Client] controller {child.Name} is not in the startup ORDER and will not run`)
	end
end

for _, controller in controllers do
	if controller.init then
		controller.init()
	end
end
for _, controller in controllers do
	if controller.start then
		controller.start()
	end
end
