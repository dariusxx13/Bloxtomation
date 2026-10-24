---
title: API quick reference
date: 2026-10-24
tags: [reference, api, engineering]
aliases: [Roblox API cheat sheet]
summary: The Roblox engine and web APIs this vault refers to, grouped by job, with one-line usage notes.
audience: [human, agent]
---

# API quick reference

Grouped by what you are trying to do. Check the official Engine API reference for signatures before use; APIs evolve.

## Players, data and persistence

| API | Use |
|---|---|
| `Players.PlayerAdded` / `PlayerRemoving` | Load and save player data |
| `game:BindToClose` | Save everyone on shutdown |
| `DataStoreService:GetDataStore`, `:UpdateAsync` | Atomic read-modify-write of player profiles |
| `DataStoreService:GetRequestBudgetForRequestType` | Check budgets before non-critical writes |
| `DataStoreService:GetOrderedDataStore` | Global leaderboards |
| `MemoryStoreService` | Temporary cross-server data (queues, sorted maps) |
| `MessagingService` | Cross-server messages (announcements, admin events) |
| `Player:GetJoinData()` | Launch data, referral (`ReferredByPlayerId`), event entry, ad campaign data |
| `Players:BanAsync` | Ban users across the game |

## Monetization

| API | Use |
|---|---|
| `MarketplaceService.ProcessReceipt` | Grant developer products (idempotent; save before `PurchaseGranted`) |
| `MarketplaceService:PromptProductPurchase` / `:PromptGamePassPurchase` | Start purchases |
| `MarketplaceService:UserOwnsGamePassAsync` | Check pass ownership (cache per session) |
| `MarketplaceService:GetProductInfoAsync` (with `Enum.InfoType.Product` / `GamePass`) | Runtime prices and discount details |
| `MarketplaceService:GetDeveloperProductsAsync` | List all developer products |
| `MarketplaceService:RecommendTopProductsAsync` / `:RankProductsAsync` | Personalized product picks |
| `MarketplaceService:GetUsersPriceLevelsAsync` | Compare regional price levels for trades and gifts |
| `MarketplaceService:PromptRobloxSubscriptionPurchase` (+ `PromptRobloxSubscriptionPurchaseFinished`) | Roblox Plus sign-ups |
| `Player.HasRobloxSubscription`, `MarketplaceService:GetRobloxSubscriptionDetailsAsync` | Plus status |
| `MarketplaceService:PromptRobuxTransferAsync`, `:BindReceiptHandler` | In-game Robux transfers |
| `MarketplaceService:PromptPremiumPurchase`, `Player.MembershipType` | Premium |
| `PolicyService:GetPolicyInfoForPlayerAsync` | `ArePaidRandomItemsRestricted`, `IsPaidItemTradingAllowed`, ads and other per-player rules |
| `AdService:GetAdAvailabilityNowAsync` | Rewarded video availability |

## Social and engagement

| API | Use |
|---|---|
| `SocialService:PromptGameInvite`, `:CanSendGameInviteAsync`, `ExperienceInviteOptions` | Invites with custom messages and launch data |
| `SocialService:GetPlayersByPartyId` | Keep parties together |
| `ExperienceNotificationService:PromptOptIn` | Ask for notification opt-in (13+) |
| `GroupService:PromptJoinAsync`, `Player:IsInGroupAsync` | Group join and membership rewards |
| `AvatarEditorService:PromptSetFavorite` | Favorite prompt |
| `TextChatService` | Chat and system messages |
| `TextService:FilterStringAsync` | Filter player-written text |
| `RecommendationService` | Personalized in-game recommendations |

## Analytics and live ops

| API | Use |
|---|---|
| `AnalyticsService:LogOnboardingFunnelStepEvent` | Onboarding funnel |
| `AnalyticsService:LogFunnelStepEvent` | Recurring funnels |
| `AnalyticsService:LogEconomyEvent` | Sources and sinks |
| `AnalyticsService:LogCustomEvent` | Custom metrics |
| `ConfigService:GetConfigAsync` / `:GetConfigForPlayerAsync` | Live configs, targeting, experiments |

## World, physics and performance

| API | Use |
|---|---|
| `Workspace.StreamingEnabled`, `StreamingMinRadius`, `StreamingTargetRadius`, model streaming modes | Instance streaming |
| `Player:RequestStreamAroundAsync` | Pre-stream before teleporting within a place |
| `Workspace:GetPartBoundsInBox` / `GetPartBoundsInRadius`, `Raycast`, shapecasts | Spatial queries for gameplay |
| `PhysicsService` collision groups | Skip unnecessary collisions |
| `CollectionService` | Tag-based managers |
| `PathfindingService` | NPC navigation |
| `RunService:BindToSimulation`, `:SetPredictionMode` | Server authority simulation |
| `TweenService` | Animation of properties and UI |
| `ContentProvider:PreloadAsync` | Preload essential assets |

## Input and UI

| API | Use |
|---|---|
| Input Action System (input actions, bindings, contexts) | Cross-device input |
| `ContextActionService:BindAction` | Bind actions to multiple inputs with touch buttons |
| `UserInputService` | Device detection, raw input, last input type |
| `ProximityPrompt` | Contextual interactions |
| `GuiService` | Gamepad selection, insets |
| `StyleSheet`, `StyleRule`, `StyleLink` | UI styling with tokens and themes |
| `UIListLayout` + `UIFlexItem`, `UIGridLayout`, constraints | Responsive layouts |
| `ScreenGui.ScreenInsets` | Safe areas |

## Web and tooling

| API / tool | Use |
|---|---|
| Open Cloud place publishing: `POST /universes/v1/{universeId}/places/{placeId}/versions?versionType=Saved` | Upload builds (automation uses Saved only) |
| Open Cloud DataStores | Support tools, backups, erasure |
| Studio MCP server tools | Agent automation of Studio (see [Studio MCP playbook](../16-ai-studio-operations/studio-mcp-playbook.md)) |
| Studio CLI `--task RunScript` | Headless script runs in a place |
| Public game data (unofficial): explore sorts, games, votes, thumbnails | Chart tracking (see [Reading the charts](../15-market-research/reading-the-charts.md)) |

Related: [Key numbers](key-numbers.md) · [Sources](sources.md) · [13 Building it right](../13-building-it-right/INDEX.md)
