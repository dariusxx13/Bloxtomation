---
title: Audio systems
date: 2026-10-24
tags: [engineering, audio, sound, music, mixing, voice, effects]
aliases: [Audio API, AudioPlayer, Audio wiring, Audio emitters and listeners, Sound engineering]
summary: The engineering side of audio on Roblox - the modular audio objects (AudioPlayer, AudioEmitter, AudioListener, AudioDeviceOutput, Wire and friends) that replace Sound and SoundGroup, 2D and 3D setups, effects and bus-style mixing with faders and sidechain compression, import rules and limits, a client sound module design, and performance and accessibility rules.
audience: [human, agent]
---

# Audio systems

Sound is half of game feel, and Roblox's audio engine has changed. [Audio and music](../07-characters-vfx-and-assets/audio-and-music.md) covers what to play and why; this note covers how audio works in code today. Timing with effects is in [VFX timing and choreography](../19-vfx/vfx-timing-and-choreography.md).

## The modular audio objects (Fact, creator docs, accessed 2026-10-24)

Roblox's docs now describe **`Sound`, `SoundGroup` and `SoundEffect` as discouraged** in favour of modular audio objects that work like real audio equipment:

| Object | Real-world equivalent | Role |
|---|---|---|
| `AudioPlayer` | A media player | Loads and plays an audio asset |
| `AudioEmitter` | A speaker in the world | Emits audio from its parent's position in 3D |
| `AudioListener` | A microphone in the world | Picks up 3D audio (at the camera or the character) |
| `AudioDeviceOutput` | Speakers or headphones | Sends audio to the player's device |
| `AudioDeviceInput` | A physical microphone | Voice input |
| `AudioTextToSpeech` | A voice generator | Converts text to speech (up to 300 characters per request) |
| `AudioSpeechToText` | A transcriber | Converts speech to text |
| `Wire` | A cable | Carries an audio stream from `SourceInstance` to `TargetInstance` |

Objects either **produce** streams (players), **consume** them (emitters, outputs), **modify** them (effects) or **carry** them (wires).

### 2D audio (music, UI sounds)

`AudioPlayer` → `Wire` → `AudioDeviceOutput`, typically under `SoundService`. The sound plays at the same volume wherever the player is.

### 3D audio (sounds in the world)

`AudioPlayer` → `Wire` → `AudioEmitter` (parented to a part or attachment) ... `AudioListener` → `Wire` → `AudioDeviceOutput`. Set `SoundService` listener location to **Character** or **Camera** to have the engine create the listener (and the device output) automatically; **Default** creates a camera listener in voice-enabled games. `AudioEmitter.DistanceAttenuation` is a volume-over-distance curve.

## Effects (Fact, creator docs)

Effects are wired between a player and its output and modify the stream without changing the asset: **Equalizer** (frequency bands, for example muffling underwater), **Compressor** (consistent loudness; has a **Sidechain** input), **Reverb** (rooms and halls), **Chorus**, **Distortion**, **Echo**, **Flanger**, **Pitch Shift**, **Tremolo**, **Fader** (volume) and **Analyzer** (measures loudness and spectrum). Several players can be wired through one effect, and the **order of effects in the chain** changes the result.

## Mixing with buses

The wiring model makes a classic game mix easy:

```text
Music players ─┐
               ├─> Fader "Music"  ─┐
UI players ────┼─> Fader "UI"     ─┼─> Compressor "Master" ─> AudioDeviceOutput
SFX emitters → listener → Fader "World" ─┘
```

- **Settings sliders** set the Fader volume for each bus (music, effects, UI), stored in player settings ([Settings and accessibility](../05-ui-and-hud/INDEX.md)).
- **Ducking:** wire the important bus (for example announcements or voice lines) into the master compressor's Sidechain input so music dips while it plays.
- **Environment:** route world sounds through a reverb or equalizer when the player enters a cave, building or underwater zone.

## Assets (Fact, creator docs)

- Import only audio you have the rights to. The Creator Store offers more than 100,000 free, professionally produced sounds and music tracks.
- Import requirements: one track in `.mp3`, `.ogg`, `.wav` or `.flac`; under 20 MB and 7 minutes; sample rate up to 48 kHz; mono, stereo, 3.0 or 5.1.
- Import limits: 2,000 free audio imports per 30 days for ID-verified creators, 100 for unverified.
- The asset privacy system controls which experiences can use an audio asset; upload audio to the group that owns the game ([Asset pipeline](../07-characters-vfx-and-assets/asset-pipeline.md)).

## A client sound module

Keep sound playback in one client module so sounds can be swapped, pooled and mixed in one place:

```lua
--!strict
-- SoundBank (sketch): named 2D sounds through the UI bus with pitch variation.
local SoundService = game:GetService("SoundService")

local SoundBank = {}

local uiBus: Instance? = nil
local pool: { [string]: { AudioPlayer } } = {}

local ASSETS: { [string]: string } = {
	CoinCollect = "rbxassetid://0", -- replace with group-owned asset ids
	ButtonPress = "rbxassetid://0",
}

local function newPlayer(name: string): AudioPlayer
	local player = Instance.new("AudioPlayer")
	player.Asset = ASSETS[name]
	player.Parent = SoundService
	local wire = Instance.new("Wire")
	wire.SourceInstance = player
	wire.TargetInstance = uiBus
	wire.Parent = player
	return player
end

function SoundBank.init(bus: Instance)
	uiBus = bus
end

function SoundBank.play(name: string, pitchVariation: number?)
	if not ASSETS[name] or not uiBus then
		return
	end
	local list = pool[name]
	if not list then
		list = {}
		pool[name] = list
	end
	local player: AudioPlayer? = nil
	for _, p in list do
		if not p.IsPlaying then
			player = p
			break
		end
	end
	if not player and #list < 4 then
		player = newPlayer(name)
		table.insert(list, player :: AudioPlayer)
	end
	if player then
		local variation = pitchVariation or 0.05
		player.PlaybackSpeed = 1 + (math.random() * 2 - 1) * variation
		player.TimePosition = 0
		player:Play()
	end
end

return SoundBank
```

The pool caps simultaneous copies per sound (four here), which prevents ear-splitting stacks when many coins are collected at once. Check property names against the current API reference when implementing.

## Sound in multiplayer

- **Cosmetic sounds are client-side**, triggered by the same events that trigger effects ([VFX architecture and replication](../19-vfx/vfx-architecture-and-replication.md)).
- **Positional sounds of other players** (footsteps, attacks) play on each client from replicated animations or events.
- **Under server authority**, predicted sounds can be mispredicted; drive them from a synchronised state and allow them to be stopped ([Combat systems and hitboxes](combat-systems-and-hitboxes.md)).
- **Voice chat** uses `AudioDeviceInput` and the same wiring; it is subject to eligibility and safety rules, and features built on players' voices are a policy question for the human.

## Performance and accessibility

- Cap simultaneous sounds per type and globally; most phones handle a few dozen voices comfortably, not hundreds (Rule of thumb).
- Short, compressed effects; stream long music rather than preloading many tracks.
- Distance attenuation and culling for world sounds; do not play inaudible sounds.
- Every important sound has a visual equivalent; many players play muted ([Audio and music](../07-characters-vfx-and-assets/audio-and-music.md)).
- Volume settings per bus; a "reduce loud effects" option for sensitive players.

## Migrating from Sound objects

The template and older games may still use `Sound`. Migrate gradually: new systems use audio objects; when touching an old system, move its sounds to the sound module and buses. Keep behaviour identical and test on phones.

## For agents

- [ ] New audio uses AudioPlayer, emitters, listeners and wires; Sound objects only in legacy code.
- [ ] Music, effects and UI go through separate faders controlled by settings.
- [ ] Sound playback goes through one client module with pooling and caps.
- [ ] All audio assets are group-owned, licensed or original, with records.
- [ ] Important sounds have visual equivalents.

Sources: [Audio](https://create.roblox.com/docs/audio) · [Audio objects](https://create.roblox.com/docs/audio/objects) · [Audio effects](https://create.roblox.com/docs/audio/effects) · [Audio assets](https://create.roblox.com/docs/audio/assets) · [AudioCompressor](https://create.roblox.com/docs/reference/engine/classes/AudioCompressor)

Related: [Audio and music](../07-characters-vfx-and-assets/audio-and-music.md) · [Animation systems](animation-systems.md) · [Game feel and juice](../02-core-loop/game-feel-and-juice.md) · [Performance optimization](performance-optimization.md) · [Asset pipeline](../07-characters-vfx-and-assets/asset-pipeline.md)
