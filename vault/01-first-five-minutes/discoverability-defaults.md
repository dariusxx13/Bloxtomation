---
title: Discoverability defaults
date: 2026-10-24
tags: [onboarding, discoverability, prompts, labels, signage, feedback, ux]
aliases: [Make everything findable, Interaction defaults, Signposting, World labels]
summary: A default kit that makes every game world self-explanatory - proximity prompts on everything interactable, floating labels on key objects, a short welcome card, signs at spawns and zone entrances, a rotating tips bar, instant pickup feedback and a guide arrow - with the official prompt and billboard properties to set, budgets, and a review checklist.
audience: [human, agent]
---

# Discoverability defaults

New players leave when they cannot see what to do. Many games already have the right systems but hide them: a shop with no sign, a door you must guess how to open, a reward with no feedback. These defaults make every world explain itself. The idea was adapted from the "make everything discoverable" checklist in a community AI bridge the studio reviewed, rewritten and extended here ([AI tooling landscape](../22-references/ai-tooling-landscape.md)). Teaching patterns are in [Onboarding patterns](onboarding-patterns.md); timing in [First session blueprint](first-session-blueprint.md).

## The default kit

| Default | Where | Purpose |
|---|---|---|
| **Proximity prompts** | Every interactable object (doors, shops, NPCs, machines, chests, seats) | Shows what you can do and which key or button does it |
| **Floating labels** | Key objects and destinations (shop, eggs, portals, quest givers) | Names things from a distance |
| **Welcome card** | First join | One sentence goal and one next step |
| **Spawn sign** | Next to spawn, facing the camera | What this place is and where to go first |
| **Zone entrance signs** | Each zone or area boundary | Name, level or price requirement, what is inside |
| **Tips bar** | A small rotating line on the HUD | Hints for systems players have not used yet |
| **Pickup and reward feedback** | Every gain | Sound, pop, number, and where it went |
| **Guide arrow or path** | Until the first goal is done | Points to the next objective ([Onboarding patterns](onboarding-patterns.md)) |

The template's `Guide` and `Interact` controllers and `Onboarding` system already implement the guide and interaction patterns; use them rather than building new ones.

## Proximity prompts (Fact, creator docs, accessed 2026-10-24)

`ProximityPrompt` objects are parented to the part, model or attachment the player interacts with. They show the input for keyboard, gamepad and touch automatically.

| Property | Default practice |
|---|---|
| `ObjectText` | The thing: "Egg", "Shop", "Door" |
| `ActionText` | The verb: "Hatch", "Open", "Talk" |
| `KeyboardKeyCode`, `GamepadKeyCode` | Leave defaults (E and the gamepad's face button) unless the game needs more than one action |
| `MaxActivationDistance` | 8-12 studs for most objects; larger for big machines |
| `RequiresLineOfSight` | Default true: prompts only show when the camera can see the object |
| `HoldDuration` | 0 for quick actions; 0.5-1 s for actions with consequences (buying, opening a rare chest) |
| `Exclusivity` | Default behaviour shows one prompt per key; adjust when prompts cluster |
| `ClickablePrompt` | On, so mouse and touch players can tap the prompt itself |

Handle `Triggered` on the **server** for anything that changes state (with validation), and on the client only for purely local UI ([Networking and remotes](../13-building-it-right/networking-and-remotes.md)).

## Floating labels

Use `BillboardGui` with a `TextLabel`:

- Short text (one or two words) with a strong outline; an icon when possible.
- `MaxDistance` set so labels disappear when far away (for example 60-120 studs), keeping the screen clean and the GPU happy.
- `AlwaysOnTop` only for objectives; other labels should be hidden by walls.
- Size with `Scale` so labels stay readable at distance, and test on a phone ([UI implementation](../05-ui-and-hud/ui-implementation.md)).
- Budget: a few dozen visible billboards at most; hundreds of always-on billboards cost performance.

## Welcome card

- One sentence: "Hatch pets, grow your power, unlock new worlds."
- One button: "Let's go" (closes the card and starts the guide).
- Shown once per account (saved), skippable, never blocking for more than a few seconds.
- No walls of text, no lore dump ([First-session killers](first-session-killers.md)).

## Signs and zone labels

- Spawn sign facing the spawn camera angle.
- Zone entrances: name, requirement ("Rebirth 2" or a price), and a preview of what is inside.
- In-world signs use the same font and colours as the HUD for a consistent visual language ([Art direction](../06-world-and-look/art-direction.md)).

## Tips bar

- One line, bottom or top of the HUD, rotating every 10-15 seconds.
- Shows tips for systems the player has **not** used yet (the data system knows), not generic advice.
- Hidden during combat, cutscenes and reveals; closable in settings.

## Pickup and reward feedback

Every gain needs:

1. A sound (with slight pitch variation).
2. A visual pop at the source.
3. A number ("+25").
4. A trail or fly-to animation into the counter that grew ([Reward, UI and hatch VFX](../19-vfx/reward-ui-and-hatch-vfx.md)).

If players cannot tell where a reward went, they do not understand the economy.

## Review checklist

Walk the map as a new player, on a phone, with sound off, and check:

- [ ] Everything interactable shows a prompt with an object and a verb.
- [ ] The first goal is visible from spawn or pointed to by the guide.
- [ ] Every zone entrance says what it is and what it needs.
- [ ] Every reward has sound, pop, number and destination.
- [ ] The welcome card is one sentence and one button.
- [ ] Labels fade with distance; the screen is not cluttered.

This walk is part of the newcomer playtest (PROTO-03) and the first-session review ([Measuring onboarding](measuring-onboarding.md)).

## For agents

- [ ] Every brief that adds an interactable object lists its prompt texts and hold duration.
- [ ] Billboards have a `MaxDistance` and a budget.
- [ ] Tips are driven by systems the player has not used yet.
- [ ] The checklist above is run in Studio play mode with a screenshot per item in the handoff.

Sources: [Proximity prompts](https://create.roblox.com/docs/ui/proximity-prompts) · [ProximityPrompt](https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt) · [BillboardGui](https://create.roblox.com/docs/reference/engine/classes/BillboardGui) · Adapted from the discoverability checklist in [Bbasche/roblox-ai](https://github.com/Bbasche/roblox-ai) (reviewed 2026-10-24; rewritten in the studio's own words).

Related: [Onboarding patterns](onboarding-patterns.md) · [First session blueprint](first-session-blueprint.md) · [HUD layout](../05-ui-and-hud/hud-layout.md) · [Feedback, popups and toasts](../05-ui-and-hud/feedback-popups-and-toasts.md) · [Game feel and juice](../02-core-loop/game-feel-and-juice.md)
