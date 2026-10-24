---
title: Learning and hiring for VFX
date: 2026-10-24
tags: [vfx, learning, hiring, careers, commissions, team]
aliases: [VFX learning path, Hiring a VFX artist, VFX commissions, VFX portfolio]
summary: A practical path to learn Roblox VFX in eight weeks, what a VFX portfolio should show, how VFX commissions and hiring work, how to brief and review a VFX artist, and red flags in purchased effects.
audience: [human, agent]
---

# Learning and hiring for VFX

VFX is one of the most in-demand skills on Roblox because combat, anime, RNG and simulator games all sell on spectacle. This note is for two readers: someone who wants to learn to make effects, and a studio (or an AI Director) that needs to hire or brief someone who does.

## An eight-week learning path (Rule of thumb)

| Week | Focus | Practice project |
|---|---|---|
| 1 | Particle basics: every property in [Particle emitters in depth](particle-emitters-in-depth.md) | Smoke, sparks, dust, magic motes; one emitter each |
| 2 | Layering and timing | Explosion with five layers; hit spark with hitstop |
| 3 | Beams and trails | Laser, lightning, sword trail, dash streaks |
| 4 | Textures | Paint ten grayscale textures; replace defaults in weeks 1-3 effects |
| 5 | Meshes in Blender | Ring, dome, crescent; shockwave and slash effects |
| 6 | Scripting effects | A client effect module triggered from a server event; pooling; animation markers |
| 7 | Flipbooks and screen effects | One hand-drawn 4×4 impact; impact frame; camera shake |
| 8 | A themed kit | Six moves for one character (M1, dash, two skills, finisher, ultimate) with tiers and budgets |

Habits that speed learning:

- **Study reality and great games frame by frame.** Record a clip and step through it to see how many frames each phase lasts. Learn the timing, not the exact look.
- **Recreate, then reinvent.** Recreating an effect you admire is good practice; shipping a copy of someone else's signature effect is not. Change shape, color and timing until it is yours.
- **Always pair with sound.** An effect reviewed silently is reviewed half.
- **Test on a phone weekly.**

## What a VFX portfolio should show

- Short clips (5-15 s) of effects in context: on a character, in a real lighting setup, with sound.
- A range: combat, magic, environment, UI/reward.
- At least one **move kit** showing tier escalation from basic hit to ultimate.
- Performance awareness: a note on particle counts or a low-quality version.
- Clean organisation: what the folder structure and naming look like.
- For scripters: a clip showing client replication working with two clients side by side.

## Hiring and commissions

Common ways Roblox studios get VFX:

| Route | Notes |
|---|---|
| Full-time or contract team member | Best for games where VFX is the product (battlegrounds, anime TD); consistency across the whole game |
| Per-effect or per-kit commissions | Common for smaller teams; agree on revisions, deadlines, file formats and ownership up front |
| Effect packs from marketplaces | Fast and cheap, but generic and riskier (licenses, scripts); see below |
| Revenue share | Common on Roblox, risky for both sides; put terms in writing |

Recruitment usually happens through the Roblox Talent Hub, the Developer Forum's collaboration categories, VFX community servers and portfolio sites. Prices vary widely with skill and scope; ask for quotes per move tier rather than per "effect".

### What to put in a VFX brief

- The game, its art direction and palette, with reference images.
- The list of effects with **tiers**, triggers and timing beats (anticipation, impact, follow-through).
- Animation files or marker names the effects must sync to.
- Budgets per tier ([Combat and anime VFX](combat-and-anime-vfx.md)) and target devices.
- Delivery format: an `.rbxm` per effect with templates, emit settings as attributes, textures uploaded to the game's group, a preview script.
- Ownership: who owns the textures, meshes and code; the license must allow use and modification in your game indefinitely.
- Review rounds and acceptance criteria (for example "reads clearly on a phone at 30 studs; under 120 live particles").

The studio's agent team uses the same structure: the Artist agent receives effect briefs with tiers and budgets, and the Gatekeeper checks POLISH-04 (rarest outcomes clearly more exciting than common ones) against the effects.

## Reviewing delivered effects

1. Play each effect in the real game context, with sound, at real distances.
2. Check the tier table: does the ultimate feel bigger than the skill?
3. Count particles and meshes; run the stress test on a phone.
4. Open the files: no scripts you did not expect, assets owned by your group, clean naming.
5. Check readability: can a new player tell where the danger is?

## Red flags in bought or delivered effects

- Scripts inside effect models (particles do not need scripts; a backdoor might).
- Textures uploaded to a stranger's account (they can be deleted or changed later).
- Effects that only look good at high graphics quality.
- Hundreds of particles per emitter, or emitters left enabled.
- Obvious copies of a famous anime's signature attack, name and colors together (IP risk; see [Anime IP and legal](../20-anime-games/anime-ip-and-legal.md)).

## For agents

- [ ] Effect briefs include tiers, timing beats, markers, budgets, delivery format and ownership.
- [ ] Delivered effects are reviewed in context with sound, on a phone, with counts.
- [ ] Purchased packs are scanned, re-tinted to the art direction and recorded in the asset index.

Related: [VFX tools and workflow](vfx-tools-and-workflow.md) · [Asset pipeline](../07-characters-vfx-and-assets/asset-pipeline.md) · [Money, DevEx and teams](../17-policy-and-business/money-devex-and-teams.md) · [Build briefs](../16-ai-studio-operations/build-briefs.md)
