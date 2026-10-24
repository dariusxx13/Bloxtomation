---
title: Privacy and data
date: 2026-10-24
tags: [policy, privacy, gdpr, rtbf, data]
aliases: [Right to erasure, RTBF, GDPR, Data deletion]
summary: Your responsibilities for player data on Roblox: what to store, right-to-erasure requests and automation, logging, external services, and children's privacy.
audience: [human, agent]
---

# Privacy and data

Many Roblox players are children, and privacy laws around the world protect them. Roblox handles most platform-level privacy, but you are responsible for the data your game stores in DataStores and any external services.

## Store only what you need

- Store game progress, settings and purchase receipts keyed by user id. That is usually all a game needs.
- Do not store personal information (real names, emails, phone numbers, addresses, birthdays, photos, voice).
- Do not store chat logs. If you need moderation logs, keep them minimal and short-lived.
- Do not try to identify players across platforms or link accounts outside Roblox's systems.

## Right to erasure (RTBF)

Users can ask Roblox to delete their data. Roblox then notifies creators of games that user played (platform facts, 2026):

- Roblox sends a daily right-to-erasure notification for affected games.
- **Automated data store deletion**: you can configure deletion templates so Roblox automatically deletes matching keys in your DataStores when it processes a request.
- **Creator webhooks**: configure a webhook with the Right to Erasure Request trigger to run your own deletion automation (for complex schemas or external systems).
- You remain responsible for deleting the user's personal data wherever your game stored it, including external systems.

Design implications:

- Key player data by user id in predictable DataStore names and keys (for example `PlayerData` with key `user_<userId>`) so automated deletion templates work.
- Keep a list of every place a user id is stored (profiles, ordered leaderboards, trade logs, ban lists, external analytics) so deletion is complete.
- For complex cases, use Open Cloud DataStore APIs from your webhook handler to delete data.

## External services

If your game sends data out with `HttpService` (analytics, Discord webhooks, servers):

- Send only what is necessary, never personal information.
- Secure endpoints and keys (never put secrets in client-visible code).
- Your external systems are subject to erasure requests too.
- Do not use Discord webhooks from game servers for high-volume logging (rate limits, and it is not what they are for).

## Children's privacy

- Assume many players are under 13.
- Never ask for personal information in-game (no forms for emails or phone numbers, no "tell us your age" prompts for data collection).
- Player-created text must be filtered before others see it.
- Avoid features that encourage sharing personal details or contacting players off-platform.

## For agents

- [ ] Data schema contains no personal information beyond the user id.
- [ ] Every storage location of user ids is listed for deletion.
- [ ] RTBF deletion is automated (templates or webhook) or a documented manual process exists.
- [ ] No secrets in client-visible code; external requests carry no personal data.

Related: [Data persistence](../13-building-it-right/data-persistence.md) · [Community standards for developers](community-standards-for-devs.md) · [Money, DevEx and teams](money-devex-and-teams.md)

Sources: [RTBF and creators](https://create.roblox.com/docs/production/publishing/RTBF-and-creators)
