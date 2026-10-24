---
title: Art direction
date: 2026-10-24
tags: [art, visuals, style, branding]
aliases: [Visual style, Art style]
summary: How to choose and hold a visual style that reads on phones, matches the audience, stands out on the Home page and stays cheap to produce.
audience: [human, agent]
---

# Art direction

Art direction is the set of decisions that make every asset in the game look like it belongs together: shapes, colors, materials, lighting, UI style and effects. On Roblox, a clear art direction does three jobs: it sells the game in a 150-pixel icon, it reads on a small phone screen, and it keeps a small team (or an agent team) producing consistent assets fast.

## Choose a style on purpose

| Style | Looks like | Strengths | Risks | Fits |
|---|---|---|---|---|
| Bright stylized (toy-like) | Saturated colors, rounded shapes, simple textures | Reads on phones, cheap, kid-friendly, performant | Can look generic | Simulators, tycoons, obbies, pets, farms |
| Low-poly flat | Faceted shapes, flat or gradient colors | Very cheap, clean, cohesive | Can look empty | Survival, exploration, casual |
| Anime / cel-shaded feel | Strong outlines, vivid VFX, dramatic poses | Huge audience appeal, great clips | VFX and animation heavy | Battlegrounds, RPGs, RNG auras |
| Semi-realistic | PBR materials, realistic lighting | Stands out, appeals to older players | Expensive, heavy on low-end phones | Horror, shooters, 16+ games |
| Cartoon horror | Exaggerated creatures, dark palette with color accents | Scary but readable, all-ages possible | Content rating care | Co-op horror, 1-vs-all |
| Meme / collage | Internet-culture characters, absurd mixes | Viral potential | Short trend life, IP risk | Brainrot-style trend games |

Rules of thumb:

- **Match the audience.** Younger players respond to bright, saturated, rounded art; older players accept darker and more detailed styles. The US 18+ DevEx rate also rewards high-quality R15 character articulation for older-audience games.
- **Match the trend, then twist it.** If the genre's top games all use one look, use a recognizable variation, not a copy. Roblox demotes games whose visuals closely match existing games.
- **Choose what you can produce.** A style the team can make 50 consistent assets in, every week, beats a gorgeous style that takes a week per asset.

## The style guide (one page)

Write a one-page style guide before making assets. Agents and contractors follow it; reviewers check against it.

1. **Palette**: 5-8 main colors plus accents for rarity tiers and UI. Give hex values.
2. **Shapes**: rounded or angular; proportion rules (for example, chunky with big heads for pets).
3. **Materials**: which Roblox materials and textures are allowed (SmoothPlastic and a few custom `MaterialVariant`s is a common stylized choice).
4. **Outlines and edges**: outlines on characters or not; bevel rules.
5. **Lighting mood** per zone (see [Lighting and atmosphere](lighting-and-atmosphere.md)).
6. **UI style**: corner radius, stroke thickness, fonts, button shapes (see [UI principles for Roblox](../05-ui-and-hud/ui-principles.md)).
7. **VFX language**: particle shapes, colors per element, how rarity is expressed.
8. **Reference images**: 6-12 images showing the target look (your own concept art or annotated screenshots).

## Readability rules

- **Silhouettes first.** Important objects (enemies, collectibles, interactables) are recognizable by shape alone at a distance.
- **Value contrast.** Interactive objects are brighter or more saturated than the background. Backgrounds are calmer.
- **Color means something.** Reserve your strongest accent color for "interact with this" or "valuable". Do not paint scenery in rarity colors.
- **Scale tells importance.** Bosses, gates and landmarks are big; clutter is small.
- **Test at phone size.** Take a screenshot, shrink it to phone size, and check that the player, the objective and threats are visible.

## Identity and branding

- A memorable **mascot or hero object** (the main pet, the signature weapon, the main creature) appears in the icon, thumbnails, lobby and loading screen. It becomes the game's face.
- A **logo** with a short readable title for thumbnails and in-game signs.
- **Consistent color identity** across icon, thumbnails and the first frame of the game, so the click delivers what the image promised.

## Cost-saving techniques

- **Modular kits**: walls, floors, rocks and props built to a grid so levels are assembled, not sculpted.
- **Color variants**: the same model in different palettes for zones or rarity tiers.
- **Material variants and decals** instead of new meshes for variety.
- **Procedural placement** scripts for scattering trees and rocks consistently.
- **AI generation** for drafts and filler (Studio's mesh and material generation, external tools), always checked against the style guide and cleaned up. See [AI asset generation](../16-ai-studio-operations/ai-asset-generation.md).

## For agents

- [ ] A one-page style guide exists with palette hex values, shape rules, materials and reference images.
- [ ] New assets are reviewed against the style guide before use.
- [ ] Interactive and valuable objects are visually distinct from scenery at phone size.
- [ ] The icon, thumbnail and first in-game frame share the same hero object and colors.
- [ ] The look is a recognizable variation within its genre, not a copy of a specific game.

Related: [World and level design](world-and-level-design.md) · [Lighting and atmosphere](lighting-and-atmosphere.md) · [Asset pipeline](../07-characters-vfx-and-assets/asset-pipeline.md) · [Icons](../11-store-page-and-discovery/icons.md)
