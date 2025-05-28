local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local UserInputService = game:GetService("UserInputService")
local ToolState = require(script.Parent.ToolState)
local Previews = require(script.Parent.Previews)
local Shared = game.ReplicatedStorage.Shared
local Shapes = require(Shared.Shapes)
local LinearUtils = require(Shared.LinearUtils)
local Dragger = {}
local toolModel = {
    Name = "Modify",
    Tool = nil,
}
local selected = false
local dragInfo: {
    Instance: BasePart,
    Handle: CFrame,
    Joint: Weld,
    Orientation: CFrame,
    Increment: number,
    [string]: any,
}? = nil
Dragger.toolModel = toolModel
function toolModel.Selected(tool, mouse)
    selected = true
end
function toolModel.Deselected(tool, mouse)
    selected = false
end
function toolModel.Instantiated(tool) end
local function raycast(excludedInstance: Instance?)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams:AddToFilter(excludedInstance)
    if Player.Character then raycastParams:AddToFilter(Player.Character) end
    local unitRay = Mouse.UnitRay
    local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 100, raycastParams)
    return result
end
local function dragMove(input: InputObject)
    if not dragInfo then return end
    local result = raycast(dragInfo.Instance)
    if not result or not result.Instance:IsA("BasePart") then return end
    local target = {
        Instance = result.Instance
    }
    target.Handle = Shapes:PointOnFace(result, dragInfo.Increment)
    dragInfo.Target = target
    local cubeOrientation = dragInfo.Orientation * LinearUtils.CubeToClosestCF(target.Instance.CFrame * target.Handle)
    dragInfo.Joint.C1 = target.Handle * cubeOrientation
    dragInfo.Joint.Part1 = target.Instance
end
local function dragStart(input: InputObject)
    if not dragInfo then return end
    local result = raycast()
    if not result or result.Instance:IsA("Terrain") then return end
    dragInfo = {
        Instance = result.Instance,
        Handle = Shapes:PointOnFace(result, dragInfo.Increment),
        Joint = Instance.new("Weld"),
        Orientation = CFrame.identity,
        Increment = 1,
    }
    dragInfo.Preview = Previews:PreviewPart(dragInfo.Instance)
    dragInfo.Joint.Part0 = dragInfo.Preview
    dragInfo.Joint.C0 = dragInfo.Handle
    dragInfo.Joint.Parent = dragInfo.Preview
end
local function dragEnd(input: InputObject)
    if not dragInfo then return end
    dragInfo.Preview:Destroy()
    dragInfo.Joint:Destroy()
    dragInfo = nil
end
UserInputService.InputBegan:Connect(function(input, processed)
    if selected and not processed and input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart(input)
    end
end)
UserInputService.InputEnded:Connect(function(input, processed)
    if selected and input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragEnd(input)
    end
end)
UserInputService.InputChanged:Connect(function(input, processed)
    if selected and input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragMove(input)
    end
end)
ToolState.newTool(toolModel)
return Dragger