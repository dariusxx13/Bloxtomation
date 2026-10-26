# Studio board

Updated 2026-10-26T10:58:59Z by studioctl. Do not edit: run `python3 agents/studioctl.py board`.

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
| T-0012 | gatekeeper | stormcatch | Run the design gate | - |

### Needs review (0)


### Queued (0)


### Draft (needs a brief) (0)


## Studio leases

- studio-1: free

## Recent activity

- 2026-10-26T10:58:59Z gatekeeper: started T-0012
- 2026-10-26T10:58:38Z director: T-0017 -> done: Reviewed: grep finds no v1 pacing values in gdd.md, v2 values present, GDD v3.1, prototype brief and handoff validate; Auto Reel pause and Gusts assist decided.
- 2026-10-26T10:58:21Z designer: submitted T-0017 for review
- 2026-10-26T10:52:53Z designer: started T-0017
- 2026-10-26T10:52:40Z director: added T-0017 'Sync the GDD with economy sheet v2' for designer (queued)
- 2026-10-26T10:52:40Z director: T-0015 -> done: Reviewed: output md5 64bb627... matches, handoff validates, paying player buys catalog products only; ratios 1.31x (by design, nothing sold before the first bridge), 2.34x, 2.87x; catalog questions and O-EC3/4/5 answered in sheet section 19. GDD mirror numbers sync queued as T-0017.
- 2026-10-26T10:51:59Z economist: submitted T-0015 for review
- 2026-10-26T06:09:51Z director: T-0016 -> done: Reviewed: re-ran world_layout.py (exit 0, layout v2, All checks pass), both harbour visit paths avoid cove_dock, WindYaw defined per Gusts cell including two cells v1 missed, handoff validates.
- 2026-10-26T06:09:32Z worldbuilder: submitted T-0016 for review
- 2026-10-26T06:02:50Z worldbuilder: started T-0016
- 2026-10-26T06:02:36Z director: added T-0016 'Add harbour weather visits and WindYaw to the world plan' for worldbuilder (queued)
- 2026-10-26T06:02:36Z director: T-0014 -> done: Reviewed: cove_visits_check.py run (all checks pass: rain wait 260 s, 0/672 cycles without the Sky Bell window, 0/168 hours missing a visit, Rainbow unchanged), W1/W2 resolved by hourly natural visits, four catalog rules added, prototype brief unchanged (md5 4c04c92...) and valid, GDD v3.
- 2026-10-26T06:01:53Z designer: submitted T-0014 for review
- 2026-10-26T05:51:29Z economist: started T-0015
- 2026-10-26T05:51:26Z designer: started T-0014
