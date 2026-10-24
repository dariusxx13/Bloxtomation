--!strict
-- Wrapper around AnalyticsService (vault: 13-building-it-right/analytics-instrumentation.md).
-- All calls are protected; high-frequency sources (hits) are batched to respect analytics rate limits.
-- Events only record in published games; calls in Studio are harmless no-ops.

local AnalyticsService = game:GetService("AnalyticsService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnalyticsConfig = require(ReplicatedStorage.Shared.Config.Analytics)

local Analytics = {}

type Batch = { [string]: { currency: string, amount: number, transactionType: string, sku: string? } }
local batches: { [Player]: Batch } = {}
local hitCounts: { [Player]: number } = {}
local shopFunnels: { [Player]: { id: string, step: number } } = {}

local FIELD_KEYS = {
	Enum.AnalyticsCustomFieldKeys.CustomField01.Name,
	Enum.AnalyticsCustomFieldKeys.CustomField02.Name,
	Enum.AnalyticsCustomFieldKeys.CustomField03.Name,
}

local function fieldsFrom(values: { string }?): { [string]: string }?
	if not values or #values == 0 then
		return nil
	end
	local fields: { [string]: string } = {}
	for i = 1, math.min(#values, 3) do
		fields[FIELD_KEYS[i]] = values[i]
	end
	return fields
end

local function safe(label: string, fn: () -> ...any)
	local ok, err = pcall(fn)
	if not ok then
		warn(`[Analytics] {label} failed: {err}`)
	end
end

function Analytics.onboardingStep(player: Player, step: number, name: string)
	safe("onboarding", function()
		AnalyticsService:LogOnboardingFunnelStepEvent(player, step, name)
	end)
end

function Analytics.funnelStep(player: Player, funnel: string, sessionId: string, step: number, name: string)
	safe("funnel", function()
		AnalyticsService:LogFunnelStepEvent(player, funnel, sessionId, step, name)
	end)
end

-- Shop funnel: step 1 "Opened" starts a new funnel session; later steps reuse it and only move forward.
-- Steps: 1 Opened, 2 Prompted, 3 Purchased (a purchase from outside the shop logs no funnel step).
function Analytics.shopFunnel(player: Player, step: number, name: string)
	local current = shopFunnels[player]
	if step == 1 then
		current = { id = HttpService:GenerateGUID(false), step = 0 }
		shopFunnels[player] = current
	end
	if not current or step <= current.step then
		return
	end
	current.step = step
	Analytics.funnelStep(player, AnalyticsConfig.funnels.shop, current.id, step, name)
end

-- flow: "Source" or "Sink"
function Analytics.economy(
	player: Player,
	flow: "Source" | "Sink",
	currency: string,
	amount: number,
	balanceAfter: number,
	transactionType: string,
	sku: string?,
	fields: { string }?
)
	if amount <= 0 then
		return
	end
	safe("economy", function()
		local flowType = if flow == "Source"
			then Enum.AnalyticsEconomyFlowType.Source
			else Enum.AnalyticsEconomyFlowType.Sink
		AnalyticsService:LogEconomyEvent(
			player,
			flowType,
			currency,
			amount,
			balanceAfter,
			transactionType,
			sku,
			fieldsFrom(fields)
		)
	end)
end

function Analytics.custom(player: Player, eventName: string, value: number?, fields: { string }?)
	safe("custom", function()
		AnalyticsService:LogCustomEvent(player, eventName, value or 1, fieldsFrom(fields))
	end)
end

-- Accumulates a source; flushed periodically by `flush` with the balance at flush time.
function Analytics.batchSource(
	player: Player,
	currency: string,
	amount: number,
	transactionType: string,
	sku: string?
)
	local batch = batches[player]
	if not batch then
		batch = {}
		batches[player] = batch
	end
	local key = `{currency}|{transactionType}|{sku or ""}`
	local entry = batch[key]
	if entry then
		entry.amount += amount
	else
		batch[key] = { currency = currency, amount = amount, transactionType = transactionType, sku = sku }
	end
end

function Analytics.countHit(player: Player)
	hitCounts[player] = (hitCounts[player] or 0) + 1
end

-- `balanceOf(player, currency)` lets the flush report correct balances.
function Analytics.flush(player: Player, balanceOf: (Player, string) -> number)
	local batch = batches[player]
	batches[player] = nil
	if batch then
		for _, entry in batch do
			Analytics.economy(
				player,
				"Source",
				entry.currency,
				entry.amount,
				balanceOf(player, entry.currency),
				entry.transactionType,
				entry.sku
			)
		end
	end
	local hits = hitCounts[player]
	hitCounts[player] = nil
	if hits and hits > 0 then
		Analytics.custom(player, AnalyticsConfig.customEvents.hits, hits)
	end
end

Players.PlayerRemoving:Connect(function(player: Player)
	shopFunnels[player] = nil
end)

function Analytics.startBatching(balanceOf: (Player, string) -> number)
	task.spawn(function()
		while true do
			task.wait(AnalyticsConfig.hitBatchSeconds)
			for _, player in Players:GetPlayers() do
				Analytics.flush(player, balanceOf)
			end
		end
	end)
end

return Analytics
