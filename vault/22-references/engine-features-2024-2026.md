---
title: Engine and platform features 2024-2026
date: 2026-10-24
tags: [reference, engine, features, studio, platform, roadmap]
aliases: [New Roblox features, What is new in Roblox, Feature map]
summary: A map of the Roblox engine, Studio and platform features from 2024 to October 2026 that change how games are built - netcode, input, animation, audio, UI styling, AI and Studio automation, analytics and configs, monetization, discovery, social and safety tools - plus features announced at RDC 2026 and not yet released, each with the note that explains it.
audience: [human, agent]
---

# Engine and platform features 2024-2026

Roblox changes quickly, and much older tutorial code predates the current features. This map lists what exists now (per the official docs and newsroom read on 2026-10-24), what it replaces, and where the vault explains it. Use it to check whether a design or code review is using current tools.

## Netcode and simulation

| Feature | What it changes | Vault note |
|---|---|---|
| Server authority model (`AuthorityMode = Server`) | Server-owned simulation with client prediction, rollback and resimulation; prevents movement cheats; requires simulation callbacks and input actions | [Combat systems and hitboxes](../13-building-it-right/combat-systems-and-hitboxes.md) |
| Input Action System | Declarative input actions and contexts; required for server authority; works across keyboard, gamepad and touch | [Controls and input](../08-mobile-and-cross-platform/controls-and-input.md) |
| Instance stitching and position smoothing | Predicted creation of instances; smooth rendering of corrected objects | [Combat systems and hitboxes](../13-building-it-right/combat-systems-and-hitboxes.md) |
| Custom matchmaking | Signal weights and up to two custom signals for server selection | [Matchmaking and teleports](../13-building-it-right/matchmaking-and-teleports.md) |
| MemoryStore observability and documented partition limits | Dashboards, alerts and clear throttling rules | [MemoryStore and cross-server systems](../13-building-it-right/memorystore-and-cross-server.md) |

## Characters, animation and audio

| Feature | What it changes | Vault note |
|---|---|---|
| Animation Graph Editor with blend nodes and state machines | Visual animation logic with parameters, replacing hand-written blending for locomotion | [Animation systems](../13-building-it-right/animation-systems.md) |
| Adaptive Animation (`HumanoidRigDescription`) | Custom rigs play standard R15 animations and emotes | [Animation systems](../13-building-it-right/animation-systems.md) |
| `IKControl` | Runtime inverse kinematics for feet, hands and looking | [Animation systems](../13-building-it-right/animation-systems.md) |
| Modular audio API (players, emitters, listeners, wires, effects) | Replaces `Sound`, `SoundGroup` and `SoundEffect` (now discouraged); real mixing and routing | [Audio systems](../13-building-it-right/audio-systems.md) |
| Text-to-speech and speech-to-text audio objects | Voices and transcription inside the audio graph | [Audio systems](../13-building-it-right/audio-systems.md) |
| Layered accessories, dynamic heads, avatar generation | Avatar-centric games and fashion | [Fashion and dress-up playbook](../14-genre-playbooks/fashion-and-dress-up.md) |

## Rendering and UI

| Feature | What it changes | Vault note |
|---|---|---|
| `Lighting.LightingStyle` and `PrioritizeLightingQuality` | Artistic lighting intent and quality scaling | [Lighting and screen effects for VFX](../19-vfx/lighting-and-screen-effects.md) |
| `ColorGradingEffect` with tonemapper presets | Whole-game colour looks | [Lighting and screen effects for VFX](../19-vfx/lighting-and-screen-effects.md) |
| UI styling (style sheets with CSS-like rules) | Shared styles for UI instead of per-element properties | [UI implementation](../05-ui-and-hud/ui-implementation.md) |
| Flex layouts, 9-slice, rich text, drag detectors, video frames | Responsive, interactive UI without custom code | [UI implementation](../05-ui-and-hud/ui-implementation.md) |

## AI and Studio automation

| Feature | What it changes | Vault note |
|---|---|---|
| Built-in Studio MCP server | External AI clients can read and edit scripts, run Luau, playtest, capture screens and generate assets | [Studio MCP playbook](../16-ai-studio-operations/studio-mcp-playbook.md) |
| Studio CLI | Command-line automation of Studio | [Tooling and CI](../13-building-it-right/tooling-and-ci.md) |
| Assistant Planning Mode and playtesting agent (beta) | Plan-then-build workflows inside Studio | [AI tooling landscape](ai-tooling-landscape.md) |
| Mesh generation, material generation, procedural models | Draft assets from prompts and reference images | [AI asset generation](../16-ai-studio-operations/ai-asset-generation.md) |
| Build (Roblox app) | Prompt-to-game creation on mobile (alpha regions) | [AI tooling landscape](ai-tooling-landscape.md) |
| Scene Analysis | Treemaps of memory, instances and triangles during play | [Parallel Luau and profiling](../13-building-it-right/parallel-luau-and-profiling.md) |

## Live ops, analytics and monetization

| Feature | What it changes | Vault note |
|---|---|---|
| Configs and Experiments in Creator Hub | Live tuning and A/B tests without republishing | [Experiments and configs](../12-live-ops-and-launch/experiments-and-configs.md) |
| Analytics: custom events, funnels, economy events, crashes, error reports, alerts, feedback | Measure everything the gates ask for | [Analytics instrumentation](../13-building-it-right/analytics-instrumentation.md) |
| Managed pricing (regional pricing plus price optimization) | Automatic localized and tested prices; price-level checks for trades | [Anime monetization](../20-anime-games/anime-monetization.md) |
| Subscriptions, Roblox Plus incentives, Creator Rewards | New recurring and engagement-based income | [Platform payouts](../09-monetization/platform-payouts.md) |
| Rewarded video ads and Ads Manager objectives | Player-chosen ads; paid acquisition | [Ads and rewarded video](../09-monetization/ads-and-rewarded-video.md) |
| License Manager and Licenses catalog | Legal use of brands and franchises; offers to look-alike games | [Anime IP and legal](../20-anime-games/anime-ip-and-legal.md) |
| U.S. 18+ DevEx rate | Higher payout for eligible older-audience purchases | [Studio business models](../21-hits-and-trends/studio-business-models.md) |

## Discovery, social and safety

| Feature | What it changes | Vault note |
|---|---|---|
| Roblox Kids and Select | Age-based audiences; evaluation before under-16 reach | [Age ratings and audience](../17-policy-and-business/age-ratings-and-audience.md) |
| Experience events, update announcements and experience notifications | Scheduled events, Notify Me, opt-in notifications | [Anime community, updates and codes](../20-anime-games/anime-community-updates-and-codes.md) |
| Friend referral system, invite prompts with launch data, share links | Trackable growth loops | [Viral and social mechanics](../21-hits-and-trends/viral-and-social-mechanics.md) |
| Moments tab | Gameplay videos that link to play | [Platform shifts 2025-2026](../21-hits-and-trends/platform-shifts-2025-2026.md) |
| Social media link rules (16+ verified, game page only) | Community funnels outside the game | [Viral and social mechanics](../21-hits-and-trends/viral-and-social-mechanics.md) |

## Announced at RDC 2026, not yet generally available (as of 2026-10-24)

| Feature | Timing (as announced) |
|---|---|
| Web play in Chrome from a game's detail page | By the end of 2026 |
| Offline solo play alongside multiplayer | Early access soon; available by mid-2027 |
| Standalone apps ("Roblox Everywhere") | Announced; no date given |
| Orthographic camera, animated image containers, sprite-sheet import; UI blur, text shadows, gradients | Announced for 2D and puzzle games |
| Turn notifications for asynchronous games | Studio beta October 2026; full release by end of 2026 |
| Quick Words (pre-reviewed chat phrases) | Later in 2026 |
| Scene Generator (prompt and reference image to layout) | Later in 2026 |
| Roblox Wallet and Roblox Card | Wallet later in 2026 for eligible U.S. creators; Card in 2027 |

Check the official pages before designing around any of these; announced features can change.

## Replaced or discouraged

| Older approach | Use instead |
|---|---|
| `wait`, `spawn`, `delay` | `task.wait`, `task.spawn`, `task.defer`, `task.delay` |
| `Sound`, `SoundGroup`, `SoundEffect` | Modular audio objects |
| Client `TeleportService:Teleport` | Server `TeleportAsync` |
| `BadgeService:AwardBadge`, `UserHasBadge` | `AwardBadgeAsync`, `UserHasBadgeAsync` |
| `Touched` for combat hits | Spatial queries at animation markers |
| Hard-coded prices | Prices read from `MarketplaceService` (managed pricing) |
| Legacy chat | `TextChatService` |

## For agents

- [ ] Designs and code reviews use the current feature for each need (check the "Replaced" table).
- [ ] Announced features are not relied on until released; note the date checked.

Sources: [Server authority model](https://create.roblox.com/docs/projects/server-authority) · [Input Action System](https://create.roblox.com/docs/input/input-action-system) · [Animation Graph Editor](https://create.roblox.com/docs/animation/graph-editor) · [Adaptive Animation](https://create.roblox.com/docs/characters/adaptive-animation) · [Audio objects](https://create.roblox.com/docs/audio/objects) · [UI styling](https://create.roblox.com/docs/ui/styling) · [Studio MCP](https://create.roblox.com/docs/studio/mcp) · [Matchmaking](https://create.roblox.com/docs/matchmaking) · [Managed pricing](https://create.roblox.com/docs/production/monetization/managed-pricing) · [IP licensing](https://create.roblox.com/docs/ip-licensing) · [Analytics](https://create.roblox.com/docs/production/analytics) · Roblox newsroom: [RDC 2026](https://about.roblox.com/newsroom/2026/09/rdc-2026-the-world-needs-more-play), [Roblox Studio is going agentic](https://about.roblox.com/newsroom/2026/04/roblox-studio-going-agentic)

Related: [The Roblox platform in 2026](../00-start-here/roblox-platform-2026.md) · [Platform shifts 2025-2026](../21-hits-and-trends/platform-shifts-2025-2026.md) · [API cookbook](api-cookbook.md) · [Engine limits reference](engine-limits-reference.md) · [Common Luau mistakes](../13-building-it-right/common-luau-mistakes.md)
