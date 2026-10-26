---
title: "GDD: Reel the Storm (id stormcatch)"
date: 2026-10-25
version: 2
status: in review
author: designer (tasks T-0007 and T-0013)
---

# Reel the Storm: game design document

Tasks T-0007 (v1) and T-0013 (v2 sync) · Designer · 2026-10-25 · Stage: design · Outcome served: **stay** (each weather is a different way to fish, so players keep fishing and follow the fronts). Systems also serve **return** (Tide Pots, Almanac, calendar), **click** (clip moments, external funnel) and **spend** (the Sky Bell, D6).

**Changelog**

| Version | Date | Task | Changes |
|---|---|---|---|
| 2 | 2026-10-25 | T-0013 | Synced with the accepted `economy-sheet.md` (T-0008) and `world-plan.md` (T-0011). (1) Every number that waited for the economy sheet now gives the sheet's value and section; the full list (old, new, source) is in `handoffs/T-0013.md`. (2) Adopted the sheet's changes: Tide Pots pay 0.5 min of income per pot-hour and hold 8 fish (§4.8); Stormborn hook 4.0% per eye bite with a hard pity at 60 eye bites, helper share 10% (§4.3); eye catches and Stormborn pay at the best island multiplier, Stormborn at half their tier value (§4.3); the Sky Bell's shared bonus is +25% Sky luck (§4.10); the luck stacking rule and caps (§4.6); Thunderhead needs no New Tide, and New Tide needs all four islands (§4.5, §4.7); prototype values 5/10/20/50, Rumblefin 250, Hushgill Rare (§13, brief). (3) Storm fishing (faster bites, Charged flash taps, best-island value) now applies at the eye only; the rest of the map rains lightly and fishes as Clear, as the economy model assumes (§4.2, §4.3). (4) Adopted the world plan's changes: the ferry stops at the harbour, Thunderhead Point and Lantern Reef only, and the 60 s reach holds on foot (§4.5); the Dock Ripple is 10 studs ahead and 5 left of spawn, near edge about 6 studs (§3.1); rock pools moved to Pebble Point (§4.1); spot attributes `CellId` and `CastPoint`, tags `WeatherCell`, `StormHome`, `FogLantern` and `SkyBell` (§4.1, §9.4); tap-to-walk goes to the spot's `CastPoint`. (5) First-frame shower decided: the prototype timetable stays (§3.1). (6) Open questions updated (§12). |
| 1 | 2026-10-25 | T-0007 | First version, written before the economy sheet and the world plan existed. |

**This GDD supersedes the loop sketch** (`games/stormcatch/docs/loop-sketch.md`, T-0002). Everything in the sketch that still holds is carried into this document, and this document wins where the two differ. The sketch stays unedited as the pitch-stage record. Appendix A lists every sketch statement this GDD supersedes and why.

**Binding inputs.** The human's decisions D1-D6 (`games/stormcatch/docs/decisions.md`), the approved pitch (`games/stormcatch/docs/pitch.md`, approved 2026-10-24: "Prototype only; go/stop on the twist tests"), the market scan (`games/stormcatch/docs/market-scan.md`) and the template (`template/README.md`; the game's copy is `games/stormcatch/project/`).

**Labels used for numbers.**

| Label | Meaning |
|---|---|
| *Target (source)* | A design target and the vault note or comparable it comes from. |
| *First-pass estimate* | A number nobody has modelled yet. The prototype or the Economist replaces it. |
| *Economy sheet §n* | The Economist's value, copied from `games/stormcatch/docs/economy-sheet.md` (T-0008, accepted 2026-10-25), section n; letters such as "output D" point into `models/economy_model_output.txt`. If this GDD and the sheet ever differ on a number, the sheet wins and this GDD is corrected. |
| *World plan §n* | The Worldbuilder's measured value from `games/stormcatch/docs/world-plan.md` (T-0011, accepted 2026-10-25), section n, computed by `models/world_layout.py`. |
| *Catalog (T-0009)* | The Monetization Designer owns this (prices, products, offer copy). |
| *Design value* | A feel or rule number the Designer owns (ring speeds, front timing, pull time, Sky Bell slots). Each one is tuned in the prototype. |

**Reading path (about 20 minutes per role).** Everyone: §1, §2 and §13.4. Engineer (prototype): §13 and `specs/prototype.md`. Economist: §2.2, §4.1-§4.3, §4.10 effect and §5. Monetization Designer: §4.10 and §6. Worldbuilder: §4.1 spot attributes, §4.10 "Where" and §13.2. Gatekeeper: the criterion map below, then each listed section. Human: §4.10 and §12 (questions O-H1 to O-H4).

## Criterion map

| Criterion | Where it is answered | Status |
|---|---|---|
| DESIGN-01 (loops, seven loop tests) | §2 Loops; §2.4 the seven loop tests plus twist tests A and B with pass targets | In this GDD |
| DESIGN-02 (first-session timeline, targets per phase) | §3.1 timeline (0-60 s, minutes 1-10, bridge at 10-15 min, first Great Storm, minutes 10-30); §3.3 onboarding steps mapped to `project/src/shared/Config/Onboarding.luau` | In this GDD |
| DESIGN-05 (return systems) | §4.8: daily calendar, streak with a weekly freeze, Almanac daily tasks, Tide Pots (next-day timer), playtime gifts, notifications, welcome back | In this GDD |
| DESIGN-06 (social reason) | §4.9: Great Storm co-op pull, friend bonus, invites, referrals, presence, records; argued omissions of trading and a consequence layer | In this GDD |
| DESIGN-09 (executable build brief, open questions) | §13 prototype scope and go/stop rule; full build brief at `games/stormcatch/docs/specs/prototype.md`; §12 open questions | In this GDD |
| DESIGN-10 (reuse by id) | §9.4 reuse map by template file path, new systems sized S/M/L | In this GDD |
| DESIGN-03, DESIGN-04 (economy, drop tables) | `economy-sheet.md` (T-0008). §5 lists the targets and the sheet's results against them; §4 quotes the sheet's values with their sections | Economist |
| DESIGN-07 (catalog) | `catalog.md` (T-0009). §6 gives the design direction and the Sky Bell rules the catalog must keep | Monetization Designer |
| DESIGN-08 (art direction) | `art-direction.md` (T-0010). §7 lists what design needs from it | Artist |
| D6 paid weather summon | §4.10 Sky Bell: inside all four D6 constraints; the Sky Bell decision is argued there | In this GDD |
| D3 title | "Reel the Storm" throughout; game id `stormcatch`. No open trademark item | In this GDD |
| External funnel plan (pitch rubric gap) | §11.3: clip moments, share and invite points, share links and codes per channel, creator plan draft that spends nothing | In this GDD |

---

## 1. Summary

**One-liner:** You **tap to cast and reel, fishing a different way in each weather that drifts past** (quick in rain, by feel in fog, riding the wind in gusts, pulling together in the storm), to get **fish only that weather brings** (coins and new Sky Journal pages), so you can **buy a better rod and boots, fix the bridge to the next island and be at the pier when the Great Storm hits**.

| Item | Decision |
|---|---|
| Store title | **Reel the Storm** (D3). Game id `stormcatch`. |
| Genre | Simulation (fishing and collection). The playbook is `vault/14-genre-playbooks/fishing-and-collection.md`. |
| Target tier and label | Roblox Kids and Select reachable. Expected label **Minimal** (D5). No violence, fear, hazards or jump scares; storms never hurt. The human answers the questionnaire. |
| Players | Core age 7-13 on phones (design choice, `vault/00-start-here/roblox-platform-2026.md`). Older "chill progression" players in the first weeks of the 16+ launch window (`vault/17-policy-and-business/age-ratings-and-audience.md`). |
| Devices | Phone first: one thumb button, 56 px or larger touch targets (template `UI/Root`), and a weather signal that is always visual first. |
| Server size | **12** (first-pass estimate; playtest 8 against 12). A Great Storm needs 4-8 players at the pier (§4.9). |
| Session family | Persistent and active, not AFK-idle. A peak every 15 minutes (the Great Storm). Target average session 15-30 min (`vault/02-core-loop/session-structure.md`, fishing row). |

**Pillars** (each system below names the pillar it serves):

1. **Every weather is a different way to fish.** What your hands and eyes do changes with the weather, not only the fish table. This is the twist (pitch PITCH-04).
2. **Read the sky, choose where to go.** Fronts drift between islands on a forecast that is true for everyone, so the decision every minute is where to fish.
3. **Storms bring us together.** The best moment of each quarter hour is a crowd pulling in a giant, with strangers welcome. Storms are a treat, never a threat.

**Cozy rules** (carried over from sketch §3 and still binding; each one is observable in a playtest):

| Cozy promise | Observable rule |
|---|---|
| Unhurried pace | Every natural front is on the Sky Dial at least 60 s before it reaches a spot, and stays 90-120 s per spot (design value). Adjacent spots are at most 15 s apart at base walk speed (16 studs/s, template `Characters`). A missed front costs nothing, and another arrives within minutes. |
| No harsh fail states | A failed reel costs 0 coins and 0 items, and Cast is available again within 1 s. There is no death, damage, hunger, stamina, energy, durability or fish loss. |
| Nothing taken by others | No PvP and no stealing. Spots are never exclusive: any number of players fish the same ripple without lowering each other's catch. |
| Storms are a treat | No weather can hurt, push, slow or cost a player anything. |
| Calm audio and visuals | Storm audio swells over 3 s or more. Thunder is a low rumble. Lightning flashes are short, soft and switched off by the template's reduce-motion setting (a sound and icon cue remains). Fog and night never hide the water. |
| Social warmth | Helping someone land a giant pays the helper. Banners celebrate and never shame. |
| Honest time | Every countdown (front ETA, Great Storm, Almanac day, Tide Pot fill, Sky Bell arrival) shows the real schedule. It never restarts, and nothing sells skipping it (`vault/09-monetization/monetization-compliance.md` §3). |

---

## 2. Loops (DESIGN-01)

```
Moment loop:  tap Cast (the weather shapes the cast) -> bobber lands, short wait -> bite signal (depends on weather)
              -> reel on the ring, the way this weather demands -> fish leaps out: name, kg, rarity colour, weather mark
              -> coins fly to the counter; NEW! if first of its species
              (one catch every 7.5 s in Clear, inside the 6-10 s target; economy sheet §3.2)
Session loop: coins -> Rod (catch value), Lure (luck), Boots (walk speed, reach fronts first), companion nests
              -> bigger and rarer fish, faster to the next front -> fix the bridge to the next island
              -> be at the Open Pier when the Great Storm hits (every 15 min)
              (gap between upgrades 30 s - 2 min in the first session; target, vault/02-core-loop/core-loop-design.md)
Long loop:    Sky Journal sets (island x weather), Stormborn giants and Witnessed stamps, New Tide (rebirth),
              daily Almanac tasks and Fish of the Day, Tide Pots set under tonight's forecast, a new front every Saturday
One sentence: You tap to cast and reel, fishing a different way in each passing weather, to get fish only that
              weather brings, so you can upgrade, open islands and be at the pier for the Great Storm.
Friend reason: the weather is shared and forecast for everyone, and Stormborn giants land several times faster
              when the players nearby pull together; every helper, stranger or friend, is paid and stamped.
```

### 2.1 Moment loop: cast, bite, reel, reveal

The full rules are in §4.1. The weather changes three things in the player's hands: **the bite signal**, **the ring** and **the reveal**.

| Weather | Bite signal (what you watch) | Ring (how you reel) | Reveal | Why it feels different |
|---|---|---|---|---|
| Clear | "!" over the bobber and a splash | Marker goes round in 1.6 s; green arc 90° | Normal card | Baseline |
| **Showers: quick fishing** | A big splash and "!" (raindrops hide small ripples). Bites come about twice as fast | Marker faster (1.1 s) but green arc much wider (150°); fewer taps per fish | Normal card | Many quick, forgiving catches |
| **Sea Fog: fishing by feel** | No "!" at all. The bobber **dips under** (big and clear), with a low chime and a phone vibration where supported. You tap within 3 s of the dip to hook the fish | The ring appears only after you hook, and it is faint (40% opacity); the marker stays bright. One extra miss allowed | A silhouette grows with each good tap; the species, kg and mark stay hidden until the fish lands (mystery catch) | You watch the water, not the UI |
| **Gusts: riding the wind** (launch, not prototype) | "!" plus a wind arrow. A cast made when the arrow points from you toward a far ripple flies about twice as far and reaches far water; the line visibly bows | The green arc sways ±40° around the ring with the gust (3 s period) | Sizes x1.25; Breezy mark on 20% of catches, x1.5 (economy sheet §3.2, §9.4) | The skill weather; players choose to go there |
| **Great Storm: pulling together** (every 15 min, at the eye over the Open Pier) | The line hums and glows before a strike | Normal ring. Lightning flashes keep a slow beat (every 6-9 s, a 0.5 s glow warns of each one). At the eye, a landing tap inside a flash makes a regular catch **Charged**. Stormborn giants need a crowd (§4.3). Away from the eye the storm is light rain and spots fish as Clear (§4.2 rule 4) | Charged stamp, a bolt on the line | Timing your last tap with the sky; pulling together |
| Rainbow (after Showers, 60 s) | As Clear | As Clear | Catches pay x2; Prism mark on 5%, x5 (economy sheet §3.2, §9.4) | A friendly race to the rainbow |
| Aurora Night (weekly) | As Clear | As Clear | Auroral mark on 10%, x3 (economy sheet §9.4) | Appointment to return |

All ring numbers are design values to tune in the prototype. On touch every window stays generous (`fishing-and-collection.md`: "generous timing windows on mobile"), every signal is visual first, and a miss costs nothing.

### 2.2 Session loop

| Step | What the player does | Target (source) |
|---|---|---|
| Earn | Fish under whatever weather is near; chase fronts that pay better | Being under a front must pay more per minute than Clear water: Showers about 1.5-2x the coins per minute of Clear, Sea Fog about 1.2-1.5x with more rares (design target; without it, twist test B cannot pass). **Sheet result:** Showers 1.76-2.00x and Sea Fog 1.34-1.49x on every island; prototype harbour 1.92-1.97x and 1.32x; Rare-or-better per catch at Lantern Reef 12.0% in Clear, 32.0% in Sea Fog (economy sheet §3.3) |
| Upgrade | Rod (value), Lure (luck), Boots (speed), Pal Pouch (companion capacity) | Gap between meaningful upgrades 30 s - 2 min in the first session, widening slowly (`core-loop-design.md`); two or three paths offered by minute 4-6. Sheet: Lure and Boots shown at 4:00, second line bought at 4.2 min; worst gap between Rod buys in the prototype's first 10 min 1.83 min casual, 2.07 typical (economy sheet §1, §14) |
| Collect | Companion nests (one per island, odds shown), Sky Journal pages | First collection system at minute 5-20 (`vault/04-progression-and-economy/progression-architecture.md`). Sheet: the Driftwood Nest at 5.0 min (economy sheet §1) |
| Unlock | Fix the bridge to the next island | Bridge 1 at 10-12 min for a casual free player, bridge 2 at 20-30 min (`first-session-blueprint.md`, `progression-architecture.md`). Sheet: Lantern Reef (620 coins) at 10.8 min, Gustwhistle Bluffs (19,000) at 23.6 min (economy sheet §1, §5) |
| Peak | The Great Storm at :00, :15, :30, :45 UTC | One peak per 10-20 min (`session-structure.md`) |

Progression axes active in the first session: power (Rod, Lure, Boots), access (bridges) and collection (journal, companions). That is the house maximum of three (`progression-architecture.md`). New Tide (prestige) arrives after the first session.

### 2.3 Long loop

| Goal | Why it lasts | Return reason |
|---|---|---|
| Sky Journal: 12 sets (4 islands, 3 weathers, Stormborn, Witnessed, Rainbow, Aurora, Records) | Weather sets hold species that bite only in one weather, so a set nags you toward a front ("Fog set 2/3: the last one bites only in Sea Fog"). Each island set is locked by its rarest member. Every completed set adds +5% coins and a title (economy sheet §9.2) | Tomorrow's forecast shows when that weather comes |
| Stormborn giants and Witnessed stamps | Four giants, each landed or witnessed, with Charged versions | Every 15 minutes, all day |
| New Tide (rebirth) | Resets coins, Rod and Boots for +50% coins per tide (at most 30 tides); keeps islands, journal, companions, Lure and Pal Pouch. Opens once all four islands are open (economy sheet §7) | The reset curve; the first inside the template's 20-90 min band: casual 62.2 min, typical 44.2 (economy sheet §1) |
| Almanac | 3 daily tasks and the Fish of the Day (§4.8) | New page every UTC day |
| Tide Pots | Set where tonight's forecast promises the weather you need | Full by morning: 8 fish at the 8 h cap (economy sheet §12.3) |
| Saturday fronts | A new weather or weekly front every Saturday (§4.11) | Weekly heartbeat |

### 2.4 The seven loop tests and the two twist tests (DESIGN-01, feeds PROTO-02)

All are **untested** until the prototype (§13). Each test names who runs it and what passes. The prototype playtest protocol is in §13.3.

| # | Test (`core-loop-design.md`) | How it is tested in the prototype | Pass target |
|---|---|---|---|
| 1 | 30-second test | 5 newcomer testers on a phone-size screen, fresh profiles, no help. Time from spawn to first landed fish, from the server catch log | 5 of 5 land a fish within 30 s (PROTO-03; design target 15-20 s) |
| 2 | 100th-time test | Each newcomer plays 20 min (about 100+ casts). At the end: "How fun was it in the last 5 minutes?" on a 1-5 smiley scale, then "You can stop now" | Median rating 4 or higher, and 3 of 5 keep playing 2+ minutes after being told they can stop |
| 3 | Upgrade-feel test | After the first Rod upgrade, ask "Did anything change?" without showing numbers | 4 of 5 name a visible change (longer rod, bigger fish, more coins) |
| 4 | Friend test | 3 or more testers in one server across one Great Storm. Server log of Stormborn landing times; observer notes where testers stand | Group landings at least 3x faster than solo (holds by construction, §4.3: 3 helpers give 3.6x, 4 helpers 4.5x). Behaviour: 2 of 3 testers walk to the Open Pier within 60 s of storm start unprompted, and 2 of 3 say it was more fun with the others |
| 5 | "One more" test | HUD screenshot of each tester at 10:00 | Every screenshot shows a goal 1-3 minutes away (next front ETA, Rod bar, storm countdown) |
| 6 | Silent test | 10-second muted clip of a storm landing with the UI hidden, shown to 3 people with no context | 2 of 3 say some form of "it's storming and they caught a giant fish (together)". Placeholder art caveat: this checks scale, light and motion, not final art |
| 7 | One-sentence test | At 20:00, before the twist questions: "Tell a friend what this game is, in one sentence" | 3 of 5 say some form of "you fish in weather, and the weather changes how you fish" |
| A | **Twist test A (feel)** | At 20:00: "How was fishing in the rain different from fishing in the fog?" Scored only on testers who landed 3+ fish in each of Showers and Sea Fog (catch log). Two raters (Designer and QA tester) score independently; a disagreement counts as "not described". Answers about the action count ("bites came fast", "I had to watch the bobber sink", "I couldn't see the fish until it landed"); answers about looks do not ("it was grey") | 4 of 5 qualifying testers describe **both** Showers and Sea Fog by what they did. Keep adding testers until 5 qualify, and report how many did not qualify |
| B | **Twist test B (chase index)** | Server catch log: share of **line time** (seconds with a line in the water) spent under a front, from minute 5 (or onboarding step 7, whichever is later) to the end, excluding Great Storm time, pooled across all testers. Compared with the timetable's front coverage over the same window (27.8% in the prototype, §13.2) | **45% or more** of line time under fronts. **Under 30%** means players ignore the weather (go/stop rule, §13.4) |

Twist test B is refined from the pitch's "share of catches" to "share of line time". Showers doubles the bite rate, so a catch count would inflate the share for a player who never chose rain. The thresholds stay as approved (45% pass, under 30% pivot or stop); the catch share is reported alongside.

---

## 3. First session (DESIGN-02)

### 3.1 Timeline with a target per phase

| Phase (`first-session-blueprint.md`) | Time | What happens (player actions) | Target metric (source) |
|---|---|---|---|
| Load | 0-10 s | Spawns on the harbour dock under the canopy, facing north over the **Dock Ripple**, rod in hand. The ripple is 10 studs ahead and 5 studs left of the facing line, its near edge about 6 studs away, so the avatar never hides it (world plan §5). The Thunderhead storm cloud always sits on the horizon, and most of the time a front hangs over the cove beside the dock: the first frame matches the thumbnail (see "First frame" below). One pulsing **Cast** button; nothing else on the HUD | Join to first input under 10 s; step 2 (First Cast) reached by 90% or more of new players (blueprint: first action 85-95% healthy) |
| First action | 10-30 s | Taps Cast. The bobber plops; the first bite is scripted at 2 s; "Tap on green!" (4 words). One tap lands the first fish | First fish within 30 s for 5 of 5 testers (PROTO-03); design target 15-20 s (`fishing-and-collection.md`: first catch within 20-30 s). Step 3 reached by 90% or more (GDD template) |
| First reward | 15-60 s | The fish leaps out: **Pebble Minnow, 0.8 kg**, rarity colour, "+12" coins flying to a counter that pops into view, "NEW!" stamp (12 coins: economy sheet §3.1). Casts once or twice more while a "Better Rod" bar fills; the Rod is affordable from the second catch | Reward animated and audible (juice layers 1-4, `game-feel-and-juice.md`); step 4 reached by 85% or more (first-pass estimate) |
| First choice | 45 s - 3 min | The Shop button pulses when the Rod is affordable; the shop opens on the Rod with it highlighted; buys **Rod 2** (15 coins); the shop closes; the rod visibly grows and the next fish is bigger. At 4-6 min the shop offers **Lure or Boots** (a real choice; both shown at 4:00) | Rod 2 at about 60 s (blueprint: first upgrade within 1-2 actions); the sheet models 45 s for every player type, and the second line at 4.2 min (economy sheet §1, §4). Step 6 reached by 80% or more (blueprint "strong") |
| First loop | 1-5 min | The **Sky Dial** pops in: "Rain → Cove Shallows 0:40". A beam shows where the shower will land. Walks into the rain and feels fishing change (faster bites, wider green). The first catch in rain is **guaranteed** to be the **Pitterpike**, a rain-only Rare, with the **Drizzled** mark (economy sheet §3.1). The shower leaves and a **Rainbow** lands on that spot for 60 s | First weather catch at a median of 4 min or less and at most about 5 min by schedule (Pebble Cove gets Showers often enough that the longest wait for rain is about 4.3 min; §13.2 shows the prototype version). Step 7 reached by 70% or more (first-pass estimate). Seeded early rare (`fishing-and-collection.md`) |
| First goal | 5-15 min | The broken bridge to **Lantern Reef**, with its price sign, is visible from spawn (101 studs, inside the first frame; world plan §5); a "Bridge" bar toward its 620-coin price appears after the first rain catch. Opens the **Driftwood Nest** (150 coins, shown at 5:00, odds shown) and equips a companion. Places the first free **Tide Pot** (about minute 9). Fixes the bridge (minute 10-12) | Bridge at 10-12 min for a casual free player, inside 10-15 (blueprint phase 5; template pacing test: zone 2 at 8-16 min). Sheet: 10.8 min [10.3-11.1 across storm join minutes], and 14.8 min on catch income alone; first nest at 5.0 min (economy sheet §1, §5, §6, §12.3). Step 11 reached by 40% or more of new players (blueprint: 30-50% healthy) |
| First wow | within 15 min | **The first Great Storm**, guaranteed by schedule within 15 min of joining: the Sky Dial counts down from 5:00 ("Great Storm 4:12, Open Pier"), the sky darkens, music swells, everyone heads to the pier. Taps **Pull!** to help land a Stormborn and gets a Witnessed stamp; may hook one themselves | One peak per 10-20 min (`session-structure.md`); planned wow within 20 min (blueprint phase 6). StormJoined within the first 15 min for 60% or more of sessions that last 15 min (first-pass estimate) |
| Minutes 10-30 | 10-30 min | Crosses into Lantern Reef's sea fog and learns fishing by feel; opens the Reef Nest (Lamp Moth: more rares in fog). Finishes the **Pebble Cove set (8/8)** for +5% coins and the title "Cove Regular". Meets Gusts drifting from the Bluffs. Works toward the bridge to **Gustwhistle Bluffs**. A second Great Storm hits by minute 30 at the latest | Bridge 2 at 20-30 min cumulative (sources disagree: `progression-architecture.md` 15-25 min, template economy comment 30-45 min; the sheet holds 20-30). Sheet: 19,000 coins at 23.6 min; Pebble Cove set at a median of 17.2 min (economy sheet §1, §5). No gap over about 3 min without an upgrade in the first hour (`progression-architecture.md`); sheet: casual worst 2.22 min in the first 30 min, typical worst 3.47 min in 1 of 15 join minutes, "near" (economy sheet §1) |
| Return hook | before minute 10, and on leaving | Tide Pot placed where tonight's fog will pass ("Full in 7h 50m"); day 2 of the calendar previewed when day 1 is claimed at minute 5; the Almanac shows tomorrow's Fish of the Day | Return hook visible before minute 10 (blueprint). Step 10 reached by 55% or more (first-pass estimate). Median first session 12 min or more (blueprint: 8-15 healthy); D1 15% or more after launch (blueprint: 12-20% healthy) |

**First frame (decided in v2; world plan §14 question 1).** The prototype timetable (§13.2) stays as it is. From spawn, the Thunderhead storm cloud is always in view (+26.7°, inside the ±35° core cone), and both harbour front spots sit beside the Dock Ripple, never on it (world plan §5). Over a 900 s cycle, a newcomer's first frame shows a shower 44.4% of the time, sea fog 22.2%, the Great Storm 20.0%, and clear water under the storm cloud 13.3%: some weather 86.7% of the time. That is accepted, for four reasons:

1. The vault rule is that the first frame must look like the thumbnail (`first-session-blueprint.md`; `first-session-killers.md`, mismatch with the thumbnail). The thumbnail sells water, a storm and weather to fish in. The storm cloud is in every first frame and a front or the storm in about 87%, so none of the four states contradicts it.
2. More harbour Showers would weaken the go/stop test. Front coverage is twist test B's chance baseline (27.8%), and every extra 100 s of Showers on a front spot adds 4.6 points (100 of 2,160 spot-seconds). A shower in two-thirds of first frames needs about 200 s more: either coverage rises to 37.0%, leaving 8 points between chance and the 45% pass bar instead of 17, or the 200 s of Sea Fog are replaced, and twist test A needs Sea Fog.
3. Onboarding step 7's beam and the Sky Dial lead a newcomer to rain, not the first frame. The longest wait for rain stays 260 s.
4. The economy sheet's prototype numbers (§14) and the world plan's prototype paths (§12) were computed on this timetable; changing it would reopen two accepted documents.

At launch the first frame is not a schedule constraint, because the 180 s clear-harbour window for Sky Bell calls (§4.10) already limits harbour weather. The prototype checks the decision: if the Newcomer's or QA's first-frame captures read as an empty harbour, the fix is visual (a stronger storm cloud on the horizon), not more harbour Showers.

### 3.2 HUD reveal order (progressive reveal, `onboarding-patterns.md` pattern 4)

| When | Appears (pop and sound) |
|---|---|
| Spawn | Cast button only |
| First catch | Coin counter; "Better Rod" bar |
| Rod affordable | Shop button (pulsing) |
| After Rod 2 | Sky Dial strip (top centre) |
| First rain catch | Bridge bar |
| Minute 4 | Lure and Boots in the shop |
| Minute 5 | Gifts button (first playtime gift and day 1 of the calendar, with day 2 previewed) |
| First hatch | Companions button |
| Step 9 done | Tide Pot and Almanac button (pulsing) |
| Step 11 done | Almanac daily tasks open; Journal tab "Sets" |
| Step 12 done (10 min) | "Ring the Sky Bell" inside the expanded Sky Dial (never a popup, never auto-opened) |
| Lantern Reef reached | Pal Pouch in the shop; second Tide Pot slot (economy sheet §4, §12.3) |
| First New Tide possible (all four islands open, economy sheet §7) | New Tide button |

No purchase prompt appears in the first session unless the player opens it (`first-session-blueprint.md` "What to cut"; `first-session-killers.md` #10).

### 3.3 Onboarding steps mapped to `project/src/shared/Config/Onboarding.luau`

Pre-launch, so the template's list may still be replaced. **After launch, never renumber; append only.** Hints are 5 words or fewer. The server logs every step (`src/server/Systems/Onboarding.luau`, `Analytics.onboardingStep`) and checks real state before advancing.

| Step | `name` | Player action | `guide` | `hint` | Server condition | Template step it replaces | Target time |
|---|---|---|---|---|---|---|---|
| 1 | Joined | Arrives on the dock | none | "" | Profile loaded | same | 0 s |
| 2 | First Cast | Taps Cast | node | "Tap to cast" | A `Cast` accepted by `Fishing` | First Move | 10 s or less |
| 3 | First Catch | Lands a fish | node | "Tap on green!" | `stats.catches >= 1` | First Hit | 30 s or less |
| 4 | Earned Rod Coins | Catches 1-2 more | node | "Catch more fish" | `stats.totalCoinsEarned >= coinsForStep4` (= Rod tier 2 price) | Earned 15 Coins | about 40 s |
| 5 | Opened Shop | Taps the Shop button | shop | "Open the shop" | `ClientEvents.PanelOpened("shop")` | same | about 50 s |
| 6 | First Rod Upgrade | Buys Rod 2 | upgradePower | "Buy a better rod" | `upgrades.rod >= 1` | First Upgrade | about 60 s |
| 7 | Caught in Rain | Lands a fish under Showers | **weather** (new) | "Fish in the rain!" | A catch whose weather is Showers | 50 Hits | median 4 min or less; at most about 5 min |
| 8 | First Hatch | Opens a companion nest | egg | "Open a nest" | `stats.hatches >= 1` | same | 5-8 min |
| 9 | Equipped Companion | Equips the companion | pets | "Bring your pal" | `#equipped >= 1` | Equipped Pet | 5-8 min |
| 10 | Placed Tide Pot | Places the first free pot | **pot** (new) | "Set a Tide Pot" | A pot in slot 1 | Zone 2 Unlocked (moved to 11) | 10 min or less |
| 11 | Island 2 Unlocked | Fixes the bridge to Lantern Reef | gate | "Fix the bridge" | `zonesUnlocked.lantern_reef` | Played 10 Minutes (moved to 12) | 10-15 min |
| 12 | Played 10 Minutes | Keeps playing | none | "" | Play time 10 min or more | new position | 10 min |
| 13 | Joined a Great Storm | Pulls or hooks in a storm | **storm** (new) | "Help pull!" | `stats.stormsJoined >= 1` | new, appended | first storm |

Notes:
- Steps advance in order, so step 13 logs as soon as step 12 is done if the player already joined a storm. The funnel then reads "stayed 10 minutes and has joined a storm". Time to first storm is measured separately with the `StormJoined` event (§10).
- The "Help pull!" tooltip shows on any storm, whatever the funnel step.
- Config changes (size S): three new guide kinds in `StepDef.guide` (`weather`: beam to the nearest spot under Showers; `pot`: beam to the nearest unlocked spot plus a pulsing pot button; `storm`: beam to the Open Pier eye). Replace `hitsForStep7` with the weather-catch condition; keep `minutesForStep11` renamed `minutesForStep12 = 10`; `coinsForStep4 = 15`, the Rod's first price (economy sheet §4 and §14; the template's value, kept).
- The prototype uses steps 1-7 exactly as numbered here, with `lastStep = 7` (§13), so nothing is renumbered later.

### 3.4 Returning players and invited players

- Returning players with step 13 done see no onboarding. They land on the dock with the "welcome back" sequence: Tide Pot reveal, then the calendar claim, then the Almanac page (one panel at a time; each closes into the next).
- Players invited from a storm countdown carry launch data `{"spawn":"openPier"}` (§4.9). If a storm is active or due within 2 minutes, they spawn at the Open Pier; otherwise at the dock. Onboarding conditions do not depend on place, so step 2 counts a first cast at the pier.

---

## 4. Systems

Each system lists its purpose and the outcome it serves, its rules, data, server and client split, config, UI and analytics. Economy and odds numbers belong to the Economist's `economy-sheet.md`; since v2 each one is quoted here with its section, next to the design target it had to hit. World positions and distances belong to `world-plan.md` and are quoted the same way.

### 4.1 Fishing: cast, bite, reel, reveal (core action)

Serves: **stay** (pillar 1). Template base: the `Nodes` validation pattern (`src/server/Systems/Nodes.luau`), `Interact` tap-to-walk (`src/client/Controllers/Interact.luau`), `Hatch` reveal anticipation (`src/client/Controllers/Hatch.luau`).

**Spots.** Glowing ripple rings 10 studs across, registered by the template `World` system (`ResourceNode` tag, attributes `NodeId` and `ZoneId` = island id). Spots never break. There are 19: 10 regular spots (3 on Pebble Cove, 3 on Lantern Reef, 2 on Gustwhistle Bluffs, 2 on Thunderhead Point), 3 rock pools, 4 lantern ripples and 2 far-water ripples; ids, names and positions are in world plan §6.5. The attributes below are agreed with world plan §9:

| Attribute | Meaning |
|---|---|
| `SpotKind` | `regular`, `pool` (a rock pool that exists only under Showers: two on Pebble Point inside the Cove Shallows cell, moved there from the Dock Ripple cell because a sheltered cell never gets Showers, and one at Squall Rocks), `lantern` (exists only in Sea Fog: three at Lantern Reef, one at Anvil Reach), `far` (reachable only with a wind-carried cast: two at Gustwhistle Bluffs, 42.8 and 43.9 studs from their stands) |
| `CellId` | The weather cell the spot belongs to (= the `NodeId` of its regular spot). Fronts move cell to cell |
| `CastPoint` | The stand (a Vector3) where the player stands to cast; tap-to-walk goes here, never into the water |
| `StormEye` | `true` for the Open Pier (`pier_head`): the only spot with storm fishing during the Great Storm (§4.2 rule 4) |
| `Sheltered` | `true` for the **Dock Ripple** at spawn (`cove_dock`), under the harbour canopy: no front, Sky Bell call or Rainbow ever covers it, and no front path crosses its cell (the closest drift leg passes 52 studs from its centre, outside its 36-stud radius; world plan §7), so every new player's first cast is in Clear. The Great Storm still rains on it |
| `Callable` | `true` for the harbour spots a Sky Bell call covers (§4.10): `pier_head`, `cove_shallows`, `cove_pool_1` and `cove_pool_2`. Never the Dock Ripple |

**World tags the Weather system reads** (world plan §9): `WeatherCell` (one invisible part per regular spot, radius 36 studs, carrying `CellId`, `ZoneId`, `WindYaw` on Gusts cells, and the cell's `Sheltered`, `Callable` and `StormEye`), `StormHome` (the Thunderhead anvil cloud over the Thunder Spire; the Great Storm cloud rolls 154 studs from it to the eye in the last minute of each countdown), `FogLantern` (lights beside lantern ripples, switched on in fog, at most 4 near the camera) and `SkyBell` (the bell on the quay at the pier root, §4.10).

**Rules.**
1. **Cast.** The Cast button (thumb zone, 56 px or larger) casts at the nearest unlocked spot within cast range: the template's `Economy.hitRange` of 28 studs, as in the world plan's cast geometry. A wind-carried cast in Gusts reaches `far` spots up to 44 studs away. With no spot in range, the button reads "Walk to a ripple" and the guide beam points to the nearest spot; tapping a spot in the world walks the avatar to that spot's `CastPoint` (the template's `Interact` walks to `node.Position`, which for a ripple is in the water; world plan §9 rule 6). The client sends `Cast(spotId)`. The server checks that the spot exists, its island is unlocked, the distance is within range plus a latency margin, no line is out, and the cast cooldown has passed.
2. **Bite.** The server schedules the bite after a wait drawn for the weather at that spot, uniform: Clear 2.0-5.0 s, Showers 1.0-2.5 s, Sea Fog 2.8-7.0 s, Gusts 2.0-5.0 s, the storm eye 2.0-4.0 s; Rainbow and Aurora as Clear (economy sheet §3.2). The means keep the design ratios: Showers 0.5x and Sea Fog 1.4x the Clear wait. At bite time the server rolls species, size and mark for the weather **at bite time** and tells the client only what it may show: the tier (for ring steps and glow), never the species in fog.
3. **Hook (Sea Fog only).** The bobber dips; the player must tap within 3.0 s. A missed hook means the fish nibbles off silently, and a new bite comes after a fresh wait, at no cost.
4. **Reel.** A marker travels round the ring; each tap while the marker is on the green arc counts as one step. Fish need 1-3 steps by tier (table below). Misses beyond the budget, or 12 s without landing, mean the fish swims off at no cost. **The server owns the ring**: it knows the start time, speed and arc, and judges each `ReelTap` on its own clock with a latency allowance (the player's measured ping, capped at 250 ms, plus 60 ms). Taps closer than 0.15 s apart are ignored.
5. **Land and pay.** The fish leaps out (client), the server pays coins (economy sheet §3.1: 5 coins × tier value (Common 1, Uncommon 2, Rare 4, Epic 10, Legendary 30, Mythic 100, Secret 400) × island multiplier (x1, x4, x16, x64) × size factor × weather value (Rainbow x2) × mark × Fish of the Day (x3) × Rod (1.14 per level) × companions × bonus × boost × New Tide, every category capped, §5), records the catch in the Sky Journal and updates records. **There is no fish inventory and no selling step**: every catch pays at once. This keeps one currency step out of a 9-year-old's way and removes a capacity wall (design decision).
6. **First catch of a profile** is a scripted common Pebble Minnow (0.8 kg) with a bite at 2 s, one step, and no escape. It pays 12 coins (economy sheet §3.1, kept from sketch §5.1).
7. **First rain catch of a profile** is a guaranteed Pitterpike, a rain-only Rare, with the Drizzled mark (seeded early rare; economy sheet §3.1).

**Ring parameters (design values, tuned in the prototype).**

| Mode | Marker lap | Green arc | Steps by tier: Common / Uncommon / Rare / Epic+ | Miss budget | Extra |
|---|---|---|---|---|---|
| Clear | 1.6 s | 90° | 1 / 2 / 3 / 3 | 3 | "!" signal |
| Showers | 1.1 s | 150° | 1 / 1 / 2 / 2 | 3 | Big splash signal |
| Sea Fog | 1.8 s | 90°, ring at 40% opacity | 1 / 2 / 3 / 3 | 4 | Hook tap within 3.0 s of the dip; silhouette grows per step; reveal on landing |
| Gusts | 1.4 s | 80°, sways ±40° on a 3 s period | 1 / 2 / 3 / 3 | 3 | Wind-carried cast to a `far` spot when the arrow points within 45° of it |
| Great Storm (the eye only) | 1.6 s | 90° | 1 / 2 / 3 / 3 | 3 | Landing tap inside a flash window (0.8 s) = Charged (x3). Design target: a typical player lands about 1 in 4 eye catches on a flash, the 25% the economy sheet models (§8, §9.4); the prototype measures it |
| Rainbow, Aurora, and every spot but the eye during the storm | as Clear | as Clear | as Clear | 3 | |

**Feedback (juice).** Every catch gets layers 1-4 of `vault/02-core-loop/game-feel-and-juice.md` (pitched splash and reel sounds with ±10% variation; bobber and fish react; "+coins" popup flying to the counter; counter bump). Rare and up add layers 5-8 (particles, avatar cheer, a tiny optional camera shake, a soft flash that reduce-motion disables). Stormborn add layer 10 (server banner). Popups are pooled and capped.

**Data.** `stats.catches`, `stats.totalCoinsEarned` (template), journal entries (§4.6), records. **Config:** new `Config/Fishing.luau` (ring table, cast range, hook window, latency allowance, tap spacing) and `Config/Species.luau` (tables from economy sheet §9, and §14 for the prototype). **Remotes:** `Cast`, `HookTap`, `ReelTap` (client to server, rate-limited); `Bite`, `ReelState`, `CatchResult` (server to client). **Analytics:** `Cast`, `Catch`, `ReelResult` (§10).

### 4.2 Weather: fronts, schedule, Sky Dial

Serves: **stay** (pillars 1 and 2) and **return** (forecast-driven appointments).

**Rules.**
1. The archipelago is a hub and three spokes around a lagoon (world plan §1): **Pebble Cove** (start and hub, with Driftlight Harbor and the Open Pier; 3 regular spots), **Lantern Reef** (3), **Gustwhistle Bluffs** (2) and **Thunderhead Point** (2). Home weathers: Pebble Cove Showers, Lantern Reef Sea Fog, Gustwhistle Bluffs Gusts, Thunderhead Point a mix.
2. **Natural weather is deterministic from UTC time and identical in every server.** A pure module (`src/shared/Util/WeatherSchedule.luau`, unit-tested in Lune) returns, for any time t, the weather at every spot and the upcoming events. The 15-minute cycle index is `floor(unixTime / 900)`; each cycle's front routes are picked from a fixed pool by a hash of the cycle index. No cross-server messaging is needed, and Tide Pots and the Almanac read the same module for past and future times.
3. At any moment 1-3 natural **fronts** (Showers, Sea Fog, Gusts) drift along routes across the islands. Each covers one spot's area and lingers 90-120 s per spot (design value), then moves to the next spot on its route or dissipates. Together, fronts cover about a quarter of fishable spot-time (design value; it is twist test B's baseline). Every arrival is on the Sky Dial at least 60 s ahead. Pebble Cove's Showers come often enough that no player waits more than about 4.5 minutes for rain to arrive (onboarding step 7). The route pool is the world plan's paths, as ordered lists of cells (§7): Harbour Showers reef_steps > cove_shallows > pier_head > squall_rocks; Reef Fog reef_outer > reef_lagoon > reef_steps > anvil_reach; Bluff Gusts whistle_point > kite_ledge > squall_rocks > anvil_reach. No path crosses the Dock Ripple's cell.
4. **Great Storm:** every 15 minutes, clock-aligned at :00, :15, :30 and :45 UTC, lasting 3 minutes (design values; vault target one peak per 10-20 min). The storm cloud rolls in from `StormHome` over Thunderhead Point during the last minute of the countdown, then the whole map darkens and rains lightly. Its eye always sits over the **Open Pier**, the only spot with storm fishing: bites every 2.0-4.0 s, Charged flash taps, Stormborn hooks, and catches valued at the player's best island multiplier (economy sheet §3.2, §8). Every other spot keeps fishing as Clear under the light rain, as the economy model assumes, so the storm draws everyone to the pier. The storm is the same in every server, and **nothing a player buys or does moves, replaces, shortens or skips it** (D6 constraint 3).
5. **Rainbow:** when a Showers front leaves a spot and the spot turns Clear, a Rainbow lands on that spot for 60 s, visible from every island.
6. **Aurora Night:** two 30-minute windows every Saturday (first-pass: 01:00 and 17:00 UTC, so most time zones get one in the evening; open question O-D1). The whole map gets the aurora sky and the Auroral mark. Great Storms inside the window still happen on time.
7. **Sky Bell calls** (D6) add fronts in one server only; §4.10 gives the rules. They never change any of rules 2-6.

**Sky Dial (HUD).** A compact strip at top centre: the Great Storm countdown (always shown, highlighted from 5:00, with a small "Invite" button from 2:00), then the next three events ("Fog → Lantern Reef 1:10"). Each spot also carries a floating weather icon. Tapping the strip opens the expanded dial: a small map of the four islands with each spot's weather, all events in the next 5 minutes, Sky Bell calls marked with a bell icon and "this server", and "Ring the Sky Bell" (from onboarding step 12). The Storm Petrel companion extends the expanded dial 5 minutes further ahead (economy sheet §6).

**Server and client.** The server runs the schedule and tells clients only the current state and next events (`WeatherState`, small, reliable, on change). Clients render the front nearest the camera at full detail and others as sky icons, prefer `Atmosphere` and lighting tweens over particles, and follow the per-weather VFX budget in `art-direction.md` (T-0010; `vault/19-vfx/vfx-performance-budgets.md`).

**Config:** new `Config/Weather.luau` (cycle length, storm offset and duration, linger range, announce lead, route pool, Aurora windows). LiveConfig flags (template `src/server/Services/LiveConfig.luau`): `featureSkyBell`, `featureAuroraNight`. Changing the cycle through a live config would change every server at once; it stays a published config value, not a live key, so servers never disagree.

**Analytics:** `FrontEntered` (weather, spot, called). **QA** (template `QA` system): `forceWeather`, `forceStorm`, `setScheduleOffset`.

### 4.3 The Great Storm co-op pull (the social core)

Serves: **stay** and the **social reason** (pillar 3).

1. When a player hooks a **Stormborn** at the eye, a big **Pull!** button appears for every player within 40 studs of the angler (design value). No friendship or progress is needed; a brand-new player can help.
2. **The pull meter fills from the angler and the active helpers.** The angler always pulls while hooked (a new angler cannot fail) at 100/45 points per second. A helper is active if they tapped Pull! in the last 1.0 s, and each active helper adds 0.875 of the angler's rate, with at most 7 helpers counted. Landing time = 45 / (1 + 0.875 × helpers): **45 s alone, 12.4 s with 3 helpers, 10 s with 4 helpers, 7.3 s with 7** (design values; the sketch's target "45 s alone, about 10 s with four helpers", and the formula in the Economist's model `models/economy_model.py`). A helper helps the nearest active pull within range.
3. **Charged:** lightning flashes every 6-9 s (server-timed, the same for everyone at the pier), each warned by a 0.5 s glow on the line. A Stormborn lands Charged **by chance**, and each friend of the angler among the active helpers raises that chance (sketch §4.4 item 3): 25%, +5% per friend helper, capped at 50%, for x3 value (economy sheet §8, §9.4). When a Charged giant lands, a bolt strikes the taut line as it breaches: the clip moment. A tap-based rule was rejected for giants, because helpers tap at least once a second and would hit almost every flash, so nearly every group giant would be Charged and the mark would stop being rare.
4. **No fail state.** A giant hooked before the storm's 3 minutes end always lands: the eye lingers over any pull in progress (at most 45 s), and no new giant can be hooked after the storm ends. The schedule on the Sky Dial does not change.
5. **The fish belongs to the angler.** Each helper whose taps counted gets a **Witnessed** stamp for that Stormborn in their own Sky Journal and a coin share **minted on top**, never taken from the angler: **10% of the giant's value at the helper's own multipliers, for at most 3 paid helps per player per storm** (economy sheet §8), so pulling is not worth farming with alt accounts (`vault/21-hits-and-trends/viral-and-social-mechanics.md`, abuse-safe rewards). A help pays about what the helper would have caught at the eye in the same seconds; the reward for helping is the stamp and the crowd, not the coins.
6. **Banner:** "Mia and 4 anglers landed a CHARGED Rumblefin, 212 kg!" The angler's avatar holds the giant in a catch pose for 3 s, visible to all. This is clip moment C1 (§11.3).
7. **Stormborn hook rate:** with 4 or more players fishing the eye, a storm has at least 2 pulls on average, so everyone gets to help; a player who fishes the eye through every storm hooks a Stormborn at least every other storm (design target). **Sheet:** 4.0% of eye bites hook a Stormborn, at most 1 per player per storm, with a **hard pity**: after 60 eye bites without a hook, the next eye bite hooks (2.4x the expected 25). A player at the eye all storm hooks one in 55% of storms (prototype), one walking in from Pebble Cove 45-50%, and the first hook comes within 1.9-2.4 storms on average. With 4 anglers at the eye a storm has about 2.2 pulls (economy sheet §8, §14; output D and M).
8. **What the storm pays** (economy sheet §8). Eye catches are Pebble Cove species valued at the player's **best island multiplier**, so the storm stays the best quarter-hour for veterans too: the eye pays 1.61x Clear coins per minute before Stormborn. Stormborn pay **half their tier value** × the best island multiplier: their prize is the journal page, the banner and the crowd, and a full-value giant made the first bridge depend on the storm clock. The Stormborn table (two Legendary, the Mythic Rumblefin, one Secret) ignores luck. Over the first 240 minutes the storm brings 4.6% of a casual player's coins and 10.9% of a typical player's (economy sheet §12.1).

**Remotes:** `PullTap` (client to server, rate-limited 6/s, burst 10); `PullState` (server to nearby clients). **Data:** `stats.stormsJoined`, `stats.giantsLanded`, `stats.helps`, `stats.eyeBitesSinceGiant` (the pity counter), Witnessed stamps in the journal. **Analytics:** `StormJoined`, `StormLanded`, `PullHelped`.

### 4.4 Upgrades: Rod, Lure, Boots, Pal Pouch

Serves: **stay** (the session loop). Reuse: `src/server/Systems/Upgrades.luau` and `src/shared/Config/Upgrades.luau` (cost = round(baseCost × costGrowth^level)). Costs and effects are economy sheet §4:

| Line | Template `kind` | What changes, visibly | Base cost, growth | Effect per level | Max level | Shown | Resets on New Tide |
|---|---|---|---|---|---|---|---|
| Rod | `power` | Catch value. The rod model gets longer per tier and changes colour every 3 tiers; the next fish is visibly bigger | 15, x1.28 | coins x1.14 | 150 | from the start | Yes |
| Lure | `luck` | Rarer fish; the lure glows brighter per tier | 150, x2.0 | luck +4% (cap +100%) | 25 | 4:00 | No |
| Boots | `speed` | Walk speed (reach fronts first); boots leave a splash trail | 120, x1.55 | walk speed +1 | 16 | 4:00 | Yes |
| Pal Pouch | `storage` | Companion capacity | 1,000, x3.0 | capacity +10 | 10 | on reaching Lantern Reef | No |

The cozy distance rules pass at base walk speed (16 studs/s), so Boots only speed up the chase (world plan §4).

Equip slots stay at the template's 3 (`Config/Pets.luau` `baseEquipSlots`); any extra slots are a catalog item (T-0009).

### 4.5 Islands and bridges

Serves: **stay** (access progression and the first goal). Reuse: `Zones` (`src/server/Systems/Zones.luau`, `src/shared/Config/Zones.luau`), `ZoneGate` and `UnlockPrompt` in the world contract, `src/client/Controllers/Gates.luau`. Each gate becomes a broken bridge with a price sign, visible from the spawn or the Open Pier (world plan §5). Islands in order: `pebble_cove`, `lantern_reef`, `gustwhistle_bluffs`, `thunderhead_point`; each bridge needs the one before it and none needs a New Tide.

| Island | Bridge price (coins) | Island value multiplier | Bridge deck | Casual / typical arrival |
|---|---|---|---|---|
| Pebble Cove | start | x1 | - | start |
| Lantern Reef | 620 | x4 | 79 studs | 10.8 / 8.7 min |
| Gustwhistle Bluffs | 19,000 | x16 | 50 studs | 23.6 / 16.4 min |
| Thunderhead Point | 1,600,000 | x64 | 71 studs | 38.8 / 28.9 min |

Prices, multipliers and arrival times: economy sheet §1 and §5; decks: world plan §2. Rod catch-up turns each x4 island into about x19 income, so every future island is priced with that rule (economy sheet §5).

**Ferry** (world plan §8). A small boat on a fixed 681-stud loop links Driftlight Harbor with the Thunderhead Point and Lantern Reef slips. **It does not stop at Gustwhistle Bluffs**: that bridge is 50 studs from the hub, and Whistle Point to the Open Pier is 17 s on foot. A slip offers only unlocked islands. Nothing depends on the ferry: on foot, every walkway point reaches every `Callable` harbour spot within 29.6 s and every spot reaches the Open Pier within 27.5 s (world plan §4), inside the 60 s lead of the storm countdown and Sky Bell calls. The ferry shortens the map's longest trip (Lantern Reef slip to Thunderhead slip) from 42.1 s on foot to 9.3 s. **Launch scope (world plan §14 question 5):** in, size S, and the first item cut if the build stage runs late, because no rule depends on it. Driveable boats are deferred.

### 4.6 Collection and randomness

Serves: **stay** and **return** (pillar 1's familiar layer: weather tables and marks are already standard in the genre, per the market scan).

- **Species (launch):** 48. That is 8 per island (32), 3 weather-only per front type (9), 4 Stormborn and 3 Aurora Night. All names are invented; 11 are named so far and the rest are slot ids in the sheet (open question O-DS1). Drop tables per island and weather are economy sheet §9.2 (DESIGN-04). Under a front, an island's 8 species and that front's 3 weather-only species form one table, so weather-only species bite under their front on every island, at that island's value.
- **Rarity and time-to-see** (economy sheet §9.1; tiers and colours are the template's `Rarities`; luck applies to Rare and up). Designed medians for a casual free player: Uncommon 1.5 min or less, Rare 3 min or less (the scripted Pitterpike), Epic 5-15 min, Legendary 20-45 min; Mythic in the first week for a typical player; Secret with no promise. Modelled casual medians: 1.0, 2.0, 6.5 and 23.8 min; Mythic about day 12 (typical day 3).
- **Sizes** (economy sheet §9.3): a lognormal factor around 1.0, clamped 0.5-3.0 (Stormborn spread wider; Gusts x1.25 after the clamp), multiplying both kg and value. About 4% of fish are 1.5x or more and 0.18% are 2x or more: the record-board fish.
- **Marks:** Drizzled (Showers), Misty (Sea Fog), Breezy (Gusts), Charged (the Great Storm's eye: by a landing tap on a flash for regular catches, by chance for Stormborn, §4.1 and §4.3), Prism (Rainbow), Auroral (Aurora Night). **One mark per fish; marks never stack** (`vault/03-rarity-and-rng/collection-and-variants.md`). Chances and multipliers (economy sheet §9.4): Drizzled 20% x1.5, Misty 15% x2, Breezy 20% x1.5, Charged x3 (about 25% of eye catches by flash taps; Stormborn 25% + 5% per friend helper, cap 50%), Prism 5% x5, Auroral 10% x3. No mark is above x5, and weather value × mark × Fish of the Day is capped at x10.
- **Sky Journal:** silhouettes for unseen species with a hint ("Bites only in Sea Fog"), the heaviest kg per species, marks seen, and 12 sets with completion rewards (+5% coins each, in the bonus category, and a visible title; economy sheet §9.2). Journal keys reuse the template's collection index (`species:mark`).
- **Companions and nests:** 12 companions across 4 nests (one per island), each with a weather perk active only in its weather. Named so far, with their perks (economy sheet §6): Puddle Frog, bite wait -10% in Showers; Lamp Moth, luck +10% in Sea Fog; Kite Gull, reel success +5 points in Gusts (a steadier band); Storm Petrel, Sky Dial +5 min. The other 8 are named in the content pass (O-DS1); the sheet may swap perks inside its caps (bite wait at most -30%, reel success at most 98%, a mark chance at most 2x its weather's base, companion luck +50%). Nests (economy sheet §6): Driftwood Nest 150 coins, Reef Nest 5,000, Bluff Nest 1,000,000, Thunder Nest 50,000,000; odds Common 75%, Rare 22%, Legendary 3%, with a hard pity of a Legendary on hatch 80 (2.4x expected); **no luck of any kind applies to nests**. The Thunderhead nest's display name is "Thunder Nest" (the world plan's proposed id `storm_nest` stays). "Equip best for this weather" is added to the template's equip best. Reuse: `Hatching`, `PetInventory`, `PetFollow`, `Hatch` (odds panel always shown) with `Config/Eggs.luau` and `Config/Pets.luau`.
- **Paid random items (D2):** nests count as paid random items when coins can be bought with Robux. Odds are always shown (the template's hatch odds panel uses the same tables the server rolls), and `ArePaidRandomItemsRestricted` is respected through `src/server/Services/Policy.luau`.
- **Luck stacking** (economy sheet §10, DESIGN-04): one rule, shown in the odds panel, additive inside a category and multiplied across categories:

  ```
  luck = min(6, (1 + Gear) × (1 + Companions) × (1 + Friends) × (1 + Sky))
  Gear       = min(+100%, Lure +4% per level)
  Companions = min(+50%, equipped companions' luck perks in this weather)
  Friends    = min(+50%, +10% per friend in the server)
  Sky        = min(+100%, natural weather (Sea Fog +100%, others 0)
                         + min(+25%, all paid luck: the Sky Bell's shared bonus and any paid luck item)
                         + free timed luck (the day-7 Lucky Tide, code boosts))
  ```

  The total cap is x6, down from the template's `maxLuck` 10. Luck multiplies Rare-and-up weights, then renormalises; it never applies to nests or to the Stormborn table. Players whose `ArePaidRandomItemsRestricted` is true get no paid luck (template `Util/Stats.luau`). At the cap, a Thunderhead Mythic is about 1 catch in 300.

### 4.7 New Tide (rebirth)

Serves: **stay** (long loop). Reuse: `Rebirth` and `RebirthPanel` renamed. It resets coins, Rod and Boots, and keeps islands (`rebirthKeepsZones = true`), journal, companions, Lure and Pal Pouch. The panel shows exactly what resets and what stays (template). Numbers (economy sheet §7): New Tide opens once all four islands are open, so every tide is taken at x64; it costs 130,000,000 coins, then x1.9 per tide; each tide adds +50% coins, at most 30 tides (x16). The first falls inside the template's tested 20-90 min band (`tests/Economy.spec.luau`): casual 62.2 min, typical 44.2 (economy sheet §1). Tides 2-4 take about 16-17 minutes each, and cycles pass 90 minutes from tide 13, so **a second prestige layer must be designed before tide 12** (about 6.7 h of play, around day 10 for a typical player; open question O-DS2).

### 4.8 Return systems (DESIGN-05)

Serves: **return**. Every item maps to the retention checklist in `vault/10-retention-and-social/retention-systems.md`.

| System | Rules | Reuse and size |
|---|---|---|
| **Daily calendar** | 7 days, day 7 the best and previewed from day 1; claim with one tap; server-day boundaries. Day 1 is claimed at minute 5 of the first session with day 2 previewed. Contents scale with income and include a weather cosmetic so returning shows on the avatar. In minutes of income (economy sheet §12.2): day 1: 2; day 2: 3; day 3: 4 and a raincoat colour; day 4: 5 and coins2x for 10 min; day 5: 6; day 6: 8; day 7: 12, a Lucky Tide (+25% Sky luck for 15 min) and Tide Pot bait (+2 fish) | `Rewards`, `RewardsPanel`, `Util/Daily`, `Config/Rewards.luau`; S |
| **Streak** | Gentle: the streak bonus is +2% coins a day, capped at +30% (template; economy sheet §12.2). A missed day pauses the calendar and resets the streak bonus (template rule). **One free "Calm Day" freeze per 7 days** covers a single missed day automatically, so a child who misses a day does not lose everything; nothing is sold to restore a streak (design decision) | `Util/Daily` change; S |
| **Almanac (daily quests and Fish of the Day)** | A page per UTC day, the **same for every player in the world** (generated from the date, like the weather), so friends compare notes. 3 tasks of about 15-20 minutes total (`retention-systems.md`: daily quests 10-20 min): (1) **Fish of the Day**: catch species X, which bites only in weather W; it pays x3 that day; (2) a weather task ("Land 5 fish in Sea Fog"); (3) a together task ("Help pull a Stormborn" or "Catch 3 fish under a Rainbow"). Each task pays 1 minute of income, and all three pay 2 more: 5 minutes a day (economy sheet §3.1, §12.2). Tomorrow's Fish of the Day is previewed. Unlocks after the first bridge (step 11), following the vault's order: quests and daily systems at the end of session 1 | New `Almanac` system and panel; reads `Util/WeatherSchedule`; M |
| **Tide Pots (next-day timer)** | One free pot slot from onboarding step 10, a second slot on reaching Lantern Reef. Place a pot on any unlocked, non-sheltered spot. It fills for up to **8 hours** (cap). On collection the server computes the catch from the **global natural schedule** for that spot over the time it sat there: the fish carry the marks of the weather that really passed and enter the Sky Journal. A pot pays **0.5 minute of active income per pot-hour** (at the player's best island and current multipliers) and reveals **1 fish per hour, 8 when full**; day-7 bait adds 2 (economy sheet §12.3). That is 0.83% of active efficiency, far below the vault's usual 10-50% offline band, on purpose: with an 8 h cap and two slots, 25% would make pots 91% of a typical player's daily coins, and the vault's rule is that passive income stays below about half for active players (`vault/04-progression-and-economy/idle-and-offline-progression.md`). Measured passive share: typical 13.0%, casual 32.2% (economy sheet §12.1). For a 10-minute-a-day player, two full pots are 8 minutes of income, close to a day's play; the reveal sells the fish, not the coins. Pots ignore Sky Bell calls (they are per server) and never yield Stormborn. The pot shows "Full in 7h 12m"; rejoining opens a "while you were away" reveal. Extra slots, if sold, are capacity, never a skip (catalog (T-0009)) | New `TidePots` system and panel; `Grants` for payouts; M |
| **Playtime gifts** | Template gifts at 5, 10, 15, 25, 40 and 60 minutes; the last is the best; countdown on the HUD. Rewards (economy sheet §12.2): 1, 1 and 2 minutes of income, coins2x for 10 min, then 3 and 5 minutes | `Rewards`; S (retune) |
| **Notifications** | Opt-in asked once, at a value moment: right after placing the first Tide Pot ("Want to know when your pot is full?"), only where the platform allows the prompt (13+). Messages: "Your Tide Pot is full" and "A new front arrives Saturday in 1 hour". At most one a day | New, S |
| **Group and favourite** | Template group bonus. Group prompt once, after the first storm ends. Favourite prompt once, after crossing the first bridge. Never gating content | `Social`; S |
| **Welcome back** | After 3 or more days away: a welcome gift of 10 minutes of income plus coins2x for 15 minutes (economy sheet §12.2) and a "What's new" card for the latest Saturday front | `Rewards`; S |

### 4.9 Social (DESIGN-06)

Serves: **stay**, **return** and **click** (co-play days, invites and clips).

**Social reason: co-play first** (the Great Storm pull, §4.3), with presence and friendly competition.

| Layer (`social-systems.md`) | Design |
|---|---|
| Co-op with strangers | Stormborn land 3.6x faster with 3 helpers and 4.5x faster with 4, and every helper is paid and stamped (§4.3). New players help from minute one. A Sky Bell call (§4.10) is a server-wide gift with the buyer thanked by name |
| Co-play with friends | Friend bonus: the template's `Social` system (+10% per friend in the server, capped at +50%, `Config/Economy.luau`), applied to **luck** inside the stacking rule (economy sheet §10; §4.6). Friends in one server also share the forecast, so they plan a session together |
| Invites | Invite button on the storm countdown from 2:00 (never a popup, never on spawn). `SocialService:PromptGameInvite` with `ExperienceInviteOptions` and launch data `{"spawn":"openPier"}` (§3.4). A second invite point: the banner after a Stormborn lands carries "Invite" for 10 s |
| Referrals | The friend referral system (`ReferredByPlayerId`): both sides are rewarded once the invitee has played 10 active minutes, checked on the server; the invitee gets coins2x for 15 minutes, the inviter a raincoat colour and 5 minutes of income; at most 3 rewarded invitees per inviter per day; once per invitee ever; pending rewards stored for offline inviters (`viral-and-social-mechanics.md`, abuse-safe rules; amounts: economy sheet §12.2) |
| Presence | Companions follow you; journal titles above heads; the Stormborn catch pose; weather cosmetics (raincoats, umbrellas) |
| Friendly competition | An in-world **harbour record board**: today's heaviest catch per island and the heaviest catch of the current storm, with names (daily reset, so new players can rank). The race to the Rainbow. A one-tap **Cheer** on rare-catch banners |
| Server size | 12 (playtest 8 against 12): enough for a crowd of 4-8 at the pier, small enough that everyone is visible. Comparables run 6-20 (sketch §6, tracker 2026-10-24) |

**Argued omissions.**
- **Trading: not at launch.** It brings scams and duplication risk (`vault/21-hits-and-trends/why-games-die.md`), extra policy duties (`IsPaidItemTradingAllowed`; companions from nests are paid random items under D2), and moderation load for a young audience. The co-op storm already gives a reason to be with others. Revisit after launch with data.
- **Consequence layer (loss caused by other players): deliberately none.** The 2025-2026 evidence favours consequence layers (`vault/21-hits-and-trends/anatomy-of-a-hit.md`, ingredient 3), so this is a real gap, accepted for four reasons: (1) the cozy promise and the expected Minimal label for a Kids and Select audience (D5); (2) the twist's social structure is cooperation, and a theft layer would turn the storm crowd into rivals; (3) the substitute tension is honest and visible: fronts and storms that leave on time, the per-storm record board and the race to the Rainbow; (4) the prototype's friend test measures whether co-op alone draws players together. **Revisit trigger:** if, after launch, D7 is under the blueprint's healthy band and invites per active player are low, consider friendly rivalry (storm tournaments, team records), never loss.

### 4.10 The Sky Bell: paid weather calls (D6)

Serves: **spend** (a social purchase) without breaking pillar 2. Familiar layer, not part of the twist (pitch PITCH-04).

**Decision on the Sky Bell (sketch §4.3 and §7): merged into D6, and its free co-op charging dropped.** The Sky Bell becomes the in-world form of the paid call: a bell on Driftlight Harbor that rings for the whole server whenever a front is called, and whose frame shows the call queue. The parked free version (players charging the bell together until it calls a front for free) is dropped, for four reasons:
1. A free charge meter next to a Robux button would turn the purchase into paying to skip a shared wait, which the compliance note and the hit formula reject (`monetization-compliance.md` §3; `hit-formula.md` #11).
2. The free, cooperative weather moment already exists and is better: the Great Storm, every 15 minutes, which nobody can buy or move. A second co-op summoning loop would compete with it for the same crowd.
3. Free players already get every callable weather for free from the natural schedule, and they share every call anyone buys.
4. Scope: one system (calls) instead of two (calls plus charging).

**The four D6 constraints and how the design meets each one.**

| D6 constraint | Design rule |
|---|---|
| (1) A summoned front appears on the Sky Dial for everyone in the server | The moment a call is placed, it appears on every player's Sky Dial with its exact arrival time (at least 60 s ahead), a bell icon, "Called by <display name>" and the tag "this server". The bell rings and one banner shows: "Mia rang the Sky Bell: Sea Fog at the harbour in 1:00. Everyone can fish it!" **Once on the dial, the call always happens**, even if the buyer leaves, so the forecast stays true |
| (2) The benefit is shared with every player there, never only the buyer | The call covers the **harbour spots** (`Callable`), which every player in the server, whatever their progress, can reach within the 60 s lead (Pebble Cove is everyone's start island, and every walkway point reaches every `Callable` spot within 29.6 s on foot; world plan §4). Everyone fishing under it gets exactly the same effect. **The buyer gets no gameplay extra**: no exclusive spot, no personal bonus, only the public thank-you. Players who join during the call share it too |
| (3) It never moves or replaces the Great Storm schedule | Calls are additive. No call can be active from 60 s before a Great Storm until 30 s after it ends, and the storm, the Rainbow rule and Aurora Night are untouched. A call never moves, delays, shortens or replaces any natural front; it is placed only into clear harbour time |
| (4) Duration, price and effects are designed, not guessed; granted only in `ProcessReceipt` | Duration and slots: below (design values with reasons). Effect: below, +25% Sky luck for everyone under the call (economy sheet §13). Price: catalog (T-0009). Grant: only in `ProcessReceipt` (below) |

**What can be called.** **Showers, Sea Fog or Gusts**, chosen by the buyer. Not the Great Storm, not a Rainbow on its own (a called Showers front leaves a Rainbow under the normal rule), not Aurora Night, and not Saturday event fronts (any future addition re-checks this section).

**Where.** The harbour: the Pebble Cove spots marked `Callable`, at least 2 including the Open Pier. These are `pier_head` and `cove_shallows`, plus the two Pebble Point rock pools (`cove_pool_1`, `cove_pool_2`) while a called Showers front is there (world plan §6.1, §6.5). Never the sheltered Dock Ripple, so a newcomer's first cast is never changed by someone's purchase. The longest walk from any walkway point to a `Callable` spot is 29.6 s (world plan §4), well inside the 60 s lead. The harbour has no `far` spot, so a called Gusts front there changes the band and the size roll only. The in-world bell (tag `SkyBell`) stands on the quay at the pier root, outside the spawn view, so no purchase surface is in the first frame (world plan §5, §6.1).

**When (slot rules).** A call starts at the first time slot that satisfies all of these:
1. At least 60 s after the call is placed (the cozy announce rule).
2. No natural front or Rainbow covers any `Callable` spot during the slot (natural weather keeps priority; the slot is computed from `Util/WeatherSchedule`, which knows the future).
3. Outside the storm guard: from 60 s before a Great Storm starts until 30 s after it ends.
4. Outside Aurora Night windows.
5. At least 60 s after the previous call in this server ended, so the sky visibly clears between calls.
6. Starting within the next 15 minutes. If no such slot exists, the bell is not sold right now, and the panel says when the sky is free ("The sky is busy until 12:52"): an honest reason, not a timer.

**Schedule guarantee.** Rule 2 gives natural weather priority, so the launch route pool must leave room. **Every 15-minute cycle keeps at least one 180 s window of clear harbour time** (no natural front or Rainbow on any `Callable` spot), outside the storm guard. Pebble Cove's Showers must still arrive often enough for onboarding step 7. A `WeatherSchedule` unit test checks both over 7 days of cycles. Without this rule, a harbour whose home weather is Showers would rarely have a free slot. (A check of the prototype timetable on 2026-10-25 found 0 slots per cycle, because its fronts fill the harbour. That is fine there, since the prototype has no Sky Bell, but it shows that the guarantee has to be designed.)

**Duration: 180 s active**, then the front drifts out to sea (visual only). Reasons: (a) it is 1.5-2x a natural front's 90-120 s linger, so a player anywhere on the map sees the 60 s warning, reaches the harbour and still fishes 2 minutes or more under it; (b) two calls fit between storm guards (a 15-minute cycle leaves 210-840 s outside the guard: 180 s + 60 s gap + 180 s), so called weather can never cover more than 360 of the 720 non-storm seconds at the harbour and never touches the other islands; (c) it is far shorter than the 10-15 minute server weather a comparable sells (Fish It!, market scan), because ours is local, forecast and shared, and must not crowd out natural weather.

**Queue and cooldown, per server.** 1 call active and at most 2 waiting. One waiting call per buyer. At most 2 calls start per storm cycle (this follows from the slot rules and is checked as an invariant). Before buying, the panel shows the exact arrival time the purchase would get.

**Effect (shared).** A called front behaves **exactly like a natural front of its type**: the same way of fishing, the same weather-only species, the same mark chances, the same Rainbow after Showers. On top of that, every player fishing under the call gets a **shared bonus of +25% Sky luck** (economy sheet §13). It sits in the Sky category with every other paid luck, all capped together at +25% (§4.6), so it stays below Lure level 7 (+28%, which a casual player reaches at minute 23.9), and the Sky cap of +100% means a called Sea Fog adds nothing over natural fog. For a new player: Rare-or-better per catch under a called Showers rises from 14.98% to 18.05% and coins per catch by 6.0%; a called Gusts adds 8.8% coins; a called Sea Fog adds 0. Worst case, with calls on half of all non-storm time and the player always under them: the casual first bridge comes 8.6% sooner (10.8 → 9.9 min), the typical 17.7% sooner (economy sheet §13). The buyer gets nothing extra. Tide Pots and Almanac windows ignore calls; the Almanac's Fish of the Day and weather tasks do count catches under a call (it is real weather, shared by everyone there). Catches under a call are tagged `called = true` in analytics, so twist test B and the economy reports separate paid weather from natural chasing.

**Purchase and receipts (house rule 5; `vault/09-monetization/monetization-compliance.md` §7).**
1. Three developer products, one per weather (ids in `Config/Products.luau`; prices: catalog (T-0009)). One product per weather means the server never trusts a client "chosen weather" argument.
2. The template's `src/server/Systems/Purchases.luau` `ProcessReceipt` is the **only** place that grants: it adds one **Sky Call credit** for that weather to the buyer's profile, saved together with the receipt id (the template's idempotent pattern), then returns `PurchaseGranted`.
3. The Weather system immediately spends the credit to place the call in its slot (spend saved). If a race filled the queue between the prompt and the receipt, the credit stays in the profile and the buyer can ring it later from the Sky Dial at no extra cost ("Your Sky Bell call is saved").
4. On server shutdown (`BindToClose`), a call that has not started and whose buyer is still in the server is returned to the buyer as a credit before the final save. If the buyer already left, the server logs `SkyCallLost` with the buyer's id for restoration (open question O-E3).

**Before purchase (disclosure surface).** The panel shows the weather, its way of fishing, where, the exact arrival time and the 3-minute duration, "Everyone in this server shares it", an **"Odds"** button listing the harbour's species table under that weather with percentages (and, while a call is active, the odds shown update), and the shared bonus if any. Final wording belongs to the Monetization Designer. **How a paid, server-wide odds change is disclosed, and whether it changes the questionnaire answers, is the human's decision** (the D6 open item, escalated by the Monetization Designer in T-0009).

**Griefing protection.**

| Risk | Rule that prevents it |
|---|---|
| Changing someone's weather under them | Calls go only into clear harbour time; no natural front, Rainbow, storm or Aurora is ever replaced |
| Locking the sky or the harbour | 1 active and at most 2 waiting per server; one waiting call per buyer; at most 2 starts per cycle; 60 s clear gaps |
| Excluding players | Calls cover only harbour spots everyone can reach; no targeting of players or islands |
| Disrupting newcomers | The Dock Ripple is never covered |
| Spam or abusive text | One banner per call showing only the buyer's display name; no custom text |
| Pressure on young players | The button lives inside the expanded Sky Dial, appears only after onboarding step 12, and is never a popup. Neutral copy ("Ring the Sky Bell"), no countdown pressure, no scarcity claims (`monetization-compliance.md` §3) |
| Feeling of pay-to-win | No buyer-only benefit; the effect is capped below active play with upgrades; the Great Storm, the social core, cannot be bought |

**Policy.** The products are marked `probabilityModifier = true` and `fundsRandomItems = false`, so the template hides them for players whose `ArePaidRandomItemsRestricted` is true. Whether those players may fish under a call that another player bought is a policy question for the human (O-H2); the GDD does not answer it. Under the sheet's luck rule they never get the +25% shared bonus, because restricted players get no paid luck (§4.6); O-H2 is about the called weather's fish table and marks.

**Solo servers.** A buyer alone in a server gets the same call; anyone who joins during it shares it.

**Analytics:** `SkyCallPurchased` (weather, wait seconds), `SkyCallStarted`, `SkyCallEnded` (unique players who caught under it, catches, buyer present), `SkyCallLost`. Success target: a median of 3 or more players other than the buyer catch under each call (first-pass estimate).

**Not in the prototype** (no paid products, pitch recommendation 2). It is built at the build stage after the human answers O-H2 and the D6 disclosure item. Size M.

### 4.11 Events framework

Serves: **return** (weekly heartbeat, `hit-formula.md` #8).

- **Weekly update unit: "a new front".** Every Saturday a new weather condition or weekly front arrives, bringing 4-6 species, a mark or mark variant, a journal set and (every other week) a companion, plus a live arrival moment at a fixed time. A new island ships every 3-4 weeks. Each update makes the twist richer.
- Event fronts are added to the `WeatherSchedule` route pool for their window, so they stay forecastable and identical in every server.
- **Aurora Night** (§4.2) is the first recurring event.
- LiveConfig flags switch each event on without publishing (template `LiveConfig`).
- Event brief template: `vault/18-templates-and-checklists/event-brief-template.md`.

---

## 5. Economy (owner: Economist, `economy-sheet.md`, T-0008)

- **Currencies: Coins only.** The template's Gems (`Config/Game.luau` `premiumCurrency`) are not used and stay hidden; rewards and products that grant gems are re-expressed in coins or items by the Economist and the Monetization Designer. Reason: one currency is readable for a 9-year-old (`hit-formula.md` #2), and nothing in this design needs a second.
- **Sources and sinks (shape; values in the sheet).**

| Sources | Sinks |
|---|---|
| Catches (by weather, tier, size, mark) | Rod, Lure, Boots, Pal Pouch |
| Stormborn and helper shares | Bridges |
| Tide Pots | Companion nests |
| Almanac tasks, calendar, playtime gifts, codes, referrals | New Tide (resets coins) |

- **Measured shares** over the first 240 minutes (economy sheet §12.1): catches outside storms are 36% of a casual player's coins and 60% of a typical player's, the Great Storm 5% and 11%, Tide Pots 32% and 13%, and rewards 27% and 16%. The Rod takes about 72% of spending and New Tide about 27%. Passive income stays below half for every player type.
- **Time-to-goal for the first five goals** (cumulative active minutes; mean across the 15 storm join minutes; economy sheet §1):

| Goal | Target | Source | Casual free | Typical | Paying | Result |
|---|---|---|---|---|---|---|
| First Rod upgrade (15 coins) | about 60 s | `first-session-blueprint.md` phase 3; sketch §5.1 | 45 s | 45 s | 45 s | Pass |
| Bridge to Lantern Reef (620) | 10-12 min (inside 10-15) | blueprint phase 5; template pacing test 8-16 min | 10.8 [10.3-11.1] | 8.7 | 2.9 | Pass |
| Bridge to Gustwhistle Bluffs (19,000) | 20-30 min cumulative | `progression-architecture.md` (15-25) and template comment (30-45) disagree; the sheet holds 20-30 | 23.6 | 16.4 | 8.0 | Pass |
| Pebble Cove set 8/8 (median) | inside the first 30 min | sketch §5.5 | 17.2 | 12.4 | 25.5 | Pass |
| First New Tide (130M) | 20-90 min (template band) | `tests/Economy.spec.luau` | 62.2 | 44.2 | 24.4 | Pass |

  On goals 2, 3 and 5 the paying player is 3.7x, 3.0x and 2.6x faster than the casual free player, inside the vault's 2-4x. On catch income alone the casual player bridges at 14.8 min, still inside the template's 8-16 min test band.
- **Design targets and the sheet's results** (economy sheet §1, §3.2, §3.3, §9.4, §10, §12.3): a catch every 6-10 s in Clear (7.5 s); Showers about 1.5-2x the coins per minute of Clear (1.76-2.00x) and Sea Fog about 1.2-1.5x with more rares (1.34-1.49x) (§2.2); no gap over about 3 min without an upgrade in the first hour (casual worst 2.22 min in the first 30 min; typical 3.47 min in 1 of 15 join minutes, "near"); marks never stacking (kept); a single luck stacking rule with caps that includes the Sky Bell's shared bonus (§4.6). **Changed:** Tide Pots from the GDD's 20-30% of active efficiency to 0.83% (0.5 min of income per pot-hour), with the 8 h cap kept (§4.8).
- **Multiplier categories and caps** (economy sheet §11): Rod x1.14 per level (max 150); island x1 to x64; companions at most x2; bonus (journal sets, streak, group) at most x2; boosts additive, at most x3; New Tide at most x16; per fish (weather value × mark × Fish of the Day) at most x10; luck at most x6. A maxed paying player earns 1.5x a maxed free player who has a free timed boost active, and 3.0x one who has not.
- **Pacing tests:** the template's `tests/Economy.spec.luau` models hits per second; it is re-expressed in catches per minute (economy sheet §17): Lantern Reef at 8-16 min for a casual player on catch income (modelled 14.8), the first upgrade under 60 s, and New Tide 1 at 20-90 min.

## 6. Monetization (owner: Monetization Designer, `catalog.md`, T-0009)

- **No paid products in the prototype.**
- **Design direction for the catalog:** the Sky Bell (§4.10, three products, rules fixed by this GDD); Auto Reel (a pass weaker than active play; it never plays the fog hook or the storm pull for you); Pal Pouch or equip slots (capacity); an extra Tide Pot slot (capacity, never a skip); a Lure luck boost with its odds effect disclosed; weather cosmetics (raincoats, umbrellas, bobbers). Coin packs are the catalog's call; if they exist, nests stay paid random items (D2).
- **Economy limits the catalog keeps** (economy sheet §10, §11, §13): all Robux-linked luck, the Sky Bell's bonus included, shares one +25% paid cap, so the template's Luck Potion (x2) and Server Luck (x2) are resized or dropped; the 2x Coins pass stacks additively with timed boosts, capped at x3. Prices are the catalog's (T-0009).
- **One server-wide paid effect only:** the Sky Bell replaces the template's "Server Luck" product (`Config/Products.luau` `serverLuck`), so two paid server-wide odds changes never stack or confuse.
- **Never sold:** skipping an honest timer, moving or calling the Great Storm, changing the forecast for one player only, Stormborn outside the storm, or anything a free player cannot reach by playing.
- **Offer moments:** in context only: Pal Pouch when companion capacity is full; a pot slot when both pots are placed; the Sky Bell inside the expanded Sky Dial. No purchase prompt interrupts play, and none appears before onboarding step 12.
- **Compliance:** odds shown for every paid random path (nests, D2); `ArePaidRandomItemsRestricted` respected (template `Policy`); receipts idempotent; the D6 disclosure question escalated by the Monetization Designer.

## 7. Art and audio direction (owner: Artist, `art-direction.md`, T-0010)

- Needs from the art direction: a mood per weather (Clear, Showers, Sea Fog, Gusts, Rainbow, Great Storm, Aurora Night) readable on a phone at a glance; the fog's bobber dip and lantern glow readable on a small screen with sound off; rarity colours; a per-weather VFX budget for low-end phones; an icon and thumbnail concept selling clip moment C1.
- **Sound list** (all original or licensed and recorded in the asset index): cast whoosh, plop, splash bite, fog dip chime (low), reel tick per good tap (pitch varies ±10%), miss swish, landing splash per tier, coin fly, rare sting, Stormborn sting, thunder rumble (low), storm swell (3 s or more), bell (soft), Rainbow shimmer, Cheer, calm acoustic music bed, a storm music layer. The prototype uses the template's built-in sounds (`Config/Game.luau` `sounds`).

## 8. UI

**HUD layout (phone landscape, 1280x720 design canvas, template `UI/Root`):**

```
+--------------------------------------------------------------------------------+
| [Coins 1,240]   [Storm 4:12 | Fog > Reef 1:10 | Rain > Pier 2:40]      [Menu]  |
| [Bridge ======62%]                                                              |
| [Better Rod ===]                                                                |
|                                                                                 |
|                    (world: water, bobber, weather icons over spots)             |
|                                                                                 |
| [Journal]                                                       [Gift 2:31]     |
| [Almanac]                                                                       |
|  (thumbstick)                                     [Shop]     (  CAST / REEL  )  |
+--------------------------------------------------------------------------------+
```

- The reel ring centres above the Cast button, inside the thumb's reach; the Cast button becomes Reel, then Pull! during a pull.
- **Menus:** Shop (Upgrades, Companions, Store), Companions, Sky Journal (Species, Sets, Records), Almanac, Gifts (calendar, playtime, codes), Settings (sound, music, reduce motion, vibration, QA tools in Studio), expanded Sky Dial (map, events, Sky Bell).
- **Visual language:** one highlight colour for "do this now" everywhere; rarity colours on every card; weather icons identical on the Sky Dial, the spots and the journal hints. The Interface Designer turns this into mocks at the prototype and build stages.

## 9. Tech

### 9.1 Architecture notes

New server systems (template rule: `init`/`start`, remotes in `Config/Remotes.luau` with rate limits, types in `Types.luau`, added to the startup `ORDER` list): `Fishing`, `Weather` (with the pure `Util/WeatherSchedule`), `StormPull`, `Journal`, `TidePots`, `Almanac`, `SkyBell` (build stage), `Records`. New client controllers: `Reel` (ring and signals), `SkyDial`, `JournalPanel`, `AlmanacPanel`, `PotPanel`, `StormHUD`. Systems talk through signals (`Fishing.Caught`, `Weather.Changed`, `StormPull.Landed`), as the template's `Nodes.Hit` and `Upgrades.Bought` do.

**Remotes (proposed; the Engineer sets final rate limits):** client to server `Cast`, `HookTap`, `ReelTap`, `PullTap`, `PlacePot`, `CollectPot`, `ClaimAlmanac`, `RingSkyBell` (spends a saved credit only); server to client `Bite`, `ReelState`, `CatchResult`, `WeatherState`, `PullState`, `StormState`. The template's `Hit` remote and `Nodes` payout are retired once `Fishing` replaces them.

### 9.2 Data schema additions (bump `Data/Schema.luau` `VERSION`, add a step in `Data/Migrations.luau`)

`journal` (species → count, heaviest kg, marks seen; sets claimed; Witnessed stamps), `pots` (slot → spot id, placed at), `potBait` (count, from the day-7 calendar), `almanac` (day, tasks done), `skyCallCredits` (weather → count), `streakFreezeUsedAt`, `stats.catches`, `stats.stormsJoined`, `stats.giantsLanded`, `stats.helps`, `stats.eyeBitesSinceGiant` (the Stormborn hook pity counter), `records` (personal bests). All JSON-safe; the server owns all of it.

### 9.3 Performance budgets and risks

- Budgets: `art-direction.md` (T-0010) per weather and `world-plan.md` (T-0011) per island, both from `vault/19-vfx/vfx-performance-budgets.md` and `vault/06-world-and-look/build-budgets.md`. Full detail only for the front nearest the camera.
- Risks: weather VFX on low-end Android (mitigation above); tap judging under latency (generous windows, the server-side allowance); schedule edge cases at cycle boundaries (unit tests); the Sky Bell's offline credit restore (O-E3).

### 9.4 Reuse map (DESIGN-10)

Paths are in `games/stormcatch/project/` (a copy of `template/`). Sizes: **S** is config, reskin or about a day; **M** is about 2-4 days; **L** is about 1-2 weeks of engineering (first-pass; the Engineer confirms).

| Mechanic | Reused template system and files (id) | What changes | New? | Size |
|---|---|---|---|---|
| Fishing spots | `src/server/Systems/World.luau` (`ResourceNode`, `NodeId`, `ZoneId`) | Spots never break; new attributes `SpotKind`, `CellId`, `CastPoint`, `StormEye`, `Sheltered`, `Callable`; new tags `WeatherCell`, `StormHome`, `FogLantern`, `SkyBell` (world plan §9); the world built as code from `Config/WorldLayout.luau` (world plan §11) | Reuse | S |
| Cast, bite, reel, reveal | Validation pattern of `src/server/Systems/Nodes.luau`; tap-to-walk in `src/client/Controllers/Interact.luau` (changed to walk to the spot's `CastPoint`); reveal anticipation in `src/client/Controllers/Hatch.luau`; `src/shared/Util/Validate.luau`; `src/shared/Net.luau` | New `Fishing` server system and `Reel` client controller; new `Config/Fishing.luau`, `Config/Species.luau` | **New** | L |
| Weather ways of fishing | none | Ring modes per weather (§4.1), fog hook and silhouette, gust sway and wind cast, storm flashes; all judged on the server | **New** | M |
| Weather fronts, schedule, Sky Dial | `src/server/Services/LiveConfig.luau` (feature flags) | New `Weather` system, pure `Util/WeatherSchedule.luau` with Lune tests, `Config/Weather.luau`, `SkyDial` controller, weather VFX | **New** | L |
| Great Storm co-op pull | Announcements in `src/server/Systems/Hatching.luau` (banner pattern); `Net.toAll` | New `StormPull` system and `StormHUD` controller | **New** | M |
| Species tables, luck, pity | `src/shared/Util/Odds.luau`, `src/shared/Config/Eggs.luau` table shape, hard pity in `Hatching.luau` | Tables per island and weather (economy sheet §9); seeded first rain catch; Stormborn hook pity at 60 eye bites; nests rolled with luck 1 (economy sheet §6) | Reuse | S |
| Sizes and records | none | Size roll in `Fishing`; `Records` system and harbour board | **New** | S |
| Weather marks | Collection index keys (`species:mark`) in the profile; `Util/Odds.luau` | Mark roll per weather; Charged by skill | **New** (small) | S |
| Rod, Lure, Boots, Pal Pouch | `src/server/Systems/Upgrades.luau`, `src/shared/Config/Upgrades.luau` (`power`, `luck`, `speed`, `storage`), `src/shared/Util/Stats.luau`, `src/server/Systems/Characters.luau` (walk speed) | Rename and retune; rod model per tier | Reuse | S |
| Islands and bridges | `src/server/Systems/Zones.luau`, `src/shared/Config/Zones.luau`, `ZoneGate`/`UnlockPrompt`, `src/client/Controllers/Gates.luau` | Bridges with price signs; harbour ferry (an anchored boat moved on the client from server time, `FerrySlip` prompts offering unlocked islands only, the server moves the rider; world plan §8; new, S, first cut if late) | Reuse | S |
| Companions and nests | `src/server/Systems/Hatching.luau`, `PetInventory.luau`, `src/client/Controllers/PetFollow.luau`, `PetsPanel.luau`, `Hatch.luau`, `src/shared/Config/Pets.luau`, `Config/Eggs.luau` | Reskin; weather perks; "Equip best for this weather" | Reuse plus small change | S |
| Sky Journal | Profile collection index; `PetsPanel.luau` UI patterns | Journal panel with sets, silhouettes, hints, set rewards | **New** UI | M |
| New Tide | `src/server/Systems/Rebirth.luau`, `src/client/Controllers/RebirthPanel.luau` | Rename and retune | Reuse | S |
| Calendar, streak, playtime gifts | `src/server/Systems/Rewards.luau`, `src/shared/Config/Rewards.luau`, `src/shared/Util/Daily.luau`, `src/client/Controllers/RewardsPanel.luau` | Retune; weekly Calm Day freeze | Reuse plus small change | S |
| Almanac | `src/shared/Util/Daily.luau` (server day), `Util/WeatherSchedule.luau` | New `Almanac` system and panel | **New** | M |
| Tide Pots | `src/server/Systems/Grants.luau`, `src/shared/Util/Daily.luau` | New `TidePots` system and panel; offline fill from the schedule | **New** | M |
| Sky Bell calls (D6) | `src/server/Systems/Purchases.luau` (idempotent `ProcessReceipt`; `serverBoost` pattern), `src/shared/Config/Products.luau`, `src/server/Services/Policy.luau` | New grant kind `skyCall`; credits; `SkyBell` slot planner in `Weather`; bell object; panel | **New** | M (build stage) |
| Codes | `src/server/Systems/Codes.luau`, `src/shared/Config/Codes.luau` | Channel and creator codes (§11.3) | Reuse | S |
| Shop | `src/client/Controllers/Shop.luau`, `Purchases.luau`, `Config/Products.luau` | Reskin; catalog at the design stage; Gems hidden | Reuse | S |
| Friend and group bonus | `src/server/Systems/Social.luau`, `Config/Economy.luau` (`friendBonusPerFriend`, `maxFriendBonus`) | Applied to luck | Reuse | S |
| Invites and referrals | none in the template | Invite button with launch data; referral rewards | **New** | S |
| Onboarding | `src/server/Systems/Onboarding.luau`, `src/shared/Config/Onboarding.luau`, `src/client/Controllers/Guide.luau` | 13-step list (§3.3); guide kinds `weather`, `pot`, `storm` | Reuse plus small change | S |
| HUD, toasts, UI kit | `src/client/Controllers/HUD.luau`, `Toasts.luau`, `src/client/UI/Builder.luau`, `Root.luau`, `Theme.luau`, `Sounds.luau` | Sky Dial strip, progress bars, reel ring | Reuse plus new widgets | S |
| Data and saves | `src/server/Systems/PlayerData.luau`, `src/server/Core/ProfileStore.luau`, `src/shared/Data/Schema.luau`, `Data/Migrations.luau`, `src/server/Systems/Currency.luau` | Schema additions (§9.2) | Reuse | S |
| Analytics | `src/server/Services/Analytics.luau`, `src/shared/Config/Analytics.luau` | Events in §10 | Reuse | S |
| QA tools | `src/server/Systems/QA.luau`, `src/client/Controllers/SettingsPanel.luau` | `forceWeather`, `forceStorm`, `forceStormborn`, `setScheduleOffset`, `twistStats`, `exportLog`, `fillPot` | Reuse | S |
| Pacing tests | `tests/Economy.spec.luau`, `scripts/economy-sheet.luau` | Re-express in catches per minute | Reuse | S |
| Placeholder sounds (assets) | `rbxasset://sounds/electronicpingshort.wav`, `rbxasset://sounds/button.wav` (Roblox built-ins named in `Config/Game.luau`) | Prototype only; replaced by recorded assets | Reuse | S |
| Driveable boats | none | Later update candidate | **New** | L (deferred) |

Totals: 2 large (Fishing, Weather), 6 medium (ways of fishing, storm pull, Sky Journal, Almanac, Tide Pots, Sky Bell), the rest small. The template already covers data safety, receipts, odds display, the paid-random-items policy, rate limits and analytics.

## 10. Analytics

- **Funnels:** onboarding (13 steps, §3.3); shop (template); storm (`StormJoined` → `PullHelped` or `StormLanded`).
- **Economy events:** every coin source and sink through `Currency` (template), with catches batched as the template batches hits.
- **Custom events** (names stable forever; variation in fields; added to `Config/Analytics.luau`): `Cast` (spot, weather, called), `Catch` (species, tier, mark, weather, called, kg, lineSeconds, underFront), `ReelResult` (mode, taps, misses, landed), `FrontEntered` (weather, spot, called), `StormJoined` (minutesSinceFirstJoin, role), `StormLanded` (helpers, charged), `PullHelped`, `PotPlaced`, `PotCollected` (hours, fish), `AlmanacTask` (task), `SkyCallPurchased`, `SkyCallStarted`, `SkyCallEnded`, `SkyCallLost`, `InviteSent` (point), `ShowOff`.
- **Twist index after launch:** the share of line time under natural fronts (excluding called fronts and storms) per day, against the schedule's coverage. If it drops under 30% for a week, the twist is fading.
- **Experiments after launch (hypotheses):** a wider Showers band on touch raises step 7 conversion; a fog "ring hint" on the first fog bite raises fog catches without lowering twist test A answers; 3 against 4 Almanac tasks for D7.

## 11. Launch and live ops

### 11.1 Store page

Title **Reel the Storm** (D3). Icon and thumbnails: Artist and Storefront (the clip moment C1: a giant fish breaching under lightning, a crowd on the pier). Description first line (draft): "Fish a different way in every weather. A Great Storm every 15 minutes: pull in giants together!" The storefront checks the look-alike notes from T-0010.

### 11.2 Launch plan and first four weekly updates

- Launch reaches age-checked 16+ players first, until the under-16 evaluation passes (250 unique plays from engaged age-checked users within 60 days; `vault/17-policy-and-business/age-ratings-and-audience.md`). The fees and verification steps are the human's decision at launch planning (pitch question 3).
- First four Saturday fronts (themes; the Director schedules): **Snowflurry** (a winter front; launch may fall in the holiday season, pitch "Urgency"), **Glowtide** (a night front with glowing fish), **Sunshower** (rain with sun: Rainbow-rich), **Kite Winds** (a Gusts variant). Each brings 4-6 species, a mark variant, a journal set and a live arrival moment.

### 11.3 External funnel plan (spends nothing)

Closes the pitch rubric gap "no external funnel plan" (pitch, "Social and clip potential"; hit sheet row 8).

**1. Clip moments designed into the game** (`vault/02-core-loop/clip-moments-and-shareability.md`: surprise, scale, one-second readability, emotion):

| Id | Moment | Why it reads muted and without UI |
|---|---|---|
| C1 | A Great Storm landing: five avatars pulling on the pier, lightning on the taut line, a giant Rumblefin breaching against the flash, CHARGED, the banner naming everyone | Dark sky, a flash, a huge fish, a crowd |
| C2 | A Prism catch under a Rainbow, after a race to the rainbow's foot | Colour and a race |
| C3 | The fog mystery reveal: a grey silhouette grows, then a rare fish bursts out | Suspense, then surprise |
| C4 | The Sky Bell rings and the harbour sky turns to fog while players run to the pier | The whole world changes at once |

Clip-friendly features: a **Show Off** button after any Rare-or-better catch (the avatar lifts the fish and the HUD fades for 3 s; size S); the Stormborn catch pose visible to all; the storm schedule is public and regular, so a creator can plan a recording ("next storm at :30").

**2. Share and invite points (in game):** the storm countdown "Invite" button from 2:00 with launch data to spawn at the Open Pier; "Invite" on the Stormborn banner for 10 s; the referral reward banner in the invite menu (both sides rewarded after 10 active minutes, §4.9). No social links, invite codes or addresses are shown inside the game (`viral-and-social-mechanics.md`, social links rule).

**3. Share links per channel** (created by the human in Creator Hub; free): TikTok, YouTube Shorts, YouTube long-form, Discord, X, the Roblox group, and one per creator. Each carries launch data `{"src":"<channel>"}`; new players from a link get the normal first session (launch data is visible in the URL, so it never grants anything valuable). Measured in Creator Hub > Share Links.

**4. Codes per channel** (template `Codes`; server-validated, once per player, rate-limited, behind `featureCodes`; each pays 2-5 minutes of income or a 10-minute Lucky Tide of +25% Sky luck, once per player; economy sheet §12.2):

| Code type | Where it is posted | Expiry |
|---|---|---|
| Launch code | Store description and every channel | 30 days |
| One code per channel (TikTok, YouTube, Discord, X, group) | That channel only | 30 days |
| One code per creator | That creator's videos | 30 days, renewable |
| Saturday front code | Patch notes, every week | 7 days |
| Like and favourite milestone codes | Channels, at each round number | 14 days |

Redemptions per code (`CodeRedeemed` event) show which channel brings players. No code requires posting on social media.

**5. Creator plan draft (no money):**
- **Who:** 15-25 creators who play Roblox fishing or cozy games, 1K-200K subscribers, posting in the last 30 days, with age-appropriate content. The list is drafted from public channel pages; nobody is contacted without the human's approval.
- **What they get (free):** embargoed patch notes 24 h before each Saturday front; a creator kit (logo, key art, the three clip moments, the storm schedule); a personal share link and code; credit in patch notes with permission; a cosmetic code for their community. No gameplay advantages in public servers (`vault/12-live-ops-and-launch/working-with-content-creators.md`).
- **Footage before launch:** requires a test place playable by outsiders, which only the human can publish (house rule 1): open question O-H4.
- **Timeline:** launch -21 days: the list; -14 days: the human sends outreach drafted by the studio; launch week: codes and links live; then weekly with each Saturday front.
- **Money:** any request for payment, paid promotion or a contract is escalated with `--kind money` and never agreed by an agent. Paid or gifted creators are asked in writing to disclose under their platform's rules.
- **Measure:** new players, D1 and D7 by share link; code redemptions per creator; chart snapshots before and after a video.

**6. Search:** the exact title "Reel the Storm" is distinctive and searchable (Creator Rewards counts name searches; `clip-moments-and-shareability.md`).

---

## 12. Open questions (DESIGN-09)

**For the human** (policy and decisions; drafts only, not answered here):

| Id | Question | Owner | Due |
|---|---|---|---|
| O-H1 | **D6 disclosure (open item from D6):** how is a paid, server-wide change to odds or luck shown to players, and does it change the questionnaire answers? | Human; drafted and escalated by the Monetization Designer (T-0009) | Before the build stage |
| O-H2 | **Restricted players and Sky Bell calls (policy):** players whose `ArePaidRandomItemsRestricted` is true never see the Sky Bell products. May they fish under a call that another player bought, whose fish table and marks differ from Clear water? Options for the human: (a) yes, like any other weather in the world, since they paid nothing; (b) they see the weather but fish the Clear table inside it; (c) calls are not sold in a server that holds a restricted player. Each option changes constraint (2) differently, so the human decides. Under the economy sheet's luck rule they never get the +25% shared bonus (no paid luck for restricted players, §4.6), so the question is only the called weather's fish table and marks | Human; the Monetization Designer adds it to the D6 escalation | Before the build stage (the prototype has no paid products) |
| O-H3 | **Prototype testers:** who plays the prototype (at least 5 newcomer testers for each twist test and 3 at once for the friend test)? Testers under 13 would need a parent or guardian's consent and presence. | Human, with the Director | Before the prototype playtests |
| O-H4 | **How testers reach the build:** Studio Team Test with the human's collaborators, or a private test place that the human publishes (agents never publish). The same choice decides creator footage before launch (§11.3) | Human | Before the prototype playtests |

**For the Economist.** The v1 requests are answered by the accepted `economy-sheet.md` (T-0008), including the D6 timing (the sheet uses 180 s calls and the guard from 60 s before to 30 s after a storm, §13) and a paste-ready prototype subset (§14). Remaining:

| Id | Question | Owner | Due |
|---|---|---|---|
| O-EC1 | The model's walks to the pier (`travelSecondsByIsland`: Lantern Reef 30 s, Gustwhistle 40 s, Thunderhead 50 s) are longer than the world plan's measured walks to the Open Pier (at most 27.5, 17.0 and 16.2 s; Pebble Cove 6.9-12.1 s against the model's 10; world plan §4). The storm numbers away from Pebble Cove are therefore conservative: real players get more eye bites and a higher hook rate per storm. Refresh them; no GDD target changes | Economist | Balance pass (POLISH-05) |
| O-EC2 | The second prestige layer before New Tide 12 (with the Designer, O-DS2) | Economist and Designer | Before launch |

**For the Monetization Designer (T-0009):** Sky Bell prices for three products and their copy, for a shared bonus of +25% Sky luck (§4.10); dropping the template's Server Luck product; resizing every Robux-linked luck item into the +25% paid cap; Auto Reel limits; capacity products; whether coin packs exist.

**For the Worldbuilder.** The v1 requests are met by the accepted `world-plan.md` (T-0011): no front path crosses the sheltered Dock Ripple's cell, four `Callable` harbour spots including the Open Pier, every walkway point within 29.6 s of each, the Dock Ripple 6.9 s from the Open Pier, and the prototype subset and routes of §13.2. The ferry wording (world plan §14 question 5) is answered in §4.5 and the first-frame question (question 1) in §3.1. Remaining:

| Id | Question | Owner | Due |
|---|---|---|---|
| O-W1 | Call the Thunderhead nest "Thunder Nest" (the economy sheet's name) instead of "Storm Nest" in world plan §6.4; the id `storm_nest` stays | Worldbuilder | Before the build stage |
| O-W2 | The prototype's bridge-1 stub sign shows the name "Lantern Reef" only, with no price, because nothing beyond the Rod can be bought in the prototype (brief requirement 2) | Worldbuilder | Prototype world task |

**For the Designer (open design work).**

| Id | Question | Owner | Due |
|---|---|---|---|
| O-DS1 | Name the 37 species slots and 8 companions the economy sheet leaves as ids (§4.6; sheet §6, §9.2), and set base kg per species within the sheet's tier values | Designer | Before the build stage |
| O-DS2 | Design the second prestige layer ("Great Tide" or similar) and multi-tide before New Tide 12, which a typical player reaches around day 10 (§4.7; sheet §7) | Designer, with the Economist | Before launch |

**For the Engineer:** O-E1 confirm the deterministic schedule module and its cost; O-E2 confirm the server-owned ring judging with the latency allowance on real phones; O-E3 a restore path for a Sky Bell call lost when the server shuts down after the buyer left; O-E4 which phones support vibration through `HapticService` (fog's third signal is optional).

**For the Director:** O-D1 Aurora Night windows for time zones; O-D2 schedule the second chart snapshot the pitch asked for before the prototype verdict.

**Design questions the prototype settles:** Great Storm every 15 against 20 minutes; server size 8 against 12; ring against hold-to-reel on touch; whether fog's dip reads on a small phone without sound; whether the first frame reads as "weather and a storm" without a shower in it (§3.1); whether players still help pull when a help pays about one catch (§4.3); whether the Gusts sway is cozy enough (Gusts is tested at the build stage, because the prototype has Showers and Sea Fog only).

---

## 13. Prototype (DESIGN-09, feeds PROTO-01 to PROTO-04)

The pitch was approved for a **prototype only, with go/stop on the twist tests** (2026-10-24). The full build brief, ready to queue for the Engineer, is **`games/stormcatch/docs/specs/prototype.md`**. This section gives its scope, timetable, playtest protocol and the go/stop rule.

### 13.1 Scope

| In | Out |
|---|---|
| The moment loop with juice layers 1-4 (Clear, Showers, Sea Fog ring modes; fog hook and mystery reveal) | Gusts, Rainbow, Aurora Night |
| Showers and Sea Fog fronts moving across the 3 prototype spots on a deterministic timetable (the sheltered Dock Ripple at spawn stays Clear; fronts drift between the other two) | Islands 2-4, bridges, ferry |
| A minimal Sky Dial (storm countdown and next 3 events) and spot weather icons | Sky Journal, Almanac, Tide Pots, calendar, codes |
| One upgrade line: Rod | Lure, Boots, Pal Pouch, companions, nests, New Tide |
| One Great Storm (every 15 min) with the co-op pull and Charged flashes at the Open Pier | Paid products of any kind, the Sky Bell |
| Onboarding steps 1-7 (§3.3) | Invites, referrals, records board |
| A server catch log and QA commands for the tests | Final art (placeholder parts and built-in sounds) |

Content: 11 species (6 Clear, 2 Showers-only, 2 Sea Fog-only, 1 Stormborn), marks Drizzled, Misty and Charged. Every value is economy sheet §14: base coins Common 5, Uncommon 10, Rare 20, Epic 50 and the Rumblefin (Mythic, the only Stormborn) 250; Hushgill is Rare; the size roll is the launch lognormal; Rumblefin hooks on 4.0% of eye bites; helpers get 10%. The launch hook pity (60 eye bites) is left out, because about 15-20 eye bites per storm cannot reach it in a 20-minute playtest.

### 13.2 Prototype weather timetable (identical in every server)

Spots and front paths are the world plan's prototype subset (world plan §12; positions in §6.5): **`cove_dock`** (Dock Ripple, sheltered, at spawn), **`cove_shallows`** (Cove Shallows) and **`pier_head`** (Open Pier, the storm eye). Showers drifts 66 studs from the pier to the shallows; Sea Fog enters from a fog bank off the Lantern Reef edge at (-80, 0, -110), then moves to the shallows and the pier. No drift leg comes within 52 studs of the dock cell's centre. The cycle restarts every 900 s at :00, :15, :30 and :45 UTC. The timetable is unchanged in v2 (first-frame decision, §3.1).

| Seconds into cycle | `cove_dock` | `cove_shallows` | `pier_head` |
|---|---|---|---|
| 0-180 | Storm | Storm | **Storm eye** |
| 180-200 | Clear | Clear | Clear |
| 200-300 | Clear | Clear | **Showers** |
| 300-400 | Clear | **Showers** | Clear |
| 400-420 | Clear | Clear | Clear |
| 420-520 | Clear | **Sea Fog** | Clear |
| 520-620 | Clear | Clear | **Sea Fog** |
| 620-640 | Clear | Clear | Clear |
| 640-740 | Clear | Clear | **Showers** |
| 740-840 | Clear | **Showers** | Clear |
| 840-900 | Clear (the sky darkens toward the storm) | Clear | Clear |

Properties (checked by unit tests): 3 fronts per cycle, each visiting both front spots for 100 s (a design value inside the 90-120 s linger), so at any non-gap moment one front spot is covered and the other two spots are Clear. Every arrival is visible on the Sky Dial at least 60 s ahead. The longest wait for rain from any join time is 260 s, about 4.3 min (onboarding step 7). **Front coverage outside the storm is 600 / (3 × 720) = 27.8%**, close to the launch design's "about a quarter" and the baseline for twist test B.

### 13.3 Playtest protocol (run by the QA Tester and the Newcomer, with the human's testers per O-H3 and O-H4)

1. **Newcomer sessions:** at least 5 testers, each on a fresh profile at a phone-size screen, no help, 20 minutes of play. Observer notes: hesitation points and where they walk when a front is announced. Screenshot at 10:00 (test 5). At 20:00, ask in order: the 100th-time rating (test 2), "You can stop now" and watch 2 minutes, the one-sentence question (test 7), then the twist A question. The upgrade-feel question is asked right after their first Rod upgrade (test 3).
2. **Storm session:** at least 3 testers together through one Great Storm (`forceStorm` allowed; storm time is excluded from twist test B). Log landing times solo and with helpers; note who walks to the pier unprompted; ask "Was it more fun with the others?" (test 4).
3. **Silent clip:** record a 10-second storm landing with the UI hidden and muted; show it to 3 people with no context (test 6).
4. **Agent runs:** the Newcomer agent's fresh-profile runs count for tests 1, 5 and 6 and for mechanical checks. They do not count for twist test A or the ratings in tests 2, 3 and 7, which need people.
5. **Data:** `twistStats` and `exportLog` (QA commands) after every session; the report uses `vault/18-templates-and-checklists/playtest-report-template.md` and is stored in `games/stormcatch/playtests/`.
6. **Verdict:** the Designer reports the seven loop tests and both twist tests with evidence (PROTO-02) and recommends continue, pivot or stop (PROTO-04). **The human decides** and records it.

### 13.4 Go/stop rule

Applied in this order:

1. **30-second test fails:** fix the onboarding and re-run with new testers before judging the twist. This is not a verdict on the game.
2. **Two or more of loop tests 2-7 fail:** the loop needs redesign (`core-loop-design.md`: "A loop that fails two or more of them needs redesign"). Recommendation: **pivot** the failing parts, whatever the twist results.
3. **Twist tests:**

| Twist A (feel) | Twist B (line time under fronts) | Recommendation |
|---|---|---|
| Pass | 45% or more | **Go** to the build stage |
| Pass | 30-44% | **Iterate once** (3 days or less: stronger front rewards, a louder forecast, shorter walks), then re-run B with 5 new testers. 45% or more: go. Otherwise: **pivot (a)** |
| Pass | under 30% | **Pivot (a):** weather becomes fixed per island on a timetable; keep the ways of fishing and drop the chase |
| Fail | 30% or more | **Iterate the ring modes once**, then re-run A with 5 new testers. Pass: apply the B rows above. Fail: **stop** (the weather reads as decoration, pitch risk 1) |
| Fail | under 30% | **Stop** (recommend parking the game) |

The pitch's continue condition (twist A, twist B and the 30-second test all pass) is the "Go" row. The pitch's stop condition (under 30% of catches under fronts) is kept on line time, and its pivot option (a) comes from sketch risk 1.

---

## Appendix A: loop-sketch statements this GDD supersedes

| Sketch location | Statement (quoted or summarised) | Superseded by | Now |
|---|---|---|---|
| §1 | "Working title: Stormcatch. The human decides the store title... (see open questions)" | D3 | Title "Reel the Storm"; id `stormcatch` (§1) |
| §3, last paragraph | "Deliberately left out: ... buying or summoning weather at all at launch, for coins or Robux" | D6 | Weather can be called for Robux through the Sky Bell under the four D6 constraints (§4.10). Coins still cannot call weather |
| §4.3, Influence row | "Nobody can buy or summon weather at launch, for coins or Robux... A cooperative 'call a front' idea is parked as a post-launch candidate" | D6 and this GDD | Robux calls exist (§4.10); the parked free co-op Sky Bell is merged into the paid call as its in-world form, and its free charging is dropped (§4.10 decision) |
| §4.3, Forecast and Share rows (implicit) | Weather is the same in every server, so the forecast is true for everyone | D6 constraint 1 | Natural weather and the Great Storm are the same in every server; calls are added in one server only, marked "this server" on the Sky Dial, and never remove or move anything already forecast (§4.2, §4.10) |
| §4.2 Great Storm row | "Tap on a lightning flash for a Charged catch" (for every storm catch) | This GDD | Kept for regular catches at the storm eye (v2: away from the eye the storm fishes as Clear, §4.2). Stormborn are Charged by chance, raised by friends among the helpers, as sketch §4.4 item 3 says (§4.3) |
| §4.4 item 2 | "If the storm ends first, the giant slips away at no cost" | This GDD | A giant hooked before the storm ends always lands; no new hooks after it ends (§4.3) |
| §4.5 Fisch and Fish It! rows | "Nothing can summon weather"; "Weather can't be bought" | D6 (the pitch already corrected this) | Both games and ours let players summon weather, so summoning is not a difference |
| §4.5 twist check | "Summoning or buying weather: Left out at launch, on purpose" | D6 | Included as a paid familiar layer, not part of the twist |
| §5.8 step table | Steps 10-12 order and conditions; step 13 "logged on the first storm after step 12" | This GDD | Step list in §3.3 (Tide Pot 10, bridge 11, 10 minutes 12, storm 13 on `stormsJoined >= 1`) |
| §7 Sky Bell row | "Cut from launch... Parked as a post-launch candidate" | D6 and this GDD | Sky Bell calls at launch, size M, build stage (§9.4) |
| §8 IP notes | "Our design has no weather-summoning items at all" | D6 | The Sky Bell needs an original name and look (the name "Sky Bell" is invented) |
| §8 IP notes | "Open: ... Nobody has run a trademark search for 'Stormcatch' or 'Reel the Storm'. That is for the human." | D3 | Closed: no search, by the human's choice; no open trademark item |
| §9 row 1 | Title scores 1 ("a verb-first store title... would score 2") | D3 | Scores 2; the hit sheet reads 18/20 (pitch cross-check) |
| §10 twist test B | "45% or more of catches under fronts" | This GDD | Measured on line time, thresholds unchanged (§2.4) |
| §10 twist test A | "After 15 minutes" | This GDD | At 20:00, scored only on testers who fished both weathers, by two raters (§2.4) |
| §12 questions 1-4 for the human | Maturity, paid random items, title, summoning | D5, D2, D3, D6 | Answered; new questions in §12 |
| §5.1 "15 coins is the template's first-upgrade cost" | Template value as the Rod price | This GDD and economy sheet §4 | The Rod's first price stays 15 coins (economy sheet §4, §14); `coinsForStep4 = 15` |
| (new) | The template's Gems | This GDD | Coins only (§5) |

Everything else in the sketch (the cozy rules, weather modes, islands, content floor, social reason, server size, update unit, risks and comparables) is carried into this GDD.

## Sources

- Human decisions: `games/stormcatch/docs/decisions.md` (D1-D6, 2026-10-24). Pitch: `games/stormcatch/docs/pitch.md` (approved 2026-10-24). Market scan: `games/stormcatch/docs/market-scan.md` (T-0001, 2026-10-24; comparable mechanics keep the scan's verification labels). Loop sketch: `games/stormcatch/docs/loop-sketch.md` (T-0002).
- Economy sheet: `games/stormcatch/docs/economy-sheet.md` (T-0008, accepted 2026-10-25; §15 lists its changes to v1), with `handoffs/T-0008.md` and the model output `models/economy_model_output.txt` (md5 4a409553dcea425bee81ad30b2134f4f). World plan: `games/stormcatch/docs/world-plan.md` (T-0011, accepted 2026-10-25), with `handoffs/T-0011.md` and `models/world_layout_output.txt` ("All checks pass"). Both read for v2 on 2026-10-25.
- Vault (all dated 2026-10-24): `00-start-here/hit-formula.md`, `01-first-five-minutes/first-session-blueprint.md`, `01-first-five-minutes/onboarding-patterns.md`, `01-first-five-minutes/first-session-killers.md`, `02-core-loop/core-loop-design.md`, `02-core-loop/game-feel-and-juice.md`, `02-core-loop/session-structure.md`, `02-core-loop/clip-moments-and-shareability.md`, `03-rarity-and-rng/collection-and-variants.md`, `04-progression-and-economy/progression-architecture.md`, `04-progression-and-economy/idle-and-offline-progression.md`, `09-monetization/monetization-compliance.md`, `10-retention-and-social/retention-systems.md`, `10-retention-and-social/social-systems.md`, `12-live-ops-and-launch/user-acquisition.md`, `12-live-ops-and-launch/working-with-content-creators.md`, `14-genre-playbooks/fishing-and-collection.md`, `14-genre-playbooks/grow-and-farm.md`, `16-ai-studio-operations/build-briefs.md`, `16-ai-studio-operations/quality-gates.md`, `17-policy-and-business/age-ratings-and-audience.md`, `18-templates-and-checklists/gdd-template.md`, `18-templates-and-checklists/playtest-report-template.md`, `20-anime-games/anime-community-updates-and-codes.md`, `21-hits-and-trends/anatomy-of-a-hit.md`, `21-hits-and-trends/viral-and-social-mechanics.md`.
- Template (read 2026-10-25): `template/README.md`; `games/stormcatch/project/src/shared/Config/` (`Onboarding`, `Economy`, `Upgrades`, `Zones`, `Products`, `Rewards`, `Analytics`, `Remotes`, `Game`, `Pets`); `src/server/Systems/` (`Onboarding`, `Purchases`, `Nodes`, `QA`); `src/shared/Util/Stats.luau`; `src/server/Services/LiveConfig.luau`; `tests/Economy.spec.luau`.

Related: [Decisions](decisions.md) · [Pitch](pitch.md) · [Loop sketch](loop-sketch.md) · [Market scan](market-scan.md) · [Economy sheet](economy-sheet.md) · [World plan](world-plan.md) · [Prototype build brief](specs/prototype.md)
