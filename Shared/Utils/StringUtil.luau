

--[[
	turns numbers to time format. 60 -> 1:00 | 3600 -> 01:00:00 | 30 -> 30
]]
local function NumberToTimeFormat(seconds: number): string
	seconds = math.floor(seconds)

	if seconds < 60 then
		return tostring(seconds)
	end

	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local remainingSeconds = seconds % 60

	if hours > 0 then
		return string.format('%02d:%02d:%02d', hours, minutes, remainingSeconds)
	end

	return string.format('%d:%02d', minutes, remainingSeconds)
end

return {
    TimeFormat = NumberToTimeFormat,
}