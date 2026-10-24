---
title: Age ratings and audience
date: 2026-10-24
tags: [policy, age-rating, maturity, audience, publishing]
aliases: [Content maturity, Maturity questionnaire, Roblox Kids, Roblox Select]
summary: How Roblox's 2026 account tiers and content maturity labels decide who can play your game, what the questionnaire covers, and how to choose a rating strategy.
audience: [human, agent]
---

# Age ratings and audience

Your content maturity label decides which players can find and play your game. Since 2025-2026, Roblox also groups accounts into age tiers with their own publishing requirements. Choose your audience first, then design content to fit it.

## Account tiers (platform facts, 2026)

| Tier | Who | Content they can play | Chat |
|---|---|---|---|
| Roblox Kids | Self-declared or age-checked 5-8 | Minimal, Mild | Off by default; can be enabled via a linked parent after age check |
| Roblox Select | Self-declared 9+ (until age-checked) or age-checked 9-15 | Minimal, Mild, Moderate | Off for self-declared; introduced gradually after age check |
| Roblox | Age-checked 16+ | All rated content except Restricted | On by default where available |
| Restricted content | Age-verified 18+ only | Restricted | n/a |

Parents can link accounts and control access (including approving specific games for young children).

## Content maturity labels

| Label | Eligible tiers |
|---|---|
| Minimal | Kids, Select, Roblox |
| Mild | Kids, Select, Roblox |
| Moderate | Select, Roblox |
| Restricted | Age-verified 18+ only (and unplayable in some countries, such as Korea, Saudi Arabia and Türkiye) |
| Content May Vary | Given when only the first age-restricted question is answered "No"; released to age-checked 16+ only |

## The Maturity & Compliance Questionnaire

The questionnaire asks about: violence, blood, fear, crude humor, unplayable gambling content, strong language, romantic themes, alcohol, social hangout, free-form user creation, sensitive issues, paid random items (and whether you respect `ArePaidRandomItemsRestricted`), paid item trading, media, and AI interaction. Your answers produce a label and content descriptors shown on the game page.

Rules:

- Answer accurately. Inaccurate labels can be replaced or removed by Roblox, and content beyond your label is subject to moderation.
- Re-answer when an update changes content (a new horror event, a new trading system).
- Restricted content requires the full questionnaire and an age-verified creator.

## Reaching under-16 players

A new public game starts with age-checked 16+ players. To reach Kids and Select, the owner must be verified, use 2-step verification, complete the full questionnaire with a Minimal, Mild or Moderate rating, meet the publishing fee or subscription requirement, and pass the evaluation (250 unique plays from highly engaged age-checked 16+ users within 60 days, plus a safety review). An expedited review is available for a refundable fee. Details: [Launch playbook](../12-live-ops-and-launch/launch-playbook.md).

## Choosing a rating strategy

| Strategy | Pros | Cons | Fits |
|---|---|---|---|
| Minimal / Mild | Largest possible audience including young kids | Tight limits on violence, fear, themes | Simulators, tycoons, obbies, pets, farming, casual |
| Moderate | Older kids, teens and adults; more intense content allowed | Excludes Kids tier | Action, fighting, horror-lite, shooters |
| 16+ only (Content May Vary or Moderate without evaluation) | Faster launch, older audience | Smaller audience | Prototypes, older-audience games |
| Restricted (18+) | Mature themes allowed | Small audience, regional blocks, higher scrutiny | Specific mature games |

Rules of thumb:

- If your game could be Mild with small changes (less blood, cartoonish violence, milder scares), that usually pays off in audience size.
- Horror and fighting games should decide their intensity deliberately and test their questionnaire answers early.
- Social hangout and free-form creation features carry extra safety duties (filtering, moderation tools).

## Older audiences and earnings

The U.S. 18+ DevEx rate (0.0054 per earned Robux) rewards purchases by age-verified US adults in games meeting avatar requirements (R15-only player characters or qualifying custom characters). Games built for older players can earn more per Robux spent. See [Platform payouts](../09-monetization/platform-payouts.md).

## For agents

- [ ] Target audience tier chosen before content design.
- [ ] Content choices (violence, fear, romance, gambling-like mechanics) checked against the target label.
- [ ] Questionnaire answers drafted from actual content for human review; re-reviewed with each content update.
- [ ] Launch plan accounts for the 16+ trial and the under-16 evaluation.

Related: [Launch playbook](../12-live-ops-and-launch/launch-playbook.md) · [Community standards for developers](community-standards-for-devs.md) · [Monetization compliance](../09-monetization/monetization-compliance.md) · [The Roblox platform in 2026](../00-start-here/roblox-platform-2026.md)

Sources: [Roblox Kids and Select](https://create.roblox.com/docs/production/publishing/kids-and-select), [Content maturity](https://create.roblox.com/docs/production/promotion/content-maturity)
