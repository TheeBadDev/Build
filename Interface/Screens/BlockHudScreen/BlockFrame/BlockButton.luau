const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Maid = require(ReplicatedStorage.Shared.Libraries.Maid)
const Throttle = require(ReplicatedStorage.Shared.Libraries.Throttle)
const BlockUtil = require(ReplicatedStorage.Shared.Utils.BlockUtil)

const ItemViewport = require(ReplicatedStorage.Interface.Components.ItemViewport)
const Find = require(ReplicatedStorage.Interface.Modules.Find)


const PRESS_DEBOUNCE_SECONDS = 0.2


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
        Throttle(button, PRESS_DEBOUNCE_SECONDS, function()
            props.OnPressed(props.BlockName)
        end)
    end)
end