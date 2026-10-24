---
title: Tooling and CI
date: 2026-10-24
tags: [engineering, tooling, rojo, wally, selene, stylua, lune, ci, open-cloud]
aliases: [Rojo setup, Toolchain, Continuous integration, Publishing pipeline]
summary: The professional Roblox toolchain (Rokit, Rojo, Wally, Selene, StyLua, luau-lsp, Lune, Open Cloud), when to use Script Sync instead, and a CI pipeline that checks every change and uploads saved builds safely.
audience: [human, agent]
---

# Tooling and CI

Working only inside Studio is fine for small projects, but teams and AI agents need code in files, version control, automatic checks and repeatable builds. This is the toolchain used by the template in this repository.

## Two ways to get code on disk

| Approach | What it syncs | Best for |
|---|---|---|
| **Script Sync** (built into Studio) | Scripts and folders only, two-way between Studio and disk | Existing Studio-first projects that want an external editor and git for code |
| **Rojo** (community tool) | Code and, optionally, models and assets described by project files; the file system is the source of truth | New projects, teams, CI, AI agents editing files |

Script Sync facts: right-click a folder in Studio and choose "Sync to...". Naming on disk maps to instance types (`name.luau` module, `name.server.luau` server script, `name.client.luau` client script, `name.local.luau` LocalScript, folders and `init` files for scripts with children). It supports large codebases and Team Create. It syncs only scripts and folders, so do not sync folders that mix scripts with other instances, and avoid syncing scripts that carry attributes or tags.

House rule for this repository: **Rojo is the source of truth for code.** Agents edit files, never scripts inside Studio, because Studio edits get overwritten by the next sync.

## The toolchain

| Tool | Job |
|---|---|
| **Rokit** | Installs and pins the versions of all the tools below per project (successor to Aftman/Foreman) |
| **Rojo** | Builds place files from the file tree; live-syncs into Studio with its plugin |
| **Wally** | Package manager for Luau libraries (for example a data library, signals, UI libraries) |
| **Selene** | Linter: catches mistakes and bad patterns, with a Roblox standard library definition |
| **StyLua** | Formatter: one consistent code style, no debates |
| **luau-lsp** | Language server for editors: autocomplete, type checking, go-to-definition (with a companion Studio plugin for live data model info) |
| **Lune** | Standalone Luau runtime: scripts for builds, data processing, unit tests of pure modules, Open Cloud calls |

## Repository layout

```text
rokit.toml            pinned tool versions
default.project.json  Rojo project (maps src/ to the data model)
wally.toml            dependencies
selene.toml           lint config (std = "roblox")
stylua.toml           format config
src/                  game code (see Project architecture)
tests/                unit tests for pure modules
scripts/              Lune scripts (build, upload, data tools)
.github/workflows/    CI
```

## Local workflow

1. `rokit install` once.
2. `wally install` to fetch packages.
3. `rojo serve` and connect the Studio plugin for live sync while working.
4. Edit in an editor with luau-lsp, Selene and StyLua extensions.
5. Before committing: `stylua --check src`, `selene src`, `rojo build -o build.rbxl`, run unit tests.

## CI pipeline (on every push and pull request)

1. Install tools with Rokit (cache them).
2. `stylua --check` (format).
3. `selene` (lint).
4. Type check with luau-lsp's analyze mode (with Roblox type definitions and the Rojo sourcemap).
5. `rojo build` (the place must build).
6. Run unit tests of pure modules (with Lune, or in Studio on a runner that has Studio).
7. On the main branch: upload a **saved** (not published) place version with Open Cloud, so a human can review it in Studio and publish.

## Publishing with Open Cloud

Roblox's Open Cloud place publishing API accepts a place file and creates a new version:

```
POST https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions?versionType=Saved
x-api-key: <key with place publishing permission for that universe>
Content-Type: application/octet-stream   (for .rbxl)
```

- `versionType=Saved` stores a version without making it live. `Published` makes it live to players.
- House rule: automation (CI or agents) only uses **Saved**. A human publishes.
- Keep API keys in CI secrets with the narrowest scope (one universe, place publishing only) and IP restrictions where possible. Never commit keys.
- Use separate places (a test universe) for staging builds when possible.

## Packages, assets and models

- Code lives in files; large models and maps usually live in the place file (edited in Studio) or in `.rbxm` files referenced by the Rojo project.
- For mixed projects, a common setup is "partially managed": Rojo manages code folders, while the world is edited in Studio and saved in the place. Make sure everyone knows which parts are file-managed.

## For agents

- [ ] Tools pinned in `rokit.toml`; CI uses the same versions.
- [ ] Every change passes format, lint, type check, build and unit tests before review.
- [ ] Automation uploads only Saved versions; no automated Published versions.
- [ ] API keys only in secrets, scoped to the minimum.
- [ ] Code edited in files, never directly in Studio for Rojo-managed folders.

Related: [Project architecture](project-architecture.md) · [Testing and QA](testing-and-qa.md) · [Luau standards](luau-standards.md) · [Studio MCP playbook](../16-ai-studio-operations/studio-mcp-playbook.md)

Sources: [Script Sync](https://create.roblox.com/docs/scripting/sync), [Place publishing API guide](https://create.roblox.com/docs/cloud/guides/usage-place-publishing)
