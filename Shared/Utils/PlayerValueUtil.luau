const ReplicatedStorage = game:GetService("ReplicatedStorage")

const InstanceSchema = require(ReplicatedStorage.Shared.Modules.InstanceSchema)

local function newSchema()
	const currentScore = Instance.new("NumberValue")
	currentScore.Value = 0

	return {
		Taunt = {
			CurrentScore = currentScore,
		},
	}
end

const Template = newSchema()

export type Data = typeof(Template)

local function getData(player: Player): Data?
	return InstanceSchema.Get(player, Template) :: Data?
end

local function getTaunt(player: Player): typeof(Template.Taunt)?
	const data = getData(player)
	return if data then data.Taunt else nil
end

local function createPlayerValues(player: Player): Data
	return InstanceSchema.Create(player, newSchema()) :: Data
end

local function getPlayerValues(player: Player): Data?
	const found = getData(player)
	if found then
		return found
	end

	task.wait(2)
	return getData(player)
end

return {
	Get = getPlayerValues,
	GetTaunt = getTaunt,
	Create = createPlayerValues,
}