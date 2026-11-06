const INIT_FUNCTION_NAME = 'Init'
const MAIN_FUNCTRION_NAME = 'Main'
const REQUIRE_TIMEOUT = 5

local function hasValidExtension(moduleName: string, extension: string): boolean
	return moduleName:sub(-#extension) == extension
end

local function safeGet(result: any, key: string): unknown
	const success, value = pcall(function()
		return result[key]
	end)
	if success then
		return value
	end
	return nil
end

local function exicuteFunction(functionName: string, moduleScript: ModuleScript, moduleResult: {[string]: unknown})
	const candidate = safeGet(moduleResult, functionName)

	if typeof(candidate) == "function" then
		const success, errorMessage = pcall(candidate)
		if not success then
			warn(`{moduleScript} ModuleScript ERROR: {errorMessage}`)
		end
	end
end

local function ExicuteInitFunctions(moduleScript: ModuleScript, moduleResult: {[string]: unknown})
	exicuteFunction(INIT_FUNCTION_NAME,moduleScript,moduleResult)
end

local function ExicuteMainFunctions(moduleScript: ModuleScript, moduleResult: {[string]: unknown} | ()->())
	if typeof(moduleResult) == "function" then
		const success, errorMessage = pcall(moduleResult)
		if not success then
			warn(`{moduleScript} ModuleScript ERROR: {errorMessage}`)
		end
	else
		exicuteFunction(MAIN_FUNCTRION_NAME,moduleScript,moduleResult)
	end
end

local function loadModules(folder: Folder, extension: string): ({[ModuleScript]: {[string]: unknown}}, {[ModuleScript]: {[string]: unknown} | ()->()})

	local initModules = {}
	local mainModules = {}
	local pending = 0
	local closed = false

	for _, moduleScript in folder:QueryDescendants('ModuleScript') do

		if not hasValidExtension(moduleScript.Name,extension) then continue end

		pending += 1

		task.spawn(function()
			const success, result = pcall(require, moduleScript)
			pending -= 1

			if closed then return end

			if not success then
				warn(`[ModuleLoader] Failed to require {moduleScript}: {result}`)
				return
			end

			if typeof(result) == 'table' then
				if safeGet(result, INIT_FUNCTION_NAME) then
					initModules[moduleScript] = result
				end
				if safeGet(result, MAIN_FUNCTRION_NAME) then
					mainModules[moduleScript] = result
				end
			elseif typeof(result) == 'function' then
				mainModules[moduleScript] = result
			end
		end)
	end

	const deadline = os.clock() + REQUIRE_TIMEOUT
	while pending > 0 and os.clock() < deadline do
		task.wait()
	end
	closed = true

	if pending > 0 then
		warn(`[ModuleLoader] {pending} module(s) timed out while loading`)
	end

	return initModules, mainModules
end

return {
	Fire = function(folder: Folder, extension: string)
		const initModules, mainModules = loadModules(folder,extension)

		for moduleScript, moduleResult in initModules do
			ExicuteInitFunctions(moduleScript, moduleResult)
		end

		for moduleScript, moduleResult in mainModules do
			task.spawn(ExicuteMainFunctions,moduleScript,moduleResult)
		end
	end,
}