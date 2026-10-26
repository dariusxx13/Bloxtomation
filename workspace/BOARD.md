# Studio board

Updated 2026-10-26T11:14:08Z by studioctl. Do not edit: run `python3 agents/studioctl.py board`.

## Needs you

- E-0001 **policy** from monetization-designer on stormcatch: D6 disclosure (GDD O-H1) plus O-H2: (1) How should a paid, server-wide Sky Bell luck/odds change be shown to buyers and to players who paid nothing, and does it change the questionnaire answers (including the catalog's paid-random-item classification in section 6.1)? (2) May players whose ArePaidRandomItemsRestricted is true fish under a call another player bought? Options and recommendations in games/stormcatch/docs/catalog.md section 7 (7.2 options A/B/C, 7.3 options a/b/c). (`human resolve E-0001 --note "..."`)

## Games

| Game | Title | Stage | Status | Last gate |
|---|---|---|---|---|
| stormcatch | Stormcatch (working title) | design | active | design fail |

## Tasks

### Working (0)


### Needs review (0)


### Queued (2)

| Task | Owner | Game | Title | Waiting on |
|---|---|---|---|---|
| T-0018 | monetization-designer | stormcatch | Revise the catalog to economy sheet v2 and GDD v3.1 | - |
| T-0019 | gatekeeper | stormcatch | Re-run the design gate after the catalog revision | T-0018 |

### Draft (needs a brief) (0)


## Studio leases

- studio-1: free

## Recent activity

- 2026-10-26T11:14:08Z director: added T-0019 'Re-run the design gate after the catalog revision' for gatekeeper (queued)
- 2026-10-26T11:14:08Z director: added T-0018 'Revise the catalog to economy sheet v2 and GDD v3.1' for monetization-designer (queued)
- 2026-10-26T11:14:08Z director: T-0012 -> done: Gate review accepted: 9/10 pass, DESIGN-07 fail confirmed (catalog never revised to sheet v2 / GDD v3.1; Director did not queue the catalog change requests). Rework T-0018, re-gate T-0019; non-blocking items 6-13 tracked in docs/design-followups.md.
- 2026-10-26T11:12:53Z gatekeeper: submitted T-0012 for review
- 2026-10-26T11:11:37Z gatekeeper: gate design for stormcatch: fail
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
