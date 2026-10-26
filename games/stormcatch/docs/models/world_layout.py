#!/usr/bin/env python3
"""Reel the Storm (stormcatch) world layout model (T-0011, Worldbuilder, design stage).

One source of truth for the world plan: coordinates of walkways, fishing spots, bridges,
weather cells, front paths, the ferry route and landmarks. It computes walking distances
(shortest path over the walkway graph), checks the cozy distance rules and the first-frame
sightlines, and draws the top-down map as SVG.

Run (stdlib only):
    python3 games/stormcatch/docs/models/world_layout.py
    python3 games/stormcatch/docs/models/world_layout.py --svg games/stormcatch/docs/world-map.svg

Coordinates are Roblox world studs: +X east, +Z south (north is -Z, the default LookVector),
+Y up. Sea level (terrain water surface) is Y = 0. A node's Y is the walking surface.
"""

from __future__ import annotations

import argparse
import heapq
import math
import sys
from typing import Dict, List, Optional, Tuple

Vec = Tuple[float, float, float]

LAYOUT_VERSION = "v2 (T-0016, 2026-10-26)"  # v1 T-0011 2026-10-25; v2 adds the GDD v3 harbour visits and harbour WindYaw

# ---------------------------------------------------------------------------------------------
# Template facts (cited in world-plan.md)
# ---------------------------------------------------------------------------------------------
BASE_WALK_SPEED = 16.0  # src/shared/Util/Stats.luau:103  walkSpeed = 16 + speed level * effect
MAX_TEMPLATE_WALK_SPEED = 32.0  # Config/Upgrades.luau speed: effect 1 per level, maxLevel 16
HIT_RANGE = 28.0  # src/shared/Config/Economy.luau:10 hitRange (client range; server adds 8)
SERVER_MARGIN = 8.0  # src/server/Systems/Nodes.luau:26 LATENCY_RANGE_MARGIN
ROOT_ABOVE_FLOOR = 3.0  # HumanoidRootPart centre above the floor (default avatar, approximate)

# ---------------------------------------------------------------------------------------------
# Design rules (loop-sketch.md section 3, converted to studs at base walk speed)
# ---------------------------------------------------------------------------------------------
ADJACENT_RULE_S = 15.0  # "adjacent spots at most about 15 s apart at base walk speed"
ADJACENT_TARGET_S = 12.5  # our margin: 2.5 s for turns, other players and hesitation
WARNING_S = 60.0  # "a front is announced at least 60 s before it reaches a spot"
ANY_SPOT_TARGET_S = 45.0  # reach any announced front with >= 15 s of the warning left
STORM_GATHER_TARGET_S = 45.0  # any spot to the Open Pier head
WIND_CAST_RANGE = 44.0  # proposed: Gusts wind-assisted cast reach (loop sketch: about 2x)
CELL_RADIUS = 36.0  # WeatherCell radius (one front covers about one spot's area)
FERRY_CLEARANCE = 20.0  # ferry route keeps this far from every spot centre
FERRY_SPEED = 20.0  # studs/s, proposed
CORE_CONE_DEG = 35.0  # must-see items: inside this half-angle on every phone
FRAME_CONE_DEG = 43.0  # visible on 4:3 tablets and anything wider (vertical FOV 70)
SPAWN_CAMERA: Vec = (0.0, 12.5, 12.0)  # default camera ~12 studs behind and above spawn

# ---------------------------------------------------------------------------------------------
# Islands (zone ids proposed for Config/Zones.luau)
# ---------------------------------------------------------------------------------------------
ZONES = [
    ("pebble_cove", "Pebble Cove", 1, "Showers"),
    ("lantern_reef", "Lantern Reef", 2, "SeaFog"),
    ("gustwhistle_bluffs", "Gustwhistle Bluffs", 3, "Gusts"),
    ("thunderhead_point", "Thunderhead Point", 4, "Mixed"),
]

# ---------------------------------------------------------------------------------------------
# Walkway graph nodes: name -> (position, zone or "bridge", label)
# ---------------------------------------------------------------------------------------------
NODES: Dict[str, Tuple[Vec, str, str]] = {
    # Pebble Cove: Driftlight Harbor quay (deck Y 4), Pebble Point (west arm), Gull Point (east arm)
    "SPAWN": ((0, 4, 0), "pebble_cove", "PlayerSpawn on the harbour dock, facing north"),
    "Q_W": ((-36, 4, -2), "pebble_cove", "Quay, west end (foot of Pebble Point)"),
    "Q_E": ((20, 4, -2), "pebble_cove", "Quay at the Open Pier root"),
    "Q_E2": ((68, 4, -2), "pebble_cove", "Quay, east end (foot of Gull Point)"),
    "WA_MID": ((-52, 5, -30), "pebble_cove", "Pebble Point path"),
    "ST_cove_shallows": ((-37, 5, -52), "pebble_cove", "Cove Shallows stand"),
    "GATE_lantern_reef": ((-50, 5, -76), "pebble_cove", "Bridge 1 gate (Pebble Point tip)"),
    "PIER_MID": ((20, 4, -40), "pebble_cove", "Open Pier, ferry slip side"),
    "LOOKOUT": ((10, 4, -66), "pebble_cove", "Harbour Master's lookout (weathervane), west side"),
    "PIER_HEAD": ((20, 4, -80), "pebble_cove", "Open Pier head (36 x 20)"),
    "ST_pier_head": ((20, 4, -89), "pebble_cove", "Pier Head stand"),
    "ST_cove_dock": ((0, 4, -3), "pebble_cove", "Harbor Dock stand (dock edge)"),
    "EA_MID": ((82, 5, -40), "pebble_cove", "Gull Point path"),
    "NET_E": ((64, 5, -80), "pebble_cove", "Net Walk landing on the Gull Point tip"),
    "GATE_gustwhistle_bluffs": ((100, 5, -55), "pebble_cove", "Bridge 2 gate (Gull Point east shore)"),
    "GATE_thunderhead_point": ((78, 5, -80), "pebble_cove", "Bridge 3 gate (Gull Point tip)"),
    "NEST_pebble": ((-16, 4, 6), "pebble_cove", "Driftwood Nest"),
    "SLIP_harbor": ((31, 4, -40), "pebble_cove", "Ferry slip, east side of the Open Pier (east basin)"),
    # Lantern Reef: an atoll ring of islets joined by boardwalks (deck Y 5)
    "L_LAND": ((-102, 5, -135), "lantern_reef", "Bridge 1 landing"),
    "ST_reef_steps": ((-88, 5, -175), "lantern_reef", "Lantern Steps stand"),
    "L_NE": ((-106, 5, -215), "lantern_reef", "Ring boardwalk NE"),
    "L_SQ": ((-138, 5, -218), "lantern_reef", "Lantern Square (Great Lantern, Reef Nest)"),
    "L_NW": ((-193, 5, -212), "lantern_reef", "Ring boardwalk NW"),
    "ST_reef_outer": ((-213, 5, -180), "lantern_reef", "Outer Reef stand"),
    "L_SW": ((-198, 5, -138), "lantern_reef", "Ring boardwalk SW"),
    "ST_reef_lagoon": ((-153, 5, -140), "lantern_reef", "Glow Lagoon stand"),
    "SLIP_reef": ((-140, 4, -242), "lantern_reef", "Ferry slip, north rim"),
    # Gustwhistle Bluffs: landing at Y 6, ledges at Y 12, ridge at Y 18
    "G_LAND": ((150, 6, -50), "gustwhistle_bluffs", "Bridge 2 landing"),
    "G_RAMP": ((165, 10, -72), "gustwhistle_bluffs", "Ramp to the ledges"),
    "ST_kite_ledge": ((180, 12, -90), "gustwhistle_bluffs", "Kite Ledge stand"),
    "G_TOP": ((215, 18, -70), "gustwhistle_bluffs", "Ridge (Whistle Rock, Bluff Nest)"),
    "ST_whistle_point": ((260, 12, -85), "gustwhistle_bluffs", "Whistle Point stand"),
    # Thunderhead Point: landing Y 5, spire plaza Y 8
    "T_LAND": ((90, 5, -150), "thunderhead_point", "Bridge 3 landing"),
    "ST_squall_rocks": ((116, 5, -172), "thunderhead_point", "Squall Rocks stand (east shore)"),
    "T_SPIRE": ((105, 8, -200), "thunderhead_point", "Spire plaza (Thunder Spire, Storm Nest)"),
    "ST_anvil_reach": ((98, 6, -268), "thunderhead_point", "Anvil Reach stand"),
    "SLIP_thunder": ((48, 4, -215), "thunderhead_point", "Ferry slip, west shore"),
}

EDGES: List[Tuple[str, str]] = [
    # Pebble Cove
    ("SPAWN", "ST_cove_dock"),
    ("SPAWN", "NEST_pebble"),
    ("SPAWN", "Q_W"),
    ("SPAWN", "Q_E"),
    ("Q_E", "Q_E2"),
    ("Q_W", "WA_MID"),
    ("Q_W", "ST_cove_shallows"),
    ("WA_MID", "ST_cove_shallows"),
    ("ST_cove_shallows", "GATE_lantern_reef"),
    ("WA_MID", "GATE_lantern_reef"),
    ("Q_E", "PIER_MID"),
    ("PIER_MID", "SLIP_harbor"),
    ("PIER_MID", "LOOKOUT"),
    ("LOOKOUT", "PIER_HEAD"),
    ("PIER_MID", "PIER_HEAD"),
    ("PIER_HEAD", "ST_pier_head"),
    ("PIER_HEAD", "NET_E"),  # Net Walk: arched footbridge, pier head to Gull Point tip (10 studs clearance)
    ("Q_E2", "EA_MID"),
    ("EA_MID", "NET_E"),
    ("EA_MID", "GATE_gustwhistle_bluffs"),
    ("NET_E", "GATE_gustwhistle_bluffs"),
    ("NET_E", "GATE_thunderhead_point"),
    # Bridges (deck beyond each gate belongs to the next island's ZoneBounds)
    ("GATE_lantern_reef", "L_LAND"),
    ("GATE_gustwhistle_bluffs", "G_LAND"),
    ("GATE_thunderhead_point", "T_LAND"),
    # Lantern Reef ring
    ("L_LAND", "ST_reef_steps"),
    ("ST_reef_steps", "L_NE"),
    ("L_NE", "L_SQ"),
    ("L_SQ", "SLIP_reef"),
    ("L_SQ", "L_NW"),
    ("L_NW", "ST_reef_outer"),
    ("ST_reef_outer", "L_SW"),
    ("L_SW", "ST_reef_lagoon"),
    ("ST_reef_lagoon", "L_LAND"),
    # Gustwhistle Bluffs
    ("G_LAND", "G_RAMP"),
    ("G_RAMP", "ST_kite_ledge"),
    ("G_RAMP", "G_TOP"),
    ("G_TOP", "ST_whistle_point"),
    ("ST_kite_ledge", "ST_whistle_point"),
    # Thunderhead Point
    ("T_LAND", "ST_squall_rocks"),
    ("T_LAND", "T_SPIRE"),
    ("T_SPIRE", "ST_anvil_reach"),
    ("ST_squall_rocks", "ST_anvil_reach"),
    ("T_SPIRE", "SLIP_thunder"),
]

BRIDGES = [
    ("lantern_reef", "GATE_lantern_reef", "L_LAND", "Bridge 1, Pebble Point to Lantern Reef"),
    ("gustwhistle_bluffs", "GATE_gustwhistle_bluffs", "G_LAND", "Bridge 2, Gull Point to Gustwhistle Bluffs"),
    ("thunderhead_point", "GATE_thunderhead_point", "T_LAND", "Bridge 3, Gull Point to Thunderhead Point"),
]

# ---------------------------------------------------------------------------------------------
# Fishing spots (ResourceNode). kind: regular | pool (Showers only) | lantern (Sea Fog only)
# | far (Gusts only, wind cast) | eye (Great Storm only). cell = CellId (a regular spot's NodeId).
# ---------------------------------------------------------------------------------------------
SPOTS: List[Dict] = [
    # Pebble Cove
    dict(id="cove_dock", name="Dock Ripple", zone="pebble_cove", stand="ST_cove_dock", pos=(-5, 0, -10), kind="regular", cell="cove_dock", proto=True, sheltered=True),
    dict(id="cove_shallows", name="Cove Shallows", zone="pebble_cove", stand="ST_cove_shallows", pos=(-20, 0, -52), kind="regular", cell="cove_shallows", proto=True, callable=True),
    dict(id="pier_head", name="Open Pier", zone="pebble_cove", stand="ST_pier_head", pos=(20, 0, -104), kind="regular", cell="pier_head", proto=True, callable=True, storm_eye=True),
    dict(id="cove_pool_1", name="Point Rock Pool South", zone="pebble_cove", stand="ST_cove_shallows", pos=(-48, 4.5, -62), kind="pool", cell="cove_shallows", proto=False, callable=True),
    dict(id="cove_pool_2", name="Point Rock Pool North", zone="pebble_cove", stand="ST_cove_shallows", pos=(-50, 4.5, -44), kind="pool", cell="cove_shallows", proto=False, callable=True),
    # Lantern Reef
    dict(id="reef_steps", name="Lantern Steps", zone="lantern_reef", stand="ST_reef_steps", pos=(-70, 0, -180), kind="regular", cell="reef_steps", proto=False),
    dict(id="reef_lagoon", name="Glow Lagoon", zone="lantern_reef", stand="ST_reef_lagoon", pos=(-153, 0, -160), kind="regular", cell="reef_lagoon", proto=False),
    dict(id="reef_outer", name="Outer Reef", zone="lantern_reef", stand="ST_reef_outer", pos=(-231, 0, -186), kind="regular", cell="reef_outer", proto=False),
    dict(id="reef_lantern_1", name="Lantern Ripple Steps", zone="lantern_reef", stand="ST_reef_steps", pos=(-66, 0, -166), kind="lantern", cell="reef_steps", proto=False),
    dict(id="reef_lantern_2", name="Lantern Ripple Lagoon", zone="lantern_reef", stand="ST_reef_lagoon", pos=(-148, 0, -164), kind="lantern", cell="reef_lagoon", proto=False),
    dict(id="reef_lantern_3", name="Lantern Ripple Outer", zone="lantern_reef", stand="ST_reef_outer", pos=(-235, 0, -168), kind="lantern", cell="reef_outer", proto=False),
    # Gustwhistle Bluffs
    dict(id="kite_ledge", name="Kite Ledge", zone="gustwhistle_bluffs", stand="ST_kite_ledge", pos=(182, 0, -108), kind="regular", cell="kite_ledge", proto=False),
    dict(id="whistle_point", name="Whistle Point", zone="gustwhistle_bluffs", stand="ST_whistle_point", pos=(278, 0, -91), kind="regular", cell="whistle_point", proto=False),
    dict(id="kite_far", name="Far Water North", zone="gustwhistle_bluffs", stand="ST_kite_ledge", pos=(182, 0, -130), kind="far", cell="kite_ledge", proto=False),
    dict(id="whistle_far", name="Far Water East", zone="gustwhistle_bluffs", stand="ST_whistle_point", pos=(300, 0, -95), kind="far", cell="whistle_point", proto=False),
    # Thunderhead Point
    dict(id="squall_rocks", name="Squall Rocks", zone="thunderhead_point", stand="ST_squall_rocks", pos=(134, 0, -170), kind="regular", cell="squall_rocks", proto=False),
    dict(id="anvil_reach", name="Anvil Reach", zone="thunderhead_point", stand="ST_anvil_reach", pos=(96, 0, -286), kind="regular", cell="anvil_reach", proto=False),
    dict(id="squall_pool", name="Squall Rock Pool", zone="thunderhead_point", stand="ST_squall_rocks", pos=(108, 4, -160), kind="pool", cell="squall_rocks", proto=False),
    dict(id="anvil_lantern", name="Lantern Ripple Anvil", zone="thunderhead_point", stand="ST_anvil_reach", pos=(110, 0, -289), kind="lantern", cell="anvil_reach", proto=False),
]

WEATHER_ONLY = {"regular": None, "pool": "Showers", "lantern": "SeaFog", "far": "Gusts"}  # SpotKind -> weather

# Adjacent pairs for the 15 s rule: every pair on one island, plus the nearest pair across each bridge.
ADJACENT_PAIRS = [
    ("cove_dock", "cove_shallows"),
    ("cove_dock", "pier_head"),
    ("cove_shallows", "pier_head"),
    ("reef_steps", "reef_lagoon"),
    ("reef_steps", "reef_outer"),
    ("reef_lagoon", "reef_outer"),
    ("kite_ledge", "whistle_point"),
    ("squall_rocks", "anvil_reach"),
]

# ---------------------------------------------------------------------------------------------
# Front paths (Config/Weather.luau): ordered CellIds. Fronts drift over water between cells.
# ---------------------------------------------------------------------------------------------
FRONT_PATHS = {
    "Showers (Harbour Showers)": ["reef_steps", "cove_shallows", "pier_head", "squall_rocks"],
    "Sea Fog (Reef Fog)": ["reef_outer", "reef_lagoon", "reef_steps", "anvil_reach"],
    "Gusts (Bluff Gusts)": ["whistle_point", "kite_ledge", "squall_rocks", "anvil_reach"],
}
PROTO_FRONT_PATHS = {  # gdd.md 13.2 / specs/prototype.md req 6
    "Showers (prototype)": ["pier_head", "cove_shallows"],
    "Sea Fog (prototype)": ["FOG_ENTRY", "cove_shallows", "pier_head"],
}
# GDD v3 4.2 rule 8: hourly natural harbour visits. Each lingers on one harbour front spot (never cove_dock).
# Both end on pier_head, as in the Designer's illustrative check (docs/specs/cove_visits_check.py).
HARBOUR_VISIT_PATHS = {
    "Sea Fog (Cove Fog, hourly)": ["COVE_FOG_ENTRY", "pier_head"],
    "Gusts (Cove Gusts, hourly)": ["COVE_GUSTS_ENTRY", "pier_head"],
}
# A geometric option for the Designer, checked but not in the route pool and not drawn.
VARIANT_PATHS = {
    "Sea Fog (Cove Fog variant to cove_shallows, not in the pool)": ["COVE_FOG_ENTRY", "cove_shallows"],
}
FOG_ENTRY: Vec = (-80, 0, -110)  # prototype fog bank sits off the Lantern Reef edge stub
ENTRY_POINTS: Dict[str, Vec] = {
    "FOG_ENTRY": FOG_ENTRY,
    "COVE_FOG_ENTRY": (5, 0, -160),  # open sea off the cove mouth, north of the Open Pier
    "COVE_GUSTS_ENTRY": (140, 0, -100),  # open water between Gull Point and the Bluffs' west shore
}

# WindYaw (degrees clockwise from north, north = -Z): the direction the wind blows TOWARD, which is where the
# wind arrow points. Client GlobalWind = (sin(yaw), 0, -cos(yaw)) * the Gusts strength (art-direction.md 6).
# Rule: a cell with a far ripple points at it, so a cast from the stand is wind-carried (GDD 4.1: arrow within
# 45 deg). A cell without one follows the direction Gusts drift into it (rounded to 5 deg), so the cloud and the arrow
# agree. The two harbour cells share one wind blowing off the Bluffs (west), so GlobalWind never flips between them;
# the harbour has no far spot, so its casts are never wind-carried.
WIND_YAW: Dict[str, float] = {
    "kite_ledge": 0.0,  # far ripple kite_far due north
    "whistle_point": 75.0,  # far ripple whistle_far east-north-east
    "squall_rocks": 320.0,  # Bluff Gusts arrives from kite_ledge, heading north-west
    "anvil_reach": 345.0,  # Bluff Gusts arrives from squall_rocks, heading north-north-west
    "pier_head": 270.0,  # Cove Gusts arrives from the Bluffs side, heading west
    "cove_shallows": 270.0,  # called Gusts only; same harbour wind as pier_head
}
WIND_CAST_ANGLE = 45.0  # GDD 4.1 ring table, Gusts row: arrow within 45 deg of the far spot
STORM_HOME: Vec = (115, 50, -217)  # anvil cloud base over the Thunder Spire (StormHome)
STORM_EYE: Vec = (20, 60, -96)  # eye centre over the Open Pier head (StormEye)

# Ferry loop (cosmetic boat on a fixed route; riding is a prompt at a slip, unlocked stops only)
FERRY_ROUTE: List[Tuple[str, Vec]] = [
    ("SLIP_harbor", (35, 0, -40)),
    ("east basin exit (under the Net Walk)", (50, 0, -95)),
    ("channel", (50, 0, -130)),
    ("SLIP_thunder", (44, 0, -215)),
    ("SLIP_reef", (-140, 0, -246)),
    ("mid lagoon", (-10, 0, -185)),
    ("channel", (50, 0, -130)),
    ("east basin exit (under the Net Walk)", (50, 0, -95)),
    ("SLIP_harbor", (35, 0, -40)),
]

# ---------------------------------------------------------------------------------------------
# Landmarks and sightline targets (position of the part that must read; Y = top or centre)
# ---------------------------------------------------------------------------------------------
SIGHT_TARGETS = [
    ("Dock Ripple (first spot, sheltered), 5 studs left of the avatar", (-5, 0, -10), True),
    ("Cove Shallows cell (showers over the far end of the cove)", (-28.5, 6, -52), True),
    ("Bridge 1 gate and price sign (next goal)", (-50, 14, -76), True),
    ("Pier Head (Great Storm eye below)", (20, 4, -80), True),
    ("Rumblefin weathervane on the lookout", (10, 26, -66), False),
    ("Bridge 3 gate (Thunderhead, via the Net Walk)", (78, 14, -80), False),
    ("Thunderhead anvil cloud, base", (115, 50, -217), True),
    ("Thunderhead anvil cloud, top", (115, 150, -217), False),
    ("Great Lantern (Lantern Reef landmark), top", (-153, 115, -222), False),
    ("Whistle Rock (Gustwhistle landmark), top", (225, 128, -50), False),
]

LANDMARKS = [
    ("Great Lantern", "lantern_reef", (-153, 5, -222), 110),
    ("Whistle Rock", "gustwhistle_bluffs", (225, 18, -50), 110),
    ("Thunder Spire + anvil cloud", "thunderhead_point", (115, 8, -217), 142),
    ("Lookout + weathervane", "pebble_cove", (10, 4, -66), 22),
]

# Drawing-only outlines (x, z)
ISLAND_OUTLINES = {
    "pebble_cove": [(-70, -4), (-70, -60), (-58, -80), (-42, -80), (-36, -60), (-36, -4), (60, -4), (60, -70),
                    (70, -84), (86, -84), (100, -60), (102, -4), (110, 40), (80, 85), (0, 95), (-70, 80), (-84, 30)],
    "gustwhistle_bluffs": [(147, -40), (152, -70), (172, -100), (197, -104), (252, -98), (282, -80), (287, -50),
                           (267, -25), (222, -15), (172, -20)],
    "thunderhead_point": [(80, -145), (100, -145), (125, -175), (135, -230), (120, -275), (95, -280), (70, -255),
                          (52, -215), (55, -175)],
}
REEF_OUTER = (-153, -175, 72, 62)  # cx, cz, rx, rz
REEF_INNER = (-153, -185, 34, 24)
PIER_RECTS = [(15, -70, 25, -4), (2, -90, 38, -70), (5, -72, 15, -60), (38, -83, 62, -77), (25, -46, 31, -34)]  # x0, z0, x1, z1


# ---------------------------------------------------------------------------------------------
# Geometry helpers
# ---------------------------------------------------------------------------------------------
def dist(a: Vec, b: Vec) -> float:
    return math.dist(a, b)


def hdist(a: Vec, b: Vec) -> float:
    return math.hypot(a[0] - b[0], a[2] - b[2])


def pos(name: str) -> Vec:
    return NODES[name][0]


def root_at(name: str) -> Vec:
    x, y, z = pos(name)
    return (x, y + ROOT_ABOVE_FLOOR, z)


def build_graph() -> Dict[str, List[Tuple[str, float]]]:
    graph: Dict[str, List[Tuple[str, float]]] = {name: [] for name in NODES}
    for a, b in EDGES:
        length = dist(pos(a), pos(b))
        graph[a].append((b, length))
        graph[b].append((a, length))
    return graph


def shortest(graph, start: str) -> Dict[str, Tuple[float, Optional[str]]]:
    best: Dict[str, Tuple[float, Optional[str]]] = {start: (0.0, None)}
    queue = [(0.0, start)]
    while queue:
        d, node = heapq.heappop(queue)
        if d > best[node][0]:
            continue
        for nxt, w in graph[node]:
            nd = d + w
            if nxt not in best or nd < best[nxt][0]:
                best[nxt] = (nd, node)
                heapq.heappush(queue, (nd, nxt))
    return best


def path_of(tree, end: str) -> List[str]:
    out = [end]
    while tree[out[-1]][1] is not None:
        out.append(tree[out[-1]][1])
    return list(reversed(out))


def seg_point_distance(p: Vec, a: Vec, b: Vec) -> float:
    ax, az, bx, bz, px, pz = a[0], a[2], b[0], b[2], p[0], p[2]
    dx, dz = bx - ax, bz - az
    length2 = dx * dx + dz * dz
    t = 0.0 if length2 == 0 else max(0.0, min(1.0, ((px - ax) * dx + (pz - az) * dz) / length2))
    return math.hypot(ax + t * dx - px, az + t * dz - pz)


def segments_cross(a: Vec, b: Vec, c: Vec, d: Vec) -> bool:
    def orient(p, q, r):
        return (q[0] - p[0]) * (r[2] - p[2]) - (q[2] - p[2]) * (r[0] - p[0])

    return (orient(a, b, c) * orient(a, b, d) < 0) and (orient(c, d, a) * orient(c, d, b) < 0)


def cell_centre(spot_id: str) -> Vec:
    spot = next(s for s in SPOTS if s["id"] == spot_id)
    sx, _, sz = pos(spot["stand"])
    px, _, pz = spot["pos"]
    return ((sx + px) / 2, 0.0, (sz + pz) / 2)


def secs(studs: float, speed: float = BASE_WALK_SPEED) -> float:
    return studs / speed


def compass_bearing(a: Vec, b: Vec) -> float:
    """Compass bearing from a to b in degrees (0 = north = -Z, 90 = east = +X)."""
    return math.degrees(math.atan2(b[0] - a[0], -(b[2] - a[2]))) % 360


def angle_between(a: float, b: float) -> float:
    d = abs(a - b) % 360
    return min(d, 360 - d)


def in_polygon(poly, x: float, z: float) -> bool:
    hit = False
    for i in range(len(poly)):
        (ax, az), (bx, bz) = poly[i], poly[(i + 1) % len(poly)]
        if (az > z) != (bz > z) and x < ax + (z - az) * (bx - ax) / (bz - az):
            hit = not hit
    return hit


def on_land(x: float, z: float) -> bool:
    if any(in_polygon(poly, x, z) for poly in ISLAND_OUTLINES.values()):
        return True
    ox, oz, orx, orz = REEF_OUTER
    ix, iz, irx, irz = REEF_INNER
    return ((x - ox) / orx) ** 2 + ((z - oz) / orz) ** 2 <= 1 and ((x - ix) / irx) ** 2 + ((z - iz) / irz) ** 2 > 1


def path_point(name: str, centres: Dict[str, Vec]) -> Vec:
    return ENTRY_POINTS[name] if name in ENTRY_POINTS else centres[name]


ALL_PATHS = {**FRONT_PATHS, **HARBOUR_VISIT_PATHS, **PROTO_FRONT_PATHS, **VARIANT_PATHS}


# ---------------------------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------------------------
def report() -> int:
    graph = build_graph()
    failures: List[str] = []
    spot_by_id = {s["id"]: s for s in SPOTS}
    regular = [s for s in SPOTS if s["kind"] == "regular"]
    trees = {s["stand"]: shortest(graph, s["stand"]) for s in SPOTS}
    trees["SPAWN"] = shortest(graph, "SPAWN")

    def walk(a_id: str, b_id: str) -> float:
        return trees[spot_by_id[a_id]["stand"]][spot_by_id[b_id]["stand"]][0]

    print(f"# World layout model output, layout {LAYOUT_VERSION}\n")
    print(f"Base walk speed {BASE_WALK_SPEED:g} studs/s (Stats.luau:103). 15 s = {ADJACENT_RULE_S * BASE_WALK_SPEED:g} studs;"
          f" target 12.5 s = {ADJACENT_TARGET_S * BASE_WALK_SPEED:g} studs; 60 s warning = {WARNING_S * BASE_WALK_SPEED:g} studs;"
          f" 45 s = {ANY_SPOT_TARGET_S * BASE_WALK_SPEED:g} studs.\n")

    # 1. Adjacent spots
    print("## Adjacent spots (15 s rule)\n")
    print("Pairs: every pair of regular spots on one island, plus the nearest pair across each bridge.\n")
    print("| From | To | Path (studs) | Base walk (s) | At Speed 32 (s) | Rule <= 15 s | Target <= 12.5 s |")
    print("|---|---|---|---|---|---|---|")
    pairs = list(ADJACENT_PAIRS)
    zone_order = {z[0]: z[2] for z in ZONES}
    for zone, gate, landing, label in BRIDGES:
        near_side = [s for s in regular if s["zone"] == NODES[gate][1]]
        far_side = [s for s in regular if s["zone"] == zone]
        best = min(((walk(a["id"], b["id"]), a["id"], b["id"]) for a in near_side for b in far_side))
        pairs.append((best[1], best[2]))
    del zone_order
    for a, b in pairs:
        d = walk(a, b)
        ok_rule = secs(d) <= ADJACENT_RULE_S
        ok_target = secs(d) <= ADJACENT_TARGET_S
        if not ok_rule:
            failures.append(f"adjacent {a}-{b} {d:.0f} studs")
        print(f"| {a} | {b} | {d:.0f} | {secs(d):.1f} | {secs(d, MAX_TEMPLATE_WALK_SPEED):.1f} | {'pass' if ok_rule else 'FAIL'} | {'pass' if ok_target else 'over'} |")

    # 2. Full matrix of regular spots
    print("\n## Walking time between regular spots (seconds at 16 studs/s)\n")
    ids = [s["id"] for s in regular]
    print("| | " + " | ".join(ids) + " |")
    print("|---" * (len(ids) + 1) + "|")
    worst = (0.0, "", "")
    for a in ids:
        row = []
        for b in ids:
            d = walk(a, b)
            if d > worst[0]:
                worst = (d, a, b)
            row.append("-" if a == b else f"{secs(d):.0f}")
        print(f"| {a} | " + " | ".join(row) + " |")
    print(f"\nLongest spot-to-spot walk: {worst[1]} to {worst[2]}, {worst[0]:.0f} studs = {secs(worst[0]):.1f} s"
          f" (60 s warning rule: {'pass' if secs(worst[0]) <= WARNING_S else 'FAIL'};"
          f" 45 s target: {'pass' if secs(worst[0]) <= ANY_SPOT_TARGET_S else 'over'}).")
    if secs(worst[0]) > WARNING_S:
        failures.append("longest walk exceeds the 60 s warning")

    # 3. Spawn and storm gathering
    print("\n## From spawn, and to the Open Pier for the Great Storm\n")
    print("| Spot | Spawn to stand (studs / s) | Stand to Pier Head stand (studs / s) |")
    print("|---|---|---|")
    pier_stand = spot_by_id["pier_head"]["stand"]
    for s in regular:
        d_spawn = trees["SPAWN"][s["stand"]][0]
        d_pier = trees[s["stand"]][pier_stand][0]
        if secs(d_pier) > STORM_GATHER_TARGET_S:
            failures.append(f"storm gather {s['id']}")
        print(f"| {s['id']} | {d_spawn:.0f} / {secs(d_spawn):.1f} | {d_pier:.0f} / {secs(d_pier):.1f} |")
    for goal in ["GATE_lantern_reef", "GATE_gustwhistle_bluffs", "GATE_thunderhead_point", "NEST_pebble", "LOOKOUT"]:
        d = trees["SPAWN"][goal][0]
        print(f"| (goal) {goal} | {d:.0f} / {secs(d):.1f} | |")

    # 4. Bridges
    print("\n## Bridges\n")
    print("| Bridge | Gate (studs from spawn) | Deck length (studs) | Crossing (s) |")
    print("|---|---|---|---|")
    for zone, gate, landing, label in BRIDGES:
        length = dist(pos(gate), pos(landing))
        print(f"| {label} | {trees['SPAWN'][gate][0]:.0f} | {length:.0f} | {secs(length):.1f} |")

    # 5. Cast geometry
    print("\n## Cast geometry (stand root to spot centre, 3D; hitRange 28, server +8)\n")
    print("| Spot | Name | SpotKind | Only in | Cell | Flags | Horizontal | 3D | Check |")
    print("|---|---|---|---|---|---|---|---|---|")
    for s in SPOTS:
        root = root_at(s["stand"])
        h = hdist(root, s["pos"])
        d3 = dist(root, s["pos"])
        if s["kind"] == "far":
            ok = HIT_RANGE < d3 <= WIND_CAST_RANGE
            check = f"wind only ({HIT_RANGE:g} < d <= {WIND_CAST_RANGE:g})"
        else:
            ok = d3 <= HIT_RANGE
            check = f"<= {HIT_RANGE:g}"
        if not ok:
            failures.append(f"cast range {s['id']} {d3:.1f}")
        flags = ", ".join(f for f, key in (("Sheltered", "sheltered"), ("Callable", "callable"), ("StormEye", "storm_eye")) if s.get(key)) or "-"
        print(f"| {s['id']} | {s['name']} | {s['kind']} | {WEATHER_ONLY[s['kind']] or 'any'} | {s['cell']} | {flags} | {h:.1f} | {d3:.1f} | {'pass' if ok else 'FAIL'} {check} |")

    # 6. Weather cells
    print("\n## Weather cells (radius 36; a point belongs to the nearest cell centre)\n")
    centres = {s["id"]: cell_centre(s["id"]) for s in regular}
    print("| Cell | Zone | Centre (x, z) | Nearest other cell (studs) |")
    print("|---|---|---|---|")
    for cid, c in centres.items():
        others = [(hdist(c, o), oid) for oid, o in centres.items() if oid != cid]
        near = min(others)
        if near[0] < 50:
            failures.append(f"cells {cid}-{near[1]} too close")
        zone = spot_by_id[cid]["zone"]
        print(f"| {cid} | {zone} | ({c[0]:.0f}, {c[2]:.0f}) | {near[1]} {near[0]:.0f} |")
    for s in SPOTS:
        nearest = min(centres, key=lambda cid: hdist(centres[cid], s["pos"]))
        inside = hdist(centres[s["cell"]], s["pos"]) <= CELL_RADIUS
        if nearest != s["cell"] or not inside:
            failures.append(f"spot {s['id']} not in its cell {s['cell']} (nearest {nearest})")
    print("\nEvery spot lies inside its own cell and nearest to its own cell centre: "
          + ("pass" if not any(f.startswith("spot ") for f in failures) else "FAIL"))
    coverage = [1 / len(regular), 2 / len(regular), 3 / len(regular)]
    print(f"Front coverage with 1/2/3 fronts on {len(regular)} cells: "
          + " / ".join(f"{c:.0%}" for c in coverage) + " (loop sketch: about a quarter).")

    # 7. Front paths
    print("\n## Front paths (drift over water between cell centres)\n")
    print("| Front | Cells | Legs (studs) | Total drift (studs) |")
    print("|---|---|---|---|")
    for label, cells in ALL_PATHS.items():
        pts = [path_point(c, centres) for c in cells]
        legs = [hdist(pts[i], pts[i + 1]) for i in range(len(pts) - 1)]
        print(f"| {label} | {' > '.join(cells)} | {', '.join(f'{x:.0f}' for x in legs)} | {sum(legs):.0f} |")
    storm_leg = hdist(STORM_HOME, STORM_EYE)
    print(f"| Great Storm roll-in | StormHome (Thunder Spire) > StormEye (Open Pier) | {storm_leg:.0f} | {storm_leg:.0f} |")
    home_counts = {}
    for label, cells in FRONT_PATHS.items():
        for c in cells:
            z = spot_by_id[c]["zone"]
            home_counts.setdefault(z, []).append(label.split(" (")[0])
    # Sheltered cells: never on a front path, and no drift leg passes over them
    sheltered = [s["id"] for s in SPOTS if s.get("sheltered")]
    print("\n## Sheltered spot (GDD 4.1: no front, call or Rainbow ever covers it)\n")
    print("Paths checked: natural route pool, the hourly harbour visits (GDD 4.2 rule 8) and the prototype routes.\n")
    print("| Sheltered cell | On any front path | Closest drift leg to its centre (studs) | Rule |")
    print("|---|---|---|---|")
    for cid in sheltered:
        on_path = [label for label, cells in ALL_PATHS.items() if cid in cells]
        closest = min(
            seg_point_distance(centres[cid], path_point(a, centres), path_point(b, centres))
            for cells in ALL_PATHS.values()
            for a, b in zip(cells, cells[1:]))
        ok = not on_path and closest > CELL_RADIUS
        if not ok:
            failures.append(f"sheltered {cid} crossed")
        print(f"| {cid} | {', '.join(on_path) if on_path else 'no'} | {closest:.0f} | {'pass' if ok else 'FAIL'} (> {CELL_RADIUS:g}, outside its cell) |")

    # Harbour visits (GDD v3 4.2 rule 8)
    print("\n## Harbour visits: Cove Fog and Cove Gusts (GDD 4.2 rule 8)\n")
    print("| Visit | Entry (x, z) | Ends on | Leg (studs) | Closest approach to the Dock Ripple cell centre | Over water | Rule |")
    print("|---|---|---|---|---|---|---|")
    for label, cells in {**HARBOUR_VISIT_PATHS, **VARIANT_PATHS}.items():
        pts = [path_point(c, centres) for c in cells]
        target = spot_by_id[cells[-1]]
        dry = 0
        samples = 0
        for a, b in zip(pts, pts[1:]):
            n = int(hdist(a, b))
            for i in range(n + 1):
                t = i / max(n, 1)
                samples += 1
                if on_land(a[0] + (b[0] - a[0]) * t, a[2] + (b[2] - a[2]) * t):
                    dry += 1
        dock = min(seg_point_distance(centres[c], a, b) for c in sheltered for a, b in zip(pts, pts[1:]))
        ok = (target["zone"] == "pebble_cove" and target["kind"] == "regular" and target.get("callable")
              and not target.get("sheltered") and dry == 0 and dock > CELL_RADIUS)
        if not ok:
            failures.append(f"harbour visit {label}")
        entry = ENTRY_POINTS[cells[0]]
        print(f"| {label} | ({entry[0]:.0f}, {entry[2]:.0f}) | {cells[-1]} | {sum(hdist(a, b) for a, b in zip(pts, pts[1:])):.0f} |"
              f" {dock:.0f} (> {CELL_RADIUS:g}) | {'yes' if dry == 0 else f'NO ({dry}/{samples} samples on land)'} | {'pass' if ok else 'FAIL'} |")

    # WindYaw (GDD 4.1 Gusts row; GDD 4.2 rule 8; GDD 4.10 called Gusts on Callable spots)
    gust_cells = {c for label, cells in {**FRONT_PATHS, **HARBOUR_VISIT_PATHS}.items() if label.startswith("Gusts")
                  for c in cells if c in centres}
    called_cells = {s["cell"] for s in SPOTS if s.get("callable") and s["kind"] == "regular"}
    print("\n## WindYaw (the wind arrow) on every cell Gusts can cover\n")
    print("WindYaw is the compass direction the wind blows toward (0 = north = -Z, 90 = east = +X); the wind arrow points"
          " that way and the client sets GlobalWind = (sin, 0, -cos) x strength.\n")
    print("| Cell | Why it needs WindYaw | WindYaw | GlobalWind direction (x, z) | Far spot: bearing from stand, off the arrow | Wind-carried cast |")
    print("|---|---|---|---|---|---|")
    for cid in sorted(gust_cells | called_cells):
        reasons = []
        if any(cid in cells for label, cells in FRONT_PATHS.items() if label.startswith("Gusts")):
            reasons.append("Bluff Gusts route")
        if any(cid in cells for label, cells in HARBOUR_VISIT_PATHS.items() if label.startswith("Gusts")):
            reasons.append("Cove Gusts visit")
        if cid in called_cells:
            reasons.append("called Gusts (Callable)")
        yaw = WIND_YAW.get(cid)
        if yaw is None:
            failures.append(f"WindYaw missing on {cid}")
            print(f"| {cid} | {', '.join(reasons)} | MISSING | | | |")
            continue
        wx, wz = math.sin(math.radians(yaw)), -math.cos(math.radians(yaw))
        fars = [s for s in SPOTS if s["cell"] == cid and s["kind"] == "far"]
        if fars:
            parts = []
            for f in fars:
                b = compass_bearing(root_at(f["stand"]), f["pos"])
                off = angle_between(b, yaw)
                if off > WIND_CAST_ANGLE:
                    failures.append(f"far spot {f['id']} {off:.0f} deg off the wind")
                parts.append(f"{f['id']} {b:.0f} deg, {off:.0f} deg off")
            cast = f"yes from the stand (within {WIND_CAST_ANGLE:g} deg)"
            far_text = "; ".join(parts)
        else:
            far_text = "none"
            cast = "never (no far spot); the line bows downwind"
        print(f"| {cid} | {', '.join(reasons)} | {yaw:g} | ({wx:+.2f}, {wz:+.2f}) | {far_text} | {cast} |")
    print("\nCells without a far ripple: the Gusts cloud and the wind arrow agree (within"
          f" {WIND_CAST_ANGLE:g} deg).\n")
    print("| Gusts path | Arrives in | Drift bearing | WindYaw | Apart | Rule |")
    print("|---|---|---|---|---|---|")
    for label, cells in {**FRONT_PATHS, **HARBOUR_VISIT_PATHS}.items():
        if not label.startswith("Gusts"):
            continue
        for prev, cid in zip(cells, cells[1:]):
            if any(sp["cell"] == cid and sp["kind"] == "far" for sp in SPOTS):
                continue
            drift = compass_bearing(path_point(prev, centres), path_point(cid, centres))
            off = angle_between(drift, WIND_YAW[cid])
            ok = off <= WIND_CAST_ANGLE
            if not ok:
                failures.append(f"{label} drift into {cid} disagrees with its WindYaw")
            print(f"| {label} | {cid} | {drift:.0f} | {WIND_YAW[cid]:g} | {off:.0f} | {'pass' if ok else 'FAIL'} |")

    # Callable harbour spots (GDD 4.10): at least 2 incl. the Open Pier, never sheltered, reachable within 60 s
    callable_spots = [s for s in SPOTS if s.get("callable")]
    print("\n## Callable harbour spots (GDD 4.10, paid Sky Bell calls)\n")
    print("| Callable spot | Kind | Farthest walkway point | Walk (studs / s) | Rule <= 60 s | Target <= 45 s |")
    print("|---|---|---|---|---|---|")
    for s in callable_spots:
        tree = shortest(graph, s["stand"])
        far_node, (far_d, _) = max(tree.items(), key=lambda kv: kv[1][0])
        ok = secs(far_d) <= WARNING_S
        if not ok:
            failures.append(f"callable {s['id']} too far")
        print(f"| {s['id']} | {s['kind']} | {far_node} | {far_d:.0f} / {secs(far_d):.1f} | {'pass' if ok else 'FAIL'} | {'pass' if secs(far_d) <= ANY_SPOT_TARGET_S else 'over'} |")
    regular_callable = [s for s in callable_spots if s["kind"] == "regular"]
    rules = [
        ("at least 2 regular Callable spots", len(regular_callable) >= 2),
        ("the Open Pier (StormEye) is Callable", any(s.get("storm_eye") for s in callable_spots)),
        ("all Callable spots are on Pebble Cove", all(s["zone"] == "pebble_cove" for s in callable_spots)),
        ("no Callable spot is Sheltered", not any(s.get("sheltered") for s in callable_spots)),
    ]
    dock_to_pier = walk("cove_dock", "pier_head")
    rules.append((f"Dock Ripple to Open Pier within 10 s (GDD 13 note): {dock_to_pier:.0f} studs = {secs(dock_to_pier):.1f} s",
                  secs(dock_to_pier) <= 10))
    for text, ok in rules:
        if not ok:
            failures.append(text)
        print(f"\n- {text}: {'pass' if ok else 'FAIL'}", end="")
    print()

    print("\nFront visits per island per cycle: "
          + "; ".join(f"{z}: {', '.join(v)}" for z, v in home_counts.items()))

    # 8. Ferry
    print("\n## Ferry loop\n")
    route = [p for _, p in FERRY_ROUTE]
    legs = [hdist(route[i], route[i + 1]) for i in range(len(route) - 1)]
    total = sum(legs)
    clear = min((seg_point_distance(s["pos"], route[i], route[i + 1]), s["id"]) for s in SPOTS for i in range(len(route) - 1))
    crossings = BRIDGES + [("pebble_cove", "PIER_HEAD", "NET_E", "Net Walk footbridge (arched, 10 studs clearance)")]
    crosses = sorted({label for _, g, l, label in crossings for i in range(len(route) - 1)
                      if segments_cross(route[i], route[i + 1], pos(g), pos(l))})
    print(f"Stops: {' > '.join(n for n, _ in FERRY_ROUTE)}")
    print(f"Loop length {total:.0f} studs; at {FERRY_SPEED:g} studs/s that is {total / FERRY_SPEED:.0f} s of sailing plus 3 stops.")
    stops = {}
    acc = 0.0
    for i, (name, _) in enumerate(FERRY_ROUTE):
        if name.startswith("SLIP") and name not in stops:
            stops[name] = acc
        if i < len(legs):
            acc += legs[i]
    print("\n| Stop | Sailing from the harbour slip (studs / s) |")
    print("|---|---|")
    for name, at in stops.items():
        print(f"| {name} | {at:.0f} / {at / FERRY_SPEED:.1f} |")
    print()
    reef_to_thunder = abs(stops["SLIP_thunder"] - stops["SLIP_reef"])
    walk_rt = shortest(graph, "SLIP_reef")["SLIP_thunder"][0]
    print(f"Reef slip to Thunderhead slip: ferry {reef_to_thunder:.0f} studs ({reef_to_thunder / FERRY_SPEED:.1f} s);"
          f" walking {walk_rt:.0f} studs ({secs(walk_rt):.1f} s).")
    print(f"Closest approach to any spot centre: {clear[0]:.1f} studs ({clear[1]}); rule >= {FERRY_CLEARANCE:g}:"
          f" {'pass' if clear[0] >= FERRY_CLEARANCE else 'FAIL'}. Crosses a bridge: {', '.join(crosses) if crosses else 'no'}.")
    if clear[0] < FERRY_CLEARANCE:
        failures.append("ferry clearance")

    # 9. Sightlines from the spawn camera
    print("\n## First-frame sightlines from the spawn camera\n")
    print(f"Camera assumed at {SPAWN_CAMERA} looking north (-Z). Core cone +/-{CORE_CONE_DEG:g} deg; frame cone +/-{FRAME_CONE_DEG:g} deg"
          " (vertical FOV 70: 16:9 phones show about +/-51 deg, 4:3 tablets about +/-43 deg).\n")
    print("| Target | Bearing (deg, + = right) | Distance (studs) | Elevation (deg) | Must see | Result |")
    print("|---|---|---|---|---|---|")
    cx, cy, cz = SPAWN_CAMERA
    for label, (tx, ty, tz), must in SIGHT_TARGETS:
        bearing = math.degrees(math.atan2(tx - cx, -(tz - cz)))
        horiz = math.hypot(tx - cx, tz - cz)
        elevation = math.degrees(math.atan2(ty - cy, horiz))
        limit = CORE_CONE_DEG if must else FRAME_CONE_DEG
        ok = abs(bearing) <= limit
        if must and not ok:
            failures.append(f"sightline {label}")
        result = ("core" if abs(bearing) <= CORE_CONE_DEG else "frame" if abs(bearing) <= FRAME_CONE_DEG else "off-frame")
        print(f"| {label} | {bearing:+.1f} | {horiz:.0f} | {elevation:+.1f} | {'yes' if must else 'no'} | {result} |")

    # 10. Map extent (for streaming radii)
    xs = [p[0][0] for p in NODES.values()] + [s["pos"][0] for s in SPOTS]
    zs = [p[0][2] for p in NODES.values()] + [s["pos"][2] for s in SPOTS]
    hub = pos("PIER_HEAD")
    far_from_hub = max(hdist(hub, s["pos"]) for s in SPOTS)
    far_pair = max(hdist(a["pos"], b["pos"]) for a in SPOTS for b in SPOTS)
    print(f"\n## Extent\n\nWalkable and fishable extent: X {min(xs):.0f}..{max(xs):.0f}, Z {min(zs):.0f}..{max(zs):.0f}"
          f" ({max(xs) - min(xs):.0f} x {max(zs) - min(zs):.0f} studs). Farthest spot from the pier head: {far_from_hub:.0f} studs."
          f" Farthest spot pair (straight line): {far_pair:.0f} studs.")
    counts = {}
    for s in SPOTS:
        counts.setdefault(s["zone"], {}).setdefault(s["kind"], 0)
        counts[s["zone"]][s["kind"]] += 1
    print("\nResourceNode counts per island: " + "; ".join(
        f"{z}: " + ", ".join(f"{k} {n}" for k, n in sorted(v.items())) for z, v in counts.items())
        + f". Total {len(SPOTS)} ({len(regular)} regular).")
    proto = [s["id"] for s in SPOTS if s["proto"]]
    print(f"Prototype ResourceNodes: {', '.join(proto)}.")

    print("\n## ASCII map (1 char = 9 studs east-west, 18 studs north-south; north is up)\n")
    print(ascii_map())
    print("\nKey: S spawn (faces north), 1-0 regular spots (" + ", ".join(f"{v} {k}" for k, v in SPOT_KEYS.items())
          + "), o weather-only spot, # ZoneGate, = bridge, - Net Walk, | Open Pier, ^ landmark, : ferry loop, . land, ~ water.")

    print(f"\n## Result, layout {LAYOUT_VERSION}\n")
    if failures:
        print("FAIL: " + "; ".join(failures))
        return 1
    print("All checks pass.")
    return 0


# ---------------------------------------------------------------------------------------------
# SVG map
# ---------------------------------------------------------------------------------------------
def write_svg(path: str) -> None:
    graph = build_graph()
    x0, x1, z0, z1 = -270, 345, -305, 100
    scale = 1.75
    pad = 20
    width = (x1 - x0) * scale + 2 * pad
    height = (z1 - z0) * scale + 2 * pad + 170

    def P(x: float, z: float) -> Tuple[float, float]:
        return ((x - x0) * scale + pad, (z - z0) * scale + pad)

    def pts(points) -> str:
        return " ".join(f"{P(x, z)[0]:.1f},{P(x, z)[1]:.1f}" for x, z in points)

    out: List[str] = []
    add = out.append
    add(f'<svg xmlns="http://www.w3.org/2000/svg" width="{width:.0f}" height="{height:.0f}" '
        f'viewBox="0 0 {width:.0f} {height:.0f}" font-family="Helvetica, Arial, sans-serif">')
    add(f"<title>Reel the Storm: top-down world plan, layout {LAYOUT_VERSION}</title>")
    add('<defs><marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">'
        '<path d="M0,0 L10,5 L0,10 z" fill="context-stroke"/></marker></defs>')
    add(f'<rect x="0" y="0" width="{width:.0f}" height="{height:.0f}" fill="#3F7F8C"/>')
    # grid every 50 studs
    for gx in range(-250, 345, 50):
        a, b = P(gx, z0), P(gx, z1)
        add(f'<line x1="{a[0]:.1f}" y1="{a[1]:.1f}" x2="{b[0]:.1f}" y2="{b[1]:.1f}" stroke="#4E8FA3" stroke-width="0.6"/>')
    for gz in range(-300, 101, 50):
        a, b = P(x0, gz), P(x1, gz)
        add(f'<line x1="{a[0]:.1f}" y1="{a[1]:.1f}" x2="{b[0]:.1f}" y2="{b[1]:.1f}" stroke="#4E8FA3" stroke-width="0.6"/>')
    # weather cells
    centres = {s["id"]: cell_centre(s["id"]) for s in SPOTS if s["kind"] == "regular"}
    sheltered_cells = {s["cell"] for s in SPOTS if s.get("sheltered")}
    for cid, c in centres.items():
        cxp, czp = P(c[0], c[2])
        if cid in sheltered_cells:
            add(f'<circle cx="{cxp:.1f}" cy="{czp:.1f}" r="{CELL_RADIUS * scale:.1f}" fill="#18203A" fill-opacity="0.12" '
                f'stroke="#18203A" stroke-width="2.5"/>')
        else:
            add(f'<circle cx="{cxp:.1f}" cy="{czp:.1f}" r="{CELL_RADIUS * scale:.1f}" fill="#A8DCD1" fill-opacity="0.18" '
                f'stroke="#A8DCD1" stroke-dasharray="3,3" stroke-width="1"/>')
    # islands
    land = "#6BAA75"
    for zone, outline in ISLAND_OUTLINES.items():
        add(f'<polygon points="{pts(outline)}" fill="{land}" stroke="#18203A" stroke-width="1.5"/>')
    cxr, czr = P(REEF_OUTER[0], REEF_OUTER[1])
    add(f'<ellipse cx="{cxr:.1f}" cy="{czr:.1f}" rx="{REEF_OUTER[2] * scale:.1f}" ry="{REEF_OUTER[3] * scale:.1f}" fill="{land}" stroke="#18203A" stroke-width="1.5"/>')
    cxi, czi = P(REEF_INNER[0], REEF_INNER[1])
    add(f'<ellipse cx="{cxi:.1f}" cy="{czi:.1f}" rx="{REEF_INNER[2] * scale:.1f}" ry="{REEF_INNER[3] * scale:.1f}" fill="#4E8FA3" stroke="#18203A" stroke-width="1"/>')
    for (ax, az, bx, bz) in PIER_RECTS:
        p1, p2 = P(ax, az), P(bx, bz)
        add(f'<rect x="{min(p1[0], p2[0]):.1f}" y="{min(p1[1], p2[1]):.1f}" width="{abs(p2[0] - p1[0]):.1f}" '
            f'height="{abs(p2[1] - p1[1]):.1f}" fill="#FFF8EC" stroke="#FF7A59" stroke-width="1.5"/>')
    # ferry route
    route = [p for _, p in FERRY_ROUTE]
    add(f'<polyline points="{pts([(p[0], p[2]) for p in route])}" fill="none" stroke="#FFF8EC" stroke-width="2" stroke-dasharray="8,5"/>')
    # front paths
    colours = {"Showers": "#6FC3D9", "Sea Fog": "#E6ECEA", "Gusts": "#9BE3C3"}
    offsets = {"Showers": (-4, -4), "Sea Fog": (4, 4), "Gusts": (0, 6)}
    for label, cells in FRONT_PATHS.items():
        key = label.split(" (")[0]
        ox, oz = offsets[key]
        line = [(centres[c][0] + ox, centres[c][2] + oz) for c in cells]
        add(f'<polyline points="{pts(line)}" fill="none" stroke="{colours[key]}" stroke-width="3" stroke-opacity="0.95" marker-end="url(#arrow)"/>')
    # hourly harbour visits (GDD 4.2 rule 8)
    for label, cells in HARBOUR_VISIT_PATHS.items():
        key = label.split(" (")[0]
        line = [(path_point(c, centres)[0], path_point(c, centres)[2]) for c in cells]
        add(f'<polyline points="{pts(line)}" fill="none" stroke="{colours[key]}" stroke-width="3.5" '
            f'stroke-dasharray="7,4" marker-end="url(#arrow)"/>')
        ex, ez = P(line[0][0], line[0][1])
        add(f'<circle cx="{ex:.1f}" cy="{ez:.1f}" r="5" fill="{colours[key]}" stroke="#18203A" stroke-width="1.5"/>')
        name = label.split("(")[1].split(",")[0]
        add(f'<text x="{ex + 8:.1f}" y="{ez + 4:.1f}" font-size="10" font-weight="bold" fill="#FFF8EC">{name} (hourly)</text>')
    # wind arrows (WindYaw) on every Gusts-capable cell
    for cid, yaw in WIND_YAW.items():
        c = centres[cid]
        tip = (c[0] + 24 * math.sin(math.radians(yaw)), c[2] - 24 * math.cos(math.radians(yaw)))
        a, b = P(c[0], c[2]), P(*tip)
        add(f'<line x1="{a[0]:.1f}" y1="{a[1]:.1f}" x2="{b[0]:.1f}" y2="{b[1]:.1f}" stroke="#FFFFFF" stroke-width="2.5" marker-end="url(#arrow)"/>')
        add(f'<text x="{a[0] + 4:.1f}" y="{a[1] + 14:.1f}" font-size="9" fill="#FFFFFF">{yaw:g}°</text>')
    sh, se = P(STORM_HOME[0], STORM_HOME[2]), P(STORM_EYE[0], STORM_EYE[2])
    add(f'<line x1="{sh[0]:.1f}" y1="{sh[1]:.1f}" x2="{se[0]:.1f}" y2="{se[1]:.1f}" stroke="#FFC42E" stroke-width="3" stroke-dasharray="2,4" marker-end="url(#arrow)"/>')
    # walkways
    for a, b in EDGES:
        pa, pb = P(pos(a)[0], pos(a)[2]), P(pos(b)[0], pos(b)[2])
        is_bridge = any((a == g and b == l) or (a == l and b == g) for _, g, l, _ in BRIDGES)
        colour, w = ("#FF7A59", 5) if is_bridge else ("#FFF8EC", 2)
        add(f'<line x1="{pa[0]:.1f}" y1="{pa[1]:.1f}" x2="{pb[0]:.1f}" y2="{pb[1]:.1f}" stroke="{colour}" stroke-width="{w}" stroke-linecap="round"/>')
        if is_bridge:
            length = dist(pos(a), pos(b))
            mx, my = (pa[0] + pb[0]) / 2, (pa[1] + pb[1]) / 2
            add(f'<text x="{mx + 6:.1f}" y="{my:.1f}" font-size="11" fill="#18203A" font-weight="bold">{length:.0f}</text>')
    # gates
    for zone, gate, landing, label in BRIDGES:
        gp = P(pos(gate)[0], pos(gate)[2])
        add(f'<rect x="{gp[0] - 5:.1f}" y="{gp[1] - 5:.1f}" width="10" height="10" fill="#18203A"/>')
    # spots
    for s in SPOTS:
        sp = P(s["pos"][0], s["pos"][2])
        r = 5 * scale / 1.75 * 1.0
        if s["kind"] == "regular":
            add(f'<circle cx="{sp[0]:.1f}" cy="{sp[1]:.1f}" r="{r + 1:.1f}" fill="#FFC42E" stroke="#18203A" stroke-width="2"/>')
        else:
            fill = {"pool": "#6FC3D9", "lantern": "#E6ECEA", "far": "#9BE3C3"}[s["kind"]]
            add(f'<circle cx="{sp[0]:.1f}" cy="{sp[1]:.1f}" r="{r - 1:.1f}" fill="{fill}" stroke="#18203A" stroke-width="1.2"/>')
        if s["proto"]:
            add(f'<circle cx="{sp[0]:.1f}" cy="{sp[1]:.1f}" r="{r + 5:.1f}" fill="none" stroke="#FF7A59" stroke-width="2"/>')
        if s.get("callable"):
            add(f'<circle cx="{sp[0]:.1f}" cy="{sp[1]:.1f}" r="{r + 9:.1f}" fill="none" stroke="#FFC42E" stroke-width="2" stroke-dasharray="3,2"/>')
        st = P(pos(s["stand"])[0], pos(s["stand"])[2])
        add(f'<line x1="{st[0]:.1f}" y1="{st[1]:.1f}" x2="{sp[0]:.1f}" y2="{sp[1]:.1f}" stroke="#18203A" stroke-width="0.8" stroke-dasharray="2,2"/>')
        if s["kind"] == "regular":
            add(f'<text x="{sp[0] + 8:.1f}" y="{sp[1] + 4:.1f}" font-size="11" fill="#18203A" font-weight="bold">{s["id"]}</text>')
    # landmarks
    for name, zone, (lx, ly, lz), h in LANDMARKS:
        lp = P(lx, lz)
        add(f'<polygon points="{lp[0]:.1f},{lp[1] - 9:.1f} {lp[0] - 7:.1f},{lp[1] + 6:.1f} {lp[0] + 7:.1f},{lp[1] + 6:.1f}" fill="#FFF8EC" stroke="#18203A" stroke-width="1.5"/>')
        anchor, dx = ("end", -10) if zone == "pebble_cove" else ("start", 9)
        add(f'<text x="{lp[0] + dx:.1f}" y="{lp[1] - 4:.1f}" font-size="10" fill="#FFF8EC" text-anchor="{anchor}">{name} ({h})</text>')
    # spawn and view cone
    spx, spz = P(0, 0)
    cam = P(SPAWN_CAMERA[0], SPAWN_CAMERA[2])
    reach = 330
    for sign, colour in ((1, "#FFC42E"),):
        left = P(SPAWN_CAMERA[0] - reach * math.tan(math.radians(CORE_CONE_DEG)), SPAWN_CAMERA[2] - reach)
        right = P(SPAWN_CAMERA[0] + reach * math.tan(math.radians(CORE_CONE_DEG)), SPAWN_CAMERA[2] - reach)
        add(f'<polygon points="{cam[0]:.1f},{cam[1]:.1f} {left[0]:.1f},{left[1]:.1f} {right[0]:.1f},{right[1]:.1f}" '
            f'fill="{colour}" fill-opacity="0.05" stroke="{colour}" stroke-opacity="0.6" stroke-dasharray="6,4"/>')
    add(f'<circle cx="{spx:.1f}" cy="{spz:.1f}" r="7" fill="#FF7A59" stroke="#18203A" stroke-width="2"/>')
    add(f'<text x="{spx + 10:.1f}" y="{spz + 18:.1f}" font-size="12" fill="#18203A" font-weight="bold">PlayerSpawn (faces north)</text>')
    # island names
    labels = [("Pebble Cove", (-60, 60)), ("Driftlight Harbor", (-20, 30)), ("Lantern Reef", (-250, -120)),
              ("Gustwhistle Bluffs", (200, -5)), ("Thunderhead Point", (140, -150))]
    for text, (lx, lz) in labels:
        lp = P(lx, lz)
        add(f'<text x="{lp[0]:.1f}" y="{lp[1]:.1f}" font-size="15" font-weight="bold" fill="#18203A">{text}</text>')
    op = P(28, -24)
    add(f'<text x="{op[0]:.1f}" y="{op[1]:.1f}" font-size="11" fill="#FFF8EC" font-weight="bold">Open Pier</text>')
    add(f'<text x="{op[0]:.1f}" y="{op[1] + 13:.1f}" font-size="9" fill="#FFF8EC">Storm Eye at the head</text>')
    dl = P(-62, 22)
    add(f'<text x="{dl[0]:.1f}" y="{dl[1]:.1f}" font-size="10" fill="#18203A" font-weight="bold">Sheltered dock cell: no fronts</text>')
    nw = P(36, -92)
    add(f'<text x="{nw[0]:.1f}" y="{nw[1]:.1f}" font-size="10" fill="#FFF8EC">Net Walk</text>')
    # prototype build area (Pebble Cove harbour edge, Open Pier, bridge-1 stub, Lantern Reef edge stub)
    pa, pb = P(-110, -150), P(45, 14)
    add(f'<rect x="{pa[0]:.1f}" y="{pa[1]:.1f}" width="{pb[0] - pa[0]:.1f}" height="{pb[1] - pa[1]:.1f}" fill="none" '
        f'stroke="#FF7A59" stroke-width="2.5" stroke-dasharray="10,6"/>')
    add(f'<text x="{pa[0] + 4:.1f}" y="{pa[1] - 6:.1f}" font-size="12" fill="#FF7A59" font-weight="bold">Prototype build area</text>')
    # north arrow and scale bar
    na = P(320, -285)
    add(f'<line x1="{na[0]:.1f}" y1="{na[1] + 30:.1f}" x2="{na[0]:.1f}" y2="{na[1]:.1f}" stroke="#FFF8EC" stroke-width="3" marker-end="url(#arrow)"/>')
    add(f'<text x="{na[0] - 5:.1f}" y="{na[1] + 45:.1f}" font-size="13" fill="#FFF8EC" font-weight="bold">N</text>')
    sb = P(-250, 85)
    add(f'<line x1="{sb[0]:.1f}" y1="{sb[1]:.1f}" x2="{sb[0] + 100 * scale:.1f}" y2="{sb[1]:.1f}" stroke="#FFF8EC" stroke-width="3"/>')
    add(f'<text x="{sb[0]:.1f}" y="{sb[1] - 6:.1f}" font-size="11" fill="#FFF8EC">100 studs = 6.25 s at walk speed 16 (grid 50 studs)</text>')
    # legend
    ly = (z1 - z0) * scale + 2 * pad + 8
    items = [
        ("circle", "#FFC42E", "Regular spot (ResourceNode)"),
        ("circle", "#6FC3D9", "Rock pool (Showers only)"),
        ("circle", "#E6ECEA", "Lantern ripple (Sea Fog only)"),
        ("circle", "#9BE3C3", "Far water (Gusts, wind cast)"),
        ("line", "#FFF8EC", "Walkway, Net Walk footbridge"),
        ("ring", "#FF7A59", "Prototype spot"),
        ("line", "#FF7A59", "Bridge, deck length in studs"),
        ("square", "#18203A", "ZoneGate with UnlockPrompt"),
        ("dash", "#FFF8EC", "Ferry loop"),
        ("line", "#6FC3D9", "Showers front path"),
        ("line", "#E6ECEA", "Sea Fog front path"),
        ("line", "#9BE3C3", "Gusts front path"),
        ("dash", "#FFC42E", "Great Storm roll-in"),
        ("cell", "#A8DCD1", "WeatherCell (r 36)"),
        ("tri", "#FFF8EC", "Landmark (height studs)"),
        ("cone", "#FFC42E", "Spawn camera, +/-35 deg"),
        ("dash", "#FF7A59", "Prototype build area"),
        ("callring", "#FFC42E", "Callable (Sky Bell harbour spot)"),
        ("shelter", "#18203A", "Sheltered cell (never a front)"),
        ("dash", "#9BE3C3", "Hourly harbour visit (Cove Fog, Cove Gusts)"),
        ("line", "#FFFFFF", "WindYaw: wind arrow, degrees from north"),
    ]
    add(f'<rect x="{pad:.0f}" y="{ly - 4:.0f}" width="{width - 2 * pad:.0f}" height="158" fill="#18203A" rx="8"/>')
    cols = 4
    colw = (width - 2 * pad - 20) / cols
    for i, (shape, colour, text) in enumerate(items):
        cx_ = pad + 16 + (i % cols) * colw
        cy_ = ly + 16 + (i // cols) * 24
        if shape == "callring":
            add(f'<circle cx="{cx_:.1f}" cy="{cy_:.1f}" r="7" fill="none" stroke="{colour}" stroke-width="2" stroke-dasharray="3,2"/>')
        elif shape == "shelter":
            add(f'<circle cx="{cx_:.1f}" cy="{cy_:.1f}" r="7" fill="#3E5376" stroke="#FFF8EC" stroke-width="2"/>')
        elif shape in ("circle", "ring"):
            fill = "none" if shape == "ring" else colour
            add(f'<circle cx="{cx_:.1f}" cy="{cy_:.1f}" r="6" fill="{fill}" stroke="{colour if shape == "ring" else "#FFF8EC"}" stroke-width="2"/>')
        elif shape == "square":
            add(f'<rect x="{cx_ - 5:.1f}" y="{cy_ - 5:.1f}" width="10" height="10" fill="{colour}" stroke="#FFF8EC"/>')
        elif shape == "tri":
            add(f'<polygon points="{cx_:.1f},{cy_ - 7:.1f} {cx_ - 6:.1f},{cy_ + 5:.1f} {cx_ + 6:.1f},{cy_ + 5:.1f}" fill="{colour}"/>')
        elif shape == "cell":
            add(f'<circle cx="{cx_:.1f}" cy="{cy_:.1f}" r="7" fill="{colour}" fill-opacity="0.3" stroke="{colour}" stroke-dasharray="2,2"/>')
        elif shape == "cone":
            add(f'<polygon points="{cx_ - 6:.1f},{cy_ + 6:.1f} {cx_ - 10:.1f},{cy_ - 6:.1f} {cx_ + 2:.1f},{cy_ - 6:.1f}" fill="{colour}" fill-opacity="0.4"/>')
        else:
            dash = ' stroke-dasharray="5,3"' if shape == "dash" else ""
            add(f'<line x1="{cx_ - 9:.1f}" y1="{cy_:.1f}" x2="{cx_ + 9:.1f}" y2="{cy_:.1f}" stroke="{colour}" stroke-width="3"{dash}/>')
        add(f'<text x="{cx_ + 16:.1f}" y="{cy_ + 4:.1f}" font-size="11" fill="#FFF8EC">{text}</text>')
    add("</svg>")
    with open(path, "w", encoding="utf-8") as handle:
        handle.write("\n".join(out) + "\n")
    del graph


# ---------------------------------------------------------------------------------------------
# ASCII map (one character = 9 studs east-west, 18 studs north-south)
# ---------------------------------------------------------------------------------------------
SPOT_KEYS = {"cove_dock": "1", "cove_shallows": "2", "pier_head": "3", "reef_steps": "4", "reef_lagoon": "5",
             "reef_outer": "6", "kite_ledge": "7", "whistle_point": "8", "squall_rocks": "9", "anvil_reach": "0"}


def ascii_map() -> str:
    x0, x1, z0, z1, cw, ch = -250, 320, -300, 100, 9, 18
    cols, rows = int((x1 - x0) / cw) + 1, int((z1 - z0) / ch) + 1
    grid = [["~"] * cols for _ in range(rows)]

    def cell(x: float, z: float):
        return int(round((z - z0) / ch)), int(round((x - x0) / cw))

    def put(x: float, z: float, char: str):
        r, c = cell(x, z)
        if 0 <= r < rows and 0 <= c < cols:
            grid[r][c] = char

    def inside(poly, x, z):
        hit = False
        for i in range(len(poly)):
            (ax, az), (bx, bz) = poly[i], poly[(i + 1) % len(poly)]
            if (az > z) != (bz > z) and x < ax + (z - az) * (bx - ax) / (bz - az):
                hit = not hit
        return hit

    for r in range(rows):
        for c in range(cols):
            x, z = x0 + c * cw, z0 + r * ch
            land = any(inside(poly, x, z) for poly in ISLAND_OUTLINES.values())
            ox, oz, orx, orz = REEF_OUTER
            ix, iz, irx, irz = REEF_INNER
            if ((x - ox) / orx) ** 2 + ((z - oz) / orz) ** 2 <= 1 and ((x - ix) / irx) ** 2 + ((z - iz) / irz) ** 2 > 1:
                land = True
            if land:
                grid[r][c] = "."

    def line(a: Vec, b: Vec, char: str):
        steps = int(max(abs(b[0] - a[0]) / cw, abs(b[2] - a[2]) / ch) * 2) + 1
        for i in range(steps + 1):
            t = i / steps
            put(a[0] + (b[0] - a[0]) * t, a[2] + (b[2] - a[2]) * t, char)

    route = [p for _, p in FERRY_ROUTE]
    for i in range(len(route) - 1):
        line(route[i], route[i + 1], ":")
    for (ax, az, bx, bz) in PIER_RECTS[:2]:
        for xx in range(int(ax), int(bx) + 1, 3):
            line((xx, 0, az), (xx, 0, bz), "|")
    line(pos("PIER_HEAD"), pos("NET_E"), "-")
    for _, g, l, _ in BRIDGES:
        line(pos(g), pos(l), "=")
    for _, g, _, _ in BRIDGES:
        put(pos(g)[0], pos(g)[2], "#")
    for _, _, (lx, _, lz), _ in LANDMARKS:
        put(lx, lz, "^")
    for s in sorted(SPOTS, key=lambda spot: spot["kind"] == "regular"):
        put(s["pos"][0], s["pos"][2], SPOT_KEYS.get(s["id"], "o"))
    put(0, 0, "S")
    return "\n".join("".join(row).rstrip() for row in grid)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--svg", help="write the top-down map to this SVG path")
    args = parser.parse_args()
    if args.svg:
        write_svg(args.svg)
        print(f"SVG written to {args.svg}\n")
    return report()


if __name__ == "__main__":
    sys.exit(main())
