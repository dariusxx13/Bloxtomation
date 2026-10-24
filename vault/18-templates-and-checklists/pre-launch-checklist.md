---
title: Pre-launch checklist
date: 2026-10-24
tags: [checklist, launch, qa]
aliases: [Launch checklist, Release checklist]
summary: Everything to verify before releasing a Roblox game publicly, grouped by area, with links to the notes that explain each item.
audience: [human, agent]
---

# Pre-launch checklist

Use this before the first public release and before the full-audience launch update. Each line links to its explanation. Mark each item with evidence (link, screenshot, number).

## Game

- [ ] Core action fun within 10 seconds; first session follows the blueprint ([First session blueprint](../01-first-five-minutes/first-session-blueprint.md)).
- [ ] Newcomer playtest done with at least five fresh players; top confusion points fixed ([Playtest report template](playtest-report-template.md)).
- [ ] First named goal reachable in 10-15 minutes for a casual free player ([Economy math](../04-progression-and-economy/economy-math.md)).
- [ ] Return hook visible before minute 10 ([Retention systems](../10-retention-and-social/retention-systems.md)).
- [ ] At least one social reason and one clip moment ([Social systems](../10-retention-and-social/social-systems.md)).

## Tech

- [ ] Build, lint, type checks and unit tests pass ([Tooling and CI](../13-building-it-right/tooling-and-ci.md)).
- [ ] Session-locked data, autosave, leave and shutdown saves, failed-load kick ([Data persistence](../13-building-it-right/data-persistence.md)).
- [ ] Idempotent `ProcessReceipt`; real purchase tested on a test account.
- [ ] Every remote validated and rate-limited; security checklist passed ([Security and anti-exploit](../13-building-it-right/security-and-anti-exploit.md)).
- [ ] Golden-path test and multi-client test pass ([Testing and QA](../13-building-it-right/testing-and-qa.md)).
- [ ] Low-end phone: no stutter at spawn; stable memory over 30 minutes ([Device performance](../08-mobile-and-cross-platform/device-performance.md)).
- [ ] Analytics minimum event plan implemented ([Analytics instrumentation](../13-building-it-right/analytics-instrumentation.md)).
- [ ] Features behind configs with kill switches ([Experiments and configs](../12-live-ops-and-launch/experiments-and-configs.md)).
- [ ] QA and admin tools unreachable by regular players.

## UI and devices

- [ ] Device Simulator screenshots at small phone, large phone, tablet and desktop; no overlap with platform controls ([HUD layout](../05-ui-and-hud/hud-layout.md)).
- [ ] Gamepad navigation works if consoles are enabled ([Console and VR](../08-mobile-and-cross-platform/console-and-vr.md)).
- [ ] Key strings localized for top languages ([Localization and global players](../08-mobile-and-cross-platform/localization-and-global-players.md)).

## Monetization and compliance

- [ ] Prices fetched at runtime; managed pricing enabled ([Pricing and price ladders](../09-monetization/pricing-and-price-ladders.md)).
- [ ] Odds displayed for any paid randomness; `PolicyService` gates ([Monetization compliance](../09-monetization/monetization-compliance.md)).
- [ ] No fake discounts, timers, scarcity or pressure language.
- [ ] Cheap first purchase exists; catalog reviewed for fairness ([Product catalog](../09-monetization/product-catalog.md)).

## Store page

- [ ] Icon 512×512, readable at 150 px ([Icons](../11-store-page-and-discovery/icons.md)).
- [ ] 3-5 thumbnails at 1920×1080, honest to gameplay; personalization ready ([Thumbnails](../11-store-page-and-discovery/thumbnails.md)).
- [ ] Title, description (hook in 160 characters), genre and subgenre set ([Titles and descriptions](../11-store-page-and-discovery/titles-and-descriptions.md)).
- [ ] Social links and group configured; experience event created for launch.

## Policy and business

- [ ] Maturity & Compliance Questionnaire answered fully and accurately ([Age ratings and audience](../17-policy-and-business/age-ratings-and-audience.md)).
- [ ] Owner verified, 2-step verification on all collaborators, Plus/Premium or publishing fee ready for under-16 reach.
- [ ] All assets original or licensed; asset index complete ([IP and licensing](../17-policy-and-business/ip-and-licensing.md)).
- [ ] Right-to-erasure deletion automated or documented ([Privacy and data](../17-policy-and-business/privacy-and-data.md)).
- [ ] Group owns the game and its assets ([Money, DevEx and teams](../17-policy-and-business/money-devex-and-teams.md)).

## Launch operations

- [ ] Launch plan: 16+ trial, plan to reach 250 highly engaged plays, full-audience launch update timing ([Launch playbook](../12-live-ops-and-launch/launch-playbook.md)).
- [ ] Rollback plan and on-call time after release.
- [ ] Discord, codes, update log and creator outreach ready ([Community building](../10-retention-and-social/community-building.md)).
- [ ] First four weekly updates planned ([Update cadence](../12-live-ops-and-launch/update-cadence.md)).
- [ ] A human performs the publish.

Related: [Launch playbook](../12-live-ops-and-launch/launch-playbook.md) · [Quality gates](../16-ai-studio-operations/quality-gates.md) · [Update checklist](update-checklist.md)
