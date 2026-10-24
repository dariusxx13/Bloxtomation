---
title: Glossary
date: 2026-10-24
tags: [reference, glossary]
aliases: [Terms, Vocabulary]
summary: Roblox, game design, business and agent-team terms used across this vault, defined in one line each.
audience: [human, agent]
---

# Glossary

| Term | Meaning |
|---|---|
| Active spender | A user who spent at least $9.99 on Robux, Premium or UGC subscriptions in the last 60 days and was not new or reactivated in that period (Creator Rewards) |
| ARPDAU | Average revenue per daily active user |
| ARPPU | Average revenue per paying user |
| ARPU | Average revenue per user |
| Atomic (streaming) | A model that streams in and out as one unit |
| Aura | A visual effect around a character, often a collectible status item |
| Battle pass / season pass | A track of rewards earned by play over a season, with free and premium tracks |
| Bounce (first-play bounce) | Leaving shortly after joining for the first time; a negative discovery signal |
| Breakout | A young or small game rising fast in the charts |
| Clip moment | A moment players want to record and share |
| Co-play days | Days a user returns to play with friends (a discovery signal) |
| Config (ConfigService) | Live key-value settings changeable without publishing |
| Content May Vary | Label for games that skipped the full questionnaire; 16+ only |
| Contextual offer | A product shown at the moment it is most useful or desirable |
| Creator Rewards | Roblox program paying for daily engagement of active spenders and for bringing new or returning users |
| CPP | Cost per play (ads) |
| D1 / D7 / D30 | Share of new users returning 1, 7, 30 days after first play |
| DAU / CCU | Daily active users / concurrent users |
| Developer product | A repeatable Robux purchase |
| DevEx | Developer Exchange: converting earned Robux to money |
| Drop table | The list of possible random outcomes and their weights |
| Earned Robux | Robux earned from creating value (sales, rewards), eligible for DevEx |
| Economy event | Analytics event for a currency source or sink |
| Explore and expand | How recommendations test a game with new cohorts and widen reach if they engage |
| FTUE | First-time user experience |
| Funnel | A sequence of steps whose conversion you measure |
| Gate (stage gate) | A checklist work must pass to move to the next stage |
| Golden path | The intended new-player path through the first session |
| Hard pity | A guaranteed rare outcome after N unsuccessful tries |
| House rule | A deliberate choice of this vault for consistency |
| IAS | Input Action System |
| Juice | Extra feedback that makes actions feel satisfying |
| Launch data | Data attached to a join link, read with `GetJoinData()` |
| Lapsed user | A user inactive for a period (60 days for Creator Rewards; 30-180 days for Ads Manager "lapsed" audiences) |
| Like ratio | Upvotes divided by total votes |
| Live ops | Running a game after launch: updates, events, tuning |
| Locals / tourists | Roblox's terms for deeply engaged players vs game-hoppers |
| Managed pricing | Roblox system combining regional pricing and price optimization |
| MDE | Minimum detectable effect of an experiment |
| Moment / session / long loop | Loops at the scale of seconds, minutes, and days |
| Obby | Obstacle course game |
| PCR | Payer conversion rate: payers divided by active users |
| Pass (game pass) | A one-time Robux purchase granting permanent benefits |
| Pity | A rule that improves odds or guarantees an outcome after bad luck |
| Play-through rate (PTR) | Share of users who play after seeing the game's tile |
| PolicyService | Per-player compliance rules (random items, trading, ads, etc.) |
| ProcessReceipt | The callback that grants developer products |
| Qualified play | A meaningful play session (filters accidental clicks) |
| Rebirth / prestige | Resetting progress for a permanent bonus |
| RFY | Recommended for You, the main Home sort |
| Rojo | Tool syncing a file-based project into Roblox Studio |
| Rule of thumb | A heuristic, not a platform fact |
| Script Sync | Studio's built-in syncing of scripts to disk |
| Session locking | Ensuring only one server owns a player's data at a time |
| Share link | A trackable link to your game, used for attribution and Creator Rewards |
| Sink / source | Where currency leaves / enters the economy |
| Soft / hard currency | Earnable everyday currency / scarcer premium currency |
| Streaming | Loading parts of the world around the player |
| Studio MCP | Roblox Studio's built-in server that lets AI clients control Studio |
| Subscription | A monthly auto-renewing purchase |
| Tier (age) | Roblox Kids, Roblox Select, Roblox (16+) |
| Time to goal | Minutes a player needs to reach a goal, computed from cost and income |
| Universe / place | A game (universe) and its places (levels or servers' worlds) |
| Variant / mutation | A modified version of an item (golden, shiny, giant) |

## Terms from the VFX, anime, hits, engineering and reference sections

| Term | Meaning |
|---|---|
| Actor (Parallel Luau) | An instance whose scripts can run in parallel with other actors' scripts |
| Adaptive Animation | A system that maps custom rigs to Roblox's standard joints so they can play standard animations |
| Admin abuse event | A scheduled live session where developers trigger generous, chaotic effects for everyone online |
| Animation Graph Editor | Studio's node-based tool for blending and state machines of animations |
| Animation marker (event) | A named point in an animation that fires a signal, used to time hits, effects and sounds |
| Anomaly (job games) | A hidden "wrong" customer, patient or event players must notice in a job simulator |
| Anti-infinite rules | Combat limits (stun decay, combo scaling, hit caps, evasives) that stop endless combos |
| Asymmetric game | A game where sides have different roles and powers, such as one hunter versus several survivors |
| Assembly | Parts joined rigidly or by joints that the physics engine treats as one body |
| Awakening | An upgraded form or moveset unlocked late, common in anime games |
| Banner | A summon pool shown to players, often with featured units at boosted odds |
| Battlegrounds | A free-for-all arena fighting genre with character movesets |
| Beam | An effect object that draws a textured strip between two attachments |
| Brainrot | Absurd internet meme characters; the theme of a 2025 record-setting game |
| Consequence layer | Risk of loss caused by other players (stealing, raids) added to a loop |
| Content floor | The minimum content needed to launch and to sustain a regular update rhythm |
| Cross-server messaging | Sending messages between a game's servers with MessagingService (best effort) |
| Evasive | A combo-breaker escape on a meter or cooldown in fighting games |
| Expected pulls | Average number of summons needed for a result, including pity |
| Flipbook | A sprite-sheet texture played as frames by a particle emitter |
| Hitstop | A brief freeze of attacker and victim on impact that sells weight |
| Impact frame | A few frames of high-contrast silhouette at the moment of a big hit |
| Input Action System | Roblox's declarative input actions and contexts, required by the server authority model |
| Instance stitching | Merging a client-predicted instance with the server's copy under server authority |
| Lag compensation | Validating hits against where targets were, rewound by the attacker's latency |
| License Manager | Roblox's tool for rights holders to license IP to creators; offers can auto-activate after 14 days |
| Licenses catalog | The list of IP licenses creators can request on Roblox |
| Managed pricing | Roblox's combined regional pricing and price optimization system |
| MemoryStore | Fast, expiring shared storage across a game's servers (sorted maps, queues, hash maps) |
| Mesh VFX | Effects built from textured meshes (rings, domes, slashes) animated with tweens |
| Moments | A Roblox tab of gameplay videos that link straight to play |
| Network ownership | Which machine (server or a client) simulates an unanchored part's physics |
| Novelty fade | The drop in players after a fresh premise has been fully experienced |
| Overdraw | Drawing many transparent layers on the same pixels, the main VFX cost on phones |
| Pity | A guarantee of a top result after a number of unsuccessful rolls |
| Power creep | New content that makes old content obsolete by being strictly stronger |
| Prediction (client) | A client showing the result of its input before the server confirms it |
| Probability modifier | A luck boost, pity system or rate-up that changes odds; paid ones must be explained |
| Recognisability test | Asking whether a fan would identify a franchise character from silhouette, colours and pose |
| Reserved server | A private server reachable only by teleport with its access code |
| Rollback and resimulation | Under server authority, rewinding a mispredicted client to the server's state and replaying inputs |
| Scene Analysis | Studio's treemap views of memory, instances and triangles during play |
| Server authority model | Roblox's model where the server owns simulation and clients predict inputs |
| Session shape | Whether a game is built for long sessions or short, frequent ones |
| Sharding | Splitting one data structure into several to spread request load |
| Shapecast | A spatial query that sweeps a box or sphere along a direction |
| Social deduction | A hidden-role genre where players work out who is who |
| Standard offer (licensing) | A rights holder's license offer to a game that activates after 14 days unless disputed |
| Title tag | A bracketed prefix in a game title announcing an update, event or boost |
| Trait | A random modifier on a unit or character, often rerollable |
| Trend wave | A burst of similar games after one spark game finds a new loop or theme |
| Unit (anime TD) | A collectible character placed in tower defense matches |
| Web play | Playing Roblox in a browser from a link, announced for Chrome by the end of 2026 |
| Wire (audio) | The object that carries an audio stream between modular audio objects |

Related: [Key numbers](key-numbers.md) · [API quick reference](api-quick-reference.md) · [How to use this vault](../00-start-here/how-to-use-this-vault.md)
