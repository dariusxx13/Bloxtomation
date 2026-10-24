---
title: Trend waves
date: 2026-10-24
tags: [trends, history, market, waves, formats, timing]
aliases: [Roblox trend history, Format waves, What was popular when]
summary: A history of Roblox format waves from the classics to October 2026 - simulators, pets and trading, horror, anime, tower defense, RNG, fishing, grow-and-farm, steal-and-defend, brainrot memes, +1 speed and eggs - with the spark, the shape and the legacy of each, how to spot a new wave in the chart data, and how to time an entry.
audience: [human, agent]
---

# Trend waves

Roblox moves in waves. A spark game finds a new loop or theme, dozens of similar games follow within weeks, most fade, and the format either becomes a lasting genre or disappears. This note is a history of the waves and a method for spotting the next one. The phases of a single trend are in [Trend lifecycle](../15-market-research/trend-lifecycle.md).

Years below are approximate and come from community history, game pages and the trackers cited; treat them as orientation, not exact dates.

## The waves at a glance

| Era (approx.) | Wave | Spark examples | Legacy |
|---|---|---|---|
| 2008-2014 | Classic survival and minigames | Natural Disaster Survival, Murder Mystery 2 | Lasting: both still chart in 2026 |
| 2015-2018 | Tycoons, roleplay jobs, obby towers | Build A Boat For Treasure (2016), Jailbreak (2017), Tower of Hell (2018) | Lasting genres |
| 2017-2020 | Simulators and pet collecting | Bee Swarm Simulator (2018), Adopt Me! (2017) with pet trading | Lasting: simulators remain the largest genre by players |
| 2020 | Story horror | Piggy | Became a lasting horror genre with co-op variants |
| 2019-2022 | Anime RPGs and tower defense | Blox Fruits (2019), All Star Tower Defense (2020) | Lasting: see [Anime games](../20-anime-games/INDEX.md) |
| 2020-2022 | Roleplay towns | Brookhaven RP (2020) | Lasting: the most visited game on the platform |
| 2022-2023 | Co-op horror and battlegrounds | DOORS, The Strongest Battlegrounds | Lasting genres |
| 2023-2024 | Meme tower defense, fashion | Toilet-themed tower defense, Dress To Impress | Fashion lasting; meme TD faded into general TD |
| 2024 | RNG and auras | Sol's RNG and many "RNG" games | Became a genre with many variants ([RNG and aura playbook](../14-genre-playbooks/rng-and-aura.md)) |
| 2024 | Fishing collection | Fisch, later Fish It! | Lasting ([Fishing and collection playbook](../14-genre-playbooks/fishing-and-collection.md)) |
| Early 2025 | Journey survival | Dead Rails | Spawned many journey and vehicle survival games |
| Mid 2025 | Grow and farm | Grow a Garden | Lasting genre; the record holder until September 2025 ([Grow and farm playbook](../14-genre-playbooks/grow-and-farm.md)) |
| Mid 2025 | Steal and defend; brainrot memes | Steal a Brainrot | Lasting format; meme layer fades and renews ([Steal and defend playbook](../14-genre-playbooks/steal-and-defend.md), [Meme and brainrot games](meme-and-brainrot-games.md)) |
| Mid 2025 | Co-op survival with a finish line | 99 Nights in the Forest | Strong; still top three in October 2026 |
| Early-mid 2026 | +1 Speed | +1 Speed Keyboard Escape, +1 Speed Monkey Escape | Many copies by August 2026; wave cooling by September |
| Mid 2026 | Job horror | Animal Hospital | Faded fast after a huge peak |
| Mid-late 2026 | Egg stealing and hatching | Steal An Egg, Ride A Pet, Break and Steal an Egg, Fake an Egg | Peak wave in October 2026 |
| Late 2026 | Anime dice and luck idle | Anime Dice | Rising in September-October 2026 |

## What each wave teaches

### Simulators and pets (2017-2020)

Clicking or collecting with numbers that grow, pets that multiply income, and rebirths. The pet layer turned simulators into trading economies. **Lesson:** a collection layer can outlive the loop it was added to ([Simulator and incremental playbook](../14-genre-playbooks/simulator-incremental.md)).

### Horror (2020 onward)

Story horror with chapters gave way to co-op horror with procedurally varied rooms. **Lesson:** fear is social; co-op and clip moments carry horror ([Survival and horror co-op playbook](../14-genre-playbooks/survival-horror-coop.md)).

### Anime (2019 onward)

The anime fantasy keeps renewing on new loops: RPG, TD, battlegrounds, sports, dice. **Lesson:** a durable fantasy outlives the loops it wears.

### RNG and auras (2024)

A loop of rolling for rare auras with luck boosts proved that a pure reveal loop can hold players. **Lesson:** anticipation and rarity alone can be a game when the reveal is spectacular ([Reveal and hatch design](../03-rarity-and-rng/reveal-and-hatch-design.md)).

### Grow and farm (2025)

Offline growth, restocking shops, mutations and weekly events produced the first 20M+ concurrent game. **Lesson:** a cosy idle loop plus a fixed weekly heartbeat can reach anyone.

### Steal and defend (2025-2026)

Ownership plus theft plus small servers. The format survived the end of its first spark game's peak by moving to new themes (eggs, pets). **Lesson:** when a format outlives its theme, it has become a genre.

### +1 Speed (2026)

Progress every step, short sessions, very high ratings. By August 2026 two near-identical games from unrelated studios sat in the top 10 (StudioKrew). **Lesson:** a format with a tiny content floor saturates within weeks; the first few good versions take most of the audience.

### Eggs (late 2026)

The October 2026 snapshot showed many egg titles among young games: Break and Steal an Egg (about 73K), Climb For Animals Eggs (about 55K), Fake an Egg (about 36K), with Bike For Egg among the week's new entries in a tracker's weekly report (studio snapshot 2026-10-24; RoWatcher, October 12-18, 2026). **Reading:** saturation phase. New entries need a strong twist.

## How waves move

1. **Spark.** One game finds a loop or theme; the spark often comes from a small team.
2. **Copies within weeks.** Formats with a small content floor are copied first and fastest.
3. **Title convergence.** Names start to share a pattern ("Steal a ___", "+1 Speed ___", "Grow a ___").
4. **Shakeout.** Most copies fade; Roblox's discovery demotes games whose metadata and files closely resemble others ([Trend lifecycle](../15-market-research/trend-lifecycle.md)).
5. **Genre or gone.** If players keep returning across several different games, the format becomes a genre.

## Spotting the next wave in the data

The studio's chart tracker (`charts/`) is built for this:

```text
python3 charts/charts.py snapshot            # take a snapshot (run on a schedule)
python3 charts/charts.py report              # breakouts, risers, new entries, rank movers, genres
python3 charts/charts.py genres              # genre shares, growth and phase
python3 charts/charts.py evidence --genre "Simulation"   # pitch-ready evidence block
```

Signals of a forming wave:

| Signal | Where to see it |
|---|---|
| Two or more young games with the same verb or theme rising together | `report` breakout candidates; game names |
| A title pattern spreading | Names in new entries and up-and-coming |
| A genre's share rising over several days | `genres` growth column |
| Unrelated studios shipping near-identical loops | Creator column |
| A spark game's players still rising after two weekends | `game <name>` history |

Combine with weekly third-party reports (for example RoWatcher's weekly gainers and new games) and creator content trends. Cite every source with its date ([Reading the charts](../15-market-research/reading-the-charts.md)).

## Timing an entry

| Phase when you would ship | Strategy |
|---|---|
| Spark or early rise (weeks) | Ship fast with a real twist; small scope; weekly updates |
| Late rise or saturation | Enter only with a clearly better or different product, or skip |
| Shakeout | Do not start a copy; look for the next spark or a durable sub-genre |
| Genre | Compete like any genre: quality, live ops and community |

Build time decides which phase you can reach. A team that needs three months cannot be early to a wave that saturates in six weeks; it should target formats that have already become genres, with a better product.

## For agents

- [ ] Every trend pitch names the wave, its phase and the evidence (snapshots, reports, dates).
- [ ] Build time is compared with how fast the format saturated in the past.
- [ ] The twist changes play, not only the theme ([Trend lifecycle](../15-market-research/trend-lifecycle.md)).

Sources: Bloxodes monthly reports (June-September 2026); StudioKrew boards (July-September 2026); RoWatcher weekly report (October 12-18, 2026); Wikipedia articles "Grow a Garden" and "Steal a Brainrot"; the studio's chart snapshot of 2026-10-24. All accessed 2026-10-24. Earlier eras summarise community history and game pages.

Related: [Trend lifecycle](../15-market-research/trend-lifecycle.md) · [Reading the charts](../15-market-research/reading-the-charts.md) · [Hits of 2025](hits-2025.md) · [Hits of 2026](hits-2026.md) · [October 2026 chart snapshot](chart-snapshot-2026-10.md)
