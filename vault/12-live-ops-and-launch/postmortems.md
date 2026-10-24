---
title: Postmortems
date: 2026-10-24
tags: [live-ops, learning, process, analytics]
aliases: [Learning loop, Retrospectives, Update reviews]
summary: How to turn every launch, update, event and experiment into recorded knowledge that improves the next game, without fooling yourself with small samples.
audience: [human, agent]
---

# Postmortems

A postmortem is a short written review after a launch, update, event or experiment: what we expected, what happened, why, and what we will do differently. Studios that write them get better with every game. Studios that do not repeat the same mistakes.

## When to write one

- After every launch (at day 14 and day 60).
- After every update (7 days after release).
- After every event (when it ends).
- After every experiment (when it concludes).
- After every incident (data loss, exploit, outage) as soon as it is fixed.

## The format (keep it short)

```
Title: <update or event name> postmortem
Date range measured: <UTC start> to <UTC end>
What we changed: <one paragraph>
Hypothesis before release: <what we expected to move, which direction, how much>
Results (with sources):
  - Metric: before -> after (source dashboard, date range, sample size)
  - ...
Confounders: <seasonality, ads running, viral video, other changes>
Verdict: confirmed / refuted / inconclusive
Why we think it happened: <evidence-based explanation>
What we will do next: <decisions>
Lessons (tag each): observation | candidate rule | house rule
```

## Rules for honest learning

1. **Numbers have sources.** Every number cites the dashboard and date range. No bare numbers.
2. **Pre-registered expectations.** Write the hypothesis before release (in the update plan), so you cannot rewrite history.
3. **Name confounders.** Weekends, holidays, school terms, ads, creator videos, competitor launches and Roblox algorithm changes all move numbers. If something else changed at the same time, the result is weaker evidence.
4. **Negative results count equally.** A refuted idea saves the next game from trying it. Record it with the same detail as wins.
5. **Do not promote a lesson to a rule from one case.** A lesson becomes a house rule only after it holds in at least three independent cases (games, updates or experiments). Until then, it is an observation.
6. **Judge verdicts only on measured metrics.** If you did not measure D7, do not claim the update improved D7.
7. **Compare like with like.** Cohorts of the same type of user (organic new users vs organic new users), same length windows.

## Where lessons go

- Update the vault note the lesson belongs to (with date, evidence and a link to the postmortem).
- Keep a **lessons index** per studio: each lesson, its status (observation, candidate rule, house rule), how many confirming and refuting cases, and links.
- When a rule of thumb in this vault is contradicted by your data, record that too, and propose an edit.

## Incident postmortems

For data loss, exploits and outages, add:

- Timeline (detection, response, fix).
- Impact (players affected, items lost or duplicated, revenue impact).
- Root cause (technical and process).
- Player communication and compensation.
- Prevention: the specific test, check or guardrail that would have caught it.

Blameless: focus on how the system allowed the failure, not on who made the mistake.

## For agents

- [ ] Every launch, update, event and experiment has a postmortem using the format above.
- [ ] Hypotheses recorded before release; results cite sources and date ranges.
- [ ] Confounders named; verdict stated as confirmed, refuted or inconclusive.
- [ ] Lessons tagged with status; none promoted to house rules with fewer than three confirming cases.
- [ ] The relevant vault note updated with dated evidence.

Related: [Experiments and configs](experiments-and-configs.md) · [Update cadence](update-cadence.md) · [Postmortem template](../18-templates-and-checklists/postmortem-template.md) · [How to use this vault](../00-start-here/how-to-use-this-vault.md)
