---
title: Lobby and hub design
date: 2026-10-24
tags: [world, lobby, hub, social, monetization]
aliases: [Lobby, Hub, Spawn area]
summary: How to design the shared spaces where players spawn, wait, meet, shop and show off, which often decide first impressions and social retention.
audience: [human, agent]
---

# Lobby and hub design

The lobby (in round-based games) or the hub (in persistent games) is the most visited place in your game. It is where new players form their first impression, where veterans show off, and where waiting happens between rounds. Treat it as a product, not a waiting room.

## Jobs of a lobby or hub

1. **Orient new players**: show what the game is and where to start.
2. **Fill waiting time**: give something to do between rounds or while a timer runs.
3. **Show off**: let veterans display rare items, ranks and pets where others see them.
4. **Sell honestly**: shops and featured offers placed where players naturally pass, never blocking movement.
5. **Connect players**: create reasons to talk, trade, party up and compete.

## Layout rules

- **Spawn facing the main action** (the queue portal, the first activity, the hub center).
- **Compact.** Everything important within a short walk (or a few seconds). Big empty lobbies feel dead.
- **Clear landmarks** for each function: a big shop building, a glowing portal to play, a leaderboard wall, an event stage.
- **Leaderboards in the world** on `SurfaceGui` walls, near spawn: top players today, this week, all time. They are social proof and status.
- **Showcase spots**: podiums or display cases for the server's top players or rarest items.
- **Event stage**: one area that changes with each event (decorations, NPCs, a boss arena).

## Things to do while waiting

- Mini activities: an obby course, a punching bag, a basketball hoop, a spinning wheel with free daily spins.
- Social toys: emote pads, music, seats, photo spots.
- Progression: daily quest board, rewards to claim, shop browsing.
- Spectating the current round on a big screen (a `SurfaceGui` or camera feed) in round-based games.

Waiting time should never be more than about 30 seconds in a full server; if it is, the round design is the problem (see [Session structure](../02-core-loop/session-structure.md)).

## Monetization in the hub (fair placement)

- A shop building or kiosk on the main path, visible but not in the way.
- Display passes as physical objects (a VIP door that shows what is behind it, a gamepass podium with the reward model spinning).
- A VIP area that is cosmetic or comfort-oriented (lounge, special emotes, exclusive cosmetic shop), never required for progress.
- Never block the play portal with shops or force players through a sales path.

## Social design details

- Name tags with titles, ranks or clan tags above avatars (`BillboardGui` with short distance).
- Visible pets, auras and trails.
- Chat-friendly spaces: places to stand together, not long corridors.
- Party queue: friends can enter the next round together from the lobby.

## Performance

The lobby is where everyone gathers, so it is the most performance-critical area:

- Keep part counts and effects modest; many players with pets and auras already cost a lot.
- Offer a setting to hide other players' pets or effects.
- Stream or unload round maps when players are in the lobby.

## For agents

- [ ] Spawn faces the main action; the play portal or first activity is visible immediately.
- [ ] Lobby or hub has an activity for waiting, leaderboards in the world, and a showcase spot.
- [ ] Shops are visible on the main path but never block movement or the play portal.
- [ ] VIP areas are cosmetic or comfort-only.
- [ ] Lobby performance checked with a full server of players with pets and effects.

Related: [World and level design](world-and-level-design.md) · [Social systems](../10-retention-and-social/social-systems.md) · [Session structure](../02-core-loop/session-structure.md) · [Shop UX and contextual offers](../09-monetization/shop-ux-and-contextual-offers.md)
