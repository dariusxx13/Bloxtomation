---
title: Testing and QA
date: 2026-10-24
tags: [engineering, testing, qa, playtesting, automation]
aliases: [QA, Unit tests, Playtesting]
summary: How to test a Roblox game: pure-logic unit tests, Studio multi-client playtests, gated QA tools, automated smoke tests with the Studio CLI and MCP, device checks, and a release QA checklist.
audience: [human, agent]
---

# Testing and QA

Roblox games break in ways that are hard to see in a solo playtest: on phones, with several players, after rejoining, when data fails, when a server shuts down, when an exploiter fires remotes. Testing has to cover those situations, and much of it can be automated.

## Test layers

| Layer | What it checks | Tools |
|---|---|---|
| Static checks | Syntax, types, style, common mistakes | luau-lsp / type checker, Selene, StyLua, `rojo build` |
| Unit tests | Pure logic: economy math, drop tables, validators, formatting, migrations | Jest-Lua or TestEZ in Studio; Lune for running pure modules outside Roblox |
| Integration in Studio | Systems working together on a real server and clients | Studio playtest (Play, Run, multi-client "Clients and Servers"), Studio MCP automation |
| Device and layout | UI on phones, tablets, consoles | Device Simulator, real low-end phone |
| Live QA | Real-state bugs in the published game | Gated QA commands, private test servers, logs |
| Monitoring | Errors and crashes after release | Error report, performance dashboards, alerts |

## Design for testability

- Put game rules in **pure modules** (functions that take values and return values, without touching instances or services). Economy formulas, drop table picks, validators, quest progress, damage math. These can be unit-tested anywhere.
- Inject randomness: pass a `Random` object so tests can seed it.
- Keep Roblox service calls at the edges (data module, analytics wrapper, marketplace wrapper) so they can be replaced by fakes in tests.

## What to unit test first

1. Data migrations (every version step, plus a full migration from version 1).
2. Receipt handling logic (idempotency: the same receipt twice grants once).
3. Remote validators (garbage input: `nil`, `NaN`, huge numbers, wrong types, wrong table shapes).
4. Drop tables (weights sum, one-million-roll distribution within tolerance, luck and pity behavior).
5. Economy math (costs, time-to-goal targets as regression tests).
6. Currency transactions (cannot go negative, sinks and sources logged).

## Studio playtests

- **Multi-client tests**: Studio can start a local server with several clients. Test trading, steal mechanics, co-op, leaderboards, server events and replication with at least two clients.
- **Network simulation**: test with added latency to catch timing assumptions.
- **Rejoin tests**: leave and rejoin quickly (session locking), rejoin to a different server, play after a failed load (simulate failures in a test mode).
- **Shutdown test**: stop the server with players in it and confirm `BindToClose` saves.

## Gated QA tools

Live bugs often depend on state that takes hours to reach (rebirth 25, a rare item, an event day). Build QA commands that set state directly:

- Give currency, set rebirths, grant items, set the day, start events, skip timers.
- **Gated**: only allowlisted user ids (or Studio) can use them, checked on the server. They never ship reachable to regular players.
- Note: requiring a ModuleScript from Studio's command bar creates a separate copy of the module; it does not change the running game's state. Use the gated QA remotes or the Studio MCP's server-context Luau execution instead.

## Automated testing with Studio tools

- **Studio CLI**: `RobloxStudioBeta.exe --task RunScript --runScriptFile smokeTest.luau --outputFile out.log --quitAfterExecution` runs a Luau script in a place after it loads (with command-bar permissions) and can write output to a file. Useful for smoke tests and data checks in CI on a Windows or macOS runner.
- **Studio MCP server**: an AI agent (or script) can start and stop playtests, run Luau in edit, client or server contexts, read the console, capture screenshots and simulate keyboard, mouse and character navigation. This enables automated golden-path playtests: spawn, perform the first action, check currency increased, open the shop, buy the first upgrade, verify. See [Studio MCP playbook](../16-ai-studio-operations/studio-mcp-playbook.md).

## The golden-path test

Every game should have a scripted check of the new-player path:

1. Join as a new player (fresh data).
2. Perform the first action; verify the reward.
3. Buy the first upgrade; verify the effect.
4. Reach the first zone gate condition (with QA tools if needed) and pass it.
5. Rejoin; verify the data persisted.

Run it before every publish.

## Release QA checklist

- [ ] Static checks pass (build, lint, format, types).
- [ ] Unit tests pass (migrations, receipts, validators, drop tables, economy).
- [ ] Golden-path test passes.
- [ ] Multi-client test of social systems.
- [ ] Rejoin, failed-load and shutdown tests pass.
- [ ] Device Simulator review at phone, tablet and desktop; one real low-end phone session.
- [ ] Purchases tested (a real cheap purchase on a test account, including rejoin during purchase).
- [ ] QA tools confirmed unreachable for regular players.
- [ ] Error report checked for the new version within an hour of release.

## For agents

- [ ] New logic placed in pure modules with unit tests.
- [ ] Every bug fix adds a test that would have caught it, when testable.
- [ ] Playtest evidence attached to reports: steps, console output, screenshots.
- [ ] Never declare a feature done without the golden path still passing.

Related: [Tooling and CI](tooling-and-ci.md) · [Studio MCP playbook](../16-ai-studio-operations/studio-mcp-playbook.md) · [Data persistence](data-persistence.md) · [Security and anti-exploit](security-and-anti-exploit.md)
