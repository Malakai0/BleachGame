--[[
    A testing-class to check if the ClassController is working as intended.
]]--

local Test2 = {}

function Test2:Initialize()
    print("Initialized \"Test2\"")
end

function Test2:Deinitialize()
    print("Deinitialized \"Test2\"")
    self.Trove:Destroy()
end

return Test2