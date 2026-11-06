
const ReplicatedStorage = game:GetService("ReplicatedStorage")


const SelectEnums = require(ReplicatedStorage.Shared.Enums.SelectEnums)
const Maid = require(ReplicatedStorage.Shared.Libraries.Maid)
const SelectedBlock = require(script.SelectedBlock)


const _Maid = Maid

const BlockHudEvents = game.ReplicatedStorage.Events.BlockEvents.BlockHudEvents


local function onSelectedBlockBlock(blockName: string)
    SelectedBlock.Fire(blockName)
end

local function onSelectedTool(toolName: string)

end


local function OnSelectEvent(type: string, ...)
    if type == SelectEnums.BLOCK then
        onSelectedBlockBlock(...)
        else
        onSelectedTool(...)
    end
end


BlockHudEvents.Select.Event:Connect(OnSelectEvent)


return function()

end
