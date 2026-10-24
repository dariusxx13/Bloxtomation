---
title: Anime IP and legal
date: 2026-10-24
tags: [anime, ip, copyright, trademark, licensing, license-manager, takedowns, policy]
aliases: [Anime copyright, Anime licensing on Roblox, License Manager for anime, DMCA anime games]
summary: The biggest risk in anime games is someone else's IP. What is and is not protected, the inspired-by spectrum and the recognisability test, the takedowns and remodels that hit top anime games, how Roblox's License Manager works (license types, revenue share, offers that auto-activate after 14 days, disputes, expiry), and the studio's rules for agents.
audience: [human, agent]
---

# Anime IP and legal

Most anime games on Roblox borrow, to some degree, from anime franchises owned by publishers and studios that enforce their rights. This note explains the risk and the legal path. It is a practical guide, **not legal advice**. Decisions about disputes, licenses or takedowns belong to the human owner; agents draft and escalate (`python3 agents/studioctl.py escalate --kind policy --note "..." --by <role>`). General IP rules are in [IP and licensing](../17-policy-and-business/ip-and-licensing.md).

## What is protected and what is not

| Generally free to use | Protected (needs permission) |
|---|---|
| The anime **art style**: large expressive eyes, cel-shaded looks, speed lines, dramatic poses | Specific **character designs**: a recognisable combination of hair, outfit, colors, weapon and silhouette |
| **Tropes**: tournaments, rivals, power-ups, transformations, training arcs, academies, pirates, ninjas, demons, spirits | **Names** of characters, techniques, places, organizations and the franchise (copyright and often trademark) |
| **Mechanics**: fruits that grant powers, ability mastery, summons, traits, combos | **Logos, emblems and symbols** tied to a franchise |
| Generic elements: fire, lightning, swords, energy beams | **Signature moves** as expressed: a recognisable technique's look, name and pose together |
| Japanese language and culture | **Music, voice clips and sound effects** from shows and games |
| Your own original characters in an anime style | **Story, scenes and dialogue** from the source |

Ideas and styles are not owned. Expression is. The closer a game gets to a specific franchise's expression, the more risk it carries.

## The inspired-by spectrum

| Level | Example (generic) | Risk |
|---|---|---|
| 1. Original | Original world, power system, characters and names in an anime style | Low |
| 2. Genre-inspired | Pirates with elemental powers, but your own islands, power names and designs | Low |
| 3. Archetype echo | A bald overpowered hero archetype or a masked ninja archetype with original designs | Low to medium, depends on detail |
| 4. Renamed look-alike | A character clearly recognisable as a franchise character, with a descriptive title instead of the name | High |
| 5. Direct copy | Franchise names, logos, designs, music | Very high |

### The recognisability test

Ask: **would a fan of the franchise identify this character, move or place within a second, from the silhouette, colors and pose alone?** If yes, renaming does not help. Distinctive elements to change together, not one at a time:

- hair shape and color,
- outfit cut, colors and emblems,
- signature weapon or accessory,
- signature move's shape, color, pose and name,
- catchphrases and voice,
- theme music.

## What has happened to anime games on Roblox

These are reported by community and press sources; details vary between sources.

| Game | What happened | Lesson |
|---|---|---|
| Blox Fruits | Started under the name Blox Piece and was renamed | Franchise-like names are a liability even for future giants |
| Shindo Life | Originally Shinobi Life 2, later renamed | Same lesson |
| Anime Adventures | Taken down after a copyright claim in December 2023; returned publicly on 2024-12-24 | A takedown can remove a top game for a year |
| Anime Vanguards | Remodelled assets after a copyright claim tied to a major franchise in September 2025 | Even top games redesign under pressure; a remodel costs months of art |
| Many smaller games | Removed or renamed after reports | Most enforcement is invisible because small games just disappear |

## The legal path: Roblox's License Manager (Fact, creator docs, accessed 2026-10-24)

Roblox launched the License Manager and a Licenses catalog in July 2025. At RDC 2025, Kodansha added Blue Lock and That Time I Got Reincarnated as a Slime to the catalog. Rights holders list licenses; creators request them.

### License types

| Type | What it allows |
|---|---|
| **Full game** | Building an entire game around the IP |
| **In-game sales** | Selling IP-based developer products and passes inside a specific eligible game |
| **Marketplace** | Selling IP-based avatar items (body items, clothing, accessories, animations, makeup); each license currently allows up to 100 items; a separate game license is not needed to sell these items inside a game |

### How a request works

1. The game must be **public** before requesting.
2. Pick a license in the Licenses catalog and review its revenue share, duration, content standards and brand guidelines.
3. Write a **pitch**: the vision, the team's track record, creative elements (visuals, audio, story), how gameplay uses the IP, and a timeline. Images are optional for full game requests and required for in-game sales and Marketplace requests.
4. The rights holder approves, rejects, or (for perpetual licenses) sends a **conditional approval** listing changes required before activation.
5. For perpetual licenses, the creator states whether the IP is already integrated; revenue share starts when the agreement becomes active, or later if the rights holder chooses.

Using the IP **before** approval may activate a request or agreement early, and early detected usage can prevent cancelling a request.

### Revenue share

- The rights holder sets a rate between 0% and 95%, and it cannot change once the license is used in an agreement.
- It applies to the game's gross Robux after platform fees, and only to earnings after the agreement is active.
- Docs example at a 10% rate on a 100 Robux sale: a game pass gives the item owner 60 Robux, of which 6 go to the rights holder; a developer product or subscription gives 70 Robux, of which 7 go to the rights holder.
- Items bought on the Marketplace outside the licensed game are not subject to the game's license revenue share.

### Offers sent to you (important for look-alike games)

Rights holders can send a license offer **directly to a game** when Roblox detects a high likelihood that the game makes prominent use of a registered IP.

| Offer type | What happens |
|---|---|
| **Standard offer** | Becomes active automatically after **14 days** unless you dispute it. Active means the rights holder's revenue share and terms apply |
| **Conditional offer** | Requires changes to meet content standards; does not auto-activate; you have 14 days to make the changes or dispute, after which it expires and the rights holder may pursue an infringement claim |

Dispute reasons offered: the game does not use the IP; the use is fair or otherwise legally allowed; or the IP has been removed. If a rights holder rejects a dispute, the offer comes back; a second and final dispute archives it, and the rights holder may file an infringement claim separately.

**For this studio:** a license offer is a decision about terms and money. Under the house rules, agents never accept, dispute or ignore an offer on their own. They record it and escalate it to the human the day it arrives, because the 14-day clock is running.

### Expiry and termination

If a license expires or is terminated, licensed items are removed from sale automatically, and the creator must remove the IP from the game. Players keep items they bought unless separately moderated. Licensed creations can show a **licensed badge**, which the rights holder may remove.

## Choosing a path

| Path | Good for | Costs |
|---|---|---|
| **Original anime-style IP** | Most studios, especially new ones | Character and world design effort; no built-in fanbase |
| **Licensed IP** | Studios with a track record and production capacity | Revenue share, approvals, content standards, brand guidelines, limited duration |
| **Look-alike of a franchise** | Not recommended | Takedown or forced license offer at any time; can't build long-term value |

An original world can be licensed to others, merchandised and expanded without asking anyone. A look-alike can be removed the week it succeeds. See [Building an original anime game](building-an-original-anime-game.md).

## Audio, fonts and text

- **Music and voice**: anime openings, soundtracks and voice clips are protected. Use original music, licensed tracks from Roblox's audio library, or commissioned work with written ownership ([Audio and music](../07-characters-vfx-and-assets/audio-and-music.md)).
- **Fonts**: check that a Japanese-style or display font allows embedding and commercial use, and use Roblox's available fonts where possible.
- **Japanese text**: if the game uses Japanese words, use them correctly (check with a fluent speaker). Fake or garbled Japanese reads as careless to the audience.

## If a claim or takedown arrives

1. Do not re-upload the removed content or create a copy of the game.
2. Escalate to the human immediately with the notice text and what content it names.
3. The human decides whether to remove the content, seek a license, or file a counter-notice. A counter-notice is only for genuine mistakes; false notices or counter-notices are illegal and against Roblox policy.
4. Record the incident and what changed in the game's docs.

## Rules for agents

- Never prompt for, generate or import franchise characters, names, logos, music or designs, even "as a placeholder".
- Do not include franchise names in AI asset prompts; describe original designs instead ([AI asset generation](../16-ai-studio-operations/ai-asset-generation.md)).
- Run the recognisability test on every character, unit and signature move in review.
- Record provenance for every asset ([Asset pipeline](../07-characters-vfx-and-assets/asset-pipeline.md)).
- Escalate any license offer, claim, takedown or license request decision to the human with `--kind policy`.

## For agents

- [ ] The game's IP position (original, licensed, or rejected) is written in the GDD.
- [ ] Every character and signature move passes the recognisability test.
- [ ] No franchise audio, fonts without licenses, or garbled Japanese text.
- [ ] Any license offer is escalated the day it arrives, with the 14-day deadline noted.

Sources: [IP licensing](https://create.roblox.com/docs/ip-licensing) · [Licenses for creators](https://create.roblox.com/docs/ip-licensing/creators) · [License Manager](https://create.roblox.com/docs/ip-licensing/license-manager) · [IP guidelines](https://create.roblox.com/docs/production/publishing/ip-guidelines)

Related: [IP and licensing](../17-policy-and-business/ip-and-licensing.md) · [Anime power systems and worldbuilding](anime-power-systems-and-worldbuilding.md) · [Building an original anime game](building-an-original-anime-game.md) · [Anime genre landscape](anime-genre-landscape.md) · [Community standards for developers](../17-policy-and-business/community-standards-for-devs.md)
