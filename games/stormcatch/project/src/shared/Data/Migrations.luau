--!strict
-- Ordered migration steps from one schema version to the next. Pure module.
-- Add a step when you bump Schema.VERSION:
--   STEPS[1] = function(data) ... return data end   -- migrates version 1 -> 2
-- Steps must be deterministic and must not yield (they run inside DataStore UpdateAsync).

local Schema = require("./Schema")

local Migrations = {}

local STEPS: { [number]: (any) -> any } = {
	-- 1 -> 2 (Reel the Storm prototype): fishing stats and the Pebble Cove zone. Nothing is removed; template
	-- fields the prototype does not use (gems, pets, daily, codes) stay so the build stage can use them.
	[1] = function(data)
		local stats = if type(data.stats) == "table" then data.stats else {}
		data.stats = stats
		for _, field in { "catches", "rainCatches", "stormsJoined", "giantsLanded", "helps" } do
			if type(stats[field]) ~= "number" then
				stats[field] = 0
			end
		end
		local zones = if type(data.zonesUnlocked) == "table" then data.zonesUnlocked else {}
		data.zonesUnlocked = zones
		zones.pebble_cove = true
		return data
	end,
}

-- Runs all steps from the stored version to Schema.VERSION, then fills missing fields.
-- Errors if a step is missing (better to refuse loading than to corrupt a save).
function Migrations.migrate(data: any, steps: { [number]: (any) -> any }?, targetVersion: number?): any
	local useSteps = steps or STEPS
	local target = targetVersion or Schema.VERSION
	if type(data.version) ~= "number" then
		data.version = 1
	end
	if data.version > target then
		error(`profile version {data.version} is newer than this server ({target}); refusing to load`)
	end
	while data.version < target do
		local step = useSteps[data.version]
		if not step then
			error(`missing migration from version {data.version}`)
		end
		data = step(data)
		data.version += 1
	end
	Schema.reconcile(data)
	return data
end

return Migrations
