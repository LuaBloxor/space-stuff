local Range = {}
function Range.argmax<a, inputs...>(array: {a}, comparator: (a, inputs...) -> (number), ...: inputs...)
    local nearest: number = -1/0 -- start with nil / infinity as in argmax
    local output: a -- assuming array is nonzero length then this will be non-nil
    for _, element in array do
        local newNearest = comparator(element, ...)
        if not nearest or newNearest > nearest then
            nearest = newNearest
            output = element
        end
    end
    return output, nearest
end
function Range.argmin<a, inputs...>(array: {a}, comparator: (a, inputs...) -> (number), ...: inputs...)
    local nearest: number = 1/0
    local output: a
    for _, element in array do
        local newNearest = comparator(element, ...)
        if not nearest or newNearest < nearest then
            nearest = newNearest
            output = element
        end
    end
    return output, nearest
end
return Range