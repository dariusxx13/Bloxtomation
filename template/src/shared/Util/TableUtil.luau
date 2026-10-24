--!strict
-- Small table helpers. Pure module.

local TableUtil = {}

-- Deep copy of plain data (no metatables, no cycles). Used to build new profiles from defaults.
function TableUtil.deepCopy<T>(value: T): T
	if type(value) ~= "table" then
		return value
	end
	local source = value :: any
	local copy = {}
	for key, item in source do
		copy[key] = TableUtil.deepCopy(item)
	end
	return copy :: any
end

-- Fills keys missing from `target` with copies from `template`, recursively for nested string-keyed tables.
-- Arrays in the template are only copied when the target has no value at all.
function TableUtil.reconcile(target: { [any]: any }, template: { [any]: any })
	for key, defaultValue in template do
		local current = target[key]
		if current == nil then
			target[key] = TableUtil.deepCopy(defaultValue)
		elseif type(current) == "table" and type(defaultValue) == "table" and #defaultValue == 0 then
			TableUtil.reconcile(current, defaultValue)
		end
	end
end

function TableUtil.count(t: { [any]: any }): number
	local n = 0
	for _ in t do
		n += 1
	end
	return n
end

function TableUtil.indexOf<T>(list: { T }, value: T): number?
	for i, item in list do
		if item == value then
			return i
		end
	end
	return nil
end

-- Keeps only the last `maxSize` elements of an array (oldest removed first).
function TableUtil.trimFront<T>(list: { T }, maxSize: number)
	local overflow = #list - maxSize
	if overflow > 0 then
		for _ = 1, overflow do
			table.remove(list, 1)
		end
	end
end

return TableUtil
