local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Settings = {
    AimPlayers = false,
    AimAnimals = false,
    WallCheck = false,
    SilentAim = false,
    FOV = 150,
    ShowFOVCircle = false,
    PlayerName = false,
    PlayerHP = false,
    PlayerBox = false,
    AnimalESP = false,
    ChestESP = false,
    ItemESP = false,
    ShowDistance = false,
    ESPDistance = 10000,
    ChestESPDistance = 10000,
    ItemESPDistance = 10000,
    TextSize = 12,
    PlayerColor = Color3.fromRGB(255, 0, 0),
    AnimalColor = Color3.fromRGB(255, 165, 0),
    ChestColor = Color3.fromRGB(255, 215, 0),
    ItemColor = Color3.fromRGB(0, 255, 200),
    InstantInteract = false,
    TPWalk = false,
    TPWalkSpeed = 2,
    FullBright = false,
    NoFog = false,
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ProximityPromptService = game:GetService("ProximityPromptService")

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1

local Window = Rayfield:CreateWindow({
    Name = "BabyBound | 80he, Greg, Fresh",
    Icon = 0,
    LoadingTitle = "BabyBound",
    LoadingSubtitle = "by 80he",
    Theme = "Amethyst",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
})

local SoundService = game:GetService("SoundService")
local function PlaySound(id, volume, pitch)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. id
    sound.Volume = volume or 0.5
    sound.PlaybackSpeed = pitch or 1
    sound.Parent = SoundService
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 3)
end
local Sounds = {
    Load   = 4590657391,
    Click  = 6895079853,
    Toggle = 3744371862,
    Slider = 6026984224,
    Error  = 4590663556,
    Notify = 4590657391,
}
task.delay(1.5, function()
    PlaySound(Sounds.Load, 0.6, 1)
end)

local CombatTab = Window:CreateTab("Combat", "crosshair")
local VisualsTab = Window:CreateTab("Visuals", "eye")
local WorldTab = Window:CreateTab("World", "globe")

CombatTab:CreateSection("Aimbot Settings")
VisualsTab:CreateSection("Visuals")
WorldTab:CreateSection("Utility")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.K then
        PlaySound(Sounds.Click, 0.5, 1)
        Rayfield:Toggle()
    end
end)

local function GetRootPart(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end

local function GetDist(pos)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return math.floor((LocalPlayer.Character.HumanoidRootPart.Position - pos).Magnitude)
    end
    return 0
end

local function CleanAnimalName(obj)
    local name = tostring(obj.Name):lower()
    local prefix = name:find("legendary") and "Legendary " or ""
    if name:find("crow") then return prefix .. "Crow" end
    if name:find("dire wolf") or name:find("direwolf") then return prefix .. "Dire Wolf" end
    if name:find("wolf") then return prefix .. "Wolf" end
    if name:find("coyote") then return prefix .. "Coyote" end
    if name:find("fox") then return prefix .. "Fox" end
    if name:find("grizzly") then return prefix .. "Grizzly Bear" end
    if name:find("black bear") then return prefix .. "Black Bear" end
    if name:find("bear") then return prefix .. "Bear" end
    if name:find("bison") or name:find("buffalo") then return prefix .. "Bison" end
    if name:find("buck") or name:find("doe") or name:find("fawn") or name:find("deer") then return prefix .. "Deer" end
    if name:find("horse") then return "Horse" end
    if name:find("cow") or name:find("cattle") then return "Cow" end
    if name:find("pig") or name:find("boar") then return "Pig" end
    if name:find("rabbit") or name:find("bunny") then return "Rabbit" end
    if name:find("chicken") then return "Chicken" end
    return obj.Name
end

-- ─── CHEST DETECTION ──────────────────────────────────────────────────────────
local function IsChest(obj)
    if not obj:IsA("Model") and not obj:IsA("BasePart") then return false end
    local name = obj.Name:lower()
    if name:find("%(item%)") then return false end
    return (name:find("treasure") and name:find("chest")) or name == "treasurechest"
end

local function GetChestLabel()
    return "💰 Treasure Chest"
end

-- ─── ITEM DETECTION ───────────────────────────────────────────────────────────
local function GetItemLabel(obj)
    local name = obj.Name:lower()
    if name:find("silver skull") then return "💀 Silver Skull" end
    if name:find("gold skull") or name:find("golden skull") then return "💀 Gold Skull" end
    if name:find("gold crown") or name:find("golden crown") then return "👑 Gold Crown" end
    if name:find("gold key") or name:find("golden key") then return "🔑 Gold Key" end
    if name:find("silver key") then return "🔑 Silver Key" end
    if name:find("gold jewelry") or name:find("gold jewlery") or name:find("gold jewellery")
    or name:find("golden jewelry") or name:find("golden jewlery") then return "📿 Gold Jewelry" end
    if name:find("jewelry") or name:find("jewlery") or name:find("jewellery") then return "📿 Jewelry" end
    if name:find("emerald") then return "💚 Emerald" end
    if name:find("ruby") then return "❤️ Ruby" end
    if name:find("diamond") then return "💎 Diamond" end
    if name:find("crown") then return "👑 Crown" end
    return nil
end

local function IsItem(obj)
    return GetItemLabel(obj) ~= nil
end
-- ──────────────────────────────────────────────────────────────────────────────

local function IsVisible(targetPart)
    if not targetPart or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then return false end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    local result = workspace:Raycast(origin, direction, raycastParams)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

-- ─── AIMBOT ───────────────────────────────────────────────────────────────────
local LockedTarget = nil

local function GetClosestTarget()
    local targetPart = nil
    local dist = Settings.FOV
    if Settings.AimPlayers then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character
            and v.Character:FindFirstChild("Head")
            and v.Character:FindFirstChild("Humanoid")
            and v.Character.Humanoid.Health > 0 then
                if Settings.WallCheck and not IsVisible(v.Character.Head) then continue end
                local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < dist then
                        targetPart = v.Character.Head
                        dist = mag
                    end
                end
            end
        end
    end
    if Settings.AimAnimals then
        for _, folderName in pairs({"Harvestables", "Animals", "NPCS"}) do
            local folder = workspace:FindFirstChild(folderName)
            if folder then
                for _, v in pairs(folder:GetChildren()) do
                    if v:IsA("Model") then
                        local hum = v:FindFirstChild("Humanoid") or v:FindFirstChildWhichIsA("Humanoid")
                        if hum and hum.Health <= 0 then continue end
                        local rp = GetRootPart(v)
                        if rp then
                            if Settings.WallCheck and not IsVisible(rp) then continue end
                            local pos, vis = Camera:WorldToViewportPoint(rp.Position)
                            if vis then
                                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                                if mag < dist then
                                    targetPart = rp
                                    dist = mag
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return targetPart
end

local function ValidateLockedTarget()
    if not LockedTarget then return false end
    if not LockedTarget.Parent then return false end
    local char = LockedTarget.Parent
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return false end
    return true
end
-- ──────────────────────────────────────────────────────────────────────────────

local function ManageESP(obj, text, color, tag, shouldShow, dist, isPlayer)
    local rootPart = isPlayer and (obj:FindFirstChild("Head") or obj:FindFirstChild("HumanoidRootPart")) or GetRootPart(obj)
    if not rootPart then return end
    local billboard = rootPart:FindFirstChild(tag)
    local inRange = isPlayer or (dist <= Settings.ESPDistance)
    if shouldShow and inRange then
        if not billboard then
            billboard = Instance.new("BillboardGui")
            billboard.Name = tag
            billboard.Adornee = rootPart
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 150, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.Parent = rootPart
            local label = Instance.new("TextLabel", billboard)
            label.Name = "TextL"
            label.Text = ""
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 1, 0)
            label.TextStrokeTransparency = 0
            label.Font = Enum.Font.SourceSansBold
        end
        local label = billboard:FindFirstChild("TextL")
        if label then
            label.TextSize = Settings.TextSize
            label.TextColor3 = color
            local distText = Settings.ShowDistance and " [" .. dist .. "m]" or ""
            label.Text = text .. distText
        end
    else
        if billboard then billboard:Destroy() end
    end
end

local function ManageChestESP(obj, text, color, tag, shouldShow, dist)
    local rootPart = GetRootPart(obj)
    if not rootPart then return end
    local billboard = rootPart:FindFirstChild(tag)
    local inRange = dist <= Settings.ChestESPDistance
    if shouldShow and inRange then
        if not billboard then
            billboard = Instance.new("BillboardGui")
            billboard.Name = tag
            billboard.Adornee = rootPart
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 200, 0, 60)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.Parent = rootPart
            local label = Instance.new("TextLabel", billboard)
            label.Name = "TextL"
            label.Text = ""
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 1, 0)
            label.TextStrokeTransparency = 0
            label.Font = Enum.Font.SourceSansBold
        end
        local label = billboard:FindFirstChild("TextL")
        if label then
            label.TextSize = Settings.TextSize
            label.TextColor3 = color
            local distText = Settings.ShowDistance and " [" .. dist .. "m]" or ""
            label.Text = text .. distText
        end
    else
        if billboard then billboard:Destroy() end
    end
end

local function ManageItemESP(obj, text, color, tag, shouldShow, dist)
    local rootPart = GetRootPart(obj)
    if not rootPart then return end
    local billboard = rootPart:FindFirstChild(tag)
    local inRange = dist <= Settings.ItemESPDistance
    if shouldShow and inRange then
        if not billboard then
            billboard = Instance.new("BillboardGui")
            billboard.Name = tag
            billboard.Adornee = rootPart
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 200, 0, 60)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.Parent = rootPart
            local label = Instance.new("TextLabel", billboard)
            label.Name = "TextL"
            label.Text = ""
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 1, 0)
            label.TextStrokeTransparency = 0
            label.Font = Enum.Font.SourceSansBold
        end
        local label = billboard:FindFirstChild("TextL")
        if label then
            label.TextSize = Settings.TextSize
            label.TextColor3 = color
            local distText = Settings.ShowDistance and " [" .. dist .. "m]" or ""
            label.Text = text .. distText
        end
    else
        if billboard then billboard:Destroy() end
    end
end

local function ClearAllChestESP()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "OverlordChestESP" then obj:Destroy() end
    end
end

local function ClearAllItemESP()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "OverlordItemESP" then obj:Destroy() end
    end
end

-- ─── COMBAT TAB ───────────────────────────────────────────────────────────────
CombatTab:CreateToggle({
    Name = "Aim at Players",
    CurrentValue = false,
    Flag = "AimPlayers",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.AimPlayers = v
        if not v then LockedTarget = nil end
    end,
})
CombatTab:CreateToggle({
    Name = "Aim at Animals",
    CurrentValue = false,
    Flag = "AimAnimals",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.AimAnimals = v
        if not v then LockedTarget = nil end
    end,
})
CombatTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = false,
    Flag = "WallCheck",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.WallCheck = v
    end,
})
CombatTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Flag = "SilentAim",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.SilentAim = v
    end,
})
CombatTab:CreateSlider({
    Name = "FOV Radius",
    Range = {0, 800},
    Increment = 1,
    Suffix = "px",
    CurrentValue = 150,
    Flag = "FOV",
    Callback = function(v)
        PlaySound(Sounds.Slider, 0.2, 1)
        Settings.FOV = v
    end,
})
CombatTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = false,
    Flag = "ShowFOVCircle",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.ShowFOVCircle = v
    end,
})

-- ─── VISUALS TAB ──────────────────────────────────────────────────────────────
VisualsTab:CreateToggle({
    Name = "Name ESP",
    CurrentValue = false,
    Flag = "PlayerName",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.PlayerName = v
    end,
})
VisualsTab:CreateToggle({
    Name = "Health ESP",
    CurrentValue = false,
    Flag = "PlayerHP",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.PlayerHP = v
    end,
})
VisualsTab:CreateToggle({
    Name = "Chams",
    CurrentValue = false,
    Flag = "PlayerBox",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.PlayerBox = v
    end,
})
VisualsTab:CreateToggle({
    Name = "Animal ESP",
    CurrentValue = false,
    Flag = "AnimalESP",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.AnimalESP = v
        if not v then
            for _, folderName in pairs({"Harvestables", "Animals", "NPCS"}) do
                local folder = workspace:FindFirstChild(folderName)
                if folder then
                    for _, animal in pairs(folder:GetChildren()) do
                        local rp = GetRootPart(animal)
                        if rp and rp:FindFirstChild("OverlordAnimalESP") then
                            rp.OverlordAnimalESP:Destroy()
                        end
                    end
                end
            end
        end
    end,
})
VisualsTab:CreateToggle({
    Name = "Chest ESP",
    CurrentValue = false,
    Flag = "ChestESP",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.ChestESP = v
        if not v then ClearAllChestESP() end
    end,
})
VisualsTab:CreateSlider({
    Name = "Max Chest ESP Range",
    Range = {500, 20000},
    Increment = 100,
    Suffix = "studs",
    CurrentValue = 10000,
    Flag = "ChestESPDistance",
    Callback = function(v)
        PlaySound(Sounds.Slider, 0.2, 1)
        Settings.ChestESPDistance = v
    end,
})
VisualsTab:CreateColorPicker({
    Name = "Chest ESP Color",
    Color = Color3.fromRGB(255, 215, 0),
    Flag = "ChestColor",
    Callback = function(v)
        PlaySound(Sounds.Click, 0.4, 1)
        Settings.ChestColor = v
    end,
})
VisualsTab:CreateToggle({
    Name = "Item ESP",
    CurrentValue = false,
    Flag = "ItemESP",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.ItemESP = v
        if not v then ClearAllItemESP() end
    end,
})
VisualsTab:CreateSlider({
    Name = "Max Item ESP Range",
    Range = {500, 20000},
    Increment = 100,
    Suffix = "studs",
    CurrentValue = 10000,
    Flag = "ItemESPDistance",
    Callback = function(v)
        PlaySound(Sounds.Slider, 0.2, 1)
        Settings.ItemESPDistance = v
    end,
})
VisualsTab:CreateColorPicker({
    Name = "Item ESP Color",
    Color = Color3.fromRGB(0, 255, 200),
    Flag = "ItemColor",
    Callback = function(v)
        PlaySound(Sounds.Click, 0.4, 1)
        Settings.ItemColor = v
    end,
})
VisualsTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = false,
    Flag = "ShowDistance",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.ShowDistance = v
    end,
})
VisualsTab:CreateSlider({
    Name = "Max Animal ESP Range",
    Range = {500, 20000},
    Increment = 100,
    Suffix = "studs",
    CurrentValue = 10000,
    Flag = "ESPDistance",
    Callback = function(v)
        PlaySound(Sounds.Slider, 0.2, 1)
        Settings.ESPDistance = v
    end,
})
VisualsTab:CreateSlider({
    Name = "Text Size",
    Range = {8, 20},
    Increment = 1,
    Suffix = "px",
    CurrentValue = 12,
    Flag = "TextSize",
    Callback = function(v)
        PlaySound(Sounds.Slider, 0.2, 1)
        Settings.TextSize = v
    end,
})
VisualsTab:CreateColorPicker({
    Name = "Player ESP Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "PlayerColor",
    Callback = function(v)
        PlaySound(Sounds.Click, 0.4, 1)
        Settings.PlayerColor = v
    end,
})
VisualsTab:CreateColorPicker({
    Name = "Animal ESP Color",
    Color = Color3.fromRGB(255, 165, 0),
    Flag = "AnimalColor",
    Callback = function(v)
        PlaySound(Sounds.Click, 0.4, 1)
        Settings.AnimalColor = v
    end,
})

-- ─── WORLD TAB ────────────────────────────────────────────────────────────────
WorldTab:CreateToggle({
    Name = "Full Bright",
    CurrentValue = false,
    Flag = "FullBright",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.FullBright = v
    end,
})
WorldTab:CreateToggle({
    Name = "No Fog",
    CurrentValue = false,
    Flag = "NoFog",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.NoFog = v
        if v then
            local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmos then atmos:Destroy() end
            Lighting.FogEnd = 100000
            Lighting.FogStart = 100000
        else
            Lighting.FogStart = 0
            Lighting.FogEnd = 100000
        end
    end,
})
WorldTab:CreateToggle({
    Name = "TP-Walk",
    CurrentValue = false,
    Flag = "TPWalk",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.TPWalk = v
    end,
})
WorldTab:CreateSlider({
    Name = "TP Speed",
    Range = {1, 15},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 2,
    Flag = "TPWalkSpeed",
    Callback = function(v)
        PlaySound(Sounds.Slider, 0.2, 1)
        Settings.TPWalkSpeed = v
    end,
})
WorldTab:CreateToggle({
    Name = "Instant Interact",
    CurrentValue = false,
    Flag = "InstantInteract",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.InstantInteract = v
    end,
})
WorldTab:CreateKeybind({
    Name = "Toggle GUI",
    CurrentKeybind = "K",
    HoldToInteract = false,
    Flag = "ToggleGUI",
    Callback = function()
        PlaySound(Sounds.Click, 0.5, 1)
        Rayfield:Toggle()
    end,
})

-- ─── LOOPS ────────────────────────────────────────────────────────────────────
task.spawn(function()
    while task.wait(1) do
        if Settings.AnimalESP then
            for _, folderName in pairs({"Harvestables", "Animals", "NPCS"}) do
                local folder = workspace:FindFirstChild(folderName)
                if folder then
                    for _, v in pairs(folder:GetChildren()) do
                        if v:IsA("Model") then
                            local rp = GetRootPart(v)
                            if rp then
                                local dist = GetDist(rp.Position)
                                ManageESP(v, CleanAnimalName(v), Settings.AnimalColor, "OverlordAnimalESP", true, dist, false)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ─── CHEST ESP ────────────────────────────────────────────────────────────────
local TrackedChests = {}

local function HideChestESP(obj)
    pcall(function()
        local rp = GetRootPart(obj)
        if rp then
            local bb = rp:FindFirstChild("OverlordChestESP")
            if bb then bb:Destroy() end
        end
    end)
    TrackedChests[obj] = nil
end

local function TryTagChest(obj)
    if not IsChest(obj) then return end
    local rp = GetRootPart(obj)
    if not rp then return end
    if TrackedChests[obj] then return end
    TrackedChests[obj] = true
    obj.ChildAdded:Connect(function(child)
        pcall(function()
            local n = child.Name:lower()
            if n == "opened" or n == "open" or n == "isopened" then
                HideChestESP(obj)
            end
        end)
    end)
end

for _, obj in pairs(workspace:GetDescendants()) do pcall(TryTagChest, obj) end
workspace.DescendantAdded:Connect(function(obj) pcall(TryTagChest, obj) end)
workspace.DescendantRemoving:Connect(function(obj)
    if TrackedChests[obj] then TrackedChests[obj] = nil end
end)

task.spawn(function()
    while task.wait(1) do
        for obj in pairs(TrackedChests) do
            pcall(function()
                local rp = GetRootPart(obj)
                if not rp then HideChestESP(obj) return end
                for _, child in pairs(obj:GetChildren()) do
                    local n = child.Name:lower()
                    if n == "opened" or n == "open" or n == "isopened" then
                        HideChestESP(obj)
                        return
                    end
                end
                if Settings.ChestESP then
                    ManageChestESP(obj, GetChestLabel(), Settings.ChestColor, "OverlordChestESP", true, GetDist(rp.Position))
                else
                    local bb = rp:FindFirstChild("OverlordChestESP")
                    if bb then bb:Destroy() end
                end
            end)
        end
    end
end)

task.spawn(function()
    pcall(function()
        local chestFolder = workspace:WaitForChild("ChestFolder", 15)
        if not chestFolder then return end
        chestFolder.ChildRemoved:Connect(function(obj)
            pcall(function()
                if TrackedChests[obj] then HideChestESP(obj) end
            end)
        end)
        for _, obj in pairs(chestFolder:GetChildren()) do
            pcall(TryTagChest, obj)
        end
    end)
end)

task.delay(3, function()
    for _, obj in pairs(workspace:GetDescendants()) do
        pcall(TryTagChest, obj)
    end
end)
-- ──────────────────────────────────────────────────────────────────────────────

-- ─── ITEM ESP ─────────────────────────────────────────────────────────────────
local TrackedItems = {}

local function TryTagItem(obj)
    if not IsItem(obj) then return end
    local rp = GetRootPart(obj)
    if not rp then return end
    if TrackedItems[obj] then return end
    TrackedItems[obj] = GetItemLabel(obj)
end

for _, obj in pairs(workspace:GetDescendants()) do pcall(TryTagItem, obj) end
workspace.DescendantAdded:Connect(function(obj) pcall(TryTagItem, obj) end)
workspace.DescendantRemoving:Connect(function(obj)
    if TrackedItems[obj] then TrackedItems[obj] = nil end
end)

task.spawn(function()
    while task.wait(1) do
        if Settings.ItemESP then
            for obj, label in pairs(TrackedItems) do
                pcall(function()
                    local rp = GetRootPart(obj)
                    if not rp then TrackedItems[obj] = nil return end
                    ManageItemESP(obj, label, Settings.ItemColor, "OverlordItemESP", true, GetDist(rp.Position))
                end)
            end
        end
    end
end)
-- ─────────────────────────────────────────────────────────────────────────────

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Settings.ShowFOVCircle
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    local isAiming = (Settings.AimPlayers or Settings.AimAnimals)
        and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    local isSilent = Settings.SilentAim
        and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)

    if isAiming or isSilent then
        if not ValidateLockedTarget() then LockedTarget = nil end
        if not LockedTarget then LockedTarget = GetClosestTarget() end
        if LockedTarget and LockedTarget.Parent then
            if isAiming then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, LockedTarget.Position)
            elseif isSilent then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, LockedTarget.Position), 0.1)
            end
        end
    else
        LockedTarget = nil
    end

    if Settings.FullBright then
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
    end

    if Settings.NoFog then
        local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmos then atmos:Destroy() end
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
    end

    if Settings.TPWalk and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        if hum.MoveDirection.Magnitude > 0 then
            LocalPlayer.Character:TranslateBy(hum.MoveDirection * Settings.TPWalkSpeed / 10)
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local rp = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")

            if rp and hum and hum.Health > 0 then
                local dist = GetDist(rp.Position)
                local shouldShow = Settings.PlayerName or Settings.PlayerHP
                local dText = ""
                if Settings.PlayerName then dText = p.Name end
                if Settings.PlayerHP then dText = dText .. (dText ~= "" and "\n" or "") .. "[HP: " .. math.floor(hum.Health) .. "]" end
                ManageESP(char, dText, Settings.PlayerColor, "OverlordPlayerESP", shouldShow, dist, true)

                local highlight = char:FindFirstChild("OverlordHigh")
                if Settings.PlayerBox then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "OverlordHigh"
                        highlight.Parent = char
                    end
                    highlight.FillColor = Settings.PlayerColor
                    highlight.FillTransparency = 0.5
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                elseif highlight then
                    highlight:Destroy()
                end
            else
                local b = char:FindFirstChild("OverlordPlayerESP", true)
                if b then b:Destroy() end
                local h = char:FindFirstChild("OverlordHigh")
                if h then h:Destroy() end
            end
        end
    end
end)

ProximityPromptService.PromptShown:Connect(function(prompt)
    if Settings.InstantInteract then
        prompt.HoldDuration = 0
    end
end)

Rayfield:Notify({
    Title = "BabyBound",
    Content = "Successfully loaded! | K = Toggle GUI",
    Duration = 5,
    Image = 4483362458,
})
PlaySound(Sounds.Notify, 0.6, 1.05)
