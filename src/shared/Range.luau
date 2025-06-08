--!strict
local Range = {}
function Range.argmax<a, index, inputs...>(array: {[index]: a}, comparator: (a, index, inputs...) -> (number?), ...: inputs...)
    local nearest: number = -1/0 -- start with nil / infinity as in argmax
    local output: a -- assuming array is nonzero length then this will be non-nil
    local outputIndex
    for index, element in array do
        local newNearest = comparator(element, index, ...)
        if not nearest or newNearest and newNearest > nearest then
            nearest = newNearest
            output = element
            outputIndex = index
        end
    end
    return output, nearest, outputIndex
end
function Range.argmin<a, index, inputs...>(array: {[index]: a}, comparator: (a, index, inputs...) -> (number?), ...: inputs...)
    local nearest: number = 1/0
    local output: a
    local outputIndex
    for index, element in array do
        local newNearest = comparator(element, index, ...)
        if not nearest or newNearest and newNearest < nearest then
            nearest = newNearest
            output = element
            outputIndex = index
        end
    end
    return output, nearest, outputIndex
end
return Range