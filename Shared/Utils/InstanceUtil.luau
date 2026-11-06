

type Callback = (child: Instance, ...any) -> ()


local function GetInstanceChildren(instance: Instance, callback: Callback, ...): RBXScriptConnection
    local connection = instance.ChildAdded:Connect(callback)
    for _, child: Instance in instance:GetChildren() do
        callback(child,...)
    end
    return connection
end



return {
    GetChildren = GetInstanceChildren,
}