local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

for _, Dependency: ModuleScript in pairs(ReplicatedStorage.Source:GetDescendants()) do
    local IsModuleScript = Dependency:IsA("ModuleScript")

    local IsComponent = Dependency:FindFirstAncestor("Components") and Dependency.Name:match("Component$")
    local IsController = Dependency:FindFirstAncestor("Controllers") and Dependency.Name:match("Controller$")

    if IsModuleScript and (IsComponent or IsController) then
        require(Dependency)
    end
end

Knit.Start():andThen(function()
    print("Knit started")
end):catch(warn)