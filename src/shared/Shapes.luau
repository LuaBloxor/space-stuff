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
            {Vector3.new(0, 1, 0), Vector3.new(-0.5, 1, -0.5)},
            {Vector3.new(1, 0, 0), Vector3.new(1, -0.5, -0.5)},
            {Vector3.new(0, 0, 1), Vector3.new(-0.5, -0.5, 1)},
            {Vector3.new(0, -1, 0), Vector3.new(-0.5, -1, -0.5)},
            {Vector3.new(-1, 0, 0), Vector3.new(-1, -0.5, -0.5)},
            {Vector3.new(0, 0, -1), Vector3.new(-0.5, -0.5, -1)},
        },
    },
    Wedge = {
        FaceNormals = {
            {Vector3.new(0, 1, -1).Unit, Vector3.new(-0.5, -0.5, -0.5), Vector3.xAxis},
            {Vector3.new(1, 0, 0), Vector3.new(1, -0.5, -0.5)},
            {Vector3.new(0, 0, 1), Vector3.new(-0.5, -0.5, 1)},
            {Vector3.new(0, -1, 0), Vector3.new(-0.5, -1, -0.5)},
            {Vector3.new(-1, 0, 0), Vector3.new(-1, -0.5, -0.5)},
        },
    },
} :: {[any]: {FaceNormals: {any}}}
for _, faces in Shapes.FACES do
    for _, face in faces.FaceNormals do
        if typeof(face[2]) == "Vector3" then
            face[2] = CFrame.lookAlong(face[2], face[1], face[3])
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
    local face = Range.argmax(self.FACES[shape], comparator, normal)[2]
    return LinearUtils.ResizeCFrame(face, shape.Size)
end
function Shapes:PointOnFace(raycast: RaycastResult, increment: number)
    local instance = raycast.Instance
    local normal = raycast.Normal
    if not instance.ClassName:IsA("BasePart") then
        return CFrame.lookAlong(raycast.Position, normal)
    end
    local face = self:GetFace(instance, instance.CFrame:VectorToObjectSpace(normal))
    local position = face:Inverse() * instance.CFrame:Inverse() * raycast.Position
    local gridPosition = LinearUtils.RoundVectorToPlane(position, increment)
    return gridPosition, face * gridPosition
end
return Shapes