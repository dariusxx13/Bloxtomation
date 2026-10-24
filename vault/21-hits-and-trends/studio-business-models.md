---
title: Studio business models
date: 2026-10-24
tags: [business, studios, deals, licensing, brands, devex, valuation]
aliases: [Roblox studio business, Buying into a game, Publishing deals, Licensing out a hit]
summary: How money and ownership work around Roblox hits in 2025-2026 - small creators and the studios that buy in, publishing and live-ops partnerships, brand collaborations, licensing a hit to other platforms and films, Roblox's DevEx rates including the U.S. 18+ rate, what makes a game valuable, and which decisions are always the human's.
audience: [human, agent]
---

# Studio business models

Behind many hits is a deal: a small creator finds a loop, then a studio with live-ops experience buys a share and scales it. Hits then become brands licensed beyond Roblox. This note maps those models so the studio can recognise opportunities and risks. It is not legal, tax or financial advice, and every decision here belongs to the human owner. Team money basics are in [Money, DevEx and teams](../17-policy-and-business/money-devex-and-teams.md).

## Who makes hits

| Maker | Strength | Weakness |
|---|---|---|
| Solo creator or tiny team | Speed; finds new loops; low cost | Live ops at scale; monetization; burnout |
| Small studio (3-15) | Steady cadence; polish | Limited marketing reach |
| Established studio or publisher | Live-ops teams, analytics, ads, brand deals, cross-promotion | Slower to find new loops |
| Brand-led studio | Licensed IP and partners | Approvals, revenue shares, brand constraints |

**The 2025 pattern:** Grow a Garden's first version was reportedly made in about three days by a 16-year-old; a studio bought a share in April 2025 when it had around 1,000 concurrent players, and another studio later took a minority share; the original developer was reported to keep half (Wikipedia, citing press interviews). The studio reported to hold that minority share is also reported as the owner of Steal a Brainrot (Wikipedia). By mid-2025 the game had two teams dedicated to weekly events. Small makers found the loops; studios scaled the live operation.

## Deal types

| Deal | What it means | Watch for |
|---|---|---|
| **Equity in the game** | A partner owns a share of the game's revenue (usually via group ownership and revenue splits) | Who controls publishing, monetization and the group; exit terms |
| **Publishing or live-ops partnership** | A partner runs ads, analytics, events and monetization for a share | Fee or share size; performance obligations; creative control |
| **Acquisition** | The game is transferred to the buyer's group | Ownership transfer closes servers during transfer; assets, packages and scripts must move with it ([Why games die](why-games-die.md)) |
| **Contracting** | The studio builds for a client for a fee | Ownership of work, delivery terms |
| **Licensing in** | Building with someone else's IP through the License Manager | Revenue share, approvals, duration ([Anime IP and legal](../20-anime-games/anime-ip-and-legal.md)) |
| **Licensing out** | Letting others use your game's IP (other platforms, films, merchandise) | Brand control; quality; contracts |
| **Brand collaboration** | A brand pays for or partners on content inside your game | Disclosure, content standards, contracts |

## Hits become brands (dated examples)

| Example | What happened | Source |
|---|---|---|
| Steal a Brainrot in Fortnite Creative | An officially licensed replica launched in July 2025 and set an island record (about 400K, later about 500K concurrent players) | Wikipedia, citing press |
| Unlicensed copies sued | The studio behind Steal a Brainrot sued an unlicensed copy on another platform in October 2025; the game is registered with the U.S. Copyright Office | Wikipedia |
| Films | Film adaptations announced for Grow a Garden and Steal a Brainrot (with a production company, November 2025 onward) and for 99 Nights in the Forest (with a major film studio) | Wikipedia; press |
| Concert | A major pop star performed inside Steal a Brainrot in January 2026 (about 12.8M concurrent players) | Wikipedia |
| Branded collaboration award | "Steal a Brainrot x GOAT" won the Innovation in Branded Game category at the 2026 Innovation Awards | Press lists, September 2026 |
| Brand event in an evergreen | Brookhaven ran a two-week event with a dinosaur film brand in September 2026 | StudioKrew, September 2026 |
| Roblox's own titles | "The Hollow", credited to Roblox Presents, appeared among up-and-coming games on 2026-10-24 | Studio chart snapshot |

**Lesson:** a game with original IP can grow into a brand others pay to use. A game built on someone else's IP cannot.

## How Roblox pays (Fact, creator docs, accessed 2026-10-24)

- Players spend Robux on passes, developer products, subscriptions and items; creators also earn engagement-based payouts ([Platform payouts](../09-monetization/platform-payouts.md)).
- Groups can pay collaborators with **one-time payouts** or **recurring percentage splits**; some groups do not have payouts unlocked at first, and payouts cannot be shared for games that charge paid access in local currency.
- The **U.S. 18+ DevEx rate** of 0.0054 USD per Robux applies to certain earned Robux in eligible games from eligible purchases by U.S. players verified as 18 or older; eligibility criteria emphasise high-quality character articulation and strong creative direction for an older audience. Third-party reporting gives the standard rate as 0.0038 and the start of the higher rate as 2026-06-08 (StudioKrew, August 2026). Check the DevEx pages for current rates before any forecast.

## What makes a game valuable

| Driver | Why buyers care |
|---|---|
| Retention (D1, D7, D30) | Predicts how long revenue lasts and how much the algorithm will help |
| Monetization per daily user | Revenue per player, and the fairness of how it is earned |
| Trend phase | A game at the top of a fading wave is worth less than its current numbers suggest |
| Owned IP | Original characters and worlds can be licensed and extended |
| Live-ops pipeline | A content buffer and a team that can keep the cadence |
| Code and data quality | Security, data safety and maintainability reduce risk |
| Dependence on one person | A game only its creator understands is fragile |
| Policy standing | Moderation history, content rating, compliance with paid random item rules |

The studio's own practices (template, gates, check records, analytics) are designed to make games valuable on these drivers ([Quality gates](../16-ai-studio-operations/quality-gates.md)).

## Decisions that are always the human's

Under the house rules, agents never:

- accept, sign or negotiate deals, licenses, publishing or brand agreements;
- transfer, sell or buy games;
- set up or change group payouts;
- spend money on ads, assets, talent or promotion;
- answer policy questions or sign terms.

Agents **prepare**: metrics summaries with sources, code and data audits, risk lists, draft term questions. They escalate with `python3 agents/studioctl.py escalate --kind money` or `--kind policy`.

## For agents

- [ ] Any partner, license or brand opportunity is escalated with a one-page summary of metrics, risks and open questions.
- [ ] Valuation-relevant metrics (retention, monetization, trend phase) are kept current in the game's docs.
- [ ] Original IP ownership records (assets, contracts) are complete.

Sources: [Groups](https://create.roblox.com/docs/projects/groups) · [U.S. 18+ exchange rate](https://create.roblox.com/docs/production/monetization/18-plus-devex-rate) · [Developer Exchange](https://create.roblox.com/docs/production/monetization/developer-exchange) · [Game ownership transfer](https://create.roblox.com/docs/projects/game-ownership-transfer) · Wikipedia articles "Grow a Garden" and "Steal a Brainrot"; Innovation Awards 2026 winner lists; StudioKrew boards (August-September 2026). All accessed 2026-10-24.

Related: [Money, DevEx and teams](../17-policy-and-business/money-devex-and-teams.md) · [Platform payouts](../09-monetization/platform-payouts.md) · [Hits of 2025](hits-2025.md) · [Anime IP and legal](../20-anime-games/anime-ip-and-legal.md) · [Pitch and greenlight](../15-market-research/pitch-and-greenlight.md)
