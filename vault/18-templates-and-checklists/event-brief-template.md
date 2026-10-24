---
title: Event brief template
date: 2026-10-24
tags: [template, live-ops, events, brief]
aliases: [Live event brief, Admin event brief, Seasonal event brief]
summary: A copy-paste brief for any live event - admin session, update party, seasonal event or crossover - with goal, schedule in UTC, rewards and caps, fairness rules, content tie-in, technical plan with kill switch, test plan, communications, success metrics and the decisions reserved for the human.
audience: [human, agent]
---

# Event brief template

Copy this into `games/<id>/tasks/` as the brief for an event task. It follows the [Build briefs](../16-ai-studio-operations/build-briefs.md) rules (acceptance criteria required) and the design guidance in [Live events and admin events](../21-hits-and-trends/live-events-and-admin-events.md).

```markdown
# Event: <name>

## Outcome served
<click | stay | return | spend | safety> - one sentence on why this event exists.

## Type
<admin session | update party | seasonal event | crossover | platform event participation>

## Schedule (UTC)
- Announce in game and on the Roblox event listing: <date time>
- Start: <date time>   End: <date time>
- Repeats: <none | weekly on Saturday at ...>

## Content tie-in
What new content ships with or right after the event (an event without content is a spike with no floor).

## Rewards
| Reward | Who gets it | Cap | Source of truth |
|--------|-------------|-----|-----------------|
| <item/currency> | everyone online during the window | <cap> | server grant via Grants |

## Fairness rules
- Every server runs the same event at the same time.
- Rewards for attendance and play, never for purchases.
- No special treatment for friends or creators in public servers.

## Technical plan
- Schedule stored in live config: <keys>
- Activation: servers compare UTC time with the schedule every <n> s
- Optional live triggers via MessagingService (best effort only)
- Kill switch flag: <key>
- Effects budget on phones: <particles, meshes>

## Test plan
- Mid-event server start picks up the event
- Full server on a low-end phone with event effects
- Reward caps and duplicate-claim protection
- Kill switch turns everything off without a publish

## Communications
- In-game countdown, Roblox event listing (Notify Me), patch notes, code
- Social channels linked from the game page only (no links in game)

## Success metrics
- Peak concurrent players versus the previous comparable event
- D1 and D7 return of event attendees
- Economy: currency granted versus cap; inflation check

## Acceptance criteria
- [ ] Event starts and ends on schedule in all servers (log evidence)
- [ ] Rewards granted once per eligible player within caps (analytics evidence)
- [ ] Kill switch tested
- [ ] Phone performance within budget (MicroProfiler capture)

## Human decisions (escalate, do not decide)
- Any paid partner, creator payment or brand involvement (--kind money)
- Any policy question about rewards or content (--kind policy)
```

## For agents

- [ ] Every event task uses this template; briefs without acceptance criteria stay in draft.
- [ ] Post-event, the Analyst adds the success metrics to the handoff and proposes vault updates if something new was learned ([Vault maintenance](../16-ai-studio-operations/vault-maintenance.md)).

Related: [Live events and admin events](../21-hits-and-trends/live-events-and-admin-events.md) · [Events and seasons](../12-live-ops-and-launch/events-and-seasons.md) · [Seasonal calendar](../12-live-ops-and-launch/seasonal-calendar.md) · [Update checklist](update-checklist.md) · [Build briefs](../16-ai-studio-operations/build-briefs.md)
