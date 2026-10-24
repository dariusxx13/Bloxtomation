---
title: First-session killers
date: 2026-10-24
tags: [onboarding, ftue, bounce, debugging]
aliases: [Why players leave, Bounce causes]
summary: The concrete causes of early bounce on Roblox, how to detect each one, and the fix.
audience: [human, agent]
---

# First-session killers

When new players leave in the first few minutes, it is almost always one of the causes below. Work down the list in order: the earlier items are both more common and cheaper to fix.

## How to find the killer

1. Open the onboarding funnel (see [Measuring onboarding](measuring-onboarding.md)) and find the step with the largest drop.
2. Watch real first sessions. Record five new players (friends, testers, or yourself on a fresh account) on a phone. Do not explain anything. Write down every moment of hesitation.
3. Check the performance dashboard for crashes, frame rate and memory on low-end devices.
4. Match what you see to the table below.

## The killers

### 1. Promise mismatch

**Symptom.** Players bounce within 10-30 seconds; play-through rate may be fine.
**Cause.** The thumbnail or title promised something the first frame does not show (a dragon on the thumbnail, a grey baseplate on spawn).
**Fix.** Make the first frame look like the thumbnail. Spawn players next to the thing the thumbnail sells. Roblox also demotes games whose metadata does not match content, so this is a discovery problem too.

### 2. Nothing to do immediately

**Symptom.** Players walk around, then leave. Low completion of onboarding step 1.
**Cause.** No obvious first action; spawn far from the action; a menu before the game.
**Fix.** Spawn at the action, add one pointer, remove the menu. See [First session blueprint](first-session-blueprint.md).

### 3. Confusion

**Symptom.** Players do random things, open menus and close them, then leave. Funnel drops at a step that needs understanding (place, merge, equip, craft).
**Cause.** Too many buttons, unclear icons, text instructions, two systems introduced together.
**Fix.** Progressive UI reveal, one concept per step, ghost demonstration for non-obvious gestures. See [Onboarding patterns](onboarding-patterns.md).

### 4. Slow or stuttering load

**Symptom.** Bounce concentrated on mobile, especially Android; long time between join and first input in the data; high crash rate.
**Cause.** Big map without streaming, huge textures and meshes, too many scripts running on start, heavy effects at spawn.
**Fix.** Enable `StreamingEnabled` with sensible radii, defer non-essential loading, cut spawn-area detail, profile with the MicroProfiler on a low-end device. See [Device performance](../08-mobile-and-cross-platform/device-performance.md).

### 5. Controls that fight the player

**Symptom.** High bounce on touch devices only.
**Cause.** Buttons covering the jump button or thumbstick, tiny buttons, keyboard-only actions (press F, press Q) with no touch equivalent, camera that fights the player.
**Fix.** Every action has a touch button in the thumb zone; nothing overlaps default controls; test in the Device Simulator at several phone sizes. See [Controls and input](../08-mobile-and-cross-platform/controls-and-input.md).

### 6. A reward that does not feel like one

**Symptom.** Players do the first action, then stop. Step 1 completion is high, step 2 or 3 drops.
**Cause.** The reward is a silent number change, too small, or delayed.
**Fix.** Animate it, add sound, make the number big, show what it buys. See [Game feel and juice](../02-core-loop/game-feel-and-juice.md).

### 7. Nothing to spend on

**Symptom.** Players earn, then leave around minute 2-4.
**Cause.** The first upgrade costs too much or is hidden.
**Fix.** The first upgrade is affordable within 1-3 actions and the shop is shown by a guided purchase.

### 8. Early punishment

**Symptom.** Bounce right after a death, a lost round, a robbery or a failed jump.
**Cause.** The player loses progress or gets killed by a veteran before they understand the game.
**Fix.** Safe first area, spawn protection, new-player matchmaking or a protected base for the first minutes, no loss of earned progress on early deaths.

### 9. Veterans make it unfair

**Symptom.** In PvP, steal and competitive games: bounce in mixed servers, better retention in empty servers.
**Cause.** New players dropped into servers where veterans dominate, steal from them or spawn-kill them.
**Fix.** Protection timers, catch-up mechanics, separate new-player servers or lobbies, rewards for veterans helping newcomers, scale steal targets by progression.

### 10. Pay pressure

**Symptom.** Bounce after a purchase prompt; dislikes mention "pay to win" or "greedy".
**Cause.** Popup offers in the first minutes, paywalled early content, a timer you can pay to skip.
**Fix.** No interrupting purchase prompts in the first session. Offers appear in context (out of space, rare egg available), never as a gate. See [Shop UX and contextual offers](../09-monetization/shop-ux-and-contextual-offers.md).

### 11. Empty server feeling

**Symptom.** Retention much worse at low player counts; players leave servers with 1-2 people.
**Cause.** The game needs other people to be fun (social, PvP, roleplay) but matchmaking spreads players thin.
**Fix.** Smaller max server size early, fill servers before opening new ones (Roblox's default matchmaking prefers fuller servers; custom matchmaking can bias further), bots or NPCs to fill the world, and solo-viable content.

### 12. Bugs on the golden path

**Symptom.** A sharp funnel drop at one specific step.
**Cause.** A broken prompt, a stuck NPC, a remote that errors, a UI element off-screen on some devices.
**Fix.** Check the error report and the console for that step; replay the step on every device type. Make the golden path a QA test that runs before every publish. See [Testing and QA](../13-building-it-right/testing-and-qa.md).

## Quick diagnosis table

| Where the drop is | Most likely killer |
|---|---|
| Before step 1 (join to first action) | 1, 2, 4 |
| Between first action and first reward | 3, 5, 12 |
| Between first reward and first upgrade | 6, 7 |
| After the first death, loss or prompt | 8, 9, 10 |
| Only on mobile | 4, 5 |
| Only in low-population servers | 11 |
| A single step, all devices | 12 |

## For agents

When asked to "fix retention" or "fix bounce":

1. Pull the onboarding funnel and find the largest drop. Do not guess.
2. Name which killer(s) match, with the evidence (funnel step, device split, error count).
3. Propose the smallest fix that addresses that killer, and the metric that should move.
4. After the fix ships, compare the same funnel step for new-user cohorts before and after (7 days each), and report the change with sample sizes.

Related: [First session blueprint](first-session-blueprint.md) · [Onboarding patterns](onboarding-patterns.md) · [Measuring onboarding](measuring-onboarding.md) · [Discovery algorithm](../11-store-page-and-discovery/discovery-algorithm.md)
