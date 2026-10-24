--!strict
-- Currency: the ONLY module that changes coin and gem balances. Every change is validated, logged to
-- economy analytics (or batched for high-frequency sources) and replicated.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local AnalyticsConfig = require(Shared.Config.Analytics)
local Signal = require(Shared.Util.Signal)

local Analytics = require(script.Parent.Parent.Services.Analytics)
local PlayerData = require(script.Parent.PlayerData)

export type CurrencyId = "Coins" | "Gems"

local Currency = {}

-- (player, currency, newBalance, delta)
Currency.Changed = Signal.new() :: Signal.Signal<Player, CurrencyId, number, number>

local FIELD: { [CurrencyId]: string } = { Coins = "coins", Gems = "gems" }

local function validAmount(amount: number): boolean
	return amount == amount and amount > 0 and amount < math.huge
end

function Currency.balance(player: Player, currency: CurrencyId): number
	local data = PlayerData.get(player)
	if not data then
		return 0
	end
	return (data :: any)[FIELD[currency]] or 0
end

-- Adds currency. `batch = true` aggregates analytics for high-frequency sources (hits).
function Currency.add(
	player: Player,
	currency: CurrencyId,
	amount: number,
	transactionType: string,
	sku: string?,
	batch: boolean?
): boolean
	local data = PlayerData.get(player)
	if not data or not validAmount(amount) then
		return false
	end
	local field = FIELD[currency]
	local newBalance = ((data :: any)[field] :: number) + amount;
	(data :: any)[field] = newBalance
	if currency == "Coins" then
		data.stats.totalCoinsEarned += amount
	end
	PlayerData.changed(player, field)
	local analyticsName = if currency == "Coins"
		then AnalyticsConfig.currencies.coins
		else AnalyticsConfig.currencies.gems
	if batch then
		Analytics.batchSource(player, analyticsName, amount, transactionType, sku)
	else
		Analytics.economy(player, "Source", analyticsName, amount, newBalance, transactionType, sku)
	end
	Currency.Changed:Fire(player, currency, newBalance, amount)
	return true
end

-- Spends currency if the balance covers it. Returns false (and changes nothing) otherwise.
function Currency.trySpend(
	player: Player,
	currency: CurrencyId,
	amount: number,
	transactionType: string,
	sku: string?
): boolean
	local data = PlayerData.get(player)
	if not data or not validAmount(amount) then
		return false
	end
	local field = FIELD[currency]
	local balance = (data :: any)[field] :: number
	if balance < amount then
		return false
	end
	local newBalance = balance - amount;
	(data :: any)[field] = newBalance
	PlayerData.changed(player, field)
	local analyticsName = if currency == "Coins"
		then AnalyticsConfig.currencies.coins
		else AnalyticsConfig.currencies.gems
	Analytics.economy(player, "Sink", analyticsName, amount, newBalance, transactionType, sku)
	Currency.Changed:Fire(player, currency, newBalance, -amount)
	return true
end

-- Sets coins to zero (rebirth). Logged as a sink.
function Currency.resetCoins(player: Player, transactionType: string, sku: string?)
	local balance = Currency.balance(player, "Coins")
	if balance > 0 then
		Currency.trySpend(player, "Coins", balance, transactionType, sku)
	end
end

function Currency.init() end

function Currency.start()
	Analytics.startBatching(function(player: Player, currency: string): number
		return Currency.balance(
			player,
			if currency == AnalyticsConfig.currencies.gems then "Gems" else "Coins"
		)
	end)
	PlayerData.Removing:Connect(function(player: Player)
		Analytics.flush(player, function(p: Player, currency: string): number
			return Currency.balance(
				p,
				if currency == AnalyticsConfig.currencies.gems then "Gems" else "Coins"
			)
		end)
	end)
end

return Currency
