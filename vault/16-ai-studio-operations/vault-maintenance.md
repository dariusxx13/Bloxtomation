---
title: Vault maintenance
date: 2026-10-24
tags: [ai-studio, vault, maintenance, freshness, evidence, process]
aliases: [Keeping the vault fresh, Vault upkeep, Knowledge maintenance]
summary: The operating procedure for keeping this vault accurate as Roblox and the market change - claim labels, a refresh calendar per kind of note, how agents propose and make changes, the lint and link checks, handling contradictions and deprecated features, and recording lessons from the studio's own games.
audience: [human, agent]
---

# Vault maintenance

A knowledge base that is wrong is worse than none: agents act on it. Roblox changes its APIs, rules and payouts several times a year, and the charts change every week. This note is the procedure that keeps the vault true. The principles are in [How to use this vault](../00-start-here/how-to-use-this-vault.md) ("Keeping the vault true"); this is the checklist.

## Claim labels

Every claim belongs to one of these, and the label is visible in the note:

| Label | Meaning | Requirement |
|---|---|---|
| **Fact** | Documented by Roblox (docs, API reference, newsroom) | Link to the official page and the date checked |
| **Reported** | A third party reports something (trackers, press, guides) | Name the source and date; numbers marked approximate |
| **Rule of thumb** | The studio's heuristic | Labelled as such; revisited when evidence arrives |
| **Studio data** | From the studio's own tracker, playtests or analytics | Snapshot or check record reference |

A Reported item becomes a Fact only when an official source is found; then update the label and the link (as done for RDC 2026 items in [Platform shifts 2025-2026](../21-hits-and-trends/platform-shifts-2025-2026.md)).

## Refresh calendar

| Notes | Refresh | Trigger |
|---|---|---|
| Chart snapshot notes | Monthly (a new dated note each time) | Scout's monthly market report |
| Hits of the year, trend waves | Quarterly | New breakouts or waves |
| Platform shifts, engine features | After each RDC and major announcement | Roblox newsroom posts |
| Key numbers, engine limits | When Roblox changes a rule; full check twice a year | Doc changes, DevEx or policy updates |
| Monetization compliance, IP | Whenever policy pages change | Policy updates |
| Genre playbooks | Twice a year, or after the studio ships in that genre | Postmortems |
| Engineering notes | When an API is deprecated or a new system ships | Engine release notes |

The Analyst and Scout propose updates; the Director assigns them as normal tasks.

## Making a change

1. **Find the official source** (docs, API reference or newsroom) or a dated third-party source.
2. **Edit the note it belongs to**; do not create duplicates. Keep the same frontmatter fields (`title`, `date`, `tags`, `aliases`, `summary`, `audience`) and the `Related:` line.
3. **Update the date** in frontmatter when the substance changes.
4. **Update dependants**: [Key numbers](../99-reference/key-numbers.md), [Engine limits reference](../22-references/engine-limits-reference.md), [Glossary](../99-reference/glossary.md), indexes and any note that repeats the fact.
5. **Run the checks** (below) and include their output in the handoff.
6. **Commit** with a message that names the source and what changed.

## Checks

- **Vault lint:** the Obsidian-notes lint script must report zero errors (broken links, missing indexes, frontmatter errors) and no orphans.
- **Official link check:** links to `create.roblox.com/docs` are checked against a local copy of Roblox's public creator-docs repository; zero missing.
- **Agents' vault sync test:** `python3 -m unittest discover -s agents/tests` keeps the gate criteria and roster in sync with this section.
- **Word and scope check:** new notes follow the note structure in [How to use this vault](../00-start-here/how-to-use-this-vault.md).

## Contradictions and deprecations

- When two notes disagree, the one with the newer official source wins; fix the other in the same change.
- When Roblox deprecates an API or feature, update [Engine and platform features 2024-2026](../22-references/engine-features-2024-2026.md) ("Replaced or discouraged"), [Common Luau mistakes](../13-building-it-right/common-luau-mistakes.md) and the notes that use it. Example from October 2026: Roblox's docs now discourage `Sound` objects, so the audio notes were updated together.
- When a third-party number conflicts with another, show both with sources, or prefer the one with a clearer method.

## Lessons from the studio's own games

Postmortems at day 14 and day 60 produce **evidence-backed proposals** to update the vault ([Postmortems](../12-live-ops-and-launch/postmortems.md)). A proposal states the claim, the evidence (check records, analytics with dates), the note to change and the new text. The Director approves; an agent edits; the Gatekeeper checks the evidence like any other handoff.

## For agents

- [ ] Every new or changed claim has a label and a dated source.
- [ ] Changes update all dependants and pass the lint, link check and vault sync tests.
- [ ] Monthly chart notes are new files, not overwrites.

Related: [How to use this vault](../00-start-here/how-to-use-this-vault.md) · [Quality gates](quality-gates.md) · [Postmortems](../12-live-ops-and-launch/postmortems.md) · [Sources](../99-reference/sources.md) · [Platform shifts 2025-2026](../21-hits-and-trends/platform-shifts-2025-2026.md)
