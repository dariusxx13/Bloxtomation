--!strict
-- Validators for values received from clients. Every remote argument is `unknown` until checked here.
-- Order of checks: type -> range -> existence/permission (in the system) -> plausibility (in the system).
-- Pure module.

local Validate = {}

function Validate.isFiniteNumber(value: unknown): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

function Validate.integerInRange(value: unknown, min: number, max: number): boolean
	if not Validate.isFiniteNumber(value) then
		return false
	end
	local n = value :: number
	return n == math.floor(n) and n >= min and n <= max
end

-- Non-empty string with a maximum length and only allowed characters (default: letters, digits, _ and -).
function Validate.identifier(value: unknown, maxLength: number?): boolean
	if type(value) ~= "string" then
		return false
	end
	local s = value :: string
	local limit = maxLength or 64
	if #s == 0 or #s > limit then
		return false
	end
	return string.match(s, "^[%w_%-]+$") ~= nil
end

function Validate.boolean(value: unknown): boolean
	return type(value) == "boolean"
end

-- An array of identifiers with at most `maxCount` entries and no duplicates.
function Validate.identifierList(value: unknown, maxCount: number, maxLength: number?): { string }?
	if type(value) ~= "table" then
		return nil
	end
	local list = value :: { [unknown]: unknown }
	local result: { string } = {}
	local seen: { [string]: boolean } = {}
	local count = 0
	local maxIndex = 0
	for key, item in list do
		count += 1
		if count > maxCount then
			return nil
		end
		if not Validate.integerInRange(key, 1, maxCount) or not Validate.identifier(item, maxLength) then
			return nil
		end
		maxIndex = math.max(maxIndex, key :: number)
		local id = item :: string
		if seen[id] then
			return nil
		end
		seen[id] = true
		result[key :: number] = id
	end
	if maxIndex ~= count then
		return nil -- sparse table (holes)
	end
	return result
end

return Validate
