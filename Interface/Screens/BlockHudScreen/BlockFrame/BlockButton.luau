const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Maid = require(ReplicatedStorage.Shared.Libraries.Maid)
const BlockUtil = require(ReplicatedStorage.Shared.Utils.BlockUtil)

const ItemViewport = require(ReplicatedStorage.Interface.Components.ItemViewport)
const Find = require(ReplicatedStorage.Interface.Modules.Find)

export type Props = {
    Frame: Frame,
    BlockName: string,
    OnPressed: (blockName: string) -> (),
}

-- Calls props.OnPressed(blockName) when the button is pressed
return function(maid: Maid.Type, props: Props)
    const _Find = Find(props.Frame)
    const button = _Find.GuiButton() :: GuiButton

    maid[`viewportFrame{props.Frame.Name}`] = ItemViewport(props.Frame, BlockUtil.FindBlock(props.BlockName))

    maid[`button{props.Frame.Name}`] = button.Activated:Connect(function()
        props.OnPressed(props.BlockName)
    end)
end