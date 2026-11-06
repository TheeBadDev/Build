
local Players = game:GetService("Players")

local function FireToWhiteListClients(event: RemoteEvent, list: {Player}, ...: any)
    for _, player in ipairs(list) do
        event:FireClient(player, ...)
    end
end

local function FireToAllClientsExcluding(event: RemoteEvent, list: {Player}, ...: any)
     for _, player in Players:GetPlayers() do
        if table.find(list,player) then return end
        event:FireClient(player, ...)
    end
end

return {
    FireWhiteList = FireToWhiteListClients,
    FireAllExcluding = FireToAllClientsExcluding
}