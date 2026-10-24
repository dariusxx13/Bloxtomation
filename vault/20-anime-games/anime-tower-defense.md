---
title: Anime tower defense deep dive
date: 2026-10-24
tags: [anime, tower-defense, units, waves, modes, balance, engineering]
aliases: [Anime TD, Unit tower defense, Anime tower defense design]
summary: How anime tower defense games are built - match flow, unit roles and stats, enemy design, wave and money curves with worked numbers, modes from story to raids, meta-progression, server simulation of hundreds of enemies, and the balance traps that end these games.
audience: [human, agent]
---

# Anime tower defense deep dive

Anime tower defense (TD) is the most monetizable anime sub-genre on Roblox and one of the most crowded. The formula: summon anime-style units, place them along a path, survive waves, earn rewards, then use those rewards to summon and upgrade more units. The [Tower defense playbook](../14-genre-playbooks/tower-defense.md) covers TD in general. This note goes deeper into the anime variant: unit design, numbers, modes and engineering.

## The match, beat by beat

```text
Lobby (summon, equip team, pick stage) -> teleport or load into match
  -> wave 1 starts after a short countdown; players get starting money
  -> place units on legal ground, upgrade them with money from kills and wave bonuses
  -> every 5-10 waves: a boss with an ability (stun units, shield, summon minions)
  -> final wave or base destroyed -> results screen (gems, items, XP, unit XP)
  -> vote: replay, next stage, or return to lobby
```

Rule of thumb timings: story stages 5-12 minutes, boss or raid stages 10-20 minutes, infinite mode until defeat. Offer 2x (and often 3x) speed so experienced players can farm quickly, and auto-skip so waves start when the last one is cleared.

## Unit design

### Stats every unit has

| Stat | What it controls | Notes |
|---|---|---|
| Placement cost | Money to place | The main balance lever; strong units cost more to place |
| Upgrade levels and costs | Damage, range, cooldown per level | 4-8 levels is common; the last levels are dramatic |
| Damage | Per attack | Scale with upgrade level and unit level |
| Cooldown (attack speed) | Seconds between attacks | DPS = damage ÷ cooldown × targets hit |
| Range | Radius in studs | Long range rewards placement thinking |
| Attack shape | Single, circle, cone, line, full map | Shape decides whether a unit is boss-killer or crowd-clearer |
| Placement limit | Max copies per match | Stops one cheap unit from being spammed |
| Placement type | Ground, hill, water, air | Map tiles with types create placement puzzles |
| Effects | Slow, stun, burn, bleed, armor break | Status effects create team synergy |
| Targeting | First, last, strongest, weakest, closest | Let players change it; it is a free strategic layer |

### Roles

| Role | Job | Design notes |
|---|---|---|
| Single-target carry | Kill bosses | High damage, slow attack, long range; weak to swarms |
| Area damage (AoE) | Clear crowds | Lower damage per hit, circle or cone shapes |
| Control | Slow or stun | Low damage; must not stun bosses forever (diminishing returns) |
| Economy ("farm") | Generates money per wave | Very strong early; cap with placement limits and diminishing returns |
| Support (buffer) | Raises nearby units' damage, range or speed | Creates placement puzzles and team identity |
| Detection / anti-air | Hits hidden or flying enemies | Gives every unit type a reason to exist |
| Summoner | Spawns walking minions on the path | Spectacle; costs server performance, so cap it |

**Rule of thumb:** every new unit must have a role sentence: "best at X because Y, weak to Z." If it has no weakness, it is power creep.

### Unit progression outside matches

- **Unit level** (XP items or duplicate feeding) raises base stats moderately.
- **Evolution**: a recipe of materials from specific stages turns a unit into a stronger form with a new look. Evolutions give old units a second life and give materials a purpose.
- **Traits**: random modifiers rolled on a unit (for example +damage, +range, money bonus, a rare "unique" trait). See [Anime units, gacha and traits](anime-units-gacha-and-traits.md) for trait odds and the paid-random-item rules.
- **Stat potentials**: per-unit random stat grades (C to S) that can be rerolled. This adds a second layer of chase; keep the gap between grades modest (for example 0.9× to 1.15×).
- **Shiny or variant forms**: cosmetic variants with a small bonus; great for rarity reveals.

## Enemy design

| Enemy type | Purpose |
|---|---|
| Basic walker | Teaches the path and placement |
| Fast runner | Punishes slow, single-target teams |
| Tank (high HP) | Tests single-target damage |
| Armored or shielded | Needs armor break or high hit damage |
| Flying | Needs anti-air units |
| Hidden / stealth | Needs detection |
| Healer or buffer | Priority target; rewards "strongest" or manual targeting |
| Splitter | Spawns smaller enemies on death; rewards AoE |
| Boss | Ability every few seconds: stuns units in a radius, shields itself, summons, speeds up |

Bosses should **telegraph** their abilities (a wind-up animation and a ground marker for a stun radius) so players can learn and respond. Readability matters as much as in a fighting game ([Combat and anime VFX](../19-vfx/combat-and-anime-vfx.md)).

## Wave and money curves (worked example)

A simple, tunable model:

- Enemy HP for wave `w`: `HP(w) = H0 × g^(w-1)` with `H0` the first-wave HP and `g` the growth per wave.
- Money per wave (kills plus wave bonus): `M(w) = M0 × m^(w-1)`.
- Team DPS a player can afford grows roughly with cumulative money spent, but **with diminishing returns** because upgrade costs rise faster than damage.

Example for a 30-wave story stage (Rule of thumb starting values, tune with playtests):

| Parameter | Value |
|---|---|
| `H0` | 100 |
| `g` | 1.12 (HP roughly triples every 10 waves) |
| `M0` | 250 |
| `m` | 1.08 |
| Boss waves | 10, 20, 30 at 15×, 25×, 40× that wave's HP |

With these values, wave 30 enemies have about 2,675 HP each (100 × 1.12^29), while money per wave has grown to about 2,330 (250 × 1.08^29). Because HP outgrows money, the stage gets harder over time even if the player spends perfectly. That is the intended pressure. Difficulty modes multiply `H0` and `g` (Hard: `g` = 1.14; Nightmare: 1.16) rather than changing enemies, so content is reused.

Test with **typical free loadouts**, not the developer's best team. A stage that only top-rarity units can clear is a pay wall, and the community will call it one ([Economy math](../04-progression-and-economy/economy-math.md)).

## Modes (the content map)

| Mode | What it is | Why it exists |
|---|---|---|
| Story (worlds and acts) | 4-6 acts per themed world, Normal and Hard | First-time progression; unlocks the next world |
| Legend or nightmare stages | Harder variants with special mechanics | Mid-game goals; drop evolution materials |
| Infinite / endless | Waves until defeat; leaderboards | Endgame bragging rights; tests scaling |
| Challenges | Rotating modifiers (no farms, fast enemies, half range) refreshed on a timer | Daily reason to log in; uses existing maps |
| Raids | Harder boss stages with exclusive drops, sometimes on a schedule | Social endgame; drives co-op |
| Portals or keys | Consumable items that open a stage with random modifiers and better rewards | A tradable, farmable item sink |
| Events | Limited-time stages with event currency and a shop | Update marketing and comeback driver |
| Versus or competitive | Rare; usually races or score attacks | Can work as a side mode; hard to balance |

Each mode should drop something **specific** (evolution materials from Legend stages, raid-exclusive units, portal keys from challenges). If every mode drops the same gems, players only play the most efficient one.

## Meta-progression and currencies

| Currency or item | Earned from | Spent on |
|---|---|---|
| Gems (main soft-premium) | Stages, quests, codes, achievements; also sold | Summons |
| Gold or coins | Stages | Unit leveling, shop items |
| Trait reroll items | Challenges, events, daily rewards; sometimes sold | Rerolling traits |
| Evolution materials | Specific stages and raids | Evolutions |
| Event currency | Event stages | Event shop |
| Battle pass XP | Playing anything | Pass tiers |

Keep the number of currencies small enough to explain in one screen. Every currency needs a source table and a sink table in the economy sheet ([Economy design](../04-progression-and-economy/economy-design.md)).

## Engineering: hundreds of enemies without lag

Anime TD games are performance-heavy: many enemies, many units attacking, big VFX. The proven architecture:

1. **Enemies are data on the server, not physics objects.** Each enemy is a record: id, type, HP, distance travelled along the path, status effects.
2. **The path is a list of waypoints.** An enemy's position is computed from its distance travelled, so the server never moves parts.
3. **The server ticks at a fixed rate** (for example 10-20 times per second): advance distances, apply effects, run unit attacks and damage, remove dead enemies, check the base.
4. **Clients render.** The server sends compact updates (spawns, deaths, HP changes, effect starts); each client moves enemy models along the same path locally and interpolates.
5. **Projectiles and attack VFX are client-only.** The server decides hits; clients draw them ([VFX architecture and replication](../19-vfx/vfx-architecture-and-replication.md)).
6. **Pool models and effects**; cap enemies and summons per match.

Position from distance (sketch):

```lua
--!strict
-- Path: precomputed waypoints and cumulative lengths, built once per map.
export type Path = { points: { Vector3 }, cumulative: { number }, total: number }

local function positionAt(path: Path, distance: number): Vector3
	local d = math.clamp(distance, 0, path.total)
	for i = 2, #path.points do
		if d <= path.cumulative[i] then
			local segStart = path.cumulative[i - 1]
			local alpha = (d - segStart) / (path.cumulative[i] - segStart)
			return path.points[i - 1]:Lerp(path.points[i], alpha)
		end
	end
	return path.points[#path.points]
end
```

Targeting is then cheap: "first" is the enemy with the largest distance travelled within range, "strongest" the highest current HP within range. Use a squared-distance check before anything else.

Security follows the house rules: the client asks to place or upgrade a unit; the server checks ownership, money, placement limits, legal ground and spacing, then applies it ([Security and anti-exploit](../13-building-it-right/security-and-anti-exploit.md)).

## Co-op design

- 1-4 players per match is standard; each player has their own money and placement limits, or a shared pool for small teams.
- Vote systems for difficulty, speed and replay; a majority or host decides.
- Reward carrying: veterans who help newcomers clear a stage earn a bonus, which builds community and onboarding at once.
- Solo must remain viable; matchmaking queues should never be the only way to play.

## Update cadence for TD

A pattern that sustains interest (Rule of thumb):

| Cadence | Content |
|---|---|
| Weekly | Balance patch, a challenge rotation tweak, a code, a small QoL change |
| Every 2-3 weeks | New banner units (2-4), a new evolution, an event stage |
| Every 6-10 weeks | New story world, new raid, new system (for example a new trait tier or a new mode) |

Announce update times in advance and keep them consistent; the community schedules around them ([Update cadence](../12-live-ops-and-launch/update-cadence.md)).

## Traps specific to anime TD

| Trap | Fix |
|---|---|
| Every banner's top unit is strictly better than the last | New niches and mechanics; buff old units with evolutions |
| Farm units dominate every strategy | Placement limits, diminishing returns, modes that ban farms |
| Paid trait rerolls with hidden odds | Display odds for anything bought with Robux or Robux-bought items; gate with `PolicyService` |
| Stages tuned around top units | Test every stage with a typical free team |
| Server lag in infinite mode | Data-driven enemies, fixed tick, caps, client rendering |
| Unit designs recognisable as franchise characters | Original designs or a real license ([Anime IP and legal](anime-ip-and-legal.md)) |
| Lobby clutter | One clear path from lobby to "Play"; summons and team edit one tap away |

## For agents

- [ ] Every unit has a role sentence, a placement limit and a weakness.
- [ ] Wave HP and money curves are in the economy sheet with the formula and values used.
- [ ] Stages are cleared in playtests with a typical free loadout at each difficulty.
- [ ] Enemies are simulated as data with a fixed server tick; clients render and interpolate.
- [ ] Each mode drops something specific; every currency has listed sources and sinks.

Sources: [PolicyService](https://create.roblox.com/docs/reference/engine/classes/PolicyService) · [Paid random items policy](https://create.roblox.com/docs/production/monetization/paid-random-items) (via [Monetization compliance](../09-monetization/monetization-compliance.md))

Related: [Tower defense playbook](../14-genre-playbooks/tower-defense.md) · [Anime units, gacha and traits](anime-units-gacha-and-traits.md) · [Anime monetization](anime-monetization.md) · [Performance optimization](../13-building-it-right/performance-optimization.md) · [Economy math](../04-progression-and-economy/economy-math.md)
