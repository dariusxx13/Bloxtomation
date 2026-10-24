---
title: Idle and offline progression
date: 2026-10-24
tags: [progression, idle, offline, retention, economy]
aliases: [Offline earnings, AFK progression, Idle systems]
summary: How to reward players for time away and time idle without breaking the economy or encouraging empty AFK servers.
audience: [human, agent]
---

# Idle and offline progression

Idle progression rewards players while they are not actively playing: producers that keep producing, crops that keep growing, pets that keep collecting. It is a powerful return hook ("your farm made 2.4M while you were gone") and a natural fit for tycoons, farms and simulators. Handled carelessly, it inflates the economy and fills servers with AFK players.

## Three kinds of passive progress

| Kind | When it runs | Example | Main purpose |
|---|---|---|---|
| In-session idle | Player is in the game but not acting | Droppers in a tycoon, auto-collect pets | Smooths the loop, rewards automation upgrades |
| AFK in server | Player leaves the game window open | Standing in a zone that grants passive income | Session length (use carefully) |
| Offline | Player has left the game | "While you were away" earnings, crops finishing | Return hook, D1/D7 |

## Offline earnings design

Offline earnings are computed when the player rejoins, not simulated while they are away.

```
offline_seconds  = min(now - last_logout_time, offline_cap_seconds)
offline_earnings = offline_seconds * offline_rate * offline_efficiency
```

Rules of thumb:

- **Cap the time.** 2-12 hours is common. A cap pushes players to return at least once or twice a day, which is exactly the "play days" behavior the algorithm rewards.
- **Lower efficiency than active play.** Offline income typically runs at 10-50% of active income. Active play must always be better.
- **Upgrade the cap and efficiency** as progression (and optionally as a pass: "Offline earnings x2", "12-hour vault").
- **Show it with a celebration** on rejoin: a popup with the amount, a big collect button, an optional "double it" via rewarded video ad (if eligible) or a cheap product.
- **Use server time.** Compute with `os.time()` on the server and store the logout time in player data at save time. Never trust the client clock.

## Timers that finish while away

Crops, incubators, research, crafting queues, expeditions. They create a natural appointment: "come back in 4 hours".

- Show finish times clearly ("Ready in 3h 12m") and send an experience notification when ready, if the player opted in. See [Retention systems](../10-retention-and-social/retention-systems.md).
- Mix lengths: short (5-15 min, finish during the session), medium (1-4 h, return the same day), long (8-24 h, return tomorrow).
- **Avoid selling skips for timers in the core loop.** Roblox's own monetization guidance notes that "pay to skip the wait" timers are unpopular with Roblox players. Sell more capacity (more plots, more incubators) instead of skipping the wait. Speed-ups as a small convenience on optional timers are acceptable if they never gate core fun.

## AFK in servers

Some games deliberately reward standing in the game (AFK zones that give gems over time). It boosts playtime numbers but has downsides:

- AFK playtime adds little real engagement, and Recommended for You caps playtime at 60 minutes per user per day, so very long AFK sessions add nothing to ranking.
- AFK players fill server slots, making servers feel full but dead to active players.
- It encourages auto-clickers and anti-AFK scripts.

If you include AFK rewards: put AFK players in a separate place or a dedicated AFK zone/server, keep rewards modest, and never let AFK income beat active play.

> [!NOTE]
> Roblox disconnects idle players after about 20 minutes of no input by default. Players use tools to defeat this. Do not design systems that need AFK abuse to be competitive.

## In-session automation as progression

Auto-collect, auto-hit, auto-sell and auto-hatch are excellent rewards *after* the player has done the action manually many times. They convert grinding into management and keep long sessions comfortable.

- Unlock automation in steps: auto-collect (minute 20-40), auto-sell (later), full auto (late game or pass).
- Automation should be slightly less efficient than skilled manual play in the early game, then equal or better later.
- Automation passes are popular and fair purchases when the manual action remains fully available.

## Economy impact

Passive income can quietly dominate the economy. Check:

- What share of a typical player's daily income is passive? If it exceeds about half for active players, the core loop is losing its reason to exist.
- Does offline income scale with multipliers? If so, cap or apply only part of the multipliers, or late-game offline earnings will explode.
- Log offline earnings as a separate `TimedReward` economy source so you can see it on the dashboard.

## For agents

- [ ] Offline earnings use server time, are capped, and run below active efficiency.
- [ ] Rejoin shows a "while you were away" celebration with a collect action.
- [ ] Timers include short, medium and long lengths; notifications offered when ready.
- [ ] No core-loop timer is sold as a skip; capacity is sold instead.
- [ ] AFK rewards, if any, are modest and isolated from active play spaces.
- [ ] Passive income share of total income is measured and kept below about half for active players.

Related: [Session structure](../02-core-loop/session-structure.md) · [Economy design](economy-design.md) · [Retention systems](../10-retention-and-social/retention-systems.md) · [Tycoon](../14-genre-playbooks/tycoon.md) · [Grow and farm](../14-genre-playbooks/grow-and-farm.md)
