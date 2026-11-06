
const ReplicatedStorage = game:GetService("ReplicatedStorage")


const BlockUtil = require(ReplicatedStorage.Shared.Utils.BlockUtil)


const BLOCK_TRANSPARENCY = 0.4


local function makeSemiTransparent(block: BasePart)
    block.Transparency = BLOCK_TRANSPARENCY

    for _, descendant in block:QueryDescendants(`BasePart`) do
        descendant.Transparency = BLOCK_TRANSPARENCY
    end
end

return function(blockName: string): BasePart
    const blockClone = BlockUtil.FindBlock(blockName):Clone() :: BasePart
    blockClone.CanQuery = false
    blockClone.CanCollide = false
    blockClone.Parent = workspace

    makeSemiTransparent(blockClone)

    return blockClone
end