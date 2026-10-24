---
title: Competitive and ranked systems
date: 2026-10-24
tags: [retention, competitive, ranked, rating, seasons, leaderboards, matchmaking]
aliases: [Ranked mode, Rating systems, Elo, Seasons and tiers, Leaderboards]
summary: How to build ranked play that keeps competitive players returning - rating math with a worked Elo example, visible tiers versus hidden ratings, placement matches, seasons and resets, decay, protecting newcomers and stopping smurfs and boosting, leaderboards, rewards, and the server-side rules that keep ratings honest.
audience: [human, agent]
---

# Competitive and ranked systems

Ranked modes give skilled players a long-term goal that does not depend on content updates: getting better. Competitive games such as RIVALS (Best Shooter at the 2025 and 2026 Innovation Awards) show how a skill ladder plus cosmetics can hold players for years ([Evergreen giants](../21-hits-and-trends/evergreen-giants.md)). This note covers the systems behind a fair ladder. Matchmaking mechanics are in [Matchmaking and teleports](../13-building-it-right/matchmaking-and-teleports.md).

## Hidden rating and visible rank

Use two layers:

| Layer | Purpose |
|---|---|
| **Hidden rating** (a number such as Elo or Glicko) | Matchmaking accuracy |
| **Visible rank** (Bronze to Champion, with divisions) | Motivation and identity |

The visible rank follows the hidden rating but moves in friendlier steps (promotion games, protection from instant demotion), so players feel progress even when the rating wobbles.

## Rating math: Elo, worked

The classic Elo update:

```text
Expected score:  E_A = 1 / (1 + 10^((R_B - R_A) / 400))
New rating:      R_A' = R_A + K × (S_A - E_A)      (S = 1 win, 0.5 draw, 0 loss)
```

Example with K = 32: player A (1200) beats player B (1400).

- `E_A = 1 / (1 + 10^(200/400)) ≈ 0.24`
- A gains `32 × (1 - 0.24) ≈ +24.3`; if A had lost, A would lose `32 × 0.24 ≈ 7.7`.
- Between equal players (E = 0.5), a win is worth +16 and a loss -16.

Practical choices:

- **Higher K for new players** (for example 40-64 for the first 20-30 matches) so they reach their true level quickly; lower K later (16-24) for stability.
- **Team games:** use the average rating of each team for the expected score, then apply individual adjustments sparingly (performance-based changes are easy to game).
- **Glicko-style uncertainty** (a rating plus a confidence value) handles returning and new players better; consider it when the player base is large.

## Placement and new players

- **Placement matches** (for example 5-10) before a visible rank is shown.
- **Unranked first:** require a player level or a number of casual matches before ranked unlocks, to keep brand-new players out of ranked lobbies.
- **Starting rating** at the population median, with high K, so new players move fast.

## Seasons

| Element | Rule of thumb |
|---|---|
| Length | 6-12 weeks, aligned with content updates ([Seasonal calendar](../12-live-ops-and-launch/seasonal-calendar.md)) |
| Soft reset | Pull ratings partway toward the median at season start (for example halfway), plus a few placement matches |
| Rewards | Cosmetic rewards by highest rank reached (titles, borders, skins); never power |
| Leaderboard | Top players per region or mode for the season |

## Decay and activity

- Apply decay only at high ranks (to keep top boards active), slowly, after inactivity (for example after 14 days).
- Show decay warnings in advance.
- Never decay lower ranks; it only discourages returning players.

## Integrity

| Problem | Countermeasure |
|---|---|
| Smurfing (experienced players on new accounts) | Level gates, faster K for new accounts, performance-based placement |
| Boosting (strong players carrying weak ones) | Rating-gap limits for parties in ranked; team-average plus gap penalties |
| Win trading | Detect repeated matches between the same players; limit rating gains |
| Leaving to avoid losses | Count leaving as a loss; short ranked bans for repeated leavers |
| Exploits | Results computed on the server from validated events only ([Security and anti-exploit](../13-building-it-right/security-and-anti-exploit.md)) |

**All rating changes happen on the server** from server-recorded results, saved in the player's profile with session locking ([Data persistence](../13-building-it-right/data-persistence.md)). Leaderboards read from server data ([MemoryStore and cross-server systems](../13-building-it-right/memorystore-and-cross-server.md)).

## Matchmaking with ratings

- Queue players with their rating; match within a window that widens with wait time (for example ±100, widening by 50 every 15 seconds).
- Prefer a slightly unfair match soon over a perfect match never; low-population hours need wider windows or bots in casual modes.
- Roblox's custom matchmaking can add a skill signal for public servers, but ranked matches usually use reserved servers formed by your own queue ([Matchmaking and teleports](../13-building-it-right/matchmaking-and-teleports.md)).

## Showing progress

- Show rating change after every match ("+18") and progress within the division.
- Show streaks and personal bests.
- Celebrate promotions with a reveal moment ([Reward, UI and hatch VFX](../19-vfx/reward-ui-and-hatch-vfx.md)).
- Soften losses: show what went well (MVP stats) and keep demotion protection.

## Casual players matter too

Most players never touch ranked. Keep casual modes rewarding, with their own goals, so ranked is an option rather than a requirement ([Retention systems](retention-systems.md)).

## For agents

- [ ] Ratings and results are computed and stored on the server only.
- [ ] Placement, K-factor schedule, season length and reset rule are documented in the design doc.
- [ ] Ranked rewards are cosmetic; integrity countermeasures are implemented before launch.
- [ ] Queue windows widen with wait time; low-population fallbacks exist.

Sources: Innovation Awards 2025 and 2026 winner lists (press); Elo rating system (standard formula).

Related: [Matchmaking and teleports](../13-building-it-right/matchmaking-and-teleports.md) · [Shooters and PvP playbook](../14-genre-playbooks/shooters-and-pvp.md) · [Sports games playbook](../14-genre-playbooks/sports-games.md) · [Endgame and long-term goals](endgame-and-long-term-goals.md) · [Social systems](social-systems.md)
