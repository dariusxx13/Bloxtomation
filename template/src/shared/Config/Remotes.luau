--!strict
-- Every remote in the game, declared once (vault: 13-building-it-right/networking-and-remotes.md).
-- kind: "event" (client <-> server fire), "function" (client invokes server), "unreliable" (cosmetic server -> client)
-- rate/burst: token bucket per player for client -> server traffic. Server -> client remotes have no limit.

export type RemoteKind = "event" | "function" | "unreliable"
export type RemoteDef = { kind: RemoteKind, rate: number?, burst: number? }

local Remotes: { [string]: RemoteDef } = {
	-- client -> server
	Hit = { kind = "event", rate = 7, burst = 10 },
	BuyUpgrade = { kind = "function", rate = 8, burst = 12 },
	UnlockZone = { kind = "function", rate = 2, burst = 4 },
	Hatch = { kind = "function", rate = 3, burst = 5 },
	EquipPet = { kind = "function", rate = 8, burst = 12 },
	UnequipPet = { kind = "function", rate = 8, burst = 12 },
	EquipBest = { kind = "function", rate = 2, burst = 3 },
	DeletePets = { kind = "function", rate = 2, burst = 3 },
	LockPet = { kind = "function", rate = 6, burst = 10 },
	Rebirth = { kind = "function", rate = 1, burst = 2 },
	ClaimDaily = { kind = "function", rate = 1, burst = 3 },
	ClaimPlaytime = { kind = "function", rate = 2, burst = 4 },
	RedeemCode = { kind = "function", rate = 0.5, burst = 3 },
	SetSetting = { kind = "event", rate = 4, burst = 8 },
	UiEvent = { kind = "event", rate = 4, burst = 8 },
	RequestSnapshot = { kind = "function", rate = 0.2, burst = 2 },
	QACommand = { kind = "function", rate = 5, burst = 10 },

	-- server -> client
	StateSnapshot = { kind = "event" },
	StateDelta = { kind = "event" },
	Toast = { kind = "event" },
	Announce = { kind = "event" },
	PetsChanged = { kind = "event" },
	HitEffect = { kind = "unreliable" },
}

return table.freeze(Remotes)
