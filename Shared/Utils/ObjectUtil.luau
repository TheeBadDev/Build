


local function CanPlayerDestroyObject(object: Instance)
	if not object then
		return false
	end
	
	if object.Parent == workspace then
		return false
	end
	
	return true
end



return {
	CanDestroy = CanPlayerDestroyObject,
}