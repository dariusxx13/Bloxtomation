--!strict
-- Soft-currency upgrade lines. cost(level) = round(baseCost * costGrowth ^ level).
-- The prototype has one line, the Rod: the template's `power` line renamed (prototype brief req. 5 and 8;
-- economy sheet v2 §4 and §14). The launch maximum is 150; the prototype stops at 30. If testers stall
-- between minutes 15 and 20, the sheet's lever is costGrowth = 1.24, changed from the QA report only.

export type UpgradeKind = "power"

export type UpgradeDef = {
	id: string,
	kind: UpgradeKind,
	name: string,
	description: string,
	baseCost: number,
	costGrowth: number,
	effect: number,
	maxLevel: number,
	resetsOnRebirth: boolean,
	order: number,
}

local Upgrades: { UpgradeDef } = {
	{
		id = "rod",
		kind = "power",
		name = "Rod",
		description = "Every fish pays more",
		baseCost = 15,
		costGrowth = 1.28,
		effect = 1.14, -- coins per catch multiplied by this per level
		maxLevel = 30,
		resetsOnRebirth = true,
		order = 1,
	},
}

return table.freeze(Upgrades)
