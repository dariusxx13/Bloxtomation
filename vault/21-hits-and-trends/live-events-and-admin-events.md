---
title: Live events and admin events
date: 2026-10-24
tags: [live-ops, events, admin-abuse, update-parties, concerts, cross-server, engineering]
aliases: [Admin abuse events, Admin events, Update parties, Live events, Scheduled events]
summary: Why scheduled live events (admin abuse sessions, update parties, seasonal events, concerts, platform events) produce the biggest player peaks on Roblox, what the 2025-2026 record events looked like, how to design fair and safe events, and how to run them across servers with schedules, configs and MessagingService.
audience: [human, agent]
---

# Live events and admin events

The largest player peaks on Roblox in 2025 and 2026 did not come from launches. They came from **scheduled live moments**: a developer joining servers to rain rewards, a weekly "update party", a seasonal event, a concert. This note explains why they work, what the record events looked like, and how to run them well. Seasonal content planning is in [Events and seasons](../12-live-ops-and-launch/events-and-seasons.md); the anime angle in [Anime community, updates and codes](../20-anime-games/anime-community-updates-and-codes.md).

## Types of live events

| Type | What happens | Typical rhythm |
|---|---|---|
| **Admin abuse session** | Developers use special powers in live servers: global luck boosts, raining currency, spawning rare items, changing weather, chaotic gimmicks | Weekly (often Saturday), or with updates |
| **Update party** | Players who are online at a set time get rewards; often followed by the update going live | Weekly or with each update |
| **Seasonal event** | Themed map, currency, shop and limited items for weeks | Holidays, summer, Halloween |
| **Crossover** | A guest character, creator or game theme appears | Occasional |
| **Concert or celebrity appearance** | A performer or public figure appears live in the game | Rare, high production |
| **Platform event** | Roblox-run events across many games (for example a scavenger hunt) | A few per year |
| **Mock rivalry** | Two developers stage a "war" between their games | Rare; enormous reach |

## The record events (dated)

| Date | Event | What happened | Source |
|---|---|---|---|
| 2025-07-26 | Grow a Garden "Corruption Update" with a celebrity appearance | A professional football player appeared in a live event | Wikipedia, Grow a Garden article (accessed 2026-10-24) |
| 2025-08-23 | Mock "admin war" between Grow a Garden and Steal a Brainrot | Grow a Garden reached at least 22.3M concurrent players; Steal a Brainrot passed 20M; Roblox set a platform record of about 47.3M concurrent users | Wikipedia articles for both games; press coverage |
| 2025-09-13 | Steal a Brainrot "Extinct Event" | A peak of about 24M concurrent players | Wikipedia, Steal a Brainrot article |
| Oct 2025 | Steal a Brainrot | A peak of about 25.4M concurrent players, the highest for any Roblox game at the time of reporting | Press coverage (PocketGamer.biz) |
| Jan 2026 | A virtual concert inside Steal a Brainrot | About 12.8M concurrent players and about 10M livestream viewers | Wikipedia, Steal a Brainrot article |
| 2026-07-23 to 08-24 | Murder Mystery 2 Summer 2026 event | The 2014 game set a new all-time peak of about 1.35M concurrent players | StudioKrew board citing GGAID (August 2026); Bloxodes July and August 2026 reports |
| 2026-08-09 | +1 Speed Keyboard Escape admin abuse events | A 24-hour peak of about 5.2M, against an all-time high of about 7.28M | StudioKrew board citing GGAID (August 2026) |
| 2026-09-19 | Steal An Egg crossover with the creator of Steal a Brainrot | A peak of about 14.27M concurrent players | StudioKrew board citing RoVitals (September 2026) |
| 2026-09-17 to 09-28 | The Hunt: Roblox 20 (platform event) | Older games such as Lumber Tycoon 2 and Jailbreak saw waves of returning players | Bloxodes September 2026 report |
| 2026-10-22 to 11-02 | The Hollow (platform event) | A Roblox-run Halloween survival event for ages 9+, with a new monster each day from nine horror games (including 99 Nights in the Forest, DOORS and Animal Hospital), creator livestreams and a live finale on October 31 | Roblox newsroom, 2026-10-21 |

Numbers are from press and third-party trackers, rounded and approximate.

## Why live events work

1. **Scarcity in time.** Rewards available only during the window turn "I'll play later" into "I must be online at 10 AM Saturday".
2. **Shared spectacle.** Everyone in the server sees the same chaos at once; it feels like a party, not a solo grind.
3. **Clips and streams.** Creators schedule streams around events; viewers join to get the rewards they see.
4. **Social pull.** Players message friends to come online, often through invites ([Viral and social mechanics](viral-and-social-mechanics.md)).
5. **Algorithm fuel.** A concurrency spike puts the game at the top of popularity sorts, where non-players see it.
6. **Habit.** A fixed weekly time becomes a routine; Adopt Me's Friday updates, Saturday admin sessions and a weekly "2D Tuesday", and 99 Nights in the Forest's Saturday update parties are examples cited by trackers in 2026.

Peaks fade after the event. The goal is not the spike itself but **a higher floor**: some of the players who return for an event stay for the update that comes with it.

## Designing an event

### Before

- **Announce the time** in the game (lobby countdown), in a Roblox event listing with Notify Me, and on social channels linked from the game page ([Anime community, updates and codes](../20-anime-games/anime-community-updates-and-codes.md)).
- **Pick a fixed, global-friendly time** and state it in UTC and two or three major time zones.
- **Pair it with content**: an event without new content is a spike with no floor.
- **Prepare server capacity**: test the game at full server size with event effects active; plan for many simultaneous joins.

### During

- **Rewards for everyone online**, not only for whoever stands in the right spot. Fairness complaints are the top cause of event backlash.
- **Clear on-screen messaging**: what is happening, how long it lasts, what you get.
- **Server-authoritative grants** through the normal reward path; never let clients claim event rewards ([Security and anti-exploit](../13-building-it-right/security-and-anti-exploit.md)).
- **Effects within budget**: global weather, explosions and raining items must respect mobile budgets ([VFX performance budgets](../19-vfx/vfx-performance-budgets.md)).

### After

- Patch notes and a thank-you code.
- Analytics review: joins, peak, how many event players returned on D1 and D7, economy inflation from event rewards ([Analytics instrumentation](../13-building-it-right/analytics-instrumentation.md)).
- Fix what broke before the next event.

### Fairness and safety rules

| Risk | Rule |
|---|---|
| Rewards only for some servers | Every server runs the same event at the same time |
| Paid advantage during events | Events reward attendance and play, not purchases |
| Economy inflation | Cap event currency and items; event items are cosmetic or time-limited where possible |
| Favoritism | No special treatment for friends or creators in public servers |
| Dangerous pressure on young players | No "spend now or miss out" prompts during events ([Monetization compliance](../09-monetization/monetization-compliance.md)) |
| Celebrity or brand appearances | Contracts and payments are human decisions; escalate as money or policy questions |

## Engineering live events

### Schedule first, messages second

The robust way to run a global event is a **schedule every server can compute**, not a message every server must receive:

- Store event windows (start and end in UTC, event id, parameters) in a live config ([Experiments and configs](../12-live-ops-and-launch/experiments-and-configs.md)) or in shared config shipped with the update.
- Each server checks the current UTC time against the schedule every few seconds and starts or ends the event locally.
- New servers that start mid-event see the same schedule and join in at the right point.

### MessagingService for live triggers (Fact, API reference, accessed 2026-10-24)

`MessagingService` lets servers of the same game exchange messages on topics, typically within 1-2 seconds. Delivery is **best effort and not guaranteed**. Limits include 1 KB per message, `600 + 240 × players` messages sent per server per minute, and `40 + 80 × servers` messages received per topic per minute. Use it for things that can tolerate a lost message: "the developer just triggered a meteor shower", global announcements of rare finds. Do not use it as the only source of truth for an event start. A server that misses the message should still pick the event up from the schedule or config on its next check.

### Sketch: scheduled event with an optional live trigger

```lua
--!strict
-- EventClock (sketch): servers start and stop events from a UTC schedule; a
-- MessagingService topic can add short live moments, which are best effort.
local MessagingService = game:GetService("MessagingService")

export type EventWindow = { id: string, startsAt: number, endsAt: number }

local EventClock = {}
local active: { [string]: boolean } = {}

local function setActive(id: string, on: boolean)
	if active[id] == on then
		return
	end
	active[id] = on
	-- Start or stop the event's systems here (boosts, weather, spawns, UI state).
end

function EventClock.tick(schedule: { EventWindow })
	local now = DateTime.now().UnixTimestamp
	for _, window in schedule do
		setActive(window.id, now >= window.startsAt and now < window.endsAt)
	end
end

function EventClock.listen(topic: string, onMoment: (momentId: string) -> ())
	local ok, err = pcall(function()
		MessagingService:SubscribeAsync(topic, function(message)
			if typeof(message.Data) == "string" and #message.Data <= 64 then
				onMoment(message.Data)
			end
		end)
	end)
	if not ok then
		warn(`EventClock subscribe failed: {err}`)
	end
end

return EventClock
```

Who can trigger a live moment is decided on the server against an allowlist of user ids; the trigger arrives through a validated, rate-limited remote, and in production only staff accounts pass. The template's `QA` system shows the pattern: open to everyone in Studio, and in live servers only to user ids listed in `Config/Game.qaUserIds`.

### Load and stability

- Expect join surges at the start time. Keep join-time work light: load data, spawn, and defer heavy setup.
- Do not save player data on every event reward; the normal autosave covers it ([Data persistence](../13-building-it-right/data-persistence.md)).
- Server-wide effects run on clients; the server sends one compact "event state" update.
- Watch error rates live and keep a kill switch (a config flag) for every event feature.

## Running events with this studio's agents

- The Director schedules events in the roadmap with dates and owners.
- The Designer writes the event brief (goal, rewards, fairness rules, duration, content tie-in).
- The Engineer implements schedule-driven activation behind a flag and tests a mid-event server start.
- The Artist budgets effects; QA tests on phones at full server size.
- The Analyst reports the D1 and D7 return of event players.
- Anything involving paid talent, sponsors or brand partners is escalated to the human.

## For agents

- [ ] Every event has a UTC schedule in config, a kill switch and a content tie-in.
- [ ] Rewards go to everyone online, through server-side grants, and are capped.
- [ ] Live triggers via MessagingService are optional extras; the schedule is the source of truth.
- [ ] A mid-event server start was tested.
- [ ] The post-event report shows D1 and D7 return of event attendees.

Sources: [MessagingService](https://create.roblox.com/docs/reference/engine/classes/MessagingService) · [Cross-server messaging](https://create.roblox.com/docs/cloud-services/cross-server-messaging) · [Experience events and updates](https://create.roblox.com/docs/production/promotion/experience-events) · Wikipedia articles "Grow a Garden" and "Steal a Brainrot"; StudioKrew monthly boards (July-September 2026, citing GGAID, RoVitals and Rolimon's); Bloxodes monthly reports (June-September 2026). All accessed 2026-10-24.

Related: [Events and seasons](../12-live-ops-and-launch/events-and-seasons.md) · [Update cadence](../12-live-ops-and-launch/update-cadence.md) · [Anatomy of a Roblox hit](anatomy-of-a-hit.md) · [Hits of 2025](hits-2025.md) · [Hits of 2026](hits-2026.md)
