# Bloxtomation

An AI-assisted studio kit for making Roblox games: a deep knowledge vault, a production-ready game template with tooling, an AI agent team that plans, builds and tests games, and a chart tracker that finds what is growing on Roblox.

| Part | Folder | Status |
|---|---|---|
| Knowledge vault (Obsidian) | [`vault/`](vault/README.md) | Done: 191 notes (about 200,000 words) across 24 sections |
| Game template and Roblox tools | [`template/`](template/README.md) | Done: full simulator game (19 server systems, 13 client controllers), strict types, 47 unit tests, CI |
| AI agent team, stage gates, orchestrator | [`agents/`](agents/README.md), [`.claude/agents/studio/`](.claude/agents/studio/) | Done: 15 role agents, `/studio` commands, `studioctl` task queue with gates, leases and human checkpoints, guard hook, 45 tests |
| Chart tracking | [`charts/`](charts/README.md) | Done: snapshots of every discovery sort, breakouts, risers, new entries, rank movers, genre phases, pitch evidence, scheduled collection to a data branch, 20 tests |

## The vault

Open `vault/` as a folder vault in Obsidian, or read it on GitHub. Start with [How to use this vault](vault/00-start-here/how-to-use-this-vault.md). AI agents start with [For AI agents](vault/00-start-here/for-ai-agents.md).

It covers: the 2026 Roblox platform (discovery signals, Creator Rewards, Roblox Plus, age tiers, DevEx rates), first-session design, core loops and game feel, rarity and odds math, economy math, UI, world and art, characters and VFX, mobile and cross-platform, monetization and compliance, retention and social, store page and discovery, launch and live ops, engineering standards, genre playbooks, market research, AI studio operations with Roblox Studio's MCP server, policy and business, templates and checklists, and a reference section with key numbers, APIs, glossary and sources. The October 2026 expansion added deep dives on VFX, anime games (sub-genres, gacha math, IP and the License Manager, original power systems), what goes popular (dated 2025-2026 case studies, trend waves, live and admin events, a chart snapshot, platform shifts), engineering (combat and the server authority model, NPC AI, physics ownership, profiling, animation, audio, MemoryStore, matchmaking, trading), twenty-two genre playbooks in total, and references (AI tooling landscape with a review of a community Studio bridge, engine limits, an API cookbook, learning paths).

Facts are dated 2026-10-24 and link to official Roblox documentation. Rules of thumb are labelled as such.

## The template

A complete Rojo project for a tap-to-earn simulator (zones, eggs and pets, upgrades, rebirths, daily and playtime rewards, codes, Robux shop, onboarding funnel, analytics, live configs) built to the vault's engineering and compliance rules. Run `bash template/scripts/install-tools.sh` and `bash template/scripts/check.sh` for the full quality gate (StyLua, Selene, strict luau-lsp, Lune tests, config gate, Rojo build). See [the template README](template/README.md).

## The agent team

Open the repository in Claude Code and type `/studio <your game idea>`. The Director (one of fifteen role agents) plans the stages, briefs and dispatches the fourteen specialists (Scout, Designer, Economist, Monetization Designer, Engineer, Interface Designer, Worldbuilder, Artist, Storefront, QA Tester, Newcomer, Security Reviewer, Gatekeeper, Analyst), reviews their evidence, runs the stage gates and brings you only the decisions that are yours: approving the pitch, the prototype verdict, spending, policy answers and publishing. Progress is on `workspace/BOARD.md`. With Roblox Studio's MCP server connected, the agents playtest, build and capture in Studio. See [the agents README](agents/README.md).

## Chart tracking

`python3 charts/charts.py snapshot` records every sort on the Roblox Charts page (about 900 games) with details; `report --days 7` turns the snapshots into breakouts, risers, new entries, breakout candidates, organic rank movers and genre trends; `evidence --genre ... --game ...` produces a dated, sourced block for a pitch. A scheduled GitHub Action can collect every 3 hours into the `chart-data` branch. See [the charts README](charts/README.md).

Automation in this repo never publishes a game: `template/scripts/upload-place.luau` uploads Saved versions only, and a person publishes.
