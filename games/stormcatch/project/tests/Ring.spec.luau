--!strict
-- The server's ring judgement (prototype brief req. 3.4 and 14): lap, arc, start time and tap time, with the
-- latency allowance min(ping, 250 ms) + 60 ms; and the flash-window test for Charged landing taps (req. 9.5).
local TestKit = require("./TestKit")
local Ring = require("../src/shared/Util/Ring")

return function(test: TestKit.Test)
	-- Clear ring: lap 1.6 s, 90 degree arc centred at 180 (green from 135 to 225 degrees).
	local clear: Ring.Params = { start = 100, lap = 1.6, arcCenter = 180, arcWidth = 90 }

	test("marker angle runs clockwise from the start, once per lap", function()
		TestKit.near(Ring.markerAngle(clear, 100), 0, 1e-9)
		TestKit.near(Ring.markerAngle(clear, 100.4), 90, 1e-9)
		TestKit.near(Ring.markerAngle(clear, 100.8), 180, 1e-9)
		local lap = Ring.markerAngle(clear, 101.6)
		TestKit.near(math.min(lap, 360 - lap), 0, 1e-9, "a full lap is back at 0")
		TestKit.near(Ring.markerAngle(clear, 102.0), 90, 1e-9)
	end)

	test("allowance is min(ping, 0.25) + 0.06 and ignores junk pings", function()
		TestKit.near(Ring.allowance(0), 0.06, 1e-9)
		TestKit.near(Ring.allowance(0.1), 0.16, 1e-9)
		TestKit.near(Ring.allowance(0.9), 0.31, 1e-9)
		TestKit.near(Ring.allowance(0 / 0), 0.06, 1e-9)
		TestKit.near(Ring.allowance(-1), 0.06, 1e-9)
	end)

	test("a tap with the marker on the arc is good; off the arc is a miss", function()
		TestKit.truthy(Ring.judge(clear, 100.8, 0), "centre")
		TestKit.truthy(Ring.judge(clear, 100 + 0.62, 0), "139.5 degrees, inside")
		TestKit.truthy(Ring.judge(clear, 100 + 0.95, 0), "213.75 degrees, inside")
		TestKit.truthy(not Ring.judge(clear, 100.2, 0), "45 degrees")
		TestKit.truthy(not Ring.judge(clear, 100 + 0.55, 0), "123.75 degrees, before the arc")
		TestKit.truthy(not Ring.judge(clear, 100 + 1.05, 0), "236.25 degrees, after the arc")
		TestKit.truthy(Ring.judge(clear, 100.8 + 1.6 * 5, 0), "five laps later")
	end)

	test("the allowance accepts a tap that arrives late by up to the allowance", function()
		-- Marker left the arc at 225 degrees (t = 101.0). A tap arriving at 101.05 (236.25 degrees):
		TestKit.truthy(not Ring.judge(clear, 101.05, 0.0), "no allowance: miss")
		TestKit.truthy(not Ring.judge(clear, 101.05, 0.04), "0.04 s: still past the arc")
		TestKit.truthy(Ring.judge(clear, 101.05, 0.06), "0.06 s (the minimum allowance): good")
		TestKit.truthy(Ring.judge(clear, 101.05 + 0.25, Ring.allowance(0.3)), "0.31 s allowance")
		TestKit.truthy(not Ring.judge(clear, 101.05 + 0.3, Ring.allowance(0.3)), "beyond the allowance")
	end)

	test("taps before the ring starts never count; the arc wraps past 360", function()
		TestKit.truthy(not Ring.judge(clear, 99.9, 0.31), "before start")
		local wrapped: Ring.Params = { start = 0, lap = 1.1, arcCenter = 350, arcWidth = 150 } -- 275..65
		TestKit.truthy(Ring.judge(wrapped, 1.1 * (300 / 360), 0), "300 degrees")
		TestKit.truthy(Ring.judge(wrapped, 1.1 * (10 / 360) + 1.1, 0), "10 degrees on lap 2")
		TestKit.truthy(not Ring.judge(wrapped, 1.1 * (180 / 360), 0), "180 degrees")
	end)

	test("the next arc lands 120-240 degrees ahead of the marker", function()
		TestKit.near(Ring.nextArcCenter(10, 0), 130, 1e-9)
		TestKit.near(Ring.nextArcCenter(300, 0.5), 120, 1e-9)
		TestKit.near(Ring.nextArcCenter(200, 0.999999), 79.99976, 1e-3)
	end)

	test("a landing tap counts on a flash only inside a flash window (0.8 s, with the allowance)", function()
		local flashes = { 50, 58.5 }
		TestKit.truthy(Ring.onFlash(flashes, 0.8, 50.0, 0.06), "at the flash")
		TestKit.truthy(Ring.onFlash(flashes, 0.8, 50.79, 0.06), "late in the window")
		TestKit.truthy(Ring.onFlash(flashes, 0.8, 50.85, 0.06), "just after, within the allowance")
		TestKit.truthy(not Ring.onFlash(flashes, 0.8, 50.95, 0.06), "after the window")
		TestKit.truthy(not Ring.onFlash(flashes, 0.8, 49.9, 0.31), "before the flash")
		TestKit.truthy(not Ring.onFlash({}, 0.8, 50, 0.31), "no flashes")
	end)
end
