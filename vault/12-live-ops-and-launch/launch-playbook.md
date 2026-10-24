---
title: Launch playbook
date: 2026-10-24
tags: [launch, live-ops, publishing, age-tiers, marketing]
aliases: [How to launch, Release plan, Soft launch]
summary: A step-by-step plan from private testing to full audience reach, built around Roblox's 2026 publishing rules (16+ trial, under-16 evaluation), with timing, readiness gates and the first two weeks after launch.
audience: [human, agent]
---

# Launch playbook

Launching a Roblox game in 2026 is a staged process, because a new game does not reach every player on day one. This playbook combines the platform rules with practical steps.

## The 2026 publishing reality (platform facts)

- A newly released public game is first available to **age-checked users aged 16+** (a trial phase). If you answer "No" to the age-restricted content question without completing the full questionnaire, the game gets a "Content May Vary" label and stays 16+ only.
- To reach **Roblox Kids (5-8)** and **Roblox Select (9-15)**, the game owner (user, or group owner for group games) must: be in good standing; verify their account (facial age estimation if under 18, government ID if 18+); enable 2-step verification; complete the full Maturity & Compliance Questionnaire with a Minimal, Mild or Moderate rating; and either hold a Roblox Plus or Premium subscription for 2 consecutive months or pay a one-time **refundable 1,000 Robux** publishing fee per game (refunded if the game keeps 25 highly engaged players for 60 days without moderation).
- The game must then pass an **evaluation**: **250 unique plays from highly engaged, age-checked 16+ users within 60 days**, plus a safety review of its moderation reports and gameplay. Progress shows in Creator Hub's **Audience Reach** dashboard.
- An **expedited review** is available for timed launches for a refundable **50,000 Robux** fee (refund requestable after 90 days if the game stays in good standing with 25 highly engaged players).
- Ads Manager's **Engagement** objective targets age-checked highly engaged players whose plays count toward the threshold (expect a higher cost per play).
- You can release at most **5 never-released games per day**. Before release you can invite up to **10 similar-aged friends** as early testers.

## Stage 0: Before anything public

- [ ] Core loop, first session and the first hour are playable and fun (playtested with people who have never seen the game).
- [ ] Data saving is bulletproof: session locking, retries, autosave, `BindToClose`, receipt handling. See [Data persistence](../13-building-it-right/data-persistence.md).
- [ ] Security pass on every remote. See [Security and anti-exploit](../13-building-it-right/security-and-anti-exploit.md).
- [ ] Onboarding funnel, economy events and key custom events instrumented. See [Analytics instrumentation](../13-building-it-right/analytics-instrumentation.md).
- [ ] Performance tested on a low-end phone.
- [ ] Icon, 3-5 thumbnails, title, description, genre ready. See [11 Store page and discovery](../11-store-page-and-discovery/INDEX.md).
- [ ] Maturity & Compliance Questionnaire answered accurately and completely.
- [ ] Account verification, 2FA, and the Plus/Premium or fee requirement handled for the owner.
- [ ] Monetization: a few fair passes and a cheap first purchase, all with runtime prices.
- [ ] Moderation-safe content and assets (no unlicensed IP, no risky uploads).

## Stage 1: Private testing (1-2 weeks)

- Early testers (up to 10 similar-aged friends), your team, a small Discord group.
- Goals: find bugs on the golden path, confirm the first session works without explanation, check devices.
- Fix, then fix again. Do not release with known golden-path bugs.

## Stage 2: Public release to 16+ (the trial phase)

- Release publicly. The audience is age-checked 16+.
- **Seed engaged players**: your Discord and social followers, friends, creators who make content for older audiences, and optionally an Engagement objective campaign in Ads Manager with a dedicated budget. Ask for nothing artificial: the evaluation looks at real engagement (account age, play history, spend) to filter bots.
- Watch: onboarding funnel, first-play bounce, D1, crash and error rates, the Audience Reach progress toward 250 highly engaged plays.
- Fix the biggest funnel drop every few days. Each fix is an update that refreshes exploration.

> [!TIP]
> If your game is designed for younger players, the 16+ trial audience may react differently from your target audience. Use the trial to fix universal problems (bugs, clarity, performance), and expect your real numbers once the full audience opens.

## Stage 3: Full audience (Kids and Select unlocked)

- Once the evaluation passes, the under-16 audience opens (if your rating allows). This is your real launch.
- Plan a **launch update** for this moment: new content, a launch event, codes, thumbnails refreshed, creators notified.
- **Timing**: Roblox traffic peaks on weekends (Saturday is usually the strongest day) and in school holidays. Ship the launch update on a Friday or Saturday, at a time when your main audience is awake, with the team available to fix issues.
- Turn on thumbnail personalization with several concepts.
- Consider a Plays or Engagement ad campaign to kick-start exploration in Recommended for You. Remember ads do not count toward ranking; they only help Roblox notice the game.

## The first 14 days

| Day | Focus |
|---|---|
| 0-1 | Watch errors, crashes, data issues, purchase failures. Hotfix anything critical immediately. |
| 2-3 | Read the onboarding funnel and first-play bounce. Ship the first fix. |
| 3-7 | D1 cohorts available; compare by platform and source. Second update with the next-biggest fix and a small content drop. |
| 7 | First weekly update with visible new content (keeps exploration going). |
| 7-14 | D7 cohorts arrive. Tune progression pacing. Plan the first event. |
| 14 | First event or bigger update. Review monetization only if retention is healthy. |

## Launch-day checklist

- [ ] Team available for several hours after release.
- [ ] Rollback plan: previous place version noted; configs to disable new features quickly (see [Experiments and configs](experiments-and-configs.md)).
- [ ] Error report and performance dashboards open; alerts configured.
- [ ] Codes and announcements prepared; Discord ready.
- [ ] Thumbnails, icon, description final.
- [ ] Purchases tested with a real (cheap) purchase on a test account.

## For agents

- [ ] Publishing requirements for the target audience verified against the current docs before scheduling.
- [ ] Stage 0 checklist complete with evidence.
- [ ] A plan to reach 250 highly engaged age-checked plays (channels, expected time, optional Engagement budget) approved by the human.
- [ ] Launch update and timing chosen for the full-audience moment.
- [ ] No automated publishing: a human releases the game.

Related: [Update cadence](update-cadence.md) · [User acquisition](user-acquisition.md) · [Age ratings and audience](../17-policy-and-business/age-ratings-and-audience.md) · [Pre-launch checklist](../18-templates-and-checklists/pre-launch-checklist.md) · [Discovery algorithm](../11-store-page-and-discovery/discovery-algorithm.md)

Sources: [Roblox Kids and Select](https://create.roblox.com/docs/production/publishing/kids-and-select), [Publish games and places](https://create.roblox.com/docs/production/publishing/publish-games-and-places), [Ads Manager](https://create.roblox.com/docs/production/promotion/ads-manager)
