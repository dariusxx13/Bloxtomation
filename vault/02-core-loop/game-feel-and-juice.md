---
title: Game feel and juice
date: 2026-10-24
tags: [core-loop, feedback, vfx, sound, polish]
aliases: [Juice, Feedback, Game feel]
summary: The feedback layers that make simple Roblox actions satisfying, how much to use, and how to build them without hurting performance.
audience: [human, agent]
---

# Game feel and juice

"Juice" is the extra feedback that makes an action feel good: the sound, the flash, the bounce, the number that flies across the screen. On Roblox, where the core actions are simple, juice is often the difference between a game that feels cheap and one that feels premium.

## The feedback stack

For any important action, layer feedback from cheap to expensive. Most actions need the first four; big moments use all of them.

| Layer | What it is | Example |
|---|---|---|
| 1. Sound | A short, crisp sound with slight pitch variation | Coin "ding" randomly pitched 0.9-1.1 |
| 2. Visual response on the target | The thing you hit reacts | Ore shakes and flashes white for 0.1 s |
| 3. Number or icon popup | What you got, flying toward where it goes | "+25" floats up and flies to the coin counter |
| 4. Counter animation | The total ticks up and bumps | Coin counter scales 1.0 to 1.15 and back |
| 5. Particles | Small burst at the impact point | Sparkles, dust, gems |
| 6. Character animation | The avatar does something expressive | Swing, flex, celebrate |
| 7. Camera | Short shake or FOV kick | Tiny shake on crit only |
| 8. Screen effect | Flash, vignette, color shift | White flash on legendary drop |
| 9. Slow motion or freeze frame | Time bends for a beat | 0.1 s hit-stop on a boss kill |
| 10. Social broadcast | Others see it | Server-wide "Player got a SECRET pet!" |

## Rules of thumb

- **Scale juice with importance.** A common pickup gets layers 1-4. A rare drop gets 1-8. A once-a-week event gets everything. If everything shakes, nothing feels special.
- **Vary repeated feedback.** Randomize pitch slightly (about ±10%), alternate two or three sound variants, and randomize particle direction. Identical repetition becomes noise.
- **Respond on the client instantly, confirm on the server.** Play the swing, sound and hit effect immediately on the client. The server decides the reward, and the client shows the number when the server confirms (usually within 100-200 ms, which still feels instant). Never let the client decide the reward amount.
- **Make numbers readable.** Big, bold, outlined text (`UIStroke`), short format (1.2K, 3.4M, 5.6B), color-coded by type (gold for coins, blue for gems, purple for rare). See [Feedback, popups and toasts](../05-ui-and-hud/feedback-popups-and-toasts.md).
- **Anticipation before payoff.** For anything random or valuable, add a short build-up: shake, glow, rising pitch, drumroll. 1-3 seconds for an egg; longer only for very rare results. See [Reveal and hatch design](../03-rarity-and-rng/reveal-and-hatch-design.md).
- **Respect motion sensitivity.** Camera shake and flashes should be small, short and optional (a settings toggle). Never flash rapidly.
- **Mute-proof it.** Many players play with sound off. Every important event must also be visible.

## Juice for common Roblox actions

| Action | Minimum feedback | Upgrade path |
|---|---|---|
| Collecting currency | Sound, popup flying to counter, counter bump | Combo multiplier text, particle trail |
| Hitting a resource node | Node shake + flash, sound, particles | Crit hits with bigger text and color |
| Buying an upgrade | Purchase sound, button press animation, stat increase shown | Character visibly changes, confetti |
| Leveling up | Banner, sound, particles around character | Aura burst visible to others |
| Hatching or rolling | Shake, glow by rarity, reveal sound, card | Rarity-specific music sting, server announcement |
| Getting hit | Red flash on character, damage number, sound | Knockback, screen edge vignette |
| Defeating an enemy | Pop, loot burst, XP number | Slow motion on boss, camera pull-back |
| Completing a stage | Checkpoint sound, flag animation | Fireworks, stage counter |
| Stealing an item | Pickup animation, alert sound for the victim | Chase music, server message |

## Building juice without hurting performance

Juice is mostly cheap if you build it right. Common traps:

- **Creating and destroying instances every hit.** Pool popups and particle emitters: keep a few instances and reuse them. Use `ParticleEmitter:Emit(n)` on an existing emitter instead of creating new ones.
- **Tweens on hundreds of objects.** Cap simultaneous popups (for example, 10-20 on screen; merge extra numbers into the newest popup).
- **Sounds piling up.** Limit concurrent instances of the same sound; reuse `Sound` objects; keep files short.
- **Server-side effects.** Effects are visual and belong on the client. The server sends one small event ("player X hit node Y for 25") and each client plays the effect locally. Do not replicate particles from the server.
- **Effects for distant players.** Skip or simplify effects that happen far from the local camera.

See [VFX and particles](../07-characters-vfx-and-assets/vfx-and-particles.md) and [Performance optimization](../13-building-it-right/performance-optimization.md).

## The juice pass

Before calling a feature done, run a juice pass:

1. Do the action 20 times with sound on, then 20 times muted. Does it still read?
2. Does each layer of the stack exist for this action's importance level?
3. Is anything too loud, too long or too flashy for how often it happens?
4. Is the rarest outcome dramatically more exciting than the common one?
5. Check performance in the MicroProfiler while spamming the action on a low-end device profile.

## For agents

- [ ] Every core action has at least layers 1-4 of the feedback stack.
- [ ] Rare outcomes have strictly more feedback than common ones.
- [ ] Visual feedback is client-side; rewards are server-decided.
- [ ] Popups and emitters are pooled; simultaneous popups are capped.
- [ ] Camera shake and flashes respect a settings toggle.
- [ ] The action reads correctly with sound muted.

Related: [Core loop design](core-loop-design.md) · [Feedback, popups and toasts](../05-ui-and-hud/feedback-popups-and-toasts.md) · [VFX and particles](../07-characters-vfx-and-assets/vfx-and-particles.md) · [Audio and music](../07-characters-vfx-and-assets/audio-and-music.md)
