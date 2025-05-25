local Range = require(game.ReplicatedStorage.Shared.FindRange)

local function comparator(face, target)
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
            {Vector3.new(0, 1, -1).Unit, Vector3.new(-0.5, -0.5, -0.5)},
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
function Shapes:GetFace(raycastResult: RaycastResult)
    local normal = raycastResult.Normal
    local shape = Shapes:GetShape(raycastResult.Instance)
    local face = Range.argmax(self.FACES[shape], comparator, normal)[2]
    return face
end
return Shapes