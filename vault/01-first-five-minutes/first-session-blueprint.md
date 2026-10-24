---
title: First session blueprint
date: 2026-10-24
tags: [onboarding, ftue, retention, first-session]
aliases: [FTUE blueprint, First five minutes]
summary: A second-by-second plan for a new player's first session, from load-in to the first return hook, with targets for each phase.
audience: [human, agent]
---

# First session blueprint

A new player decides in seconds whether to stay, and in minutes whether to come back. Roblox measures that decision directly: first-play bounce (leaving within roughly the first one to three minutes) is a top negative signal for Recommended for You, and D1 return days weigh heavily. This note is a timeline for the first session. Every phase has one job.

## The timeline

| Phase | Time | The player's question | Your job |
|---|---|---|---|
| 0. Load | 0-10 s | "Is this broken? Is it what the thumbnail showed?" | Load fast, show the promise immediately |
| 1. First action | 10-30 s | "What do I do?" | Make the core action obvious and do it once |
| 2. First reward | 30-90 s | "Was that worth it?" | Pay off the action with a visible, juicy reward |
| 3. First choice | 1-3 min | "What do I want?" | Let the player spend the reward on an upgrade they chose |
| 4. First loop | 3-5 min | "Can I do it again, better?" | Close the loop: act, earn, upgrade, act faster |
| 5. First goal | 5-15 min | "What am I working toward?" | Reveal a named goal reachable this session |
| 6. First wow | 5-20 min | "That was amazing." | Deliver a peak moment: rare drop, new zone, boss, big reveal |
| 7. Return hook | before leaving | "Why come back?" | Plant something that pays off tomorrow |

### Phase 0: Load (0-10 seconds)

- Spawn the player *where the action is*, facing it. Not in a lobby corridor, not behind a wall, not in a menu.
- The first frame should look like your thumbnail. A mismatch between promise and first frame is the fastest way to lose a click you paid for.
- Keep the loading screen short. Use `ReplicatedFirst` for a brief branded screen only if assets must load; remove it as soon as the character can move. Never put lore or rules on it.
- Avoid a main menu with a "Play" button for casual genres. Every extra click before play loses players. Competitive and round-based games may need a menu, but the default action ("Play" or "Quick match") should be big and pre-selected.
- The first frame on a cheap phone must not stutter. Stream the world, delay heavy effects, preload only what the first minute needs. See [Device performance](../08-mobile-and-cross-platform/device-performance.md).

### Phase 1: First action (10-30 seconds)

- Point at exactly one thing. Use a beam, an arrow, a glowing outline, a big pulsing button or an NPC with an exclamation mark. One pointer, not five.
- The action should take one input: tap, click, walk into, press E. If it needs a tool, equip it automatically.
- Use as few words as possible. Five words or fewer, with an icon. Many players are young or do not read English well, and Roblox auto-translation is imperfect on game text.
- Lock out distractions for the first action if needed: hide the shop button, the codes button and the rebirth button until the player has done the core action once. Reveal UI as it becomes relevant.

### Phase 2: First reward (30-90 seconds)

- The reward must be **visible** (a number flies to the counter), **audible** (a satisfying sound) and **bigger than it needs to be**. The first rewards should feel generous; you can tighten the economy later.
- Show the counter going up with animation, not a silent number change.
- If the game has a collection or random element, give a **guaranteed good result early**. The first egg hatches something rare-looking; the first fish is a decent size. Early luck hooks players; later odds can be honest and normal.

### Phase 3: First choice (1-3 minutes)

- The first reward should be enough to afford the first upgrade within one or two actions.
- Present 1-3 obvious choices, not a shop with 40 items. The best first upgrade should visibly change the next action: bigger tool, faster speed, more coins per hit.
- Let the player buy it themselves (guided), so they learn where the shop is. Close the shop for them after the purchase and point back at the action.

### Phase 4: First loop (3-5 minutes)

- The player repeats the action with the upgrade and *feels* the difference. If the upgrade does not change the feel, it is not a first upgrade.
- By the end of minute 5, the player should have completed the loop (act, earn, spend, act better) at least twice without help.
- Remove the tutorial pointers once the player has shown they understand. Re-show them only if the player is idle for 10-20 seconds.

### Phase 5: First goal (5-15 minutes)

- Name a goal the player can reach this session: "Unlock the Volcano zone", "Hatch a Legendary", "Reach 1,000 power", "Rebirth once".
- Show progress toward it on screen (a bar, a counter, a locked gate with a price on it).
- Rule of thumb from strong simulators and tycoons: the first named goal is reachable in **10-15 minutes** of play for a non-paying player. Shorter feels trivial; much longer and players leave before they get there.

### Phase 6: First wow (5-20 minutes)

- Plan one peak moment in the first session: a new zone with a dramatic reveal, a boss, a rare drop with a server-wide announcement, a giant transformation, an impossible-looking jump that works.
- This is the moment players remember and tell friends about. Put real art and VFX budget here. See [Clip moments and shareability](../02-core-loop/clip-moments-and-shareability.md).

### Phase 7: The return hook

Before the player leaves (you cannot know when, so plant it early):

- Show the daily reward and the streak ("Come back tomorrow for day 2: Rare Egg").
- Start something that finishes later: a crop growing, an egg incubating, a research timer. Make the payoff visible ("Ready in 8h").
- Show the next goal they did not reach, with their progress saved.
- Offer the group join or "like and favorite" reward once the player has had fun, not on spawn.

See [Retention systems](../10-retention-and-social/retention-systems.md).

## What to cut from the first session

- **Character creation.** Use the Roblox avatar. If your game needs a class or starter choice, offer it after the first action, with a sensible default.
- **Story exposition.** Show the story through the world. A one-line goal beats a paragraph.
- **Settings, codes, shop, trading, rebirth.** Hide or de-emphasize until relevant.
- **Choices that can be wrong.** No permanent decisions in the first five minutes.
- **Monetization pressure.** No purchase prompt that interrupts play in the first session. A visible shop button is fine; a popup "Buy the starter pack!" at minute 1 is not. See [Shop UX and contextual offers](../09-monetization/shop-ux-and-contextual-offers.md).

## Returning players are different

Returning players must skip the tutorial entirely. Save tutorial progress per step, and on rejoin, place returning players directly into the loop with a short "welcome back" (daily reward, offline earnings, what's new).

New players from ads, invites or referral links may deserve a tailored start (for example, the inviter's server, or a small "welcome" gift). Read `Player:GetJoinData()` for launch data. See [User acquisition](../12-live-ops-and-launch/user-acquisition.md).

## Targets (rules of thumb)

| Metric | Weak | Healthy | Strong |
|---|---|---|---|
| Onboarding step 1 completion (did the first action) | under 80% | 85-95% | 95%+ |
| Reached first upgrade | under 60% | 65-80% | 80%+ |
| Reached first named goal (first session) | under 25% | 30-50% | 50%+ |
| Median first-session length | under 5 min | 8-15 min | 20+ min |
| D1 retention (new users) | under 10% | 12-20% | 25%+ |

These are community benchmarks from shipped games, not Roblox-published numbers, and they vary by genre: obbies and horror games often have shorter, more intense sessions; simulators and tycoons longer ones. Compare against the benchmark games shown in your Creator Analytics, which are drawn from similar games.

## For agents

- [ ] The player can perform the core action within 30 seconds of spawning without reading.
- [ ] One pointer at a time; no more than five words per instruction.
- [ ] First reward is animated, audible and lands within 90 seconds.
- [ ] First upgrade affordable within 3 minutes and changes how the action feels.
- [ ] A named first goal is visible with progress, reachable in 10-15 minutes by a free player.
- [ ] At least one planned "wow" moment in the first 20 minutes.
- [ ] Return hook visible before minute 10.
- [ ] Every onboarding step is logged with `AnalyticsService:LogOnboardingFunnelStepEvent` on the server (see [Measuring onboarding](measuring-onboarding.md)).
- [ ] Returning players skip the tutorial.
- [ ] Tested at phone resolution in the Device Simulator.

Related: [Onboarding patterns](onboarding-patterns.md) · [First-session killers](first-session-killers.md) · [Measuring onboarding](measuring-onboarding.md) · [Core loop design](../02-core-loop/core-loop-design.md) · [Retention systems](../10-retention-and-social/retention-systems.md)
