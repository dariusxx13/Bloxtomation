--!strict
-- Rarity tiers and their colours (the template's tiers, moved here from Config/Pets; art direction §2).
-- `luckApplies`: luck multiplies this tier's weight. Natural Sea Fog doubles them (economy sheet §14).

local Types = require("../Types")

export type RarityDef = {
	id: Types.RarityId,
	order: number,
	color: { number },
	luckApplies: boolean,
	announce: "none" | "server" | "global",
}

local Rarities: { RarityDef } = {
	{ id = "Common", order = 1, color = { 200, 200, 200 }, luckApplies = false, announce = "none" },
	{ id = "Uncommon", order = 2, color = { 90, 210, 100 }, luckApplies = false, announce = "none" },
	{ id = "Rare", order = 3, color = { 70, 150, 255 }, luckApplies = true, announce = "none" },
	{ id = "Epic", order = 4, color = { 170, 90, 255 }, luckApplies = true, announce = "none" },
	{ id = "Legendary", order = 5, color = { 255, 190, 40 }, luckApplies = true, announce = "server" },
	{ id = "Mythic", order = 6, color = { 255, 70, 110 }, luckApplies = true, announce = "server" },
	{ id = "Secret", order = 7, color = { 30, 30, 30 }, luckApplies = true, announce = "global" },
}

local byId: { [string]: RarityDef } = {}
for _, rarity in Rarities do
	byId[rarity.id] = rarity
end

return table.freeze({
	list = Rarities,
	byId = byId,
})
