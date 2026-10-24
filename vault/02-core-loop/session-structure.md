---
title: Session structure
date: 2026-10-24
tags: [core-loop, sessions, pacing, playtime]
aliases: [Session design, Round structure]
summary: How to shape a play session (persistent or round-based) so players stay longer, leave at good moments and come back.
audience: [human, agent]
---

# Session structure

A session is one visit to your game, from join to leave. Playtime per user (capped at 60 minutes per user per day for ranking) and qualified play sessions are both Recommended-for-You signals, so session shape matters directly for discovery.

## Two families of sessions

### Persistent sessions

The player's progress lives in the world: a base, a farm, a tycoon, a pet collection. Sessions are open-ended and the player decides when to stop.

- **Strengths:** long sessions, strong sense of ownership, natural idle and offline progress.
- **Risks:** no natural "one more round" hook; players drift away when the next goal is far.
- **Shape it with:** a chain of goals 1-5 minutes apart, timed events in the server (meteor showers, boss spawns, merchant visits every 10-15 minutes), and things that finish while the player is still online.

### Round-based sessions

The game runs in rounds or matches: a horror round, a PvP match, a minigame, a raid. Each round is self-contained, with meta-progression between rounds.

- **Strengths:** natural tension and climax; a clear "one more round" hook; great for clips.
- **Risks:** downtime between rounds; losing feels bad; round length drives bounce.
- **Shape it with:** short rounds (2-8 minutes typical), short intermissions (10-30 seconds) with something to do, rewards for every round (even losses), and visible progress between rounds.

Many hits are hybrids: a persistent hub with round-based activities (a lobby with a raid queue, a farm with a weekly boss).

## The session arc

A good session has a rhythm, not a flat line:

1. **Warm-up (0-2 min):** collect offline earnings, claim the daily reward, see what is new. Quick wins.
2. **Build (2-10 min):** the core loop at full speed, upgrades every minute or two.
3. **Peak (10-20 min):** a bigger moment: boss, rare event, new zone, rebirth, event round.
4. **Wind-down and hook:** a reason to come back: start a long timer, show the next goal, claim a streak.

Design one peak per 10-20 minutes for persistent games, one per round for round-based games.

## Pacing tools

| Tool | What it does | Example |
|---|---|---|
| Server events on a timer | Gives everyone in the server a shared reason to stay | "Golden meteor in 2:00" |
| Rotating shops | Something new to check | Merchant stock refreshes every 5 minutes |
| Capacity limits | Natural mini-break and decision | Backpack full, go sell |
| Timed producers | Rewards for staying online | Crops ready in 3 minutes |
| Combo or streak in-session | Rewards continuous play | x2 multiplier after 10 kills in a row |
| Playtime rewards | Explicit stay incentive | Gift at 5, 10, 20, 30, 45, 60 minutes |
| Round timers | Tension and end points | 4-minute rounds with a final 30-second surge |

> [!TIP]
> Playtime rewards (gifts that unlock at 5, 10, 15, 30, 45 and 60 minutes of play in a session) are one of the most reliable session-length tools on Roblox. Make the last gift clearly the best, show the countdown in the HUD, and let players claim with one tap. See [Retention systems](../10-retention-and-social/retention-systems.md).

## Round design rules

- **Rounds start fast.** Under 15 seconds of waiting in a full server. If the server is small, start with fewer players or add bots.
- **Every round pays.** Losers get something (XP, a share of currency, progress on a quest), winners get more.
- **Late joiners can play.** Joining mid-round should put the player into something within seconds: spectate with a "next round in 0:45" counter and something to do in the lobby, or drop them in.
- **Climax at the end.** The last 20-30% of a round should be the most intense: the shrinking zone, the monster speeding up, the final wave.
- **Show results.** A short results screen with what each player earned and a highlight (MVP, best moment) feeds the clip and social loops.
- **Queue the next round automatically.** Never make players press a button to keep playing.

## Session length targets (rules of thumb)

Average session length depends heavily on genre. Use your Creator Analytics benchmarks (similar games) as the real target. Rough community ranges for healthy games:

| Genre family | Typical healthy average session |
|---|---|
| Obby, short horror, party | 8-15 min |
| Simulator, RNG, fishing | 15-30 min |
| Tycoon, farm, steal-and-defend | 15-35 min |
| Fighting, shooter (round-based) | 12-25 min |
| Roleplay, hangout | 20-45 min |
| Survival co-op | 20-40 min |

The ranking signal caps playtime at 60 minutes per user per day, so beyond an hour, extra playtime helps players but not your distribution. Play *days* matter more than squeezing extra minutes into one day.

## Making leaving feel okay (so they return)

A player who leaves frustrated rarely returns. A player who leaves satisfied, with something waiting, does.

- End sessions on a high: a completed goal, a rare drop, a won round.
- Show what is waiting next time: "Your crops will be ready in 2h", "Day 3 reward: Mythic Egg".
- Save constantly so nothing is lost by closing the app.
- Offline progress (capped) rewards returning without punishing absence. See [Idle and offline progression](../04-progression-and-economy/idle-and-offline-progression.md).

## For agents

- [ ] Session type stated: persistent, round-based or hybrid.
- [ ] Peak moments scheduled (one per 10-20 minutes, or one per round).
- [ ] Server-wide timed event exists for persistent games.
- [ ] Round games: round start under 15 s, every round pays, auto-queue, late join handled.
- [ ] Playtime rewards configured with the best reward last.
- [ ] A visible "waiting for you next time" hook before the player is likely to leave.

Related: [Core loop design](core-loop-design.md) · [Retention systems](../10-retention-and-social/retention-systems.md) · [Idle and offline progression](../04-progression-and-economy/idle-and-offline-progression.md) · [Discovery algorithm](../11-store-page-and-discovery/discovery-algorithm.md)
