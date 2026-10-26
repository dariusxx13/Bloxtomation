#!/usr/bin/env python3
"""Reel the Storm (game id `stormcatch`): economy and drop-table model.

Task T-0008, Economist, design stage, 2026-10-25. Updated by T-0015 (2026-10-26): the paying model buys only what
the accepted catalog (games/stormcatch/docs/catalog.md) sells, every minutes-of-income grant uses one permanent
basis (no timed boosts, friends or paid coin pass), and section N answers the catalog's three questions.

Run from the repository root:

    python3 games/stormcatch/docs/models/economy_model.py --out games/stormcatch/docs/models/economy_model_output.txt

Standard library only. The pacing part is a deterministic expected-value simulation stepped one
second at a time (no randomness); the odds checks use a seeded Monte Carlo, so the output is identical
on every run. Every constant block names the Config module it becomes in
games/stormcatch/project/src/shared/Config/. Nothing here edits game code.

Why Python: when this task started `lune` was not installed (`which lune` printed nothing, 2026-10-25).
`python3 agents/studioctl.py check stormcatch` later installed the pinned tools into project/.tools/bin, but the
template's `scripts/economy-sheet.luau` reads only the game's Config, which still holds the template's values
(this task edits no code). So this file is the economy of record until the Engineer moves these tables into
Config; from then on `lune run scripts/economy-sheet` and tests/Economy.spec.luau take over. It mirrors the
template's formulas (Util/EconomyMath.luau, Util/Odds.luau, Util/Stats.luau) and extends them to fishing.

Tuning aids: `--quick` (3 join minutes instead of 15) and `--timeline casual|typical|paying --phase N`.
"""

from __future__ import annotations

import argparse
import math
import random
import sys

# =====================================================================================================
# 1. CONFIG (each block names its Config file)
# =====================================================================================================

TIERS = ["Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"]
# Config/Pets.luau Rarities.luckApplies: luck multiplies Rare-and-up weights only (template rule).
LUCK_APPLIES = {"Rare", "Epic", "Legendary", "Mythic", "Secret"}

# Config/Species.luau (new): value of a fish = baseCoinsPerCatch * tierValue * islandMultiplier * size * mark.
TIER_VALUE = {"Common": 1, "Uncommon": 2, "Rare": 4, "Epic": 10, "Legendary": 30, "Mythic": 100, "Secret": 400}

# Config/Economy.luau
ECONOMY = {
    "baseCoinsPerCatch": 5,  # replaces baseCoinsPerHit = 1 (one catch is ~8 s, not 0.2 s)
    "firstCatchCoins": 12,  # the scripted onboarding catch (Pebble Minnow, 0.8 kg), loop sketch 5.1
    "shopOpensAtSeconds": 45,  # onboarding steps 4-5 (shop pulses after 15 coins); first purchase not earlier
    "assumedCatchesPerMinute": 5,  # converts "minutes of income" rewards to coins (Rewards.assumedHitsPerMinute)
    # New Tide (rebirth): template keys rebirthBaseCost / rebirthCostGrowth / rebirthMultiplierPerRebirth
    "newTideBaseCost": 130_000_000,
    "newTideCostGrowth": 1.9,
    "newTideMultiplierPerTide": 0.5,
    "maxNewTides": 30,  # cap: x16 at 30 tides; a second layer is planned before tide 15 (see output)
    "newTideKeepsIslands": True,  # template rebirthKeepsZones
    "newTideRequiresIsland": "thunderhead_point",
}

# Config/Weather.luau (new). Seconds per catch phase. Bite waits are uniform in [lo, hi]; the mean is used.
WEATHER = {
    "clear": dict(cast=1.0, bite=(2.0, 5.0), reel=1.5, reveal=1.5, reel_delta=0.00, size=1.00, value=1.0,
                  mark=None, sky_luck=0.0, only=None),
    "showers": dict(cast=1.0, bite=(1.0, 2.5), reel=1.0, reveal=1.5, reel_delta=+0.08, size=1.00, value=1.0,
                    mark=("Drizzled", 0.20, 1.5), sky_luck=0.0, only="showers"),
    "fog": dict(cast=1.0, bite=(2.8, 7.0), reel=1.5, reveal=2.0, reel_delta=-0.04, size=1.00, value=1.0,
                mark=("Misty", 0.15, 2.0), sky_luck=1.0, only="fog"),
    "gusts": dict(cast=1.0, bite=(2.0, 5.0), reel=2.0, reveal=1.5, reel_delta=-0.12, size=1.25, value=1.0,
                  mark=("Breezy", 0.20, 1.5), sky_luck=0.0, only="gusts"),
    "rainbow": dict(cast=1.0, bite=(2.0, 5.0), reel=1.5, reveal=1.5, reel_delta=0.00, size=1.00, value=2.0,
                    mark=("Prism", 0.05, 5.0), sky_luck=0.0, only=None),
    # The Great Storm's eye over the Open Pier: Pebble Cove species, valued at the player's best island.
    "eye": dict(cast=1.0, bite=(2.0, 4.0), reel=1.5, reveal=1.5, reel_delta=0.00, size=1.00, value=1.0,
                mark=("Charged", 0.25, 3.0), sky_luck=0.0, only=None),
}
FAILED_REEL_RECOVER_S = 1.0  # loop sketch section 3: Cast is available again within 1 s
MARK_CAP = 5.0  # no mark multiplier above x5 (risk 5, mark inflation)
CHARGED_PER_FRIEND = 0.05  # friends among the pull helpers raise the Charged chance (loop sketch 4.4)
CHARGED_CAP = 0.50

# Size roll (Config/Species.luau sizeRoll): factor = clamp(exp(N(-s^2/2, s)), lo, hi) * weather size.
SIZE_SIGMA = 0.25
SIZE_CLAMP = (0.5, 3.0)
STORMBORN_SIZE_SIGMA = 0.30

# Great Storm (Config/Weather.luau greatStorm)
STORM = {
    "periodSeconds": 900,  # :00 :15 :30 :45 UTC
    "durationSeconds": 180,
    "stormbornHookChance": 0.04,  # chance that an eye bite is a Stormborn (GDD 4.3 target: one every other storm,
                                  # which needs 4% once hooks are capped at one per player per storm)
    "stormbornMaxPerStorm": 1,  # per player (prototype brief req. 9.3)
    "stormbornPityEyeBites": 60,  # hard pity: 60 eye bites without a hook -> the next eye bite hooks (2.4x of 25)
    "soloLandSeconds": 45.0,  # loop sketch 4.4
    "helperSpeedup": 0.875,  # land time = 45 / (1 + 0.875 * helpers): 4 helpers -> 10 s
    "stormbornValueFactor": 0.5,  # giants pay half their tier value in coins: the prize is the journal page, the
                                  # banner and the crowd (a full-value giant in a new player's first storm skipped
                                  # most of the first bridge in the model run of 2026-10-25)
    "helperShare": 0.10,  # a helper's minted share of the Stormborn's value (prototype fallback 25% halved twice:
                          # at 25% a new player's first storm paid more than 3 minutes of fishing in helper shares)
    "helperSharesCapPerStorm": 3,  # abuse cap (loop sketch 4.4)
    "travelSecondsByIsland": {"pebble_cove": 10, "lantern_reef": 30, "gustwhistle_bluffs": 40,
                              "thunderhead_point": 50},  # at walk speed 16; Boots shorten it
}

# Fronts (Config/Weather.luau fronts): where a player stands under a front, which type is it.
FRONT_MIX = {
    "showers": {"showers": 0.6, "fog": 0.2, "gusts": 0.2},
    "fog": {"showers": 0.2, "fog": 0.6, "gusts": 0.2},
    "gusts": {"showers": 0.2, "fog": 0.2, "gusts": 0.6},
    "mixed": {"showers": 1 / 3, "fog": 1 / 3, "gusts": 1 / 3},
}
FRONTS_START_SECONDS = 90  # the first shower reaches the dock at about 1:30 (loop sketch 5.2)
SCRIPTED_RAIN_RARE_SECONDS = 120  # first catch in rain is a guaranteed rain-only Rare with Drizzled

# Config/Zones.luau (islands; gateCost = bridge price)
ISLANDS = [
    dict(id="pebble_cove", name="Pebble Cove", gate=0, mult=1, tides=0, home="showers", nest="driftwood_nest"),
    dict(id="lantern_reef", name="Lantern Reef", gate=620, mult=4, tides=0, home="fog", nest="reef_nest"),
    dict(id="gustwhistle_bluffs", name="Gustwhistle Bluffs", gate=19_000, mult=16, tides=0, home="gusts",
         nest="bluff_nest"),
    dict(id="thunderhead_point", name="Thunderhead Point", gate=1_600_000, mult=64, tides=0, home="mixed",
         nest="thunder_nest"),
]
ISLAND_BY_ID = {i["id"]: i for i in ISLANDS}

# Config/Species.luau species. Weights, not percentages (probability = weight / table total).
# Ids are slots; the Designer names them in the GDD (names given only where the loop sketch has them).
SPECIES = [
    # Pebble Cove (8): 3 Common, 2 Uncommon, 2 Rare, 1 Epic. Set lock: the Epic.
    ("pebble_minnow", "Common", "island:pebble_cove", 26.0),
    ("bobblefin", "Common", "island:pebble_cove", 22.0),
    ("sandskipper", "Common", "island:pebble_cove", 18.0),
    ("tidetail", "Uncommon", "island:pebble_cove", 13.0),
    ("kelpnibbler", "Uncommon", "island:pebble_cove", 11.0),
    ("copperscale", "Rare", "island:pebble_cove", 4.7),
    ("pc_rare_2", "Rare", "island:pebble_cove", 3.8),
    ("pc_epic_1", "Epic", "island:pebble_cove", 2.0),
    # Lantern Reef (8): 3 C, 2 U, 1 R, 1 E, 1 L
    ("lr_common_1", "Common", "island:lantern_reef", 25.0),
    ("lr_common_2", "Common", "island:lantern_reef", 21.0),
    ("lr_common_3", "Common", "island:lantern_reef", 17.0),
    ("lr_uncommon_1", "Uncommon", "island:lantern_reef", 14.0),
    ("lr_uncommon_2", "Uncommon", "island:lantern_reef", 11.0),
    ("lr_rare_1", "Rare", "island:lantern_reef", 9.0),
    ("lr_epic_1", "Epic", "island:lantern_reef", 2.6),
    ("lr_legendary_1", "Legendary", "island:lantern_reef", 0.4),
    # Gustwhistle Bluffs (8): 3 C, 2 U, 1 R, 1 E, 1 L
    ("gb_common_1", "Common", "island:gustwhistle_bluffs", 25.0),
    ("gb_common_2", "Common", "island:gustwhistle_bluffs", 21.0),
    ("gb_common_3", "Common", "island:gustwhistle_bluffs", 17.0),
    ("gb_uncommon_1", "Uncommon", "island:gustwhistle_bluffs", 14.0),
    ("gb_uncommon_2", "Uncommon", "island:gustwhistle_bluffs", 11.0),
    ("gb_rare_1", "Rare", "island:gustwhistle_bluffs", 9.0),
    ("gb_epic_1", "Epic", "island:gustwhistle_bluffs", 2.6),
    ("gb_legendary_1", "Legendary", "island:gustwhistle_bluffs", 0.4),
    # Thunderhead Point (8): 2 C, 2 U, 1 R, 1 E, 1 L, 1 M
    ("tp_common_1", "Common", "island:thunderhead_point", 30.0),
    ("tp_common_2", "Common", "island:thunderhead_point", 25.0),
    ("tp_uncommon_1", "Uncommon", "island:thunderhead_point", 15.0),
    ("tp_uncommon_2", "Uncommon", "island:thunderhead_point", 13.0),
    ("tp_rare_1", "Rare", "island:thunderhead_point", 11.5),
    ("tp_epic_1", "Epic", "island:thunderhead_point", 4.5),
    ("tp_legendary_1", "Legendary", "island:thunderhead_point", 0.9),
    ("tp_mythic_1", "Mythic", "island:thunderhead_point", 0.1),
    # Weather-only, 3 per front type; they join the table of any island the front covers.
    ("splashkin", "Uncommon", "weather:showers", 15.0),
    ("pitterpike", "Rare", "weather:showers", 6.5),  # the scripted first rain catch
    ("rain_epic", "Epic", "weather:showers", 1.5),
    ("hushgill", "Rare", "weather:fog", 6.0),
    ("lanternfin", "Epic", "weather:fog", 2.2),  # Fish of the Day example in loop sketch 5.7
    ("fog_legendary", "Legendary", "weather:fog", 0.5),
    ("gust_rare", "Rare", "weather:gusts", 12.0),
    ("gust_epic", "Epic", "weather:gusts", 4.5),
    ("gust_legendary", "Legendary", "weather:gusts", 1.0),
    # Stormborn (4): rolled only when an eye bite is a Stormborn hook. All tiers are luck tiers, so luck
    # cannot change this table (multiplying every weight and renormalising is a no-op): fixed odds.
    ("stormborn_legendary_1", "Legendary", "storm", 50.0),
    ("stormborn_legendary_2", "Legendary", "storm", 37.0),
    ("rumblefin", "Mythic", "storm", 12.0),
    ("stormborn_secret", "Secret", "storm", 1.0),
    # Aurora Night (3): weekly event table (not part of first-session pacing).
    ("aurora_rare", "Rare", "aurora", 70.0),
    ("aurora_epic", "Epic", "aurora", 25.0),
    ("aurora_legendary", "Legendary", "aurora", 5.0),
]
SPECIES_TIER = {s[0]: s[1] for s in SPECIES}

# Config/Upgrades.luau. cost(level) = baseCost * costGrowth ^ level (template formula, EconomyMath.upgradeCost)
UPGRADES = {
    "rod": dict(kind="power", name="Rod", baseCost=15, costGrowth=1.28, effect=1.14, maxLevel=150,
                resetsOnNewTide=True, revealSeconds=0),
    "lure": dict(kind="luck", name="Lure", baseCost=150, costGrowth=2.0, effect=0.04, maxLevel=25,
                 resetsOnNewTide=False, revealSeconds=240),
    "boots": dict(kind="speed", name="Boots", baseCost=120, costGrowth=1.55, effect=1, maxLevel=16,
                  resetsOnNewTide=True, revealSeconds=240),
    "pal_pouch": dict(kind="storage", name="Pal Pouch", baseCost=1_000, costGrowth=3.0, effect=10, maxLevel=10,
                      resetsOnNewTide=False, revealSeconds=None),  # +10 companion capacity; revealed at Lantern Reef
}
BASE_WALK_SPEED = 16
BASE_COMPANION_SLOTS = 3  # Pets.baseEquipSlots (template 3; GDD 4.4)
BASE_COMPANION_CAPACITY = 60  # Pets.baseCapacity (template)

# Config/Eggs.luau (nests) and Config/Pets.luau (companions). Nest odds are fixed: no luck applies.
NESTS = [
    dict(id="driftwood_nest", island="pebble_cove", price=150, scale=1, revealSeconds=300),
    dict(id="reef_nest", island="lantern_reef", price=5_000, scale=2, revealSeconds=0),
    dict(id="bluff_nest", island="gustwhistle_bluffs", price=1_000_000, scale=3, revealSeconds=0),
    dict(id="thunder_nest", island="thunderhead_point", price=50_000_000, scale=4, revealSeconds=0),
]
NEST_ENTRIES = [("Common", 75.0), ("Rare", 22.0), ("Legendary", 3.0)]
NEST_PITY = ("Legendary", 80)  # hard pity: 80 hatches = 2.4x the expected 33.3
COMPANION_COIN_BONUS = {"Common": 0.05, "Rare": 0.10, "Legendary": 0.25}  # times the nest's scale
# Weather perks (active only in the matching weather); caps per perk type.
PERK_CAPS = {
    "bite": 0.30,  # bite wait reduced by at most 30%
    "luck": 0.50,  # companion luck category cap
    "reel": 0.98,  # reel success never above 98%
    "mark": 2.0,  # mark chance at most 2x its weather's base
}

# Luck stacking rule (Config/Economy.luau luck block). Additive inside a category, multiplied across
# categories, every category capped, the product capped.
LUCK = {
    "gearCap": 1.00,  # Lure: +4% per level, 25 levels
    "companionCap": 0.50,
    "friendPerFriend": 0.10,  # template friendBonusPerFriend, applied to luck (loop sketch section 6)
    "friendCap": 0.50,  # template maxFriendBonus
    "skyCap": 1.00,  # weather and timed or paid luck
    "paidCap": 0.25,  # every Robux-linked luck source combined (D6 Called Front, any paid luck item)
    "totalCap": 6.0,  # template maxLuck = 10
    "fog": 1.00,  # natural Sea Fog: Rare-and-up weights x2 (loop sketch 4.2)
    "calledFront": 0.25,  # D6: shared by everyone in the server while a called front lingers
    "luckyTide": 0.25,  # day-7 calendar reward, 15 minutes, personal
}

# D6 Called Front (Config/Weather.luau calledFront; the product row belongs to the Monetization Designer)
CALLED_FRONT = {  # GDD 4.10 (timing is the Designer's; the shared bonus is the Economist's)
    "warningSeconds": 60,  # on the Sky Dial for everyone before it arrives
    "lingerSeconds": 180,
    "maxActivePerServer": 1,
    "maxQueuedPerServer": 2,
    "maxPerStormCycle": 2,  # 2 x 180 = 360 of the 720 non-storm seconds at most
    "guardBeforeStormSeconds": 60,
    "guardAfterStormSeconds": 30,
    "gapSeconds": 60,
    "where": "harbour Callable spots (Pebble Cove values, x1)",
}

# Coin multiplier categories (Util/Stats.luau rule)
COIN = {
    "companionCap": 1.00,  # companions: 1 + sum, capped (template maxPetMultiplier = 25)
    "bonusCap": 1.00,  # journal sets + streak + group, additive
    "journalSetBonus": 0.05,  # per completed Sky Journal set (12 sets)
    "groupBonus": 0.10,  # Game.groupCoinBonus (kept on coins)
    "boostCap": 2.00,  # x2 Coins pass (+1) and timed coins2x (+1) are additive: at most x3
}

# Config/Rewards.luau (coin rewards in minutes of income)
DAILY = [
    dict(coinsMinutes=2),
    dict(coinsMinutes=3),
    dict(coinsMinutes=4),
    dict(coinsMinutes=5, boost="coins2x", boostSeconds=600),
    dict(coinsMinutes=6),
    dict(coinsMinutes=8),
    dict(coinsMinutes=12, boost="luckyTide", boostSeconds=900, potBait=1),
]
STREAK_PER_DAY = 0.02
STREAK_CAP = 0.30
PLAYTIME = [  # per session (template Rewards.playtime; claimed once per session)
    dict(minutes=5, coinsMinutes=1),
    dict(minutes=10, coinsMinutes=1),
    dict(minutes=15, coinsMinutes=2),
    dict(minutes=25, boost="coins2x", boostSeconds=600),
    dict(minutes=40, coinsMinutes=3),
    dict(minutes=60, coinsMinutes=5),
]

# Config/TidePots.luau (new)
TIDE_POTS = {
    "fillCapHours": 8,
    "coinsMinutesPerHour": 0.5,  # one fish an hour, each worth about half a minute of active income
    "baseSlots": 1,  # the free pot placed at onboarding step 10 (about minute 9)
    "slotTwoUnlock": "lantern_reef",
    "placeSeconds": 540,
    "baitExtraFish": 2,
}

# Player models (Config/Economy.luau playerModels). Template: casual 10x1, typical 20x2, paying 30x3.
MODELS = {
    "casual": dict(label="Casual free", sessionMin=10, sessionsPerDay=1, sameDayGapHours=0,
                   reel=0.85, idle=0.25, travel=0.10, front=0.30, rainbow=0.02, stormAttend=0.6,
                   friends=0, helpers=3, helps=1, bootsCap=4, hatch={"driftwood_nest": 1, "reef_nest": 1,
                   "bluff_nest": 1, "thunder_nest": 1}, x2coins=False, paidLuck=0.0, extraSlots=0),
    "typical": dict(label="Typical", sessionMin=20, sessionsPerDay=2, sameDayGapHours=6,
                    reel=0.92, idle=0.12, travel=0.10, front=0.45, rainbow=0.05, stormAttend=0.9,
                    friends=1, helpers=3, helps=2, bootsCap=8, hatch={"driftwood_nest": 2, "reef_nest": 2,
                    "bluff_nest": 2, "thunder_nest": 2}, x2coins=False, paidLuck=0.0, extraSlots=0),
    "paying": dict(label="Paying", sessionMin=30, sessionsPerDay=3, sameDayGapHours=4,
                   reel=0.92, idle=0.12, travel=0.10, front=0.45, rainbow=0.05, stormAttend=0.9,
                   friends=2, helpers=3, helps=2, bootsCap=10, hatch={"driftwood_nest": 3, "reef_nest": 3,
                   "bluff_nest": 3, "thunder_nest": 3}, x2coins=False, paidLuck=0.0, extraSlots=0,
                   catalog=dict(x2Coins=True, luckyBobber=True, starterPack=True, dailyPacks=["coinCrate"],
                                tidePot3=True, palPouchPlus=True, autoReel=True, skyCalls=True)),
}
# T-0015: the paying model buys only what the accepted catalog sells (games/stormcatch/docs/catalog.md, T-0009):
# 2x Coins (active from the first bridge), Lucky Bobber, the Starter Pack and one Coin Crate a day from onboarding
# step 12, Third Tide Pot, Big Pal Pouch, Auto Reel and Sky Bell calls. No extra equip slots are sold.
# Variants for the fairness check (section B): a heavy spender (also one Coin Chest a day), passes only, and the
# T-0008 placeholder payer (template passes from second 0, +3 equip slots) for comparison.
PAYING_VARIANTS = {
    "heavy": dict(MODELS["paying"], label="Heavy spender (Crate and Chest every day)",
                  catalog=dict(MODELS["paying"]["catalog"], dailyPacks=["coinCrate", "coinChest"])),
    "passes_only": dict(MODELS["paying"], label="Passes only (no coin products)",
                        catalog=dict(MODELS["paying"]["catalog"], starterPack=False, dailyPacks=[])),
    "t0008": dict(MODELS["paying"], label="T-0008 placeholder payer (template passes from 0:00, +3 slots)",
                  x2coins=True, paidLuck=0.25, extraSlots=3, catalog=None),
}

# Catalog effects (games/stormcatch/docs/catalog.md section 3; prices are the catalog's and are not modelled)
CATALOG = {
    "x2Coins": dict(coinBoost=1.0, activeFromIsland=2),  # from the bridge to Lantern Reef; additive, cap x3
    "luckyBobber": dict(paidLuck=0.25),  # inside the +25% paid cap; 0 in Sea Fog (Sky cap)
    "starterPack": dict(coinsMinutes=30, boost="coins2x", boostSeconds=900),
    "packs": {"coinPouch": 15, "coinCrate": 60, "coinChest": 180},  # minutes of income
    "tidePot3": dict(extraSlots=1),
    "palPouchPlus": dict(capacity=50),  # no income effect
    "autoReel": dict(landed=0.70, reelFactor=2.0, weathers=("clear", "rainbow")),  # never used in active play
    "skyCallShare": 0.25,  # one call a cycle: 180 of 720 non-storm seconds, harbour only
}
STEP12_SECONDS = 600  # onboarding step 12 "Played 10 Minutes"; steps advance in order, so never before step 11
# "Minutes of income" basis for every grant (coin products, calendar, gifts, pots): permanent multipliers only.
MINUTES_BASIS = {"timedBoosts": False, "paidCoinPass": False}

GOAL_TARGETS = {  # casual free player, cumulative active minutes (brief T-0008; loop sketch 5.1-5.5, 12)
    "first_rod": (0.0, 1.25),
    "bridge_lantern_reef": (10.0, 12.0),
    "bridge_gustwhistle": (20.0, 30.0),
    "pebble_set": (20.0, 40.0),
    "new_tide_1": (20.0, 90.0),
}

SIM_MINUTES = 240
PHASES_MIN = list(range(0, 15))  # minute of the 15-minute storm clock at which the player joins

# =====================================================================================================
# 2. ODDS (mirrors Util/Odds.luau: luck multiplies luck-tier weights, then renormalise)
# =====================================================================================================


def table_entries(island_id: str | None, weather: str) -> list[tuple[str, str, float]]:
    """Species rows for fishing at an island in a weather. The eye uses Pebble Cove's island table."""
    rows: list[tuple[str, str, float]] = []
    src_island = "pebble_cove" if weather == "eye" else island_id
    for sid, tier, source, weight in SPECIES:
        if source == f"island:{src_island}":
            rows.append((sid, tier, weight))
    only = WEATHER[weather]["only"]
    if only:
        for sid, tier, source, weight in SPECIES:
            if source == f"weather:{only}":
                rows.append((sid, tier, weight))
    return rows


def special_entries(source: str) -> list[tuple[str, str, float]]:
    return [(sid, tier, w) for sid, tier, src, w in SPECIES if src == source]


def effective(rows: list[tuple[str, str, float]], luck: float) -> list[tuple[str, str, float]]:
    out = []
    total = 0.0
    for sid, tier, w in rows:
        if tier in LUCK_APPLIES:
            w = w * max(1.0, luck)
        out.append((sid, tier, w))
        total += w
    return [(sid, tier, w / total) for sid, tier, w in out]


def pick(outcomes: list[tuple[str, str, float]], roll: float) -> tuple[str, str, float]:
    target = roll
    for o in outcomes:
        target -= o[2]
        if target < 0:
            return o
    return outcomes[-1]


# =====================================================================================================
# 3. LUCK RULE
# =====================================================================================================


def luck_total(lure_level: int, companion_luck: float, friends: int, natural_sky: float, paid: float,
               timed: float) -> tuple[float, dict]:
    gear = min(LUCK["gearCap"], lure_level * UPGRADES["lure"]["effect"])
    comp = min(LUCK["companionCap"], companion_luck)
    social = min(LUCK["friendCap"], friends * LUCK["friendPerFriend"])
    sky = min(LUCK["skyCap"], natural_sky + min(LUCK["paidCap"], paid) + timed)
    raw = (1 + gear) * (1 + comp) * (1 + social) * (1 + sky)
    return min(LUCK["totalCap"], raw), dict(gear=gear, companions=comp, friends=social, sky=sky, raw=raw)


# =====================================================================================================
# 4. FISH VALUE AND CATCH TIMING
# =====================================================================================================


def mean_size_factor(sigma: float) -> float:
    # Expected value of clamp(exp(N(-s^2/2, s)), lo, hi) by numeric integration (no randomness).
    lo, hi = SIZE_CLAMP
    n = 4000
    total = 0.0
    weight = 0.0
    for i in range(n):
        z = -6 + 12 * (i + 0.5) / n
        pdf = math.exp(-z * z / 2)
        f = min(hi, max(lo, math.exp(-sigma * sigma / 2 + sigma * z)))
        total += f * pdf
        weight += pdf
    return total / weight


SIZE_MEAN = mean_size_factor(SIZE_SIGMA)
STORMBORN_SIZE_MEAN = mean_size_factor(STORMBORN_SIZE_SIGMA)


def mark_factor(weather: str, friends: int = 0) -> float:
    mark = WEATHER[weather]["mark"]
    if not mark:
        return 1.0
    _, chance, mult = mark
    if weather == "eye":
        chance = min(CHARGED_CAP, chance + CHARGED_PER_FRIEND * friends)
    return 1 + chance * (min(MARK_CAP, mult) - 1)


def ev_tier_value(probs: list[tuple[str, str, float]]) -> float:
    return sum(p * TIER_VALUE[tier] for _, tier, p in probs)


def landed_seconds(weather: str, reel_success: float, bite_scale: float = 1.0) -> float:
    w = WEATHER[weather]
    bite = (w["bite"][0] + w["bite"][1]) / 2 * bite_scale
    s = max(0.05, min(PERK_CAPS["reel"], reel_success + w["reel_delta"]))
    t_ok = w["cast"] + bite + w["reel"] + w["reveal"]
    t_fail = w["cast"] + bite + w["reel"] + FAILED_REEL_RECOVER_S
    return (s * t_ok + (1 - s) * t_fail) / s


def stormborn_ev_tier_value() -> float:
    return ev_tier_value(effective(special_entries("storm"), 1.0))


def land_seconds(helpers: int) -> float:
    return STORM["soloLandSeconds"] / (1 + STORM["helperSpeedup"] * helpers)


# =====================================================================================================
# 5. PACING SIMULATION
# =====================================================================================================


def upgrade_cost(key: str, level: int) -> float:
    d = UPGRADES[key]
    return math.floor(d["baseCost"] * d["costGrowth"] ** level + 0.5)


def new_tide_cost(tides: int) -> float:
    return math.floor(ECONOMY["newTideBaseCost"] * ECONOMY["newTideCostGrowth"] ** tides + 0.5)


def new_tide_multiplier(tides: int) -> float:
    return 1 + ECONOMY["newTideMultiplierPerTide"] * min(tides, ECONOMY["maxNewTides"])


def nest_ev_bonus(nest: dict) -> float:
    total = sum(w for _, w in NEST_ENTRIES)
    return sum(w / total * COMPANION_COIN_BONUS[t] * nest["scale"] for t, w in NEST_ENTRIES)


SETS = {
    "pebble_cove": [s[0] for s in SPECIES if s[2] == "island:pebble_cove"],
    "lantern_reef": [s[0] for s in SPECIES if s[2] == "island:lantern_reef"],
    "gustwhistle_bluffs": [s[0] for s in SPECIES if s[2] == "island:gustwhistle_bluffs"],
    "thunderhead_point": [s[0] for s in SPECIES if s[2] == "island:thunderhead_point"],
    "rain": [s[0] for s in SPECIES if s[2] == "weather:showers"],
    "fog": [s[0] for s in SPECIES if s[2] == "weather:fog"],
    "gusts": [s[0] for s in SPECIES if s[2] == "weather:gusts"],
    "stormborn": [s[0] for s in SPECIES if s[2] == "storm"],
}


def set_complete_prob(lam: dict, ids: list[str]) -> float:
    p = 1.0
    for sid in ids:
        p *= 1 - math.exp(-lam.get(sid, 0.0))
    return p


class Player:
    def __init__(self, model: dict, phase_min: int, called_front_share: float = 0.0,
                 include_rewards: bool = True, track_species: bool = True, continuous: bool = True):
        self.m = dict(model)
        self.day_len = model["sessionMin"] * model["sessionsPerDay"] * 60  # play seconds per play-day
        self.cat = self.m.get("catalog")
        self.step12_t: int | None = None
        self.last_pack_day = -1
        self.robux_coins = 0.0
        # continuous=True: one long first session (template simulatePacing); return sources (later daily
        # rewards, Tide Pots) are left out because they depend on when the player comes back, not on play time.
        self.continuous = continuous
        if continuous:
            self.m["sessionMin"] = 10 ** 6
        self.phase = phase_min * 60
        self.cf_share = called_front_share  # share of non-storm time a D6 Called Front is active
        self.cf_share_base = called_front_share
        self.rewards = include_rewards
        self.track = track_species
        self.t = 0
        self.coins = 0.0
        self.lv = {"rod": 0, "lure": 0, "boots": 0, "pal_pouch": 0}
        self.islands = 1
        self.tides = 0
        self.companions: list[float] = []
        self.hatches = {n["id"]: 0 for n in NESTS}
        self.lam: dict[str, float] = {}
        self.sets_done: set[str] = set()
        self.events: dict[str, float] = {}
        self.purchases: list[float] = []
        self.boost_until = {"coins2x": -1, "luckyTide": -1}
        self.claimed: set[int] = set()
        self.session = 0
        self.pot_bait = 0
        self.income_log: list[tuple[int, float]] = []
        self.storm_coins = 0.0
        self.total_coins = 0.0
        self.passive_coins = 0.0
        self.reward_coins = 0.0
        self.spend: dict[str, float] = {}
        self.cache: dict = {}

    # ----- derived stats -----
    def island(self) -> dict:
        return ISLANDS[self.islands - 1]

    def best_mult(self) -> float:
        return self.island()["mult"]

    def walk(self) -> float:
        return BASE_WALK_SPEED + self.lv["boots"] * UPGRADES["boots"]["effect"]

    def slots(self) -> int:
        return BASE_COMPANION_SLOTS + self.m["extraSlots"]

    def companion_coin(self) -> float:
        best = sorted(self.companions, reverse=True)[: self.slots()]
        return min(COIN["companionCap"], sum(best))

    def pass_boost(self) -> float:
        if self.m["x2coins"]:
            return 1.0
        if self.cat and self.cat.get("x2Coins") and self.islands >= CATALOG["x2Coins"]["activeFromIsland"]:
            return CATALOG["x2Coins"]["coinBoost"]
        return 0.0

    def paid_luck(self) -> float:
        if self.cat and self.cat.get("luckyBobber") and self.step12_t is not None:
            return CATALOG["luckyBobber"]["paidLuck"]
        return self.m["paidLuck"]

    def coin_mult(self, permanent: bool = False) -> float:
        rod = UPGRADES["rod"]["effect"] ** self.lv["rod"]
        journal = COIN["journalSetBonus"] * len(self.sets_done)
        day = self.session // self.m["sessionsPerDay"] + 1
        streak = min(STREAK_CAP, STREAK_PER_DAY * (day - 1)) if self.rewards else 0.0
        bonus = min(COIN["bonusCap"], journal + streak)
        timed = 1.0 if self.boost_until["coins2x"] > self.t else 0.0
        pass_b = self.pass_boost()
        if permanent:
            timed = timed if MINUTES_BASIS["timedBoosts"] else 0.0
            pass_b = pass_b if MINUTES_BASIS["paidCoinPass"] else 0.0
        boost = min(COIN["boostCap"], pass_b + timed)
        return rod * (1 + self.companion_coin()) * (1 + bonus) * (1 + boost) * new_tide_multiplier(self.tides)

    def luck(self, weather: str, called: bool, permanent: bool = False) -> float:
        natural = WEATHER[weather]["sky_luck"]
        paid = self.paid_luck() + (LUCK["calledFront"] if called else 0.0)
        timed = LUCK["luckyTide"] if self.boost_until["luckyTide"] > self.t else 0.0
        friends = self.m["friends"]
        if permanent:  # the minutes-of-income basis: Lure and owned luck passes, never friends or timed luck
            timed, friends = 0.0, 0
        return luck_total(self.lv["lure"], 0.0, friends, natural, paid, timed)[0]

    def minutes_basis(self) -> float:
        """Coins in one 'minute of income' for every grant: best island, Clear, permanent multipliers only
        (Rod, companions, bonus, New Tide, Lure and owned luck passes); no timed boosts, no friends, and the
        2x Coins pass only if MINUTES_BASIS['paidCoinPass'] (T-0015 answer to catalog question 1)."""
        isl = self.island()
        _, ev = self.table(isl["id"], "clear", self.luck("clear", False, permanent=True))
        return (self.catch_value(isl["mult"], "clear", ev) * self.coin_mult(permanent=True)
                * ECONOMY["assumedCatchesPerMinute"])

    def table(self, island_id: str, weather: str, luck: float):
        key = (island_id, weather, round(luck, 4))
        hit = self.cache.get(key)
        if hit is None:
            probs = effective(table_entries(island_id, weather), luck)
            hit = (probs, ev_tier_value(probs))
            self.cache[key] = hit
        return hit

    def catch_value(self, island_mult: float, weather: str, ev_tier: float) -> float:
        w = WEATHER[weather]
        return (ECONOMY["baseCoinsPerCatch"] * ev_tier * island_mult * SIZE_MEAN * w["size"] * w["value"]
                * mark_factor(weather, self.m["friends"]))

    def income_per_minute_clear(self) -> float:
        """'Minutes of income' unit for rewards and pots: best island, clear water, assumed catch rate."""
        isl = self.island()
        _, ev = self.table(isl["id"], "clear", self.luck("clear", False))
        return self.catch_value(isl["mult"], "clear", ev) * self.coin_mult() * ECONOMY["assumedCatchesPerMinute"]

    # ----- one second of play -----
    def weather_mix(self) -> list[tuple[str, float, bool]]:
        """(weather, share of fishing time, under a D6 call). Calls go only into clear harbour time (GDD 4.10)."""
        if self.t < FRONTS_START_SECONDS:
            return [("clear", 1.0, False)]
        f, r = self.m["front"], self.m["rainbow"]
        mix = FRONT_MIX[self.island()["home"]]
        clear = 1 - f - r
        called = min(self.cf_share, clear) if self.island()["id"] == "pebble_cove" else 0.0
        out = [("clear", clear - called, False), ("rainbow", r, False)]
        out += [(w, f * share, False) for w, share in mix.items()]
        if called > 0:
            out.append(("showers", called, True))  # worst case: every call is Showers, the best coin weather
        return out

    def efficiency(self) -> float:
        return max(0.0, 1 - self.m["idle"] - self.m["travel"] * BASE_WALK_SPEED / self.walk())

    def add_species(self, probs, rate):
        if not self.track:
            return
        for sid, _, p in probs:
            self.lam[sid] = self.lam.get(sid, 0.0) + rate * p

    def step(self) -> None:
        t = self.t
        if t < 18:
            self.t += 1
            return
        if t == 18:  # scripted first catch
            self.gain(ECONOMY["firstCatchCoins"])
            self.reward_coins += ECONOMY["firstCatchCoins"]
            self.lam["pebble_minnow"] = math.inf
            self.t += 1
            return
        if t == SCRIPTED_RAIN_RARE_SECONDS:
            isl = self.island()
            v = (ECONOMY["baseCoinsPerCatch"] * TIER_VALUE["Rare"] * isl["mult"] * 1.5) * self.coin_mult()
            self.gain(v)
            self.lam["pitterpike"] = math.inf
        wall = self.phase + t
        in_storm = (wall % STORM["periodSeconds"]) < STORM["durationSeconds"]
        storm_sec = wall % STORM["periodSeconds"]
        isl = self.island()
        mult = self.coin_mult()
        eff = self.efficiency()
        income = 0.0
        if in_storm:
            attend = self.m["stormAttend"]
            travel = STORM["travelSecondsByIsland"][isl["id"]] * BASE_WALK_SPEED / self.walk()
            # the share of the storm not at the eye is light rain on the player's island (treated as clear)
            luck_c = self.luck("clear", False)
            probs_c, ev_c = self.table(isl["id"], "clear", luck_c)
            rate_c = (1 - attend) * eff / landed_seconds("clear", self.m["reel"])
            income += rate_c * self.catch_value(isl["mult"], "clear", ev_c) * mult
            self.add_species(probs_c, rate_c)
            if storm_sec >= travel:
                help_time = self.m["helps"] * land_seconds(self.m["helpers"])
                eye_share = max(0.0, 1 - help_time / max(1.0, STORM["durationSeconds"] - travel))
                luck_e = self.luck("eye", False)
                probs_e, ev_e = self.table("pebble_cove", "eye", luck_e)
                hook = self.effective_hook(travel)
                t_catch = landed_seconds("eye", self.m["reel"]) + hook * land_seconds(self.m["helpers"])
                rate_e = attend * eye_share * (1 - self.m["idle"]) / t_catch
                normal = (1 - hook) * self.catch_value(isl["mult"], "eye", ev_e)
                sb = hook * self.stormborn_value(isl["mult"])
                inc = rate_e * (normal + sb) * mult
                income += inc
                self.storm_coins += inc
                self.add_species(probs_e, rate_e * (1 - hook))
                if self.track:
                    for sid, _, p in effective(special_entries("storm"), 1.0):
                        self.lam[sid] = self.lam.get(sid, 0.0) + rate_e * hook * p
            if storm_sec == STORM["durationSeconds"] - 1:  # helper shares minted at the end of the storm
                shares = min(STORM["helperSharesCapPerStorm"], self.m["helps"])
                inc = attend * shares * STORM["helperShare"] * self.stormborn_value(isl["mult"]) * mult
                income += inc
                self.storm_coins += inc
        else:
            for weather, frac, called in self.weather_mix():
                if frac <= 0:
                    continue
                lk = self.luck(weather, called)
                probs, ev = self.table(isl["id"], weather, lk)
                rate = frac * eff / landed_seconds(weather, self.m["reel"])
                income += rate * self.catch_value(isl["mult"], weather, ev) * mult
                self.add_species(probs, rate)
        self.gain(income)
        if t % 60 == 0:
            self.income_log.append((t, income * 60))
        self.t += 1

    def eye_bites_per_storm(self, travel: float) -> float:
        help_time = self.m["helps"] * land_seconds(self.m["helpers"])
        eye_seconds = max(0.0, STORM["durationSeconds"] - travel - help_time) * (1 - self.m["idle"])
        return eye_seconds / landed_seconds("eye", self.m["reel"])

    def effective_hook(self, travel: float) -> float:
        """Per-bite hook chance after the cap of one Stormborn per player per storm (expected value)."""
        h = STORM["stormbornHookChance"]
        n = self.eye_bites_per_storm(travel)
        if n <= 0:
            return 0.0
        return (1 - (1 - h) ** n) / n

    def stormborn_value(self, island_mult: float) -> float:
        return (ECONOMY["baseCoinsPerCatch"] * stormborn_ev_tier_value() * STORM["stormbornValueFactor"]
                * STORMBORN_SIZE_MEAN * island_mult * mark_factor("eye", self.m["friends"]))

    def gain(self, v: float) -> None:
        self.coins += v
        self.total_coins += v

    # ----- sessions, rewards, pots -----
    def session_tick(self) -> None:
        sess_len = self.m["sessionMin"] * 60
        sess_idx = self.t // sess_len
        sess_t = self.t - sess_idx * sess_len
        if sess_idx != self.session:
            self.session = sess_idx
            self.claimed = set()
            if self.rewards:
                new_day = sess_idx % self.m["sessionsPerDay"] == 0
                if new_day:
                    day = sess_idx // self.m["sessionsPerDay"]
                    d = DAILY[day % 7]
                    self.reward(d)
                # pots placed last session are collected now
                if self.t >= TIDE_POTS["placeSeconds"]:
                    hours = TIDE_POTS["fillCapHours"] if new_day else min(TIDE_POTS["fillCapHours"],
                                                                           self.m["sameDayGapHours"])
                    slots = TIDE_POTS["baseSlots"] + (1 if self.islands >= 2 else 0)
                    if self.cat and self.cat.get("tidePot3") and self.islands >= 2:
                        slots += CATALOG["tidePot3"]["extraSlots"]
                    fish = hours * slots + self.pot_bait * TIDE_POTS["baitExtraFish"]
                    self.pot_bait = 0
                    v = fish * TIDE_POTS["coinsMinutesPerHour"] * self.minutes_basis()
                    self.gain(v)
                    self.passive_coins += v
        if self.rewards:
            for i, g in enumerate(PLAYTIME):
                if i not in self.claimed and sess_t >= g["minutes"] * 60 and g["minutes"] < self.m["sessionMin"]:
                    self.claimed.add(i)
                    self.reward(g)
        # day-1 reward on the very first second
        if self.rewards and self.t == 0:
            self.reward(DAILY[0])
        self.catalog_tick()

    def catalog_tick(self) -> None:
        """Catalog purchases (T-0015). Everything is listed from onboarding step 12, which follows step 11
        (the first bridge), so no product can move a first bridge."""
        if not self.cat:
            return
        if self.step12_t is None and self.islands >= 2 and self.t >= STEP12_SECONDS:
            self.step12_t = self.t
            self.events.setdefault("step12", self.t)
            if self.cat.get("skyCalls"):
                self.cf_share = max(self.cf_share_base, CATALOG["skyCallShare"])
            if self.rewards and self.cat.get("starterPack"):
                sp = CATALOG["starterPack"]
                v = sp["coinsMinutes"] * self.minutes_basis()
                self.gain(v)
                self.robux_coins += v
                self.boost_until[sp["boost"]] = max(self.boost_until[sp["boost"]], self.t) + sp["boostSeconds"]
        if self.step12_t is not None and self.rewards and self.cat.get("dailyPacks"):
            day = self.t // self.day_len
            if day > self.last_pack_day:
                self.last_pack_day = day
                for pack in self.cat["dailyPacks"]:
                    v = CATALOG["packs"][pack] * self.minutes_basis()
                    self.gain(v)
                    self.robux_coins += v
                    self.events.setdefault(f"pack_day{day}_{pack}", self.t)

    def reward(self, r: dict) -> None:
        if r.get("coinsMinutes"):
            v = r["coinsMinutes"] * self.minutes_basis()
            self.gain(v)
            self.reward_coins += v
        if r.get("boost"):
            self.boost_until[r["boost"]] = self.t + r["boostSeconds"]
        if r.get("potBait"):
            self.pot_bait += r["potBait"]

    # ----- purchases -----
    def next_goal(self) -> tuple[str, float]:
        if self.islands < len(ISLANDS):
            nxt = ISLANDS[self.islands]
            if self.tides >= nxt["tides"]:
                return f"bridge:{nxt['id']}", nxt["gate"]
        req = [i["id"] for i in ISLANDS].index(ECONOMY["newTideRequiresIsland"]) + 1
        if self.islands >= req and self.tides < ECONOMY["maxNewTides"]:
            return "new_tide", new_tide_cost(self.tides)
        return "none", math.inf

    def normal_rate(self) -> float:
        """Coins per minute from ordinary (non-storm) fishing at the current island, current state."""
        isl = self.island()
        eff = self.efficiency()
        mult = self.coin_mult()
        total = 0.0
        for weather, frac, called in self.weather_mix():
            if frac <= 0:
                continue
            _, ev = self.table(isl["id"], weather, self.luck(weather, called))
            total += frac * eff / landed_seconds(weather, self.m["reel"]) * self.catch_value(isl["mult"], weather, ev)
        return total * 60 * mult

    def candidates(self) -> list[tuple[float, str]]:
        cands = []
        for key, d in UPGRADES.items():
            lvl = self.lv[key]
            if lvl >= d["maxLevel"]:
                continue
            if key == "boots" and lvl >= self.m["bootsCap"]:
                continue
            if key == "pal_pouch" and self.islands < 2:
                continue
            if d["revealSeconds"] is not None and self.t < d["revealSeconds"]:
                continue
            cands.append((upgrade_cost(key, lvl), key))
        nest = next(n for n in NESTS if n["island"] == self.island()["id"])
        if self.t >= nest["revealSeconds"] and self.hatches[nest["id"]] < self.m["hatch"][nest["id"]]:
            cands.append((nest["price"], "nest:" + nest["id"]))
        return cands

    def gain_of(self, key: str) -> float:
        """Income per minute added by a candidate purchase (best-return-per-coin buyer)."""
        before = self.normal_rate()
        if key.startswith("nest:"):
            nid = key[5:]
            self.companions.append(nest_ev_bonus(next(n for n in NESTS if n["id"] == nid)))
            after = self.normal_rate()
            self.companions.pop()
        else:
            self.lv[key] += 1
            after = self.normal_rate()
            self.lv[key] -= 1
        return after - before

    def apply(self, key: str, cost: float) -> None:
        self.coins -= cost
        cat = "nests" if key.startswith("nest:") else key
        self.spend[cat] = self.spend.get(cat, 0.0) + cost
        self.purchases.append(self.t)
        if key.startswith("nest:"):
            nid = key[5:]
            self.hatches[nid] += 1
            self.companions.append(nest_ev_bonus(next(n for n in NESTS if n["id"] == nid)))
            self.events.setdefault("first_nest", self.t)
        else:
            self.lv[key] += 1
            if key == "rod":
                self.events.setdefault("first_rod", self.t)
            if key == "lure" and self.lv[key] == 7:
                self.events.setdefault("lure_7", self.t)
            if key in ("lure", "boots"):
                self.events.setdefault("second_line", self.t)

    def buy(self) -> None:
        if self.t < ECONOMY["shopOpensAtSeconds"]:
            return
        for _ in range(60):
            goal, cost = self.next_goal()
            if self.coins >= cost:
                self.coins -= cost
                self.purchases.append(self.t)
                cat = "bridges" if goal.startswith("bridge:") else "new_tide"
                self.spend[cat] = self.spend.get(cat, 0.0) + cost
                if goal.startswith("bridge:"):
                    self.islands += 1
                    self.events.setdefault(goal, self.t)
                else:
                    self.new_tide()
                continue
            cands = [(c, k) for c, k in self.candidates() if c <= self.coins and (cost - self.coins) > c]
            if not cands:
                return
            # guided moments first (onboarding steps 6 and 8): Rod 2, then the first nest once it is shown
            guided = [(c, k) for c, k in cands if (k == "rod" and "first_rod" not in self.events)
                      or (k.startswith("nest:") and "first_nest" not in self.events)]
            if guided:
                c, key = guided[0]
            else:
                c, key = max(cands, key=lambda ck: self.gain_of(ck[1]) / ck[0])
                if self.gain_of(key) <= 0:
                    return
            self.apply(key, c)

    def new_tide(self) -> None:
        pre = self.coin_rate_estimate()
        self.tides += 1
        self.events.setdefault(f"new_tide_{self.tides}", self.t)
        self.events.setdefault(f"pre_tide_rate_{self.tides}", pre)
        self.coins = 0.0
        for key, d in UPGRADES.items():
            if d["resetsOnNewTide"]:
                self.lv[key] = 0

    def coin_rate_estimate(self) -> float:
        return self.income_per_minute_clear()

    def check_sets(self) -> None:
        if not self.track:
            return
        for name, ids in SETS.items():
            if name not in self.sets_done and set_complete_prob(self.lam, ids) >= 0.5:
                self.sets_done.add(name)
                self.events.setdefault(f"set:{name}", self.t)

    def run(self, minutes: int, stop_after_tides: int | None = None) -> "Player":
        end = minutes * 60
        while self.t < end:
            self.session_tick()
            self.step()
            self.buy()
            if self.t % 10 == 0:
                self.check_sets()
            if self.tides >= 1 and "regain_1" not in self.events and self.t > self.events["new_tide_1"]:
                if self.coin_rate_estimate() >= self.events["pre_tide_rate_1"]:
                    self.events["regain_1"] = self.t
            if stop_after_tides is not None and self.tides >= stop_after_tides:
                break
        return self


# =====================================================================================================
# 6. REPORT HELPERS
# =====================================================================================================

OUT: list[str] = []


def out(s: str = "") -> None:
    OUT.append(s)


def fmt_min(x: float | None) -> str:
    if x is None or x != x:
        return "-"
    return f"{x:.1f}"


def short(n: float) -> str:
    if n is None or n != n:
        return "-"
    if n == math.inf:
        return "inf"
    a = abs(n)
    for div, suf in ((1e12, "T"), (1e9, "B"), (1e6, "M"), (1e3, "K")):
        if a >= div:
            return f"{n / div:.2f}".rstrip("0").rstrip(".") + suf
    if a >= 100:
        return f"{n:.0f}"
    return f"{n:.3g}"


def pct(p: float) -> str:
    if p >= 0.01:
        return f"{p * 100:.2f}%"
    if p >= 0.0001:
        return f"{p * 100:.3f}%"
    return f"{p * 100:.5f}%"


def table(header: list[str], rows: list[list[str]]) -> None:
    out("| " + " | ".join(header) + " |")
    out("|" + " --- |" * len(header))
    for r in rows:
        out("| " + " | ".join(r) + " |")
    out()


def median_time(lam_series: list[tuple[int, float]], target: float = math.log(2)) -> float | None:
    prev_t, prev_l = 0, 0.0
    for t, l in lam_series:
        if l >= target:
            if l == math.inf or l == prev_l:
                return t / 60
            frac = (target - prev_l) / (l - prev_l)
            return (prev_t + frac * (t - prev_t)) / 60
        prev_t, prev_l = t, l
    return None


# =====================================================================================================
# 7. MAIN
# =====================================================================================================


def run_model(name: str, phase: int, **kw) -> tuple[Player, dict]:
    p = Player(MODELS[name], phase, **kw)
    series: dict[str, list[tuple[int, float]]] = {tier: [] for tier in TIERS}
    end = SIM_MINUTES * 60
    while p.t < end:
        p.session_tick()
        p.step()
        p.buy()
        if p.t % 10 == 0:
            p.check_sets()
            if p.track:
                by_tier = {tier: 0.0 for tier in TIERS}
                for sid, lam in p.lam.items():
                    by_tier[SPECIES_TIER[sid]] += lam
                for tier in TIERS:
                    series[tier].append((p.t, by_tier[tier]))
        if p.tides >= 1 and "regain_1" not in p.events and p.t > p.events["new_tide_1"]:
            if p.coin_rate_estimate() >= p.events["pre_tide_rate_1"]:
                p.events["regain_1"] = p.t
    return p, series


GOALS = [
    ("first_rod", "1. First rod upgrade (Rod 2)"),
    ("bridge:lantern_reef", "2. Bridge to Lantern Reef"),
    ("bridge:gustwhistle_bluffs", "3. Bridge to Gustwhistle Bluffs"),
    ("set:pebble_cove", "4. First island set complete (Pebble Cove 8/8, median)"),
    ("new_tide_1", "5. New Tide (first rebirth)"),
]
GOAL_TARGET_KEY = {"first_rod": "first_rod", "bridge:lantern_reef": "bridge_lantern_reef",
                   "bridge:gustwhistle_bluffs": "bridge_gustwhistle", "set:pebble_cove": "pebble_set",
                   "new_tide_1": "new_tide_1"}
EXTRA = [
    ("second_line", "Second upgrade line (first Lure or Boots)"),
    ("first_nest", "First nest (Driftwood)"),
    ("lure_7", "Lure level 7 (+28% luck, above the D6 +25%)"),
    ("set:rain", "Rain set 3/3 (median)"),
    ("set:lantern_reef", "Lantern Reef set 8/8 (median)"),
    ("bridge:thunderhead_point", "Bridge to Thunderhead Point"),
    ("new_tide_2", "New Tide 2"),
]


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--out", help="also write the report to this path")
    ap.add_argument("--timeline", help="print a 2.5-minute timeline for one model (casual, typical, paying)")
    ap.add_argument("--phase", type=int, default=7, help="join minute for --timeline")
    ap.add_argument("--quick", action="store_true", help="tuning aid: 3 join minutes instead of 15")
    args = ap.parse_args()
    if args.quick:
        PHASES_MIN[:] = [0, 5, 10]
    if args.timeline:
        print_timeline(args.timeline, args.phase)
        return

    out("# Reel the Storm economy model output")
    out()
    out("Generated by games/stormcatch/docs/models/economy_model.py (T-0008, Economist). Deterministic:")
    out(f"expected-value pacing, 1 s steps, {SIM_MINUTES} min of active play, averaged over the {len(PHASES_MIN)} "
        "possible join minutes of the 15-minute Great Storm clock (min-max in brackets). Monte Carlo checks use")
    out("random.Random(20261025).")
    out()

    # ---------------------------------------------------------------- catch timing
    out("## A. Catch timing and value per weather (Config/Weather.luau)")
    out()
    rows = []
    for w, d in WEATHER.items():
        bite = (d["bite"][0] + d["bite"][1]) / 2
        mark = d["mark"]
        rows.append([w, f"{d['bite'][0]}-{d['bite'][1]} (mean {bite:.2f})", f"{d['cast'] + bite + d['reel'] + d['reveal']:.2f}",
                     f"{60 / landed_seconds(w, 0.85):.2f}", f"{60 / landed_seconds(w, 0.92):.2f}",
                     f"{d['reel_delta']:+.2f}", f"x{d['size']:.2f}", f"x{d['value']:.1f}",
                     f"{mark[0]} {mark[1]:.0%} x{mark[2]}" if mark else "-", f"x{mark_factor(w):.3f}",
                     f"+{d['sky_luck']:.0%}"])
    table(["Weather", "Bite wait s", "Cycle s (landed)", "Catches/min @85% reel", "Catches/min @92% reel",
           "Reel success", "Size", "Value", "Mark (one per fish)", "Mark EV", "Sky luck"], rows)
    out(f"Mean size factor (clear) {SIZE_MEAN:.4f}; Stormborn {STORMBORN_SIZE_MEAN:.4f}. Failed reel costs the cast,"
        f" the wait, the reel and {FAILED_REEL_RECOVER_S:.0f} s.")
    out()

    # coins per minute relative to clear at Pebble Cove, base luck, typical reel
    rows = []
    base_ev = ev_tier_value(effective(table_entries("lantern_reef", "clear"), 1.0))
    base_rate = 60 / landed_seconds("clear", 0.92)
    for w in ("clear", "showers", "fog", "gusts", "rainbow"):
        lk = luck_total(0, 0, 0, WEATHER[w]["sky_luck"], 0, 0)[0]
        probs = effective(table_entries("lantern_reef", w), lk)
        ev = ev_tier_value(probs) * WEATHER[w]["size"] * WEATHER[w]["value"] * mark_factor(w)
        rate = 60 / landed_seconds(w, 0.92)
        rare_up = sum(p for _, tier, p in probs if tier in LUCK_APPLIES)
        rows.append([w, f"{rate:.2f}", f"{ev / base_ev:.2f}", f"{rate * ev / (base_rate * base_ev):.2f}",
                     pct(rare_up)])
    table(["Weather (Lantern Reef, Lure 0, typical reel)", "Catches/min", "Value per catch vs clear",
           "Coins per minute vs clear", "Rare-or-better per catch"], rows)

    # ---------------------------------------------------------------- pacing
    out("## B. Pacing: time to goal by player model (cumulative active minutes)")
    out()
    results: dict[str, list[Player]] = {}
    series_by: dict[str, list[dict]] = {}
    for name in MODELS:
        runs = [run_model(name, ph) for ph in PHASES_MIN]
        results[name] = [r[0] for r in runs]
        series_by[name] = [r[1] for r in runs]

    def stat(name: str, key: str):
        vals = [p.events.get(key) for p in results[name]]
        vals = [v / 60 for v in vals if v is not None]
        if len(vals) < len(PHASES_MIN):
            return None, None, None, len(vals)
        return sum(vals) / len(vals), min(vals), max(vals), len(vals)

    def cell(name: str, key: str) -> str:
        mean, lo, hi, n = stat(name, key)
        if mean is None:
            return f"> {SIM_MINUTES}" if n == 0 else f"only {n}/{len(PHASES_MIN)} runs by {SIM_MINUTES}"
        m = MODELS[name]
        sess = math.ceil(mean / m["sessionMin"] + 1e-9)
        day = math.ceil(sess / m["sessionsPerDay"])
        if key == "first_rod":
            return f"{mean * 60:.0f} s [{lo * 60:.0f}-{hi * 60:.0f}] (s1)"
        return f"{mean:.1f} [{lo:.1f}-{hi:.1f}] (s{sess}, d{day})"

    rows = []
    for key, label in GOALS:
        lo_t, hi_t = GOAL_TARGETS[GOAL_TARGET_KEY[key]]
        rows.append([label] + [cell(n, key) for n in MODELS] + [f"{lo_t:g}-{hi_t:g} min"])
    table(["Goal"] + [MODELS[n]["label"] for n in MODELS] + ["Target (casual free)"], rows)
    out("Cells: mean minutes [fastest-slowest join minute] (session index, day index). Session and day use the")
    out("model's session length and sessions per day (casual 10x1, typical 20x2, paying 30x3).")
    out()
    rows = []
    for key, label in EXTRA:
        rows.append([label] + [cell(n, key) for n in MODELS])
    table(["Other milestones"] + [MODELS[n]["label"] for n in MODELS], rows)

    # target checks
    out("### Target checks (casual free unless named)")
    out()
    checks = []
    m, lo, hi, _ = stat("casual", "first_rod")
    checks.append(("First rod upgrade about 60 s (under 75 s), every model",
                   all((stat(n, "first_rod")[2] or 99) * 60 <= 75 for n in MODELS), f"casual {m * 60:.0f} s, max {max((stat(n, 'first_rod')[2] or 0) * 60 for n in MODELS):.0f} s"))
    m, lo, hi, _ = stat("casual", "bridge:lantern_reef")
    checks.append(("Bridge to Lantern Reef at 10-12 min (brief target), inside 10-15 (DESIGN-03)",
                   lo >= 10 and hi <= 12.5, f"mean {m:.1f}, range {lo:.1f}-{hi:.1f}"))
    m, lo, hi, _ = stat("casual", "bridge:gustwhistle_bluffs")
    checks.append(("Bridge to Gustwhistle Bluffs at 20-30 min", lo >= 20 and hi <= 30, f"mean {m:.1f}, range {lo:.1f}-{hi:.1f}"))
    m, lo, hi, _ = stat("casual", "new_tide_1")
    checks.append(("New Tide 1 within 20-90 min (template Economy.spec)", m is not None and lo >= 20 and hi <= 90,
                   f"mean {fmt_min(m)}, range {fmt_min(lo)}-{fmt_min(hi)}"))
    mt, lot, hit, _ = stat("typical", "new_tide_1")
    checks.append(("Typical New Tide 1 within 30-60 min (vault key numbers)", mt is not None and lot >= 30 and hit <= 60,
                   f"mean {fmt_min(mt)}, range {fmt_min(lot)}-{fmt_min(hit)}"))
    ratios = []
    for key, _ in (GOALS[1], GOALS[2], GOALS[4]):  # the set goal is not purchasable
        c = stat("casual", key)[0]
        pv = stat("paying", key)[0]
        if c and pv:
            ratios.append(c / pv)
    in_band = all(2.0 <= r <= 4.0 for r in ratios[1:]) and 1.0 <= ratios[0] <= 4.0
    checks.append(("Paying faster than casual, within 2-4x on goals 2, 3 and 5 (goal 2 runs at free pace by "
                   "catalog design: nothing is sold before onboarding step 12, which follows the first bridge)",
                   ("PASS (goal 2 below 2x by design)" if ratios[0] < 2.0 else "PASS") if in_band else "CHECK",
                   ", ".join(f"{r:.2f}x" for r in ratios)))
    # max purchase gap in first hour, typical
    gaps = []
    for p in results["typical"]:
        pts = [0] + [t for t in p.purchases if t <= 3600]
        a, b = max(zip(pts, pts[1:]), key=lambda ab: ab[1] - ab[0])
        gaps.append(((b - a) / 60, b == p.events.get("new_tide_1")))
    long_gaps = [g for g in gaps if g[0] > 3.2]
    status = "PASS" if not long_gaps else (
        "NEAR (final save for New Tide 1 only)" if all(tide for _, tide in long_gaps) else "CHECK")
    checks.append(("No gap above about 3 min between purchases in the first hour (typical)", status,
                   f"worst gap {max(g for g, _ in gaps):.2f} min; over 3.2 min in {len(long_gaps)} of {len(gaps)} join "
                   f"minutes; mean worst {sum(g for g, _ in gaps) / len(gaps):.2f} min"))
    gaps_c = []
    for p in results["casual"]:
        pts = [0] + [t for t in p.purchases if t <= 1800]
        gaps_c.append(max((b - a) for a, b in zip(pts, pts[1:])) / 60)
    checks.append(("Next purchase 1-3 min away in the first 30 min (casual)", max(gaps_c) <= 3.2,
                   f"worst gap {max(gaps_c):.2f} min"))
    reg = []
    for p in results["typical"]:
        if "regain_1" in p.events:
            reg.append((p.events["regain_1"] - p.events["new_tide_1"]) / p.events["new_tide_1"])
    in_band = bool(reg) and 0.2 <= sum(reg) / len(reg) <= 0.4
    checks.append(("After New Tide 1, regain the pre-tide income in 1/4-1/3 of the original time (typical; "
                   "vault band assumes zones reset, islands stay here)",
                   "PASS" if in_band else "ARGUED DEVIATION",
                   (f"{sum(reg) / len(reg):.2f} of the original time; the tide's cost is carried by the cycle "
                    "length instead (section D)") if reg else "not reached"))
    rows = [[c, ok if isinstance(ok, str) else ("PASS" if ok else "CHECK"), note] for c, ok, note in checks]
    table(["Check", "Result", "Model value"], rows)

    # T-0015: paying variants against the catalog
    out("### Paying variants (T-0015): catalog purchases, continuous view, same join minutes")
    out()
    out("Paying = typical skill plus the catalog: 2x Coins from the first bridge; Lucky Bobber, the Starter Pack "
        "(30 min of income and a 15-minute coins2x) and one Coin Crate (60 min) a day from onboarding step 12; "
        "Third Tide Pot; Big Pal Pouch and Auto Reel owned (no income effect: Auto Reel is slower than reeling "
        "yourself, section N); a Sky Bell call every cycle (harbour only, so no effect once past Pebble Cove). "
        "Coin grants use the minutes-of-income basis " + ("with" if MINUTES_BASIS["paidCoinPass"] else "without")
        + " the 2x Coins pass and never timed boosts.")
    out()
    var_rows = []

    def variant_row(label: str, model: dict) -> None:
        ps = []
        for ph in PHASES_MIN:
            pl = Player(model, ph)
            end = SIM_MINUTES * 60
            while pl.t < end and "new_tide_1" not in pl.events:
                pl.session_tick()
                pl.step()
                pl.buy()
                if pl.t % 10 == 0:
                    pl.check_sets()
            ps.append(pl)
        cells = [label]
        rs = []
        for key, _ in (GOALS[1], GOALS[2], GOALS[4]):
            vals = [pl.events.get(key) for pl in ps]
            if any(v is None for v in vals):
                cells.append("-")
                continue
            mean = sum(vals) / len(vals) / 60
            c = stat("casual", key)[0]
            tv = stat("typical", key)[0]
            rs.append(c / mean)
            cells.append(f"{mean:.1f} [{min(vals) / 60:.1f}-{max(vals) / 60:.1f}] = {c / mean:.2f}x casual, "
                         f"{tv / mean:.2f}x typical")
        var_rows.append(cells)

    variant_row("Paying (catalog), the five-goal row", MODELS["paying"])
    for key in ("heavy", "passes_only", "t0008"):
        variant_row(PAYING_VARIANTS[key]["label"], PAYING_VARIANTS[key])
    keep = MINUTES_BASIS["paidCoinPass"]
    MINUTES_BASIS["paidCoinPass"] = not keep
    variant_row(f"Heavy spender, basis {'with' if not keep else 'without'} the 2x Coins pass (alternative)",
                PAYING_VARIANTS["heavy"])
    MINUTES_BASIS["paidCoinPass"] = keep
    table(["Payer", "Bridge to Lantern Reef (goal 2)", "Bridge to Gustwhistle (goal 3)", "New Tide 1 (goal 5)"],
          var_rows)

    # catch-only conservative run (Economy.spec analogue: no rewards, no pots)
    out("### Conservative run: catch income only (no daily, playtime, pot or journal-set rewards)")
    out()
    rows = []
    for name in MODELS:
        ps = [run_model(name, ph, include_rewards=False, track_species=False)[0] for ph in PHASES_MIN]
        def c2(key):
            vals = [p.events.get(key) for p in ps]
            if any(v is None for v in vals):
                return "-"
            vals = [v / 60 for v in vals]
            return f"{sum(vals) / len(vals):.1f} [{min(vals):.1f}-{max(vals):.1f}]"
        rows.append([MODELS[name]["label"], c2("bridge:lantern_reef"), c2("bridge:gustwhistle_bluffs"), c2("new_tide_1")])
    table(["Model", "Bridge to Lantern Reef", "Bridge to Gustwhistle", "New Tide 1"], rows)

    # return view: sessions, later daily rewards and Tide Pots included
    out("### Return view: the same goals with sessions, daily rewards and Tide Pots (play minutes, session, day)")
    out()
    ret: dict[str, list[Player]] = {}
    for name in MODELS:
        ret[name] = [run_model(name, ph, continuous=False)[0] for ph in PHASES_MIN]
    rows = []
    for key, label in GOALS[1:3] + [GOALS[4]] + [EXTRA[-2]]:
        row = [label]
        for name in MODELS:
            vals = [p.events.get(key) for p in ret[name]]
            if any(v is None for v in vals):
                row.append(f"> {SIM_MINUTES}")
                continue
            mean = sum(vals) / len(vals) / 60
            m = MODELS[name]
            sess = math.ceil(mean / m["sessionMin"] + 1e-9)
            row.append(f"{mean:.1f} [{min(vals) / 60:.1f}-{max(vals) / 60:.1f}] (s{sess}, d{math.ceil(sess / m['sessionsPerDay'])})")
        rows.append(row)
    table(["Goal"] + [MODELS[n]["label"] for n in MODELS], rows)
    out("Return sources arrive at the start of each session, so a goal close to a session end lands at the next")
    out("session's first second. The five-goal table above is the design commitment; this view is the upside.")
    out()
    out("### Where the coins come from (return view, first 240 play minutes, mean over join minutes)")
    out()
    rows = []
    for name in MODELS:
        ps = ret[name]
        tot = sum(p.total_coins for p in ps)
        st = sum(p.storm_coins for p in ps)
        pas = sum(p.passive_coins for p in ps)
        rew = sum(p.reward_coins for p in ps)
        rob = sum(p.robux_coins for p in ps)
        rows.append([MODELS[name]["label"], f"{(tot - st - pas - rew - rob) / tot:.1%}", f"{st / tot:.1%}",
                     f"{pas / tot:.1%}", f"{rew / tot:.1%}", f"{rob / tot:.1%}"])
    table(["Model", "Catches outside storms", "Great Storm (eye catches, Stormborn, helper shares)", "Tide Pots",
           "Calendar, playtime gifts, scripted first catch", "Robux coin products (Starter Pack, packs)"], rows)
    out("### Where the coins go (return view, first 240 play minutes, share of coins spent)")
    out()
    cats = ["rod", "lure", "boots", "pal_pouch", "nests", "bridges", "new_tide"]
    rows = []
    for name in MODELS:
        ps = ret[name]
        spent = {c: sum(p.spend.get(c, 0.0) for p in ps) for c in cats}
        tot_s = sum(spent.values())
        tot_g = sum(p.total_coins for p in ps)
        rows.append([MODELS[name]["label"]] + [f"{spent[c] / tot_s:.1%}" for c in cats]
                    + [f"{1 - tot_s / tot_g:.1%}"])
    table(["Model", "Rod", "Lure", "Boots", "Pal Pouch", "Nests", "Bridges", "New Tide", "Unspent at 240 min (share of earned)"], rows)
    out("New Tide also resets the Rod and Boots, so their coins are sunk twice over a tide.")
    out()

    # ---------------------------------------------------------------- upgrade curves
    out("## C. Upgrade cost curves (Config/Upgrades.luau)")
    out()
    levels = [0, 1, 2, 5, 10, 15, 20, 24, 30, 40, 60]
    rows = []
    for key, d in UPGRADES.items():
        rows.append([f"{d['name']} ({d['kind']}; {d['baseCost']} x {d['costGrowth']}^L; max {d['maxLevel']})"]
                    + [short(upgrade_cost(key, L)) if L < d["maxLevel"] else "-" for L in levels])
    table(["Upgrade"] + [f"L{L}" for L in levels], rows)
    out(f"Rod effect x{UPGRADES['rod']['effect']} coins per level: L10 x{1.14 ** 10:.2f}, L20 x{1.14 ** 20:.1f}, "
        f"L40 x{1.14 ** 40:.0f}, L60 x{short(1.14 ** 60)}, max L150 x{short(1.14 ** 150)}. "
        f"r/g = {1.28 / 1.14:.3f} (vault band 1.03-1.15).")
    out("Lure +4% luck per level (Gear category, cap +100% at L25). Boots +1 walk speed per level (16 -> 32).")
    out("Pal Pouch +10 companion capacity per level (60 -> 160); equip slots stay at 3 (GDD 4.4), so it adds no income.")
    out()

    # ---------------------------------------------------------------- islands and tides
    out("## D. Islands, bridges and New Tide (Config/Zones.luau, Config/Economy.luau)")
    out()
    rows = []
    for isl in ISLANDS:
        rows.append([isl["name"], short(isl["gate"]), f"x{isl['mult']}", isl["home"],
                     f"New Tide {isl['tides']}" if isl["tides"] else "-", isl["nest"]])
    table(["Island", "Bridge price", "Value multiplier", "Home weather", "Also needs", "Nest"], rows)
    rows = []
    for n in range(0, 12):
        rows.append([str(n + 1), short(new_tide_cost(n)), f"x{new_tide_multiplier(n + 1):.1f}"])
    table(["New Tide #", "Cost (coins)", "Coin multiplier after"], rows)

    # long run: tide cycle lengths for the typical model (rewards off for speed, conservative)
    out("### New Tide cycle lengths (typical model, catch income plus storms, no rewards, continuous play)")
    out()
    cyc = tide_cycles("typical", [1, 2, 3, 5, 8, 10, 11, 12, 15, 20, 25])
    rows = [[str(n), fmt_min(v[0]), fmt_min(v[1])] for n, v in cyc.items()]
    table(["New Tide #", "Minutes since previous tide", "Cumulative active hours"], rows)

    out("### Great Storm and Stormborn (Config/Weather.luau greatStorm)")
    out()
    rows = []
    rng_sb = random.Random(20261025)
    for name in ("casual", "typical"):
        m = MODELS[name]
        pl = Player(m, 0, track_species=False)
        for isl_id in ("pebble_cove", "gustwhistle_bluffs"):
            travel = STORM["travelSecondsByIsland"][isl_id]
            n = pl.eye_bites_per_storm(travel)
            p_hook = 1 - (1 - STORM["stormbornHookChance"]) ** n
            # storms to first hook with the 100-eye-bite pity (Monte Carlo, whole storms at the eye)
            trials, total = 20_000, 0
            for _ in range(trials):
                bites = storms = 0
                while True:
                    storms += 1
                    got = False
                    for _b in range(int(round(n))):
                        bites += 1
                        if bites >= STORM["stormbornPityEyeBites"] or rng_sb.random() < STORM["stormbornHookChance"]:
                            got = True
                            break
                    if got:
                        break
                total += storms
            rows.append([m["label"], isl_id, f"{travel} s", f"{n:.1f}", f"{p_hook:.0%}", f"{total / trials:.2f}",
                         f"{land_seconds(m['helpers']):.1f} s"])
    table(["Model", "Walks to the pier from", "Walk", "Eye bites per storm", "P(hook) per storm",
           "Storms to first hook (with pity)", "Land time with 3 helpers"], rows)
    out(f"Hook {STORM['stormbornHookChance']:.1%} per eye bite, at most {STORM['stormbornMaxPerStorm']} per player per storm, hard "
        f"pity at {STORM['stormbornPityEyeBites']} eye bites ({STORM['stormbornPityEyeBites'] * STORM['stormbornHookChance']:.1f}x the expected {1 / STORM['stormbornHookChance']:.0f}). Stormborn coin value = tier value x "
        f"{STORM['stormbornValueFactor']} x the player's best island multiplier; eye catches use Pebble Cove species at the "
        f"best island multiplier. Helper share {STORM['helperShare']:.0%} of the giant's value, at most "
        f"{STORM['helperSharesCapPerStorm']} paid helps per player per storm. Charged: 25% + 5% per friend helper, cap 50%, x3.")
    out()

    # ---------------------------------------------------------------- odds tables
    out("## E. Drop tables per island and weather (Config/Species.luau), base luck x1 except natural Sea Fog")
    out()
    out("Displayed odds = the same effective() function the server rolls with. Columns are what a player with")
    out("no Lure, companions or friends sees. Natural Sea Fog carries Sky luck +100% (Rare-and-up weights x2).")
    out()
    for isl in ISLANDS:
        out(f"### {isl['name']} (x{isl['mult']})")
        out()
        cols = ["clear", "showers", "fog", "gusts"]
        probs_by = {}
        for w in cols:
            lk = luck_total(0, 0, 0, WEATHER[w]["sky_luck"], 0, 0)[0]
            probs_by[w] = {sid: p for sid, _, p in effective(table_entries(isl["id"], w), lk)}
        ids = [sid for sid, _, _ in table_entries(isl["id"], "clear")]
        for w in ("showers", "fog", "gusts"):
            ids += [sid for sid, _, src, _ in SPECIES if src == f"weather:{w}"]
        rows = []
        for sid in ids:
            tier = SPECIES_TIER[sid]
            val = ECONOMY["baseCoinsPerCatch"] * TIER_VALUE[tier] * isl["mult"]
            weight = next(w for s, _, _, w in SPECIES if s == sid)
            rows.append([sid, tier, f"{weight:g}", short(val)] + [pct(probs_by[w][sid]) if sid in probs_by[w] else "-" for w in cols])
        sums = [f"{sum(probs_by[w].values()) * 100:.4f}%" for w in cols]
        rows.append(["**sum**", "", "", ""] + sums)
        table(["Species", "Tier", "Weight", "Base value (coins)", "Clear", "Showers", "Sea Fog", "Gusts"], rows)
    out("### Great Storm eye (Open Pier): Pebble Cove table at the player's best island value, plus Stormborn hooks")
    out()
    hook = STORM["stormbornHookChance"]
    rows = []
    for sid, tier, p in effective(table_entries(None, "eye"), 1.0):
        rows.append([sid, tier, pct(p * (1 - hook))])
    for sid, tier, p in effective(special_entries("storm"), 1.0):
        rows.append([sid, tier, pct(p * hook) + f" (= {hook:.1%} hook x {pct(p)})"])
    table(["Species", "Tier", "Chance per eye bite"], rows)
    out("### Aurora Night (weekly event table, base luck)")
    out()
    rows = [[sid, tier, pct(p)] for sid, tier, p in effective(special_entries("aurora"), 1.0)]
    table(["Species", "Tier", "Chance"], rows)

    # ---------------------------------------------------------------- time to see
    out("## F. Designed and modelled time-to-see per tier (median, cumulative active minutes)")
    out()
    design = {
        "Common": "first catch (scripted, 0:18)",
        "Uncommon": "<= 1.5 min",
        "Rare": "<= 3 min (scripted rain Rare at 2:00)",
        "Epic": "5-15 min",
        "Legendary": "20-45 min",
        "Mythic": "typical: first week (<= 280 min); casual: weeks",
        "Secret": "no promise (>= 30 h)",
    }
    rows = []
    for tier in TIERS:
        cells = []
        for name in MODELS:
            meds = []
            p90s = []
            for s in series_by[name]:
                meds.append(median_time(s[tier]))
                p90s.append(median_time(s[tier], math.log(10)))
            if all(v is not None for v in meds):
                txt = f"{sum(meds) / len(meds):.1f}"
                if all(v is not None for v in p90s):
                    txt += f" (p90 {sum(p90s) / len(p90s):.1f})"
                else:
                    txt += " (p90 > 240)"
            else:
                # extrapolate with the final hourly hazard rate
                ext = []
                for s in series_by[name]:
                    t_end, l_end = s[tier][-1]
                    t_prev, l_prev = s[tier][-361]
                    rate = (l_end - l_prev) / ((t_end - t_prev) / 60)
                    ext.append(t_end / 60 + (math.log(2) - l_end) / rate if rate > 0 else math.inf)
                v = sum(ext) / len(ext)
                txt = f"~{v:.0f} (extrapolated, {v / (MODELS[name]['sessionMin'] * MODELS[name]['sessionsPerDay']):.1f} play days)"
            cells.append(txt)
        rows.append([tier, design[tier]] + cells)
    table(["Tier", "Designed median"] + [MODELS[n]["label"] for n in MODELS], rows)
    out("Median = time when the expected number of catches of that tier reaches ln 2 (Poisson, exact for the")
    out("modelled catch rate); p90 = ln 10. Includes Stormborn hooks and weather-only species.")
    out()

    # ---------------------------------------------------------------- luck rule
    out("## G. Luck stacking rule and caps (Config/Economy.luau luck block)")
    out()
    out("luck = min(totalCap, (1 + Gear) x (1 + Companions) x (1 + Friends) x (1 + Sky));")
    out("Sky = min(skyCap, naturalWeather + min(paidCap, paid) + timed). Additive inside a category, multiplied across.")
    out()
    rows = [
        ["Gear", "Lure +4%/level", f"+{LUCK['gearCap']:.0%}", "earned"],
        ["Companions", "weather perks of equipped companions (in their weather)", f"+{LUCK['companionCap']:.0%}", "earned (nests are paid random items, D2)"],
        ["Friends", "+10% per friend in the server", f"+{LUCK['friendCap']:.0%}", "social"],
        ["Sky", "natural Sea Fog +100%; Lucky Tide (day 7) +25%; D6 Called Front +25%; any paid luck item",
         f"+{LUCK['skyCap']:.0%}; paid share at most +{LUCK['paidCap']:.0%}", "weather, timed and paid"],
        ["Total", "product of the four", f"x{LUCK['totalCap']:.0f}", ""],
    ]
    table(["Category", "Sources (additive inside)", "Cap", "Kind"], rows)
    scen = [
        ("New player, clear water", 0, 0, 0, 0.0, 0.0, 0.0),
        ("New player under a called Showers front (D6 bonus)", 0, 0, 0, 0.0, 0.25, 0.0),
        ("New player, natural Sea Fog", 0, 0, 0, 1.0, 0.0, 0.0),
        ("New player under a called Sea Fog (bonus capped: adds 0)", 0, 0, 0, 1.0, 0.25, 0.0),
        ("Lure 7, clear (casual after first session)", 7, 0, 0, 0.0, 0.0, 0.0),
        ("Lure 12, 1 friend, Lamp Moth in fog (typical, hour 1-2)", 12, 0.15, 1, 1.0, 0.0, 0.0),
        ("Max free: Lure 25, companions +50%, 5 friends, clear", 25, 0.5, 5, 0.0, 0.0, 0.0),
        ("Max free in natural fog (total cap binds)", 25, 0.5, 5, 1.0, 0.0, 0.0),
        ("Max paying: max free + paid luck item + D6 bonus (paid cap +25%)", 25, 0.5, 5, 0.0, 0.5, 0.0),
        ("Max paying in natural fog (cap binds; same as free)", 25, 0.5, 5, 1.0, 0.5, 0.0),
    ]
    rows = []
    for label, lure, comp, fr, nat, paid, timed in scen:
        tot, parts = luck_total(lure, comp, fr, nat, paid, timed)
        rows.append([label, f"+{parts['gear']:.0%}", f"+{parts['companions']:.0%}", f"+{parts['friends']:.0%}",
                     f"+{parts['sky']:.0%}", f"x{parts['raw']:.3f}", f"x{tot:.3f}"])
    table(["Scenario", "Gear", "Companions", "Friends", "Sky", "Raw product", "Applied"], rows)

    # what luck does to odds on a few tables
    out("### Luck applied to Thunderhead Point clear water (tier totals)")
    out()
    rows = []
    for lk in (1.0, 1.25, 2.0, 3.0, 4.5, 6.0):
        probs = effective(table_entries("thunderhead_point", "clear"), lk)
        tiers = {t: 0.0 for t in TIERS}
        for _, tier, p in probs:
            tiers[tier] += p
        ev = ev_tier_value(probs) / ev_tier_value(effective(table_entries("thunderhead_point", "clear"), 1.0))
        rows.append([f"x{lk}"] + [pct(tiers[t]) for t in TIERS[:6]] + [f"x{ev:.2f}"])
    table(["Luck"] + TIERS[:6] + ["Coin value per catch"], rows)

    # ---------------------------------------------------------------- D6
    out("## H. D6 Sky Bell call: effect size and cap (GDD 4.10)")
    out()
    out(f"A call is a natural front of the chosen type on the harbour's Callable spots (Pebble Cove values, x1) for "
        f"{CALLED_FRONT['lingerSeconds']} s, plus the shared bonus: Sky luck +{LUCK['calledFront']:.0%} for every player "
        f"fishing under it. Paid luck of every kind shares one +{LUCK['paidCap']:.0%} cap; the Sky category is capped "
        f"at +{LUCK['skyCap']:.0%}; the total at x{LUCK['totalCap']:.0f}.")
    out()
    rows = []
    for w in ("showers", "fog", "gusts"):
        tot, parts = luck_total(0, 0, 0, WEATHER[w]["sky_luck"], LUCK["calledFront"], 0)
        nat, _ = luck_total(0, 0, 0, WEATHER[w]["sky_luck"], 0, 0)
        p0 = effective(table_entries("pebble_cove", w), nat)
        p1 = effective(table_entries("pebble_cove", w), tot)
        r0 = sum(p for _, t_, p in p0 if t_ in LUCK_APPLIES)
        r1 = sum(p for _, t_, p in p1 if t_ in LUCK_APPLIES)
        ev0 = ev_tier_value(p0)
        ev1 = ev_tier_value(p1)
        rows.append([w, f"x{nat:.2f}", f"x{tot:.2f}", f"+{tot / nat - 1:.0%}", f"{pct(r0)} -> {pct(r1)}",
                     f"+{ev1 / ev0 - 1:.1%}"])
    table(["Called weather", "Luck under a natural front (new player)", "Luck under the call", "Added by the bonus",
           "Rare-or-better per catch", "Coin value per catch"], rows)
    lure7 = luck_total(7, 0, 0, 0, 0, 0)[0]
    out(f"Compared with play: Lure 7 alone gives x{lure7:.2f}; Lure 25 (Gear cap) x2.00; Gear x Companions at cap "
        f"x{2.0 * 1.5:.2f}. The paid part of a call (+25%) is below Lure 7, and a called Sea Fog is never luckier "
        f"than a natural one (Sky cap), so a call never gives more than free weather plus +25%.")
    out()
    ev_c = ev_tier_value(effective(table_entries("pebble_cove", "clear"), 1.0)) * mark_factor("clear")
    lk = luck_total(0, 0, 0, 0.0, LUCK["calledFront"], 0)[0]
    ev_s = ev_tier_value(effective(table_entries("pebble_cove", "showers"), lk)) * mark_factor("showers")
    gain_s = (60 / landed_seconds("showers", 0.92) * ev_s) / (60 / landed_seconds("clear", 0.92) * ev_c) - 1
    ev_n = ev_tier_value(effective(table_entries("pebble_cove", "showers"), 1.0)) * mark_factor("showers")
    gain_n = (60 / landed_seconds("showers", 0.92) * ev_n) / (60 / landed_seconds("clear", 0.92) * ev_c) - 1
    out(f"- Coins: a natural Showers front pays +{gain_n:.0%} per minute against Clear at the harbour; a called one "
        f"+{gain_s:.0%} (the shared bonus adds {100 * (gain_s - gain_n):.0f} points).")
    out(f"- Coins: a player at the harbour under a called Showers earns +{gain_s:.0%} per minute against Clear for "
        f"{CALLED_FRONT['lingerSeconds'] // 60} min, about {gain_s * CALLED_FRONT['lingerSeconds'] / 60:.1f} extra minutes "
        f"of harbour income per call. The harbour pays Pebble Cove values, so for anyone past Lantern Reef (x4) a call is "
        f"a collection and social moment (weather-only species, marks, journal), not income: a player at Gustwhistle "
        f"earns {16 / (1 + gain_s):.0f}x more per minute at home than under a call.")
    max_share = CALLED_FRONT["maxPerStormCycle"] * CALLED_FRONT["lingerSeconds"] / (
        STORM["periodSeconds"] - STORM["durationSeconds"])
    out(f"- Upper bound on coverage: {CALLED_FRONT['maxPerStormCycle']} calls x {CALLED_FRONT['lingerSeconds']} s = "
        f"{max_share:.0%} of the 720 non-storm seconds, only on clear harbour time.")
    out()
    rows = []
    for name in ("casual", "typical"):
        base = results[name]
        d6 = [run_model(name, ph, called_front_share=max_share)[0] for ph in PHASES_MIN]

        def mean_ev(ps, key):
            v = [p.events.get(key) for p in ps]
            v = [x for x in v if x]
            return sum(v) / 60 / len(v) if v else float("nan")
        for key, label in (GOALS[1], GOALS[2], GOALS[4]):
            bm, dm = mean_ev(base, key), mean_ev(d6, key)
            rows.append([MODELS[name]["label"], label, f"{bm:.1f}", f"{dm:.1f}", f"{(bm - dm) / bm:.1%}"])
    table(["Model", "Goal", "No calls", f"Worst case: Showers calls on {max_share:.0%} of non-storm time, player "
           "always under them", "Time saved"], rows)

    # ---------------------------------------------------------------- multipliers
    out("## I. Coin multiplier categories and the maxed player")
    out()
    free_cat = dict(companions=1 + COIN["companionCap"], bonus=1 + COIN["bonusCap"], boost=1 + 1.0,
                    tide=new_tide_multiplier(ECONOMY["maxNewTides"]))
    pay_cat = dict(companions=1 + COIN["companionCap"], bonus=1 + COIN["bonusCap"], boost=1 + COIN["boostCap"],
                   tide=new_tide_multiplier(ECONOMY["maxNewTides"]))
    rows = [
        ["Rod", f"x{UPGRADES['rod']['effect']} per level", f"max level {UPGRADES['rod']['maxLevel']}", "same", "same"],
        ["Island", "x1 / x4 / x16 / x64", "Thunderhead x64", "same", "same"],
        ["Companions (coins)", "1 + sum of equipped bonuses", f"x{1 + COIN['companionCap']:.1f}", f"x{free_cat['companions']:.1f}", f"x{pay_cat['companions']:.1f}"],
        ["Bonus", "journal sets +5% each, streak +2%/day (max +30%), group +10%", f"x{1 + COIN['bonusCap']:.1f}", f"x{free_cat['bonus']:.1f}", f"x{pay_cat['bonus']:.1f}"],
        ["Boost", "x2 Coins pass +100%, timed coins2x +100% (additive)", f"x{1 + COIN['boostCap']:.0f}", "x2 (timed boost only)", f"x{pay_cat['boost']:.0f}"],
        ["New Tide", "+50% per tide", f"x{new_tide_multiplier(ECONOMY['maxNewTides']):.0f} at {ECONOMY['maxNewTides']} tides", f"x{free_cat['tide']:.0f}", f"x{pay_cat['tide']:.0f}"],
        ["Marks", "one per fish", f"x{MARK_CAP:.0f} (Prism)", "same", "same"],
        ["Luck (value via rarer fish)", "see section G", f"x{LUCK['totalCap']:.0f} luck", "x6", "x6"],
    ]
    table(["Category", "Rule", "Cap", "Max free", "Max paying"], rows)
    f_prod = math.prod(free_cat.values())
    p_prod = math.prod(pay_cat.values())
    out(f"Product of the capped categories (excluding Rod and island, which are equal for both): free x{f_prod:.0f}, "
        f"paying x{p_prod:.0f}; paying / free = {p_prod / f_prod:.2f} with a free timed boost active, "
        f"{p_prod / (f_prod / 2):.2f} without. Luck caps are equal, so paid luck changes nothing at the cap.")
    out()

    # ---------------------------------------------------------------- nests
    out("## J. Nests (Config/Eggs.luau) and companions (Config/Pets.luau): fixed odds, hard pity")
    out()
    total = sum(w for _, w in NEST_ENTRIES)
    rows = []
    for nest in NESTS:
        for tier, w in NEST_ENTRIES:
            p = w / total
            rows.append([nest["id"], short(nest["price"]), tier, f"{w:g}", pct(p), f"1 in {1 / p:.1f}",
                         f"+{COMPANION_COIN_BONUS[tier] * nest['scale']:.0%}",
                         str(math.ceil(math.log(0.5) / math.log(1 - p)))])
    table(["Nest", "Price", "Tier", "Weight", "Chance", "One in", "Coin bonus", "Hatches for 50%"], rows)
    pt, pn = NEST_PITY
    p_l = dict(NEST_ENTRIES)[pt] / total
    out(f"Hard pity: {pt} guaranteed on hatch {pn} without one = {pn * p_l:.2f}x the expected {1 / p_l:.1f} hatches "
        f"(DESIGN-04 band 2-3x; template Odds.spec 1.8-3.2x). Luck never applies to nests.")
    out()
    rng = random.Random(20261025)
    trials = 200_000
    counts = []
    pity_hits = 0
    for _ in range(trials):
        n = 0
        while True:
            n += 1
            if n >= pn:
                pity_hits += 1
                break
            if rng.random() < p_l:
                break
        counts.append(n)
    counts.sort()
    out(f"Monte Carlo, {trials:,} players hatching until the first {pt}: mean {sum(counts) / trials:.1f} hatches, "
        f"median {counts[trials // 2]}, p90 {counts[int(trials * 0.9)]}, pity reached by {pity_hits / trials:.2%} "
        f"(closed form {(1 - p_l) ** (pn - 1):.2%}). Effective {pt} rate with pity: {trials / sum(counts):.3%}.")
    out()

    # ---------------------------------------------------------------- odds verification
    out("## K. Displayed odds equal rolled odds (Monte Carlo, server pick function)")
    out()
    rows = []
    for label, isl, w, lk in (("Pebble Cove clear, luck x1", "pebble_cove", "clear", 1.0),
                              ("Lantern Reef natural fog, luck x2.2", "lantern_reef", "fog", 2.2),
                              ("Thunderhead clear, luck x6 (cap)", "thunderhead_point", "clear", 6.0)):
        outc = effective(table_entries(isl, w), lk)
        n = 1_000_000
        cnt: dict[str, int] = {}
        for _ in range(n):
            o = pick(outc, rng.random())
            cnt[o[0]] = cnt.get(o[0], 0) + 1
        worst = 0.0
        ok = True
        for sid, _, p in outc:
            obs = cnt.get(sid, 0) / n
            tol = max(p * 0.03, 0.0003)
            ok = ok and abs(obs - p) <= tol
            worst = max(worst, abs(obs - p) / p)
        rows.append([label, f"{sum(p for _, _, p in outc):.12f}", f"{worst:.2%}", "PASS" if ok else "FAIL"])
    table(["Table", "Sum of displayed probabilities", "Worst relative deviation, 1M rolls", "Within Odds.spec tolerance"], rows)

    # size roll
    n = 1_000_000
    sizes = []
    for _ in range(n):
        z = rng.gauss(0, 1)
        sizes.append(min(SIZE_CLAMP[1], max(SIZE_CLAMP[0], math.exp(-SIZE_SIGMA ** 2 / 2 + SIZE_SIGMA * z))))
    sizes.sort()
    out("### Size roll (Config/Species.luau sizeRoll)")
    out()
    out(f"factor = clamp(exp(N(-{SIZE_SIGMA}^2/2, {SIZE_SIGMA})), {SIZE_CLAMP[0]}, {SIZE_CLAMP[1]}); kg = species average kg x factor x weather size. "
        f"1M rolls: mean {sum(sizes) / n:.4f}, median {sizes[n // 2]:.3f}, p99 {sizes[int(n * 0.99)]:.3f}, "
        f"share >= 1.5x {sum(1 for s in sizes if s >= 1.5) / n:.2%}, share >= 2x {sum(1 for s in sizes if s >= 2.0) / n:.3%}.")
    out()

    prototype_report()
    catalog_report()

    # ---------------------------------------------------------------- pots and passive share
    out("## L. Tide Pots and passive share (Config/TidePots.luau)")
    out()
    rows = []
    chosen = TIDE_POTS["coinsMinutesPerHour"] / 60 * 100
    for eff_pct in (25, 10, 5, chosen):
        full = TIDE_POTS["fillCapHours"] * 60 * eff_pct / 100
        mt, mc = MODELS["typical"], MODELS["casual"]
        typ_day = 2 * (full + full * min(8, mt["sameDayGapHours"]) / 8)
        cas_day = 2 * full
        rows.append([f"{eff_pct:.2f}%" + (" (chosen)" if eff_pct == chosen else ""), f"{full:.0f}",
                     f"{typ_day:.0f}", f"{typ_day / (typ_day + 40):.0%}", f"{cas_day / (cas_day + 10):.0%}"])
    table(["Pot rate vs active income", "Full pot (8 h), minutes of income", "Typical: 2 pots, 2 collections/day",
           "Passive share, typical (40 active min/day)", "Passive share, casual (2 pots, 10 active min/day)"], rows)
    out(f"Chosen: {TIDE_POTS['coinsMinutesPerHour']} minute of income per pot-hour, cap {TIDE_POTS['fillCapHours']} h, "
        f"one fish per hour (a full pot reveals 8 fish; day-7 bait adds {TIDE_POTS['baitExtraFish']}). "
        "Measured share in the return view: see section B.")
    out()

    text = "\n".join(OUT) + "\n"
    sys.stdout.write(text)
    if args.out:
        with open(args.out, "w", encoding="utf-8") as fh:
            fh.write(text)


# =====================================================================================================
# 8. PROTOTYPE SUBSET (GDD 13, docs/specs/prototype.md): 3 spots, Rod only, Clear/Showers/Sea Fog, one storm
# =====================================================================================================

PROTO_SPECIES = [  # (id, tier, table, weight); base value = baseCoinsPerCatch * TIER_VALUE[tier]
    ("pebble_minnow", "Common", "clear", 26.0),
    ("bobblefin", "Common", "clear", 22.0),
    ("sandskipper", "Common", "clear", 18.0),
    ("tidetail", "Uncommon", "clear", 13.0),
    ("kelpnibbler", "Uncommon", "clear", 11.0),
    ("copperscale", "Rare", "clear", 6.0),
    ("splashkin", "Uncommon", "showers", 15.0),
    ("pitterpike", "Rare", "showers", 6.5),
    ("hushgill", "Rare", "fog", 6.0),
    ("lanternfin", "Epic", "fog", 2.2),
    ("rumblefin", "Mythic", "storm", 1.0),
]
PROTO_ROD = dict(baseCost=15, costGrowth=1.28, effect=1.14, maxLevel=30)  # template values (prototype brief)
# GDD 13.2 timetable for the two front spots (cove_dock is always Clear outside the storm)
PROTO_FRONTS = [(200, 300, "showers"), (300, 400, "showers"), (420, 520, "fog"), (520, 620, "fog"),
                (640, 740, "showers"), (740, 840, "showers")]
PROTO_WALK_SECONDS = 8  # moving between cove_shallows and pier_head when a front moves (layout model: <= 7-10 s)


def proto_rows(weather: str) -> list[tuple[str, str, float]]:
    rows = [(sid, tier, w) for sid, tier, tbl, w in PROTO_SPECIES if tbl == "clear"]
    if weather in ("showers", "fog"):
        rows += [(sid, tier, w) for sid, tier, tbl, w in PROTO_SPECIES if tbl == weather]
    return rows


def proto_value_per_catch(weather: str) -> tuple[float, list]:
    lk = 1.0 + WEATHER[weather]["sky_luck"]  # no Lure, no friends in the prototype
    probs = effective(proto_rows("clear" if weather == "eye" else weather), lk)
    w = WEATHER[weather]
    ev = ECONOMY["baseCoinsPerCatch"] * ev_tier_value(probs) * SIZE_MEAN * w["size"] * w["value"] * mark_factor(weather)
    return ev, probs


def proto_front_at(c: int) -> str | None:
    for a, b, w in PROTO_FRONTS:
        if a <= c < b:
            return w
    return None


def proto_run(model: dict, behaviour: str, phase_s: int, minutes: int = 20) -> dict:
    """behaviour: stay (Dock Ripple only), target (45% of non-storm line time under fronts), chase (every front)."""
    coins, rod, t = 0.0, 0, 0
    buys: list[int] = []
    under = total_line = 0.0
    eye_rumble = STORM["stormbornValueFactor"] * ECONOMY["baseCoinsPerCatch"] * TIER_VALUE["Mythic"] * mark_factor("eye")
    front_cover = sum(b - a for a, b, _ in PROTO_FRONTS) / 720
    take = {"stay": 0.0, "target": 0.45 / front_cover, "chase": 1.0}[behaviour]
    while t < minutes * 60:
        c = (phase_s + t) % 900
        mult = PROTO_ROD["effect"] ** rod
        if t == 18:
            coins += ECONOMY["firstCatchCoins"]
        elif t > 18:
            if c < 180:  # storm: eye at pier_head (attend) else storm ring at other spots, clear table
                attend = model["stormAttend"]
                ev_e, _ = proto_value_per_catch("eye")
                n = max(1.0, (180 - 10) * (1 - model["idle"]) / landed_seconds("eye", model["reel"]))
                hook = (1 - (1 - STORM["stormbornHookChance"]) ** n) / n
                rate = (1 - model["idle"]) / (landed_seconds("eye", model["reel"]) + hook * land_seconds(model["helpers"]))
                ev_c, _ = proto_value_per_catch("clear")
                inc = attend * rate * ((1 - hook) * ev_e + hook * eye_rumble)
                inc += (1 - attend) * (1 - model["idle"]) / landed_seconds("clear", model["reel"]) * ev_c
                if c == 179:
                    inc += attend * min(STORM["helperSharesCapPerStorm"], model["helps"]) * STORM["helperShare"] * eye_rumble
                coins += inc * mult
            else:
                front = proto_front_at(c)
                just_moved = any(0 <= c - a < PROTO_WALK_SECONDS for a, _, _ in PROTO_FRONTS)
                walk = take if (front is not None and just_moved) else 0.0
                share_front = take if (front is not None and not just_moved) else 0.0
                eff = 1 - model["idle"]
                inc = 0.0
                if share_front > 0:
                    ev_f, _ = proto_value_per_catch(front)
                    inc += share_front * eff / landed_seconds(front, model["reel"]) * ev_f
                ev_c, _ = proto_value_per_catch("clear")
                inc += (1 - share_front - walk) * eff / landed_seconds("clear", model["reel"]) * ev_c
                coins += inc * mult
                total_line += 1
                under += share_front
            if t == SCRIPTED_RAIN_RARE_SECONDS and behaviour != "stay":
                coins += ECONOMY["baseCoinsPerCatch"] * TIER_VALUE["Rare"] * 1.5 * mult
        t += 1
        while t >= ECONOMY["shopOpensAtSeconds"] and rod < PROTO_ROD["maxLevel"]:
            cost = math.floor(PROTO_ROD["baseCost"] * PROTO_ROD["costGrowth"] ** rod + 0.5)
            if coins < cost:
                break
            coins -= cost
            rod += 1
            buys.append(t)
    return dict(buys=buys, under=under / max(1, total_line), rod=rod)


def prototype_report() -> None:
    out("## M. Prototype subset (GDD 13, docs/specs/prototype.md): paste-ready values")
    out()
    out("Spots cove_dock (sheltered, always Clear outside the storm), cove_shallows, pier_head (storm eye); "
        "timetable of GDD 13.2 (front coverage 600/720 s of non-storm time at the two front spots). No Lure, "
        "no companions, no friend bonus: luck is 1.0 except natural Sea Fog's Sky +100%.")
    out()
    rows = []
    kg = {"Common": 0.8, "Uncommon": 2, "Rare": 5, "Epic": 12, "Mythic": 180}
    tables = {w: {sid: p for sid, _, p in effective(proto_rows(w), 1.0 + WEATHER[w]["sky_luck"])}
              for w in ("clear", "showers", "fog")}
    for sid, tier, tbl, wgt in PROTO_SPECIES:
        val = ECONOMY["baseCoinsPerCatch"] * TIER_VALUE[tier] * (STORM["stormbornValueFactor"] if tbl == "storm" else 1)
        cells = [pct(tables[w][sid]) if sid in tables[w] else "-" for w in ("clear", "showers", "fog")]
        rows.append([sid, tier, tbl, f"{wgt:g}", f"{val:g}", f"{kg[tier]:g}"] + cells)
    table(["Species", "Tier", "Table", "Weight", "Base coins", "Base kg", "Clear (and storm away from the eye)",
           "Showers", "Sea Fog"], rows)
    out(f"Rumblefin: {STORM['stormbornHookChance']:.1%} of eye bites during the storm, at most "
        f"{STORM['stormbornMaxPerStorm']} per player per storm; Charged by chance 25% (+5% per friend helper, cap 50%), x3. "
        f"Helper share {STORM['helperShare']:.0%} of its value, at most {STORM['helperSharesCapPerStorm']} paid helps per storm. "
        "Regular storm catches: Charged by a landing tap on a flash (model assumes 25%).")
    out()
    rows = []
    base_ev, _ = proto_value_per_catch("clear")
    for w in ("clear", "showers", "fog", "eye"):
        ev, probs = proto_value_per_catch(w)
        for label, reel in (("casual 85%", 0.85), ("typical 92%", 0.92)):
            rate = 60 / landed_seconds(w, reel)
            rows.append([w, label, f"{rate:.2f}", f"{ev:.2f}",
                         f"{rate * ev / (60 / landed_seconds('clear', reel) * base_ev):.2f}",
                         pct(sum(p for _, t_, p in probs if t_ in LUCK_APPLIES))])
    table(["Weather", "Reel success", "Catches/min", "Coins per catch (Rod 0)", "Coins/min vs Clear",
           "Rare-or-better"], rows)
    rows = []
    for name in ("casual", "typical"):
        for beh in ("stay", "target", "chase"):
            runs = [proto_run(MODELS[name], beh, ph * 60) for ph in PHASES_MIN]
            first = sum(r["buys"][0] for r in runs) / len(runs)

            def level_at(r, m):
                return sum(1 for b in r["buys"] if b <= m * 60)
            lv = [sum(level_at(r, m) for r in runs) / len(runs) for m in (5, 10, 15, 20)]
            gaps = []
            for r in runs:
                pts = [0] + [b for b in r["buys"] if b <= 1200] + [1200]
                gaps.append(max(b - a for a, b in zip(pts, pts[1:])) / 60)
            under = sum(r["under"] for r in runs) / len(runs)
            rows.append([MODELS[name]["label"], beh, f"{under:.0%}", f"{first:.0f} s"] + [f"{x:.1f}" for x in lv]
                        + [f"{max(gaps):.2f}"])
    table(["Model", "Behaviour", "Line time under fronts", "First Rod", "Rod level @5 min", "@10", "@15", "@20",
           "Worst gap between Rod buys in 20 min (min)"], rows)
    rows = []
    for name in ("casual", "typical"):
        waits, early = [], []
        for ph in PHASES_MIN:
            r = proto_run(MODELS[name], "target", ph * 60)
            nxt = [b for b in r["buys"] if b > 600]
            waits.append((nxt[0] - 600) / 60 if nxt else float("inf"))
            pts = [0] + [b for b in r["buys"] if b <= 600] + [600]
            early.append(max(b - a for a, b in zip(pts, pts[1:])) / 60)
        rows.append([MODELS[name]["label"], f"{sum(waits) / len(waits):.2f} (max {max(waits):.2f})", f"{max(early):.2f}"])
    table(["Model (target behaviour)", "At 10:00, minutes to the next Rod level (test 5: 1-3 min)",
           "Worst gap between Rod buys in the first 10 min"], rows)
    n = (180 - 10) * (1 - MODELS["typical"]["idle"]) / landed_seconds("eye", 0.92)
    p_hook = 1 - (1 - STORM["stormbornHookChance"]) ** n
    out(f"Storm (typical at the eye all storm): {n:.1f} eye bites; P(hooks a Rumblefin) = {p_hook:.0%} per storm; "
        f"with 4 anglers at the eye, expected pulls per storm = {4 * p_hook:.1f}. Rod max level 30 costs "
        f"{short(math.floor(15 * 1.28 ** 29 + 0.5))} for the last level.")
    out()


# =====================================================================================================
# 9. CATALOG CHECKS (T-0015): the catalog's three questions to the Economist (catalog section 11)
# =====================================================================================================


def auto_landed_seconds(weather: str) -> float:
    w = WEATHER[weather]
    a = CATALOG["autoReel"]
    bite = (w["bite"][0] + w["bite"][1]) / 2
    reel = w["reel"] * a["reelFactor"]
    t_ok = w["cast"] + bite + reel + w["reveal"]
    t_fail = w["cast"] + bite + reel + FAILED_REEL_RECOVER_S
    return (a["landed"] * t_ok + (1 - a["landed"]) * t_fail) / a["landed"]


def catalog_report() -> None:
    out("## N. Catalog checks (T-0015, catalog section 11)")
    out()
    out("### N1. Auto Reel: 70% landed, reel x2, Clear-ring water only, never Charged")
    out()
    auto = 60 / auto_landed_seconds("clear")
    rows = []
    for name in ("casual", "typical"):
        m = MODELS[name]
        clear = 60 / landed_seconds("clear", m["reel"])
        showers = 60 / landed_seconds("showers", m["reel"])
        # whole fishing mix at Lantern Reef, Lure 0: Auto Reel in Clear and Rainbow, active in fronts
        mix = FRONT_MIX["fog"]
        f, r = m["front"], m["rainbow"]
        parts = [("clear", 1 - f - r), ("rainbow", r)] + [(w, f * sh) for w, sh in mix.items()]
        active = auto_mix = 0.0
        for w, frac in parts:
            lk = luck_total(0, 0, 0, WEATHER[w]["sky_luck"], 0, 0)[0]
            ev = ev_tier_value(effective(table_entries("lantern_reef", w), lk)) * WEATHER[w]["size"] * \
                WEATHER[w]["value"] * mark_factor(w)
            a_rate = 60 / landed_seconds(w, m["reel"])
            active += frac * a_rate * ev
            if w in CATALOG["autoReel"]["weathers"]:
                auto_mix += frac * (60 / auto_landed_seconds(w)) * ev
            else:
                auto_mix += frac * a_rate * ev
        rows.append([m["label"], f"{clear:.2f}", f"{auto:.2f} ({auto / clear:.0%})", f"{showers:.2f} ({auto / showers:.0%})",
                     f"{auto_mix / active:.0%}"])
    table(["Model", "Active Clear catches/min", "Auto Reel Clear (share of active)", "Active Showers (Auto as share)",
           "Coins/min with Auto Reel on in all Clear and Rainbow time, against reeling yourself"], rows)
    ev_c = ev_tier_value(effective(table_entries("lantern_reef", "clear"), 1.0))
    typ_active = 0.0
    m = MODELS["typical"]
    for w, frac in [("clear", 1 - m["front"] - m["rainbow"]), ("rainbow", m["rainbow"])] + \
            [(w, m["front"] * sh) for w, sh in FRONT_MIX["fog"].items()]:
        lk = luck_total(0, 0, 0, WEATHER[w]["sky_luck"], 0, 0)[0]
        typ_active += frac * 60 / landed_seconds(w, m["reel"]) * ev_tier_value(effective(table_entries("lantern_reef", w), lk)) \
            * WEATHER[w]["size"] * WEATHER[w]["value"] * mark_factor(w)
    afk_share = auto * ev_c / typ_active
    out(f"Auto Reel can only lower a player's income: it is slower than reeling yourself in Clear and pauses in every "
        f"front and the storm. Exposure if a macro taps Cast with Auto Reel on, unattended in Clear water: "
        f"{afk_share:.0%} of a typical player's active coins per minute, so one unattended hour is worth about "
        f"{afk_share * 60:.0f} minutes of active income, against {TIDE_POTS['coinsMinutesPerHour']} minute for a "
        f"Tide Pot hour.")
    out()
    out("### N2. Lucky Bobber in Sea Fog: current rule (Sky cap) against a separate paid category")
    out()
    rows = []
    for label, lure in (("New player", 0), ("Casual, Lure 7", 7), ("Typical, Lure 12", 12)):
        for rule in ("current", "separate"):
            if rule == "current":
                lk = luck_total(lure, 0, 0, 1.0, CATALOG["luckyBobber"]["paidLuck"], 0)[0]
            else:
                lk = min(LUCK["totalCap"], luck_total(lure, 0, 0, 1.0, 0, 0)[0] * (1 + CATALOG["luckyBobber"]["paidLuck"]))
            base = luck_total(lure, 0, 0, 1.0, 0, 0)[0]
            p0 = effective(table_entries("lantern_reef", "fog"), base)
            p1 = effective(table_entries("lantern_reef", "fog"), lk)
            r0 = sum(p for _, t_, p in p0 if t_ in LUCK_APPLIES)
            r1 = sum(p for _, t_, p in p1 if t_ in LUCK_APPLIES)
            l0 = sum(p for _, t_, p in p0 if t_ in ("Legendary", "Mythic", "Secret"))
            l1 = sum(p for _, t_, p in p1 if t_ in ("Legendary", "Mythic", "Secret"))
            rows.append([label, "Sky cap (current)" if rule == "current" else "own category x1.25",
                         f"x{base:.2f} -> x{lk:.2f}", f"{pct(r0)} -> {pct(r1)}", f"{pct(l0)} -> {pct(l1)}",
                         f"+{ev_tier_value(p1) / ev_tier_value(p0) - 1:.1%}"])
    table(["Player (Lantern Reef, natural Sea Fog)", "Rule for the bobber", "Luck", "Rare-or-better",
           "Legendary-or-better", "Coin value per catch"], rows)
    out("### N3. Coin products: what one 'minute of income' counts")
    out()
    out("Basis for every minutes-of-income grant (coin packs, Starter Pack, calendar, gifts, Tide Pots): coins per "
        "catch at the best island in Clear water with permanent multipliers (Rod, companions, bonus category, New "
        "Tide, Lure and owned luck passes) x 5 catches a minute. Never timed boosts or friends. 2x Coins pass in the "
        f"basis: {'yes' if MINUTES_BASIS['paidCoinPass'] else 'no'}. Section B's variant table shows both bases for "
        "the heavy spender.")
    out()


def print_timeline(name: str, phase: int) -> None:
    p = Player(MODELS[name], phase)
    print("min  isl tides rod lure boots slots compC  coins      inc/min(clear unit)  luck(clear)  purchases")
    while p.t < SIM_MINUTES * 60:
        p.session_tick()
        p.step()
        p.buy()
        if p.t % 10 == 0:
            p.check_sets()
        if p.t % 150 == 0:
            print(f"{p.t / 60:5.1f} {p.islands:3d} {p.tides:5d} {p.lv['rod']:3d} {p.lv['lure']:4d} {p.lv['boots']:5d} "
                  f"{p.slots():5d} {p.companion_coin():5.2f} {short(p.coins):>9} {short(p.income_per_minute_clear()):>12} "
                  f"{p.luck('clear', False):10.3f} {len(p.purchases):6d}")
    print({k: round(v / 60, 2) for k, v in p.events.items() if not k.startswith('pre_')})


def tide_cycles(name: str, wanted: list[int]) -> dict[int, tuple[float, float]]:
    """Long horizon: time for each New Tide, no rewards, species not tracked, 5 s steps (EV scaled)."""
    p = Player(MODELS[name], 0, include_rewards=False, track_species=False)
    res: dict[int, tuple[float, float]] = {}
    last = 0
    limit = 400 * 3600
    target = max(wanted)
    while p.t < limit and p.tides < target:
        p.session_tick()
        before = p.tides
        p.step()
        p.buy()
        if p.tides > before:
            if p.tides in wanted:
                res[p.tides] = ((p.t - last) / 60, p.t / 3600)
            last = p.t
    for n in wanted:
        res.setdefault(n, (float("nan"), float("nan")))
    return res


if __name__ == "__main__":
    main()
