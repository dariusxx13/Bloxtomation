---
title: Rebirth and prestige
date: 2026-10-24
tags: [progression, rebirth, prestige, retention]
aliases: [Rebirth, Prestige, Ascension]
summary: How reset-for-permanent-bonus systems work, when to introduce them, how to make the reset feel like a reward, and how to layer them over months.
audience: [human, agent]
---

# Rebirth and prestige

A rebirth (also prestige, ascension, reincarnation) lets a player trade their current progress for a permanent bonus. It is the main reason simulator and incremental players keep playing after they have "finished" the zones. Done well, it turns a finite game into an endless one.

## Why it works

- **It resets the fun part.** The fastest, most satisfying part of an exponential economy is the start. Rebirth lets players replay it, faster each time.
- **It converts a wall into a choice.** Instead of grinding against slowing upgrades, the player chooses to reset and come back stronger.
- **It gives status.** Rebirth counts are visible numbers to show off and rank on.
- **It is a long-term sink.** It consumes everything a player has, solving inflation for that player.

## When to introduce it

- **Not in the first 20 minutes.** Players must first understand what they are giving up.
- **Typically at minute 30-60** in the first session or early in the second, when the first slowdown arrives.
- Reveal the rebirth button when the player first *can* rebirth, with a guided explanation: what you lose, what you keep, what you gain.

## Designing the reset

Decide clearly what resets and what stays:

| Usually resets | Usually stays |
|---|---|
| Soft currency | Rebirth count and multiplier |
| Basic upgrades | Pets or collection (often) |
| Zone access (sometimes) | Premium currency |
| | Purchased passes and their effects |
| | Cosmetics, titles, badges |
| | Collection index |

House rule: **never reset things players paid Robux for**, and never reset collection progress. Resetting pets is possible in some designs, but it is the most painful reset; if you do it, the rebirth reward must clearly outweigh it.

## Making the reset feel like a reward

- **Preview the gain**: "Rebirth 4: +50% coins (total x3.0). You'll be back here in about 12 minutes."
- **Celebrate**: a big animation, sound, a new title, a visual change on the character (an aura that evolves with rebirth count).
- **Give a starter pack after rebirth** (some coins, an auto-unlock of the first zone) so the restart is instantly fast.
- **Unlock something only rebirthers can access**: a rebirth shop, new pets, a new zone, a new upgrade line.

## Rebirth layers

One rebirth layer eventually slows down too (see the math in [Economy math](economy-math.md)). Long-running games add layers:

1. **Rebirth**: resets coins and upgrades; gives coin multiplier and rebirth tokens.
2. **Super rebirth** (or ascension): resets rebirths; gives a bigger multiplier and a new currency.
3. **Ultra layer**: resets super rebirths; unlocks new worlds or systems.

Each layer should arrive roughly an order of magnitude later than the previous one and come with its own shop and visual identity.

## Rebirth quality-of-life

As rebirth counts climb, players need tools to avoid tedium:

- **Multi-rebirth**: rebirth several times at once when you have enough currency.
- **Auto-rebirth** (often an upgrade or pass): rebirths automatically when a threshold is reached.
- **Rebirth upgrades**: spend rebirth tokens on permanent quality-of-life (keep zone 2 unlocked, start with 10 upgrades).

## Monetization around rebirth (fair versions)

- A pass that gives extra rebirth tokens or a better multiplier per rebirth.
- A pass for auto-rebirth.
- Cosmetic rebirth auras.

Avoid selling a "skip rebirth" that makes the system meaningless, and never make the next rebirth require a purchase.

## Common mistakes

- **Rebirth too early.** Players lose progress they never got to enjoy.
- **Multiplier too small.** If rebirth 1 gives +10%, players feel cheated.
- **No information.** Players fear the button if they do not know what they lose.
- **Linear rebirth costs with exponential multipliers.** The economy breaks within weeks.
- **One layer forever.** Rebirth 200 takes days with no new goal.

## For agents

- [ ] What resets and what stays is listed and shown in the rebirth UI.
- [ ] First rebirth reachable at 30-60 minutes; regain-to-previous-point time is a quarter to a third of the original.
- [ ] Rebirth preview shows multiplier gain and estimated time to return.
- [ ] Paid items and the collection index never reset.
- [ ] Multi-rebirth and a second layer are planned before rebirth counts exceed about 50.

Related: [Economy math](economy-math.md) · [Progression architecture](progression-architecture.md) · [Simulator and incremental](../14-genre-playbooks/simulator-incremental.md) · [Endgame and long-term goals](../10-retention-and-social/endgame-and-long-term-goals.md)
