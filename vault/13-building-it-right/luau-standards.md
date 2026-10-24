---
title: Luau standards
date: 2026-10-24
tags: [engineering, luau, code-style, typing]
aliases: [Code style, Luau style guide, Strict mode]
summary: The coding standards for Luau in this studio: strict typing, naming, module shape, error handling, and the patterns reviewers check.
audience: [human, agent]
---

# Luau standards

Consistent code is faster to read, review and change, for humans and agents alike. These are the house standards used by the template and checked in review.

## Typing

- Start every file with `--!strict`. Fix type errors instead of downgrading to `--!nonstrict`.
- Shared types for anything crossing the client-server boundary or saved to DataStores live in `shared/Types.luau` and are exported (`export type PlayerData = {...}`).
- Annotate function parameters and return types of public module functions.
- Narrow optional values before use: results of `FindFirstChild`, `GetAttribute`, `Players:GetPlayerFromCharacter` can be `nil`.
- Remote handler parameters are typed `unknown` and narrowed by validators. Never trust a type annotation for data from the client.
- Avoid `any` except at true boundaries (JSON decode, library interop); narrow it immediately.

## Naming

| Thing | Style | Example |
|---|---|---|
| Modules and classes | PascalCase | `CurrencySystem`, `ShopController` |
| Functions and variables | camelCase | `getBalance`, `playerData` |
| Constants | UPPER_SNAKE_CASE | `MAX_PETS_EQUIPPED` |
| Types | PascalCase | `PetEntry`, `EggConfig` |
| Remote names | PascalCase verbs | `RequestHatch`, `BuyUpgrade` |
| Config ids | lower_snake_case | `egg_volcano`, `pass_x2coins` |
| Private module members | leading underscore or local | `_cache` |

## Module shape

```lua
--!strict
-- CurrencySystem: owns all currency balances; the only module that changes them.
local Players = game:GetService("Players")

local Types = require(game.ReplicatedStorage.Shared.Types)

local CurrencySystem = {}

local balances: { [Player]: { [string]: number } } = {}

function CurrencySystem.init()
	-- wire dependencies, no yielding
end

function CurrencySystem.start()
	-- connections and loops
end

function CurrencySystem.get(player: Player, currency: string): number
	local playerBalances = balances[player]
	return if playerBalances then playerBalances[currency] or 0 else 0
end

return CurrencySystem
```

- One responsibility per module; a one-line comment at the top states it.
- Services at the top, then requires, then constants, then state, then functions.
- Return a single table.
- No side effects at require time beyond defining things; work happens in `init` and `start`.

## Error handling

- Wrap calls that can fail (DataStores, HTTP, MarketplaceService, MessagingService, PolicyService, AnalyticsService if needed, `Players:GetUserIdFromNameAsync`, teleports) in `pcall` and handle failure paths explicitly.
- Retries with backoff for important calls.
- Never let a remote handler error kill a shared thread; the Net wrapper runs handlers in protected calls.
- Use `warn` for recoverable problems and `error` for programmer mistakes; log enough context (player id, item id) for the error report.

## Patterns reviewers flag

| Flag | Fix |
|---|---|
| `wait()`, `spawn()`, `delay()` | `task.wait`, `task.spawn`, `task.delay` |
| Loops that never end without cleanup | Track and stop on player leave or destroy |
| `:Connect` without cleanup for temporary objects | Use a cleanup helper |
| Magic numbers in logic | Config constants |
| Deep nesting | Early returns |
| Copy-pasted logic | Extract a function or module |
| `FindFirstChild` result used without check | Narrow first |
| Client code deciding outcomes | Move to a server system |
| String concatenation for UI text with numbers | Localization formatting or a formatter util |
| `math.random` in gameplay | A seeded `Random` object owned by the system |

## Formatting and linting

- StyLua formats everything (tabs, consistent quotes, line width from `stylua.toml`). Never hand-format against it.
- Selene with the Roblox standard library; warnings are fixed, not ignored, unless a line has a justified inline allow comment.

## Comments and docs

- Explain *why*, not *what*. The code shows what.
- Every system module has a top comment with its responsibility and its public functions.
- Non-obvious formulas cite their design doc ("balance: see economy sheet, gate costs").

## For agents

- [ ] `--!strict` on every file; no unexplained `any`.
- [ ] Names follow the table; config ids stable.
- [ ] Modules follow the shape with `init`/`start` and a responsibility comment.
- [ ] Every fallible service call wrapped and handled.
- [ ] StyLua and Selene clean.

Related: [Project architecture](project-architecture.md) · [Tooling and CI](tooling-and-ci.md) · [Networking and remotes](networking-and-remotes.md) · [Testing and QA](testing-and-qa.md)
