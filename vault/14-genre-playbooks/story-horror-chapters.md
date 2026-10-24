---
title: Story horror with chapters playbook
date: 2026-10-24
tags: [genre, horror, story, chapters, puzzles, finite-games, playbook]
aliases: [Chapter horror, Story games, Puzzle horror, Narrative games]
summary: How to build finite, story-driven horror and adventure games on Roblox - chapters released as updates, puzzle and chase design, scares that respect a young audience, co-op, replay value through endings and collectibles, how discovery treats finite games, content maturity, monetization without paywalls, and a chapter production plan.
audience: [human, agent]
---

# Story horror with chapters playbook

Story games give players a beginning, middle and end: escape the house, survive the night, uncover what happened. On Roblox they usually arrive in **chapters**, each released as an update, so a finite game becomes a live one. Chapter horror was one of the platform's big waves around 2020, and story experiences remain on the charts in 2026: on 2026-10-24 a Roblox Presents title, The Hollow, led the up-and-coming sort, and "A Long Flight" (early access) was also rising (studio snapshot). For co-op survival horror with no story arc, see [Survival and horror co-op playbook](survival-horror-coop.md).

Roblox genre: Survival (horror), Adventure or Entertainment (story).

## Discovery and finite games (Fact, discovery FAQ, accessed 2026-10-24)

Roblox's discovery FAQ says story-driven and finite games are **not penalised simply because their genre has lower long-term retention**; recommendations personalise to players who like that kind of game. Chapters still help: each one is a reason to return and a new "update" moment.

## The loop

```
Moment:  explore -> find a clue or item -> solve a puzzle -> a threat appears -> hide or run
Chapter: intro -> 3-6 puzzle beats -> chase or boss -> escape -> ending and cliffhanger
Long:    new chapters -> collectibles and lore -> alternate endings -> harder modes -> skins and characters
```

## Chapter design

| Element | Guidance (Rule of thumb) |
|---|---|
| Length | 15-30 minutes for a first clear; shorter for later replays |
| Structure | Hook in the first 60 seconds, rising tension, a set piece, a release |
| Puzzles | Find-and-use items, codes, switches, simple logic; always readable without text where possible |
| Threat | A visible, learnable hunter with clear rules (sound, sight, patrols) |
| Checkpoints | Generous; frustration kills horror faster than fear |
| Ending | A clear win, a reward, and a cliffhanger or teaser for the next chapter |

Write each chapter as a beat sheet before building: what the player sees, does and feels every 2-3 minutes.

## Scares for a young audience

- **Tension over gore.** Darkness, sound, anticipation and chases work; graphic content raises the maturity rating and shrinks the audience.
- **Telegraph the hunter.** Players should learn its rules and use them.
- **Jump scares sparingly**, with a setting to reduce them or reduce flashing and screen shake ([Lighting and screen effects for VFX](../19-vfx/lighting-and-screen-effects.md)).
- **Content maturity:** fear and violence levels affect the questionnaire answers and which age groups can play; the human completes the questionnaire ([Age ratings and audience](../17-policy-and-business/age-ratings-and-audience.md)).

## Co-op

- 1-4 players per server works well: friends make horror fun.
- Puzzles that benefit from splitting up (one holds a door, one finds the key) without requiring it.
- Revive mechanics or a short respawn so one mistake does not end the chapter for everyone.
- Shared progress with clear "waiting for teammates" UI at gates.

## Replay value

- **Multiple endings** based on choices or secrets.
- **Collectibles** (notes, photos, badges) that reveal lore ([Anime power systems and worldbuilding](../20-anime-games/anime-power-systems-and-worldbuilding.md) has lore delivery patterns that apply here).
- **Harder modes** (nightmare, no checkpoints, faster hunter).
- **Speedrun timers** with server-validated leaderboards.
- **Playable hunter modes** or asymmetric versions of chapter maps ([Social deduction and asymmetric playbook](social-deduction-and-asymmetric.md)).

## Engineering notes

- **Chapter as place or as area:** separate places per chapter keep memory low and allow teleports from a hub; one place with streaming keeps players together ([Matchmaking and teleports](../13-building-it-right/matchmaking-and-teleports.md)).
- **Puzzle state on the server**, replicated to all players in the round; never trust a client's "puzzle solved".
- **Hunter AI** with clear states and perception rules ([NPC AI and pathfinding](../13-building-it-right/npc-ai-and-pathfinding.md)).
- **Cutscenes** with skippable camera sequences after the first view.
- **Save progress per chapter** (completed, endings found, collectibles) in the profile.

## Monetization

| Do | Avoid |
|---|---|
| Character and hunter skins, flashlight styles, emotes | Selling puzzle solutions or skips in the first run |
| Private servers for friend groups | Paywalling the next chapter without a free path |
| Optional revives as a small convenience in hard modes | Revive spam offers during tense moments |
| Chapter-themed bundles at release | Advantages that trivialise the hunter |

Roblox also supports paid access (charging Robux or local currency to join a game); it suits premium story games but cuts discovery and is a business decision for the human ([Monetization strategy](../09-monetization/monetization-strategy.md)).

## Production plan for chapters

| Phase | Content |
|---|---|
| Launch | Chapter 1 polished, hub, skins shop, teaser for Chapter 2 |
| Every 4-8 weeks | A new chapter (map, puzzles, hunter variant, ending) |
| Between chapters | Hard mode, collectibles hunt, seasonal event map, speedrun boards |
| Final chapter | A big finale event; then remasters, modes or a sequel |

Announce the next chapter's date in the game and with a Roblox event listing ([Anime community, updates and codes](../20-anime-games/anime-community-updates-and-codes.md) covers update-day mechanics that apply to any genre).

## Clip moments

Chases with near escapes, the hunter's first appearance, group screams, twist reveals, ending scenes.

## Traps

| Trap | Fix |
|---|---|
| Unclear objectives | Visual hints, highlights on key items, a hint button after a delay |
| Punishing deaths | Checkpoints, revives, short respawns |
| Long gaps between chapters | Interim modes and events |
| Content too intense for the audience | Tension over gore; maturity questionnaire answered honestly |
| Puzzle logic that only the designer understands | Newcomer playtests for every chapter ([Testing and QA](../13-building-it-right/testing-and-qa.md)) |

## For agents

- [ ] Each chapter has a beat sheet, a hunter rules sheet and a newcomer playtest.
- [ ] Puzzle and progress state is server-side; checkpoints are generous.
- [ ] Scare intensity and reduced-scare settings are reviewed against the target maturity rating.
- [ ] The next chapter's date and teaser exist at each release.

Sources: [Discovery FAQ](https://create.roblox.com/docs/discovery-faq) · [Content maturity](https://create.roblox.com/docs/production/promotion/content-maturity) · [Paid access with Robux](https://create.roblox.com/docs/production/monetization/paid-access-robux) · the studio's chart snapshot of 2026-10-24.

Related: [Survival and horror co-op playbook](survival-horror-coop.md) · [Social deduction and asymmetric playbook](social-deduction-and-asymmetric.md) · [Trend waves](../21-hits-and-trends/trend-waves.md) · [World and level design](../06-world-and-look/world-and-level-design.md) · [Lighting and atmosphere](../06-world-and-look/lighting-and-atmosphere.md)
