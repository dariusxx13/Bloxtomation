--!strict
-- Redeemable codes. Keep rewards small; one redemption per player; validated on the server.
-- `expiresAt` is a unix timestamp (0 = never). Codes are matched case-insensitively.

export type CodeDef = {
	code: string,
	gems: number?,
	coinsMinutes: number?,
	boost: string?,
	boostSeconds: number?,
	expiresAt: number,
}

local Codes: { CodeDef } = {
	{ code = "WELCOME", gems = 25, expiresAt = 0 },
	{ code = "LAUNCH", coinsMinutes = 5, boost = "coins2x", boostSeconds = 600, expiresAt = 0 },
}

local byCode: { [string]: CodeDef } = {}
for _, def in Codes do
	byCode[string.upper(def.code)] = def
end

return table.freeze({
	list = Codes,
	byCode = byCode,
	maxLength = 24,
})
