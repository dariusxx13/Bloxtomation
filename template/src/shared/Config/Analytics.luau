--!strict
-- Analytics names in one place so they never drift (vault: 13-building-it-right/analytics-instrumentation.md).
-- Event names are stable forever; variation goes into custom fields, not names.

return table.freeze({
	currencies = table.freeze({ coins = "Coins", gems = "Gems" }),
	customEvents = table.freeze({
		hits = "Hits", -- value = hits in batch
		hatch = "HatchEgg", -- fields: egg, rarity
		rebirth = "Rebirth",
		zoneUnlocked = "ZoneUnlocked", -- field: zone
		codeRedeemed = "CodeRedeemed", -- field: code
		dailyClaimed = "DailyClaimed", -- field: day
		playtimeClaimed = "PlaytimeClaimed", -- field: gift index
		offerShown = "OfferShown",
		uiOpened = "UiOpened", -- field: panel
	}),
	funnels = table.freeze({
		shop = "Shop",
	}),
	hitBatchSeconds = 30, -- hit counts are batched per player to respect analytics rate limits
})
