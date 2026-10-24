--!strict
-- PetInventory: equip, unequip, equip best, delete and lock. Pets are data on the server; every client
-- renders the equipped pets of nearby players from PetsChanged broadcasts (vault: 07-characters-vfx-and-assets/characters-npcs-and-pets.md).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local Pets = require(Shared.Config.Pets)
local Signal = require(Shared.Util.Signal)
local TableUtil = require(Shared.Util.TableUtil)
local Types = require(Shared.Types)
local Validate = require(Shared.Util.Validate)

local PlayerData = require(script.Parent.PlayerData)

local PetInventory = {}

-- (player)
PetInventory.EquipChanged = Signal.new() :: Signal.Signal<Player>

local MAX_DELETE = 50

local function findPet(data: Types.ProfileData, petId: string): (Types.OwnedPet?, number?)
	for index, pet in data.pets do
		if pet.id == petId then
			return pet, index
		end
	end
	return nil, nil
end

function PetInventory.equippedKinds(player: Player): { string }
	local data = PlayerData.get(player)
	local kinds: { string } = {}
	if not data then
		return kinds
	end
	for _, id in data.equipped do
		local pet = findPet(data, id)
		if pet then
			table.insert(kinds, pet.kind)
		end
	end
	return kinds
end

local function broadcast(player: Player)
	Net.toAll("PetsChanged", player.UserId, PetInventory.equippedKinds(player))
	PetInventory.EquipChanged:Fire(player)
end

local function onEquip(player: Player, petId: unknown): Types.ActionResult
	if not Validate.identifier(petId, 64) then
		return { ok = false, reason = "invalid" }
	end
	local data = PlayerData.get(player)
	local derived = PlayerData.derived(player)
	if not data or not derived then
		return { ok = false, reason = "invalid" }
	end
	local id = petId :: string
	if not findPet(data, id) then
		return { ok = false, reason = "missing" }
	end
	if TableUtil.indexOf(data.equipped, id) then
		return { ok = true }
	end
	if #data.equipped >= derived.petSlots then
		return { ok = false, reason = "slots" }
	end
	table.insert(data.equipped, id)
	PlayerData.changed(player, "equipped")
	broadcast(player)
	return { ok = true }
end

local function onUnequip(player: Player, petId: unknown): Types.ActionResult
	if not Validate.identifier(petId, 64) then
		return { ok = false, reason = "invalid" }
	end
	local data = PlayerData.get(player)
	if not data then
		return { ok = false, reason = "invalid" }
	end
	local index = TableUtil.indexOf(data.equipped, petId :: string)
	if index then
		table.remove(data.equipped, index)
		PlayerData.changed(player, "equipped")
		broadcast(player)
	end
	return { ok = true }
end

local function onEquipBest(player: Player): Types.ActionResult
	local data = PlayerData.get(player)
	local derived = PlayerData.derived(player)
	if not data or not derived then
		return { ok = false, reason = "invalid" }
	end
	local sorted = table.clone(data.pets)
	table.sort(sorted, function(a, b)
		local defA = Pets.byKind[a.kind]
		local defB = Pets.byKind[b.kind]
		return (defA and defA.bonus or 0) > (defB and defB.bonus or 0)
	end)
	local equipped: { string } = {}
	for i = 1, math.min(derived.petSlots, #sorted) do
		table.insert(equipped, sorted[i].id)
	end
	data.equipped = equipped
	PlayerData.changed(player, "equipped")
	broadcast(player)
	return { ok = true }
end

local function onDelete(player: Player, ids: unknown): Types.ActionResult
	local list = Validate.identifierList(ids, MAX_DELETE, 64)
	local data = PlayerData.get(player)
	if not list or not data then
		return { ok = false, reason = "invalid" }
	end
	local deleteSet: { [string]: boolean } = {}
	for _, id in list do
		deleteSet[id] = true
	end
	local kept: { Types.OwnedPet } = {}
	local removed = 0
	for _, pet in data.pets do
		local protected = pet.locked == true or TableUtil.indexOf(data.equipped, pet.id) ~= nil
		if deleteSet[pet.id] and not protected then
			removed += 1
		else
			table.insert(kept, pet)
		end
	end
	data.pets = kept
	PlayerData.changed(player, "pets")
	return { ok = true, removed = removed }
end

local function onLock(player: Player, petId: unknown, locked: unknown): Types.ActionResult
	if not Validate.identifier(petId, 64) or not Validate.boolean(locked) then
		return { ok = false, reason = "invalid" }
	end
	local data = PlayerData.get(player)
	if not data then
		return { ok = false, reason = "invalid" }
	end
	local pet = findPet(data, petId :: string)
	if not pet then
		return { ok = false, reason = "missing" }
	end
	pet.locked = if locked then true else nil
	PlayerData.changed(player, "pets")
	return { ok = true }
end

function PetInventory.init() end

function PetInventory.start()
	Net.handle("EquipPet", onEquip)
	Net.handle("UnequipPet", onUnequip)
	Net.handle("EquipBest", onEquipBest)
	Net.handle("DeletePets", onDelete)
	Net.handle("LockPet", onLock)
	PlayerData.Loaded:Connect(function(player: Player)
		broadcast(player)
		for _, other in Players:GetPlayers() do
			if other ~= player and PlayerData.isLoaded(other) then
				Net.toClient(player, "PetsChanged", other.UserId, PetInventory.equippedKinds(other))
			end
		end
	end)
end

return PetInventory
