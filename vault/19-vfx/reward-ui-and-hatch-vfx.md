---
title: Reward, UI and hatch VFX
date: 2026-10-24
tags: [vfx, ui, rewards, hatching, rarity, game-feel]
aliases: [UI effects, Reward effects, Hatch effects, Rarity effects, Shine effects]
summary: Effects that make rewards feel valuable - currency pickups, level-ups, rarity reveals, shop and button feedback - built from GUI tools (UIGradient, CanvasGroup, rotating rays, ViewportFrames) and world effects, scaled by rarity.
audience: [human, agent]
---

# Reward, UI and hatch VFX

Simulators, RNG games and collection games live on reward moments. A coin pickup happens thousands of times per session; a mythic pet appears once a month. Both need effects, sized to their importance. This note covers effects drawn in the interface and the world effects that accompany them.

## The reward ladder

| Reward | Frequency | Effect |
|---|---|---|
| Currency tick (per hit) | Every second | Number pop near the source, tiny sparkle, soft sound; counter count-up in the HUD |
| Currency burst (node breaks, chest) | Every 10-60 s | Coins fly from the source toward the HUD counter, counter bounces |
| Upgrade bought | Every few minutes | Button pop, stat panel flash, short rising sound |
| Level-up / rebirth | Every 10-60 min | Full-screen banner, character burst (rising light pillar), confetti, unique sound |
| Rare item | Hourly to daily | Reveal sequence with anticipation and rarity color |
| Legendary+ item | Daily to rarely | Reveal + server-wide announcement + lingering aura or trail on the character for a few seconds |

## Coins that fly to the counter

One of the most satisfying micro-effects in the genre:

1. Convert the world position to the screen with `Camera:WorldToViewportPoint`.
2. Spawn a few coin images (`ImageLabel`) at that screen point in a top-level `ScreenGui`.
3. Tween each toward the currency counter's absolute position with slight random arcs and staggered start times (20-40 ms apart).
4. When each arrives, bump the counter (scale pop) and play a soft tick with rising pitch.
5. Count the number up with a tween rather than snapping to the new value.

Cap the number of flying coins (for example 5-8) regardless of the amount gained; show the amount as text instead.

## GUI effect tools

| Tool | Effect |
|---|---|
| `UIGradient` | Animated shine sweeps (tween `Offset` across a button), rarity gradients on frames, holographic text |
| `UIStroke` | Glowing outlines on rare item cards; tween thickness for a pulse |
| `CanvasGroup` | Fade a whole card or panel as one with `GroupTransparency`; clip shines to rounded corners |
| Rotating ray image | A star-burst image behind a reward, slowly rotating, scaling in on reveal |
| `ViewportFrame` | Show the 3D pet or item spinning on the card |
| `UIScale` | Pops and bounces on press and reveal |
| Image sequences | Hand-drawn 2D sparkle animations by swapping `ImageRectOffset` on a sprite sheet |

**Shine sweep recipe:** put a `UIGradient` with a narrow bright band (transparency 1 → 0.4 → 1) on the card; tween `Offset` from (-1, 0) to (1, 0) over 0.6 s every 2-3 s for rare items. It reads instantly as "valuable".

**Rotating rays recipe:** a square image of soft rays behind the item, `Rotation` tweened continuously (one turn every 8-12 s), color of the rarity, transparency 0.4. Add a second copy rotating the other way, smaller and fainter.

## Hatch and reveal sequences

The template's reveal (`template/src/client/Controllers/Hatch.luau` in this repository) follows this structure, which you can extend:

1. **Anticipation:** the egg or box wobbles with increasing intensity; for higher rarities, the wobble lasts longer and the background dims. Sound pitch rises with each wobble.
2. **Rarity hint (optional):** a glow color appears before the reveal. Hinting is exciting but can feel bad on commons; many games hint only at rare and above.
3. **Burst:** flash, the egg shatters (fragments as images or meshes), confetti in the rarity color.
4. **Reveal:** the item card scales in with an overshoot ease; name, rarity text and a "NEW!" tag if first discovery.
5. **Celebration scaled by rarity:** rotating rays, shine sweep, bloom spike, server announcement for top tiers.
6. **Skip and fast mode:** let players skip or speed up the animation after they have seen it a few times; auto-hatch modes need a compact reveal.

The rule from [Reveal and hatch design](../03-rarity-and-rng/reveal-and-hatch-design.md) applies: the reveal must never lie. The result is decided on the server before the animation starts, and the animation shows exactly that result.

## Rarity color language

Use the same color per tier everywhere: card borders, text, particles, beams, auras and announcements. The template's tiers run Common (grey), Uncommon (green), Rare (blue), Epic (purple), Legendary (gold), Mythic (red/pink), Secret (black with special treatment). Higher tiers add:

- motion (shine, rotation, pulsing),
- light (glow, bloom),
- sound (unique stingers),
- audience (server and global announcements).

## World effects that accompany rewards

- **Pickup sparkles:** a small burst at the collected object, a short rising sound.
- **Level-up pillar:** a cylinder mesh of light rising from the character, rising motes, a ring at the feet.
- **Rare drop beam:** a vertical beam of the rarity color marking a dropped item from far away (common in looter and fishing games).
- **Celebration confetti:** client-side confetti around the local player for big moments; nearby players see a smaller version.

## Performance in the UI

- Animate with `TweenService`, not `RenderStepped` loops, for most UI effects.
- Many `ViewportFrame`s are expensive; show 3D previews only for the selected or newest items and use static icons for grids.
- Destroy or recycle flying images when the animation ends.
- Respect reduce motion: skip shakes and long reveals, keep the information.

## For agents

- [ ] Every reward has an effect proportional to its frequency and value.
- [ ] Flying-coin and similar effects are capped regardless of the amount.
- [ ] Reveal animations show a result already decided and saved on the server.
- [ ] Rarity colors are consistent across UI, world effects and announcements.
- [ ] Reveal sequences offer skip or fast mode after the first few times.

Related: [Reveal and hatch design](../03-rarity-and-rng/reveal-and-hatch-design.md) · [Feedback, popups and toasts](../05-ui-and-hud/feedback-popups-and-toasts.md) · [VFX timing and choreography](vfx-timing-and-choreography.md) · [Rarity tiers and odds](../03-rarity-and-rng/rarity-tiers-and-odds.md)
