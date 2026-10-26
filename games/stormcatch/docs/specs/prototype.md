# Prototype build brief: Reel the Storm

Written by the Designer (T-0007, 2026-10-25) as a ready-to-queue brief, and synced with the accepted economy sheet and world plan in T-0013 (GDD v2, 2026-10-25). Design source: `games/stormcatch/docs/gdd.md` §2.4, §4.1-§4.3 and §13. Queue it with `python3 agents/studioctl.py task add --game stormcatch --title "Build the Reel the Storm prototype" --owner engineer --stage prototype --brief games/stormcatch/docs/specs/prototype.md --gates PROTO-01`. The Director decides when, after the design gate.

## Title
Build the Reel the Storm weather-fishing prototype

## Owner
engineer

## Game / stage
stormcatch / prototype

## Outcome
stay: a playable prototype that answers the approved go/stop question: is each weather a different way to fish (twist test A), and do players follow the fronts (twist test B)? No paid products.

## Context
The human approved a prototype only, with go/stop on the twist tests (2026-10-24, `games/stormcatch/docs/decisions.md`). The design lives in `games/stormcatch/docs/gdd.md`. Every rule below is copied from it, so this brief can be built without it. Every number is the accepted economy sheet's value (`games/stormcatch/docs/economy-sheet.md`, T-0008; §14 is the prototype subset, and other sections are named where used), so the brief has no fallback values; if the sheet changes, the sheet wins. The world is the accepted world plan's prototype subset (`games/stormcatch/docs/world-plan.md`, T-0011, §6.5 and §12). Project: `games/stormcatch/project/` (a copy of `template/`; read `template/README.md`).

## Requirements
1. **Scope.** Players can reach only what is listed in this brief: the Cast/Reel/Pull button, the coin counter, the Rod bar, the Shop's Upgrades tab (Rod only), the Sky Dial strip, the onboarding hints and Settings. Template features outside the scope (zones 2-5, eggs, pets, rebirth, daily and playtime rewards, codes, the store tab, server luck) have no UI entry and no world object in the prototype. All pass and product ids stay `0`. Set `Config/Game.luau` `name = "Reel the Storm"`.

2. **World (placeholder parts; world plan §6.5, §9, §12).** Pebble Cove's harbour edge only. Coordinates are Roblox studs: +X east, +Z south (north is -Z), water surface at Y = 0. `PlayerSpawn` (8 x 1 x 8) sits at (0, 4, 0) with orientation (0, 0, 0), so it faces north over the Dock Ripple, under a harbour canopy whose underside is at Y 22. Three spots, each a ripple part tagged `ResourceNode` with `NodeId`, `ZoneId = "pebble_cove"`, `SpotKind = "regular"`, `CellId` (equal to `NodeId`), `CastPoint` (the stand, a Vector3) and the attributes below:

   | NodeId | Name shown | Role | Stand (`CastPoint`) | Ripple centre | Attributes |
   |---|---|---|---|---|---|
   | `cove_dock` | Dock Ripple | Spawn spot under the canopy, 10 studs ahead of spawn and 5 left of the facing line (near edge about 6 studs), so the avatar never hides it | (0, 4, -3) | (-5, 0, -10) | `Sheltered = true` (no front ever covers it) |
   | `cove_shallows` | Cove Shallows | Front spot on Pebble Point's inner shore; Sea Fog enters here from the island edge | (-37, 5, -52) | (-20, 0, -52) | `Callable = true` (unused until the Sky Bell exists) |
   | `pier_head` | Open Pier | Front spot at the front rail of the 36 x 20 pier head; the Great Storm eye | (20, 4, -89) | (20, 0, -104) | `StormEye = true`, `Callable = true` |

   Walks between stands: 89 studs (dock to shallows), 110 (dock to pier) and 193 (shallows to pier), so every spot is within 160 studs (10 s at walk speed 16) of its nearest neighbour and every pair within 240 studs (15 s). Also build three invisible, anchored `WeatherCell` parts (radius 36 studs around the midpoint of each stand and ripple, with `CellId`, `ZoneId` and the cell's `Sheltered` or `StormEye`; collide, touch and query off), one `StormHome` block-out (the Thunderhead anvil cloud over a Thunder Spire block-out, north-east across the lagoon), one `ZoneBounds` for `pebble_cove`, and scenery stubs with no contract tags: the broken bridge 1 on the Pebble Point tip with a sign that reads "Lantern Reef" and no price (nothing beyond the Rod can be bought in the prototype), and the near edge of Lantern Reef with a block-out Great Lantern. From spawn the camera sees the water, the Dock Ripple, both front spots, the bridge stub and the storm cloud on the horizon (world plan §5). A ripple is a flat cylinder 10 studs across with a neon ring and a soft bob. At most 400 placeholder parts (SmoothPlastic and Neon only), no meshes or textures, at most 3 lights (the pier lanterns, storm only), terrain water over the cove and lagoon.

3. **Fishing core** (new server system `Fishing`, new client controller `Reel`, config `Config/Fishing.luau` and `Config/Species.luau`):
   1. **Cast.** One Cast button in the bottom-right thumb zone, 56 px or larger. It casts at the nearest spot within 28 studs (the template's `Economy.hitRange`). With none in range, it reads "Walk to a ripple" and the guide beam points to the nearest spot. Tapping a spot walks the avatar to that spot's `CastPoint`, never to the ripple in the water (the template's `Interact` walks to `node.Position` and needs this change; world plan §9 rule 6). The client sends `Cast(spotId)`. The server rejects the cast unless the spot exists, the player is within 28 studs plus 8 studs of latency margin, no line is out and 0.5 s have passed since the last line ended.
   2. **Bite.** The server waits a bite time drawn uniformly for the spot's weather at cast time: Clear 2.0-5.0 s, Showers 1.0-2.5 s, Sea Fog 2.8-7.0 s, and `pier_head` during the storm 2.0-4.0 s. The other two spots during the storm use the Clear wait (economy sheet §3.2, §14). At bite time the server rolls species, size and mark for the weather **at bite time** and sends `Bite` with the tier only. In Sea Fog it sends no species until landing.
   3. **Signals.** Clear and Storm: "!" over the bobber and a splash sound; the ring starts at once. Showers: a big splash and "!"; the ring starts at once. Sea Fog: **no "!"**. The bobber dips under (large and clear), a low chime plays, and the phone vibrates through `HapticService` where supported. The player must tap within 3.0 s to hook. A missed hook means the fish nibbles off silently and a new bite comes after a fresh wait, at no cost.
   4. **Ring.** A marker travels round a ring centred above the button, and each tap on the green arc is one step. The server owns the ring: it stores the start time, lap time and arc position, and judges each `ReelTap` on its own clock with a latency allowance of min(player ping, 250 ms) + 60 ms. Taps under 0.15 s apart are ignored.

      | Mode | Lap | Green arc | Steps (Common / Uncommon / Rare / Epic / Stormborn) | Miss budget | Notes |
      |---|---|---|---|---|---|
      | Clear (also `cove_dock` and `cove_shallows` during the storm) | 1.6 s | 90° | 1 / 2 / 3 / 3 / – | 3 | |
      | Showers | 1.1 s | 150° | 1 / 1 / 2 / 2 / – | 3 | |
      | Sea Fog | 1.8 s | 90°, ring drawn at 40% opacity, marker at full | 1 / 2 / 3 / 3 / – | 4 | Ring appears only after the hook tap. A dark silhouette scales up per good step. Species, kg and mark stay hidden until landing |
      | Storm (`pier_head` during the storm) | 1.6 s | 90° | 1 / 2 / 3 / 3 / see req. 9 | 3 | A landing tap inside a flash window gives the Charged mark |

      Going over the miss budget, or 12 s without landing, means the fish swims off: no cost, and Cast is back within 1 s.
   5. **Land.** The fish leaps out (client), the server pays coins, and the catch card shows name, kg, rarity colour, mark stamp, coins and "NEW!" for a first-of-species. There is no fish inventory and no selling step.
   6. **First catch of a profile:** a scripted Pebble Minnow, 0.8 kg, Common, with the bite at 2.0 s, 1 step and no escape possible. It pays 12 coins (economy sheet §3.1, §14).
   7. **First catch under Showers of a profile:** a guaranteed Pitterpike (Rare) with the Drizzled mark (economy sheet §3.1, §14).

4. **Juice (PROTO-01).** Every catch gets layers 1-4 of `vault/02-core-loop/game-feel-and-juice.md`: a reel tick on each good tap and a landing splash (±10% pitch, two variants), the bobber and fish reacting, a "+N" popup flying to the coin counter, and a counter bump. Rare and Epic add a particle burst, an avatar cheer, a tiny camera shake and a soft white flash. The shake and flash are switched off by the template's reduce-motion setting. Stormborn add a banner to the whole server. Popups and emitters are pooled; at most 10 popups show at once. Sounds: the template's built-in ids in `Config/Game.luau` only.

5. **Content and numbers** (economy sheet §14 unless named; paste into `Config/Species.luau`, `Config/Fishing.luau` and `Config/Upgrades.luau`).
   - **Tables.** One weighted table per weather; the chance of a species is its weight divided by the table total. Clear is the six `clear` rows. Showers adds the two `showers` rows to Clear. Sea Fog adds the two `fog` rows and doubles every Rare-and-up weight (natural Sea Fog's +100% Sky luck). There is no other luck in the prototype: no Lure, companions or friend bonus.

     | id | Name | Tier | Table | Weight | Base coins | Base kg | Clear (and the storm away from the eye) | Showers | Sea Fog |
     |---|---|---|---|---|---|---|---|---|---|
     | `pebble_minnow` | Pebble Minnow | Common | clear | 26 | 5 | 0.8 | 27.08% | 22.13% | 21.96% |
     | `bobblefin` | Bobblefin | Common | clear | 22 | 5 | 0.8 | 22.92% | 18.72% | 18.58% |
     | `sandskipper` | Sandskipper | Common | clear | 18 | 5 | 0.8 | 18.75% | 15.32% | 15.20% |
     | `tidetail` | Tidetail | Uncommon | clear | 13 | 10 | 2 | 13.54% | 11.06% | 10.98% |
     | `kelpnibbler` | Kelpnibbler | Uncommon | clear | 11 | 10 | 2 | 11.46% | 9.36% | 9.29% |
     | `copperscale` | Copperscale | Rare | clear | 6 | 20 | 5 | 6.25% | 5.11% | 10.14% |
     | `splashkin` | Splashkin | Uncommon | showers | 15 | 10 | 2 | - | 12.77% | - |
     | `pitterpike` | Pitterpike | Rare | showers | 6.5 | 20 | 5 | - | 5.53% | - |
     | `hushgill` | Hushgill | Rare | fog | 6 | 20 | 5 | - | - | 10.14% |
     | `lanternfin` | Lanternfin | Epic | fog | 2.2 | 50 | 12 | - | - | 3.72% |
     | `rumblefin` | Rumblefin | Mythic (the only Stormborn) | storm | - | 250 | 180 | hooked at the eye only (req. 9.3) | | |

     At `pier_head` during the storm, each bite first rolls the Rumblefin hook (requirement 9.3); otherwise it rolls the Clear table.
   - **Value.** Coins = base coins × size factor × mark × 1.14^(Rod level), rounded to the nearest whole coin and at least 1 (design value: whole coins on the card). Rumblefin's 250 is its Mythic tier value at half, the launch rule for Stormborn (economy sheet §8).
   - **Size** (economy sheet §9.3). factor = clamp(exp(N(-σ²/2, σ)), 0.5, 3.0) with σ = 0.25, and σ = 0.30 for Rumblefin. kg = base kg × factor, and value is proportional to factor (mean 1.0, median 0.97; about 4% of fish at 1.5x or more).
   - **Marks** (one per fish, never stacked; economy sheet §9.4). Drizzled on 20% of Showers catches (x1.5), Misty on 15% of Sea Fog catches (x2), Charged x3 (requirement 9).
   - **Rod.** The template's `power` line renamed: `id = "rod"`, `name = "Rod"`, `baseCost = 15`, `costGrowth = 1.28`, `effect = 1.14`, `maxLevel = 30` (the launch maximum is 150, economy sheet §4). If testers stall between minutes 15 and 20, the sheet's lever is `costGrowth = 1.24`; that change comes from the QA report, not from this build.

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

   Fronts drift visibly over the water and never over the dock cell (world plan §7, §12): Showers drifts 66 studs from `pier_head` to `cove_shallows`; Sea Fog enters from a fog bank off the Lantern Reef edge at (-80, 0, -110), then moves to `cove_shallows` and on to `pier_head`. API: `stateAt(t): {[spotId]: Weather}`, `arrivalsAfter(t, n): {{at: number, spot: string, weather: Weather}}` (front arrivals only), `stormAt(t): {active: boolean, startsAt: number, endsAt: number}`, `coverage(t0, t1): number` (the time-weighted share of the three spots under showers or fog, excluding storm time). Interval boundaries are start-inclusive and end-exclusive.

   Visuals (placeholder, client only):
   - **Showers:** a dark translucent cloud part 30 studs above the front's cell and a rain emitter (rate 60 or less, live only while the camera is within 150 studs). Rain falls over the front's own cell, never around a camera that stands outside it, so the Dock Ripple looks sheltered as well as being sheltered.
   - **Sea Fog:** a grey translucent volume of radius 30 studs centred on its cell, with `Atmosphere` density raised while the camera is inside it. Its edge stays at least 14 studs clear of the Dock Ripple's centre (world plan §12).
   - **Storm:** during cycleTime 840-900 the storm cloud moves from the `StormHome` block-out to the eye over the pier; at 0 the lighting tweens darker over 3 s and light rain falls over every spot, and lightning is a 0.15 s brightness flash. Under reduce motion, the flash is replaced by a line glow and a low rumble.
   - **Budgets:** the per-weather budgets in `art-direction.md` (T-0010) section 11 and world plan §10.

7. **Sky Dial (minimal).** A strip at top centre that appears after the first Rod purchase. It shows "Storm m:ss" at all times, highlighted from 5:00, then the next three front arrivals as "<icon> Rain → Cove Shallows 0:40". A floating icon over each spot shows its current weather. The server sends `WeatherState` on every change; the client counts down locally from server time.

8. **Rod line.** Only the `rod` upgrade exists, bought in the template Shop's Upgrades tab. The rod is a part held by the avatar: 5 studs long plus 0.4 per level, with a new colour every 3 levels.

9. **Great Storm and co-op pull** (new server system `StormPull`, client `StormHUD`):
   1. **Storm.** Runs at cycleTime 0-180 s. The sky darkens over at least 3 s, storm audio swells over at least 3 s, and light rain falls over every spot. Only `pier_head`, the eye, fishes as Storm (the 2.0-4.0 s bite wait, the Storm ring with Charged flash taps, and Rumblefin hooks); `cove_dock` and `cove_shallows` keep fishing as Clear (economy sheet §8).
   2. **Lightning.** Flashes are server-timed every 6-9 s (uniform), each with a 0.5 s glow on the line before it and a 0.8 s window that counts as "on a flash". All clients at the pier see the same flash times.
   3. **Stormborn.** 4.0% of bites at `pier_head` during the storm hook a Rumblefin, at most 1 per player per storm (economy sheet §8, §14). The launch hard pity (the next eye bite hooks after 60 eye bites without one) is not built in the prototype: at about 15-20 eye bites per storm it cannot fire in a 20-minute playtest, and storm playtests may use `forceStormborn`. No new Stormborn after cycleTime 180.
   4. **Pull.** When a Stormborn is hooked, a big **Pull!** button replaces Cast for every player within 40 studs of the angler. The angler always pulls while hooked, at 100/45 meter points per second. A helper is active if they sent `PullTap` in the last 1.0 s. Each active helper adds 0.875 of the angler's rate, with at most 7 helpers counted. Landing time = 45 / (1 + 0.875 × helpers): 45 s solo, 12.4 s with 3 helpers, 10 s with 4. A helper helps the nearest pull in range.
   5. **Charged.** A Stormborn is Charged by chance, rolled at landing: 25%, +5% per friend of the angler among the active helpers, capped at 50% (economy sheet §8). A Charged giant lands with a bolt striking the line and the x3 mark. Regular catches at `pier_head` during the storm are Charged only by a landing tap inside a flash window (requirement 3.4); catches at the other spots are never Charged.
   6. **No fail.** A giant hooked before the storm ends always lands. The storm visuals stay over the pier until the last pull lands, at most 45 s; the timetable does not change.
   7. **Rewards.** The angler gets the full catch. Each helper whose taps counted gets 10% of the giant's coin value at the helper's own Rod level, minted on top, for at most 3 paid helps per helper per storm (economy sheet §8, §14). Every helper's card reads "Witnessed: Rumblefin".
   8. **Banner.** One banner to the whole server: "<angler> and N anglers landed a [CHARGED] Rumblefin, X kg!" The angler holds the fish in a catch pose for 3 s, visible to all.

10. **Onboarding.** Replace the step list in `src/shared/Config/Onboarding.luau` with these 7 steps (`lastStep = 7`). Add the guide kind `weather` to `StepDef` and to `src/client/Controllers/Guide.luau`: it beams to the spot under Showers now, or, if none, to the next one due, showing its ETA. Set `coinsForStep4 = 15`, the Rod's first cost (economy sheet §14). Update the conditions in `src/server/Systems/Onboarding.luau`:

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

14. **Pure logic tested.** Lune tests in `tests/` cover `WeatherSchedule`, the ring judgement (given lap, arc, start time and tap time, with the allowance), the pull meter (contributors over time to landing time) and the species tables (every table's chances sum to 1 and match requirement 5 within 0.01 percentage points).

## Out of scope
Gusts, Rainbow, Aurora Night, islands 2-4, bridges (bridge 1 is a scenery stub only), the ferry, rock pools, lantern and far-water ripples, Lure, Boots, Pal Pouch, companions and nests, the Sky Journal, Almanac, Tide Pots, the daily calendar, codes, the Sky Bell, invites and referrals, the records board, the Stormborn hook pity, any paid product or purchase prompt, final art and audio, and publishing.

## Constraints
House rules in `CLAUDE.md`: never publish; Saved uploads only, and only if the human asks for one for playtests (GDD open question O-H4); the server owns everything of value; every remote is validated and rate-limited; player data is never lost. Use only template built-in sounds and placeholder parts, so nothing new enters the asset index. Numbers come from economy sheet §14 and the sections this brief names; do not invent replacements. Do not loosen or skip tests to get green.

## Acceptance criteria
- PROTO-01: on 20 catches with sound and 20 muted, every catch shows layers 1-4 (tick and splash sounds with pitch variation, bobber and fish reaction, the "+N" popup flying to the counter, the counter bump); Rare and Epic catches show strictly more feedback than Common ones
- On a fresh profile at a phone-size Device Simulator screen, Cast is usable within 10 s of spawn and the first fish lands within 30 s with only the on-screen hints (catch log: first catch at 30 s or less since join)
- Onboarding steps 1-7 log in order on a fresh profile; a profile already at step 7 shows no guide after rejoin
- On a fresh profile following the hints, the Rod becomes affordable on the second catch and is bought through the guided shop within 60 s of join (catch log and step 6 time; economy sheet §1 models 45 s)
- Config values equal requirement 5 and economy sheet §14 (species weights, base coins and kg, bite waits, mark chances and multipliers, size σ and clamp, Rod 15 / 1.28 / 1.14 / max 30, Rumblefin hook 0.04, helper share 0.10 with 3 per storm, Charged 0.25 + 0.05 per friend up to 0.50, `coinsForStep4 = 15`), shown by a diff of the Config files against this brief
- Tapping each of the three spots from 20 studs away walks the avatar to that spot's `CastPoint`, and the avatar never enters the water (Studio test, one screenshot per spot)
- With `forceWeather` on `cove_shallows`, Clear, Showers and Sea Fog each show their ring lap, arc and opacity from requirement 3.4 and their own signal; in Sea Fog no "!" appears, the ring appears only after a hook tap within 3 s of the dip, and species, kg and mark stay hidden until landing (one screenshot per mode)
- `WeatherSchedule` Lune tests pass: the same t gives the same state; every timetable boundary matches requirement 6; every arrival is returned by `arrivalsAfter` at least 60 s before it happens; `coverage` over cycleTime 180-900 equals 0.2778 within 0.001; `cove_dock` is `clear` or `storm` at every t
- Two clients in one Studio server show the same weather on the same spot at the same moment and the same Sky Dial events (screenshot pair)
- Storm (cycle start or `forceStorm`): the sky darkens over 3 s or more; Rumblefin bites only at `pier_head`; catches at `cove_dock` and `cove_shallows` during the storm use the Clear bite wait and are never Charged; a solo pull lands in 45 s ±2 s; a pull with 3 helper clients lands in 12.4 s ±1.5 s; with the Charged chance set to 1.0 in config the giant always lands Charged with the bolt, and with 0.0 never; a regular catch at `pier_head` during the storm is Charged when its landing tap falls inside a flash window and never otherwise; a giant hooked at storm second 179 still lands (server log excerpts)
- Helpers receive the Witnessed card and a minted share of 10% of the giant's value, at most 3 per storm, and the angler's payout is identical with or without helpers (log)
- `twistStats` and `exportLog` return every field in requirement 11, and forced and storm seconds are excluded from the twist share
- No purchase prompt can open: all pass and product ids are 0, and no store UI is reachable
- `python3 agents/studioctl.py check stormcatch` passes and stores a check record (BUILD-01, BUILD-02, BUILD-03); new remotes go through `Net` with rate limits (BUILD-04); no reward is decided on the client (BUILD-05)
- Phone layout screenshots at three Device Simulator phone sizes show the Cast, Reel and Pull button at 56 px or larger in the thumb zone, overlapping neither the thumbstick nor the jump button

## Evidence to return
The check record path; Lune test output; screenshots (each ring mode, the Sky Dial pair, a storm pull with helpers, the `CastPoint` walks, three phone sizes, and the first frame from spawn at three cycle times: under a shower, under fog and in a clear gap); server log excerpts for pull timings and onboarding steps; a `twistStats` sample; the Config diff against requirement 5; the files changed.

## Dependencies
The design gate (T-0012) passed; the economy sheet's prototype subset (T-0008, §14) and the world plan's prototype subset (T-0011, §12), both accepted on 2026-10-25 and copied into this brief in T-0013. Playtests also need the human's answers to GDD open questions O-H3 (testers) and O-H4 (how testers reach the build); the build itself does not.

## Hand off to
qa-tester (golden path, juice pass, device check, first-frame captures), newcomer (fresh-profile runs), designer (loop tests, twist tests A and B, and the PROTO-02 and PROTO-04 verdict under GDD §13.4), gatekeeper (prototype gate).

Related: [GDD](../gdd.md) · [Economy sheet](../economy-sheet.md) · [World plan](../world-plan.md) · [Decisions](../decisions.md)
