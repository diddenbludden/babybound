local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Settings = {
    AimPlayers = false,
    AimAnimals = false,
    WallCheck = false,
    SilentAim = false,
    SAAliveCheck = false,
    SAVisibleCheck = false,
    SABulletTP = false,
    SAShowTarget = false,
    SAWhitelist = {},
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
    AutoFarm = false,
    MaxInventory = 10,
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
    ToggleUIKeybind = "K",
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

-- ─── HUD: TRAIN + MANSION TIMERS ─────────────────────────────────────────────
local HudGui = Instance.new("ScreenGui")
HudGui.Name = "BabyBoundHud"
HudGui.ResetOnSpawn = false
HudGui.IgnoreGuiInset = true
HudGui.Parent = LocalPlayer.PlayerGui

local function MakeHudLabel(yOffset, bgColor, textColor)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 230, 0, 34)
    frame.Position = UDim2.new(1, -240, 0, yOffset)
    frame.BackgroundColor3 = bgColor
    frame.BackgroundTransparency = 0.25
    frame.BorderSizePixel = 0
    frame.Parent = HudGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = textColor
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextStrokeTransparency = 0.5
    label.Text = ""
    label.Parent = frame

    return label
end

-- Top-right corner: train on row 1, mansion on row 2
local TrainHudLabel   = MakeHudLabel(10, Color3.fromRGB(25, 10, 10), Color3.fromRGB(255, 100, 100))
local MansionHudLabel = MakeHudLabel(52, Color3.fromRGB(10, 10, 30), Color3.fromRGB(130, 170, 255))

local function FormatTime(seconds)
    seconds = math.max(0, math.floor(seconds))
    local m = math.floor(seconds / 60)
    local s = seconds % 60
    return string.format("%d:%02d", m, s)
end

-- ─── TRAIN DETECTION ─────────────────────────────────────────────────────────
local trainKeywords = {"train", "locomotive", "railcar", "steamengine"}

local function LooksLikeTrain(name)
    local n = name:lower()
    for _, kw in pairs(trainKeywords) do
        if n:find(kw) then return true end
    end
    return false
end

local trainPresent = false
local trainStateTime = tick()

-- Check workspace for train on startup
for _, obj in pairs(workspace:GetChildren()) do
    if LooksLikeTrain(obj.Name) then
        trainPresent = true
        break
    end
end

workspace.ChildAdded:Connect(function(obj)
    pcall(function()
        if LooksLikeTrain(obj.Name) and not trainPresent then
            trainPresent = true
            trainStateTime = tick()
            PlaySound(Sounds.Notify, 0.7, 0.85)
            Rayfield:Notify({
                Title = "🚂 Train Spotted!",
                Content = "The train has arrived!",
                Duration = 5,
                Image = 4483362458,
            })
        end
    end)
end)

workspace.ChildRemoved:Connect(function(obj)
    pcall(function()
        if LooksLikeTrain(obj.Name) and trainPresent then
            trainPresent = false
            trainStateTime = tick()
            Rayfield:Notify({
                Title = "🚂 Train Left",
                Content = "The train has despawned.",
                Duration = 4,
                Image = 4483362458,
            })
        end
    end)
end)

-- ─── MANSION DETECTION ───────────────────────────────────────────────────────
local function IsNight()
    local t = Lighting.ClockTime
    return t >= 18 or t < 6
end

local mansionKeywords = {"mansion", "manor", "haunted", "estate", "victorian", "castle"}

local function LooksLikeMansion(name)
    local n = name:lower()
    for _, kw in pairs(mansionKeywords) do
        if n:find(kw) then return true end
    end
    return false
end

local function CheckMansionOpen()
    if IsNight() then return true end
    for _, obj in pairs(workspace:GetDescendants()) do
        local ok, result = pcall(function()
            if LooksLikeMansion(obj.Name) then
                for _, valName in pairs({"Open", "IsOpen", "Active", "Unlocked"}) do
                    local v = obj:FindFirstChild(valName)
                    if v and v:IsA("BoolValue") and v.Value then
                        return true
                    end
                end
            end
        end)
        if ok and result then return true end
    end
    return false
end

local mansionOpen = CheckMansionOpen()
local mansionStateTime = tick()

task.spawn(function()
    while true do
        task.wait(2)
        local nowOpen = CheckMansionOpen()
        if nowOpen ~= mansionOpen then
            mansionOpen = nowOpen
            mansionStateTime = tick()
            if mansionOpen then
                PlaySound(Sounds.Notify, 0.7, 1.1)
                Rayfield:Notify({
                    Title = "🏚️ Mansion Open!",
                    Content = "Night has fallen — mansion is open!",
                    Duration = 6,
                    Image = 4483362458,
                })
            else
                Rayfield:Notify({
                    Title = "🏚️ Mansion Closed",
                    Content = "Day has come — mansion is closed.",
                    Duration = 4,
                    Image = 4483362458,
                })
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local tElapsed = math.floor(tick() - trainStateTime)
    if trainPresent then
        TrainHudLabel.Text = "🚂 Train active: " .. FormatTime(tElapsed)
        TrainHudLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    else
        TrainHudLabel.Text = "🚂 Train gone: " .. FormatTime(tElapsed) .. " ago"
        TrainHudLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    end

    local mElapsed = math.floor(tick() - mansionStateTime)
    if mansionOpen then
        MansionHudLabel.Text = "🏚️ Mansion OPEN: " .. FormatTime(mElapsed)
        MansionHudLabel.TextColor3 = Color3.fromRGB(100, 255, 140)
    else
        MansionHudLabel.Text = "🏚️ Mansion closed: " .. FormatTime(mElapsed) .. " ago"
        MansionHudLabel.TextColor3 = Color3.fromRGB(130, 150, 255)
    end
end)
-- ─────────────────────────────────────────────────────────────────────────────

local CombatTab = Window:CreateTab("Combat", "crosshair")
local VisualsTab = Window:CreateTab("Visuals", "eye")
local WorldTab = Window:CreateTab("World", "globe")
local FarmTab = Window:CreateTab("AutoFarm", "star")

CombatTab:CreateSection("Aimbot Settings")
VisualsTab:CreateSection("Visuals")
WorldTab:CreateSection("Utility")
FarmTab:CreateSection("Mansion Item Farm")

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

-- ─── SILENT AIM BY FRESH ───────────────────────────────────────────────────

local _saCurrentTarget = nil

local function SAIsVisible(targetPart)
    if not targetPart or not LocalPlayer.Character then return false end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = { LocalPlayer.Character }
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    local result = workspace:Raycast(origin, direction, raycastParams)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

local function UpdateSATarget()
    if not Settings.SilentAim then
        _saCurrentTarget = nil
        return
    end
    local bestPart = nil
    local bestDist = math.huge
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2

    for _, v in pairs(Players:GetPlayers()) do
        if v == LocalPlayer then continue end

        if next(Settings.SAWhitelist) ~= nil then
            if not Settings.SAWhitelist[v.Name] then continue end
        end

        local char = v.Character
        if not char then continue end

        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then continue end

        if Settings.SAAliveCheck and hum.Health <= 0 then continue end
        if Settings.SAVisibleCheck and not SAIsVisible(hrp) then continue end

        local ok, screenPos, onScreen = pcall(function()
            return Camera:WorldToViewportPoint(hrp.Position)
        end)
        if not ok or not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(cx, cy)).Magnitude
        if dist < bestDist then
            bestDist = dist
            bestPart = hrp
        end
    end

    _saCurrentTarget = bestPart
end


RunService.Heartbeat:Connect(function()
    pcall(UpdateSATarget)
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local method = getnamecallmethod()

    
    if Settings.SilentAim and not checkcaller() then
        if method == "FindPartOnRayWithIgnoreList"
        or method == "FindPartOnRayWithWhitelist"
        or method == "FindPartOnRay"
        or method == "findPartOnRay"
        or method == "Raycast" then
            local args = {...}
            if args[1] == workspace then
                local target = _saCurrentTarget
                if target and target.Parent then
                    if method == "Raycast" then
                        local origin = args[2]
                        if typeof(origin) == "Vector3" then
                            if Settings.SABulletTP then
                                origin = (target.CFrame * CFrame.new(0, 0, 1)).Position
                            end
                            args[2] = origin
                            args[3] = (target.Position - origin).Unit * 1000
                            return oldNamecall(unpack(args))
                        end
                    else
                        local ray = args[2]
                        if typeof(ray) == "Ray" then
                            local origin = ray.Origin
                            if Settings.SABulletTP then
                                origin = (target.CFrame * CFrame.new(0, 0, 1)).Position
                            end
                            args[2] = Ray.new(origin, (target.Position - origin).Unit * 1000)
                            return oldNamecall(unpack(args))
                        end
                    end
                end
            end
        end
    end

    return oldNamecall(...)
end))
-- ─────────────────────────────────────────────────────────────────────────────

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

-- ─── AUTOFARM ─────────────────────────────────────────────────────────────────
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ActiveFarmTween = nil

local STEP_SIZE = 50
local ARRIVE_THRESHOLD = 5

local function FindSurfaceNear(pos)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { LocalPlayer.Character }

    local downRay = workspace:Raycast(pos + Vector3.new(0, 10, 0), Vector3.new(0, -40, 0), rayParams)
    if downRay then return downRay.Position + Vector3.new(0, 3, 0) end

    local directions = {
        Vector3.new(1,0,0), Vector3.new(-1,0,0),
        Vector3.new(0,0,1), Vector3.new(0,0,-1),
        Vector3.new(1,0,1).Unit, Vector3.new(-1,0,1).Unit,
        Vector3.new(1,0,-1).Unit, Vector3.new(-1,0,-1).Unit,
    }
    for _, dir in ipairs(directions) do
        local checkPos = pos + dir * 5
        local floorRay = workspace:Raycast(checkPos + Vector3.new(0, 10, 0), Vector3.new(0, -40, 0), rayParams)
        if floorRay then return floorRay.Position + Vector3.new(0, 3, 0) end
    end

    return pos + Vector3.new(0, 3, 0)
end

local function HopTo(targetPos)
    if not Settings.AutoFarm then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _ = 1, 200 do
        if not Settings.AutoFarm then return end
        char = LocalPlayer.Character
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local currentPos = hrp.Position
        local toTarget = targetPos - currentPos
        local dist = toTarget.Magnitude
        if dist <= ARRIVE_THRESHOLD then break end

        local stepDist = math.min(STEP_SIZE, dist)
        local stepPos = currentPos + toTarget.Unit * stepDist

        if dist <= STEP_SIZE then
            hrp.CFrame = CFrame.new(targetPos)
            break
        else
            local surfacePos = FindSurfaceNear(stepPos)
            hrp.CFrame = CFrame.new(surfacePos)
        end

        task.wait(0.05)
    end
end

local function PressF()
    pcall(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F, false, game)
    end)
    task.wait(0.08)
    pcall(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
end

local function FirePromptOn(obj)
    pcall(function()
        local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
        if not prompt then
            for _, child in pairs(obj:GetChildren()) do
                local p = child:FindFirstChildOfClass("ProximityPrompt")
                if p then prompt = p break end
            end
        end
        if prompt then
            local oldHold = prompt.HoldDuration
            prompt.HoldDuration = 0
            pcall(function() fireclickdetector(prompt) end)
            prompt:InputHoldBegin()
            task.wait(0.05)
            prompt:InputHoldEnd()
            task.wait(0.05)
            prompt.HoldDuration = oldHold
        end
    end)
end

local function InteractAt(obj)
    PressF()
    if obj then FirePromptOn(obj) end
    task.wait(0.3)
end

local function FireSellPrompts()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("ProximityPrompt") then
                local action = obj.ActionText:lower()
                local obj2 = obj.ObjectText:lower()
                if action:find("sell") or action:find("pawn")
                or obj2:find("sell") or obj2:find("pawn") or obj2:find("fence") then
                    local part = obj.Parent
                    local pos = part and part:IsA("BasePart") and part.Position
                    if pos and (pos - char.HumanoidRootPart.Position).Magnitude < 20 then
                        local oldHold = obj.HoldDuration
                        obj.HoldDuration = 0
                        obj:InputHoldBegin()
                        task.wait(0.1)
                        obj:InputHoldEnd()
                        obj.HoldDuration = oldHold
                        task.wait(0.3)
                    end
                end
            end
        end)
    end
end

local function FindSellLocation()
    local keywords = {"pawn", "sell", "fence", "shop", "buyer", "dealer", "merchant", "vendor"}
    for _, obj in pairs(workspace:GetDescendants()) do
        local ok, result = pcall(function()
            local name = obj.Name:lower()
            for _, kw in pairs(keywords) do
                if name:find(kw) then
                    local rp = GetRootPart(obj)
                    if rp then return rp.Position end
                end
            end
        end)
        if ok and result then return result end
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local ok, result = pcall(function()
                local action = obj.ActionText:lower()
                local obj2 = obj.ObjectText:lower()
                if action:find("sell") or action:find("pawn")
                or obj2:find("sell") or obj2:find("pawn") or obj2:find("fence") then
                    local part = obj.Parent
                    if part and part:IsA("BasePart") then return part.Position end
                    local rp = GetRootPart(obj.Parent)
                    if rp then return rp.Position end
                end
            end)
            if ok and result then return result end
        end
    end
    return nil
end

local function GetInventoryCount()
    local count = 0
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") or item:IsA("Model") then count = count + 1 end
        end
    end
    local char = LocalPlayer.Character
    if char then
        for _, item in pairs(char:GetChildren()) do
            if item:IsA("Tool") then count = count + 1 end
        end
    end
    return count
end

local function GetFarmableItems()
    local items = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        pcall(function()
            if IsItem(obj) and GetRootPart(obj) then
                table.insert(items, obj)
            end
        end)
    end
    return items
end

local FarmStatusGui = Instance.new("ScreenGui")
FarmStatusGui.Name = "FarmStatusGui"
FarmStatusGui.ResetOnSpawn = false
FarmStatusGui.IgnoreGuiInset = true
FarmStatusGui.Parent = LocalPlayer.PlayerGui

local FarmStatusLabel = Instance.new("TextLabel")
FarmStatusLabel.Name = "FarmStatus"
FarmStatusLabel.Size = UDim2.new(0, 280, 0, 36)
FarmStatusLabel.Position = UDim2.new(0.5, -140, 0, 10)
FarmStatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
FarmStatusLabel.BackgroundTransparency = 0.25
FarmStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
FarmStatusLabel.Font = Enum.Font.SourceSansBold
FarmStatusLabel.TextSize = 15
FarmStatusLabel.Text = ""
FarmStatusLabel.TextStrokeTransparency = 0.5
FarmStatusLabel.Visible = false
FarmStatusLabel.Parent = FarmStatusGui

local UICornerFarm = Instance.new("UICorner")
UICornerFarm.CornerRadius = UDim.new(0, 6)
UICornerFarm.Parent = FarmStatusLabel

local function SetFarmStatus(text)
    FarmStatusLabel.Text = text
    FarmStatusLabel.Visible = text ~= ""
end

-- ─── SELL TRIGGER FLAGS ──────────────────────────────────────────────────────
local sellTriggeredByChat = false

pcall(function()
    local TextChatService = game:GetService("TextChatService")
    TextChatService.MessageReceived:Connect(function(msg)
        pcall(function()
            local t = msg.Text:lower()
            if t:find("inventory") and t:find("full") then
                sellTriggeredByChat = true
            end
        end)
    end)
    local channels = TextChatService:FindFirstChild("TextChannels")
    if channels then
        local function hookChannel(ch)
            pcall(function()
                ch.MessageReceived:Connect(function(msg)
                    pcall(function()
                        local t = msg.Text:lower()
                        if t:find("inventory") and t:find("full") then
                            sellTriggeredByChat = true
                        end
                    end)
                end)
            end)
        end
        for _, ch in pairs(channels:GetChildren()) do hookChannel(ch) end
        channels.ChildAdded:Connect(hookChannel)
    end
end)

local function FindGeneralStore()
    local storeKeywords = {"generalstore", "general store", "general_store", "redrock", "red rock", "camp store", "campstore"}
    for _, obj in pairs(workspace:GetDescendants()) do
        local ok, result = pcall(function()
            local n = obj.Name:lower()
            for _, kw in pairs(storeKeywords) do
                if n:find(kw) then
                    local rp = GetRootPart(obj)
                    if rp then return rp.Position end
                end
            end
        end)
        if ok and result then return result end
    end
    return FindSellLocation()
end

local function DoSell()
    SetFarmStatus("🏪 Heading to General Store...")
    local sellPos = FindGeneralStore()
    if sellPos then
        HopTo(sellPos)
        if not Settings.AutoFarm then return end
        task.wait(0.4)
        FireSellPrompts()
        task.wait(0.5)
        sellTriggeredByChat = false
    else
        SetFarmStatus("⚠️ No sell location found...")
        task.wait(3)
    end
end

local farmThread = nil

local function StartFarm()
    if farmThread then return end
    farmThread = task.spawn(function()

        local noclipConn = RunService.Stepped:Connect(function()
            local c = LocalPlayer.Character
            if not c then return end
            for _, p in pairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)

        while Settings.AutoFarm do
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                task.wait(1) continue
            end

            if sellTriggeredByChat or GetInventoryCount() >= Settings.MaxInventory then
                DoSell()
                if not Settings.AutoFarm then break end
                continue
            end

            local items = GetFarmableItems()
            if #items == 0 then
                if GetInventoryCount() > 0 then
                    DoSell()
                    if not Settings.AutoFarm then break end
                else
                    SetFarmStatus("⏳ No items — waiting for respawn...")
                    task.wait(3)
                end
                continue
            end

            table.sort(items, function(a, b)
                local rpa = GetRootPart(a)
                local rpb = GetRootPart(b)
                if not rpa or not rpb then return false end
                return GetDist(rpa.Position) < GetDist(rpb.Position)
            end)

            for _, item in pairs(items) do
                if not Settings.AutoFarm then break end
                if sellTriggeredByChat or GetInventoryCount() >= Settings.MaxInventory then break end

                local rp = GetRootPart(item)
                if not rp or not item.Parent then continue end

                local label = GetItemLabel(item) or item.Name
                local inv = GetInventoryCount()
                SetFarmStatus("📦 " .. label .. " [" .. inv .. "/" .. Settings.MaxInventory .. "]")

                HopTo(rp.Position)
                if not Settings.AutoFarm then break end

                InteractAt(item)
            end

            task.wait(0.3)
        end

        noclipConn:Disconnect()
        local c = LocalPlayer.Character
        if c then
            for _, p in pairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end

        SetFarmStatus("")
        farmThread = nil
    end)
end

local function StopFarm()
    Settings.AutoFarm = false
    if farmThread then
        task.cancel(farmThread)
        farmThread = nil
    end
    local c = LocalPlayer.Character
    if c then
        for _, p in pairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
    SetFarmStatus("")
end
-- ──────────────────────────────────────────────────────────────────────────────

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

CombatTab:CreateSection("Silent Aim (CounterBlox)")
CombatTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Flag = "SilentAim",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.SilentAim = v
    end,
})
CombatTab:CreateToggle({
    Name = "SA: Alive Check",
    CurrentValue = false,
    Flag = "SAAliveCheck",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.SAAliveCheck = v
    end,
})
CombatTab:CreateToggle({
    Name = "SA: Visible Check",
    CurrentValue = false,
    Flag = "SAVisibleCheck",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.SAVisibleCheck = v
    end,
})
CombatTab:CreateToggle({
    Name = "SA: Bullet Teleport",
    CurrentValue = false,
    Flag = "SABulletTP",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.SABulletTP = v
    end,
})
CombatTab:CreateToggle({
    Name = "SA: Show Target Highlight",
    CurrentValue = false,
    Flag = "SAShowTarget",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.SAShowTarget = v
        if not v then
            -- clean up any leftover highlight
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local h = p.Character:FindFirstChild("BabyBoundSATarget")
                    if h then h:Destroy() end
                end
            end
        end
    end,
})


local function GetPlayerNames()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    table.sort(names)
    return names
end

local SAWhitelistDropdown = CombatTab:CreateDropdown({
    Name = "SA Whitelist (ignore = target all)",
    Options = GetPlayerNames(),
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "SAWhitelistDropdown",
    Callback = function(selected)
        PlaySound(Sounds.Click, 0.4, 1)
        Settings.SAWhitelist = {}
        for _, name in pairs(selected) do
            Settings.SAWhitelist[name] = true
        end
    end,
})


Players.PlayerRemoving:Connect(function(p)
    if Settings.SAWhitelist[p.Name] then
        Settings.SAWhitelist[p.Name] = nil
    end
end)

CombatTab:CreateSection("Aimbot FOV")
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
-- ─── AUTOFARM TAB ─────────────────────────────────────────────────────────────
FarmTab:CreateToggle({
    Name = "Auto Farm (Mansion Items)",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.AutoFarm = v
        if v then
            StartFarm()
            Rayfield:Notify({
                Title = "AutoFarm",
                Content = "Farm started! Teleporting to mansion items.",
                Duration = 4,
                Image = 4483362458,
            })
        else
            StopFarm()
            Rayfield:Notify({
                Title = "AutoFarm",
                Content = "Farm stopped.",
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})
FarmTab:CreateSlider({
    Name = "Max Inventory Slots",
    Range = {1, 30},
    Increment = 1,
    Suffix = "slots",
    CurrentValue = 10,
    Flag = "MaxInventory",
    Callback = function(v)
        PlaySound(Sounds.Slider, 0.2, 1)
        Settings.MaxInventory = v
    end,
})
FarmTab:CreateLabel("Tip: Farm teleports to each item in the mansion, picks it up, then goes to sell when inventory is full.")
-- ──────────────────────────────────────────────────────────────────────────────

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

    if isAiming then
        if not ValidateLockedTarget() then LockedTarget = nil end
        if not LockedTarget then LockedTarget = GetClosestTarget() end
        if LockedTarget and LockedTarget.Parent then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, LockedTarget.Position)
        end
    else
        LockedTarget = nil
    end

    
    do
        local saTarget = (Settings.SilentAim and Settings.SAShowTarget) and _saCurrentTarget or nil
        for _, p in pairs(Players:GetPlayers()) do
            if p == LocalPlayer or not p.Character then continue end
            local char = p.Character
            local existing = char:FindFirstChild("BabyBoundSATarget")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if saTarget and hrp and saTarget == hrp then
                
                if not existing then
                    existing = Instance.new("Highlight")
                    existing.Name = "BabyBoundSATarget"
                    existing.FillColor = Color3.fromRGB(255, 30, 30)
                    existing.OutlineColor = Color3.fromRGB(255, 255, 255)
                    existing.FillTransparency = 0.4
                    existing.OutlineTransparency = 0
                    existing.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    existing.Parent = char
                end
            else
                if existing then existing:Destroy() end
            end
        end
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
    Content = "Loaded!",
    Duration = 5,
    Image = 4483362458,
})
PlaySound(Sounds.Notify, 0.6, 1.05)
