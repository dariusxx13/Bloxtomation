--!strict
-- Minimal test helpers for Lune. Each spec file returns function(test: TestKit.Test).

export type Test = (name: string, body: () -> ()) -> ()

local TestKit = {}

function TestKit.equal(actual: any, expected: any, message: string?)
	if actual ~= expected then
		error(`{message or "values differ"}: expected {tostring(expected)}, got {tostring(actual)}`, 2)
	end
end

function TestKit.near(actual: number, expected: number, tolerance: number, message: string?)
	if math.abs(actual - expected) > tolerance then
		error(`{message or "not near"}: expected {expected} ± {tolerance}, got {actual}`, 2)
	end
end

function TestKit.truthy(value: any, message: string?)
	if not value then
		error(message or "expected a truthy value", 2)
	end
end

function TestKit.throws(fn: () -> (), message: string?)
	local ok = pcall(fn)
	if ok then
		error(message or "expected an error", 2)
	end
end

-- Deterministic pseudo-random generator (LCG) so distribution tests are reproducible in Lune.
function TestKit.rng(seed: number): () -> number
	local state = seed % 2147483647
	if state <= 0 then
		state += 2147483646
	end
	return function(): number
		state = (state * 16807) % 2147483647
		return (state - 1) / 2147483646
	end
end

return TestKit
