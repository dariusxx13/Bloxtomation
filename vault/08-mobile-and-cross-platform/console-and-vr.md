---
title: Console and VR
date: 2026-10-24
tags: [console, vr, xbox, playstation, cross-platform]
aliases: [Console, Xbox, PlayStation, VR]
summary: What changes when a Roblox game runs on Xbox, PlayStation or VR headsets, and the minimum work to support them well.
audience: [human, agent]
---

# Console and VR

Consoles and VR are smaller audiences than phones and PC, but they are real and growing, and a game that works badly there gets bad reviews and wasted impressions. Decide deliberately whether to support each platform, then do it properly.

## Consoles (Xbox, PlayStation)

Console players sit far from a TV with a gamepad. Roblox publishes console development guidelines (platform facts, 2026), including:

- **TV-safe area**: some TVs do not show the edges of the image. Keep important UI inside a TV-safe margin.
- **Gamepad-only navigation**: every menu, shop and prompt must be usable with a controller (selection highlight, logical navigation order, B to back out).
- **No chat window**: disable the chat window for console players regardless of your chat customization, and use other ways to show important messages.
- **Readable at a distance**: larger text and icons than on PC.
- Video thumbnails are not supported on consoles (static thumbnails are).

### Design checklist for console

- [ ] UI within TV-safe margins; text readable from a couch.
- [ ] Every interaction reachable by gamepad, including shops, trading and settings.
- [ ] Prompts show controller buttons, not keyboard keys.
- [ ] Chat window disabled on console; important info shown through toasts or banners.
- [ ] Purchases tested with the console purchase flow.
- [ ] No feature depends on typing (codes may need an alternative or simply be optional).

## VR

VR players use headsets with motion controllers. Supporting VR well means rethinking the camera, movement comfort and UI.

- Avoid forced camera movement (shakes, cutscenes moving the view) that cause motion sickness.
- UI should be in world space or comfortably placed panels, not tiny screen corners.
- Interactions should work with pointing and grabbing.
- If you do not design for VR, consider disabling VR support in game settings rather than shipping a bad experience. Roblox also publishes VR guidelines worth reading before enabling it.

## Cross-platform fairness

- **PvP across inputs**: mouse aiming beats touch aiming. Consider aim assist for touch and gamepad, input-based matchmaking, or design combat that does not depend on precise aiming.
- **Same content everywhere**: purchases and progression are the same on every platform (Roblox subscription rules also require the same benefits regardless of where the subscription was purchased).

## Decide and declare

In your game settings, choose which devices are supported. Supporting everything by default without testing is the most common cause of one-star experiences on consoles and VR.

Related: [Controls and input](controls-and-input.md) · [Mobile-first design](mobile-first-design.md) · [HUD layout](../05-ui-and-hud/hud-layout.md)
