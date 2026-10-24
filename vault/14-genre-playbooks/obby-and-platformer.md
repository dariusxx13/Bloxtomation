---
title: Obby and platformer playbook
date: 2026-10-24
tags: [genre, obby, platformer, playbook]
aliases: [Obby, Obstacle course, Tower obby, Parkour]
summary: How to build obbies and platformers that keep players climbing: stage design, difficulty curves, checkpoints, skips, tower and runner variants, monetization and retention.
audience: [human, agent]
---

# Obby and platformer playbook

Obbies (obstacle courses) are the purest Roblox genre: jump, fail, retry, succeed. They are cheap to build, which makes the market huge and crowded. Winning obbies stand out through a theme, a twist mechanic, excellent level design and a reason to keep coming back.

Roblox genre: Obby & Platformer (subgenres Classic Obby, Runner, Tower Obby).

## Audience

Young players, very mobile-heavy. Short to medium sessions (8-20 minutes). High tolerance for failure if retries are instant.

## The loop

```
Moment:  jump -> land (or fall) -> instant respawn at checkpoint
Session: stage -> stage -> milestone stage (reward, new theme) -> ...
Long:    completion of the course, harder courses, speedruns, cosmetics, wins leaderboard
```

## Stage design rules

- **Teach, test, twist.** Introduce an obstacle safely, test it, then combine it with something else.
- **Difficulty curve**: easy first 5-10 stages (almost everyone succeeds), gentle rise, regular "breather" stages after hard ones, and milestone stages every 10 or so with a reward and a theme change.
- **Tune to the character**: default walk speed (16 studs/s) and jump height (around 7 studs) define what is possible. Test every jump on PC *and* phone; touch controls are less precise, so phone players need slightly more forgiving gaps.
- **Readable hazards**: kill parts in a consistent color (often red/neon) and shape; moving hazards with clear patterns.
- **No blind jumps**: the player should see where they are landing.
- **Checkpoints every stage** with instant respawn (no long death animations). The checkpoint saves on the server.
- **Fair failure**: a failure should feel like the player's mistake, never like a hitbox bug.

## Variants

| Variant | Twist | Notes |
|---|---|---|
| Classic stage obby | Numbered stages with themes | Stage counter and leaderboard |
| Tower obby | Climb up through floors; falling costs height | High tension; great clips |
| Runner | Auto-run, dodge obstacles | Very phone-friendly |
| Difficulty chart obby | Stages ranked by difficulty colors | Older players, skill bragging |
| Story obby | Narrative stages ("escape the ...") | Strong theme, character moments |
| Troll / joke obby | Fake platforms, surprises | Viral humor; must stay fair-ish |
| Mechanic obby | One unique mechanic (gravity flip, grappling, size change) | Best way to stand out |

## Monetization

- **Skip stage** (developer product, cheap): the genre's main product; players accept it.
- Speed or gravity coils (passes), trails and auras (cosmetic), VIP, revive-at-same-spot products for tower obbies.
- Never make stages so hard that skipping feels mandatory; skips should be convenience, not escape from unfair design.

## Retention

- Save progress per stage; returning players continue where they stopped.
- Daily reward, daily challenge course, rotating "stage of the day".
- Regular content: new stage packs weekly or biweekly.
- Win counters, completion badges, time leaderboards, harder modes after completion.

## Social

Racing friends, co-op stages that need two players, spectating, carrying newcomers, troll elements (pushing, within limits).

## Clip moments

Near misses, falling from the top of a tower obby, impossible jumps, troll surprises, completion celebrations.

## Traps

| Trap | Fix |
|---|---|
| Difficulty spike early | Playtest with new players; smooth the curve |
| Jumps impossible on phone | Test on touch; widen gaps' landing zones |
| Slow respawn | Instant respawn at checkpoint |
| Generic look | Strong theme per section; one unique mechanic |
| Progress lost | Save checkpoint on server each stage |
| Exploiters teleporting to the end | Server validates stage order and plausibility of time |

Related: [World and level design](../06-world-and-look/world-and-level-design.md) · [Mobile-first design](../08-mobile-and-cross-platform/mobile-first-design.md) · [Onboarding patterns](../01-first-five-minutes/onboarding-patterns.md) · [Clip moments and shareability](../02-core-loop/clip-moments-and-shareability.md)
