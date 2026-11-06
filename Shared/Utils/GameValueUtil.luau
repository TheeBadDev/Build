const ReplicatedStorage = game:GetService("ReplicatedStorage")

const InstanceSchema = require(ReplicatedStorage.Shared.Modules.InstanceSchema)

const Folder = ReplicatedStorage.GameValues

const DEFAULT_TARGET = 10
const DEFAULT_INCREMENT = 1

local function newSchema()
	const target = Instance.new("NumberValue")
	target.Value = DEFAULT_TARGET

	const increment = Instance.new("NumberValue")
	increment.Value = DEFAULT_INCREMENT

	return {
		Score = {
			Target = target,
			Increment = increment,
		},

		Round = {
			CanJoin = Instance.new("BoolValue"),
			Taunt = {
				LeadingPlayer = Instance.new("ObjectValue"),
			},
		},
	}
end

const Template = newSchema()

export type Data = typeof(Template)

local function createGameValues(): Data
	return InstanceSchema.Create(Folder, newSchema()) :: Data
end

local function getGameValues(): Data?
	return InstanceSchema.Get(Folder, Template) :: Data?
end

return {
	Get = getGameValues,
	Create = createGameValues,
}