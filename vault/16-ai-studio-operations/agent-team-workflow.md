---
title: Agent team workflow
date: 2026-10-24
tags: [ai, agents, workflow, process, studio]
aliases: [AI studio, Agent roster, Multi-agent workflow]
summary: How a team of AI agents builds and runs Roblox games: the fifteen roles, the stage pipeline, handoffs, the task queue, Studio sharing, evidence and human checkpoints.
audience: [human, agent]
---

# Agent team workflow

This note describes how this repository's agent team works. The agents live in `agents/` (definitions, prompts and the orchestrator). The vault is their shared brain: every agent reads the notes relevant to its role before acting.

## Principles

1. **One goal in, a playable game out.** The human gives an idea or picks a pitch; the team plans, builds, tests and improves it, and brings back decisions, not busywork.
2. **Specialists with clear lanes.** Each agent owns one part of the work and checks the work of others where its expertise applies.
3. **Evidence over claims.** Every handoff includes proof: build output, playtest notes, screenshots, numbers with sources.
4. **Stages with gates.** Work moves through stages; the Gatekeeper checks each stage against written criteria before the next starts.
5. **Humans decide money, publishing and policy.** Agents never publish, never spend money, never answer policy questions on the human's behalf.

## The roster

| Agent | Owns | Main vault folders |
|---|---|---|
| **Director** | Turns goals into plans and tasks; routes work; keeps the human informed | 00, 16, 18 |
| **Scout** | Chart tracking, trend analysis, teardowns, pitches | 15, 11 |
| **Designer** | Game design document, loops, onboarding, progression, systems specs | 01, 02, 03, 04, 14 |
| **Economist** | Economy sheet, pacing math, drop tables, multipliers | 03, 04 |
| **Monetization Designer** | Product catalog, pricing, offers, compliance | 09 |
| **Engineer** | Server systems, client controllers, data, networking, analytics | 13 |
| **Interface Designer** | UI, HUD, menus, mobile layouts, feedback | 05, 08 |
| **Worldbuilder** | Maps, zones, lobbies, lighting, build budgets | 06 |
| **Artist** | Models, VFX, animation, audio sourcing, asset safety and index | 07 |
| **Storefront** | Icon, thumbnails, title, description, store video, ad creatives | 11 |
| **QA Tester** | Playtests in Studio, golden path, multi-client, devices, regressions | 13 (testing) |
| **Newcomer** | Plays like a brand-new young player with no context; reports confusion | 01 |
| **Security Reviewer** | Reviews remotes, data, receipts, exploits and compliance before ship | 13, 09 |
| **Gatekeeper** | Checks stage criteria with evidence; approves or returns work | 16 (quality gates) |
| **Analyst** | Live metrics, experiments, update plans, postmortems | 12 |

## The stage pipeline

| Stage | Output | Gate owner |
|---|---|---|
| 1. Pitch | Pitch document with evidence and rubric score | Gatekeeper, then human approval |
| 2. Design | GDD: loops, first session, progression, economy sheet, catalog draft, art direction | Gatekeeper |
| 3. Prototype | Playable core loop with juice; fun-check report | Gatekeeper, then human decision (continue, pivot, stop) |
| 4. Build | Systems and launch content; data, receipts, analytics; UI on all devices | Gatekeeper |
| 5. Polish | Balance pass, juice pass, performance pass, store page assets | Gatekeeper |
| 6. Release candidate | Saved (not published) upload; full QA and security sign-off | Gatekeeper, then **human publishes** |
| 7. Live | Monitoring, hotfixes, first updates | Analyst |
| 8. Review | Day-14 and day-60 postmortems; lessons into the vault | Analyst, Gatekeeper |

Details of each gate: [Quality gates](quality-gates.md).

## Tasks and handoffs

- Every unit of work is a **task** with: title, owner agent, game, stage, brief (see [Build briefs](build-briefs.md)), dependencies, acceptance criteria and status (queued, working, needs review, done, dropped).
- Each agent works one task at a time from its own queue, in order. New messages to a busy agent wait their turn.
- A handoff note at the end of each task states: what was done, evidence, what is next and for whom, and open questions.
- The Director creates and routes tasks; any agent can propose tasks to the Director.

## Sharing Roblox Studio

Studio is a shared, limited resource:

- Agents that need Studio (Engineer for integration, Worldbuilder, Interface Designer for device checks, QA Tester, Newcomer) acquire a **Studio lease** before using it and release it when done.
- The number of concurrent Studio instances is configurable (for example 1 or 2), depending on the machine.
- Every Studio MCP call names the Studio instance (`studio_id`), so agents never act on the wrong window.
- Code changes happen in the repository files (Rojo), not inside Studio, so Studio work never overwrites code.

See [Studio MCP playbook](studio-mcp-playbook.md).

## Human checkpoints

The Director brings these to the human, with a recommendation:

- Approving a pitch and the prototype decision.
- Any spending (ads, paid assets, fees) and any publishing.
- Policy questions (age rating answers, IP, random items).
- Changes to prices of subscriptions or private servers.
- Data incidents.

The human also gets a short "needs you" list: things to look at (screenshots to approve, a build to play on their phone).

## Learning loop

- Every rejection at a gate cites the failed criteria by id.
- Postmortems record results with sources; lessons start as observations and become house rules only after repeating (see [Postmortems](../12-live-ops-and-launch/postmortems.md)).
- Agents propose vault edits with evidence when data contradicts a rule.

## For agents

- [ ] Start every task by reading its brief and the vault notes for your role.
- [ ] End every task with a handoff note containing evidence.
- [ ] Acquire and release Studio leases; always pass `studio_id`.
- [ ] Escalate money, publishing, policy and data-loss risks to the Director immediately.

Related: [Quality gates](quality-gates.md) · [Build briefs](build-briefs.md) · [Studio MCP playbook](studio-mcp-playbook.md) · [For AI agents](../00-start-here/for-ai-agents.md)
