---
title: Measuring onboarding
date: 2026-10-24
tags: [onboarding, analytics, funnels]
aliases: [Onboarding funnel, FTUE analytics]
summary: How to instrument the first session with Roblox funnel events, name the steps, read the funnel, and decide what to fix.
audience: [human, agent]
---

# Measuring onboarding

You cannot fix what you cannot see. Roblox gives you a free onboarding funnel in Creator Analytics, but only if you log the steps yourself. Do this before launch, not after.

## The tool: onboarding funnel events

Platform facts (Creator Analytics docs, 2026):

- `AnalyticsService:LogOnboardingFunnelStepEvent(player, stepNumber, stepName)` logs a one-time funnel step per player. It powers the onboarding view on the Funnel page.
- `AnalyticsService:LogFunnelStepEvent(player, funnelName, funnelSessionId, stepNumber, stepName)` logs recurring funnels, such as a shop checkout, where the same player can go through many times. Generate a new `funnelSessionId` (for example with `HttpService:GenerateGUID()`) each time a new pass through the funnel starts.
- Events can be sent **only from the server and only in published games**. Calls from the client or from Studio playtests do not appear.
- You can show up to 10 funnels as tabs on the dashboard.
- A player's saved step expires after 180 days without events; they then count as new for that funnel.
- Funnel events can carry **custom fields** for breakdowns (for example, which starter pet the player picked).

## Designing the steps

Good steps are **actions or achievements**, logged right after they happen, with names a person can read on a chart.

A template for most games (adapt names to your game):

| # | Step name | Logged when |
|---|---|---|
| 1 | Joined | `PlayerAdded`, after data loads |
| 2 | First Move | Character moved a few studs (proves the game loaded and controls work) |
| 3 | First Action | Core action performed once |
| 4 | First Reward | First currency or item granted |
| 5 | Opened Shop | First time the upgrade UI opens |
| 6 | First Upgrade | First upgrade bought |
| 7 | Loop x3 | Core loop completed three times |
| 8 | First Goal Visible | Player has seen the first named goal |
| 9 | Second Area | Reached the second zone or tier |
| 10 | First Goal Done | First named goal reached |
| 11 | Session 10 min | Played 10 minutes in the first session |

Rules:

- **Keep steps sequential and meaningful.** If a step can happen out of order, the funnel becomes misleading; log only the next expected step, or use a separate funnel.
- **8 to 15 steps.** Fewer hides the problem; more makes the chart unreadable.
- **Never change step numbers after launch** without starting a new funnel version; comparisons across versions break.
- **Validate on the server.** If the client tells the server "step done", check the actual game state first and reject impossible steps (for example, a step number higher than the next expected). Never log what the client claims without checking.

## Reading the funnel

1. **Find the biggest absolute drop.** That is your first problem, even if a later drop looks scarier in percentage.
2. **Split by platform.** A drop only on phones points to controls, UI layout or performance. Split by new versus returning, by source (Home recommendation, search, ads, friends), and by age group where available.
3. **Check timing.** Combine with custom events that record time-to-step (log the seconds since join as a value). A step that most players reach, but slowly, is a pacing problem.
4. **Compare cohorts, not days.** After a change, compare new-user cohorts from 7 days before and 7 days after. Watch out for traffic mix changes (an ad campaign or a viral video changes who arrives).

## Supporting metrics

- **First-play bounce rate** (Home Recommendations dashboard): the share of organic Recommended-for-You players who leave after a very short first session. This is one of Roblox's most important ranking signals.
- **D1 retention** by first-play cohort (Retention dashboard).
- **Session length distribution** (Engagement dashboard): look for a big spike of sessions under one minute.
- **Error report and crash rate** for the onboarding area.
- **Custom events** on hesitation: for example, log "IdleOver15s" with the current step as a custom field to find where players get stuck.

## A worked example

A simulator's funnel shows:

| Step | Players | Step conversion |
|---|---|---|
| Joined | 10,000 | 100% |
| First Move | 9,400 | 94% |
| First Action | 8,900 | 95% |
| First Reward | 8,850 | 99% |
| Opened Shop | 5,100 | 58% |
| First Upgrade | 4,600 | 90% |

The big drop is between First Reward and Opened Shop (42% lost). Players earn but never find the shop. Likely killers: the reward feels small, or the shop button is not revealed and pointed at. Fix: when the player first has enough coins, pulse the shop button, show a beam to the upgrade pad, and guide the first purchase. Ship the fix behind a config flag and A/B test it with Experiments so the improvement is measured, not assumed. See [Experiments and configs](../12-live-ops-and-launch/experiments-and-configs.md).

## Instrumenting other funnels

Use recurring funnels for:

- **Shop checkout**: Opened Shop > Viewed Item > Pressed Buy > Prompt Shown > Purchased. Reveals where buyers drop.
- **Rebirth or prestige**: Eligible > Viewed Rebirth > Confirmed Rebirth.
- **Social**: Opened Invite > Sent Invite > Friend Joined.
- **Event participation**: Saw Event > Started Event > Finished Event.

See [Analytics instrumentation](../13-building-it-right/analytics-instrumentation.md) for naming conventions and the economy and custom events that complete the picture.

## For agents

- [ ] Onboarding funnel has 8-15 sequential steps, logged on the server after the step is truly complete.
- [ ] Step names are human-readable and match the game's terms.
- [ ] Step numbers are constants in one module and never renumbered after launch.
- [ ] Client-reported steps are validated against server state.
- [ ] A shop checkout funnel exists before the first monetized update.
- [ ] Every fix to onboarding names the funnel step it should move and the expected size of the change.

Related: [First session blueprint](first-session-blueprint.md) · [First-session killers](first-session-killers.md) · [Analytics instrumentation](../13-building-it-right/analytics-instrumentation.md) · [Experiments and configs](../12-live-ops-and-launch/experiments-and-configs.md)
