local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local ToolState = require(script.Parent.ToolState)
local Dragger = {}
local toolModel = {
    Name = "Modify",
    Tool = nil,
}
Dragger.toolModel = toolModel
function toolModel.Selected(tool, mouse)
end
function toolModel.Deselected(tool, mouse)
end
function toolModel.Instantiated(tool) end
ToolState.newTool(toolModel)
return Dragger