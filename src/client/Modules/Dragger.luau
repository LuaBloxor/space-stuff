local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local UserInputService = game:GetService("UserInputService")
--local ToolState = require(script.Parent.ToolState)
local ROT = CFrame.fromMatrix(Vector3.zero, -Vector3.xAxis, Vector3.yAxis, -Vector3.zAxis)
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
local display
function toolModel.Instantiated(tool)
    display = Instance.new("Part")
    display.Material = Enum.Material.Neon
    display.Color = Color3.new(1,0,0)
    display.Size = Vector3.new(0.5,0.5,2)
    Previews:ConvertToPreview(display)
    display.Anchored = true
    display.Parent = workspace
end
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
    local sourceFace = Shapes:GetFace(dragInfo.Instance, dragInfo.Orientation:Inverse() * -result.Normal)
    local targetPoint, _, targetFace = Shapes:PointOnFace(result)
    --[[
    project sourceHandle at unit direction sourcePart.Rotation^-1 * (sourcePart * sourceHandle - cameraPos) to sourceFace.Normal (LookVector) (eq 1)
    where sourcePart location at other face-origin is an equation:
     1. sourcePart * sourceFace = targetPart * targetFace
     2. sourcePart = targetPart * targetFace * sourceFace^-1 (eq 2)
     now calculate (targetPart * targetFace)^-1 * sourcePart = targetFace^-1 * targetPart^-1 * sourcePart:
     3. targetPart^-1 * sourcePart = targetFace * sourceFace^-1
     4. targetFace^-1 * targetPart^-1 * sourcePart = sourceFace^-1 = (targetPart * targetFace)^-1 * sourcePart (eq 3: defines sourcePart relative to targetFace)
    define LineSegment(closed) `ray` where:
     ray[destination] = targetPart * targetHandle
     LiesIn(ray, sourcePart * sourceHandle)
     ray[source] = cameraPos
    sourcePart rotation relative to targetFace is determined
    ]]
    local targetPart = result.Instance.CFrame
    -- local sourcePart = targetPart * targetFace * sourceFace:Inverse() -- eq 2
    -- local eq3 = sourceFace:Inverse() -- sourcePart relative to targetFace's frame
    local cubeOrientation = LinearUtils.ClosestCubeElementToCF(sourceFace.Rotation:Inverse() * result.Instance.CFrame.Rotation * targetFace.Rotation * ROT) * dragInfo.Orientation
    --ClosestCubeElementToCF produces the inverted CFrame snapped to the nearest cube state given a CFrame
    local orient = (ROT * cubeOrientation)
    local orient1 = orient:Inverse()
    local direction = orient1 * targetFace.Rotation:Inverse() * targetPart.Rotation:Inverse() * (result.Position - workspace.CurrentCamera.CFrame.Position).Unit -- put eq2 into direction
    --local direction = orient1 * targetFace.Rotation:Inverse() * targetPart.Rotation:Inverse() * workspace.CurrentCamera:ScreenPointToRay(Mouse.X, Mouse.Y).Direction.Unit
    -- project direction to z plane from sourceHandle
    local projPoint = sourceFace:Inverse() * dragInfo.Handle.Position
    local sourcePoint = projPoint - direction * (projPoint.Z / direction.Z) --TODO: clamp source point to source part bounds
    
    --done: project source handle (in Ray 1's direction to produce a new handle) (and rotate handle to identity cframe using the above code to one of four rotations) to a face of the identity-rotated Shape, as pointed onto by the target's surface normal
    --[[
    Choice 1:
     The plane perpendicular to the normal of the Target Surface is projected onto the unrotated Source Shape, so that the projected face of the Source Shape is aligned with the Target Surface.
     Ray 1 is defined as the ray towards the camera intersecting the Source Handle (where the Source Shape is projected in the direction of the ray to be tangent to the Target Surface) towards the Target Surface.
     The Source Shape is then updated to snap the endpoint of Ray 1 to grid plane (as Weld's C0 and C1), bringing the projected face's snapped endpoint projection to the Target Surface's snapped projection.
    Choice 2:
     Ray 1 is instead defined where the Source Handle is snapped to the grid and the ray is in the direction of the Target Surface's normal.
     This is what Roblox Studio uses and deviations from the other choice appears.
    --]]
    -- targetFace * targetPoint * cubeOrientation = sourceFace * sourcePoint
    -- targetFace * targetPoint * cubeOrientation * sourcePoint^-1 = sourceFace
    --if (cubeOrientation * Vector3.new(0,0,1) - Vector3.new(0,0,1)).Magnitude > 0.001 then print((cubeOrientation * Vector3.new(0,0,1) - Vector3.new(0,0,1)).Magnitude) end
    dragInfo.Preview.Anchored = false
    dragInfo.Joint.C1 = targetFace * orient * CFrame.new(LinearUtils.RoundVectorToPlane(orient1 * targetPoint - sourcePoint, dragInfo.Increment))
    dragInfo.Joint.C0 = sourceFace
    dragInfo.Joint.Part1 = result.Instance
    display.CFrame = dragInfo.Preview.CFrame * sourceFace * CFrame.new(sourcePoint) -- TODO:add orient
    --print(workspace.CurrentCamera:WorldToScreenPoint(display.CFrame.Position).X - Mouse.X)
end
local function dragEnd(input: InputObject)
    if not dragInfo then return end
    dragInfo.Preview:Destroy()
    dragInfo.Joint:Destroy()
    dragInfo = nil::any
end
local function dragStart(input: InputObject)
    dragEnd(input)
    local result = raycast()
    if not result or result.Instance:IsA("Terrain") then return end
    local _pos, handle = Shapes:PointOnFace(result)
    dragInfo = {
        Instance = result.Instance,
        Handle = handle,
        Joint = Instance.new("Weld"),
        Orientation = CFrame.identity,
        Increment = 1,
    }
    dragInfo.Preview = Previews:PreviewPart(dragInfo.Instance, dragInfo.Joint)
    dragInfo.Preview.Anchored = true
    dragInfo.Joint.Part0 = dragInfo.Preview
    dragInfo.Joint.Parent = dragInfo.Preview
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