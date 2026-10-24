---
title: FAQ for new developers
date: 2026-10-24
tags: [reference, faq, beginners, questions]
aliases: [Frequently asked questions, Beginner questions, Common questions]
summary: Short, direct answers to the questions new Roblox developers and new studio members ask most - what to build, how long it takes, how games get found, how money works, how to stay safe and legal, how to work with AI agents - each linking to the note with the full answer.
audience: [human, agent]
---

# FAQ for new developers

Short answers with links to the full explanation. Facts are dated 2026-10-24; check the linked notes for sources.

## Choosing what to build

**What genre should I make?**
One whose content you can produce every week, with a loop you can explain in one sentence, in a format that is not saturated right now. Use [Anatomy of a Roblox hit](../21-hits-and-trends/anatomy-of-a-hit.md), the [October 2026 chart snapshot](../21-hits-and-trends/chart-snapshot-2026-10.md) and [Trend waves](../21-hits-and-trends/trend-waves.md).

**Should I copy what is trending?**
No. Follow a trend only with a twist that changes how the game plays, and only if you can ship before the wave saturates. Roblox's discovery does not prioritise look-alikes ([Trend lifecycle](../15-market-research/trend-lifecycle.md)).

**Can I make a game based on my favourite anime, show or brand?**
Not without a license. Use an original world in the same style, or request a license through Roblox's Licenses catalog (a decision for the game's owner) ([Anime IP and legal](../20-anime-games/anime-ip-and-legal.md)).

**Where do game ideas come from?**
From combining a proven loop with a fresh theme, verb or social twist. See the [Game concepts bank](../15-market-research/game-concepts-bank.md) for worked examples.

## Building

**How long does a game take?**
A simple loop can be prototyped in days; a launch-ready game with enough content for weekly updates usually takes weeks to months. The real cost is the live operation after launch ([Building an original anime game](../20-anime-games/building-an-original-anime-game.md) has a content-floor table that applies to any genre).

**Do I need to know how to code?**
To make a serious game, someone on the team does. The template, the API cookbook and the agent team reduce how much ([Learning paths](learning-paths.md), [API cookbook](api-cookbook.md)).

**Rojo or Studio scripting?**
This studio edits code on disk with Rojo and strict Luau, with a quality gate; Studio is for building, testing and playtesting ([Tooling and CI](../13-building-it-right/tooling-and-ci.md)).

**Why is my code being rejected in review?**
Usually one of the classic mistakes: client-trusted rewards, deprecated APIs, scripts inside parts, missing data saving ([Common Luau mistakes](../13-building-it-right/common-luau-mistakes.md)).

**How do I stop exploiters?**
The server decides everything that matters, validates every remote and rate-limits it, and checks movement plausibility. Competitive games can use the server authority model ([Security and anti-exploit](../13-building-it-right/security-and-anti-exploit.md), [Combat systems and hitboxes](../13-building-it-right/combat-systems-and-hitboxes.md)).

**How do I make sure players never lose data?**
Session-locked profiles, `UpdateAsync`, autosave, `BindToClose`, retries, and purchases granted only in `ProcessReceipt` ([Data persistence](../13-building-it-right/data-persistence.md)).

**My game lags on phones. Where do I start?**
Measure on a real low-end Android device with the MicroProfiler and Scene Analysis before changing anything ([Parallel Luau and profiling](../13-building-it-right/parallel-luau-and-profiling.md)).

## Getting players

**How do players find games?**
Mostly through Roblox's recommendations, which reward games whose organically acquired players keep playing and come back over days and weeks; search, sorts, friends, short videos and Moments add more ([Discovery algorithm](../11-store-page-and-discovery/discovery-algorithm.md), [Platform shifts 2025-2026](../21-hits-and-trends/platform-shifts-2025-2026.md)).

**Why can't younger players find my game?**
New games launch to age-checked 16+ players first and must pass an evaluation (engaged plays and a safety review) to reach Roblox Kids and Select ([Age ratings and audience](../17-policy-and-business/age-ratings-and-audience.md)).

**Do ads help my ranking?**
Ads bring players, but their engagement does not count toward Recommended For You ranking signals; organic retention must stand on its own ([User acquisition](../12-live-ops-and-launch/user-acquisition.md)).

**Can I put my Discord link in the game?**
No. Social links live on the game's detail page and are shown only to users verified as 16 or older ([Viral and social mechanics](../21-hits-and-trends/viral-and-social-mechanics.md)).

**What makes players come back tomorrow?**
Timers, daily goals, streaks, weekly events, friends and visible new content ([Retention systems](../10-retention-and-social/retention-systems.md), [Live events and admin events](../21-hits-and-trends/live-events-and-admin-events.md)).

## Money

**How do games earn?**
Passes, developer products, subscriptions, avatar items, engagement-based payouts and ads; creators convert earned Robux through DevEx ([Platform payouts](../09-monetization/platform-payouts.md), [Key numbers](../99-reference/key-numbers.md)).

**Is it OK to sell random rewards (eggs, crates, rerolls)?**
Only with all outcomes and odds shown before purchase, probability modifiers explained, and `PolicyService` treatments for restricted players. Policy answers are the owner's decision ([Anime units, gacha and traits](../20-anime-games/anime-units-gacha-and-traits.md), [Monetization compliance](../09-monetization/monetization-compliance.md)).

**What should I charge?**
A ladder of prices, read dynamically from `MarketplaceService` so managed pricing can localise and test them ([Pricing and price ladders](../09-monetization/pricing-and-price-ladders.md)).

**Should I make it pay-to-win?**
No. Fair, convenience-first monetization is also good positioning; communities punish pay-to-win ([Anime monetization](../20-anime-games/anime-monetization.md)).

## Running live

**How often should I update?**
On a fixed, public rhythm: a small weekly update plus bigger updates every few weeks ([Update cadence](../12-live-ops-and-launch/update-cadence.md)).

**What are admin abuse events?**
Scheduled live sessions where developers trigger chaotic, generous effects for everyone online; they produced many of the biggest peaks in 2025-2026 ([Live events and admin events](../21-hits-and-trends/live-events-and-admin-events.md)).

**My game's numbers are falling. Is it dead?**
Compare the same weekday over several weeks, then use the diagnosis table ([Why games die](../21-hits-and-trends/why-games-die.md)).

## Safety and rules

**What gets games removed?**
IP violations, inappropriate content, misleading thumbnails or titles, scams, and breaking monetization rules ([Community standards for developers](../17-policy-and-business/community-standards-for-devs.md), [IP and licensing](../17-policy-and-business/ip-and-licensing.md)).

**Can my game include horror or violence?**
Yes, within the content maturity rating you declare; it changes which ages can play ([Age ratings and audience](../17-policy-and-business/age-ratings-and-audience.md)).

## Working with AI agents

**Can the agents publish my game?**
No. Agents upload Saved versions; a person publishes ([For AI agents](../00-start-here/for-ai-agents.md)).

**What do agents never do?**
Publish, spend money, accept terms, answer policy questions for the owner, or record a human's decision ([Agent team workflow](../16-ai-studio-operations/agent-team-workflow.md)).

**Which AI tools should we use with Studio?**
The built-in Studio MCP server and Roblox's own tools first; community bridges only after a security review ([AI tooling landscape](ai-tooling-landscape.md)).

**How do I know an agent's work is good?**
Evidence: check records, playtest results, screenshots and numbers with sources, judged against gate criteria ([Quality gates](../16-ai-studio-operations/quality-gates.md)).

## For agents

- [ ] When answering a human's question, link the relevant note and give the short answer first.
- [ ] If an answer depends on a platform rule, check the source date before answering.

Related: [Learning paths](learning-paths.md) · [How to use this vault](../00-start-here/how-to-use-this-vault.md) · [Glossary](../99-reference/glossary.md) · [Key numbers](../99-reference/key-numbers.md) · [Engine limits reference](engine-limits-reference.md)
