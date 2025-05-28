local LinearUtils = {}
local Shared = game.ReplicatedStorage.Shared
local Range = require(Shared.Range)
local CUBE = {
    Vector3.xAxis,
    -Vector3.zAxis,
    Vector3.yAxis,
    -Vector3.xAxis,
    Vector3.zAxis,
    -Vector3.yAxis,
}
function LinearUtils.ResizeCFrame(cf: CFrame, transform: Vector3)
    local ZVec = (cf.ZVector / transform).Unit
    local YVec = (cf.YVector * transform).Unit
    return CFrame.fromMatrix(cf.Position * transform, -ZVec:Cross(YVec), YVec, ZVec)
end
function LinearUtils.RoundVectorToPlane(vec: Vector3, increment: number)
    return Vector3.new(math.round(vec.X * increment) / increment, math.round(vec.Y * increment) / increment, 0)
end

local function comparator(face, index, target, excluded)
    if index == excluded then return nil end
    return target:Dot(face)
end
function LinearUtils.ClosestCubeElementToCF(target: CFrame)
    local targetFaces = {
        target.RightVector,
        target.LookVector,
        target.UpVector,
        -target.RightVector,
        -target.LookVector,
        -target.UpVector,
    }
    local _, _, lookIndex = Range.argmax(targetFaces, comparator, -Vector3.zAxis)
    local _, _, upIndex = Range.argmax(targetFaces, comparator, Vector3.yAxis, lookIndex)
    return CFrame.lookAlong(Vector3.zero, CUBE[lookIndex], CUBE[upIndex])
end
return LinearUtils