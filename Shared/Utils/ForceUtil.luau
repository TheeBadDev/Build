
type LinerForceData = {
	Target: BasePart,
	Destination: Vector3,
	Time: number?,
	TargetMass: number?
}

local function ApplyLinerForceToPart(data: LinerForceData)
	const _time = data.Time or 1
	const mass = data.TargetMass or data.Target:GetMass()

	const direction = data.Destination - data.Target.CFrame.Position

	const gravityCompensation = Vector3.new(0, workspace.Gravity * 0.5 * _time, 0)
	const force = (direction / _time) + gravityCompensation

	data.Target:ApplyImpulse(force * mass)
end

return {
	ApplyLinterForce = ApplyLinerForceToPart
}