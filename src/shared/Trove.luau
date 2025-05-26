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
    table = function(instances: {[any]: any})
        for k, v in instances do
            Trove:Activate(v, k)
        end
    end,
}
function Trove:Activate(instance: any, ...)
    local instanceType = typeof(instance)
    local action = self.Classes[instanceType]
    if not action then return end
    action(instance, ...)
end
return Trove