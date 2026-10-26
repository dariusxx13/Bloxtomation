---
title: "Economy sheet: Reel the Storm (id stormcatch)"
date: 2026-10-26
version: 2
status: in review
author: economist (tasks T-0008 and T-0015)
---

# Reel the Storm: economy sheet

Tasks T-0008 and T-0015 · Economist · 2026-10-26 · Stage: design · Outcome served: **stay**. The casual free player reaches the first bridge in 10-12 minutes, and the next goal is always 1-3 minutes away. Odds are fair, shown and capped.

**How to reproduce every number here.** From the repository root:

```text
python3 games/stormcatch/docs/models/economy_model.py --out games/stormcatch/docs/models/economy_model_output.txt
```

The model needs the standard library only. Its pacing part is a deterministic expected-value simulation in 1-second steps over 240 minutes of play, run for each of the 15 possible join minutes of the 15-minute Great Storm clock. Its odds checks are a Monte Carlo with a fixed seed, `random.Random(20261025)`. A full run takes about 4.5 minutes and writes `games/stormcatch/docs/models/economy_model_output.txt` (509 lines, letter-coded sections A-N, md5 afd22212157985e60dec9157f5111bfd). Section letters below (for example "[B]") point into that file.

**Why a Python model.** `which lune` printed nothing when the task started. The studio check later installed the pinned tools, but `lune run scripts/economy-sheet` reads only the game's `Config/`, which still holds the template's values (this task edits no code). Its baseline is the "before" column in §14: casual zone 2 at 13.7 min and first rebirth at 44 min. Once the Engineer moves these tables into `Config/`, the Lune sheet and `tests/Economy.spec.luau` take over (§13).

**Labels.** *Modelled*: produced by the model above. *Target (source)*: a goal from the GDD or the vault. *Design value*: a timing the Designer owns (GDD), used as an input. Every table names the Config file it becomes.

**Inputs.** The GDD, `games/stormcatch/docs/gdd.md` (T-0007, accepted), wins on timing. The prototype brief is `games/stormcatch/docs/specs/prototype.md`. Decisions D2 and D6 are in `games/stormcatch/docs/decisions.md`. The template config is `games/stormcatch/project/src/shared/Config/`, and the template tests are `games/stormcatch/project/tests/Economy.spec.luau` and `Odds.spec.luau`. Vault: `04-progression-and-economy/` (economy-math, economy-design, progression-architecture, rebirth-and-prestige, idle-and-offline-progression, worked-economy-example), `03-rarity-and-rng/` (rarity-tiers-and-odds, rng-systems-and-pity, collection-and-variants), `18-templates-and-checklists/economy-sheet-template.md` and `99-reference/key-numbers.md`.

---

## 1. The five goals by player type (DESIGN-03)

All times are cumulative minutes of active play. Each cell gives the mean, then [fastest-slowest] across the 15 storm join minutes, then (session, day). This is modelled in the continuous view [B]: one first session that runs until the goal, with in-session sources included (catches, storms, playtime gifts, the day-1 reward and journal-set bonuses). It is the same convention as the template's `simulatePacing`. The paying column buys only what the accepted catalog sells (§2, §19).

| Goal | Casual free | Typical | Paying | Target (source) | Result |
|---|---|---|---|---|---|
| 1. First Rod upgrade (Rod 2, 15 coins) | 45 s | 45 s | 45 s | about 60 s (blueprint phase 3; GDD §3.1 "45 s - 3 min") | Pass |
| 2. Bridge to Lantern Reef (620) | **10.8** [10.3-11.1] (s2, d2) | 8.7 [6.6-9.6] (s1, d1) | 8.5 [6.5-9.7] (s1, d1) | 10-12 min, inside 10-15 (brief; GDD §5) | Pass |
| 3. Bridge to Gustwhistle Bluffs (19,000) | **23.6** [23.1-24.3] (s3, d3) | 16.4 [15.3-17.9] (s1, d1) | 10.0 [10.0-10.0] (s1, d1) | 20-30 min (GDD §5; the Economist decides between the vault's 15-25 and the template's 30-45) | Pass |
| 4. First island set complete (Pebble Cove 8/8, median) | **17.2** [11.7-24.3] (s2, d2) | 12.4 [8.2-20.7] (s1, d1) | 10.5 [7.7-20.0] (s1, d1) | inside the first 30 min (GDD §5) | Pass |
| 5. New Tide 1 (130M) | **62.2** [60.9-67.9] (s7, d7) | 44.1 [40.5-49.4] (s3, d2) | 21.8 [21.3-22.3] (s1, d1) | 20-90 min (Economy.spec); typical 30-60 (key numbers) | Pass |

Notes:
- **Rod 2.** The shop opens at 45 s, after onboarding steps 4-5. The Rod is affordable from the second catch, so the guided purchase happens at 45-60 s.
- **Casual sessions.** The casual model plays 10 minutes a day, so its 10.8-minute bridge falls on day 2. A first session that runs past minute 11 reaches it on day 1, which is the blueprint's assumption.
- **Paying against casual** (goals 2, 3 and 5): **1.27x, 2.36x and 2.85x** faster (v1, with template passes from second 0: 3.72x, 2.95x, 2.55x).
  - Goal 2 is below the vault's 2-4x on purpose. The catalog sells nothing before onboarding step 12, which follows step 11, the first bridge. The paying player therefore crosses at a free player's pace (1.02x the typical player, the same skill).
  - Goals 3 and 5 are inside the band. The heavy spender (a Coin Chest every day as well) is at 2.99x on goal 5 (§19).
- **The step-12 jump.** The Starter Pack (30 min of income) and the first daily Coin Crate (60 min) arrive together at step 12 (minute 10). That buys the second bridge at once, so the paying player crosses to Gustwhistle at exactly 10.0 min in every join minute and spends about 1.5 minutes at Lantern Reef. It is inside the band; §19 lists the option of listing coin products later.
- **Set completion.** Money cannot buy set completion, so the paying-speed check leaves goal 4 out.

**Other milestones** [B]:

| Milestone | Casual free | Typical | Paying |
|---|---|---|---|
| Second upgrade line (Lure or Boots) | 4.2 | 4.2 | 4.1 |
| First nest (Driftwood) | 5.0 | 5.0 | 5.0 |
| Lure level 7 (+28% luck, more than the Sky Bell's +25%) | 23.9 | 16.9 | 10.1 |
| Bridge to Thunderhead Point (1.6M) | 38.8 | 28.9 | 14.3 |
| New Tide 2 | 92.3 | 59.2 | 26.0 |
| Rain set 3/3 (median) | 81.1 | 42.7 | 31.7 |
| Lantern Reef set 8/8 (median) | > 240 (a multi-day set) | > 240 | > 240 |

**Checks** [B]:

| Check (vault or GDD) | Result | Model value |
|---|---|---|
| First upgrade under 1 minute, every model | Pass | 45 s |
| No gap above about 3 min in the first hour (typical) | Near | Worst 3.48 min, in 2 of 15 join minutes, and only in the final save for New Tide 1 with the tide bar visible. Mean worst gap 2.73 min |
| Next purchase 1-3 min away in the first 30 min (casual; GDD test 5) | Pass | Worst gap 2.22 min |
| Paying player faster but within 2-4x (goals 2, 3, 5) | Pass (goal 2 below 2x by design) | 1.27x, 2.36x, 2.85x |
| Regain pre-tide income in 1/4-1/3 of the first cycle | Argued deviation | 0.14. The vault band assumes zones reset; here islands stay (GDD §4.7), so a tide's cost shows up in cycle length instead (§7) |

**Conservative view** (catch income only: no calendar, playtime gifts, pots or journal bonuses; the analogue of `Economy.spec`) [B]: the casual player reaches Lantern Reef at 14.8 [14.0-15.1], Gustwhistle at 29.3 and New Tide 1 at 93.6. The typical player reaches them at 10.1, 20.8 and 61.0, and the paying player (passes only, no coin products in this view) at 10.0, 15.3 and 32.9. Even without a single reward the casual first bridge stays inside the template's 8-16 minute test band.

**Return view** (sessions, later daily rewards and Tide Pots included) [B]: the casual player reaches Lantern Reef at 10.0 (the first second of session 2, day 2), Gustwhistle at 20.0 (day 3), Thunderhead at 30.0 (day 4) and New Tide 1 at 40.0 (day 5). The typical player reaches New Tide 1 at 40.1 (day 2). Return sources land at the start of a session, so goals near a session end snap to the next session. The five-goal table is the commitment; the return view is the upside.

## 2. Player models (Config/Economy.luau `playerModels`)

The template models hits per second. These models describe a fisher. `tests/Economy.spec.luau` must be re-expressed with them (§13).

| Input | Casual free | Typical | Paying | Source |
|---|---|---|---|---|
| Session length × sessions per day | 10 × 1 | 20 × 2 | 30 × 3 | Template `playerModels` |
| Reel success in Clear | 85% | 92% | 92% | First-pass; the prototype measures it (GDD §13.3) |
| Idle and menu share | 25% | 12% | 12% | Template sheet's 60/80/90% efficiency, split into idle and travel |
| Travel share at walk speed 16 (Boots shorten it) | 10% | 10% | 10% | First-pass |
| Fishing time under a front | 30% | 45% | 45% | Twist test B target 45% (GDD §13.4); the casual player chases less |
| Time under a Rainbow | 2% | 5% | 5% | First-pass |
| Share of each storm spent at the eye | 60% | 90% | 90% | First-pass |
| Friends in the server; helps per storm | 0; 1 | 1; 2 | 2; 2 | Template friend bonus; GDD §4.3 |
| Boots bought up to | 4 | 8 | 10 | First-pass |
| Purchases | none | none | The accepted catalog only (v2): 2x Coins (active from the first bridge); from onboarding step 12, the Lucky Bobber (+25% paid luck), the Starter Pack (30 min of income and a 15-minute coins2x) and one Coin Crate (60 min) a day; Third Tide Pot; Big Pal Pouch and Auto Reel owned with no income effect; a Sky Bell call every cycle (harbour only). No extra equip slots | `docs/catalog.md` (T-0009) §2-§3 |

Buying rule (best return per coin, guided moments first): buy Rod 2, then the first nest when it is shown (onboarding steps 6 and 8). After that, buy the affordable upgrade with the highest income gain per coin, but only while the next goal is further away than the upgrade's price. That last condition is the template's `simulatePacing` rule.

## 3. Catch values and catch rates

### 3.1 Value of one fish (Config/Species.luau, Util/Stats.luau)

```
coins = baseCoinsPerCatch (5)
      × tierValue        (Common 1, Uncommon 2, Rare 4, Epic 10, Legendary 30, Mythic 100, Secret 400)
      × islandMultiplier (Pebble Cove x1, Lantern Reef x4, Gustwhistle x16, Thunderhead x64;
                          catches in the Great Storm's eye use the player's best island)
      × sizeFactor       (§9.3; Gusts x1.25)
      × weatherValue     (Rainbow x2)
      × mark             (one per fish, §9.4)
      × Fish of the Day  (x3 on that species, that day; weatherValue × mark × Fish of the Day is capped at x10)
      × Rod              (1.14^level)
      × (1 + companions) (cap +100%)
      × (1 + bonus)      (journal sets +5% each, streak +2% a day up to +30%, group +10%; cap +100%)
      × (1 + boost)      (2x Coins pass +1, timed coins2x +1, additive; cap +200%)
      × New Tide         (1 + 0.5 × tides, at most 30 tides)
```

The first catch of a profile is the scripted Pebble Minnow, 0.8 kg, paying **12 coins** (kept from GDD §4.1). The first catch under Showers is the guaranteed **Pitterpike** (Rare) with Drizzled (kept). "Minutes of income", for every grant (coin products, Starter Pack, calendar, playtime gifts, Tide Pots, codes), = coins per catch at the player's best island in Clear, × **5 catches a minute**. It counts **permanent multipliers only**: Rod, companions, the bonus category, New Tide, the Lure and owned luck passes. It never counts timed boosts, friends or the 2x Coins pass (v2, §19 Q1). That is `Config/Rewards.luau` `assumedHitsPerMinute` (90 in the template), renamed `assumedCatchesPerMinute`. It feeds the template's `Stats.coinsForMinutes`.

### 3.2 Bite waits and catch rates per weather (Config/Fishing.luau `biteWait`, Config/Weather.luau)

A catch cycle is cast (1.0 s) + bite wait + reel + reveal. A failed reel costs the cast, the wait, the reel and 1 s (GDD §3). Reel times are model estimates from the GDD ring table, and the prototype measures them [A].

| Weather | Bite wait, uniform (mean) | Reel / reveal s | Cycle s | Catches/min at 85% / 92% reel | Reel success change | Size | Mark | Sky luck |
|---|---|---|---|---|---|---|---|---|
| Clear | 2.0-5.0 (3.50) | 1.5 / 1.5 | 7.50 | 6.87 / 7.40 | 0 | x1.00 | none | 0 |
| Showers | 1.0-2.5 (1.75 = 0.5x Clear) | 1.0 / 1.5 | 5.25 | 10.70 / 11.22 | +8 points | x1.00 | Drizzled 20% x1.5 | 0 |
| Sea Fog | 2.8-7.0 (4.90 = 1.4x Clear) | 1.5 / 2.0 | 9.40 | 5.28 / 5.69 | -4 points (hook tap) | x1.00 | Misty 15% x2 | +100% |
| Gusts | 2.0-5.0 (3.50) | 2.0 / 1.5 | 8.00 | 5.57 / 6.08 | -12 points (sway) | x1.25 | Breezy 20% x1.5 | 0 |
| Rainbow (60 s) | as Clear | as Clear | 7.50 | 6.87 / 7.40 | 0 | x1.00 | Prism 5% x5; value x2 | 0 |
| Great Storm eye | 2.0-4.0 (3.00) | 1.5 / 1.5 | 7.00 | 7.36 / 7.93 | 0 | x1.00 | Charged 25% x3 | 0 |

These confirm the GDD ratios: Showers 0.5x and Sea Fog 1.4x the Clear bite wait, and a catch every 6-10 s in Clear (7.5 s).

### 3.3 Fronts must pay more than Clear (twist test B; GDD §2.2): confirmed

Coins per minute under each front against Clear, at the same island and player. This is modelled per island; the full grid is in the model run notes.

| Island | Showers (target 1.5-2x) | Sea Fog (target 1.2-1.5x) | Gusts | Rainbow |
|---|---|---|---|---|
| Pebble Cove | 1.95x (casual reel 2.00x; with Lure +40%: 1.97x) | 1.42x (with Lure +40%: 1.49x) | 1.69x | 2.40x |
| Lantern Reef | 1.87x | 1.40x (1.44x) | 1.59x | 2.40x |
| Gustwhistle Bluffs | 1.87x | 1.40x (1.44x) | 1.59x | 2.40x |
| Thunderhead Point | 1.76x | 1.35x (1.34x) | 1.46x | 2.40x |
| Prototype harbour [M] | 1.92-1.97x | 1.32x | (not in the prototype) | (not in the prototype) |

**Confirmed, after one adjustment.** The first model run gave Sea Fog 1.54-1.63x, above the GDD's 1.5x. I lowered the weather-only weights to fix that (§16, rows 23-24). The marks stay as the GDD has them (Drizzled 20% x1.5, Misty 15% x2). Showers is the coin weather and Sea Fog the rare weather: Rare-or-better per catch at Lantern Reef is 12.0% in Clear, 16.3% in Showers and 32.0% in Sea Fog [A].

## 4. Upgrade cost curves (Config/Upgrades.luau)

Formula (template `EconomyMath.upgradeCost`): `cost(L) = round(baseCost × costGrowth^L)` [C].

| Line (template `kind`) | baseCost | costGrowth | Effect per level | maxLevel | Resets on New Tide | Shown | L0 | L5 | L10 | L20 | L24 | L40 | L60 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Rod (`power`) | 15 | 1.28 | coins x1.14 | 150 | yes | 0 s | 15 | 52 | 177 | 2.09K | 5.61K | 291K | 40.6M |
| Lure (`luck`) | 150 | 2.0 | luck +4% (Gear) | 25 | no | 4:00 | 150 | 4.8K | 153.6K | 157.3M | 2.52B | - | - |
| Boots (`speed`) | 120 | 1.55 | walk speed +1 | 16 | yes | 4:00 | 120 | 1.07K | 9.61K | - | - | - | - |
| Pal Pouch (`storage`) | 1,000 | 3.0 | companion capacity +10 | 10 | no | Lantern Reef | 1K | 243K | - | - | - | - | - |

Reasoning per curve:
- **Rod.** The template values are kept. r = 1.28 and g = 1.14 give r/g = 1.123, inside the vault's 1.03-1.15 band for early lines: each level takes about 12% longer than the last, which pushes the player to the next bridge. maxLevel is cut from 400 to 150, because a cap of 1.14^150 (about x343M) is still never reached in the model and "no multiplier without a cap" needs a real bound. A visual Rod tier changes every 3 levels (GDD §4.4).
- **Lure.** Growth is steepened from the template's 1.6 to 2.0 and the effect cut from +5% to +4% (cap +100% at level 25). Lure survives New Tide, and every island jump multiplies income (§5). At 1.5 the line maxed inside the first 45 minutes. At 2.0 the typical player reaches level 25 after about 3 hours of play (day 4-5) and the casual player in about week 3. The casual player first passes the Sky Bell's +25% at Lure 7, at minute 23.9.
- **Boots.** The template's 1.55 growth is kept, with base 120 so that Lure and Boots are a real choice at minutes 4-6 (GDD §3.1). Walk speed only shortens travel, so the return-based buyer stops at 4-10 levels.
- **Pal Pouch.** This is capacity only (GDD §4.4: equip slots stay at the template's 3). It adds no income and is a collection sink. Growth 3.0 replaces the template's 1.8 so that later levels stay meaningful at later islands.

## 5. Islands and bridges (Config/Zones.luau)

| Island (order) | gateCost | valueMultiplier | Home weather | Nest | Casual / typical arrival |
|---|---|---|---|---|---|
| Pebble Cove (1) | 0 | x1 | Showers | Driftwood Nest | start |
| Lantern Reef (2) | **620** | x4 | Sea Fog | Reef Nest | 10.8 / 8.7 min |
| Gustwhistle Bluffs (3) | **19,000** | x16 | Gusts | Bluff Nest | 23.6 / 16.4 min |
| Thunderhead Point (4) | **1,600,000** | x64 | mixed | Thunder Nest | 38.8 / 28.9 min |

**Formula and reasoning.** I priced each gate with `gate = income at arrival × target minutes` (economy-math §3), then tuned each price by bisection in the model: Lantern Reef for casual at 11.0, Gustwhistle for casual at 24, Thunderhead for typical at 29. Prices are rounded to two significant figures.

The steps are large (x31, then x84) because Rod catch-up amplifies every island multiplier. After a jump of M, the player buys Rod levels until the cost-to-income ratio is back where it was. That adds ΔL = ln M / ln(r/g) levels, so income grows by `M × g^ΔL = M^(1 + ln g / ln(r/g)) = M^2.13`, about **x19 for each x4 island**.

I kept the template's x4 island multiplier and sized the gates to that amplification. Thunderhead needs no New Tide: the GDD lists the four islands in order with no requirement (§4.5). It also means every New Tide happens with all four islands open, so a single geometric tide cost works (§7). The casual player reaches zone 4 at 38.8 minutes, inside the vault's 35-60 minute band (progression-architecture).

## 6. Nests and companions (Config/Eggs.luau, Config/Pets.luau)

Nests are paid random items (D2). Odds are always shown from the same table the server rolls. **No luck of any kind applies to nests**, which keeps the D2 disclosure simple. The Engineer passes luck 1 to `Odds.effective` for nests, because the template applies Lure luck to eggs [J].

| Nest | Price | Common (75) | Rare (22) | Legendary (3) | Hard pity |
|---|---|---|---|---|---|
| Driftwood Nest (Pebble Cove, shown at 5:00) | 150 | 75.00%, coins +5% | 22.00%, +10% | 3.00% (1 in 33.3), +25% | Legendary on hatch 80 = 2.4x expected |
| Reef Nest (Lantern Reef) | 5,000 | +10% | +20% | +50% | same |
| Bluff Nest (Gustwhistle) | 1,000,000 | +15% | +30% | +75% | same |
| Thunder Nest (Thunderhead) | 50,000,000 | +20% | +40% | +100% | same |

Prices are about 1-5 minutes of casual income on arrival (the Thunder Nest up to about 10). Pity was simulated with 200,000 players hatching until the first Legendary [J]. The mean was 30.5 hatches (median 23, p90 77), and 9.16% reached pity (closed form 9.02%), for an effective Legendary rate of 3.275%. Template `Odds.spec` requires pity at 1.8-3.2x expected, and 2.4x passes.

**Companion perks** (active only in their weather; the Designer names the 9 unnamed companions and may swap perks inside the same caps). The model counts coin bonuses (expected value per hatch, best 3 equipped) and leaves perks out, so it is conservative.

| Nest | Common | Rare | Legendary |
|---|---|---|---|
| Driftwood (Showers) | Puddle Frog: bite wait -10% | Drizzled chance +3 points | Luck +15% |
| Reef (Sea Fog) | Lamp Moth: luck +10% | Reel success +5 points | Luck +25% |
| Bluff (Gusts) | Kite Gull: reel success +5 points (steadier band) | Breezy chance +3 points | Luck +25% |
| Thunder (Great Storm) | Storm Petrel: Sky Dial +5 min (no economy effect) | Charged chance +5 points | Luck +25% at the eye |

Perk caps: bite wait at most -30%; reel success at most 98%; a mark chance at most 2x its weather's base; Charged at most 50%; companion luck +50% (§10).

## 7. New Tide (Config/Economy.luau; GDD §4.7)

| Key | Template | Reel the Storm | Reason |
|---|---|---|---|
| `rebirthBaseCost` → `newTideBaseCost` | 250,000 | **130,000,000** | Tuned to typical New Tide 1 at 45 min (modelled 44.1); casual 62.2 |
| `rebirthCostGrowth` → `newTideCostGrowth` | 3 | **1.9** | Keeps tides 2-13 within 90 min each (below) |
| `rebirthMultiplierPerRebirth` | 0.5 | 0.5 | Kept: x1.5 after tide 1, which roughly doubles early speed once the Rod catches up (rebirth-and-prestige) |
| `maxNewTides` (new cap) | none | **30** (x16) | "No multiplier without a cap" |
| `rebirthKeepsZones` | true | true | GDD §4.7: keeps islands, journal, companions, Lure and Pal Pouch; resets coins, Rod and Boots |
| Requirement | - | all four islands | Every tide then happens at x64 (§5) |

Costs: tide 1 is 130M, 2 is 247M, 3 is 469M, 5 is 1.69B and 10 is 42B [D].

**Cycle lengths** (typical, catch income and storms, no rewards) [D]:

| New Tide # | 1 | 2 | 3 | 5 | 8 | 10 | 11 | 12 | 15 | 20 | 25 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Minutes since the previous tide | 59.8 | 16.4 | 16.5 | 19.3 | 29.6 | 43.0 | 52.0 | 66.1 | 134.8 | 462.9 | 1,684.6 |
| Cumulative hours | 1.0 | 1.3 | 1.5 | 2.1 | 3.4 | 4.7 | 5.6 | 6.7 | 12.1 | 36.7 | 124.9 |

**Formula.** With greedy Rod buying, a cycle's length grows like `T_n^α / I_n`, where α = ln(r/g) / ln r = 0.47 and I_n is the tide multiplier. Each tide's cost is x1.9, so time grows x1.35, and the multiplier rises by (1 + 0.5(n+1)) / (1 + 0.5n). The cycle therefore grows slowly at first, then faster.

**Findings:**
- Tides 2-4 run 16-17 minutes, below the vault's "typically 20-90": islands stay, so a Rod rebuild at x64 is quick. A steeper growth (2.1) did not lengthen tide 2 (16.0 min) and shortened the life of the layer, so I kept 1.9.
- Tides 5-13 sit at 19-85 minutes.
- **A second layer (for example a "Great Tide") must be designed before tide 12** (about 6.7 h of play, about day 10 for the typical player), with multi-tide before then. That is earlier than the vault's "before about 50", because there are only four islands at launch. Each new island (every 3-4 weeks, GDD §4.11) must be priced with the x19 amplification of §5.

## 8. Great Storm and Stormborn (Config/Weather.luau `greatStorm`, Config/Species.luau)

| Key | Value | Source and reason |
|---|---|---|
| Cycle, duration | every 900 s at :00/:15/:30/:45 UTC, 180 s | Design value (GDD §4.2) |
| Stormborn hook chance per eye bite | **4.0%** (GDD 2.5%) | GDD §4.3 target: "hooks a Stormborn at least every other storm". With the brief's cap of 1 per player per storm and 14-17 eye bites per storm, 2.5% gives 31-35% per storm. 4.0% gives 45-50% from Pebble Cove and 38-42% from Gustwhistle [D] |
| Most Stormborn per player per storm | 1 | Prototype brief req. 9.3 |
| Hook pity (new) | the next eye bite hooks after 60 eye bites without one (2.4x the expected 25) | DESIGN-04. Storms to the first hook, with pity: typical 1.9-2.3, casual 2.0-2.4 [D] |
| Pull time | 45 / (1 + 0.875 × helpers) s: 45 s solo, 12.4 s with 3, 10 s with 4 | Design value, kept |
| Stormborn table (luck cannot change it: all four are luck tiers) | two Legendary (weights 50, 37), Rumblefin Mythic (12), one Secret (1) | Rumblefin is 0.48% of eye bites and the Secret 0.04% [E] |
| Stormborn coin value | tier value × **0.5** × best island multiplier | Their prize is the journal page, the banner and the crowd. A full-value giant made the first bridge depend on the storm clock (a typical player bridged at 3.3 min when joining at a storm) |
| Eye catches | Pebble Cove species at the **player's best island multiplier**; Charged 25% x3 (landing tap; the GDD's design target) | Keeps the storm the best quarter-hour for veterans. **New rule for the GDD** (§15) |
| Charged on Stormborn | 25% + 5% per friend among helpers, cap 50%, x3 | Kept (GDD §4.3) |
| Helper share | **10%** of the giant's value (at the helper's own multipliers), at most **3** paid helps per player per storm | Prototype fallback 25% → 10%: at 25%, a new player's first storm paid more than 3 minutes of fishing in helper shares alone |

Storm share of all coins [B]: casual 5.4%, typical 11.2%, paying 12.9%. During its 3 minutes the eye pays 1.61x Clear coins per minute before Stormborn [M].

## 9. Drop tables (DESIGN-04; Config/Species.luau, Config/Pets.luau `Rarities`)

### 9.1 Tiers and designed time-to-see

Tiers and colours are the template's `Config/Pets.luau` `Rarities` (Common to Secret). Luck applies to Rare and up (`luckApplies`). Announcements follow the template: server for Legendary and Mythic, global for Secret. Median time-to-first-see, in cumulative active minutes, uses p_seen(t) = 1 - exp(-Λ(t)) over the modelled catch stream, including weather-only species and Stormborn [F]:

| Tier | Designed median (casual free) | Casual free | Typical | Paying |
|---|---|---|---|---|
| Common | first catch (scripted at 0:18) | 0.3 | 0.3 | 0.3 |
| Uncommon | 1.5 min or less | 1.0 (p90 2.4) | 0.8 | 0.8 |
| Rare | 3 min or less (scripted Pitterpike at about 2:00) | 2.0 (p90 2.2) | 1.6 | 1.3 |
| Epic | 5-15 min | 6.5 (p90 17.5) | 4.6 | 3.7 |
| Legendary | 20-45 min | 23.8 (p90 52.4) | 15.9 | 11.5 |
| Mythic | typical: in the first week (280 min or less); casual: weeks | 116.5 (about day 12) | 83.1 (day 3) | 63.8 |
| Secret | no promise (30 h or more) | about 4,800 min | about 2,800 min (about day 70) | about 2,700 min |

The design follows the vault ladder (Rare in the first minute or two, Epic by about minute 5, Legendary by about minute 20, Mythic in the first week), slowed for a 10-minute-a-day casual player.

### 9.2 Tables per island and weather

Probability = weight / table total; luck multiplies luck-tier weights, then renormalises (template `Odds.effective`). Under a front, the island's 8 species plus the front's 3 weather-only species form one table. The displayed odds below are for luck x1, except natural Sea Fog with its Sky +100% [E]. The value column is coins at Rod 0. Slot ids are named by the Designer; names already in the prototype brief are used.

**Pebble Cove (x1).**

| Species | Tier | Weight | Value | Clear | Showers | Sea Fog | Gusts |
|---|---|---|---|---|---|---|---|
| pebble_minnow | Common | 26 | 5 | 25.87% | 21.05% | 20.25% | 22.03% |
| bobblefin | Common | 22 | 5 | 21.89% | 17.81% | 17.13% | 18.64% |
| sandskipper | Common | 18 | 5 | 17.91% | 14.57% | 14.02% | 15.25% |
| tidetail | Uncommon | 13 | 10 | 12.94% | 10.53% | 10.12% | 11.02% |
| kelpnibbler | Uncommon | 11 | 10 | 10.95% | 8.91% | 8.57% | 9.32% |
| copperscale | Rare | 4.7 | 20 | 4.68% | 3.81% | 7.32% | 3.98% |
| pc_rare_2 | Rare | 3.8 | 20 | 3.78% | 3.08% | 5.92% | 3.22% |
| pc_epic_1 (the set's lock) | Epic | 2.0 | 50 | 1.99% | 1.62% | 3.12% | 1.69% |
| splashkin (rain-only) | Uncommon | 15 | 10 | - | 12.15% | - | - |
| pitterpike (rain-only) | Rare | 6.5 | 20 | - | 5.26% | - | - |
| rain_epic (rain-only) | Epic | 1.5 | 50 | - | 1.21% | - | - |
| hushgill (fog-only) | Rare | 6.0 | 20 | - | - | 9.35% | - |
| lanternfin (fog-only) | Epic | 2.2 | 50 | - | - | 3.43% | - |
| fog_legendary (fog-only) | Legendary | 0.5 | 150 | - | - | 0.779% | - |
| gust_rare (gust-only) | Rare | 12 | 20 | - | - | - | 10.17% |
| gust_epic (gust-only) | Epic | 4.5 | 50 | - | - | - | 3.81% |
| gust_legendary (gust-only) | Legendary | 1.0 | 150 | - | - | - | 0.847% |
| sum | | | | 100% | 100% | 100% | 100% |

**Lantern Reef (x4) and Gustwhistle Bluffs (x16)** have the same shape; values are x4 and x16.

| Slot | Tier | Weight | Clear | Showers | Sea Fog | Gusts |
|---|---|---|---|---|---|---|
| lr_ / gb_ common_1, 2, 3 | Common | 25, 21, 17 | 25.00, 21.00, 17.00% | 20.33, 17.07, 13.82% | 19.32, 16.23, 13.14% | 21.28, 17.87, 14.47% |
| uncommon_1, 2 | Uncommon | 14, 11 | 14.00, 11.00% | 11.38, 8.94% | 10.82, 8.50% | 11.91, 9.36% |
| rare_1 | Rare | 9 | 9.00% | 7.32% | 13.91% | 7.66% |
| epic_1 | Epic | 2.6 | 2.60% | 2.11% | 4.02% | 2.21% |
| legendary_1 (the set's lock) | Legendary | 0.4 | 0.400% | 0.325% | 0.618% | 0.340% |

Under a front, the weather-only rows read: Showers 12.20 / 5.28 / 1.22%; Sea Fog 9.27 / 3.40 / 0.773%; Gusts 10.21 / 3.83 / 0.851%.

**Thunderhead Point (x64).**

| Slot | Tier | Weight | Clear | Showers | Sea Fog | Gusts |
|---|---|---|---|---|---|---|
| tp_common_1, 2 | Common | 30, 25 | 30.00, 25.00% | 24.39, 20.33% | 22.32, 18.60% | 25.53, 21.28% |
| tp_uncommon_1, 2 | Uncommon | 15, 13 | 15.00, 13.00% | 12.20, 10.57% | 11.16, 9.67% | 12.77, 11.06% |
| tp_rare_1 | Rare | 11.5 | 11.50% | 9.35% | 17.11% | 9.79% |
| tp_epic_1 | Epic | 4.5 | 4.50% | 3.66% | 6.70% | 3.83% |
| tp_legendary_1 | Legendary | 0.9 | 0.900% | 0.732% | 1.34% | 0.766% |
| tp_mythic_1 | Mythic | 0.1 | 0.100% | 0.081% | 0.149% | 0.085% |

Under a front, the weather-only rows read: Showers 12.20 / 5.28 / 1.22%; Sea Fog 8.93 / 3.27 / 0.744%; Gusts 10.21 / 3.83 / 0.851%.

**Great Storm eye** (Pebble Cove species, chance per eye bite): pebble_minnow 24.84%, bobblefin 21.01%, sandskipper 17.19%, tidetail 12.42%, kelpnibbler 10.51%, copperscale 4.49%, pc_rare_2 3.63%, pc_epic_1 1.91%. Stormborn: legendary_1 2.00%, legendary_2 1.48%, rumblefin 0.480%, secret 0.040%. Everywhere else on the map during the storm is light rain: the island's Clear table.

**Aurora Night** (weekly event table): aurora_rare 70%, aurora_epic 25%, aurora_legendary 5%. Auroral mark 10%, x3.

**Sky Journal sets** (12): each island set needs its rarest member, which locks it: the Pebble Cove Epic at 2.0% (set median 17.2 casual), the Lantern Reef and Gustwhistle Legendary at 0.4% (multi-day sets), the Thunderhead Mythic at 0.1%. Each completed set adds **+5% coins** in the bonus category (§11) and a title.

### 9.3 Size roll (Config/Species.luau `sizeRoll`)

`factor = clamp(exp(N(-σ²/2, σ)), 0.5, 3.0)` with σ = 0.25 (Stormborn 0.30); Gusts multiply by 1.25 after the clamp. `kg = species base kg × factor`, and value is proportional to factor. Base kg by tier: Common 0.8, Uncommon 2, Rare 5, Epic 12, Legendary 40, Mythic 180 (Rumblefin), Secret 500; the Designer may vary them per species. One million rolls [K]: mean 1.0000, median 0.969, p99 1.732; 4.01% at 1.5x or more and 0.182% at 2x or more (record-board fish).

### 9.4 Marks (Config/Species.luau `marks`): one per fish, never stacked

| Mark | Where | Chance | Value | EV factor |
|---|---|---|---|---|
| Drizzled | Showers | 20% | x1.5 | x1.10 |
| Misty | Sea Fog | 15% | x2 | x1.15 |
| Breezy | Gusts | 20% | x1.5 | x1.10 |
| Prism | Rainbow (60 s) | 5% | x5 | x1.20 (on top of the Rainbow's x2) |
| Charged | Great Storm: regular catches by a landing tap on a flash (about 25% for a typical player, modelled); Stormborn by chance 25% + 5% per friend helper, cap 50% | as listed | x3 | x1.5 |
| Auroral | Aurora Night | 10% | x3 | x1.2 |

Caps: no mark above x5 (sketch risk 5); companion perks may at most double a mark chance; weatherValue × mark × Fish of the Day ≤ x10.

## 10. The luck stacking rule and its caps (Config/Economy.luau `luck` block, Util/Stats.luau)

**One rule, shown in the odds panel: additive inside a category, multiplied across categories, every category capped, the product capped.**

```
luck = min(6, (1 + Gear) × (1 + Companions) × (1 + Friends) × (1 + Sky))

Gear       = min(1.00, 0.04 × Lure level)                                  earned
Companions = min(0.50, sum of equipped companions' luck perks in this weather)  earned
Friends    = min(0.50, 0.10 × friends in the server)   (template friendBonusPerFriend / maxFriendBonus, on luck)
Sky        = min(1.00, natural weather at the spot          (Sea Fog +1.00; others 0)
                     + min(0.25, paid luck)                 (Sky Bell shared bonus +0.25, Lucky Bobber +0.25)
                     + free timed luck)                     (day-7 Lucky Tide +0.25, a code boost +0.25)
```

Luck multiplies Rare-and-up weights and renormalises. It never applies to nests or to the Stormborn table. Players whose `ArePaidRandomItemsRestricted` is true get no paid luck (template `Stats.derive`).

Scenarios [G]:

| Scenario | Gear | Comp. | Friends | Sky | Applied luck |
|---|---|---|---|---|---|
| New player, Clear | 0 | 0 | 0 | 0 | x1.00 |
| New player under a called Showers (Sky Bell bonus) | 0 | 0 | 0 | +25% | x1.25 |
| New player in natural Sea Fog | 0 | 0 | 0 | +100% | x2.00 |
| New player under a called Sea Fog (bonus capped away) | 0 | 0 | 0 | +100% | x2.00 |
| Casual after day 3: Lure 7, Clear | +28% | 0 | 0 | 0 | x1.28 |
| Typical, hour 1-2: Lure 12, Lamp Moth, 1 friend, Sea Fog | +48% | +15% | +10% | +100% | x3.74 |
| Max free, Clear | +100% | +50% | +50% | 0 | x4.50 |
| Max free in Sea Fog (total cap binds) | +100% | +50% | +50% | +100% | x6.00 |
| Max paying, Clear (paid share capped at +25%) | +100% | +50% | +50% | +25% | x5.63 |
| Max paying in Sea Fog | +100% | +50% | +50% | +100% | x6.00 |

The cap's effect on odds, Thunderhead Clear [G]:

| Luck | Rare | Epic | Legendary | Mythic | Coin value per catch |
|---|---|---|---|---|---|
| x1 | 11.50% | 4.50% | 0.900% | 0.100% | x1.00 |
| x2 | 19.66% | 7.69% | 1.54% | 0.171% | x1.31 |
| x6 (cap) | 37.30% | 14.59% | 2.92% | 0.324% | x1.99 |

The total cap is x6, down from the template's `maxLuck` 10. At the cap the Mythic is about 1 in 300 catches (40 minutes at Thunderhead for a maxed player): still a server-wide moment, never routine.

## 11. Coin multiplier categories and the maxed player [I]

| Category | Rule | Cap | Max free | Max paying |
|---|---|---|---|---|
| Rod | x1.14 per level | maxLevel 150 | same | same |
| Island | x1 / x4 / x16 / x64 | x64 | same | same |
| Companions (coins) | 1 + sum of the 3 equipped | x2.0 (template `maxPetMultiplier` 25) | x2.0 | x2.0 |
| Bonus | journal sets +5% each, streak +2%/day up to +30%, group +10% (`Game.groupCoinBonus`), additive | x2.0 | x2.0 | x2.0 |
| Boost | 2x Coins pass +100% (from the first bridge) and timed coins2x +100%, **additive** (the template multiplies them) | x3 | x2 (timed boost) | x3 |
| New Tide | +50% per tide | x16 at 30 tides | x16 | x16 |
| Per fish | weatherValue × mark × Fish of the Day | x10 | same | same |
| Luck | §10 | x6 | x6 | x6 |

Product of the capped categories other than Rod and island (equal for both): free x128, paying x192. That is **1.5x** with a free timed boost active and **3.0x** without: inside "not absurd", and paid luck changes nothing at the cap.

## 12. Sources, sinks, rewards and Tide Pots

### 12.1 Sources and sinks (measured, return view, first 240 play minutes) [B]

| Source | Casual free | Typical | Paying |
|---|---|---|---|
| Catches outside storms | 41.0% | 61.9% | 67.9% |
| Great Storm (eye catches, Stormborn, helper shares) | 5.4% | 11.2% | 12.9% |
| Tide Pots | 31.2% | 11.5% | 5.3% |
| Calendar, playtime gifts, scripted first catch | 22.4% | 15.4% | 3.5% |
| Robux coin products (Starter Pack, daily Coin Crate) | 0 | 0 | 10.4% |

| Sink (share of coins spent) | Casual | Typical | Paying |
|---|---|---|---|
| Rod | 63.6% | 74.2% | 63.5% |
| New Tide | 35.8% | 25.2% | 36.4% |
| Lure, Boots, Pal Pouch, nests, bridges | under 1% together (cheap against the late exponential prices) | under 1% | under 0.1% |
| Unspent at 240 min (share of earned) | 4.2% | 15.1% | 6.4% |

Every source has a sink. Nests are the endless sink (D2), and New Tide resets coins, Rod and Boots. Every source and sink logs `AnalyticsService:LogEconomyEvent` with its transaction type (template `Analytics`); Tide Pots log as `TimedReward`. Passive income (Tide Pots) is below half for every model, including active players (vault rule). The casual player's coins come mostly from return sources (54%), which is by design for a 10-minute-a-day player (the return outcome).

### 12.2 Rewards (Config/Rewards.luau; coins only, GDD §5)

"Min" means minutes of income (§3.1). The template's Gems lines are re-expressed as coins or items.

| Day | 1 | 2 | 3 | 4 | 5 | 6 | 7 (best, previewed from day 1) |
|---|---|---|---|---|---|---|---|
| Calendar | 2 min | 3 min | 4 min + a raincoat colour (GDD §4.8 cosmetic) | 5 min + coins2x 10 min | 6 min | 8 min | 12 min + Lucky Tide (+25% Sky luck, 15 min) + Tide Pot bait (+2 fish) |

Streak: +2% coins a day, cap +30% (template), in the bonus category; one free Calm Day freeze per 7 days (GDD).

| Playtime gift (per session; template minutes) | 5 | 10 | 15 | 25 | 40 | 60 (best) |
|---|---|---|---|---|---|---|
| Reward | 1 min | 1 min | 2 min | coins2x 10 min | 3 min | 5 min |

Other rewards (GDD §4.8-§4.9; not in the five-goal table):
- **Almanac:** 1 min of income per task, plus 2 min for all three (5 min a day). The Fish of the Day pays x3 that day.
- **Welcome back** (3 or more days away): 10 min of income plus coins2x for 15 min.
- **Codes** (`Config/Codes.luau`): 2-5 min of income, or a 10-minute Lucky Tide; once per player.
- **Referrals:** the invitee gets coins2x for 15 min; the inviter gets a raincoat colour and 5 min of income. At most 3 rewarded invitees per inviter per day, and once per invitee.

### 12.3 Tide Pots (Config/TidePots.luau, new)

| Key | Value |
|---|---|
| Slots | 1 free (onboarding step 10, about 9:00) plus 1 on reaching Lantern Reef (GDD) |
| Fill cap | 8 h (GDD) |
| Fill rate | **0.5 minute of active income per pot-hour**, at the player's best island and current multipliers (`Stats.coinsForMinutes`) |
| Fish | 1 per hour, so **8 at full**, inside the GDD's 6-10. Fish carry the marks of the weather that really passed the spot, never Stormborn. Day-7 bait adds 2 |
| Efficiency against active play | **0.83%** (GDD and vault first-pass: 20-30%) |

Why not 20-30% [L]: with an 8-hour cap and two slots, 25% makes a full pot worth 120 minutes of income. That gives the typical player 420 income-minutes a day from pots against 40 active minutes, a 91% passive share, and a casual player 96%. The vault's rule is passive income below half for active players. 25% also contradicts the GDD's own "6-10 fish" reveal, since an active player lands about 7 fish a minute. At 0.83%:

| Model | Passive share (formula) | Passive share (measured) |
|---|---|---|
| Typical | 26% | 11.5% |
| Casual | 44% | 31.2% |

The pot stays a strong return hook: the casual player's 8 minutes of income each morning is close to a whole day's play.

## 13. Sky Bell calls (D6): the capped shared bonus (GDD §4.10) [H]

The GDD's timing is used as given: 180 s, a storm guard from 60 s before to 30 s after, 1 active, 2 queued, one per buyer, at most 2 per cycle, harbour Callable spots only. A call behaves exactly like a natural front of its type. On top, the sheet gives it one **shared bonus: Sky luck +25% for every player fishing under the call** (none for the buyer alone).

| Called weather | Luck: natural front → call (new player) | Rare-or-better per catch | Coin value per catch |
|---|---|---|---|
| Showers | x1.00 → x1.25 | 14.98% → 18.05% | +6.0% |
| Sea Fog | x2.00 → x2.00 (Sky cap: the bonus adds 0) | 29.91% → 29.91% | 0 |
| Gusts | x1.00 → x1.25 | 23.73% → 28.00% | +8.8% |

**Caps that keep it below active play with upgrades:**
1. The bonus sits in the Sky category with every other paid luck. Paid luck combined is capped at **+25%**. That is below Lure 7 (+28%, which the casual player reaches by minute 23.9), a quarter of the Gear cap (+100%), and well under Gear × Companions at cap (x3.0).
2. The Sky category is capped at +100%. A called Sea Fog is therefore never luckier than a natural one: the most a call can give anyone is free weather plus +25%.
3. Total luck is capped at x6.
4. The harbour pays Pebble Cove values (x1). A called Showers pays +105% per minute against Clear at the harbour; 93 points of that is what a natural Showers pays, so the bonus adds 12 points, about 3.1 extra minutes of harbour income per call per player. A player at Gustwhistle earns 8x more per minute at home, so for anyone past Lantern Reef a call is a collection and social moment, not income.
5. Coverage is at most 2 × 180 s = 50% of the 720 non-storm seconds, and only on clear harbour time.

**Worst-case pacing effect** (Showers calls on 50% of non-storm time, with the player always under them):

| Model | Bridge to Lantern Reef | Bridge to Gustwhistle | New Tide 1 |
|---|---|---|---|
| Casual | 10.8 → 9.9 (-8.6%) | 23.6 → 21.8 (-7.7%) | 62.2 → 61.3 (-1.4%) |
| Typical | 8.7 → 7.1 (-17.6%) | 16.4 → 15.1 (-7.9%) | 44.1 → 40.3 (-8.5%) |

The Monetization Designer prices the three products (T-0009). How a paid, server-wide luck change is disclosed is the human's question (D6 open item, GDD O-H1); the restricted-player case is O-H2. The Engineer: all Robux-linked luck goes through the paid sub-cap in `Util/Stats.luau`. The catalog (T-0009) keeps every paid luck item inside it: the Lucky Bobber (+25%) replaces the template's Lucky, and the Luck Potion (x2) and Server Luck (x2) are dropped.

## 14. Prototype subset (GDD §13; paste into Config for `specs/prototype.md`) [M]

This table replaces the brief's fallbacks. The spots are `cove_dock` (sheltered, always Clear outside the storm), `cove_shallows` and `pier_head` (the eye), on the GDD §13.2 timetable. There is no Lure, no companions and no friend bonus: luck is 1.0, and Sea Fog doubles Rare-and-up weights.

**Config/Species.luau (prototype)**

| id | Tier | Table | Weight | Base coins | Base kg | Clear (and storm away from the eye) | Showers | Sea Fog |
|---|---|---|---|---|---|---|---|---|
| pebble_minnow | Common | clear | 26 | 5 | 0.8 | 27.08% | 22.13% | 21.96% |
| bobblefin | Common | clear | 22 | 5 | 0.8 | 22.92% | 18.72% | 18.58% |
| sandskipper | Common | clear | 18 | 5 | 0.8 | 18.75% | 15.32% | 15.20% |
| tidetail | Uncommon | clear | 13 | 10 | 2 | 13.54% | 11.06% | 10.98% |
| kelpnibbler | Uncommon | clear | 11 | 10 | 2 | 11.46% | 9.36% | 9.29% |
| copperscale | Rare | clear | 6 | 20 | 5 | 6.25% | 5.11% | 10.14% |
| splashkin | Uncommon | showers | 15 | 10 | 2 | - | 12.77% | - |
| pitterpike | Rare | showers | 6.5 | 20 | 5 | - | 5.53% | - |
| hushgill | **Rare** (brief: Uncommon) | fog | 6 | 20 | 5 | - | - | 10.14% |
| lanternfin | Epic | fog | 2.2 | 50 | 12 | - | - | 3.72% |
| rumblefin | Mythic (the only Stormborn) | storm | - | 250 | 180 | eye only | | |

Other prototype values:
- **Config/Fishing.luau.** `biteWait`: Clear 2.0-5.0, Showers 1.0-2.5, Sea Fog 2.8-7.0, Storm 2.0-4.0 s. First catch 12 coins. First Showers catch is Pitterpike with Drizzled.
- **Marks.** Drizzled 20% x1.5; Misty 15% x2; Charged x3 by a landing tap (regular catches) or by chance 25% + 5% per friend helper, cap 50% (Rumblefin).
- **Size.** Size roll as in §9.3; it replaces the brief's uniform 0.8-1.25.
- **Rumblefin.** 4.0% of eye bites, at most 1 per player per storm (pity optional in the prototype). Helper share 10%, at most 3 paid helps per storm.
- **Config/Upgrades.luau.** Rod: template values 15 / 1.28 / 1.14, maxLevel 30. `coinsForStep4 = 15`.

Prototype results:

| Measure | Casual | Typical | Target |
|---|---|---|---|
| First Rod | 45 s | 45 s | about 60 s |
| Rod level at 10 / 20 min ("target" behaviour: 41% of line time under fronts) | 14.5 / 19.5 | 16.9 / 22.3 | - |
| At 10:00, minutes to the next Rod level | 0.67 (max 1.42) | 1.06 (max 2.00) | 1-3 (loop test 5) |
| Worst gap between Rod buys, first 10 min | 1.83 | 2.07 | 30 s - 2 min (GDD §2.2) |
| Worst gap over the 20 minutes | 2.98 | 3.32 | one line only, so it widens after minute 10 |
| Coins per minute vs Clear: Showers / Sea Fog / eye | 1.97 / 1.32 / 1.61 | 1.92 / 1.32 / 1.61 | Showers 1.5-2x, Sea Fog 1.2-1.5x |
| P(hooks Rumblefin) per storm, at the eye all storm | - | 55% (2.2 pulls a storm with 4 anglers) | at least every other storm |

If testers stall between minutes 15 and 20 (one Rod line only), the lever is Rod `costGrowth` 1.24 in the prototype. That is a change for the QA report, not now.

## 15. Changes against the GDD's "economy sheet (T-0008)" targets (for the Designer to sync)

| # | GDD place | GDD value | Sheet value | Why |
|---|---|---|---|---|
| G1 | §4.8 Tide Pots, §5 | "about 20-30% of active play ... about 6-10 fish when full" | 0.5 min of income per pot-hour (0.83%), 8 fish when full | §12.3: 25% makes passive income 91% of a typical day |
| G2 | §4.3 item 7, §12, brief req. 9.3 | Stormborn hook 2.5% per eye bite | **4.0%**, plus pity at 60 eye bites | Keeps "at least every other storm" under the 1-per-storm cap (§8) |
| G3 | brief req. 9.7 | helper share 25%, at most 3 | **10%**, at most 3 per storm | §8 |
| G4 | §4.3 (not stated) | - | Eye catches and Stormborn pay at the player's **best island** multiplier; Stormborn at half their tier value | Keeps the storm the best moment for every player without making the first bridge depend on the storm clock |
| G5 | §4.10 effect | "shared bonus ... may be zero" | **+25% Sky luck** for players under a call; 0 in Sea Fog | §13 |
| G6 | brief req. 5 | Hushgill Uncommon; values C 10 / U 25 / R 80 / E 250 / Rumblefin 1,500; size uniform 0.8-1.25 | Hushgill Rare; values 5 / 10 / 20 / 50 / 250; lognormal size | One scale for prototype and launch; Sea Fog is the "more rares" weather |
| G7 | brief req. 3.2 fallback | Sea Fog bite 3-7 s | 2.8-7.0 s (mean 4.9 = 1.4x Clear, the GDD §4.1 ratio) | Matches the GDD ratio |
| G8 | §4.4 | Lure resets no; Pal Pouch capacity; 3 equip slots | kept as written; Lure +4%/level, max 25 | §4 |
| G9 | §4.5 | islands in order | Thunderhead needs no New Tide; New Tide needs all four islands | §5, §7 |
| G10 | §4.6 | rarity, time-to-see, size, marks to come from the sheet | §9 | - |
| G11 | §5 targets | Showers 1.5-2x, Sea Fog 1.2-1.5x, Pebble Cove set within 30 min, gap ≤ 3 min | confirmed (§3.3, §1) | - |

Kept unchanged, as the Director asked: first catch +12 coins; Rod 2 at 15 coins; pull formula (10 s with 4 helpers); Charged 25% +5% per friend, cap 50%; guaranteed Rare first-rain catch; coins as the only currency.

## 16. Before and after against the template config

Every changed number, from the template config to Reel the Storm, with the reason:

| # | File and key | Before (template) | After | Reason |
|---|---|---|---|---|
| 1 | Economy `baseCoinsPerHit` | 1 | `baseCoinsPerCatch` 5 | One catch is about 7.5 s, not a 0.18 s hit |
| 2 | Economy `hitCooldownSeconds`, `autoHitInterval`, node keys | 0.18, 0.45, node break | replaced by `Config/Fishing.luau` bite and reel timing | No nodes break (GDD §4.1) |
| 3 | Economy `rebirthBaseCost` | 250,000 | 130,000,000 | §7, with a x19-per-island income scale |
| 4 | Economy `rebirthCostGrowth` | 3 | 1.9 | §7 cycle lengths |
| 5 | Economy (new) `maxNewTides` | none | 30 | Cap |
| 6 | Economy `maxPetMultiplier` | 25 | companions capped at +100% (x2) | Companions are a side bonus; the Rod is the main line |
| 7 | Economy `maxLuck` | 10 | 6, with four category caps and a +25% paid cap | §10 |
| 8 | Economy `friendBonusPerFriend` / `maxFriendBonus` | 0.1 / 0.5 on coins | 0.1 / 0.5 on **luck** | GDD §4.9 |
| 9 | Economy `playerModels` | hits per second | §2 | Fishing |
| 10 | Upgrades `power` | 15 / 1.28 / 1.14, max 400 | Rod 15 / 1.28 / 1.14, max 150 | Cap |
| 11 | Upgrades `speed` | 60 / 1.55 / +1, max 16 | Boots 120 / 1.55 / +1, max 16 | Lure-or-Boots choice at 4-6 min |
| 12 | Upgrades `luck` | 400 / 1.6 / +5%, max 20, kept on rebirth | Lure 150 / 2.0 / +4%, max 25, kept | §4 |
| 13 | Upgrades `storage` | 1,000 / 1.8 / +10, max 10 | Pal Pouch 1,000 / 3.0 / +10, max 10 | Sink at later islands |
| 14 | Zones | 5 zones, gates 3K / 240K / 4.8M / 96M, x1-x256 | 4 islands, gates 620 / 19K / 1.6M, x1 / x4 / x16 / x64 | §5 |
| 15 | Eggs | 5 eggs (120 to 120M), 5 entries each, pity 600-650 or Epic 100 | 4 nests (150 / 5K / 1M / 50M), 3 entries (75 / 22 / 3), Legendary pity 80; luck never applies | §6 |
| 16 | Pets `Rarities` | 7 tiers, Rare and up luck | unchanged | - |
| 17 | Pets bonuses | 0.1 to 5,000 | +5% to +100% coins plus one weather perk | §6 |
| 18 | Pets `baseEquipSlots` / `baseCapacity` | 3 / 60 | 3 / 60 | GDD §4.4 |
| 19 | Rewards `daily` | 3, 5, 6, 8, 10, 12, 20 min plus gems and boosts | 2, 3, 4, 5, 6, 8, 12 min plus raincoat, coins2x, Lucky Tide, bait; no gems | 10-minute casual sessions; coins only |
| 20 | Rewards `playtime` | 2 min, gems, 4 min, coins2x, gems, 15 min + gems | 1, 1, 2 min, coins2x, 3, 5 min | Gifts were +75% of a 10-minute session |
| 21 | Rewards `assumedHitsPerMinute` | 90 | `assumedCatchesPerMinute` 5 | §3.1 |
| 22 | Species (new) Pebble Cove Epic weight | 1.5 (model run 1) | 2.0 | Pebble Cove set inside 30 min (median 17.2 casual) |
| 23 | Species Pitterpike / rain Epic | 8 / 2 (run 1) | 6.5 / 1.5 | Showers ≤ 2.0x Clear |
| 24 | Species Hushgill / Lanternfin / fog Legendary | 12 / 4.5 / 1 (run 1) | 6 / 2.2 / 0.5 | Sea Fog ≤ 1.5x Clear |
| 25 | Weather (new) Stormborn hook | 2.5% (run 1, as quoted by the GDD) | 4.0% plus pity 60 | §8 |
| 26 | Weather (new) Stormborn value factor; helper share | 1.5; 10% (run 1), 25% (brief) | 0.5; 10% | §8 |
| 27 | Products `passEffects.luckyLuckBonus`, `boostEffects.luck2x`, `serverLuck` | +0.5, x2, x2 | catalog: Lucky Bobber +25% (inside the paid cap); Luck Potion and Server Luck dropped | §13, §19 |
| 28 | Stats boost stacking | x2Coins × coins2x = x4 | additive, cap x3 | §11 |

## 17. Config map (every table above becomes a file)

| Table | File | Change type |
|---|---|---|
| §2 player models | `Config/Economy.luau` `playerModels` | retune |
| §3.1 value formula, tier values, Fish of the Day | `Config/Species.luau` (new), `Util/Stats.luau` | new and code |
| §3.2 bite waits and reel modifiers | `Config/Fishing.luau` (new) `biteWait`; `Config/Weather.luau` (new) | new |
| §4 upgrades | `Config/Upgrades.luau` | retune |
| §5 islands | `Config/Zones.luau` | retune, 4 islands |
| §6 nests and companions | `Config/Eggs.luau`, `Config/Pets.luau` | retune plus a perk field |
| §7 New Tide | `Config/Economy.luau` rebirth keys | retune plus `maxNewTides` |
| §8 storm and Stormborn | `Config/Weather.luau` `greatStorm`, `Config/Species.luau` | new |
| §9 drop tables, size, marks | `Config/Species.luau` | new |
| §10 luck rule | `Config/Economy.luau` `luck` block, `Util/Stats.luau`, `Util/Odds.luau` (no luck for nests) | retune and code |
| §11 coin categories | `Config/Economy.luau`, `Util/Stats.luau` | code |
| §12.2 rewards | `Config/Rewards.luau`, `Config/Codes.luau` | retune |
| §12.3 Tide Pots | `Config/TidePots.luau` (new) | new |
| §13 Sky Bell bonus | `Config/Economy.luau` `luck.calledFront`, `Config/Weather.luau` `calledFront` | new |
| §14 prototype | `Config/Species.luau`, `Config/Fishing.luau`, `Config/Upgrades.luau` | prototype build |
| Pacing tests | `tests/Economy.spec.luau` → catches per minute: Lantern Reef at 8-16 min (catch only, casual; modelled 14.8), first upgrade under 60 s, New Tide 1 at 20-90 min; `tests/Odds.spec.luau` for every species table and luck state plus the 2.4x nest pity | re-express |

## 18. Balance risks and the balance pass

1. **Compounding** (biggest risk). Rod catch-up turns each x4 island into about x19 income. New Tide cycles run 16-17 minutes for tides 2-4 and pass 90 minutes from tide 13. A second layer is needed before tide 12 (about day 10 for a typical player), and each new island must be priced with the x19 rule. A content week priced without it would be skipped in minutes.
2. **The storm clock.** The first bridge's spread across join minutes is 10.3-11.1 for casual and 6.6-9.6 for typical. It is driven by whether a storm lands in the first minutes. If playtests show bigger spreads, lower the eye value first, not the hook rate.
3. **Return income for the casual player.** Pots and calendar make 54% of a 10-minute player's coins. That is fine for return, but if casual retention depends on it, the active loop is carrying less than intended.
4. **Model assumptions the prototype must measure:** reel success (85% / 92%), the share of time under fronts (30% / 45%), the 25% flash-tap rate, eye bites per storm (about 17) and the 7.5 s Clear cycle.

**Balance pass (POLISH-05).** Compare QA playtest times for goals 1-5, catches per minute per weather, and twist B line share with this sheet. Change Config, or update the sheet, and say which.

Related: [GDD](gdd.md) · [Prototype brief](specs/prototype.md) · [Decisions](decisions.md) · [Loop sketch](loop-sketch.md) · [Model](models/economy_model.py) · [Model output](models/economy_model_output.txt)
