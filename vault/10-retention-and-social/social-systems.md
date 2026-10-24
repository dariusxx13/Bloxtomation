---
title: Social systems
date: 2026-10-24
tags: [social, co-play, invites, referrals, multiplayer]
aliases: [Co-play, Multiplayer design, Friends]
summary: How to make a Roblox game better with friends and with strangers: co-play incentives, invites and referrals, show-off, cooperation, competition and safe social design.
audience: [human, agent]
---

# Social systems

Roblox is a social platform first. Players follow friends into games, play together, and talk about games outside Roblox. Co-play days (returning to play with friends) are a Recommended-for-You signal, friend invites are free acquisition, and players who play with friends tend to stay longer. A single-player game in a multiplayer server wastes all of that.

## Layers of social design

| Layer | Question | Examples |
|---|---|---|
| Presence | Can I see other players and what they have? | Visible pets, auras, bases, titles, leaderboards |
| Co-play | Is it better to play with friends? | Friend luck bonus, shared rewards, co-op bosses, party queue |
| Cooperation | Do strangers benefit from helping each other? | Server-wide boosts, raid bosses, shared goals |
| Competition | Can I compare myself and compete? | Leaderboards, PvP, races, records |
| Exchange | Can I give or trade? | Trading, gifting, helping |
| Community | Do I belong to something? | Clans, groups, Discord, events |

## Co-play incentives

- **Friend bonus**: "+10% luck/coins per friend in the server, up to +50%". Simple and very effective; it also counts toward intentional co-play days.
- **Party features**: join a friend's server from the menu, queue rounds together, teleport to a friend.
- **Shared progress**: co-op bosses where both players get rewards; shared plots or farms; team missions.
- **Joint moments**: things that are only possible together (two-player puzzles, combo attacks, carrying a friend).

Roblox supports parties at the platform level; `SocialService` exposes party information (for example `GetPlayersByPartyId`) so you can keep parties together in teams or matchmaking.

## Invites and referrals

- **Invite prompts**: `SocialService:PromptGameInvite(player, options)` opens a friend picker (check `CanSendGameInviteAsync` first). With `ExperienceInviteOptions` you can customize the prompt message, invite a specific friend, use a custom notification message (created in Creator Hub, using placeholders for the game name and sender), and attach launch data (up to 200 characters) that the friend's client receives on join.
- **Friend referral rewards**: players joining through a referral link carry `ReferredByPlayerId` in `Player:GetJoinData()`. Reward **both** the inviter and the new player (a badge, currency, a pet), and show a reward banner in the invite modal so players know the deal.
- **When to prompt**: after a fun moment or when a feature needs friends ("This boss is easier with friends! Invite?"). Never as a popup on spawn.
- **No fake invite gates**: never require invites to access content.

## Show-off

Status is one of the strongest motivations on Roblox:

- Equipped pets, auras, trails and titles visible to everyone.
- Rare drops broadcast in chat and announced visually.
- In-world leaderboards (daily, weekly, all time) and showcases in the lobby.
- Badges for achievements (Roblox badges appear on profiles).
- Base or house visits: players can tour each other's creations.

## Competition

- **Leaderboards** with multiple time windows so new players can rank (today, this week, all time) and multiple stats (power, rebirths, rare collection, time played).
- **Records** ("fastest clear", "biggest fish") with names attached.
- **PvP** only where it fits; optional PvP zones protect players who do not want it.
- **Matchmaking fairness**: new players should not meet veterans in competitive modes immediately.

## Cooperation with strangers

- **Server-wide boosts** bought or triggered by one player for everyone (thank the buyer publicly).
- **Raid bosses** where everyone's damage counts and everyone gets rewards.
- **Server goals** ("Server collected 1M candies: everyone gets a chest").
- These turn strangers into allies and make full servers feel good.

## Chat and voice

- Roblox's `TextChatService` handles text chat with filtering. Any text players type that others will see (pet names, signs, base names) **must** be filtered with `TextService` before display. Never show unfiltered player text.
- Voice chat is available to eligible age-checked users; design so the game works without voice.
- Age tiers affect chat availability (for example chat is off by default for the youngest tier). Social features must not depend on chat to function.

## Safety in social design

- Allow players to hide from others' effects or block interactions.
- Avoid features that encourage harassment (unbounded griefing, stealing everything from new players). In steal-and-defend games, protect newcomers.
- Do not build ways to exchange off-platform contact details or move conversations off Roblox.

## For agents

- [ ] A friend bonus or co-play-only feature exists.
- [ ] Invite prompts use `ExperienceInviteOptions` with launch data where useful; shown after positive moments.
- [ ] Referral rewards for both inviter and invitee, with a reward banner.
- [ ] Visible status: pets, auras, titles, in-world leaderboards with several time windows.
- [ ] All player-written text filtered with `TextService` before others see it.
- [ ] The game works fully without text or voice chat.

Related: [Retention systems](retention-systems.md) · [Community building](community-building.md) · [Clip moments and shareability](../02-core-loop/clip-moments-and-shareability.md) · [Lobby and hub design](../06-world-and-look/lobby-and-hub-design.md) · [Trading economies](../04-progression-and-economy/trading-economies.md)
