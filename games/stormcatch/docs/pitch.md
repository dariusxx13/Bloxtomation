---
title: "Pitch: Stormcatch (working title)"
date: 2026-10-24
status: submitted
author: scout (task T-0003)
---

# Stormcatch (working title): pitch

Task T-0003 · Scout · 2026-10-24 · Stage: pitch · Outcome served: **click** (an evidence-backed decision on whether to build this game). Submitted for the pitch gate (T-0004). The decision is yours.

This is a decision document. The detail is in the market scan (`games/stormcatch/docs/market-scan.md`, T-0001) and the loop sketch (`games/stormcatch/docs/loop-sketch.md`, T-0002), and each section here points to the part it draws on.

**Citation keys.** Every number below carries one of these keys.

| Key | Source | Taken or accessed (UTC) |
|---|---|---|
| [PC] | Chart snapshot `20261024T192440Z-computer-all.json.gz`: 26 sorts, 879 games (Roblox discovery sorts and public games API; unofficial endpoints) | 2026-10-24 19:24:40 |
| [PH] | Chart snapshot `20261024T192617Z-high_end_phone-all.json.gz`: 26 sorts, 907 games | 2026-10-24 19:26:17 |
| [GEN] | Tracker genres output `2026-10-24-genres-computer-all.txt`, computed from [PC] | 2026-10-24 |
| [RW] | RoWatcher game history pages (third party, approximate), via the scan | accessed 2026-10-24 |
| [GUIDES] | Public guides listed in the scan's Sources, with their dates and verification labels | published 2024-11-20 to 2026-10-21, read 2026-10-24 |
| [SK n] | Loop sketch section n. These are design targets and first-pass estimates, not measurements | 2026-10-24 |

Committed copies of [PC], [PH], both reports, both genres outputs and both evidence blocks are in `games/stormcatch/docs/evidence/charts-2026-10-24/`, because `charts/data/` is git-ignored. Every [PC] and [PH] number in this pitch was re-read from those files on 2026-10-24. **[PC] can support decisions under PITCH-01 (7 days) until 2026-10-31 19:24 UTC.** No second snapshot was taken; the Director decided against one.

## Decision in brief

- **The game:** cozy fishing on a small archipelago where each kind of weather is a different way to fish. The weather drifts between islands on a forecast everyone can read. Storms never hurt anyone. Every 15 minutes a Great Storm brings players together to pull in giant fish, and strangers count as helpers.
- **The market:** fishing is a stable genre with two leaders. Nine fishing games chart with 219,733 players, and Fisch and Fish It! hold 83.5% of them [PC]. We would be late for a fast follow, so we can only win by being different and better.
- **Rubric:** **35 / 54**, in the "refine the pitch" band (30-39). Comparable games prove the basic fishing loop. The twist, which is the reason to build this game, is untested.
- **Recommendation: approve with changes.** Approve a prototype only, with a written go/stop rule that tests whether players really fish differently in each weather. The options and their trade-offs are at the end.
- **What we need from you:** the decision and answers to five policy and naming questions (end of document). The prototype needs no money.

## Where each criterion is answered

| Criterion | Section here | Evidence pointer |
|---|---|---|
| PITCH-01 | Evidence | [PC], [PH], [GEN] in the evidence folder; scan "Data used", "Comparables" and appendix |
| PITCH-02 | One-liner | Sketch section 2 |
| PITCH-03 | The game | Sketch sections 5.1, 5.3, 5.7 |
| PITCH-04 | Competition and twist | Sketch sections 4.2 and 4.5; scan "Does weather already change play in the top 3 fishing games?" |
| PITCH-05 | Urgency | Scan "Urgency read"; [GEN] |
| PITCH-06 | Portfolio check | `python3 agents/studioctl.py game list`, 2026-10-24 19:46:59 UTC |
| PITCH-07 | Audience, rating and IP | Sketch section 8; scan "Audience" and "IP risks seen in the space" |
| PITCH-08 | Rubric score | This document; hit sheet in sketch section 9 as a cross-check |

## One-liner (PITCH-02)

**You tap to cast and reel, fishing a different way in each weather that drifts past, to get fish only that weather brings (coins and new journal pages) so you can buy a better rod and boots, open the bridge to the next island and be at the pier when the Great Storm hits.** [SK 2]

How it works in Roblox: there is one Cast button in the thumb zone, and the fishing spots are tagged ripple patches. The server decides every bite, roll and payout. The client sends only "cast at spot X" and "tapped at time t", and the server checks both for plausibility [SK 2]. The moment loop is the genre's standard cast, wait, bite, reel and reveal (`vault/14-genre-playbooks/fishing-and-collection.md`).

## Genre and audience

- **Roblox genre:** Simulation. All five fishing comparables select it. They rank in its trending sort: on computer, Fisch is #1, Deep Fishing #31 and Harpoon a Fish #51 [PC]. Subgenre: unknown from our data, because the games API returns "Simulation" in both fields for all five [PC].
- **Tier and label:** Kids and Select can be reached. The expected label is Minimal (a draft; see PITCH-07).
- **Devices:** phone first. Fish It! and the smaller fishing games rank higher on phone sorts, and Fisch ranks higher on computer. For example, Fish It! is #37 in Fun with Friends on computer and #21 on phone, and Fisch is #7 in top earning on computer and #13 on phone ([PC], [PH]). Absolute device shares are unknown.
- **Tourists and locals:** tourists land a first catch within 20 s and see a storm within 15 minutes. Locals get journal sets, size records, Tide Pots and a new weather front every Saturday [SK 5, 6].

## The game (PITCH-03)

All times are design targets or first-pass estimates [SK 5]. The prototype checks them.

| | As player actions |
|---|---|
| Core loop | Cast and wait 2-5 s. Reel the way the current weather demands. See the reveal (species, kg, rarity, weather mark) while coins fly to the counter. Spend coins on Rod, Lure, Boots and companion nests, and fix bridges to new islands. Long term: journal sets per island and weather, storm giants, a rebirth called "New Tide", and Saturday fronts. |
| First 60 seconds | Spawn on the dock facing a glowing ripple, rod in hand (0-5 s). Tap Cast (5-10 s). Tap when the ring turns green to land a first fish with a name, a weight and "+12" coins (10-20 s). Cast 3-4 more times while a "Better Rod: 15" bar fills (20-45 s). Open the pulsing shop and buy Rod 2, and the next fish is visibly bigger (45-60 s). [SK 5.1] |
| Minutes 1-10 | Walk into the first rain front and feel the reel change: bites come faster and the green band is wider. The first catch in rain is always a new species. Chase a rainbow, choose Lure or Boots, open a nest for a companion, and place a first Tide Pot where tonight's fog will pass. [SK 5.2] |
| Goal at 10-15 min | **Fix the bridge to Lantern Reef.** Its price sign is visible from spawn, and a progress bar sits on the HUD. Target: 10-12 minutes for a casual player who spends nothing. [SK 5.3] |
| First wow | Every player sees a Great Storm within 15 minutes of joining, because storms start at :00, :15, :30 and :45. Gather at the pier and tap **Pull!** to help land a giant. [SK 5.4] |
| Minutes 10-30 | Learn to fish fog by feel on the new island and finish the first 8-fish set. Meet gusts, where you cast with the wind. Work toward the next bridge and see a second storm. [SK 5.5] |
| Why tomorrow | Collect the Tide Pot set under last night's forecast. Catch the Fish of the Day that the daily almanac announced. Claim day 2 of the calendar. Finish a set that needs one weather. On Saturday, see the new front. [SK 5.7] |
| Friend reason | Everyone shares the weather. A storm giant takes about 45 s to land alone and about 10 s with four helpers (first-pass). Every helper, stranger or friend, gets a journal stamp and extra coins that do not come out of the angler's catch, capped per storm. [SK 4.4] |
| Clip moment | Five avatars pulling on the pier, lightning on a taut line, a giant fish breaching and a server banner naming everyone. It reads muted and without UI. [SK 5.6] |
| How it makes money | Directions only, because the catalog is design-stage work. An auto-reel pass weaker than active play, companion slots, an extra Tide Pot slot sold as capacity (not as a skip), a luck boost with its effect on odds disclosed, and weather cosmetics. The forecast and storms stay free, and nothing sells a way to skip a timer. [SK 3, 12] |
| Icon concept | Scout proposal for the Artist: a large fish leaping from dark water under a storm cloud, with one lightning flash and no text. Compare it with the comparables' icons before use, so it echoes none of them. |

## Evidence (PITCH-01)

| Source | Date (UTC) | Metric | Value | Note |
|---|---|---|---|---|
| [PC] all sorts | 2026-10-24 19:24:40 | Fishing games on the charts | 9 (7 at 1K+ players) | Listed in scan "Comparables" |
| [PC] | same | Fishing players on the charts | 219,733, which is 1.67% of 13,196,221 | Concurrent players in sort placements |
| [PC] | same | Leaders' share of fishing players | 83.5% (Fisch 107,205; Fish It! 76,378) | |
| [PC] | same | Fishing games created in 2026 | 5, with 26,156 players; largest Deep Fishing 12,352 | Like ratios 95-98% |
| [PC] | same | Fisch ranks | Playing now #14, earning #7, most popular #17, trending in Simulation #1 | |
| [PC], [PH] | 19:24:40; 19:26:17 | Fish It! in Fun with Friends | #37 computer, #21 phone | The only fishing game in that sort's top 40 |
| [PH] | 2026-10-24 19:26:17 | Heavyweight Fishing in top revisited | #8 phone (#32 computer [PC]) | Players return to a smaller fishing game |
| [GEN] | from [PC] | Simulation genre | 4.9M players, 37.1% of charting players, 254 games; phase "unknown (needs 36h+ of data)" | |
| [PC] games API | 2026-10-24 19:24:40 | Maturity of the 9 fishing and 3 weather comparables | All "minimal", minimum age 0 | |
| [RW] | accessed 2026-10-24 | Fish It! trajectory | Peak about 1.4M on 2025-11-24; now about 76K (about 5% of peak); 30-day -27%, "declining" | Approximate |
| [RW] | accessed 2026-10-24 | Fisch trajectory | 7-day average about 85K; 30-day -2.5%, "stable"; event peak about 510K on 2026-10-17 | Approximate |
| [GUIDES] | 2024-11-20 to 2026-10-21 | Weather in the top 3 fishing games | Fisch: seasons, random weather, summoning items [2 sources]. Fish It!: random weather and server weather bought with coins [2 sources]. Deep Fishing: none found [unverified absence] | Nobody at the studio has played these games |

Limits: there is one reading per device, taken on a Saturday evening (UTC) during Halloween events. One snapshot cannot show growth, risers or breakouts. Fisch's player count is spiky (see its event peak above), so any single reading of it is noisy. Third-party figures are approximate.

## Competition and twist (PITCH-04)

| Game (universe id) | Players [PC] | Like [PC] | Age [PC] | How Stormcatch plays differently |
|---|---|---|---|---|
| Fisch (5750914919) | 107,205 | 91% | 955 d | In Fisch, weather changes which fish spawn, and players can summon it. Seasons run on a global timer of about 9.6 h [GUIDES, 2 sources], and one storm event can eliminate players [GUIDES, 1 source]. In Stormcatch, weather changes how you cast and reel. Several fronts drift between islands at once, so the decision is where to go. The forecast shows the next few minutes inside the game, nothing summons weather, and storms are never a hazard. |
| Fish It! (6701277882) | 76,378 | 83% | 733 d | In Fish It!, one player pays coins for a server-wide boost (faster rods, luck, shiny odds) [GUIDES, 2 sources], and groups take turns paying [GUIDES, 1 source]. In Stormcatch, weather cannot be bought, so it stays a shared event that players can see coming. The social hook is being there together, not paying for a boost. |
| Deep Fishing (10526853622) | 12,352 | 97% | 97 d | No weather found [unverified absence]. It stood out with a new verb: a distance cast that steers through several fish. We take the lesson and copy nothing: a new way of fishing set apart the strongest 2026 entrant. |
| Heavyweight Fishing (8342498724) | 9,889 | 96% | 446 d | Mechanics not researched; listed for size and like ratio. |
| Harpoon a Fish (10764240948) | 7,501 | 97% | 57 d | Mechanics not researched; listed for size and like ratio. |

**The twist: each weather is a different way to fish, and the weather moves** [SK 4.2]:

- Rain gives fast, forgiving reels.
- Fog is fishing by feel: there is no "!" alert, you watch the bobber dip, and the catch is a mystery until it lands.
- In gusts, a cast made with the wind flies twice as far and the reel target sways.
- Great Storm giants land fastest when a crowd pulls.

These four parts are in the scan's "not found" column. Weather that changes spawns, weather mutations, rare weather as a server moment and summoned weather are already standard in Fisch, Fish It!, Grow a Garden, Sol's RNG and Ride A Pet (scan). Stormcatch keeps the first three only as the familiar layer and leaves summoning out [SK 4.5, twist check].

In the twist dimensions of `vault/15-market-research/trend-lifecycle.md`, this changes three things: the core verb (it differs per weather), the social structure (co-op landing) and platform fit (phone first). Caveat: "not found" means the scout did not find it in the public guides read; it is not a verified absence. Whether players feel the difference is also untested (risk 1).

## Urgency (PITCH-05)

| Measure | Value | Source |
|---|---|---|
| Fishing games on the charts | 9 (7 at 1K+ players) | [PC] |
| Leaders' share | 83.5% of 219,733 players | [PC] |
| Fishing games created in 2026 | 5, with 26,156 players combined; largest 12,352 | [PC] |
| Charting games where weather already changes play | 5 (Fisch, Fish It!, Grow a Garden, Sol's RNG, Ride A Pet) | [PC] plus [GUIDES] |
| Leader trajectories | Fisch stable (30-day -2.5%); Fish It! declining (30-day -27%; about 5% of its 2025-11-24 peak) | [RW] |

**Trend phase: genre (phase 5 in `vault/15-market-research/trend-lifecycle.md`). This is the scout's judgment, not a measurement.** It rests on four things: the 2024 spark (Fisch), Fish It!'s peak and decline [RW], a stable leader, and several smaller fishing games that hold 96-98% like ratios and returning players ([PC], [PH]).

The chart tool cannot measure the phase from one snapshot. It needs at least 36 hours of history and prints "unknown (needs 36h+ of data)" [GEN] (the threshold is in `charts/chartlib/analysis.py`). A second snapshot after 2026-10-25 19:24 UTC gives the first measured 24-hour change and visits per day for each comparable. A snapshot at or after 2026-10-26 07:25 UTC (36 hours after the first) also gives the tool's phase estimate. That estimate covers Simulation as a whole. The phase for fishing alone comes from the growth of the nine fishing games in the same report.

**Read: late for a fast follow, on time for a genre entry.** A 6-10 week build is the scan's estimate; the Engineer has not sized it yet. Counted from today, it would ship between 2026-12-05 and 2027-01-02, during the winter holidays, when traffic is higher and the leaders also run events. A prototype first pushes those dates later. Being early buys nothing here, and the 2026 fishing entrants top out at about 12K players [PC]. We win only by being **different** (the twist) and **better** (a phone-first feel and a new front every week). If the twist reads as decoration, this is a third fishing game behind two leaders.

## Portfolio check (PITCH-06)

`python3 agents/studioctl.py game list`, run 2026-10-24 19:46:59 UTC:

```text
stormcatch               pitch      active   Stormcatch (working title)
```

Stormcatch is the studio's only game, and the studio has not shipped any game yet, so Stormcatch duplicates nothing. The studio has recorded no house patterns, so there are none to follow or depart from. Stormcatch builds on the studio's game template (`template/`), which is a generic simulator base, not a shipped game.

## Audience, rating and IP (PITCH-07)

- **Audience tier (draft):** Roblox Kids and Select, phone first. The designer's draft core audience is ages 7-13 [SK 8]. The comparables' age split is not public, so it is unknown. All nine fishing comparables and the three weather comparables are "minimal" with minimum age 0 [PC].
- **Launch reach:** a new public game reaches only age-checked users aged 16 and over until it passes the under-16 evaluation. The evaluation needs 250 unique plays from engaged age-checked users within 60 days, plus a safety review (`vault/17-policy-and-business/age-ratings-and-audience.md`). The cozy loop therefore has to hold older players in the first weeks. Depth (weather skill, size records) matters for that, not only cute visuals.
- **Expected content rating (draft only; the human answers the questionnaire):** Minimal. The game as designed has no violence, blood, fear, crude humour, romance, alcohol, strong language, free-form creation or AI interaction. On fear: storms never hurt, there are no jump scares, and lightning flashes can be turned off [SK 8]. Whether the game has paid random items depends on question 2 below.
- **IP risks** (scan "IP risks seen in the space"; [SK 8]):
  1. Title convergence: fishing titles cluster on "Fish ___", "___ Fishing", "Catch a ___" and puns, and discovery demotes look-alike metadata. Our title and thumbnail must avoid those patterns.
  2. Competitors' named weather tools, items, events, UI and art belong to them. The general mechanics are free to use. Every name in the sketch is invented.
  3. No anime, meme or franchise characters, and no real tackle or outdoor brands.
  4. The working title is unchecked. One web search on 2026-10-24 found no Roblox game named "Stormcatch". "Storm Catcher" is an item name in a game outside Roblox. No trademark search has been done (question 3).
  5. The weather is fictional and runs on a schedule. No real-world weather data or player location is used, so no data-licensing or privacy question arises.
  6. Music and sound must be original or licensed, and recorded in the asset index.

## Build estimate and reuse

- **Prototype:** the vault's prototype gate says "days, not weeks", and the Engineer sizes it. The scope is the moment loop with juice, Showers and Sea Fog fronts moving across 3 spots, one rod upgrade line, one Great Storm with the co-op pull, and placeholder art [SK 10]. Most of the work is cut-down versions of the two new large systems, Fishing and Weather.
- **Launch content** [SK 6]: 4 islands, 4 weathers plus the Rainbow and the Great Storm, 48 species, 6 marks, 12 companions, 12 journal sets and 4 upgrade lines. Systems: an on-screen forecast dial, a daily almanac, Tide Pots, rebirth, a daily calendar, codes and the shop. The 6-10 week estimate comes from the scan; the Director and Engineer have not confirmed it.
- **Reuse** [SK 7]: these template systems need only a reskin or config: Upgrades, Zones and gates, Pets and Eggs (companions and nests), Rebirth, Rewards, Codes, Purchases (idempotent `ProcessReceipt`), Social, Onboarding, Analytics and QA. New work: 2 large systems (Fishing, Weather) and 4 medium ones (weather reel modes, the storm co-op pull, the Sky Journal, Tide Pots).

## Risks

1. **The twist reads as decoration**, turning the game into "Fisch with moving clouds". Mitigation: make each weather's action clearly different and teach the first one at minute 2. In the prototype, run two twist tests [SK 10, 11]:
   - Test A passes if 4 of 5 testers describe two weathers by what their hands did.
   - Test B passes if 45% or more of catches happen under fronts, which cover about 25% of the water. Under 30% means players ignore the weather.
2. **Late entry into a genre two leaders control** (83.5% share [PC]). Mitigation: a phone-first feel, the twist, a new front every week, and a thumbnail that sells the storm. If the twist fails, stop rather than ship a third generic fishing game.
3. **Phone problems:** weather effects may be too costly on low-end devices, and the reel modes may be fiddly on touch. Mitigation: full detail only for the nearest front, lighting and `Atmosphere` instead of particles, generous timing windows, misses that cost nothing, and gusts left optional. Test on a low-end Android phone in the first prototype week [SK 11].

Other risks (cozy pace against chasing fronts, value inflation from marks, time zones) are in sketch section 11.

## Rubric score (PITCH-08)

The scores use the rubric in `vault/15-market-research/pitch-and-greenlight.md`. The design is scored as written against each line's 0 and 3 descriptions, and a point comes off only for a named gap. "Untested" counts once, on the core loop line, because that line's description asks for proof.

| Criterion | Weight | Score 0-3 | Points | Justification |
|---|---|---|---|---|
| Core loop clarity and fun | 3 | 2 | 6 | Strong comparables prove the cast-reel-reveal loop (Fisch 107,205 and Fish It! 76,378 players [PC]). The twist that makes this game worth building has no prototype yet. |
| First-session strength | 2 | 2 | 4 | The design puts the first input by 10 s, the first catch at 15-20 s, the bridge goal at 10-12 min and a storm within 15 min [SK 5]. Gaps: the first catch comes later than the rubric's 10 s mark. The title "Stormcatch" has no verb, so the game's tile does not explain the loop (hit sheet row 1: 1/2). The weather reel modes are the part most likely to confuse a young player on a phone. |
| Return and endgame potential | 2 | 2 | 4 | Strong reasons to come back (Tide Pots, Fish of the Day, the calendar, sets that need one weather) and a clear update unit: a new front every Saturday and a new island every 3-4 weeks. Gaps: there is **no consequence layer**, the risk of loss to other players that 2025-2026 hits use to bring players back to protect what they have (`vault/21-hits-and-trends/anatomy-of-a-hit.md`, ingredient 3). There is also no trading at launch. |
| Social and clip potential | 2 | 2 | 4 | The strongest line on paper: strangers help land storm giants and earn rewards for it, and the clip moment reads with the sound off. Gaps: **no external funnel plan** (creators, social media, crossovers) to carry clips outside the game (hit sheet row 8: 1/2), and no consequence stories to share. |
| Market evidence | 2 | 2 | 4 | Same-day evidence across several games shows steady demand for fishing (9 games, 219,733 players [PC]; a stable leader [RW]). Gaps: one snapshot per device, so there is no measured growth, risers or phase. The evidence shows demand for fishing, not for this twist. |
| Differentiation | 2 | 2 | 4 | A clear twist that changes the action, the social structure and the device fit, checked against the scan's "not found" column. Gap: that column comes from public guides, not from playing the comparables, so the claim that the twist is unique is unverified. |
| Timing | 1 | 1 | 1 | **Late entry into a two-leader genre**: the leaders hold 83.5%, and 2026 entrants top out at 12,352 players [PC]. Not 0, because fishing has become an evergreen genre with stable demand, not a fading wave. |
| Monetization fit | 1 | 2 | 2 | The directions are natural and fair: an auto-reel pass weaker than active play, capacity, cosmetics and disclosed luck, with no pay-to-skip and no paid weather. Gaps: no catalog or price tiers yet, and the paid-random-items question (selling coins for Robux) is open. |
| Feasibility for our team | 2 | 2 | 4 | Most systems are template reskins [SK 7]. Gaps: 2 large and 4 medium new systems, weather effects on low-end phones, a weekly update rhythm the team has never kept, and no shipped game that shows how fast the team works. |
| Policy and IP safety | 1 | 2 | 2 | Expected Minimal, all names invented, no real-world data. Gaps: **no trademark check on the title**, and paid random items are undecided. |
| **Total (max 54)** | | | **35** | **Band 30-39: refine the pitch** (usually the twist or the evidence). |

**Cross-check with the hit sheet** (sketch section 9, 17/20). The two scores answer different questions. The hit sheet measures how closely the design matches recent hits, and it rates this design highly. The greenlight rubric weighs proof, timing and feasibility, so the same pitch scores 85% on the hit sheet and 65% here. The three weak hit-sheet rows (title, consequence layer, external funnel) are the same gaps named above.

**What can still move the score.** Work on paper can add about 5 points, to about 40:

- +2 on market evidence, if a measured second snapshot shows fishing holding steady.
- +2 on social and clip, from an external funnel plan.
- +1 on policy and IP, from a cleared title and a decision on paid random items.

The core loop, differentiation and first-session lines carry 7 of the rubric's 18 weight units. Only a prototype can move them.

## Recommendation and options

**Scout recommendation: approve with changes.** The total falls in the "refine" band. The biggest gap is one no document can close: whether players really fish differently in each weather. A prototype answers that in days for some engineering time, and the fixes to the evidence can run alongside it.

The changes:

1. Approve a **prototype only** (scope in sketch section 10) with a written go/stop rule. Continue only if twist tests A and B and the 30-second test pass (5 of 5 testers land a fish within 30 s). Pivot or stop if fewer than 30% of catches happen under fronts.
2. The scout takes a second snapshot at or after 2026-10-26 07:25 UTC, then re-scores market evidence and timing before the prototype verdict.
3. The title is chosen and name-checked before any store page or thumbnail work. The prototype does not need it.
4. An external funnel plan is added at the design stage. The absence of a consequence layer stays as an argued omission and is reviewed with prototype data.

| Option | What happens | Trade-off |
|---|---|---|
| **A. Approve with changes (recommended)** | The prototype starts, the evidence fixes run beside it, and the twist tests decide go or stop. | It spends engineering days on an unproven twist in a genre we are late to. In return, the top risk is answered by play rather than argument, and most systems are reused. |
| **B. Refine first, then decide** | Second snapshot, title check, funnel plan and paid-random-items decision; re-score in about a week. | This is the literal reading of the 30-39 band. Evidence improves and the score rises by about 5 points at most. But the core loop line (weight 3) and differentiation cannot move without play. Each week of delay pushes the ship window further into or past the winter holidays. |
| **C. Reject (park) and look for an earlier trend** | Keep tracking fishing while the scout looks for formats in the spark or rise phase. | It avoids a late entry into a genre where 2026 entrants top out at about 12K players [PC]. But the studio has no other pitch ready, so the studio has nothing to build until a new scan and sketch exist, and the designed loop goes unused. |

The decision is yours. Passing the pitch gate means only that the pitch meets the written criteria.

## Questions for the human

These are open questions, each with the studio's recommendation. The scout has not escalated any of them; the Director handles escalation.

1. **Maturity questionnaire.** How will you answer it for this content? Studio recommendation: answer from the content as built, at release, expecting Minimal (the draft is in PITCH-07). Answer it again after each content update.
2. **Paid random items.** Should coins be sold for Robux? If they are, companion nests become paid random items, because the rules cover random outcomes obtained with Robux "directly or indirectly" (`vault/09-monetization/monetization-compliance.md`). Does a Robux pass that speeds up coin earning also count as "indirectly"? Studio recommendation: no Robux coin packs at launch, so nests are bought only with coins players earn. Keep the template's odds display and `ArePaidRandomItemsRestricted` handling either way. The questionnaire answer is yours.
3. **Store title and trademark.** Keep "Stormcatch", or choose a title that starts with a verb and avoids the genre's common patterns (the designer's example is "Reel the Storm")? No trademark search has been done for any candidate. Studio recommendation: a verb-first title, with a name and trademark check on the finalists before any store page work.
4. **Selling or summoning weather.** Should players ever be able to summon or buy weather, for coins or Robux, at launch or later? Studio recommendation: no. Both leaders already do it [GUIDES], and it would make the shared forecast untrue. A Robux version would be a paid change to everyone's odds on the server, which carries disclosure duties. An unpaid, cooperative "call a front" could be tested after launch.
5. **Later, at launch planning (money and policy).** To reach players under 16, the game needs four things: a verified owner with 2-step verification, the full questionnaire, a publishing fee or subscription, and a passed evaluation. An expedited review costs a refundable fee (`vault/17-policy-and-business/age-ratings-and-audience.md`). Studio recommendation: no action now. The Director brings this to you at launch planning.

## Sources

- Market scan: `games/stormcatch/docs/market-scan.md` (T-0001, 2026-10-24). Its third-party sources and verification labels apply to every comparable mechanic quoted here.
- Loop sketch: `games/stormcatch/docs/loop-sketch.md` (T-0002, 2026-10-24).
- Chart evidence (committed copies): `games/stormcatch/docs/evidence/charts-2026-10-24/`. It holds [PC], [PH], the reports `2026-10-24-computer-all.md` and `2026-10-24-high_end_phone-all.md`, both genres outputs and both evidence blocks.
- Chart tool phase threshold: `charts/chartlib/analysis.py` (`phase_for`, `genre_stats`: at least 36 h of history).
- Portfolio: `python3 agents/studioctl.py game list`, 2026-10-24 19:46:59 UTC.
- Vault (all 2026-10-24): `15-market-research/pitch-and-greenlight.md`, `18-templates-and-checklists/pitch-template.md`, `15-market-research/trend-lifecycle.md`, `15-market-research/reading-the-charts.md`, `11-store-page-and-discovery/discovery-algorithm.md`, `00-start-here/roblox-platform-2026.md`, `14-genre-playbooks/fishing-and-collection.md`, `21-hits-and-trends/anatomy-of-a-hit.md`, `17-policy-and-business/ip-and-licensing.md`, `17-policy-and-business/age-ratings-and-audience.md`, `09-monetization/monetization-compliance.md`.
