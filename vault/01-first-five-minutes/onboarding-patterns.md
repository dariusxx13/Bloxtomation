---
title: Onboarding patterns
date: 2026-10-24
tags: [onboarding, ftue, ui, tutorial]
aliases: [Tutorial patterns, Teaching the player]
summary: A catalog of proven ways to teach Roblox players without walls of text, when to use each, and how to implement them.
audience: [human, agent]
---

# Onboarding patterns

Good onboarding does not feel like a tutorial. It feels like the game is pulling the player forward. This note lists the patterns that work on Roblox, ranked roughly from most to least effective for a young, mobile, multilingual audience.

## The principles behind every pattern

1. **Do, then explain.** Let the player do the thing, then name it. Never explain a system the player has not touched.
2. **One concept at a time.** Introduce a new mechanic only after the previous one has been used successfully at least once.
3. **Show, don't tell.** Icons, motion and world cues beat words. Assume the player will not read.
4. **Fail safely.** In the first minutes, mistakes should not cost progress.
5. **Reward learning.** Completing each onboarding step gives a small, visible reward.
6. **Get out of the way.** Once a player shows mastery, remove the guide.

## Pattern catalog

### 1. The guide beam (or path)

A glowing beam, trail or line of arrows from the player to the next objective.

- **Use for:** any "go here" step: the first resource, the shop, the next zone, the quest giver.
- **Build it with:** a `Beam` between an `Attachment` in the character's root part and one on the target, with a scrolling arrow texture. Update the target per step. On mobile, a beam reads better than an off-screen arrow.
- **Tips:** keep it bright and animated, hide it when the player is within a few studs of the target, and never show two beams at once.

### 2. The pulsing target

The object to interact with glows, bounces or pulses (a `Highlight` instance or a scaled `BillboardGui` icon above it).

- **Use for:** "click this", "hit this", "pick this up".
- **Tips:** pair with a hand or finger icon on touch devices. Use the same highlight color for "interact with me" everywhere in the game.

### 3. The forced first action

The player cannot do anything else until they do the core action once. The world is arranged so the obvious path leads straight into it (for example, spawning on a small island with one tree and an axe already equipped).

- **Use for:** the very first action only.
- **Risk:** feels restrictive if it lasts longer than 30-60 seconds.

### 4. Progressive UI reveal

HUD elements appear one by one as they become relevant, each with a small pop animation and sound: coins counter after the first coin, shop button after the first coin total that can buy something, rebirth button when rebirth is first possible.

- **Use for:** every game with more than three HUD buttons.
- **Why it works:** an empty HUD tells new players what matters now; each reveal is a mini-reward and a lesson.

### 5. The guided first purchase

When the player can first afford an upgrade, the shop button pulses, then opens with the recommended item highlighted. After purchase, the shop closes and the guide returns to the action.

- **Use for:** teaching where the shop is and that upgrades matter.
- **Tips:** the first purchase must be with soft currency, never Robux.

### 6. The NPC with a single line

An NPC with an icon above them who says one short line with a portrait. Dialog advances on tap and ends with an objective marker.

- **Use for:** story-driven games, quests, giving the world a face.
- **Rules:** one line per beat; no more than three beats before the player acts. Always include a skip.

### 7. The contextual tooltip

A small bubble that appears next to an element the first time it becomes relevant ("Tap to equip", "Drag to place"). Shown once, dismissed by doing the action.

- **Use for:** secondary mechanics introduced after the first loop.

### 8. The safe sandbox

A small first area where nothing can go wrong: no enemies, no other players' interference, fall damage off.

- **Use for:** PvP, horror, survival and steal games, where the full game would punish a confused newcomer.
- **Tips:** keep it to under two minutes, and make leaving it feel like an achievement ("Gate opened!").

### 9. Ghost demonstration

A translucent "ghost" player or animated hand demonstrates the gesture or move once (swipe to dash, hold to charge, drag to merge).

- **Use for:** non-obvious inputs, especially on touch.

### 10. Learning by failing (with a soft landing)

The first obstacle is designed to be failed once, then the hint appears ("Hold jump for a higher jump!"). Respawn is instant and nearby.

- **Use for:** obbies and skill games.
- **Rule:** the first failure costs nothing and the hint appears on the first failure, not the third.

## Patterns that usually hurt

| Pattern | Why it hurts | Better |
|---|---|---|
| Text-heavy tutorial panels | Unread, untranslated, blocks play | Icons, beams, single verbs |
| Unskippable cutscenes over 10 s | Players leave before the game starts | Show the story in the world, or let them skip after a second |
| Tutorial in a separate place | Teleport time plus bounce risk | Teach in the main world |
| Front-loading all systems | Overload | One system per loop iteration |
| "Read the rules" boards | Nobody reads them | Make the rules physical |
| Long walk to the action | Feels empty | Spawn at the action |
| Video tutorials | Heavy, ignored | Ghost demonstration |

## Onboarding by genre

| Genre | First action | First reward | First wow |
|---|---|---|---|
| Simulator | Click / swing at a resource | Currency fly-up | First egg with a guaranteed rare pet |
| Tycoon | Step on the first buy pad | Dropper starts producing | Base visibly grows into a building |
| Obby | Jump the first gap | Checkpoint flag and sound | Dramatic stage reveal |
| RNG / aura | Press Roll | First aura on the character | Early rare roll with server announcement |
| Steal and defend | Grab the nearest unguarded item | It appears on your base and earns | First successful steal from another base |
| Tower defense | Place the first tower | Enemy pops, money | First boss wave survived |
| Survival horror | Pick up a light source | Safe zone reached | First encounter with the threat, survived |
| Fighting | Press attack on a dummy | Combo counter and hit effects | Ultimate ability unlocked |
| Fishing | Cast | First catch with size reveal | First rare fish, shown in hand |

See the [genre playbooks](../14-genre-playbooks/INDEX.md) for full first sessions per genre.

## Implementation notes

- **State per step, saved.** Store the tutorial step in player data. Players who leave mid-tutorial should resume at their step, not restart. See [Data persistence](../13-building-it-right/data-persistence.md).
- **Server decides completion.** The server verifies each step was really completed (coins actually earned, item actually bought) before advancing and logging. Never trust a client "step done" message without checking state.
- **Instrument every step.** Log each step with `AnalyticsService:LogOnboardingFunnelStepEvent(player, step, name)` from the server. See [Measuring onboarding](measuring-onboarding.md).
- **One onboarding controller.** Keep tutorial logic in one module that listens to gameplay events ("CoinsEarned", "ItemBought") instead of sprinkling tutorial checks through gameplay code.
- **Configurable.** Put step parameters (reward amounts, which UI to reveal when) in config so they can be tuned and A/B tested without republishing. See [Experiments and configs](../12-live-ops-and-launch/experiments-and-configs.md).

## For agents

- [ ] Each onboarding step introduces one concept and ends with a reward.
- [ ] No step relies on reading more than five words.
- [ ] Every pointer (beam, highlight, arrow) disappears when the step completes.
- [ ] Tutorial state is saved and resumes correctly after rejoin.
- [ ] Returning players with completed tutorials see none of it.
- [ ] The server validates step completion against real game state.
- [ ] Tested by a "kid tester" pass: play the opening without reading anything and record where you got stuck.

Related: [First session blueprint](first-session-blueprint.md) · [First-session killers](first-session-killers.md) · [Measuring onboarding](measuring-onboarding.md) · [Feedback, popups and toasts](../05-ui-and-hud/feedback-popups-and-toasts.md)
