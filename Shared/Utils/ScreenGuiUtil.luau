const Players = game:GetService("Players")


local function findScreenGui(screenName: string, player: Player): ScreenGui?
	local playerGui = player:FindFirstChildWhichIsA('PlayerGui')
    if not playerGui then return nil end
    return playerGui:FindFirstChild(screenName) :: ScreenGui?
end


local function AddScreenGui(player: Player, screenGuiReference: ScreenGui): ScreenGui
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    assert(playerGui,`{player} has no playerGui`)

    local foundScreen = findScreenGui(screenGuiReference.Name, player)
    if foundScreen then return foundScreen end

    local screenGui = screenGuiReference:Clone()
    screenGui.Parent = playerGui

    return screenGui
end

local function RemoveScreenGui(player: Player, screenGuiReference: ScreenGui)
	local screenGui = findScreenGui(screenGuiReference.Name, player)
    if screenGui then
        screenGui:Destroy()
    end
end

--[[
    Give ScreenGui to all players. Joining or Existing  
]]
local function SynScreenGuiToAllPlayers(screenGuiReference: ScreenGui): RBXScriptConnection
    local function OnPlayerAdded(player: Player)
        AddScreenGui(player, screenGuiReference)
    end

    const connection = Players.PlayerAdded:Connect(OnPlayerAdded)

    for _, player in Players:GetChildren() do
        task.defer(OnPlayerAdded,player)
    end

    return connection
end

local function RemoveScreenGuiFromAll(screenGuiReference: ScreenGui)
    for _, player in Players:GetChildren() do
        task.defer(RemoveScreenGui,player, screenGuiReference)
    end
end

local function RemoveUIGroup(player: Player, folder: Folder)
	for _, screenGui: ScreenGui in folder:QueryDescendants(`ScreenGui`) do
		RemoveScreenGui(player,screenGui)
	end
end

local function AddUIGroup(player: Player, folder: Folder)
	for _, screenGui: ScreenGui in folder:QueryDescendants(`ScreenGui`) do
		AddScreenGui(player,screenGui)
	end
end


return {
    Add = AddScreenGui,
	AddGroup = AddUIGroup,
	
	Find = findScreenGui,
	
	Remove = RemoveScreenGui,
	RemoveGroup = RemoveUIGroup,
	
    RemoveFromAll = RemoveScreenGuiFromAll,

    SyncToAll = SynScreenGuiToAllPlayers,
}