---
title: Ads and rewarded video
date: 2026-10-24
tags: [monetization, ads, rewarded-video, immersive-ads]
aliases: [Rewarded ads, Immersive ads, Ad revenue]
summary: How to earn from ads inside your game without hurting the experience: rewarded video placement, rewards, eligibility and immersive ad units.
audience: [human, agent]
---

# Ads and rewarded video

Ads earn money from players who will never buy anything, which is most players. Done well, rewarded video ads feel like a free gift the player chose. Done badly, ads feel like a toll and drive players away.

## Rewarded video ads (platform facts, 2026)

- A rewarded video is a full-screen video ad (about 6-30 seconds) that the player **chooses** to watch in exchange for an in-game reward.
- **Eligibility**: creator 13+ and ID-verified; the game is public with at least **2,000 unique visitors per month**; enable serving in Creator Hub.
- **Rewards must be developer products** you choose in Creator Hub. You cannot reward Robux, and the reward cannot be random.
- **Earnings** depend on impressions: earnings per thousand impressions times the number of impressions.
- **Implementation**: on the client, call `AdService:GetAdAvailabilityNowAsync()` close to the moment you want to offer the ad (for example when the player opens the menu with the "Watch ad" button), show the offer only if an ad is available, then show the ad. The server grants the reward through the developer product flow.
- **Disclosure**: make it clear the player is about to watch an ad, what they must do and what they get.
- **Protect the player**: the character must not be harmed while the ad plays. Pause damage or only offer ads in safe zones like the lobby.

## Where rewarded videos work

| Placement | Reward idea |
|---|---|
| After a round or level | Double the round rewards |
| On rejoin | Double offline earnings |
| Out of lives or after a defeat | One free revive (limited per round) |
| Daily reward screen | A bonus daily spin or chest |
| Shop | A small free currency or boost, limited per day |
| Before a hard stage | Short boost (speed, luck) |

Rules of thumb:

- Roblox suggests rewards worth roughly **3-10 Robux** in value: boosters, some currency, extra lives, temporary privileges.
- Put offers in **high-traffic, natural breaks**: lobbies, menus, end of rounds.
- Make the offer **one or two taps** and clearly labelled ("Watch a video: x2 rewards").
- **Cap per day** so ads do not replace play or purchases.
- Do not make ads mandatory or required for core progression.
- Check the effect on retention and purchases. If paying players start watching ads instead of buying, adjust the rewards.

## Immersive ads

Immersive ad units place advertiser content inside your 3D world:

- **Image ads**: static images on surfaces in the world.
- **Video ads**: videos that play when a player looks at them.
- **Portal ads**: an image with a door that teleports players to an advertiser's game.

You earn per qualified impression (for images and video) or per successful teleport (portals). Payouts arrive on the 25th of the following month. Players who are not eligible to see ads see a fallback.

Placement rules of thumb:

- Place units where players naturally look while waiting (lobby walls, queue areas), not in combat zones.
- Do not block gameplay or navigation with ad units.
- Respect `PolicyService` eligibility (some players cannot see ads).
- Never generate fake impressions (for example forcing cameras toward ads or bots). Ad fraud is prohibited and enforced.

## Ads and your audience

- Many younger players are not eligible for some ad types. Design so the game is complete without ads.
- Ads in your game should match its audience (Roblox handles advertiser suitability, but your placement choices should keep ads out of disruptive moments).

## For agents

- [ ] Eligibility confirmed before building ad features.
- [ ] Rewarded video rewards are developer products, non-random, roughly 3-10 Robux in value, and capped per day.
- [ ] `GetAdAvailabilityNowAsync()` checked right before offering; offers hidden when no ad is available.
- [ ] Characters protected during ads.
- [ ] Immersive ad units placed in waiting areas, never blocking gameplay.
- [ ] Retention and purchase metrics compared before and after enabling ads.

Related: [Platform payouts](platform-payouts.md) · [Monetization strategy](monetization-strategy.md) · [Monetization compliance](monetization-compliance.md)

Sources: [Rewarded video ads](https://create.roblox.com/docs/production/promotion/rewarded-video-ads), [Immersive ads](https://create.roblox.com/docs/production/monetization/immersive-ads)
