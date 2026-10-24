---
title: Community standards for developers
date: 2026-10-24
tags: [policy, moderation, safety, rules]
aliases: [Roblox rules for creators, What gets games removed]
summary: The Roblox rules that most often affect developers (content, metadata, monetization, social features, off-platform links, manipulation), written as practical do's and don'ts.
audience: [human, agent]
---

# Community standards for developers

Roblox's Terms of Use and Community Standards apply to everything in your game: content, metadata, monetization and how you promote it. Violations can remove assets, games or accounts, and freeze earnings. This note summarizes the areas that matter most for game creators. It is a practical guide, not legal advice; read the official standards for details.

## Content

- **Rate content honestly.** Complete the Maturity & Compliance Questionnaire accurately; violence, blood, fear, crude humor, romance, alcohol, gambling-like content, social hangouts, free-form user creation, paid random items, paid trading and AI interaction all affect the label. See [Age ratings and audience](age-ratings-and-audience.md).
- **Some content is prohibited at any rating**: extreme violence and gore, sexual content involving minors in any way, real-world hate and extremism, glorification of real atrocities, real-world gambling for money, illegal activity, harassment and bullying, and more.
- **Uploaded assets are moderated separately** from the game's label; realistic gore or sexualized content gets removed regardless of your rating.

## Metadata and discovery

- Titles, descriptions, icons and thumbnails must represent the game honestly.
- No reward bait ("free Robux"), no fake updates, no misleading thumbnails. Discovery demotes these and moderation can remove them.
- Do not impersonate other games, creators or Roblox.
- Do not keyword-stuff or game the algorithm with artificial traffic (bots, teleport loops, alts). Creator Rewards explicitly forbids artificial activity.

## Monetization

See [Monetization compliance](../09-monetization/monetization-compliance.md). Key points: paid random items need full odds disclosure and `PolicyService` gating; no fake discounts, scarcity or timers; no pressure tactics toward young players; subscriptions must deliver their benefits; real-money trading of game items is prohibited.

## Player text and social features

- All player-created text visible to others (pet names, signs, bios, base names, custom messages) must be filtered with `TextService`.
- Do not build ways to share personal information or contact details, or to move conversations off Roblox.
- Respect chat and voice eligibility by age; the game must work for players without chat.
- Provide ways to avoid unwanted interactions (block, private spaces, hide others' effects).

## External links and off-platform

- Roblox restricts linking out of games. Use the supported social media links on your game page (shown according to age rules) instead of telling players to visit external sites in-game.
- Do not ask players to provide real-world information, pay outside Roblox, or join off-platform giveaways for in-game items.
- Advertising and sponsorships inside your game must follow Roblox's advertising standards (disclosure, suitability).

## Accounts and teams

- Protect accounts: 2-step verification for everyone with edit access, least-privilege group roles, no shared passwords.
- You are responsible for collaborators' content in your game.
- Repeat violations escalate penalties; appeal mistakes through official channels.

## Localization and global players

Some features are restricted in some countries (for example paid random items for certain players, Restricted-rated content in some regions). Use `PolicyService` per player rather than assuming one global rule.

## For agents

- [ ] Every metadata change reviewed for honesty and reward bait.
- [ ] All player text filtered before display to others.
- [ ] No in-game external links or off-platform asks beyond supported social links.
- [ ] Monetization compliance checklist passed before release.
- [ ] Questionnaire answers drafted from the actual content and reviewed by a human.

Related: [Age ratings and audience](age-ratings-and-audience.md) · [IP and licensing](ip-and-licensing.md) · [Monetization compliance](../09-monetization/monetization-compliance.md) · [Social systems](../10-retention-and-social/social-systems.md)

Sources: [Roblox Community Standards](https://en.help.roblox.com/hc/articles/203313410), [Experience guidelines](https://create.roblox.com/docs/production/promotion/experience-guidelines)
