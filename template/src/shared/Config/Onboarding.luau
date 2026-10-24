--!strict
-- Onboarding funnel steps (vault: 01-first-five-minutes/measuring-onboarding.md).
-- NEVER renumber steps after launch; add new steps at the end or start a new funnel version.
-- `guide` tells the client what to point at while the player is on this step.

export type StepDef = {
	step: number,
	name: string,
	guide: "none" | "node" | "shop" | "upgradePower" | "egg" | "pets" | "gate",
	hint: string,
}

local Steps: { StepDef } = {
	{ step = 1, name = "Joined", guide = "none", hint = "" },
	{ step = 2, name = "First Move", guide = "node", hint = "Walk to a crystal" },
	{ step = 3, name = "First Hit", guide = "node", hint = "Tap the crystal!" },
	{ step = 4, name = "Earned 15 Coins", guide = "node", hint = "Keep tapping" },
	{ step = 5, name = "Opened Shop", guide = "shop", hint = "Open the shop" },
	{ step = 6, name = "First Upgrade", guide = "upgradePower", hint = "Buy Power" },
	{ step = 7, name = "50 Hits", guide = "node", hint = "Earn coins for an egg" },
	{ step = 8, name = "First Hatch", guide = "egg", hint = "Hatch an egg" },
	{ step = 9, name = "Equipped Pet", guide = "pets", hint = "Equip your pet" },
	{ step = 10, name = "Zone 2 Unlocked", guide = "gate", hint = "Unlock the next zone" },
	{ step = 11, name = "Played 10 Minutes", guide = "none", hint = "" },
}

return table.freeze({
	steps = Steps,
	lastStep = #Steps,
	coinsForStep4 = 15,
	hitsForStep7 = 50,
	minutesForStep11 = 10,
})
