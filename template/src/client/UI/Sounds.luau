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

-- Plays a named sound from Config/Game.sounds. `pitch` defaults to ~1 with +-6% variation.
function Sounds.play(name: string, pitch: number?)
	if not Sounds.enabled then
		return
	end
	local sound = get(name)
	if not sound then
		return
	end
	sound.PlaybackSpeed = (pitch or 1) * rng:NextNumber(0.94, 1.06)
	SoundService:PlayLocalSound(sound)
end

return Sounds
