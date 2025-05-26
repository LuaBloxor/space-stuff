local LinearUtils = {}
function LinearUtils.ResizeCFrame(cf: CFrame, transform: Vector3)
    local ZVec = (cf.ZVector/transform).Unit
    local YVec = (cf.YVector*transform).Unit
    return CFrame.fromMatrix(cf.Position * transform, -ZVec:Cross(YVec), YVec, ZVec)
end
function LinearUtils.RoundVectorToPlane(vec: Vector3, increment: number)
    return Vector3.new(math.round(vec.X * increment) / increment, math.round(vec.Y * increment) / increment, 0)
end
return LinearUtils