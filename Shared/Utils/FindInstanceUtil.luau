



local function waitForDuration(instance: Instance, duration: number, queryName: string, class: boolean?): Instance?
    local connection: RBXScriptConnection?
    local foundDescendant: Instance?

    local timeStarted = os.clock()

	local function cleanUpConnection()
		if not connection then return end
		connection:Disconnect()
		connection = nil
	end

    connection = instance.DescendantAdded:Connect(function(child: Instance)
       if (not class and child.Name ~= queryName) or (class and child.ClassName ~= queryName) then return end
        foundDescendant = child
        cleanUpConnection()
    end)

   while  connection and (os.clock() - timeStarted) < duration do
        task.wait(0.5)
   end
   
   cleanUpConnection()
   return foundDescendant
end

local function WaitForTypeOfDescendant(instance: Instance, className: string, duration: number?): Instance
	const _duration = duration or 10
	const found = instance:FindFirstChildWhichIsA(className, true) or waitForDuration(instance, _duration, className, true)
	assert(found, `{className} Instance Type not found in descendants of {instance}`)
	return found
end

local function WaitForDescendantName(instance: Instance, childName: string, duration: number?): Instance
	const _duration = duration or 10
	const found = instance:FindFirstChild(childName, true) or waitForDuration(instance, _duration, childName)
	assert(found, `{childName} Instance not found in descendants of {instance}`)
	return found
end

local function WaitForTypeOfChild(instance: Instance, className: string, duration: number?): Instance
	const _duration = duration or 10
	const found = instance:FindFirstChildWhichIsA(className) or waitForDuration(instance, _duration, className, true)
	assert(found, `{className} Instance Type not found in {instance}`)
	return found
end


local function AssertWaitForChild(parent: Instance, childName: string, waitDurationInSeconds: number?): Instance
    const waitDuration = waitDurationInSeconds or 10
    const child = parent:WaitForChild(childName, waitDuration)
   assert(child,`{childName} Instance not found in {parent}`)
    return child
end

local function AssertFindFirstChild(parent: Instance,childName: string,recursive: boolean?): Instance
   const child = parent:FindFirstChild(childName, recursive)
   assert(child,`{childName} Instance not found in {parent}`)
    return child
end

local function AssertFindFirstChildWhichIsA(parent: Instance, className: string, recursive: boolean?): Instance
	const child = parent:FindFirstChildWhichIsA(className, recursive)
	assert(child,`{className} Instance Type not found in {parent}`)
	return child
end


return {
	FindFirstChild = AssertFindFirstChild,
	FindFirstChildWhichIsA = AssertFindFirstChildWhichIsA,
	WaitForChild = AssertWaitForChild,
	WaitForChildWhichIsA = WaitForTypeOfChild,
    WaitForDescendantName = WaitForDescendantName,
    WaitForTypeOfDescendant = WaitForTypeOfDescendant,
}