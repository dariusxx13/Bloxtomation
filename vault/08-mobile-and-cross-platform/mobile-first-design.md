---
title: Mobile-first design
date: 2026-10-24
tags: [mobile, ux, controls, performance]
aliases: [Mobile design, Phone first]
summary: Why every Roblox game should be designed for phones first, and the concrete design, control and performance rules that follow.
audience: [human, agent]
---

# Mobile-first design

Most Roblox sessions happen on phones and tablets, many of them on inexpensive Android devices. A game designed on a PC with a mouse and keyboard and "ported" to mobile at the end almost always loses its mobile players in the first minute. Design for a phone in landscape first, then add PC and console comforts.

## What changes on a phone

| Factor | PC | Phone | Design consequence |
|---|---|---|---|
| Input | Mouse precision, many keys | Two thumbs, imprecise taps | Few, large buttons; auto-aim or generous hitboxes |
| Screen | Large | ~6 inches, partly covered by thumbs | Big text, minimal HUD, important things at the top and center |
| Camera | Mouse look | Swipe to rotate, conflicts with buttons | Simple camera needs; avoid precise aiming |
| Performance | Strong | Weak CPU and GPU, little memory | Strict budgets, streaming, low-detail options |
| Session context | At a desk | On the bus, in bed, short bursts | Quick sessions must still progress; save often |
| Network | Stable | Variable, mobile data | Tolerate latency; small, infrequent network messages |

## Design rules

1. **One-thumb core action.** The core action works with a single tap, a hold, or simply walking into things. Avoid actions that need two simultaneous precise inputs.
2. **Auto-target where precision would hurt.** Lock-on, aim assist, generous hitboxes, or tap-on-target interactions.
3. **Buttons on the right, movement on the left.** Never put buttons in the bottom-left thumbstick area or on the jump button. See [HUD layout](../05-ui-and-hud/hud-layout.md).
4. **Every keyboard action has a touch button.** If PC uses E, Q, F, R and Shift, mobile needs visible buttons for each, or the design must not need them.
5. **Large targets** with spacing; no tiny close buttons.
6. **Readable at arm's length.** Bold text with outlines; test at real phone size.
7. **Short, interruptible sessions still progress.** A two-minute session on the bus should earn something.
8. **Respect the notch and home indicator.** Use safe insets.
9. **Optional portrait support** only if your game is designed for it; most Roblox games are landscape.
10. **Low-graphics friendliness.** Effects scale down when the player's graphics level is low.

## Touch controls

- Roblox provides a default thumbstick and jump button. Keep them unless you have a reason; players know them.
- Custom action buttons: use `ContextActionService:BindAction` with `createTouchButton = true` for quick prototypes, or custom UI buttons for full styling, or the newer Input Action System (input actions and bindings that map one action to keyboard, gamepad and touch). See [Controls and input](controls-and-input.md).
- Hold-to-repeat for repeated actions (holding the attack button keeps attacking) saves thumbs.
- Auto-run or auto-collect upgrades are much more valuable on phones than on PC.

## Testing on mobile

- **Device Simulator** in Studio for layouts at different phone and tablet sizes and orientations. It checks layout, not phone performance.
- **A real low-end Android phone** for performance, heat and memory. This is the device your worst-case players use.
- **Play the whole first session on a phone** before every major release, without a keyboard.
- **Check analytics by platform** after launch: retention, session length and conversion by device. A big gap between phone and PC numbers is a design or performance bug.

## For agents

- [ ] Core action playable with one thumb.
- [ ] Every PC keybind has a touch equivalent or is not required.
- [ ] No UI in the thumbstick zone or on the jump button; safe insets respected.
- [ ] Full first session played on a phone-sized simulator; screenshots attached.
- [ ] Platform split of D1 and session length reviewed after launch.

Related: [Controls and input](controls-and-input.md) · [Device performance](device-performance.md) · [HUD layout](../05-ui-and-hud/hud-layout.md) · [UI principles for Roblox](../05-ui-and-hud/ui-principles.md)
