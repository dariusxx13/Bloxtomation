# Stormcatch: loop sketch

Task T-0002 · Designer · 2026-10-24 · Stage: pitch · Outcome served: **stay** (a loop worth repeating on a phone from the first minute), with **return** as the second outcome (weather schedules and overnight traps).

**Inputs used.** The scout's market scan (`games/stormcatch/docs/market-scan.md`) did not exist yet when this was written. Comparable numbers come from the vault snapshot note (`vault/21-hits-and-trends/chart-snapshot-2026-10.md`, taken 2026-10-24 17:04 UTC) and from the scout's fresh tracker snapshot `charts/data/snapshots/2026/10/24/20261024T192440Z-computer-all.json.gz` (2026-10-24 19:24:40 UTC, device computer, country all). I read that file and ran `python3 charts/charts.py game "Fisch"` and `game "Fish It"`; neither changes it. Mechanics come from the vault's fishing playbook (`vault/14-genre-playbooks/fishing-and-collection.md`).

**Labels used below.** *Target (source)*: a design target and the vault note or comparable it came from. *First-pass estimate*: a number nobody has modelled yet. The Economist turns these into the economy sheet at the design stage. Nothing here is a measured fact unless it cites a snapshot.

---

## 1. The game in one breath

You fish around a small, cozy archipelago where the weather moves. Rain showers, sea fog and gusts drift slowly from island to island on a forecast that everyone can read. Each kind of weather changes which fish bite, how the reel feels and what mark the catch carries. You decide where to stand and when to cast by reading the sky. Every quarter hour a Great Storm rolls over the harbour. Everyone gathers at the pier, and giant storm fish bite that are landed fastest when many players pull together.

Working title: **Stormcatch**. The human decides the store title. A verb-first option to test is *Fish the Storm* (see open questions).

---

## 2. The loop (PITCH-02, DESIGN-01)

**One sentence:** You **tap to cast and reel wherever the weather is passing** to get **fish stamped by that weather (coins plus new Sky Journal pages)** so you can **buy a better rod and boots, open the bridge to the next island and be at the pier when the Great Storm hits**.

```
Moment loop:  tap Cast -> bobber lands, 2-5 s wait -> "!" bite -> tap the reel ring on green (1-3 taps)
              -> fish leaps out: name, size (kg), rarity colour, weather mark -> coins fly to the counter
              (one catch every ~6-10 s in clear weather; first-pass estimate)
Session loop: coins -> Rod (value), Lure (luck), Boots (walk speed, to reach fronts first), companion nests
              -> bigger and rarer fish, faster to the next front -> fix the bridge to the next island
              (gap between upgrades 30 s - 2 min in the first session; target, core-loop-design.md)
Long loop:    Sky Journal sets (island x weather), Stormborn giants, New Tide (rebirth), daily Almanac
              windows, Tide Pots set under tonight's forecast, a new weather front every Saturday
One sentence: You tap to cast and reel wherever the weather is passing to get weather-marked fish
              so you can upgrade, unlock islands and be at the pier for the Great Storm.
Friend reason: the weather is shared, and Stormborn giants in the Great Storm are landed by everyone
              nearby pulling together; every helper gets a journal stamp and coins.
```

Why this is playable in Roblox terms: the moment loop needs a single tap button (thumb zone, 56 px+, as the template already does). The rod is equipped automatically. Fishing spots are glowing ripple patches tagged in `Workspace.World`, and the server decides every bite, roll and payout. The client only sends "cast at spot X" and "tapped at time t", and the server checks both for plausibility.

---

## 3. What "cozy" means in this game (observable)

| Cozy promise | Observable rule (what a playtester can check) |
|---|---|
| Unhurried pace | A front is announced on the Sky Dial at least 60 s before it reaches a spot and stays 90-120 s (first-pass estimate). Adjacent spots are at most about 15 s apart at base walk speed (first-pass estimate). A missed front costs nothing, and another arrives within minutes. |
| No harsh fail states | A failed reel costs 0 coins and 0 items. The fish swims off and Cast is available again within 1 s. There is no death, drowning, damage, hunger, stamina, energy or durability, and no player can lose a caught fish. |
| Nothing taken by others | No PvP, no stealing. Fishing spots are not exclusive: any number of players can fish the same ripple without lowering each other's catches, so nobody can block or "camp" a spot. |
| Calm audio | A soft acoustic music bed with rain and wave ambience. Storm audio swells over 3 s or more and has no sudden stingers or jump scares. Thunder is a low rumble. All sounds use the template's volume settings. |
| Calm visuals | A warm palette, rounded shapes, slow camera. Lightning flashes are short, soft and optional (the template's reduce-motion setting also disables them). Night and fog never get so dark that the water is unreadable. |
| Social warmth | Helping someone land a giant pays the helper. Friends nearby raise luck. A one-tap Cheer emote plays on rare catches. Every server-wide banner celebrates; none shames. |
| Honest time | Every countdown (front ETA, Great Storm, Almanac windows) shows the real schedule. It never restarts, and nothing sells skipping it (`vault/09-monetization/monetization-compliance.md`). |

**Deliberately left out:** PvP, stealing and raids (the consequence layer of 2025-2026 hits; see risks), losing fish or progress, energy and stamina timers, pay-to-skip timers, jump scares, damaging lightning, timed reflex tests that gate rewards, text-heavy quests, trading at launch (argued in section 6), real-money weather control at launch (an open question).

---

## 4. The weather twist (PITCH-04)

### 4.1 How the weather works

- The archipelago has four islands, each with 2-3 fishing spots: **Pebble Cove** (start, with Driftlight Harbor and the Open Pier), **Lantern Reef**, **Gustwhistle Bluffs** and **Thunderhead Point**.
- At any moment 1-3 **fronts** (Showers, Sea Fog, Gusts) drift along paths across the islands. Each front covers about one spot's area and lingers 90-120 s per spot before moving on (first-pass estimate). Together, fronts cover about a quarter of the fishable water at any moment (first-pass estimate).
- Each island has a **home weather** that visits it more often: Pebble Cove gets Showers, Lantern Reef gets Sea Fog, Gustwhistle Bluffs gets Gusts, and Thunderhead Point gets a mix.
- The schedule is **deterministic from UTC time** and is the same in every server. That makes the forecast true for everyone, lets friends in different servers plan around it, and lets Tide Pots be computed offline. The Engineer confirms feasibility; it is plain math on server time and needs no cross-server messaging.
- The **Great Storm** happens every 15 minutes, clock-aligned at :00, :15, :30 and :45 UTC (first-pass estimate; vault target: one peak per 10-20 minutes, `vault/02-core-loop/session-structure.md`). It lasts 3 minutes (first-pass estimate). The whole map darkens and rains, and its eye always sits over the **Open Pier** at the harbour, so new and veteran players meet there.
- A **Rainbow** lands on one nearby spot for 60 s after a Showers front leaves a spot in clear sky (first-pass estimate).
- **Aurora Night** is a scheduled weekly window on Saturday (two windows for time zones; see open questions). It is the first live-ops heartbeat.

### 4.2 What each weather does to fish, spots, catches and the reel

All multipliers and chances are first-pass estimates for the Economist. One mark per fish at launch: marks do not stack (`vault/03-rarity-and-rng/collection-and-variants.md` requires a stacking rule).

| Weather | Fish | Spots | Catch (mark) | Reel | Decision it creates |
|---|---|---|---|---|---|
| Clear | Island base table (8 species per island) | Standard ripples | No mark | Normal ring | Baseline; fine to stay put |
| Showers | Bites about twice as fast; 3 rain-only species | Rock pools on the shore fill and become temporary extra spots (less crowding) | **Drizzled** (about x1.5 value, about 1 in 5 catches) | Ring closes faster with a wider green band | "Go where it's raining" for speed and coins |
| Sea Fog | Bites about 40% slower; Rare-and-up weight about x2; 3 fog-only species | Hidden "lantern ripples" farther out appear only while the fog is there | **Misty** (about x2 value) | You only see a silhouette on the line until it lands (a mystery reveal) | Trade speed for rares and journal pages |
| Gusts | Size roll pushed up about 25%; 3 gust-only species | Wind pushes ripples to far water; cast distance grows to reach them from the cliff edges | **Breezy** (about x1.5 value) | The green band drifts around the ring (the skill weather) | Skilled players chase size records here |
| Rainbow (after Showers) | Same table as the spot | One spot, marked by the rainbow's foot, for 60 s | Catches pay about x2; rare **Prism** mark (about x5, about 1 in 20) | Normal | Predict where the shower ends; friendly race to the rainbow |
| Great Storm (every 15 min) | 4 **Stormborn** giants bite only in the eye at the Open Pier | The eye is the Stormborn spot; everywhere else gets light rain | **Charged** (about x3) when the final tap lands on a lightning flash; missing the flash still lands the fish | Lightning flashes mark the perfect tap; giants need a shared **Pull** meter | Drop everything, gather, invite friends |
| Aurora Night (weekly) | Event species | The whole map, for the window | **Auroral** (event mark) | Normal | Appointment to come back on Saturday |

### 4.3 Forecast, chase, influence, share

| Verb | Can players do it? | How |
|---|---|---|
| **Forecast** | Yes, for free | The **Sky Dial** on the HUD shows the current weather on each island and the next three fronts with real ETAs ("Fog → Lantern Reef in 1:10"). The daily **Almanac** page shows today's special windows, the **Fish of the Day** (bites only in one weather) and tomorrow's preview. The Storm Petrel companion extends the Sky Dial 5 minutes further ahead (first-pass estimate). |
| **Chase** | Yes | Fronts move, so players walk (Boots upgrade) or ride the harbour ferry to reach them. Coziness comes from the 60 s warning and the long linger. |
| **Influence** | Yes, cooperatively | The **Sky Bell** at the harbour has a server meter. Players offer duplicate fish (any copy past the first of a species and mark) to fill it. When it is full, everyone nearby votes among Showers, Fog and Gusts, and the winner arrives as a bonus front in this server for 3 minutes. The meter size scales with server population (first-pass target: it fills about every 10-20 minutes in a full server). This gives duplicates a use (`collection-and-variants.md`: "every duplicate has at least one use"). No Robux path at launch. |
| **Share** | Yes, always | Weather is server-wide. Fronts and storms are moments everyone sees. Stormborn giants are landed together, rainbows are visible from every island, and Great Storm countdowns carry an invite prompt with launch data that spawns the friend at the Open Pier. |

### 4.4 The Great Storm co-op pull (the social core)

1. When a player hooks a Stormborn in the eye, a big **Pull!** button appears for every player within about 40 studs. They don't need to be friends; strangers count.
2. The angler taps the reel ring as usual, and each helper's tap adds to a shared Pull meter. Alone, a giant lands in about 45 s; with four helpers, in about 10 s (first-pass estimate). If the storm ends first, the giant slips away at no cost.
3. The fish always belongs to the angler. Each helper gets a **Witnessed** stamp for that Stormborn in their own Sky Journal (a collectible set) and a coin share minted on top, not taken from the angler. Friends among the helpers raise the chance of the Charged mark. Helper rewards are capped per storm, so pulling isn't worth farming with alt accounts (`vault/21-hits-and-trends/viral-and-social-mechanics.md`, abuse-resistant rewards).
4. A server banner names everyone: "Mia and 4 anglers landed a CHARGED Rumblefin, 212 kg!" This is the clip moment (section 5.6).

New players help from minute one: pulling needs no rod level. That gives a newcomer a meaningful part in a veteran's big moment, and a reason for veterans to welcome full servers.

### 4.5 Comparables and how play differs

Player numbers are concurrent players. Like ratios are not in the tracker; the scout's market scan adds them.

| Game | Players (tracker, 2026-10-24 19:24:40 UTC) | Other data | What weather or conditions do there | Verified? |
|---|---|---|---|---|
| **Fisch** | 107.2K (vault snapshot at 17:04 UTC: about 157K) | 5.1B visits, servers of 20, Minimal, created 2024-03, updated 2026-10-24 | Vault: "fishing as a collection and conditions system"; time of day, weather and seasons change which fish appear. From general knowledge only: one weather state for the whole server at a time, and items bought with in-game currency that change server weather or time. | Vault part yes (`vault/22-references/reference-games-by-genre.md`, `fishing-and-collection.md`); the rest **unverified**. T-0001 requirement 3 checks it against public update logs. |
| **Fish It!** | 76.4K | 4.8B visits, servers of 20, Minimal, created 2024-10, updated 2026-10-24 | Vault: very stable audience, within about 3% of its weekly average in August 2026 (StudioKrew). From general knowledge only: server-wide weather events that one player can trigger by spending in-game currency, raising luck or mutation chances for everyone. | Vault part yes; weather part **unverified** (scout to check). |
| Grow a Garden (weather comparable, farming) | 32.5K (tracker) | 36.0B visits, servers of 4 | Weather events (rain, storms, special skies) trigger crop mutations and give the server a shared moment; server-wide weather triggers are sold | Vault (`vault/14-genre-playbooks/grow-and-farm.md`) |
| Ride A Pet (weather comparable, eggs) | 23.5K (tracker) | Servers of 6 | Added weather mutations on 2026-09-19 | Vault (`vault/21-hits-and-trends/hits-2026.md`, citing StudioKrew) |

Other fishing titles charting in the same tracker snapshot (name search, approximate): Deep Fishing 12.3K (created 2026-07), Heavyweight Fishing 9.9K, Harpoon a Fish 7.4K (created 2026-08), Fish an Anime RNG 3.5K, Roll a Fisherman 2.8K, Cage Fishing 0.1K. Counting Fisch and Fish It!, that is 8 fishing titles. The urgency read and trend phase belong to the scout (T-0001).

**What is different in play, not in looks:**

1. **Weather is a place, not a server state.** In the comparables (as we understand them; unverified), the whole server has one weather and you keep fishing where you are. In Stormcatch, several fronts cross the map at once, so the island you are on differs from the next one. The core decision each minute is *where* to stand, and moving is part of the loop (the Boots upgrade exists for it).
2. **Weather changes the reel, not just the fish table.** Rain makes reeling quick and forgiving, fog hides what is on the line, wind moves the target, and the storm adds lightning timing. Changing weather changes the hands-on feel, which keeps the 100th cast fresh.
3. **Weather is forecastable, so it creates timing decisions and appointments.** The Sky Dial (minutes ahead) and the Almanac (today and tomorrow) are free and true for everyone. Players time casts for the rainbow and plan sessions around Fish of the Day windows.
4. **Influence is cooperative and costs duplicates, not money.** In the comparables (unverified), one player buys weather for the server. Here a whole server fills the Sky Bell together and votes.
5. **The biggest weather moment needs other people.** Stormborn giants are landed by a crowd pulling together, and every helper is rewarded. Co-play is a mechanic, not only a bonus percentage.
6. **Weather drives the overnight decision.** Before leaving, players place Tide Pots where tonight's forecast promises the weather they want (section 5.7).

In Grow a Garden and Ride A Pet, weather marks are a familiar idea (familiar format); our fresh part is the *spatial, forecastable, chased and shared* weather around them.

---

## 5. The first session as player actions (PITCH-03, DESIGN-02)

### 5.1 First 60 seconds

| Time | The player does | The game shows | Target (source) |
|---|---|---|---|
| 0-5 s | Spawns on the harbour dock facing the water, rod already in hand | A glowing ripple 8 studs ahead; a light shower over the far end of the cove and a dark storm cloud on the horizon (this matches the thumbnail); one pulsing **Cast** button in the thumb zone; nothing else on the HUD | Spawn at the action, first frame equals the thumbnail (`first-session-blueprint.md`, phase 0) |
| 5-10 s | Taps **Cast** | Bobber arcs out, plop, ripples | Core action with one input within 10-30 s (blueprint, phase 1) |
| 10-15 s | Sees "!" over the bobber after a short wait (first cast is scripted at about 2 s), taps when the ring turns green | Ring reel, one tap needed for the first fish | Hint of 5 words or fewer: "Tap on green!" (blueprint) |
| 15-20 s | Watches the catch | The fish leaps out of the water; card shows **Pebble Minnow, 0.8 kg**, a rarity colour, "+12" coins flying to a counter that pops into view, and a Journal icon with "NEW 1/8" | First catch within 20-30 s (`fishing-and-collection.md`); reward animated and audible (blueprint, phase 2) |
| 20-45 s | Casts 3-4 more times | Sizes vary; a "Better Rod: 15" progress bar fills on the HUD | First upgrade affordable within 1-2 actions (blueprint, phase 3); 15 coins is the template's first-upgrade cost (`Config/Upgrades.luau`), first-pass |
| 45-60 s | Taps the pulsing **Shop** button and buys **Rod 2** (guided) | The rod glows and grows longer; the shop closes; the pointer returns to the water; the next fish is visibly bigger | First choice by minute 1-3, and the upgrade changes the feel (blueprint, phases 3-4) |

### 5.2 Minutes 1-10

| Time | The player does | Target (source) |
|---|---|---|
| ~1:00 | Sees the **Sky Dial** pop onto the HUD with a cloud icon: "Rain → here in 0:30", and a beam to where the shower will arrive (10-15 s down the dock) | Progressive UI reveal (`onboarding-patterns.md`) |
| ~1:30-2:30 | Walks into the rain and keeps fishing; bites come about twice as fast. The first catch in rain is **guaranteed** to be a new rain-only species with the **Drizzled** mark: a shimmer stamp, a bigger reveal and "NEW!" | Guaranteed early rare (`fishing-and-collection.md`, "seed a guaranteed early rare"); first weather catch by minute 4 (first-pass estimate, set by a Pebble Cove shower about every 3 minutes) |
| ~3:00-4:00 | Sees the shower move on and a **rainbow** land on a nearby ripple; hurries over and casts inside the 60 s window | First taste of timing and chasing |
| 4-6 min | Chooses the second upgrade: **Lure** (luck) or **Boots** (walk speed), a real choice | Two or three upgrade paths (`core-loop-design.md`) |
| 5-8 min | Sees the **Driftwood Nest** glow when affordable, opens it, gets a companion (for example a Puddle Frog: faster bites in Showers), and it follows | First collection system at minute 5-20 (`progression-architecture.md`) |
| 8-10 min | Opens the **Almanac** from a pulsing icon, sees tonight's forecast, and places the first free **Tide Pot** at a spot the fog will cross tonight | Return hook visible before minute 10 (blueprint, phase 7) |

### 5.3 Goal at 10-15 minutes

**"Fix the bridge to Lantern Reef."** The broken bridge with its price sign is visible from the dock at spawn. A HUD progress bar ("Bridge: 62%") appears after the first upgrade. Target: a casual free player gets there in 10-12 minutes (`first-session-blueprint.md`: first named goal at 10-15 min; the template's pacing test puts zone 2 at 8-16 min for a casual player, `template/README.md`). Crossing the bridge reveals Lantern Reef under sea fog, with glowing lantern ripples, 8 new silhouettes in the journal and a new nest.

### 5.4 First wow (within 15 minutes, by schedule)

The **first Great Storm** is due within 15 minutes of joining for every player, because storms run every 15 minutes. The Sky Dial counts down from 5 minutes out: "Great Storm 4:12, Open Pier". The sky darkens, music swells and everyone heads to the pier. The new player taps **Pull!** to help land a Stormborn and gets a Witnessed stamp. If lucky, they hook one themselves. Target: one peak per 10-20 minutes (`session-structure.md`) and a planned wow within 20 minutes (blueprint, phase 6).

### 5.5 Minutes 10-30

- Fish Lantern Reef's fog for Misty rares and the 3 fog-only species. Open the Reef Nest for a fog companion (Lamp Moth: more rares in fog).
- Finish the **Pebble Cove set (8/8)** for a permanent small coin bonus and a visible title ("Cove Regular").
- Fill the Sky Bell with duplicates and vote for a front together.
- Work toward the next bridge, to **Gustwhistle Bluffs**. Target: 20-30 min cumulative. Sources disagree (`progression-architecture.md` puts zone 3 at 15-25 min; the template's economy comment puts it at 30-45 min), so the Economist decides.
- A second Great Storm happens at the latest by minute 30.

### 5.6 Clip moment

A Great Storm landing: five avatars on the pier pulling, lightning hitting the taut line, a giant Rumblefin breaching against the flash, a **CHARGED** stamp and a server banner with everyone's name. Second clip: a Prism catch under a rainbow. Both read without UI or sound: dark sky, lightning, a huge fish, a crowd (`clip-moments-and-shareability.md`: surprise, scale, readable in one second, emotion).

### 5.7 Why tomorrow (player actions)

1. **Collect the Tide Pot.** Last night the player put a pot where the forecast promised fog. Today they open it to a "while you were away" reveal of 6-10 fish (first-pass estimate) carrying the marks of the weather that really passed that spot. Pots fill for up to 8 hours (cap) at lower efficiency than active play (first-pass about 20-30%; vault range 10-50%, `idle-and-offline-progression.md`).
2. **Catch the Fish of the Day.** The Almanac showed it yesterday: "Tomorrow: Lanternfin pays x3, bites only in Sea Fog." The player checks the Sky Dial and goes to where the fog is.
3. **Claim day 2** of the 7-day calendar (previewed yesterday) and keep the streak.
4. **Finish a journal set.** Yesterday's journal said "7/8, last one only in Gusts". Today they chase a Gusts front.
5. **Saturday: a new front arrives.** The banner says what is coming and when.

### 5.8 Onboarding steps mapped to `project/src/shared/Config/Onboarding.luau`

These are pre-launch, so renumbering the template's list is still allowed. **After launch, never renumber; append only.** Hints have 5 words or fewer. Every step is logged on the server with the template's onboarding funnel.

| Step | Name | Player action | Guide | Hint | Template step it replaces | Target time |
|---|---|---|---|---|---|---|
| 1 | Joined | Arrives on the dock | none | | same | 0 s |
| 2 | First Cast | Taps Cast | node (fishing spot) | "Tap to cast" | First Move | 10 s or less |
| 3 | First Catch | Lands a fish | node | "Tap on green!" | First Hit | 30 s or less |
| 4 | Earned 15 Coins | Catches 1-2 more | node | "Catch more fish" | same (`coinsForStep4 = 15`) | about 40 s |
| 5 | Opened Shop | Taps the Shop button | shop | "Open the shop" | same | about 50 s |
| 6 | First Rod Upgrade | Buys Rod 2 | upgradePower | "Buy a better rod" | First Upgrade | about 60 s |
| 7 | Caught in Rain | Lands a fish under a Showers front | **weather** (new guide kind) | "Fish in the rain!" | 50 Hits | 4 min or less |
| 8 | First Hatch | Opens a companion nest | egg | "Open a nest" | same | 5-8 min |
| 9 | Equipped Companion | Equips the companion | pets | "Bring your pal" | Equipped Pet | 5-8 min |
| 10 | Placed Tide Pot | Places the first free pot | **pot** (new guide kind) | "Set a Tide Pot" | new | 10 min or less |
| 11 | Island 2 Unlocked | Fixes the bridge to Lantern Reef | gate | "Fix the bridge" | Zone 2 Unlocked | 10-15 min |
| 12 | Played 10 Minutes | Keeps playing | none | | same | 10 min |
| 13 | Joined a Great Storm | Pulls or hooks during a storm | **storm** (new guide kind) | "Help pull!" | new, appended | first storm after step 12 |

Note on step 13: storms can happen before step 12, and the "Help pull!" tooltip shows on any storm regardless of funnel position. The funnel step is logged on the first storm after step 12, so it measures "stayed for a storm".

Changes needed: three new `guide` kinds (`weather`, `pot`, `storm`) in `StepDef`; `hitsForStep7` replaced by a weather-catch trigger; `minutesForStep11` moves to step 12. Size: small.

---

## 6. Social reason, session shape, server size, content floor, update unit (DESIGN-06)

**Social reason: co-play (primary), with presence and friendly competition. No trading at launch.**

- *Co-play:* the weather is shared, the Great Storm's giants are landed by a crowd and every helper is paid, and the Sky Bell is a server goal. A friend bonus reuses the template's `Social` system (+10% per friend in the server, capped at +50%, `Config/Economy.luau`), applied to luck instead of coins (Economist). Invite prompts appear at the storm countdown, never on spawn (`social-systems.md`).
- *Presence:* companions follow you, Stormborn are held up in a catch pose, journal titles show above heads, and weather cosmetics (raincoats, umbrellas) are visible.
- *Competition, friendly:* an in-world harbour board for the biggest fish today and the biggest catch of each storm, and a race to the rainbow.
- *Why no trading at launch:* trading brings scams and duplication risk (`vault/21-hits-and-trends/why-games-die.md`), extra policy duties (`IsPaidItemTradingAllowed`) and moderation load for a young audience. The co-op storm already gives a reason to be with others. Revisit after launch with data.

**Session shape: long-session family, persistent and active, not AFK-idle.** Target average session 15-30 minutes (`session-structure.md`, simulator/RNG/fishing row) with 1-2 sessions a day. Peaks come from the Great Storm every 15 minutes, and appointments come from Almanac windows and Tide Pots. Auto-reel arrives later and is weaker than active play (`idle-and-offline-progression.md`).

**Server size: 12** (first-pass, to playtest against 8). A Great Storm needs a crowd of 4-8 at the pier, 12 still lets everyone see everyone, and it fills quickly when friends join. Comparables in the tracker range from 6 to 20 (Fisch 20, Fish It! 20, Deep Fishing 12, Heavyweight Fishing 10, Harpoon a Fish 6). The vault puts 10-20 as "a neighbourhood: simulators with show-off, farming" (`viral-and-social-mechanics.md`).

**Content floor at launch** (first-pass; the Director and Engineer confirm build time):

| Content | Launch amount |
|---|---|
| Islands | 4 (Pebble Cove with Driftlight Harbor, Lantern Reef, Gustwhistle Bluffs, Thunderhead Point) |
| Weathers | Clear, Showers, Sea Fog, Gusts, plus Rainbow aftermath and the Great Storm event |
| Species | 48: 8 per island (32), 3 weather-only per front type (9), 4 Stormborn, 3 Aurora Night event |
| Marks | 6: Drizzled, Misty, Breezy, Charged, Prism, Auroral |
| Companions | 12 across 4 nests (each with a weather perk) |
| Sky Journal sets | 12 (4 island sets, 3 weather sets, Stormborn, Witnessed, Rainbow, Aurora, Records) |
| Upgrade lines | Rod, Lure, Boots, Pal Pouch (companion slots) |
| Systems | Sky Dial, Almanac, Sky Bell, Tide Pots (2 slots), New Tide (rebirth), daily calendar and streak, playtime gifts, codes, shop |

**Weekly update unit: "a new front".** Every Saturday a new weather condition or a limited weekly front arrives. Each one brings 4-6 species, a mark or mark variant, a journal set and (every other week) a companion, plus a live arrival moment at a fixed time. A new island ships every 3-4 weeks. The update unit is the game's twist, so every update makes the weather richer (`hit-formula.md` #8; `anatomy-of-a-hit.md` #7).

---

## 7. Template reuse map (DESIGN-10 input)

Sizes are first-pass: **S** is config, reskin or about a day; **M** is about 2-4 days; **L** is about 1-2 weeks of engineering.

| Mechanic | Template system (`template/README.md`) | What changes | New? | Size |
|---|---|---|---|---|
| Fishing spots (ripple patches) | `World` registry (`ResourceNode` tag), `Nodes` validation (zone, range, cooldown) | Re-tag nodes as spots; spots never "break" | Reuse | S |
| Cast, bite, reel, reveal | `Interact` (tap), `Nodes` (server validation pattern), `Hatch` (reveal anticipation for rares) | New `Fishing` server system (bite timer, roll on bite, reel-timing plausibility check) and a new `Reel` client controller (ring mini-game) | **New** | L |
| Species tables, luck and pity | `Config/Eggs` table shape, `Util/Odds` (weights, luck), hard pity | Tables per island and weather; pity for the first rare | Reuse | S |
| Fish size (kg) and records | none | Size roll; harbour record board | **New** | S |
| Weather marks | Collection index keys (`species:mark`), `Util/Odds` | Mark roll per weather; one mark per fish | **New** (small) | S |
| Weather fronts, schedule, Sky Dial | `LiveConfig` for tuning and event overrides | New `Weather` system (deterministic UTC schedule, front paths, per-spot state), weather VFX within mobile budgets, Sky Dial HUD | **New** | L |
| Great Storm co-op pull | `Hatching` rare-pull announcements (server and cross-server) for banners | Shared pull meter, helper rewards and caps | **New** | M |
| Sky Bell (cooperative weather call) | `Currency` sink pattern | Server meter fed by duplicates, vote, bonus front | **New** | M |
| Rod, Lure, Boots, Pal Pouch | `Upgrades` (power, luck, speed, storage) | Rename and retune; the rod model changes per tier | Reuse | S |
| Islands and bridges | `Zones`, `ZoneGate` and `UnlockPrompt`, `Gates` controller | Gates become broken bridges with price signs | Reuse | S |
| Companions | `Pets`, `PetInventory` (equip best, lock, delete), `PetFollow` | Reskin; weather perks active only in matching weather; "Equip best for this weather" | Reuse plus small change | S |
| Companion nests | `Eggs`, `EggStand`, `Hatch` odds panel | Reskin (odds always shown, as the template already does) | Reuse | S |
| Sky Journal | Profile collection index; `PetsPanel` UI patterns | Journal panel with sets, silhouettes, hints, set rewards | **New** UI | M |
| New Tide (rebirth) | `Rebirth`, `RebirthPanel` | Rename and retune | Reuse | S |
| Daily calendar, streak, playtime gifts | `Rewards`, `RewardsPanel`, `Util/Daily` | Retune rewards (for example day 7 gives a luck boost and a Tide Pot bait) | Reuse | S |
| Almanac (daily windows, Fish of the Day) | `Util/Daily` (server-day boundaries) | Panel reading the same weather schedule | **New** | S |
| Tide Pots (overnight traps) | `Grants` (payouts), `Util/Daily` (time) | Place a pot, compute offline fill on rejoin from the schedule, cap, "while you were away" reveal | **New** | M |
| Codes | `Codes` | none | Reuse | S |
| Shop, passes, products | `Purchases` (idempotent `ProcessReceipt`), `Shop`, `Config/Products` | Reskin (Auto Hit becomes Auto Reel, and so on); catalog at the design stage | Reuse | S |
| Friend and group bonus | `Social` | Apply to luck and Charged chance | Reuse | S |
| Onboarding | `Onboarding`, `Guide` (beam, outline) | New step list (section 5.8); guide kinds `weather`, `pot`, `storm` | Reuse plus small change | S |
| Analytics | `Analytics`, `Config/Analytics` | Events: Cast, Catch (species, mark, weather), FrontEntered, StormJoined, StormLanded, PotPlaced, PotCollected, BellFed | Reuse | S |
| QA tools | `QA`, `SettingsPanel` | Force weather, force storm, set schedule time, fill pot | Reuse | S |
| Harbour ferry between islands | none | A moving platform on a fixed route (no driveable boats at launch) | **New** | S |
| Driveable boats | none | Later update candidate, not launch | **New** | L (deferred) |

Totals: 2 large (Fishing, Weather), 4 medium (Great Storm pull, Sky Bell, Sky Journal, Tide Pots), and the rest small reskins and config. The template already covers data safety, receipts, odds display, the paid-random-items policy, rate limits and analytics.

---

## 8. Audience, maturity draft and IP notes (PITCH-07 input)

**Audience tier (draft):** Roblox Kids and Roblox Select (both reachable with a Minimal or Mild label), core age 7-13, phone-first. The genre also draws "older players who enjoy chill progression" (`fishing-and-collection.md`). That matters because a new public game first reaches only age-checked 16+ players until it passes the under-16 evaluation (250 unique plays from engaged 16+ users within 60 days; `vault/17-policy-and-business/age-ratings-and-audience.md`). The cozy, chill angle has to work for those older players in the first weeks too.

**Expected content maturity (draft only; the human answers the questionnaire):** we expect **Minimal**, based on the content as designed:
- Violence and blood: none. Fish leap out and are added to the journal; nothing is shown being hurt.
- Fear: none intended. Thunder is a gentle rumble, there are no jump scares, and lightning flashes are optional.
- Crude humour, romance, alcohol, strong language: none.
- Free-form user creation and AI interaction: none.
- Paid random items: **a question for the human.** If coins can be bought with Robux (as in the template), companion nests count as paid random items. The template already shows odds and respects `ArePaidRandomItemsRestricted`, but the questionnaire answer is the human's.
- Comparables in the tracker are all labelled Minimal (Fisch, Fish It!, Deep Fishing, Heavyweight Fishing, Harpoon a Fish; snapshot 2026-10-24 19:24:40 UTC). That supports the expectation but does not decide it.

**IP notes:**
- Every name in this sketch is invented (islands, weathers, marks, species, companions, systems). Species are invented rather than real-world fish, so they are collectible and searchable.
- Do not reuse the comparables' item names, fish designs, mutation names, UI layouts, title patterns or thumbnail compositions. The reel is our own ring design, not a copy of any comparable's bar layout. General mechanics (fishing, reel mini-games, weather mutations) are not protected; the specific expression is (`vault/17-policy-and-business/ip-and-licensing.md`).
- Discovery demotes games whose metadata and files closely resemble existing ones (`trend-lifecycle.md`), so originality is also a discovery requirement.
- Music and sound must be original or licensed, each with a source and licence recorded in the asset index.
- **Open:** nobody has checked "Stormcatch" or "Fish the Storm" for collisions with existing games or trademarks. This is for the scout and the human.

---

## 9. Hit-potential scoring sheet (`vault/21-hits-and-trends/anatomy-of-a-hit.md`)

| # | Ingredient | Score | Justification |
|---|---|---|---|
| 1 | Title explains the loop | 1 | "Stormcatch" hints at catching in storms but has no verb a child reads at once; a verb-first store title such as "Fish the Storm" would score 2 (the human decides). |
| 2 | Familiar format plus one fresh thing | 2 | Fishing is a proven, lasting genre (Fisch 107.2K, Fish It! 76.4K at 2026-10-24 19:24 UTC). The one fresh thing is moving, forecastable fronts that you chase, summon together and land giants under. Unproven until the prototype (risk 1). |
| 3 | Consequence layer from other players (or a clear reason it is not needed) | 1 | Deliberately none: the cozy promise for a Kids and Select audience. The substitute tension is honest storm windows that close and a per-storm biggest-catch board. The vault's evidence favours consequence layers, so this is a real gap, not a free pass. |
| 4 | Progress visible every few seconds | 2 | A catch every ~6-10 s (first-pass) with a size reveal, coin fly-up and journal tick; the next-upgrade bar is always on screen. |
| 5 | Collectibles with rarity and surprise | 2 | 48 species × 6 marks × size rolls, 12 companions and 12 journal sets with silhouettes and hints. Fog's mystery reveal and Prism rainbows add surprise. |
| 6 | Server size chosen for the social design | 2 | 12, chosen so the Great Storm draws a crowd of 4-8 at the pier while everyone stays visible; 8 vs 12 to be playtested. |
| 7 | Weekly heartbeat planned (cadence, events) | 2 | Saturday "new front" updates with a live arrival moment and Aurora Night windows. The update unit is the twist itself. |
| 8 | External funnel planned (creators, social, crossovers) | 1 | The clip moment is named and readable without UI, and share links and codes per channel are planned. No creator or crossover plan yet. |
| 9 | D2-D7 retention hooks designed | 2 | Tide Pots set by tomorrow's forecast, Almanac Fish of the Day, 7-day calendar and streak, journal sets that need a specific weather, Saturday fronts. |
| 10 | Clear on a phone in ten seconds | 2 | Spawn facing the water with one Cast button; the weather is a big visible cloud; the forecast UI only appears after the first upgrade. |
| | **Total** | **17 / 20** | In the 16-20 band ("strong hit potential"). A high score is not a prediction; it means the pitch has the shape of recent hits. The weakest rows (1, 3, 8) are the ones to improve. |

---

## 10. Seven loop tests, planned for the prototype (DESIGN-01, feeds PROTO-02)

Status for all: **untested** (no prototype yet). Proposed prototype scope: the moment loop with juice, Showers and Sea Fog fronts moving across 3 spots, one Rod upgrade line, one Great Storm with the co-op pull, and placeholder art.

| # | Test | How we test it | Pass target |
|---|---|---|---|
| 1 | 30-second test | Newcomer playtest on a phone, no help; onboarding funnel step 3 timestamp | 5 of 5 testers land a fish within 30 s (`core-loop-design.md`; PROTO-03) |
| 2 | 100th-time test | Tester plays to about cast 100 (about 12-15 min) and rates it | Still rated 4/5 or higher and the tester keeps playing unprompted (first-pass estimate) |
| 3 | Upgrade-feel test | After Rod 2 and Boots, ask what changed without showing numbers | Tester names a visible change (longer rod, bigger fish, reaches fronts sooner) |
| 4 | Friend test | 3+ testers in one server during a Great Storm; measure Stormborn landing time solo vs group and where testers stand | Group landing at least 3x faster than solo; testers gather at the pier unprompted |
| 5 | "One more" test | HUD screenshot at 10:00 | A goal 1-3 minutes away is visible (next front ETA, bridge %, set 7/8) |
| 6 | Silent test | Muted, UI hidden, a 10-second storm clip shown to someone with no context | Viewer can say "it's storming and they caught a giant fish" |
| 7 | One-sentence test | After 5 minutes, ask a newcomer to describe the game | They say some form of "you fish where the weather is" |
| + | **Twist test (chase index)** | Analytics: share of catches made under a front after minute 5, against the share of water fronts cover | 45% or more of catches under fronts while fronts cover about 25% of the water (first-pass estimates). Under 30% means players ignore the weather: pivot (risk 1). |

---

## 11. Risks

| # | Risk | Mitigation |
|---|---|---|
| 1 | **The twist reads as decoration.** Players don't move with the fronts, and Stormcatch becomes a third fishing game behind Fisch (107.2K) and Fish It! (76.4K). | Make weather matter in play: about 2x bite speed in rain, about 2x rare weight in fog, weather-only species and spots, changes to the reel (first-pass). Teach it at minute 2 (onboarding step 7). Measure the chase index in the prototype. Pivot option: fixed hourly weather per island (a simpler "where is it raining now" choice). |
| 2 | **Crowded genre with entrenched leaders.** 8 fishing titles charting in the tracker snapshot (name search, approximate). | The thumbnail and title sell the storm, not the fishing (a giant fish breaching under lightning). The scout's urgency read decides whether we are late. |
| 3 | **Weather VFX on low-end phones.** Moving rain, fog and lightning cells are costly. | Render only the front near the camera at full detail and show the others as sky icons. Prefer `Atmosphere` and lighting changes over particles. Budget per `vault/19-vfx/vfx-performance-budgets.md`. Test on low-end Android in the first prototype week. |
| 4 | **Cozy vs chase.** Fronts that move too fast turn into a chore. | 60 s warnings, 90-120 s lingers, no penalty for missing a front, another front within minutes, Boots upgrade. Ask testers how relaxed they feel. |
| 5 | **Economy inflation from marks** (a grow-and-farm trap). | One mark per fish; the Economist caps mark multipliers and Tide Pot efficiency. |
| 6 | **A global schedule meets global time zones.** Some players always miss Aurora Night. | Two Saturday windows; storms every 15 minutes so everyone sees many. |

**Biggest risk: number 1.** If the weather doesn't change where and when people fish, nothing else here matters.

---

## 12. Open questions (DESIGN-09)

**For the human (policy and naming; drafts only, not answered here):**
1. Maturity questionnaire answers. The draft expectation is Minimal (section 8); the human answers.
2. Paid random items: if coins can be bought with Robux, companion nests are paid random items. How should the questionnaire be answered, and should Robux coin packs exist at all?
3. Store title: "Stormcatch" (working) or a verb-first title such as "Fish the Storm". Neither has been checked for collisions or trademarks.
4. Should a Robux "call a front for the server" product ever exist? It would be a server-wide probability modifier with disclosure duties. Recommendation: not at launch.

**For the Economist (design stage):** catch values, bite waits, mark chances and multipliers, Tide Pot fill rate and cap, Sky Bell meter size, bridge prices, and New Tide timing. The goals: first upgrade at about 60 s, bridge 1 at 10-12 min, bridge 2 at 20-30 min, and New Tide within the template's tested 20-90 minute band.

**For the Monetization Designer:** catalog direction (Auto Reel pass weaker than active play, Pal Pouch, extra Tide Pot slot as capacity rather than a skip, Lucky with disclosed odds effect, weather cosmetics such as raincoats and umbrellas). The forecast and storms stay free for everyone.

**For the scout (T-0001 and T-0003):** verify how weather works in Fisch and Fish It! from public update logs (section 4.5 marks it unverified); add like ratios; give the urgency read and trend phase; run a title collision search.

**For the Director and Engineer:** confirm the deterministic UTC weather schedule approach, prototype scope (section 10), and the sizes of the two large systems (Fishing, Weather). Driveable boats are deferred.

**Design questions to settle in the prototype:** Great Storm every 15 vs 20 minutes; server size 8 vs 12; ring reel vs hold-to-reel on touch; whether Gusts' drifting band is cozy enough.

---

## Sources

- Vault (all dated 2026-10-24): `00-start-here/hit-formula.md`, `01-first-five-minutes/first-session-blueprint.md`, `01-first-five-minutes/onboarding-patterns.md`, `01-first-five-minutes/first-session-killers.md`, `02-core-loop/core-loop-design.md`, `02-core-loop/session-structure.md`, `02-core-loop/game-feel-and-juice.md`, `02-core-loop/clip-moments-and-shareability.md`, `03-rarity-and-rng/collection-and-variants.md`, `04-progression-and-economy/progression-architecture.md`, `04-progression-and-economy/idle-and-offline-progression.md`, `10-retention-and-social/retention-systems.md`, `10-retention-and-social/social-systems.md`, `14-genre-playbooks/fishing-and-collection.md`, `14-genre-playbooks/grow-and-farm.md`, `15-market-research/pitch-and-greenlight.md`, `15-market-research/trend-lifecycle.md`, `17-policy-and-business/age-ratings-and-audience.md`, `17-policy-and-business/ip-and-licensing.md`, `09-monetization/monetization-compliance.md`, `21-hits-and-trends/anatomy-of-a-hit.md`, `21-hits-and-trends/afk-idle-and-short-session-games.md`, `21-hits-and-trends/chart-snapshot-2026-10.md`, `21-hits-and-trends/hits-2026.md`, `21-hits-and-trends/trend-waves.md`, `21-hits-and-trends/viral-and-social-mechanics.md`, `22-references/reference-games-by-genre.md`.
- Chart tracker snapshot `charts/data/snapshots/2026/10/24/20261024T192440Z-computer-all.json.gz` (2026-10-24 19:24:40 UTC, computer, all countries; unofficial Roblox endpoints), read with `python3 charts/charts.py game "Fisch"`, `game "Fish It"` and a name search for fishing titles. Third-party and tracker numbers are approximate.
- Template: `template/README.md`; `games/stormcatch/project/src/shared/Config/` (`Onboarding.luau`, `Economy.luau`, `Upgrades.luau`, `Zones.luau`, `Eggs.luau`, `Rewards.luau`); `games/stormcatch/project/src/server/Systems/Social.luau`.
