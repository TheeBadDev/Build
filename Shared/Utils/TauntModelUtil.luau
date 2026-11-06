const ReplicatedStorage = game:GetService("ReplicatedStorage")


const TauntModels = ReplicatedStorage.Assets.Taunt.Models.Objects


local function Find(name: string): Model?
	for _, model in TauntModels:QueryDescendants("Model") do
		if model.Name == name then
			return model :: Model
		end
	end
	return nil
end

local function GetNames(rarity: string): {string}
	const folder = TauntModels:FindFirstChild(rarity)
	const names = {}
	if not folder then return names end

	for _, model in folder:GetChildren() do
		table.insert(names,model.Name)
	end
	return names
end

local function RandomName(rarity: string): string?
	const names = GetNames(rarity)
	if #names == 0 then return nil end
	return names[math.random(#names)]
end

local function IsRarity(name: string, rarity: string): boolean
	const folder = TauntModels:FindFirstChild(rarity)
	return folder ~= nil and folder:FindFirstChild(name) ~= nil
end


return {
	Find = Find,
	GetNames = GetNames,
	RandomName = RandomName,
	IsRarity = IsRarity,
}
