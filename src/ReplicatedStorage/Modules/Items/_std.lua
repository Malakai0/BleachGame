--[[
    A PlayerItem is a class that will serve as a base for all items that players use.
    It will provide a lot of the basic functionality that is needed for all items.
]]--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ANIMATION_DIRECTORY = ReplicatedStorage.Assets.Animations
local DEFAULT_ANIMATION = "ToolNone"

local Trove = require(ReplicatedStorage.Packages.Trove)

local function PlayAnimation(AnimationName, Animator)
    local Animation = ANIMATION_DIRECTORY:FindFirstChild(AnimationName)

    if not Animation then
        return
    end

    local Track = Animator:LoadAnimation(Animation)
    Track:Play()
end

local PlayerItem = {}
PlayerItem.__index = PlayerItem

function PlayerItem.new(Name, Player, DefaultState)
    local self = {
        Player = Player,
        Name = Name,

        State = DefaultState or {},
        Animations = {},

        Trove = Trove.new(),

        _offset = CFrame.new(),
    }

    setmetatable(self, PlayerItem)

    self.Trove:Add(function()
        self:_cleanUp()
    end)

    return self
end

function PlayerItem:Activated()

end

function PlayerItem:Unactivated()

end

function PlayerItem:Equip()

end

function PlayerItem:Unequip()

end

function PlayerItem:AdjustGrip(Offset: CFrame)
    assert(typeof(Offset) == "CFrame", ":AdjustGrip(Offset), offset MUST be of type CFrame!")

    self._offset = Offset

    if self._weld then
        self._weld.C1 = Offset
    end
end

function PlayerItem:IsAnimationLoaded(AnimationName)
    return self.Animations[AnimationName] ~= nil
end

function PlayerItem:IsAnimationPlaying(AnimationName)
    if not self:IsAnimationLoaded(AnimationName) then
        return false
    end

    local Animation = self.Animations[AnimationName]

    return Animation.IsPlaying == true
end

function PlayerItem:PlayAnimation(AnimationName)
    local Character = self.Player.Character
    local Humanoid = if Character then Character:FindFirstChild("Humanoid") else nil
    local Animator = if Humanoid then Humanoid:FindFirstChild("Animator") else nil

    if not Animator then
        return
    end

    if self:_tryPlayFromCache(AnimationName) then
        return
    end

    PlayAnimation(AnimationName, Animator)
end

function PlayerItem:PlayToolAnimation(AnimationName)
    if not self.Model then
        return
    end

    local AnimationController = self.Model:FindFirstChild("AnimationController")

    if not AnimationController then
        AnimationController = Instance.new("AnimationController")
        AnimationController.Parent = self.Model
    end

    if self:_tryPlayFromCache(AnimationName) then
        return
    end

    PlayAnimation(AnimationName, AnimationController)
end

function PlayerItem:StopAnimation(AnimationName)
    if not self:IsAnimationPlaying(AnimationName) then
        return
    end

    local Animation = self.Animations[AnimationName]

    if not Animation then
        return
    end

    Animation:Stop()
    return true
end

function PlayerItem:StopAllAnimations()
    for _, Animation: AnimationTrack in pairs(self.Animations) do
        Animation:Stop()
        Animation:Destroy()
    end
end

function PlayerItem:_tryPlayFromCache(AnimationName)
    local Animation = self.Animations[AnimationName]

    if not Animation then
        return
    end

    Animation:Play()
    return true
end

function PlayerItem:_equip(_use_default_animation: boolean) -- Do not override, automatic Instance welding; should be used in :Equip()
    local Character = self.Player.Character
    local Hand = Character:FindFirstChild("RightHand")
    local Model = self.Model

    if not Hand or not Model then
        return
    end

    local Weld = Instance.new("Motor6D") --// Use a Motor6D; allows for animations.

    Weld.Part0 = Hand
    Weld.Part1 = Model.PrimaryPart
    Weld.C0 = CFrame.new()
    Weld.C1 = self._offset

    Weld.Parent = Model
    self._weld = Weld

    if _use_default_animation then
        local Humanoid = Character:FindFirstChild("Humanoid")
        local Animator = Humanoid:FindFirstChild("Animator")

        if not Animator then
            return
        end

        self:PlayAnimation(DEFAULT_ANIMATION)
    end
end

function PlayerItem:_unequip() -- Do not override, clean-up.
    self.Trove:Destroy()
end

function PlayerItem:_cleanUp() -- Do not override, clean up callback.
    if self._weld then
        self._weld:Destroy()
    end
    self:StopAllAnimations()
end

return PlayerItem