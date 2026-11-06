
const ReplicatedStorage = game:GetService("ReplicatedStorage")


const SnapToGrid = require(ReplicatedStorage.Shared.Modules.SnapToGrid)
const ObjectUtil = require(ReplicatedStorage.Shared.Utils.ObjectUtil)

const HasAliveHumanoid = require(ReplicatedStorage.Shared.Modules.Character.HasAliveHumanoid)


const BlockEvents = game.ReplicatedStorage.Events.BlockEvents


local function placeBlock(block: BasePart, targetPosition: Vector3, hitNormal: Vector3)
	const blockClone = block:Clone()
	blockClone.Anchored = true
	
	const newPosition = targetPosition + hitNormal * (blockClone.Size / 2)
	blockClone:PivotTo(CFrame.new(newPosition))
	
	SnapToGrid.Instance(blockClone)
	
	blockClone.Parent = workspace.PlacedBlocks
end

local function OnPlaceBlockEvent(player: Player, tool: Tool, targetPosition: Vector3, hitNormal: Vector3)
	const character = HasAliveHumanoid(player.Character)
	
	if not character or not tool or not targetPosition or not hitNormal then return end
	
	const block = tool:FindFirstChild('Handle') :: BasePart
	
	placeBlock(block,targetPosition,hitNormal)
end

local function OnDestroyBlock(player: Player, block: BasePart)
	if not ObjectUtil.CanDestroy(block) then return end

	block:Destroy()
end


local function GetEquippedBlocks()
	const BLOCKS_LIST = {'White', 'Yellow', 'Black', 'Purple', 'Red'}
	return BLOCKS_LIST
end


BlockEvents.Place.OnServerEvent:Connect(OnPlaceBlockEvent)
BlockEvents.DestroyBlock.OnServerEvent:Connect(OnDestroyBlock)
BlockEvents.BlockHudEvents.Equipped.OnServerInvoke = GetEquippedBlocks

return {
}