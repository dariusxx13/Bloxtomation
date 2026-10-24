---
title: Viral and social mechanics
date: 2026-10-24
tags: [virality, social, invites, referrals, share-links, clips, server-size, growth]
aliases: [Virality on Roblox, Invite rewards, Referral system, Social growth loops]
summary: The mechanics that make players bring other players - consequence and theft, server size, co-op roles, show-off moments, clips, trading - and Roblox's official growth tools (invite prompts, the friend referral system, share links with launch data, notifications), with abuse-safe reward rules and a server-side referral sketch.
audience: [human, agent]
---

# Viral and social mechanics

A Roblox game grows fastest when its players recruit other players. Recommendations amplify that growth, but the spark is social: friends joining friends, clips spreading, rivals returning for revenge. This note collects the mechanics that produce that effect in recent hits and the official tools that support it. Foundations are in [Social systems](../10-retention-and-social/social-systems.md) and [Clip moments and shareability](../02-core-loop/clip-moments-and-shareability.md).

## Mechanics that make players recruit players

| Mechanic | Why it spreads | Recent example (third-party reports) |
|---|---|---|
| **Consequence from other players** | Loss creates stories, revenge and "come help me defend" | Stealing in Steal a Brainrot and Steal An Egg; night raids in Grow a Garden 2 |
| **Small servers** | Every player is visible; theft and rivalry feel personal | Servers of seven in Steal An Egg and six in Ride A Pet |
| **Asymmetric co-op roles** | Friends need each other in different roles | Ten classes in Animal Hospital |
| **Shared threat** | Fear and survival are better together | 99 Nights in the Forest |
| **Show-off moments** | Rare items and pets displayed to the whole server | Server-wide rarity announcements, display bases |
| **Trading** | Value only exists with other players | Murder Mystery 2, Adopt Me, Blox Fruits |
| **Competitive ladders** | Rivals return to win back status | RIVALS duels, battlegrounds kill streaks |
| **Clip moments** | Reactions and rare events become videos | Upset reactions to stolen characters; rare reveals; ultimates |
| **Live events** | "Get online now" messages to friends | Weekly admin sessions and update parties ([Live events and admin events](live-events-and-admin-events.md)) |

Design at least two of these into the core loop, not as add-ons.

## Choosing server size

Server size (`MaxPlayers`) shapes the social design:

| Size | Feels like | Good for |
|---|---|---|
| 4-8 | A small group where everyone knows everyone | Theft, rivalry, co-op horror, party games |
| 10-20 | A neighbourhood | Simulators with show-off, battlegrounds, farming |
| 25-50+ | A town or arena | Roleplay hubs, large battles, social hangouts |

Small servers also fill faster for friends joining together and make each player's actions matter. Big servers create crowds but hide individuals. Test the choice in playtests; do not keep the default.

## Official growth tools (Fact, creator docs, accessed 2026-10-24)

### Invite prompts

`SocialService` can prompt a player to invite friends from inside the game, using `ExperienceInviteOptions` to customise the prompt text, target a specific friend and attach **launch data** that the invited friend's join can read through `Player:GetJoinData()` (for example, spawning them next to the inviter or opening a specific mode). Prompt at natural moments: after a win, before a co-op mode, when a raid starts, never on a timer.

### Friend referral system

The friend referral system tracks who invited whom. `GetJoinData()` populates a `ReferredByPlayerId` for invited players across invitation types, and creators can show a customised **reward banner** in the invite menu to explain rewards for inviters and invitees.

### Share links

Share links are unique, trackable links created in the Creator Dashboard for off-platform channels (a video description, a community post). Each can carry custom launch data for an in-game perk, and acquisition analytics show which channel brings the most engaged players. Create one link per channel to compare them ([User acquisition](../12-live-ops-and-launch/user-acquisition.md)).

### Notifications

Experience notifications reach opted-in players outside the game (for example "your garden is ready" or "the raid starts in 10 minutes") and can carry launch data. Keep them useful and rare ([Retention systems](../10-retention-and-social/retention-systems.md)).

### Social links rule

Links to social media are shown only on the game's detail page and only to users verified as 16 or older; games must not show links, invite codes or addresses inside the game ([Anime community, updates and codes](../20-anime-games/anime-community-updates-and-codes.md)).

## Reward rules that resist abuse

Invite rewards attract alt accounts and farming. Rules of thumb:

1. **Reward the inviter only after the invitee plays for real** (for example 10 minutes of active play or a first milestone), checked on the server.
2. **Cap rewards** per inviter per day and in total.
3. **One reward per invitee**, ever, recorded in the invitee's profile.
4. **Reward both sides**, with the invitee's reward helping them start (a starter boost) and the inviter's reward cosmetic or modest.
5. **Never grant paid currency** for invites in a way that makes invite-farming worth more than playing.
6. **Store pending rewards** for offline inviters in their saved data so they receive them on next join.

### Server-side referral sketch

```lua
--!strict
-- Referral (sketch): reward an inviter once the invitee has really played.
-- Pending rewards for offline inviters are written to their saved data elsewhere.
local Players = game:GetService("Players")

local REQUIRED_ACTIVE_SECONDS = 600

local pending: { [Player]: number } = {} -- invitee -> inviter user id

Players.PlayerAdded:Connect(function(player)
	local joinData = player:GetJoinData()
	local inviterId = joinData.ReferredByPlayerId
	if typeof(inviterId) == "number" and inviterId > 0 and inviterId ~= player.UserId then
		pending[player] = inviterId
	end
end)

Players.PlayerRemoving:Connect(function(player)
	pending[player] = nil
end)

-- Called by the session tracker when a player's active time crosses a threshold.
local function onActiveTime(player: Player, activeSeconds: number)
	local inviterId = pending[player]
	if not inviterId or activeSeconds < REQUIRED_ACTIVE_SECONDS then
		return
	end
	pending[player] = nil
	-- Check the invitee's profile flag (rewarded once ever) and the inviter's daily cap,
	-- then grant through the shared rewards module and log an analytics event.
end

return { onActiveTime = onActiveTime }
```

## Clips by design

Players record what surprises them. Make those moments easy to capture:

- Big, readable reveals with sound for rare outcomes ([Reveal and hatch design](../03-rarity-and-rng/reveal-and-hatch-design.md)).
- Short slow-motion or camera moments on rare events, with a setting to reduce motion.
- Names and ranks visible above players, so viewers can find them.
- A photo or pose mode for show-off.
- No UI covering the action during peak moments.

## Measuring social growth

Track these per day and per acquisition source ([Analytics instrumentation](../13-building-it-right/analytics-instrumentation.md)):

| Metric | Meaning |
|---|---|
| Share of sessions with a friend present | How social the game is |
| Invites sent per active player | Willingness to recruit |
| Invite acceptance rate | Prompt quality and timing |
| D1 and D7 retention of invited players versus others | Whether social players stay longer |
| Players who joined through share links, by channel | Which channels work |

Roblox's own discovery signals include "intentional co-play days" among the secondary signals worth checking (Fact, discovery docs, accessed 2026-10-24) ([Discovery algorithm](../11-store-page-and-discovery/discovery-algorithm.md)).

## For agents

- [ ] At least two social mechanics are part of the core loop.
- [ ] Server size is chosen and justified in the GDD.
- [ ] Invite prompts fire at natural moments; launch data routes invitees to the inviter.
- [ ] Referral rewards follow the abuse-safe rules and are granted on the server.
- [ ] No social links or invite codes inside the game.

Sources: [Player invite prompts](https://create.roblox.com/docs/production/promotion/invite-prompts) · [Friend referral system](https://create.roblox.com/docs/production/promotion/referral-system) · [Share links](https://create.roblox.com/docs/production/promotion/share-links) · [Experience notifications](https://create.roblox.com/docs/production/promotion/experience-notifications) · [Social media links](https://create.roblox.com/docs/production/promotion/social-media-links) · [Discovery](https://create.roblox.com/docs/discovery) · Third-party examples from StudioKrew boards (July-September 2026) and Wikipedia, accessed 2026-10-24.

Related: [Social systems](../10-retention-and-social/social-systems.md) · [Anatomy of a Roblox hit](anatomy-of-a-hit.md) · [Live events and admin events](live-events-and-admin-events.md) · [User acquisition](../12-live-ops-and-launch/user-acquisition.md) · [Community building](../10-retention-and-social/community-building.md)
