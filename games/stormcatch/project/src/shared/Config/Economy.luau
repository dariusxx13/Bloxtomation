--!strict
-- Game-wide economy values that are not one system's (the prototype's catch economy lives in
-- Config/Fishing, Config/Species and Config/Upgrades; economy sheet v2 §14).

local Economy = {
	baseWalkSpeed = 16, -- studs per second (template value; world plan §3 builds every distance on it)
	-- "Minutes of income" = coins per catch at the player's best island in Clear x this (economy sheet §3.1).
	-- Only product grants use it, and the prototype sells nothing.
	assumedCatchesPerMinute = 5,
}

return table.freeze(Economy)
