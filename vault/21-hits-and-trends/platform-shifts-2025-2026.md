---
title: Platform shifts 2025-2026
date: 2026-10-24
tags: [platform, discovery, safety, kids-and-select, devex, rdc, market]
aliases: [Roblox changes 2026, Platform changes, What changed on Roblox, RDC 2026]
summary: The platform changes from 2025 to October 2026 that shape what goes popular - record growth and concentration, recommendation signals that reward return play, ad traffic excluded from recommendation signals, bot purges, Kids and Select going worldwide, AI creation tools, web play announced at RDC 2026, licensing and payouts - each with its source and what it means for the studio.
audience: [human, agent]
---

# Platform shifts 2025-2026

What goes popular depends on the platform's rules as much as on players' tastes. This note lists the changes from 2025 to October 2026 that matter most for choosing and building games. It extends the summary in [The Roblox platform in 2026](../00-start-here/roblox-platform-2026.md). Each item says where the information comes from: official Roblox documentation (Fact), or third-party reporting of a Roblox announcement (Reported). Check the official source before acting on anything marked Reported.

## Scale and concentration

| Change | Source | What it means |
|---|---|---|
| Platform concurrency record of about 47.3M on 2025-08-23, during a mock "admin war" between two games | Reported (press; Wikipedia) | Live events can move the whole platform |
| 2025: revenue about $4.9B (+36%), bookings about $6.8B (+55%), about 126.5M average daily users (+53%), about 123.8B hours (+69%) | Reported (Newzoo summary of public results) | The market is still growing fast |
| Top-of-chart concentration: the biggest title's share of top-10 visits went from 22% to 43% during 2025 | Reported (Newzoo, RoMonitor data) | Winners take more; the middle is thin |

## Discovery and recommendations

| Change | Source | What it means |
|---|---|---|
| Recommendations aim for long-term retention and monetization; impressions follow play-through rate, play days, playtime and first-play bounce | Fact (discovery docs) | Design for return play, not only first-day clicks ([Discovery algorithm](../11-store-page-and-discovery/discovery-algorithm.md)) |
| Engagement, retention and spend from ad-acquired players are excluded from Recommended For You ranking signals; ads do not downrank a game | Fact (discovery FAQ) | Ads buy players, not algorithm credit; organic retention must stand on its own ([User acquisition](../12-live-ops-and-launch/user-acquisition.md)) |
| New games are tested daily with small audiences; signals are read in stages (D1, D2-D7, D8-D28) | Fact (discovery FAQ) | A soft launch gets evaluated quickly; the first week's retention matters |
| Story-driven and finite games are not penalized just because their genre has lower long-term retention | Fact (discovery FAQ) | Finite experiences remain viable |
| Unique metadata and an own spin on trends are recommended; close look-alikes are not prioritized | Fact (discovery docs) | Copies lose twice: players and algorithm ([Trend lifecycle](../15-market-research/trend-lifecycle.md)) |
| 2026-06-15: Recommended For You reportedly moved to a 28-day window and added weight on whether returning players keep playing and whether first-time players leave quickly | Reported (Bloxodes, June 2026) | Same direction: return play wins |
| 2026-08-19: Roblox announced large-scale action against bot accounts; counts may fluctuate; known bot engagement excluded from Recommended For You | Reported (Bloxodes, citing a Developer Forum post) | Expect tracker noise; never buy fake engagement |
| RDC 2026 (2026-09-11): discovery to become more age-aware and to look at whether players return beyond their first week | Reported (Bloxodes, September 2026) | Retention past day 7 matters more |

## Audiences and safety

| Change | Source | What it means |
|---|---|---|
| Age-based Kids (5-8) and Select (9-15) experiences; new games launch to age-checked 16+ players first and must pass an evaluation to reach younger players | Fact (Kids and Select docs) | Plan for a staged audience ([Age ratings and audience](../17-policy-and-business/age-ratings-and-audience.md), [Launch playbook](../12-live-ops-and-launch/launch-playbook.md)) |
| 2026-06-16: Kids and Select experiences made available worldwide, with more restrictive chat defaults for players under 16 | Reported (Bloxodes, June 2026) | The younger audience is reachable only through the evaluation |
| July 2026: eligibility rules loosened twice; Roblox said about 33% more new games per day entered that catalog | Reported (Bloxodes, July 2026) | More competition inside Kids and Select |
| Mid-August 2026: the engaged-player threshold for the evaluation reportedly halved from 500 to 250 | Reported (StudioKrew, August 2026); the current docs state 250 unique plays from highly engaged age-checked users within 60 days | A smaller bar to unlock the full audience |
| Social media links visible only to users verified 16+, and never inside games | Fact (social media links docs) | Community funnels must live on the game page ([Viral and social mechanics](viral-and-social-mechanics.md)) |
| Lawsuits by U.S. states over child safety were filed or allowed to proceed in 2026 (allegations, not findings) | Reported (Bloxodes, June and September 2026) | Safety and age-appropriateness are under scrutiny; follow content rules strictly |

## Creation tools and access

| Change | Source | What it means |
|---|---|---|
| 2026-07-16: a mobile-first tool that turns a text prompt into a basic playable game announced, with a public alpha starting in New Zealand on 2026-07-28 | Reported (Bloxodes, July 2026) | More, faster competition for simple formats; quality and live ops matter more |
| 2026-07-14: unified 2D and 3D Marketplace publishing requirements after revised avatar-item fees | Reported (Bloxodes, July 2026) | Check current fees before UGC plans (money decisions go to the human) |
| RDC 2026: players able to join games in the Chrome browser without installing the app by the end of 2026 | Reported (Bloxodes, September 2026) | New players on laptops and school devices; test performance and input on low-end browsers when available |
| Built-in Studio MCP server and Studio CLI for AI agents | Fact (vault note) | The studio's agent workflow ([Studio MCP playbook](../16-ai-studio-operations/studio-mcp-playbook.md)) |

## Money and IP

| Change | Source | What it means |
|---|---|---|
| License Manager and Licenses catalog (July 2025); Kodansha IP added at RDC 2025; rights holders can send license offers to games detected using their IP | Fact (IP licensing docs) | A legal path to franchises, and a new risk for look-alikes ([Anime IP and legal](../20-anime-games/anime-ip-and-legal.md)) |
| U.S. 18+ DevEx rate of 0.0054 for eligible earnings from verified 18+ U.S. players | Fact (DevEx docs) | Older-audience games with strong character articulation earn more ([Studio business models](studio-business-models.md)) |
| Managed pricing (regional pricing plus price optimization), enabled by default for new items | Fact (managed pricing docs) | Read prices dynamically; protect trades ([Anime monetization](../20-anime-games/anime-monetization.md)) |
| Roblox's 20th anniversary event "The Hunt: Roblox 20" (2026-09-17 to 09-28) brought waves to older participating games | Reported (Bloxodes; Pocket Tactics) | Platform events are free exposure for participating games |

## What the studio does differently because of these shifts

1. **Retention first.** D1, D2-D7 and D8-D28 hooks are designed before launch; ads are never a substitute for organic retention.
2. **Staged audience plan.** Launch to 16+, earn the Kids and Select evaluation with engaged early players, then grow.
3. **Original metadata and IP.** Unique names and art; no look-alikes of hits or franchises.
4. **Safety by default.** Content rules, chat defaults and age-appropriate design are reviewed at every gate.
5. **Live ops as the moat.** As AI tools make simple games cheap, cadence, events and community become the differentiators.
6. **Watch the noise.** Bot purges and seasonal swings distort numbers; compare like with like ([Reading the charts](../15-market-research/reading-the-charts.md)).

## For agents

- [ ] Label every platform claim as Fact (with an official link) or Reported (with the reporter and date).
- [ ] Before acting on a Reported change, look for the official source and record it.
- [ ] Update this note and [Key numbers](../99-reference/key-numbers.md) when Roblox changes a rule.

Sources: [Discovery](https://create.roblox.com/docs/discovery) · [Discovery FAQ](https://create.roblox.com/docs/discovery-faq) · [Roblox Kids and Select](https://create.roblox.com/docs/production/publishing/kids-and-select) · [Social media links](https://create.roblox.com/docs/production/promotion/social-media-links) · [IP licensing](https://create.roblox.com/docs/ip-licensing) · [U.S. 18+ exchange rate](https://create.roblox.com/docs/production/monetization/18-plus-devex-rate) · [Managed pricing](https://create.roblox.com/docs/production/monetization/managed-pricing) · Bloxodes monthly reports (June-September 2026); StudioKrew August 2026 board; Newzoo 2025 summary; Pocket Tactics Innovation Awards coverage. All accessed 2026-10-24.

Related: [The Roblox platform in 2026](../00-start-here/roblox-platform-2026.md) · [Discovery algorithm](../11-store-page-and-discovery/discovery-algorithm.md) · [Anatomy of a Roblox hit](anatomy-of-a-hit.md) · [Age ratings and audience](../17-policy-and-business/age-ratings-and-audience.md) · [Key numbers](../99-reference/key-numbers.md)
