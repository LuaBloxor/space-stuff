local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local UserInputService = game:GetService("UserInputService")
--local ToolState = require(script.Parent.ToolState)
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
} = nil
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
    if excludedInstance then raycastParams:AddToFilter(excludedInstance) end
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
    _, target.Handle = Shapes:PointOnFace(result, dragInfo.Increment)
    dragInfo.Target = target
    local cubeOrientation = LinearUtils.ClosestCubeElementToCF(dragInfo.Handle.Rotation:Inverse() * target.Instance.CFrame.Rotation * target.Handle.Rotation) * dragInfo.Orientation
    --Annihilating rotation matrices created the above formula, this one doesn't snap to the surface's rotation: local cubeOrientation = (dragInfo.Handle.Rotation:Inverse() * target.Instance.CFrame.Rotation * target.Handle.Rotation):Inverse() * dragInfo.Orientation
    --TODO: project source handle (in Ray 1's direction to produce a new handle) (and rotate handle to identity cframe using the above code to one of four rotations) to a face of the identity-rotated Shape, as pointed onto by the target's surface normal
    --[[
    Choice 1:
     The plane perpendicular to the normal of the Target Surface is projected onto the unrotated Source Shape, so that the projected face of the Source Shape is aligned with the Target Surface.
     Ray 1 is defined as the ray towards the camera intersecting the Source Handle (where the Source Shape is projected in the direction of the ray to be tangent to the Target Surface) towards the Target Surface.
     The Source Shape is then updated to snap the endpoint of Ray 1 to grid plane (as Weld's C0 and C1), bringing the projected face's snapped endpoint projection to the Target Surface's snapped projection.
    Choice 2:
     Ray 1 is instead defined where the Source Handle is snapped to the grid and the ray is in the direction of the Target Surface's normal.
     This is what Roblox Studio uses and deviations from the other choice appears.
    --]]
    dragInfo.Joint.C1 = target.Handle * cubeOrientation
    dragInfo.Joint.Part1 = target.Instance
end
local function dragStart(input: InputObject)
    local result = raycast()
    if not result or result.Instance:IsA("Terrain") then return end
    local _pos, handle = Shapes:PointOnFace(result, 1)
    dragInfo = {
        Instance = result.Instance,
        Handle = handle,
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
    dragInfo = nil::any
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
    if selected and input.UserInputType == Enum.UserInputType.MouseMovement then
        dragMove(input)
    end
end)
return Dragger