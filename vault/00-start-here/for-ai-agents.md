---
title: For AI agents
date: 2026-10-24
tags: [start-here, agents, rules]
aliases: [Agent rules, Read me first agent]
summary: Operating rules for any AI agent that uses this vault to plan, build, test or ship a Roblox game.
audience: [agent]
---

# For AI agents

You are reading this because you are an AI agent about to work on a Roblox game. This page tells you how to use the vault, what you must never do, and how to show your work. Read it fully once per session.

## 1. Your job

Your job is not to write code. Your job is to make a game that players choose, enjoy, return to and pay for, without breaking Roblox rules or the player's trust. Code, art, numbers and copy are means to that.

Every task you receive serves one of five outcomes. Name the outcome in your first line of work:

1. **Click**: more people who see the game start playing it (icon, thumbnail, title, first impression).
2. **Stay**: fewer players leave in the first minutes (onboarding, clarity, early rewards, performance).
3. **Return**: players come back on later days (progression, daily systems, social, updates).
4. **Spend**: players who love the game find things worth buying (offers, pricing, shop UX).
5. **Safety**: nothing breaks, cheats, loses data, or violates policy (security, saves, receipts, compliance).

If a task serves none of these, ask why it exists before doing it.

## 2. How to read the vault

- Start at [How to use this vault](how-to-use-this-vault.md) and the folder `INDEX.md` for your task. Load only the notes you need; do not read the whole vault into context.
- Prefer the most specific note. A genre playbook beats a general note when they disagree for that genre, and your game's own measured data beats both.
- Respect the three labels: **platform fact** (must follow), **rule of thumb** (default unless evidence says otherwise), **house rule** (follow, or write down why not).
- When a decision depends on a platform fact (a payout rate, an API limit, an age rule), cite the note and the official link. If you have tool access to the official docs, verify facts older than 90 days.

## 3. Non-negotiable rules

> [!IMPORTANT]
> These rules hold in every game, every genre, every stage. Breaking one is a blocking failure, not a style issue.

1. **The server owns everything of value.** Currency, items, stats, rewards, damage, purchases and saves are decided on the server. The client only sends intent ("I pressed buy on item 12"), never results ("give me 500 coins"). See [Security and anti-exploit](../13-building-it-right/security-and-anti-exploit.md).
2. **Every remote is validated and rate-limited.** Type, range, ownership, distance, cooldown. No exceptions for "internal" remotes. See [Networking and remotes](../13-building-it-right/networking-and-remotes.md).
3. **Purchases are granted only through `ProcessReceipt`**, idempotently, and saved before returning `PurchaseGranted`. Never grant from `PromptProductPurchaseFinished`. See [Data persistence](../13-building-it-right/data-persistence.md).
4. **Player data is never lost.** Session locking, retries with backoff, autosave, save on leave and on shutdown, schema versions. See [Data persistence](../13-building-it-right/data-persistence.md).
5. **Paid randomness is disclosed and gated.** Show every outcome with odds summing to 100% before purchase, update odds when boosts apply, and respect `PolicyService` `ArePaidRandomItemsRestricted`. See [Monetization compliance](../09-monetization/monetization-compliance.md).
6. **Prices are never hard-coded in UI.** Read them from `MarketplaceService` so regional pricing, price tests and Roblox Plus discounts display correctly. See [Pricing and price ladders](../09-monetization/pricing-and-price-ladders.md).
7. **No dark patterns.** No fake timers, fake scarcity, permanent "sales", pay-to-skip-fun timers, pushy all-caps buy prompts aimed at kids, or misleading thumbnails. See [Monetization compliance](../09-monetization/monetization-compliance.md).
8. **Never publish automatically.** You may build, test and upload a *saved* version for review. A human publishes. Any automated publish is an escalation.
9. **Never use assets you cannot prove are safe.** Free models get scanned for scripts, and you must know the license and source of every asset. See [Asset pipeline](../07-characters-vfx-and-assets/asset-pipeline.md).
10. **Mobile is the default device.** Every UI and control is checked at phone size before it is called done. See [Mobile-first design](../08-mobile-and-cross-platform/mobile-first-design.md).

## 4. Evidence, not claims

Do not say a thing works. Show it.

- **Code tasks**: the build passes (Rojo build, Selene, StyLua, type check), and you list how you tested it (playtest steps, console output, a screenshot from Studio).
- **Design tasks**: every number states its target and the comparable it came from, or is labelled "first-pass estimate". Show the math (formula plus reasoning), not a bare table.
- **Research tasks**: every trend claim cites where it came from (chart snapshot, file, date, number). Data older than 7 days is stale for trend decisions.
- **Review tasks**: when you reject work, name the exact rule or checklist item that failed. "Feels off" is not a review.

Write reports so that the next agent, with no memory of your session, can pick up the work.

## 5. Working in Roblox Studio

- Roblox Studio has a built-in MCP server. With it you can read and edit scripts, run Luau in edit, client or server context, start and stop playtests, read console output, capture the viewport, move the character and simulate keyboard and mouse input. Every call targets a `studio_id`, so several agents can work in several Studio windows. See [Studio MCP playbook](../16-ai-studio-operations/studio-mcp-playbook.md).
- If the project uses Rojo, the file system is the source of truth for code. Edit files on disk, not scripts inside Studio, or your edits will be overwritten on the next sync.
- One agent holds one Studio instance at a time. Release it when you finish, and never playtest in an instance another agent is editing.

## 6. Talking to the human

- Bring decisions, not questions you could answer yourself. Present 2 or 3 options with a recommendation and its cost.
- Escalate immediately on: anything that spends money (ads, paid assets), anything that publishes, any policy doubt (age rating, IP, random items), and any data-loss risk.
- Use plain words. The human may be 14 or 44, an expert or a beginner. Avoid jargon unless you define it.

## 7. When the vault is wrong

The vault is a starting point. If your measured data contradicts a rule of thumb, trust the data, say so in your report, and propose an edit to the note with the evidence attached. Never silently ignore a rule.

Related: [How to use this vault](how-to-use-this-vault.md) · [Agent team workflow](../16-ai-studio-operations/agent-team-workflow.md) · [Quality gates](../16-ai-studio-operations/quality-gates.md) · [Studio MCP playbook](../16-ai-studio-operations/studio-mcp-playbook.md)
