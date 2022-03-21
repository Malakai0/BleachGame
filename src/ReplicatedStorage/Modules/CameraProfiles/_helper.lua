--[[
    This module holds helper functions for use of the camera.
    Separated from the BaseClass as that should only hold as much data as it should need to.
]]--

local Helper = {}

function Helper.SolveRotation(CurrentRotation, Sensitivity, Delta)
    local Change = (Sensitivity * Delta)
    local Rotation = CurrentRotation + Vector2.new(math.rad(Change.X), math.rad(Change.Y))

    return Rotation
end

function Helper.DeterminePosition(CurrentPosition, TargetPosition, IgnoreList)
    local Params = RaycastParams.new()
    Params.FilterDescendantsInstances = IgnoreList or {}
    Params.FilterType = Enum.RaycastFilterType.Blacklist
    Params.IgnoreWater = true

    local Direction = (TargetPosition - CurrentPosition)
    local Result = workspace:Raycast(CurrentPosition, Direction, Params)

    return if Result then Result.Position else TargetPosition
end

function Helper.DetermineCFrame(CurrentCFrame, TargetCFrame, IgnoreList)
    local Position = Helper.DeterminePosition(CurrentCFrame.Position, TargetCFrame.Position, IgnoreList)
    local Rotation = TargetCFrame.Rotation

    return CFrame.new(Position) * Rotation * CFrame.new(0, 0, -.5)
end

return Helper