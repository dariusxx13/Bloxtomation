---
name: studio-status
description: Show the studio board - every game's stage, tasks in progress and in review, Studio leases, gate results, and the list of decisions waiting for the human. Use when the user asks what the agents are doing or what needs them.
allowed-tools: Bash(python3 agents/studioctl.py *)
---

1. Run `python3 agents/studioctl.py board`.
2. Answer in this order, briefly:
   - **Needs you**: each item with what to look at (file paths) and the exact command to run when they decide (`python3 agents/studioctl.py human approve <game>` and so on), plus your recommendation.
   - **Games**: one line each with stage, status and last gate result.
   - **In progress and in review**: who is doing what.
   - **Blocked**: tasks waiting on dependencies, drafts missing briefs, Studio contention.
3. If there is no workspace yet, say so and suggest `/studio <idea>` to start one.
