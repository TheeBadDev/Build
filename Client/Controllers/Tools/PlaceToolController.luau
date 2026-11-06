
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")

const Throttle = require(ReplicatedStorage.Shared.Libraries.Throttle)
const Maid = require(ReplicatedStorage.Shared.Libraries.Maid)

const ToolDetectore = require(ReplicatedStorage.Client.Modules.ToolDetectore)
const Mouse = require(ReplicatedStorage.Client.Modules.Mouse)
const RaycastUtil = require(ReplicatedStorage.Client.Modules.RaycastUtil)

const SelectionBox = require(ReplicatedStorage.Client.Components.SelectionBox)
const SnapToGrid = require(ReplicatedStorage.Shared.Modules.SnapToGrid)


const _Maid = Maid.new()


const BlockEvents = game.ReplicatedStorage.Events.BlockEvents


const DELAY = 0.2


local function activated(tool: Tool)
	const rayCastResults = Mouse.Raycast()
	if not RaycastUtil.HitInsatnce(rayCastResults) then return end
	
	BlockEvents.Place:FireServer(tool,rayCastResults.Position,rayCastResults.Normal)
end

local function unequipped()
	_Maid['selectionBox'] = nil
	_Maid['Rs'] = nil
end

local function equipped(tool: Tool)
	const part = tool:FindFirstChildWhichIsA('BasePart'); assert(part,`{tool} Tool Has no base part`)
	
	const selectionBox = SelectionBox()
	
	selectionBox:PivotTo(CFrame.new(selectionBox.Position))
	selectionBox.Parent = workspace
	
	_Maid['selectionBox'] = selectionBox
	
	_Maid['Runservice'] = RunService.Heartbeat:Connect(function()
		const rayCastResults = Mouse.Raycast()
		
		if not selectionBox or not RaycastUtil.HitInsatnce(rayCastResults) then return end
		
		selectionBox.Position = rayCastResults.Position - rayCastResults.Normal * (selectionBox.Size / 2)
		SnapToGrid.Instance(selectionBox)
	end)
end



local function toolAdded(tool: Tool)
	if tool.Name ~= "PlaceBlock" then return end
	
	_Maid['Activated'] = tool.Activated:Connect(function()
		Throttle('ToolActivated',DELAY,function() activated(tool) end)
	end)
	
	_Maid['Equipped'] = tool.Equipped:Connect(function()
		equipped(tool)
	end)
	
	_Maid['Unequipped'] = tool.Unequipped:Connect(function()
		unequipped()
	end)
end



return function()
	ToolDetectore.AddedSignal:Connect(toolAdded)
end