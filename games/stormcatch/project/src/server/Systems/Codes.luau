--!strict
-- Codes: one redemption per player per code, validated and rate limited on the server.
-- Codes are a community and update-marketing tool (vault: 12-live-ops-and-launch/update-cadence.md).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local AnalyticsConfig = require(Shared.Config.Analytics)
local CodeConfig = require(Shared.Config.Codes)
local Net = require(Shared.Net)
local Types = require(Shared.Types)
local Validate = require(Shared.Util.Validate)

local Analytics = require(script.Parent.Parent.Services.Analytics)
local LiveConfig = require(script.Parent.Parent.Services.LiveConfig)
local Grants = require(script.Parent.Grants)
local PlayerData = require(script.Parent.PlayerData)

local Codes = {}

local function onRedeem(player: Player, codeArg: unknown): Types.ActionResult
	if not LiveConfig.flag("featureCodes") then
		return { ok = false, reason = "disabled" }
	end
	if not Validate.identifier(codeArg, CodeConfig.maxLength) then
		return { ok = false, reason = "unknown" }
	end
	local code = string.upper(codeArg :: string)
	local def = CodeConfig.byCode[code]
	local data = PlayerData.get(player)
	if not data then
		return { ok = false, reason = "invalid" }
	end
	if not def then
		return { ok = false, reason = "unknown" }
	end
	if def.expiresAt ~= 0 and os.time() >= def.expiresAt then
		return { ok = false, reason = "expired" }
	end
	if data.codesRedeemed[code] then
		return { ok = false, reason = "used" }
	end
	data.codesRedeemed[code] = true
	PlayerData.changed(player, "codesRedeemed")
	local summary = Grants.reward(player, {
		coinsMinutes = def.coinsMinutes,
		gems = def.gems,
		boost = def.boost,
		boostSeconds = def.boostSeconds,
	}, Enum.AnalyticsEconomyTransactionType.Gameplay.Name, `code_{code}`)
	Analytics.custom(player, AnalyticsConfig.customEvents.codeRedeemed, 1, { code })
	return { ok = true, text = Grants.describe(summary) }
end

function Codes.init() end

function Codes.start()
	Net.handle("RedeemCode", onRedeem)
end

return Codes
