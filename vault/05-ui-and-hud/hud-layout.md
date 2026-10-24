---
title: HUD layout
date: 2026-10-24
tags: [ui, hud, layout, mobile]
aliases: [HUD, Screen layout]
summary: Where things go on a Roblox screen, why, and how to keep the HUD clear of the platform's own controls on every device.
audience: [human, agent]
---

# HUD layout

The HUD (heads-up display) is the always-visible layer: currencies, main buttons, goals, timers. Players hop between many games, so a layout that matches platform conventions is understood instantly.

## The conventional Roblox layout

```
+----------------------------------------------------------------+
| [Roblox top bar: menu, chat, etc.]          [currencies] [+]   |
|                                                                 |
| [menu buttons]         [goal / quest tracker]     [timers /    |
| [Shop]                                             events]      |
| [Pets]                                                          |
| [Rebirth]                                                       |
| [Daily]                                                         |
|                                                                 |
|                    3D WORLD (keep center clear)                 |
|                                                                 |
| [touch thumbstick            [context action]       [jump]     |
|  zone, left bottom]          [ability buttons, right bottom]   |
+----------------------------------------------------------------+
```

| Zone | Usual content | Why |
|---|---|---|
| Top center | Current goal, quest tracker, event banner | Seen first, does not cover controls |
| Top right | Currencies with a "+" button to the shop | Convention across many games |
| Left side, vertical stack | Menu buttons: Shop, Inventory/Pets, Rebirth, Daily, Codes, Settings | Easy thumb reach on phones held landscape |
| Right side | Timers, event countdowns, active boosts | Glanceable, rarely tapped |
| Bottom right | Action and ability buttons (mobile) | Right thumb, near the default jump button |
| Bottom left | Reserved for the movement thumbstick on touch | Never put buttons here on mobile |
| Bottom center | Hotbar / backpack (tools), notifications | Default Roblox backpack lives here |
| Center | Nothing permanent | The game is the main content |

This is a convention, not a law. Some genres differ (shooters put ammo bottom right; fighting games put the ability bar bottom center on PC). Whatever you choose, stay consistent and keep clear of platform controls.

## Platform controls you must not cover

- **The Roblox top bar** (Roblox menu, chat, and other core buttons) at the top of the screen. Use `ScreenGui.ScreenInsets` (for example `CoreUISafeInsets`) to keep your UI out of the core UI area, and only extend art under it deliberately.
- **Device safe areas** (notches, rounded corners, home indicators). `DeviceSafeInsets` keeps elements inside the safe region.
- **The touch thumbstick** (bottom left quarter on touch devices) and the **jump button** (bottom right). Place ability buttons around the jump button, not on it.
- **Chat** when open (top left on many layouts). Test with chat expanded.

## Buttons on the left stack

- 4 to 7 buttons maximum. More belong inside a menu.
- Order by frequency: the most used at the top (often Shop), rarely used at the bottom (Settings).
- Each has an icon, a short label under or beside it, and a notification badge when something is claimable.
- Use a single column on phones; a column or a grid on tablets and PC.

## The goal tracker

The single most valuable HUD element for retention: a compact panel that always shows the next goal and progress ("Unlock Lava World: 18.4K / 25K"). Tapping it should guide the player (beam or camera pan to the gate). See [Progression architecture](../04-progression-and-economy/progression-architecture.md).

## Currencies

- Show only currencies relevant now; an event currency appears only during its event.
- Animate changes (count up, scale pop) and show gains as floating numbers.
- A "+" next to premium currency opens the right shop tab directly.

## Contextual buttons

Use `ProximityPrompt` for world interactions (open, buy pad, talk). It handles keyboard, gamepad and touch prompts automatically and appears only when relevant. Customize its style to match the game, but keep the hold-time short (or zero) for frequent actions.

## Density checks

- With the HUD fully visible on a small phone, at least about two thirds of the screen should show the game world.
- No more than one element animating for attention at a time.
- Hide or collapse non-essential HUD during intense moments (boss fight, chase, round climax).

## Layouts for portrait and console

- **Portrait phones**: some casual games support portrait. If you do, design a separate portrait layout (stacked buttons at the bottom) rather than squeezing the landscape one.
- **Console**: navigation is with a gamepad selection cursor. Buttons must be selectable in a sensible order; follow Roblox console guidelines (readable from a distance, larger text). See [Console and VR](../08-mobile-and-cross-platform/console-and-vr.md).

## For agents

- [ ] No HUD element overlaps the top bar, thumbstick zone, jump button or device safe areas (check with `ScreenInsets` and the Device Simulator).
- [ ] Left menu stack has 4-7 buttons with icons, labels and badges.
- [ ] Goal tracker visible at all times outside menus, and tappable for guidance.
- [ ] At least two thirds of a small phone screen shows the world with the full HUD visible.
- [ ] Contextual interactions use `ProximityPrompt` or an equivalent that works on touch, keyboard and gamepad.

Related: [UI principles for Roblox](ui-principles.md) · [Menus, shops and inventories](menus-shops-inventories.md) · [Controls and input](../08-mobile-and-cross-platform/controls-and-input.md) · [UI implementation](ui-implementation.md)
