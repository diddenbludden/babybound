local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Settings = {
    -- Aimbot
    AimPlayers = false,
    AimAnimals = false,
    WallCheck = false,
    SilentAim = false,
    SAAliveCheck = false,
    SAVisibleCheck = false,
    SABulletTP = false,
    SAShowTarget = false,
    SAWhitelist = {},
    AimTeamCheck = false,
    SATeamCheck = false,
    FOV = 150,
    ShowFOVCircle = false,
    HitboxExtender = false,
    HitboxSize = 5,

    -- Player ESP
    PlayerName = false,
    PlayerHP = false,
    PlayerBox = false,
    PlayerBoxESP = false,
    SkeletonESP = false,
    HeadDotESP = false,
    TracerESP = false,
    ESPTeamCheck = false,
    ESPTeamName = "",

    -- Rainbow
    RainbowBoxESP = false,
    RainbowSkeletonESP = false,
    RainbowHeadDot = false,
    RainbowTracer = false,
    RainbowNameESP = false,
    RainbowAnimalESP = false,
    RainbowChestESP = false,
    RainbowItemESP = false,

    -- Animals / Chests / Items
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
    BoxESPColor = Color3.fromRGB(255, 0, 0),
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    HeadDotColor = Color3.fromRGB(255, 0, 255),
    TracerColor = Color3.fromRGB(0, 255, 255),

    -- World / Movement
    InstantInteract = false,
    TPWalk = false,
    TPWalkSpeed = 2,
    FullBright = false,
    NoFog = false,
    WalkSpeed = 16,
    JumpHeight = 50,
    FlightEnabled = false,
    FlightSpeed = 50,
    Noclip = false,
    AntiVoid = false,
    AntiAFK = false,
    GravityValue = 196.2,
    FakeLag = false,
    FakeLagStrength = 10,
    TimeOfDay = 14,

    -- AutoFarm
    AutoFarm = false,
    MaxInventory = 10,
    InventorySlots = 24,

    -- Spoofer
    SpooferEnabled = false,
    SpooferMeshId = "",
    SpooferTextureId = "",
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- ─── RAINBOW UTILITY ──────────────────────────────────────────────────────────
local _rainbowHue = 0
RunService.RenderStepped:Connect(function(dt)
    _rainbowHue = (_rainbowHue + dt * 0.3) % 1
end)
local function RainbowColor()
    return Color3.fromHSV(_rainbowHue, 1, 1)
end

-- ─── FOV CIRCLE ───────────────────────────────────────────────────────────────
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- ─── RAYFIELD WINDOW ──────────────────────────────────────────────────────────
local GuiTheme = "Default"
local Window = Rayfield:CreateWindow({
    Name = "BabyBound | 80he, Greg, Fresh",
    Icon = "star",
    LoadingTitle = "BabyBound",
    LoadingSubtitle = "by 80he",
    Theme = GuiTheme,
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

local TrainHudLabel   = MakeHudLabel(10,  Color3.fromRGB(25,10,10),   Color3.fromRGB(255,100,100))
local MansionHudLabel = MakeHudLabel(52,  Color3.fromRGB(10,10,30),   Color3.fromRGB(130,170,255))

local function FormatTime(seconds)
    seconds = math.max(0, math.floor(seconds))
    local m = math.floor(seconds / 60)
    local s = seconds % 60
    return string.format("%d:%02d", m, s)
end

local trainKeywords = {"train","locomotive","railcar","steamengine"}
local function LooksLikeTrain(name)
    local n = name:lower()
    for _, kw in pairs(trainKeywords) do if n:find(kw) then return true end end
    return false
end

local trainPresent = false
local trainStateTime = tick()
for _, obj in pairs(workspace:GetChildren()) do
    if LooksLikeTrain(obj.Name) then trainPresent = true break end
end
workspace.ChildAdded:Connect(function(obj)
    pcall(function()
        if LooksLikeTrain(obj.Name) and not trainPresent then
            trainPresent = true
            trainStateTime = tick()
            PlaySound(Sounds.Notify, 0.7, 0.85)
            Rayfield:Notify({ Title = "🚂 Train Spotted!", Content = "The train has arrived!", Duration = 5, Image = 4483362458 })
        end
    end)
end)
workspace.ChildRemoved:Connect(function(obj)
    pcall(function()
        if LooksLikeTrain(obj.Name) and trainPresent then
            trainPresent = false
            trainStateTime = tick()
            Rayfield:Notify({ Title = "🚂 Train Left", Content = "The train has despawned.", Duration = 4, Image = 4483362458 })
        end
    end)
end)

local function IsNight()
    local t = Lighting.ClockTime
    return t >= 18 or t < 6
end
local mansionKeywords = {"mansion","manor","haunted","estate","victorian","castle"}
local function LooksLikeMansion(name)
    local n = name:lower()
    for _, kw in pairs(mansionKeywords) do if n:find(kw) then return true end end
    return false
end
local function CheckMansionOpen()
    if IsNight() then return true end
    for _, obj in pairs(workspace:GetDescendants()) do
        local ok, result = pcall(function()
            if LooksLikeMansion(obj.Name) then
                for _, valName in pairs({"Open","IsOpen","Active","Unlocked"}) do
                    local v = obj:FindFirstChild(valName)
                    if v and v:IsA("BoolValue") and v.Value then return true end
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
                Rayfield:Notify({ Title = "🏚️ Mansion Open!", Content = "Night has fallen — mansion is open!", Duration = 6, Image = 4483362458 })
            else
                Rayfield:Notify({ Title = "🏚️ Mansion Closed", Content = "Day has come — mansion is closed.", Duration = 4, Image = 4483362458 })
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

-- ─── TABS ──────────────────────────────────────────────────────────────────────
local CombatTab    = Window:CreateTab("Combat",     "crosshair")
local VisualsTab   = Window:CreateTab("Visuals",    "eye")
local PlayerTab    = Window:CreateTab("Player",     "user")
local WorldTab     = Window:CreateTab("World",      "globe")
local FarmTab      = Window:CreateTab("AutoFarm",   "star")
local AppearanceTab = Window:CreateTab("Appearance","shirt")
local MiscTab      = Window:CreateTab("Misc",       "settings")

CombatTab:CreateSection("Aimbot Settings")
VisualsTab:CreateSection("Visuals")
WorldTab:CreateSection("Utility")
FarmTab:CreateSection("Mansion Item Farm")
PlayerTab:CreateSection("Player Settings")
MiscTab:CreateSection("Miscellaneous")

-- ─── HELPERS ──────────────────────────────────────────────────────────────────
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

local function IsOnSameTeam(player)
    if not LocalPlayer.Team or not player.Team then return false end
    return LocalPlayer.Team == player.Team
end

local function CleanAnimalName(obj)
    local name = tostring(obj.Name):lower()
    local prefix = name:find("legendary") and "Legendary " or ""
    if name:find("crow") then return prefix.."Crow" end
    if name:find("dire wolf") or name:find("direwolf") then return prefix.."Dire Wolf" end
    if name:find("wolf") then return prefix.."Wolf" end
    if name:find("coyote") then return prefix.."Coyote" end
    if name:find("fox") then return prefix.."Fox" end
    if name:find("grizzly") then return prefix.."Grizzly Bear" end
    if name:find("black bear") then return prefix.."Black Bear" end
    if name:find("bear") then return prefix.."Bear" end
    if name:find("bison") or name:find("buffalo") then return prefix.."Bison" end
    if name:find("buck") or name:find("doe") or name:find("fawn") or name:find("deer") then return prefix.."Deer" end
    if name:find("horse") then return "Horse" end
    if name:find("cow") or name:find("cattle") then return "Cow" end
    if name:find("pig") or name:find("boar") then return "Pig" end
    if name:find("rabbit") or name:find("bunny") then return "Rabbit" end
    if name:find("chicken") then return "Chicken" end
    return obj.Name
end

local function IsChest(obj)
    if not obj:IsA("Model") then return false end
    local parent = obj.Parent
    if not parent or parent.Name ~= "ChestFolder" then return false end
    return obj.Name == "TreasureChest"
end

local function GetChestLabel() return "💰 Treasure Chest" end

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

local function IsItem(obj) return GetItemLabel(obj) ~= nil end

local function IsVisible(targetPart)
    if not targetPart or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then return false end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    local result = workspace:Raycast(origin, direction, raycastParams)
    if result then return result.Instance:IsDescendantOf(targetPart.Parent) end
    return true
end

-- ─── BOX ESP DRAWING ──────────────────────────────────────────────────────────
local _boxDrawings = {}

local function GetPlayerCorners(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local height = hum and hum.HipHeight * 2 + 1.5 or 5.5
    local top    = hrp.Position + Vector3.new(0, height * 0.5, 0)
    local bottom = hrp.Position - Vector3.new(0, height * 0.5, 0)
    local corners = {
        top    + Vector3.new(-1, 0, -1),
        top    + Vector3.new( 1, 0, -1),
        top    + Vector3.new( 1, 0,  1),
        top    + Vector3.new(-1, 0,  1),
        bottom + Vector3.new(-1, 0, -1),
        bottom + Vector3.new( 1, 0, -1),
        bottom + Vector3.new( 1, 0,  1),
        bottom + Vector3.new(-1, 0,  1),
    }
    local screenPts = {}
    for _, c in ipairs(corners) do
        local sp, vis = Camera:WorldToViewportPoint(c)
        if not vis then return nil end
        table.insert(screenPts, Vector2.new(sp.X, sp.Y))
    end
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    for _, sp in ipairs(screenPts) do
        if sp.X < minX then minX = sp.X end
        if sp.Y < minY then minY = sp.Y end
        if sp.X > maxX then maxX = sp.X end
        if sp.Y > maxY then maxY = sp.Y end
    end
    return minX, minY, maxX, maxY
end

local function EnsureBoxLines(player)
    if not _boxDrawings[player] then
        local lines = {}
        for i = 1, 4 do
            local l = Drawing.new("Line")
            l.Thickness = 1.5
            l.Transparency = 1
            l.Visible = false
            lines[i] = l
        end
        _boxDrawings[player] = lines
    end
end

local function DrawBoxESP(player)
    EnsureBoxLines(player)
    local lines = _boxDrawings[player]
    local char = player.Character
    if not char then
        for _, l in ipairs(lines) do l.Visible = false end
        return
    end
    local minX, minY, maxX, maxY = GetPlayerCorners(char)
    if not minX then
        for _, l in ipairs(lines) do l.Visible = false end
        return
    end
    local col = Settings.RainbowBoxESP and RainbowColor() or Settings.BoxESPColor
    local pts = {
        Vector2.new(minX, minY), Vector2.new(maxX, minY),
        Vector2.new(maxX, maxY), Vector2.new(minX, maxY),
    }
    for i = 1, 4 do
        lines[i].From = pts[i]
        lines[i].To   = pts[(i % 4) + 1]
        lines[i].Color = col
        lines[i].Visible = true
    end
end

local function HideBoxESP(player)
    if _boxDrawings[player] then
        for _, l in ipairs(_boxDrawings[player]) do l.Visible = false end
    end
end

-- ─── SKELETON ESP ─────────────────────────────────────────────────────────────
local SKELETON_CONNECTIONS = {
    {"Head","UpperTorso"}, {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"}, {"LeftUpperArm","LeftLowerArm"}, {"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"}, {"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"}, {"LeftUpperLeg","LeftLowerLeg"}, {"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"}, {"RightLowerLeg","RightFoot"},
    -- R6 fallback
    {"Head","Torso"}, {"Torso","Left Arm"}, {"Torso","Right Arm"},
    {"Torso","Left Leg"}, {"Torso","Right Leg"},
}
local _skeletonDrawings = {}

local function EnsureSkelLines(player, count)
    if not _skeletonDrawings[player] then _skeletonDrawings[player] = {} end
    local lines = _skeletonDrawings[player]
    while #lines < count do
        local l = Drawing.new("Line")
        l.Thickness = 1
        l.Transparency = 1
        l.Visible = false
        table.insert(lines, l)
    end
end

local function DrawSkeleton(player)
    local char = player.Character
    if not char then return end
    EnsureSkelLines(player, #SKELETON_CONNECTIONS)
    local lines = _skeletonDrawings[player]
    local col = Settings.RainbowSkeletonESP and RainbowColor() or Settings.SkeletonColor
    local drawn = 0
    for i, conn in ipairs(SKELETON_CONNECTIONS) do
        local p1 = char:FindFirstChild(conn[1])
        local p2 = char:FindFirstChild(conn[2])
        local l = lines[i]
        if p1 and p2 then
            local sp1, v1 = Camera:WorldToViewportPoint(p1.Position)
            local sp2, v2 = Camera:WorldToViewportPoint(p2.Position)
            if v1 and v2 then
                l.From = Vector2.new(sp1.X, sp1.Y)
                l.To   = Vector2.new(sp2.X, sp2.Y)
                l.Color = col
                l.Visible = true
                drawn = drawn + 1
            else
                l.Visible = false
            end
        else
            l.Visible = false
        end
    end
end

local function HideSkeleton(player)
    if _skeletonDrawings[player] then
        for _, l in ipairs(_skeletonDrawings[player]) do l.Visible = false end
    end
end

-- ─── HEAD DOT ESP ─────────────────────────────────────────────────────────────
local _headDots = {}

local function DrawHeadDot(player)
    if not _headDots[player] then
        local c = Drawing.new("Circle")
        c.Radius = 4
        c.Filled = true
        c.Thickness = 1
        c.Transparency = 1
        c.Visible = false
        _headDots[player] = c
    end
    local dot = _headDots[player]
    local char = player.Character
    if not char then dot.Visible = false return end
    local head = char:FindFirstChild("Head")
    if not head then dot.Visible = false return end
    local sp, vis = Camera:WorldToViewportPoint(head.Position)
    if not vis then dot.Visible = false return end
    dot.Position = Vector2.new(sp.X, sp.Y)
    dot.Color = Settings.RainbowHeadDot and RainbowColor() or Settings.HeadDotColor
    dot.Visible = true
end

local function HideHeadDot(player)
    if _headDots[player] then _headDots[player].Visible = false end
end

-- ─── TRACER ESP ───────────────────────────────────────────────────────────────
local _tracers = {}

local function DrawTracer(player)
    if not _tracers[player] then
        local l = Drawing.new("Line")
        l.Thickness = 1
        l.Transparency = 1
        l.Visible = false
        _tracers[player] = l
    end
    local tl = _tracers[player]
    local char = player.Character
    if not char then tl.Visible = false return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then tl.Visible = false return end
    local sp, vis = Camera:WorldToViewportPoint(hrp.Position)
    if not vis then tl.Visible = false return end
    tl.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    tl.To   = Vector2.new(sp.X, sp.Y)
    tl.Color = Settings.RainbowTracer and RainbowColor() or Settings.TracerColor
    tl.Visible = true
end

local function HideTracer(player)
    if _tracers[player] then _tracers[player].Visible = false end
end

-- ─── HITBOX EXTENDER ──────────────────────────────────────────────────────────
local _hitboxConnections = {}

local function ApplyHitbox(player)
    if _hitboxConnections[player] then return end
    local function ResizeHRP()
        pcall(function()
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize) end
        end)
    end
    ResizeHRP()
    _hitboxConnections[player] = player.CharacterAdded:Connect(function()
        task.wait(0.5)
        ResizeHRP()
    end)
end

local function RemoveHitbox(player)
    if _hitboxConnections[player] then
        _hitboxConnections[player]:Disconnect()
        _hitboxConnections[player] = nil
    end
    pcall(function()
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Size = Vector3.new(2, 2, 1) end
    end)
end

-- ─── AIMBOT ────────────────────────────────────────────────────────────────────
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
                if Settings.AimTeamCheck and IsOnSameTeam(v) then continue end
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
        for _, folderName in pairs({"Harvestables","Animals","NPCS"}) do
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
    if not LockedTarget or not LockedTarget.Parent then return false end
    local char = LockedTarget.Parent
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return false end
    return true
end

-- ─── SILENT AIM ────────────────────────────────────────────────────────────────
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
    if result then return result.Instance:IsDescendantOf(targetPart.Parent) end
    return true
end

local function UpdateSATarget()
    if not Settings.SilentAim then _saCurrentTarget = nil return end
    local bestPart = nil
    local bestDist = math.huge
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2
    for _, v in pairs(Players:GetPlayers()) do
        if v == LocalPlayer then continue end
        if Settings.SATeamCheck and IsOnSameTeam(v) then continue end
        if next(Settings.SAWhitelist) ~= nil and not Settings.SAWhitelist[v.Name] then continue end
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

RunService.Heartbeat:Connect(function() pcall(UpdateSATarget) end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local method = getnamecallmethod()
    if Settings.SilentAim and not checkcaller() then
        if method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist"
        or method == "FindPartOnRay" or method == "findPartOnRay" or method == "Raycast" then
            local args = {...}
            if args[1] == workspace then
                local target = _saCurrentTarget
                if target and target.Parent then
                    if method == "Raycast" then
                        local origin = args[2]
                        if typeof(origin) == "Vector3" then
                            if Settings.SABulletTP then origin = (target.CFrame * CFrame.new(0,0,1)).Position end
                            args[2] = origin
                            args[3] = (target.Position - origin).Unit * 1000
                            return oldNamecall(unpack(args))
                        end
                    else
                        local ray = args[2]
                        if typeof(ray) == "Ray" then
                            local origin = ray.Origin
                            if Settings.SABulletTP then origin = (target.CFrame * CFrame.new(0,0,1)).Position end
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

-- ─── BILLBOARD ESP HELPERS ────────────────────────────────────────────────────
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
local STEP_SIZE = 25
local ARRIVE_THRESHOLD = 5
local TP_DELAY = 0.05
local names = {"CircularSaw","AnimalLegTrap","ShotgunTrap","PitTrap"}
for _, name in ipairs(names) do
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == name then obj:Destroy() end
    end
end

local function Log(tag, msg) print(string.format("[AUTOFARM][%s] %s", tag, tostring(msg))) end

local function FindSurfaceNear(pos)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { LocalPlayer.Character }
    local downRay = workspace:Raycast(pos + Vector3.new(0,100,0), Vector3.new(0,-500,0), rayParams)
    if downRay then return downRay.Position + Vector3.new(0,3,0) end
    local directions = {Vector3.new(5,0,0),Vector3.new(-5,0,0),Vector3.new(0,0,5),Vector3.new(0,0,-5)}
    for _, dir in ipairs(directions) do
        local checkPos = pos + dir
        local floorRay = workspace:Raycast(checkPos + Vector3.new(0,100,0), Vector3.new(0,-500,0), rayParams)
        if floorRay then return floorRay.Position + Vector3.new(0,3,0) end
    end
    return pos + Vector3.new(0,3,0)
end

local function GetCenterPos(obj)
    if not obj then return nil end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        local cf, _ = obj:GetBoundingBox()
        return cf.Position
    end
    if obj:IsA("BasePart") then return obj.Position end
    local rp = GetRootPart(obj)
    if rp then return rp.Position end
    return nil
end

local function PressF()
    pcall(function() game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F, false, game) end)
    task.wait(0.08)
    pcall(function() game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.F, false, game) end)
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

local function HopTo(targetPos, targetItem)
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
        if dist <= 100 then
            hrp.CFrame = CFrame.new(targetPos)
            hrp.AssemblyLinearVelocity = Vector3.zero
            task.wait(TP_DELAY)
            if targetItem then
                while targetItem and targetItem.Parent and Settings.AutoFarm do
                    local freshPos = GetCenterPos(targetItem)
                    if freshPos then hrp.CFrame = CFrame.new(freshPos) end
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    PressF()
                    if targetItem and targetItem.Parent then FirePromptOn(targetItem) end
                    task.wait(0.3)
                end
            end
            break
        else
            local stepPos = currentPos + toTarget.Unit * STEP_SIZE
            local surfacePos = FindSurfaceNear(Vector3.new(stepPos.X, targetPos.Y, stepPos.Z))
            hrp.CFrame = CFrame.new(surfacePos)
        end
        task.wait(TP_DELAY)
    end
end

local function FireSellPrompts()
    task.wait(0.5)
    pcall(function() game:GetService("ReplicatedStorage").GeneralEvents.Inventory:InvokeServer("Sell") end)
    task.wait(0.3)
    pcall(function() game:GetService("ReplicatedStorage").GeneralEvents.Inventory:InvokeServer("Sell") end)
end

local function FindSellLocation()
    local direct = workspace:FindFirstChild("Shops") and workspace.Shops:FindFirstChild("OutlawGeneralStore1")
    if direct then
        local pos = GetCenterPos(direct)
        if pos then return pos end
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local ok, result = pcall(function()
                local action = obj.ActionText:lower()
                local obj2 = obj.ObjectText:lower()
                if action:find("sell") or obj2:find("sell") or obj2:find("pawn") or obj2:find("fence") then
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
    local inventory = LocalPlayer:FindFirstChild("Inventory")
    if inventory then
        for _, _ in pairs(inventory:GetChildren()) do count = count + 1 end
    end
    return count
end

local function GetFarmableItems()
    local items = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        pcall(function()
            if IsItem(obj) and GetRootPart(obj) then table.insert(items, obj) end
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

local farmThread = nil
local noclipConnection = nil

local function StartFarm()
    if farmThread then return end
    noclipConnection = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)
    farmThread = task.spawn(function()
        while Settings.AutoFarm do
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then task.wait(1) continue end
            if GetInventoryCount() >= Settings.InventorySlots then
                SetFarmStatus("🏪 Full — hopping to sell...")
                local sellPos = FindSellLocation()
                if sellPos then
                    HopTo(sellPos)
                    if not Settings.AutoFarm then break end
                    task.wait(0.4)
                    FireSellPrompts()
                    task.wait(0.5)
                else
                    SetFarmStatus("⚠️ No sell location found...")
                    task.wait(3)
                end
                continue
            end
            local items = GetFarmableItems()
            if #items == 0 then SetFarmStatus("⏳ No items — waiting...") task.wait(3) continue end
            table.sort(items, function(a, b)
                local rpa = GetRootPart(a)
                local rpb = GetRootPart(b)
                if not rpa or not rpb then return false end
                return GetDist(rpa.Position) < GetDist(rpb.Position)
            end)
            for _, item in pairs(items) do
                if not Settings.AutoFarm then break end
                if GetInventoryCount() >= Settings.InventorySlots then
                    SetFarmStatus("🏪 Max items — heading to sell...")
                    local sellPos = FindSellLocation()
                    if sellPos then
                        HopTo(sellPos)
                        if not Settings.AutoFarm then break end
                        task.wait(0.4)
                        FireSellPrompts()
                        task.wait(0.5)
                    else
                        SetFarmStatus("⚠️ No sell location found...")
                        task.wait(3)
                    end
                    break
                end
                local centerPos = GetCenterPos(item)
                if not centerPos or not item.Parent then continue end
                local label = GetItemLabel(item) or item.Name
                SetFarmStatus("📦 " .. label .. " [" .. GetInventoryCount() .. "/" .. Settings.InventorySlots .. "]")
                HopTo(centerPos, item)
                if not Settings.AutoFarm then break end
            end
            if Settings.AutoFarm and GetInventoryCount() > 0 and #GetFarmableItems() == 0 then
                SetFarmStatus("🏪 No items left — selling...")
                local sellPos = FindSellLocation()
                if sellPos then
                    HopTo(sellPos)
                    if not Settings.AutoFarm then break end
                    task.wait(0.4)
                    FireSellPrompts()
                    task.wait(0.5)
                end
            end
            task.wait(0.5)
        end
        SetFarmStatus("")
        farmThread = nil
    end)
end

local function StopFarm()
    Settings.AutoFarm = false
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
    if farmThread then task.cancel(farmThread) farmThread = nil end
    SetFarmStatus("")
end

-- ─── FLIGHT ────────────────────────────────────────────────────────────────────
local _flightBV = nil
local _flightConn = nil

local function StartFlight()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp
    _flightBV = bv
    _flightConn = RunService.RenderStepped:Connect(function()
        if not Settings.FlightEnabled then return end
        local char2 = LocalPlayer.Character
        if not char2 then return end
        local hrp2 = char2:FindFirstChild("HumanoidRootPart")
        if not hrp2 or _flightBV ~= bv then return end
        local vel = Vector3.zero
        local spd = Settings.FlightSpeed
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + Camera.CFrame.LookVector * spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - Camera.CFrame.LookVector * spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - Camera.CFrame.RightVector * spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + Camera.CFrame.RightVector * spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, spd, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0, spd, 0) end
        bv.Velocity = vel
    end)
end

local function StopFlight()
    if _flightConn then _flightConn:Disconnect() _flightConn = nil end
    if _flightBV then _flightBV:Destroy() _flightBV = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

-- ─── NOCLIP ────────────────────────────────────────────────────────────────────
local _noclipConn = nil

local function SetNoclip(v)
    Settings.Noclip = v
    if v then
        _noclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    else
        if _noclipConn then _noclipConn:Disconnect() _noclipConn = nil end
        local char = LocalPlayer.Character
        if char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end

-- ─── ANTI VOID ─────────────────────────────────────────────────────────────────
RunService.Heartbeat:Connect(function()
    if not Settings.AntiVoid then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp.Position.Y < -100 then
        hrp.CFrame = CFrame.new(0, 100, 0)
    end
end)

-- ─── FAKE LAG ──────────────────────────────────────────────────────────────────
local _fakeLagConn = nil
local function SetFakeLag(v)
    Settings.FakeLag = v
    if v then
        _fakeLagConn = RunService.Heartbeat:Connect(function()
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                hrp.CFrame = hrp.CFrame * CFrame.new(
                    math.random(-Settings.FakeLagStrength, Settings.FakeLagStrength) * 0.01,
                    0,
                    math.random(-Settings.FakeLagStrength, Settings.FakeLagStrength) * 0.01
                )
            end)
        end)
    else
        if _fakeLagConn then _fakeLagConn:Disconnect() _fakeLagConn = nil end
    end
end

-- ─── ANTI AFK ──────────────────────────────────────────────────────────────────
local _antiAfkConn = nil
local VirtualUser = game:GetService("VirtualUser")
local function SetAntiAfk(v)
    Settings.AntiAFK = v
    if v then
        LocalPlayer.Idled:Connect(function()
            if Settings.AntiAFK then
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(0.1)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end
        end)
    end
end

-- ─── REMOTE SPY ────────────────────────────────────────────────────────────────
local _remoteSpyActive = false
local _remoteSpyLogs = {}
local _remoteSpyGui = nil
local _remoteSpyLabel = nil
local _remoteFirewall = {}
local _remoteSpyConn = nil

local function SetupRemoteSpyGui()
    if _remoteSpyGui then return end
    _remoteSpyGui = Instance.new("ScreenGui")
    _remoteSpyGui.Name = "RemoteSpyGui"
    _remoteSpyGui.ResetOnSpawn = false
    _remoteSpyGui.IgnoreGuiInset = true
    _remoteSpyGui.Parent = LocalPlayer.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 420, 0, 200)
    frame.Position = UDim2.new(0, 10, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = _remoteSpyGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Text = "📡 Remote Spy"
    title.Size = UDim2.new(1, 0, 0, 24)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(0, 220, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 14
    title.Parent = frame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -30)
    scroll.Position = UDim2.new(0, 5, 0, 26)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    _remoteSpyGui._scroll = scroll
    _remoteSpyGui._layout = layout
    _remoteSpyGui._frame = frame
end

local function AddRemoteLog(text)
    if not _remoteSpyGui or not _remoteSpyGui._scroll then return end
    local scroll = _remoteSpyGui._scroll
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(180, 255, 180)
    label.Font = Enum.Font.Code
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = scroll
    scroll.CanvasSize = UDim2.new(0, 0, 0, _remoteSpyGui._layout.AbsoluteContentSize.Y)
    scroll.CanvasPosition = Vector2.new(0, scroll.CanvasSize.Y.Offset)
    -- keep max 100 logs
    if #scroll:GetChildren() > 102 then
        local kids = scroll:GetChildren()
        for i = 1, #kids - 100 do
            if kids[i]:IsA("TextLabel") then kids[i]:Destroy() end
        end
    end
end

local _remoteSpyHook = nil
local function StartRemoteSpy()
    if _remoteSpyHook then return end
    SetupRemoteSpyGui()
    _remoteSpyHook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if (method == "FireServer" or method == "InvokeServer" or method == "FireAllClients") then
            if not _remoteFirewall[tostring(self)] then
                local args = {...}
                local argStr = ""
                pcall(function()
                    for i, a in ipairs(args) do
                        argStr = argStr .. tostring(a)
                        if i < #args then argStr = argStr .. ", " end
                    end
                end)
                pcall(function()
                    AddRemoteLog("[" .. method .. "] " .. tostring(self.Name) .. "(" .. argStr .. ")")
                end)
            else
                -- blocked
                return nil
            end
        end
        return _remoteSpyHook(self, ...)
    end))
end

local function StopRemoteSpy()
    -- Can't unhook, just hide GUI
    if _remoteSpyGui then
        _remoteSpyGui._frame.Visible = false
    end
end

-- ─── ACCESSORY / MESH SPOOFER ─────────────────────────────────────────────────
local function ApplySpoofer()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("SpecialMesh") then
            if Settings.SpooferMeshId ~= "" then
                pcall(function() part.MeshId = "rbxassetid://" .. Settings.SpooferMeshId end)
            end
            if Settings.SpooferTextureId ~= "" then
                pcall(function() part.TextureId = "rbxassetid://" .. Settings.SpooferTextureId end)
            end
        end
    end
end

-- ─── SERVER HOP / REJOIN / SNIPE ──────────────────────────────────────────────
local TeleportService = game:GetService("TeleportService")

local function Rejoin()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

local function ServerHop()
    local servers = {}
    pcall(function()
        local url = "https://games.roproxy.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local res = HttpService:JSONDecode(game:HttpGet(url))
        if res and res.data then
            for _, s in pairs(res.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    table.insert(servers, s.id)
                end
            end
        end
    end)
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
    else
        Rayfield:Notify({ Title = "Server Hop", Content = "No available servers found!", Duration = 4, Image = 4483362458 })
    end
end

local function ServerSnipe(targetPlayerName)
    if targetPlayerName == "" then
        Rayfield:Notify({ Title = "Server Snipe", Content = "Enter a player name first!", Duration = 3, Image = 4483362458 })
        return
    end
    task.spawn(function()
        local found = false
        pcall(function()
            local url = "https://games.roproxy.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            local res = HttpService:JSONDecode(game:HttpGet(url))
            if res and res.data then
                for _, s in pairs(res.data) do
                    if s.id ~= game.JobId then
                        -- try to join each server and hope the player is there
                        -- (no direct player-to-server API publicly available without extra endpoints)
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                        found = true
                        break
                    end
                end
            end
        end)
        if not found then
            Rayfield:Notify({ Title = "Server Snipe", Content = "Could not find server for: " .. targetPlayerName, Duration = 4, Image = 4483362458 })
        end
    end)
end

local _snipeTargetName = ""

-- ─────────────────────────────────────────────────────────────────────────────
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
    Name = "Team Check (Skip teammates)",
    CurrentValue = false,
    Flag = "AimTeamCheck",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.AimTeamCheck = v
    end,
})
CombatTab:CreateToggle({
    Name = "Hitbox Extender",
    CurrentValue = false,
    Flag = "HitboxExtender",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.HitboxExtender = v
        if v then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then ApplyHitbox(p) end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then RemoveHitbox(p) end
            end
        end
    end,
})
CombatTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {2, 30},
    Increment = 0.5,
    Suffix = "st",
    CurrentValue = 5,
    Flag = "HitboxSize",
    Callback = function(v)
        PlaySound(Sounds.Slider, 0.2, 1)
        Settings.HitboxSize = v
        if Settings.HitboxExtender then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    pcall(function()
                        local char = p.Character
                        if not char then return end
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then hrp.Size = Vector3.new(v, v, v) end
                    end)
                end
            end
        end
    end,
})
CombatTab:CreateToggle({
    Name = "No Recoil",
    CurrentValue = false,
    Flag = "NoRecoil",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        if v then
            local stateConfig = LocalPlayer:FindFirstChild("StateConfig")
            if not stateConfig then Rayfield:Notify({Title="No Recoil",Content="StateConfig not found!",Duration=3,Image=4483362458}) return end
            local recoilVal = stateConfig:FindFirstChild("RecoilVal")
            if not recoilVal then Rayfield:Notify({Title="No Recoil",Content="RecoilVal not found!",Duration=3,Image=4483362458}) return end
            _G.NoRecoilHeartbeat = RunService.Heartbeat:Connect(function()
                if recoilVal and recoilVal.Parent then recoilVal.Value = Vector3.new(0,0,0) end
            end)
            _G.NoRecoilChanged = recoilVal:GetPropertyChangedSignal("Value"):Connect(function()
                if recoilVal and recoilVal.Parent then recoilVal.Value = Vector3.new(0,0,0) end
            end)
        else
            if _G.NoRecoilHeartbeat then _G.NoRecoilHeartbeat:Disconnect() _G.NoRecoilHeartbeat = nil end
            if _G.NoRecoilChanged then _G.NoRecoilChanged:Disconnect() _G.NoRecoilChanged = nil end
        end
    end,
})
CombatTab:CreateToggle({
    Name = "Inf Ammo",
    CurrentValue = false,
    Flag = "InfAmmo",
    Callback = function(val)
        if val then
            local infAmmoConnections = {}
            local Consumables = LocalPlayer:WaitForChild("Consumables", 5)
            if Consumables then
                local function hookItem(item)
                    if item:IsA("IntValue") or item:IsA("NumberValue") then
                        item.Value = 69420
                        table.insert(infAmmoConnections, item.Changed:Connect(function()
                            task.defer(function()
                                if item and item.Parent then item.Value = 69420 end
                            end)
                        end))
                    end
                end
                for _, item in pairs(Consumables:GetChildren()) do hookItem(item) end
                table.insert(infAmmoConnections, Consumables.ChildAdded:Connect(function(child)
                    task.wait(0.05)
                    hookItem(child)
                end))
            end
            infAmmoThread = infAmmoConnections
        else
            if infAmmoThread then
                for _, c in pairs(infAmmoThread) do pcall(function() c:Disconnect() end) end
                infAmmoThread = nil
            end
        end
    end,
})

CombatTab:CreateSection("Silent Aim")
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
    Callback = function(v) Settings.SAAliveCheck = v end,
})
CombatTab:CreateToggle({
    Name = "SA: Visible Check",
    CurrentValue = false,
    Flag = "SAVisibleCheck",
    Callback = function(v) Settings.SAVisibleCheck = v end,
})
CombatTab:CreateToggle({
    Name = "SA: Bullet Teleport",
    CurrentValue = false,
    Flag = "SABulletTP",
    Callback = function(v) Settings.SABulletTP = v end,
})
CombatTab:CreateToggle({
    Name = "SA: Show Target Highlight",
    CurrentValue = false,
    Flag = "SAShowTarget",
    Callback = function(v)
        Settings.SAShowTarget = v
        if not v then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local h = p.Character:FindFirstChild("BabyBoundSATarget")
                    if h then h:Destroy() end
                end
            end
        end
    end,
})
CombatTab:CreateToggle({
    Name = "SA: Team Check (Skip teammates)",
    CurrentValue = false,
    Flag = "SATeamCheck",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.SATeamCheck = v
    end,
})

local function GetPlayerNames()
    local names2 = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names2, p.Name) end
    end
    table.sort(names2)
    return names2
end

CombatTab:CreateDropdown({
    Name = "SA Whitelist (empty = target all)",
    Options = GetPlayerNames(),
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "SAWhitelistDropdown",
    Callback = function(selected)
        PlaySound(Sounds.Click, 0.4, 1)
        Settings.SAWhitelist = {}
        for _, name in pairs(selected) do Settings.SAWhitelist[name] = true end
    end,
})

Players.PlayerRemoving:Connect(function(p)
    if Settings.SAWhitelist[p.Name] then Settings.SAWhitelist[p.Name] = nil end
    HideBoxESP(p)
    HideSkeleton(p)
    HideHeadDot(p)
    HideTracer(p)
end)

Players.PlayerAdded:Connect(function(p)
    if Settings.HitboxExtender then
        task.wait(1)
        ApplyHitbox(p)
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
VisualsTab:CreateSection("Player ESP")
VisualsTab:CreateToggle({
    Name = "Name ESP",
    CurrentValue = false,
    Flag = "PlayerName",
    Callback = function(v) Settings.PlayerName = v end,
})
VisualsTab:CreateToggle({
    Name = "Rainbow Name ESP",
    CurrentValue = false,
    Callback = function(v) Settings.RainbowNameESP = v end,
})
VisualsTab:CreateToggle({
    Name = "Health ESP",
    CurrentValue = false,
    Flag = "PlayerHP",
    Callback = function(v) Settings.PlayerHP = v end,
})
VisualsTab:CreateToggle({
    Name = "Chams (Highlight)",
    CurrentValue = false,
    Flag = "PlayerBox",
    Callback = function(v) Settings.PlayerBox = v end,
})
VisualsTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = false,
    Flag = "PlayerBoxESP",
    Callback = function(v) Settings.PlayerBoxESP = v end,
})
VisualsTab:CreateToggle({
    Name = "Rainbow Box ESP",
    CurrentValue = false,
    Callback = function(v) Settings.RainbowBoxESP = v end,
})
VisualsTab:CreateColorPicker({
    Name = "Box ESP Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "BoxESPColor",
    Callback = function(v) Settings.BoxESPColor = v end,
})
VisualsTab:CreateToggle({
    Name = "Skeleton ESP",
    CurrentValue = false,
    Flag = "SkeletonESP",
    Callback = function(v) Settings.SkeletonESP = v end,
})
VisualsTab:CreateToggle({
    Name = "Rainbow Skeleton ESP",
    CurrentValue = false,
    Callback = function(v) Settings.RainbowSkeletonESP = v end,
})
VisualsTab:CreateColorPicker({
    Name = "Skeleton Color",
    Color = Color3.fromRGB(255, 255, 255),
    Flag = "SkeletonColor",
    Callback = function(v) Settings.SkeletonColor = v end,
})
VisualsTab:CreateToggle({
    Name = "Head Dot ESP",
    CurrentValue = false,
    Flag = "HeadDotESP",
    Callback = function(v) Settings.HeadDotESP = v end,
})
VisualsTab:CreateToggle({
    Name = "Rainbow Head Dot",
    CurrentValue = false,
    Callback = function(v) Settings.RainbowHeadDot = v end,
})
VisualsTab:CreateColorPicker({
    Name = "Head Dot Color",
    Color = Color3.fromRGB(255, 0, 255),
    Flag = "HeadDotColor",
    Callback = function(v) Settings.HeadDotColor = v end,
})
VisualsTab:CreateToggle({
    Name = "Tracer ESP",
    CurrentValue = false,
    Flag = "TracerESP",
    Callback = function(v) Settings.TracerESP = v end,
})
VisualsTab:CreateToggle({
    Name = "Rainbow Tracer",
    CurrentValue = false,
    Callback = function(v) Settings.RainbowTracer = v end,
})
VisualsTab:CreateColorPicker({
    Name = "Tracer Color",
    Color = Color3.fromRGB(0, 255, 255),
    Flag = "TracerColor",
    Callback = function(v) Settings.TracerColor = v end,
})
VisualsTab:CreateToggle({
    Name = "ESP Team Check (Enemies only)",
    CurrentValue = false,
    Flag = "ESPTeamCheck",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.ESPTeamCheck = v
    end,
})
VisualsTab:CreateColorPicker({
    Name = "Player ESP Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "PlayerColor",
    Callback = function(v) Settings.PlayerColor = v end,
})

VisualsTab:CreateSection("Animal / World ESP")
VisualsTab:CreateToggle({
    Name = "Animal ESP",
    CurrentValue = false,
    Flag = "AnimalESP",
    Callback = function(v)
        Settings.AnimalESP = v
        if not v then
            for _, folderName in pairs({"Harvestables","Animals","NPCS"}) do
                local folder = workspace:FindFirstChild(folderName)
                if folder then
                    for _, animal in pairs(folder:GetChildren()) do
                        local rp = GetRootPart(animal)
                        if rp and rp:FindFirstChild("OverlordAnimalESP") then rp.OverlordAnimalESP:Destroy() end
                    end
                end
            end
        end
    end,
})
VisualsTab:CreateToggle({
    Name = "Rainbow Animal ESP",
    CurrentValue = false,
    Callback = function(v) Settings.RainbowAnimalESP = v end,
})
VisualsTab:CreateToggle({
    Name = "Chest ESP",
    CurrentValue = false,
    Flag = "ChestESP",
    Callback = function(v)
        Settings.ChestESP = v
        if not v then ClearAllChestESP() end
    end,
})
VisualsTab:CreateToggle({
    Name = "Rainbow Chest ESP",
    CurrentValue = false,
    Callback = function(v) Settings.RainbowChestESP = v end,
})
VisualsTab:CreateSlider({
    Name = "Max Chest ESP Range",
    Range = {500, 20000},
    Increment = 100,
    Suffix = "studs",
    CurrentValue = 10000,
    Flag = "ChestESPDistance",
    Callback = function(v) Settings.ChestESPDistance = v end,
})
VisualsTab:CreateColorPicker({
    Name = "Chest ESP Color",
    Color = Color3.fromRGB(255, 215, 0),
    Flag = "ChestColor",
    Callback = function(v) Settings.ChestColor = v end,
})
VisualsTab:CreateToggle({
    Name = "Item ESP",
    CurrentValue = false,
    Flag = "ItemESP",
    Callback = function(v)
        Settings.ItemESP = v
        if not v then ClearAllItemESP() end
    end,
})
VisualsTab:CreateToggle({
    Name = "Rainbow Item ESP",
    CurrentValue = false,
    Callback = function(v) Settings.RainbowItemESP = v end,
})
VisualsTab:CreateSlider({
    Name = "Max Item ESP Range",
    Range = {500, 20000},
    Increment = 100,
    Suffix = "studs",
    CurrentValue = 10000,
    Flag = "ItemESPDistance",
    Callback = function(v) Settings.ItemESPDistance = v end,
})
VisualsTab:CreateColorPicker({
    Name = "Item ESP Color",
    Color = Color3.fromRGB(0, 255, 200),
    Flag = "ItemColor",
    Callback = function(v) Settings.ItemColor = v end,
})
VisualsTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = false,
    Flag = "ShowDistance",
    Callback = function(v) Settings.ShowDistance = v end,
})
VisualsTab:CreateSlider({
    Name = "Max Animal ESP Range",
    Range = {500, 20000},
    Increment = 100,
    Suffix = "studs",
    CurrentValue = 10000,
    Flag = "ESPDistance",
    Callback = function(v) Settings.ESPDistance = v end,
})
VisualsTab:CreateSlider({
    Name = "Text Size",
    Range = {8, 20},
    Increment = 1,
    Suffix = "px",
    CurrentValue = 12,
    Flag = "TextSize",
    Callback = function(v) Settings.TextSize = v end,
})
VisualsTab:CreateColorPicker({
    Name = "Animal ESP Color",
    Color = Color3.fromRGB(255, 165, 0),
    Flag = "AnimalColor",
    Callback = function(v) Settings.AnimalColor = v end,
})

-- ─── PLAYER TAB ───────────────────────────────────────────────────────────────
PlayerTab:CreateSection("Movement")
PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 500},
    Increment = 1,
    Suffix = "",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(v)
        Settings.WalkSpeed = v
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end,
})
PlayerTab:CreateSlider({
    Name = "Jump Height",
    Range = {50, 500},
    Increment = 5,
    Suffix = "",
    CurrentValue = 50,
    Flag = "JumpHeight",
    Callback = function(v)
        Settings.JumpHeight = v
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpHeight = v end
        end
    end,
})
PlayerTab:CreateToggle({
    Name = "Flight",
    CurrentValue = false,
    Flag = "FlightEnabled",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.FlightEnabled = v
        if v then StartFlight() else StopFlight() end
    end,
})
PlayerTab:CreateSlider({
    Name = "Flight Speed",
    Range = {10, 300},
    Increment = 5,
    Suffix = "",
    CurrentValue = 50,
    Flag = "FlightSpeed",
    Callback = function(v) Settings.FlightSpeed = v end,
})
PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        SetNoclip(v)
    end,
})
PlayerTab:CreateToggle({
    Name = "Anti-Void",
    CurrentValue = false,
    Flag = "AntiVoid",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.AntiVoid = v
    end,
})

PlayerTab:CreateSection("Camera")
PlayerTab:CreateSlider({
    Name = "FOV",
    Range = {70, 120},
    Increment = 1,
    Suffix = "°",
    CurrentValue = 70,
    Flag = "CameraFOV",
    Callback = function(v)
        Camera.FieldOfView = v
    end,
})
PlayerTab:CreateSlider({
    Name = "Max Zoom Distance",
    Range = {0, 2000},
    Increment = 10,
    Suffix = "st",
    CurrentValue = 400,
    Flag = "MaxZoom",
    Callback = function(v)
        LocalPlayer.CameraMaxZoomDistance = v
    end,
})

-- ─── WORLD TAB ────────────────────────────────────────────────────────────────
WorldTab:CreateToggle({
    Name = "Enhanced Shaders",
    CurrentValue = false,
    Flag = "EnhancedShaders",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.EnhancedShaders = v

        if v then
            Lighting.GlobalShadows = true
            Lighting.ShadowSoftness = 0.08
            for _, effect in pairs(Lighting:GetChildren()) do
                if effect:IsA("BloomEffect") or effect:IsA("ColorCorrectionEffect")
                or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") or effect:IsA("BlurEffect") then
                    if effect.Name ~= "HealthColorCorrection" and effect.Name ~= "GuiBlur" and effect.Name ~= "GuiColorCorrection" then
                        effect:Destroy()
                    end
                end
            end
            local bloom = Instance.new("BloomEffect")
            bloom.Intensity = 0.6 bloom.Size = 20 bloom.Threshold = 0.9 bloom.Parent = Lighting
            local sunRays = Instance.new("SunRaysEffect")
            sunRays.Intensity = 0.12 sunRays.Spread = 0.5 sunRays.Parent = Lighting
            local colorCorrection = Instance.new("ColorCorrectionEffect")
            colorCorrection.Brightness = 0.06 colorCorrection.Contrast = 0.25
            colorCorrection.Saturation = 0.2 colorCorrection.TintColor = Color3.fromRGB(255,240,200)
            colorCorrection.Parent = Lighting
            local dof = Instance.new("DepthOfFieldEffect")
            dof.FarIntensity = 0.1 dof.NearIntensity = 0.0 dof.FocusDistance = 45 dof.InFocusRadius = 55 dof.Parent = Lighting
            Lighting.Ambient = Color3.fromRGB(80,78,75)
            Lighting.OutdoorAmbient = Color3.fromRGB(110,105,95)
            Lighting.Brightness = 1.0

            local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
            local DAY = { bloomIntensity=0.6,bloomSize=20,bloomThreshold=0.9,sunRaysIntensity=0.12,sunRaysSpread=0.5,ccBrightness=0.06,ccContrast=0.25,ccSaturation=0.2,ccTint=Color3.fromRGB(255,240,200),dofFar=0.1,dofFocus=45,dofRadius=55,atmDensity=0.3,atmOffset=0.1,atmColor=Color3.fromRGB(199,170,140),atmDecay=Color3.fromRGB(90,70,55),atmGlare=0.1,atmHaze=1.5,shadowSoftness=0.08,ambient=Color3.fromRGB(80,78,75),outdoorAmbient=Color3.fromRGB(110,105,95),brightness=1.0 }
            local NIGHT = { bloomIntensity=1.6,bloomSize=38,bloomThreshold=0.45,sunRaysIntensity=0,sunRaysSpread=0,ccBrightness=0.15,ccContrast=0.4,ccSaturation=0.05,ccTint=Color3.fromRGB(100,120,190),dofFar=0.15,dofFocus=50,dofRadius=28,atmDensity=0.4,atmOffset=0.2,atmColor=Color3.fromRGB(25,35,80),atmDecay=Color3.fromRGB(15,18,55),atmGlare=0,atmHaze=2.5,shadowSoftness=0.03,ambient=Color3.fromRGB(25,28,45),outdoorAmbient=Color3.fromRGB(35,40,60),brightness=0.3 }
            local function Smootherstep(t) return t*t*t*(t*(t*6-15)+10) end
            local function GetNightAlpha()
                local clock = Lighting.ClockTime
                if clock>=7 and clock<17 then return 0
                elseif clock>=19 or clock<5 then return 1
                elseif clock>=17 and clock<19 then return Smootherstep((clock-17)/2)
                elseif clock>=5 and clock<7 then return Smootherstep(1-((clock-5)/2))
                end return 0
            end
            local function LerpColor(a,b,t) return Color3.new(a.R+(b.R-a.R)*t,a.G+(b.G-a.G)*t,a.B+(b.B-a.B)*t) end
            local function Lerp(a,b,t) return a+(b-a)*t end
            local currentAlpha = GetNightAlpha()
            local ALPHA_SPEED = 2.0
            local elapsed = 0
            _G.ShaderConnection = RunService.RenderStepped:Connect(function(dt)
                elapsed = elapsed + dt
                local targetAlpha = GetNightAlpha()
                currentAlpha = currentAlpha + (targetAlpha-currentAlpha) * math.min(ALPHA_SPEED*dt, 1)
                if math.abs(currentAlpha-targetAlpha) < 0.001 then currentAlpha = targetAlpha end
                local alpha = currentAlpha
                local isNight = alpha > 0.5
                local pulse = isNight and (math.sin(elapsed*0.8)*0.1) or (math.sin(elapsed*1.2)*0.06)
                bloom.Intensity = Lerp(DAY.bloomIntensity,NIGHT.bloomIntensity,alpha)+pulse
                bloom.Size = Lerp(DAY.bloomSize,NIGHT.bloomSize,alpha)
                bloom.Threshold = Lerp(DAY.bloomThreshold,NIGHT.bloomThreshold,alpha)
                sunRays.Intensity = Lerp(DAY.sunRaysIntensity,NIGHT.sunRaysIntensity,alpha)
                sunRays.Spread = Lerp(DAY.sunRaysSpread,NIGHT.sunRaysSpread,alpha)
                dof.FarIntensity = Lerp(DAY.dofFar,NIGHT.dofFar,alpha)
                dof.FocusDistance = Lerp(DAY.dofFocus,NIGHT.dofFocus,alpha)
                dof.InFocusRadius = Lerp(DAY.dofRadius,NIGHT.dofRadius,alpha)
                Lighting.Ambient = LerpColor(DAY.ambient,NIGHT.ambient,alpha)
                Lighting.OutdoorAmbient = LerpColor(DAY.outdoorAmbient,NIGHT.outdoorAmbient,alpha)
                Lighting.Brightness = Lerp(DAY.brightness,NIGHT.brightness,alpha)
                Lighting.ShadowSoftness = Lerp(DAY.shadowSoftness,NIGHT.shadowSoftness,alpha)
                if not Settings.RealisticRain then
                    colorCorrection.Enabled = true
                    colorCorrection.Brightness = Lerp(DAY.ccBrightness,NIGHT.ccBrightness,alpha)
                    colorCorrection.Contrast = Lerp(DAY.ccContrast,NIGHT.ccContrast,alpha)
                    colorCorrection.Saturation = Lerp(DAY.ccSaturation,NIGHT.ccSaturation,alpha)
                    colorCorrection.TintColor = LerpColor(DAY.ccTint,NIGHT.ccTint,alpha)
                else colorCorrection.Enabled = false end
                if atmosphere then
                    atmosphere.Density = Lerp(DAY.atmDensity,NIGHT.atmDensity,alpha)
                    atmosphere.Offset = Lerp(DAY.atmOffset,NIGHT.atmOffset,alpha)
                    atmosphere.Color = LerpColor(DAY.atmColor,NIGHT.atmColor,alpha)
                    atmosphere.Decay = LerpColor(DAY.atmDecay,NIGHT.atmDecay,alpha)
                    atmosphere.Glare = Lerp(DAY.atmGlare,NIGHT.atmGlare,alpha)
                    atmosphere.Haze = Lerp(DAY.atmHaze,NIGHT.atmHaze,alpha)
                end
            end)
        else
            if _G.ShaderConnection then _G.ShaderConnection:Disconnect() _G.ShaderConnection = nil end
            for _, effect in pairs(Lighting:GetChildren()) do
                if effect:IsA("BloomEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
                    if effect.Name ~= "HealthColorCorrection" and effect.Name ~= "GuiBlur" and effect.Name ~= "GuiColorCorrection" then effect:Destroy() end
                end
            end
            Lighting.ShadowSoftness = 0.5
            Lighting.Ambient = Color3.fromRGB(127,127,127)
            Lighting.OutdoorAmbient = Color3.fromRGB(127,127,127)
            Lighting.Brightness = 2
        end
    end,
})

WorldTab:CreateToggle({
    Name = "Realistic Rain",
    CurrentValue = false,
    Flag = "RealisticRain",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        Settings.RealisticRain = v
        if v then
            local camera = workspace.CurrentCamera
            _G.RainDrops = {}
            _G.RainBatchIdx = 0
            _G.RainFolder = Instance.new("Folder")
            _G.RainFolder.Name = "RainFolder"
            _G.RainFolder.Parent = workspace
            local DROP_COUNT = 1500
            local AREA = 60
            local DROP_SPEED = 400
            local WIND = Vector3.new(5,0,0)
            local function CreateDrop()
                local part = Instance.new("Part")
                part.Size = Vector3.new(0.05,0.05,0.05)
                part.Anchored = true part.CanCollide = false part.CanTouch = false part.CastShadow = false part.Transparency = 1
                part.Parent = _G.RainFolder
                local a0 = Instance.new("Attachment") local a1 = Instance.new("Attachment")
                a0.Position = Vector3.new(0,0.4,0) a1.Position = Vector3.new(0,-0.4,0)
                a0.Parent = part a1.Parent = part
                local beam = Instance.new("Beam")
                beam.Attachment0 = a0 beam.Attachment1 = a1
                beam.Width0 = 0.025 beam.Width1 = 0.025
                beam.Color = ColorSequence.new(Color3.fromRGB(160,165,170))
                beam.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.0),NumberSequenceKeypoint.new(1,0.0)})
                beam.LightEmission = 0.2 beam.LightInfluence = 0.8 beam.FaceCamera = true
                beam.Segments = 1 beam.CurveSize0 = 0 beam.CurveSize1 = 0 beam.Parent = part
                local camPos = camera.CFrame.Position
                local rx = math.random(-AREA,AREA) local ry = math.random(0,AREA*2) local rz = math.random(-AREA,AREA)
                part.CFrame = CFrame.new(camPos+Vector3.new(rx,ry,rz))
                return { part=part, vel=Vector3.new(WIND.X,-DROP_SPEED,WIND.Z), life=math.random()*2 }
            end
            local created = 0
            _G.RainSpawnConnection = RunService.RenderStepped:Connect(function()
                for i = 1, 50 do
                    if created >= DROP_COUNT then _G.RainSpawnConnection:Disconnect() _G.RainSpawnConnection = nil break end
                    table.insert(_G.RainDrops, CreateDrop())
                    created = created + 1
                end
            end)
            _G.RainColorCorrection = Instance.new("ColorCorrectionEffect")
            _G.RainColorCorrection.Name = "RainColorCorrection"
            _G.RainColorCorrection.Brightness = -0.08 _G.RainColorCorrection.Contrast = 0.3
            _G.RainColorCorrection.Saturation = -0.6 _G.RainColorCorrection.TintColor = Color3.fromRGB(140,145,155)
            _G.RainColorCorrection.Parent = Lighting
            Lighting.FogColor = Color3.fromRGB(110,115,125) Lighting.FogStart = 10 Lighting.FogEnd = 120
            local rainSound = Instance.new("Sound")
            rainSound.Name = "RainSound" rainSound.SoundId = "rbxassetid://140533807333752"
            rainSound.Volume = 1.0 rainSound.Looped = true rainSound.RollOffMaxDistance = 0
            rainSound.Parent = camera rainSound:Play()
            _G.RainConnection = RunService.RenderStepped:Connect(function(dt)
                local camPos = camera.CFrame.Position
                local drops = _G.RainDrops
                local count = #drops
                if count == 0 then return end
                local batchSize = math.ceil(count/3)
                local startIdx = (_G.RainBatchIdx % count) + 1
                _G.RainBatchIdx = _G.RainBatchIdx + batchSize
                for i = startIdx, math.min(startIdx+batchSize-1, count) do
                    local drop = drops[i]
                    if drop then
                        drop.life = drop.life - dt
                        local pos = drop.part.Position + drop.vel * dt
                        drop.part.CFrame = CFrame.new(pos)
                        if drop.life <= 0 or (pos-camPos).Magnitude > AREA*2.5 then
                            local rx = math.random(-AREA,AREA) local rz = math.random(-AREA,AREA)
                            drop.part.CFrame = CFrame.new(camPos+Vector3.new(rx,AREA+10,rz))
                            drop.life = 1.0+math.random()*1.0
                        end
                    end
                end
            end)
        else
            if _G.RainSpawnConnection then _G.RainSpawnConnection:Disconnect() _G.RainSpawnConnection = nil end
            if _G.RainConnection then _G.RainConnection:Disconnect() _G.RainConnection = nil end
            if _G.RainFolder then _G.RainFolder:Destroy() _G.RainFolder = nil end
            _G.RainDrops = nil _G.RainBatchIdx = 0
            local camera = workspace.CurrentCamera
            local rainSound = camera:FindFirstChild("RainSound")
            if rainSound then rainSound:Destroy() end
            if _G.RainColorCorrection then _G.RainColorCorrection:Destroy() _G.RainColorCorrection = nil end
            Lighting.FogEnd = 100000 Lighting.FogStart = 0
        end
    end,
})

WorldTab:CreateToggle({
    Name = "Full Bright",
    CurrentValue = false,
    Flag = "FullBright",
    Callback = function(v) Settings.FullBright = v end,
})
WorldTab:CreateToggle({
    Name = "No Fog",
    CurrentValue = false,
    Flag = "NoFog",
    Callback = function(v)
        Settings.NoFog = v
        if v then
            local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmos then atmos:Destroy() end
            Lighting.FogEnd = 100000 Lighting.FogStart = 100000
        else
            Lighting.FogStart = 0 Lighting.FogEnd = 100000
        end
    end,
})
WorldTab:CreateToggle({
    Name = "TP-Walk",
    CurrentValue = false,
    Flag = "TPWalk",
    Callback = function(v) Settings.TPWalk = v end,
})
WorldTab:CreateSlider({
    Name = "TP Speed",
    Range = {1, 15},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 2,
    Flag = "TPWalkSpeed",
    Callback = function(v) Settings.TPWalkSpeed = v end,
})
WorldTab:CreateToggle({
    Name = "Instant Interact",
    CurrentValue = false,
    Flag = "InstantInteract",
    Callback = function(v) Settings.InstantInteract = v end,
})
WorldTab:CreateSlider({
    Name = "Gravity",
    Range = {0, 400},
    Increment = 5,
    Suffix = "",
    CurrentValue = 196,
    Flag = "GravityValue",
    Callback = function(v)
        Settings.GravityValue = v
        workspace.Gravity = v
    end,
})
WorldTab:CreateSlider({
    Name = "Time of Day",
    Range = {0, 24},
    Increment = 0.5,
    Suffix = "h",
    CurrentValue = 14,
    Flag = "TimeOfDay",
    Callback = function(v)
        Settings.TimeOfDay = v
        if not Settings.FullBright then
            Lighting.ClockTime = v
        end
    end,
})
WorldTab:CreateSlider({
    Name = "Horse Turn Speed",
    Range = {0, 420},
    Increment = 1,
    Suffix = "",
    CurrentValue = 26,
    Callback = function(v)
        pcall(function()
            local function FindMyHorse2()
                local username = LocalPlayer.Name
                for _, h in pairs(workspace.Horses:GetChildren()) do
                    local scripts = h:FindFirstChild("Scripts")
                    if scripts then
                        for _, val in pairs(scripts:GetChildren()) do
                            if val.Name:lower():find("owner") and tostring(val.Value) == username then return h end
                        end
                    end
                end
                return nil
            end
            local h = FindMyHorse2()
            if h then
                local ts = h:FindFirstChild("Scripts") and h.Scripts:FindFirstChild("TurnSpeed")
                if ts then ts.Value = v end
            end
        end)
    end,
})
WorldTab:CreateToggle({
    Name = "Horse Whip (Makes horse follow you everywhere)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            _G.HorseWhip = true
            task.spawn(function()
                while _G.HorseWhip do
                    game:GetService("ReplicatedStorage").GeneralEvents.SpawnHorse:InvokeServer("CallHorse")
                    task.wait(0.2)
                end
            end)
        else
            _G.HorseWhip = false
        end
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
            Rayfield:Notify({ Title = "AutoFarm", Content = "Farm started!", Duration = 4, Image = 4483362458 })
        else
            StopFarm()
            Rayfield:Notify({ Title = "AutoFarm", Content = "Farm stopped.", Duration = 3, Image = 4483362458 })
        end
    end,
})
FarmTab:CreateInput({
    Name = "Inventory Slots",
    PlaceholderText = "Enter slot count (e.g. 24)",
    RemoveTextAfterFocusLost = false,
    Callback = function(val)
        local num = tonumber(val)
        if num and num > 0 then Settings.InventorySlots = math.floor(num) end
    end,
})

-- ─── APPEARANCE TAB ─────────────────────────────────────────────────────────────
AppearanceTab:CreateSection("Themes")
AppearanceTab:CreateDropdown({
    Name = "Themes",
    Options = {"Default","AmberGlow","Amethyst","Bloom","DarkBlue","Green","Light","Ocean","Serenity"},
    CurrentOption = {"Default"},
    MultipleOptions = false,
    Callback = function(Selected)
        local theme = type(Selected) == "table" and Selected[1] or Selected
        Window.ModifyTheme(theme)
    end,
})

AppearanceTab:CreateSection("Gun")
local MATERIALS = {"SmoothPlastic","Metal","Neon","Glass","Wood","Marble","Granite","Slate","Cobblestone","Brick","Sand","Fabric","DiamondPlate","Foil","Ice"}
local PART_SLOTS = { BoltHammer={"Bolt","Hammer"}, Handle={"Handle"}, Metal={"Metal"}, Cylinder={"Cylinder"} }
local customColors = { BoltHammer=Color3.fromRGB(80,80,80), Handle=Color3.fromRGB(30,20,10), Metal=Color3.fromRGB(120,120,120), Cylinder=Color3.fromRGB(100,100,100) }
local customMaterials = { BoltHammer="Metal", Handle="SmoothPlastic", Metal="Metal", Cylinder="Metal" }

local function GetTargetModels()
    local models = {}
    local root = workspace:FindFirstChild(LocalPlayer.Name)
    if not root then return models end
    local primaryDisplay = root:FindFirstChild("PrimaryDisplay")
    local pistolDisplay = root:FindFirstChild("PistolDisplay")
    if primaryDisplay then table.insert(models, primaryDisplay) end
    if pistolDisplay then table.insert(models, pistolDisplay) end
    local character = LocalPlayer.Character
    if character then
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") then table.insert(models, child) end
        end
    end
    return models
end

local function ApplyToSlot(slotKey, color, materialName)
    customColors[slotKey] = color
    customMaterials[slotKey] = materialName
    local partNames = PART_SLOTS[slotKey]
    local mat = Enum.Material[materialName] or Enum.Material.SmoothPlastic
    for _, model in ipairs(GetTargetModels()) do
        for _, partName in ipairs(partNames) do
            local part = model:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                part.Color = color
                part.Material = mat
            end
        end
    end
end

local slotOrder = {
    {key="BoltHammer",label="Bolt / Hammer"},
    {key="Handle",label="Handle"},
    {key="Metal",label="Metal"},
    {key="Cylinder",label="Cylinder"},
}

for _, slot in ipairs(slotOrder) do
    local key = slot.key
    local label = slot.label
    AppearanceTab:CreateColorPicker({
        Name = label .. " Color",
        Color = customColors[key],
        Flag = "GunColor_" .. key,
        Callback = function(c) ApplyToSlot(key, c, customMaterials[key]) end,
    })
    AppearanceTab:CreateDropdown({
        Name = label .. " Material",
        Options = MATERIALS,
        CurrentOption = {customMaterials[key]},
        Flag = "GunMat_" .. key,
        Callback = function(selected) ApplyToSlot(key, customColors[key], selected[1]) end,
    })
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.1)
            for _, slot in ipairs(slotOrder) do ApplyToSlot(slot.key, customColors[slot.key], customMaterials[slot.key]) end
        end
    end)
end)
if LocalPlayer.Character then
    LocalPlayer.Character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.1)
            for _, slot in ipairs(slotOrder) do ApplyToSlot(slot.key, customColors[slot.key], customMaterials[slot.key]) end
        end
    end)
end

AppearanceTab:CreateSection("Bullet FX")
local bulletColor = Color3.fromRGB(255, 0, 128)
local bulletLifetime = 1

local function ApplyBulletFX(shot)
    for _, obj in pairs(shot:GetDescendants()) do
        if obj:IsA("Trail") then
            obj.Color = ColorSequence.new(bulletColor)
        end
        if obj.Name == "Emission" or obj:IsA("ParticleEmitter") then
            pcall(function() obj.Lifetime = NumberRange.new(bulletLifetime) end)
        end
    end
end

local bullets = workspace:WaitForChild("Bullets")
for _, shot in pairs(bullets:GetChildren()) do pcall(function() ApplyBulletFX(shot) end) end
bullets.ChildAdded:Connect(function(shot) pcall(function() ApplyBulletFX(shot) end) end)

AppearanceTab:CreateColorPicker({
    Name = "Bullet Trail Colour",
    Color = Color3.fromRGB(255, 0, 128),
    Callback = function(v) bulletColor = v end,
})

AppearanceTab:CreateSection("Mesh / Accessory Spoofer")
AppearanceTab:CreateInput({
    Name = "Spoof Mesh ID",
    PlaceholderText = "Enter mesh asset ID",
    RemoveTextAfterFocusLost = false,
    Callback = function(v) Settings.SpooferMeshId = v end,
})
AppearanceTab:CreateInput({
    Name = "Spoof Texture ID",
    PlaceholderText = "Enter texture asset ID",
    RemoveTextAfterFocusLost = false,
    Callback = function(v) Settings.SpooferTextureId = v end,
})
AppearanceTab:CreateButton({
    Name = "Apply Spoofer",
    Callback = function()
        ApplySpoofer()
        Rayfield:Notify({ Title = "Spoofer", Content = "Mesh/Texture applied!", Duration = 3, Image = 4483362458 })
    end,
})

AppearanceTab:CreateSection("Horse")
local function FindMyHorse()
    local username = LocalPlayer.Name
    for _, h in pairs(workspace.Horses:GetChildren()) do
        local scripts = h:FindFirstChild("Scripts")
        if scripts then
            for _, v in pairs(scripts:GetChildren()) do
                if v.Name:lower():find("owner") and tostring(v.Value) == username then return h end
            end
        end
    end
    return nil
end

local myHorse = nil
local bodyParts, eyeParts, maneParts, saddleParts = {}, {}, {}, {}
local appearanceLoaded = false
local horseWarning = nil
local materialOptions = {"SmoothPlastic","Plastic","Wood","Marble","Granite","Brick","Fabric","Metal","DiamondPlate","Foil","Glass","Neon","ForceField"}

local function BuildPartLists(h)
    bodyParts, eyeParts, maneParts, saddleParts = {}, {}, {}, {}
    local bodyPartNames = {"Tail","Mane","HumanoidRootPart","Torso","RightHind","RightFore","Right Leg","Right Arm","Rein","RHCannon","RFCannon","LeftHind","LeftFore","Left Leg","Left Arm","LFCannon","LHCannon","Head"}
    for _, name in pairs(bodyPartNames) do
        local part = h:FindFirstChild(name)
        if part then table.insert(bodyParts, part) end
    end
    local eyes = h:FindFirstChild("Eyes")
    if eyes then table.insert(eyeParts, eyes) end
    local mane = h:FindFirstChild("Mane")
    if mane then table.insert(maneParts, mane) end
    local saddle = h:FindFirstChild("Saddle")
    if saddle then table.insert(saddleParts, saddle) end
end

local function LoadAppearanceControls()
    if appearanceLoaded then return end
    appearanceLoaded = true
    AppearanceTab:CreateColorPicker({ Name="Body Colour", Color=Color3.fromRGB(255,255,255), Callback=function(v) for _,p in pairs(bodyParts) do pcall(function() p.Color=v end) end end })
    AppearanceTab:CreateDropdown({ Name="Body Material", Options=materialOptions, CurrentOption={"SmoothPlastic"}, MultipleOptions=false, Callback=function(v) local m=type(v)=="table" and v[1] or v for _,p in pairs(bodyParts) do pcall(function() p.Material=Enum.Material[m] end) end end })
    AppearanceTab:CreateColorPicker({ Name="Eyes Colour", Color=Color3.fromRGB(255,255,255), Callback=function(v) for _,p in pairs(eyeParts) do pcall(function() p.Color=v end) end end })
    AppearanceTab:CreateDropdown({ Name="Eyes Material", Options=materialOptions, CurrentOption={"SmoothPlastic"}, MultipleOptions=false, Callback=function(v) local m=type(v)=="table" and v[1] or v for _,p in pairs(eyeParts) do pcall(function() p.Material=Enum.Material[m] end) end end })
    AppearanceTab:CreateColorPicker({ Name="Mane Colour", Color=Color3.fromRGB(255,255,255), Callback=function(v) for _,p in pairs(maneParts) do pcall(function() p.Color=v end) end end })
    AppearanceTab:CreateDropdown({ Name="Mane Material", Options=materialOptions, CurrentOption={"SmoothPlastic"}, MultipleOptions=false, Callback=function(v) local m=type(v)=="table" and v[1] or v for _,p in pairs(maneParts) do pcall(function() p.Material=Enum.Material[m] end) end end })
    AppearanceTab:CreateColorPicker({ Name="Saddle Colour", Color=Color3.fromRGB(255,255,255), Callback=function(v) for _,p in pairs(saddleParts) do pcall(function() p.Color=v end) end end })
    AppearanceTab:CreateDropdown({ Name="Saddle Material", Options=materialOptions, CurrentOption={"SmoothPlastic"}, MultipleOptions=false, Callback=function(v) local m=type(v)=="table" and v[1] or v for _,p in pairs(saddleParts) do pcall(function() p.Material=Enum.Material[m] end) end end })
end

local function TryLoadHorse()
    local found = FindMyHorse()
    if found then
        myHorse = found
        BuildPartLists(myHorse)
        LoadAppearanceControls()
        if horseWarning then horseWarning:Set("","") horseWarning = nil end
    else
        if not horseWarning then
            horseWarning = AppearanceTab:CreateParagraph({ Title="⚠️ Horse Not Found", Content="Spawn your horse then press Refresh or die/respawn." })
        end
    end
end

TryLoadHorse()
AppearanceTab:CreateButton({
    Name = "Refresh Horse",
    Callback = function()
        local found = FindMyHorse()
        if found then
            myHorse = found BuildPartLists(myHorse) LoadAppearanceControls()
            if horseWarning then horseWarning:Set("","") horseWarning = nil end
            Rayfield:Notify({ Title="Horse", Content="Horse refreshed!", Duration=3, Image=4483362458 })
        else
            if not horseWarning then
                horseWarning = AppearanceTab:CreateParagraph({ Title="⚠️ Horse Not Found", Content="Spawn your horse then press Refresh or die/respawn." })
            end
            Rayfield:Notify({ Title="Horse", Content="No horse found.", Duration=3, Image=4483362458 })
        end
    end,
})

local function HookCharacter(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Died:Connect(function()
        LocalPlayer.CharacterAdded:Wait()
        task.wait(3)
        local found = FindMyHorse()
        if found then
            myHorse = found BuildPartLists(myHorse) LoadAppearanceControls()
            if horseWarning then horseWarning:Set("","") horseWarning = nil end
        end
    end)
    -- Restore walkspeed/jumpheight on respawn
    hum.WalkSpeed = Settings.WalkSpeed
    hum.JumpHeight = Settings.JumpHeight
end

if LocalPlayer.Character then HookCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(char)
    HookCharacter(char)
    if Settings.FlightEnabled then
        task.wait(0.5)
        StartFlight()
    end
    -- restore noclip
    if Settings.Noclip then
        task.wait(0.2)
        SetNoclip(true)
    end
end)

-- ─── MISC TAB ─────────────────────────────────────────────────────────────────
MiscTab:CreateSection("Server")
MiscTab:CreateButton({
    Name = "Rejoin Same Server",
    Callback = function()
        Rejoin()
    end,
})
MiscTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        ServerHop()
    end,
})
MiscTab:CreateInput({
    Name = "Server Snipe - Target Player Name",
    PlaceholderText = "Enter player name",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        _snipeTargetName = v
    end,
})
MiscTab:CreateButton({
    Name = "Server Snipe (Follow Player)",
    Callback = function()
        ServerSnipe(_snipeTargetName)
    end,
})

MiscTab:CreateSection("Utility")
MiscTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        SetAntiAfk(v)
    end,
})
MiscTab:CreateToggle({
    Name = "Fake Lag (Server Desync)",
    CurrentValue = false,
    Flag = "FakeLag",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        SetFakeLag(v)
    end,
})
MiscTab:CreateSlider({
    Name = "Fake Lag Strength",
    Range = {1, 50},
    Increment = 1,
    Suffix = "",
    CurrentValue = 10,
    Flag = "FakeLagStrength",
    Callback = function(v) Settings.FakeLagStrength = v end,
})

MiscTab:CreateSection("Remote Spy")
MiscTab:CreateToggle({
    Name = "Remote Spy",
    CurrentValue = false,
    Flag = "RemoteSpy",
    Callback = function(v)
        PlaySound(Sounds.Toggle, 0.4, v and 1.1 or 0.9)
        if v then
            StartRemoteSpy()
            if _remoteSpyGui and _remoteSpyGui._frame then
                _remoteSpyGui._frame.Visible = true
            end
            Rayfield:Notify({ Title = "Remote Spy", Content = "Now logging remotes. See overlay.", Duration = 4, Image = 4483362458 })
        else
            StopRemoteSpy()
        end
    end,
})
MiscTab:CreateInput({
    Name = "Block Remote (by name)",
    PlaceholderText = "Enter remote name to block",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        if v and v ~= "" then
            _remoteFirewall[v] = true
            Rayfield:Notify({ Title = "Remote Firewall", Content = "Blocking: " .. v, Duration = 3, Image = 4483362458 })
        end
    end,
})
MiscTab:CreateButton({
    Name = "Clear Remote Firewall",
    Callback = function()
        _remoteFirewall = {}
        Rayfield:Notify({ Title = "Remote Firewall", Content = "Cleared all blocks.", Duration = 3, Image = 4483362458 })
    end,
})

-- ─── ESP LOOPS ────────────────────────────────────────────────────────────────
task.spawn(function()
    while task.wait(1) do
        if Settings.AnimalESP then
            for _, folderName in pairs({"Harvestables","Animals","NPCS"}) do
                local folder = workspace:FindFirstChild(folderName)
                if folder then
                    for _, v in pairs(folder:GetChildren()) do
                        if v:IsA("Model") then
                            local rp = GetRootPart(v)
                            if rp then
                                local dist = GetDist(rp.Position)
                                local col = Settings.RainbowAnimalESP and RainbowColor() or Settings.AnimalColor
                                ManageESP(v, CleanAnimalName(v), col, "OverlordAnimalESP", true, dist, false)
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
local function IsChestOpen(obj)
    local opened = obj:FindFirstChild("Opened")
    if opened then
        if opened:IsA("BoolValue") then return opened.Value end
        return true
    end
    return false
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
            if n == "opened" or n == "open" or n == "isopened" then HideChestESP(obj) end
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
                if IsChestOpen(obj) then HideChestESP(obj) return end
                if Settings.ChestESP then
                    local col = Settings.RainbowChestESP and RainbowColor() or Settings.ChestColor
                    ManageChestESP(obj, GetChestLabel(), col, "OverlordChestESP", true, GetDist(rp.Position))
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
        local chestFolder = workspace:FindFirstChild("ChestFolder") or workspace:WaitForChild("ChestFolder", 10)
        if not chestFolder then return end
        for _, obj in pairs(chestFolder:GetChildren()) do pcall(TryTagChest, obj) end
        chestFolder.ChildAdded:Connect(function(obj) pcall(TryTagChest, obj) end)
        chestFolder.ChildRemoved:Connect(function(obj)
            pcall(function() if TrackedChests[obj] then HideChestESP(obj) end end)
        end)
    end)
end)

task.delay(3, function()
    for _, obj in pairs(workspace:GetDescendants()) do pcall(TryTagChest, obj) end
end)

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
                    local col = Settings.RainbowItemESP and RainbowColor() or Settings.ItemColor
                    ManageItemESP(obj, label, col, "OverlordItemESP", true, GetDist(rp.Position))
                end)
            end
        end
    end
end)

-- ─── MAIN RENDER LOOP ─────────────────────────────────────────────────────────
RunService.RenderStepped:Connect(function()
    -- FOV Circle
    FOVCircle.Visible = Settings.ShowFOVCircle
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Aimbot
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

    -- SA Highlight
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

    -- Fullbright
    if Settings.FullBright then
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
    end

    -- No Fog
    if Settings.NoFog then
        local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmos then atmos:Destroy() end
        Lighting.FogEnd = 100000 Lighting.FogStart = 100000
    end

    -- TP Walk
    if Settings.TPWalk and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        if hum.MoveDirection.Magnitude > 0 then
            LocalPlayer.Character:TranslateBy(hum.MoveDirection * Settings.TPWalkSpeed / 10)
        end
    end

    -- Per-player ESP
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local rp = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")

            -- Team check
            local skipByTeam = Settings.ESPTeamCheck and IsOnSameTeam(p)

            if rp and hum and hum.Health > 0 and not skipByTeam then
                local dist = GetDist(rp.Position)

                -- Billboard name/hp
                local shouldShow = Settings.PlayerName or Settings.PlayerHP
                local dText = ""
                if Settings.PlayerName then
                    dText = p.Name
                end
                if Settings.PlayerHP then
                    dText = dText .. (dText ~= "" and "\n" or "") .. "[HP: " .. math.floor(hum.Health) .. "]"
                end
                local nameCol = Settings.RainbowNameESP and RainbowColor() or Settings.PlayerColor
                ManageESP(char, dText, nameCol, "OverlordPlayerESP", shouldShow, dist, true)

                -- Chams
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

                -- Box ESP
                if Settings.PlayerBoxESP then
                    DrawBoxESP(p)
                else
                    HideBoxESP(p)
                end

                -- Skeleton
                if Settings.SkeletonESP then
                    DrawSkeleton(p)
                else
                    HideSkeleton(p)
                end

                -- Head Dot
                if Settings.HeadDotESP then
                    DrawHeadDot(p)
                else
                    HideHeadDot(p)
                end

                -- Tracer
                if Settings.TracerESP then
                    DrawTracer(p)
                else
                    HideTracer(p)
                end
            else
                -- Clean up
                local b = char:FindFirstChild("OverlordPlayerESP", true)
                if b then b:Destroy() end
                local h = char:FindFirstChild("OverlordHigh")
                if h then h:Destroy() end
                HideBoxESP(p)
                HideSkeleton(p)
                HideHeadDot(p)
                HideTracer(p)
            end
        end
    end
end)

ProximityPromptService.PromptShown:Connect(function(prompt)
    if Settings.InstantInteract then prompt.HoldDuration = 0 end
end)

Rayfield:Notify({
    Title = "BabyBound",
    Content = "Loaded! v2 — All features active.",
    Duration = 5,
    Image = 4483362458,
})
PlaySound(Sounds.Notify, 0.6, 1.05)
