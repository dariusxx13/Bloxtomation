---
title: Reveal and hatch design
date: 2026-10-24
tags: [rng, reveal, juice, ui, vfx]
aliases: [Hatch animation, Reveal animation, Unboxing]
summary: How to stage the moment a random reward is revealed so it builds anticipation, scales with rarity, stays fast for repeat rolls, and produces shareable moments.
audience: [human, agent]
---

# Reveal and hatch design

The reveal is where randomness turns into emotion. The same 1% drop feels like nothing with a silent inventory update and like a jackpot with a two-second build-up, a flash and a server announcement. In collection games, the reveal is the most-watched animation in the game. Treat it like a core feature, not a polish task.

## The four beats of a reveal

1. **Commit** (instant): the player presses hatch or roll. Immediate response: button press, sound, the egg or capsule appears center screen.
2. **Build-up** (0.5-2 s): anticipation. The egg shakes harder, light leaks through cracks, the pitch rises.
3. **Tell** (0.2-0.5 s): a hint of rarity before the item is shown. The color of the glow or the cracks shifts to the tier color. Rare tiers get a longer or more dramatic tell.
4. **Payoff** (1-2 s, skippable): the item appears with tier-colored effects, name, rarity label, odds ("1 in 2,500") and a "NEW!" tag if first time. Then it flies to the inventory or the player's side.

## Scaling with rarity

The reveal must be noticeably bigger for rarer outcomes. A suggested ladder:

| Tier | Build-up | Tell | Payoff extras |
|---|---|---|---|
| Common, Uncommon | Short | None or subtle | Small pop, tier color |
| Rare | Short | Blue glow | Sparkles, sound sting |
| Epic | Medium | Purple glow, extra shake | Screen-edge glow, bigger sting |
| Legendary | Medium-long | Gold light beams | Screen flash, camera push, chat message to server |
| Mythic | Long | Red pulse, slow-motion beat | Server-wide banner, world effect at the player's position |
| Top tier (Secret, Divine) | Longest | Screen goes dark, then rainbow | Unique music sting, global banner, cutscene-like moment, avatar effect visible to everyone |

> [!TIP]
> Fake-outs are powerful and cheap: occasionally let a common egg glow purple for a split second before settling on blue. Keep fake-outs rare and never on paid rolls in a way that could mislead players about what they got.

## Speed for repeat rolls

Players roll hundreds or thousands of times. A beautiful 4-second animation becomes torture by roll fifty.

- **Skip.** Tapping anywhere skips to the payoff after the first second.
- **Fast mode.** An option (often a reward or a pass) that shortens all common reveals to a fraction of a second.
- **Multi-hatch.** Hatch 3 or 8 at once, revealed together, with the rarest getting a solo highlight at the end.
- **Auto-roll.** Rolling continues automatically; only rare results interrupt. Let players set the interrupt threshold ("stop on Epic or better").
- **Never skip the rare.** Even in fast mode, Legendary and above always get a proper reveal. That is the moment the player is waiting for.

## Making it social

- **Chat announcements** for high tiers: "[Player] hatched a MYTHIC Inferno Dragon (1 in 50,000)!" Use the tier color. Use `TextChatService` system messages sent from the server.
- **World presence**: a beam of light at the player's position, visible across the map, for top-tier pulls.
- **Global announcements** (cross-server) for the very rarest using `MessagingService`. Rate-limit them so they stay special.
- **Show the pet or aura immediately** on the character so nearby players see it.
- **"Server first" and "Game first" tags**: the first player to hatch a new secret item after an update gets a permanent badge or title. Huge clip potential.

## Implementation pattern

1. Client sends `RequestHatch(eggId, count)`.
2. Server validates: owns enough currency, is near the egg (if world-based), not on cooldown, has inventory space, respects `PolicyService` if paid.
3. Server deducts cost, rolls each result, writes results to the player's data, logs economy and custom events.
4. Server replies with the list of results (ids and tiers). If any result is very rare, the server also triggers the broadcast.
5. Client plays the reveal sequence for those results. The animation is purely visual; data is already saved.
6. If the player disconnects mid-animation, nothing is lost: the items are already in their inventory.

```lua
-- Server sketch (types and validation helpers omitted)
Net.handle("RequestHatch", function(player, eggId: string, count: number)
	local egg = EggConfig[eggId]
	if not egg or not Validate.integerInRange(count, 1, Hatch.maxCountFor(player)) then
		return { ok = false, reason = "invalid" }
	end
	if not Hatch.isNearEgg(player, egg) or Cooldown.active(player, "hatch") then
		return { ok = false, reason = "unavailable" }
	end
	local cost = egg.price * count
	if not Currency.trySpend(player, egg.currency, cost, "Hatch:" .. eggId) then
		return { ok = false, reason = "funds" }
	end
	local results = Hatch.rollMany(player, egg, count) -- uses server Random, luck, pity
	Inventory.addMany(player, results) -- persisted through the data layer
	Broadcast.rareHatches(player, results)
	return { ok = true, results = results }
end)
```

## Common mistakes

- **Rolling on the client.** Exploiters will pick their own results.
- **Adding the item at the end of the animation.** Leaving during the animation loses the item or allows duplication tricks.
- **Same reveal for every tier.** Kills excitement and clip potential.
- **No skip.** Players stop rolling out of boredom, which looks like bad economy design but is actually bad reveal design.
- **Showing base odds while a luck boost is active.** A policy problem as well as a trust problem.

## For agents

- [ ] The reveal has the four beats, and payoff extras scale with tier.
- [ ] Skip, multi-hatch and auto-roll exist or are planned, and never skip top-tier reveals.
- [ ] Results are saved on the server before the client animation starts.
- [ ] Rare results broadcast to the server; the rarest also cross-server (rate-limited).
- [ ] The reveal reads clearly at phone size with sound off.

Related: [Rarity tiers and odds](rarity-tiers-and-odds.md) · [RNG systems and pity](rng-systems-and-pity.md) · [Game feel and juice](../02-core-loop/game-feel-and-juice.md) · [Clip moments and shareability](../02-core-loop/clip-moments-and-shareability.md)
