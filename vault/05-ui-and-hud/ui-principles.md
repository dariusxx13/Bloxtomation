---
title: UI principles for Roblox
date: 2026-10-24
tags: [ui, ux, design, accessibility]
aliases: [UI principles, UX rules]
summary: The design rules that make Roblox interfaces readable for young, mobile, multilingual players, with a visual language you can reuse across games.
audience: [human, agent]
---

# UI principles for Roblox

Roblox UI is read on a 6-inch phone by a 10-year-old who may not read English, while a friend talks in voice chat and the game runs behind it. Every rule here comes from that reality.

## 1. Icons first, words second

- Every button has an icon that can be understood without its label. The label is a backup.
- Use icons players already know from other Roblox games: a shopping cart or bag for shop, a gift for rewards, a gear for settings, a backpack for inventory, a circular arrow for rebirth, a trophy for leaderboards, a pet paw for pets.
- Keep text to a few words. Buttons get one or two words ("Buy", "Equip", "Hatch x3").
- Translate everything that is text. Roblox automatic translation helps but is imperfect for short UI strings; use a localization table for UI and test long languages (German, Portuguese) for overflow. See [Localization and global players](../08-mobile-and-cross-platform/localization-and-global-players.md).

## 2. Big, thumb-friendly, and few

- Touch targets roughly the size of a fingertip at the smallest supported phone: as a rule of thumb, no interactive element smaller than about 44-48 points on the shortest screen side, with spacing between buttons.
- Fewer buttons visible at once. A cluttered HUD is the most common UI failure on Roblox. Hide what is not relevant now (see progressive reveal in [Onboarding patterns](../01-first-five-minutes/onboarding-patterns.md)).
- Group related actions in one menu instead of many HUD buttons.

## 3. A consistent visual language

Decide these once per game and never break them:

| Element | Convention |
|---|---|
| Primary action | Bright green or the game's accent color, largest button |
| Secondary action | Neutral (white or grey) |
| Danger (delete, sell rare) | Red, requires confirmation |
| Premium (Robux) | Robux icon next to the price, a distinct color (often green with the Robux symbol) |
| Soft currency | Its own icon and color everywhere it appears |
| Locked | Grey with a padlock and the requirement shown |
| New or claimable | Red dot or number badge, gentle pulse |
| Rarity | The tier colors from [Rarity tiers and odds](../03-rarity-and-rng/rarity-tiers-and-odds.md) |

Roblox now supports engine-level UI styling (`StyleSheet`, style rules, tokens and themes linked with `StyleLink`), similar to CSS. Use tokens for colors, fonts and corner radii so the whole game can be restyled consistently.

## 4. Clarity of state

Every element must make its state obvious:

- **Buttons**: normal, pressed (scale down slightly), disabled (desaturated, with the reason on tap), and loading (spinner) if the action waits on the server.
- **Purchases**: owned items say "Owned" or "Equipped", never show a buy button again.
- **Progress**: bars with numbers ("2,450 / 5,000"), not bars alone.
- **Cooldowns**: radial or bar fill plus seconds remaining.

## 5. Readable text

- Bold, high-contrast fonts with an outline (`UIStroke`) when text sits over the 3D world.
- Minimum readable size on phones: test it. Body text that is comfortable on desktop is often unreadable on a phone. Use `TextScaled` with a `UITextSizeConstraint` to bound sizes.
- Short number formats: 1.2K, 34.5M, 7.8B, 1.2T, then scientific or named suffixes (Qa, Qi, Sx...) for incremental games. Always the same format everywhere.
- Avoid thin and decorative fonts for anything functional.

## 6. Motion with meaning

- Panels open with a short transition (about 0.2-0.3 seconds, a slight "back" overshoot feels playful). Snapping open feels broken.
- Motion directs attention: a pulsing button means "press me now". Only one thing pulses at a time.
- Reward motion goes *toward* where the reward is stored (coins fly to the coin counter).
- Respect a "reduce motion" setting for shakes and flashes.

## 7. Never block play without a reason

- Menus that cover the game should be quick to open and close (one tap to close, a visible X in a consistent corner, tap outside to close).
- Do not open full-screen menus automatically during gameplay. Offer them with a button or a small toast.
- Players must be able to move and dodge with the HUD open in action games: no full-screen overlays during combat.

## 8. Honest and kind

- Show prices clearly before any purchase prompt. Never trick a tap into a purchase (moving buttons, a buy button where the close button was).
- No pressure language aimed at kids ("BUY NOW", "LAST CHANCE"); Roblox guidance suggests neutral calls to action such as "View item", "See price", "Open shop".
- Confirm destructive actions (delete pets, sell rares, rebirth) with what will be lost.

See [Monetization compliance](../09-monetization/monetization-compliance.md).

## 9. Accessibility basics

- Do not rely on color alone: pair rarity colors with labels or icons; pair red/green states with symbols.
- Captions or text for important audio cues.
- Adjustable settings: music volume, sound volume, camera shake, reduce motion, UI scale where possible.
- Roblox's accessibility guidance also recommends readable contrast and alternative text on thumbnails. See [Accessibility](https://create.roblox.com/docs/production/publishing/accessibility).

## 10. Test on the real target

A UI is not done until it has been checked:

- In the Device Simulator at a small phone, a large phone, a tablet and a 1080p desktop, in both orientations if the game supports portrait.
- With the Roblox top bar and chat open (they take space).
- With a gamepad if the game is on console.
- With the longest translated strings.

## For agents

- [ ] Every button has a recognizable icon; labels are two words or fewer.
- [ ] Visual language table (primary, danger, premium, locked, new) defined and applied.
- [ ] All interactive elements meet the touch-size rule at the smallest phone.
- [ ] Every button has pressed and disabled states; server actions show loading.
- [ ] Numbers use one short-format function everywhere.
- [ ] Device Simulator screenshots at four sizes attached to the review.

Related: [HUD layout](hud-layout.md) · [Menus, shops and inventories](menus-shops-inventories.md) · [UI implementation](ui-implementation.md) · [Mobile-first design](../08-mobile-and-cross-platform/mobile-first-design.md)
