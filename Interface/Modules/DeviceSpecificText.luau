const ReplicatedStorage = game:GetService("ReplicatedStorage")
const UserInputService = game:GetService("UserInputService")


const Maid = require(ReplicatedStorage.Shared.Libraries.Maid)



export type Data = {
	Mobile: string?,
	PC: string?,
	Console: string?,
}


local function getDataKey(): string
	const inputType = UserInputService.PreferredInput
	
	if inputType == Enum.PreferredInput.Gamepad then
		return "Console"
	end
	
	if inputType == Enum.PreferredInput.KeyboardAndMouse then
		return "PC"
	end
	
	return "Mobile"
end

return function(maid: Maid.Type,textLable: TextLabel, data: Data)
	
	local function update()
		const Text = data[getDataKey()] or ""
		textLable.Text = Text
	end
	
	maid['ReferedInput'] = UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(update)
	update()
end