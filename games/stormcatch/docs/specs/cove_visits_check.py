#!/usr/bin/env python3
# Run: python3 games/stormcatch/docs/specs/cove_visits_check.py   (designer, T-0014, 2026-10-26)
# Feasibility check for GDD v3 section 4.2 rule 8 (Cove Fog and Cove Gusts visits, which close catalog W1 and W2).
# It uses an ILLUSTRATIVE launch harbour pattern, not a binding timetable: the Weather config sets the real one,
# and its WeatherSchedule tests must hold the same invariants (GDD 4.2 rule 8, 4.10 schedule guarantee).
# Spots: S = cove_shallows, P = pier_head (both Callable). The sheltered Dock Ripple is never under a front.
CYCLE, STORM_END = 900, 180
GUARD = lambda ct: ct < STORM_END + 30 or ct >= CYCLE - 60  # no Sky Bell call here (GDD 4.10 slot rule 3)

# Harbour Showers in every cycle, in the world plan's direction (cove_shallows, then pier_head; world plan 7).
BASE = [("S", 200, 300, "showers"), ("P", 300, 400, "showers"), ("S", 640, 740, "showers"), ("P", 740, 840, "showers")]
VISITS = {"fog": [("P", 200, 300, "fog")], "gusts": [("P", 640, 740, "gusts")]}  # each just before Showers reaches P


def visit_kind(cycle: int):
    """One fog cycle and one gusts cycle in every clock hour, two cycles apart (hash stands in for the hour hash)."""
    hour, k = divmod(cycle, 4)
    fog_slot = (hour * 2654435761) % 4
    return "fog" if k == fog_slot else "gusts" if k == (fog_slot + 2) % 4 else None


def fronts(cycle: int):
    kind = visit_kind(cycle)
    return BASE + (VISITS[kind] if kind else [])


def weather(t: int, spot: str, with_visits: bool = True) -> str:
    cycle, ct = divmod(t, CYCLE)
    if ct < STORM_END:
        return "storm"
    fl = fronts(cycle) if with_visits else BASE
    for s, a, b, w in fl:
        if s == spot and a <= ct < b:
            return w
    # Rainbow rule (GDD 4.2 rule 5): 60 s on a spot a Showers front has just left, if the spot turned Clear.
    for s, a, b, w in fl:
        if s == spot and w == "showers" and b <= ct < b + 60:
            if not any(s2 == spot and a2 <= b < b2 for s2, a2, b2, _ in fl):
                return "rainbow"
    return "clear"


HOURS = 24 * 7
T = range(0, HOURS * 3600)
# 1. Rain for onboarding step 7: the longest wait from any join second (GDD 4.2 rule 3: about 4.5 min).
rain = [t for t in T if weather(t, "S") == "showers" or weather(t, "P") == "showers"]
worst, j = 0, 0
for r in rain:
    worst = max(worst, r - j)
    j = r + 1
print(f"1. longest wait for rain over 7 days: {worst} s (limit about 270)")
# 2. Sky Bell: a 180 s clear-harbour window outside the storm guard in every cycle (GDD 4.10 schedule guarantee).
bad = 0
for c in range(HOURS * 4):
    run = best = 0
    for ct in range(CYCLE):
        t = c * CYCLE + ct
        ok = not GUARD(ct) and weather(t, "S") == "clear" and weather(t, "P") == "clear"
        run = run + 1 if ok else 0
        best = max(best, run)
    bad += best < 180
print(f"2. cycles without a 180 s clear-harbour window: {bad} of {HOURS * 4}")
# 3. Every clock hour has natural Sea Fog and Gusts on a Pebble Cove front spot for 90 s or more.
short = []
for h in range(HOURS):
    for w in ("fog", "gusts"):
        secs = sum(1 for t in range(h * 3600, (h + 1) * 3600) for sp in "SP" if weather(t, sp) == w)
        if secs < 90:
            short.append((h, w, secs))
print(f"3. hours missing a 90 s fog or gusts visit: {len(short)} of {HOURS}")
# 4. Visits never replace a Rainbow.
rb_with = sum(1 for t in T for sp in "SP" if weather(t, sp) == "rainbow")
rb_without = sum(1 for t in T for sp in "SP" if weather(t, sp, False) == "rainbow")
print(f"4. Rainbow seconds with visits {rb_with}, without {rb_without}: {'same' if rb_with == rb_without else 'DIFFERENT'}")
# 5. Harbour front coverage outside storms (for the Economist and the twist index baseline).
for label, wv in (("without visits", False), ("with visits", True)):
    cov = sum(1 for t in T if t % CYCLE >= STORM_END for sp in "SP" if weather(t, sp, wv) in ("showers", "fog", "gusts"))
    print(f"5. harbour front coverage {label}: {cov / (2 * HOURS * 4 * (CYCLE - STORM_END)):.4f}")
ok = worst <= 270 and bad == 0 and not short and rb_with == rb_without
print("All checks pass" if ok else "CHECK FAILED")
raise SystemExit(0 if ok else 1)
