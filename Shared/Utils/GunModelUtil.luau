const ReplicatedStorage = game:GetService("ReplicatedStorage")


const GunModels = ReplicatedStorage.Assets.Gun.Models


local function Find(name: string): Model?
	for _, model in GunModels:QueryDescendants("Model") do
		if model.Name == name then
			return model :: Model
		end
	end
	return nil
end

local function GetNames(rarity: string): {string}
	const folder = GunModels:FindFirstChild(rarity)
	const names = {}
	if not folder then return names end

	for _, model in folder:GetChildren() do
		table.insert(names,model.Name)
	end
	return names
end


return {
	Find = Find,
	GetNames = GetNames,
}
