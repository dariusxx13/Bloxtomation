--!strict
-- Analytics names in one place so they never drift (vault: 13-building-it-right/analytics-instrumentation.md).
-- Event names are stable forever; variation goes into custom fields, not names.
-- Roblox custom events carry a value and at most three custom fields (Services/Analytics), so each event
-- keeps the GDD v3.1 §10 fields that segment well; high-cardinality fields (kg, lineSeconds) live in the
-- QA catch log instead. The prototype has no Auto Reel, Easier reeling or Sky Bell, so `auto`, `assist`
-- and `called` are always false/"natural" and are not sent.

return table.freeze({
	currencies = table.freeze({ coins = "Coins", gems = "Gems" }),
	customEvents = table.freeze({
		cast = "Cast", -- value 1; fields: spot, weather
		catch = "Catch", -- value = coins; fields: species, weather, mark ("none" if unmarked)
		reelResult = "ReelResult", -- value = taps; fields: mode, result (landed | escaped), misses
		frontEntered = "FrontEntered", -- value 1; fields: weather, spot, source (natural | forced)
		stormJoined = "StormJoined", -- value = minutes since first join; field: role (eye | helper)
		stormLanded = "StormLanded", -- value = helpers; field: charged (charged | plain)
		uiOpened = "UiOpened", -- field: panel
	}),
	funnels = table.freeze({
		shop = "Shop",
	}),
	hitBatchSeconds = 30, -- catch coin sources are batched per player to respect analytics rate limits
})
