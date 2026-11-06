---    Manages the cleaning of events and other things.
-- Useful for encapsulating state and make deconstructors easy
-- @classmod Maid
-- @see Signal
export type Type = {
	[string]: Instance,
	ClassName: string,
	GiveTask: (self: Type, task: () -> () | RBXScriptConnection | { Destroy: () -> () } | Type | thread | Instance) -> number,
	GivePromise: (self: Type, promise: any) -> any,
	DoCleaning: (self: Type) -> (),
	Destroy: (self: Type) -> (),
	new: () -> Type,
	isMaid: (value: any) -> boolean,
}

local Maid = {}
Maid.ClassName = "Maid"

local function safeCancel(thread)
	if typeof(thread) == "thread" and coroutine.status(thread) == "suspended" then
		task.cancel(thread)
	end
end

--- Returns a new Maid object
-- @constructor Maid.new()
-- @treturn Maid
function Maid.new(): Type
	return setmetatable({
		_tasks = {},
	}, Maid)
end

function Maid.isMaid(value)
	return type(value) == "table" and value.ClassName == "Maid"
end

--- Returns Maid[key] if not part of Maid metatable
-- @return Maid[key] value
function Maid:__index(index)
	if Maid[index] then
		return Maid[index]
	else
		return self._tasks[index]
	end
end

--- Add a task to clean up.
function Maid:__newindex(index, newTask)
	if Maid[index] ~= nil then
		error(("'%s' is reserved"):format(tostring(index)), 2)
	end

	local tasks = self._tasks
	local oldTask = tasks[index]

	if oldTask == newTask then
		return
	end

	tasks[index] = newTask

	if oldTask then
		if type(oldTask) == "function" then
			oldTask()
		elseif typeof(oldTask) == "RBXScriptConnection" then
			oldTask:Disconnect()
		elseif typeof(oldTask) == "thread" then
			safeCancel(oldTask)
		elseif typeof(oldTask) == "Instance" then
			oldTask:Destroy()
		elseif type(oldTask) == "table" and oldTask.Disconnect then
			oldTask:Disconnect()
		elseif type(oldTask) == "table" and oldTask.Destroy then
			oldTask:Destroy()
		end
	end
end

--- Same as indexing, but uses an incremented number as a key.
-- @param task An item to clean
-- @treturn number taskId
function Maid:GiveTask(newTask)
	if not newTask then
		error("Task cannot be false or nil", 2)
	end

	local taskId = #self._tasks + 1
	self[taskId] = newTask

	if type(newTask) == "table" and not newTask.Destroy then
		warn("[Maid.GiveTask] - Gave table task without .Destroy\n\n" .. debug.traceback())
	end

	return taskId
end

function Maid:GivePromise(promise)
	if not promise:IsPending() then
		return promise
	end

	local newPromise = promise.resolved(promise)
	local id = self:GiveTask(newPromise)

	-- Ensure GC
	newPromise:Finally(function()
		self[id] = nil
	end)

	return newPromise
end

--- Cleans up all tasks.
-- @alias Destroy
function Maid:DoCleaning()
	local tasks = self._tasks

	-- Disconnect all events first as we know this is safe
	for index, job in pairs(tasks) do
		if typeof(job) == "RBXScriptConnection" then
			tasks[index] = nil
			job:Disconnect()
		end
	end

	-- Cancel all suspended threads before running other cleanup tasks
	for index, job in pairs(tasks) do
		if typeof(job) == "thread" then
			tasks[index] = nil
			safeCancel(job)
		end
	end

	-- Clear out tasks table completely, even if cleanup tasks add more tasks to the maid
	local index, job = next(tasks)
	while job ~= nil do
		tasks[index] = nil
		if type(job) == "function" then
			job()
		elseif typeof(job) == "RBXScriptConnection" then
			job:Disconnect()
		elseif typeof(job) == "thread" then
			safeCancel(job)
		elseif typeof(job) == "Instance" then
			job:Destroy()
		elseif type(job) == "table" and job.Disconnect then
			job:Disconnect()
		elseif type(job) == "table" and job.Destroy then
			job:Destroy()
		end
		index, job = next(tasks)
	end
end

--- Alias for DoCleaning()
-- @function Destroy
Maid.Destroy = Maid.DoCleaning

return Maid
