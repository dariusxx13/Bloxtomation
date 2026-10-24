---
title: Reference image workflow
date: 2026-10-24
tags: [ai-studio, art-direction, references, briefs, generation, ip]
aliases: [Mood boards, Reference sheets, Visual references for agents]
summary: How the studio collects, annotates and uses reference images so human and AI builders aim at the same look - what makes a good reference, the reference sheet format for briefs, using references with Studio's generation tools, the line between inspiration and copying, and provenance rules.
audience: [human, agent]
---

# Reference image workflow

Words like "cosy", "spooky" or "anime" mean different things to different builders, and to AI models. A handful of well-chosen reference images, annotated with what to take from each, aligns everyone faster than paragraphs of description. This workflow was prompted by the reference-first habit in a community AI bridge the studio reviewed ([AI tooling landscape](../22-references/ai-tooling-landscape.md)) and fits into the studio's briefs ([Build briefs](build-briefs.md)).

## What references are for

| Use | Example annotation |
|---|---|
| Palette | "Take the warm orange-to-purple sunset range" |
| Shape language | "Chunky, rounded silhouettes; no sharp spikes" |
| Lighting mood | "Low sun, long shadows, soft fog in valleys" |
| Composition | "Landmark visible from spawn, path curving toward it" |
| Material feel | "Painted wood, not realistic grain" |
| UI style | "Thick outlines, bouncy buttons, big numbers" |
| Effect timing | "Fast anticipation, big flash, slow sparkle fade" (video reference) |

Each reference answers **one question**. A reference without an annotation is noise.

## Collecting references

Good sources:

- Photos and screenshots **the team takes** (real places, objects, its own earlier games).
- Public-domain and openly licensed images, recorded with their license.
- Art-direction sketches and paintovers made for the project.
- Screenshots of other games **for analysis only** (layout, readability, timing), never as assets.

Rules:

- Collect 5-12 references per brief; more dilutes the direction.
- Include one **"not this"** reference showing what to avoid.
- Keep references in the game's docs folder (`games/<id>/docs/references/`) with a short index file.

## The reference sheet (for briefs)

```markdown
## Visual references
| # | File | Take from it | Do not take |
|---|------|--------------|-------------|
| 1 | refs/sunset-hills.jpg (own photo) | Palette and fog | Realistic textures |
| 2 | refs/blockout-v2.png (our blockout) | Path layout to the landmark | Placeholder colours |
| 3 | refs/ui-paintover.png (our paintover) | Button shape and outline weight | Text content |
| 4 | refs/not-this.png (our test render) | Nothing: too dark on phones | - |
```

The Artist, Worldbuilder and Interface Designer agents read this table before building; the Gatekeeper checks results against the "take from it" column at POLISH reviews ([Quality gates](quality-gates.md)).

## Using references with AI tools (Fact, Studio MCP docs, accessed 2026-10-24)

- The built-in Studio MCP server can **load an image from a local file** and pass it as a **reference image to procedural model generation**, and can generate meshes and material variants from prompts ([Studio MCP playbook](studio-mcp-playbook.md)).
- Roblox announced a **Scene Generator** that turns a prompt plus a reference image into a playable layout, for Build and Studio later in 2026 (Roblox newsroom, RDC 2026).
- Generated results are drafts: review them against the reference sheet, fix proportions and palette, and record them in the asset index ([AI asset generation](ai-asset-generation.md)).

## Inspiration versus copying

| Allowed | Not allowed |
|---|---|
| Learning palette, mood and composition from many sources | Recreating a specific game's map, character or UI |
| Using your own photos and sketches as input to generation | Feeding another game's screenshots or franchise art to a generator to get look-alikes |
| Studying another game's readability and timing | Tracing, extracting or uploading another game's textures, meshes or icons |
| Public-domain or properly licensed images with records | Uploading copyrighted images to Roblox without rights |

Uploading images to Roblox (including through tools that upload from URLs) must only use images the studio has the right to use ([IP and licensing](../17-policy-and-business/ip-and-licensing.md), [Anime IP and legal](../20-anime-games/anime-ip-and-legal.md)).

## Provenance

For every reference and every generated asset that used one, record: file, source, license or "own work", date, and which brief used it. Generated assets also record the prompt and the tool ([Asset pipeline](../07-characters-vfx-and-assets/asset-pipeline.md)).

## For agents

- [ ] Visual briefs include a reference sheet with 5-12 annotated references and one "not this" example.
- [ ] References are own work, public domain or licensed, with records; other games' images are analysis-only.
- [ ] Generated assets are reviewed against the sheet and recorded with prompt, tool and reference.

Sources: [Connect to the Roblox Studio MCP server](https://create.roblox.com/docs/studio/mcp) · Roblox newsroom, [RDC 2026](https://about.roblox.com/newsroom/2026/09/rdc-2026-the-world-needs-more-play) (accessed 2026-10-24).

Related: [Build briefs](build-briefs.md) · [AI asset generation](ai-asset-generation.md) · [Art direction](../06-world-and-look/art-direction.md) · [Studio MCP playbook](studio-mcp-playbook.md) · [AI tooling landscape](../22-references/ai-tooling-landscape.md)
