--!strict
-- Nodes: the core action. Clients send "Hit(nodeId)"; the server validates everything (rate, cooldown,
-- distance, zone access, node state) and decides the reward. The client only predicts visuals.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Economy = require(Shared.Config.Economy)
local Net = require(Shared.Net)
local Signal = require(Shared.Util.Signal)
local Stats = require(Shared.Util.Stats)
local Validate = require(Shared.Util.Validate)

local Analytics = require(script.Parent.Parent.Services.Analytics)
local LiveConfig = require(script.Parent.Parent.Services.LiveConfig)
local Currency = require(script.Parent.Currency)
local PlayerData = require(script.Parent.PlayerData)
local World = require(script.Parent.World)

local Nodes = {}

-- (player, nodeId, coinsEarned, broke)
Nodes.Hit = Signal.new() :: Signal.Signal<Player, string, number, boolean>

local lastHit: { [Player]: number } = {}
local LATENCY_RANGE_MARGIN = 8 -- studs of tolerance for network delay
local COOLDOWN_TOLERANCE = 0.8 -- accept hits slightly faster than the cooldown (jitter)
local EFFECT_RADIUS = 120

local function onHit(player: Player, nodeId: unknown)
	if not Validate.identifier(nodeId, 64) then
		return
	end
	local id = nodeId :: string
	local data = PlayerData.get(player)
	local derived = PlayerData.derived(player)
	local node = World.node(id)
	if not data or not derived or not node then
		return
	end
	if node:GetAttribute("Broken") == true then
		return
	end
	local zoneId = node:GetAttribute("ZoneId")
	if type(zoneId) ~= "string" or not data.zonesUnlocked[zoneId] then
		return
	end
	if World.distanceTo(player, node.Position) > Economy.hitRange + LATENCY_RANGE_MARGIN then
		return
	end
	local now = os.clock()
	local previous = lastHit[player]
	if previous and now - previous < Economy.hitCooldownSeconds * COOLDOWN_TOLERANCE then
		return
	end
	lastHit[player] = now

	local value = derived.coinsPerHit
		* Stats.zoneMultiplier(zoneId)
		* LiveConfig.get("nodeValueMultiplier") :: number
	local hp = ((node:GetAttribute("Hp") :: number?) or 0) + 1
	local broke = hp >= Economy.nodeHitsToBreak
	local earned = value
	if broke then
		earned += value * Economy.nodeBreakBonusHits
		node:SetAttribute("Hp", 0)
		node:SetAttribute("Broken", true)
		task.delay(Economy.nodeRespawnSeconds, function()
			node:SetAttribute("Broken", false)
		end)
	else
		node:SetAttribute("Hp", hp)
	end

	Currency.add(
		player,
		"Coins",
		earned,
		Enum.AnalyticsEconomyTransactionType.Gameplay.Name,
		"node_hit",
		true
	)
	data.stats.hits += 1
	PlayerData.changed(player, "stats")
	Analytics.countHit(player)
	Net.toNearby(node.Position, EFFECT_RADIUS, player, "HitEffect", id, broke)
	Nodes.Hit:Fire(player, id, earned, broke)
end

function Nodes.init() end

function Nodes.start()
	Net.handle("Hit", onHit)
	PlayerData.Removing:Connect(function(player: Player)
		lastHit[player] = nil
	end)
end

return Nodes
