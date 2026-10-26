--!strict
-- Checks the catalog's rules on the proposed Products config (T-0009, v2 T-0018). Run: lune run check
local process = require("@lune/process")
local Products = require("./Products")

local failures = 0
local function expect(condition: boolean, message: string)
	if condition then
		print(`ok    {message}`)
	else
		failures += 1
		print(`FAIL  {message}`)
	end
end

local keys: { [string]: boolean } = {}
local passCount, productCount = 0, 0

local function grantsCoins(grant: any): boolean
	if grant.kind == "coinsMinutes" then
		return true
	elseif grant.kind == "bundle" then
		for _, inner in grant.grants do
			if grantsCoins(inner) then
				return true
			end
		end
	end
	return false
end

local function grantKinds(grant: any, into: { [string]: boolean })
	into[grant.kind] = true
	if grant.kind == "bundle" then
		for _, inner in grant.grants do
			grantKinds(inner, into)
		end
	end
end

for _, pass in Products.Passes do
	passCount += 1
	expect(not keys[pass.key], `pass {pass.key}: unique key`)
	keys[pass.key] = true
	expect(pass.id == 0, `pass {pass.key}: id is 0 (the human creates it at the build stage)`)
	expect(pass.shownFromStep >= 12, `pass {pass.key}: hidden before onboarding step 12`)
	expect(not (pass.cosmetic and pass.probabilityModifier), `pass {pass.key}: a cosmetic never changes odds`)
	expect(string.find(pass.description, "%d+ ?R") == nil, `pass {pass.key}: no price in the description`)
	expect(
		#pass.description <= 200,
		`pass {pass.key}: description fits in 200 characters ({#pass.description})`
	)
end

local paidLuck = Products.passEffects.luckyBobberSkyLuck
for _, product in Products.Products do
	productCount += 1
	expect(not keys[product.key], `product {product.key}: unique key`)
	keys[product.key] = true
	expect(product.id == 0, `product {product.key}: id is 0`)
	expect(product.shownFromStep >= 12, `product {product.key}: hidden before onboarding step 12`)
	expect(
		grantsCoins(product.grant) == product.fundsRandomItems,
		`product {product.key}: fundsRandomItems is true exactly when it grants coins`
	)
	local kinds: { [string]: boolean } = {}
	grantKinds(product.grant, kinds)
	expect(
		not kinds.gems and not kinds.serverBoost,
		`product {product.key}: no gems and no serverBoost grants`
	)
	if kinds.skyCall then
		expect(
			product.probabilityModifier,
			`product {product.key}: a Sky Bell call is a probability modifier`
		)
		expect(not product.oncePerPlayer, `product {product.key}: a Sky Bell call is repeatable`)
	end
	expect(
		string.find(product.description, "%d+ ?R") == nil,
		`product {product.key}: no price in the description`
	)
	if grantsCoins(product.grant) then
		-- Economy sheet v2 §19.2: one basis, and the copy says "minutes of fishing", never "your" rate.
		expect(
			string.find(product.description, "of fishing") ~= nil
				and string.find(product.description, "your current") == nil,
			`product {product.key}: coin copy reads "about M minutes of fishing" (sheet v2 §19.2)`
		)
	end
	expect(
		#product.description <= 200,
		`product {product.key}: description fits in 200 characters ({#product.description})`
	)
end

expect(Products.passByKey.luckyBobber.probabilityModifier, "Lucky Bobber is a probability modifier")
expect(paidLuck <= 0.25, `Lucky Bobber paid luck {paidLuck} is inside the +25% paid cap`)
expect(Products.boostEffects.luck2x == nil, "template Luck Potion boost removed (x2 exceeds the paid cap)")
expect(
	Products.boostEffects.serverLuck == nil,
	"template Server Luck boost removed (replaced by the Sky Bell)"
)
expect(Products.passEffects.autoReelSuccess < 0.85, "Auto Reel lands fewer fish than a casual player (85%)")
expect(Products.passEffects.x2CoinsFromZone == "lantern_reef", "2x Coins starts at the first bridge")
local count = 0
for _ in Products.boostEffects do
	count += 1
end
expect(count == 2, "boosts: coins2x (sold in the Starter Pack) and luckyTide (free only)")
expect(
	passCount == 8 and productCount == 7,
	`8 passes and 7 developer products ({passCount}, {productCount})`
)

print(if failures == 0 then "All catalog config checks passed." else `{failures} check(s) failed.`)
process.exit(if failures == 0 then 0 else 1)
