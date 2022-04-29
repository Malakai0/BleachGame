--[[
    Replication of player inventories.
]]--

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local PlayerItem = require(ReplicatedStorage.Source.Modules.Items._std)

local BLACKLISTED_ITEMS = {"_info", "_std", "_template"}

local InventoryService = Knit.CreateService({
    Name = "InventoryService",
    Client = {
        InventoryUpdate = Knit.CreateSignal(),
    }
})

function InventoryService:GetPlayerInventory(Player)
    local Inventory = self._inventories[Player]

    if not Inventory then
        self._inventories[Player] = {Slots = {}}
        Inventory = self._inventories[Player]
    end

    return Inventory
end

function InventoryService:BulkAddItem(Player, Items) -- {{Item, State}, {Item, State}, ...}
    for _, Item in pairs(Items) do
        self:AddItem(Player, Item[1], Item[2])
    end
end

function InventoryService:AddItem(Player, ItemName, State)
    local Base = self._classes[ItemName]
    local Inventory = self:GetPlayerInventory(Player)

    if not Base then
        return
    end

    local Item = setmetatable(TableUtil.Copy(Base), {
        __index = PlayerItem.new(ItemName, Player, State)
    })

    Item:Init()

    local Index = HttpService:GenerateGUID()

    Inventory.Slots[Index] = Item
    self.Client.InventoryUpdate:Fire(Player, "AddItem", Index, ItemName, State)

    return Index
end

function InventoryService:GetEquipped(Player)
    local Inventory = self:GetPlayerInventory(Player)

    return Inventory._holding -- ez
end

function InventoryService:Unequip(Player)
    local Inventory = self:GetPlayerInventory(Player)

    if not Inventory._holding then
        return
    end

    Inventory._holding:Unequip()

    Inventory._holding = nil
    return true
end

function InventoryService:Equip(Player, Index)
    local Inventory = self:GetPlayerInventory(Player)

    if Inventory._holding then
        self:Unequip(Player)
    end

    local Item = Inventory.Slots[Index]

    if not Item then
        return
    end

    Item:Equip()

    Inventory._holding = Item
    return true
end

function InventoryService:_loadItems()
    local items = {}

    for _, Class in pairs(ReplicatedStorage.Source.Modules.Items:GetChildren()) do
        if not table.find(BLACKLISTED_ITEMS, Class.Name) then
            items[Class.Name] = require(Class)
        end
    end

    return items
end

function InventoryService.Client:Equip(Player, Index)
    if self.Server:Equip(Player, Index) then
        self.InventoryUpdate:Fire(Player, "Equip", Index)
    end
end

function InventoryService.Client:Unequip(Player)
    if self.Server:Unequip(Player) then
        self.InventoryUpdate:Fire(Player, "Unequip")
    end
end

function InventoryService.Client:Activated(Player)
    local Inventory = self.Server:GetPlayerInventory(Player)

    if not Inventory._holding then
        return
    end

    Inventory._holding:Activated()
end

function InventoryService.Client:Unactivated(Player)
    local Inventory = self.Server:GetPlayerInventory(Player)

    if not Inventory._holding then
        return
    end

    Inventory._holding:Unactivated()
end

function InventoryService.Client:FetchInventory(Player)
    return self.Server:GetPlayerInventory(Player)
end

function InventoryService:KnitInit()
    self._inventories = {}

    self._classes = self:_loadItems()

    Players.PlayerRemoving:Connect(function(Player)
        self._inventories[Player] = nil
    end)

    Players.PlayerAdded:Connect(function(player)
        task.wait(2)
        self:AddItem(player, "Test")
    end)
end

return InventoryService