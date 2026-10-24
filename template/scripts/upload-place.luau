--!strict
-- Uploads a built place file as a SAVED version through Open Cloud (vault: 13-building-it-right/tooling-and-ci.md).
-- House rule: automation never publishes. A Saved version is not live; a human publishes from Studio
-- or Creator Hub after review. This script refuses to do anything else.
--
--   rojo build -o build.rbxl
--   lune run scripts/upload-place build.rbxl
--
-- Environment (never commit these):
--   ROBLOX_API_KEY      Open Cloud key with place publishing permission for this universe
--   ROBLOX_UNIVERSE_ID  universe (experience) id
--   ROBLOX_PLACE_ID     place id

local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")
local serde = require("@lune/serde")

-- Arguments without a literal "--" separator (both `lune run x a` and `lune run x -- a` work).
local args: { string } = {}
for _, arg in process.args do
	if arg ~= "--" then
		table.insert(args, arg)
	end
end

local function fail(message: string): never
	print(`upload-place: {message}`)
	return process.exit(1)
end

for _, arg in args do
	if string.lower(arg) == "published" or string.find(string.lower(arg), "versiontype", 1, true) then
		fail("this script only uploads Saved versions; publishing is a human decision")
	end
end

local path = args[1] or "build.rbxl"
if not fs.isFile(path) then
	fail(`place file not found: {path} (run rojo build first)`)
end
local contentType = if string.match(path, "%.rbxlx$")
	then "application/xml"
	elseif string.match(path, "%.rbxl$") then "application/octet-stream"
	else fail("place file must be .rbxl or .rbxlx")

local apiKey = process.env.ROBLOX_API_KEY
local universeId = process.env.ROBLOX_UNIVERSE_ID
local placeId = process.env.ROBLOX_PLACE_ID
if not apiKey or apiKey == "" then
	fail("ROBLOX_API_KEY is not set")
end
if not universeId or not string.match(universeId, "^%d+$") then
	fail("ROBLOX_UNIVERSE_ID must be a numeric id")
end
if not placeId or not string.match(placeId, "^%d+$") then
	fail("ROBLOX_PLACE_ID must be a numeric id")
end

local url = `https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions?versionType=Saved`
local body = fs.readFile(path)
print(`Uploading {path} ({#body} bytes) to universe {universeId}, place {placeId} as a Saved version...`)

local response = net.request({
	url = url,
	method = "POST",
	headers = {
		["x-api-key"] = apiKey :: string,
		["Content-Type"] = contentType,
	},
	body = body,
})

if not response.ok then
	-- Never echo request headers: they contain the key.
	fail(`HTTP {response.statusCode} {response.statusMessage}: {string.sub(response.body, 1, 400)}`)
end

local ok, decoded = pcall(serde.decode, "json" :: any, response.body)
local version = if ok and type(decoded) == "table" then decoded.versionNumber else nil
print(`Saved version {version or "?"} uploaded. It is NOT live: review it, then publish manually.`)
