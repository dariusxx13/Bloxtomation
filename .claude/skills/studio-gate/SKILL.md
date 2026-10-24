---
name: studio-gate
description: Run the stage gate for a game with the Gatekeeper agent - criteria by id, mechanical checks re-run for the exact build, evidence verified, verdict recorded. Use when a stage's work is finished or the user asks whether a game is ready to move on.
argument-hint: "<game-id>"
disable-model-invocation: true
allowed-tools: Bash(python3 agents/studioctl.py *)
---

Game: $ARGUMENTS

1. `python3 agents/studioctl.py game show $ARGUMENTS` to get the current stage; stop and explain if the game is waiting for a human decision.
2. Queue the gate task if it does not exist yet:
   `python3 agents/studioctl.py task add --game $ARGUMENTS --owner gatekeeper --title "<stage> gate" --brief -` with a brief whose acceptance criteria list every criterion id from `python3 agents/studioctl.py gate criteria <stage>`.
3. Start the `gatekeeper` agent with: "You are assigned the <stage> gate for $ARGUMENTS. Claim it with `studioctl.py task next --owner gatekeeper` and follow your procedure."
4. When it returns, show the user the verdict, each failed criterion with what evidence would pass, any waivers, and (for pitch, prototype and release candidate) the decision that is now theirs.
