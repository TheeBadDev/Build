
const ReplicatedStorage = game:GetService("ReplicatedStorage")


const BlockEvents = ReplicatedStorage.Events.BlockEvents



local function SetPlayersEquippedBlocks(player: Player, list :{[number]: string})
	print('Send',list)
	BlockEvents.Equip:FireClient(player,list)
end

return {
    Set = SetPlayersEquippedBlocks,
}