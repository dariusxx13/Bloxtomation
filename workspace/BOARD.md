# Studio board

Updated 2026-10-26T10:44:04Z by studioctl. Do not edit: run `python3 agents/studioctl.py board`.

## Needs you

- E-0001 **policy** from monetization-designer on stormcatch: D6 disclosure (GDD O-H1) plus O-H2: (1) How should a paid, server-wide Sky Bell luck/odds change be shown to buyers and to players who paid nothing, and does it change the questionnaire answers (including the catalog's paid-random-item classification in section 6.1)? (2) May players whose ArePaidRandomItemsRestricted is true fish under a call another player bought? Options and recommendations in games/stormcatch/docs/catalog.md section 7 (7.2 options A/B/C, 7.3 options a/b/c). (`human resolve E-0001 --note "..."`)

## Games

| Game | Title | Stage | Status | Last gate |
|---|---|---|---|---|
| stormcatch | Stormcatch (working title) | design | active | pitch pass |

## Tasks

### Working (1)

| Task | Owner | Game | Title | Waiting on |
|---|---|---|---|---|
| T-0015 | economist | stormcatch | Re-run the paying-player model against the catalog | - |

### Needs review (0)


### Queued (1)

| Task | Owner | Game | Title | Waiting on |
|---|---|---|---|---|
| T-0012 | gatekeeper | stormcatch | Run the design gate | - |

### Draft (needs a brief) (0)


## Studio leases

- studio-1: free

## Recent activity

- 2026-10-26T06:09:51Z director: T-0016 -> done: Reviewed: re-ran world_layout.py (exit 0, layout v2, All checks pass), both harbour visit paths avoid cove_dock, WindYaw defined per Gusts cell including two cells v1 missed, handoff validates.
- 2026-10-26T06:09:32Z worldbuilder: submitted T-0016 for review
- 2026-10-26T06:02:50Z worldbuilder: started T-0016
- 2026-10-26T06:02:36Z director: added T-0016 'Add harbour weather visits and WindYaw to the world plan' for worldbuilder (queued)
- 2026-10-26T06:02:36Z director: T-0014 -> done: Reviewed: cove_visits_check.py run (all checks pass: rain wait 260 s, 0/672 cycles without the Sky Bell window, 0/168 hours missing a visit, Rainbow unchanged), W1/W2 resolved by hourly natural visits, four catalog rules added, prototype brief unchanged (md5 4c04c92...) and valid, GDD v3.
- 2026-10-26T06:01:53Z designer: submitted T-0014 for review
- 2026-10-26T05:51:29Z economist: started T-0015
- 2026-10-26T05:51:26Z designer: started T-0014
- 2026-10-26T05:51:10Z director: added T-0015 'Re-run the paying-player model against the catalog' for economist (queued)
- 2026-10-26T05:51:10Z director: added T-0014 'Close the catalog watch items in the GDD' for designer (queued)
- 2026-10-26T05:51:10Z director: T-0009 -> done: Reviewed: catalog_numbers output md5 reproduced (58aa713...), Products.diff applies cleanly, check record passed, fairness 15/15, E-0001 escalated with options. W1/W2 and the paying-model mismatch queued as T-0014 and T-0015 before the gate.
- 2026-10-26T05:50:24Z director: T-0013 -> done: Reviewed: 0 'economy sheet (T-0008)' placeholders in gdd.md and specs/prototype.md, prototype brief and handoff validate, GDD version 2 with changelog, catalog-requested rules (catalog section 11) left for a follow-up.
- 2026-10-26T05:50:04Z monetization-designer: submitted T-0009 for review
- 2026-10-26T05:50:03Z designer: submitted T-0013 for review
- 2026-10-26T05:49:10Z monetization-designer: escalated E-0001 (policy)
