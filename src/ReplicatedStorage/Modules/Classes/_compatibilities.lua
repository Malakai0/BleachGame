--[[
    This module will be a small library to determine compatibilities for each class.

    E.g The Hollow class isn't compatible with the Quincy class,
        however the Human class *is* compatible with the Quincy class.

    *Note to self: try not to fuck up spelling the word compatibilities.*
]]--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local Compatibilities = {}

Compatibilities._CORE_COMPATIBILITIES = {
    Human = {"Quincy"},
    Test2 = {}
}

Compatibilities._CLASS_LIST = {}

function Compatibilities.IsCompatible(ClassA, ClassB)
    local ClassAList = Compatibilities._CORE_COMPATIBILITIES[ClassA]
    local ClassBList = Compatibilities._CORE_COMPATIBILITIES[ClassB]

    if ClassA == ClassB then
        return false
    end

    if not (ClassAList and ClassBList) then
        return false
    end

    ClassAList = ClassAList or {}
    ClassBList = ClassBList or {}

    return (table.find(ClassAList, ClassB) ~= nil) or (table.find(ClassBList, ClassA) ~= nil)
end

function Compatibilities.ClearDuplicates(List)
    local Duplicates = 0

    local Seen = {}

    for I = 1, #List do
        local ActualIndex = I - Duplicates
        local Value = List[ActualIndex]

        if Seen[Value] ~= nil then
            table.remove(List, ActualIndex)
            Duplicates += 1
        end

        Seen[Value] = true
    end

    Seen = nil
    return Duplicates
end

function Compatibilities.GetCompatibilityBoolean(Class, Boolean)
    local CompatibilityList = {}

    Boolean = Boolean == true

    for _, Candidate in pairs(Compatibilities._CLASS_LIST) do
        if Compatibilities.IsCompatible(Candidate, Class) == Boolean then
            table.insert(CompatibilityList, Candidate)
        end
    end

    -- Clear any duplicates.
    local Duplicates = Compatibilities.ClearDuplicates(CompatibilityList)

    return CompatibilityList, Duplicates
end

function Compatibilities.GetCompatibilities(Class)
    return Compatibilities.GetCompatibilityBoolean(Class, true)
end

function Compatibilities.GetIncompatibilities(Class)
    return Compatibilities.GetCompatibilityBoolean(Class, false)
end

return Compatibilities