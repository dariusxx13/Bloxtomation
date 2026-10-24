---
title: AI asset generation
date: 2026-10-24
tags: [ai, assets, generation, art, workflow]
aliases: [AI art, Generated assets, Mesh generation]
summary: How to use AI tools to produce Roblox-ready assets (meshes, materials, procedural models, textures, thumbnails) that match the style guide, stay within budgets, and are legally safe.
audience: [human, agent]
---

# AI asset generation

AI tools can produce drafts of meshes, materials, textures, icons and thumbnails in minutes. Used with direction and review, they speed up small teams enormously. Used without direction, they produce an inconsistent, generic-looking game with licensing risks.

## Tools available

| Tool | Output | Notes |
|---|---|---|
| Studio mesh generation (also via the Studio MCP `generate_mesh`) | Textured meshes from text | Good for props and drafts; check scale and triangle count |
| Studio material generation (`generate_material`) | Material variants | Consistent surfaces from text descriptions |
| Studio procedural models (`generate_procedural_model`) | Models built from primitive parts with configurable attributes; can use reference images | Great for stylized, blocky assets that match Roblox's look and stay cheap |
| Studio texture generation | Textures for meshes | Iterate on look without remodeling |
| External 3D generators | Meshes | Read the license; some free tiers restrict commercial use or require attribution |
| Blender (manual or through community MCP integrations) | Cleanup, retopology, UVs, baking, rigging | Turns drafts into production assets |
| Image generators | Concept art, icon and thumbnail backgrounds, UI art | Thumbnails must still reflect real gameplay; moderation applies |
| Ads Manager AI creatives | Ad thumbnails from a description | Convenient for ad variations |

## The workflow

1. **Brief from the style guide**: palette, shape language, material rules, intended size in studs, triangle and texture budgets. See [Art direction](../06-world-and-look/art-direction.md).
2. **Generate several options** (3-5), including at least one with a reference image when consistency matters.
3. **Select** the closest option by comparing screenshots next to existing assets in the game.
4. **Clean up**: correct scale and pivot, reduce triangles, fix UVs and texture size, set collision fidelity, apply the game's materials and colors.
5. **Review**: style consistency, readability at gameplay distance and on phones, budget compliance.
6. **Record** in the asset index: tool, tier or plan, prompt, date, license notes, owner.
7. **Reuse**: convert successful assets into packages and kits.

## Prompting tips for game assets

- Describe function and context, not just appearance: "a low-poly stylized treasure chest for a kids' pirate game, chunky proportions, bright gold trim, readable from 30 studs away".
- Include style constraints: "flat colors, no small details, soft rounded edges".
- Specify size relative to the Roblox character (about 5 studs tall).
- Ask for variations by changing one attribute at a time (color, rarity tier, damage state).

## Thumbnails and icons with AI

- Generated imagery can help with composition and backgrounds, but the hero content of thumbnails must reflect real gameplay and the actual look of the game. Misleading thumbnails are demoted and can be moderated.
- Prefer compositing real in-game renders (captured with freecam) over fully generated scenes.
- Test variants with thumbnail personalization rather than guessing.

## Legal and safety

- Check the terms of every external tool: commercial use rights, attribution requirements, and whether outputs can be claimed by others.
- Do not prompt for copyrighted characters, brands, logos or real people. Generated look-alikes of protected characters are still infringement risks.
- All uploads are moderated; generated content is not exempt.
- Keep the provenance record; it is your answer if an asset is ever challenged.

## For agents

- [ ] Every generated asset has a brief derived from the style guide.
- [ ] Options compared side by side with existing assets before selection.
- [ ] Cleanup meets budgets (triangles, textures, collision).
- [ ] Asset index entry with tool, tier, prompt and license notes.
- [ ] No prompts targeting protected IP or real people.

Related: [Asset pipeline](../07-characters-vfx-and-assets/asset-pipeline.md) · [Art direction](../06-world-and-look/art-direction.md) · [Studio MCP playbook](studio-mcp-playbook.md) · [IP and licensing](../17-policy-and-business/ip-and-licensing.md)
