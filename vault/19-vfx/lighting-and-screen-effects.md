---
title: Lighting and screen effects for VFX
date: 2026-10-24
tags: [vfx, lighting, post-processing, bloom, color-correction, screen-effects]
aliases: [Post-processing for VFX, Screen flashes, Bloom, Color grading]
summary: How lights, bloom, color correction, color grading, blur, depth of field and GUI overlays turn good effects into great ones, and how to use them per player without blinding anyone.
audience: [human, agent]
---

# Lighting and screen effects for VFX

Particles and meshes sit in the world. Lights and screen effects change **how the whole frame looks** for a moment: the flash of an explosion lighting up nearby walls, the world going grey during a time-stop, the screen pulsing red at low health. Used briefly, they make effects feel powerful. Used constantly, they make the game hard to play.

## Lighting style matters first (Fact, 2026-10-24)

The `Lighting` service now expresses artistic intent through `LightingStyle`:

- `Realistic`: the most advanced lighting and shadows Roblox renders. Glows, local lights and shadows from effects look physically plausible.
- `Soft`: a flatter, retro Roblox look with softer lights and shadows.

`PrioritizeLightingQuality` tells the renderer whether to keep lighting quality or view distance when it scales down on weaker devices. If your game's identity depends on glowing effects at night, prioritise lighting quality.

Effects should be tuned in the actual lighting style and time of day of each zone. An aura tuned on a bright daytime baseplate can vanish at dusk.

## Local lights as part of an effect

| Effect | Light | Settings (Rule of thumb) |
|---|---|---|
| Fireball | `PointLight` on the projectile | Warm color, range 10-16, brightness 2-4, shadows off |
| Explosion | `PointLight` at the center | Range 20-40, brightness spikes to 5+ then tweens to 0 in 0.3 s |
| Muzzle flash | `PointLight` | Range 8-12, on for 1-2 frames |
| Lightning strike | `PointLight` at target + brief `Lighting.ExposureCompensation` bump (one client) | Very short flicker, 2-3 pulses |
| Aura | `PointLight` on the character | Low brightness (0.5-1), small range, color of the aura; optional with a setting |
| Magic circle on the ground | `SpotLight` pointing down or `SurfaceLight` | Subtle, reveals the floor texture |

Shadows from effect lights are expensive and usually wrong (a fireball casting crisp shadows looks odd). Leave `Shadows` off unless the scene is built around it, like a horror flashlight.

## Post-processing toolkit

Post-processing effects placed in `Lighting` apply to everyone; placed in the `Camera` they apply to one player. **Effect flashes almost always belong in the camera** of the players who should feel them.

| Effect | Properties | VFX uses |
|---|---|---|
| `BloomEffect` | `Intensity`, `Size`, `Threshold` | Makes neon and bright particles glow. Keep a modest global bloom; spike it briefly for big moments |
| `ColorCorrectionEffect` | `Brightness`, `Contrast`, `Saturation`, `TintColor` | Flashes (brightness up for 2-3 frames), low-health red tint, freeze/time-stop (saturation to -1), impact frames (high contrast, no saturation) |
| `BlurEffect` | `Size` | Menu backgrounds, dizziness, brief radial-feel blur on heavy hits |
| `DepthOfFieldEffect` | `FarIntensity`, `NearIntensity`, `FocusDistance`, `InFocusRadius` | Cinematic focus on a reveal (a legendary pet on a pedestal), photo modes |
| `SunRaysEffect` | `Intensity`, `Spread` | Atmosphere, holy moments when the sun is behind a hero |
| `ColorGradingEffect` | `TonemapperPreset` (`Default` or `Retro`) | Whole-game look; `Retro` imitates pre-2019 Roblox colors |
| `Atmosphere` | `Density`, `Haze`, `Glare`, `Color`, `Decay`, `Offset` | Darken or redden the world during a boss phase or domain expansion |

### Screen effect recipes

| Moment | Recipe |
|---|---|
| Hit taken | Camera `ColorCorrectionEffect` TintColor toward red at 0.85 for 0.1 s, then back over 0.25 s; vignette frame pulse |
| Critical hit dealt | Brightness +0.3 for 2 frames, bloom intensity spike, tiny camera shake |
| Ultimate start | Saturation tween to -0.6 and contrast up over 0.2 s during the wind-up, snap back on release |
| Time stop | Saturation -1, slight blue tint, particles' `TimeScale` 0, animations paused, world sounds lowered |
| Impact frame (anime) | 2-4 frames: contrast very high, saturation -1, characters silhouetted with black `Highlight` fills, optional white GUI flash behind the UI layer; then snap back |
| Legendary hatch reveal | Background blur up, depth of field on the egg, bloom up, then confetti and color return |
| Low health | Slow pulsing red vignette (GUI image with transparent center), heartbeat sound |

## GUI overlays as screen effects

GUI renders on top of the 3D world, so it is perfect for:

- **Vignettes** (a full-screen image with a transparent center).
- **Speed lines** (radial streak images that fade in during dashes).
- **Flashes** (a full-screen white or colored frame tweening transparency 0.3 → 1).
- **Damage direction indicators** (arcs on the screen edge pointing toward the attacker).
- **Comic text** ("CRITICAL!", "PERFECT!") that pops with scale and rotation.

Use `ScreenGui` with `IgnoreGuiInset` for full-screen overlays, put overlays on a `DisplayOrder` below your HUD so information stays readable, and tween a `CanvasGroup`'s `GroupTransparency` to fade complex overlays as one.

## Comfort and accessibility

Screen effects can cause discomfort and, for some players, can trigger photosensitive reactions.

- Avoid rapid full-screen flashing (several bright flashes per second). Flash once, not strobe.
- Offer a **reduce effects / reduce motion** setting that disables screen shake, flashes, blur and large post-processing changes. The template's settings panel includes reduce motion (`template/src/client/Controllers/SettingsPanel.luau`).
- Never hide critical information (health, timers, telegraphs) behind blur or tint.
- Keep the camera's own effects on the camera of the player affected; do not flash the whole server because one player got hit.

## Performance notes

- Post-processing costs scale with screen resolution; on low-end devices the engine may reduce them. Effects must still work without them.
- Do not create and destroy post-processing instances per hit; keep one of each per client and tween their properties.
- Bloom with a low threshold makes the whole world glow and hides effects; keep the threshold high enough that only intended bright things bloom.

## For agents

- [ ] Effects tuned in each zone's real lighting and time of day.
- [ ] Effect lights have shadows off unless the design depends on them.
- [ ] Per-player flashes and tints live in the client's camera, created once and tweened.
- [ ] A reduce-effects setting disables shake, flashes and heavy post-processing.
- [ ] No strobing: at most one bright full-screen flash per moment.

Sources: [Global lighting](https://create.roblox.com/docs/environment/lighting) · [Post-processing effects](https://create.roblox.com/docs/environment/post-processing-effects) · [Light sources](https://create.roblox.com/docs/effects/light-sources) · [Atmosphere](https://create.roblox.com/docs/environment/atmosphere)

Related: [Lighting and atmosphere](../06-world-and-look/lighting-and-atmosphere.md) · [VFX timing and choreography](vfx-timing-and-choreography.md) · [Reward, UI and hatch VFX](reward-ui-and-hatch-vfx.md) · [Combat and anime VFX](combat-and-anime-vfx.md)
