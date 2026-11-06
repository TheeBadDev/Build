local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MaidModule = require(ReplicatedStorage.Shared.Libraries.Maid)
local Signal = require(ReplicatedStorage.Shared.Libraries.Signal)


local Player = Players.LocalPlayer
Player:WaitForChild('Backpack')

local Maid: MaidModule.Type = MaidModule.new()


local toolTable: {Tool} = {}
local destroyWatchers: {[Tool]: RBXScriptConnection} = {}

local function GetTools(): {Tool}
	return toolTable
end

local Signals = {
	AddedSignal = Signal.new(),
	EquippedSignal = Signal.new(),
	UnequippedSignal = Signal.new(),
	DestroyedSignal = Signal.new(),
	GetDetected = GetTools,
}



local function NewToolCheck(tool: Tool)
	if table.find(toolTable, tool) then return end
	table.insert(toolTable, tool)
	Signals.AddedSignal:Fire(tool)
	task.wait()
	return
end

local function ToolFoundInCharacter(tool: Tool)
	NewToolCheck(tool)
	Signals.EquippedSignal:Fire(tool)
end

local function ToolFoundInBackPack(tool: Tool)
	NewToolCheck(tool)
	Signals.UnequippedSignal:Fire(tool)
end

local function ToolDestroyed(tool: Tool)
	Signals.DestroyedSignal:Fire(tool)
	local index = table.find(toolTable, tool)
	if index then
		table.remove(toolTable, index)
	end
	destroyWatchers[tool] = nil
end

local function DetectToolDestroying(tool: Tool)
	if destroyWatchers[tool] then return end

	destroyWatchers[tool] = tool.AncestryChanged:Connect(function(_, parent: Instance?)
		if not parent then
			local conn = destroyWatchers[tool]
			if conn then
				conn:Disconnect()
			end
			ToolDestroyed(tool)
		end
	end)
end

local function CheckForTool(parent: Instance, child: Instance?)
	if not child or not child:IsA('Tool') then return end
	if parent:IsA('Model') then
		ToolFoundInCharacter(child)
	else
		ToolFoundInBackPack(child)
	end
	DetectToolDestroying(child)
end

local function CreateToolAddedConnection(instance: Instance)
	Maid[instance] = instance.ChildAdded:Connect(function(child)
		CheckForTool(instance, child)
	end)
end

local function FindTool(instance: Instance)
	for _, child in instance:GetChildren() do
		CheckForTool(instance, child)
	end
end


local function onBackpackAdded(backpack: Backpack)
	CreateToolAddedConnection(backpack)
	FindTool(backpack)
end

Player.ChildAdded:Connect(function(child)
	if child:IsA('Backpack') then
		onBackpackAdded(child)
	end
end)


Player.CharacterAdded:Connect(function(character)
	CreateToolAddedConnection(character)
	FindTool(character)
end)

if Player.Character then
	CreateToolAddedConnection(Player.Character)
	FindTool(Player.Character)
end

if Player:FindFirstChild('Backpack') then
	onBackpackAdded(Player.Backpack)
end



return Signals