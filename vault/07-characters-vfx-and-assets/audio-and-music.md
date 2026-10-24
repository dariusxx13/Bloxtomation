---
title: Audio and music
date: 2026-10-24
tags: [audio, sound, music, game-feel]
aliases: [Sound design, Music]
summary: How to use sound effects and music to make actions satisfying, guide players and set mood, while staying within licensing rules and performance limits.
audience: [human, agent]
---

# Audio and music

Sound is half of game feel. A coin with a crisp "ding" feels twice as valuable as a silent one. Yet many players play muted, so audio must reinforce what the screen already shows, never carry information alone.

## Sound effect priorities

Build or source sounds in this order:

1. **Core action and reward** (hit, collect, coin, level up): the most-heard sounds; must be short and pleasant on repeat.
2. **UI** (button press, open, close, purchase success, error).
3. **Rarity stings** for reveals, scaled by tier.
4. **Danger cues** (enemy wind-up, alarm when your base is being robbed, timer ending).
5. **Ambience** per zone (wind, birds, lava bubbling) at low volume.
6. **Music** per zone or state.

## Rules for satisfying sound

- **Short and punchy** for repeated sounds (well under a second).
- **Vary repeats**: randomize pitch slightly (about ±5-10%) and rotate between two or three variants.
- **Layer for importance**: a rare drop gets a bigger, longer, more musical sound than a common one.
- **Rising pitch for combos and streaks** (each consecutive collect slightly higher) feels great.
- **Silence is a tool**: drop music for a beat before a big reveal or a horror moment.

## Music

- **One theme per zone or mode**, plus short stings for events. Music changes when the player enters a new zone (crossfade over a second or two).
- **Volume below effects** by default; players should hear rewards over music.
- **Loop seamlessly** and avoid tracks with distracting vocals in gameplay.
- **Event music** (Halloween, winter) is a cheap way to make events feel different.
- **Menus and lobbies** can have more energetic music than gameplay.

## Licensing

- Use audio you created, audio Roblox provides for use in games through the Creator Store audio library, or audio you have licensed with rights covering Roblox use.
- Do not upload commercial songs you do not have rights to. Uploaded audio is moderated, and copyright claims can remove assets or games.
- Uploaded audio used in a group game should be owned by (or shared with) the group that owns the game.
- Video thumbnails on your game page may contain music from Roblox's licensed catalog, but not voiceover or songs with lyrics (Roblox video thumbnail rules).

## Organizing sound

- **`SoundGroup`s** for categories (Music, SFX, UI, Ambience) so settings sliders control each group's volume.
- **Spatial vs non-spatial**: world sounds (a pickaxe hitting rock) are parented to parts so they come from a location; UI sounds play without position.
- **Central sound module**: one client module plays named sounds (`Sound.play("CoinCollect")`), handles pitch variation, pooling and volume, so sounds can be replaced in one place.
- Roblox's modular audio API (audio players, emitters, listeners and wires) is now the recommended path; the docs describe `Sound`, `SoundGroup` and `SoundEffect` as discouraged. Use audio objects for new systems and migrate older ones when you touch them. See [Audio systems](../13-building-it-right/audio-systems.md).

## Performance

- Limit simultaneous instances of the same sound.
- Stop or skip sounds from far away.
- Preload only sounds needed early (`ContentProvider:PreloadAsync` for the first minute's sounds).
- Keep file lengths and counts reasonable; long ambient loops cost memory.

## Accessibility

- Every important audio cue has a visual counterpart (alarm sound plus a flashing indicator).
- Separate volume sliders for music, effects and UI, saved per player.
- No sudden loud sounds outside horror games, and even there, provide a volume setting.

## For agents

- [ ] Core action, reward, UI, rarity and danger sounds exist, with pitch variation on repeats.
- [ ] Music per zone with crossfades; music below effects by default.
- [ ] Sound groups wired to saved volume settings.
- [ ] Every audio asset has a recorded source and rights; none are unlicensed commercial songs.
- [ ] Every important cue has a visual equivalent.

Related: [Game feel and juice](../02-core-loop/game-feel-and-juice.md) · [Asset pipeline](asset-pipeline.md) · [IP and licensing](../17-policy-and-business/ip-and-licensing.md) · [UI principles for Roblox](../05-ui-and-hud/ui-principles.md)
