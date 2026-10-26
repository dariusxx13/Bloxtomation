--!strict
-- "No purchase prompt can open" (prototype brief req. 1 and its acceptance criterion): every pass and product
-- id is 0, no source file calls a MarketplaceService prompt, and the Shop has no Robux tab.
local fs = require("@lune/fs")
local TestKit = require("./TestKit")
local Products = require("../src/shared/Config/Products")

local PROMPTS = {
	"PromptProductPurchase",
	"PromptGamePassPurchase",
	"PromptPurchase",
	"PromptBundlePurchase",
	"PromptPremiumPurchase",
	"PromptSubscriptionPurchase",
	"PromptRobloxPurchase",
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
	test("every pass and product id is 0", function()
		for _, pass in Products.Passes do
			TestKit.equal(pass.id, 0, pass.key)
		end
		for _, product in Products.Products do
			TestKit.equal(product.id, 0, product.key)
		end
	end)

	test("no source file can open a purchase prompt", function()
		local files: { string } = {}
		luauFiles("src", files)
		TestKit.truthy(#files > 20, "scanned the source tree")
		for _, path in files do
			local source = fs.readFile(path)
			for _, prompt in PROMPTS do
				TestKit.truthy(string.find(source, prompt .. "(", 1, true) == nil, `{path} calls {prompt}`)
			end
		end
	end)

	test("the Shop shows the Upgrades list only (no passes or Robux tab)", function()
		local source = fs.readFile("src/client/Controllers/Shop.luau")
		for _, word in { "Passes", "Robux", "R$", "productByKey", "passByKey", "Products" } do
			TestKit.truthy(string.find(source, word, 1, true) == nil, `Shop mentions {word}`)
		end
	end)
end
