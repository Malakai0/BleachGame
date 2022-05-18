local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local Query = {}
Query.__index = Query

function Query.new()
    local self = {
        _items = {},
        _predicate = function() return true end,
        _default = nil,
    }

    setmetatable(self, Query)

    return self
end

function Query:SetItems(Items, TableValue)
    if not Items[1] then --// If Items isn't an array
        self._items = {}

        for Key, Value in pairs(Items) do
            table.insert(self._items, if (TableValue or 1) == 1 then Key else Value)
        end
    else
        self._items = Items
    end

    return self
end

function Query:Enumerate()
    return pairs(self._items)
end

function Query:SetPredicate(Predicate)
    self._predicate = Predicate
    return self
end

function Query:DefaultIfEmpty(Default)
    self._default = Default
    return self
end

function Query:First()
    return self._items[1] or self._default
end

function Query:FirstOrDefault()
    return self._items[1] or self._default
end

function Query:Last()
    return self._items[#self._items] or self._default
end

function Query:LastOrDefault()
    return self._items[#self._items] or self._default
end

function Query:Filter()
    local _removed = 0

    for index, item in pairs(self._items) do
        if not self._predicate(item) then
            table.remove(self._items, index - _removed)
            _removed += 1
        end
    end

    return self
end

function Query:Clone()
    return Query.new():SetPredicate(self._predicate):SetItems(TableUtil.Copy(self._items)):DefaultIfEmpty(self._default)
end

return Query