const ReplicatedStorage = game:GetService("ReplicatedStorage")


const GameStateEnums = require(ReplicatedStorage.Shared.Enums.GameStateEnums)


const GameStateValue = ReplicatedStorage.GameValues.State


export type Enums = typeof(GameStateEnums)


local function GetGameState(): string?
	return GameStateValue.Value
end

local function SetGameState(newState: string)
	GameStateValue.Value = newState
end



return {
	ValueInstance = GameStateValue,
	Enums = GameStateEnums,
	
	GetCurrent = GetGameState,
	Set = SetGameState,
}