--!strict
local TestKit = require("./TestKit")
local Format = require("../src/shared/Util/Format")

return function(test: TestKit.Test)
	test("short formats small numbers without suffix", function()
		TestKit.equal(Format.short(0), "0")
		TestKit.equal(Format.short(999), "999")
		TestKit.equal(Format.short(12.5), "12.5")
	end)

	test("short uses suffixes with three significant digits", function()
		TestKit.equal(Format.short(1000), "1K")
		TestKit.equal(Format.short(1234), "1.23K")
		TestKit.equal(Format.short(15300000), "15.3M")
		TestKit.equal(Format.short(100000), "100K")
		TestKit.equal(Format.short(2500000000), "2.5B")
	end)

	test("short never prints 1000K", function()
		TestKit.equal(Format.short(999999), "1M")
	end)

	test("short handles negatives and NaN", function()
		TestKit.equal(Format.short(-1500), "-1.5K")
		TestKit.equal(Format.short(0 / 0), "0")
	end)

	test("commas", function()
		TestKit.equal(Format.commas(1234567), "1,234,567")
		TestKit.equal(Format.commas(999), "999")
		TestKit.equal(Format.commas(-1000), "-1,000")
	end)

	test("duration", function()
		TestKit.equal(Format.duration(9), "9s")
		TestKit.equal(Format.duration(125), "2m 5s")
		TestKit.equal(Format.duration(3725), "1h 2m")
	end)

	test("percent and oneIn", function()
		TestKit.equal(Format.percent(0.5), "50.0%")
		TestKit.equal(Format.percent(0.0123), "1.23%")
		TestKit.equal(Format.percent(0.000001), "0.0001%")
		TestKit.equal(Format.oneIn(0.004), "1 in 250")
	end)
end
