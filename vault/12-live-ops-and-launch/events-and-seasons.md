---
title: Events and seasons
date: 2026-10-24
tags: [live-ops, events, seasons, battle-pass, admin-events]
aliases: [Live events, Limited-time events, Seasons]
summary: How to design limited-time events, server events, admin events and seasons, use Roblox's experience events feature, and avoid the traps of fake scarcity and burnout.
audience: [human, agent]
---

# Events and seasons

Events turn time into excitement: something is happening now, and it will not last forever. They bring back lapsed players, create social moments, and give limited rewards worth chasing. They also cost content and can burn out both players and developers if overused.

## Types of events

| Type | Length | Example | Main purpose |
|---|---|---|---|
| Server events | Minutes, repeating | Meteor shower every 15 min, boss spawn, 2x luck hour | Session length, shared moments |
| Live admin events | One hour or less, scheduled | Developers join and spawn special effects or rewards for everyone | Hype, concurrency spikes, clips |
| Weekend events | 2-3 days | Double XP weekend, weekend boss | Weekend traffic, return visits |
| Limited-time events | 1-3 weeks | Halloween event with event currency, event egg, event shop | Return visits, exclusive collectibles |
| Seasons | 4-8 weeks | Season pass, seasonal leaderboard, seasonal theme | Long-term goals, recurring revenue |
| Cross-game events | Varies | Collaboration with another game (shared rewards) | New audiences |

## Designing a limited-time event

1. **Theme** (holiday, story beat, collaboration) visible everywhere: lighting, music, decorations, UI accents.
2. **Event currency** earned by playing event activities (not by paying only).
3. **Event shop** where event currency buys exclusive items: pets, cosmetics, boosts.
4. **Event track or quests** with daily goals over the event's duration, so players return daily.
5. **Event egg or roll** with limited items (paid random items rules apply if Robux is involved).
6. **A climax**: a final boss, a community goal, a final day with doubled rewards.
7. **Clear end date**, shown in the game.

Rules:

- **Scarcity must be real.** If you say items are exclusive and will not return, do not bring them back. Roblox also prohibits false scarcity and misleading countdowns.
- **Free path to most rewards.** The event should be enjoyable without paying; purchases speed up or add extras.
- **Catch-up for latecomers**: let players who join halfway still earn most rewards (event currency boosts in the last days).
- **Do not overlap too many events**; players get confused and fatigue sets in.

## Experience events (Roblox feature)

Platform facts:

- Create events in Creator Hub (Engagement > Events & Updates) with a title, description, time, category and a unique thumbnail (a distinct event thumbnail increases engagement).
- Events appear in the **Events** section of your game page; players can **Join event** when it is active or **Notify me** for upcoming events, which sends notifications when it starts (and push notifications if they opt in).
- Each event has a shareable event details page.
- The **Trending Events in Experiences** chart sort can feature active events that started within the last 7 days and have at least **1,000 RSVPs**.
- When players join through an event entry point, the event id is available in their join data, so you can greet them or grant event rewards.
- Group events appear on the group's page.

Use experience events for every update and event: it is free distribution.

## Live admin events

Popular on Roblox: developers appear in-game at a scheduled time and trigger special effects, giveaways, sky events or exclusive rewards for players present.

- Announce days in advance (Discord, group, experience event).
- Make it server-agnostic: use `MessagingService` to trigger the event in all servers at once, so every player gets the moment, not only those in the developer's server.
- Rewards for attending (an exclusive cosmetic) create attendance spikes and clips.
- Test the trigger system privately beforehand. Admin tools must be secured (server-side permission checks by user id or group rank, never client-side).

## Seasons

- 4-8 weeks, each with a theme, a season pass, seasonal leaderboards and seasonal rewards.
- At season end: rewards for leaderboard placement, then a reset of seasonal stats (not permanent progress).
- A short break or teaser between seasons builds anticipation.
- See the season pass section of [Product catalog](../09-monetization/product-catalog.md).

## Event calendar

Plan events a quarter ahead. A typical year includes: New Year, Valentine's, spring/Easter, summer (big: school holidays), back-to-school, Halloween (big), Thanksgiving/Black Friday period, winter holidays (big). Fill gaps with original themed events and collaborations.

## For agents

- [ ] Each event has theme, event currency, shop, daily track, climax and visible end date.
- [ ] Free players can earn most event rewards; latecomers can catch up.
- [ ] "Exclusive" items are never re-released if promised exclusive.
- [ ] Experience event created with a unique thumbnail for every update and event.
- [ ] Admin event triggers are server-authorized and broadcast across servers.
- [ ] Quarterly event calendar maintained.

Related: [Update cadence](update-cadence.md) · [Product catalog](../09-monetization/product-catalog.md) · [Retention systems](../10-retention-and-social/retention-systems.md) · [Community building](../10-retention-and-social/community-building.md)

Sources: [Experience events](https://create.roblox.com/docs/production/promotion/experience-events)
