---
title: Web, offline and new surfaces
date: 2026-10-24
tags: [cross-platform, web, offline, moments, discovery, roadmap]
aliases: [Web play, Browser play, Offline play, Moments, Roblox Everywhere]
summary: The new places players will meet Roblox games, as announced at RDC 2026 - web play in Chrome from a link, offline solo play, standalone apps, the Moments video tab, Friends chat and Quick Words - what each means for first sessions, input, performance, links and video, and how to prepare without relying on features before they ship.
audience: [human, agent]
---

# Web, offline and new surfaces

Until now most players arrived through the Roblox app's home page. At RDC 2026 (2026-09-11) Roblox announced several new surfaces where players will find and play games. Some are live, some are coming. This note lists them with their stated timing and what to prepare. Facts come from the Roblox newsroom post for RDC 2026, read on 2026-10-24; check the official pages before building on any of them ([Engine and platform features 2024-2026](../22-references/engine-features-2024-2026.md)).

## The surfaces

| Surface | Status (as announced) | What it is |
|---|---|---|
| **Web play** | By the end of 2026, in Chrome first | Join a game in the browser from its detail page, no install; links from search, video sites, social posts or emails start play instantly |
| **Moments** | Fully available in the U.S. | A tab of gameplay videos where players watch and click to play; videos from games' detail pages will appear there |
| **Offline play** | Early access soon; available by mid-2027 | Creators can enable offline solo play alongside the live multiplayer mode |
| **Standalone apps** ("Roblox Everywhere") | Announced | Games available as their own apps on mobile, PC and consoles, powered by Roblox |
| **Friends chat tab** | Live | Chat that follows players across games so friends can coordinate and move together |
| **Voice typing** | Released | Talk instead of typing while playing |
| **Quick Words** | Later in 2026 | Pre-set, pre-reviewed phrases a game can offer (for example "start your engines") |

## What web play changes

**Who arrives:** people clicking a link, often on laptops and school or shared computers, sometimes without having played Roblox recently.

| Area | Prepare |
|---|---|
| First session | The first 60 seconds must work for someone who arrived from a video link with no context ([First session blueprint](../01-first-five-minutes/first-session-blueprint.md)) |
| Input | Mouse and keyboard on trackpads: no reliance on right-click drags or precise mouse aiming in the first minute ([Controls and input](controls-and-input.md)) |
| Load | Smaller initial loads and streaming; a browser tab with a long load loses players faster than an installed app ([Device performance](device-performance.md)) |
| Links | Use share links and launch data so a link can open the right mode or reward ([Viral and social mechanics](../21-hits-and-trends/viral-and-social-mechanics.md)) |
| Analytics | Track acquisition by source to see browser players' retention separately ([Analytics instrumentation](../13-building-it-right/analytics-instrumentation.md)) |

Until web play is released, do not assume its performance profile; test when it is available.

## What Moments changes

Moments turns gameplay video into a front door. Practical steps:

- Upload strong, honest gameplay videos to the game's detail page; Roblox said those will start appearing in Moments ([Store page video](../11-store-page-and-discovery/store-page-video.md)).
- Design clip moments that read in a few seconds without sound: rare reveals, escapes, big hits ([Clip moments and shareability](../02-core-loop/clip-moments-and-shareability.md)).
- Make sure the first seconds after clicking from a video match what the video showed; a mismatch causes immediate bounces.

## What offline play may change

Offline solo play suggests new design space: a solo mode that works on a plane, with progress joining the online game later. The rules (what can be saved, synced or bought offline) were not detailed in the announcement. Until they are:

- Keep game logic separable from online-only services (data stores, purchases, messaging), which the template's architecture already encourages ([Project architecture](../13-building-it-right/project-architecture.md)).
- Do not design features that depend on offline play.

## Standalone apps

Roblox said creators will soon be able to make games available as standalone apps. If the studio considers it, the decision involves branding, store presence, and possibly terms and fees, so it is a human decision ([Studio business models](../21-hits-and-trends/studio-business-models.md)).

## Friends chat and Quick Words

- Friends chat across games makes "move together into a new game" easier: invite prompts, parties and matchmaking that keeps friends together matter more ([Matchmaking and teleports](../13-building-it-right/matchmaking-and-teleports.md)).
- Quick Words give all ages safe coordination; plan phrases that match the game's actions (for example "Defend the base!", "Need help here") when the feature arrives.

## For agents

- [ ] Treat announced surfaces as plans; record the date checked before relying on any of them.
- [ ] First-session reviews include a "link arrival" test: a player who has only seen one video.
- [ ] Detail-page videos are honest gameplay, refreshed with major updates.

Sources: Roblox newsroom, [RDC 2026: The World Needs More Play](https://about.roblox.com/newsroom/2026/09/rdc-2026-the-world-needs-more-play) (2026-09-11, accessed 2026-10-24) · [Share links](https://create.roblox.com/docs/production/promotion/share-links)

Related: [Mobile-first design](mobile-first-design.md) · [Controls and input](controls-and-input.md) · [Platform shifts 2025-2026](../21-hits-and-trends/platform-shifts-2025-2026.md) · [Store page video](../11-store-page-and-discovery/store-page-video.md) · [Device performance](device-performance.md)
