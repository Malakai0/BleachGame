--[[
    Handles classes for each player.
]]--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BLACKLISTED_CLASSES = {"_info", "_std", "_template"}

local Knit = require(ReplicatedStorage.Packages.Knit)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local BaseClass = require(ReplicatedStorage.Source.Modules.Classes._std)
local Compatibilities = require(ReplicatedStorage.Source.Modules.Compatibilities)

local ClassService = Knit.CreateService({
    Name = "ClassService",
    Client = {
        UpdateClass = Knit.CreateSignal(),
    }
})

function ClassService:GetPlayerClasses(Player)
    local Classes = self._activeClasses[Player]

    if not Classes then
        self._activeClasses[Player] = {}
        Classes = self._activeClasses[Player]
    end

    return Classes
end

function ClassService:_loadClasses()
    self._loadedClasses = {}

    local class_array = {}

    for _, Class in pairs(ReplicatedStorage.Source.Modules.Classes:GetChildren()) do
        local IsBlacklisted = table.find(BLACKLISTED_CLASSES, Class.Name)

        if Class:IsA("ModuleScript") and (not IsBlacklisted) then
            self._loadedClasses[Class.Name] = require(Class)
            table.insert(class_array, Class.Name)
        end
    end

    return class_array
end

function ClassService:GetClassArray()
    return TableUtil.Copy(self._class_array)
end

function ClassService:DeactivateIncompatibleClasses(Player, ClassName, StopSelf)
    local Classes = self:GetPlayerClasses(Player)

    for _, IncompatibleClass in pairs(Compatibilities.GetIncompatibilities(ClassName)) do
        for _, Class in pairs(Classes) do
            local Name = Class.Name
            if Name == IncompatibleClass and ((Name == ClassName and StopSelf) or Name ~= ClassName) then
                self:DeactivateClass(Player, Name)
            end
        end
    end
end

function ClassService:ActivateClass(Player, ClassName, Environment)
    local ClassTemplate = self._loadedClasses[ClassName]
    local Classes = self:GetPlayerClasses(Player)

    if not ClassTemplate then
        return
    end

    local Class = setmetatable(TableUtil.Copy(ClassTemplate), {
        __index = BaseClass.new(ClassName, Player, self, Environment or {})
    })

    self:DeactivateIncompatibleClasses(Player, ClassName, true)

    Class:Initialize()
    Classes[ClassName] = Class

    self.Client.UpdateClass:Fire(Player, "Activate", ClassName, Environment)

    return Class
end

function ClassService:DeactivateClass(Player, ClassName)
    local Classes = self:GetPlayerClasses(Player)
    local Class = Classes[ClassName]

    if not Class then
        return
    end

    Class:Deinitialize()
    Classes[ClassName] = nil
    Class = nil
    self.Client.UpdateClass:Fire(Player, "Deactivate", ClassName)

    return true
end

function ClassService.Client:ActivateClass(Player, ClassName, Environment)
    if not table.find(self.Server._permittedClasses[Player], ClassName) then
        return false
    end

    local Class = self.Server:ActivateClass(Player, ClassName, Environment)

    if Class then
        return true
    end
end

function ClassService.Client:DeactivateClass(Player, ClassName)
    return self.Server:DeactivateClass(Player, ClassName)
end

function ClassService:PlayerAdded(Player)
    self._permittedClasses[Player] = {}

    for _, ClassName in ipairs(self._class_array) do
        table.insert(self._permittedClasses[Player], ClassName)
    end
end

function ClassService:KnitInit()
    self._class_array = self:_loadClasses()

    self._permittedClasses = {}
    self._activeClasses = {}

    Compatibilities._CLASS_LIST = TableUtil.Copy(self._class_array)

    for _, Player in ipairs(Players:GetPlayers()) do
        self:PlayerAdded(Player)
    end

    Players.PlayerAdded:Connect(function(Player)
        self:PlayerAdded(Player)
    end)
end

return ClassService