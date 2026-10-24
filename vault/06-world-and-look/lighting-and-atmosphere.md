---
title: Lighting and atmosphere
date: 2026-10-24
tags: [lighting, atmosphere, post-processing, visuals]
aliases: [Lighting, Atmosphere, Post-processing]
summary: How to light a Roblox world for mood and readability using Lighting properties, Atmosphere, sky and post-processing, with per-genre starting points.
audience: [human, agent]
---

# Lighting and atmosphere

Lighting is the cheapest way to make a Roblox game look professional. The same blocky map can look like a cheap baseplate or a polished world depending on a dozen properties. It also changes mood instantly, which makes it a powerful tool for zones and events.

## The levers

| Object or property | What it controls | Typical use |
|---|---|---|
| `Lighting.Brightness` | Overall light intensity | Higher for sunny, cheerful worlds |
| `Lighting.Ambient` | Fill color everywhere (also indoors) | Tint shadows; keep subtle |
| `Lighting.OutdoorAmbient` | Fill color outdoors | Warm for sunset, cool for night |
| `Lighting.ExposureCompensation` | Camera exposure | Brighten or darken the whole image |
| `Lighting.EnvironmentDiffuseScale` / `EnvironmentSpecularScale` | How much the sky and environment light and reflect | Richer, more realistic materials |
| `Lighting.ClockTime` | Sun position | Golden hour (around 6-7 or 17-18) is flattering |
| `Lighting.GlobalShadows` | Sun shadows | Usually on; off for very stylized looks |
| `Atmosphere` | Haze, density, color, glare | Depth, distance fade, mood |
| `Sky` | Skybox images, sun and moon | Identity of a zone |
| `Clouds` | Dynamic clouds | Outdoor realism and weather |
| Post-processing: `ColorCorrectionEffect`, `BloomEffect`, `SunRaysEffect`, `DepthOfFieldEffect`, `BlurEffect` | Final image look | Color grading, glow on neon and VFX |
| Local lights: `PointLight`, `SpotLight`, `SurfaceLight` | Lamps, torches, glow | Guide the eye, mark interactables |

Roblox has been unifying its lighting technologies. Use the current Studio defaults as the base and tune the properties above rather than relying on legacy modes.

## Starting presets (tune per game)

These are starting points, not exact values. Adjust in a playtest on both a phone and a PC.

| Mood | Brightness | ClockTime | Atmosphere | Color correction | Bloom |
|---|---|---|---|---|---|
| Cheerful simulator | High (around 2-3) | Midday (12-14) | Light haze, low density | Saturation up slightly, contrast up slightly | Low, for shiny items |
| Golden adventure | Medium | Late afternoon (16.5-17.5) | Warm haze | Warm tint | Medium |
| Spooky (all ages) | Low | Night | Dense, colored (purple or green) haze | Desaturated, cool | Low; strong local lights |
| Horror (older) | Very low | Night | Dense, dark | Desaturated, high contrast | Minimal; flashlight carries the scene |
| Sci-fi / space | Medium | Custom sky | Thin | Cool tint | High on neon |
| Underwater / ocean | Medium | Midday | Dense blue-green | Blue tint | Low |

## Lighting for readability

- **Light the path.** Brighter light and warm local lights where the player should go; darker edges where they should not.
- **Light interactables.** A soft point light or a `Highlight` makes shops, eggs and gates pop.
- **Keep characters visible.** Never light a scene so dark that avatars become silhouettes, unless it is deliberate horror with a flashlight mechanic.
- **Contrast between zones.** Each zone gets its own lighting and atmosphere preset, applied when the player enters (tween the properties over 1-2 seconds for a smooth transition).

## Events and time of day

- A day/night cycle adds life and can drive gameplay (night-only fish, nocturnal enemies). Keep nights bright enough to play.
- Event lighting (Halloween purple, winter blue, a blood-red moon) is a cheap way to make an event feel big.
- Weather (rain particles, fog density, lightning flashes) creates server-wide moments. Flash effects must be brief and optional for motion sensitivity.

## Performance

- Every shadow-casting local light costs GPU. Use few shadow-casting lights; disable `Shadows` on decorative lights.
- Post-processing is relatively cheap, but stack only what you need.
- Neon material with bloom gives a glow look cheaply compared to many lights.
- Test on a low-end phone: lighting that looks great on PC may be washed out or too dark on a phone screen outdoors.

## For agents

- [ ] Each zone has a named lighting preset stored as data (properties and values), applied with a short tween on entry.
- [ ] The path to the next goal and all interactables are visually lit or highlighted.
- [ ] Avatars remain visible in every zone and at every time of day.
- [ ] Shadow-casting local lights are counted and kept low.
- [ ] Screenshots from phone and PC are compared before sign-off.

Related: [Art direction](art-direction.md) · [World and level design](world-and-level-design.md) · [VFX and particles](../07-characters-vfx-and-assets/vfx-and-particles.md) · [Build budgets](build-budgets.md)
