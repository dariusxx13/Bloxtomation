#!/usr/bin/env python3
"""Reel the Storm (game id `stormcatch`): the numbers behind the product catalog.

Tasks T-0009 (v1, 2026-10-25) and T-0018 (v2, 2026-10-26), Monetization Designer, design stage.

Run from the repository root:

    python3 games/stormcatch/docs/models/catalog_numbers.py --out games/stormcatch/docs/models/catalog_numbers_output.txt

Standard library only, deterministic (no randomness). It reads no files: every input below is copied from
the accepted economy sheet v2 (games/stormcatch/docs/economy-sheet.md, T-0008 and T-0015, section noted on
each block) or is a catalog draft value (prices, pack sizes, Auto Reel limits) from
games/stormcatch/docs/catalog.md. It recomputes the economist's Sky Bell figures as a cross-check, then the
catalog's own figures: odds before and after each paid luck item, Auto Reel against active play, coin value
per Robux, the Sky Bell price parity, the cost of the whole catalog and (v2) the coin-product basis.
Nothing here edits game code or prices.

v2 (T-0018): luck multipliers print rounded half up, as the sheet rounds them (5.625 -> x5.63; Python's
default would print x5.62), and section [G] shows the sheet v2 section 19.2 coin basis, which leaves the
2x Coins pass out of every minutes-of-income grant. No economy input changed between sheet v1 and v2.
"""

from __future__ import annotations

import argparse
import sys
from decimal import ROUND_HALF_UP, Decimal

# --- Economy sheet inputs -----------------------------------------------------------------------------

# Sheet section 9.1: tier coin values at Rod 0 (base 5 x tierValue) and which tiers luck multiplies.
TIER_VALUE = {"Common": 5, "Uncommon": 10, "Rare": 20, "Epic": 50, "Legendary": 150}
LUCK_TIERS = {"Rare", "Epic", "Legendary", "Mythic", "Secret"}
TIER_ORDER = ["Common", "Uncommon", "Rare", "Epic", "Legendary"]

# Sheet section 9.2: Pebble Cove (the harbour, where every Sky Bell call lands) and the weather-only rows.
PEBBLE_COVE = [
    ("pebble_minnow", "Common", 26),
    ("bobblefin", "Common", 22),
    ("sandskipper", "Common", 18),
    ("tidetail", "Uncommon", 13),
    ("kelpnibbler", "Uncommon", 11),
    ("copperscale", "Rare", 4.7),
    ("pc_rare_2", "Rare", 3.8),
    ("pc_epic_1", "Epic", 2.0),
]
WEATHER_ONLY = {
    "Clear": [],
    "Showers": [("splashkin", "Uncommon", 15), ("pitterpike", "Rare", 6.5), ("rain_epic", "Epic", 1.5)],
    "Sea Fog": [("hushgill", "Rare", 6.0), ("lanternfin", "Epic", 2.2), ("fog_legendary", "Legendary", 0.5)],
    "Gusts": [("gust_rare", "Rare", 12), ("gust_epic", "Epic", 4.5), ("gust_legendary", "Legendary", 1.0)],
}
# Sheet section 9.4: one mark per fish; expected-value factor of the weather's mark.
MARK_EV = {"Clear": 1.0, "Showers": 1.10, "Sea Fog": 1.15, "Gusts": 1.10}
# Sheet section 9.3: Gusts multiply size (and value) by 1.25.
SIZE_EV = {"Clear": 1.0, "Showers": 1.0, "Sea Fog": 1.0, "Gusts": 1.25}

# Sheet section 10: Sky = min(1.00, natural + min(0.25, paid) + free timed); total luck capped at x6.
NATURAL_SKY = {"Clear": 0.0, "Showers": 0.0, "Sea Fog": 1.0, "Gusts": 0.0}
SKY_CAP = 1.0
PAID_CAP = 0.25
TOTAL_CAP = 6.0

# Sheet section 3.2: catch cycle in Clear (cast 1.0 s + bite wait + reel + reveal; a failed reel costs
# cast + wait + reel + 1 s). Reel success: casual 85%, typical 92%. Showers: wait 1.75, reel 1.0, +8 points.
CLEAR = {"cast": 1.0, "wait": 3.5, "reel": 1.5, "reveal": 1.5}
SHOWERS = {"cast": 1.0, "wait": 1.75, "reel": 1.0, "reveal": 1.5}
REEL_SUCCESS = {"casual": 0.85, "typical": 0.92}
SHOWERS_SUCCESS_BONUS = 0.08

# Sheet section 13: one called front gives a player at the harbour about 3.1 extra minutes of harbour
# income (a called Showers pays +105% per minute against Clear, for 3 minutes).
CALL_MINUTES_PER_PLAYER = 3.1
CALL_SECONDS = 180
# GDD section 4.10: success target, a median of 3 or more players other than the buyer catch under a call.
CALL_TARGET_OTHERS = 3
# GDD section 4.10: at most 2 calls start per 15-minute storm cycle in one server.
CALLS_PER_CYCLE = 2

# Sheet section 12.3: Tide Pots fill at 0.5 minute of active income per pot-hour, 8 h cap, 1 fish per hour.
POT_MINUTES_PER_HOUR = 0.5
POT_HOURS = 8
POT_FISH = 8

# --- Catalog draft values (catalog.md sections 2 and 3) -----------------------------------------------

# Auto Reel (catalog 3.3): Clear-ring water only; lands 70% of bites; each reel takes twice as long.
AUTO_SUCCESS = 0.70
AUTO_REEL_FACTOR = 2.0

# Draft Robux prices (the human sets the real ones in Creator Hub; UI always reads them at runtime).
PRICES = {
    "skyCallShowers": 49,
    "skyCallSeaFog": 49,
    "skyCallGusts": 49,
    "coinPouch": 49,
    "bobberBox": 75,
    "starterPack": 75,
    "palPouchPlus": 99,
    "rainGear": 99,
    "autoReel": 149,
    "luckyBobber": 149,
    "tidePot3": 149,
    "coinCrate": 149,
    "x2Coins": 249,
    "coinChest": 399,
    "lanternKeeper": 699,
}
GAMEPLAY_PASSES = ["x2Coins", "autoReel", "luckyBobber", "palPouchPlus", "tidePot3"]
COSMETIC_PASSES = ["rainGear", "bobberBox", "lanternKeeper"]
# Minutes of income per coin product (catalog 3.7 and 3.8).
COIN_MINUTES = {"coinPouch": 15, "starterPack": 30, "coinCrate": 60, "coinChest": 180}

# Sheet v2 sections 3.1 and 19.2: one minutes-of-income basis for every grant. It counts permanent
# multipliers only (best island in Clear, Rod, companions, bonus category, New Tide, Lure, owned luck passes)
# and never timed boosts, friends or the 2x Coins pass. Section [G] uses an example rate of 100 coins a
# minute on that basis; the ratios, not the 100, are the point.
EXAMPLE_RATE = 100
X2_PASS_FACTOR = 2  # the 2x Coins pass doubles what a pass owner earns by fishing (sheet section 11)
TIMED_BOOST_FACTOR = 2  # a timed coins2x while active (additive with the pass, cap x3)

# Vault 09-monetization/pricing-and-price-ladders.md: tier bands in Robux.
TIERS = [("Impulse", 15, 99), ("Core", 100, 499), ("Premium", 500, 1499), ("High-end", 1500, 10**9)]


# --- Helpers -------------------------------------------------------------------------------------------


def half_up(value: float) -> str:
    """Two decimals, rounded half up as the economy sheet prints luck (5.625 -> 5.63)."""
    return str(Decimal(repr(value)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP))


def sky_luck(weather: str, paid: float, free: float = 0.0) -> float:
    """The Sky category (sheet section 10)."""
    return min(SKY_CAP, NATURAL_SKY[weather] + min(PAID_CAP, paid) + free)


def luck_multiplier(weather: str, paid: float, gear: float = 0.0, comp: float = 0.0, friends: float = 0.0) -> float:
    return min(TOTAL_CAP, (1 + gear) * (1 + comp) * (1 + friends) * (1 + sky_luck(weather, paid)))


def table(weather: str) -> list[tuple[str, str, float]]:
    return PEBBLE_COVE + WEATHER_ONLY[weather]


def odds(weather: str, luck: float) -> dict[str, float]:
    rows = [(name, tier, weight * (luck if tier in LUCK_TIERS else 1.0)) for name, tier, weight in table(weather)]
    total = sum(w for _, _, w in rows)
    return {name: w / total for name, _, w in rows}


def tier_odds(weather: str, luck: float) -> dict[str, float]:
    per_species = odds(weather, luck)
    result = {tier: 0.0 for tier in TIER_ORDER}
    for name, tier, _ in table(weather):
        result[tier] += per_species[name]
    return result


def coin_value(weather: str, luck: float) -> float:
    per_species = odds(weather, luck)
    base = sum(per_species[name] * TIER_VALUE[tier] for name, tier, _ in table(weather))
    return base * MARK_EV[weather] * SIZE_EV[weather]


def catches_per_minute(cycle: dict[str, float], success: float, reel_factor: float = 1.0) -> float:
    reel = cycle["reel"] * reel_factor
    ok = cycle["cast"] + cycle["wait"] + reel + cycle["reveal"]
    fail = cycle["cast"] + cycle["wait"] + reel + 1.0
    expected_seconds = success * ok + (1 - success) * fail
    return 60.0 * success / expected_seconds


def tier_of(price: int) -> str:
    for name, low, high in TIERS:
        if low <= price <= high:
            return name
    return "below impulse"


# --- Sections ------------------------------------------------------------------------------------------


def section_a(out: list[str]) -> None:
    out.append("[A] Cross-check of the economy sheet's Sky Bell figures (sheet section 13), harbour = Pebble Cove")
    out.append(f"{'Called weather':<14} {'luck before':>11} {'luck after':>10} {'Rare+ before':>12} {'Rare+ after':>11} {'coins/catch':>11}")
    for weather in ("Showers", "Sea Fog", "Gusts"):
        before = luck_multiplier(weather, paid=0.0)
        after = luck_multiplier(weather, paid=0.25)
        rare_before = sum(v for t, v in tier_odds(weather, before).items() if t in LUCK_TIERS)
        rare_after = sum(v for t, v in tier_odds(weather, after).items() if t in LUCK_TIERS)
        coins = coin_value(weather, after) / coin_value(weather, before) - 1
        out.append(
            f"{weather:<14} {half_up(before):>11} {half_up(after):>10} {rare_before:>12.2%} {rare_after:>11.2%} {coins:>+11.1%}"
        )
    out.append("Sheet values: Showers 14.98% -> 18.05%, +6.0%; Sea Fog 29.91% -> 29.91%, 0; Gusts 23.73% -> 28.00%, +8.8%.")
    out.append("")


def section_b(out: list[str]) -> None:
    out.append("[B] Tier odds shown before purchase (new player at the harbour: no Lure, companions or friends)")
    cases = [
        ("Lucky Bobber, Clear", "Clear", 0.0, 0.25),
        ("Lucky Bobber, Sea Fog (Sky cap)", "Sea Fog", 0.0, 0.25),
        ("Sky Bell: Showers", "Showers", 0.0, 0.25),
        ("Sky Bell: Sea Fog (Sky cap)", "Sea Fog", 0.0, 0.25),
        ("Sky Bell: Gusts", "Gusts", 0.0, 0.25),
        ("Bobber owner under a Showers call", "Showers", 0.25, 0.50),
    ]
    header = f"{'Case':<36} {'luck':>11} " + " ".join(f"{t:>17}" for t in TIER_ORDER)
    out.append(header)
    for label, weather, paid_before, paid_after in cases:
        before = luck_multiplier(weather, paid=paid_before)
        after = luck_multiplier(weather, paid=paid_after)
        tb = tier_odds(weather, before)
        ta = tier_odds(weather, after)
        cells = " ".join(f"{tb[t]:>7.2%} -> {ta[t]:>6.2%}" for t in TIER_ORDER)
        out.append(f"{label:<36} {half_up(before):>4}->{half_up(after):<5} {cells}")
        assert abs(sum(ta.values()) - 1.0) < 1e-12 and abs(sum(tb.values()) - 1.0) < 1e-12
    out.append("Every row sums to exactly 100% before and after (asserted).")
    out.append("")
    out.append("Paid luck never stacks above +25% (sheet section 10):")
    for gear, comp, friends, label in ((0, 0, 0, "new player"), (0.28, 0, 0, "casual, Lure 7"), (1.0, 0.5, 0.5, "maxed free")):
        for weather in ("Clear", "Sea Fog"):
            values = [
                luck_multiplier(weather, paid, gear, comp, friends) for paid in (0.0, 0.25, 0.50)
            ]
            out.append(
                f"  {label:<15} {weather:<8} no paid luck x{half_up(values[0])} | Bobber or Bell x{half_up(values[1])} | Bobber and Bell x{half_up(values[2])}"
            )
    out.append("")


def section_c(out: list[str]) -> None:
    out.append("[C] Auto Reel against reeling yourself (catches per minute; sheet section 3.2 cycle model)")
    auto_clear = catches_per_minute(CLEAR, AUTO_SUCCESS, AUTO_REEL_FACTOR)
    out.append(f"Auto Reel in Clear water: {auto_clear:.2f} per minute (lands {AUTO_SUCCESS:.0%}, reel x{AUTO_REEL_FACTOR:g})")
    for player, success in REEL_SUCCESS.items():
        clear = catches_per_minute(CLEAR, success)
        showers = catches_per_minute(SHOWERS, min(0.98, success + SHOWERS_SUCCESS_BONUS))
        out.append(
            f"  {player:<8} active Clear {clear:.2f} (Auto = {auto_clear / clear:.0%}); "
            f"active Showers {showers:.2f} (Auto = {auto_clear / showers:.0%})"
        )
    out.append("Coins per catch are the same, so the coin ratio equals the catch ratio. Auto Reel pauses under")
    out.append("Showers, Sea Fog, Gusts and the Great Storm, so it can only ever earn the Clear-water rate.")
    out.append("")


def section_d(out: list[str]) -> None:
    out.append("[D] Coin products: minutes of income per Robux at the draft prices")
    base = COIN_MINUTES["coinPouch"] / PRICES["coinPouch"]
    for key, minutes in COIN_MINUTES.items():
        rate = minutes / PRICES[key]
        out.append(
            f"  {key:<12} {minutes:>4} min for {PRICES[key]:>4} R = {rate:.3f} min/R ({rate / base - 1:+.0%} against the Pouch)"
        )
    out.append("The Starter Pack also carries a 15-minute coins2x boost and a raincoat colour (not counted above).")
    out.append("")
    out.append("Third Tide Pot (sheet section 12.3): one more pot = "
               f"{POT_MINUTES_PER_HOUR * POT_HOURS:.0f} minutes of income and {POT_FISH} fish per full 8-hour fill.")
    out.append("")


def section_e(out: list[str]) -> None:
    out.append("[E] Sky Bell price parity")
    price = PRICES["skyCallShowers"]
    players = CALL_TARGET_OTHERS + 1
    server_minutes = players * CALL_MINUTES_PER_PLAYER
    pouch_rate = COIN_MINUTES["coinPouch"] / PRICES["coinPouch"]
    out.append(
        f"  One call at {price} R: {players} players (buyer + {CALL_TARGET_OTHERS}, GDD target) x {CALL_MINUTES_PER_PLAYER} min "
        f"= {server_minutes:.1f} player-minutes of harbour income = {server_minutes / price:.3f} min/R"
    )
    out.append(f"  Coin Pouch at {PRICES['coinPouch']} R: 15 minutes for one player = {pouch_rate:.3f} min/R")
    out.append(f"  The buyer's own share: {CALL_MINUTES_PER_PLAYER} min = {CALL_MINUTES_PER_PLAYER / price:.3f} min/R (a gift, not a deal)")
    for alt in (25, 49, 99):
        out.append(
            f"  At {alt:>3} R a call would give {server_minutes / alt:.3f} server min/R, "
            f"{server_minutes / alt / pouch_rate:.2f}x the Pouch's rate"
        )
    calls_per_hour = CALLS_PER_CYCLE * 4
    out.append(
        f"  Most one server can buy: {CALLS_PER_CYCLE} calls per 15-minute cycle = {calls_per_hour} per hour; "
        f"one buyer with one call per cycle (GDD v3 section 4.10) at most 4 per hour = {4 * price} R per hour"
    )
    out.append("")


def section_f(out: list[str]) -> None:
    out.append("[F] Ladder and totals at the draft prices")
    counts: dict[str, int] = {}
    for key, price in sorted(PRICES.items(), key=lambda kv: (kv[1], kv[0])):
        tier = tier_of(price)
        counts[tier] = counts.get(tier, 0) + 1
        out.append(f"  {price:>4} R  {tier:<8} {key}")
    out.append("  Items per tier: " + ", ".join(f"{name} {counts.get(name, 0)}" for name, _, _ in TIERS))
    gameplay = sum(PRICES[k] for k in GAMEPLAY_PASSES)
    cosmetic = sum(PRICES[k] for k in COSMETIC_PASSES)
    out.append(f"  All gameplay passes together: {gameplay} R; all cosmetic passes: {cosmetic} R; every pass: {gameplay + cosmetic} R")
    out.append(f"  Cheapest item: {min(PRICES.values())} R; most expensive: {max(PRICES.values())} R")
    out.append("")


def section_g(out: list[str]) -> None:
    out.append("[G] Coin-product basis (sheet v2 sections 3.1 and 19.2), at an example rate of "
               f"{EXAMPLE_RATE} coins a minute on the permanent basis")
    out.append(f"{'Product':<12} {'min':>4} {'v2 grant':>9} {'v1 draft, pass owner':>21} {'v2, pass owner':>15} "
               f"{'v2, coins2x on':>15} {'pass owner fishing to earn it':>30}")
    for key, minutes in COIN_MINUTES.items():
        v2 = minutes * EXAMPLE_RATE
        v1_pass_owner = v2 * X2_PASS_FACTOR  # the v1 catalog draft counted the pass in the basis
        v2_pass_owner = v2  # the pass is left out
        v2_boosted = v2  # timed boosts never count
        own_minutes = v2 / (EXAMPLE_RATE * X2_PASS_FACTOR)
        out.append(
            f"{key:<12} {minutes:>4} {v2:>9,} {v1_pass_owner:>21,} {v2_pass_owner:>15,} {v2_boosted:>15,} "
            f"{own_minutes:>25.1f} min"
        )
        assert v2_pass_owner == v2 and v2_boosted == v2
    out.append("On the v2 basis a grant is the same for every player with the same permanent progress, whatever")
    out.append("they bought or whatever boost is running. A 2x Coins owner earns it by fishing in half the minutes,")
    out.append("so the copy says 'about M minutes of fishing', not 'of your fishing' (sheet section 19.2).")
    out.append("")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[1])
    parser.add_argument("--out", help="also write the output to this file")
    args = parser.parse_args()
    out: list[str] = [
        "Reel the Storm catalog numbers (T-0009, v2 T-0018). Inputs: economy-sheet.md v2 (T-0008, T-0015) and catalog.md v2.",
        "",
    ]
    for section in (section_a, section_b, section_c, section_d, section_e, section_f, section_g):
        section(out)
    text = "\n".join(out)
    print(text)
    if args.out:
        with open(args.out, "w", encoding="utf-8") as handle:
            handle.write(text + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
