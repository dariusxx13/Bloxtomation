---
title: Core loop design
date: 2026-10-24
tags: [core-loop, design, systems]
aliases: [Core loop, Gameplay loop]
summary: How to design the loops a player repeats every few seconds, every few minutes and every session, with Roblox-specific loop shapes and tests.
audience: [human, agent]
---

# Core loop design

The core loop is what the player repeats. If the loop is fun, retention and monetization have something to build on. If it is not, no amount of daily rewards or shop polish will save the game.

## Three nested loops

Every successful Roblox game has three loops nested inside each other:

| Loop | Length | Question it answers | Example (simulator) |
|---|---|---|---|
| **Moment loop** | 1-10 seconds | "Is this action satisfying?" | Click, hit sound, coin pops out |
| **Session loop** | 1-15 minutes | "Am I getting stronger?" | Collect, sell, upgrade, unlock next zone |
| **Long loop** | days to weeks | "What am I building toward?" | Rebirth, collection index, season pass, leaderboard |

Design them in that order. A long loop on top of a boring moment loop is a chore list.

## The universal shape: act, earn, grow

Almost every Roblox hit uses this shape:

1. **Act**: a simple, repeatable action (hit, collect, steal, jump, catch, place, fight, roll).
2. **Earn**: the action produces a resource (currency, items, XP, pets, ingredients).
3. **Grow**: spending the resource makes the next action better (faster, bigger, rarer, safer) or opens new places to act.

The magic is in the **feedback between grow and act**: the upgrade must change how the action feels, not only a number in a menu. A faster swing, a bigger hitbox, a pet that collects for you, a base that visibly grows.

## Roblox loop shapes

The shapes below cover most of the platform. Many hits combine two.

### Accumulate and multiply (simulators, incrementals)

Act to earn; spend on multipliers; multipliers make each act worth more; reset (rebirth) for a permanent multiplier. Numbers grow exponentially. See [Simulator and incremental](../14-genre-playbooks/simulator-incremental.md).

### Build and collect (tycoons, bases, farms)

Buy a producer; it produces passively; collect; buy more producers; the base grows into something to show off. Idle production keeps paying while you play elsewhere in the game. See [Tycoon](../14-genre-playbooks/tycoon.md) and [Grow and farm](../14-genre-playbooks/grow-and-farm.md).

### Roll and collect (RNG, eggs, auras, gacha)

Spend a resource or time to roll; get a random outcome with a rarity; collect, equip, show off; boost luck; roll again. The emotion is anticipation. See [RNG and aura](../14-genre-playbooks/rng-and-aura.md).

### Steal and defend (raid loops)

Gather valuable things to your base where they earn over time; other players can steal them; you steal from others; protect with locks, timers or defenders. Social tension drives everything. See [Steal and defend](../14-genre-playbooks/steal-and-defend.md).

### Run and master (obbies, platformers, parkour)

Attempt a challenge; fail; learn; succeed; move to a harder stage. Progress is skill plus checkpoints. See [Obby and platformer](../14-genre-playbooks/obby-and-platformer.md).

### Fight and level (combat, battlegrounds, RPG)

Fight enemies or players; earn XP and loot; unlock abilities; fight harder enemies. Moment-to-moment feel is everything. See [Anime battlegrounds](../14-genre-playbooks/anime-battlegrounds.md).

### Survive and escape (horror, survival, 1-vs-all)

A round with a threat; gather, hide, cooperate or betray; survive to the end; earn meta-progression between rounds. See [Survival horror co-op](../14-genre-playbooks/survival-horror-coop.md).

### Express and socialize (roleplay, dress-up, hangout)

Customize, roleplay, show, hang out. The "loop" is social and creative; progression comes from unlocking more expression. See [Roleplay and life sim](../14-genre-playbooks/roleplay-life-sim.md).

## Designing the moment loop

The moment loop is judged in the first ten seconds and repeated thousands of times. Make it:

- **Instant**: the action responds on the same frame on the client (predict visually), while the server confirms the result.
- **Readable**: the player knows what they hit, what they got and how much.
- **Rich in feedback**: sound, particles, number popups, camera shake used sparingly, animation. See [Game feel and juice](game-feel-and-juice.md).
- **Varied**: small variation keeps it fresh: crits, combo multipliers, random bonus drops, occasional rare events.
- **Short**: one action, one result, under a second or two.

## Designing the session loop

- **Clear next goal.** Always show the next upgrade or unlock and its price. The player should never wonder what to do next.
- **Short gaps.** In the first session, the gap between meaningful upgrades should be roughly 30 seconds to 2 minutes, widening slowly as the session goes on.
- **Choice.** Offer two or three upgrade paths (speed, power, luck, capacity) so players feel smart about their build.
- **Milestones.** Every 5-15 minutes, something bigger: a new zone, a new tool tier, a boss, a rebirth. See [Progression architecture](../04-progression-and-economy/progression-architecture.md).
- **Natural break points.** End of a round, a full backpack, a finished crop: moments where leaving feels okay *and* coming back feels rewarded.

## Designing the long loop

- **Reset with a reward** (rebirth, prestige, seasons) so progress is never "done".
- **Collections** that take weeks to complete (pet index, fish book, aura list).
- **Social standing**: leaderboards, ranks, clans, visible rare items.
- **Scheduled novelty**: weekly updates and events give the long loop new destinations. See [Update cadence](../12-live-ops-and-launch/update-cadence.md).

## Tests for a core loop

Run these on a prototype before building content. A loop that fails two or more of them needs redesign, not more content.

1. **The 30-second test.** A first-time player, without help, performs the core action and understands the reward within 30 seconds.
2. **The 100th-time test.** After doing the action 100 times, is it still satisfying? If not, add variation, feedback or automation.
3. **The upgrade-feel test.** After the first upgrade, can the player *feel* the difference without looking at numbers?
4. **The friend test.** Is the loop more fun with a friend in the same server? Is there a reason to stand near other players?
5. **The "one more" test.** At the 10-minute mark, does the player have a goal that is 1-3 minutes away?
6. **The silent test.** With sound muted and the UI hidden, can a viewer still tell what is happening? (Shows whether the visuals carry the loop, which matters for clips.)
7. **The explain-in-one-sentence test.** "You ___ to get ___ so you can ___." If you cannot fill it in, neither can the player.

## Common mistakes

- **Two core actions at once.** Pick one. Add the second after the first is mastered.
- **Upgrades that only change numbers.** Make them visible.
- **A dead moment loop hidden by fast numbers.** Big numbers are not fun on their own. The action itself must feel good.
- **Grinding instead of growing.** If the player repeats the same action at the same speed for more than a few minutes without any upgrade, the loop is stalling.
- **Automating the fun away too early.** Auto-collect and auto-attack are great rewards, but if they arrive in minute 2, there is nothing left to do.

## For agents

When proposing or reviewing a core loop, write it as:

```
Moment loop:  <action> -> <immediate feedback> -> <resource>
Session loop: <resource> -> <upgrade or unlock> -> <how the action changes> (gap: <seconds>)
Long loop:    <reset or collection or social goal> -> <why tomorrow>
One sentence: You <verb> to get <reward> so you can <goal>.
Friend reason: <why it is better with others>
```

Then report the seven tests above as pass, fail or untested, with the evidence for each.

Related: [Game feel and juice](game-feel-and-juice.md) · [Session structure](session-structure.md) · [Progression architecture](../04-progression-and-economy/progression-architecture.md) · [The hit formula](../00-start-here/hit-formula.md) · [Genre playbooks](../14-genre-playbooks/INDEX.md)
