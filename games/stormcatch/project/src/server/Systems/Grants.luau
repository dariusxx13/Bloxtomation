--!strict
-- Grants: pays product rewards (coins as "minutes of income", personal boosts). Purchases uses it; the
-- prototype sells nothing (every id is 0), so it only runs at the build stage or from a QA grant.
-- Minutes of income = the expected Clear catch at the player's Rod level x Economy.assumedCatchesPerMinute.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Economy = require(Shared.Config.Economy)
local Products = require(Shared.Config.Products)
local Stats = require(Shared.Util.Stats)

local PlayerData = require(script.Parent.PlayerData)

local Grants = {}

function Grants.coinsForMinutes(player: Player, minutes: number): number
	local data = PlayerData.get(player)
	local derived = PlayerData.derived(player)
	if not data or not derived then
		return 0
	end
	return Stats.coinsForMinutes(data, derived, minutes, Economy.assumedCatchesPerMinute)
end

-- Extends a personal boost. Stacking adds time instead of multiplying the effect.
function Grants.boost(player: Player, boostId: string, seconds: number): boolean
	local data = PlayerData.get(player)
	if not data or (Products.boostEffects :: any)[boostId] == nil or seconds <= 0 then
		return false
	end
	local now = os.time()
	data.boosts[boostId] = math.max(data.boosts[boostId] or 0, now) + math.floor(seconds)
	PlayerData.changed(player, "boosts")
	return true
end

-- Drops expired boosts so profiles stay small.
local function pruneBoosts(player: Player)
	local data = PlayerData.get(player)
	if not data then
		return
	end
	local now = os.time()
	local changed = false
	for boostId, expiry in data.boosts do
		if expiry <= now then
			data.boosts[boostId] = nil
			changed = true
		end
	end
	if changed then
		PlayerData.changed(player, "boosts")
	end
end

function Grants.init() end

function Grants.start()
	PlayerData.Loaded:Connect(pruneBoosts)
end

return Grants
