---
title: Studio MCP playbook
date: 2026-10-24
tags: [ai, agents, studio, mcp, automation, testing]
aliases: [Roblox Studio MCP, Studio automation, MCP tools]
summary: How AI agents use Roblox Studio's built-in MCP server: setup with Claude Code, the tools, safe patterns for editing, playtesting, capturing and asset work, and multi-instance rules.
audience: [human, agent]
---

# Studio MCP playbook

Roblox Studio includes a built-in MCP (Model Context Protocol) server. With it, an AI client such as Claude Code can read and edit scripts, inspect the game tree, run Luau, start and stop playtests, read the output, capture the viewport, simulate player input and generate or insert assets. This note explains how agents use it safely and effectively.

## Setup (platform facts, 2026)

1. Install the latest Roblox Studio.
2. In Studio, open **Assistant**, then **... > Manage MCP Servers**, and turn on **Enable Studio as MCP server**.
3. Connect the client. Claude Code is supported by Studio's quick connect. Manual configuration (stdio transport):
   - Windows: command `cmd.exe` with args `/c %LOCALAPPDATA%\Roblox\mcp.bat`
   - macOS: command `/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP`
4. Verify in Studio: a green indicator shows connected clients.

Only connect clients you trust: MCP clients can read and modify your open places.

## The tools

| Group | Tools | Use |
|---|---|---|
| Scripts | `script_read`, `multi_edit`, `script_search`, `script_grep` | Read and edit scripts in the data model (use only for places not managed by Rojo) |
| Assets and generation | `generate_mesh`, `generate_material`, `generate_procedural_model`, `wait_job_finished`, `search_asset`, `insert_asset`, `upload_image`, `store_image` | Create drafts, find and insert assets |
| Exploration | `search_game_tree`, `inspect_instance`, `subagent` (explore, playtest) | Understand the place |
| Luau execution | `execute_luau` (Edit, Client or Server data model) | Inspect state, set up test conditions, run checks |
| Playtesting | `get_studio_state`, `start_stop_play`, `get_console_output`, `screen_capture` | Run the game, read errors, take screenshots |
| Input simulation | `character_navigation`, `user_keyboard_input`, `user_mouse_input` | Act like a player |
| Docs and skills | `http_get` (allowed Roblox docs), `skill` | Look up APIs and Roblox guidance |
| Sessions | `list_roblox_studios` | Find Studio instances and their ids |

Every call takes a `studio_id`. Call `list_roblox_studios` first and target the instance you hold.

## Rules for agents

1. **Rojo-managed code is edited on disk**, not with `multi_edit`. Studio edits to synced scripts get overwritten. Use script tools only for non-synced places or quick experiments that you then port to files.
2. **Hold a Studio lease** before using an instance; one agent per instance at a time.
3. **Never publish** from Studio. Saving to a file or uploading a Saved version (through the pipeline) is allowed; publishing is a human action.
4. **Be careful with `execute_luau` in Edit mode**: it changes the place. Prefer running checks in Server or Client mode during a playtest, and never delete or restructure the world without an explicit task.
5. **Inserted assets are untrusted**: scan inserted models for scripts (see [Asset pipeline](../07-characters-vfx-and-assets/asset-pipeline.md)) and record them in the asset index.
6. **Stop playtests when done** and leave Studio in a clean state.

## Pattern: golden-path playtest

1. `get_studio_state`; if playing, stop.
2. `start_stop_play` to start a playtest.
3. `execute_luau` (Server): reset the test player's data to a new-player state through the game's QA hooks.
4. `character_navigation` to the first resource; `user_mouse_input` or `user_keyboard_input` to perform the core action.
5. `execute_luau` (Server): read the player's currency; assert it increased.
6. Open the shop through input simulation; buy the first upgrade; assert the effect.
7. `get_console_output`: assert no errors or warnings from game code.
8. `screen_capture` at key moments (first reward, shop open) for the report.
9. `start_stop_play` to stop.

Report: steps, assertions passed or failed, console excerpt, screenshots.

## Pattern: device and UI check

1. Start a playtest.
2. Use Studio's device emulation (the Device Simulator) at phone, tablet and desktop sizes; capture each with `screen_capture`.
3. Check: nothing overlaps the top bar, thumbstick or jump button; text readable; buttons large.
4. Attach the captures to the UI review.

## Pattern: newcomer playtest

The Newcomer agent plays without reading the design docs:

1. Fresh data, start a playtest.
2. Act only on what is visible on screen. Record each moment of uncertainty ("I don't know what to do", "I can't find the shop").
3. Capture the screen at each confusion point.
4. Report confusion points with timestamps and screenshots to the Designer and Interface Designer.

## Pattern: asset drafting

1. Write a prompt from the style guide.
2. `generate_mesh` or `generate_procedural_model` (with a reference image via `store_image` if useful); `wait_job_finished`.
3. Capture a screenshot; compare with the style guide and existing assets.
4. Clean up, then move the asset into the project's asset folders and record it.

See [AI asset generation](ai-asset-generation.md).

## Headless checks without MCP

The Studio command line can run a Luau script in a place and quit (`--task RunScript --runScriptFile ... --outputFile ... --quitAfterExecution`). Useful in CI on a machine with Studio installed. See [Testing and QA](../13-building-it-right/testing-and-qa.md).

## For agents

- [ ] `list_roblox_studios` before any call; `studio_id` on every call.
- [ ] Studio lease acquired and released.
- [ ] No edits to Rojo-managed scripts inside Studio.
- [ ] No publishing; no destructive edit-mode Luau without an explicit task.
- [ ] Playtest reports include steps, assertions, console output and screenshots.

Related: [Agent team workflow](agent-team-workflow.md) · [Testing and QA](../13-building-it-right/testing-and-qa.md) · [AI asset generation](ai-asset-generation.md) · [Tooling and CI](../13-building-it-right/tooling-and-ci.md)

Sources: [Studio MCP server](https://create.roblox.com/docs/studio/mcp), [Studio command line](https://create.roblox.com/docs/studio/cli)
