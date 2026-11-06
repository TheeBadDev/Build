
const FOV = 40
const PADDING = 1.15 -- >1 leaves space around the item
const VIEW_DIRECTION = Vector3.new(1, 0.8, 1).Unit -- front-top-right angle

local function getBounds(item: PVInstance): (CFrame, Vector3)
    if item:IsA("Model") then
        return item:GetBoundingBox()
    elseif item:IsA("BasePart") then
        return item.CFrame, item.Size
    end
    return item:GetPivot(), Vector3.one
end

return function(frame: Frame, item: PVInstance): ViewportFrame
    assert(frame, "ItemViewport: frame is nil")
    assert(item, "ItemViewport: item is nil")

    const viewport = Instance.new("ViewportFrame")
    viewport.Name = "ItemViewport"
    viewport.BackgroundTransparency = 1
    viewport.Size = UDim2.fromScale(1, 1)
    viewport.AnchorPoint = Vector2.new(0.5, 0.5)
    viewport.Position = UDim2.fromScale(0.5, 0.5)
    viewport.Active = false -- let clicks pass through to the button below
    viewport.ZIndex = 2
    viewport.Ambient = Color3.fromRGB(200, 200, 200)
    viewport.LightColor = Color3.fromRGB(255, 255, 255)
    viewport.LightDirection = Vector3.new(-1, -1, -1)

    -- Clone and center the item at the origin
    const clone = item:Clone()
    for _, d in clone:GetDescendants() do
        if d:IsA("BaseScript") then
            d:Destroy()
        end
    end
    if clone:IsA("BasePart") then
        clone.Anchored = true
    end

    const boundsCFrame, size = getBounds(clone)
    clone:PivotTo(boundsCFrame:Inverse() * clone:GetPivot())
    clone.Parent = viewport

    -- Camera framed to fit the item's bounding sphere
    const camera = Instance.new("Camera")
    camera.FieldOfView = FOV
    const radius = size.Magnitude / 2
    const distance = (radius / math.sin(math.rad(FOV / 2))) * PADDING
    camera.CFrame = CFrame.lookAt(VIEW_DIRECTION * distance, Vector3.zero)
    camera.Parent = viewport
    viewport.CurrentCamera = camera

    viewport.Parent = frame
    return viewport
end