local Shared = game.ReplicatedStorage.Shared
local Range = require(Shared.Range)
local LinearUtils = require(Shared.LinearUtils)

local function comparator(face, index, target)
    return target:Dot(face[1])
end
local Shapes = {}
Shapes.FACES = {
    Block = {
        FaceNormals = {
            {Vector3.new(0, 1, 0), Vector3.new(-0.5, 0.5, -0.5)},
            {Vector3.new(1, 0, 0), Vector3.new(0.5, -0.5, -0.5)},
            {Vector3.new(0, 0, 1), Vector3.new(-0.5, -0.5, 0.5)},
            {Vector3.new(0, -1, 0), Vector3.new(-0.5, -0.5, -0.5)},
            {Vector3.new(-1, 0, 0), Vector3.new(-0.5, -0.5, -0.5)},
            {Vector3.new(0, 0, -1), Vector3.new(-0.5, -0.5, -0.5)},
        },
    },
    Wedge = {
        FaceNormals = {
            {Vector3.new(0, 1, -1).Unit, Vector3.new(-0.5, -0.5, -0.5), Vector3.xAxis},
            {Vector3.new(1, 0, 0), Vector3.new(0.5, -0.5, -0.5)},
            {Vector3.new(0, 0, 1), Vector3.new(-0.5, -0.5, 0.5)},
            {Vector3.new(0, -1, 0), Vector3.new(-0.5, -0.5, -0.5)},
            {Vector3.new(-1, 0, 0), Vector3.new(-0.5, -0.5, -0.5)},
            {Vector3.new(0, 0, -1), Vector3.new(-0.5, -0.5, -0.5)},
        },
    },
} :: {[any]: {FaceNormals: {any}}}
for _, shape in Shapes.FACES do
    for _, face in shape.FaceNormals do
        if typeof(face[2]) == "Vector3" then
            face[2] = if #face == 3 then CFrame.lookAlong(face[2], face[1], face[3]) else CFrame.lookAlong(face[2], face[1])
        end
    end
end
local GetShapes: {[string]: any | (any) -> any} = {
    Part = function(instance: Part)
        return instance.Shape.Name
    end,
    WedgePart = "Wedge",
    CornerWedgePart = "CornerWedge",
}

function Shapes:GetShape(instance: Instance)
    local shape = GetShapes[instance.ClassName]
    return if shape then (if type(shape) == "function" then shape(instance) else shape) else "Block"
end
function Shapes:GetFace(instance, normal)
    local shape = Shapes:GetShape(instance)
    local face = Range.argmax(self.FACES[shape].FaceNormals, comparator, normal / instance.Size)[2]
    return LinearUtils.ResizeCFrame(face, instance.Size)
end
function Shapes:PointOnFace(raycast: RaycastResult|any, increment: number?): (Vector3, CFrame, CFrame)
    local instance = raycast.Instance
    local normal = raycast.Normal
    if not instance:IsA("BasePart") then
        return Vector3.zero, CFrame.lookAlong(raycast.Position, normal), CFrame.identity
    end
    local face = self:GetFace(instance, instance.CFrame:VectorToObjectSpace(normal))
    local position = face:Inverse() * instance.CFrame:Inverse() * raycast.Position
    local gridPosition = if increment then LinearUtils.RoundVectorToPlane(position, increment) else position
    return gridPosition, face * CFrame.new(gridPosition), face
end
return Shapes