--[[
    The Camera Controller loads and activates profiles for different situations.
    Should have high versatility for different variations of weapons & states.
]]--

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VALID_SHAKE_SETTINGS = {"FadeInTime", "Frequency", "Amplitude", "RotationInfluence"}
local BLACKLISTED_PROFILES = {"_info", "_std", "_helper"}

local Knit = require(ReplicatedStorage.Packages.Knit)
local Shake = require(ReplicatedStorage.Packages.Shake)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local BaseProfile = require(ReplicatedStorage.Source.Modules.CameraProfiles._std)

local CameraProfiles = ReplicatedStorage.Source.Modules.CameraProfiles

local CurrentCamera = workspace.CurrentCamera

local CameraController = Knit.CreateController({
    Name = "CameraController"
})

function CameraController:Shake(ShakeLength)
    self._shakeActive = true
    task.delay(ShakeLength, function()
        self._shakeActive = false
    end)
end

function CameraController:ApplyShakeSettings(Settings)
    for _, SettingKey in pairs(VALID_SHAKE_SETTINGS) do
        local Setting = Settings[SettingKey]
        if Setting then
            self._shake[SettingKey] = Setting
        end
    end
end

function CameraController:SetPriority(ProfileID, Priority)
    local Profile = self._activeProfiles[ProfileID]

    if Profile then
        Profile.Priority = Priority
    end
end

-- TODO: Think of better name.
function CameraController:GetProfile()
    local Profile = nil

    for _, Candidate in pairs(self._activeProfiles) do
        if (not Profile) or Candidate.Priority > Profile.Priority then
            Profile = Candidate
        end
    end

    return Profile
end

function CameraController:InitializeProfile()
    local Profile = self:GetProfile()

    if not Profile or Profile._initialized then
        return
    end

    Profile._initialized = true
    Profile:Initialize()
end

function CameraController:ActivateProfile(ProfileName, Environment)
    local ProfileTemplate = self._loadedProfiles[ProfileName]

    if not ProfileTemplate then
        return
    end

    local ProfileID = HttpService:GenerateGUID(false)
    local Profile = setmetatable(TableUtil.Copy(ProfileTemplate), {
        __index = BaseProfile.new(ProfileName, self, ProfileID, Environment or {})
    })

    self._activeProfiles[ProfileID] = Profile

    return Profile
end

function CameraController:DeactivateProfile(ProfileID)
    local Profile = self._activeProfiles[ProfileID]

    if not Profile then
        return
    end

    Profile:Deinitialize()
    self._activeProfiles[ProfileID] = nil
end

function CameraController:_loadProfiles()
    self._loadedProfiles = {}

    for _, Profile in pairs(CameraProfiles:GetChildren()) do
        if not table.find(BLACKLISTED_PROFILES, Profile.Name) then
            self._loadedProfiles[Profile.Name] = require(Profile)
        end
    end
end

function CameraController:KnitInit()
    self.Camera = CurrentCamera

    self:_loadProfiles()
    self._activeProfiles = {}
    self._shakeActive = false

    local lastProfile

    self._cameraUpdater = RunService.Heartbeat:Connect(function(dt)
        local Profile = self:GetProfile()

        if Profile ~= lastProfile then
            if lastProfile then
                lastProfile:Deinitialize()
            end

            self:InitializeProfile()
        end

        if Profile and Profile._initialized then
            Profile:Update(dt)
        end

        lastProfile = Profile
    end)

    local _shake = Shake.new()
    _shake.FadeInTime = 0
    _shake.Frequency = 0
    _shake.Amplitude = 0
    _shake.RotationInfluence = Vector3.zero

    _shake:Start()
    _shake:BindToRenderStep(_shake.NextRenderName(), Enum.RenderPriority.Camera.Value, function(Position, Rotation)
        if self._shakeActive then
            self.Camera.CFrame *= CFrame.new(Position) * CFrame.Angles(Rotation.X, Rotation.Y, Rotation.Z)
        end
    end)

    self.Shake = _shake
end

function CameraController:KnitStart()
    self:ActivateProfile("Default", {
        Zoom = 1
    }) --// Initialize the Default profile off the rip.
end

return CameraController