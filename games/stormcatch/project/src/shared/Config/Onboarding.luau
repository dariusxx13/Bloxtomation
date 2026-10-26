--!strict
-- Onboarding funnel steps (vault: 01-first-five-minutes/measuring-onboarding.md; GDD v3.1 §3.3; brief req. 10).
-- NEVER renumber steps after launch; add new steps at the end or start a new funnel version. The prototype
-- uses steps 1-7 exactly as numbered in GDD §3.3, so nothing is renumbered later.
-- `guide` tells the client what to point at while the player is on this step.

export type StepDef = {
	step: number,
	name: string,
	guide: "none" | "node" | "shop" | "upgradePower" | "weather",
	hint: string,
}

local Steps: { StepDef } = {
	{ step = 1, name = "Joined", guide = "none", hint = "" },
	{ step = 2, name = "First Cast", guide = "node", hint = "Tap to cast" },
	{ step = 3, name = "First Catch", guide = "node", hint = "Tap on green!" },
	{ step = 4, name = "Earned Rod Coins", guide = "node", hint = "Catch more fish" },
	{ step = 5, name = "Opened Shop", guide = "shop", hint = "Open the shop" },
	{ step = 6, name = "First Rod Upgrade", guide = "upgradePower", hint = "Buy a better rod" },
	{ step = 7, name = "Caught in Rain", guide = "weather", hint = "Fish in the rain!" },
}

return table.freeze({
	steps = Steps,
	lastStep = #Steps,
	coinsForStep4 = 15, -- the Rod's first cost (economy sheet §14)
	upgradeForStep6 = "rod",
})
