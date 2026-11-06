local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Shared.Libraries.Signal)

local StateMachine = {}
StateMachine.__index = StateMachine


local DEFAULT_STATE = 'None'

type StateName = string

export type Transitions = {
	[StateName] : { StateName } 
}

type Callback = (self: Interface,...any?)->()

export type Interface = typeof(setmetatable({} :: {
	_CurrentState: string,
	_Transitions: Transitions?,
	_Callbacks: { [StateName]: Callback },
	StateChanged: Signal.SignalType,
	Destroying: Signal.SignalType,
}, StateMachine))


function StateMachine.new(transitions: Transitions?): Interface
	local self = setmetatable({
		_CurrentState = DEFAULT_STATE,
		_Transitions = transitions,
		_Callbacks = {},
		StateChanged = Signal.new(),
		Destroying = Signal.new(),
	}, StateMachine)
	return self
end

function StateMachine.GetCurrentState(self: Interface): string
	return self._CurrentState
end

function StateMachine.ValidateTransition(self: Interface, newState: StateName): boolean
	if not self._Transitions then
		return true
	end

	if self._CurrentState == DEFAULT_STATE then
		return true
	end

	if not table.find(self._Transitions[self._CurrentState], newState) then
		return false
	end

	return true
end

function StateMachine._UpdateCurrentState(self: Interface, newState: StateName)
	if newState == self._CurrentState then
		warn(`{script.Name}: {newState} -Transition To Same State`)
	end
	self._CurrentState = newState
	self.StateChanged:Fire(newState)
end

function StateMachine.Change(self: Interface, newState: StateName, ...)
	local IsValidTransition = self:ValidateTransition(newState)
	assert(IsValidTransition,`{script.Name}: {self._CurrentState} State Invalid Transition To {newState}`)
	
	self:_UpdateCurrentState(newState)
	
	local callback = self._Callbacks[newState]
	assert(callback,`{script.Name}: {newState} Has No Callback function`)

	task.defer(callback,self,...)
end

function StateMachine.Assign(self: Interface, stateName: StateName, callback: Callback)
	if self._Callbacks[stateName] then
		warn(`{stateName} Already Has Callback Function`)
	end
	self._Callbacks[stateName] = callback
end

function StateMachine.Destroy(self: Interface)
	self.StateChanged:Fire(nil)
	self.Destroying:Fire()
	
	for index, _ in pairs(self) do
		self[index] = nil
	end
end

return StateMachine
