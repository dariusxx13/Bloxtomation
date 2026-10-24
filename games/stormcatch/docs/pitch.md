---
title: "Pitch: Reel the Storm (id stormcatch)"
date: 2026-10-24
status: "resubmitted for the re-gate T-0006 after the T-0005 fixes"
author: scout (task T-0003)
---

# Reel the Storm: pitch

Game id `stormcatch`. The working title was Stormcatch until the human chose "Reel the Storm" (D3).

Task T-0003 · Scout · 2026-10-24 · Stage: pitch · Outcome served: **click** (an evidence-backed decision on whether to build this game). Submitted for the pitch gate (T-0004), which failed PITCH-01; resubmitted for the re-gate (T-0006) after the T-0005 fixes. The decision is yours.

**Ten-minute reading path:** "Decision in brief", "Decisions you have already made", "Rubric score", "Recommendation and options" and "Questions for the human". The other sections hold the evidence for each gate criterion.

This is a decision document. The detail is in the market scan (`games/stormcatch/docs/market-scan.md`, T-0001), the loop sketch (`games/stormcatch/docs/loop-sketch.md`, T-0002) and the human's decisions (`games/stormcatch/docs/decisions.md`). Each section here points to the part it draws on.

**Citation keys.** Every number below carries one of these keys.

| Key | Source | Taken or accessed (UTC) |
|---|---|---|
| [PC] | Chart snapshot `20261024T192440Z-computer-all.json.gz`: 26 sorts, 879 games (Roblox discovery sorts and public games API; unofficial endpoints) | 2026-10-24 19:24:40 |
| [PH] | Chart snapshot `20261024T192617Z-high_end_phone-all.json.gz`: 26 sorts, 907 games | 2026-10-24 19:26:17 |
| [GEN] | Tracker genres output `2026-10-24-genres-computer-all.txt`, computed from [PC] | 2026-10-24 |
| [RW] | RoWatcher game history pages (third party, approximate), via the scan | accessed 2026-10-24 |
| [GUIDES] | Public guides listed in the scan's Sources, with their dates and verification labels | published 2024-11-20 to 2026-10-21, read 2026-10-24 |
| [SK n] | Loop sketch section n. These are design targets and first-pass estimates, not measurements | 2026-10-24 |
| [D n] | The human's decision n, recorded by the Director in `decisions.md` | 2026-10-24 |

Committed copies of [PC], [PH], both reports, both genres outputs and both evidence blocks are in `games/stormcatch/docs/evidence/charts-2026-10-24/`, because `charts/data/` is git-ignored. Every [PC] and [PH] number in this pitch was re-read from those files on 2026-10-24. **[PC] can support decisions under PITCH-01 (7 days) until 2026-10-31 19:24 UTC.** No second snapshot was taken; the Director decided against one.

## Decision in brief

- **The game:** cozy fishing on a small archipelago where each kind of weather is a different way to fish. The weather drifts between islands on a forecast everyone can read. Storms never hurt anyone. Every 15 minutes a Great Storm brings players together to pull in giant fish, and strangers count as helpers.
- **The market:** fishing is a stable genre with two leaders. Nine fishing games chart with 219,733 players, and Fisch and Fish It! hold 83.5% of them [PC]. We would be late for a fast follow, so we can only win by being different and better.
- **Rubric:** **35 / 54**, in the "refine the pitch" band (30-39). Comparable games prove the basic fishing loop. The twist, which is the reason to build this game, is untested. Your decisions D2 to D6 changed six justifications and no scores.
- **Recommendation: approve with changes.** Approve a prototype only, with a written go/stop rule that tests whether players really fish differently in each weather. The options and their trade-offs are at the end.
- **What we need from you:** the decision after the gate, and three open questions (end of document). The prototype needs no money.

## Decisions you have already made

From `games/stormcatch/docs/decisions.md` (written by the Director from your chat replies of 2026-10-24). They are recorded here as your decisions, not as studio answers.

| # | Your decision | Where it shows in this pitch |
|---|---|---|
| D1 | You intend to approve. This is not an approval: the gate runs on evidence, and you record the approval yourself after it. It changed neither the score nor the recommendation. | Recommendation |
| D2 | Companion nests count as paid random items when coins can be bought with Robux. | The game (money), PITCH-07 |
| D3 | The store title is "Reel the Storm", with no trademark search; you accept that risk. The game id stays `stormcatch`. | Title, PITCH-07, rubric |
| D4 | Superseded by D6 the same day (the first answer was "no"). | n/a |
| D5 | The expected label is Minimal. This is the Director's reading of "Whatever the designer recommends", which you can correct in `decisions.md`. You fill in the questionnaire yourself in Creator Hub before release. | PITCH-07 |
| D6 | Players can summon weather for Robux ("Wait, summoning weather shall be at a robux cost."). | The game (money), PITCH-04, risks, rubric, questions |

## Where each criterion is answered

| Criterion | Section here | Evidence pointer |
|---|---|---|
| PITCH-01 | Evidence | [PC], [PH], [GEN] in the evidence folder; scan "Data used", "Comparables" and appendix |
| PITCH-02 | One-liner | Sketch section 2 |
| PITCH-03 | The game | Sketch sections 5.1, 5.3, 5.7 |
| PITCH-04 | Competition and twist | Sketch sections 4.2 and 4.5; scan "Does weather already change play in the top 3 fishing games?"; D6 |
| PITCH-05 | Urgency | Scan "Urgency read"; [GEN] |
| PITCH-06 | Portfolio check | `python3 agents/studioctl.py game list`, 2026-10-24 19:46:59 UTC |
| PITCH-07 | Audience, rating and IP | Sketch section 8; scan "Audience" and "IP risks seen in the space"; D2, D3, D5, D6 |
| PITCH-08 | Rubric score | This document; hit sheet in sketch section 9 as a cross-check |

## One-liner (PITCH-02)

**You tap to cast and reel, fishing a different way in each weather that drifts past, to get fish only that weather brings (coins and new journal pages) so you can buy a better rod and boots, open the bridge to the next island and be at the pier when the Great Storm hits.** [SK 2]

How it works in Roblox: there is one Cast button in the thumb zone, and the fishing spots are tagged ripple patches. The server decides every bite, roll and payout. The client sends only "cast at spot X" and "tapped at time t", and the server checks both for plausibility [SK 2]. The moment loop is the genre's standard cast, wait, bite, reel and reveal (`vault/14-genre-playbooks/fishing-and-collection.md`).

## Genre and audience

- **Roblox genre:** Simulation. All five fishing comparables select it. They rank in its trending sort: on computer, Fisch is #1, Deep Fishing #31 and Harpoon a Fish #51 [PC]. Subgenre: unknown from our data, because the games API returns "Simulation" in both fields for all five [PC].
- **Tier and label:** Kids and Select can be reached. The expected label is Minimal [D5] (see PITCH-07).
- **Devices:** phone first, as a design choice. Most Roblox sessions are on phones and tablets, a large share on cheap Android devices, and the platform note says to design for a 6-inch touchscreen first (`vault/00-start-here/roblox-platform-2026.md` line 28, note dated 2026-10-24; it gives no percentage). Absolute device shares are unknown. The fishing chart ranks do not by themselves point to phone: they split by game. Organic ranks, computer / phone ([PC] 19:24:40, [PH] 19:26:17, sponsored entries removed) (corrected by scout, T-0005, per gate PITCH-01):
  - Higher on phone: Fish It! (Fun with Friends #37 / #21, earning #74 / #32; playing now #21 / #21) and Heavyweight Fishing (revisited #32 / #8).
  - Higher on computer, or charting only there: Fisch (earning #7 / #13, most popular #17 / #53, trending in Simulation #1 / #17, revisited #28 / #37; playing now #14 / #14; Fun with Friends #87 on phone only), Deep Fishing (earning #80 / #79, one place apart; trending #64 and trending in Simulation #31 on computer only), Fish an Anime RNG (Fun with Friends #80 on computer; in none of the 26 phone sorts) and Roll a Fisherman (Fun with Friends #86 on computer; in none of the 26 phone sorts).
  - Mixed: Harpoon a Fish (trending #92 and trending in Simulation #51 on computer only; up-and-coming #88 on phone only).
  - Equal: Cage Fishing (top rated #38 / #38) and Titan Fishing (top rated #60 / #60).
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
| How it makes money | The catalog includes a **Robux weather summon** [D6], alongside the designer's direction [SK 12]: an auto-reel pass weaker than active play, companion slots, an extra Tide Pot slot sold as capacity (not as a skip), a luck boost with its effect on odds disclosed, and weather cosmetics. Companion nests are paid random items when coins can be bought with Robux, with odds shown [D2]. Prices, durations and effects are design-stage work. The design stage applies four constraints to the summon [D6]: (1) a summoned front shows on the Sky Dial for the whole server; (2) its benefit is shared with every player there; (3) it never moves the Great Storm schedule; (4) the purchase is granted only in `ProcessReceipt`. The Designer reworks sketch sections 3, 4.3 and 12 to match [D6]. |
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

| Game (universe id) | Players [PC] | Like [PC] | Age [PC] | How Reel the Storm plays differently |
|---|---|---|---|---|
| Fisch (5750914919) | 107,205 | 91% | 955 d | In Fisch, weather changes which fish spawn, and players can summon it with items [GUIDES, 2 sources]. Seasons run on a global timer of about 9.6 h [GUIDES, 2 sources], and one storm event can eliminate players [GUIDES, 1 source]. In Reel the Storm, weather changes how you cast and reel. Several fronts drift between islands at once, so the decision is where to go. The forecast shows the next few minutes inside the game, and storms are never a hazard. Both games let players summon weather (ours for Robux [D6]), so summoning is not a difference. |
| Fish It! (6701277882) | 76,378 | 83% | 733 d | In Fish It!, one player pays coins for a server-wide boost (faster rods, luck, shiny odds) [GUIDES, 2 sources], and groups take turns paying [GUIDES, 1 source]. Reel the Storm also sells a shared server weather (for Robux [D6]), so that part is familiar, not a difference. The differences are three: what weather does in your hands, fronts that move between islands, and a main social event (the Great Storm) that nobody can buy or move. |
| Deep Fishing (10526853622) | 12,352 | 97% | 97 d | No weather found [unverified absence]. It stood out with a new verb: a distance cast that steers through several fish. We take the lesson and copy nothing: a new way of fishing set apart the strongest 2026 entrant. |
| Heavyweight Fishing (8342498724) | 9,889 | 96% | 446 d | Mechanics not researched; listed for size and like ratio. |
| Harpoon a Fish (10764240948) | 7,501 | 97% | 57 d | Mechanics not researched; listed for size and like ratio. |

**The twist: each weather is a different way to fish, and the weather moves** [SK 4.2]:

- Rain gives fast, forgiving reels.
- Fog is fishing by feel: there is no "!" alert, you watch the bobber dip, and the catch is a mystery until it lands.
- In gusts, a cast made with the wind flies twice as far and the reel target sways.
- Great Storm giants land fastest when a crowd pulls.

These four parts are in the scan's "not found" column. The scan's "already standard" column holds four things: weather that changes spawns, weather mutations, rare weather as a server moment, and summoning or buying weather (Fisch's summoning items, Fish It!'s coin-bought weather machine). Reel the Storm uses the first three as the familiar layer [SK 4.5]. The Robux weather summon [D6] is a **familiar monetization layer, not part of the twist**.

**The forecast and the paid summon.** The twist promises a forecast that is true for everyone, and a bought front changes the sky. D6's constraints handle most of that tension:

- The summoned front appears on the Sky Dial for everyone in that server, so every player there sees it as soon as it is bought.
- Its benefit goes to every player in the server, not only the buyer.
- The Great Storm schedule stays the same in every server.

What the constraints leave to the design stage: a forecast read before a purchase did not include the bought front, and it is open how summoned fronts interact with the natural fronts and with features computed from the global schedule (Tide Pots, almanac windows). The Designer reworks sketch sections 3, 4.3 and 12 for this [D6].

In the twist dimensions of `vault/15-market-research/trend-lifecycle.md`, the twist changes two things: the core verb (it differs per weather) and the social structure (co-op landing). Platform fit is not claimed: that dimension means "a mobile-first version of a PC-heavy format", and the [PC]/[PH] ranks do not show fishing as computer-heavy (Fish It! and Heavyweight Fishing rank higher on phone; see "Genre and audience", Devices). Phone first stays as a design choice, because most Roblox sessions are on phones and tablets (`vault/00-start-here/roblox-platform-2026.md` line 28, 2026-10-24). (corrected by scout, T-0005, per gate PITCH-01) Caveat: "not found" means the scout did not find it in the public guides read; it is not a verified absence. Whether players feel the difference is also untested (risk 1).

## Urgency (PITCH-05)

| Measure | Value | Source |
|---|---|---|
| Fishing games on the charts | 9 (7 at 1K+ players) | [PC] |
| Leaders' share | 83.5% of 219,733 players | [PC] |
| Fishing games created in 2026 | 5, with 26,156 players combined; largest 12,352 | [PC] |
| Charting games where weather already changes play | 5 (Fisch, Fish It!, Grow a Garden, Sol's RNG, Ride A Pet) | [PC] plus [GUIDES] |
| Leader trajectories | Fisch stable (30-day -2.5%); Fish It! declining (30-day -27%; about 5% of its 2025-11-24 peak) | [RW] |

**Trend phase: genre (phase 5 in `vault/15-market-research/trend-lifecycle.md`). This is the scout's judgment, not a measurement.** It rests on four things: the 2024 spark (Fisch), Fish It!'s peak and decline [RW], a stable leader, and staying-power signals. Six of the seven smaller fishing games hold 96-98% like ratios (Deep Fishing 97.2%, Heavyweight Fishing 96.1%, Harpoon a Fish 97.3%, Roll a Fisherman 98.3%, Cage Fishing 98.2%, Titan Fishing 98.0%; the seventh, Fish an Anime RNG, 95.0%) [PC]. Two fishing games place in top revisited: Heavyweight Fishing, the only smaller one there (#32 computer / #8 phone), and Fisch (#28 / #37) ([PC], [PH]). (corrected by scout, T-0005, per gate PITCH-01)

The chart tool cannot measure the phase from one snapshot. It needs at least 36 hours of history and prints "unknown (needs 36h+ of data)" [GEN] (the threshold is in `charts/chartlib/analysis.py`). A second snapshot after 2026-10-25 19:24 UTC gives the first measured 24-hour change and visits per day for each comparable. A snapshot at or after 2026-10-26 07:25 UTC (36 hours after the first) also gives the tool's phase estimate. That estimate covers Simulation as a whole. The phase for fishing alone comes from the growth of the nine fishing games in the same report.

**Read: late for a fast follow, on time for a genre entry.** A 6-10 week build is the scan's estimate; the Engineer has not sized it yet. Counted from today, it would ship between 2026-12-05 and 2027-01-02, in the winter-holiday season (December in the studio's seasonal calendar). That calendar calls the winter holidays "the yearly peak for many games", a rule of thumb whose dated example is Brookhaven's record of about 1.3M in December 2025 (StudioKrew; `vault/12-live-ops-and-launch/seasonal-calendar.md`, December row, note dated 2026-10-24). One leader runs seasonal events now: Fisch's title in [PC] carries a ghost emoji and the tag "[HORSEMAN]", and Fisch had an event peak of about 510K on 2026-10-17 [RW]. Whether Fisch or Fish It! will run winter events is unknown; Fish It!'s title tag in [PC], "[6 HRS]", names no event. (corrected by scout, T-0005, per gate PITCH-01) A prototype first pushes those dates later. Being early buys nothing here, and the 2026 fishing entrants top out at about 12K players [PC]. We win only by being **different** (the twist) and **better** (a phone-first feel and a new front every week). If the twist reads as decoration, this is a third fishing game behind two leaders.

## Portfolio check (PITCH-06)

`python3 agents/studioctl.py game list`, run 2026-10-24 19:46:59 UTC:

```text
stormcatch               pitch      active   Stormcatch (working title)
```

`stormcatch` (now titled Reel the Storm [D3]) is the studio's only game, and the studio has not shipped any game yet, so it duplicates nothing. The studio has recorded no house patterns, so there are none to follow or depart from. The game builds on the studio's game template (`template/`), which is a generic simulator base, not a shipped game.

## Audience, rating and IP (PITCH-07)

- **Audience tier (draft):** Roblox Kids and Select, phone first. The designer's draft core audience is ages 7-13 [SK 8]. The comparables' age split is not public, so it is unknown. All nine fishing comparables and the three weather comparables are "minimal" with minimum age 0 [PC].
- **Launch reach:** a new public game reaches only age-checked users aged 16 and over until it passes the under-16 evaluation. The evaluation needs 250 unique plays from engaged age-checked users within 60 days, plus a safety review (`vault/17-policy-and-business/age-ratings-and-audience.md`). The cozy loop therefore has to hold older players in the first weeks. Depth (weather skill, size records) matters for that, not only cute visuals.
- **Content rating expectation: Minimal, adopted by the human [D5].** The game as designed has no violence, blood, fear, crude humour, romance, alcohol, strong language, free-form creation or AI interaction. On fear: storms never hurt, there are no jump scares, and lightning flashes can be turned off [SK 8]. The human fills in the Maturity & Compliance Questionnaire in Creator Hub before release (gate criterion RC-03). Agents only draft.
- **Paid random items: decided [D2].** Companion nests count as paid random items when coins can be bought with Robux, and the questionnaire answer is "yes". Nests show their odds, and the game respects `ArePaidRandomItemsRestricted` through PolicyService. The template already does both (`games/stormcatch/project/src/server/Services/Policy.luau` and the hatch odds panel [SK 7]).
- **Paid weather summon [D6]:** a paid, server-wide change to luck or odds. How it is disclosed, and whether it changes the questionnaire answers, is open (question 2).
- **IP risks** (scan "IP risks seen in the space"; [SK 8]):
  1. Title convergence: fishing titles cluster on "Fish ___", "___ Fishing", "Catch a ___" and puns, and discovery demotes look-alike metadata. "Reel the Storm" avoids those patterns.
  2. The title "Reel the Storm" [D3] has had no trademark search, by the human's choice; the human accepts that risk. The scout checked our chart data for look-alikes, which is not a trademark search. No name across both snapshots (1,121 unique games) matches. Three names contain "Storm", and the closest is "Ride Storm" (universe 4420562665, Simulation, 9,546 players [PH]); see question 1.
  3. Competitors' named weather tools, items, events, UI and art belong to them. The general mechanics, including summoning weather, are free to use. Every name in the sketch is invented, and the summon product must get an original name and look.
  4. No anime, meme or franchise characters, and no real tackle or outdoor brands.
  5. The weather is fictional and runs on a schedule. No real-world weather data or player location is used, so no data-licensing or privacy question arises.
  6. Music and sound must be original or licensed, and recorded in the asset index.

## Build estimate and reuse

- **Prototype:** the vault's prototype gate says "days, not weeks", and the Engineer sizes it. The scope is the moment loop with juice, Showers and Sea Fog fronts moving across 3 spots, one rod upgrade line, one Great Storm with the co-op pull, and placeholder art [SK 10]. It has no paid products. Most of the work is cut-down versions of the two new large systems, Fishing and Weather.
- **Launch content** [SK 6]: 4 islands, 4 weathers plus the Rainbow and the Great Storm, 48 species, 6 marks, 12 companions, 12 journal sets and 4 upgrade lines. Systems: an on-screen forecast dial, a daily almanac, Tide Pots, rebirth, a daily calendar, codes and the shop. The Robux weather summon [D6] adds summoned fronts to the Weather system and one product to the catalog. The 6-10 week estimate comes from the scan, predates D6, and has not been confirmed by the Director and Engineer.
- **Reuse** [SK 7]: these template systems need only a reskin or config: Upgrades, Zones and gates, Pets and Eggs (companions and nests), Rebirth, Rewards, Codes, Purchases (idempotent `ProcessReceipt`), Social, Onboarding, Analytics and QA. New work: 2 large systems (Fishing, Weather) and 4 medium ones (weather reel modes, the storm co-op pull, the Sky Journal, Tide Pots).

## Risks

1. **The twist reads as decoration**, turning the game into "Fisch with moving clouds". Mitigation: make each weather's action clearly different and teach the first one at minute 2. In the prototype, run two twist tests [SK 10, 11]:
   - Test A passes if 4 of 5 testers describe two weathers by what their hands did.
   - Test B passes if 45% or more of catches happen under fronts, which cover about 25% of the water. Under 30% means players ignore the weather.
2. **Late entry into a genre two leaders control** (83.5% share [PC]). Mitigation: a phone-first feel, the twist, a new front every week, and a thumbnail that sells the storm. If the twist fails, stop rather than ship a third generic fishing game.
3. **Phone problems:** weather effects may be too costly on low-end devices, and the reel modes may be fiddly on touch. Mitigation: full detail only for the nearest front, lighting and `Atmosphere` instead of particles, generous timing windows, misses that cost nothing, and gusts left optional. Test on a low-end Android phone in the first prototype week [SK 11].
4. **A paid weather can read as pay-to-win or break the shared forecast** [D6]. Mitigation, from D6's constraints:
   - The benefit is shared with every player in the server, never only the buyer.
   - The summoned front is visible to everyone on the Sky Dial.
   - The Great Storm schedule never moves.
   - The purchase is granted only in `ProcessReceipt`.
   - The design stage still has to make it fair in feel; see the open interactions under PITCH-04.

Other risks (cozy pace against chasing fronts, value inflation from marks, time zones) are in sketch section 11.

## Rubric score (PITCH-08)

The scores use the rubric in `vault/15-market-research/pitch-and-greenlight.md`. The design is scored as written against each line's 0 and 3 descriptions, and a point comes off only for a named gap. "Untested" counts once, on the core loop line, because that line's description asks for proof. **Re-scored after the human's decisions D2 to D6** (2026-10-24): six justifications changed, and no score changed.

| Criterion | Weight | Score 0-3 | Points | Justification |
|---|---|---|---|---|
| Core loop clarity and fun | 3 | 2 | 6 | Strong comparables prove the cast-reel-reveal loop (Fisch 107,205 and Fish It! 76,378 players [PC]). The twist that makes this game worth building has no prototype yet. |
| First-session strength | 2 | 2 | 4 | The design puts the first input by 10 s, the first catch at 15-20 s, the bridge goal at 10-12 min and a storm within 15 min [SK 5]. Re-scored for D3: **the title gap is closed**, because "Reel the Storm" starts with a verb and names the twist. It stays at 2 because the first catch lands after the rubric's 10 s mark, and the weather reel modes are the part most likely to confuse a young player on a phone. |
| Return and endgame potential | 2 | 2 | 4 | Strong reasons to come back (Tide Pots, Fish of the Day, the calendar, sets that need one weather) and a clear update unit: a new front every Saturday and a new island every 3-4 weeks. Gaps: there is **no consequence layer**, the risk of loss to other players that 2025-2026 hits use to bring players back to protect what they have (`vault/21-hits-and-trends/anatomy-of-a-hit.md`, ingredient 3). There is also no trading at launch. |
| Social and clip potential | 2 | 2 | 4 | The strongest line on paper: strangers help land storm giants and earn rewards for it, and the clip moment reads with the sound off. The D6 summon benefits everyone in the server, so it is a social purchase, not a private boost. Gaps: **no external funnel plan** (creators, social media, crossovers) to carry clips outside the game (hit sheet row 8: 1/2), and no consequence stories to share. |
| Market evidence | 2 | 2 | 4 | Same-day evidence across several games shows steady demand for fishing (9 games, 219,733 players [PC]; a stable leader [RW]). Gaps: one snapshot per device, so there is no measured growth, risers or phase. The evidence shows demand for fishing, not for this twist. |
| Differentiation | 2 | 2 | 4 | A clear twist that changes the action and the social structure, checked against the scan's "not found" column. Device fit is not claimed as a difference: the [PC]/[PH] ranks split by game rather than lean to computer, so phone first is a design choice (see "Genre and audience", Devices) (corrected by scout, T-0005, per gate PITCH-01). Gaps: that column comes from public guides, not from playing the comparables, so the claim that the twist is unique is unverified. D6 adds a paid summon, which is already standard and narrows the difference from Fish It!. The four parts of the twist still stand, so the score holds. |
| Timing | 1 | 1 | 1 | **Late entry into a two-leader genre**: the leaders hold 83.5%, and 2026 entrants top out at 12,352 players [PC]. Not 0, because fishing has become an evergreen genre with stable demand, not a fading wave. |
| Monetization fit | 1 | 2 | 2 | D6 adds a shared, server-wide weather purchase like ones the genre already sells: Fish It! sells one for coins [GUIDES], and the grow-and-farm playbook calls server-wide weather triggers "a social purchase players love" (`vault/14-genre-playbooks/grow-and-farm.md`). It sits alongside an auto-reel pass weaker than active play, capacity, cosmetics and disclosed luck. Paid random items are decided [D2]. Gaps: no catalog or price tiers yet, and how the paid server-wide odds change is disclosed is open. |
| Feasibility for our team | 2 | 2 | 4 | Most systems are template reskins [SK 7]. Gaps: 2 large and 4 medium new systems, plus summoned fronts in the Weather system [D6]. Weather effects must run on low-end phones. The team has never kept a weekly update rhythm and has shipped no game that shows how fast it works. |
| Policy and IP safety | 1 | 2 | 2 | Expected Minimal [D5], all names invented, no real-world data. Paid random items are decided and handled (odds shown, PolicyService gating [D2]). Gaps: **no trademark search on "Reel the Storm"** (the human accepted the risk [D3], but the risk remains), a same-genre charting title "Ride Storm" [PH], and an open disclosure question for the paid weather [D6]. |
| **Total (max 54)** | | | **35** | **Band 30-39: refine the pitch** (usually the twist or the evidence). |

**Cross-check with the hit sheet** (sketch section 9). As written it scores 17/20. Its row 1 says a verb-first title such as "Reel the Storm" would score 2, so with D3 it reads 18/20; the sketch has not been updated. The two scores answer different questions. The hit sheet measures how closely the design matches recent hits, and it rates this design highly. The greenlight rubric weighs proof, timing and feasibility, so the same pitch scores 90% on the hit sheet and 65% here. The two remaining weak hit-sheet rows (consequence layer, external funnel) are the same gaps named above.

**What can still move the score.** Work on paper can add about 4 points, to about 39, which is still under 40:

- +2 on market evidence, if a measured second snapshot shows fishing holding steady.
- +2 on social and clip, from an external funnel plan.

The policy and IP line would need a trademark search, which the human declined [D3], and an answer to the disclosure question. The core loop, differentiation and first-session lines carry 7 of the rubric's 18 weight units. Only a prototype can move them.

## Recommendation and options

**Scout recommendation: approve with changes.** The total falls in the "refine" band, and paper work alone tops out at about 39. The biggest gap is one no document can close: whether players really fish differently in each weather. A prototype answers that in days for some engineering time, and the fixes to the evidence can run alongside it. You told the Director you intend to approve [D1]. That did not change this recommendation or the score. The gate runs on evidence, and you record the approval yourself after it.

The changes:

1. Approve a **prototype only** (scope in sketch section 10) with a written go/stop rule. Continue only if twist tests A and B and the 30-second test pass (5 of 5 testers land a fish within 30 s). Pivot or stop if fewer than 30% of catches happen under fronts.
2. Keep paid products out of the prototype, as its scope already does. Twist test B then measures whether players follow the natural fronts, not bought ones.
3. The scout takes a second snapshot at or after 2026-10-26 07:25 UTC, then re-scores market evidence and timing before the prototype verdict.
4. An external funnel plan is added at the design stage. The absence of a consequence layer stays as an argued omission and is reviewed with prototype data.

| Option | What happens | Trade-off |
|---|---|---|
| **A. Approve with changes (recommended)** | The prototype starts, the evidence fixes run beside it, and the twist tests decide go or stop. | It spends engineering days on an unproven twist in a genre we are late to. In return, the top risk is answered by play rather than argument, and most systems are reused. |
| **B. Refine first, then decide** | Second snapshot and an external funnel plan; re-score in about a week. | This is the literal reading of the 30-39 band. Evidence improves, but the score rises by about 4 points at most, to about 39, still under 40. The core loop line (weight 3) and differentiation cannot move without play. Each week of delay pushes the ship window further into or past the winter holidays, which the seasonal calendar calls "the yearly peak for many games" (December row: Brookhaven's record of about 1.3M in December 2025, StudioKrew; see "Urgency") (corrected by scout, T-0005, per gate PITCH-01). |
| **C. Reject (park) and look for an earlier trend** | Keep tracking fishing while the scout looks for formats in the spark or rise phase. | It avoids a late entry into a genre where 2026 entrants top out at about 12K players [PC]. But the studio has no other pitch ready, so the studio has nothing to build until a new scan and sketch exist, and the designed loop goes unused. |

The decision is yours. Passing the pitch gate means only that the pitch meets the written criteria.

## Questions for the human

Your answers of 2026-10-24 (D2 to D6) closed the earlier questions on maturity, paid random items, the title and selling weather. These questions remain open. Each carries the studio's recommendation where it has one. The scout has not escalated any of them; the Director handles escalation.

1. **Title look-alike (new).** "Ride Storm" is a Simulation game on the phone charts: universe 4420562665, 9,546 players, created 2023-02-24 [PH]. Discovery demotes games whose metadata closely resembles others. Does that change your title choice? Nobody has researched what that game plays like. Studio recommendation: keep "Reel the Storm", which has a different verb and a fishing tile. The Artist should look at that game's store page before icon and thumbnail work, so ours does not resemble it.
2. **Disclosure of the paid weather (open item from D6, policy).** How is a paid, server-wide change to odds or luck disclosed to players, and does it change the questionnaire answers? The Monetization Designer drafts this at the design stage, and the answer is yours. The studio has no recommendation yet.
3. **Later, at launch planning (money and policy).** To reach players under 16, the game needs four things: a verified owner with 2-step verification, the full questionnaire, a publishing fee or subscription, and a passed evaluation. An expedited review costs a refundable fee (`vault/17-policy-and-business/age-ratings-and-audience.md`). Studio recommendation: no action now. The Director brings this to you at launch planning.

## Sources

- Market scan: `games/stormcatch/docs/market-scan.md` (T-0001, 2026-10-24). Its third-party sources and verification labels apply to every comparable mechanic quoted here.
- Loop sketch: `games/stormcatch/docs/loop-sketch.md` (T-0002, 2026-10-24).
- Human decisions: `games/stormcatch/docs/decisions.md` (D1 to D6, 2026-10-24, written by the Director from the human's chat replies).
- Chart evidence (committed copies): `games/stormcatch/docs/evidence/charts-2026-10-24/`. It holds [PC], [PH], the reports `2026-10-24-computer-all.md` and `2026-10-24-high_end_phone-all.md`, both genres outputs and both evidence blocks. The title look-alike check read game names from [PC] and [PH] only; it called no endpoint.
- Chart tool phase threshold: `charts/chartlib/analysis.py` (`phase_for`, `genre_stats`: at least 36 h of history).
- Portfolio: `python3 agents/studioctl.py game list`, 2026-10-24 19:46:59 UTC.
- Vault (all 2026-10-24): `15-market-research/pitch-and-greenlight.md`, `18-templates-and-checklists/pitch-template.md`, `15-market-research/trend-lifecycle.md`, `15-market-research/reading-the-charts.md`, `11-store-page-and-discovery/discovery-algorithm.md`, `00-start-here/roblox-platform-2026.md`, `12-live-ops-and-launch/seasonal-calendar.md` (added by scout, T-0005, per gate PITCH-01), `14-genre-playbooks/fishing-and-collection.md`, `14-genre-playbooks/grow-and-farm.md`, `21-hits-and-trends/anatomy-of-a-hit.md`, `17-policy-and-business/ip-and-licensing.md`, `17-policy-and-business/age-ratings-and-audience.md`, `09-monetization/monetization-compliance.md`.
