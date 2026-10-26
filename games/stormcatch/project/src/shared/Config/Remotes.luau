--!strict
-- Every remote in the game, declared once (vault: 13-building-it-right/networking-and-remotes.md).
-- kind: "event" (client <-> server fire), "function" (client invokes server), "unreliable" (cosmetic server -> client)
-- rate/burst: token bucket per player for client -> server traffic. Server -> client remotes have no limit.
-- Fishing limits are the brief's proposals (prototype req. 13): Cast 2/s burst 3, HookTap 4/s burst 6,
-- ReelTap 8/s burst 12, PullTap 6/s burst 10.

export type RemoteKind = "event" | "function" | "unreliable"
export type RemoteDef = { kind: RemoteKind, rate: number?, burst: number? }

local Remotes: { [string]: RemoteDef } = {
	-- client -> server
	Cast = { kind = "function", rate = 2, burst = 3 }, -- (spotId) -> { ok, reason?, lineId? }
	HookTap = { kind = "event", rate = 4, burst = 6 }, -- () Sea Fog hook
	ReelTap = { kind = "event", rate = 8, burst = 12 }, -- () one ring tap
	PullTap = { kind = "event", rate = 6, burst = 10 }, -- () help the nearest Stormborn pull
	BuyUpgrade = { kind = "function", rate = 8, burst = 12 },
	SetSetting = { kind = "event", rate = 4, burst = 8 },
	UiEvent = { kind = "event", rate = 4, burst = 8 },
	RequestSnapshot = { kind = "function", rate = 0.2, burst = 2 },
	QACommand = { kind = "function", rate = 5, burst = 10 },

	-- server -> client
	StateSnapshot = { kind = "event" },
	StateDelta = { kind = "event" },
	Toast = { kind = "event" },
	Announce = { kind = "event" },
	Bite = { kind = "event" }, -- Types.BitePayload
	ReelState = { kind = "event" }, -- Types.ReelStatePayload
	CatchResult = { kind = "event" }, -- Types.CatchPayload
	WeatherState = { kind = "event" }, -- Types.WeatherStatePayload
	PullState = { kind = "event" }, -- Types.PullStatePayload
	StormState = { kind = "event" }, -- { flashAt: number } lightning, server-timed
}

return table.freeze(Remotes)
