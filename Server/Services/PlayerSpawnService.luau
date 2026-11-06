
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")



const EquippedBlocks = require(ServerScriptService.Server.Modules.EquippedBlocks)
const Observers = require(ReplicatedStorage.Shared.Libraries.Observers)




local function OnPlayerObserved(player: Player)
    
end

Observers.observePlayer(OnPlayerObserved)


return {}