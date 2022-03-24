--[[
    The System Controller handles running systems.
    A "System" could be used for anything, and is completely versatile.
]]--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local SystemController = Knit.CreateController({
    Name = "SystemController"
})

function SystemController:GetSystem(SystemName)
    return self._systems[SystemName]
end

function SystemController:KnitStart()
    local Done = 0

    for _, System in pairs(self._systems) do
        task.spawn(function()
            if System.Init then
                System.Init()
            end

            Done += 1
        end)
    end

    repeat
        task.wait()
    until Done >= self._systemCount

    for _, System in pairs(self._systems) do
        if System.Start then
            task.spawn(System.Start)
        end
    end
end

function SystemController:_loadSystems()
    local Systems = ReplicatedStorage.Source.Modules.Systems:GetChildren()

    self._systemCount = #Systems

    for _, System in pairs(Systems) do
        self._systems[System.Name] = require(System)
    end
end

function SystemController:KnitInit()
    self._systems = {}
    self:_loadSystems()
end

return SystemController