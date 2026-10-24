--!strict
-- Token-bucket rate limiter keyed by (owner, action). Pure: the clock is injected so tests can control time.
-- Usage on the server: local limiter = RateLimiter.new(os.clock); if not limiter:allow(player, "Hit", 7, 10) then return end

local RateLimiter = {}
RateLimiter.__index = RateLimiter

type Bucket = { tokens: number, last: number }

export type RateLimiter = typeof(setmetatable(
	{} :: {
		clock: () -> number,
		buckets: { [any]: { [string]: Bucket } },
		violations: { [any]: number },
	},
	RateLimiter
))

function RateLimiter.new(clock: () -> number): RateLimiter
	return setmetatable({ clock = clock, buckets = {}, violations = {} }, RateLimiter)
end

function RateLimiter.allow(self: RateLimiter, owner: any, action: string, ratePerSecond: number, burst: number): boolean
	local now = self.clock()
	local ownerBuckets = self.buckets[owner]
	if not ownerBuckets then
		ownerBuckets = {}
		self.buckets[owner] = ownerBuckets
	end
	local bucket = ownerBuckets[action]
	if not bucket then
		bucket = { tokens = burst, last = now }
		ownerBuckets[action] = bucket
	end
	bucket.tokens = math.min(burst, bucket.tokens + (now - bucket.last) * ratePerSecond)
	bucket.last = now
	if bucket.tokens < 1 then
		self.violations[owner] = (self.violations[owner] or 0) + 1
		return false
	end
	bucket.tokens -= 1
	return true
end

function RateLimiter.violationCount(self: RateLimiter, owner: any): number
	return self.violations[owner] or 0
end

-- Call on PlayerRemoving so per-player state does not leak.
function RateLimiter.forget(self: RateLimiter, owner: any)
	self.buckets[owner] = nil
	self.violations[owner] = nil
end

return RateLimiter
