--!strict
-- Remote input validation: garbage in must be rejected.
local TestKit = require("./TestKit")
local Validate = require("../src/shared/Util/Validate")
local RateLimiter = require("../src/shared/Util/RateLimiter")

return function(test: TestKit.Test)
	test("integerInRange rejects NaN, infinity, fractions, wrong types", function()
		TestKit.truthy(Validate.integerInRange(3, 1, 3))
		TestKit.truthy(not Validate.integerInRange(0 / 0, 1, 3))
		TestKit.truthy(not Validate.integerInRange(math.huge, 1, 3))
		TestKit.truthy(not Validate.integerInRange(2.5, 1, 3))
		TestKit.truthy(not Validate.integerInRange("2", 1, 3))
		TestKit.truthy(not Validate.integerInRange(nil, 1, 3))
		TestKit.truthy(not Validate.integerInRange(4, 1, 3))
	end)

	test("identifier accepts ids and rejects junk", function()
		TestKit.truthy(Validate.identifier("meadow_egg"))
		TestKit.truthy(not Validate.identifier(""))
		TestKit.truthy(not Validate.identifier("a b"))
		TestKit.truthy(not Validate.identifier(string.rep("a", 200)))
		TestKit.truthy(not Validate.identifier({}))
		TestKit.truthy(not Validate.identifier(12))
	end)

	test("identifierList rejects sparse, oversized and duplicate lists", function()
		TestKit.truthy(Validate.identifierList({ "a", "b" }, 5) ~= nil)
		TestKit.truthy(Validate.identifierList({ "a", "a" }, 5) == nil)
		TestKit.truthy(Validate.identifierList({ "a", "b", "c" }, 2) == nil)
		TestKit.truthy(Validate.identifierList({ [1] = "a", [3] = "c" }, 5) == nil)
		TestKit.truthy(Validate.identifierList({ x = "a" }, 5) == nil)
		TestKit.truthy(Validate.identifierList("a", 5) == nil)
	end)

	test("rate limiter allows a burst then blocks, then refills", function()
		local now = 0
		local limiter = RateLimiter.new(function()
			return now
		end)
		local allowed = 0
		for _ = 1, 20 do
			if limiter:allow("p1", "Hit", 5, 10) then
				allowed += 1
			end
		end
		TestKit.equal(allowed, 10, "burst")
		TestKit.truthy(limiter:violationCount("p1") == 10)
		now = 1
		allowed = 0
		for _ = 1, 20 do
			if limiter:allow("p1", "Hit", 5, 10) then
				allowed += 1
			end
		end
		TestKit.equal(allowed, 5, "refill after one second")
		limiter:forget("p1")
		TestKit.equal(limiter:violationCount("p1"), 0)
	end)
end
