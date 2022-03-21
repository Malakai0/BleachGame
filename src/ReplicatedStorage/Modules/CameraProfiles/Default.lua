--[[
    The default camera is to be active whilst a player has no specific profile active.
    Any "specific profile" would be when a player is wielding a wepaon; talking to an npc; during konso, etc.
]]--

local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

local ZOOM_OFFSET = 10
local OFFSET = CFrame.new(0, 1.5, 0)
local ZOOM_BOUNDS = {0, 4}
local SENSITIVITY = 1
local ROTATION_BOUND = math.rad(79)

local DefaultCamera = {}

DefaultCamera.Priority = 1

function DefaultCamera:Initialize()
    local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    local Camera: Camera = self.Controller.Camera

    Character:WaitForChild("HumanoidRootPart")

    Camera.CameraSubject = nil
    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.FieldOfView = 75

    local ZoomOffset = math.max(ZOOM_OFFSET / 2, (ZOOM_OFFSET * self.Environment.Zoom))

    local Rotation = self.Environment.Rotation
    local Subject = CFrame.new(Character.Head.Position)

    local RotationAngle = CFrame.Angles(Rotation.Y, Rotation.X, 0)
    local TargetCFrame = Subject * RotationAngle * CFrame.new(0, 0, ZoomOffset) * OFFSET

    self.Environment.CFrame = self.Helper.DetermineCFrame(Character.HumanoidRootPart.CFrame, TargetCFrame, {Character})
    self.Environment.LastPosition = UserInputService:GetMouseLocation()

    self.ZoomInput = self:GenerateUniqueString("ZoomInput")

    ContextActionService:BindAction(self.ZoomInput, function(_, State, Input)
        self.Environment.Zoom = math.clamp(self.Environment.Zoom - Input.Position.Z, unpack(ZOOM_BOUNDS))
    end, false, Enum.UserInputType.MouseWheel)
end

function DefaultCamera:Deinitialize()
    ContextActionService:UnbindAction(self.ZoomInput)
end

function DefaultCamera:Update()
    local Camera: Camera = self.Controller.Camera

    if not Players.LocalPlayer.Character then
        return
    end

    if not Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition

        local Location = UserInputService:GetMouseLocation()
        local Delta = UserInputService:GetMouseDelta()

        if UserInputService.MouseBehavior == Enum.MouseBehavior.Default then
            Delta = Location - self.Environment.LastPosition
        end

        local CurrentRotation = self.Environment.Rotation
        local Rotation = self.Helper.SolveRotation(CurrentRotation, Vector2.new(-SENSITIVITY, -SENSITIVITY * (9/16)), Delta)

        self.Environment.Rotation = Vector2.new(Rotation.X, math.clamp(Rotation.Y, -ROTATION_BOUND, ROTATION_BOUND))
        self.Environment.LastPosition = Location
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end

    local ZoomOffset = math.max(ZOOM_OFFSET / 2, (ZOOM_OFFSET * self.Environment.Zoom))
    local Subject = CFrame.new(Players.LocalPlayer.Character.HumanoidRootPart.Position)

    local Rotation = self.Environment.Rotation
    local RotationAngle = CFrame.Angles(0, Rotation.X, 0) * CFrame.Angles(Rotation.Y, 0, 0)
    local TargetCFrame = Subject * RotationAngle * CFrame.new(0, 0, ZoomOffset) * OFFSET

    local CameraCFrame = self.Helper.DetermineCFrame(Subject * OFFSET, TargetCFrame, {Players.LocalPlayer.Character})

    self.Environment.CFrame = CameraCFrame
    Camera.CFrame = CameraCFrame
end

return DefaultCamera