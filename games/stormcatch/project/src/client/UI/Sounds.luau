--!strict
-- UI and feedback sounds with a little pitch variation so repeats do not fatigue (vault: 07-characters-vfx-and-assets/audio-and-music.md).
-- `Sounds.enabled` follows the player's SFX setting (set by the Settings controller).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Game = require(ReplicatedStorage.Shared.Config.Game)

local Sounds = {}

Sounds.enabled = true

local cache: { [string]: Sound } = {}
local rng = Random.new()

local function get(name: string): Sound?
	local existing = cache[name]
	if existing then
		return existing
	end
	local id = (Game.sounds :: any)[name]
	if type(id) ~= "string" then
		return nil
	end
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = id
	sound.Volume = 0.5
	sound.Parent = SoundService
	cache[name] = sound
	return sound
end

-- Plays a named sound from Config/Game.sounds. `pitch` defaults to 1; `variation` (default 0.06) randomises
-- it by up to +-variation so repeats do not fatigue (juice layer 1 uses 0.10).
function Sounds.play(name: string, pitch: number?, variation: number?)
	if not Sounds.enabled then
		return
	end
	local sound = get(name)
	if not sound then
		return
	end
	local spread = variation or 0.06
	sound.PlaybackSpeed = (pitch or 1) * rng:NextNumber(1 - spread, 1 + spread)
	SoundService:PlayLocalSound(sound)
end

-- A looped sound whose volume the caller tweens (the storm swell). Returns nil if the id is unknown.
function Sounds.loop(name: string, pitch: number): Sound?
	local id = (Game.sounds :: any)[name]
	if type(id) ~= "string" then
		return nil
	end
	local sound = Instance.new("Sound")
	sound.Name = name .. "Loop"
	sound.SoundId = id
	sound.Looped = true
	sound.Volume = 0
	sound.PlaybackSpeed = pitch
	sound.Parent = SoundService
	return sound
end

return Sounds
