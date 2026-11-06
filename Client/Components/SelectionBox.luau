
const ReplicatedStorage = game:GetService("ReplicatedStorage")


const GidConfig = ReplicatedStorage.Configs.GidConfig

const DEFAULT_COLOR = Color3.new(0, 0, 0)
const DEFAULT_LINE_THICKNESS = 0.028
const DEFAULT_TRANSPARENCY = 0

export type Props = {
	Color3: Color3?,
	LineThickness: number?,
	Transparency: number?,
}


local partTemplate = Instance.new('Part')
partTemplate.Size = GidConfig.CellSize.Value
partTemplate.Anchored = true

partTemplate.CanQuery = false
partTemplate.CanCollide = false
partTemplate.CanTouch = false
partTemplate.CanCollide = false



return function(props: Props?): (BasePart, SelectionBox)
	const partClone = partTemplate:Clone()
	
	partClone.Transparency = 1
		
	const selectionBox = Instance.new('SelectionBox')
	selectionBox.Parent = partClone
	selectionBox.Adornee = partClone
	
	const _props: Props = props or {}
	selectionBox.Color3 = _props.Color3 or DEFAULT_COLOR
	selectionBox.LineThickness = _props.LineThickness or DEFAULT_LINE_THICKNESS
	selectionBox.Transparency = _props.Transparency or DEFAULT_TRANSPARENCY
	
	partClone.Parent = workspace

	return partClone, selectionBox
end