---
title: Animation systems
date: 2026-10-24
tags: [engineering, animation, animator, markers, ik, animation-graph, adaptive-animation, replication]
aliases: [Animator, AnimationTrack, Animation markers, Animation Graph Editor, IKControl, Adaptive Animation]
summary: The engineering side of animation on Roblox - Animator and AnimationController, loading and playing tracks, priorities and per-joint blending, weights and speed, markers that sync hits and effects, replication rules, the Animation Graph Editor with blend trees and state machines, IKControl, Adaptive Animation for custom rigs, and rules for animation under server authority.
audience: [human, agent]
---

# Animation systems

Animation is where game feel, combat timing and effects meet. [Animation](../07-characters-vfx-and-assets/animation.md) covers what to animate and how to publish it; this note covers how animation works in code and the newer tools. Timing for effects is in [VFX timing and choreography](../19-vfx/vfx-timing-and-choreography.md).

## The building blocks (Fact, creator docs, accessed 2026-10-24)

| Object | Role |
|---|---|
| `Animation` | Holds an `AnimationId` pointing to an uploaded animation asset |
| `Animator` | Loads and plays animations; lives under a `Humanoid` or an `AnimationController` |
| `AnimationController` | Replaces `Humanoid` for rigs without one (creatures, props, vehicles) |
| `AnimationTrack` | A loaded animation you can play, stop, speed up, weight and listen to |
| `Motor6D` / `Bone` | The joints animations move |

To play: make sure the rig has an `Animator`, create an `Animation` with the id, call `Animator:LoadAnimation(animation)` to get a track, then `track:Play()`. Animations must be owned by the game's owner (user or group) to play in the game ([Animation](../07-characters-vfx-and-assets/animation.md)).

## Priorities and blending

Tracks are evaluated per joint from high to low priority: `Action4`, `Action3`, `Action2`, `Action`, `Movement`, `Idle`, `Core`. Higher priorities override lower ones on the joints they animate; tracks with the same priority blend in proportion to their weights, and once the total weight on a joint reaches 1.0, lower priorities are not evaluated for that joint. Core is for default character animations; Idle and Movement are recommended for idle and locomotion; Action levels for gameplay actions.

Practical rules:

- Locomotion at `Movement`, idles at `Idle`, attacks and emotes at `Action`, overlays such as a held weapon pose at `Action2`, hit reactions and stuns at `Action3` or `Action4` so they interrupt attacks.
- Only animate the joints an animation needs. An upper-body attack that leaves leg keyframes empty lets locomotion continue underneath.
- Use `fadeTime` in `Play(fadeTime, weight, speed)` and `Stop(fadeTime)` for smooth transitions (about 0.1 s for combat, 0.2-0.3 s for idles).
- `AdjustSpeed` scales playback; `AdjustWeight` blends; `TimePosition` jumps within the track.

## Markers: syncing gameplay to animation

Animation events (markers) named in the Animation Editor fire through `AnimationTrack:GetMarkerReachedSignal(name)`, with an optional parameter string. Use them for:

- The **hit frame** of an attack: the moment the hitbox query runs ([Combat systems and hitboxes](combat-systems-and-hitboxes.md)).
- **Effect beats**: slash trail on, impact spark, footstep dust ([VFX architecture and replication](../19-vfx/vfx-architecture-and-replication.md)).
- **Sound beats**: whooshes and footsteps.
- **State changes**: "cancel window opens", "recovery ends".

Name markers consistently across all moves (for example `Hit`, `TrailOn`, `TrailOff`, `CancelOpen`, `End`) so systems can rely on them. Put the marker names in the build brief for the animator.

**Do not trust markers on the server for timing-critical decisions alone.** The server should know each move's hit time from move data as well, so a client cannot fire the hit early.

## Replication

- Animations played on a player's own character through its `Animator` replicate to other players automatically.
- Animations on server-owned NPCs played by the server replicate to clients.
- Purely cosmetic animations (UI rigs, viewport models, pets rendered client-side) are played on the client and stay local.
- Track **events** (markers) fire where the track plays. If the server needs to react, it should use its own timing, not wait for a client's marker.

## Loading and caching

- Preload important animations (for example with `ContentProvider:PreloadAsync`) during loading to avoid a first-play hitch.
- Load each animation once per animator and reuse the track in the classic model.
- Clean up tracks and connections when characters are removed ([Performance optimization](performance-optimization.md)).

### Under the server authority model

Rollback can invalidate cached tracks. The server authority docs advise **not** caching `AnimationTrack` objects across frames and mirroring animation logic on client and server inside simulation callbacks ([Combat systems and hitboxes](combat-systems-and-hitboxes.md)).

## The Animation Graph Editor (Fact, creator docs)

A visual, node-based tool (Avatar tab, Graph Editor) for building animation logic without hand-written blending code:

- **Clip nodes** play animations; **Add** nodes layer an additive animation over a base; **Blend** nodes (for example a 1D blend driven by `Speed`) mix clips by a parameter.
- **Graph parameters** (numbers, booleans) are set from gameplay code to drive blends and transitions.
- **State machines** group nodes into named states (for example Locomotion, Fall, LandIdle) with transitions that fire on an expression (such as `not Grounded`) or when a clip finishes, with blend lengths and curves.
- Clips can play once and hold their final pose (useful for fall and land).
- Reference places from Roblox demonstrate a full jump, fall, land and run graph.

When to use it: locomotion sets, characters with many movement states, and teams where animators should own transitions. Keep combat moves (which need markers and server timing) as explicit tracks or clearly separated graph states.

## Inverse kinematics (Fact, creator docs)

`IKControl` procedurally poses part of a rig at runtime. Required properties: `Type` (for example Position or Transform), `EndEffector` (the part or bone that reaches), `Target` (anything with a world position) and `ChainRoot` (where the affected chain starts). Uses:

- Feet planted on slopes and stairs.
- Hands reaching for doors, levers or a held object.
- Heads looking at targets (NPCs watching the player, shopkeepers turning to customers).

IK runs on top of animations; keep weights modest and test on slopes and stairs.

## Adaptive Animation for custom rigs (Fact, creator docs)

The Adaptive Animation system lets custom characters with different proportions play standard animations and emotes:

- Import a rigged character with the 3D Importer as a **Custom** rig.
- Use **Avatar > Adaptive Animation** to create a `HumanoidRigDescription` (and `DigitsRigDescription` for hands).
- Map at least the **15 standard joints** to the rig's joints and set a T-pose reference.
- The character can then play any R15 animation, or animations published from rigs with a rig description.

This matters for anime and stylised games with custom proportions ([Anime art, UI and style](../20-anime-games/anime-art-ui-and-style.md)): one animation library can serve many character shapes.

## Procedural and code-driven motion

- Simple bobbing, spinning and swaying: tween or update `Motor6D.Transform` or CFrames on the client.
- Camera-driven effects (recoil, sway): client-only.
- Ragdolls: replace `Motor6D`s with `BallSocketConstraint`s temporarily, with ownership handled as in [Physics and network ownership](physics-and-network-ownership.md).

## Animation in briefs

Every animation brief lists: rig type, moves with durations, priorities, required markers (names and frames), looping or not, blend expectations, and the ownership group for publishing. QA checks markers fire in game and that priority conflicts do not freeze joints.

## For agents

- [ ] Every combat or effect-synced animation has named markers listed in the brief.
- [ ] Priorities follow the table (locomotion Movement, actions Action, reactions higher).
- [ ] The server uses move data for hit timing, not client markers alone.
- [ ] Tracks are preloaded and cleaned up; under server authority they are not cached across frames.
- [ ] Custom rigs use Adaptive Animation so the shared animation library works.

Sources: [Use animations](https://create.roblox.com/docs/animation/using) · [Animation events](https://create.roblox.com/docs/animation/events) · [AnimationPriority](https://create.roblox.com/docs/reference/engine/enums/AnimationPriority) · [Animation Graph Editor](https://create.roblox.com/docs/animation/graph-editor) · [Graph Editor state machines](https://create.roblox.com/docs/animation/graph-editor-state-machine) · [Inverse kinematics](https://create.roblox.com/docs/animation/inverse-kinematics) · [Adaptive Animation](https://create.roblox.com/docs/characters/adaptive-animation) · [Server authority techniques](https://create.roblox.com/docs/projects/server-authority/techniques)

Related: [Animation](../07-characters-vfx-and-assets/animation.md) · [Combat systems and hitboxes](combat-systems-and-hitboxes.md) · [VFX timing and choreography](../19-vfx/vfx-timing-and-choreography.md) · [Characters, NPCs and pets](../07-characters-vfx-and-assets/characters-npcs-and-pets.md) · [NPC AI and pathfinding](npc-ai-and-pathfinding.md)
