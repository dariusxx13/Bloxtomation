---
title: Update checklist
date: 2026-10-24
tags: [checklist, live-ops, updates]
aliases: [Weekly update checklist]
summary: The checklist for every weekly or major update: planning, building, testing, store page, release and measurement.
audience: [human, agent]
---

# Update checklist

## Plan (Monday)

- [ ] Last update's postmortem written ([Postmortems](../12-live-ops-and-launch/postmortems.md)).
- [ ] Theme chosen from the content backlog ([Update cadence](../12-live-ops-and-launch/update-cadence.md)).
- [ ] Hypothesis written: what metric should move and why.
- [ ] Something visible on join; something for newcomers; something for veterans.
- [ ] Fair monetization hook (if any) reviewed for compliance.

## Build (Tuesday-Thursday)

- [ ] Briefs with acceptance criteria for every task ([Build briefs](../16-ai-studio-operations/build-briefs.md)).
- [ ] New content data-driven (config tables) where possible.
- [ ] New features behind config flags.
- [ ] Data schema changes have migrations and tests.
- [ ] New analytics events defined.

## Test (Thursday-Friday)

- [ ] Build, lint, tests pass.
- [ ] Golden path still passes.
- [ ] New content tested on phone, tablet, desktop.
- [ ] Economy impact checked (sinks added for new sources).
- [ ] Odds displays updated for new random items.

## Store page and community (Friday)

- [ ] Update log written with images; in-game "What's new" updated.
- [ ] New thumbnails (2-3 concepts) prepared for personalization.
- [ ] Title update tag and description "recent update" line (optional).
- [ ] Experience event created; Discord sneak peek posted; codes ready.
- [ ] Creators notified with early access if applicable.

## Release (Saturday or chosen day)

- [ ] Saved version uploaded by pipeline; human publishes.
- [ ] Monitor errors, crashes and purchases for the first hours.
- [ ] Kill switches ready.

## Measure (following 7 days)

- [ ] Before/after metrics recorded with sources and confounders.
- [ ] Feedback themes collected.
- [ ] Lessons logged with status.

Related: [Update cadence](../12-live-ops-and-launch/update-cadence.md) · [Pre-launch checklist](pre-launch-checklist.md) · [Postmortem template](postmortem-template.md)
