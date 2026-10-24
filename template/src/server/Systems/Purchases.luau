--!strict
-- Purchases: pass ownership, idempotent developer-product receipts, server boosts, and the per-player
-- paid-random-item policy (vault: 09-monetization/*.md, 13-building-it-right/data-persistence.md).
--
-- Receipt rules: grant only in ProcessReceipt; remember PurchaseId in the profile; save before returning
-- PurchaseGranted; return NotProcessedYet on any doubt (Roblox retries, including on the next join).
-- Purchases can arrive from outside the game UI (Roblox Shop surfaces), so nothing here assumes a prompt.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Game = require(Shared.Config.Game)
local Net = require(Shared.Net)
local Products = require(Shared.Config.Products)
local Signal = require(Shared.Util.Signal)
local TableUtil = require(Shared.Util.TableUtil)

local Analytics = require(script.Parent.Parent.Services.Analytics)
local Policy = require(script.Parent.Parent.Services.Policy)
local Currency = require(script.Parent.Currency)
local Grants = require(script.Parent.Grants)
local PlayerData = require(script.Parent.PlayerData)

local Purchases = {}

-- (player, productKey)
Purchases.ProductGranted = Signal.new() :: Signal.Signal<Player, string>
-- (player, passKey)
Purchases.PassOwned = Signal.new() :: Signal.Signal<Player, string>

local IAP = Enum.AnalyticsEconomyTransactionType.IAP.Name
local LOAD_WAIT_SECONDS = 10

local passById: { [number]: Products.PassDef } = {}
for _, pass in Products.Passes do
	if pass.id ~= 0 then
		passById[pass.id] = pass
	end
end

local serverLuckUntil = 0

-- Whether this product may be sold to (and granted for) this player under their policy.
function Purchases.allowedFor(player: Player, product: Products.ProductDef): boolean
	if product.fundsRandomItems or product.probabilityModifier then
		local session = PlayerData.session(player)
		return session ~= nil and not session.randomItemsRestricted
	end
	return true
end

local function setPass(player: Player, pass: Products.PassDef)
	local session = PlayerData.session(player)
	if session and not session.passes[pass.key] then
		session.passes[pass.key] = true
		PlayerData.sessionChanged(player, "passes")
		Purchases.PassOwned:Fire(player, pass.key)
	end
end

local function loadPasses(player: Player)
	for _, pass in Products.Passes do
		if pass.id ~= 0 then
			for attempt = 1, 3 do
				local ok, owns = pcall(function()
					return MarketplaceService:UserOwnsGamePassAsync(player.UserId, pass.id)
				end)
				if ok then
					if owns then
						setPass(player, pass)
					end
					break
				end
				task.wait(attempt)
			end
		end
	end
end

local function applyServerLuck(player: Player)
	local session = PlayerData.session(player)
	if session and session.serverLuckUntil ~= serverLuckUntil then
		session.serverLuckUntil = serverLuckUntil
		PlayerData.sessionChanged(player, "serverLuckUntil")
	end
end

local function grantServerBoost(buyer: Player, seconds: number)
	serverLuckUntil = math.max(serverLuckUntil, os.time()) + seconds
	for _, player in Players:GetPlayers() do
		applyServerLuck(player)
	end
	Net.toAll("Announce", {
		userId = buyer.UserId,
		name = buyer.DisplayName,
		kind = "serverLuck",
		rarity = "",
		global = false,
	})
end

local function grant(player: Player, product: Products.ProductDef, grantDef: Products.ProductGrant): boolean
	if grantDef.kind == "coinsMinutes" then
		local coins = math.max(1, Grants.coinsForMinutes(player, grantDef.minutes))
		Currency.add(player, "Coins", coins, IAP, product.key)
	elseif grantDef.kind == "gems" then
		Currency.add(player, "Gems", grantDef.amount, IAP, product.key)
	elseif grantDef.kind == "boost" then
		Grants.boost(player, grantDef.boost, grantDef.seconds)
	elseif grantDef.kind == "serverBoost" then
		grantServerBoost(player, grantDef.seconds)
	elseif grantDef.kind == "bundle" then
		for _, inner in grantDef.grants do
			grant(player, product, inner)
		end
	end
	return true
end

local function waitForData(player: Player)
	local deadline = os.clock() + LOAD_WAIT_SECONDS
	while not PlayerData.isLoaded(player) and player.Parent and os.clock() < deadline do
		task.wait(0.25)
	end
	return PlayerData.get(player)
end

local function processReceipt(receipt: { [string]: any }): Enum.ProductPurchaseDecision
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet -- granted when they next join
	end
	local data = waitForData(player)
	if not data then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local purchaseId = tostring(receipt.PurchaseId)
	if table.find(data.receipts, purchaseId) then
		return Enum.ProductPurchaseDecision.PurchaseGranted -- already granted (saved earlier)
	end
	local product = Products.productById[receipt.ProductId]
	if not product then
		warn(`[Purchases] unknown product id {receipt.ProductId}`)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	if not Purchases.allowedFor(player, product) then
		-- Restricted players are never shown these products; a purchase from another surface is held.
		warn(`[Purchases] {product.key} not available for player {player.UserId} under their policy`)
		Net.toClient(
			player,
			"Toast",
			{ text = `{product.name} isn't available for your account.`, kind = "error" }
		)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local ok, err = pcall(grant, player, product, product.grant)
	if not ok then
		warn(`[Purchases] grant failed for {product.key}: {err}`)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	table.insert(data.receipts, purchaseId)
	TableUtil.trimFront(data.receipts, Game.maxReceiptsKept)
	if product.oncePerPlayer then
		data.oneTimeProducts[product.key] = true
	end
	PlayerData.changed(player, "receipts", "oneTimeProducts")

	if not PlayerData.saveNow(player) then
		-- The grant stays in memory with its receipt id, so a retry on this server will not grant twice.
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	Analytics.shopFunnel(player, 3, "Purchased")
	Net.toClient(player, "Toast", { text = `Thank you! {product.name} received.`, kind = "reward" })
	Purchases.ProductGranted:Fire(player, product.key)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

local function onLoaded(player: Player)
	local session = PlayerData.session(player)
	if not session then
		return
	end
	local info = Policy.load(player)
	if PlayerData.session(player) ~= session then
		return -- left while the policy loaded
	end
	session.randomItemsRestricted = info.paidRandomItemsRestricted
	PlayerData.sessionChanged(player, "randomItemsRestricted")
	applyServerLuck(player)
	loadPasses(player)
end

function Purchases.init()
	MarketplaceService.ProcessReceipt = processReceipt
end

function Purchases.start()
	PlayerData.Loaded:Connect(onLoaded)
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(
		function(player: Player, passId: number, purchased: boolean)
			local pass = passById[passId]
			if purchased and pass then
				setPass(player, pass)
				Net.toClient(player, "Toast", { text = `Thank you! {pass.name} is active.`, kind = "reward" })
			end
		end
	)
end

-- QA: grant a pass for this session only (Studio / allowlisted testers).
function Purchases.qaGrantPass(player: Player, passKey: string): boolean
	local pass = Products.passByKey[passKey]
	if not pass then
		return false
	end
	local session = PlayerData.session(player)
	if session and not session.passes[pass.key] then
		session.passes[pass.key] = true
		PlayerData.sessionChanged(player, "passes")
		Purchases.PassOwned:Fire(player, pass.key)
	end
	return true
end

-- QA: run a product grant without a receipt.
function Purchases.qaGrantProduct(player: Player, productKey: string): boolean
	local product = Products.productByKey[productKey]
	if not product then
		return false
	end
	grant(player, product, product.grant)
	return true
end

return Purchases
