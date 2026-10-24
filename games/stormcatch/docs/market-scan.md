# Stormcatch market scan: fishing, cozy collection and weather

Task T-0001, scout, 2026-10-24. Outcome served: **click**. The question is whether there is room for a cozy fishing game with a weather twist, and which players it would win.

## Data used

| Item | Value |
|---|---|
| Fresh snapshot, computer | `charts/data/snapshots/2026/10/24/20261024T192440Z-computer-all.json.gz`, taken **2026-10-24 19:24:40 UTC**: 26 sorts, 879 games, 23 requests |
| Fresh snapshot, phone (for the device read) | `charts/data/snapshots/2026/10/24/20261024T192617Z-high_end_phone-all.json.gz`, taken **2026-10-24 19:26:17 UTC**: 26 sorts, 907 games, 24 requests |
| Reports | `charts/data/reports/2026-10-24-computer-all.md`, `charts/data/reports/2026-10-24-high_end_phone-all.md` |
| Genres output | `charts/data/reports/2026-10-24-genres-computer-all.txt`, `charts/data/reports/2026-10-24-genres-high_end_phone-all.txt` |
| Evidence blocks | `charts/data/reports/2026-10-24-evidence-simulation-computer-all.md` (copy in the appendix), `charts/data/reports/2026-10-24-evidence-simulation-high_end_phone-all.md` |
| Valid for decisions until (PITCH-01, 7 days) | **2026-10-31 19:24 UTC** |
| Committed copy (added by the Director, because `charts/data/` is git-ignored) | `games/stormcatch/docs/evidence/charts-2026-10-24/`: both snapshots, both reports, both genres outputs and both evidence blocks |

`charts/data/` is git-ignored, so the appendix keeps a copy of the evidence block. Both snapshots are single readings taken on a Saturday evening (UTC) during Halloween events. The tool needs 36 hours of history before it reports risers, breakouts or genre phase; on this data it prints "unknown (needs 36h+ of data)". The trend phase below is my reading of the vault method plus third-party history, and it is labelled that way.

Unless a row says otherwise, numbers come from the computer snapshot at 2026-10-24 19:24:40 UTC. "Players" means concurrent players in the sort placement. "Like" is up / (up + down) votes. "Age" counts from the universe creation date, which can be earlier than the public launch. Titles are shortened: bracket tags and emoji are removed, and the universe id identifies each game.

## Headline findings

1. **Fishing is a two-leader genre.** Nine fishing games are on the charts, with 219.7K players between them (1.67% of the 13.2M players across charting games). Fisch (107.2K) and Fish It! (76.4K) hold 83.5% of that. The five fishing games created in 2026 have 26.2K players combined; the largest of them has 12.4K.
2. **Weather already changes play in both leaders.** In Fisch, rotating seasons, a day and night cycle, random weather and summonable totems change which fish spawn and how often, and some events open spots or add hazards. In Fish It!, weather comes at random, and players can also buy a server-wide weather with in-game coins that changes rod speed, luck, shiny odds, mutations and which fish spawn. Weather mutations or weather biomes also drive Grow a Garden, Sol's RNG and Ride A Pet. **Weather that changes spawn odds or adds mutations is now standard, so it cannot be the twist on its own.**
3. **Phase: genre (phase 5).** The fishing wave started in 2024. Fish It! peaked at about 1.4M on 2025-11-24 and now sits at 5% of that peak (RoWatcher, approximate). Fisch is stable. **We would be late for a fast follow.** Timing gives a genre entry no advantage, but it does not count against one either. We can win only by being both different and better.
4. **Audience: everyone, phone first.** Every fishing comparable carries the "minimal" maturity label with minimum age 0, so all three account tiers can play them. Fish It! and the smaller fishing games rank higher on phone sorts, while Fisch ranks higher on computer sorts. Device shares in absolute terms are unknown.
5. **IP risk is in names and hybrids.** The genre's titles converge on a few patterns ("Fish ___", "___ Fishing", a pun on the word). Some hybrids lean on anime or meme characters. Competitors' named weather tools and items are their own expression. Our working title needs a name check by the human.

## Comparables

### Main comparables (5 fishing, 3 with weather that changes play)

| # | Game (universe id) | Why it is here | Players | Visits | Like | Created (age) | Last update | Server size | Organic ranks, computer / phone |
|---|---|---|---|---|---|---|---|---|---|
| 1 | Fisch (5750914919) | Fishing leader; seasons, weather, totems | 107,205 | 5.06B | 91% | 2024-03-13 (955 d) | 2026-10-24 (0 d) | 20 | Playing now #14, earning #7, revisited #28, most popular #17, trending in Simulation #1 / playing now #14, earning #13, revisited #37, friends #87, most popular #53, trending in Simulation #17 |
| 2 | Fish It! (6701277882) | Second fishing leader; buyable server weather | 76,378 | 4.80B | 83% | 2024-10-21 (733 d) | 2026-10-24 (0 d) | 20 | Playing now #21, friends #37, earning #74 / playing now #21, friends #21, earning #32 |
| 3 | Deep Fishing (10526853622) | Third fishing game by players; young, distance-based loop | 12,352 | 20.1M | 97% | 2026-07-18 (97 d) | 2026-10-24 (0 d) | 12 | Trending #64, earning #80, trending in Simulation #31 / earning #79 |
| 4 | Heavyweight Fishing (8342498724) | Fishing game with return play | 9,889 | 68.4M | 96% | 2025-08-04 (446 d) | 2026-10-24 (0 d) | 10 | Revisited #32 / revisited #8 |
| 5 | Harpoon a Fish (10764240948) | Youngest fishing riser (under 60 days, 1K+ players) | 7,501 | 6.8M | 97% | 2026-08-28 (57 d) | 2026-10-24 (0 d) | 6 | Trending #92, trending in Simulation #51 / up-and-coming #88 |
| 6 | Grow a Garden (7436755782) | Cozy collection; weather mutations | 33,150 | 35.99B | 90% | 2025-03-25 (577 d) | 2026-10-24 (0 d) | 4 | Trending #24, playing now #58, most popular #51, trending in Simulation #10 / playing now #59, earning #36, most popular #67, trending in Simulation #21 |
| 7 | Sol's RNG (5361032378) | Weather biomes change luck and drops | 31,911 | 2.25B | 91% | 2023-12-03 (1,056 d) | 2026-10-22 (2 d) | 20 | Playing now #60, revisited #10, earning #28, trending in Simulation #22 / playing now #60, revisited #30, earning #56 |
| 8 | Ride A Pet (10035204815) | Ride and hatch; weather mutations since 2026-09-19 | 23,670 | 426M | 96% | 2026-04-14 (193 d) | 2026-10-24 (0 d) | 6 | Playing now #82, most popular #83, trending in Simulation #58 / playing now #83, earning #61, most popular #69, trending in Simulation #66 |

Lifetime average visits per day (visits divided by age; this is not current traffic, which needs two snapshots a day apart): Fisch about 5.3M, Fish It! about 6.5M, Deep Fishing about 207K, Heavyweight Fishing about 153K, Harpoon a Fish about 120K, Grow a Garden about 62.4M, Sol's RNG about 2.1M, Ride A Pet about 2.2M.

All eight carry the "minimal" maturity label and minimum age 0 (public games API, same snapshot).

### Other fishing games on the charts

| Game (universe id) | Players | Visits | Like | Created (age) | Last update | Organic ranks (computer) |
|---|---|---|---|---|---|---|
| Fish an Anime RNG (9582986239) | 3,526 | 19.2M | 95% | 2026-01-18 (279 d) | 2026-10-24 | Friends #80 |
| Roll a Fisherman (10636331438) | 2,762 | 15.3M | 98% | 2026-08-05 (80 d) | 2026-10-24 | Friends #86 |
| Cage Fishing (7629884826) | 105 | 90.7M | 98% | 2025-05-02 (540 d) | 2026-10-16 | Top rated #38 |
| Titan Fishing (9619492068) | 15 | 51.5M | 98% | 2026-01-25 (272 d) | 2026-10-08 | Top rated #60 |

Also seen, but not counted as fishing games: a card battler with a fishing update tag (9702081004, 1,043 players, phone snapshot only).

### Adjacent signals (water or weather themes, not fishing)

| Game (universe id) | Players | Like | Created (age) | Note |
|---|---|---|---|---|
| Crazy Diver (10767840473) | 21,018 | 57% | 2026-09-24 (30 d) | Young water-themed game; trending #91 on computer and #24 on phone. A 57% like ratio rarely sustains growth (vault, reading the charts) |
| What If Disasters (10769484703) | 16,538 | 90% | 2026-10-05 (19 d) | Survival, "mild"; up-and-coming #8 and trending #26. Disasters as a threat, the opposite of cozy. Theme read from the title only |
| Natural Disaster Survival (65241) | 9,824 | 91% | 2008-03-28 | Evergreen; weather as a hazard |

### Swing between snapshots

The vault's earlier snapshot (2026-10-24 17:04 UTC, `vault/21-hits-and-trends/chart-snapshot-2026-10.md`) recorded Fisch at about 157K and Fish It! at about 75K. Our snapshot 2 hours 20 minutes later shows 107.2K (-32%) and 76.4K. RoWatcher gives Fisch's 7-day average as 85K (accessed 2026-10-24), so 157K was most likely a short peak. That is an inference; the 17:04 snapshot file is not in this repository, so the number cannot be re-checked. Fisch's concurrency is spiky and Fish It!'s is steady. This matches the vault's earlier note that Fish It! stayed within about 3% of its weekly average in August 2026 (StudioKrew, via `vault/22-references/reference-games-by-genre.md`).

## Device read (relative ranks, computer vs phone)

Player counts are global, so the two snapshots show the same counts. Only ranks differ by device. The table below compares ranks; it does not give device shares.

| Game | Ranks higher on | Evidence (computer rank / phone rank) |
|---|---|---|
| Fish It! | Phone | Friends #37 / #21; earning #74 / #32 |
| Heavyweight Fishing | Phone | Revisited #32 / #8 |
| Crazy Diver | Phone | Trending #91 / #24; up-and-coming #66 / #16 |
| Ride a Dino (10758824872) | Phone (earning) | Earning #78 / #43 |
| Grow a Garden | Phone (earning) | Earning: not ranked / #36 |
| Fisch | Computer | Earning #7 / #13; trending in Simulation #1 / #17; most popular #17 / #53 |
| Sol's RNG | Computer | Revisited #10 / #30; earning #28 / #56 |

Reading: phone players earn and return more strongly in the steady, social fishing game. Fisch leans toward computer. The platform's sessions are mostly on phones (`vault/00-start-here/roblox-platform-2026.md`), so a phone-first fishing game is where the gap in device fit is. Absolute device mix: **unknown**.

## Does weather already change play in the top 3 fishing games?

Verification labels: **[2 sources]** means two or more public sources agree on the mechanic. **[1 source]** means one public source. **[unverified]** means search summaries only or conflicting sources. Nobody at the studio has played these games; everything here is read from public guides, never observed in play.

### 1. Fisch: yes, deeply

- **Seasons, global and on a timer** [2 sources]: four seasons, each lasting about 576 real minutes, the same on every server. Each fish prefers a season, and its spawn rate rises in that season. Sources disagree on the size of the bonus: about +25% in season (Gamezebo, 2024-11-20; Destructoid via search) against about -15% off season (search summary). A rod raises seasonal odds by about 20% (Pocket Tactics, updated 2026-03-24). Per the search summary, nothing in the game changes the season, so players wait for it [unverified].
- **Day and night** [1 source]: a full day lasts about 25 minutes. Some weather and events happen only by day or only by night (Pocket Tactics, 2026-03-24).
- **Random weather** [2 sources]: Pocket Tactics (2026-03-24) lists nine types. Windy (about 32.5%), Rain (about 28.4%) and Foggy (about 32.5%) are common. Starfall (about 0.6%, night only) drops collectibles. Blizzard (7.5%, 8 minutes) and "Absolute Darkness" (10%, which darkens a deep area and opens a pool for one rare creature) are among the others. Fish that prefer the current weather spawn more often: +35% per Gamezebo (2024-11-20, an old figure).
- **Players can change the weather** [2 sources]: totems bought in the game summon rain, wind, fog, aurora, blizzard or starfall, or advance the time of day (Gamezebo, 2024-11-20; Pocket Tactics, 2026-03-24).
- **Conditions unlock places and events** [1 source]: a rare event that appears only on clear winter nights opens a fishing spot. A migration event has a chance to start rain. A 5-minute storm event can eliminate players in one room at a 50% chance, so weather is sometimes a hazard (Pocket Tactics, 2026-03-24).
- **Weather mutations** [unverified]: search summaries say weather triggers mutations on catches, but I did not open a page that confirms it.

### 2. Fish It!: yes, as a shared, buyable buff

- **Random weather** [1 source]: "Most of the time, weather rolls on its own" (allthings.how, 2025-12-22).
- **A weather machine bought with in-game coins** [2 sources]: one player pays coins and the whole server fishes under that weather for about 10 to 15 minutes (Bloxodes, updated 2026-10-21; allthings.how, 2025-12-22). Up to three weathers can run at once (allthings.how only). The effects are faster rods (10,000 coins), more luck (20,000), speed and luck together (35,000), higher shiny odds (50,000), and a shark event that makes a rare shark catchable (300,000). A frozen mutation option at 15,000 appears in the December 2025 guide but not in the October 2026 list, so it may have been removed [unverified].
- **Weather changes which fish spawn** [1 source]: "some catches effectively need their weather active" (Bloxodes, 2026-10-21).
- **Social use** [1 source]: groups take turns paying for weather and everyone shares the buff (Bloxodes, 2026-10-21). This fits Fish It! being the only fishing game in the top 40 of Fun with Friends (#37 computer, #21 phone).
- Both sources quote the machine's prices in in-game coins. Whether Robux can buy weather directly: **unknown**.

### 3. Deep Fishing: none found

- The two public guides I read (allthings.how, 2026-09-19 and 2026-09-24) never mention weather, day and night, seasons or other world conditions. **[unverified absence]**: a guide that leaves something out is not proof the game lacks it.
- The loop the guides describe: hold and release to cast farther, steer the line through several fish on the way back, sell the haul, then buy rods, bait and stats that reach deeper water, where rarity rises with distance. Consecutive casts build a streak multiplier. There are 101 fish across three islands. Monetization is luck passes, a mutations pass, auto-sell and double coins (allthings.how, 2026-09-19).
- A young fishing game reached 12.4K players and a 97% like ratio with no weather in its public description. Its distinct verb (a distance cast that steers through several fish) did the differentiating instead.

### Weather beyond fishing (cozy collection and ride games)

- **Grow a Garden** [unverified numbers, mechanic confirmed by several guides]: rain and thunderstorms speed growth and add value mutations to crops. Lightning gives a rare high-multiplier mutation (search summaries of Pocket Tactics, Sportskeeda and Deltia's Gaming, accessed 2026-10-24). The vault's grow-and-farm playbook calls server-wide weather "a social purchase players love".
- **Sol's RNG** [unverified numbers]: weather "biomes" (windy, rainy, snowy) arrive at random, multiply luck and enable auras found only in that biome. Lanterns raise the chance of a biome (search summaries, rates conflict between sources).
- **Ride A Pet** [1 source, plus search summaries]: a weather-mutations update went live on 2026-09-19. Weather strikes give mounts random mutations; guides list five (vault `hits-2026.md` citing StudioKrew, September 2026; search summaries of the event page). It had about 208K players at the end of September (StudioKrew via the vault, approximate) and 23,670 in our snapshot (-89%). Public data does not show the cause.

### What weather does in these games, and what nobody seems to do yet

| Already standard (seen in 2 or more charting games) | Not found in the sources I read (designer to judge; unverified) |
|---|---|
| Weather changes spawn tables or luck (Fisch, Fish It!, Sol's RNG) | Weather that changes the physical act of fishing (how a cast flies, how a reel feels), beyond a speed stat |
| Weather adds mutations or variants (Grow a Garden, Ride A Pet, Fish It! shiny odds, Fisch reportedly) | A short forecast players can read and plan a session around. Fisch's seasons run on a fixed timer, and community wikis count them down |
| Players can summon or buy server weather (Fisch totems, Fish It! machine) | Players responding to weather together (shared shelter, co-op catches that need a storm) as the core social reason |
| Rare weather as a shared server moment (all five) | A cozy treatment of storms: calm and safe even in rough weather. Fisch uses some storms as hazards |

## Urgency read (PITCH-05)

| Measure | Value | Source and date |
|---|---|---|
| Fishing games on the charts | 9 (7 at 1K+ players) | Snapshot, computer, 2026-10-24 19:24 UTC |
| Fishing players on the charts | 219,733 (1.67% of 13,196,221 charting players) | Same |
| Share held by the two leaders | 83.5% | Same |
| Fishing games created in 2026 that chart | 5, with 26,156 players combined; largest 12,352 | Same |
| Charting games where weather changes play (checked) | 5 (Fisch, Fish It!, Grow a Garden, Sol's RNG, Ride A Pet) | Snapshot plus public guides above |
| Fish It! trajectory | Peak about 1.4M on 2025-11-24; now about 76K (5% of peak); 30-day change -27%, verdict "declining" | RoWatcher, accessed 2026-10-24, approximate |
| Fisch trajectory | 7-day average about 85K, 30-day average about 79K, 30-day change -2.5%, verdict "stable"; event peak about 510K on 2026-10-17 within RoWatcher's window | RoWatcher, accessed 2026-10-24, approximate |
| Simulation genre (context) | 4.9M players, 37.1% of charting players, 254 games | Snapshot, computer, 2026-10-24 19:24 UTC |
| Tool phase heuristic | Unknown (needs 36h+ of data) | `genres`, 2026-10-24 |

**Phase: genre (phase 5 of the vault's lifecycle).** The 2024 fishing wave has gone through its spark (Fisch), rise and saturation. Fish It! peaked in November 2025, and a shakeout has left the original and a few strong variants. The format survives across different games. Signs of that: Fisch is stable, Fish It! is steady week to week, Heavyweight Fishing is #8 in top revisited on phone, and several fishing games carry 96-98% like ratios. New fishing entrants in 2026 top out at about 12K. This is a judgment, not the tool's output; re-check it when 36 hours of snapshots exist.

**Early or late: late for a fast follow, on time for a genre entry.** A 6 to 10 week build ships between **2026-12-05 and 2027-01-02**, inside the winter school holidays. Traffic is higher then, and the leaders will also be running winter events. Being early buys no advantage. Discovery favors games people return to for weeks (vault, platform 2026). So we can win only by being **better and different**:
- a twist that changes how fishing plays, because weather as a luck or mutation modifier already exists in both leaders;
- a phone-first feel that matches the steadier, social, phone-leaning leader (Fish It!);
- a weekly update rhythm. Every main comparable except Sol's RNG shows an update date equal to the snapshot day (the API's updated date, which also moves on small publishes).

Risk if we go ahead unchanged: "a fishing game where weather changes which fish bite" describes what Fisch already does. By the vault's own rule of thumb, that is a skin, not a twist.

## Audience (input to PITCH-07)

- **Age tier:** all nine fishing comparables and the three weather comparables are labelled "minimal" with minimum age 0, so they are open to Roblox Kids (5-8), Select (9-15) and 16+ (public games API, snapshot 2026-10-24). How their players split by age: **unknown** (not public). The genre playbook describes the audience as "younger collectors and older players who enjoy chill progression" (vault).
- **Content rating expectation (draft only; the human answers the questionnaire):** a cozy fishing game with calm weather fits Minimal or Mild. Two things could push it up or add descriptors: storms used as hazards (Fisch's elimination storm is an example to avoid in a cozy game), and paid random items if bait, weather or luck is sold for Robux with random outcomes.
- **Launch reach:** a new public game is shown only to age-checked 16+ users until it passes the under-16 evaluation (250 unique plays from engaged age-checked users within 60 days, plus a safety review) (vault, `roblox-platform-2026.md`). Its first players will be older than the genre's core audience. That counts in favor of a twist with depth, not only cute visuals.
- **Devices:** see the device read above. Fish It! and the small fishing games lean toward phone; Fisch leans toward computer. Absolute mix: **unknown**.
- **Social shape:** the leaders use 20-player servers, and newer fishing games use 6-12. Fish It! is the only fishing game in the top 40 of Fun with Friends. Its shared weather purchase is the social hook named in public guides.

## IP risks seen in the space (input to PITCH-07)

1. **Title convergence.** Fishing titles cluster on "Fish ___", "___ Fishing", "Catch a ___" and a pun spelling of the word. Discovery demotes games whose metadata closely resembles others (`vault/15-market-research/trend-lifecycle.md`). Our title and thumbnail should not follow these patterns.
2. **Competitors' named systems.** The named totems, the weather machine, named rods and named events in Fisch and Fish It! are their own expression. Generic ideas (weather affects fishing, summoning weather) are free to use. Their names, item names, UI layout and art are not.
3. **Anime and meme hybrids.** One charting fishing game builds on an anime theme, and a card battler with a fishing update builds on meme characters. Franchise characters are licensed IP, and meme characters have unclear ownership. Avoid both.
4. **Real brands.** Real tackle, boat or outdoor brands on rods, lures or boats are trademarks. Use only original names.
5. **Working title.** One web search on 2026-10-24 found no Roblox game named "Stormcatch". "Storm Catcher" is an item name in a non-Roblox game, and storm-chasing games exist on Roblox. No trademark search was done; the name check is for the human.
6. **If the design uses real-world weather or player location:** data licensing and privacy questions. Draft them and escalate with `--kind policy`; do not decide them.
7. **Selling weather or luck for Robux:** Fish It!'s machine is sold for in-game coins. Paid random outcomes are a questionnaire item ("paid random items"), and the human decides it.

## Limits and unknowns

- One snapshot per device, taken on a Saturday evening in the Halloween season. Not enough for risers, breakouts or a measured genre phase. Take another snapshot at least 24 hours later (36 hours for phase) and before the pitch gate.
- No game was played. Every mechanic above is read from public guides, which conflict on numbers and can lag updates.
- Third-party figures (RoWatcher, StudioKrew via the vault, guide sites) are approximate.
- Age split, device shares in absolute terms, revenue and retention of any comparable: **unknown**.
- Whether Robux can buy weather in Fish It! or totems in Fisch: **unknown**.

## Sources

Studio data:
- Chart tracker snapshots `20261024T192440Z-computer-all` and `20261024T192617Z-high_end_phone-all` (Roblox discovery sorts and public games API; unofficial endpoints), taken 2026-10-24.
- Reports and evidence blocks listed under "Data used", generated 2026-10-24.
- Vault: `vault/21-hits-and-trends/chart-snapshot-2026-10.md` (2026-10-24 17:04 UTC), `vault/21-hits-and-trends/trend-waves.md`, `vault/21-hits-and-trends/hits-2026.md` (Ride A Pet, citing StudioKrew, September 2026), `vault/22-references/reference-games-by-genre.md` (Fish It! stability, citing StudioKrew, August 2026), `vault/14-genre-playbooks/fishing-and-collection.md`, `vault/14-genre-playbooks/grow-and-farm.md`, `vault/00-start-here/roblox-platform-2026.md`, `vault/17-policy-and-business/ip-and-licensing.md`, `vault/17-policy-and-business/age-ratings-and-audience.md`.

Third-party (read for analysis only; all accessed 2026-10-24):
- RoWatcher, "Is Fish It! dying?": https://rowatcher.com/games/6701277882/upd-fish-it/dying
- RoWatcher, "Is Fisch dying?": https://rowatcher.com/games/5750914919/fisch-save-nate/dying
- Pocket Tactics, "All Fisch seasons and weather events" (updated 2026-03-24): https://www.pockettactics.com/fisch-seasons
- Gamezebo, "Fisch Weather Guide" (2024-11-20): https://www.gamezebo.com/walkthroughs/fisch-weather-guide/
- Sportskeeda, "All Fisch Seasons guide" (search summary only): https://www.sportskeeda.com/roblox-news/all-fisch-seasons-guide-effects-timing
- Destructoid, "Complete Fisch seasons and weather guide" (search summary only): https://www.destructoid.com/complete-fisch-seasons-and-weather-guide/
- Bloxodes, "Fish It weather" (updated 2026-10-21): https://bloxodes.com/wiki/fish-it/weather
- allthings.how, "Fish It Weather Machine guide" (2025-12-22): https://allthings.how/roblox-fish-it-weather-machine-guide-for-faster-luckier-fishing/
- allthings.how, "Deep Fishing guide: best rods and upgrade order" (2026-09-19): https://allthings.how/roblox-deep-fishing-guide-best-rods-and-upgrade-order/
- allthings.how, "Deep Fishing: every fish by island" (2026-09-24): https://allthings.how/deep-fishing-every-fish-you-can-catch-by-island/
- Grow a Garden weather and mutation guides (search summaries only): https://www.pockettactics.com/grow-a-garden-mutations, https://www.sportskeeda.com/roblox-news/all-mutations-grow-garden
- Sol's RNG biome guides (search summaries only): https://www.gamezebo.com/walkthroughs/sols-rng-biomes/, https://bloxodes.com/wiki/sols-rng/biomes
- Ride A Pet weather mutation guides (search summaries only): https://bloxodes.com/articles/ride-a-pet-mutations-explained-effects-and-how-to-get-them

## Appendix: evidence block (chart tracker, computer, 2026-10-24 19:24:40 UTC)

Copied from `charts/data/reports/2026-10-24-evidence-simulation-computer-all.md` (emoji and empty brackets removed from titles). The tool's "Players (latest)" uses the games-API count fetched seconds after the sort pages, so some values differ from the tables above by under 2% (for example Deep Fishing 12.3K against 12,352).

```text
### Market evidence

- Data: 1 snapshots from 2026-10-24T19:24:40Z to 2026-10-24T19:24:40Z (device computer, country all).
- Newest snapshot is 0 hours old.
- Genre Simulation: 4.9M concurrent players across 254 charting games (37.1% of charting players); 162 games at 1K+ players; growth of daily peaks -; 0 games rising 30%+; phase (heuristic): unknown (needs 36h+ of data).

| Comparable | Genre | Players (latest) | 24h | Window peak growth | Visits/day | Like | Age (days) | Updated (days ago) | Ranks |
|---|---|---|---|---|---|---|---|---|---|
| Steal a Brainrot (7709344486) | Simulation | 1.2M (2026-10-24T19:24:40Z) | - | - | - | 85% | 526 | 0 | top-playing-now #2, top-earning #48 |
| Steal An Egg (10563114921) | Simulation | 1.1M (2026-10-24T19:24:40Z) | - | - | - | 92% | 91 | 0 | top-playing-now #3, top-earning #3, top-revisited #35 |
| +1 Speed Keyboard Escape / Candy & Chocolate (9584852943) | Simulation | 259.9K (2026-10-24T19:24:40Z) | - | - | - | 97% | 279 | 0 | top-playing-now #8, top-earning #57 |
| Fisch [HORSEMAN] (5750914919) | Simulation | 107.2K (2026-10-24T19:24:40Z) | - | - | - | 91% | 955 | 0 | top-playing-now #14, top-earning #7, top-revisited #28 |
| [PSX] Pet Simulator 99! (3317771874) | Simulation | 82.5K (2026-10-24T19:24:40Z) | - | - | - | 95% | 1722 | 0 | top-playing-now #19, top-earning #12 |
| [6 HRS] Fish It! (6701277882) | Simulation | 76.4K (2026-10-24T19:24:40Z) | - | - | - | 83% | 733 | 0 | top-playing-now #21, top-earning #74, fun-with-friends #37 |
| Anime Dice (10708913337) | Simulation | 75.8K (2026-10-24T19:24:40Z) | - | - | - | 99% | 70 | 0 | top-playing-now #22, top-earning #42 |
| [15MIN] Tap Simulator REBORN (10629695169) | Simulation | 67K (2026-10-24T19:24:40Z) | - | - | - | 95% | 81 | 0 | top-trending #25, up-and-coming #26, top-playing-now #28, top-earning #13, fun-with-friends #52 |
| Bike Universe (10768284407) | Simulation | 57.9K (2026-10-24T19:24:40Z) | - | - | - | 85% | 27 | 0 | top-trending #7, up-and-coming #4, top-playing-now #33 |
| Break and Steal an Egg (10765288803) | Simulation | 54.8K (2026-10-24T19:24:40Z) | - | - | - | 97% | 49 | 2 | top-playing-now #35, top-earning #50 |
| [x2] Deep Fishing (10526853622) | Simulation | 12.3K (2026-10-24T19:24:40Z) | - | - | - | 97% | 97 | 0 | top-trending #64, top-earning #80 |
| [UPD] Heavyweight Fishing (8342498724) | Simulation | 9.9K (2026-10-24T19:24:40Z) | - | - | - | 96% | 446 | 0 | top-revisited #32 |
| [UPD] Harpoon a Fish (10764240948) | Simulation | 7.4K (2026-10-24T19:24:40Z) | - | - | - | 97% | 57 | 0 | top-trending #92 |
| Crazy Diver (10767840473) | Simulation | 21K (2026-10-24T19:24:40Z) | - | - | - | 57% | 30 | 3 | top-trending #91, up-and-coming #66 |
| Grow a Garden (7436755782) | Simulation | 32.6K (2026-10-24T19:24:40Z) | - | - | - | 90% | 577 | 0 | top-trending #24, top-playing-now #58 |
| Sol's RNG [ Radiant Forest] (5361032378) | Simulation | 31.8K (2026-10-24T19:24:40Z) | - | - | - | 91% | 1056 | 2 | top-playing-now #60, top-earning #28, top-revisited #10 |
| Ride A Pet (10035204815) | Simulation | 23.5K (2026-10-24T19:24:40Z) | - | - | - | 96% | 193 | 0 | top-playing-now #82 |
| Ride a Dino (10758824872) | Simulation | 40.2K (2026-10-24T19:24:40Z) | - | - | - | 98% | 61 | 0 | top-trending #12, top-playing-now #44, top-earning #78 |

Source: Roblox discovery sorts (explore-api get-sorts) and the public games API. These endpoints are unofficial and may change. Player counts are concurrent players at snapshot time; sponsored placements are excluded from ranks. Trend phases are heuristics; check them against the vault's trend lifecycle note.
```
