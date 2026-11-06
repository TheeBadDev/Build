const ReplicatedStorage = game:GetService("ReplicatedStorage")


const GunStats = require(ReplicatedStorage.Shared.Data.Gun.GunStats)


local function GetGunType(instance: Instance): string?
	const tags = instance:GetTags()
	local gunType: string?

	for _, tag: string in tags do
		if GunStats[tag] then
			gunType = tag
			break
		end
	end

	return gunType
end


return {
	GunType = GetGunType,
}