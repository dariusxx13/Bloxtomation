---
title: Accessibility and player settings
date: 2026-10-24
tags: [ui, accessibility, settings, text-size, reduced-motion, colour, audio]
aliases: [Accessibility, Player preferences, Reduced motion, Text size settings, Colour blindness]
summary: How to make Roblox games playable by more people - text size, contrast, colour and sound non-reliance, and Roblox's built-in player preferences (preferred transparency, preferred text size, reduced motion) with the exact properties to honour, plus volume buses, flashing and shake limits, input options and a review checklist.
audience: [human, agent]
---

# Accessibility and player settings

Roblox's accessibility guidance notes that over 26% of people have some type of disability and over 5% have some form of colour blindness (Fact, creator docs, accessed 2026-10-24). Accessible design also helps everyone else: players on small phones, in bright sunlight, with the sound off, or simply tired. Basics are in [UI principles](ui-principles.md); this note covers the specific settings Roblox exposes and how to honour them.

## The four principles (Fact, accessibility guidelines)

| Principle | Practice |
|---|---|
| **Text size** | Small text is hard to read; increase the size of small labels, especially on phones |
| **Colour contrast** | Avoid light-on-light and dark-on-dark; choose text and background colours with strong contrast |
| **Colour non-reliance** | Pair colour with symbols, shapes or labels (rarity frames with icons, teams with patterns) |
| **Sound non-reliance** | Every event signalled by sound also has a visual signal (a ringing phone also flashes an icon) |

## Built-in player preferences (Fact, accessibility guidelines)

Players can change these in Roblox's settings; games should respect them.

### Preferred transparency

- Setting: Background Transparency, exposed as `GuiService.PreferredTransparency` (1 = default, 0 = prefers fully opaque backgrounds).
- Recommended use: multiply each UI element's `BackgroundTransparency` by `PreferredTransparency`, and update when the property changes.

### Preferred text size

- Setting: Text Size, exposed as `GuiService.PreferredTextSize` (default Medium; players can choose larger sizes).
- Behaviours to know:
  - Text limited by a `UITextSizeConstraint` will not grow beyond its `MaxTextSize`.
  - Text with `TextScaled` enabled is **not** scaled by the preference.
  - Elements with `AutomaticSize` grow to fit larger text.
  - Wrapped text wraps onto more lines within the element's bounds.
  - `TextService:GetTextSize()` and `GetTextBoundsAsync()` honour the preference.
- Practice: for body text, prefer fixed text sizes with `AutomaticSize` containers over `TextScaled`, so the preference works; keep `TextScaled` for big decorative numbers.

### Reduced motion

- Setting: Reduce Motion, exposed as `GuiService.ReducedMotionEnabled`.
- Practice: when true, replace movement tweens with instant changes or fades (for example tween `GroupTransparency` on a `CanvasGroup` instead of sliding a panel in).
- Extend the same setting to camera shake, screen flashes and big zooms in gameplay ([VFX timing and choreography](../19-vfx/vfx-timing-and-choreography.md)).

### Sketch: honouring all three

```lua
--!strict
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local function openPanel(panel: CanvasGroup)
	panel.Visible = true
	if GuiService.ReducedMotionEnabled then
		panel.GroupTransparency = 1
		TweenService:Create(panel, TweenInfo.new(0.15), { GroupTransparency = 0 }):Play()
	else
		panel.Position = UDim2.fromScale(0.5, 1.2)
		TweenService:Create(panel, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
			Position = UDim2.fromScale(0.5, 0.5),
		}):Play()
	end
end

local function applyBackground(frame: GuiObject, defaultTransparency: number)
	frame.BackgroundTransparency = defaultTransparency * GuiService.PreferredTransparency
end
```

Re-apply backgrounds on `GuiService:GetPropertyChangedSignal("PreferredTransparency")`.

## Game settings to add

| Setting | Why |
|---|---|
| Volume per bus (music, effects, UI, voice) | Separate control helps players focus; the guidelines recommend volume controls per audio group ([Audio systems](../13-building-it-right/audio-systems.md)) |
| Screen shake and flashes (on, reduced, off) | Comfort and photosensitivity |
| Colour-blind friendly palette or patterns | For team colours, rarity and hazards |
| Hold versus toggle for held actions | Motor accessibility |
| Button size and position (touch) | Hands and devices differ ([Controls and input](../08-mobile-and-cross-platform/controls-and-input.md)) |
| Auto-run, auto-aim assist, auto-accelerate | Lower the skill floor where it is not the point of the game |
| Hide other players' effects and pets | Clutter and performance |
| Subtitles for voice lines and important sounds | Sound non-reliance |

The template's settings panel (`template/src/client/Controllers/SettingsPanel.luau`) is the place to add these.

## Effects and flashing

- Avoid large, fast, full-screen flashes; keep impact frames short and offer a reduced option ([Lighting and screen effects for VFX](../19-vfx/lighting-and-screen-effects.md)).
- Never rely on colour alone for danger zones; add shapes, outlines or patterns.
- Keep text away from busy effects; add backing panels.

## Review checklist

- [ ] All body text readable at phone size; contrast checked.
- [ ] Every colour-coded meaning also has a symbol or label.
- [ ] Every important sound has a visual equivalent.
- [ ] `PreferredTransparency`, `PreferredTextSize` and `ReducedMotionEnabled` are honoured in menus and HUD.
- [ ] Shake, flash and motion-heavy effects respect the reduced setting.
- [ ] Volume buses and comfort settings exist and save with the profile.

## For agents

- [ ] UI briefs state how each panel behaves with larger text and reduced motion.
- [ ] QA tests with Reduce Motion on, Text Size at the largest option and sound off, with screenshots.

Sources: [Accessibility guidelines](https://create.roblox.com/docs/production/publishing/accessibility) · [GuiService](https://create.roblox.com/docs/reference/engine/classes/GuiService)

Related: [UI principles](ui-principles.md) · [UI implementation](ui-implementation.md) · [Controls and input](../08-mobile-and-cross-platform/controls-and-input.md) · [Audio systems](../13-building-it-right/audio-systems.md) · [Lighting and screen effects for VFX](../19-vfx/lighting-and-screen-effects.md)
