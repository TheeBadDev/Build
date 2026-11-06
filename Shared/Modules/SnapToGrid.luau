


local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CellSize: Vector3Value = ReplicatedStorage:WaitForChild("Configs"):WaitForChild("GidConfig"):WaitForChild("CellSize")

local HALF = 0.5

local function SnapAxis(value: number, cell: number): number
	if cell <= 0 then
		return value
	end
	return math.round(value / cell) * cell
end

-- Returns the grid position closest to the given position.
local function SnapPosition(position: Vector3): Vector3
	local cell = CellSize.Value

	return Vector3.new(
		SnapAxis(position.X, cell.X),
		SnapAxis(position.Y, cell.Y),
		SnapAxis(position.Z, cell.Z)
	)
end

-- Returns the bounding box CFrame and size of a part or model.
local function GetBox(instance: PVInstance): (CFrame, Vector3)
	if instance:IsA("Model") then
		return instance:GetBoundingBox()
	end

	local part = instance :: BasePart
	return part.CFrame, part.Size
end

-- Half size of the world-axis-aligned box that encloses the (possibly rotated) box.
local function GetWorldHalfExtents(boxCFrame: CFrame, size: Vector3): Vector3
	local r, u, l = boxCFrame.RightVector, boxCFrame.UpVector, boxCFrame.LookVector
	local half = size / 2

	return Vector3.new(
		math.abs(r.X) * half.X + math.abs(u.X) * half.Y + math.abs(l.X) * half.Z,
		math.abs(r.Y) * half.X + math.abs(u.Y) * half.Y + math.abs(l.Y) * half.Z,
		math.abs(r.Z) * half.X + math.abs(u.Z) * half.Y + math.abs(l.Z) * half.Z
	)
end


local function SnapInstance(instance: PVInstance): Vector3
	local pivot = instance:GetPivot()
	local boxCFrame, size = GetBox(instance)
	local half = GetWorldHalfExtents(boxCFrame, size)

	local snappedCenter = SnapPosition(boxCFrame.Position - half) + half
	local snapped = snappedCenter + (pivot.Position - boxCFrame.Position)

	instance:PivotTo(CFrame.new(snapped) * pivot.Rotation)
	return snapped
end

-- Moves the block into the grid cell next to the surface at position, pushed out along the surface normal
local function SnapOnSurface(block: BasePart, position: Vector3, normal: Vector3): Vector3
	block.Position = position + normal * (block.Size * HALF)
	return SnapInstance(block)
end


return {
	Instance = SnapInstance,
	Position = SnapPosition,
	OnSurface = SnapOnSurface,
}