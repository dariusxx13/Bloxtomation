#!/usr/bin/env python3
"""Reel the Storm (game id `stormcatch`): economy and drop-table model.

Task T-0008, Economist, design stage, 2026-10-25.

Run from the repository root:

    python3 games/stormcatch/docs/models/economy_model.py --out games/stormcatch/docs/models/economy_model_output.txt

Standard library only. The pacing part is a deterministic expected-value simulation stepped one
second at a time (no randomness); the odds checks use a seeded Monte Carlo, so the output is identical
on every run. Every constant block names the Config module it becomes in
games/stormcatch/project/src/shared/Config/. Nothing here edits game code.

Why Python: `lune` is not installed in this environment (`which lune` returns nothing), so the
template's `scripts/economy-sheet.luau` cannot run. This file mirrors the template's formulas
(Util/EconomyMath.luau, Util/Odds.luau, Util/Stats.luau) and extends them to fishing.
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

# Config/Fish.luau (new): value of a fish = baseCoinsPerCatch * tierValue * islandMultiplier * size * mark.
TIER_VALUE = {"Common": 1, "Uncommon": 2, "Rare": 4, "Epic": 10, "Legendary": 30, "Mythic": 100, "Secret": 400}

# Config/Economy.luau
ECONOMY = {
    "baseCoinsPerCatch": 5,  # replaces baseCoinsPerHit = 1 (one catch is ~8 s, not 0.2 s)
    "firstCatchCoins": 12,  # the scripted onboarding catch (Pebble Minnow, 0.8 kg), loop sketch 5.1
    "shopOpensAtSeconds": 45,  # onboarding steps 4-5 (shop pulses after 15 coins); first purchase not earlier
    "assumedCatchesPerMinute": 7,  # converts "minutes of income" rewards to coins (Rewards.assumedHitsPerMinute)
    # New Tide (rebirth): template keys rebirthBaseCost / rebirthCostGrowth / rebirthMultiplierPerRebirth
    "newTideBaseCost": 40_000,
    "newTideCostGrowth": 2.4,
    "newTideMultiplierPerTide": 0.5,
    "maxNewTides": 30,  # cap: x16 at 30 tides; a second layer is planned before tide 15 (see output)
    "newTideKeepsIslands": True,  # template rebirthKeepsZones
    "newTideRequiresIsland": "gustwhistle_bluffs",
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

# Size roll (Config/Fish.luau sizeRoll): factor = clamp(exp(N(-s^2/2, s)), lo, hi) * weather size.
SIZE_SIGMA = 0.25
SIZE_CLAMP = (0.5, 3.0)
STORMBORN_SIZE_SIGMA = 0.30

# Great Storm (Config/Weather.luau greatStorm)
STORM = {
    "periodSeconds": 900,  # :00 :15 :30 :45 UTC
    "durationSeconds": 180,
    "stormbornHookChance": 0.025,  # chance that an eye bite is a Stormborn
    "soloLandSeconds": 45.0,  # loop sketch 4.4
    "helperSpeedup": 0.875,  # land time = 45 / (1 + 0.875 * helpers): 4 helpers -> 10 s
    "stormbornValueFactor": 1.5,  # giants: extra value on top of tier value
    "helperShare": 0.10,  # a helper's minted share of the Stormborn's value
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
    dict(id="lantern_reef", name="Lantern Reef", gate=2_000, mult=4, tides=0, home="fog", nest="reef_nest"),
    dict(id="gustwhistle_bluffs", name="Gustwhistle Bluffs", gate=25_000, mult=16, tides=0, home="gusts",
         nest="bluff_nest"),
    dict(id="thunderhead_point", name="Thunderhead Point", gate=2_500_000, mult=64, tides=1, home="mixed",
         nest="thunder_nest"),
]
ISLAND_BY_ID = {i["id"]: i for i in ISLANDS}

# Config/Fish.luau species. Weights, not percentages (probability = weight / table total).
# Ids are slots; the Designer names them in the GDD (names given only where the loop sketch has them).
SPECIES = [
    # Pebble Cove (8): 3 Common, 2 Uncommon, 2 Rare, 1 Epic. Set lock: the Epic.
    ("pebble_minnow", "Common", "island:pebble_cove", 26.0),
    ("pc_common_2", "Common", "island:pebble_cove", 22.0),
    ("pc_common_3", "Common", "island:pebble_cove", 18.0),
    ("pc_uncommon_1", "Uncommon", "island:pebble_cove", 13.0),
    ("pc_uncommon_2", "Uncommon", "island:pebble_cove", 11.0),
    ("pc_rare_1", "Rare", "island:pebble_cove", 4.7),
    ("pc_rare_2", "Rare", "island:pebble_cove", 3.8),
    ("pc_epic_1", "Epic", "island:pebble_cove", 1.5),
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
    ("rain_uncommon", "Uncommon", "weather:showers", 15.0),
    ("rain_rare", "Rare", "weather:showers", 8.0),  # the scripted first rain catch
    ("rain_epic", "Epic", "weather:showers", 2.0),
    ("fog_rare", "Rare", "weather:fog", 12.0),
    ("fog_epic", "Epic", "weather:fog", 4.5),
    ("lanternfin", "Legendary", "weather:fog", 1.0),  # Fish of the Day example in loop sketch 5.7
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
    "lure": dict(kind="luck", name="Lure", baseCost=150, costGrowth=1.5, effect=0.04, maxLevel=25,
                 resetsOnNewTide=False, revealSeconds=240),
    "boots": dict(kind="speed", name="Boots", baseCost=120, costGrowth=1.55, effect=1, maxLevel=16,
                  resetsOnNewTide=True, revealSeconds=240),
    "pal_pouch": dict(kind="slots", name="Pal Pouch", baseCost=3_000, costGrowth=8.0, effect=1, maxLevel=2,
                      resetsOnNewTide=False, revealSeconds=None),  # revealed by the Lantern Reef bridge
}
BASE_WALK_SPEED = 16
BASE_COMPANION_SLOTS = 2  # Pets.baseEquipSlots (template 3)

# Config/Eggs.luau (nests) and Config/Pets.luau (companions). Nest odds are fixed: no luck applies.
NESTS = [
    dict(id="driftwood_nest", island="pebble_cove", price=150, scale=1, revealSeconds=300),
    dict(id="reef_nest", island="lantern_reef", price=5_000, scale=2, revealSeconds=0),
    dict(id="bluff_nest", island="gustwhistle_bluffs", price=150_000, scale=3, revealSeconds=0),
    dict(id="thunder_nest", island="thunderhead_point", price=6_000_000, scale=4, revealSeconds=0),
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
CALLED_FRONT = {
    "warningSeconds": 60,  # on the Sky Dial for everyone before it arrives
    "lingerSeconds": 300,
    "maxActivePerServer": 1,
    "maxPerStormCycle": 2,  # at most 10 of every 15 minutes
    "blockedBeforeStormSeconds": 240,  # never during, or in the 4 minutes before, a Great Storm
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
    dict(coinsMinutes=3),
    dict(coinsMinutes=4),
    dict(coinsMinutes=5),
    dict(coinsMinutes=6, boost="coins2x", boostSeconds=600),
    dict(coinsMinutes=8),
    dict(coinsMinutes=10),
    dict(coinsMinutes=15, boost="luckyTide", boostSeconds=900, potBait=1),
]
STREAK_PER_DAY = 0.02
STREAK_CAP = 0.30
PLAYTIME = [  # per session (template Rewards.playtime; claimed once per session)
    dict(minutes=5, coinsMinutes=2),
    dict(minutes=10, coinsMinutes=3),
    dict(minutes=15, coinsMinutes=4),
    dict(minutes=25, boost="coins2x", boostSeconds=600),
    dict(minutes=40, coinsMinutes=6),
    dict(minutes=60, coinsMinutes=10),
]

# Config/TidePots.luau (new)
TIDE_POTS = {
    "fillCapHours": 8,
    "coinsMinutesPerHour": 1.0,  # one fish an hour, each worth about one minute of active income
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
                   reel=0.92, idle=0.10, travel=0.10, front=0.50, rainbow=0.05, stormAttend=0.9,
                   friends=2, helpers=3, helps=2, bootsCap=10, hatch={"driftwood_nest": 3, "reef_nest": 3,
                   "bluff_nest": 3, "thunder_nest": 3}, x2coins=True, paidLuck=0.25, extraSlots=1),
}
# The paying model's purchases are placeholders from the template catalog (2x Coins pass, a paid luck
# item at the paid-luck cap, +1 companion slot) until the Monetization Designer's catalog (T-0009) lands.

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
                 include_rewards: bool = True, track_species: bool = True):
        self.m = model
        self.phase = phase_min * 60
        self.cf_share = called_front_share  # share of non-storm time a D6 Called Front is active
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
        self.cache: dict = {}

    # ----- derived stats -----
    def island(self) -> dict:
        return ISLANDS[self.islands - 1]

    def best_mult(self) -> float:
        return self.island()["mult"]

    def walk(self) -> float:
        return BASE_WALK_SPEED + self.lv["boots"] * UPGRADES["boots"]["effect"]

    def slots(self) -> int:
        return BASE_COMPANION_SLOTS + self.lv["pal_pouch"] + self.m["extraSlots"]

    def companion_coin(self) -> float:
        best = sorted(self.companions, reverse=True)[: self.slots()]
        return min(COIN["companionCap"], sum(best))

    def coin_mult(self) -> float:
        rod = UPGRADES["rod"]["effect"] ** self.lv["rod"]
        journal = COIN["journalSetBonus"] * len(self.sets_done)
        day = self.session // self.m["sessionsPerDay"] + 1
        streak = min(STREAK_CAP, STREAK_PER_DAY * (day - 1)) if self.rewards else 0.0
        bonus = min(COIN["bonusCap"], journal + streak)
        boost = (1.0 if self.m["x2coins"] else 0.0) + (1.0 if self.boost_until["coins2x"] > self.t else 0.0)
        boost = min(COIN["boostCap"], boost)
        return rod * (1 + self.companion_coin()) * (1 + bonus) * (1 + boost) * new_tide_multiplier(self.tides)

    def luck(self, weather: str, called: bool) -> float:
        natural = WEATHER[weather]["sky_luck"]
        paid = self.m["paidLuck"] + (LUCK["calledFront"] if called else 0.0)
        timed = LUCK["luckyTide"] if self.boost_until["luckyTide"] > self.t else 0.0
        return luck_total(self.lv["lure"], 0.0, self.m["friends"], natural, paid, timed)[0]

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
    def weather_mix(self, called: bool) -> list[tuple[str, float]]:
        if self.t < FRONTS_START_SECONDS:
            return [("clear", 1.0)]
        f, r = self.m["front"], self.m["rainbow"]
        mix = FRONT_MIX[self.island()["home"]]
        out = [("clear", 1 - f - r), ("rainbow", r)]
        out += [(w, f * share) for w, share in mix.items()]
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
            self.lam["pebble_minnow"] = math.inf
            self.t += 1
            return
        if t == SCRIPTED_RAIN_RARE_SECONDS:
            isl = self.island()
            v = (ECONOMY["baseCoinsPerCatch"] * TIER_VALUE["Rare"] * isl["mult"] * 1.5) * self.coin_mult()
            self.gain(v)
            self.lam["rain_rare"] = math.inf
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
                hook = STORM["stormbornHookChance"]
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
            for called in (False, True):
                share = self.cf_share if called else 1 - self.cf_share
                if share <= 0:
                    continue
                for weather, frac in self.weather_mix(called):
                    if frac <= 0:
                        continue
                    lk = self.luck(weather, called)
                    probs, ev = self.table(isl["id"], weather, lk)
                    rate = share * frac * eff / landed_seconds(weather, self.m["reel"])
                    income += rate * self.catch_value(isl["mult"], weather, ev) * mult
                    self.add_species(probs, rate)
        self.gain(income)
        if t % 60 == 0:
            self.income_log.append((t, income * 60))
        self.t += 1

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
                    fish = hours * slots + self.pot_bait * TIDE_POTS["baitExtraFish"]
                    self.pot_bait = 0
                    v = fish * TIDE_POTS["coinsMinutesPerHour"] * self.income_per_minute_clear()
                    self.gain(v)
                    self.passive_coins += v
        if self.rewards:
            for i, g in enumerate(PLAYTIME):
                if i not in self.claimed and sess_t >= g["minutes"] * 60 and g["minutes"] <= self.m["sessionMin"]:
                    self.claimed.add(i)
                    self.reward(g)
        # day-1 reward on the very first second
        if self.rewards and self.t == 0:
            self.reward(DAILY[0])

    def reward(self, r: dict) -> None:
        if r.get("coinsMinutes"):
            self.gain(r["coinsMinutes"] * self.income_per_minute_clear())
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
        if self.islands >= 3 and self.tides < ECONOMY["maxNewTides"]:
            return "new_tide", new_tide_cost(self.tides)
        return "none", math.inf

    def buy(self) -> None:
        if self.t < ECONOMY["shopOpensAtSeconds"]:
            return
        for _ in range(50):
            goal, cost = self.next_goal()
            if self.coins >= cost:
                self.coins -= cost
                self.purchases.append(self.t)
                if goal.startswith("bridge:"):
                    self.islands += 1
                    self.events.setdefault(goal, self.t)
                else:
                    self.new_tide()
                continue
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
            if not cands:
                return
            c, key = min(cands)
            if self.coins < c or (cost - self.coins) <= c:
                return
            self.coins -= c
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
    ("first_nest", "First nest (Driftwood)"),
    ("lure_7", "Lure level 7 (+28% luck, above the D6 +25%)"),
    ("set:rain", "Rain set 3/3 (median)"),
    ("set:lantern_reef", "Lantern Reef set 8/8 (median)"),
    ("bridge:thunderhead_point", "Bridge to Thunderhead Point (needs New Tide 1)"),
    ("new_tide_2", "New Tide 2"),
]


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--out", help="also write the report to this path")
    args = ap.parse_args()

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
            return "-" if n == 0 else f"only {n}/{len(PHASES_MIN)} runs"
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
    for key, _ in GOALS[1:]:
        c = stat("casual", key)[0]
        pv = stat("paying", key)[0]
        if c and pv:
            ratios.append(c / pv)
    checks.append(("Paying player faster but within 2-4x of casual on goals 2-5", all(1.0 < r <= 4.0 for r in ratios),
                   ", ".join(f"{r:.2f}x" for r in ratios)))
    # max purchase gap in first hour, typical
    gaps = []
    for p in results["typical"]:
        pts = [0] + [t for t in p.purchases if t <= 3600]
        gaps.append(max((b - a) for a, b in zip(pts, pts[1:])) / 60 if len(pts) > 1 else 99)
    checks.append(("No gap above about 3 min between purchases in the first hour (typical)", max(gaps) <= 3.2,
                   f"worst gap {max(gaps):.2f} min, mean worst {sum(gaps) / len(gaps):.2f} min"))
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
    checks.append(("After New Tide 1, regain the pre-tide income in 1/4-1/3 of the original time (typical)",
                   bool(reg) and 0.2 <= sum(reg) / len(reg) <= 0.4,
                   f"{sum(reg) / len(reg):.2f} of the original time" if reg else "not reached"))
    rows = [[c, "PASS" if ok else "CHECK", note] for c, ok, note in checks]
    table(["Check", "Result", "Model value"], rows)

    # catch-only conservative run (Economy.spec analogue: no rewards, no pots)
    out("### Conservative run: catch income only (no daily, playtime or pot rewards)")
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

    # income composition for typical
    out("### Where the coins come from (first 240 min, mean over join minutes)")
    out()
    rows = []
    for name in MODELS:
        ps = results[name]
        tot = sum(p.total_coins for p in ps)
        st = sum(p.storm_coins for p in ps)
        pas = sum(p.passive_coins for p in ps)
        rows.append([MODELS[name]["label"], f"{st / tot:.1%}", f"{pas / tot:.1%}"])
    table(["Model", "Great Storm share (eye catches, Stormborn, helper shares)", "Tide Pot share"], rows)

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
    out("Pal Pouch +1 companion slot per level (2 -> 4 slots).")
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
    cyc = tide_cycles("typical", [1, 2, 5, 10, 15, 25])
    rows = [[str(n), fmt_min(v[0]), fmt_min(v[1])] for n, v in cyc.items()]
    table(["New Tide #", "Minutes since previous tide", "Cumulative active hours"], rows)

    # ---------------------------------------------------------------- odds tables
    out("## E. Drop tables per island and weather (Config/Fish.luau), base luck x1 except natural Sea Fog")
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
        "Epic": "8-20 min",
        "Legendary": "25-60 min",
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
        ("New player, clear, D6 Called Front in the server", 0, 0, 0, 0.0, 0.25, 0.0),
        ("New player, natural Sea Fog", 0, 0, 0, 1.0, 0.0, 0.0),
        ("New player, natural Sea Fog + D6 (capped: adds 0)", 0, 0, 0, 1.0, 0.25, 0.0),
        ("Lure 7, clear (casual after first session)", 7, 0, 0, 0.0, 0.0, 0.0),
        ("Lure 12, 1 friend, Lamp Moth in fog (typical, hour 1-2)", 12, 0.15, 1, 1.0, 0.0, 0.0),
        ("Max free: Lure 25, companions +50%, 5 friends, clear", 25, 0.5, 5, 0.0, 0.0, 0.0),
        ("Max free in natural fog (total cap binds)", 25, 0.5, 5, 1.0, 0.0, 0.0),
        ("Max paying: as max free + paid luck + D6, clear", 25, 0.5, 5, 0.0, 0.5, 0.0),
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
    out("## H. D6 Called Front: effect size and cap")
    out()
    probs0 = effective(table_entries("lantern_reef", "clear"), 1.0)
    probs1 = effective(table_entries("lantern_reef", "clear"), 1.25)
    ev_gain = ev_tier_value(probs1) / ev_tier_value(probs0) - 1
    rare0 = sum(p for _, t, p in probs0 if t in LUCK_APPLIES)
    rare1 = sum(p for _, t, p in probs1 if t in LUCK_APPLIES)
    lure7 = luck_total(7, 0, 0, 0, 0, 0)[0]
    out(f"- Shared luck: +{LUCK['calledFront']:.0%} in the Sky category for every player in the server for "
        f"{CALLED_FRONT['lingerSeconds'] // 60} min. Lantern Reef clear: Rare-or-better {pct(rare0)} -> {pct(rare1)}; "
        f"coin value per catch +{ev_gain:.1%}.")
    out(f"- Compared with play: Lure 7 alone gives x{lure7:.2f}; natural Sea Fog gives x2.00; max earned "
        f"(Gear x Companions) gives x{2.0 * 1.5:.2f}. The Called Front gives x1.25 and adds 0 in natural fog (Sky cap).")
    # coin effect of a called Showers front for a player standing in it, vs clear
    lk = 1.25
    ev_c = ev_tier_value(effective(table_entries("lantern_reef", "clear"), 1.0)) * mark_factor("clear")
    ev_s = ev_tier_value(effective(table_entries("lantern_reef", "showers"), lk)) * mark_factor("showers")
    gain_s = (60 / landed_seconds("showers", 0.92) * ev_s) / (60 / landed_seconds("clear", 0.92) * ev_c) - 1
    out(f"- A player who walks into the called front itself (Showers type) earns +{gain_s:.0%} coins per minute "
        f"for up to 5 min, the same as a natural Showers front plus the +25% luck: at most "
        f"{gain_s * 5:.1f} extra minutes of income per call.")
    # pacing sensitivity: casual in a server with D6 fronts the maximum allowed time
    max_share = CALLED_FRONT["maxPerStormCycle"] * CALLED_FRONT["lingerSeconds"] / (
        STORM["periodSeconds"] - STORM["durationSeconds"])
    rows = []
    for name in ("casual", "typical"):
        base = [run_model(name, ph, track_species=False)[0] for ph in PHASES_MIN]
        d6 = [run_model(name, ph, called_front_share=max_share, track_species=False)[0] for ph in PHASES_MIN]
        def mean_ev(ps, key):
            v = [p.events.get(key) for p in ps]
            return sum(x for x in v if x) / 60 / len([x for x in v if x]) if any(v) else float("nan")
        for key, label in GOALS[1:3] + [GOALS[4]]:
            b, d = mean_ev(base, key), mean_ev(d6, key)
            rows.append([MODELS[name]["label"], label, f"{b:.1f}", f"{d:.1f}", f"{(b - d) / b:.1%}"])
    table(["Model", "Goal", "No Called Fronts", f"Called Front active {max_share:.0%} of non-storm time (max allowed)",
           "Time saved"], rows)

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
    out("### Size roll (Config/Fish.luau sizeRoll)")
    out()
    out(f"factor = clamp(exp(N(-{SIZE_SIGMA}^2/2, {SIZE_SIGMA})), {SIZE_CLAMP[0]}, {SIZE_CLAMP[1]}); kg = species average kg x factor x weather size. "
        f"1M rolls: mean {sum(sizes) / n:.4f}, median {sizes[n // 2]:.3f}, p99 {sizes[int(n * 0.99)]:.3f}, "
        f"share >= 1.5x {sum(1 for s in sizes if s >= 1.5) / n:.2%}, share >= 2x {sum(1 for s in sizes if s >= 2.0) / n:.3%}.")
    out()

    # ---------------------------------------------------------------- pots and passive share
    out("## L. Tide Pots and passive share (Config/TidePots.luau)")
    out()
    rows = []
    for eff_pct in (25, 10, 5, 100 / 60):
        full = TIDE_POTS["fillCapHours"] * 60 * eff_pct / 100
        m = MODELS["typical"]
        per_day = 2 * (full + full * min(8, m["sameDayGapHours"]) / 8)
        active = m["sessionMin"] * m["sessionsPerDay"]
        rows.append([f"{eff_pct:.2f}%" + (" (chosen)" if eff_pct < 2 else ""), f"{full:.0f}", f"{per_day:.0f}",
                     f"{per_day / (per_day + active):.0%}"])
    table(["Pot rate vs active income", "Full pot (8 h) in minutes of income", "2 pots, typical, minutes of income per day",
           "Passive share of a typical day (40 active min)"], rows)
    out()

    text = "\n".join(OUT) + "\n"
    sys.stdout.write(text)
    if args.out:
        with open(args.out, "w", encoding="utf-8") as fh:
            fh.write(text)


def tide_cycles(name: str, wanted: list[int]) -> dict[int, tuple[float, float]]:
    """Long horizon: time for each New Tide, no rewards, species not tracked, 5 s steps (EV scaled)."""
    p = Player(MODELS[name], 0, include_rewards=False, track_species=False)
    res: dict[int, tuple[float, float]] = {}
    last = 0
    limit = 200 * 3600
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
