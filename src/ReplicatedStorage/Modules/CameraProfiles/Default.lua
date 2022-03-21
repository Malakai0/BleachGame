--[[
    The default camera is to be active whilst a player has no specific profile active.
    Any "specific profile" would be when a player is wielding a wepaon; talking to an npc; during konso, etc.
]]--

local Players = game:GetService("Players")

local DefaultCamera = {}

DefaultCamera.Priority = 1

function DefaultCamera:Initialize()
    local Character = Players.LocalPlayer.Character
    local Camera: Camera = self.Controller.Camera

    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.FieldOfView = 75

    local TargetCFrame = Character.Head.CFrame * CFrame.new(0, 0, 5)

    self.Environment.CFrame = self.Helper.DetermineCFrame(Character.Head.CFrame, TargetCFrame)
end

function DefaultCamera:Update()

end

return DefaultCamera