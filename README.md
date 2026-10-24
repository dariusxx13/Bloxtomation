# Bloxtomation

An AI-assisted studio kit for making Roblox games: a deep knowledge vault, a production-ready game template with tooling, an AI agent team that plans, builds and tests games, and a chart tracker that finds what is growing on Roblox.

| Part | Folder | Status |
|---|---|---|
| Knowledge vault (Obsidian) | [`vault/`](vault/README.md) | Done: 132 notes across 20 sections |
| Game template and Roblox tools | [`template/`](template/README.md) | Done: full simulator game (19 server systems, 13 client controllers), strict types, 47 unit tests, CI |
| AI agent team, stage gates, orchestrator | `agents/` | Planned |
| Chart tracking | `charts/` | Planned |

## The vault

Open `vault/` as a folder vault in Obsidian, or read it on GitHub. Start with [How to use this vault](vault/00-start-here/how-to-use-this-vault.md). AI agents start with [For AI agents](vault/00-start-here/for-ai-agents.md).

It covers: the 2026 Roblox platform (discovery signals, Creator Rewards, Roblox Plus, age tiers, DevEx rates), first-session design, core loops and game feel, rarity and odds math, economy math, UI, world and art, characters and VFX, mobile and cross-platform, monetization and compliance, retention and social, store page and discovery, launch and live ops, engineering standards, thirteen genre playbooks, market research, AI studio operations with Roblox Studio's MCP server, policy and business, templates and checklists, and a reference section with key numbers, APIs, glossary and sources.

Facts are dated 2026-10-24 and link to official Roblox documentation. Rules of thumb are labelled as such.

## The template

A complete Rojo project for a tap-to-earn simulator (zones, eggs and pets, upgrades, rebirths, daily and playtime rewards, codes, Robux shop, onboarding funnel, analytics, live configs) built to the vault's engineering and compliance rules. Run `bash template/scripts/install-tools.sh` and `bash template/scripts/check.sh` for the full quality gate (StyLua, Selene, strict luau-lsp, Lune tests, config gate, Rojo build). See [the template README](template/README.md).

Automation in this repo never publishes a game: `template/scripts/upload-place.luau` uploads Saved versions only, and a person publishes.
