--!strict
local function MergeFunctionMap<k, v, i..., o...>(src: {[k]: v}, dest: {[k]: (i...)->(o...)}, bind: (v, i...)->(o...))
    for k, v in src do
        dest[k] = function(...) return bind(v, ...) end
    end
end
return MergeFunctionMap