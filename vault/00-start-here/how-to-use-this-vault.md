---
title: How to use this vault
date: 2026-10-24
tags: [start-here, meta]
aliases: [Start here, Vault guide]
summary: What this vault is, how it is organized, how to read it as a human or an AI agent, and how to keep it true.
audience: [human, agent]
---

# How to use this vault

This vault is a working playbook for making Roblox games that people play, come back to, and pay for. It is written for two readers at once:

- **Humans** who design, build, publish and run Roblox games (solo devs, small studios, beginners with zero experience).
- **AI agents** (Claude Code or any other agent) that research, plan, build, test and improve Roblox games on a human's behalf.

Everything here is meant to be *used*: each note ends in rules, numbers, checklists or templates you can act on today. If a note does not change what you would build, it does not belong here.

## How it is organized

The folders follow the life of a game, from the first idea to live operations:

| Folder | Read it when |
|---|---|
| [00 Start here](INDEX.md) | Before anything else. Platform basics, the hit formula, rules for agents. |
| [01 First five minutes](../01-first-five-minutes/INDEX.md) | Designing or fixing onboarding. Most games die here. |
| [02 Core loop](../02-core-loop/INDEX.md) | Deciding what the player does every 10 seconds, minute and session. |
| [03 Rarity and RNG](../03-rarity-and-rng/INDEX.md) | Any game with drops, eggs, rolls, auras, crates, mutations. |
| [04 Progression and economy](../04-progression-and-economy/INDEX.md) | Currencies, upgrades, rebirths, pacing, trading. Includes the math. |
| [05 UI and HUD](../05-ui-and-hud/INDEX.md) | Any screen the player touches. |
| [06 World and look](../06-world-and-look/INDEX.md) | Art direction, maps, lighting, lobbies, build budgets. |
| [07 Characters, VFX and assets](../07-characters-vfx-and-assets/INDEX.md) | NPCs, pets, animation, effects, sound, the asset pipeline. |
| [08 Mobile and cross-platform](../08-mobile-and-cross-platform/INDEX.md) | Always. Most players are on phones. |
| [09 Monetization](../09-monetization/INDEX.md) | Passes, products, subscriptions, pricing, payouts, compliance. |
| [10 Retention and social](../10-retention-and-social/INDEX.md) | Daily reasons to return; playing with friends. |
| [11 Store page and discovery](../11-store-page-and-discovery/INDEX.md) | Icon, thumbnails, title, description, and how the algorithm decides. |
| [12 Live ops and launch](../12-live-ops-and-launch/INDEX.md) | Launch day, update cadence, events, A/B tests, ads. |
| [13 Building it right](../13-building-it-right/INDEX.md) | Code architecture, security, data, performance, testing, tooling. |
| [14 Genre playbooks](../14-genre-playbooks/INDEX.md) | Starting a game in a specific genre. |
| [15 Market research](../15-market-research/INDEX.md) | Choosing what to build next; reading the charts. |
| [16 AI studio operations](../16-ai-studio-operations/INDEX.md) | Running an AI agent team that builds Roblox games. |
| [17 Policy and business](../17-policy-and-business/INDEX.md) | Rules that get games removed, age ratings, IP, DevEx, teams. |
| [18 Templates and checklists](../18-templates-and-checklists/INDEX.md) | Copy-paste documents for pitches, GDDs, playtests, launches. |
| [19 VFX](../19-vfx/INDEX.md) | Building any visual effect, from a hit spark to an ultimate, within budget. |
| [20 Anime games](../20-anime-games/INDEX.md) | Making an anime-style game: sub-genres, gacha, IP, art, monetization, community. |
| [21 Hits and trends](../21-hits-and-trends/INDEX.md) | Choosing what to build: what went popular, why, and what the charts say now. |
| [99 Reference](../99-reference/INDEX.md) | Key numbers, API cheat sheet, glossary, sources. |

## Three ways to read it

1. **Start from zero.** Read [The Roblox platform in 2026](roblox-platform-2026.md), then [The hit formula](hit-formula.md), then the folders 01 to 04 in order. That is the minimum to design a game that can survive.
2. **Fix a live game.** Go to [Discovery algorithm](../11-store-page-and-discovery/discovery-algorithm.md) to learn which number matters, find the weak signal in your analytics, then jump to the folder that owns it (bounce rate lives in 01, playtime in 02 and 04, return days in 10, spend in 09).
3. **Pick a genre and go.** Open the [genre playbook](../14-genre-playbooks/INDEX.md), which links back to every system note the genre needs.

## How claims are labelled

The vault separates three kinds of statement. Agents must keep them separate too.

- **Platform fact.** Something Roblox documents or enforces: an API, a limit, a payout rate, a policy. These carry a link to the official source and a date. Platform facts change; check [Sources](../99-reference/sources.md) if a decision depends on one.
- **Rule of thumb.** A heuristic from shipped games and the developer community, such as "aim for the first reward inside 60 seconds". These are starting points, not laws. Your own analytics beat them.
- **House rule.** A choice this vault makes on purpose so that a team (or agent team) behaves consistently, such as "every remote goes through one Net module". House rules can be broken, but only with a written reason.

> [!IMPORTANT]
> Numbers in this vault are dated 2026-10-24. Payout rates, age-tier rules and discovery signals have all changed in the last 18 months. Before a decision that costs real money (ads, pricing, a launch date), re-check the linked official page.

## How notes are built

Every note has the same skeleton so it can be skimmed by people and parsed by agents:

- **Frontmatter**: `title`, `date`, `tags`, `summary`, `audience`.
- **The idea**: what it is and why it matters on Roblox specifically.
- **How to do it**: steps, numbers, examples.
- **Mistakes**: what goes wrong and how to spot it.
- **Checklist** or **For agents**: testable rules.
- **Related**: links to the notes it builds on.

## Keeping the vault true

- When a test, launch or update teaches you something, write it into the note it belongs to, with the date and the evidence (numbers, not feelings). One clear lesson beats ten vague ones.
- Do not promote a single result to a rule. A lesson needs to repeat across at least three games or three tests before it becomes a house rule. Until then, record it as an observation.
- Record failures with the same care as wins. A refuted idea saves the next game from repeating it.
- When Roblox changes a rule, update the note and [Key numbers](../99-reference/key-numbers.md) in the same edit.

Related: [For AI agents](for-ai-agents.md) · [The Roblox platform in 2026](roblox-platform-2026.md) · [The hit formula](hit-formula.md) · [Key numbers](../99-reference/key-numbers.md)
