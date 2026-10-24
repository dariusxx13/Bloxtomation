---
title: Platform payouts
date: 2026-10-24
tags: [monetization, devex, creator-rewards, roblox-plus, payouts]
aliases: [Creator Rewards, DevEx, Roblox Plus, How Roblox pays creators]
summary: Every way Roblox pays creators in 2026 besides direct sales (Creator Rewards, Roblox Plus incentives, ads, private servers, transfers), how DevEx works, and the design moves that increase each one.
audience: [human, agent]
---

# Platform payouts

Direct sales (passes, products, subscriptions) are the biggest income source for most games, but Roblox also pays you for engagement, for bringing new players, and for some platform subscriptions. These payouts reward exactly the behavior that also grows your game, so design for them.

> [!NOTE]
> Facts on this page are dated 2026-10-24 and come from Roblox's creator documentation. Payout programs change; check the linked pages before making financial decisions.

## The revenue share on sales

- You receive about **70%** of the Robux price of passes, developer products and Robux subscriptions.
- Local-currency subscriptions pay 70% in the first month and **100%** in following months.
- Some earnings have holding periods before they become available (for example Creator Rewards and Plus incentives have a 60-day hold; paid access in Robux up to 7 days; Creator Store sales 30 days).

## Developer Exchange (DevEx)

- **Standard rate: 0.0038 USD per earned Robux** (since 5 September 2025; $114 per 30,000 Robux). Earned Robux from before that date cash out first, at the old 0.0035 rate.
- **US 18+ rate: 0.0054 USD per earned Robux** (since 8 June 2026) for earned Robux from developer products, passes, subscriptions and private servers bought by US players who verified they are 18+, in games whose player characters meet the requirements (R15-only platform avatars, or qualifying custom human-form or non-human characters; any R6 option disqualifies).
- **Eligibility**: 13+, at least 30,000 earned Robux, compliance with Roblox terms, and one completed cash-out per calendar month. Processing takes around 10 business days for first-timers and about 5 for returning participants.
- **Earned Robux** includes sales, Creator Rewards, Plus incentives, private servers, paid access, ad publishing earnings and the fee share from in-game Robux transfers. It does not include Robux bought with money, monthly stipends, Robux received through transfers or gift cards.

## Creator Rewards (since July 2025)

Creator Rewards replaced engagement-based payouts (Premium Payouts) and the Creator Affiliate program.

### Daily Engagement rewards

You earn **5 Robux per day** for each **active spender** who plays your game for **10+ minutes** that day, if your game is one of the **first three** games they open that day.

- Active spender: a user who spent at least $9.99 on Robux, Premium or UGC subscriptions in the last 60 days, and was not a new or reactivated user in that period.

Design implications:

- Be a **daily first stop**. Daily rewards, streaks, crops ready in the morning, a weekly event that starts at a known time: anything that makes your game the first thing players open.
- Ten minutes is the threshold. A daily session that reliably reaches 10 minutes (daily quests, a short daily loop) matters.
- Paying players' habits matter most; take care of your spenders' experience.

### Audience Expansion rewards

When a **new user** joins Roblox (or a **lapsed user**, inactive for 60 days, returns) and is attributed to your game, you earn **35% of their first $100 of qualifying purchases anywhere on Roblox** during their first 60 days. Attribution requires one of:

- Clicking your game's **share link**, joining Roblox and playing your game 10+ minutes that day.
- Clicking your game's direct link, with your game as their first session that day, 10+ minutes.
- Searching your **exact game name**, with your game as their first session that day, 10+ minutes.

And your game must average **100+ DAU for 60 days** after the join. Requires an ID-verified account in good standing.

Design implications:

- Off-platform growth pays twice: new players and a share of their spending. Use share links everywhere (videos, Discord, social). See [User acquisition](../12-live-ops-and-launch/user-acquisition.md).
- A distinctive, searchable name helps attribution by search.
- Strictly forbidden: bots, automation, teleport manipulation, encouraging alt accounts, impersonation, fraud. Violations forfeit rewards and can terminate accounts.

## Roblox Plus incentives

Roblox Plus is a user subscription. For creators it means:

- **Subsidized discounts**: Plus subscribers get 10% off eligible purchases (20% from their third month), but Roblox covers the discount, so you earn the same as from a full-price sale. Requires runtime price display (see [Pricing and price ladders](pricing-and-price-ladders.md)).
- **Sign-up bonus**: up to **750 Robux** per new Plus subscriber you sign up from your game with `MarketplaceService:PromptRobloxSubscriptionPurchase` (250 Robux per month for their first three paid months). Check `Player.HasRobloxSubscription` first and reward subscribers fairly.
- **Paid private server time**: Plus subscribers get paid private servers free, and you can earn up to **100 Robux per subscriber** per cycle if they spend 60+ minutes in a paid private server they created in your game (one of their top five).
- **Robux transfers**: Plus subscribers can transfer Robux to other users in your game with `PromptRobuxTransferAsync` (10-500 Robux per transfer); your game earns **10%**, DevEx-eligible.

## Ads income

- **Rewarded video ads**: players choose to watch a 6-30 second ad for an in-game reward (which must be a developer product, not Robux and not random). Eligibility: 13+, ID-verified, public game with at least 2,000 unique monthly visitors. See [Ads and rewarded video](ads-and-rewarded-video.md).
- **Immersive ads**: image, video and portal ad units placed in your world; you earn per qualified impression or teleport.

## Other income

- **Private servers** with a monthly Robux price.
- **Paid access** (Robux or local currency).
- **Avatar item commissions** when players buy avatar items inside your game.
- **Creator Store** sales of models and plugins in USD.

## For agents

- [ ] Daily habit features (daily reward, streak, daily quest reaching 10 minutes) exist to earn Daily Engagement rewards.
- [ ] Share links created per channel; game name is distinctive and searchable.
- [ ] Prices displayed at runtime so Plus discounts show correctly.
- [ ] Plus prompt placed at a natural moment with a fair in-game reward for subscribers.
- [ ] No artificial traffic, alt encouragement or teleport tricks anywhere in the design.

Related: [Monetization strategy](monetization-strategy.md) · [Ads and rewarded video](ads-and-rewarded-video.md) · [Retention systems](../10-retention-and-social/retention-systems.md) · [User acquisition](../12-live-ops-and-launch/user-acquisition.md) · [Money, DevEx and teams](../17-policy-and-business/money-devex-and-teams.md)

Sources: [Creator Rewards](https://create.roblox.com/docs/creator-rewards), [Developer Exchange](https://create.roblox.com/docs/production/monetization/developer-exchange), [US 18+ DevEx rate](https://create.roblox.com/docs/production/monetization/18-plus-devex-rate), [Roblox Plus](https://create.roblox.com/docs/production/monetization/roblox-plus), [Subscriptions](https://create.roblox.com/docs/production/monetization/subscriptions)
