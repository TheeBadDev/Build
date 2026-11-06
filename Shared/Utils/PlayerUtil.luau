
const Players = game:GetService("Players")


local function GetPlayersFormListOfCharacters(characterList: { Model }): { Player }
	const players = {}

	for _, character in characterList do
		xpcall(function()
			const player = Players:GetPlayerFromCharacter(character)
			if player then
				table.insert(players, player)
			end
		end,function(message: string)
			warn(message)
		end)
	end

	return players
end

local function GetCharactersThatBelongToPlayers(characterList: { Model }): { Model }
	local playerCharacters = {}

	for _, character in ipairs(characterList) do
		local player = Players:GetPlayerFromCharacter(character)

		if player then
			table.insert(playerCharacters, character)
		end
	end

	return playerCharacters
end


local function GetPlayerHeadShot(userID: number): string
	local thumbnail = "rbxassetid://18743123595"
	const _userID = userID :: any
	
	local success, result = pcall(function()
		return Players:GetUserThumbnailAsync(
			_userID,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size100x100)
	end)
	
	if success then
		thumbnail = result
	else
		warn(result)
	end
	
	return thumbnail
end

local function GetPlayerName(userID: number): string
	local name = "No_Name"
	const _userID = userID :: any

	local success, result = pcall(function()
		return Players:GetNameFromUserIdAsync(_userID)
	end)
	
	if success then
		name = result
	end
	
	return name
end


return {
	GetPhoto = GetPlayerHeadShot,
	GetName = GetPlayerName,
	
	GetPlayerCharacetrs = GetCharactersThatBelongToPlayers,
    GetPlayersFromCharacters =  GetPlayersFormListOfCharacters,
}