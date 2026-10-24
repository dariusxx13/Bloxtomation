---
title: The Roblox platform in 2026
date: 2026-10-24
tags: [start-here, platform, audience, discovery, economics]
aliases: [Platform overview, Roblox basics]
summary: Who plays Roblox, how they move between games, how games get found, how money flows, and what changed in 2025-2026.
audience: [human, agent]
---

# The Roblox platform in 2026

Roblox is not an app store. It behaves more like a video platform where every "video" is a playable game, the feed is personalized, and viewers flick between items in seconds. Every design decision in this vault follows from that one fact.

## The audience

**Scale.** Around 123 million daily active users in Q2 2026 (company report, roughly +10% year on year), spending about 29 billion hours on the platform that quarter. Record concurrency is in the tens of millions during big cross-game events.

**Age.** Roblox now has more users aged 13+ than under 13, but the under-13 audience is still large and drives most viral trends. Since 2025-2026 every account sits in an age tier, and the tier controls what your game can reach:

| Tier | Ages | Content allowed | Notes |
|---|---|---|---|
| Roblox Kids | 5-8 (self-declared or checked) | Minimal, Mild | Chat off by default; strong parental controls |
| Roblox Select | 9-15 (self-declared 9+ until age-checked) | Minimal, Mild, Moderate | Chat introduced gradually after age check |
| Roblox | Age-checked 16+ | Everything except Restricted | Restricted (18+) needs age verification |

Platform fact, see [Age ratings and audience](../17-policy-and-business/age-ratings-and-audience.md). A brand-new public game is first shown only to age-checked users 16+. It unlocks the under-16 audience after passing an evaluation (250 unique plays from highly engaged, age-checked users within 60 days, plus a safety review) and meeting creator verification rules. Plan launches around this; see [Launch playbook](../12-live-ops-and-launch/launch-playbook.md).

**Devices.** Most sessions are on phones and tablets, a large share on cheap Android devices. PC is the second platform, then consoles (Xbox, PlayStation) and VR. Design for a 6-inch touchscreen first. See [Mobile-first design](../08-mobile-and-cross-platform/mobile-first-design.md).

**Geography.** The US, UK and Canada are still the biggest spending regions, but growth comes from Europe, Asia-Pacific and Latin America. Regional pricing exists because a 400 Robux item is a very different ask in Brazil than in the US. See [Pricing and price ladders](../09-monetization/pricing-and-price-ladders.md).

## How players behave

- **Sessions hop between games.** A typical Roblox session visits several games. Players join, judge you in seconds, and leave for the next tile. Your first minute competes with the whole Home page.
- **Tourists and locals.** Roblox's own model: *tourists* sample many games and want instant fun and flashy, visible rewards; *locals* settle into a few games, play deeply, and value long-term goals (season passes, collections, ranks). Your first five minutes must win tourists; your systems must turn some of them into locals. See [Monetization strategy](../09-monetization/monetization-strategy.md).
- **Friends move together.** Players follow friends into games, invite them, and play in parties. Games that are better with friends spread faster and keep players longer. See [Social systems](../10-retention-and-social/social-systems.md).
- **Conventions are shared.** Because players hop so much, they carry habits between games: the shop button is on the left, the rebirth button glows, eggs hatch with a shake and a flash, a beam points at the next objective. Breaking conventions costs you clarity. Follow them unless breaking one *is* your hook.
- **Culture moves fast.** Memes, YouTubers, TikTok clips and Discord servers drive spikes. A trend can go from nothing to millions of concurrent players in weeks and fade just as fast. See [Trend lifecycle](../15-market-research/trend-lifecycle.md).

## How games get found

The Home page's **Recommended for You** feed is the biggest source of plays for most games. Roblox has published how it works (platform fact, 2026):

1. **Retrieval** picks a candidate set of games for each user, using engagement, retention and monetization signals.
2. **Ranking** orders those games for that user. It only uses the behavior of players who arrived *organically from Recommended for You*. Ads, friends, search and social links can get you considered, but they do not count toward ranking.

The most important ranking signals are play-through rate (how many people who see your tile play), first-play bounce rate (leaving within roughly the first one to three minutes, a negative signal), play days per user (D1, D2-7 and D8-28), and playtime per user (capped at 60 minutes per user per day). Next come co-play days with friends, qualified play sessions, spend days and Robux spent per user. Signals are averages per user, so a small game with very engaged players is not punished for being small.

In 2026 Roblox said the algorithm leans further toward **long-term engagement over short-term spend**. Games built on a quick spike and heavy monetization lost reach; games people return to for weeks gained it.

Other surfaces: Continue Playing, Friends, Sponsored (ads), curated sorts (for example Standout Games), Charts on the Discover page (top and trending sorts by genre), Search (now semantic, so "food games" works), the game details page (events, groups, passes, similar games) and notifications.

> [!IMPORTANT]
> A game with only a default thumbnail gets **no** Home recommendation impressions. Games whose metadata implies Robux rewards, whose thumbnail does not match the gameplay, or that copy existing games' titles, visuals or place files are demoted. See [Discovery algorithm](../11-store-page-and-discovery/discovery-algorithm.md).

## How money flows

Players buy Robux with real money. They spend Robux in your game, and you keep about **70%** of the Robux price on passes, developer products and Robux subscriptions. You convert earned Robux to cash through the **Developer Exchange (DevEx)** at a standard **0.0038 USD per Robux** (since September 2025; $114 per 30,000 Robux). A higher **0.0054** rate applies to some purchases by age-verified US adults in games that meet avatar requirements (R15-only player characters, from June 2026).

Rough rule for planning: **1,000 Robux spent by a player is about 700 earned Robux, which is about $2.66 at DevEx**. In practice, you see about a quarter to a third of the dollar value players paid for the Robux.

Income sources, from most to least important for a typical game:

1. **In-game purchases**: developer products (repeatable), passes (one-time), subscriptions (monthly).
2. **Creator Rewards** (replaced Premium Payouts in July 2025): 5 Robux per day for each "active spender" who plays your game 10+ minutes as one of the first three games they open that day; plus a 35% revenue share on the first $100 spent by new or returning-lapsed users you bring to Roblox through share links, direct links or searches for your game's name.
3. **Roblox Plus incentives** (new subscription): up to 750 Robux for each subscriber you sign up in-game, payouts for Plus users' time in your paid private servers, and 10% of in-game Robux transfers.
4. **Ads**: rewarded video ads and immersive ads.
5. **Private servers, paid access, avatar item commissions, Creator Store sales.**

Details: [Platform payouts](../09-monetization/platform-payouts.md).

## What changed in 2025-2026 (and why it matters)

| Change | What it means for you |
|---|---|
| Creator Rewards replaced engagement payouts (Jul 2025) | Being one of the first three games a paying player opens each day is worth money. Build a daily habit. |
| DevEx rate up to 0.0038, US 18+ rate 0.0054 | Older-audience games with R15 avatars earn more per Robux. |
| Age tiers (Kids, Select, Roblox) and evaluation for under-16 reach | New games launch to 16+ first. You need engaged early players to unlock the full audience. |
| Recommended for You favors long-term engagement | Retention and return days beat short spikes. |
| Managed pricing (regional pricing plus automatic price tests) | Never hard-code prices; let Roblox localize and test them. |
| Roblox-run in-game Shop and external surfacing of items | Players can buy your items outside your game. Receipt handling must be flawless. |
| Cross-game pass and product sales disabled (May 2026) | Use Robux transfers for any cross-game selling mechanics. |
| Roblox Plus subscription | Plus subscribers get 10-20% off your items at no cost to you. |
| Built-in Studio MCP server and Studio CLI | AI agents can edit, playtest and capture Studio directly. See [Studio MCP playbook](../16-ai-studio-operations/studio-mcp-playbook.md). |
| Configs and Experiments in Creator Hub | Tune live values without republishing and run real A/B tests. See [Experiments and configs](../12-live-ops-and-launch/experiments-and-configs.md). |

## What this means for design

1. **Win the first minute.** Bounce in the first one to three minutes is a top negative signal. See [First session blueprint](../01-first-five-minutes/first-session-blueprint.md).
2. **Earn return days, not just minutes.** Play days per user across D1, D2-7 and D8-28 weigh heavily. See [Retention systems](../10-retention-and-social/retention-systems.md).
3. **Be better with friends.** Co-play days are a ranking signal, and friends are the cheapest acquisition channel.
4. **Monetize what players love, not what they need to escape frustration.** Spend days and spend per user count, but only after retention is healthy. Roblox's own advice: fix the core game first, then improve monetization.
5. **Update often.** Weekly updates are the norm for top games; monthly is the minimum. Each update gets you a fresh exploration window in Recommended for You. See [Update cadence](../12-live-ops-and-launch/update-cadence.md).
6. **Be original enough.** Copies of existing games are demoted. Following a trend is fine; cloning it is not. See [Trend lifecycle](../15-market-research/trend-lifecycle.md).

Sources: [Discovery](https://create.roblox.com/docs/discovery), [Creator Rewards](https://create.roblox.com/docs/creator-rewards), [Roblox Kids and Select](https://create.roblox.com/docs/production/publishing/kids-and-select), [Developer Exchange](https://create.roblox.com/docs/production/monetization/developer-exchange), [Roblox Plus](https://create.roblox.com/docs/production/monetization/roblox-plus), [The Roblox user base](https://create.roblox.com/docs/production/roblox-user-base). Company and market figures from public Q2 2026 reporting.

Related: [The hit formula](hit-formula.md) · [Discovery algorithm](../11-store-page-and-discovery/discovery-algorithm.md) · [Platform payouts](../09-monetization/platform-payouts.md) · [Age ratings and audience](../17-policy-and-business/age-ratings-and-audience.md) · [Key numbers](../99-reference/key-numbers.md)
