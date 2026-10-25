# Prototype build brief: Reel the Storm

Written by the Designer (T-0007, 2026-10-25) as a ready-to-queue brief. Design source: `games/stormcatch/docs/gdd.md` §2.4, §4.1-§4.3 and §13. Queue it with `python3 agents/studioctl.py task add --game stormcatch --title "Build the Reel the Storm prototype" --owner engineer --stage prototype --brief games/stormcatch/docs/specs/prototype.md --gates PROTO-01`. The Director decides when, after the design gate.

## Title
Build the Reel the Storm weather-fishing prototype

## Owner
engineer

## Game / stage
stormcatch / prototype

## Outcome
stay: a playable prototype that answers the approved go/stop question: is each weather a different way to fish (twist test A), and do players follow the fronts (twist test B)? No paid products.

## Context
The human approved a prototype only, with go/stop on the twist tests (2026-10-24, `games/stormcatch/docs/decisions.md`). The design lives in `games/stormcatch/docs/gdd.md`. Every rule below is copied from it, so this brief can be built without it. Numbers marked "economy sheet" come from the prototype subset table in `games/stormcatch/docs/economy-sheet.md` (T-0008). Where that table does not give a value, use the fallback in this brief and mark it in config with the comment `-- fallback: prototype brief`. Fallbacks are first-pass estimates, and the sheet always wins. The spot layout comes from the prototype subset in `games/stormcatch/docs/world-plan.md` (T-0011); the roles and distances below must hold. Project: `games/stormcatch/project/` (a copy of `template/`; read `template/README.md`).

## Requirements
1. **Scope.** Players can reach only what is listed in this brief: the Cast/Reel/Pull button, the coin counter, the Rod bar, the Shop's Upgrades tab (Rod only), the Sky Dial strip, the onboarding hints and Settings. Template features outside the scope (zones 2-5, eggs, pets, rebirth, daily and playtime rewards, codes, the store tab, server luck) have no UI entry and no world object in the prototype. All pass and product ids stay `0`. Set `Config/Game.luau` `name = "Reel the Storm"`.

2. **World (placeholder parts).** Three spots on Pebble Cove, ids and positions from the prototype subset of the Worldbuilder's layout (`games/stormcatch/docs/models/world_layout_output.txt`; `world-plan.md` (T-0011) wins if it changes them). Each is a part tagged `ResourceNode` with `NodeId`, `ZoneId = "pebble_cove"`, `SpotKind = "regular"` and the attributes below:

   | NodeId | Name shown | Role | Attributes |
   |---|---|---|---|
   | `cove_dock` | Dock Ripple | Spawn spot in front of `PlayerSpawn`, which faces it; under the harbour roof | `Sheltered = true` (no front ever covers it) |
   | `cove_shallows` | Cove Shallows | Front spot; Sea Fog enters here from the island edge | |
   | `pier_head` | Open Pier | Front spot; the Great Storm eye | `StormEye = true` |

   Every spot is within 160 studs (10 s at walk speed 16) of its nearest neighbour, and every pair is within 240 studs (15 s); the layout model gives 89, 110 and 193 studs. From spawn the camera sees the water, a shower over the far end of the cove and a dark storm cloud on the horizon. A ripple is a flat cylinder with a neon ring and a soft bob.

3. **Fishing core** (new server system `Fishing`, new client controller `Reel`, config `Config/Fishing.luau` and `Config/Species.luau`):
   1. **Cast.** One Cast button in the bottom-right thumb zone, 56 px or larger. It casts at the nearest spot within 28 studs (the template's `Economy.hitRange`). With none in range, it reads "Walk to a ripple" and the guide beam points to the nearest spot; tapping a spot walks the avatar there (template `Interact` behaviour). The client sends `Cast(spotId)`. The server rejects the cast unless the spot exists, the player is within 28 studs plus 8 studs of latency margin, no line is out and 0.5 s have passed since the last line ended.
   2. **Bite.** The server waits a bite time drawn for the spot's weather at cast time (economy sheet; fallback, uniform: Clear 2-5 s, Showers 1-2.5 s, Sea Fog 3-7 s, Storm 2-5 s). At bite time it rolls species, size and mark for the weather **at bite time** and sends `Bite` with the tier only. In Sea Fog it sends no species until landing.
   3. **Signals.** Clear and Storm: "!" over the bobber and a splash sound; the ring starts at once. Showers: a big splash and "!"; the ring starts at once. Sea Fog: **no "!"**. The bobber dips under (large and clear), a low chime plays, and the phone vibrates through `HapticService` where supported. The player must tap within 3.0 s to hook. A missed hook means the fish nibbles off silently and a new bite comes after a fresh wait, at no cost.
   4. **Ring.** A marker travels round a ring centred above the button, and each tap on the green arc is one step. The server owns the ring: it stores the start time, lap time and arc position, and judges each `ReelTap` on its own clock with a latency allowance of min(player ping, 250 ms) + 60 ms. Taps under 0.15 s apart are ignored.

      | Mode | Lap | Green arc | Steps (Common / Uncommon / Rare / Epic / Stormborn) | Miss budget | Notes |
      |---|---|---|---|---|---|
      | Clear | 1.6 s | 90° | 1 / 2 / 3 / 3 / see req. 9 | 3 | |
      | Showers | 1.1 s | 150° | 1 / 1 / 2 / 2 / – | 3 | |
      | Sea Fog | 1.8 s | 90°, ring drawn at 40% opacity, marker at full | 1 / 2 / 3 / 3 / – | 4 | Ring appears only after the hook tap. A dark silhouette scales up per good step. Species, kg and mark stay hidden until landing |
      | Storm (every spot during the storm) | 1.6 s | 90° | 1 / 2 / 3 / 3 / see req. 9 | 3 | A landing tap inside a flash window gives the Charged mark |

      Going over the miss budget, or 12 s without landing, means the fish swims off: no cost, and Cast is back within 1 s.
   5. **Land.** The fish leaps out (client), the server pays coins, and the catch card shows name, kg, rarity colour, mark stamp, coins and "NEW!" for a first-of-species. There is no fish inventory and no selling step.
   6. **First catch of a profile:** a scripted Pebble Minnow, 0.8 kg, Common, with the bite at 2.0 s, 1 step and no escape possible. It pays 12 coins.
   7. **First catch under Showers of a profile:** a guaranteed Pitterpike (Rare) with the Drizzled mark.

4. **Juice (PROTO-01).** Every catch gets layers 1-4 of `vault/02-core-loop/game-feel-and-juice.md`: a reel tick on each good tap and a landing splash (±10% pitch, two variants), the bobber and fish reacting, a "+N" popup flying to the coin counter, and a counter bump. Rare and Epic add a particle burst, an avatar cheer, a tiny camera shake and a soft white flash. The shake and flash are switched off by the template's reduce-motion setting. Stormborn add a banner to the whole server. Popups and emitters are pooled; at most 10 popups show at once. Sounds: the template's built-in ids in `Config/Game.luau` only.

5. **Content and numbers.** The economy sheet's prototype subset table wins. Fallbacks (first-pass estimates):

   | Table | Species (tier) | Fallback odds |
   |---|---|---|
   | Clear (and storm, away from the eye) | Pebble Minnow (C), Bobblefin (C), Sandskipper (C), Tidetail (U), Kelpnibbler (U), Copperscale (R) | Common 70%, Uncommon 24%, Rare 6%; equal within a tier |
   | Showers-only | Splashkin (U), Pitterpike (R) | 25% of Showers bites roll this table (Splashkin 80%, Pitterpike 20%); the rest roll Clear |
   | Sea Fog-only | Hushgill (U), Lanternfin (E) | 30% of Sea Fog bites roll this table (Hushgill 75%, Lanternfin 25%); the rest roll Clear with Rare weight x2 |
   | Stormborn (eye only, during the storm) | Rumblefin | Requirement 9 |

   Fallback values: base coins Common 10, Uncommon 25, Rare 80, Epic 250, Rumblefin 1,500. Size factor uniform 0.8-1.25, multiplying both value and kg. Base kg: Common 0.8, Uncommon 2, Rare 5, Epic 12, Rumblefin 180. Marks (one per fish, never stacked): Drizzled on 20% of Showers catches (x1.5), Misty on 15% of Sea Fog catches (x2), Charged by skill only (x3). Rod: the template's `power` line renamed, `id = "rod"`, `name = "Rod"`, `baseCost = 15`, `costGrowth = 1.28`, `effect = 1.14`, `maxLevel = 30` (template `Config/Upgrades.luau` values). All luck is 1.0 (no Lure in the prototype). The friend bonus stays off.

6. **Weather timetable.** Write a pure module `src/shared/Util/WeatherSchedule.luau` with Lune tests. The state depends only on UTC time t (plus the QA offset), so every server agrees. The cycle is 900 s long and starts at each :00, :15, :30 and :45 UTC (`cycleTime = (t + offset) % 900`).

   | cycleTime (s) | cove_dock | cove_shallows | pier_head |
   |---|---|---|---|
   | 0-180 | storm | storm | storm (eye) |
   | 180-200 | clear | clear | clear |
   | 200-300 | clear | clear | showers |
   | 300-400 | clear | showers | clear |
   | 400-420 | clear | clear | clear |
   | 420-520 | clear | fog | clear |
   | 520-620 | clear | clear | fog |
   | 620-640 | clear | clear | clear |
   | 640-740 | clear | clear | showers |
   | 740-840 | clear | showers | clear |
   | 840-900 | clear (the sky darkens toward the storm) | clear | clear |

   Fronts drift visibly from one front spot to the other over the water, never over the dock cell. API: `stateAt(t): {[spotId]: Weather}`, `arrivalsAfter(t, n): {{at: number, spot: string, weather: Weather}}` (front arrivals only), `stormAt(t): {active: boolean, startsAt: number, endsAt: number}`, `coverage(t0, t1): number` (the time-weighted share of the three spots under showers or fog, excluding storm time). Interval boundaries are start-inclusive and end-exclusive.

   Visuals (placeholder, client only):
   - **Showers:** a dark translucent cloud part 30 studs above the spot and a rain emitter (rate 60 or less, live only while the camera is within 150 studs).
   - **Sea Fog:** a grey translucent volume of radius 30 studs, with `Atmosphere` density raised while the camera is inside it.
   - **Storm:** lighting tweens darker over 3 s, a storm cloud sits over the pier, and lightning is a 0.15 s brightness flash. Under reduce motion, the flash is replaced by a line glow and a low rumble.
   - **Budgets:** use the per-weather budgets in `art-direction.md` (T-0010) when they exist.

7. **Sky Dial (minimal).** A strip at top centre that appears after the first Rod purchase. It shows "Storm m:ss" at all times, highlighted from 5:00, then the next three front arrivals as "<icon> Rain → Cove Shallows 0:40". A floating icon over each spot shows its current weather. The server sends `WeatherState` on every change; the client counts down locally from server time.

8. **Rod line.** Only the `rod` upgrade exists, bought in the template Shop's Upgrades tab. The rod is a part held by the avatar: 5 studs long plus 0.4 per level, with a new colour every 3 levels.

9. **Great Storm and co-op pull** (new server system `StormPull`, client `StormHUD`):
   1. **Storm.** Runs at cycleTime 0-180 s. During it every spot uses the Storm ring. The sky darkens over at least 3 s, and storm audio swells over at least 3 s.
   2. **Lightning.** Flashes are server-timed every 6-9 s (uniform), each with a 0.5 s glow on the line before it and a 0.8 s window that counts as "on a flash". All clients at the pier see the same flash times.
   3. **Stormborn.** Rumblefin bites only at `pier_head` during the storm. The economy sheet gives the chance; fallback: 2.5% per bite at the pier (the Economist's model value, `models/economy_model.py`, 2026-10-25), at most 1 per player per storm. Storm playtests may use `forceStormborn`. No new Stormborn after cycleTime 180.
   4. **Pull.** When a Stormborn is hooked, a big **Pull!** button replaces Cast for every player within 40 studs of the angler. The angler always pulls while hooked, at 100/45 meter points per second. A helper is active if they sent `PullTap` in the last 1.0 s. Each active helper adds 0.875 of the angler's rate, with at most 7 helpers counted. Landing time = 45 / (1 + 0.875 × helpers): 45 s solo, 12.4 s with 3 helpers, 10 s with 4. A helper helps the nearest pull in range.
   5. **Charged.** A Stormborn is Charged by chance, rolled at landing (economy sheet; fallback: 25%, +5% per friend of the angler among the active helpers, capped at 50%). A Charged giant lands with a bolt striking the line and the x3 mark. Regular storm catches are Charged only by a landing tap inside a flash window (requirement 3.4).
   6. **No fail.** A giant hooked before the storm ends always lands. The storm visuals stay over the pier until the last pull lands, at most 45 s; the timetable does not change.
   7. **Rewards.** The angler gets the full catch. Each helper whose taps counted gets a coin share minted on top. The economy sheet gives the share; fallback: 25% of the giant's value, for at most 3 paid helps per helper per storm. Every helper's card reads "Witnessed: Rumblefin".
   8. **Banner.** One banner to the whole server: "<angler> and N anglers landed a [CHARGED] Rumblefin, X kg!" The angler holds the fish in a catch pose for 3 s, visible to all.

10. **Onboarding.** Replace the step list in `src/shared/Config/Onboarding.luau` with these 7 steps (`lastStep = 7`). Add the guide kind `weather` to `StepDef` and to `src/client/Controllers/Guide.luau`: it beams to the spot under Showers now, or, if none, to the next one due, showing its ETA. Set `coinsForStep4` to the Rod's first cost (15 with the fallback). Update the conditions in `src/server/Systems/Onboarding.luau`:

    | Step | name | guide | hint | Condition |
    |---|---|---|---|---|
    | 1 | Joined | none | "" | profile loaded |
    | 2 | First Cast | node | "Tap to cast" | a `Cast` accepted by the server |
    | 3 | First Catch | node | "Tap on green!" | 1 catch or more |
    | 4 | Earned Rod Coins | node | "Catch more fish" | total coins earned >= `coinsForStep4` |
    | 5 | Opened Shop | shop | "Open the shop" | shop panel opened |
    | 6 | First Rod Upgrade | upgradePower | "Buy a better rod" | rod level 1 or more |
    | 7 | Caught in Rain | weather | "Fish in the rain!" | a catch whose weather was Showers |

11. **Measurement for the playtests.**
    - **Catch log.** The server keeps a session log with one row per line: player alias (P1, P2, ... per server; never names or user ids), seconds since join, spot, weather at bite, `underFront` (showers or fog), `lineSeconds` (cast to land, escape or leave), result, species, tier, mark, kg, coins, misses, `forced` (true if a QA override applied).
    - **Line time.** Each line's seconds are split per second by the spot's weather from `WeatherSchedule`, into under-front, clear and storm buckets.
    - **`twistStats`** (QA command) returns, per alias and pooled: under-front line seconds and total line seconds in the window from max(300 s after join, the step 7 time) to now, excluding storm and forced seconds; the share; the timetable's coverage over the same windows (time-weighted); catches by weather; and the times of first catch, step 6 and step 7.
    - **`exportLog`** (QA command) prints the log as CSV lines to the output.
    - **Other QA commands:** `forceWeather <spot> <clear|showers|fog> <seconds, at most 120>` (logged, rows marked forced), `forceStorm` (a 180 s storm now in this server; excluded from twist B), `forceStormborn` (the caller's next bite at `pier_head` hooks a Rumblefin), `setScheduleOffset <seconds>`, and the template's `wipeData` for fresh newcomer runs.
    - All commands use the template `QA` system (Studio and allowlisted testers only; every use logged).

12. **Analytics.** Add custom events `Cast`, `Catch`, `ReelResult`, `FrontEntered`, `StormJoined` and `StormLanded` to `src/shared/Config/Analytics.luau`, with the fields listed in GDD §10, logged through `src/server/Services/Analytics.luau`. They record only in published games; the QA log is the prototype's evidence.

13. **Security and data.**
    - Every new remote is declared in `src/shared/Config/Remotes.luau` with a rate limit and handled through `Net.handle` with `Util/Validate`. Proposed limits: `Cast` 2/s burst 3; `HookTap` 4/s burst 6; `ReelTap` 8/s burst 12; `PullTap` 6/s burst 10.
    - The server decides bites, rolls, ring judgement, pull progress and payouts.
    - Any profile shape change (for example `stats.catches`, `stats.stormsJoined`) bumps `Data/Schema.luau` `VERSION` and adds a migration step.

14. **Pure logic tested.** Lune tests in `tests/` cover `WeatherSchedule`, the ring judgement (given lap, arc, start time and tap time, with the allowance) and the pull meter (contributors over time to landing time).

## Out of scope
Gusts, Rainbow, Aurora Night, islands 2-4, bridges, the ferry, Lure, Boots, Pal Pouch, companions and nests, the Sky Journal, Almanac, Tide Pots, the daily calendar, codes, the Sky Bell, invites and referrals, the records board, any paid product or purchase prompt, final art and audio, and publishing.

## Constraints
House rules in `CLAUDE.md`: never publish; Saved uploads only, and only if the human asks for one for playtests (GDD open question O-H4); the server owns everything of value; every remote is validated and rate-limited; player data is never lost. Use only template built-in sounds and placeholder parts, so nothing new enters the asset index. Numbers come from the economy sheet's prototype subset; fallbacks are marked in config. Do not loosen or skip tests to get green.

## Acceptance criteria
- PROTO-01: on 20 catches with sound and 20 muted, every catch shows layers 1-4 (tick and splash sounds with pitch variation, bobber and fish reaction, the "+N" popup flying to the counter, the counter bump); Rare and Epic catches show strictly more feedback than Common ones
- On a fresh profile at a phone-size Device Simulator screen, Cast is usable within 10 s of spawn and the first fish lands within 30 s with only the on-screen hints (catch log: first catch at 30 s or less since join)
- Onboarding steps 1-7 log in order on a fresh profile; a profile already at step 7 shows no guide after rejoin
- The first Rod upgrade is bought through the guided shop at the economy sheet's target time (fallback numbers: after the second catch)
- With `forceWeather` on `cove_shallows`, Clear, Showers and Sea Fog each show their ring lap, arc and opacity from requirement 3.4 and their own signal; in Sea Fog no "!" appears, the ring appears only after a hook tap within 3 s of the dip, and species, kg and mark stay hidden until landing (one screenshot per mode)
- `WeatherSchedule` Lune tests pass: the same t gives the same state; every timetable boundary matches requirement 6; every arrival is returned by `arrivalsAfter` at least 60 s before it happens; `coverage` over cycleTime 180-900 equals 0.2778 within 0.001; `cove_dock` is `clear` or `storm` at every t
- Two clients in one Studio server show the same weather on the same spot at the same moment and the same Sky Dial events (screenshot pair)
- Storm (cycle start or `forceStorm`): the sky darkens over 3 s or more; Rumblefin bites only at `pier_head`; a solo pull lands in 45 s ±2 s; a pull with 3 helper clients lands in 12.4 s ±1.5 s; with the Charged chance set to 1.0 in config the giant always lands Charged with the bolt, and with 0.0 never; a regular storm catch is Charged when its landing tap falls inside a flash window and never otherwise; a giant hooked at storm second 179 still lands (server log excerpts)
- Helpers receive the Witnessed card and the minted share, and the angler's payout is identical with or without helpers (log)
- `twistStats` and `exportLog` return every field in requirement 11, and forced and storm seconds are excluded from the twist share
- No purchase prompt can open: all pass and product ids are 0, and no store UI is reachable
- `python3 agents/studioctl.py check stormcatch` passes and stores a check record (BUILD-01, BUILD-02, BUILD-03); new remotes go through `Net` with rate limits (BUILD-04); no reward is decided on the client (BUILD-05)
- Phone layout screenshots at three Device Simulator phone sizes show the Cast, Reel and Pull button at 56 px or larger in the thumb zone, overlapping neither the thumbstick nor the jump button

## Evidence to return
The check record path; Lune test output; screenshots (each ring mode, the Sky Dial pair, a storm pull with helpers, three phone sizes); server log excerpts for pull timings and onboarding steps; a `twistStats` sample; the list of fallback values used, if any; the files changed.

## Dependencies
The design gate (T-0012) passed; the economy sheet's prototype subset table (T-0008); the world plan's prototype subset (T-0011). Playtests also need the human's answers to GDD open questions O-H3 (testers) and O-H4 (how testers reach the build); the build itself does not.

## Hand off to
qa-tester (golden path, juice pass, device check), newcomer (fresh-profile runs), designer (loop tests, twist tests A and B, and the PROTO-02 and PROTO-04 verdict under GDD §13.4), gatekeeper (prototype gate).

Related: [GDD](../gdd.md) · [Decisions](../decisions.md)
