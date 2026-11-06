
const UserInputService = game:GetService("UserInputService")

const MAX_DISTANCE_STUDS = 1_000
const HALF = 0.5


type callback = (instance: BasePart, position: Vector3, normal: Vector3) -> ()


local function getScreenPoint(input: InputObject): Vector2?
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		return Vector2.new(input.Position.X, input.Position.Y)
	end

	-- Gamepad: aim from the center of the screen
	if input.KeyCode == Enum.KeyCode.ButtonR2 then
		return workspace.CurrentCamera.ViewportSize * HALF
	end

	return nil
end

-- Calls callback when the player clicks/taps a BasePart in the world within range. Disconnect to stop.
local function DetectPlayerClick(callback: callback): RBXScriptConnection
	return UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		if gameProcessed then return end

		const screenPoint = getScreenPoint(input)
		if not screenPoint then return end

		const unitRay = workspace.CurrentCamera:ScreenPointToRay(screenPoint.X, screenPoint.Y)
		const result = workspace:Raycast(unitRay.Origin, unitRay.Direction * MAX_DISTANCE_STUDS)
		if not result then return end
		if not result.Instance:IsA("BasePart") then return end

		callback(result.Instance, result.Position, result.Normal)
	end)
end

return {
    Fire = DetectPlayerClick,
}