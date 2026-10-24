---
title: Update cadence
date: 2026-10-24
tags: [live-ops, updates, content, retention]
aliases: [Updates, Content cadence, Weekly updates]
summary: How often to update a Roblox game, what each update should contain, how to theme and announce updates, and how to run a sustainable weekly pipeline.
audience: [human, agent]
---

# Update cadence

Top Roblox games update constantly. Updates bring lapsed players back, give creators something to post, give the recommendation system a reason to explore your game again, and keep veterans busy. Roblox's own guidance: a weekly cadence is ideal; monthly is the minimum.

## The rhythm

| Cadence | Content | Example |
|---|---|---|
| Weekly | Something visible and themed | A new egg, a new boss, a new map, a limited shop rotation, balance fixes, quality-of-life |
| Every 2-4 weeks | Expansion of existing systems | New zone in the existing chain, new pet set, new quest line |
| Every 1-3 months | A new system or big feature | Trading, clans, a new mode, rebirth layer, season pass |
| Seasonal | Events tied to holidays or seasons | Halloween, winter, summer, anniversary |

Roblox's retention guidance gives a similar pattern: smaller updates on existing mechanics every 2-4 weeks and bigger feature updates every 2-3 months, with weekly as the ideal pace for engagement.

## What makes a good update

1. **One clear theme.** "Volcano update", "Ocean event". A theme makes the update easy to understand and market, and helps players see what is new. Everything in the update connects to it.
2. **Visible on join.** Returning players should see the new thing within seconds: a new portal, a giant new egg, an event banner, a "What's new" panel.
3. **Something for everyone.** A goal for newcomers, a goal for veterans.
4. **Earned access.** Roblox notes that players flock to updates; if the new content is consumed in five minutes, they leave. Let players earn access (new zone after a requirement, event track over days).
5. **A monetization hook (fair).** An event egg, a themed bundle, a pass that fits the update.
6. **A clip moment.** A new rare, a new boss, a dramatic reveal.
7. **Fresh store page.** New thumbnails (test them with personalization), icon variant for big updates, update tag in the title, codes.

## Update day

- **Pick a consistent day and time.** Many games update on Saturdays (the platform's peak day) at a fixed hour. Players learn to show up.
- **Announce in advance**: Discord sneak peeks during the week, an experience event on your page with "Notify me", a countdown in the game.
- **Global or timed release**: content can unlock at a set time using server time checks (so all servers switch together) or by publishing at the time. Servers running old versions keep running until shut down; use Roblox's server update options (migrate or restart servers) when the update requires it.
- **Be online after release** to fix problems.

## The weekly pipeline

A sustainable weekly cycle for a small team or agent team:

| Day | Work |
|---|---|
| Mon | Review last update's data (retention, funnel, economy, revenue, feedback). Choose this week's theme and scope. |
| Tue-Wed | Build content and systems; art and VFX; balance numbers. |
| Thu | Integrate; playtest; fix. Prepare thumbnails, update log, codes. |
| Fri | Final QA on all devices; upload saved version; staged config changes; sneak peek. |
| Sat | Human publishes; monitor; hotfix. |
| Sun | Watch metrics; community feedback; plan next week. |

Keep a **content backlog** of 4-8 weeks of themed updates so you are never inventing content on Monday.

## Content that scales

- Systems that take new content cheaply: new eggs and pets (models plus a table entry), new zones built from kits, new enemies as variants, new quests from data.
- Data-driven content: items, eggs, zones and quests defined in config tables, so adding content is editing data, not writing code.
- Live configs: tune values without republishing (see [Experiments and configs](experiments-and-configs.md)).

## Measuring updates

For every update, record before and after (7 days each):

- DAU and concurrent players.
- Home Recommendation impressions and signals.
- D1 and D7 for new cohorts; return rate of lapsed players.
- Revenue, payer conversion, ARPPU.
- Like ratio and feedback themes.

Write the result into a short update postmortem (see [Postmortems](postmortems.md)). Over time this becomes your most valuable knowledge: which kinds of updates work for your game.

## For agents

- [ ] Content backlog of at least 4 weeks of themed updates.
- [ ] Each update: one theme, visible on join, something for new and veteran players, earned access, a fair monetization hook, a clip moment.
- [ ] Update log, thumbnails, codes and announcement prepared before release day.
- [ ] Before/after metrics recorded for every update.

Related: [Events and seasons](events-and-seasons.md) · [Launch playbook](launch-playbook.md) · [Postmortems](postmortems.md) · [Endgame and long-term goals](../10-retention-and-social/endgame-and-long-term-goals.md) · [Update checklist](../18-templates-and-checklists/update-checklist.md)
