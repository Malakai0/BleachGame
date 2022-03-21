local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

for _, Dependency: ModuleScript in pairs(ServerStorage.Source:GetDescendants()) do
    local IsModuleScript = Dependency:IsA("ModuleScript")

    local IsComponent = Dependency:FindFirstAncestor("Components") and Dependency.Name:match("Component$")
    local IsService = Dependency:FindFirstAncestor("Services") and Dependency.Name:match("Service$")

    if IsModuleScript and (IsComponent or IsService) then
        require(Dependency)
    end
end

Knit.Start():andThen(function()
    print("Knit started")
end):catch(warn)