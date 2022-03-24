local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

ReplicatedStorage:WaitForChild("Assets")
ReplicatedStorage.Assets:WaitForChild("GUIPrefabs")

local ClassButtonPrefab = ReplicatedStorage.Assets.GUIPrefabs:WaitForChild("ClassButton")

local ClassMenu = {}

function ClassMenu.HandleClassMenu(Object)
    local ClassController = Knit.GetController("ClassController")
    local ClassArray = ClassController:GetClassArray()

    for _, ClassName in ipairs(ClassArray) do
        local ClassButton = ClassButtonPrefab:Clone()

        ClassButton.Text = ClassName
        ClassButton:SetAttribute("Class", ClassName)
        ClassButton.Activated:Connect(function()
            ClassController:ActivateClass(ClassName)
        end)
        ClassButton.Parent = Object
    end
end

function ClassMenu.Start()
    local GuiController = Knit.GetController("GuiController")

    GuiController:Observe("ClassSelect", ClassMenu.HandleClassMenu)
end

return ClassMenu