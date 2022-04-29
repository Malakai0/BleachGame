--[[
    Test tool.
]]--

local Test = {}

function Test:Init()
    self.Model = Instance.new("Model")

    local Part = Instance.new("Part")

    Part.CanCollide = false
    Part.Anchored = false

    Part.Parent = self.Model
    self.Model.PrimaryPart = Part
end

function Test:Equip()
    self:_equip(true)
    self.Model.Parent = self.Player.Character
    print("rawr")
end

function Test:Unequip()
    self:_unequip()
    self.Model.Parent = nil
end

function Test:Activated()
    print("Activated", self.Name)
end

function Test:Unactivated()
    print("Unactivated", self.Name)
end

return Test