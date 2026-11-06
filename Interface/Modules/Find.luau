

export type InstanceSelector = {
	GuiButton: (name: string?) -> GuiButton,
	TextLabel: (name: string?) -> TextLabel,
	TextButton: (name: string?) -> TextButton,
	Frame: (name: string?) -> Frame,
	ScrollingFrame: (name: string?) -> ScrollingFrame,
	ImageLabel: (name: string?) -> ImageLabel,
	ImageButton: (name: string?) -> ImageButton,
	GuiObject: (name: string?) -> GuiObject,
	UIListLayout: (name: string?) -> UIListLayout,
	UIStroke: (name: string?) -> UIStroke,
}



const DURATION = 10


local function waitForDuration(parentInstance: Instance, instnceType: string, instanceName: string?): Instance?
	local connection: RBXScriptConnection?
	local foundDescendant: Instance?

	local timeStarted = os.clock()

	local function cleanUpConnection()
		if not connection then return end
		connection:Disconnect()
		connection = nil
	end

	connection = parentInstance.DescendantAdded:Connect(function(child: Instance)
		if child.ClassName ~= instnceType then return end
		if instanceName and instanceName ~= child.Name then return end
		foundDescendant = child
		cleanUpConnection()
	end)

	while  connection and (os.clock() - timeStarted) < DURATION do
		task.wait(0.5)
	end

	cleanUpConnection()
	return foundDescendant
end

--Find firstChild
local function findInstance<a>(parentInstance: Instance, instnceType: string, instanceName: string?): a
	const selector = instanceName and `{instnceType} [Name = {instanceName}]` or `{instnceType}`
	const firstChild = parentInstance:QueryDescendants(`> {selector}`)
	const findDecendant = parentInstance:QueryDescendants(selector)
	
	if firstChild[1] or findDecendant[1] then
		return firstChild[1] or findDecendant[1]
	end
	
	const addedInstance = waitForDuration(parentInstance,instnceType,instanceName) 
	assert(addedInstance,`{instnceType}: Named {instanceName} not found in {parentInstance}`)
	
	return addedInstance
end


return function(context: Instance): InstanceSelector
	return setmetatable({}, {
		__index = function(_, className: string)
			return function(instanceName: string?): any
				return findInstance(context, className, instanceName)
			end
		end
	}) :: InstanceSelector 
end