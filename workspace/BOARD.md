# Studio board

Updated 2026-10-26T05:51:10Z by studioctl. Do not edit: run `python3 agents/studioctl.py board`.

## Needs you

- E-0001 **policy** from monetization-designer on stormcatch: D6 disclosure (GDD O-H1) plus O-H2: (1) How should a paid, server-wide Sky Bell luck/odds change be shown to buyers and to players who paid nothing, and does it change the questionnaire answers (including the catalog's paid-random-item classification in section 6.1)? (2) May players whose ArePaidRandomItemsRestricted is true fish under a call another player bought? Options and recommendations in games/stormcatch/docs/catalog.md section 7 (7.2 options A/B/C, 7.3 options a/b/c). (`human resolve E-0001 --note "..."`)

## Games

| Game | Title | Stage | Status | Last gate |
|---|---|---|---|---|
| stormcatch | Stormcatch (working title) | design | active | pitch pass |

## Tasks

### Working (0)


### Needs review (0)


### Queued (3)

| Task | Owner | Game | Title | Waiting on |
|---|---|---|---|---|
| T-0012 | gatekeeper | stormcatch | Run the design gate | - |
| T-0014 | designer | stormcatch | Close the catalog watch items in the GDD | - |
| T-0015 | economist | stormcatch | Re-run the paying-player model against the catalog | - |

### Draft (needs a brief) (0)


## Studio leases

- studio-1: free

## Recent activity

- 2026-10-26T05:51:10Z director: added T-0015 'Re-run the paying-player model against the catalog' for economist (queued)
- 2026-10-26T05:51:10Z director: added T-0014 'Close the catalog watch items in the GDD' for designer (queued)
- 2026-10-26T05:51:10Z director: T-0009 -> done: Reviewed: catalog_numbers output md5 reproduced (58aa713...), Products.diff applies cleanly, check record passed, fairness 15/15, E-0001 escalated with options. W1/W2 and the paying-model mismatch queued as T-0014 and T-0015 before the gate.
- 2026-10-26T05:50:24Z director: T-0013 -> done: Reviewed: 0 'economy sheet (T-0008)' placeholders in gdd.md and specs/prototype.md, prototype brief and handoff validate, GDD version 2 with changelog, catalog-requested rules (catalog section 11) left for a follow-up.
- 2026-10-26T05:50:04Z monetization-designer: submitted T-0009 for review
- 2026-10-26T05:50:03Z designer: submitted T-0013 for review
- 2026-10-26T05:49:10Z monetization-designer: escalated E-0001 (policy)
- 2026-10-25T18:00:07Z designer: started T-0013
- 2026-10-25T18:00:06Z monetization-designer: started T-0009
- 2026-10-25T17:59:44Z director: added T-0013 'Sync the GDD with the economy sheet and world plan' for designer (queued)
- 2026-10-25T17:59:44Z director: T-0008 -> done: Reviewed: output md5 matches the handoff (4a40955...), check record passed, five goals per player type present (casual bridge 1 at 10.8 min, New Tide 1 at 62.2), luck stacking rule with caps including the D6 +25% shared Sky luck, deviations argued. GDD sync queued as T-0013; the gate re-runs the model.
- 2026-10-25T17:58:51Z economist: submitted T-0008 for review
- 2026-10-25T17:16:37Z director: T-0011 -> done: Reviewed: re-ran models/world_layout.py (All checks pass; output matches the stored file apart from the SVG-written line), base walk 16 studs/s confirmed in Util/Stats.luau, 11 adjacent pairs under 15 s, fronts avoid cove_dock, Callable spots marked, prototype subset marked, SVG has no external references. GDD deltas (ferry skips Gustwhistle Bluffs, dock pool moved) listed for the gate.
- 2026-10-25T17:16:00Z worldbuilder: submitted T-0011 for review
- 2026-10-25T09:44:47Z director: T-0007 -> done: Reviewed: criterion map (DESIGN-01/02/05/06/09/10), D6 Sky Bell meets all four constraints with griefing rules and ProcessReceipt credit flow, timetable check script run (60 s lead true, dock clear, 27.8% coverage), prototype brief validates. Economy numbers are labelled targets until T-0008 lands; the gate checks consistency.
