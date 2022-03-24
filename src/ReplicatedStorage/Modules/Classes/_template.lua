--[[
    A template class.
]]--

local Template = {}

function Template:Initialize()
end

function Template:Deinitialize()
    self.Trove:Destroy()
end

return Template