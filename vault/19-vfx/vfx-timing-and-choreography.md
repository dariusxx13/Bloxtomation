---
title: VFX timing and choreography
date: 2026-10-24
tags: [vfx, timing, game-feel, hitstop, camera-shake, animation]
aliases: [Effect timing, Hitstop, Hit pause, Impact frames, Camera shake, Anticipation]
summary: The timing that makes effects feel powerful - anticipation, impact, follow-through, hitstop, impact frames, camera shake, sound sync and animation events - with frame counts at 60 fps and how to implement each on Roblox.
audience: [human, agent]
---

# VFX timing and choreography

Two effects can use identical particles and meshes and feel completely different because of **timing**. Power comes from contrast: a held breath before the release, a frozen instant at contact, a long tail afterwards. This note gives the timing vocabulary and how to implement it on Roblox.

At 60 frames per second, one frame is about **16.7 ms**. Players feel differences of two or three frames.

## The three beats

Every satisfying effect has three phases.

| Phase | Purpose | Typical length | What happens |
|---|---|---|---|
| **Anticipation** | Tells the player something is coming; builds tension | 0.1-0.6 s (longer for ultimates) | Charge particles converging, glow building, a pose, sound rising, screen slightly desaturating |
| **Impact** | The moment of payoff | 1-6 frames of peak, plus a hitstop | Flash, burst, shockwave, loudest sound, camera kick |
| **Follow-through** | Lets the moment land and shows consequences | 0.3-1.5 s | Smoke, embers, debris settling, damage numbers, slow fade |

Common mistakes are skipping anticipation (the hit feels random), making impact long (it feels floaty), and cutting follow-through (it feels cheap).

## Frame-count cheat sheet (Rule of thumb, 60 fps)

| Element | Frames | Seconds |
|---|---|---|
| Hit flash on the victim | 2-4 | 0.03-0.07 |
| Hitstop, light attack | 2-4 | 0.03-0.07 |
| Hitstop, heavy attack | 5-10 | 0.08-0.17 |
| Hitstop, finisher or critical | 10-18 | 0.17-0.3 |
| Impact frame (black and white silhouette) | 2-4 | 0.03-0.07 |
| Screen flash | 1-3 at peak, fade over 6-15 | up to 0.25 |
| Camera kick on a hit | 3-6 | 0.05-0.1 |
| Camera shake on an explosion | 12-30 | 0.2-0.5 |
| Damage number pop | scale in over 4, hold 20, fade 15 | about 0.65 |
| Rare reward reveal anticipation | 60-180 | 1-3 |

## Hitstop (hit pause)

Hitstop briefly freezes the attacker and the victim at the moment of contact. It is the single most effective "this hit was heavy" tool in action games.

How to do it on Roblox, on the client of each player watching:

1. Pause the relevant animation tracks with `AnimationTrack:AdjustSpeed(0)`, then restore their previous speed after the hitstop.
2. Freeze impact particles with `ParticleEmitter.TimeScale = 0` (0 freezes, 1 is normal), then restore.
3. Optionally hold the camera still or apply a tiny kick.
4. Keep sound playing: the impact sound should start at the frame of contact, not after the pause.

Rules:

- Scale hitstop with damage or move tier. If every hit freezes 0.2 s, combat feels sluggish.
- Hitstop is **cosmetic and client-side**. The server's combat timing must not depend on it, or a laggy client would change the fight.
- Do not freeze the local player's movement input for longer than the attacker's own animation already does; players hate losing control.

## Impact frames

Anime fights often flash one or more frames of high-contrast, inverted or silhouetted art at the moment of a big hit. On Roblox a convincing impact frame is:

1. A camera `ColorCorrectionEffect` with saturation -1 and very high contrast (or a strong tint).
2. Black `Highlight` fills (fill transparency 0, outline off, `AlwaysOnTop`) on the attacker and victim so they read as silhouettes.
3. Optionally a radial "speed lines" GUI image or a white flash frame.
4. Hold for 2-4 frames, then restore everything in a single frame (a hard cut, not a fade).

Use impact frames for finishers and ultimates only. Players should feel them as special.

## Camera shake

Camera shake communicates force and proximity.

- **Implement it as an offset applied after the camera updates**, not by replacing the camera's CFrame logic. Bind a function with `RunService:BindToRenderStep` at a priority just after `Enum.RenderPriority.Camera.Value` and multiply the camera's CFrame by a small rotation or offset. This layers on top of the default camera and custom camera scripts.
- Use **noise-based** shake (smooth random motion that decays), not frame-by-frame random jumps, which look like glitches.
- Shake strength falls off with distance from the source; players far away feel a tremor, players near it feel a jolt.
- Separate **kick** (one quick directional nudge toward the hit direction, 3-6 frames) from **shake** (sustained decay, 0.2-0.5 s).
- Respect the reduce-motion setting: disable shake entirely when it is on.

Community modules exist for layered camera effects (shakes, impacts, overlays) and for classic decaying shake; if you use one, record its license and keep it client-only.

## Sync with animation: use events, not waits

Effects must line up with the animation that triggers them. Chains of `task.wait(0.23)` drift as soon as an animation is retimed or the frame rate dips.

- Place **animation events (markers)** in the animation at the exact frames that matter: `"Windup"`, `"Hit"`, `"Release"`, `"Recover"`.
- Listen with `AnimationTrack:GetMarkerReachedSignal("Hit")` and spawn the effect there.
- Every client playing the attacker's animation fires the same markers locally, so the effect appears in sync for everyone even when the attacker lags.

Battlegrounds-style games commonly do this: the server validates the move and tells every client to play it; each client plays the animation on the attacker and spawns visuals and sounds from the animation's markers. See [VFX architecture and replication](vfx-architecture-and-replication.md).

## Sound is half the timing

- The impact sound starts on the impact frame. A sound even 100 ms late breaks the illusion more than a missing particle.
- Layer sounds like effects: a sharp transient (the crack), a body (the boom) and a tail (debris, reverb).
- Duck other audio slightly on huge moments.
- Vary pitch by a few percent so repeated hits do not machine-gun the same sample.

See [Audio and music](../07-characters-vfx-and-assets/audio-and-music.md).

## Escalation across tiers

Players should be able to rank events by power from the effects alone.

| Tier | Example | Anticipation | Impact | Follow-through | Extras |
|---|---|---|---|---|---|
| 1 | Basic punch, common drop | none or 0.05 s | small burst | 0.2 s | none |
| 2 | Skill, rare drop | 0.15 s | burst + mesh | 0.4 s | small light |
| 3 | Heavy skill, epic drop | 0.3 s | layers + shake | 0.8 s | hitstop, bloom spike |
| 4 | Ultimate, legendary drop | 0.6-1.5 s | full stack | 1.5 s | impact frame, color shift, server announcement |
| 5 | Secret / mythic | 2-3 s | full stack, unique | 2-3 s | unique music sting, global announcement |

The same table drives hatch reveals: see [Reveal and hatch design](../03-rarity-and-rng/reveal-and-hatch-design.md).

## For agents

- [ ] Every important effect has anticipation, impact and follow-through.
- [ ] Effects are triggered from animation markers, not timed waits.
- [ ] Hitstop and impact frames are client-side and scaled by move tier.
- [ ] Camera shake is noise-based, distance-scaled, layered after the camera, and off with reduce motion.
- [ ] Impact sounds start on the impact frame.

Sources: [AnimationTrack:GetMarkerReachedSignal](https://create.roblox.com/docs/reference/engine/classes/AnimationTrack) · [RunService:BindToRenderStep](https://create.roblox.com/docs/reference/engine/classes/RunService) · [ParticleEmitter.TimeScale](https://create.roblox.com/docs/reference/engine/classes/ParticleEmitter)

Related: [Game feel and juice](../02-core-loop/game-feel-and-juice.md) · [Combat and anime VFX](combat-and-anime-vfx.md) · [Lighting and screen effects for VFX](lighting-and-screen-effects.md) · [Animation](../07-characters-vfx-and-assets/animation.md)
