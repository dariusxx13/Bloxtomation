---
title: Project architecture
date: 2026-10-24
tags: [engineering, architecture, rojo, luau, structure]
aliases: [Code structure, Folder layout, Systems and controllers]
summary: A code layout and startup pattern for Roblox games that stays clean as the game grows and works well for teams and AI agents.
audience: [human, agent]
---

# Project architecture

A Roblox game that survives months of weekly updates needs a structure where every piece of code has one obvious home, startup order is predictable, and the boundary between client and server is a typed API. This note is the house architecture used by the game template in this repository.

## Principles

1. **Modules everywhere, two entry points.** One server `Script` and one client `LocalScript` start everything. All other code is `ModuleScript`s. Dozens of loose scripts mean unknown execution order and duplicated logic.
2. **Server decides, client presents.** Server systems own state and rules; client controllers render state, play effects and send intents.
3. **One home per concern.** A feature is a server system + a client controller + shared types + remote definitions. Nothing else.
4. **Explicit dependencies.** `require` what you use. Never use `_G` or `shared` for communication.
5. **Data-driven content.** Items, eggs, zones, quests and prices live in config modules, not in code branches.

## Layout (Rojo)

```text
src/
  shared/                      -> ReplicatedStorage.Shared
    Types.luau                 shared type definitions
    Config/                    tunable data (items, eggs, zones, economy)
    Net/                       remote definitions and the Net wrapper
    Util/                      pure functions (formatting, math, tables)
  server/                      -> ServerScriptService.Server
    init.server.luau           THE server entry point
    Systems/                   one module per system (Data, Currency, Shop, Rewards, ...)
    Services/                  wrappers around Roblox services (Analytics, Policy, Config)
  client/                      -> StarterPlayer.StarterPlayerScripts.Client
    init.client.luau           THE client entry point
    Controllers/               one module per concern (HUD, Shop UI, Effects, Input)
    UI/                        UI components and templates
  serverStorage/               -> ServerStorage (server-only assets and modules)
assets/                        models and UI exported as .rbxm (optional)
```

Server-only logic and secrets never go in `ReplicatedStorage`: everything there is readable by clients.

## Two-phase startup

Each system or controller module may expose `init()` and `start()`:

1. The entry point requires every module in `Systems/` (or `Controllers/`).
2. It calls `init()` on all of them. `init` is synchronous: create remotes, read config, connect to other modules' signals.
3. Then it calls `start()` on all of them in separate threads. `start` runs loops and long tasks.

Because every module finished `init` before any `start`, no module can use another that is not ready. This removes a whole class of startup race bugs without a framework.

## Communication between modules

- **Direct calls** for queries and commands: `Currency.add(player, "Coins", 50, "Quest")`.
- **Signals** for events: `Currency.Changed:Connect(...)`, `Shop.Purchased:Connect(...)`. The emitting module does not know who listens.
- **No cycles**: if two modules need each other, extract the shared piece into a third module or pass a callback during `init`.
- Modules are cached by `require`, so a module is naturally a singleton.

## Client-server boundary

- All remotes are defined in one list in `shared/Net` and created by the server at startup. Clients wait for them once.
- Every remote has a declared payload type, a validator and a rate limit. See [Networking and remotes](networking-and-remotes.md).
- State replication: the server sends the player their own state (currencies, inventory, quests) as an initial snapshot plus small change messages. UI subscribes to the client copy.

## World objects

For objects with shared behavior (eggs, doors, chests, buy pads), do not put a script inside each model. Use one manager module that finds the objects (from a known folder or by `CollectionService` tags) and attaches behavior. Store per-object parameters in attributes (`egg:GetAttribute("EggId")`). With streaming enabled, client managers must handle objects streaming in and out (both the added and removed signals).

## Where does this code go?

| Code | Home |
|---|---|
| Changes or stores game state | `server/Systems/` |
| Renders state, effects, input | `client/Controllers/` and `client/UI/` |
| Pure logic used on both sides | `shared/Util/` (server result is authoritative) |
| Types crossing the boundary | `shared/Types.luau` |
| Tunable numbers and content tables | `shared/Config/` (client-readable) or `serverStorage` (secret) |
| Per-object parameters | Attributes on the instance |
| Assets the client needs | `ReplicatedStorage.Assets` |
| Assets spawned by the server only | `ServerStorage` |

## Growth rules

- A new feature should touch: one new server system, one new client controller, the shared types, the remote list, and config. If it needs edits in many unrelated files, fix the boundaries first.
- Build one complete exemplar system (for example the shop) and make every new system copy its shape.
- Delete replaced code; parallel old and new paths are where duplication bugs live.
- Libraries via Wally (for example a data library, a signal library, a UI library) are fine; pin versions.

## For agents

- [ ] New systems follow the layout: server system, client controller, shared types, remote entries, config.
- [ ] Only two entry scripts exist; everything else is a module with `init`/`start`.
- [ ] No `_G` or `shared` globals; no require cycles.
- [ ] No server-only logic or secrets in `ReplicatedStorage`.
- [ ] World behaviors use one manager per behavior with attributes for parameters.

Related: [Networking and remotes](networking-and-remotes.md) · [Data persistence](data-persistence.md) · [Tooling and CI](tooling-and-ci.md) · [Luau standards](luau-standards.md) · [UI implementation](../05-ui-and-hud/ui-implementation.md)
