
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")

const Mouse = require(ReplicatedStorage.Client.Modules.Mouse)
const RaycastUtil = require(ReplicatedStorage.Client.Modules.RaycastUtil)

const MAX_DISTANCE_FROM_CAMERA_STUDS = 1_000 


type callback = (instance: BasePart, positionIntersected: Vector3 ,normal: Vector3)->()


-- Calls callback every frame the mouse is over a BasePart. Disconnect the returned connection to stop.
local function TrackMouseTarget(callback: callback): RBXScriptConnection
	return RunService.PostSimulation:Connect(function()
		const unitRay = Mouse.GetUnitRay()
		const rayCastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * MAX_DISTANCE_FROM_CAMERA_STUDS)

		if not RaycastUtil.HitInstance(rayCastResult) then return end
		if not rayCastResult.Instance:IsA("BasePart") then return end

		callback(rayCastResult.Instance, rayCastResult.Position, rayCastResult.Normal)
	end)
end


return {
    Fire = TrackMouseTarget,
}