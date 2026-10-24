---
title: Quality gates
date: 2026-10-24
tags: [ai, agents, process, quality, review]
aliases: [Stage gates, Gate criteria, Review rubric]
summary: The written criteria each stage must meet before work moves on, with stable ids so rejections cite exactly what failed and the learning loop can count them.
audience: [human, agent]
---

# Quality gates

A gate is a checklist that work must pass before moving to the next stage. Gates make quality consistent, make reviews objective, and turn every rejection into data ("BUILD-04 failed three times this month" points to a systemic problem). The Gatekeeper agent applies them; any human reviewer can too.

## How gates work

- Each criterion has a stable id (`STAGE-NN`). Ids never change meaning; retired criteria are marked retired, not reused.
- A submission includes evidence for every criterion: links, numbers with sources, build logs, screenshots or playtest notes.
- The Gatekeeper marks each criterion **pass**, **fail** or **waived**. Waivers require a written reason and human approval, and are listed in the release candidate review.
- A rejection must cite failed criterion ids and say what evidence would pass. "Not good enough" is not a valid rejection.
- Mechanical checks (build, lint, tests) are run, not trusted from reports.

## PITCH (stage 1)

| Id | Criterion |
|---|---|
| PITCH-01 | Every market claim cites a chart snapshot or source with date and numbers; trend data is no older than 7 days. |
| PITCH-02 | The one-sentence loop ("You ___ to get ___ so you can ___") is concrete and playable in Roblox terms. |
| PITCH-03 | First 60 seconds, goal at 10-15 minutes, and why-tomorrow are written as player actions. |
| PITCH-04 | The twist changes how the game plays compared with named comparables. |
| PITCH-05 | Urgency read (early or late) with comparable counts and trend phase. |
| PITCH-06 | Checked against our portfolio: not a duplicate of something we ship. |
| PITCH-07 | Audience tier, content rating expectation and IP risks are stated. |
| PITCH-08 | Rubric score with justifications ([Pitch and greenlight](../15-market-research/pitch-and-greenlight.md)). |

## DESIGN (stage 2)

| Id | Criterion |
|---|---|
| DESIGN-01 | Moment, session and long loops written; seven loop tests planned ([Core loop design](../02-core-loop/core-loop-design.md)). |
| DESIGN-02 | First-session timeline with targets per phase ([First session blueprint](../01-first-five-minutes/first-session-blueprint.md)). |
| DESIGN-03 | Economy sheet for three player types; time-to-goal for the first five goals; first goal at 10-15 minutes for a casual free player. |
| DESIGN-04 | Drop tables with designed time-to-see per tier, luck stacking rule and caps (if randomness exists). |
| DESIGN-05 | Return systems specified: daily reward, streak or equivalent, daily quests, at least one next-day timer; or an argued omission. |
| DESIGN-06 | Social reason specified (co-play bonus, co-op, competition) or an argued omission. |
| DESIGN-07 | Product catalog draft mapped to motivations and price tiers, passing the fairness table. |
| DESIGN-08 | Art direction one-pager with palette, shapes, references; icon concept. |
| DESIGN-09 | Build brief can be executed without further design decisions; open questions listed. |
| DESIGN-10 | Reused systems and assets from our library identified by id. |

## PROTOTYPE (stage 3)

| Id | Criterion |
|---|---|
| PROTO-01 | Core action playable with juice layers 1-4 ([Game feel and juice](../02-core-loop/game-feel-and-juice.md)). |
| PROTO-02 | Seven loop tests reported with evidence. |
| PROTO-03 | Newcomer playtest: core action performed within 30 seconds without reading. |
| PROTO-04 | Fun verdict and recommendation: continue, pivot or stop, with reasons. |

## BUILD (stage 4)

| Id | Criterion |
|---|---|
| BUILD-01 | The place builds from source (`rojo build` exits successfully). |
| BUILD-02 | Format, lint and type checks clean (StyLua, Selene, luau-lsp analyze). |
| BUILD-03 | Unit tests pass for economy math, drop tables, validators, migrations and receipts. |
| BUILD-04 | All remotes go through the Net module with validators and rate limits; no raw remotes elsewhere. |
| BUILD-05 | No currency, rewards, damage or prices decided on the client. |
| BUILD-06 | Data: session locking, `UpdateAsync`, autosave, leave and shutdown saves, failed-load kick, schema version. |
| BUILD-07 | `ProcessReceipt` idempotent with receipt history; saves before acknowledging. |
| BUILD-08 | Analytics: onboarding funnel, economy events and minimum event plan implemented. |
| BUILD-09 | All tunables and new features behind config with validated defaults. |
| BUILD-10 | Game identity set (name, config ids, theme) instead of template defaults. |
| BUILD-11 | Paid random items: odds displays, boosts reflected, `PolicyService` gates. |
| BUILD-12 | Every non-owned asset scanned and recorded in the asset index with source and license. |
| BUILD-13 | The build report matches reality: three sampled brief requirements verified in a playtest. |

## POLISH (stage 5)

| Id | Criterion |
|---|---|
| POLISH-01 | Golden-path test passes in Studio, with screenshots. |
| POLISH-02 | Device checks at phone, tablet and desktop; no overlap with platform controls. |
| POLISH-03 | Low-end performance: no stutter at spawn; memory stable over 30 minutes. |
| POLISH-04 | Juice pass done; rarest outcomes clearly more exciting than common ones. |
| POLISH-05 | Economy balance pass: measured playtest times match the economy sheet within agreed tolerance, or the sheet is updated. |
| POLISH-06 | Icon 512×512 and at least three distinct thumbnails at 1920×1080, reviewed at phone size, honest to gameplay. |
| POLISH-07 | Title, description and genre written per [Titles and descriptions](../11-store-page-and-discovery/titles-and-descriptions.md). |

## RELEASE CANDIDATE (stage 6)

| Id | Criterion |
|---|---|
| RC-01 | Nothing has been published by automation; the candidate is a Saved version. |
| RC-02 | Security review complete ([Security and anti-exploit](../13-building-it-right/security-and-anti-exploit.md) checklist). |
| RC-03 | Compliance review complete ([Monetization compliance](../09-monetization/monetization-compliance.md) checklist); questionnaire answers drafted for the human. |
| RC-04 | All prior approvals refer to the exact build being shipped (version or hash). |
| RC-05 | No open waivers, or each listed for explicit human acceptance. |
| RC-06 | Launch plan and rollback plan written ([Launch playbook](../12-live-ops-and-launch/launch-playbook.md)). |

## LIVE and REVIEW (stages 7-8)

| Id | Criterion |
|---|---|
| LIVE-01 | Each change in an experiment or update names one primary variable and a pre-registered hypothesis with expected direction. |
| LIVE-02 | Measurement window stated in UTC; confounders (ads, events, holidays) declared. |
| LIVE-03 | Fix attempts on a failing metric capped (for example two) before escalating to redesign. |
| REVIEW-01 | Every outcome number cites source and date range. |
| REVIEW-02 | Verdicts only on measured metrics; refuted and inconclusive results recorded fully. |
| REVIEW-03 | No lesson promoted to a house rule with fewer than three confirming cases. |

## For agents

- [ ] Submissions include evidence per criterion id.
- [ ] Rejections cite ids and the evidence that would pass.
- [ ] Waivers only with written reasons and human approval.
- [ ] Mechanical checks re-run by the Gatekeeper, not taken from reports.

Related: [Agent team workflow](agent-team-workflow.md) · [Build briefs](build-briefs.md) · [Postmortems](../12-live-ops-and-launch/postmortems.md) · [Pre-launch checklist](../18-templates-and-checklists/pre-launch-checklist.md)
