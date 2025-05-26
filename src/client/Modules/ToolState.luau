local Player = game:GetService("Players").LocalPlayer
local Trove = require(game.ReplicatedStorage.Shared.Trove)
export type ToolModel = {
    Name: string,
    Selected: (Tool, Mouse) -> (),
    Deselected: (Tool, Mouse?) -> (),
    Instantiated: (Tool) -> (),
    Tool: Tool,
}
local ToolState = {}
function ToolState.bindToDeactivate(tool: Tool, instance: any)
    local function deactivate()
        Trove:Activate(instance)
    end
    tool.Destroying:Connect(deactivate)
    tool.Unequipped:Connect(deactivate)
end
function ToolState.newTool(toolModel: ToolModel): ToolModel
    Player.CharacterAdded:Connect(function(character: Model)
        toolModel.Tool = Player.Backpack:WaitForChild(toolModel.Name)
        toolModel.Instantiated(toolModel.Tool)
        toolModel.Tool.Equipped:Connect(function(mouse: Mouse)
            toolModel.Selected(toolModel.Tool, mouse) -- until multi-select is added
        end)
        toolModel.Tool.Unequipped:Connect(function(mouse: Mouse)
            toolModel.Deselected(toolModel.Tool, mouse)
        end)
    end)
    Player.CharacterRemoving:Connect(function(character: Model)
        if not toolModel.Tool then return end
        toolModel.Deselected(toolModel.Tool)
    end)
    return toolModel
end
return ToolState