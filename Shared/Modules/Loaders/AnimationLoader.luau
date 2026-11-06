export type AnimationID = string | number
export type KeyframeCallback = (markerName: string) -> nil

export type AnimationData = {
	Connection: RBXScriptConnection?,
	AnimationTrack: AnimationTrack
}

export type AnimationAddress = {
	[string]: AnimationData
}

local ANIMATION_EXTENSION = "rbxassetid://"
local NO_CATEGORY = "None"

local Animations: {
	[Model]: {
		[string]: AnimationAddress
	}
} = {}

local Connections: { [Model]: RBXScriptConnection } = {}

-- Helpers

local function sanitizeAnimationID(data: AnimationID): string
	if typeof(data) == "number" then
		return `{ANIMATION_EXTENSION}{data}`
	else
		return data
	end
end

local function getAnimator(character: Model): Animator?
	local humanoid = character:FindFirstChildWhichIsA("Humanoid") or character:WaitForChild('Humanoid',10)
	if not humanoid then
		warn(`{script.Name} {character} has no Humanoid`)
		return nil
	end

	local animator = humanoid:FindFirstChildWhichIsA("Animator") or humanoid:WaitForChild('Animator',10)
	assert(animator,`{character} has no Animator object`)
	return animator
end

local function getAnimation(animationID: string): Animation
	local animation = Instance.new("Animation")
	animation.AnimationId = animationID
	return animation
end

local function getAnimationAddress(character: Model, category: string): AnimationAddress
	Animations[character] = Animations[character] or {}
	Animations[character][category] = Animations[character][category] or {}
	return Animations[character][category]
end

local function findAnimationTrack(character: Model, category: string, animationID: AnimationID): AnimationTrack?
    local characterData = Animations[character]
    if not characterData then return nil end

    local animationAddress = characterData[category]
    if not animationAddress then return nil end

    local sanitized = sanitizeAnimationID(animationID)
    local animationData = animationAddress[sanitized]

    if animationData then
        local track = animationData.AnimationTrack
        if track then
            return track
        else
            if animationData.Connection then
                animationData.Connection:Disconnect()
            end
            animationAddress[sanitized] = nil
        end
    end
    return nil
end

local RemoveAll: (character: Model) -> ()



--[[
	Loads an animation onto `character` and caches it under `category`.
	Optionally connects a `keyframeCallback` to `KeyframeReached`.
	Returns the loaded AnimationTrack, or nil if the character has no Humanoid.
	Sets up a one-time AncestryChanged watcher on the first load to auto-cleanup on removal.
]]
local function LoadAnimation(character: Model, animationID: AnimationID, category: string?, keyframeCallback: KeyframeCallback?): AnimationTrack?
	local resolvedCategory = category or NO_CATEGORY
	local resolvedID = sanitizeAnimationID(animationID)

	if not Animations[character] then
		Connections[character] = character.AncestryChanged:Connect(function()
			if not character:IsDescendantOf(game) then
				RemoveAll(character)
			end
		end)
	end

	local animationAddress = getAnimationAddress(character, resolvedCategory)

	if animationAddress[resolvedID] then return animationAddress[resolvedID].AnimationTrack end

	local animator = getAnimator(character)
	if not animator then return end

	local animation = getAnimation(resolvedID)
	local animationTrack = animator:LoadAnimation(animation)

	local keyframeConnection: RBXScriptConnection? = nil
	if keyframeCallback then
		keyframeConnection = animationTrack.KeyframeReached:Connect(keyframeCallback)
	end

	animationAddress[resolvedID] = {
		Connection = keyframeConnection,
		AnimationTrack = animationTrack,
	}

	animation:Destroy()

	return animationTrack
end

--[[
	Plays a cached or newly loaded animation on `character`.
	Accepts optional `fadeTime`, `weight`, and `speed` parameters passed to `AnimationTrack:Play`.
]]
local function PlayAnimation(character: Model, animationID: AnimationID, category: string?, fadeTime: number?, weight: number?, speed: number?)
	local resolvedCategory = category or NO_CATEGORY
	local resolvedID = sanitizeAnimationID(animationID)
	local animationTrack = findAnimationTrack(character, resolvedCategory, resolvedID) or LoadAnimation(character, resolvedID, resolvedCategory)
	if animationTrack then
		animationTrack:Play(fadeTime, weight, speed)
	end
end

--[[
	Stops a cached animation on `character` without removing it from the cache.
	Use `Remove` instead if you want the track fully destroyed and cleaned up.
]]
local function StopAnimation(character: Model, animationID: AnimationID, category: string?)
	local track = findAnimationTrack(character, category or NO_CATEGORY, animationID)
	if track then
		track:Stop()
	end
end

--[[
	Disconnects the KeyframeReached connection for a specific animation, if one exists.
]]
local function DisconnectKeyframeConnection(character: Model, animationID: AnimationID, category: string?)
	local resolvedCategory = category or NO_CATEGORY
	local resolvedID = sanitizeAnimationID(animationID)
	local address = getAnimationAddress(character, resolvedCategory)
	local data = address[resolvedID]
	if data and data.Connection then
		data.Connection:Disconnect()
		data.Connection = nil
	end
end

--[[
	Returns the cached AnimationTrack for `character`, or nil if it hasn't been loaded yet.
]]
local function GetAnimationTrack(character: Model, animationID: AnimationID, category: string?): AnimationTrack?
	local resolvedCategory = category or NO_CATEGORY
	local resolvedID = sanitizeAnimationID(animationID)
	return findAnimationTrack(character, resolvedCategory, resolvedID)
end

--[[
	Returns all live AnimationTracks cached under `category` for `character`.
	Dead tracks (nil Parent) are pruned and their connections disconnected during this call.
]]
local function GetAnimationTrackList(character: Model, category: string?): {AnimationTrack}
	local resolvedCategory = category or NO_CATEGORY
	local address = getAnimationAddress(character, resolvedCategory)
	local tracks = {}
	for id, data in address do
		if data.AnimationTrack and data.AnimationTrack.Parent then
			table.insert(tracks, data.AnimationTrack)
		else
			if data.Connection then -- FIX: disconnect before pruning
				data.Connection:Disconnect()
			end
			address[id] = nil
		end
	end
	return tracks
end

--[[
	Stops and destroys a single cached animation, disconnecting any keyframe connection.
]]
local function RemoveAnimation(character: Model, animationID: AnimationID, category: string?)
	local resolvedCategory = category or NO_CATEGORY
	local resolvedID = sanitizeAnimationID(animationID)
	local address = getAnimationAddress(character, resolvedCategory)
	local data = address[resolvedID]
	if data then
		if data.Connection then
			data.Connection:Disconnect()
		end
		data.AnimationTrack:Stop()
		data.AnimationTrack:Destroy()
		address[resolvedID] = nil
	end
end

--[[
	Stops and destroys all animations cached under `category` for `character`.
]]
local function RemoveAnimationInCategory(character: Model, category: string)
	local address = getAnimationAddress(character, category)

	local ids = {}
	for id in address do
		table.insert(ids, id)
	end

	for _, id in ids do
		local data = address[id]
		if data then
			if data.Connection then
				data.Connection:Disconnect()
			end
			data.AnimationTrack:Stop()
			data.AnimationTrack:Destroy()
			address[id] = nil
		end
	end

	Animations[character][category] = nil
end

--[[
	Stops and destroys all animations across all categories for `character`,
	and removes the character entry from the cache entirely.
	Also disconnects the AncestryChanged watcher set up on first load.
]]
RemoveAll = function(character: Model)
	if not Animations[character] then return end

	local categories = {}
	for category in pairs(Animations[character]) do
		table.insert(categories, category)
	end

	for _, category in categories do
		RemoveAnimationInCategory(character, category)
	end

	Animations[character] = nil

	if Connections[character] then
		Connections[character]:Disconnect()
		Connections[character] = nil
	end
end

return {
	Load             = LoadAnimation,
	Play             = PlayAnimation,
	Stop             = StopAnimation,

	DisconnectKeyframe = DisconnectKeyframeConnection,

	GetTrack         = GetAnimationTrack,
	GetList          = GetAnimationTrackList,

	Remove           = RemoveAnimation,
	RemoveInCategory = RemoveAnimationInCategory,
	RemoveAll        = RemoveAll,
}