
-- Creates A weld constraint by defult or a normal weld instance if you also pass in ture prop
local function CreateWeldConstraint(pO: BasePart, p1: BasePart, normalWeldInstance: boolean?): Weld | WeldConstraint
    local normalWeldInstance = normalWeldInstance or false
    local weld = normalWeldInstance and Instance.new('Weld') or Instance.new('WeldConstraint')
    weld.Part0 = pO
    weld.Part1 = p1
    weld.Parent = p1
    return weld
end

local function CreateMotor6DConstraint(pO: BasePart, p1: BasePart): Motor6D
    local motor6D =  Instance.new('Motor6D')
    motor6D.Part0 = pO
    motor6D.Part1 = p1
    motor6D.Parent = p1
    return motor6D
end

return {
    Weld = CreateWeldConstraint,
    Motor6D = CreateMotor6DConstraint,
}