---
title: Learning paths
date: 2026-10-24
tags: [reference, learning, onboarding, roles, curriculum]
aliases: [How to learn Roblox development, Study plans, Curriculum by role]
summary: Ordered reading and practice plans through this vault and the official docs for each role - first-time creator, gameplay programmer, systems and backend engineer, game designer, economy designer, builder and world artist, VFX artist, UI designer, live-ops and analytics, and the person running the AI agent studio - each with weekly practice projects and a finish line.
audience: [human, agent]
---

# Learning paths

The vault is large on purpose. Nobody should read it front to back. Pick a path, follow the order, and do the practice project each week; reading without building does not stick. Every path starts with the same three notes: [How to use this vault](../00-start-here/how-to-use-this-vault.md), [The Roblox platform in 2026](../00-start-here/roblox-platform-2026.md) and [The hit formula](../00-start-here/hit-formula.md).

## 1. First-time creator (4 weeks)

| Week | Read | Build |
|---|---|---|
| 1 | [First session blueprint](../01-first-five-minutes/first-session-blueprint.md), [Core loop design](../02-core-loop/core-loop-design.md), [Discoverability defaults](../01-first-five-minutes/discoverability-defaults.md) | Install the template and run its quality gate (`bash template/scripts/check.sh`); play it in Studio |
| 2 | [Game feel and juice](../02-core-loop/game-feel-and-juice.md), [Common Luau mistakes](../13-building-it-right/common-luau-mistakes.md) | Change the core action and add one juice layer |
| 3 | [Simulator and incremental playbook](../14-genre-playbooks/simulator-incremental.md), [Economy design](../04-progression-and-economy/economy-design.md) | Add a new zone with a cost and a reward |
| 4 | [Launch playbook](../12-live-ops-and-launch/launch-playbook.md), [Thumbnails](../11-store-page-and-discovery/thumbnails.md) | Playtest with two friends; fix the first thing they get stuck on |

**Finish line:** a small game a stranger can play for ten minutes without help.

## 2. Gameplay programmer (6 weeks)

| Week | Read | Build |
|---|---|---|
| 1 | [Project architecture](../13-building-it-right/project-architecture.md), [Luau standards](../13-building-it-right/luau-standards.md), [API cookbook](api-cookbook.md) | A new system in the template with `init` and `start` |
| 2 | [Networking and remotes](../13-building-it-right/networking-and-remotes.md), [Security and anti-exploit](../13-building-it-right/security-and-anti-exploit.md) | A validated, rate-limited remote; an exploit test that fails safely |
| 3 | [Data persistence](../13-building-it-right/data-persistence.md) | Add a field with a schema migration |
| 4 | [Combat systems and hitboxes](../13-building-it-right/combat-systems-and-hitboxes.md), [Animation systems](../13-building-it-right/animation-systems.md) | A melee attack with a marker-timed server hit |
| 5 | [NPC AI and pathfinding](../13-building-it-right/npc-ai-and-pathfinding.md), [Physics and network ownership](../13-building-it-right/physics-and-network-ownership.md) | An enemy with a state machine and server ownership |
| 6 | [Testing and QA](../13-building-it-right/testing-and-qa.md), [Parallel Luau and profiling](../13-building-it-right/parallel-luau-and-profiling.md) | Unit tests plus a MicroProfiler before-and-after |

**Finish line:** code that passes the quality gate, survives an exploit test and holds 30 fps on a low-end phone.

## 3. Systems and backend engineer (4 weeks)

| Week | Read | Build |
|---|---|---|
| 1 | [Data persistence](../13-building-it-right/data-persistence.md), [Engine limits reference](engine-limits-reference.md) | A request budget for 5,000 concurrent players |
| 2 | [MemoryStore and cross-server systems](../13-building-it-right/memorystore-and-cross-server.md) | A sharded global leaderboard |
| 3 | [Matchmaking and teleports](../13-building-it-right/matchmaking-and-teleports.md) | A lobby that reserves a match server for a party |
| 4 | [Inventory and trading systems](../13-building-it-right/inventory-and-trading-systems.md), [Analytics instrumentation](../13-building-it-right/analytics-instrumentation.md) | A trade state machine with logs and a kill switch |

## 4. Game designer (5 weeks)

| Week | Read | Practice |
|---|---|---|
| 1 | [Core loop design](../02-core-loop/core-loop-design.md), [Session structure](../02-core-loop/session-structure.md), [Anatomy of a Roblox hit](../21-hits-and-trends/anatomy-of-a-hit.md) | Score three chart games with the hit sheet |
| 2 | [First five minutes](../01-first-five-minutes/INDEX.md) | Write a first-session timeline for an idea |
| 3 | [Retention systems](../10-retention-and-social/retention-systems.md), [Social systems](../10-retention-and-social/social-systems.md), [Viral and social mechanics](../21-hits-and-trends/viral-and-social-mechanics.md) | Design D1, D7 and D28 reasons to return |
| 4 | A genre playbook from [Genre playbooks](../14-genre-playbooks/INDEX.md), [Reference games by genre](reference-games-by-genre.md) | A teardown of two reference games |
| 5 | [GDD template](../18-templates-and-checklists/gdd-template.md), [Pitch and greenlight](../15-market-research/pitch-and-greenlight.md) | A pitch that passes PITCH-01 to PITCH-08 |

## 5. Economy and monetization designer (4 weeks)

| Week | Read | Practice |
|---|---|---|
| 1 | [Economy design](../04-progression-and-economy/economy-design.md), [Economy math](../04-progression-and-economy/economy-math.md) | An economy sheet with three player types |
| 2 | [Rarity tiers and odds](../03-rarity-and-rng/rarity-tiers-and-odds.md), [RNG systems and pity](../03-rarity-and-rng/rng-systems-and-pity.md), [Anime units, gacha and traits](../20-anime-games/anime-units-gacha-and-traits.md) | A drop table with pity and expected-cost math |
| 3 | [Monetization strategy](../09-monetization/monetization-strategy.md), [Pricing and price ladders](../09-monetization/pricing-and-price-ladders.md) | A catalog that passes the fairness table |
| 4 | [Monetization compliance](../09-monetization/monetization-compliance.md), [Trading economies](../04-progression-and-economy/trading-economies.md) | A compliance draft for a human to review |

## 6. Builder and world artist (4 weeks)

| Week | Read | Build |
|---|---|---|
| 1 | [Art direction](../06-world-and-look/art-direction.md), [Reference image workflow](../16-ai-studio-operations/reference-image-workflow.md) | A one-page art direction with references |
| 2 | [World and level design](../06-world-and-look/world-and-level-design.md), [Lobby and hub design](../06-world-and-look/lobby-and-hub-design.md) | A greybox hub with a landmark |
| 3 | [Lighting and atmosphere](../06-world-and-look/lighting-and-atmosphere.md), [Environment and ambient VFX](../19-vfx/environment-and-ambient-vfx.md) | Lighting and ambience for two zones |
| 4 | [Build budgets](../06-world-and-look/build-budgets.md), [Asset pipeline](../07-characters-vfx-and-assets/asset-pipeline.md) | A budget check on a phone; the asset index |

## 7. VFX artist (8 weeks)

Follow the eight-week plan in [Learning and hiring for VFX](../19-vfx/learning-and-hiring-vfx.md), starting from the [VFX toolkit reference](../19-vfx/vfx-toolkit-reference.md).

## 8. UI designer (3 weeks)

| Week | Read | Build |
|---|---|---|
| 1 | [UI principles](../05-ui-and-hud/ui-principles.md), [HUD layout](../05-ui-and-hud/hud-layout.md) | A phone-first HUD mock |
| 2 | [Menus, shops and inventories](../05-ui-and-hud/menus-shops-inventories.md), [Shop UX and contextual offers](../09-monetization/shop-ux-and-contextual-offers.md) | A shop with a "Details" odds panel |
| 3 | [UI implementation](../05-ui-and-hud/ui-implementation.md), [Feedback, popups and toasts](../05-ui-and-hud/feedback-popups-and-toasts.md) | Implement and test at three device sizes |

## 9. Live ops and analytics (3 weeks)

| Week | Read | Practice |
|---|---|---|
| 1 | [Update cadence](../12-live-ops-and-launch/update-cadence.md), [Live events and admin events](../21-hits-and-trends/live-events-and-admin-events.md) | A 12-week calendar with a weekly heartbeat |
| 2 | [Analytics instrumentation](../13-building-it-right/analytics-instrumentation.md), [Measuring onboarding](../01-first-five-minutes/measuring-onboarding.md) | A funnel and a dashboard plan |
| 3 | [Experiments and configs](../12-live-ops-and-launch/experiments-and-configs.md), [Why games die](../21-hits-and-trends/why-games-die.md) | One A/B test with a pre-registered hypothesis |

## 10. Running the AI agent studio (2 weeks)

| Week | Read | Practice |
|---|---|---|
| 1 | [For AI agents](../00-start-here/for-ai-agents.md), [Agent team workflow](../16-ai-studio-operations/agent-team-workflow.md), [Quality gates](../16-ai-studio-operations/quality-gates.md) | Run `python3 agents/studioctl.py board` and walk one task through the protocol |
| 2 | [Build briefs](../16-ai-studio-operations/build-briefs.md), [Studio MCP playbook](../16-ai-studio-operations/studio-mcp-playbook.md), [AI tooling landscape](ai-tooling-landscape.md) | Write a brief that passes `studioctl.py validate brief` |

## Official learning resources

Roblox's documentation includes tutorials, use-case guides and sample places (for example the server authority examples for racing, soccer and laser tag, and the animation graph reference places). Use them alongside these paths; when they disagree with older community tutorials, trust the official docs and the date.

## For agents

- [ ] When onboarding a human collaborator, suggest one path and the first week only.
- [ ] Practice projects produce evidence (check records, screenshots) like any task.

Related: [How to use this vault](../00-start-here/how-to-use-this-vault.md) · [FAQ for new developers](faq-for-new-developers.md) · [Learning and hiring for VFX](../19-vfx/learning-and-hiring-vfx.md) · [Agent team workflow](../16-ai-studio-operations/agent-team-workflow.md) · [Templates and checklists](../18-templates-and-checklists/INDEX.md)
