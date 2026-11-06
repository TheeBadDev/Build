
type Callack = <a, b>(index: a, value: b, ...any?)->()

local function RandomizeList<a>(list: {a}): {a}
     local result = table.clone(list)
    
    for i = #result, 2, -1 do
        local j = math.random(i)
        result[i], result[j] = result[j], result[i]
    end
    
    return result
end


local function GetRandomKey<a>(list: {[a]: any}): a
    local keys = {} :: {}?
    
    for key in list do
        table.insert(keys, key)
    end
    local value = keys[math.random(#keys)]
    keys = nil
    
    return value
end

local function GetRandomValue<a, b>(list: {[a]: b}): b
    local key = GetRandomKey(list)
    return list[key]
end

local function GetTableOfRandomValues<a, b>(list: {[a]: b}, amount: number): {b}
	const keys = {}
	for key in list do
		table.insert(keys, key)
	end

	const result = {}
	const keyCount = #keys

	for i = 1, math.min(amount, keyCount) do
		const randomIndex = math.random(i, keyCount)
		keys[i], keys[randomIndex] = keys[randomIndex], keys[i]
		table.insert(result, list[keys[i]])
	end

	return result
end

-- Returns keys that have a word in them
local function GetKeyIndexWithWord(list: {[string]: any}, word: string): {string}
	local result = {}
	local searchWord = string.lower(word)

	for key, _ in pairs(list) do
		local lowerKey = string.lower(tostring(key))

		if string.find(lowerKey, searchWord, 1, true) then
			table.insert(result, key)
		end
	end

	return result
end

local function TableCallback<a,b>(list: {[a]: b},callback: Callack,...)
	for index: a, value: b in list do
		callback(index,value,...)
	end
end

return {
	Callback = TableCallback,
    Randomize = RandomizeList,
    RandomKey = GetRandomKey,
	RandomValue = GetRandomValue,
	RandomValueTable = GetTableOfRandomValues,
    AllIndexWithWord = GetKeyIndexWithWord,
}