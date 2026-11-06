
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")


const Throttle = require(ReplicatedStorage.Shared.Libraries.Throttle)
const Maid = require(ReplicatedStorage.Shared.Libraries.Maid)

const ObjectUtil = require(ReplicatedStorage.Shared.Utils.ObjectUtil)

const SelectionBox = require(ReplicatedStorage.Client.Components.SelectionBox)

const ToolDetectore = require(ReplicatedStorage.Client.Modules.ToolDetectore)
const Mouse = require(ReplicatedStorage.Client.Modules.Mouse)
const RaycastUtil = require(ReplicatedStorage.Client.Modules.RaycastUtil)


const _Maid = Maid.new()


const BlockEvents = game.ReplicatedStorage.Events.BlockEvents


const DELAY = 0.2
const SELECTION_COLOR = Color3.new(1, 0, 0)


local function activated(tool: Tool)
	const rayCastResult = Mouse.Raycast()

	if not RaycastUtil.HitInstance(rayCastResult) then return end
	if not ObjectUtil.CanDestroy(rayCastResult.Instance) then return end
	
	BlockEvents.DestroyBlock:FireServer(rayCastResult.Instance)
end

local function unequipped()
	_Maid['RS'] = nil
	_Maid['SelectionPart'] = nil
end

local function equipped()
	const selectionPart = SelectionBox({ Color3 = SELECTION_COLOR })
	selectionPart.Parent = workspace
	
	_Maid['SelectionPart'] = selectionPart
	
	local lastTarget: BasePart?
	
	_Maid['RS'] = RunService.PostSimulation:Connect(function()
		const rayCastResult = Mouse.Raycast()
		
		if not RaycastUtil.HitInstance(rayCastResult) then return end
		if lastTarget and lastTarget == rayCastResult.Instance then return end
		if not ObjectUtil.CanDestroy(rayCastResult.Instance) then return end
		
		lastTarget = rayCastResult.Instance
		
		selectionPart.Size = lastTarget.Size
		selectionPart:PivotTo(lastTarget:GetPivot())
	end)
end



local function toolAdded(tool: Tool)
	if tool.Name ~= "Destroy" then return end
	
	_Maid['Activated'] = tool.Activated:Connect(function()
		Throttle('ToolActivated',DELAY,function() activated(tool) end)
	end)

	_Maid['Equipped'] = tool.Equipped:Connect(function()
		equipped()
	end)

	_Maid['Unequipped'] = tool.Unequipped:Connect(function()
		unequipped()
	end)
end



return function()
	ToolDetectore.AddedSignal:Connect(toolAdded)
end