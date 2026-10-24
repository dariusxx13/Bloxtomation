---
title: Experiments and configs
date: 2026-10-24
tags: [live-ops, ab-testing, configs, experiments, analytics]
aliases: [A/B testing, ConfigService, Live configs]
summary: How to change game values live with Roblox configs, run real A/B tests with Roblox Experiments, read the results correctly, and avoid fooling yourself.
audience: [human, agent]
---

# Experiments and configs

Two Roblox features changed live operations: **configs** (change values in a running game without publishing) and **experiments** (A/B tests with real statistics). Together they let you tune your game on evidence instead of guesses.

## Configs (platform facts, 2026)

- Key-value settings managed in Creator Hub (or Studio). Types: string, number, boolean, JSON object. Up to **1,000** active configs.
- Your code reads them through `ConfigService` instead of hard-coded constants.
- Changes are **staged** first (testable in Studio play sessions by your team), then published: almost instantly (roughly 15 seconds to a minute) or gradually over 15 minutes. A history page records changes with messages.
- **Targeting**: conditional values per player based on attributes such as country, language, acquisition source, how long ago they first played, payer status and engagement level.
- `ConfigService:GetConfigAsync()` gives global values; `GetConfigForPlayerAsync(player)` gives a player-specific snapshot that applies targeting and experiments.

### What to put in configs

- Economy tuning: rewards, prices of soft-currency items, drop weights (keep the odds display reading from the same source).
- Onboarding parameters: reward amounts, when to reveal UI.
- Event switches and timers: enable events, set start and end times.
- Feature flags: turn new features on or off without publishing (a kill switch for anything risky).
- Offer rules: which contextual offers show, frequency caps.

House rule: every new feature ships behind a config flag, so it can be disabled in seconds if it breaks.

### Safe config use

- Always have a **local default** in code, used if config fetching fails.
- Validate config values (types and ranges) before use; a typo should not break the economy.
- Do not put secrets in configs.
- Write a publish message for every change.

## Experiments (platform facts, 2026)

- Run **in-game experiments** on config values or **matchmaking experiments** on matchmaking configurations.
- Duration **14-60 days**. Up to **two variants plus a control** for in-game experiments (matchmaking: up to three variants, one experiment at a time).
- Choose a goal metric and a rollout percentage; Roblox shows the **minimum detectable effect (MDE)**, the smallest change the test can reliably detect with your traffic.
- Metrics tracked for every experiment: **D1 retention, D7 retention, playtime, ARPU, ARPPU, payer conversion rate**.
- **Early harm checks**: during the first 24 hours, playtime, ARPU and payer conversion update every 5 minutes to catch critical harm (decisions need enough enrolled players).
- Results update daily; a result is significant when its confidence interval does not include 0%.
- **Sample ratio mismatch** warnings appear if enrollment does not match the planned split; restart the experiment if so.
- The config key is **locked** while an experiment runs.
- "Make decision" rolls the winning value into your configs.
- Experiments can be **targeted** to audiences (for example new players only). Narrow targeting reduces sample size, raising the MDE.
- Use `GetConfigForPlayerAsync` to enroll players; the first `GetValue` call for a key enrolls them, and they keep the same variant for the experiment's duration.

## How to run a good experiment

1. **One variable.** Change exactly one thing per experiment. If two things change, you cannot tell which caused the result.
2. **Pre-register the hypothesis.** Write before starting: what you change, what metric should move, in which direction, and roughly by how much. ("Showing the first upgrade beam at 20 seconds instead of 40 increases D1 by about 1 point.")
3. **Check MDE.** If the MDE is larger than the effect you expect, the test cannot detect it. Increase rollout, run longer, or test a bolder change. Small games often cannot detect small effects; test big changes.
4. **Run the planned duration.** Do not stop early because the first days look good (except for early harm).
5. **Watch guardrail metrics.** A revenue win that hurts D7 or playtime may be a loss for discovery.
6. **Record the result**, including failed and inconclusive tests, with dates and numbers. A negative result is valuable knowledge.
7. **Do not generalize from one test.** A lesson becomes a house rule only after it repeats.

## What is worth testing

| Area | Test idea |
|---|---|
| Onboarding | Earlier first reward; fewer UI elements at start; guided first purchase |
| Economy | First zone gate price; daily reward size; offline earnings cap |
| Monetization | Starter pack contents; offer timing; shop layout |
| Social | Friend bonus size; invite prompt timing |
| Matchmaking | Server size; skill-based versus random |

Price tests for Robux products are handled separately by Roblox's managed pricing (see [Pricing and price ladders](../09-monetization/pricing-and-price-ladders.md)).

## For agents

- [ ] Every tunable number and every new feature reads from config with a validated local default.
- [ ] Each experiment has a written hypothesis, one variable, a goal metric, guardrails and an MDE check.
- [ ] Experiments run their planned duration; early harm is the only early stop.
- [ ] Results (including null and negative) are recorded with numbers, dates and sample sizes.

Related: [Measuring onboarding](../01-first-five-minutes/measuring-onboarding.md) · [Postmortems](postmortems.md) · [Analytics instrumentation](../13-building-it-right/analytics-instrumentation.md) · [Project architecture](../13-building-it-right/project-architecture.md)

Sources: [Configs](https://create.roblox.com/docs/production/configs), [Experiments](https://create.roblox.com/docs/production/experiments)
