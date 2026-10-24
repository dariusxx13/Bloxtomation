---
title: Building an original anime game
date: 2026-10-24
tags: [anime, process, pitch, prototype, scope, team, original-ip, studio]
aliases: [Anime game plan, How to make an anime game on Roblox, Anime game roadmap]
summary: A stage-by-stage plan for an original anime-style game run through the studio's gates - choosing the sub-genre by content floor, the pitch, the world bible, the vertical slice, the content pipeline for weekly updates, the team and roles, a launch content list, and the first ninety days live.
audience: [human, agent]
---

# Building an original anime game

This note turns the anime section into a plan the studio can execute. It follows the studio's stages (pitch, design, prototype, build, polish, release candidate, live, review) and the gate criteria in `agents/gates/criteria.json`. The rule underneath every step: **original world, original characters, anime style** ([Anime IP and legal](anime-ip-and-legal.md)).

## Step 1: choose the sub-genre by content floor

The biggest mistake is choosing a sub-genre the team cannot feed. Compare the minimum content needed to launch and to sustain weekly updates (Rule of thumb):

| Sub-genre | Launch content floor | Weekly update unit | Team fit |
|---|---|---|---|
| Anime dice / RNG | 30-60 collectible characters (art can be portraits plus simple models), 3-5 stages | 2-4 new characters or a new stage | Small team; strong 2D or portrait artist |
| Battlegrounds | 4-8 characters with full movesets, 1 arena | One character every 1-3 weeks | Animator and VFX artist are critical |
| Anime tower defense | 25-40 units, 2-3 story worlds, infinite mode | 2-4 units, a challenge rotation | Modeller, VFX, economy designer |
| Anime sports | 1 sport mode, 10-20 styles, 2-3 maps | New styles, events | Strong netcode for the ball and players |
| Anime RPG | 1 region with 6-8 islands, 12-20 powers, 5-8 bosses | A power, a boss, QoL; a region every 6-10 weeks | Largest; needs a full team |

Pick the lowest floor that still fits the market opening. A great dice or battlegrounds game beats an unfinished RPG.

## Step 2: the pitch (PITCH gate)

The pitch must meet PITCH-01 to PITCH-08. Anime-specific answers:

| Criterion | Anime answer |
|---|---|
| PITCH-01 market claims | Chart snapshot of the anime sub-genre with dated numbers (`python3 charts/charts.py --help`); trackers named |
| PITCH-02 one-sentence loop | "You roll Shards to unlock bearers so you can clear sky islands and awaken your strongest bearer" |
| PITCH-03 first 60 seconds | First roll within 20 seconds, first fight within 60, first awakening goal within 15 minutes |
| PITCH-04 the twist | What changes how it plays versus named comparables (for example, Strain as a shared stamina meter that makes every fight a resource puzzle) |
| PITCH-05 urgency | Where the sub-genre is in its wave; comparable counts |
| PITCH-07 IP risks | "Original world and power system; no franchise names, designs, music or terms" stated explicitly |

The human approves the pitch; agents never mark it approved.

## Step 3: the world bible and design (DESIGN gate)

Before any building:

1. **World bible**: the five parts of the power system, factions, places, glossary ([Anime power systems and worldbuilding](anime-power-systems-and-worldbuilding.md)).
2. **Roster grid** with identity lines, weaknesses, palettes and move names.
3. **GDD** with loops, the first-session timeline and return systems ([GDD template](../18-templates-and-checklists/gdd-template.md)).
4. **Economy sheet**: summon or roll odds, pity, free-player pulls per week, wave or stage curves ([Economy sheet template](../18-templates-and-checklists/economy-sheet-template.md)).
5. **Catalog draft** passing the fairness rules in [Anime monetization](anime-monetization.md) (DESIGN-07).
6. **Art direction one-pager**: lighting setup, outline technique, palette, silhouette sheet, UI language ([Anime art, UI and style](anime-art-ui-and-style.md), DESIGN-08).
7. **VFX language**: what each element looks like at each tier ([Combat and anime VFX](../19-vfx/combat-and-anime-vfx.md)).

## Step 4: the vertical slice (PROTOTYPE gate)

Build the smallest piece that proves the game is fun:

| Sub-genre | Vertical slice |
|---|---|
| Dice / RNG | Roll, reveal, collect, one stage that uses the collection |
| Battlegrounds | Two characters, full movesets, one small arena, a dummy |
| Tower defense | One map, 6 units, 15 waves, one boss |
| RPG | One island: three enemy types, one boss, two powers with mastery, one quest chain |

Prototype criteria apply: the core action with juice layers 1-4 (PROTO-01), loop tests with evidence (PROTO-02), a newcomer performing the core action within 30 seconds without reading (PROTO-03), and a fun verdict with continue, pivot or stop (PROTO-04). The human makes the continue, pivot or stop decision.

Start from the template (`template/`) so data, purchases, codes, analytics and security are already correct, and spend prototype time on feel.

## Step 5: build the content pipeline (BUILD gate)

Anime games live or die on steady content. Before launch, the pipeline must produce one weekly update unit reliably.

```text
Character or unit pipeline (Rule of thumb, per character):
  concept sheet (identity, palette, silhouette)       0.5-1 day
  model + textures + outline mesh                      2-4 days
  animations (idle, run, 4 moves, ultimate, victory)   3-6 days
  VFX for moves and ultimate (tiered)                  2-4 days
  sounds                                               0.5-1 day
  data entry (stats, odds, descriptions) + tests       0.5 day
  balance playtest                                     0.5-1 day
```

That is roughly 2-3 weeks of combined work per battlegrounds character, less for a TD unit, much less for a dice character. Run several in parallel and **build a buffer of 4-6 weeks of content before launch** so the first two months of weekly updates are already done.

Engineering rules from the build gate apply: remotes through `Net.handle` with validation and rate limits, purchases granted only in `ProcessReceipt`, session-locked data, and the analytics events that measure the loop ([Combat systems and hitboxes](../13-building-it-right/combat-systems-and-hitboxes.md), [Security and anti-exploit](../13-building-it-right/security-and-anti-exploit.md)).

## Step 6: launch content list (POLISH and RC gates)

Rule of thumb for a dice or TD launch (scale by the table in Step 1):

- [ ] Roster at the launch floor, with tiered VFX and reveal effects for every rarity.
- [ ] Odds "Details" panels and pity counters on every banner; `PolicyService` treatments working ([Anime units, gacha and traits](anime-units-gacha-and-traits.md)).
- [ ] First-session flow tested with newcomers; first goal at 10-15 minutes.
- [ ] Codes system live with a launch code; patch-notes panel in the lobby.
- [ ] Event listing for the launch on the Creator Dashboard ([Anime community, updates and codes](anime-community-updates-and-codes.md)).
- [ ] Icon and thumbnails in anime style with original characters ([Anime art, UI and style](anime-art-ui-and-style.md)).
- [ ] Phone performance test with a full server and maximum effects.
- [ ] 4-6 weeks of updates in the buffer.

The release candidate is uploaded as a Saved version; **a person publishes**.

## Step 7: the first ninety days live (LIVE gate)

| Days | Focus |
|---|---|
| 1-3 | Watch errors, economy events, first-session funnel; hotfix daily if needed |
| 4-14 | Weekly update 1 and 2 from the buffer; balance patch with numbers; first event |
| 15-30 | Fix the biggest funnel drop; first featured banner; a returning-player code |
| 31-60 | First major update (new world, mode or system) with a countdown and trailer |
| 61-90 | Review retention cohorts and monetization fairness; decide the next quarter's roadmap |

The analyst runs day-14 and day-60 reviews ([Postmortems](../12-live-ops-and-launch/postmortems.md)). Watch for the classic anime-game warning signs: one unit dominating tier lists, falling ratings after a monetization change, and comments that the game feels abandoned.

## Team and roles

| Role (studio agent) | Anime-specific responsibility |
|---|---|
| Director | Holds the world bible and roadmap; protects the weekly cadence |
| Designer | Power system, roster grid, modes, first session |
| Economist | Odds, pity, curves, free-player pace |
| Artist | Characters, outlines, VFX tiers, reveal effects, audio |
| Interface designer | Anime UI language at phone size, combat HUD, summon screens |
| Engineer | Combat netcode, server simulation, data, codes, purchases |
| Worldbuilder | Islands, arenas, maps with landmarks and budgets |
| Monetization designer | Catalog, fairness table, compliance drafts |
| Security reviewer | Remotes, trades, purchase flows, paid random item gating |
| Scout | Sub-genre wave tracking and comparables |
| Analyst | Funnel, cohorts, tier-list versus usage data |
| Storefront | Icon, thumbnails, title tags, event listings |
| QA tester and Newcomer | Playtests on phones; first-session clarity |
| Gatekeeper | Applies gate criteria with evidence |

Use `python3 agents/studioctl.py route "<text>"` to see who should own a task.

## Common failure modes

| Failure | Prevention |
|---|---|
| Launching with too little content to update weekly | The 4-6 week buffer |
| A beautiful game with weak combat feel | Prototype gate judged on feel first |
| An economy that only works for payers | Economy sheet with a free player column; playtests with free loadouts |
| Franchise drift ("just make him look a bit like...") | Recognisability test in every art review |
| Burnout from weekly updates | Sustainable unit sizes; rotate who works on the update |

## For agents

- [ ] The sub-genre choice is justified by content floor and team fit.
- [ ] The pitch states the IP position on page one and meets PITCH-01 to PITCH-08.
- [ ] A world bible, roster grid and economy sheet exist before building.
- [ ] A 4-6 week content buffer exists before the release candidate.
- [ ] The human makes the pitch approval, prototype decision and publish.

Related: [Anime genre landscape](anime-genre-landscape.md) · [Anime power systems and worldbuilding](anime-power-systems-and-worldbuilding.md) · [Quality gates](../16-ai-studio-operations/quality-gates.md) · [Agent team workflow](../16-ai-studio-operations/agent-team-workflow.md) · [Pitch and greenlight](../15-market-research/pitch-and-greenlight.md)
