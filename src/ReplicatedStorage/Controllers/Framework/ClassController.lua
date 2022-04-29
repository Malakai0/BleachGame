--[[
    The Class Controller initializes and deinitializes classes (soul, soul reaper, hollow, quincy, etc)
    Initializes classes that are active and deinitializes ones that aren't, simple!
]]--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BLACKLISTED_CLASSES = {"_info", "_std", "_template"}

local Knit = require(ReplicatedStorage.Packages.Knit)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local BaseClass = require(ReplicatedStorage.Source.Modules.Classes._std)
local Compatibilities = require(ReplicatedStorage.Source.Modules.Compatibilities)

local ClassController = Knit.CreateController({
    Name = "ClassController",
})

function ClassController:_loadClasses()
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

function ClassController:GetClassArray()
    return TableUtil.Copy(self._class_array)
end

function ClassController:_activateClass(ClassName, Environment)
    local ClassTemplate = self._loadedClasses[ClassName]

    if not ClassTemplate then
        return
    end

    local Class = setmetatable(TableUtil.Copy(ClassTemplate), {
        __index = BaseClass.new(ClassName, self, Environment or {})
    })

    Class:InitializeClient()
    self._activeClasses[ClassName] = Class

    return Class
end

function ClassController:_deactivateClass(ClassName)
    local Class = self._activeClasses[ClassName]

    if not Class then
        return
    end

    Class:DeinitializeClient()
    Class = nil
    self._activeClasses[ClassName] = nil
end

function ClassController:ActivateClass(ClassName, Environment)
    local ClassService = Knit.GetService("ClassService")

    ClassService:ActivateClass(ClassName, Environment)
end

function ClassController:DeactivateClass(ClassName)
    local ClassService = Knit.GetService("ClassService")

    ClassService:DeactivateClass(ClassName)
end

function ClassController:KnitInit()
    local ClassService = Knit.GetService("ClassService")

    self._class_array = self:_loadClasses()
    self._activeClasses = {}
    Compatibilities._CLASS_LIST = TableUtil.Copy(self._class_array)

    ClassService.UpdateClass:Connect(function(Action, ...)
        local Args = {...}

        if Action == "Activate" then
            self:_activateClass(Args[1], Args[2])
        end

        if Action == "Deactivate" then
            self:_deactivateClass(Args[1])
        end
    end)
end

return ClassController