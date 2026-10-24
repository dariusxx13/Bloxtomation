---
title: Discovery algorithm
date: 2026-10-24
tags: [discovery, algorithm, recommendations, analytics]
aliases: [Recommended for You, How Roblox recommends games, RFY]
summary: How Roblox's Recommended for You works (retrieval, ranking, signals, explore and expand), how to read the Home Recommendations dashboard, and what to fix when impressions drop.
audience: [human, agent]
---

# Discovery algorithm

Most plays for most games come from the Home page's **Recommended for You** (RFY) sort. Roblox has published how it works. Understanding it tells you which numbers matter and why some updates bring a wave of players while others do nothing.

## How it works (platform facts, 2026)

RFY decides what to show each user in two stages:

1. **Retrieval**: from millions of games, pick a candidate set this user might enjoy, based on signals like engagement, retention and monetization.
2. **Ranking**: order the candidates for this user and decide how many impressions each game gets.

Two critical details:

- **Many sources can get you considered.** Plays from ads (Sponsored), curation, search, charts, friends, teleports, notifications and social links can signal that your game deserves a look. Even a small number of players can start this.
- **Only organic RFY players count for ranking.** How far your game goes in RFY depends entirely on the behavior of users who came *from RFY*. Behavior of players from ads, friends, search or social media is not used in the ranking stage. Ads can start the engine; they cannot drive it.

## The signals

Roblox lists these signals and their relative importance:

**Most important**

| Signal | Meaning | Notes |
|---|---|---|
| Play-through rate | Share of users who play after seeing your tile in RFY | Icon, thumbnail, title |
| First-play bounce rate | Share who leave after a very short first session | Negative signal; measured around the 1-3 minute window |
| Play days per user | Unique days users return | Measured for D1, D2-7, D8-28 |
| Playtime per user | Time spent per user | Capped at 60 minutes per user, per game, per day |

**Important**

| Signal | Meaning |
|---|---|
| Intentional co-play days per user | Unique days users come back to play with friends (joins, invites, private servers) |
| Qualified play sessions per user | Meaningful sessions (filters accidental clicks and quick bounces) |
| Spend days per user | Unique days users spend Robux |
| Robux spent per user | Average spend |

Signals are **averages per user**, not totals, so a small game with engaged players can compete. Roblox says it keeps adjusting signals toward strong long-term retention; in 2026 it publicly shifted toward favoring long-term engagement over short-term spend.

## Explore and expand

When something changes (a new game, a big update), RFY **explores**: it shows the game to new cohorts of users and watches the signals. If those cohorts engage, it **expands** to more cohorts. This is why updates often bring a spike of impressions, and why the spike's size depends on how good the new players' experience is. A temporary dip in play-through rate during expansion is normal; new audiences are less targeted.

## What else changes your impressions

1. Your own changes (updates, gameplay changes).
2. Roblox changing the algorithm.
3. Total Home traffic and seasonality: weekly peaks on Saturday, lows on weekdays; summer and back-to-school swings; holidays.
4. Competitors improving faster. If similar games improve their signals more than you, your share can fall even when your numbers are steady.

## Quality filters (things that limit exposure)

- **No custom thumbnail**: games with only a default thumbnail are not eligible for Home recommendation impressions.
- **Monetary-reward metadata**: titles or images implying Robux or money rewards are not prioritized.
- **Mismatched metadata and content**: the thumbnail promises something the game does not deliver.
- **Non-unique games**: metadata and place files closely resembling existing games are not prioritized and may rank lower in search.

Roblox reclassifies quality with each update, and the Creator Dashboard shows a banner if your game has reduced exposure.

## Reading the Home Recommendations dashboard

Creator Hub > Analytics > Acquisition > **Home Recommendations** shows impressions, plays and each signal over time, with benchmarks from similar games (benchmarks do not affect the algorithm).

Diagnosis order:

1. Did impressions drop? Find the date.
2. Check the most important signals first: play-through rate, first-play bounce rate, play days per user (D1, D2-7, D8-28), playtime per user. An impression drop usually follows a drop in these.
3. If they are stable, check co-play days, qualified sessions, spend days and spend.
4. Compare each signal with the benchmark; the weakest signal relative to its benchmark is your best opportunity.
5. Check acquisition sources (did other sources change too?) and seasonality (was it a holiday week?).

## Signal-to-fix map

| Weak signal | Where to look | Notes |
|---|---|---|
| Play-through rate | [Icons](icons.md), [Thumbnails](thumbnails.md), [Titles and descriptions](titles-and-descriptions.md) | Use thumbnail personalization |
| First-play bounce | [First-session killers](../01-first-five-minutes/first-session-killers.md) | Usually the first 60 seconds |
| D1 play days | [First session blueprint](../01-first-five-minutes/first-session-blueprint.md), [Retention systems](../10-retention-and-social/retention-systems.md) | Return hook before leaving |
| D2-7 and D8-28 play days | [Progression architecture](../04-progression-and-economy/progression-architecture.md), [Update cadence](../12-live-ops-and-launch/update-cadence.md) | Goals at week scale, events |
| Playtime | [Core loop design](../02-core-loop/core-loop-design.md), [Session structure](../02-core-loop/session-structure.md) | Up to 60 min/day counts |
| Co-play days | [Social systems](../10-retention-and-social/social-systems.md) | Friend bonuses, invites |
| Spend days and spend | [Monetization strategy](../09-monetization/monetization-strategy.md) | Only after retention is healthy |

## Other discovery surfaces

- **Search**: semantic search understands natural queries ("food games"). Accurate titles, descriptions and genres help. Search ads target exact keywords.
- **Charts (Discover page)**: top and trending sorts, including genre-specific charts based on your selected genre. See [Reading the charts](../15-market-research/reading-the-charts.md).
- **Sponsored**: ads; does not change your RFY ranking.
- **Curated sorts**: Standout Games (hand-picked novel games), Live Events.
- **Game details page**: events, groups, passes and subscriptions, similar games.
- **Notifications** and **friends' activity**.

## For agents

When asked to improve discovery:

1. Pull the Home Recommendations signals and benchmarks; identify the weakest top-priority signal.
2. Rule out seasonality and competitor events before blaming your changes.
3. Fix the weakest signal using the map above; predict which signal should move and by roughly how much.
4. After shipping, compare the same signal over the following 7-14 days, noting traffic mix changes.
5. Never use tactics that violate quality filters (Robux bait, misleading thumbnails, copied metadata).

Related: [The Roblox platform in 2026](../00-start-here/roblox-platform-2026.md) · [Thumbnails](thumbnails.md) · [First-session killers](../01-first-five-minutes/first-session-killers.md) · [Retention systems](../10-retention-and-social/retention-systems.md) · [Update cadence](../12-live-ops-and-launch/update-cadence.md)

Sources: [Discovery](https://create.roblox.com/docs/discovery), [Discovery FAQ](https://create.roblox.com/docs/discovery-faq)
