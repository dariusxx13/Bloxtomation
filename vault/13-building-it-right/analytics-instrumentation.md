---
title: Analytics instrumentation
date: 2026-10-24
tags: [engineering, analytics, funnels, economy, custom-events]
aliases: [Tracking events, Analytics setup, AnalyticsService]
summary: What to log with Roblox AnalyticsService (funnels, economy events, custom events, custom fields), naming conventions, limits, and a minimum event plan for any game.
audience: [human, agent]
---

# Analytics instrumentation

Creator Analytics gives you many metrics automatically (DAU, retention, playtime, revenue, acquisition, performance). The rest you must log yourself through `AnalyticsService`: onboarding funnels, the economy, and anything specific to your game. Instrument before launch; data you did not collect cannot be recovered.

## The event types (platform facts, 2026)

| Type | Method | Unlocks | Use for |
|---|---|---|---|
| Onboarding funnel | `LogOnboardingFunnelStepEvent(player, step, name)` | Funnel page (onboarding) | One-time first-session steps |
| Recurring funnel | `LogFunnelStepEvent(player, funnelName, funnelSessionId, step, name)` | Funnel page tabs (up to 10 funnels) | Shop checkout, rebirth flow, event flow |
| Economy | `LogEconomyEvent(player, flowType, currency, amount, balanceAfter, transactionType, itemSku)` | Economy page (up to 5 currencies) | Every currency source and sink |
| Custom | `LogCustomEvent(player, eventName, value?, customFields?)` | Explore page (up to 100 event names) | Anything else: feature use, combat stats, choices |
| Custom fields | Extra key-value breakdowns on events (up to 3) | Breakdowns on all event pages | Segmenting by map, class, item, variant |

Constraints:

- Events can be sent **only from the server** and only in **published games** (not Studio).
- Custom events aggregate daily; charts can take up to 24 hours.
- Event names have tight cardinality limits; put variation in custom fields, not in names (one `PlantSeed` event with a field for the plant type, not `PlantCabbage`, `PlantTurnip`...).
- There are rate limits on analytics events; batch values where possible (log "killed 10 zombies" instead of ten separate events).

## Naming conventions (house rules)

- Event names: `PascalCase` verbs or nouns, stable forever (`HatchEgg`, `QuestCompleted`, `BossDefeated`).
- Funnel step names: human-readable, numbered, never renumbered after launch.
- Currency names exactly as shown to players (`Coins`, `Gems`).
- Transaction types: the defaults (`IAP`, `TimedReward`, `Onboarding`, `Shop`, `Gameplay`, `ContextualPurchase`) unless a custom type is clearly needed.
- Item SKUs: stable ids matching config ids (`egg_volcano`, `pass_x2coins`).
- Keep all names in one shared module of constants so they cannot drift.

## The minimum event plan

Every game should log at least:

1. **Onboarding funnel**: 8-15 steps (see [Measuring onboarding](../01-first-five-minutes/measuring-onboarding.md)).
2. **Economy**: every source and sink of every currency, with transaction type and SKU.
3. **Shop funnel**: opened shop, viewed item, pressed buy, purchase completed.
4. **Core loop custom events**: the core action with a value (count per batch), with fields for zone or tool.
5. **Progression milestones**: zone unlocked, rebirth, collection set completed (with fields).
6. **Random rewards**: each roll's tier as a custom field (to verify drop rates in production).
7. **Social**: invite sent, friend joined, trade completed.
8. **Offers**: offer shown, clicked, purchased (per offer id).
9. **Errors that matter**: purchase handling failures, data load failures (also log to the console for the error report).

## Wrapping AnalyticsService

Create one server module (`Analytics`) that:

- Exposes typed functions (`Analytics.funnelStep(player, Steps.FirstUpgrade)`, `Analytics.source(player, "Coins", 50, "Gameplay", "quest_daily_1")`).
- Checks that the step order is valid and drops duplicates.
- Batches high-frequency events.
- Does nothing in Studio (or prints to the output in a debug mode), since events are ignored there anyway.

This keeps gameplay code clean and makes naming consistent.

## Beyond Roblox analytics

- Creator Analytics also provides dashboards for retention, engagement, monetization, acquisition, performance, error reports, alerts and custom dashboards. Set alerts for crash and error spikes after updates.
- If you need deeper analysis, some studios send aggregated, privacy-safe events to their own backend with `HttpService`. Never send personal data, follow Roblox's terms and privacy rules, and keep it optional.

## For agents

- [ ] Minimum event plan implemented before launch.
- [ ] All event names, steps, currencies and SKUs defined as constants in one module.
- [ ] Variation recorded in custom fields, not in event names.
- [ ] Analytics calls only from the server, through the wrapper module.
- [ ] Every new feature ships with its events defined in the feature brief.

Related: [Measuring onboarding](../01-first-five-minutes/measuring-onboarding.md) · [Economy design](../04-progression-and-economy/economy-design.md) · [Experiments and configs](../12-live-ops-and-launch/experiments-and-configs.md) · [Postmortems](../12-live-ops-and-launch/postmortems.md)

Sources: [Funnel events](https://create.roblox.com/docs/production/analytics/funnel-events), [Economy events](https://create.roblox.com/docs/production/analytics/economy-events), [Custom events](https://create.roblox.com/docs/production/analytics/custom-events)
