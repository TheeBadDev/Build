
const ReplicatedStorage = game:GetService("ReplicatedStorage")


const Helpers = script.Parent.Helpers

const detectClick = require(Helpers.detectClick)
const trackMouseTarget = require(Helpers.trackMouseTarget)
const Maid = require(ReplicatedStorage.Shared.Libraries.Maid)
const SnapToGrid = require(ReplicatedStorage.Shared.Modules.SnapToGrid)

const createBlockClone = require(Helpers.createBlockClone)
const positionSelectionBox = require(Helpers.positionSelectionBox)
const SelectionBox = require(ReplicatedStorage.Client.Components.SelectionBox)


const _Maid = Maid.new()


local BlockName: string?


local function ClickDetected(instance: BasePart, position: Vector3, normal: Vector3)
    assert(BlockName)
    print('Clicked',position,normal,instance)
end


local function BlockSelected(blockName: string)
    BlockName = blockName

    const selectionBox = SelectionBox()
    const blockClone = createBlockClone(blockName)

    local function mouseRayResults(_, positionIntersected: Vector3 ,normal: Vector3)
        positionSelectionBox(selectionBox,positionIntersected,normal)
        SnapToGrid.OnSurface(blockClone, positionIntersected, normal)
    end

    _Maid['BlockClone'] = blockClone
    _Maid['SelectionBox'] = selectionBox
    _Maid['DetectClick'] = detectClick.Fire(ClickDetected)
    _Maid['MouseConnection'] = trackMouseTarget.Fire(mouseRayResults)
end

local function StopSelection()
     _Maid['BlockClone'] = nil
    _Maid['MouseConnection'] = nil
    _Maid['SelectionBox'] = nil
    _Maid['DetectClick'] = nil

    BlockName = nil
end


return {
    Fire = BlockSelected,
    Destroy = StopSelection,
}
