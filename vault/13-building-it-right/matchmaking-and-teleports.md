---
title: Matchmaking and teleports
date: 2026-10-24
tags: [engineering, matchmaking, teleports, reserved-servers, lobbies, rounds, multi-place]
aliases: [TeleportService, Reserved servers, Custom matchmaking, Lobby and match places, Skill matchmaking]
summary: How players get into the right server - Roblox's server matchmaking with signals, weights and custom attributes; multi-place games and TeleportService (TeleportAsync, TeleportOptions, reserved servers, teleport data, access control and failure handling); lobby-to-match flows, skill queues, parties and round-based games.
audience: [human, agent]
---

# Matchmaking and teleports

Who a player plays with shapes everything: friends together, similar skill, the same language, a full but not crowded server. Roblox now lets games tune which public server a player joins, and `TeleportService` moves players between places and private match servers. This note covers both. Cross-server queues are in [MemoryStore and cross-server systems](memorystore-and-cross-server.md); social design in [Viral and social mechanics](../21-hits-and-trends/viral-and-social-mechanics.md).

## Roblox server matchmaking (Fact, creator docs, accessed 2026-10-24)

When a player joins a place, Roblox finds eligible servers (not full, private, reserved or shutting down), **scores** each with a weighted sum of signals, and sends the player to the highest-scoring server.

### Default signals

| Signal | What it measures |
|---|---|
| Age | Difference between the server's average age and the player's (max relevant difference 25) |
| Device Type | Share of players on the same device type |
| Friends | Whether a friend (or someone on the same IP address) is in the server |
| Latency | Extra ping above the player's best reachable datacenter (max relevant 100 ms) |
| Language | Share of players with the same language |
| Occupancy | How full the server is |
| Play History | Difference in time played in the game over 28 days (log scale) |
| Voice Chat | Share with the same voice chat setting |
| Text Chat | Share of players who can text chat with the joining player |

### Custom matchmaking

In the Creator Dashboard (Configurations, Custom matchmaking), games can create configurations that change signal **weights**, add up to **two custom signals** based on **custom attributes** (for example a skill rating or a preferred mode stored in data stores), preview results on mock servers, and apply configurations per place. Matchmaking analytics show how configurations perform.

Uses:

- **Competitive games:** add a skill-rating signal so public servers group similar players.
- **Co-op and social games:** raise the Friends and Language weights.
- **Large worlds:** raise Occupancy so servers fill and feel alive.
- **Mobile-heavy games:** a Device Type weight can group touch players (useful for PvP fairness).

Server matchmaking chooses a public server; it does not form teams or start matches. For that, use teleports.

## Multi-place games and TeleportService

Large games split into places: a lobby, worlds, dungeons, match arenas. `TeleportService` moves players between them.

### The essentials (Fact, creator docs)

- **`TeleportService:TeleportAsync(placeId, players, options?)`** from the **server**. The client-side `Teleport` method is deprecated for new work.
- **`TeleportOptions`** customises the teleport:
  - `ServerInstanceId` sends players to a specific public server;
  - `ReservedServerAccessCode` sends them to a specific reserved server;
  - `ShouldReserveServer = true` creates a new reserved server for the group.
- **Teleport data:** `TeleportOptions:SetTeleportData()` sends basic data, read on arrival with `Player:GetJoinData().TeleportData` (or on the client with `GetLocalPlayerTeleportData`). It is **visible to the client and unencrypted**: never send currency, inventory or anything secure this way; use data stores or memory stores for that.
- **Failures:** wrap teleports in `pcall` with retries (especially for reserved servers), and handle `TeleportService.TeleportInitFailed`, which fires when a teleport fails late without throwing.
- **Custom loading screen:** `TeleportService:SetTeleportGui()` on the client; scripts inside that GUI do not run.
- **Studio:** teleports do not work in Studio playtests; test in published games.

### Access control for places

| Setting | Effect |
|---|---|
| Fully open | Players can join any place from anywhere (invites, deep links, joining friends) |
| Limited to same universe | Non-start places only reachable by teleports within the game (client or server teleports) |
| Secure within universe only | Non-start places only reachable by server-initiated teleports |

Use **Secure** for games with gated progression, reserved-only match places, or test places. A place-level **Direct Access Control** setting overrides the game setting for one place. Teleports to games you do not own also require "Allow Third Party Teleports".

## A safe teleport module (sketch)

```lua
--!strict
-- SafeTeleport (sketch): server-only teleports with retries; data never travels in teleport data.
local TeleportService = game:GetService("TeleportService")

local ATTEMPTS = 3
local RETRY_DELAY = 2

local SafeTeleport = {}

function SafeTeleport.go(placeId: number, players: { Player }, options: TeleportOptions?): boolean
	for attempt = 1, ATTEMPTS do
		local ok, err = pcall(function()
			TeleportService:TeleportAsync(placeId, players, options)
		end)
		if ok then
			return true
		end
		warn(`Teleport attempt {attempt} failed: {err}`)
		task.wait(RETRY_DELAY * attempt)
	end
	return false
end

TeleportService.TeleportInitFailed:Connect(function(player, result, message)
	warn(`Teleport failed late for {player.Name}: {result.Name} {message}`)
	-- Return the player to a safe state; optionally retry once.
end)

return SafeTeleport
```

Before any teleport, **save the player's data** (or rely on session locking that releases on leave and claims on arrival), so the destination never loads stale data ([Data persistence](data-persistence.md)).

## Lobby-to-match flows

### Simple rounds in one server

Many party, social deduction and survival games run rounds inside the same server: intermission, map vote, round, results, repeat. No teleports, no matchmaking beyond Roblox's server choice ([Party and minigames playbook](../14-genre-playbooks/party-and-minigames.md)).

### Lobby plus reserved match servers

```text
Lobby place: players join parties or queue pads
  -> enough players or the party leader starts
  -> server creates a reserved server (ShouldReserveServer) and teleports the group
Match place: reads the match config (mode, map) from a MemoryStore key or teleport data (non-secure only)
  -> plays the match -> saves results -> teleports everyone back to the lobby
```

Reserved servers are private: only players teleported in with the access code can join. Store the access code and match details in a MemoryStore hash map if late joiners or reconnects must be supported.

### Skill-based queues across lobbies

Use a sharded MemoryStore queue of `{userId, rating, mode, joinedAt}` and one elected matchmaker server that forms groups of similar rating, widening the acceptable range as waiting time grows (for example ±100 rating, plus 50 every 15 seconds). Then reserve and teleport. See [MemoryStore and cross-server systems](memorystore-and-cross-server.md).

### Parties

Players who should stay together (friends, a party UI group, `Player.PartyId` when available) are teleported in the same `TeleportAsync` call so they land in the same server. Keep party size within the match place's capacity.

## Design rules

| Rule | Why |
|---|---|
| Keep players in one place unless separation is needed | Teleports cost load time and lose players |
| Show a custom teleport screen with what is happening | Waiting without feedback feels broken |
| Queue times visible, with a fallback (bots, smaller matches, or solo mode) | Empty queues kill competitive modes at low player counts |
| Return players to the lobby with rewards shown | The loop continues instead of ending at a loading screen |
| Make the start place the best first impression | New players always arrive there |

## For agents

- [ ] Teleports run only on the server through one safe module with retries and late-failure handling.
- [ ] No secure data in teleport data; data is saved before teleports.
- [ ] Access control for places matches the design (Secure for gated or reserved-only places).
- [ ] Custom matchmaking weights and signals are documented with the reason for each.
- [ ] Queues have visible wait times and a fallback for low population.

Sources: [Matchmaking](https://create.roblox.com/docs/matchmaking) · [Customize matchmaking](https://create.roblox.com/docs/matchmaking/customize-matchmaking) · [Attributes and signals](https://create.roblox.com/docs/matchmaking/attributes-and-signals) · [Server scoring](https://create.roblox.com/docs/matchmaking/scoring) · [Teleport between places](https://create.roblox.com/docs/projects/teleport) · [TeleportOptions](https://create.roblox.com/docs/reference/engine/classes/TeleportOptions)

Related: [MemoryStore and cross-server systems](memorystore-and-cross-server.md) · [Data persistence](data-persistence.md) · [Social systems](../10-retention-and-social/social-systems.md) · [Shooters and PvP playbook](../14-genre-playbooks/shooters-and-pvp.md) · [Party and minigames playbook](../14-genre-playbooks/party-and-minigames.md)
