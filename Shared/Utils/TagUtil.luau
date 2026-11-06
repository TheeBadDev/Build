
local CollectionService = game:GetService("CollectionService")

type Callback = <a>(instance: a, tag: string?)->()

local function ConnectTagRemoved(tag: string, callback: (instance: Instance) -> ()): RBXScriptConnection
	return CollectionService:GetInstanceRemovedSignal(tag):Connect(callback)
end

local function ConnectTagAdded(tag: string, callback: (instance: Instance) -> ()): RBXScriptConnection
	return CollectionService:GetInstanceAddedSignal(tag):Connect(callback)
end

--[[
	Returns a table of all *direct child* Instances of `parent` that have the given tag.
]]
local function GetTaggedChildren(parent: Instance, tagName: string): {Instance}
	return parent:QueryDescendants(`> .{tagName}`)
end

--[[
	Returns a table of all *descendant* Instances of `parent` that have the given tag.
]]
local function GetTaggedDescendants(parent: Instance, tagName: string): {Instance}
	return parent:QueryDescendants(`.{tagName}`)
end



--[[
	Fires `callback` for all currently tagged instances, then listens for future ones.
]]
local function ConnectTagAddedWithBackfill(tag: string, callback: (instance: Instance) -> ()): RBXScriptConnection
	local connection = ConnectTagAdded(tag, callback)
	for _, instance in CollectionService:GetTagged(tag) do
		callback(instance)
	end
	return connection
end

local function FireIfSameInstance(target: Instance, received: Instance, callback: Callback, tag: string?)
	if target ~= received then return end
	callback(target,tag)
end

--[[
	Fires `callback` if/when the specific `instance` receives the given tag.
	Also backfills if the tag is already present.
]]
local function ConnectTagAddedToInstance(tag: string, instance: Instance, callback: Callback): RBXScriptConnection
	local connection = ConnectTagAdded(tag, function(child: Instance)
		FireIfSameInstance(instance, child, callback, tag)
	end)

	for _, child in CollectionService:GetTagged(tag) do
		FireIfSameInstance(instance, child, callback, tag)
	end

	return connection
end

--[[
	Fires `callback` when the given tag is removed from the specific `instance`.
]]
local function ConnectTagRemovedFromInstance(tag: string, instance: Instance, callback: Callback): RBXScriptConnection
	return ConnectTagRemoved(tag, function(child: Instance)
		FireIfSameInstance(instance, child, callback)
	end)
end

local function RemoveAllTags(instance: Instance)
	for _, tag in CollectionService:GetTags(instance) do
		CollectionService:RemoveTag(instance, tag)
	end
end

local function RemoveTagFromAllInstances(tag: string)
	for _, instance in CollectionService:GetTagged(tag) do
		CollectionService:RemoveTag(instance, tag)
	end
end

local function TagAllInstanceInList(list: {Instance}, tag: string)
	for _, instance: Instance in list do
		if typeof(instance) == "Instance" then
			instance:AddTag(tag)
		else
			warn(`Expected Instance in list, got {typeof(instance)}`)
		end
	end
end

local function RemoveTagFromAllInstanceInList(list: {Instance}, tag: string)
	for _, instance: Instance in list do
		if typeof(instance) == "Instance" then
			instance:RemoveTag(tag)
		else
			warn(`Expected Instance in list, got {typeof(instance)}`)
		end
	end
end

local function GetNumberOfInstancesTagged(tag: string): (number, {Instance})
	local tagged = CollectionService:GetTagged(tag)
	return (#tagged or 0), tagged 
end

local function GetAliveCharactersTaggedWith(tag: string): {Model}
	return workspace:QueryDescendants(`> Model.{tag}:has(> Humanoid:not([Health = 0]))`)
end


return {
	CharactersTagged = GetAliveCharactersTaggedWith,
	TagGroup 		= TagAllInstanceInList,
	RemoveTagFromGroup 		= RemoveTagFromAllInstanceInList,
	TaggedCount		 = GetNumberOfInstancesTagged,
	TagAllInList	 = TagAllInstanceInList,
	TaggedChildren      = GetTaggedChildren,
	TaggedDescendants   = GetTaggedDescendants,
	OnAdded          = ConnectTagAddedWithBackfill,
	OnRemoved        = ConnectTagRemoved,
	OnAddedRaw       = ConnectTagAdded,
	OnRemovedRaw     = ConnectTagRemoved,
	OnAddedToInstance   = ConnectTagAddedToInstance,
	OnRemovedFromInstance = ConnectTagRemovedFromInstance,
	RemoveAll        = RemoveAllTags,
	RemoveFromAll	=	RemoveTagFromAllInstances, 
}