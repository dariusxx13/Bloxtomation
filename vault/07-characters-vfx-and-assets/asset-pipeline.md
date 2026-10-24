---
title: Asset pipeline
date: 2026-10-24
tags: [assets, pipeline, creator-store, blender, ai, licensing, safety]
aliases: [Assets, Asset sourcing, Free models]
summary: How to source, create, check, organize and reuse 3D models, textures, sounds and animations safely and legally.
audience: [human, agent]
---

# Asset pipeline

An asset pipeline is how models, textures, sounds and animations get from an idea (or a store) into your game: sourced or made, checked, optimized, uploaded, organized and reused. A good pipeline is fast and safe. A bad one leaks backdoors into your game, breaks moderation rules, or makes every new game start from nothing.

## Where assets come from

| Source | Good for | Risks | Required checks |
|---|---|---|---|
| Your own creation (Studio parts, Blender, other tools) | Hero assets, characters, anything that defines the look | Time cost | Style guide, budgets |
| Creator Store (free) | Props, placeholders, sounds | Malicious scripts, poor quality, unclear ownership of sub-assets | Script scan, ownership check, optimization |
| Creator Store (paid models and plugins, sold in USD) | Quality props, systems, tools | Cost | Reviews, license understanding |
| Roblox's own asset packs and Roblox-provided audio | Safe defaults | Generic look | Fit to style |
| AI generation (Studio mesh, material and procedural model generation; external tools) | Drafts, filler, variety | Inconsistent style, licensing of external tools' outputs, moderation | Style review, license terms of the tool, cleanup |
| Contractors | Anything | IP ownership | Written agreement assigning rights |

## Creator Store safety (non-negotiable)

Free models are the most common way games get backdoored: a hidden script gives someone else admin, inserts ads, or steals data.

- **Insert without scripts when you only need visuals.** Studio offers an option to insert an asset without allowing its scripts to run. Then delete every script inside.
- **Scan every inserted model** for `Script`, `LocalScript` and `ModuleScript` instances, `require()` calls with numeric ids (loading remote modules), `getfenv`/`setfenv`, `loadstring`, obfuscated strings, and anything touching `HttpService`, `TeleportService` or `MarketplaceService`. Remove or rewrite.
- **Keep `LoadStringEnabled` off** and allow HTTP requests only if your game needs them.
- **Prefer meshes over scripted models** for props.
- **Keep a record** of where each asset came from (asset id, creator, date) in an asset index, so you can answer "is this safe and are we allowed to use it?" months later.

## Ownership and licensing

- **Distribution rules.** Creator Store assets distinguish dependencies that are open for anyone to use from restricted ones. You may use and redistribute composite assets only within those rules; you cannot redistribute restricted dependencies you did not upload.
- **Animations and audio must be owned by (or permitted for) the game owner** to play. Upload them to the group that owns the game.
- **External AI tools**: read each tool's terms. Some free tiers license outputs under terms that require attribution or forbid commercial use; paid tiers usually grant broader rights. Record which tier generated each asset.
- **Real-world IP** (brands, characters, songs, logos) is not yours to use without a license. See [IP and licensing](../17-policy-and-business/ip-and-licensing.md).
- **Asset privacy**: Roblox lets you control whether uploaded assets can be used by others; keep sensitive assets private.

## Making assets (Blender and Studio)

- Model at Roblox scale (1 stud is roughly 0.28 m, but match the avatar: about 5 studs tall) and keep pivots sensible.
- Keep triangle counts appropriate to the asset's screen size; bake detail into textures.
- Texture sizes: 512 px for most props, 1024 for hero assets, smaller for distant things. Use texture atlases for kits.
- Name parts and materials clearly; remove hidden geometry.
- Import with the 3D Importer; check scale, orientation and collision fidelity.
- Use `MaterialVariant`s and `SurfaceAppearance` for consistent stylized or PBR looks.

## AI-assisted assets

Studio can generate meshes and materials from text, and build procedural models from primitive parts, including through its built-in MCP server for AI agents. External tools can generate meshes and images too. Use them for speed, not as a replacement for direction:

1. Write a prompt from the style guide (palette, shape language, material, size).
2. Generate several options; pick the closest.
3. Clean up: scale, pivot, triangle count, texture size, collision.
4. Review against the style guide next to existing assets.
5. Record the source and license in the asset index.

See [AI asset generation](../16-ai-studio-operations/ai-asset-generation.md).

## Organizing for reuse

- **Packages** for assets used in many places or many games (a shop kiosk, a UI kit, a pet base model). Updating the package updates every copy.
- **An asset index** (a simple JSON or spreadsheet): id, name, type, source, license, owner, games using it, notes. New games search the index before making anything new.
- **Kits** organized by theme (forest, lava, candy) so new zones are assembled from existing parts.
- **Version control** for source files (Blender files, textures) outside Roblox.

## Moderation

All uploads (images, meshes, audio, video) are moderated. Realistic gore, sexual content, real-person likenesses without rights, and hate symbols get removed regardless of your game's maturity label, and repeated violations risk your account. Keep uploads clean, and do not try to sneak content past moderation.

## For agents

- [ ] Every inserted Creator Store model scanned; all scripts removed or reviewed; result logged.
- [ ] Asset index entry (id, source, license, owner) for every non-trivial asset.
- [ ] Animations and audio owned by the game's owner account or group.
- [ ] AI-generated assets record the tool and tier; external tool terms allow commercial use.
- [ ] Assets checked against the style guide and budgets before use.
- [ ] Reusable items converted to packages.

Related: [Art direction](../06-world-and-look/art-direction.md) · [AI asset generation](../16-ai-studio-operations/ai-asset-generation.md) · [IP and licensing](../17-policy-and-business/ip-and-licensing.md) · [Security and anti-exploit](../13-building-it-right/security-and-anti-exploit.md) · [Build budgets](../06-world-and-look/build-budgets.md)
