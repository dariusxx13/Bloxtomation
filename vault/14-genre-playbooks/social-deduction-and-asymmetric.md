---
title: Social deduction and asymmetric playbook
date: 2026-10-24
tags: [genre, social-deduction, asymmetric, rounds, horror, roles, playbook]
aliases: [Murder mystery games, Asymmetric horror, 1vX games, Killer vs survivors, Hidden role games]
summary: How to build round-based hidden-role and asymmetric games - murderer-sheriff-innocent formats, one-versus-many killer games, role assignment, information design, objectives, balance between sides, spectating and dead-player chat, leaving and teaming problems, cosmetic economies that last a decade, and the policy question of selling role chances.
audience: [human, agent]
---

# Social deduction and asymmetric playbook

Round-based games where players get different roles are among the most durable on Roblox. Murder Mystery 2, launched in 2014, set its all-time record of about 1.35M concurrent players in August 2026 and led the studio's 2026-10-24 snapshot with about 1.66M (StudioKrew citing GGAID; studio snapshot). Asymmetric "one killer versus survivors" games such as Flee the Facility (2017), Forsaken, Dandy's World and Violence District also chart strongly in 2026.

Roblox genre: Survival (most), Action (duel variants).

## Formats

| Format | Roles | Win conditions |
|---|---|---|
| Hidden-role murder | One murderer, one sheriff, many innocents | Murderer eliminates all; sheriff stops the murderer; innocents survive the timer |
| Asymmetric chase (1vX) | One powerful hunter, several survivors | Survivors complete objectives and escape; hunter catches them |
| Hidden-role teams | Impostor-style teams with tasks and voting | Complete tasks or find the impostors |
| Duels | Two sides in fast fights (for example murderer versus sheriff duels) | Elimination |

## The loop

```
Moment:  hide, chase, accuse, shoot, escape (tension and release)
Round:   lobby -> role reveal -> play (2-6 min) -> reveal and results -> rewards
Long:    levels, cosmetic weapons and effects, collection and trading, events
```

Round length is the key pacing lever: short enough that dead players do not wait long, long enough for tension to build.

## Role assignment

- **Random with protections:** avoid giving the same player the special role many rounds in a row; give everyone a fair share over time (a hidden "chance" that rises each round without the role).
- **Show the role clearly** at the start with a short reveal; hidden roles must stay hidden from other players' UIs and from client-readable data (the server tells each client only its own role).
- **Selling role chances** (paying to be the murderer or hunter more often) changes the odds of a random outcome with Robux. Under Roblox's paid random item rules, paid probability modifiers must be explained numerically and may require `PolicyService` treatments; this is a policy question for the human before it is designed ([Anime units, gacha and traits](../20-anime-games/anime-units-gacha-and-traits.md), [Monetization compliance](../09-monetization/monetization-compliance.md)).

## Information design

The fun is in what each side knows:

| Tool | Effect |
|---|---|
| Hidden roles | Suspicion and bluffing |
| Limited vision (darkness, fog, flashlights) | Tension; chances to hide |
| Sound cues (heartbeat, footsteps, terror radius) | Warning without full information |
| Reveals (a dropped weapon, a scream, a body) | Moments that change the round |
| Map knowledge | Long-term skill: hiding spots, routes, shortcuts |

Never leak hidden information through replicated data: an exploiter can read anything replicated to their client ([Security and anti-exploit](../13-building-it-right/security-and-anti-exploit.md)).

## Balancing the sides (asymmetric)

- The hunter needs **power** (speed, abilities, detection) and the survivors need **counterplay** (stuns, pallets or barriers, hiding, teamwork).
- Survivors need **objectives** (repair, collect, unlock) that force movement and risk; pure hiding gets boring.
- Track win rates per side by player count and map; aim for roughly balanced over many rounds, adjusting hunter speed, objective counts and timers ([Analytics instrumentation](../13-building-it-right/analytics-instrumentation.md)).
- Scale the hunter or objectives with the number of survivors.

## Maps

- Several maps with distinct layouts and themes; vote between rounds.
- Loops and chokepoints for chases; hiding places with risks; clear exits.
- Lighting tuned for tension but readable on phones ([Lighting and atmosphere](../06-world-and-look/lighting-and-atmosphere.md)).

## The dead and the waiting

- **Spectate** living players with simple controls.
- **Dead-player chat** separate from living players' chat so information does not leak and the dead stay engaged.
- Short rounds and a visible timer so waiting is bearable.
- Mini-activities in the lobby while waiting.

## Problems and fixes

| Problem | Fix |
|---|---|
| Teaming (murderer with friends) | Separate friends' roles where possible; report tools; accept some in casual |
| Leaving when assigned a weak role | Count leaves as losses for streaks; small rewards for finishing rounds |
| AFK players | `Player.Idled` warnings, AFK removal from rounds ([AFK, idle and short-session games](../21-hits-and-trends/afk-idle-and-short-session-games.md)) |
| Hunter griefing at spawn | Spawn protection and a release delay |
| Exploits revealing roles or teleporting | Server-only role data, movement checks |

## Monetization and economy

The genre's long-lasting economy is **cosmetic weapons and effects**: knives, guns, tools, kill effects, radios, pets and emotes, often released in seasonal boxes and tradable. A trading community gives old items value and makes each new season a market event ([Evergreen giants](../21-hits-and-trends/evergreen-giants.md)). Rules:

- Boxes and crates bought with Robux are paid random items: odds disclosure and `PolicyService` treatments apply.
- Trading of paid items is gated by `IsPaidItemTradingAllowed` ([Inventory and trading systems](../13-building-it-right/inventory-and-trading-systems.md)).
- Cosmetics never change hit boxes, speed or detection.

## Retention and social

Seasonal events with themed maps and boxes, levels and prestige, daily challenges ("win as sheriff"), collection books, trading, friends in lobbies.

## Clip moments

Last-second sheriff shots, clutch escapes, the murderer reveal, a survivor outplaying the hunter, rare cosmetic reveals.

## For agents

- [ ] Hidden roles are sent only to their owner; nothing hidden is replicated to other clients.
- [ ] Round length, timers and win rates per side are measured and tuned.
- [ ] Dead players can spectate and chat separately.
- [ ] Any paid role-chance product is escalated as a policy question before design.
- [ ] Crates follow paid random item rules; cosmetic trading follows policy gates.

Sources: [Paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items) · [PolicyService](https://create.roblox.com/docs/reference/engine/classes/PolicyService) · [Player.Idled](https://create.roblox.com/docs/reference/engine/classes/Player) · StudioKrew August 2026 board (citing GGAID); the studio's chart snapshot of 2026-10-24.

Related: [Survival and horror co-op playbook](survival-horror-coop.md) · [Party and minigames playbook](party-and-minigames.md) · [Story horror with chapters playbook](story-horror-chapters.md) · [Trading economies](../04-progression-and-economy/trading-economies.md) · [Evergreen giants](../21-hits-and-trends/evergreen-giants.md)
