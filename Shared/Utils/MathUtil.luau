
local MathUtil = {}

function MathUtil.Lerp(a: number, b: number, t: number): number
    return a + (b - a) * t
end

-- Returns the remaining time based on the provided start time and goal duration.
function MathUtil.GetTimeLeft(startedTime: number, goalDuration: number, useOSTime: boolean?): number
    local currentTime = useOSTime and os.time() or tick()
    local elapsedTime = currentTime - startedTime
    local timeLeft = goalDuration - elapsedTime
    return math.max(timeLeft, 0)
end

function MathUtil.Easing(t: number)
    local a = t * t
    local b = 1.0 - (1.0 - t) * (1.0 - t)
    return MathUtil.Lerp(a,b,t)
end

--[[
    Returns a table of positions that would be on the edges / points
    of a circle.
]]
function MathUtil.GetPositionsInACircle(origin: Vector3, radiusInStuds: number, numberOfPositions: number) : {Vector3}
	local positions = {}

	for i = 1, numberOfPositions do
		local angle = (i - 1) * (2 * math.pi / numberOfPositions)
		local x = origin.X + radiusInStuds * math.cos(angle)
		local z = origin.Z + radiusInStuds * math.sin(angle)
		table.insert(positions, Vector3.new(x, origin.Y, z))
	end

	return positions
end


function MathUtil.GetCFrameFacingAngle(position: Vector3, angleDegrees: number): CFrame
	const angleRadians = math.rad(angleDegrees)
	return CFrame.new(position) * CFrame.Angles(0, angleRadians, 0)
end

function MathUtil.GetPositionBetween(positionA: Vector3, positionB: Vector3): Vector3
	return (positionA + positionB) / 2
end

--[[
	Gives random number down to the first decimal.
]]
function MathUtil.Randomize(min: number, max: number): number
	return math.random(min * 10, max * 10) / 10
end

--[[Returns a random offset, ranging from -maxOffsetRange to +maxOffsetRange]]
function MathUtil.OffSetPosition(position: Vector3, maxOffsetRange: Vector3, useNeg: boolean?): Vector3
	local function randomAxis(range: number): number
		if range == 0 then
			return 0
		end

		local value = math.random() * range

		if useNeg then
			value *= (math.random() < 0.5 and -1 or 1)
		end

		return value
	end

	return position + Vector3.new(
		randomAxis(maxOffsetRange.X),
		randomAxis(maxOffsetRange.Y),
		randomAxis(maxOffsetRange.Z)
	)
end


--[[
	Quadratic Bezier — one control point, simple curve.
	t go 0 to 1, 0 = start, 1 = finish.
]]
function MathUtil.QuadraticBezier(p0: Vector3, p1: Vector3, p2: Vector3, t: number): Vector3
	local oneMinusT = 1 - t
	return (oneMinusT ^ 2) * p0 + 2 * oneMinusT * t * p1 + (t ^ 2) * p2
end


function MathUtil.GetCFrameOrientation(position: Vector3, angleDegrees: Vector3): CFrame
	const xRadians = math.rad(angleDegrees.X)
	const yRadians = math.rad(angleDegrees.Y)
	const zRadians = math.rad(angleDegrees.Z)

	return CFrame.new(position) * CFrame.Angles(xRadians, yRadians, zRadians)
end


function MathUtil.GetPositionAwayFromOrigin(currentPosition: Vector3, origin: Vector3, distanceInStuds: number?): Vector3
	const awayDirection = (currentPosition - origin).Unit
	const offset = distanceInStuds and (awayDirection * distanceInStuds) or awayDirection
	return currentPosition + offset
end

function MathUtil.GetPercentDiffrence(max: number, min: number, current: number): number
	local range = max - min
	if range <= 0 then
		return 0
	end
	local diff = (current - min) / range
	if diff < 0 then
		diff = 0
	elseif diff > 1 then
		diff = 1
	end
	return diff
end

function MathUtil.GetPositionFacingAwayFromOrigin(currentPosition: Vector3, origin: Vector3, distanceInStuds: number?): Vector3
	const awayDirection = (currentPosition - origin).Unit
	const offset = distanceInStuds and (awayDirection * distanceInStuds) or awayDirection
	return currentPosition + offset
end


function MathUtil.Vector3Lerp(max: Vector3, min: Vector3, percent: number): Vector3
	return min + (max - min) * percent
end

return MathUtil

