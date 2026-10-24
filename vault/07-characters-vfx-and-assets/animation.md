---
title: Animation
date: 2026-10-24
tags: [animation, characters, game-feel]
aliases: [Animations, Animator]
summary: How to plan, create, own and play animations on Roblox so actions feel good and nothing breaks at publish time.
audience: [human, agent]
---

# Animation

Animation turns a moving block into a character. On Roblox it is also a common source of last-minute bugs: animations that only play for their owner, animations that are not uploaded to the right group, and animations that fight each other.

## What to animate first

Priority order for a new game:

1. **The core action** (swing, cast, punch, collect, throw). Played thousands of times; must feel great.
2. **Reactions** (hit, stagger, death, celebrate). These make feedback readable.
3. **Locomotion overrides** only if the default Roblox animations do not fit the game (most games keep the player's own animation pack).
4. **NPC idles and attacks**.
5. **Emotes and celebrations** (social and show-off value).

## Rules for action animations

- **Anticipation, action, recovery.** A short wind-up (a few frames), a fast strike, and a recovery. The hit should land at a defined point, where the game plays the impact effect (use animation events or markers).
- **Readable from behind and at a distance.** Exaggerate poses; Roblox cameras usually see the character from behind and above.
- **Short.** Core actions under about 0.5 seconds so repeated use does not feel sluggish. Use animation speed to scale with upgrades ("attack speed").
- **Cancel windows.** Let players cancel recovery into movement or another action, so controls feel responsive.

## Ownership and publishing (common trap)

Platform facts that cause real bugs:

- Animation assets must be owned by the game owner (the user or the group that owns the experience) to play in that game. Animations uploaded by a team member's personal account will not play in a group-owned game. Upload animations to the group that owns the game.
- Use the Animation Editor or an external tool (for example Blender) to create animations, then publish them as assets.
- Keep a list of every animation id the game uses in one config module, so ownership can be audited and ids swapped in one place.

## Playing animations

- Load animations with the `Animator` inside the `Humanoid` or `AnimationController` (`animator:LoadAnimation(animation)`), and cache the loaded tracks; do not reload every time.
- Set `AnimationPriority` correctly (Idle < Movement < Action) so actions override walking.
- For the local player's character, play animations on the client: they replicate automatically through the `Animator`. Play NPC animations from the server or locally per client (for many NPCs, client-side playback based on state reduces network traffic).
- Use `AnimationTrack:GetMarkerReachedSignal("Hit")` to sync effects and hit detection timing with the animation.

## Procedural animation

Cheap tricks that add life without animators:

- Bobbing and rotation on pets and pickups (a sine wave on the CFrame offset).
- `TweenService` squash and stretch on objects being hit.
- Inverse kinematics (`IKControl`) for feet on slopes, heads looking at targets, hands reaching objects.
- Springs (smoothed follow) for cameras, pets and UI.

## Avatar animation packs

Players can own avatar animation packs (custom walk, run, jump). Respect them unless your game has a strong reason (a stylized monster, a specific movement system). If you override, override consistently and with quality.

Note that eligibility for the US 18+ DevEx rate requires animation packs on player characters to be R15, not R6.

## For agents

- [ ] Core action animation has anticipation, strike and recovery, with a "Hit" marker used for effects and hit timing.
- [ ] All animations uploaded to the game owner (user or group); ids centralized in one config.
- [ ] Animation priorities set; tracks cached.
- [ ] Action animations under about 0.5 s, scalable with speed upgrades.
- [ ] Tested on R15 avatars of different scales and with custom animation packs.

Related: [Characters, NPCs and pets](characters-npcs-and-pets.md) · [Game feel and juice](../02-core-loop/game-feel-and-juice.md) · [VFX and particles](vfx-and-particles.md) · [Asset pipeline](asset-pipeline.md)
