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
    ShowDistance = false,
    ESPDistance = 10000,
    TextSize = 12,
    PlayerColor = Color3.fromRGB(255, 0, 0),
    AnimalColor = Color3.fromRGB(255, 165, 0),
    InstantInteract = false,
    TPWalk = false,
    TPWalkSpeed = 2,
    FullBright = false,
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
    Name = "BabyBound | 80he",
    Icon = 0,
    LoadingTitle = "BabyBound",
    LoadingSubtitle = "by 80he",
    Theme = "Amethyst",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
})

-- ─── UI SOUNDS ────────────────────────────────────────────────────────────────
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
-- ──────────────────────────────────────────────────────────────────────────────

local CombatTab = Window:CreateTab("Combat", "crosshair")
local VisualsTab = Window:CreateTab("Visuals", "eye")
local WorldTab = Window:CreateTab("World", "globe")

local CombatSection = CombatTab:CreateSection("Aimbot Settings")
local VisualSettingsSection = VisualsTab:CreateSection("Visuals")
local UtilitySection = WorldTab:CreateSection("Utility")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
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

local function GetClosestTarget()
    local targetPart = nil
    local dist = Settings.FOV
    if Settings.AimPlayers then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
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

-- ─── COMBAT TAB ───────────────────────────────────────────────────────────────
CombatTab:CreateToggle({
    Name = "Aim at Players",
    CurrentValue = false,
    Flag = "AimPlayers",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.AimPlayers = v
    end,
})

CombatTab:CreateToggle({
    Name = "Aim at Animals",
    CurrentValue = false,
    Flag = "AimAnimals",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.AimAnimals = v
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
    CurrentKeybind = "RightShift",
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

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Settings.ShowFOVCircle
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    local aimPart = GetClosestTarget()
    if aimPart then
        if (Settings.AimPlayers or Settings.AimAnimals) and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
        end
        if Settings.SilentAim and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPart.Position), 0.1)
        end
    end

    if Settings.FullBright then
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
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
    Content = "Successfully loaded! | RightShift = Toggle GUI",
    Duration = 5,
    Image = 4483362458,
})
PlaySound(Sounds.Notify, 0.6, 1.05)
