--[[
    This is the base class that every Camera Profile will inherit.
]]--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local CameraHelper = require(ReplicatedStorage.Source.Modules.CameraProfiles._helper)

local CameraProfile = {}
CameraProfile.__index = CameraProfile

function CameraProfile.new(ProfileName, ControllerReference, DefaultEnvironment)
    local self = {
        Name = ProfileName,
        Controller = ControllerReference,
        Environment = TableUtil.Reconcile({CFrame = CFrame.new(), Rotation = Vector2.new(0,0)}, DefaultEnvironment),
        Helper = CameraHelper,

        _updateWarn = false,
    }

    setmetatable(self, CameraProfile)

    return self
end

function CameraProfile:Initialize()
    warn(string.format("No implementation of %sProfile:Initialize()", self.Name))
end

function CameraProfile:Update()
    if not self._updateWarn then
        self._updateWarn = true
        warn(string.format("No implementation of %sProfile:Update()", self.Name))
    end
end

return CameraProfile