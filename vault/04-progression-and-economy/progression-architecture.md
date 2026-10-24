---
title: Progression architecture
date: 2026-10-24
tags: [progression, economy, pacing, retention]
aliases: [Progression design, Pacing]
summary: How to structure what players unlock over minutes, days and weeks, with pacing targets per stage of a player's life in the game.
audience: [human, agent]
---

# Progression architecture

Progression is the map of everything a player can become in your game and how long each step takes. Roblox's own guidance links D7 retention to the progression system: a player returns in week one when they can see where they are going and feel themselves getting there.

## The progression stack

Most games combine several progression axes. More axes give more goals, but each must be understandable.

| Axis | What grows | Example |
|---|---|---|
| Power | Stats that make the core action stronger | Click power, damage, speed |
| Access | New places or modes | Zones, worlds, floors, islands |
| Collection | Things owned | Pets, units, fish, auras |
| Prestige | Permanent multipliers after a reset | Rebirths, ascensions |
| Mastery | Skill or ranked standing | Elo, ranks, best time |
| Cosmetic | Appearance and status | Titles, trails, skins, base decor |
| Social | Standing among others | Clan level, leaderboard rank |

**House rule:** a new game ships with at most **three** axes active in the first session (usually power, access and one of collection or prestige). Other axes unlock later as new layers of goals.

## Gating with zones (access progression)

Zones (worlds, islands, floors) are the most common access structure on Roblox:

- Each zone has its own resources worth more than the previous zone's.
- A gate with a visible price (or power requirement) blocks the next zone. Players see the next zone through or over the gate, so the goal is concrete.
- Each new zone looks clearly different (new color palette, biome, music). The reveal of a new zone is a "wow" moment.
- Zone costs grow so each zone takes longer than the last, but the reward multiplier also grows, so the *feeling* of progress stays steady.

Rules of thumb for a simulator-style zone chain (non-paying player, first week):

| Zone | Time to unlock (cumulative play) |
|---|---|
| 2 | 5-10 minutes |
| 3 | 15-25 minutes |
| 4 | 35-60 minutes |
| 5 | 1.5-3 hours |
| 6+ | Spread across days, often requiring rebirths |

## Pacing by player lifetime

Design progression for each stage of a player's life. Different stages need different goal distances.

| Stage | Time in game | Goal distance | What they need |
|---|---|---|---|
| Newcomer | first 15 minutes | 30 s to 2 min | Fast upgrades, first zone, first wow |
| Learner | 15 min to 2 h | 2-10 min | Second and third zones, first rebirth, first rare |
| Regular | days 2-7 | 10-30 min per goal, daily systems | Collection sets, rebirth rhythm, daily rewards |
| Local | weeks 2-8 | session-long goals, weekly goals | Leaderboards, rare variants, updates, social status |
| Veteran | months | weekly updates and events | New content, prestige tiers, trading, competition |

The first-session rule from [First session blueprint](../01-first-five-minutes/first-session-blueprint.md) (a named goal at 10-15 minutes) is the first step of this ladder.

## Curves that feel good

Players feel progress as ratios, not absolute numbers. Going from 10 to 20 damage feels as good as going from 1,000 to 2,000. That is why most Roblox progression uses **exponential growth**: costs and rewards both multiply by a constant factor per level. See [Economy math](economy-math.md) for formulas.

Key relationships:

- **Cost grows slightly faster than income** within a zone or rebirth cycle. This creates a natural slowdown that pushes the player to the next zone or a rebirth.
- **Each new zone or rebirth resets the slowdown** with a big jump in income. This creates the sawtooth pattern of most simulators: fast, slow, jump, fast, slow, jump.
- **Never let the time between upgrades grow without a jump.** If the player has waited more than a few minutes for anything in the first hour, the next jump is too far away.

## The second-goal rule

After the first goal (at 10-15 minutes), the player must immediately see the next goal, and it must be reachable within a similar time. A common failure: the first zone is fast, then the second zone costs ten times more with only double the income, and players hit a wall at minute 20. Compute the time-to-goal for each of the first five goals before building (see [Economy math](economy-math.md)).

## Unlock order of systems

Introduce systems in a sequence, each as its own small milestone:

1. Core action and first upgrade (minute 0-3)
2. Shop and second upgrade line (minute 3-10)
3. Second zone (minute 5-15)
4. Collection system: first egg or first rare (minute 5-20)
5. Rebirth or prestige (minute 20-60)
6. Quests and daily systems (end of session 1 or start of session 2)
7. Trading, clans, PvP or advanced systems (day 2+)

Each new system appears with a short guided moment (see [Onboarding patterns](../01-first-five-minutes/onboarding-patterns.md)).

## Catch-up and comeback

Long-running games accumulate a gap between new and old players.

- **Catch-up multipliers**: new players earn faster in early zones; returning lapsed players get a "welcome back" boost.
- **Server-relative goals**: events where everyone contributes equally regardless of level.
- **Separate leaderboards**: daily, weekly, and "this rebirth" boards so new players can rank.
- **Content added at the top and the bottom**: updates should include something for newcomers, not only the end game.

## For agents

- [ ] Progression axes listed, with at most three active in the first session.
- [ ] Time-to-unlock table computed for the first five zones or goals (non-paying player).
- [ ] No gap longer than about 3 minutes without an upgrade in the first hour.
- [ ] Next goal always visible on screen with progress.
- [ ] System unlock order documented with the time each appears.
- [ ] Catch-up mechanics defined for players joining after the first month.

Related: [Economy design](economy-design.md) · [Economy math](economy-math.md) · [Rebirth and prestige](rebirth-and-prestige.md) · [Core loop design](../02-core-loop/core-loop-design.md) · [Retention systems](../10-retention-and-social/retention-systems.md)
