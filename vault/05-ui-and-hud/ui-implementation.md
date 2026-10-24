---
title: UI implementation
date: 2026-10-24
tags: [ui, engineering, luau, performance]
aliases: [Building UI, UI engineering]
summary: The Roblox UI building blocks and patterns that keep interfaces responsive, consistent and cheap: scale, constraints, layouts, styling, tweens, viewports and state.
audience: [human, agent]
---

# UI implementation

This note is the engineering side of the UI folder: how to build interfaces in Roblox that scale across devices, animate cleanly and stay maintainable.

## Sizing and positioning

- **Scale for layout, offset for details.** Size and position containers with scale (`UDim2.fromScale(0.3, 0.1)`) so they adapt to screen size. Use offset only for fixed details such as border thickness.
- **`AnchorPoint`** decides which point of an element its position refers to. Set `AnchorPoint = Vector2.new(0.5, 0.5)` for centered elements and `(1, 0)` for top-right elements so they stay put when resized.
- **`UIAspectRatioConstraint`** keeps squares square (item slots, icons) as the container scales.
- **`UISizeConstraint` and `UITextSizeConstraint`** cap sizes so elements do not become huge on big monitors or unreadably small on phones. Combine `TextScaled = true` with a text size constraint.
- **`UIPadding`** for inner spacing instead of nudging children by hand.
- **Safe areas**: `ScreenGui.ScreenInsets` controls whether a ScreenGui respects device safe areas or the core UI (top bar) area. Use the safe settings for interactive UI.

## Layouts

- **`UIListLayout`** for rows and columns (HUD stacks, tabs). With flex settings and `UIFlexItem`, children can grow, shrink and wrap, similar to CSS flexbox.
- **`UIGridLayout`** for item grids. Combine with `UIAspectRatioConstraint` on the cell template.
- **`UITableLayout`** and page layouts exist for specialized cases.
- **`ScrollingFrame`** with `AutomaticCanvasSize` so the scroll area grows with content.

Let layouts position children. Hand-positioned children break the moment content changes.

## Styling

Roblox has engine-level UI styling: `StyleSheet` instances hold `StyleRule`s with selectors (by class, name, tag, hierarchy) that override properties, plus **tokens** (variables such as a primary color) and **themes** (swappable token sets), applied to a ScreenGui tree through a `StyleLink`. Use tokens for colors, fonts, corner radius and stroke thickness. Benefits: consistent look, one-line restyles, event themes (swap a token set for Halloween).

If you do not use styling, at least keep a `Theme` module with color and font constants and never hard-code colors in individual UI files.

## Visual polish primitives

| Instance | Use |
|---|---|
| `UICorner` | Rounded corners |
| `UIStroke` | Outlines on frames and text (text readability over the world) |
| `UIGradient` | Gradients, animated shimmer (tween its `Offset` or `Rotation`) |
| `CanvasGroup` | Fade a whole panel with `GroupTransparency`; clip children to rounded corners |
| 9-slice images | Scalable panels and buttons from one image |
| `ImageLabel` with sprite sheets | Animated icons |

`CanvasGroup` renders to a texture: great for fades and rounded clipping, but do not nest many or use them on huge panels that change size often, and keep crisp body text outside them when possible.

## Animation

- Use `TweenService` for UI animation, never hand-written per-frame easing loops.
- Define a small animation vocabulary once (for example: fast 0.15 s quad, bouncy 0.3 s back, slow 0.5 s sine) and reuse it everywhere.
- Cancel the previous tween on an element before starting a new one on the same property, or rapid open and close will fight.
- Animate `Position`, `Size`, `GroupTransparency` and `UIScale.Scale`, not every child's transparency.
- Add a `UIScale` to buttons and tween it for press feedback (scale 0.95 on press, 1.05 on hover for mouse).

## 3D in UI: ViewportFrames

- Clone the model into a `ViewportFrame` with its own `Camera`; frame the model using its bounding box so any size fits.
- Animation inside a viewport needs a `WorldModel`, which costs more.
- Many viewports updating every frame is expensive. For big grids, use static icons and one shared viewport for the selected item.

## World UI

- `BillboardGui` for names, health bars and labels above things; set `MaxDistance` and avoid hundreds of always-on billboards.
- `SurfaceGui` for screens and signs on parts (shop boards, leaderboards in the lobby).
- `ProximityPrompt` for interactions; it adapts its prompt to keyboard, gamepad and touch.

## Architecture: UI renders state, it does not own it

- A client controller holds the player's replicated state (currencies, inventory, quests), updated by server messages.
- UI components subscribe to that state and render it. They never read raw game objects in the workspace to compute values, and never decide outcomes.
- Buttons send intents to the server through the Net layer ("BuyUpgrade", id) and show a loading state until the server answers.
- Pick one approach per screen: built in Studio (synced by Rojo as model files) for static layouts, or generated in code from templates for dynamic lists. Hybrids drift.
- Declarative UI libraries (for example React-Lua or Fusion through Wally) are good choices for complex UIs in Rojo projects; plain instances are fine for simple games.

See [Project architecture](../13-building-it-right/project-architecture.md).

## Performance

- Avoid updating UI every frame. Update on state change events.
- Do not rebuild whole lists on every change; update the changed cells.
- Cap simultaneous floating numbers and particles in UI.
- Large `ImageLabel` textures cost memory; use appropriately sized images and sprite sheets.
- Check UI memory and frame time with the MicroProfiler and the Developer Console on a low-end phone profile.

## For agents

- [ ] Containers sized with scale and constraints; no layout relies on pixel offsets.
- [ ] Interactive ScreenGuis respect safe insets.
- [ ] Colors and fonts come from styling tokens or a single theme module.
- [ ] All animation through `TweenService` using shared timing constants; tweens cancelled before restart.
- [ ] UI reads from client state and sends intents; no gameplay decisions in UI code.
- [ ] Device Simulator checks at small phone, large phone, tablet and desktop.

Related: [UI principles for Roblox](ui-principles.md) · [HUD layout](hud-layout.md) · [Menus, shops and inventories](menus-shops-inventories.md) · [Project architecture](../13-building-it-right/project-architecture.md) · [Performance optimization](../13-building-it-right/performance-optimization.md)
