--!strict
-- Number and time formatting. Pure: safe to require from Lune tests and from both client and server.

local Format = {}

local SUFFIXES = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }

-- "15.50" -> "15.5", "2.00" -> "2", "100" -> "100" (only trims after a decimal point)
function Format.trimZeros(text: string): string
	if not string.find(text, ".", 1, true) then
		return text
	end
	local trimmed = string.gsub(text, "0+$", "")
	trimmed = string.gsub(trimmed, "%.$", "")
	return trimmed
end

-- 1234 -> "1.23K", 15300000 -> "15.3M". Always 3 significant digits above 1,000.
function Format.short(value: number): string
	if value ~= value then
		return "0"
	end
	local negative = value < 0
	local n = math.abs(value)
	if n < 1000 then
		local text = if n == math.floor(n) then tostring(math.floor(n)) else string.format("%.1f", n)
		return if negative then "-" .. text else text
	end
	local tier = math.floor(math.log10(n) / 3)
	local text: string
	if tier >= #SUFFIXES then
		text = string.format("%.2e", n)
	else
		local scaled = n / 10 ^ (tier * 3)
		-- Avoid "1000K": rounding can push scaled to 1000
		if scaled >= 999.5 then
			tier += 1
			scaled = n / 10 ^ (tier * 3)
		end
		if tier >= #SUFFIXES then
			text = string.format("%.2e", n)
		else
			local decimals = if scaled >= 100 then 0 elseif scaled >= 10 then 1 else 2
			text = Format.trimZeros(string.format("%." .. decimals .. "f", scaled)) .. SUFFIXES[tier + 1]
		end
	end
	return if negative then "-" .. text else text
end

-- 1234567 -> "1,234,567"
function Format.commas(value: number): string
	local text = tostring(math.floor(value))
	local negative = string.sub(text, 1, 1) == "-"
	if negative then
		text = string.sub(text, 2)
	end
	local formatted = string.reverse((string.gsub(string.reverse(text), "(%d%d%d)", "%1,")))
	if string.sub(formatted, 1, 1) == "," then
		formatted = string.sub(formatted, 2)
	end
	return if negative then "-" .. formatted else formatted
end

-- 3725 -> "1h 2m", 125 -> "2m 5s", 9 -> "9s"
function Format.duration(seconds: number): string
	local s = math.max(0, math.floor(seconds))
	local h = s // 3600
	local m = (s % 3600) // 60
	local sec = s % 60
	if h > 0 then
		return string.format("%dh %dm", h, m)
	elseif m > 0 then
		return string.format("%dm %ds", m, sec)
	end
	return string.format("%ds", sec)
end

-- 0.0123 -> "1.23%", 0.000001 -> "0.0001%"
function Format.percent(probability: number): string
	local p = probability * 100
	if p >= 10 then
		return string.format("%.1f%%", p)
	elseif p >= 1 then
		return string.format("%.2f%%", p)
	elseif p >= 0.01 then
		return string.format("%.3f%%", p)
	end
	return Format.trimZeros(string.format("%.6f", p)) .. "%"
end

-- 0.004 -> "1 in 250"
function Format.oneIn(probability: number): string
	if probability <= 0 then
		return "never"
	end
	return "1 in " .. Format.commas(math.floor(1 / probability + 0.5))
end

return Format
