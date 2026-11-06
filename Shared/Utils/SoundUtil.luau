
local PartInstance = Instance.new("Part")
PartInstance.Transparency = 1
PartInstance.Anchored = true
PartInstance.CanCollide = false
PartInstance.CanTouch = false
PartInstance.CanQuery = false

local Debris = game:GetService('Debris')
local soundService = game:GetService('SoundService')
local ContentProvider = game:GetService('ContentProvider')


local function createSoundClone(sound: Sound): Sound?
	assert(sound, `{sound} sound nil`)

	if not sound.Loaded then
		pcall(ContentProvider.PreloadAsync, ContentProvider, {sound})
	end

	if not sound.Loaded then
		warn(`{sound} not loaded`)
		return
	end

	local clone = sound:Clone()
	
	return clone 
end

function PlayFromPlayerCharacter(character: Model, sound: Sound)
	local rootPart = character:FindFirstChild('HumanoidRootPart') :: BasePart
	assert(rootPart, `{character} has no HumanoidRootPart`)

	local newSound = createSoundClone(sound)
	if not newSound then return end
	newSound.PlayOnRemove = true
	newSound.Parent = rootPart

	newSound:Destroy()
end

function PlaySoundInElement(soundReference: Sound, element: GuiObject)
    local sound = createSoundClone(soundReference)
	if not sound then return end
    sound.PlayOnRemove = true
    sound.Parent = element
    sound:Destroy()
end

function PlayInInstance(sound: Sound, instance: Instance)
	local newSound = createSoundClone(sound)
	if not newSound then return end
	newSound.PlayOnRemove = true
	newSound.Parent = instance

	newSound:Destroy()
end

function PlayAtPosition(sound: Sound, position: Vector3)
    local part = PartInstance:Clone()
    local soundClone = createSoundClone(sound)
    if not soundClone then return end

    part.CFrame = CFrame.new(position)
    part.Parent = workspace
	soundClone.Parent = part
	
	soundClone:Play()
	Debris:AddItem(part,sound.TimeLength + 1)
end

function PlaySoundOnClient(sound: Sound)
	local newSound = createSoundClone(sound)
	if not newSound then return end

	newSound.PlayOnRemove = true
	newSound.Parent = soundService
	
	newSound:Destroy()
end

function PlaySoundInWorkspace(sound: Sound)
	const soundClone = createSoundClone(sound)
	if not soundClone then return end
	soundClone.PlayOnRemove = true
	soundClone.Parent = workspace
	soundClone:Destroy()
end

return {
	InWorkspace = PlaySoundInWorkspace,
	
	OnClient = PlaySoundOnClient,
	AtPosition = PlayAtPosition,
	InInstance = PlayInInstance,
	InElement = PlaySoundInElement,
	PlayerCharacter = PlayFromPlayerCharacter,
}