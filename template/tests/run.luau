--!strict
-- Runs every *.spec.luau file in tests/ with Lune: `lune run tests/run`
-- Exits with code 1 if any test fails (used by CI).

local fs = require("@lune/fs")
local process = require("@lune/process")

local passed = 0
local failed = 0

local files = fs.readDir("tests")
table.sort(files)

for _, file in files do
	if string.match(file, "%.spec%.luau$") then
		local moduleName = string.gsub(file, "%.luau$", "")
		local spec = (require :: any)("./" .. moduleName)
		print(`\n{file}`)
		spec(function(name: string, body: () -> ())
			local ok, err = pcall(body)
			if ok then
				passed += 1
				print(`  ok    {name}`)
			else
				failed += 1
				print(`  FAIL  {name}\n        {err}`)
			end
		end)
	end
end

print(`\n{passed} passed, {failed} failed`)
process.exit(if failed > 0 then 1 else 0)
