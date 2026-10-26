---
title: "Product catalog: Reel the Storm (id stormcatch)"
date: 2026-10-25
version: 1
status: in review
author: monetization-designer (task T-0009)
---

# Reel the Storm: product catalog (draft)

Task T-0009 · Monetization Designer · 2026-10-25 · Stage: design · Outcome served: **spend**. Players who love the game find things worth buying, free players are never squeezed, and everything stays inside Roblox policy.

**Status of this draft.** The pitch was approved for a prototype only, and **the prototype sells nothing** (GDD §6, §13.1). This catalog is the plan for the build stage. Prices are **Robux drafts for the human's review**: the human creates every item and sets every price in Creator Hub. No product id was created, and the game's `Config/Products.luau` is unchanged. A ready-to-apply config proposal is in Appendix A.

**Binding inputs.**
- Human decisions D2 and D6: `games/stormcatch/docs/decisions.md`.
- GDD §4.10 (Sky Bell), §6 (monetization direction) and §12 (O-H1, O-H2): `games/stormcatch/docs/gdd.md` (T-0007; v2 sync T-0013 in progress, read 2026-10-25).
- Economy sheet §10 (luck rule), §11 (coin caps), §12.3 (Tide Pots) and §13 (Sky Bell bonus): `games/stormcatch/docs/economy-sheet.md` (T-0008, accepted).
- The Economist's requests in `games/stormcatch/handoffs/T-0008.md`, under "Next".
- Template: `project/src/shared/Config/Products.luau`, `src/server/Services/Policy.luau`, `src/server/Systems/Purchases.luau`, `src/shared/Util/Stats.luau` and `src/client/Controllers/Shop.luau`.

**Numbers.** Every computed number in this catalog comes from one script:

```text
python3 games/stormcatch/docs/models/catalog_numbers.py --out games/stormcatch/docs/models/catalog_numbers_output.txt
```

It needs the standard library only and is deterministic. Its inputs are copied from the economy sheet, with the section named on each one. Section letters such as [B] point into `models/catalog_numbers_output.txt`. Its section [A] reproduces the economist's Sky Bell figures exactly, as a cross-check.

## Where each requirement is answered

| Requirement (brief T-0009) | Where |
|---|---|
| DESIGN-07: every product has a motivation, a price tier and a passing fairness row | §2 catalog, §4 ladder, §5 fairness table (15 of 15 pass) |
| D6 weather summon inside the four D6 constraints | §3.1 |
| Auto Reel (weaker than active play), Pal Pouch, an extra Tide Pot slot (capacity), disclosed luck, coin packs, weather cosmetics | §3.2-§3.9 |
| D2: nests are paid random items; odds shown; `ArePaidRandomItemsRestricted` respected; what restricted players see | §6 |
| D6 disclosure question with options and a recommendation, escalated with `--kind policy` (O-H2 in the same escalation) | §7 |
| Nothing sells skipping an honest timer, changing the forecast for one player only, or moving the Great Storm | §1 rule 7, §5 column N, §3.10 |
| Offer briefs, creation list, compliance notes, config | §8, §9, §10, Appendix A |

---

## 1. Rules this catalog keeps

1. **Coins are the only currency** (GDD §5). There are no Gems; template products that grant gems are re-expressed in coins or dropped.
2. **Nothing is shown before onboarding step 12.** Step 12 ("Played 10 Minutes") always comes after step 11, the bridge to Lantern Reef (GDD §3.3). So no product is listed in the shop until the player has fixed the first bridge and played 10 minutes. Contextual cards start only in the player's second session (§8).
3. **No 2x Coins before the first bridge** (Economist, T-0008 handoff). The 2x Coins pass works only from the first bridge onward, even when it is bought outside the game.
4. **All paid luck shares one +25% cap** (economy sheet §10). That covers the Sky Bell's shared bonus and the Lucky Bobber. Paid luck never applies to nests or to Stormborn. The template's Lucky (+50%), Luck Potion (x2) and Server Luck (x2) are therefore dropped (§3.10).
5. **Prices are read at runtime** with `MarketplaceService:GetProductInfoAsync` on the client, so regional prices and Roblox Plus discounts show correctly. No price appears in config, copy or icons.
6. **No contextual offer for a probability modifier or a coin pack.** Luck and coins are sold only where the player goes on purpose: the Store tab, and the expanded Sky Dial for the Sky Bell.
7. **Never sold** (GDD §6, D6, brief requirement 5):
   - skipping or shortening an honest timer (Tide Pot fill, storm countdown, front arrival, Almanac day, calendar, playtime gifts);
   - restoring a streak;
   - calling, moving, delaying or shortening the Great Storm;
   - changing the forecast for one player;
   - Stormborn outside the storm;
   - extra equip slots, VIP multipliers or faster hatching (§3.10);
   - anything a free player cannot reach by playing. Cosmetics are style only.

---

## 2. The catalog at a glance

Motivations use the vault's list (`vault/09-monetization/monetization-strategy.md`): progress faster (speed), show off, collect, get lucky (luck), be stronger (power), play with friends (social), support the game. Tiers use `vault/09-monetization/pricing-and-price-ladders.md`: Impulse 15-99, Core 100-499, Premium 500-1,499, High-end 1,500+. "PM" means probability modifier, and "FR" means funds random items (§6.1).

| # | Item (config key) | Type | Motivation | Tier | Draft price (Robux) | What the player gets | PM | FR |
|---|---|---|---|---|---|---|---|---|
| 1 | Sky Bell: Showers (`skyCallShowers`) | Developer product, repeatable | Social, luck | Impulse | 49 | A Showers front over the harbour for 3 minutes, shared by everyone in the server, with +25% luck on Rare and rarer fish | yes | no |
| 2 | Sky Bell: Sea Fog (`skyCallSeaFog`) | Developer product, repeatable | Social, collect | Impulse | 49 | The same with Sea Fog. Fog already doubles luck, so the bell adds no extra luck | yes | no |
| 3 | Sky Bell: Gusts (`skyCallGusts`) | Developer product, repeatable | Social, luck | Impulse | 49 | The same with Gusts: swaying ring, bigger fish, +25% luck | yes | no |
| 4 | Coin Pouch (`coinPouch`) | Developer product, repeatable | Speed | Impulse | 49 | About 15 minutes of coins at the player's current rate | no | yes |
| 5 | Starter Pack (`starterPack`) | Developer product, once per player | Speed, show off | Impulse | 75 | About 30 minutes of coins, a 15-minute 2x Coins boost and a raincoat colour found only here | no | yes |
| 6 | Bobber Box (`bobberBox`) | Pass | Show off | Impulse | 75 | 6 bobber designs everyone nearby sees | no | no |
| 7 | Big Pal Pouch (`palPouchPlus`) | Pass | Collect | Impulse | 99 | +50 companion space, on top of the Pal Pouch upgrade line | no | no |
| 8 | Rain Gear (`rainGear`) | Pass | Show off | Impulse | 99 | 4 raincoat-and-hat colours and 2 umbrellas that open when it rains | no | no |
| 9 | Auto Reel (`autoReel`) | Pass | Speed (convenience) | Core | 149 | Reels for you in Clear water after you cast, at about two-thirds of your own catch rate | no | no |
| 10 | Lucky Bobber (`luckyBobber`) | Pass | Luck | Core | 149 | +25% luck on Rare and rarer fish, with odds that update, inside the +25% paid cap, plus a clover bobber look | yes | no |
| 11 | Third Tide Pot (`tidePot3`) | Pass | Collect, return | Core | 149 | A third pot slot that fills at the same speed (8 h): 4 more minutes of income and 8 more fish per full pot | no | no |
| 12 | Coin Crate (`coinCrate`) | Developer product, repeatable | Speed | Core | 149 | About 60 minutes of coins | no | yes |
| 13 | 2x Coins (`x2Coins`) | Pass | Speed | Core | 249 | Double coins from every catch, from the first bridge on; adds to timed boosts, x3 at most | no | no |
| 14 | Coin Chest (`coinChest`) | Developer product, repeatable | Speed | Core | 399 | About 3 hours of coins | no | yes |
| 15 | Lantern Keeper Set (`lanternKeeper`) | Pass | Show off | Premium | 699 | A lantern coat and hat that glow softly in Sea Fog, a lantern bobber and a lantern umbrella | no | no |

15 items: 7 developer products and 8 passes. Every gameplay pass together costs 795 Robux, and every pass together costs 1,668 Robux [F]. All passes are priced 75-699, inside the 50-800 band that Roblox promotes on the Buy Robux page (`vault/99-reference/key-numbers.md`).

---

## 3. Products in detail

### 3.1 Sky Bell: three products, one per weather (D6)

The rules come from GDD §4.10 and are not changed here. This section adds the price, the copy and the disclosure.

**How the catalog keeps the four D6 constraints.**

| D6 constraint | How the catalog keeps it |
|---|---|
| (1) A summoned front appears on the Sky Dial for everyone in the server | The product is a **saved credit** that places the call in the next free slot. The call goes on every player's dial at least 60 s ahead, with a bell icon, "Called by <display name>" (or "Someone", see §8) and "this server". The pre-purchase panel shows the exact arrival time the purchase would get. Once on the dial, the call always happens |
| (2) Its benefit is shared with every player there, never only the buyer | The catalog sells the buyer **nothing extra**: the same weather and the same +25% as everyone fishing under it, no personal bonus and no exclusive spot. The copy says so: "Everyone in this server shares it. You get the same as everyone else" |
| (3) It never moves or replaces the Great Storm schedule | The products only add a call, inside GDD §4.10's slot rules. No call runs from 60 s before a storm until 30 s after it, no natural front or Rainbow is replaced, and calls stay at the harbour. When no slot is free, the bell is not sold, and the panel says when the sky is free: a real reason, not a countdown |
| (4) Duration, price and effects are designed, and granted only in `ProcessReceipt` | Duration: 180 s (GDD). Effect: +25% Sky luck (economy sheet §13). Price: 49 Robux, reasoned below. Grant: `ProcessReceipt` adds one Sky Call credit, saved with the receipt id, through the template's idempotent pattern. One product per weather, so the server never trusts a client "weather" argument |

**What a call is worth** (economy sheet §13, recomputed in [A]):

| Called weather | Luck for a new player | Rare-or-better per catch | Coins per catch | Way of fishing |
|---|---|---|---|---|
| Showers | x1.00 → x1.25 | 14.98% → 18.05% | +6.0% | Quick fishing |
| Sea Fog | x2.00 → x2.00 (Sky cap) | 29.91% → 29.91% | 0 | Fishing by feel |
| Gusts | x1.00 → x1.25 | 23.73% → 28.00% | +8.8% | Swaying ring, sizes x1.25 |

A call gives each player at the harbour up to about 3.1 extra minutes of harbour income, against fishing in Clear water (sheet §13). For anyone past Lantern Reef, it is a collection and social moment rather than income, because the harbour pays Pebble Cove values.

**Price: 49 Robux for each of the three, the same price** [E].
- **Price parity with the cheapest personal product.** The GDD's success target is a median of 3 or more players besides the buyer fishing under each call. Four players × 3.1 minutes is about 12.4 player-minutes of harbour income per call, or 0.25 minutes per Robux. The 49-Robux Coin Pouch gives one player 15 minutes, or 0.31 minutes per Robux. A bell costs the buyer what a pouch costs, and gives roughly the same value to the server instead of to themselves.
- **Why not cheaper (25).** At 25 Robux a call would give the server 1.6x the Pouch's value per Robux. Ringing would become the cheapest way to buy income, even for oneself. The supply of 2 calls per 15-minute cycle per server would fill, so the sky would be "busy" more often and natural weather at the harbour would be crowded out. A 25-Robux reflex purchase also sits badly with a 7-13 audience.
- **Why not dearer (99 or more).** The buyer's own share is 3.1 minutes, or 0.06 minutes per Robux. Even at 49 it is a gift, not a deal. At 99 or more it would be the worst personal value in the catalog, and a server-wide treat should be an easy gift.
- **Why one price for three weathers.** The weather is a preference, not a power tier. Showers pays the most coins, Sea Fog gives the most rares through fog's own luck (and the bell adds none there), and Gusts gives bigger fish. One price is also easier for a 9-year-old to understand.
- **Spend ceiling.** With the per-buyer limit asked of the Designer (one call per buyer per storm cycle, §11), one player can spend at most 4 × 49 = 196 Robux an hour on calls. Without it, the GDD's queue allows 8 calls an hour per server.

**Pre-purchase panel copy** (expanded Sky Dial → "Ring the Sky Bell", or a tap on the bell on the quay). Draft wording; the Interface Designer lays it out.

```text
Ring the Sky Bell
Call a front over the harbour for everyone in this server.

[ Showers: quick fishing ]  [ Sea Fog: fishing by feel ]  [ Gusts: riding the wind ]

Arrives 12:41 (in 1:05) · Lasts 3:00 · Open Pier and Cove Shallows
Everyone in this server shares it. You get the same as everyone else.
+25% luck on Rare and rarer fish for everyone fishing under it.
   (Sea Fog: "Sea Fog already doubles luck, so the bell adds no extra luck.")
All paid luck together is capped at +25%. Players with a Lucky Bobber get the weather, not more luck.
[ Odds ]   Show my name on the banner [on]
[ <price from MarketplaceService> Ring ]          [ Not now ]
```

- **When no slot is free:** "The sky is busy until 12:52. You can ring the bell after that." No buy button is shown.
- **When the player has a saved credit:** "Your Sky Bell call is saved. Ring it when the sky is free." There is no extra cost, and the credit never expires.
- **The "Odds" button** lists every species at the harbour under that weather with its percentage, now and with the bell, summing to 100% (§6.2).

### 3.2 2x Coins (pass, 249)

- **Gets:** coins from every catch doubled, from the moment the bridge to Lantern Reef is fixed. It adds to the timed coins2x boost, capped at x3 (economy sheet §11).
- **Fair because:**
  - It is speed only. The Economist's paying model, which owned 2x Coins from second 0 (the worst case), was 2.6-3.7x faster than the casual free player on goals 2, 3 and 5. That is inside the vault's 2-4x band.
  - Gating it to the first bridge removes the 3.7x first-bridge edge case. A payer reaches Lantern Reef at a free player's pace.
- **Bought outside the game:** the effect still waits for the first bridge, and the description says so.

### 3.3 Auto Reel (pass, 149)

- **Gets:** after the player taps Cast, Auto Reel plays the reel ring for them. It works only in **Clear-ring water**: Clear, under a Rainbow, and Aurora Night.
- **Weaker than active play, by construction** [C]:
  - It lands 70% of bites, a fixed rate that no perk or upgrade raises.
  - Each reel takes twice as long as the weather's ring.
  - That is 4.75 catches a minute in Clear: **69%** of a casual player's active rate (6.87) and **64%** of a typical player's (7.40).
  - It is only **42-44%** of what the same player lands by walking into a Showers front.
  - It never makes a Charged catch.
- **Never plays the weather for you** (GDD §6). It pauses under Showers, Sea Fog and Gusts, and during the whole Great Storm. It never taps the fog hook or Pull!.
  - This protects the twist: what the player's hands do still changes with the weather (pillar 1).
  - It pushes the chase: a front pays more than twice what Auto Reel earns in Clear (twist test B).
  - It pushes the social core: Auto Reel stops while the storm is on, so the pier is where things happen.
- **Not AFK:** the player still taps Cast for every fish. The toggle is off by default and appears after step 12, so a copy bought outside the game changes nothing in onboarding. Catches are tagged `auto = true` in analytics, so twist and economy reports can separate them.
- **Accessibility:** Auto Reel must never be the only help for players who find the ring hard. The Designer is asked to keep a free ring assist in Settings (§11).

### 3.4 Lucky Bobber (pass, 149): the disclosed luck item

- **Gets:** +25% paid Sky luck on Rare-and-up fish wherever the player fishes, plus a clover bobber look that others see. It replaces the template's Lucky (+50%) and Luck Potion (x2), which break the +25% paid cap.
- **Disclosed numerically before purchase**, at the player's current spot. A new player at the harbour in Clear water sees, from [B]:

| Tier | Now | With Lucky Bobber |
|---|---|---|
| Common | 65.67% | 64.00% |
| Uncommon | 23.88% | 23.27% |
| Rare | 8.46% | 10.30% |
| Epic | 1.99% | 2.42% |

- **Stated limits** (economy sheet §10; checked in [B]):
  - Paid luck from all sources is capped at +25% together. Under a Sky Bell call, an owner gets the weather but no extra luck: x1.25 with the bobber, the bell, or both.
  - In Sea Fog, luck is already at its weather cap, so the bobber adds nothing there.
  - It never applies to nests or to Stormborn.
  - The total luck cap is x6.
- **Why a pass, not a timed potion:** a timed potion would lose minutes whenever a Sky Bell call overlapped it, because paid luck does not stack. That is a quiet loss, and a pass has none. The repeatable luck purchase is the Sky Bell, which is shared.
- **Fair because:** +25% is below Lure level 7 (+28%), which a casual free player reaches at minute 23.9. It is a quarter of the Gear cap. A maxed free player in Clear has x4.50 luck, and a maxed payer x5.62 [B].

### 3.5 Big Pal Pouch (pass, 99)

- **Gets:** +50 companion space on top of the base 60 and the Pal Pouch coin line (+10 a level, up to +100; economy sheet §4).
- **Fair because:** it is capacity only, with no income, luck or equip effect.
- **Free paths stay visible at the moment of need:** releasing a companion, and the Pal Pouch upgrade.
- **Why not equip slots:** extra equip slots were considered and are not sold (§3.10).

### 3.6 Third Tide Pot (pass, 149)

- **Gets:** a third pot slot, usable once the free second slot exists (on reaching Lantern Reef).
- **Capacity, never a skip:** the pot fills at the same 0.5 minute of income per pot-hour, with the same 8-hour cap and 1 fish per hour (economy sheet §12.3). A full pot adds 4 minutes of income and 8 fish carrying the marks of the natural weather that passed [D].
- **Nothing is sold that fills, speeds up or tops up a pot.** Day-7 bait stays a free calendar reward.

### 3.7 Starter Pack (developer product, once per player, 75)

- **Gets:**
  - about 30 minutes of coins, which at 0.40 minutes per Robux is 31% more than the Pouch [D];
  - a 15-minute coins2x boost;
  - a raincoat colour found only in the pack. The look is the Artist's, and the colour is not yellow (art direction §8, the horror look-alike note).
- **One per player,** enforced on the server through the template's `oncePerPlayer` and `oneTimeProducts`.
- **When:** listed from step 12. At the start of session 2 the Shop button gets a "New" badge, shown once (§8). This follows the vault rule: offer it after the player has had fun, never on spawn.
- **No value claims:** no "x% off" and no "was" price, because the boost and the colour are not sold separately. The panel lists the contents.

### 3.8 Coin packs: Pouch 49, Crate 149, Chest 399 (developer products, repeatable)

- **Sized in minutes of income,** as the Economist asked: 15, 60 and 180 minutes. They stay meaningful on every island, despite the x19 income steps.
- **Coin amount:**
  - It is the player's Clear catch rate at their best island × `assumedCatchesPerMinute` (5) × minutes.
  - It counts permanent multipliers (Rod, companions, bonus, 2x Coins pass, New Tide) and **not timed boosts**, so the amount never depends on when a player buys.
  - The panel shows "about N coins (about M minutes of your fishing)" before purchase.
- **Value steps:** 0.31, 0.40 and 0.45 minutes per Robux [D].
  - Any "more per Robux" label is computed at runtime from the prices this player sees, or not shown. Regional pricing and price tests can change the ratios.
  - Nothing is ever labelled "sale", and there is no "was" price.
- **New Tide note:** when the player's coins already cover the next New Tide, the pack panel adds "New Tide resets coins". Nobody should buy coins that a reset will remove without knowing it.
- **Why packs exist:** they are the main repeatable for engaged players (vault build order, step 6). Under D2 they make nests paid random items; §6 handles that.
- **Why no contextual coin offer:** being short of a bridge price is exactly the moment the vault warns about. The bridge sign shows "about N minutes of fishing to go" instead.

### 3.9 Weather cosmetics: Rain Gear 99, Bobber Box 75, Lantern Keeper Set 699 (passes)

- **Style only:** no effect on coins, luck, odds, capacity or time. They are worn in this game and are not Roblox avatar items; the descriptions say so.
- **Visible passes advertise themselves.** Umbrellas open when it rains at the player's spot or in the storm, bobbers float where everyone fishing nearby sees them, and the lantern coat glows softly in Sea Fog.
- **Free cosmetics exist and are shown as "Earned" in the same Style tab:**
  - the raincoat colour on calendar day 3;
  - the referral raincoat colour;
  - journal set titles.
- **No paid cosmetic is limited-time, and none claims scarcity.**
- **The Lantern Keeper Set is the premium anchor.** It is the only item above 499, and it is cosmetic only, so the deepest spending in the game buys style, never power.
- **No high-end tier (1,500+) at launch, on purpose.** The core audience is 7-13 (GDD §1). Event cosmetic sets can be added after launch if data shows payers want more depth.

### 3.10 Template products dropped, and items considered and not sold

| Item | Decision | Reason |
|---|---|---|
| Server Luck (`serverLuck`, x2 for 10 min) | Dropped | Replaced by the Sky Bell. GDD §6: one server-wide paid effect only. x2 also breaks the +25% paid cap |
| Lucky (`lucky`, +50%) | Replaced by Lucky Bobber (+25%) | Paid cap (economy sheet §10) |
| Luck Potion (`luckPotion`, x2 for 15 min) | Dropped | Breaks the cap. A +25% potion would lose time under Sky Bell calls, because paid luck does not stack (§3.4) |
| +3 Pet Slots (`petSlots`) | Not sold | Companions carry coin and luck perks (economy sheet §6), so extra equip slots are power and an indirect probability modifier. The Economist's paying model assumed them, so this catalog is weaker than modelled. Capacity is sold instead (§3.5) |
| VIP (`vip`, tag and +10% coins) | Dropped | An unmodelled multiplier in the capped bonus category. Status is served by cosmetics |
| Triple Hatch (`tripleHatch`) | Not sold | It speeds the use of a paid random item for a young audience. Nests are a sink, not a slot machine |
| Auto Hit (`autoHit`) | Replaced by Auto Reel | Fishing replaces nodes |
| Gem packs, gems in bundles | Dropped | Coins only (GDD §5) |
| Timer skips (Tide Pots, storm, fronts, Almanac, calendar, gifts), streak restore | Never sold | GDD §1 "honest time" and §4.8; `monetization-compliance.md` §3 |
| Calling or moving the Great Storm, Stormborn outside the storm, a one-player forecast | Never sold | GDD §6, D6 constraint 3 |
| Nests or nest keys for Robux | Not sold | Nests cost coins only. Coins are the one Robux-to-random path, and §6 covers it |
| Bundles with a "was" price | Not sold | No fake discounts. The Starter Pack lists its contents with no comparison |
| Subscriptions | Not at launch | Candidate later only with distinct benefits honoured for the full term (`product-catalog.md`). Needs the human |
| Season pass | Not at launch | Later candidate: an "Almanac pass" tied to Saturday fronts, with a meaningful free track |
| Private servers | The human's decision | Recommended free or low priced, because the storm needs 4-8 players and friends can bring them. Changing the price later cancels every private-server subscription, so the human sets it once |
| Rewarded video | Later | Needs 2,000 unique monthly visitors. The reward must be a non-random developer product, such as a 10-minute coins2x, once a day, after step 12 |

---

## 4. Price ladder

| Tier | Items (draft Robux) | Role |
|---|---|---|
| Impulse (15-99) | Sky Bell ×3 (49), Coin Pouch (49), Starter Pack (75), Bobber Box (75), Big Pal Pouch (99), Rain Gear (99) | First purchases. The Sky Bell and Starter Pack are the natural first buys: one social, one great value |
| Core (100-499) | Auto Reel (149), Lucky Bobber (149), Third Tide Pot (149), Coin Crate (149), 2x Coins (249), Coin Chest (399) | The main passes and the larger packs |
| Premium (500-1,499) | Lantern Keeper Set (699) | Cosmetic anchor |
| High-end (1,500+) | none at launch | Argued in §3.9 |

- **Cheap first purchase:** 49 Robux (Sky Bell, Coin Pouch).
- **Repeatables:** Sky Bell calls and coin packs.
- **Clear steps between prices:** 49, 75, 99, 149, 249, 399, 699 [F].
- **Rough player cost:** about 1 US cent per Robux (`key-numbers.md`). Every gameplay pass together is about 8 dollars.

**Effect on the paying player.** Against the Economist's paying model, this catalog:
- delays 2x Coins to the first bridge;
- removes the equip slots;
- keeps paid luck at +25%;
- adds coin packs, the Starter Pack and a third pot.

The Economist is asked to re-run the paying model with exactly this catalog and to confirm the 2-4x band (§11).

---

## 5. Fairness table (DESIGN-07)

Columns U1-U7 are the "Unfair (avoid)" column of the vault's fairness table (`vault/09-monetization/monetization-strategy.md`). Column N is the GDD §6 and brief "never sold" list. A cell says why the product passes.

- **U1** sells an escape from a frustration built in on purpose
- **U2** a paywall in the first session
- **U3** hidden odds or a misleading boost
- **U4** power free players can never get
- **U5** a timer made painful so players pay to skip it, or any honest timer skipped
- **U6** a fake discount, fake scarcity or a resetting countdown
- **U7** pressure language aimed at children
- **N** moves or calls the Great Storm, changes the forecast for one player, or sells Stormborn outside the storm

| Product | Fair column (vault) | U1 | U2 | U3 | U4 | U5 | U6 | U7 | N | Result |
|---|---|---|---|---|---|---|---|---|---|---|
| Sky Bell: Showers | Luck boost with honest odds; social | Natural Showers is free and frequent at the harbour | Step 12+, only in the expanded Sky Dial, never a popup | Odds now and with the bell before purchase; +25% and the cap stated; odds update live (§6.2) | The buyer gets nothing extra; everyone present shares it | No countdown changes; natural weather keeps priority | The arrival time is the real slot; "busy" is a real reason | "Ring the Sky Bell", "Not now" | Storm guard; on everyone's dial; harbour only | **Pass** (watch W1, W2) |
| Sky Bell: Sea Fog | Same | Same | Same | Same, plus "the bell adds no extra luck in fog" | Same | Same | Same | Same | Same | **Pass** (W1) |
| Sky Bell: Gusts | Same | Same | Same | Same | Same | Same | Same | Same | Same | **Pass** (W1, W2) |
| 2x Coins | Speed | Coins come from every catch anyway | Hidden until step 12; works only from the first bridge | Additive, x3 cap stated | Speed only; payers 2-4x faster (sheet §1) | None | No sale labels | Neutral | n/a | **Pass** |
| Auto Reel | Convenience | The ring is the fun, not a chore; Auto is weaker | Step 12; toggle off by default | "About two-thirds" stated ([C]: 64-69%) | Earns less than active play | None | None | Neutral | Never plays fog hook, storm or Pull! | **Pass** |
| Lucky Bobber | Luck boost with honest odds | Luck is not a built-in frustration | Step 12 | Odds now and with the bobber; cap and exclusions stated (§3.4) | +25% is below Lure 7 (+28%, free at minute 23.9); capped | None | None | Neutral | No luck on Stormborn or nests | **Pass** |
| Big Pal Pouch | Convenience (storage) | Free space 60, the Pal Pouch line to 160, free release | Step 12 | "+50 space", exact | Capacity only | None | None | Neutral | n/a | **Pass** |
| Third Tide Pot | Extra content (slots) | Two free pots; pots are a bonus | Step 12 | Same 8 h fill stated | +4 min of income and 8 fish a day | Fill time unchanged: capacity, not a skip | None | Neutral | Pots ignore calls and never yield Stormborn | **Pass** |
| Starter Pack | Speed, cosmetic (cheap first purchase) | n/a | Step 12; badge in session 2 | Contents listed; no "% off" | One-time; coins in minutes of income | Boost timer is real | Genuinely once per player; no countdown | Neutral | n/a | **Pass** |
| Coin Pouch | Speed | No contextual offer when short of a price | Step 12 | "About N coins (M minutes)" before purchase | Buys only what play buys; nest odds unchanged | None | No permanent "sale" | Neutral | n/a | **Pass** |
| Coin Crate | Speed | Same | Same | Same; "more per Robux" only if computed at runtime | Same | None | Same | Neutral | n/a | **Pass** |
| Coin Chest | Speed | Same | Same | Same, plus the New Tide reset note | Same | None | Same | Neutral | n/a | **Pass** |
| Rain Gear | Cosmetics | n/a | Step 12 | "Style only" | No effect | None | Not limited | Neutral | n/a | **Pass** |
| Bobber Box | Cosmetics | n/a | Step 12 | "Style only" | No effect | None | Not limited | Neutral | n/a | **Pass** |
| Lantern Keeper Set | Cosmetics | n/a | Step 12 | "Style only" | No effect | None | Not limited | Neutral | n/a | **Pass** |

**Result: 15 of 15 products pass.**

**Watch items** found while checking the Sky Bell. Neither fails a vault row, because the Sky Bell grants no power and everyone in the server shares every call. Both touch the GDD's stricter rule "nothing a free player cannot reach by playing", so they go to the Designer (§11):
- **W1, call-only collectibles.** At launch, the only natural fronts over Pebble Cove are Showers (world plan §7: "Pebble Cove's two front spots get Showers"). So Pebble Cove's 8 species with the Misty or Breezy mark, 16 "marks seen" journal entries, can appear only under a called Sea Fog or Gusts front. No set requires them; the 3 weather sets use the weather-only species, which bite naturally elsewhere.
- **W2, call-only records.** The Gusts size boost (x1.25) never happens naturally on Pebble Cove. Pebble Cove's daily record on the harbour record board can therefore be beaten only under a called Gusts front.

---

## 6. Paid random items and PolicyService (D2)

### 6.1 Classification

D2 (the human, 2026-10-24): nests count as paid random items when coins can be bought with Robux. This catalog sells coins (§3.7, §3.8), so **nests are paid random items**. Two other items are paid **probability modifiers** on fishing.

| Item | Random outcome | Robux path | Classification | Flag in config |
|---|---|---|---|---|
| Driftwood, Reef, Bluff and Thunder Nests | Which companion hatches | Coin Pouch, Crate, Chest and Starter Pack sell coins, and nests cost coins | **Paid random item** (D2) | Products that sell coins: `fundsRandomItems = true` |
| Nest hard pity (Legendary by hatch 80) | Changes nest odds | Same | **Probability modifier on a paid random item** (`rng-systems-and-pity.md`): explained before hatching | n/a (a rule, not a product) |
| Lucky Bobber | Changes fish odds | Sold for Robux | **Paid probability modifier** | `probabilityModifier = true` |
| Sky Bell ×3 | Changes fish odds and table at the harbour for everyone | Sold for Robux | **Paid probability modifier**, server-wide (§7) | `probabilityModifier = true` |
| 2x Coins, Auto Reel | None directly | They raise coins earned **by play**; Robux never buys coins with them | **Catalog's reading: not funding random items.** No Robux-to-coin exchange happens. The human confirms this with the questionnaire question (§7) | `fundsRandomItems = false` |
| Big Pal Pouch, Third Tide Pot, cosmetics | None | n/a | Not random | none |
| Fishing itself, Tide Pot catches, the Great Storm and Stormborn | Which fish bites | Free play | Free randomness. Shown anyway, and Stormborn and nests take no luck | n/a |

### 6.2 Odds disclosure surfaces

| Where | What the player sees | When |
|---|---|---|
| Nest panel | An "Odds" list, always visible before every hatch, from the same table the server rolls: each companion and its percentage, 75% / 22% / 3% per nest, summing to 100% (template `Hatch` odds panel). A pity line: "A Legendary is guaranteed by hatch 80. Hatches since your last Legendary: N". On the pity hatch the list reads "Legendary 100%" | Always, before purchase (the hatch) |
| Spot "Odds" button (descriptive label, never a lone (i) icon) | Every species at that spot in the current weather and its percentage for this player, summing to 100% (rounding note if needed), and the luck breakdown: Lure, companions, friends, Sky (weather, paid, free timed), the cap that binds, and the total | Any time; it updates live while any modifier is active |
| Lucky Bobber purchase panel | The tier table at the player's current spot, now and with the bobber, plus the limits in §3.4 | Before purchase |
| Sky Bell purchase panel | The harbour species table for the chosen weather, now and with the bell, plus the §3.1 copy | Before purchase |
| During a Sky Bell call | Depends on the human's answer to the D6 question (§7). Under the recommended option A: bell icons on the Sky Dial and the called spots, the banner, and a "Sky Bell +25%" line in every affected player's luck breakdown | While the call is active |

### 6.3 What changes for players whose `ArePaidRandomItemsRestricted` is true

The template already does most of this. `Policy.load` treats a failed lookup as restricted, `Purchases.allowedFor` refuses flagged products, `Shop.luau` hides them, and `Stats.derive` ignores paid luck.

| Area | For restricted players |
|---|---|
| Shop | **Hidden:** Coin Pouch, Coin Crate, Coin Chest and Starter Pack (FR), and Lucky Bobber and the three Sky Bells (PM). The shop simply does not list them; no gap or message is shown. **Still sold:** 2x Coins, Auto Reel, Big Pal Pouch, Third Tide Pot and every cosmetic (subject to the §7 confirmation for 2x Coins and Auto Reel) |
| Nests | **Still available,** because their coins can only come from play: no Robux path to a random outcome remains. Odds and pity stay shown, as good practice |
| Paid luck | Ignored, even if a Lucky Bobber was obtained elsewhere (the bobber look stays). The luck breakdown shows no paid line |
| The expanded Sky Dial | No "Ring the Sky Bell" button. Calls placed by others still show on their dial, because the forecast stays true for everyone (D6 constraint 1) |
| Fishing under a call someone else bought | **The human decides (O-H2, §7.3).** The +25% bonus is already withheld from them by the luck rule (economy sheet §10); the open question is the called weather's fish table and marks |
| Receipts | A flagged product reaching a restricted player from another surface is held (`NotProcessedYet`) with a neutral toast (template). The creation list keeps these items unlisted outside the game where Creator Hub allows (§9) |
| Trading | None at launch (GDD §4.9), so `IsPaidItemTradingAllowed` has nothing to gate. If trading is added, companions from nests are paid random items and must respect it |

### 6.4 Questionnaire draft (for the human; not answered here)

These are drafts for the Maturity & Compliance Questionnaire (RC-03); the human answers in Creator Hub.
- Paid random items: **Yes.** That covers nests (D2), the Lucky Bobber and the Sky Bell (probability modifiers).
- Respects `ArePaidRandomItemsRestricted`: **Yes**, as described in §6.3.
- Paid item trading: **No trading in the game.**

Whether the D6 server-wide change alters any of these is part of the escalated question (§7).

---

## 7. The D6 disclosure question and O-H2 (escalated to the human)

### 7.1 The question (GDD O-H1, from D6)

A Sky Bell call is bought by one player and changes luck and odds for everyone fishing at the harbour in that server, including players who paid nothing. How is that change shown to players, and does it change the questionnaire answers?

Platform rules that every option must meet (`vault/09-monetization/monetization-compliance.md` §1):
- A probability modifier explains numerically how it changes odds **before purchase**.
- Displayed odds update to the player's **true odds** while it is active.

### 7.2 Options

| Option | Buyer, before purchase | Everyone at the harbour, during the call | Questionnaire | For | Against |
|---|---|---|---|---|---|
| **A. Full disclosure for everyone (recommended)** | The §3.1 panel: arrival, duration, "everyone shares it", +25% and the paid cap, the odds list now and with the bell | Bell icon on the Sky Dial and on each called spot; the banner; a "Sky Bell +25%" line (or "+0 in Sea Fog") in each affected player's luck breakdown; the spot Odds list shows true odds and returns when the call ends | Unchanged: "paid random items: yes" already covers it (D2); the Sky Bell is listed with the Lucky Bobber and nests | Nobody's odds change without an on-screen reason; easy for a 7-13 audience; meets both platform rules for buyers and non-buyers; one extra line and an icon | Slightly more UI; makes visible that luck can be bought |
| B. Buyer in full, others on request | Same as A | Weather, bell icon and banner only; true odds appear when a player opens the spot's Odds list, with no luck-breakdown line | Unchanged | Less UI; still truthful wherever odds are displayed | A child who paid nothing may see better luck without being told why, which is weaker transparency for the players the purchase affects most |
| C. Weather only, no bonus | The weather's own odds list, now and with the call; no +25% | As B, or as A without the +25% line | Unchanged: the call still changes the fish table (weather-only species, marks, fog's natural luck), so it stays a paid probability modifier | Simplest luck story; the +25% paid cap holds only the Lucky Bobber | Weaker product. It needs the Economist to set the shared bonus to 0 (economy sheet §13; G5 in the GDD sync). It does not remove the disclosure duty |

**Recommendation: option A**, for four reasons:
1. It meets both platform rules for buyers and non-buyers alike.
2. It fits the cozy rule "honest time", extended to odds.
3. It costs one line and an icon.
4. None of the three options changes the questionnaire answers drafted in §6.4. The human is asked to confirm that, including the catalog's reading in §6.1 that 2x Coins and Auto Reel do not fund random items.

### 7.3 O-H2: may restricted players fish under a call someone else bought?

Players whose `ArePaidRandomItemsRestricted` is true never see the Sky Bell products, and the luck rule never gives them the +25%. The question is the called weather's fish table and marks, which differ from Clear water.

| Option | What restricted players get under a call | Effect on D6 constraint (2) | Notes |
|---|---|---|---|
| **(a) Yes, as world weather (recommended)** | The called weather's way of fishing, species and marks, like any natural front, **without** the +25% (economy sheet §10) | Kept: everyone present shares the weather | They paid nothing, and no Robux path from them reaches a random outcome. The forecast stays true for them (pillar 2), and nothing is taken from them (cozy rule) |
| (b) Weather visible, Clear table | They see the front but fish the Clear table and ring inside it | Weakened: a visible weather that does not apply to them | A child sees rain and the others' rain fish but cannot catch them, which breaks "the forecast is true" and is hard to explain |
| (c) No calls in a server with a restricted player | Nothing to fish under; the bell is not sold to anyone in that server | Kept, by removing calls | It gives one player's policy status a veto over the server, and an unexplained "bell unavailable" could reveal that status to others |

**Recommendation: (a).** It is the GDD's option (a), with the +25% withheld as the accepted economy sheet already does.

### 7.4 Escalation

Escalated on 2026-10-26 with `python3 agents/studioctl.py escalate --game stormcatch --kind policy --by monetization-designer`. **Escalation id: E-0001.** Both questions, D6 disclosure (O-H1) and O-H2, are in this one escalation. Agents do not answer it. The Sky Bell is built only after the human answers, at the build stage.

---

## 8. Offer briefs (for the Interface Designer and the Engineer)

**Global rules** (`vault/09-monetization/shop-ux-and-contextual-offers.md`):
1. **Timing.** Nothing is listed before onboarding step 12. Contextual cards only from the player's **second session**.
2. **At most one contextual card per session, for all offers together.** Never during a cast, hook, reel, reveal or pull, never during the Great Storm or its last 60 s of countdown, and never in the first 2 minutes of a session.
3. **Never in the way.** A card is dismissed with one tap, never blocks movement or the Cast button, and lives in the panel where the need is felt.
4. **Back-off.** After 2 dismissals of the same card it is not shown for 14 days. After 3 it is never shown again; the item stays in the shop.
5. **Probability modifiers and coin packs never get a card** (§1 rule 6).
6. **Copy.** Neutral: "See offer", "View", "Not now". No exclamation marks, countdowns, "only N left", "last chance", or "best deal" unless it is computed at runtime.
7. **Prices.** Every displayed price comes from `MarketplaceService:GetProductInfoAsync` on the client.
8. **Restricted players.** Flagged items never render for them, and no card mentions them.
9. **Measurement.** Log impression, open and purchase per offer key and moment (template shop funnel), and compare D1/D7 between players who saw a card and those who did not.

| Offer | Moment | Who | Where | Cap | Free alternative on screen | Draft copy |
|---|---|---|---|---|---|---|
| Big Pal Pouch | A hatch is blocked because companion space is full | Step 12, session 2+, does not own it | Card inside the nest panel | Global rules | "Release a pal" and the Pal Pouch upgrade (coins) | "Companion space is full. Release a pal, upgrade your Pal Pouch, or see the Big Pal Pouch (+50 space)." |
| Third Tide Pot | Both pots are placed and the player opens the pot panel | Has 2 slots, does not own it | A locked third slot in the pot panel ("See Third Tide Pot"), always visible; the slot is not a card | Passive slot; no card | n/a (pots are a bonus) | "A third pot. It fills at the same speed: full in 8 hours." |
| Auto Reel | After the 300th lifetime catch, at the end of a Clear-water reveal | Step 12, session 2+, does not own it | Small card above the Cast button for 6 s, then it fades | **Once ever** | Reeling yourself is the game | "Auto Reel can reel for you in Clear water, at about two-thirds of your speed." [View] [Not now] |
| Starter Pack | Start of session 2 | Step 12 done, not bought, not restricted | "New" badge on the Shop button; the pack pinned at the top of the Store tab until bought | Badge once | n/a | "Starter Pack: about 30 minutes of coins, a 15-minute 2x Coins boost and a raincoat colour. Once per player." |
| Sky Bell | Pull only: "Ring the Sky Bell" in the expanded Sky Dial (GDD §3.2), or a tap on the bell on the quay | Step 12, not restricted | Sky Bell panel (§3.1) | No card, ever | The natural forecast on the same dial | §3.1 |
| 2x Coins, Lucky Bobber | Shop only | Step 12 (Lucky Bobber: not restricted) | Store tab, with an "Odds" button on the Lucky Bobber | No card | n/a | Descriptions in §9 |
| Coin packs | Shop only; the "+" next to the coin counter opens the Store at coins | Step 12, not restricted | Store tab | No card | The bridge sign shows "about N minutes of fishing to go" | "About N coins (about M minutes of your fishing)." |
| Cosmetics | Shop only, plus world presence: a coat rack at the harbour with a try-on preview (optional, Worldbuilder) | Step 12 | Store "Style" tab, with earned cosmetics shown as "Earned" | No card | Calendar and referral raincoat colours | Descriptions in §9 |

**Sky Bell banner:**
- Default: "Mia rang the Sky Bell: Sea Fog at the harbour in 1:00. Everyone can fish it!"
- When the buyer turns their name off: "Someone rang the Sky Bell: ...". This avoids pressure on known buyers to ring again (a request to the Designer, §11).
- The banner shows the display name only, never custom text.

---

## 9. Creation list for the human (build stage)

The human creates these in Creator Hub at the build stage. The ids go into `Config/Products.luau`, which uses the keys in Appendix A. Every price is a draft. The human can enable regional pricing and managed pricing for all of them; price tests need far more volume than a new game has (about 60,000 transactions in 30 days). **This list is escalated with `--kind decision` at the build stage, not now**, because the prototype sells nothing and the Sky Bell prices depend on the policy answer (§7).

Each icon is original art by the Artist (house rule 7): a gold or cream core with a Night Ink rim, readable at small size, with no text except "2x" or "+1" (`art-direction.md` §2-§3).

| # | Name | Type | Description (Creator Hub and in game) | Draft Robux | Icon brief | List outside the game |
|---|---|---|---|---|---|---|
| 1 | Sky Bell: Showers | Developer product | Calls Showers over the harbour for 3 minutes, on everyone's Sky Dial 1 minute ahead. Everyone in this server shares it, with +25% luck on Rare and rarer fish. | 49 | A gold bell under a small rain cloud with Seafoam streaks | No (PM) |
| 2 | Sky Bell: Sea Fog | Developer product | Calls Sea Fog over the harbour for 3 minutes, on everyone's Sky Dial 1 minute ahead. Everyone in this server shares it. Fog already doubles luck, so the bell adds none. | 49 | The bell in a soft grey fog band with a lantern glow | No (PM) |
| 3 | Sky Bell: Gusts | Developer product | Calls Gusts over the harbour for 3 minutes, on everyone's Sky Dial 1 minute ahead. Everyone in this server shares it, with +25% luck on Rare and rarer fish. | 49 | The bell with two curling wind lines | No (PM) |
| 4 | Coin Pouch | Developer product | About 15 minutes of coins at your current catch rate. | 49 | A small cloth pouch of gold coins | No (FR) |
| 5 | Starter Pack | Developer product | About 30 minutes of coins, a 15-minute 2x Coins boost and a raincoat colour found only here. Once per player. | 75 | A small sea chest with coins, a "2x" tag and a raincoat sleeve | No (FR) |
| 6 | Coin Crate | Developer product | About 60 minutes of coins at your current catch rate. | 149 | A wooden crate of coins | No (FR) |
| 7 | Coin Chest | Developer product | About 3 hours of coins at your current catch rate. | 399 | A brass-bound chest of coins | No (FR) |
| 8 | 2x Coins | Pass | Double coins from every catch, starting once you fix the bridge to Lantern Reef. Adds to timed coin boosts (3x at most). | 249 | Two gold coins with "2x" | Yes |
| 9 | Auto Reel | Pass | Reels for you in Clear water after you cast, landing about two-thirds as many fish as you would. Showers, Sea Fog, Gusts and storms you reel yourself. | 149 | A reel with a circular arrow | Yes |
| 10 | Lucky Bobber | Pass | +25% luck on Rare and rarer fish (the odds you see update). All paid luck together is capped at +25%. No extra luck in Sea Fog, on nests or on Stormborn. | 149 | A cream-and-coral bobber with a small green four-leaf mark | No (PM) |
| 11 | Big Pal Pouch | Pass | Room for 50 more companions, on top of your Pal Pouch upgrades. | 99 | A bulging pouch with a Puddle Frog peeking out | Yes |
| 12 | Third Tide Pot | Pass | A third Tide Pot slot. It fills at the same speed as your others: full in 8 hours. | 149 | A clay pot on wet sand with "+1" | Yes |
| 13 | Rain Gear | Pass | 4 raincoat-and-hat colours and 2 umbrellas that open when it rains. Worn in this game. Style only. | 99 | A raincoat and an open umbrella in new colours (never a yellow hooded coat) | Yes |
| 14 | Bobber Box | Pass | 6 bobber designs that everyone fishing near you can see. Style only. | 75 | An open tackle box with six bobbers | Yes |
| 15 | Lantern Keeper Set | Pass | A lantern coat and hat that glow softly in Sea Fog, a lantern bobber and a lantern umbrella. Worn in this game. Style only. | 699 | A coat silhouette lit by a lantern in fog | Yes |

**About "List outside the game".** Roblox can sell listed passes and products on its own surfaces, outside the game (`shop-ux-and-contextual-offers.md`).
- **"No"** applies to every probability modifier and every coin product. The game cannot apply the restricted-player rules or the "nothing before step 12" rule to a purchase made outside it.
- **"Yes"** items are safe bought anywhere: 2x Coins waits for the first bridge, the Auto Reel toggle appears after step 12, and the rest is capacity or style.
- If Creator Hub offers no such choice, the template's receipt handling still holds flagged products for restricted players. The Security Reviewer confirms that this is acceptable (§10).

---

## 10. Compliance notes for the Security Reviewer

1. **Flags.**
   - `probabilityModifier = true`: Lucky Bobber, Sky Bell ×3.
   - `fundsRandomItems = true`: Starter Pack, Coin Pouch, Coin Crate, Coin Chest. Appendix A's check script asserts that this flag is true exactly when a product grants coins.
   - Every other item: neither flag.
2. **Server gates** (template, kept):
   - `Purchases.allowedFor` refuses flagged products for restricted players.
   - `Shop.luau` hides them.
   - `Policy.load` falls back to restricted when PolicyService fails.
   - New at the build stage: `shownFromStep` hides every item before step 12.
3. **Paid luck.** At the build stage, `Util/Stats.luau` adds the Lucky Bobber and the Sky Bell bonus into the single paid sub-cap (`min(0.25, paid)`) inside the Sky category (economy sheet §10), with paid luck ignored for restricted players. It never feeds `Odds.effective` for nests or Stormborn.
4. **Grants only in `ProcessReceipt`, idempotent and saved.**
   - Sky Bell: one Sky Call credit saved with the receipt id (GDD §4.10).
   - Starter Pack: `oncePerPlayer`.
   - Coin amounts are computed on the server at grant time.
   - The new remote `RingSkyBell` spends a saved credit only, is rate-limited, and checks the slot rules on the server.
5. **No client trust.** There is one product per weather, so the client never names a weather to buy. Banner text is the display name only.
6. **Odds surfaces** (§6.2) are built from the same tables the server rolls. Displayed percentages sum to 100%. The luck breakdown shows each category and the binding cap.
7. **Prices** are never hard-coded. The managed-pricing dynamic price check should show none.
8. **External purchases.** Keep PM and FR items unlisted outside the game (§9). Confirm that a flagged receipt held for a restricted player (`NotProcessedYet`) is acceptable, or define a refund path with the human.
9. **Analytics:** `called` and `auto` flags on catches; `SkyCallPurchased`, `SkyCallStarted`, `SkyCallEnded`, `SkyCallLost` (GDD §10); offer funnels per §8.
10. **Code that changes at the build stage** when Appendix A is applied. These are found by search and listed for the Engineer:
    - `src/shared/Util/Stats.luau`: x2Coins additive and gated by zone; `luck2x`, `serverLuck`, `lucky`, `vip` and `petSlots` removed.
    - `src/server/Systems/Purchases.luau`: `serverBoost` and `gems` grants out; `skyCall` and `cosmetic` grants in.
    - `src/server/Systems/Grants.luau` (`luck2x`, `serverLuck`) and `src/client/Controllers/HUD.luau` (boost labels).
    - `src/server/Systems/Hatching.luau` and `src/client/Controllers/Hatch.luau` (`tripleHatch`).
    - `src/client/Controllers/SettingsPanel.luau` (QA pass list).
    - `src/shared/Config/Rewards.luau` (day 7 uses `luck2x` and gems; becomes `luckyTide` per economy sheet §12.2).
    - `scripts/check-config.luau` (grant kinds).

---

## 11. Requests to other roles

**Economist:**
1. Re-run the paying model with this catalog:
   - 2x Coins from the first bridge;
   - Lucky Bobber +25% from step 12;
   - no extra equip slots;
   - the Starter Pack at step 12;
   - one Coin Crate a day, plus a heavy-spender case with one Coin Chest a day;
   - a third Tide Pot.

   Confirm that payers stay within 2-4x of the casual free player on goals 2, 3 and 5, and that no coin product moves the casual first bridge. Resize the packs if they do not.
2. Confirm the coin-pack basis: permanent multipliers only, never timed boosts (§3.8).
3. Confirm Auto Reel's limits: 70% landed, reel x2, Clear-ring water only, no Charged. That gives 64-69% of active Clear [C].
4. The Lucky Bobber adds nothing in Sea Fog under the Sky cap. The catalog discloses this as it stands. If you prefer paid luck to count in fog, it needs its own capped category; that is your decision.

**Designer** (GDD §4.10 and §4.6 are yours):
1. **W1:** Pebble Cove species with the Misty or Breezy mark can only be caught under a paid call. Options:
   - a rare natural Sea Fog or Gusts visit to Pebble Cove, keeping the 180 s clear-harbour window and the onboarding Showers rule;
   - no "marks seen" entries for those combinations;
   - another rule of your choice.
2. **W2:** Pebble Cove's daily record can only be beaten under a called Gusts front. Options:
   - a bell icon on records set under a call;
   - count only natural weather for records.
3. Add to §4.10:
   - **one call per buyer per storm cycle** (at most 4 an hour; [E]);
   - a **"show my name" toggle**, so the banner can read "Someone rang the Sky Bell".
4. Record the Auto Reel rules: Clear-ring water only, pauses in fronts and the storm, Cast tapped by the player, off by default, toggle after step 12.
5. Keep a **free ring assist** in Settings, such as a wider green arc, so Auto Reel is never the only help for players who find the ring hard.

**Artist:** the 15 icons and the cosmetic looks in §9. No yellow hooded raincoat (art direction §8).

**Interface Designer:** the Store tab (Upgrades, Companions, Store, Style), the Sky Bell panel (§3.1), the Odds lists with the luck breakdown (§6.2) and the offer cards (§8).

**Engineer** (build stage): apply Appendix A and the code changes listed in §10 item 10. Keep ids at `0` until the human creates the items.

**Director:**
- Queue the creation-list escalation (`--kind decision`, §9) at the build stage, after the human answers §7 and the prototype verdict is go.
- Queue the Sky Bell build after that answer.

---

## Appendix A: proposed `Config/Products.luau` (not applied)

The game's `project/src/shared/Config/Products.luau` is **unchanged**. This task edits no code. The proposal is stored as specs, ready for the build stage.

| File | What it is |
|---|---|
| `games/stormcatch/docs/specs/catalog-config/Products.luau` | The full proposed file: 8 passes and 7 products, all ids `0`, new fields `cosmetic` and `shownFromStep`, new grant kinds `skyCall` and `cosmetic`, gems and `serverBoost` removed, boosts `coins2x` (additive) and `luckyTide` (free only), pass effects (2x Coins from `lantern_reef`, Auto Reel 0.70 and x2, Lucky Bobber 0.25 paid Sky luck, +50 capacity, +1 pot) |
| `games/stormcatch/docs/specs/catalog-config/Products.diff` | Unified diff against the game's current file. `git apply --check` passes from `games/stormcatch/project` |
| `games/stormcatch/docs/specs/catalog-config/check.luau` | The catalog's rules as checks (ids 0, shown from step 12, flags matching grants, no gems or `serverBoost`, paid luck at most 0.25, Auto Reel below 85%, no price in any description) |

Checks run on 2026-10-25, from the repository root with the project's pinned tools:

```text
P=games/stormcatch/project
$P/.tools/bin/lune run games/stormcatch/docs/specs/catalog-config/check          # "All catalog config checks passed."
$P/.tools/bin/stylua --config-path $P/stylua.toml --check games/stormcatch/docs/specs/catalog-config/   # exit 0
$P/.tools/bin/luau-lsp analyze --defs=$P/.tools/globalTypes.d.luau games/stormcatch/docs/specs/catalog-config/Products.luau   # exit 0, strict
```

## Sources

- Human decisions D2 and D6: `games/stormcatch/docs/decisions.md` (2026-10-24).
- GDD: `games/stormcatch/docs/gdd.md` §1, §3.2-§3.3, §4.4, §4.6, §4.8, §4.10, §5, §6, §12 (T-0007, accepted; v2 sync T-0013 read 2026-10-25).
- Economy sheet: `games/stormcatch/docs/economy-sheet.md` §1, §4, §6, §9-§13 and the T-0008 handoff "Next".
- World plan: `games/stormcatch/docs/world-plan.md` §4 and §7 (front paths, `Callable` spots).
- Art direction: `games/stormcatch/docs/art-direction.md` (palette, two-tone rule, raincoat look-alike note).
- Market scan: `games/stormcatch/docs/market-scan.md`. Comparable server weather is sold for in-game coins and lasts 10-15 minutes; no Robux weather price was found.
- Vault (dated 2026-10-24): `09-monetization/` (monetization-strategy, product-catalog, pricing-and-price-ladders, shop-ux-and-contextual-offers, monetization-compliance, platform-payouts, ads-and-rewarded-video); `17-policy-and-business/age-ratings-and-audience.md`; `03-rarity-and-rng/rng-systems-and-pity.md`; `14-genre-playbooks/fishing-and-collection.md` and `grow-and-farm.md`; `99-reference/key-numbers.md`.
- Template code read 2026-10-25: `Config/Products.luau`, `Services/Policy.luau`, `Systems/Purchases.luau`, `Util/Stats.luau`, `Controllers/Shop.luau`, `scripts/check-config.luau`.
- Numbers: `games/stormcatch/docs/models/catalog_numbers.py` and its output `models/catalog_numbers_output.txt`.

Related: [Decisions](decisions.md) · [GDD](gdd.md) · [Economy sheet](economy-sheet.md) · [World plan](world-plan.md) · [Art direction](art-direction.md) · [Catalog numbers](models/catalog_numbers_output.txt)
