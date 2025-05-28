local previews = Instance.new("Folder")
previews.Name = "Previews"
previews.Parent = workspace

local Previews = {}
function MultiplyTransparency(a: number, b: number)
    return 1 - (1-a) * (1-b)
end
function Previews:SetTransparency(instance: Instance, transparency: number)
    local Restore = {}
    if instance:IsA("GuiObject") then
        Restore.BackgroundTransparency = instance.BackgroundTransparency
        instance.BackgroundTransparency = MultiplyTransparency(Restore.BackgroundTransparency, transparency)
    end
    if instance:IsA("TextLabel") then
        Restore.TextTransparency = instance.TextTransparency
        instance.TextTransparency = MultiplyTransparency(Restore.TextTransparency, transparency)
    end
    if instance:IsA("TextButton") then
        Restore.TextTransparency = instance.TextTransparency
        instance.TextTransparency = MultiplyTransparency(Restore.TextTransparency, transparency)
    end
    if instance:IsA("GuiBase3d") then
        Restore.Transparency = instance.Transparency
        instance.Transparency = MultiplyTransparency(Restore.Transparency, transparency)
    end
    if instance:IsA("Decal") then
        Restore.Transparency = instance.Transparency
        instance.Transparency = MultiplyTransparency(Restore.Transparency, transparency)
    end
    if instance:IsA("BasePart") then
        Restore.Transparency = instance.Transparency
        instance.Transparency = MultiplyTransparency(Restore.Transparency, transparency)
    end
    return function()
        for k, v in Restore do
            (instance::any)[k] = v
        end
    end
end
function Previews:SetTransparencyForDescendants(instance: Instance, transparency: number)
    local Restores = {}
    Restores[instance] = self:SetTransparency(instance, transparency)
    for _, descendant in instance:GetDescendants() do
        Restores[descendant] = self:SetTransparency(descendant, transparency)
    end
    return function()
        for _, i in Restores do i() end
    end
end
function Previews:ConvertToPreview(part: BasePart)
    local revert = Previews:SetTransparencyForDescendants(part, 0.5)
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Massless = true
    part.Anchored = false
    return revert
end
function Previews:PreviewPart(part: BasePart, joint: Weld?)
    local preview = part:Clone()
    Previews:ConvertToPreview(preview)
    local lastPart1Event:RBXScriptConnection
    local function unwelded()
        preview.Anchored = true
    end
    local function welded()
        preview.Anchored = false
    end
    local function ancestryChanged(a0: Instance, a1: Instance?)
        if not a1 or not a1:FindFirstAncestorWhichIsA("Workspace") then
            unwelded()
        end
    end
    if joint then
        joint.AncestryChanged:Connect(ancestryChanged)
        if joint.Part1 then lastPart1Event = joint.Part1.AncestryChanged:Connect(ancestryChanged) end
        joint.Destroying:Connect(function()
            if lastPart1Event then lastPart1Event:Disconnect() end
            unwelded()
        end)
        joint.Changed:Connect(function(attr)
            if attr == "Part0" and not joint.Part0 or attr == "Part1" and not joint.Part1 then
                unwelded()
            elseif attr == "Part1" and joint.Part1 then
                if lastPart1Event then lastPart1Event:Disconnect() end
                lastPart1Event = joint.Part1.AncestryChanged:Connect(ancestryChanged)
                welded()
            end
        end)
    end
    preview.Parent = previews
    return preview
end
return Previews