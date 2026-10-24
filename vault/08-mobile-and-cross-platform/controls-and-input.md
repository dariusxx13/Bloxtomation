---
title: Controls and input
date: 2026-10-24
tags: [input, controls, mobile, console, pc]
aliases: [Input, Controls, Keybinds]
summary: How to design and implement controls that work on touch, keyboard and mouse, and gamepad, using Roblox's input systems.
audience: [human, agent]
---

# Controls and input

A Roblox game must work with at least three input types: touch, keyboard and mouse, and gamepad (consoles and controllers on PC). Design one set of *actions* and map them to each input, rather than designing three control schemes.

## Design actions, not keys

List the game's actions first:

| Action | Touch | Keyboard / mouse | Gamepad |
|---|---|---|---|
| Move | Thumbstick | WASD | Left stick |
| Jump | Jump button | Space | A |
| Core action (attack, collect) | Big right-side button or tap on target | Left click | Right trigger or X |
| Ability 1-3 | Buttons around jump | Q, E, R or 1-3 | Bumpers, Y, B |
| Interact | Proximity prompt button | E (prompt default) | Prompt default |
| Open menu | HUD button | Hotkey (for example M, or a letter matching the menu) | D-pad or a menu button |

Rules:

- **Keep the action count low.** Each extra action is another button on a crowded phone screen. Three abilities plus the core action is usually the maximum for casual games.
- **The same action always uses the same input** across the game.
- **Show the right prompt per device**: keyboard key icons on PC, button icons on gamepad, touch buttons on mobile. Detect the last input type used and update prompts live.

## Roblox input systems

- **Input Action System (IAS)**: Roblox's newer approach. You define input actions and bind them to keys, gamepad buttons and touch, grouped in input contexts that can be enabled and disabled (for example, "combat" vs "menu"). Roblox's server authority model requires player scripts to use it (`Workspace.PlayerScriptsUseInputActionSystem`), so prefer it for new competitive projects.
- **`ContextActionService`**: bind a function to several inputs at once, optionally creating a touch button. Mature and widely used; good for many existing games.
- **`UserInputService`**: raw input events and device detection (`TouchEnabled`, `KeyboardEnabled`, `GamepadEnabled`, `GetLastInputType`). Use it for detection and special cases, not as the main action layer.
- **`ProximityPrompt`**: contextual interactions with built-in support for keyboard, gamepad and touch, hold durations and custom styles.
- **`GuiService`** and selection APIs for gamepad navigation of menus.

## Camera

- Default third-person camera is fine for most games.
- First-person or shoulder cameras suit shooters and horror; provide sensitivity settings.
- Avoid camera behaviors that fight touch rotation (auto-rotation that snaps back while the player swipes).
- Lock the camera during cutscenes and reveals, then restore the player's camera settings.

## Responsiveness

- **Client-side prediction for feel**: play the action animation and effect immediately on input, send the intent to the server, and correct if the server rejects.
- **Input buffering**: accept the next action slightly before the current one ends.
- **Debounce on the server**, not just the client: the server enforces cooldowns, whatever the client sends.

## Gamepad specifics

- Every menu is navigable with a gamepad: sensible selection order, visible selection highlight, B to close.
- Triggers and bumpers for frequent actions; face buttons for abilities.
- Test with a controller on PC; consoles add requirements (see [Console and VR](console-and-vr.md)).

## Accessibility

- Rebindable keys on PC when the game has many actions.
- Toggle instead of hold options for sprint, aim and charge.
- Auto-attack or assist options for players with limited dexterity in casual games.

## For agents

- [ ] Action table defined with touch, keyboard/mouse and gamepad mappings.
- [ ] Prompts update to the last used input type.
- [ ] Actions bound through IAS or `ContextActionService`, not scattered raw input handlers.
- [ ] Server enforces cooldowns for every action.
- [ ] Every menu navigable by gamepad.

Related: [Mobile-first design](mobile-first-design.md) · [Console and VR](console-and-vr.md) · [HUD layout](../05-ui-and-hud/hud-layout.md) · [Networking and remotes](../13-building-it-right/networking-and-remotes.md)
