
const ReplicatedStorage = game:GetService("ReplicatedStorage")


const GidConfig = ReplicatedStorage.Configs.GidConfig


local partTemplate = Instance.new('Part')
partTemplate.Size = GidConfig.CellSize.Value
partTemplate.Anchored = true

partTemplate.CanQuery = false
partTemplate.CanCollide = false
partTemplate.CanTouch = false
partTemplate.CanCollide = false



return function(): (BasePart, SelectionBox)
	const partClone = partTemplate:Clone()
	
	partClone.Transparency = 1
		
	const selectionBox = Instance.new('SelectionBox')
	selectionBox.Parent = partClone
	selectionBox.Adornee = partClone
	
	selectionBox.Color3 = Color3.new(0, 0, 0)
	selectionBox.LineThickness = 0.028
	
	return partClone, selectionBox
end