---
title: Trading economies
date: 2026-10-24
tags: [economy, trading, social, limiteds, safety]
aliases: [Trading, Player trading, Limited items]
summary: When to add player trading, how to design it so it creates value instead of scams and duplication, and the policy rules that apply.
audience: [human, agent]
---

# Trading economies

Trading turns a collection into a society. Pet and item trading drove some of Roblox's biggest games for years: players talk about values, chase limited items, visit trading hubs and come back to check the market. Trading also brings the worst problems a game can have: scams, duplication exploits, real-money trading and a broken progression curve.

## Should your game have trading?

Add trading when **all** of these are true:

- The game has a collection with real rarity and many items (dozens at least).
- Items have stable, understood value (players know what is rare and why).
- You can afford the engineering and moderation cost: atomic trades, logs, scam prevention, support.
- Your progression survives players acquiring top items from others.

Do not add trading at launch to a game whose economy you have not yet watched for a few weeks. Add it as a big update once the economy is stable.

## Designing the trade system

### The trade window

- Both players add items; both see everything; both must **accept**, then a **confirm** step with a short countdown (3-5 seconds) that **resets whenever anything changes**.
- Show item details clearly: rarity, variant, level, and a warning if the trade is very uneven by your own value estimate ("You are giving much more than you receive").
- Allow only items, not promises. No "trust trades" where one side gives first.
- Prevent trading within a few seconds of a change to stop last-second swaps.

### Server-side atomicity (non-negotiable)

A trade must either fully happen or not happen at all, even if a player leaves, a server crashes, or a data save fails.

1. Lock both players' inventories for the duration of the trade (no other trades, hatches, deletes or equips on those items).
2. Verify on the server that both players still own every offered item, unlocked and not equipped in a way that blocks trade.
3. Move items in memory for both players in one step.
4. Save both players' data. With session-locked data (see [Data persistence](../13-building-it-right/data-persistence.md)), both saves are under your server's lock.
5. Log the trade with both user ids, item ids and timestamp.
6. Unlock.

Use unique instance ids for every tradable item (a GUID per owned unit). Duplication exploits almost always come from items without unique ids, from client-trusted item lists, or from non-atomic saves.

### Trade taxes and limits

- A small trade fee in soft currency is a useful sink and slows bot trading.
- Daily trade limits for new accounts reduce scam and alt-account abuse.
- Minimum account age or play time before trading (for example 3 days or 2 hours) protects new players and fights alts.

## Value and scarcity

- **Supply-limited items** (only 500 ever) hold value; **time-limited** items (available during an event) hold value if they never return.
- Promising an item will never return is a promise you must keep. Re-releasing a "limited" destroys trust.
- Bring new items regularly so the top of the market moves, but avoid power creep that makes old valuables worthless.
- Players will build value lists on wikis and Discord. You do not need to run one, but watch them to understand your economy.

## Policy rules for trading (platform facts, 2026)

- Use `PolicyService:GetPolicyInfoForPlayerAsync(player)` and check `IsPaidItemTradingAllowed`. If it is false, the player must not be able to trade items obtained with Robux (directly or through Robux-bought currency), including outcomes of paid random items.
- When regional pricing is enabled, players in different regions may have paid different Robux prices for the same item. Use `MarketplaceService:GetUsersPriceLevelsAsync` to manage gifting and trading of priced items between users with different price levels.
- Real-money trading (selling in-game items for money or Robux outside Roblox systems) violates Roblox rules. Do not build features that facilitate it, and make it hard: no item transfers without a trade window, no gifting of high-value items to brand-new accounts.
- The Maturity & Compliance Questionnaire asks about paid item trading. Answer accurately.

## Scam prevention checklist

- [ ] Two-step accept and confirm with a countdown that resets on change.
- [ ] Item details visible; uneven-trade warning.
- [ ] No way to show a fake item (only real inventory items can be added).
- [ ] Display names *and* usernames shown in the trade window.
- [ ] Trade history visible to the player (last 50 trades) for support.
- [ ] Locked items cannot be offered.
- [ ] Rate limits and account-age limits.

## When trading goes wrong

| Problem | Sign | Response |
|---|---|---|
| Duplication | Supply of an item jumps; logs show the same instance id twice | Freeze trading, patch, remove duplicated instances using logs, communicate clearly |
| Inflation | Top items' trade values climb steadily | New sinks, new top tier, trade fees |
| Scams | Support complaints, angry reviews | Better trade UI warnings, account-age limits |
| Bots | Many low-playtime accounts trading | Account-age and playtime requirements, trade fees |

## For agents

- [ ] Trading not shipped until the economy has been observed live for at least a few weeks.
- [ ] Every tradable item has a unique instance id.
- [ ] Trades are atomic and logged; both inventories locked during the trade.
- [ ] `IsPaidItemTradingAllowed` and regional price levels respected.
- [ ] Scam prevention checklist complete.

Related: [Economy design](economy-design.md) · [Collection and variants](../03-rarity-and-rng/collection-and-variants.md) · [Data persistence](../13-building-it-right/data-persistence.md) · [Monetization compliance](../09-monetization/monetization-compliance.md) · [Social systems](../10-retention-and-social/social-systems.md)
