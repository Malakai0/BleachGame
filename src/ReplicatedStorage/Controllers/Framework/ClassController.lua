--[[
    The Class Controller initializes and deinitializes classes (soul, soul reaper, hollow, quincy, etc)
    Initializes classes that are active and deinitializes ones that aren't, simple!
]]--

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BLACKLISTED_CLASSES = {"_info", "_std", "_compatibilities", "_template"}

local Knit = require(ReplicatedStorage.Packages.Knit)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local BaseClass = require(ReplicatedStorage.Source.Modules.Classes._std)
local Compatibilities = require(ReplicatedStorage.Source.Modules.Classes._compatibilities)

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
    return TableUtil.Copy(Compatibilities._CLASS_LIST)
end

function ClassController:DeactivateIncompatibleClasses(ClassName)
    for _, IncompatibleClass in pairs(Compatibilities.GetIncompatibilities(ClassName)) do
        for _, Class in pairs(self._activeClasses) do
            local Name = Class.Name
            if Name == IncompatibleClass and Name ~= ClassName then
                self:DeactivateClass(Name)
            end
        end
    end
end

function ClassController:ActivateClass(ClassName, Environment)
    local ClassTemplate = self._loadedClasses[ClassName]

    if not ClassTemplate then
        return
    end

    local Class = setmetatable(TableUtil.Copy(ClassTemplate), {
        __index = BaseClass.new(ClassName, self, Environment or {})
    })

    self:DeactivateIncompatibleClasses(ClassName)

    Class:Initialize()
    self._activeClasses[ClassName] = Class

    return Class
end

function ClassController:DeactivateClass(ClassName)
    local Class = self._activeClasses[ClassName]

    if not Class then
        return
    end

    Class:Deinitialize()
    self._activeClasses[ClassName] = nil
end

function ClassController:KnitInit()
    local _class_array = self:_loadClasses()
    self._activeClasses = {}
    Compatibilities._CLASS_LIST = TableUtil.Copy(_class_array)
end

function ClassController:KnitStart()

end

return ClassController