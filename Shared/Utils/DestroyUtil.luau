

const Debris = game:GetService("Debris")


local function AncestryChangedCallback(instance: Instance, callback: ()->()): RBXScriptConnection?

    local connection: RBXScriptConnection? 

    connection = instance.AncestryChanged:Connect(function(_, parent: Instance?)
        if not parent and connection then
            connection:Disconnect()
            connection = nil
            callback()
        end
    end)

    return connection
end

local function DestroyInstancesInTable(instanceTable: {Instance}, _delay: number?)
	for _, instance in instanceTable do
		if _delay then
			Debris:AddItem(instance,_delay)
		else
			instance:Destroy()
		end
	end
end


return {
	Callback = AncestryChangedCallback,
	CleanTable = DestroyInstancesInTable,
} 
