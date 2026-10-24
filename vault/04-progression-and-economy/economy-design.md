---
title: Economy design
date: 2026-10-24
tags: [economy, currencies, sources, sinks, balance]
aliases: [Virtual economy, Currencies, Sources and sinks]
summary: How to design currencies, sources and sinks so the economy stays meaningful for months, and how to read Roblox's economy analytics.
audience: [human, agent]
---

# Economy design

An in-game economy is the flow of resources into players' hands (sources) and out of them (sinks). When sources outgrow sinks, currency piles up, prices stop mattering, rewards feel worthless and progression collapses. When sinks outgrow sources, the game feels stingy and players leave or feel pushed to pay.

## Currencies

### How many?

| Currency | Role | Earned by | Spent on |
|---|---|---|---|
| Soft (coins, cash) | Main progression | Core loop | Upgrades, zones, eggs |
| Hard or premium (gems, diamonds) | Scarcer, higher value | Slow free sources + Robux products | Premium eggs, boosts, cosmetics, skips |
| Event (candy, tokens) | Limited-time content | Event activities | Event shop, event eggs |
| Specialist (essence, shards, XP) | One system | Recycling, specific activities | That system only |

**House rule:** launch with **one soft currency and at most one premium currency**. Add event currencies with events. Each extra currency must have a clear, single job. Players under 13 struggle with more than two currencies on screen.

Roblox's economy analytics dashboard tracks up to five currencies, which is a sensible upper limit for a mature game.

### Robux and premium currency

Players buy premium currency (or soft currency packs) with Robux through developer products. Design rules:

- Premium currency should also be **earnable for free** in small amounts (daily rewards, quests, achievements). Free players who earn a little learn its value and are more likely to buy.
- Do not price everything in premium currency. Keep the core progression in soft currency.
- Premium currency obtained with Robux that buys random rewards makes those rewards "paid random items" with disclosure duties. See [Monetization compliance](../09-monetization/monetization-compliance.md).

## Sources

Typical sources (Roblox's analytics groups them into transaction types such as Gameplay, TimedReward, Onboarding, Shop and IAP):

- Core loop actions (the main source; should be most of all income for active players)
- Quests and achievements
- Daily, streak and playtime rewards
- Offline and idle production
- Events
- Codes
- Purchases (Robux)
- Trading and selling items

## Sinks

Sinks give currency its meaning. Good sinks feel like opportunities, not taxes.

| Sink type | Example | Notes |
|---|---|---|
| Upgrades | Tool levels, stats | The main sink in the first hours |
| Access | Zone gates | One-time, large |
| Random rewards | Eggs, rolls | Endless sink, the backbone of collection games |
| Consumables | Potions, boosts | Repeatable, time-limited |
| Cosmetics | Skins, base decor | Endless and status-driven |
| Fees | Trading tax, marketplace fee | Fight inflation in trading economies |
| Resets | Rebirth costs | Consume everything for a permanent bonus |
| Crafting | Combine items | Converts items to rarer items |

## Balance rules of thumb

- **Net flow near zero for engaged players.** Roblox's own guidance on its economy dashboard: total sources minus total sinks should hover near zero. If the net grows, add sinks.
- **Watch average wallet balance**, especially for payers. A rising balance means players have nothing worth buying. Add sinks (new content, cosmetics, eggs) rather than cutting income.
- **Income should never feel cut.** Lowering rewards after launch causes outrage. Fix inflation with new sinks, resets and new tiers, not by nerfing sources.
- **Keep spending meaningful.** If the cheapest useful thing costs less than 1% of a typical player's balance, prices have lost meaning: introduce a new tier of items or a new currency for the new layer.
- **Prices go up with progress, by design.** Exponential costs are normal (see [Economy math](economy-math.md)).

## Reading the economy analytics

Platform facts: log every source and sink with `AnalyticsService:LogEconomyEvent(player, flowType, currency, amount, balanceAfter, transactionType, itemSku)` from the server, in published games. The Economy dashboard then shows:

- **Sources and sinks by category**: where currency comes from and goes.
- **Average wallet balance** for all users, payers and non-payers.
- **Top sources and sinks** by item SKU and transaction type.

What to look for:

| Pattern | Meaning | Action |
|---|---|---|
| IAP is a tiny share of premium currency sources | Product too expensive or not visible | Better offers, contextual prompts |
| Payers' balance rises week over week | Payers have nothing to spend on | Add premium sinks: cosmetics, eggs |
| One source dominates (for example codes) | Exploit or overgenerous system | Check for abuse; rebalance the source |
| Sinks concentrated on one item | Other items are bad value | Rebalance prices or effects |
| Sources and sinks both fall | Engagement falling | Content problem, not economy |

## Economy exploits to prevent

- **Duplication**: trading or inventory bugs that create items. Use atomic server-side transactions and session locking. See [Data persistence](../13-building-it-right/data-persistence.md).
- **Client-trusted rewards**: remotes like `GiveCoins(amount)`. Never.
- **Rate exploits**: auto-clickers at 60 clicks per second. Rate-limit actions server-side to what a human can do, or design the loop so speed is capped by mechanics (cooldowns).
- **Code abuse**: alt accounts redeeming codes. Codes give small amounts, one per account.
- **Trading scams and real-money trading**: see [Trading economies](trading-economies.md).

## For agents

- [ ] Currency list with one job per currency; at most one soft and one premium at launch.
- [ ] Source and sink table for each currency, with expected share of flow.
- [ ] Every source and sink logs an economy event with transaction type and SKU.
- [ ] A rebalance plan for inflation that adds sinks rather than cutting sources.
- [ ] No client remote can set or add currency directly.

Related: [Economy math](economy-math.md) · [Progression architecture](progression-architecture.md) · [Trading economies](trading-economies.md) · [Analytics instrumentation](../13-building-it-right/analytics-instrumentation.md) · [Product catalog](../09-monetization/product-catalog.md)
