---
title: Reading the charts
date: 2026-10-24
tags: [market-research, charts, trends, data]
aliases: [Charts, Market data, Sorts]
summary: What Roblox's Charts (Discover) sorts show, which public data you can collect about games, how to compute velocity and spot breakouts, and how to avoid misreading the data.
audience: [human, agent]
---

# Reading the charts

Roblox's Charts (Discover) page lists games in sorts such as Top Trending, Up-and-Coming, Top Earning and genre-specific trending sorts. Snapshots of these sorts over time are the best free window into what is growing on the platform. This repository's chart tracker (see `charts/`) automates the collection described here.

## What the sorts are

Sorts observed on the Charts page (2026-10-24; names and composition change over time):

| Sort | What it suggests |
|---|---|
| Top Trending | Games gaining momentum now |
| Up-and-Coming | Newer or smaller games rising |
| Top Playing Now | Highest current concurrency |
| Top Earning | Highest earners (relative order only; no revenue numbers shown) |
| Top Revisited | Games players return to |
| Fun with Friends | Games with strong co-play |
| Top Rated | Highest like ratios |
| Most Popular | Broad popularity |
| Top Paid Access | Best paid-access games |
| Trending in <genre> | Trending within each genre (Action, Adventure, Entertainment, Obby & Platformer, Party & Casual, Puzzle, RPG, Roleplay & Avatar Sim, Shooter, Shopping, Simulation, Sports & Racing, Strategy, Survival) |

Charts can be filtered by device (all, entry-level phone, standard phone, tablets, computer, console, VR), country and age group. The same game can rank differently on phones vs computers and by country. Genre-specific sorts use each game's selected genre.

## Data you can collect per game

For each game in a sort: universe id, root place id, name, current players, total up and down votes, whether the tile is sponsored, maturity label and genre. Public game detail data adds total visits, creation and last-update dates, max players per server, favorites count, creator, genre and subgenre. Icons and thumbnails are available too.

These public endpoints are **unofficial and undocumented**: they can change or be rate-limited at any time. Collect politely (low frequency, caching, no hammering), and do not treat them as guaranteed infrastructure.

## Derived metrics that matter

| Metric | Formula | Why |
|---|---|---|
| Like ratio | up / (up + down) | Player satisfaction; low ratios rarely sustain growth |
| Rank change | rank(previous) − rank(now) per sort | Momentum |
| Player change | players(now) − players(previous), and % | Momentum in absolute terms |
| Visits per day | Δ visits / Δ days | Traffic volume, smoother than concurrency |
| Age of game | now − created | New breakout vs old evergreen |
| Days since update | now − updated | Live-ops intensity |
| Sort saturation | number of sorts the game appears in | Breadth of success |
| Peak to average | max players / average over a window | Spiky (event-driven) vs steady |

## Spotting breakouts

A useful working definition: a game is a **breakout candidate** if it is young (for example created in the last 30-60 days) or has low lifetime visits (for example under a few hundred thousand), but already holds meaningful concurrency (for example 500+ players) and is rising across snapshots. Tune the thresholds to the season (summer traffic is higher).

Breakouts are where trends start. Track them daily; most fade, a few become the next wave.

## Reading the data correctly

- **Time of day and day of week**: concurrency swings massively over a day (by region) and peaks on weekends. Compare the same hour and weekday, or use daily averages.
- **Seasonality**: school holidays raise everything.
- **Events and updates**: spikes around big updates or admin events are not baseline traffic.
- **Sponsored tiles**: some entries in sorts may be ads; note the sponsored flag.
- **Survivorship**: charts show winners. For every visible trend there are many failed copies you never see.
- **Earnings order is not revenue**: Top Earning ranks relative earning, not amounts.
- **Correlation is not cause**: a game's success may come from creators, an existing community or timing, not from its mechanics alone.

## Turning charts into decisions

1. Keep daily snapshots of the main sorts and your genre's trending sort.
2. Maintain a corpus of reference games per genre (titles, loops, monetization, update cadence, like ratio, visits per day).
3. Flag breakouts and rising formats; examine them hands-on (play them; see [Competitor teardown](competitor-teardown.md)).
4. Feed evidence into pitches with exact numbers, dates and sources (see [Pitch and greenlight](pitch-and-greenlight.md)).
5. Re-check data older than 7 days before acting on it.

## For agents

- [ ] Every trend claim cites a snapshot (sort, timestamp, numbers) no older than 7 days.
- [ ] Concurrency comparisons control for time of day and weekday.
- [ ] Sponsored entries are labelled.
- [ ] Breakout thresholds stated explicitly when flagging candidates.
- [ ] Collection is polite: cached, low frequency, no automated play or fake traffic.

Related: [Trend lifecycle](trend-lifecycle.md) · [Competitor teardown](competitor-teardown.md) · [Pitch and greenlight](pitch-and-greenlight.md) · [Titles and descriptions](../11-store-page-and-discovery/titles-and-descriptions.md)
