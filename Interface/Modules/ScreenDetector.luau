local Players = game:GetService("Players")

type CallbackFunction = (screen: ScreenGui) -> ()
type CallbackMap = { [number]: CallbackFunction }

local registeredCallbacks: { [string]: CallbackMap } = {}
local nextCallbackId = 0

local function generateId(): number
	nextCallbackId += 1
	return nextCallbackId
end

local function fireCallbacks(gui: ScreenGui, callbacks: CallbackMap)
	for _, callback in callbacks do
		task.defer(callback, gui)
	end
end

local function findExistingGUI(guiName: string, callback: CallbackFunction)
	for _, child in Players.LocalPlayer.PlayerGui:GetChildren() do
		if not child:IsA("ScreenGui") then
			continue
		end
		if child.Name == guiName then
			task.defer(callback, child :: ScreenGui)
		end
	end
end

local function registerCallback(guiName: string, callback: CallbackFunction): number
	local id = generateId()
	if not registeredCallbacks[guiName] then
		registeredCallbacks[guiName] = {}
	end
	registeredCallbacks[guiName][id] = callback
	return id
end

local function unregisterCallback(guiName: string, id: number)
	local callbacks = registeredCallbacks[guiName]
	if not callbacks then
		return
	end

	callbacks[id] = nil

	if next(callbacks) == nil then
		registeredCallbacks[guiName] = nil
	end
end

local function onChildAdded(child: Instance)
	if not child:IsA("ScreenGui") then
		return
	end
	local gui = child :: ScreenGui
	local callbacks = registeredCallbacks[gui.Name]
	if callbacks then
		fireCallbacks(gui, callbacks)
	end
end

Players.LocalPlayer.PlayerGui.ChildAdded:Connect(onChildAdded)

-- Class

local ScreenGuiDetector = {}
ScreenGuiDetector.__index = ScreenGuiDetector

export type ScreenGuiDetector = typeof(setmetatable(
	{} :: {
		_guiName: string,
		_callbackId: number,
		_destroyed: boolean,
	},
	ScreenGuiDetector
	))

function ScreenGuiDetector.new(
	guiName: string,
	screenAddedCallback: CallbackFunction,
	maid: { Destroy: (self: {}) -> () }?
): ScreenGuiDetector
	assert(type(guiName) == "string", "ScreenGuiDetector.new: argument #1 must be a string")
	assert(type(screenAddedCallback) == "function", "ScreenGuiDetector.new: argument #2 must be a function")

	local self = setmetatable({
		_guiName = guiName,
		_callbackId = 0,
		_destroyed = false,
	}, ScreenGuiDetector)

	local seen = setmetatable({}, { __mode = "k" })
	local function wrappedCallback(gui: ScreenGui)
		if seen[gui] then return end
		seen[gui] = true
		if maid then
			local connection: RBXScriptConnection?
			connection = gui.AncestryChanged:Connect(function(_, parent)
				if connection and not parent then
					connection:Disconnect()
					connection = nil
					ScreenGuiDetector.Destroy(self)
					maid:Destroy()
				end
			end)
		end

		screenAddedCallback(gui)
	end

	self._callbackId = registerCallback(guiName, wrappedCallback)
	findExistingGUI(guiName, wrappedCallback)

	return self
end

function ScreenGuiDetector.Destroy(self: ScreenGuiDetector)
	if self._destroyed then
		return
	end
	self._destroyed = true
	unregisterCallback(self._guiName, self._callbackId)
end

return ScreenGuiDetector
