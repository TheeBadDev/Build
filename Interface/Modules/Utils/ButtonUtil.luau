
const ReplicatedStorage = game:GetService("ReplicatedStorage")


const Maid = require(ReplicatedStorage.Shared.Libraries.Maid)
const Throttle = require(ReplicatedStorage.Shared.Libraries.Throttle)

const DEFULT_DELAY = 0.2

type Callack = (...any?)->()

local function ButtonClick(button: GuiButton, callback: Callack,...) : RBXScriptConnection
	const args = {...}
	
	return button.Activated:Connect(function()
		Throttle('Click',DEFULT_DELAY,function()
			callback(unpack(args))
		end)
	end)
end


return {
	Click = ButtonClick,
}