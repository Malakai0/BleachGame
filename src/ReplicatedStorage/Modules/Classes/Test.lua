--[[
    A testing-class to check if the ClassController is working as intended.
]]--

local Test = {}

function Test:Initialize()
    print("Initialized \"Test\"")
end

function Test:Deinitialize()
    print("Deinitialized \"Test\"")
    self.Trove:Destroy()
end

function Test:InitializeClient()
    print("Initialized \"Test\"")
end

function Test:DeinitializeClient()
    print("Deinitialized \"Test\"")
    self.Trove:Destroy()
end

return Test