---
title: Postmortem template
date: 2026-10-24
tags: [template, live-ops, learning]
aliases: [Update review template, Retro template]
summary: Template for launch, update, event, experiment and incident postmortems with sources, confounders and lesson status.
audience: [human, agent]
---

# Postmortem template

```markdown
---
title: Postmortem: <launch/update/event/experiment/incident name>
date: <YYYY-MM-DD>
type: launch | update | event | experiment | incident
window: <UTC start> to <UTC end>
---

## What changed
<One paragraph.>

## Pre-registered hypothesis
<Written before release: variable, expected direction, expected size, primary metric.>

## Results
| Metric | Before (window, n) | After (window, n) | Change | Source |
|---|---|---|---|---|
| D1 (new organic users) | | | | Retention dashboard |
| Play days per user D2-7 | | | | Home Recommendations |
| Playtime per user | | | | |
| Payer conversion | | | | Monetization dashboard |
| Like ratio | | | | Game page |

## Confounders
- <seasonality, ads, creator videos, other changes, algorithm changes>

## Verdict
confirmed | refuted | inconclusive — <one sentence>

## Why we think it happened
<Evidence-based explanation; label speculation as such.>

## Decisions
- <what we keep, change, revert>

## Lessons
| Lesson | Status (observation / candidate rule / house rule) | Confirming cases | Refuting cases | Vault note updated |
|---|---|---|---|---|

## (Incidents only)
- Timeline:
- Impact:
- Root cause:
- Player communication and compensation:
- Prevention (test or guardrail added):
```

Related: [Postmortems](../12-live-ops-and-launch/postmortems.md) · [Experiments and configs](../12-live-ops-and-launch/experiments-and-configs.md) · [Quality gates](../16-ai-studio-operations/quality-gates.md)
