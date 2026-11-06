
const ReplicatedStorage = game:GetService("ReplicatedStorage")


const BlockStorage = ReplicatedStorage.Assets.Blocks



local function FindBlockByName(name: string)
    const block = BlockStorage:FindFirstChild(name)
    assert(block,`{name} black name not found in 'Blockstorage'`)

    return block
end


return {
    FindBlock = FindBlockByName,
}