--[[
    The Inventory Controller is well; an interface for interacting with the player's inventory!
    Read Modules->Items->_info for in-depth detail of the Item class.
]]--

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Input = require(ReplicatedStorage.Packages.Input)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local PlayerItem = require(ReplicatedStorage.Source.Modules.Items._std)

local InventoryController = Knit.CreateController({
    Name = "InventoryController"
})

function InventoryController:QueryInventory(Predicate)
    local Items = {}

    for Index, Item in pairs(self._inventory.Slots) do
        if Predicate(Item) then
            table.insert(Items, Index)
        end
    end

    return Items
end

function InventoryController:AddItem(ItemName, State)
    local Base = self._classes[ItemName]

    if not Base then
        return
    end

    local Item = setmetatable(TableUtil.Copy(Base), {
        __index = PlayerItem.new(ItemName, Players.LocalPlayer, State)
    })

    if Item.InitClient then
        Item:InitClient()
    end

    return Item
end

function InventoryController:Equip(Index)
    if not self._inventory.Slots[Index] then
        return
    end

    local InventoryService = Knit.GetService("InventoryService")

    if InventoryService:Equip(Index) then
        self._inventory.Slots[Index]:EquipClient()
    end
end

function InventoryController:Unequip()
    if not self._inventory._holding then
        return
    end

    local InventoryService = Knit.GetService("InventoryService")

    if InventoryService:Unequip() then
        self._inventory._holding:UnequipClient()
    end
end

function InventoryController:_loadItems()
    local items = {}

    for _, Class in pairs(ReplicatedStorage.Source.Modules.Items:GetChildren()) do
        items[Class.Name] = require(Class)
    end

    return items
end


function InventoryController:KnitInit()
    local InventoryService = Knit.GetService("InventoryService")
    local _, Inventory =  InventoryService:FetchInventory():await()

    self._inventory = Inventory

    self._classes = self:_loadItems()
    self._mouse = Input.Mouse.new()

    InventoryService.InventoryUpdate:Connect(function(Method, ...)
        local Args = {...}

        if Method == "AddItem" then
            self._inventory.Slots[Args[1]] = self:AddItem(Args[2], Args[3])
        end

        if Method == "RemoveItem" then
            self._inventory.Slots[Args[1]] = nil
        end

        if Method == "Equip" then
            self._inventory._holding = self._inventory.Slots[Args[1]]
        end

        if Method == "Unequip" then
            self._inventory._holding = nil
        end
    end)

    self._mouse.LeftDown:Connect(function()
        if not self._inventory._holding then
            return
        end

        if InventoryService:Activated() then
            self._inventory._holding:ActivatedClient()
        end
    end)

    self._mouse.LeftUp:Connect(function()
        if not self._inventory._holding then
            return
        end

        if InventoryService:Unactivated() then
            self._inventory._holding:UnactivatedClient()
        end
    end)
end

function InventoryController:KnitStart()
    task.wait(5)

    local Tools = self:QueryInventory(function(Tool)
        return Tool.Name == "Test"
    end)

    if Tools[1] then
        self:Equip(Tools[1])
    end
end

return InventoryController