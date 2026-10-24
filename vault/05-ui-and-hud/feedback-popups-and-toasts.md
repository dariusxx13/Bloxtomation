---
title: Feedback, popups and toasts
date: 2026-10-24
tags: [ui, feedback, notifications, juice]
aliases: [Popups, Toasts, Notifications UI, Floating numbers]
summary: How to tell players what just happened (rewards, unlocks, errors, events) without spamming or blocking them.
audience: [human, agent]
---

# Feedback, popups and toasts

Players need to know what just happened, what they got and what they can do now. The art is matching the weight of the message to its importance.

## The message hierarchy

| Level | Use for | Form | Duration | Blocks play? |
|---|---|---|---|---|
| 1. Floating number | Every small gain | "+25" near the source, flies to the counter | 0.5-1 s | No |
| 2. Toast | Notable events (level up, quest done, item added) | Small banner sliding in at top or side | 2-4 s | No |
| 3. Banner | Big events (new zone unlocked, rare drop, event start) | Large center-top banner with art | 3-5 s | No |
| 4. Modal | Needs a decision or celebrates a milestone | Panel with buttons | Until closed | Yes |
| 5. Full-screen moment | Once-in-a-while peaks (top-tier hatch, rebirth, season end) | Full-screen sequence, skippable | 2-6 s | Briefly |

Rule: **the higher the level, the rarer it must be.** If a player sees more than one modal per few minutes outside menus, they will stop reading them.

## Floating numbers

- Spawn at the source in world space (use `Camera:WorldToViewportPoint` to place a screen element, or a `BillboardGui` for numbers that should stay in the world), then animate toward the counter.
- Color by currency or damage type; bigger and brighter for crits and bonuses.
- Merge rapid repeats ("+25" five times in a second becomes "+125") to reduce clutter and cost.
- Pool and cap them (10-20 on screen at most).

## Toasts

- One queue, shown one at a time or stacked up to three, newest on top.
- Icon + short text: "Quest complete: +500 coins".
- Tappable when there is an action ("Tap to equip").
- Skip low-value toasts when the queue is long, rather than delaying them.

## Banners

- Reserve for genuinely important moments: unlocks, rare drops, event starts, server announcements.
- Distinct art per type (gold for achievements, purple for rare drops, event-themed for events).
- A sound sting that matches the type.

## Modals

Use modals only when:

- The player must choose (rebirth confirmation, trade request).
- A milestone deserves a pause (first rebirth, season reward).
- A purchase-related confirmation is needed.

Every modal has an obvious close or a clear default choice, and never appears in the middle of combat or a chase.

## Errors and denials

When the server rejects an action, tell the player why, briefly and kindly:

| Bad | Good |
|---|---|
| "Error 403" | "Not enough coins" (with how many more are needed) |
| Nothing happens | Button shakes, short "Inventory full" toast with a "Manage" action |
| "You cannot do that" | "Unlock at Rebirth 3" |

Never reveal exploit-relevant details (do not echo validation internals).

## Notifications from the server

Many messages originate on the server (rare drops, event starts, admin announcements). Send a small typed message ("Toast", "Banner", id, parameters) and let the client render it. Do not build UI on the server. For chat-style announcements, use `TextChatService` system messages from the server.

## Badges and red dots

- A red dot or number on a button means "something claimable here". Clear it the moment the player sees or claims the thing.
- Never use a red dot purely to advertise a shop item. Players learn to ignore dots that lie.

## For agents

- [ ] Each message type mapped to a hierarchy level; modals are rare and never interrupt combat.
- [ ] Floating numbers pooled, capped and merged.
- [ ] One toast queue; low-value toasts dropped when busy.
- [ ] Every server rejection maps to a clear player-facing reason.
- [ ] Notification badges reflect real claimable items only.

Related: [Game feel and juice](../02-core-loop/game-feel-and-juice.md) · [UI principles for Roblox](ui-principles.md) · [HUD layout](hud-layout.md) · [Reveal and hatch design](../03-rarity-and-rng/reveal-and-hatch-design.md)
