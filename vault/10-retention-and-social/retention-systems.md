---
title: Retention systems
date: 2026-10-24
tags: [retention, daily-rewards, streaks, quests, notifications]
aliases: [Daily rewards, Streaks, Return hooks]
summary: The systems that bring players back on later days (daily rewards, streaks, playtime gifts, quests, timers, group and favorite rewards, notifications) and how to tune them for D1, D7 and D30.
audience: [human, agent]
---

# Retention systems

Retention is whether players come back. Roblox ranks games heavily on play days per user (D1, D2-7, D8-28), and Creator Rewards pays you when you are one of the first three games an active spender opens each day. Retention systems give players reasons to return; the core loop and content give them reasons to stay once they do.

> [!IMPORTANT]
> Retention systems amplify a good game. They cannot fix a weak core loop. If D1 is very low, fix the first session first (see [First session blueprint](../01-first-five-minutes/first-session-blueprint.md)).

## Which system moves which number

Roblox's own retention guidance maps the horizons to systems:

| Horizon | Main driver | Supporting systems |
|---|---|---|
| D1 | Core loop, first session, performance | Daily reward preview, timers that finish tomorrow, first goal left unfinished |
| D7 | Progression system | Streaks, daily and weekly quests, collection sets, rebirth rhythm |
| D30 | "Endgame": content updates and social systems | Events, seasons, trading, clans, leaderboards, new zones |

## Daily rewards

- **A calendar of 7 days** (or 7 plus a monthly milestone), with the best reward on day 7 and visible in advance.
- **Claim with one tap** on join; show what tomorrow brings.
- **Reset rules**: either the calendar continues even if a day is missed (gentler, better for kids) or the streak breaks. Many games use "missed days pause the calendar but break the streak bonus".
- **Rewards scale with progression**: currency rewards based on the player's current income (for example 10 minutes of their income) so they stay meaningful.
- **Use server time** for day boundaries and store the last claim time in player data.

## Streaks

- A visible counter of consecutive days played with growing bonuses (for example +10% coins per streak day up to a cap).
- **Streak protection**: a free freeze earned weekly, or a cheap product to restore a broken streak. If you sell streak recovery, put it on your price ladder and keep it cheap; the goal is to keep players, not to punish them.
- Celebrate milestones (7, 14, 30, 100 days) with titles or cosmetics others can see.

## Playtime rewards (in-session)

Gifts that unlock at increasing play times within a session (for example 5, 10, 15, 25, 40, 60 minutes). They lengthen sessions and are easy to understand. Show a countdown on the HUD and make the last gift the best. See [Session structure](../02-core-loop/session-structure.md).

## Quests

- **Daily quests** (3-5 short tasks, 10-20 minutes total) steer players toward varied content and help reach the 10-minute threshold that counts for Creator Rewards.
- **Weekly quests** for bigger goals.
- **Achievement quests** (permanent) for long-term goals and onboarding of advanced systems.
- Quests should reward with currency, boosts, or season pass XP; tie them to features you want players to discover.

## Timers that finish later

Crops, incubators, research, expeditions. A timer that finishes in 8 hours is a reason to return tomorrow. Mix short, medium and long timers. Sell capacity, not skips. See [Idle and offline progression](../04-progression-and-economy/idle-and-offline-progression.md).

## Group, favorite and like rewards

- **Group rewards**: a small bonus (for example +10% coins or a chat tag) for players in your Roblox group. Check membership with `Player:IsInGroupAsync(groupId)`, and you can prompt joining in-game with `GroupService:PromptJoinAsync`. Groups let you announce updates to players outside the game.
- **Favorite prompt**: favoriting puts your game in the player's favorites for easy return. Roblox provides a prompt for favoriting (`AvatarEditorService:PromptSetFavorite`). Offer after the player has had fun, not on spawn.
- **Like reminders**: a gentle reminder after a good moment. Never gate content behind likes or favorites.

## Notifications

Roblox's experience notifications let you message opted-in players outside the game (for example "Your crops are ready", "Your friend beat your record", "The event starts now"). Platform facts:

- Players must opt in. You can show Roblox's standard opt-in prompt in-game with `ExperienceNotificationService:PromptOptIn()` for users 13+, and it will not show to someone who saw it in the last 30 days.
- Notifications are sent from the server using Roblox's notification package and a notification string you create in Creator Hub; they can include parameters and launch data (read with `Player:GetJoinData()` when the player joins from the notification).

Rules: only send notifications that are useful to the player; ask for opt-in at a moment that makes the value obvious ("Want to know when your egg hatches?"). See [Experience events](../12-live-ops-and-launch/events-and-seasons.md) for event RSVPs ("Notify me").

## Welcome-back and lapsed players

- "Welcome back" rewards after several days away (bigger after longer absences), plus a "what's new" panel.
- Catch-up boosts for returning players so they can rejoin their friends' progress.
- Ads Manager can target lapsed players (30-180 days since last play) for bigger games, and Creator Rewards pays for bringing back users who were inactive on Roblox for 60+ days via your links or name search.

## Measuring

- D1, D7, D30 by first-play cohort (Retention dashboard), split by platform and acquisition source.
- Play days per user in the Home Recommendations dashboard (D1, D2-7, D8-28).
- Claim rates of daily rewards and quests; streak length distribution.
- Opt-in rate and click-through of notifications.

## For agents

- [ ] Daily reward calendar with day-7 highlight, server-time boundaries and scaled rewards.
- [ ] Streak with protection or cheap recovery on the price ladder.
- [ ] Playtime rewards on the HUD.
- [ ] Daily quests totaling about 10-20 minutes.
- [ ] At least one timer that finishes the next day.
- [ ] Group reward and favorite prompt shown after a positive moment, never gating content.
- [ ] Notification opt-in requested at a value moment; notifications limited to useful events.

Related: [Social systems](social-systems.md) · [Endgame and long-term goals](endgame-and-long-term-goals.md) · [Session structure](../02-core-loop/session-structure.md) · [Platform payouts](../09-monetization/platform-payouts.md) · [Discovery algorithm](../11-store-page-and-discovery/discovery-algorithm.md)
