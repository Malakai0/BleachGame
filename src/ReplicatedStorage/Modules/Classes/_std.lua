local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.Trove)

local PlayerClass = {}
PlayerClass.__index = PlayerClass

function PlayerClass.new(Name, ControllerReference, DefaultEnvironment)
    local self = {
        Name = Name,
        Controller = ControllerReference,
        Environment = (DefaultEnvironment or {}),

        Trove = Trove.new(),
    }

    setmetatable(self, PlayerClass)

    return self
end

function PlayerClass:GenerateUniqueString(String)
    return string.format("%s %s", self.Name, String)
end

function PlayerClass:Deinitialize()
    self.Trove:Destroy()
    -- No warn here, may not be necessary in some profiles.
    return
end

function PlayerClass:Initialize()
    warn(string.format("No implementation of %sClass:Initialize()", self.Name))
end

return PlayerClass