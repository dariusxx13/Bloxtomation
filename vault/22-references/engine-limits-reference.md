---
title: Engine limits reference
date: 2026-10-24
tags: [reference, limits, engineering, datastores, memorystore, physics, vfx, quotas]
aliases: [Roblox limits, Quotas, Technical limits, Rate limits cheat sheet]
summary: One table of the technical limits engineers and agents hit most often on Roblox, each from official documentation and dated - data stores, memory stores, messaging, pathfinding, physics, humanoids, idle disconnects, attributes under server authority, effects, audio, matchmaking, events, badges and more - with the design rule each limit implies.
audience: [human, agent]
---

# Engine limits reference

Limits change; this page records the values in Roblox's documentation as read on **2026-10-24**, so agents can design within them and check them before relying on them. Money, discovery and publishing numbers are in [Key numbers](../99-reference/key-numbers.md). Each section links to the vault note that explains the system.

## Data stores (Fact)

| Limit | Value | Design rule |
|---|---|---|
| Data store name, key name, scope | 50 characters each | Short, static key patterns |
| Value size | 4,194,304 characters per key (about 4 MB) | Cap inventories and logs |
| Metadata | Key name 50, value 250, total 300 characters | Keep metadata tiny |
| Per-key throughput | Reads 25 MB per minute; writes 4 MB per minute per key (rounded up per request to the next KB) | Never write a key in a loop |
| Requests per minute (standard stores, game-wide) | Read 300 + 40 × concurrent users; write 300 + 20 × CCU; list 300 + 2 × CCU; remove 300 + 40 × CCU | `UpdateAsync` counts against both read and write; Open Cloud shares the budget |
| Throttle queues | 30 requests per queue; overflow fails with error codes 301-306 | Retry with backoff; spread saves |
| Storage (latest versions, compressed) | 500 MB + 1 MB × lifetime users | Do not pre-compress; delete unused data |

See [Data persistence](../13-building-it-right/data-persistence.md).

## Memory stores (Fact)

| Limit | Value | Design rule |
|---|---|---|
| Memory quota per game | 64 KB + 1.2 KB × users (drops only after an 8-day traceback) | Short expirations |
| Request units per minute (game) | 1,000 + 120 × concurrent users | Budget for peak players |
| Sorted map or queue size | 1,000,000 items, 100 MB | Shard large structures |
| Per partition | Throttling from about 30,000 request units per minute | Sorted maps and queues are one partition each |
| Per hash map key | About 5,000 write and 15,000 read units per minute | Spread hot keys |
| Default expiration | 45 days | Always set a shorter one |

See [MemoryStore and cross-server systems](../13-building-it-right/memorystore-and-cross-server.md).

## Messaging (Fact)

| Limit | Value |
|---|---|
| Delivery | Best effort, typically within 1-2 seconds, not guaranteed |
| Topic name | 1-80 characters |
| Message size | 1 KB |
| Sent per server | 600 + 240 × players per minute |
| Received per topic | 40 + 80 × servers per minute |
| Received per game | 400 + 200 × servers per minute |
| Subscriptions per server | 20 + 8 × players; subscribe requests 240 per minute |

See [Live events and admin events](../21-hits-and-trends/live-events-and-admin-events.md).

## Characters, movement and AI (Fact)

| Limit | Value | Design rule |
|---|---|---|
| `Humanoid:MoveTo` timeout | 8 seconds without reaching the goal | Re-issue or use waypoints |
| Idle disconnect | About 20 minutes idle; `Player.Idled` fires on the client about 2 minutes after idling, then every 30 s | Warn players; never require AFK |
| Pathfinding distance | 3,000 studs straight-line from start to goal | Path to intermediate points |
| Pathfinding node budget | 20,000 nodes | Simplify large mazes |
| Pathfinding vertical range | Waypoints beyond ±65,536 studs ignored | Keep worlds within range |
| Pathfinding agent defaults | Radius 2, height 5, can jump, cannot climb | Set per NPC type |

See [NPC AI and pathfinding](../13-building-it-right/npc-ai-and-pathfinding.md).

## Physics (Fact)

| Limit | Value |
|---|---|
| Default simulation rate | 240 Hz (about 4 worldsteps per 60 fps frame) |
| Adaptive timestepping | Islands at 240, 120 or 60 Hz; up to about 2.5× faster physics |
| Sleep threshold (linear velocity) | About 0.33 studs per second |
| Anchored parts | Always server-owned |

See [Physics and network ownership](../13-building-it-right/physics-and-network-ownership.md).

## Server authority model (Fact)

| Limit | Value |
|---|---|
| Replicated attributes on predicted instances | Among the first 64 attributes; names up to 50 characters; string values up to 50 characters |
| Required settings | `AuthorityMode = Server` (sets next-generation replication, input action system, deferred signals, fixed simulation, streaming) |

See [Combat systems and hitboxes](../13-building-it-right/combat-systems-and-hitboxes.md).

## Effects and rendering (Fact)

| Limit | Value |
|---|---|
| Particle emission rate | Up to 400 per second per emitter (lower on mobile) |
| Particle lifetime | Capped at 20 seconds |
| Flipbook framerate | Up to 30 fps |
| Flipbook textures | Power-of-two sizes up to 1024, matching the layout |
| Highlights | 255 at once; the first visible one can cost about 1 ms of GPU on mobile |
| Emitters inside unions | Do not render |

See [VFX toolkit reference](../19-vfx/vfx-toolkit-reference.md) and [VFX performance budgets](../19-vfx/vfx-performance-budgets.md).

## Audio (Fact)

| Limit | Value |
|---|---|
| Import formats | `.mp3`, `.ogg`, `.wav`, `.flac`; one track |
| Import size and length | Under 20 MB and 7 minutes; up to 48 kHz; mono, stereo, 3.0 or 5.1 |
| Import quota | 2,000 per 30 days (ID-verified), 100 (unverified) |
| Text to speech | Up to 300 characters per request |

See [Audio systems](../13-building-it-right/audio-systems.md).

## Places, teleports and matchmaking (Fact)

| Limit | Value |
|---|---|
| Teleports in Studio playtests | Not supported; test in published games |
| Teleport data | Visible to the client, unencrypted: no secure data |
| Custom matchmaking signals | 2 per game |
| Latency signal | Maximum relevant extra ping 100 ms |

See [Matchmaking and teleports](../13-building-it-right/matchmaking-and-teleports.md).

## Live ops and promotion (Fact)

| Limit | Value |
|---|---|
| Experience events | Up to 10 ongoing or upcoming events |
| Social media links | Visible only to users verified 16+; not allowed inside games |
| Badges | 5 free per game per 24 hours (GMT); each additional badge costs 100 Robux (a money decision) |
| Share links | No limit per game |

See [Anime community, updates and codes](../20-anime-games/anime-community-updates-and-codes.md) and [Viral and social mechanics](../21-hits-and-trends/viral-and-social-mechanics.md).

## Licensing and pricing (Fact)

| Limit | Value |
|---|---|
| License revenue share rate | 0-95%, fixed once used in an agreement |
| Marketplace license | Up to 100 items per license |
| Standard license offer | Auto-activates after 14 days unless disputed |
| Regional prices | Between 30% and 100% of the default price (never more than 70% below it, never above it) |
| Price optimization data | Usually at least 60,000 transactions in the previous 30 days |

See [Anime IP and legal](../20-anime-games/anime-ip-and-legal.md) and [Anime monetization](../20-anime-games/anime-monetization.md).

## For agents

- [ ] Before designing a system near one of these limits, re-read the linked official page and note the date.
- [ ] Budgets (requests per minute, memory) are calculated for peak players in the design doc.
- [ ] When a limit changes, update this page and [Key numbers](../99-reference/key-numbers.md) in the same edit.

Sources: [Data store error codes and limits](https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits) · [Memory stores](https://create.roblox.com/docs/cloud-services/memory-stores) · [MessagingService](https://create.roblox.com/docs/reference/engine/classes/MessagingService) · [Pathfinding](https://create.roblox.com/docs/characters/pathfinding) · [Humanoid](https://create.roblox.com/docs/reference/engine/classes/Humanoid) · [Player](https://create.roblox.com/docs/reference/engine/classes/Player) · [Adaptive timestepping](https://create.roblox.com/docs/physics/adaptive-timestepping) · [Sleep system](https://create.roblox.com/docs/physics/sleep-system) · [Server authority model](https://create.roblox.com/docs/projects/server-authority) · [Audio assets](https://create.roblox.com/docs/audio/assets) · [Teleport between places](https://create.roblox.com/docs/projects/teleport) · [Customize matchmaking](https://create.roblox.com/docs/matchmaking/customize-matchmaking) · [Experience events](https://create.roblox.com/docs/production/promotion/experience-events) · [Badges](https://create.roblox.com/docs/production/publishing/badges) · [License Manager](https://create.roblox.com/docs/ip-licensing/license-manager) · [Regional pricing](https://create.roblox.com/docs/production/monetization/regional-pricing)

Related: [Key numbers](../99-reference/key-numbers.md) · [API quick reference](../99-reference/api-quick-reference.md) · [Performance optimization](../13-building-it-right/performance-optimization.md) · [Data persistence](../13-building-it-right/data-persistence.md) · [API cookbook](api-cookbook.md)
