---
name: studio-playtest
description: Playtest a game in Roblox Studio through the Studio MCP server with the QA Tester (golden path, acceptance checks, devices) or the Newcomer (first-time player confusion report). Use when the user wants a game tested or a first-session check.
argument-hint: "<game-id> [golden|newcomer|devices]"
disable-model-invocation: true
allowed-tools: Bash(python3 agents/studioctl.py *)
---

Arguments: $ARGUMENTS (game id, then the kind of test; default `golden`).

1. Make sure Roblox Studio is running with the MCP server enabled and the game's project synced (`rojo serve` in `games/<id>/project` plus the Rojo plugin). If the Studio MCP tools are not available in this session, tell the user how to connect them (see `agents/README.md`, "Connect Roblox Studio") and stop.
2. Queue a task with a brief:
   - `golden` or `devices`: owner `qa-tester`, acceptance criteria from the vault's golden-path and device patterns (`vault/16-ai-studio-operations/studio-mcp-playbook.md`).
   - `newcomer`: owner `newcomer`, 10 minutes of play from fresh data, report confusion points with timestamps (PROTO-03).
3. Start the matching agent and wait for its handoff.
4. Summarise for the user: what passed, what failed (with reproduction steps), timings measured, and the proposed fixes as tasks for the Director.
