
local ReplicatedStorage = game:GetService("ReplicatedStorage")


const BlockFrame = require(script.BlockFrame)
const Find = require(ReplicatedStorage.Interface.Modules.Find)
const ScreenDetector = require(ReplicatedStorage.Interface.Modules.ScreenDetector)
local MaidModule = require(ReplicatedStorage.Shared.Libraries.Maid)
const DestroyUtil = require(ReplicatedStorage.Shared.Utils.DestroyUtil) 


const BlockHudEvents = game.ReplicatedStorage.Events.BlockEvents.BlockHudEvents


local BlockHud = {}
BlockHud.__index = BlockHud


export type Interface = typeof(setmetatable({} :: {
	_MAID: MaidModule.Type,
	BlockFrame: Frame,
	ToolFrame: Frame,
}, BlockHud))


function BlockHud.new(Screen: ScreenGui, BlockFrame: Frame, ToolFrame: Frame): Interface

	local self = setmetatable({
		_MAID = MaidModule.new(),
		BlockFrame = BlockFrame,
		ToolFrame = ToolFrame,
	}, BlockHud)

    self:Execute()

	return self
end



function BlockHud.Execute(self: Interface)
	const startingBlocks = BlockHudEvents.Equipped:InvokeServer()
	
	local function selectCallback(...)
		BlockHudEvents.Select:Fire(...)
	end
	
	BlockFrame(self._MAID,{
    	BlockFrame = self.BlockFrame,
		BlockList = startingBlocks,
		Callback = selectCallback
	})
end

function BlockHud.Destroy(self: Interface)
	self._MAID:Destroy()
	table.clear(self :: any)
end


return function()
	const SCREEN_NAME = 'BlockHUD'
	
	ScreenDetector.new(SCREEN_NAME, function(screen: ScreenGui)
		const _Find = Find(screen)

		const blockFrame = _Find.Frame("Blocks")
		const toolFrame = _Find.Frame("Tools")

		const class = BlockHud.new(screen,blockFrame,toolFrame)

		DestroyUtil.Callback(screen, function()
			class:Destroy()
		end)
	end)
	
end