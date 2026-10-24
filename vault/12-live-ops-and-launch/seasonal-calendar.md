---
title: Seasonal calendar
date: 2026-10-24
tags: [live-ops, calendar, seasons, events, planning]
aliases: [Live ops calendar, Yearly event calendar, Seasonal planning]
summary: A twelve-month live-ops calendar for Roblox games - holidays and school breaks that move players, Roblox's own recurring moments (RDC, Innovation Awards, platform events), the weekly rhythm with Saturday peaks, lead times for seasonal content, and a planning table the Director fills each quarter.
audience: [human, agent]
---

# Seasonal calendar

Players' time follows the calendar: school terms, holidays, weekends and big platform moments. Games that plan seasonal content months ahead ride those waves; games that improvise miss them. This note gives a yearly map and a planning method. Event design itself is in [Events and seasons](events-and-seasons.md) and [Live events and admin events](../21-hits-and-trends/live-events-and-admin-events.md).

## The weekly rhythm

- **Saturday is the weekly traffic peak** on Roblox ([Key numbers](../99-reference/key-numbers.md)). Many 2026 hits ran updates or admin sessions on Saturdays, and trackers saw Saturday averages well above monthly averages (Bloxodes, June 2026).
- **Friday** releases (as Brookhaven and Adopt Me use, according to trackers) give the weekend to the new content.
- **Weekday evenings** in the main player regions are the daily peaks; spread live moments across time zones or repeat them.

Pick a weekly slot and keep it ([Update cadence](update-cadence.md)).

## The year (Rule of thumb, with dated examples)

| Month | What moves players | Examples and notes |
|---|---|---|
| January | Winter holidays end; New Year events wind down; Lunar New Year (late January or February) | Concert-style events can draw huge crowds (a January 2026 concert inside a top game reached about 12.8M concurrent players, Wikipedia) |
| February | Lunar New Year, Valentine's themes | Light cosmetic events |
| March | Spring breaks begin in some regions | A good month for a mid-size update |
| April | Spring and egg themes in many regions; school breaks | Egg-themed events suit collection games |
| May | End of school year approaches (Northern hemisphere) | Launch window for summer games; Grow a Garden's first records came in May 2025 |
| June | Summer holidays start (Northern hemisphere) | Survival games rose strongly in June 2026 (Bloxodes); Roblox changed recommendation windows mid-June 2026 (reported) |
| July | Peak summer play | Murder Mystery 2's summer event began on 2026-07-23 and set records into August |
| August | Summer continues; back-to-school late in the month | Innovation Awards voting closed on 2026-08-11 (playnews.gg) |
| September | Back to school; RDC; Innovation Awards; a platform event | RDC 2026 on 2026-09-11; The Hunt: Roblox 20 from 2026-09-17 to 09-28 |
| October | Halloween: horror's biggest month | The Hollow platform event 2026-10-22 to 11-02; 29 of the top 100 titles carried a pumpkin on 2026-10-24 (studio snapshot) |
| November | Halloween ends; US Thanksgiving; winter preparation | Start winter events late in the month |
| December | Winter holidays: the yearly peak for many games | Brookhaven's record (about 1.3M) came in December 2025 (StudioKrew) |

Southern-hemisphere summer holidays run roughly December to February, which supports winter-holiday peaks there too. Regional holidays matter for games with big audiences in specific countries ([Localization and global players](../08-mobile-and-cross-platform/localization-and-global-players.md)).

## Lead times

| Content | Start building |
|---|---|
| Major seasonal event (Halloween, winter) | 8-12 weeks before |
| Seasonal cosmetics and shop | 6-8 weeks before |
| Smaller holiday events | 4 weeks before |
| Weekly update | The previous week (with a buffer of several weeks banked) |

Build seasonal content behind live config flags so it can ship early and switch on at the right time ([Experiments and configs](experiments-and-configs.md)).

## Platform moments

- **RDC** (September) brings feature announcements that change plans; read the newsroom post and update [Platform shifts 2025-2026](../21-hits-and-trends/platform-shifts-2025-2026.md).
- **Innovation Awards** (voting in summer, awards at RDC) raise visibility for nominees and winners.
- **Platform events** (for example The Hunt and The Hollow in 2026) feature selected games; participation is by Roblox's invitation or programs, and any agreement is a human decision.

## Quarterly planning table

The Director fills this each quarter and links it from the roadmap:

```markdown
| Week of | Weekly update | Event | Season content | Code | Owner |
|---------|---------------|-------|----------------|------|-------|
| 2026-11-02 | New egg + QoL | - | Winter shop (in build) | NOVEMBER | Designer |
| 2026-11-09 | Balance patch | Admin session (Sat) | Winter map (in build) | - | Engineer |
| ...     | ...           | ...   | ...            | ...  | ...   |
```

## For agents

- [ ] Every game's roadmap shows the next two seasonal events with start dates and build start dates.
- [ ] Seasonal content ships behind flags and is tested before the event date.
- [ ] After each season, the analyst compares the event's D1 and D7 return with the previous one.

Sources: Bloxodes monthly reports (June-September 2026); StudioKrew boards (July-September 2026); Roblox newsroom (RDC 2026, The Hollow); Wikipedia ("Grow a Garden", "Steal a Brainrot"); the studio's chart snapshot of 2026-10-24. All accessed 2026-10-24.

Related: [Events and seasons](events-and-seasons.md) · [Update cadence](update-cadence.md) · [Live events and admin events](../21-hits-and-trends/live-events-and-admin-events.md) · [Update checklist](../18-templates-and-checklists/update-checklist.md) · [Evergreen giants](../21-hits-and-trends/evergreen-giants.md)
