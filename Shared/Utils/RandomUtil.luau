const rng = Random.new()

local function RandomWait(min: number, max: number)
	const minimum = math.round(min * 10)
	const maximum = math.round(max * 10)

	const duration = rng:NextInteger(minimum, maximum) / 10

	task.wait(duration)
end

return {
	Wait = RandomWait,
}