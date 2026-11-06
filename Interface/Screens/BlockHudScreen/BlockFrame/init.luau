
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const SelectEnums = require(ReplicatedStorage.Shared.Enums.SelectEnums)
const BlockButton = require(script.BlockButton)
const Maid = require(ReplicatedStorage.Shared.Libraries.Maid)


export type Props = {
    BlockFrame: Frame,
    BlockList: {string},
    Callback: (...any) -> (),
}

local function getFrame(blockFrame: Frame, index: number): Frame
    const frame = blockFrame:WaitForChild(`{index}`) :: Frame
    assert(frame,`{blockFrame} has no frame named {index}`)
    return frame
end

return function(maid: Maid.Type, props: Props)

    local function clicked(blockName: string)
        props.Callback(SelectEnums.BLOCK,blockName)
    end

    for index: number, blockName: string in props.BlockList do
        const frame = getFrame(props.BlockFrame, index)
        
        BlockButton(maid,{
            Frame = frame,
            BlockName = blockName,
            OnPressed = clicked,
        })
    end
end