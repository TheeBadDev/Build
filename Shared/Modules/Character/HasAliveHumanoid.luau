


return function(instance: Model?): Model?
	if not instance then return end
	if typeof(instance) ~= "Instance" then return end
	if not instance.Parent then return end
	
	const Humanoid = instance:FindFirstChildWhichIsA('Humanoid')
	
	if not Humanoid then return end
	if Humanoid.Health <= 0 then return end
	
	return instance
end