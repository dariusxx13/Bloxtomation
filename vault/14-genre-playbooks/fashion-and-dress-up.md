---
title: Fashion and dress-up playbook
date: 2026-10-24
tags: [genre, fashion, dress-up, avatar, social, voting, playbook]
aliases: [Dress-up games, Fashion games, Runway games, Avatar creator games]
summary: How to build Roblox fashion and dress-up games - themed rounds with a timed dressing room, runway and voting, wardrobes with layered items and makeup, fair and kind voting, progression and quests, selling avatar items and in-game cosmetics, safety for a young audience, and performance for many detailed avatars.
audience: [human, agent]
---

# Fashion and dress-up playbook

Fashion games turn Roblox's love of avatars into a game: dress for a theme, walk the runway, get voted on. Dress To Impress is the genre's giant, with about 11.2B visits and about 229K players during its Halloween quest in the studio's 2026-10-24 snapshot. Avatar editor and catalog games (for example Catalog Avatar Creator, about 91K players in the same snapshot) form a related "Shopping" category.

Roblox genre: Roleplay & Avatar Sim (dress-up competitions) or Shopping (catalog and avatar editors).

## Audience

Mostly younger players, a large share of girls, very social, heavy short-video and creator audience. Mobile-majority. Sessions are a series of rounds, often 20-60 minutes.

## The loop

```
Moment:  pick an item -> see it on your avatar instantly -> combine and adjust
Round:   theme announced -> timed dressing room -> runway walk and pose -> voting -> placement and rewards
Long:    unlock items and makeup -> levels and titles -> quests and seasonal themes -> show-off
```

## Core mechanics

### Themes

A theme per round ("Fairy tale", "Rock star", "Under the sea"), drawn from a large pool with seasonal and event themes. Themes must be understandable by young players at a glance (an icon plus one or two words).

### The dressing room

- A **timer** (for example 3-5 minutes) creates urgency and keeps rounds moving.
- Categories: hair, tops, bottoms, dresses, shoes, accessories, makeup, poses, effects.
- **Colour pickers** and patterns multiply the value of each item.
- **Instant preview** on the avatar with a rotating camera and lighting presets.
- Search and favourites for large wardrobes.
- Works one-handed on a phone.

### Runway and voting

- Each player walks with a chosen pose and walk style; camera and music make it a moment.
- Others vote (for example 1-5 stars); the game shows placement, not individual voters.
- **Fairness and kindness:** hide who voted what; cap the effect of friends voting for friends; discard extreme outlier votes; reward participation as well as placement.

### Progression

- Currency and XP from rounds; bonuses for placement and for completing the theme's "hidden" requirements.
- Unlockable items, makeup and poses; titles and badges.
- Quests and events with themed items ([Events and seasons](../12-live-ops-and-launch/events-and-seasons.md)).

## Avatar and item systems

- Use **layered clothing and accessories** that fit Roblox avatar bodies; test across body types.
- Keep wardrobe items as data (definition ids) and apply them to the avatar on the server for visibility to others, or render outfits on clients from replicated outfit data to save bandwidth.
- Save outfits as presets in the player profile ([Data persistence](../13-building-it-right/data-persistence.md)).
- Check avatar scaling rules so outfits do not create oversized or obstructive avatars.

## Monetization

| Product | Notes |
|---|---|
| VIP pass | Exclusive items or a VIP section, extra time, extra outfit slots |
| Item packs and makeup sets | Themed bundles; seasonal drops |
| Poses, walks and effects | Show off on the runway |
| Private servers | Friends and creators |
| Real avatar items | Marketplace items sold in the game; per the licensing docs' revenue example, items sold inside a game give the game owner a seller share in addition to the creator's share ([IP licensing for creators](https://create.roblox.com/docs/ip-licensing/creators)) |

Avoid selling voting advantages. Purchases should change what you can wear, not how others judge you ([Monetization strategy](../09-monetization/monetization-strategy.md)).

## Safety for a young audience

- **Content standards:** items and combinations must respect Roblox's Community Standards; block revealing or inappropriate combinations; review new items.
- **Voting and comments:** no free-text comments on others' outfits; fixed positive reactions only.
- **Bullying:** report tools, kick-vote limits, moderation of names and chat ([Community standards for developers](../17-policy-and-business/community-standards-for-devs.md)).
- **Age ratings:** complete the questionnaire honestly; the human answers it ([Age ratings and audience](../17-policy-and-business/age-ratings-and-audience.md)).

## Performance

Many detailed avatars with layered clothing in one server is heavy:

- Limit server size (for example 12-20).
- Use streaming and simple runway environments.
- Lazy-load wardrobe thumbnails and 3D previews; one shared preview `ViewportFrame` instead of one per item ([UI implementation](../05-ui-and-hud/ui-implementation.md)).
- Test a full server on a low-end phone.

## Retention and social

Daily themes and streaks, weekly events, seasonal collections, friend lobbies, "best dressed" boards for the server, photo modes for sharing outside the game.

## Clip moments

Runway walks, dramatic reveals, last-second outfit changes, winning with an unexpected look, "transformations" from basic to stunning. Add a photo and pose mode.

## Traps

| Trap | Fix |
|---|---|
| Voting unfairness and friend-voting | Hidden votes, outlier trimming, participation rewards |
| Wardrobe UI unusable on phones | Big categories, search, favourites, one-handed design |
| Unsafe item combinations | Rules, reviews, blocked combinations |
| Thin item library | A weekly item drop pipeline before launch |
| Lag with many avatars | Smaller servers, streaming, preview optimisation |

## For agents

- [ ] Themes are readable at a glance; the dressing-room timer and round flow are tested with newcomers.
- [ ] Voting is anonymous, trimmed and paired with participation rewards.
- [ ] Items are reviewed for content standards; no free-text judging.
- [ ] Wardrobe UI works one-handed on a phone; full-server performance is tested.

Sources: [Layered clothing](https://create.roblox.com/docs/avatar/layered-accessories) · [IP licensing for creators](https://create.roblox.com/docs/ip-licensing/creators) · the studio's chart snapshot of 2026-10-24.

Related: [Roleplay and life sim playbook](roleplay-life-sim.md) · [Party and minigames playbook](party-and-minigames.md) · [Social systems](../10-retention-and-social/social-systems.md) · [Menus, shops and inventories](../05-ui-and-hud/menus-shops-inventories.md) · [Age ratings and audience](../17-policy-and-business/age-ratings-and-audience.md)
