---
title: Anime power systems and worldbuilding
date: 2026-10-24
tags: [anime, worldbuilding, power-systems, characters, naming, original-ip, design]
aliases: [Original power system, Anime worldbuilding, Naming techniques, Character roster design]
summary: How to design an original anime world the studio owns - the parts of a power system, ten original patterns, franchise-specific terms to avoid, naming patterns for techniques and characters, roster grids that prevent overlap, delivering lore in a Roblox game, and a complete worked example setting.
audience: [human, agent]
---

# Anime power systems and worldbuilding

The power system is the heart of an anime game. It decides what players collect, how combat looks, what updates add, and what the game is called. A franchise's power system is its most recognisable creation, so borrowing one is the fastest route to a takedown. An original one is the studio's most valuable asset: it can be expanded, licensed and merchandised forever. This note shows how to build one. Read with [Anime IP and legal](anime-ip-and-legal.md).

## The five parts of a power system

| Part | Question it answers | Why it matters in a game |
|---|---|---|
| **Source** | Where does power come from? | Decides what players collect (objects, spirits, bloodlines, contracts) |
| **Rules and costs** | What limits it? | Becomes cooldowns, meters, weaknesses and counters |
| **Expression** | What does it look and sound like? | Becomes VFX language, colors and animation style |
| **Growth** | How does it get stronger? | Becomes mastery, evolution, awakening and rebirth systems |
| **Social layer** | Who shares or opposes it? | Becomes factions, clans, guilds, PvP sides and story arcs |

Write one paragraph for each before designing any character. If a part is missing, the game will lack a system that players expect.

## Ten original patterns to start from

These are generic patterns, not borrowed systems. Mix two or three and give them your own names, rules and look.

| Pattern | Source | Game systems it suggests |
|---|---|---|
| **Relic-bound** | Ancient objects that bond with their bearer | Collectible relics with rarity; relic slots; trading |
| **Spirit pacts** | Contracts with spirits of places or ideas | Spirits as summonable units; bond levels; evolutions |
| **Elemental fusion** | Two affinities combine into a third | Combo discovery; loadout choices; element counters |
| **Written techniques** | Spells written in a brush script or code | Crafting moves from parts; a technique "editor" |
| **Bloodlines** | Families carry inherited traits | Random lineage at start; rerolls; clan rivalries |
| **Weapon souls** | Weapons that awaken a personality | Weapon evolution trees; weapon-specific movesets |
| **Realm shaping** | Users impose a pocket world on an area | Domain-style ultimates; arena modifiers |
| **Engine cores** | Mechanical hearts that power suits or bodies | Part upgrades; transformations; mecha bosses |
| **Beast forms** | Bonds with mythical animals grant transformations | Transformation meters; mounts; beast collections |
| **Star charts** | Powers tied to constellations or seasons | Rotating buffs by real-world time; event seasons |

## Franchise-specific terms to avoid

Some words are so tied to one franchise that using them signals the borrowing immediately. Do not use these as system names (the list is not exhaustive): **Devil Fruit, Haki, Chakra, Jutsu (as a system name), Sharingan, Quirk, Cursed Energy, Domain Expansion, Breathing Styles, Bankai, Zanpakuto, Nen, Stand, Titan shifting, Ki blasts named after a franchise's signature moves, Super Saiyan.** Also avoid the franchise's place names, organization names and attack names.

General words are fine: element, spirit, aura, energy, technique, style, form, awakening, mastery, clan, academy, guild.

## Naming patterns

| Thing | Pattern | Example (original) |
|---|---|---|
| Power system | Evocative noun from the source | "Resonance", "Inkcraft", "Pactbinding" |
| Technique | `[Element or theme] [Form]: [Image]` | "Ember Form: Rising Crane" |
| Ultimate | `[Image] of [Grand concept]` | "Requiem of the Hollow Sun" |
| Character | Short given name + epithet | "Ren Aldaine, the Ashen Warden" |
| Faction | `The [Adjective] [Group noun]` | "The Lantern Corsairs" |
| Place | Compound of two images | "Thornreach", "Glasswater Pass" |
| Item rarity line | Consistent suffixes | "Shard", "Fragment", "Core", "Heart" |

Rules of thumb:

- Search every name before use to check it is not a well-known character, technique or brand.
- Keep names pronounceable for young players and short enough for mobile UI.
- If you use another language for flavor, use it correctly.

## Designing the roster without overlap

Use a grid so every character fills a different cell.

| | Rushdown | Zoner | Grappler | Trickster | Support |
|---|---|---|---|---|---|
| **Fire** | ● | | | | |
| **Water** | | ● | | | |
| **Lightning** | | | | ● | |
| **Shadow** | | | ● | | |
| **Light** | | | | | ● |

Add a third axis for personality (stoic, hot-headed, cheerful, scheming, gentle) so characters differ in animation and voice too. When planning updates, fill empty cells first. For each character write:

1. A one-line identity ("a hot-headed fire rushdown who wins up close").
2. A weakness and a counter.
3. A silhouette sketch and element palette ([Anime art, UI and style](anime-art-ui-and-style.md)).
4. Four moves and an ultimate, named with the patterns above.

## Delivering lore in a Roblox game

Players skip text. Lore works when it is short, visual and optional:

- **Environmental storytelling**: ruins, statues, scars from old battles, faction banners.
- **One-line NPC barks** instead of dialogue trees.
- **Item and unit descriptions**: one sentence of flavor each; collectors read them.
- **Boss intros**: a name card and a one-line taunt.
- **Update arcs as story chapters**: each major update advances the world (a new faction appears, a region falls, a rival returns), giving trailers a story.
- **A codex** in the menu for fans who want more.

## Making it ownable

- Keep a **world bible**: power system rules, glossary, factions, places, character sheets, palette, VFX language. Store it in the game's `docs/` folder.
- Keep **dated source files** for all characters and art; contractors assign ownership in writing ([IP and licensing](../17-policy-and-business/ip-and-licensing.md)).
- Trademark or other legal protection for names is a human decision; escalate with `--kind policy`.

## Worked example: an original setting

This is a complete, original example the studio can use as a model (not a plan for a specific game).

**World:** *Tessera*, a sky of floating islands that formed when an ancient sky-dome shattered. Its fragments, called **Shards**, fell among the people.

**Power system: Resonance.**

| Part | Design |
|---|---|
| Source | A Shard bonds with one person; each Shard holds an element and a memory of the old sky |
| Rules and costs | Using Resonance builds **Strain**; at full Strain the user is staggered. Stronger Shards build Strain faster |
| Expression | Light cracks across the user's skin in the Shard's color; techniques look like fractured glass, prisms and shockwaves |
| Growth | Resonance levels unlock techniques; at the top level a Shard **Awakens**, revealing the memory it holds (a new form and ultimate) |
| Social layer | Three factions: the **Wardens** (keep order on the islands), the **Lantern Corsairs** (sky pirates who trade Shards) and the **Archivists** (scholars who seek the old sky). Players pick one, which shapes quests and PvP sides |

**Game fit:**

- *RPG*: islands are regions; Shards drop from bosses and rotate in a shop; Strain is the stamina system; factions drive PvP.
- *Battlegrounds*: each character is a Shard bearer; Awakening is the ultimate meter.
- *Tower defense*: units are Shard bearers; Awakening is evolution; Strain becomes a cooldown mechanic.

**Signature move example:** "Prism Form: Thousand Splinters": the user cracks the air in front of them and a cone of glass shards bursts outward. VFX: a crescent mesh with a prism texture, white-to-cyan particles, a short impact frame ([Combat and anime VFX](../19-vfx/combat-and-anime-vfx.md)).

## For agents

- [ ] The world bible states all five parts of the power system before characters are designed.
- [ ] No franchise-specific terms, names or signature moves appear anywhere.
- [ ] Every name was searched and is not a known character, technique or brand.
- [ ] The roster grid has no duplicate cells; each character has an identity line, weakness and palette.
- [ ] Lore is delivered visually and in short lines; the codex is optional.

Related: [Anime IP and legal](anime-ip-and-legal.md) · [Building an original anime game](building-an-original-anime-game.md) · [Anime battlegrounds and fighting deep dive](anime-battlegrounds-and-fighting.md) · [Art direction](../06-world-and-look/art-direction.md) · [Characters, NPCs and pets](../07-characters-vfx-and-assets/characters-npcs-and-pets.md)
