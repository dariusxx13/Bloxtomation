# Reel the Storm: design follow-ups

Non-blocking mismatches found by the first design gate (`gates/design-01.json`, T-0012, 2026-10-26). None fails a criterion on its own. The Director tracks them here, and the owners fix them in their next pass on each document, at the latest before the prototype gate. Mark each item done with the commit that fixed it.

| # | Where | Mismatch | Owner | Status |
|---|---|---|---|---|
| 6 | GDD §4.3 | Pull time "7.3 s with 7 helpers"; the formula 45/(1+0.875×7) gives 6.3 s (7.2 s is the 6-helper figure) | designer | open |
| 7 | Economy sheet §17 | Catch-only casual bridge "modelled 14.8"; §1, the model and the GDD say 14.3 | economist | open |
| 8 | Economy sheet §6 | "9 unnamed companions"; there are 8 | economist | open |
| 9 | GDD §4.2 rule 3 | Harbour visit paths still "to be added to world plan §7"; world plan v2 §7.1 has them | designer | open |
| 10 | World plan §8, GDD §4.5 | Longest walk given as slip-to-slip (673 studs, 42.1 s); it is reef_outer to anvil_reach (681 studs, 42.5 s) | worldbuilder, designer | open |
| 11 | World plan §6.1 | The 40-stud Pull circle is said to cover the pier head; the head's diagonal is 41.2 studs | worldbuilder | open |
| 12 | World plan vs layout model | Thunderhead nest id `storm_nest` (plan) vs `thunder_nest` (model); tied to open question O-W1 | worldbuilder | open |
| 13 | Art direction vs world plan | Weathervane on a roof (art) vs on the pier mast (world plan) | artist | open |

Items 1-5 from the same gate were in the catalog and are fixed by task T-0018.

Process note: change requests in a handoff's **Next** section become Director-queued tasks before a gate is called. Missing that step caused the first design gate's only failure (DESIGN-07).

Related: [GDD](gdd.md) · [Economy sheet](economy-sheet.md) · [World plan](world-plan.md) · [Art direction](art-direction.md) · [Catalog](catalog.md)
