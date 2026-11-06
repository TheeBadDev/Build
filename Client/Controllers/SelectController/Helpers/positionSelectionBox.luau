
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const SnapToGrid = require(ReplicatedStorage.Shared.Modules.SnapToGrid)

const HALF = 0.5


-- Moves the selection box onto the grid cell at the target position, pushed in along the surface normal
return function(selectionBox: BasePart, targetPosition: Vector3, normal: Vector3)
	selectionBox.Position = targetPosition - normal * (selectionBox.Size * HALF)
	SnapToGrid.Instance(selectionBox)
end