--!strict
-- BUILD-04 by source scan: every remote the code uses is declared in Config/Remotes (with a rate limit when a
-- client sends it), every client-to-server remote has exactly one server handler, and no file but Net touches
-- raw RemoteEvent / RemoteFunction APIs.
local fs = require("@lune/fs")
local TestKit = require("./TestKit")
local Remotes = require("../src/shared/Config/Remotes")

local RAW = {
	":FireServer(",
	".OnServerEvent",
	":InvokeServer(",
	".OnServerInvoke",
	":FireClient(",
	":FireAllClients(",
	".OnClientEvent",
	'Instance.new("RemoteEvent")',
	'Instance.new("RemoteFunction")',
	'Instance.new("UnreliableRemoteEvent")',
}

local function luauFiles(dir: string, out: { string })
	for _, name in fs.readDir(dir) do
		local path = dir .. "/" .. name
		if fs.isDir(path) then
			luauFiles(path, out)
		elseif string.match(name, "%.luau$") then
			table.insert(out, path)
		end
	end
end

return function(test: TestKit.Test)
	local files: { string } = {}
	luauFiles("src", files)
	local sources: { [string]: string } = {}
	for _, path in files do
		-- code only: comments (which quote usage examples) are stripped
		sources[path] = (string.gsub(fs.readFile(path), "%-%-[^\n]*", ""))
	end

	test("every remote used through Net is declared, and client-sent ones are rate limited", function()
		local used = 0
		for path, source in sources do
			for fn, name in string.gmatch(source, 'Net%.(%a+)%(%s*"(%w+)"') do
				used += 1
				local def = Remotes[name]
				TestKit.truthy(def ~= nil, `{path}: Net.{fn}("{name}") is not declared`)
				if fn == "handle" or fn == "fire" or fn == "invoke" then
					TestKit.truthy(def.rate ~= nil and def.burst ~= nil, `{name} has no rate limit`)
				end
			end
		end
		TestKit.truthy(used > 20, `found {used} Net calls`)
	end)

	test("every client-to-server remote has exactly one Net.handle on the server", function()
		local handled: { [string]: number } = {}
		for path, source in sources do
			if string.find(path, "src/server/", 1, true) then
				for name in string.gmatch(source, 'Net%.handle%(%s*"(%w+)"') do
					handled[name] = (handled[name] or 0) + 1
				end
			end
		end
		for name, def in Remotes do
			if def.rate ~= nil then
				TestKit.equal(handled[name], 1, `{name} handlers`)
			end
		end
	end)

	test("no raw remote API outside src/shared/Net.luau", function()
		for path, source in sources do
			if not string.find(path, "src/shared/Net.luau", 1, true) then
				for _, raw in RAW do
					TestKit.truthy(string.find(source, raw, 1, true) == nil, `{path} uses {raw}`)
				end
			end
		end
	end)
end
