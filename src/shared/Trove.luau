--!strict
local Trove = {}
Trove.Actions = {
    RBXScriptConnection = function(instance: RBXScriptConnection)
        instance:Disconnect()
    end,
    Instance = function(instance: Instance)
        instance:Destroy()
    end,
    ["function"] = function(instance: (...any) -> (), ...: any)
        instance(...)
    end,
    table = function(instances: {[any]: unknown})
        for k, v in instances do
            Trove:Activate(v, k)
        end
    end,
}
function Trove:Activate(instance: unknown, ...) -- Luau-LSP type compilation breaks if dependent on runtime type indices (theoretically its a union of tuples comprising type-level strings and respective types)
    local instanceType = typeof(instance)
    local action = self.Actions[instanceType]
    if not action then return end
    action(instance, ...)
end
return Trove