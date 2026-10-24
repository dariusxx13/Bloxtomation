---
title: AI tooling landscape
date: 2026-10-24
tags: [ai, tools, mcp, studio, agents, security, references]
aliases: [AI tools for Roblox, Studio MCP alternatives, Community AI bridges, Roblox AI agents]
summary: The AI tools that build Roblox games in 2026 - Roblox's own Assistant, built-in Studio MCP server, Build and generation tools; community MCP servers, bridges, desktop agents and skill packs - how they compare, a security review of one community bridge (unauthenticated local server, open CORS, loadstring execution, permission prompts disabled, outdated example code), and the studio's rules for choosing and using AI tools.
audience: [human, agent]
---

# AI tooling landscape

AI-assisted Roblox development went mainstream in 2026. Roblox reported that **44% of the top 1,000 creators** used Roblox Assistant or third-party AI tools through MCP between March and April 2026 (Roblox newsroom, 2026-04-15). This note maps the tools, compares them, and records what the studio learned from reviewing a popular community bridge. How this studio's own agents use Studio is in [Studio MCP playbook](../16-ai-studio-operations/studio-mcp-playbook.md) and [Agent team workflow](../16-ai-studio-operations/agent-team-workflow.md).

## Official Roblox tools (Fact, Roblox docs and newsroom, accessed 2026-10-24)

| Tool | What it does |
|---|---|
| **Roblox Assistant** (in Studio) | Chat-based help that reads the data model and code; an improved **Planning Mode** turns a prompt into a reviewable, editable plan before changes; a **playtesting agent** (beta) tests against the plan using the player character; mesh generation and procedural models (announced April 2026) |
| **Built-in Studio MCP server** | A local server inside Studio (stdio transport) that lets external AI clients read and edit scripts, search the game tree, inspect instances, run Luau in edit, client or server contexts, start and stop playtests, read console output, capture the viewport, simulate player input, and generate or insert assets; supports several open Studio windows |
| **Studio CLI** | Command-line control of Studio for automation ([Tooling and CI](../13-building-it-right/tooling-and-ci.md)) |
| **Build** (Roblox app tab) | Mobile-first prompt-to-game creation; about 9,000 games published and 71% of its creators new to Studio by September 2026; expanding beyond its New Zealand alpha |
| **Scene Generator** | Prompt plus reference image to a playable layout, announced for Build and Studio later in 2026 |
| **Asset generation** | Text-to-mesh, material variants, procedural models, avatar generation and texture tools ([AI asset generation](../16-ai-studio-operations/ai-asset-generation.md)) |

Roblox's evaluation of Build is a useful model for judging any AI-made game. It scores four signals separately: **specification quality** (does the plan preserve intent and make decisions explicit), **static game quality** (engineering: correct systems, safe client-server boundaries, mobile-ready UI; design: loop depth, variety, progression), **playtest pass rate** with real player-like input, and **visual and experiential quality** on device-sized viewports (Roblox newsroom, 2026-10-08). The studio's gates check the same four things ([Quality gates](../16-ai-studio-operations/quality-gates.md)).

## Community tools (third-party; descriptions from their own pages, not verified by the studio unless stated)

| Tool | Type | Notes |
|---|---|---|
| robloxstudio-mcp (and forks) | MCP server plus Studio plugin | Explore the game tree and read or edit scripts; a read-only inspector variant exists; directory listings in 2026 reported the original being archived and a maintained fork |
| Roblox's earlier reference MCP server | Open-source MCP server plus plugin | Tools such as running code and inserting models; superseded for most uses by the built-in server |
| Desktop agents (for example Roqer, Stud, RoAgent) | Apps or plugins connecting models to Studio | Diff review, adjustable autonomy or action quotas, varying licenses and platform requirements |
| Skill packs (for example MSayib/roblox-dev-skill) | Prompt and knowledge packs for coding agents | Teach conventions; quality varies |
| Bbasche/roblox-ai | Local bridge, MCP server and polling Studio plugin | Reviewed below |

Prefer the **built-in Studio MCP server** for anything new: it is maintained by Roblox, runs locally over stdio, and exposes far more tools than community bridges.

## Review: a community bridge (Bbasche/roblox-ai)

The studio reviewed this public repository read-only in October 2026 (the user had shared a zip of a similarly named project). It is a small, readable project and a good illustration of both the appeal and the risks of homemade bridges.

### How it works

1. A Python **bridge server** (FastAPI) listens on `localhost:8765` with endpoints to queue Lua code, fetch the next command and post results.
2. A **Studio plugin** polls the bridge every 0.5 seconds over HTTP and executes received code with `loadstring`, posting the result back.
3. An **MCP server** gives the AI client a tool that posts Lua to the bridge and waits for the result.
4. A **launcher script** starts the bridge and opens the AI client with **permission prompts disabled** (`--dangerously-skip-permissions`).

### Risks found

| Finding | Why it matters |
|---|---|
| No authentication on the local server | Any local process can queue code that the plugin will run in Studio |
| CORS allows every origin | A web page open in the user's browser can also send requests to the local server; combined with no authentication, a malicious page could queue code for Studio to run |
| Arbitrary code execution via `loadstring` in a plugin | Plugin code runs with broad Studio permissions, including editing the place and making HTTP requests (which could send scripts or assets elsewhere) |
| AI client launched with permission prompts disabled | Every tool call, including shell commands on the user's machine, runs without confirmation |
| Example code in its instructions is outdated or buggy | Examples used deprecated `wait` and `spawn`, scripts inside parts, `BrickColor` styling, no data saving, no remote validation; one coin example referenced an undefined variable, one found leaderstats through the wrong parent, and a checkpoint example set the respawn location to the spawn instead of the checkpoint ([Common Luau mistakes](../13-building-it-right/common-luau-mistakes.md)) |

### Ideas worth keeping (rewritten in the studio's own words)

- **Discoverability defaults:** every interactable gets a prompt, labels float over key objects, a welcome message explains the goal, signs mark spawns and zones, a tips bar rotates hints, pickups give immediate feedback. Adopted as [Discoverability defaults](../01-first-five-minutes/discoverability-defaults.md).
- **Reference images first:** collect visual references before building, and describe them in the brief. Adopted as [Reference image workflow](../16-ai-studio-operations/reference-image-workflow.md).

## Choosing and using AI tools: studio rules

1. **Prefer official, maintained tools** (built-in Studio MCP, Assistant, Open Cloud) over homemade bridges.
2. **No unauthenticated local servers that execute code.** If a bridge is unavoidable: bind to localhost, require a secret token, reject browser origins, and allow-list commands.
3. **Never disable permission prompts** for agents that can run shell commands on a person's machine; this repository's guard hook also blocks publishing commands ([For AI agents](../00-start-here/for-ai-agents.md)).
4. **Treat downloaded tools and code as untrusted:** read before running, keep them in their own folder, never run them in a working project ([Security and anti-exploit](../13-building-it-right/security-and-anti-exploit.md)).
5. **Judge AI output by evidence**, not claims: the quality gate, playtests, screenshots and check records ([Quality gates](../16-ai-studio-operations/quality-gates.md)).
6. **Keep humans on the decisions that are theirs:** publishing, money, terms and policy answers.
7. **Teach agents current conventions:** strict Luau, server authority, validated remotes, session-locked data, original assets ([Luau standards](../13-building-it-right/luau-standards.md)).

## For agents

- [ ] Use the built-in Studio MCP server; do not install community bridges without a human decision and a security review.
- [ ] Never run AI clients with permission prompts disabled on a person's machine.
- [ ] Generated code passes the template's quality gate before it is accepted.
- [ ] Community tool descriptions in briefs are labelled as third-party and dated.

Sources: [Connect to the Roblox Studio MCP server](https://create.roblox.com/docs/studio/mcp) · [Studio CLI](https://create.roblox.com/docs/studio/cli) · Roblox newsroom: [Roblox Studio is going agentic](https://about.roblox.com/newsroom/2026/04/roblox-studio-going-agentic), [RDC 2026](https://about.roblox.com/newsroom/2026/09/rdc-2026-the-world-needs-more-play), [How Roblox evaluates Build game creation](https://about.roblox.com/newsroom/2026/10/how-roblox-evaluates-build-game-creation) · Repositories reviewed or listed: [Bbasche/roblox-ai](https://github.com/Bbasche/roblox-ai), [boshyxd/robloxstudio-mcp](https://github.com/boshyxd/robloxstudio-mcp), [MSayib/roblox-dev-skill](https://github.com/MSayib/roblox-dev-skill), [madebyshaurya/stud](https://github.com/madebyshaurya/stud). All accessed 2026-10-24.

Related: [Studio MCP playbook](../16-ai-studio-operations/studio-mcp-playbook.md) · [AI asset generation](../16-ai-studio-operations/ai-asset-generation.md) · [Agent team workflow](../16-ai-studio-operations/agent-team-workflow.md) · [Common Luau mistakes](../13-building-it-right/common-luau-mistakes.md) · [Discoverability defaults](../01-first-five-minutes/discoverability-defaults.md)
