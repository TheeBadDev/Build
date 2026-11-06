


local function RaycastHitInsatance(rayCastResults: RaycastResult): boolean
	if not rayCastResults then
		return false
	end

	if not rayCastResults.Instance then
		return false
	end

	if not rayCastResults.Position then 
		return false
	end

	return true
end



return {
	HitInsatnce = RaycastHitInsatance,
}