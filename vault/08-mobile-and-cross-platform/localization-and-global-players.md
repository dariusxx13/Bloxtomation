---
title: Localization and global players
date: 2026-10-24
tags: [localization, translation, global, regional-pricing]
aliases: [Localization, Translation, Global players]
summary: How to make a Roblox game understandable and fairly priced for players around the world using Roblox localization tools and design choices.
audience: [human, agent]
---

# Localization and global players

Roblox is global. A large share of players do not speak English as a first language, and growth is strongest outside the US. Localization is cheap on Roblox, and design choices (icons over text, simple mechanics) matter as much as translation.

## Design for translation first

- **Icons and visuals carry meaning**; text is a backup. See [UI principles for Roblox](../05-ui-and-hud/ui-principles.md).
- **Short strings** translate better and fit better. German and Portuguese text is often much longer than English; leave room.
- **No text baked into images** for anything that matters. Use text labels so they can be translated.
- **Numbers and icons for currencies and stats** read in every language.
- **Avoid wordplay, slang and memes** in instructions. Keep them for flavor text where mistranslation does not hurt.

## Roblox localization tools (platform facts)

- **Automatic translation**: Roblox can automatically translate game text for players who enable automatic translations in their account settings. It only generates translations for strings that do not have a manual translation.
- **Manual translations** always take priority over automatic ones. Add manual translations for your most important strings (onboarding, shop, key UI) in your top languages.
- **Localization table**: a game-wide table of source strings and translations, managed in Creator Hub. Roblox can capture strings from your game automatically.
- **Opt out of translation** for strings that must not change (names, logos, codes) by disabling auto-localization on those UI elements.
- **Translators**: you can invite translators as collaborators and download translation analytics.
- **Scripting**: `LocalizationService` and translators let code format strings with parameters ("You earned {amount} coins") so word order works in every language.
- Set the source language and supported languages in localization settings before translating.

## Priority languages

Look at your own analytics (players by language and country). Common high-value additions beyond English: Spanish, Portuguese (Brazil), French, German, Indonesian, Japanese, Korean, Thai, Turkish, Russian, Chinese (Simplified and Traditional), Vietnamese, Filipino, Polish, Arabic. Translate the onboarding and shop first.

## Global pricing

Players in different countries have very different purchasing power. Roblox's managed pricing (including regional pricing) adjusts prices per player's economic location between 30% and 100% of your default price, and it is enabled by default for new items. Your job: never hard-code prices in UI (always read them from `MarketplaceService`), and use `GetUsersPriceLevelsAsync` to manage trades and gifts between players with different price levels. See [Pricing and price ladders](../09-monetization/pricing-and-price-ladders.md).

## Global events and timing

- Server-wide events and live update releases should consider time zones of your main audiences. US afternoons and weekends are strong for English-speaking players; check your own players-by-hour chart.
- Holidays differ by region; global events (New Year, summer) are safer than country-specific ones.
- Some content is restricted in some regions (for example Restricted-rated games are unplayable in certain countries; paid random items are restricted for some players). Use `PolicyService` for per-player rules.

## For agents

- [ ] No essential text inside images; strings in the localization table.
- [ ] Onboarding and shop strings manually translated for the top languages by player share.
- [ ] Parameterized strings use the localization formatting, not string concatenation.
- [ ] Prices read from `MarketplaceService`; trades respect price levels.
- [ ] Long-language overflow checked in the Device Simulator.

Related: [UI principles for Roblox](../05-ui-and-hud/ui-principles.md) · [Pricing and price ladders](../09-monetization/pricing-and-price-ladders.md) · [Monetization compliance](../09-monetization/monetization-compliance.md)
