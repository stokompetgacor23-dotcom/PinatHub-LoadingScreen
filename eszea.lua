repeat task.wait() until game:IsLoaded()

-- =======================================================
-- PINATHUB | SZA FEATURES (WindUI v2)
-- =======================================================

-- ============================================
-- SERVICES
-- ============================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- EXECUTOR COMPATIBILITY
-- ============================================
local function noop() end
local get_hui = gethui or (syn and syn.gethui) or noop
local set_clipboard = setclipboard or (syn and syn.setclipboard) or noop

-- ============================================
-- PLAYER VARIABLES
-- ============================================
local player = LocalPlayer
local UIS = UserInputService
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- ============================================
-- GLOBAL CONFIG (Dari SZA)
-- ============================================
_G = _G or {}

-- Normal Lighting Settings untuk Fullbright
_G.NormalLightingSettings = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient
}

_G.FullBrightEnabled = false
_G.FullBrightExecuted = false

-- Referensi Game Objects (Dynamic)
local VoidShards = Workspace:FindFirstChild("VoidShards") or Workspace:WaitForChild("VoidShards", 5)

-- Dynamic function for Zombies_Local (FIXED)
local function getZombiesLocal()
    return Workspace:FindFirstChild("Zombies_Local")
end

-- State Variables
local WaveFarm = false
local OldPosition = humanoidRootPart.CFrame
local lastWaveCount = 0

-- ============================================
-- FULLBRIGHT LOGIC (New)
-- ============================================
local function setupFullbright()
    if _G.FullBrightExecuted then return end
    
    Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
        if Lighting.Brightness ~= 1 and Lighting.Brightness ~= _G.NormalLightingSettings.Brightness then
            _G.NormalLightingSettings.Brightness = Lighting.Brightness
            if not _G.FullBrightEnabled then
                repeat task.wait() until _G.FullBrightEnabled
            end
            Lighting.Brightness = 1
        end
    end)

    Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
        if Lighting.ClockTime ~= 12 and Lighting.ClockTime ~= _G.NormalLightingSettings.ClockTime then
            _G.NormalLightingSettings.ClockTime = Lighting.ClockTime
            if not _G.FullBrightEnabled then
                repeat task.wait() until _G.FullBrightEnabled
            end
            Lighting.ClockTime = 12
        end
    end)

    Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
        if Lighting.FogEnd ~= 786543 and Lighting.FogEnd ~= _G.NormalLightingSettings.FogEnd then
            _G.NormalLightingSettings.FogEnd = Lighting.FogEnd
            if not _G.FullBrightEnabled then
                repeat task.wait() until _G.FullBrightEnabled
            end
            Lighting.FogEnd = 786543
        end
    end)

    Lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
        if Lighting.GlobalShadows ~= false and Lighting.GlobalShadows ~= _G.NormalLightingSettings.GlobalShadows then
            _G.NormalLightingSettings.GlobalShadows = Lighting.GlobalShadows
            if not _G.FullBrightEnabled then
                repeat task.wait() until _G.FullBrightEnabled
            end
            Lighting.GlobalShadows = false
        end
    end)

    Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
        if Lighting.Ambient ~= Color3.fromRGB(178, 178, 178) and Lighting.Ambient ~= _G.NormalLightingSettings.Ambient then
            _G.NormalLightingSettings.Ambient = Lighting.Ambient
            if not _G.FullBrightEnabled then
                repeat task.wait() until _G.FullBrightEnabled
            end
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        end
    end)

    -- Apply initial Fullbright settings
    Lighting.Brightness = 1
    Lighting.ClockTime = 12
    Lighting.FogEnd = 786543
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.fromRGB(178, 178, 178)

    local LatestValue = true
    task.spawn(function()
        repeat task.wait() until _G.FullBrightEnabled
        while task.wait() do
            if _G.FullBrightEnabled ~= LatestValue then
                if not _G.FullBrightEnabled then
                    Lighting.Brightness = _G.NormalLightingSettings.Brightness
                    Lighting.ClockTime = _G.NormalLightingSettings.ClockTime
                    Lighting.FogEnd = _G.NormalLightingSettings.FogEnd
                    Lighting.GlobalShadows = _G.NormalLightingSettings.GlobalShadows
                    Lighting.Ambient = _G.NormalLightingSettings.Ambient
                else
                    Lighting.Brightness = 1
                    Lighting.ClockTime = 12
                    Lighting.FogEnd = 786543
                    Lighting.GlobalShadows = false
                    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
                end
                LatestValue = not LatestValue
            end
        end
    end)
    
    _G.FullBrightExecuted = true
end

-- ============================================
-- NO FOG LOGIC (New)
-- ============================================
local function applyNoFog()
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.ClockTime = 14
    Lighting.Brightness = 2
    Lighting.GlobalShadows = false
end

local function resetFog()
    Lighting.FogEnd = _G.NormalLightingSettings.FogEnd or 100000
    Lighting.FogStart = 0
    Lighting.ClockTime = _G.NormalLightingSettings.ClockTime or 12
    Lighting.Brightness = _G.NormalLightingSettings.Brightness or 2
    Lighting.GlobalShadows = _G.NormalLightingSettings.GlobalShadows or true
end

-- ============================================
-- CREATE HIDE PART (Safe Zone)
-- ============================================
local hidePart = nil

local function createHidePart()
    if hidePart and hidePart.Parent then
        hidePart:Destroy()
        hidePart = nil
    end

    local part = Instance.new("Part")
    part.Name = "PinatHubHideZone"
    part.Size = Vector3.new(10, 10, 10)
    part.Position = Vector3.new(23.050, -9.820, -46.845)
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Parent = Workspace

    hidePart = part
    return part
end

local function teleportToHidePart()
    if not hidePart then
        createHidePart()
        task.wait(0.1)
    end

    if hidePart then
        humanoidRootPart.CFrame = hidePart.CFrame + Vector3.new(0, 3, 0)
        if Window then
            Window:Notify("Hide Zone", "Teleported to safe zone!", 2)
        end
        return true
    end
    return false
end

-- ============================================
-- LOGO LAUNCHER PINATHUB
-- ============================================
local logoGui = Instance.new("ScreenGui")
logoGui.Name = "PinatHubLogo"
logoGui.ResetOnSpawn = false
logoGui.Parent = player:WaitForChild("PlayerGui", 5)

local logoButton = Instance.new("ImageButton")
logoButton.Name = "LogoButton"
logoButton.Size = UDim2.new(0, 50, 0, 50)
logoButton.Position = UDim2.new(0.5, -25, 0.5, -25)
logoButton.BackgroundTransparency = 1
logoButton.Image = "rbxassetid://118264723961739"
logoButton.ImageColor3 = Color3.fromRGB(180, 0, 255)
logoButton.ScaleType = Enum.ScaleType.Fit
logoButton.Parent = logoGui

local uiCornerLogo = Instance.new("UICorner")
uiCornerLogo.CornerRadius = UDim.new(1, 0)
uiCornerLogo.Parent = logoButton

local hoverTween = TweenService:Create(logoButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)})
local unhoverTween = TweenService:Create(logoButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 50, 0, 50)})

logoButton.MouseEnter:Connect(function() hoverTween:Play() end)
logoButton.MouseLeave:Connect(function() unhoverTween:Play() end)

local dragging = false
local dragStart = nil
local startPos = nil

logoButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = logoButton.Position
    end
end)

logoButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        dragStart = nil
        startPos = nil
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and dragStart and startPos then
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            local newX = startPos.X.Offset + delta.X
            local newY = startPos.Y.Offset + delta.Y
            logoButton.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        end
    end
end)

-- ============================================
-- LOAD WINDUI
-- ============================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "PinatHub",
    Author = "@viunze",
    Folder = "pinathub_sza",
    Size = UDim2.fromOffset(550, 400),
    Transparent = true,
    Theme = "Dark",
    IsOpenButtonEnabled = false,
    UserEnabled = true,
    HasOutline = true,
    SideBarWidth = 150,
})

-- Logo button toggle open/close UI
local guiVisible = true
logoButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    if Window then
        pcall(function()
            if guiVisible then
                Window:Open()
            else
                Window:Minimize()
            end
        end)
    end
end)

-- ============================================
-- CREATE TABS (SZA Style)
-- ============================================
local Tabs = {
    CombatTab = Window:Tab({ Title = "Combat", Icon = "sword" }),
    AutoTab = Window:Tab({ Title = "Auto", Icon = "bot" }),
    PlayerTab = Window:Tab({ Title = "Player", Icon = "user" }),
    VisualTab = Window:Tab({ Title = "Visual", Icon = "eye" }),
    WorldTab = Window:Tab({ Title = "World", Icon = "globe" }),
    SettingsTab = Window:Tab({ Title = "Settings", Icon = "cog" }),
    CommunityTab = Window:Tab({ Title = "Community", Icon = "users" }),
}

-- ============================================
-- SZA FEATURES - COMBAT TAB
-- ============================================
local combatSection = Tabs.CombatTab:Section({ Title = "Combat Features", Icon = "sword" })

-- Instance Kill
combatSection:Toggle({
    Title = "Instance Kill",
    Description = "Instantly kill all zombies",
    Default = false,
    Callback = function(state)
        _G.InstanceKill = state
    end
})

-- Kill Aura
combatSection:Toggle({
    Title = "Kill Aura",
    Description = "Auto attack nearby zombies",
    Default = false,
    Callback = function(state)
        _G.KillAura = state
    end
})

combatSection:Slider({
    Title = "Kill Aura Distance",
    Value = { Min = 10, Max = 1000, Default = 50 },
    Callback = function(value)
        _G.KillAuraDistance = value
    end
})

combatSection:Divider()

-- Auto Abilities
combatSection:Paragraph({ Title = "Auto Abilities", Desc = "Automatically use abilities" })

combatSection:Toggle({
    Title = "Auto Ability E",
    Default = false,
    Callback = function(state)
        _G.AutoAbilityE = state
    end
})

combatSection:Toggle({
    Title = "Auto Ability R",
    Default = false,
    Callback = function(state)
        _G.AutoAbilityR = state
    end
})

combatSection:Toggle({
    Title = "Auto Ability Q",
    Default = false,
    Callback = function(state)
        _G.AutoAbilityQ = state
    end
})

-- ============================================
-- SZA FEATURES - AUTO TAB
-- ============================================
local autoSection = Tabs.AutoTab:Section({ Title = "Auto Features", Icon = "bot" })

-- Auto Void Shard
autoSection:Toggle({
    Title = "Auto Void Shard",
    Description = "Auto collect void shards",
    Default = false,
    Callback = function(state)
        _G.AutoVoidShard = state
    end
})

-- Auto Open Galactic Crate
autoSection:Toggle({
    Title = "Auto Open Galactic Crate",
    Description = "Auto open galactic crates",
    Default = false,
    Callback = function(state)
        _G.AutoOpenGalacticCrate = state
    end
})

autoSection:Divider()

-- Auto Upgrades
autoSection:Paragraph({ Title = "Auto Upgrades", Desc = "Automatically purchase upgrades" })

autoSection:Toggle({
    Title = "Auto Upgrade Health",
    Default = false,
    Callback = function(state)
        _G.AutoUpgradeHealth = state
    end
})

autoSection:Toggle({
    Title = "Auto Upgrade Weapon",
    Default = false,
    Callback = function(state)
        _G.AutoUpgradeWeapon = state
    end
})

autoSection:Divider()

-- Wave Settings
autoSection:Paragraph({ Title = "Wave Settings", Desc = "Auto wave management" })

autoSection:Toggle({
    Title = "Auto Skip Wave",
    Default = false,
    Callback = function(state)
        _G.AutoSkipWave = state
    end
})

autoSection:Toggle({
    Title = "Auto Reset After Wave",
    Default = false,
    Callback = function(state)
        _G.AutoResetAfterWave = state
    end
})

autoSection:Input({
    Title = "Reset After Wave",
    Placeholder = "Enter wave number",
    Numeric = true,
    Callback = function(value)
        _G.ResetAfterWave = tonumber(value) or 50
    end
})

autoSection:Toggle({
    Title = "Auto Play Again",
    Default = false,
    Callback = function(state)
        _G.AutoPlayAgain = state
    end
})

autoSection:Divider()

-- Auto Execute (without Auto Equip Weapon)
autoSection:Toggle({
    Title = "Auto Execute (Teleport)",
    Description = "Auto re-execute after teleport",
    Default = false,
    Callback = function(state)
        _G.AutoExecute = state
    end
})

autoSection:Divider()

-- Spam Delay
autoSection:Slider({
    Title = "Spam Delay (seconds)",
    Value = { Min = 0, Max = 3, Default = 1, Decimal = true },
    Callback = function(value)
        _G.SpamDelay = value
    end
})

-- ============================================
-- SZA FEATURES - PLAYER TAB
-- ============================================
local playerSection = Tabs.PlayerTab:Section({ Title = "Player Modifiers", Icon = "user" })

-- WalkSpeed
playerSection:Slider({
    Title = "Walk Speed",
    Value = { Min = 16, Max = 250, Default = 16 },
    Callback = function(value)
        _G.WalkSpeed = value
        if humanoid then humanoid.WalkSpeed = value end
    end
})

-- JumpPower
playerSection:Slider({
    Title = "Jump Power",
    Value = { Min = 50, Max = 500, Default = 50 },
    Callback = function(value)
        _G.JumpPower = value
        if humanoid then
            humanoid.JumpPower = value
            humanoid.UseJumpPower = true
        end
    end
})

-- Infinite Jump
playerSection:Toggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(state)
        _G.Infjump = state
    end
})

playerSection:Divider()

-- Fly System
playerSection:Paragraph({ Title = "Fly System", Desc = "Nimbus flying system" })

playerSection:Slider({
    Title = "Fly Speed",
    Value = { Min = 50, Max = 200, Default = 50 },
    Callback = function(value)
        _G.FlySpeed = value
    end
})

playerSection:Toggle({
    Title = "Fly (Nimbus)",
    Default = false,
    Callback = function(state)
        _G.Fly = state
        if _G.Fly == false then
            if character and character:FindFirstChildOfClass("Humanoid") and character.Humanoid.RootPart and character.HumanoidRootPart:FindFirstChild("VelocityHandler") and character.HumanoidRootPart:FindFirstChild("GyroHandler") then
                character.HumanoidRootPart.VelocityHandler:Destroy()
                character.HumanoidRootPart.GyroHandler:Destroy()
                character.Humanoid.PlatformStand = false
            end
        end
        while _G.Fly do
            if character and character:FindFirstChildOfClass("Humanoid") and character.Humanoid.RootPart and character.HumanoidRootPart:FindFirstChild("VelocityHandler") and character.HumanoidRootPart:FindFirstChild("GyroHandler") then
                character.HumanoidRootPart.VelocityHandler.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                character.HumanoidRootPart.GyroHandler.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                character.Humanoid.PlatformStand = true
                character.HumanoidRootPart.GyroHandler.CFrame = Workspace.CurrentCamera.CoordinateFrame
                character.HumanoidRootPart.VelocityHandler.Velocity = Vector3.new()
                if require(player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule")):GetMoveVector().X > 0 then
                    character.HumanoidRootPart.VelocityHandler.Velocity = character.HumanoidRootPart.VelocityHandler.Velocity + Workspace.CurrentCamera.CFrame.RightVector * (require(player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule")):GetMoveVector().X * (_G.FlySpeed or 50))
                end
                if require(player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule")):GetMoveVector().X < 0 then
                    character.HumanoidRootPart.VelocityHandler.Velocity = character.HumanoidRootPart.VelocityHandler.Velocity + Workspace.CurrentCamera.CFrame.RightVector * (require(player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule")):GetMoveVector().X * (_G.FlySpeed or 50))
                end
                if require(player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule")):GetMoveVector().Z > 0 then
                    character.HumanoidRootPart.VelocityHandler.Velocity = character.HumanoidRootPart.VelocityHandler.Velocity - Workspace.CurrentCamera.CFrame.LookVector * (require(player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule")):GetMoveVector().Z * (_G.FlySpeed or 50))
                end
                if require(player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule")):GetMoveVector().Z < 0 then
                    character.HumanoidRootPart.VelocityHandler.Velocity = character.HumanoidRootPart.VelocityHandler.Velocity - Workspace.CurrentCamera.CFrame.LookVector * (require(player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule")):GetMoveVector().Z * (_G.FlySpeed or 50))
                end
            elseif character and character:FindFirstChildOfClass("Humanoid") and character.Humanoid.RootPart and character.HumanoidRootPart:FindFirstChild("VelocityHandler") == nil and character.HumanoidRootPart:FindFirstChild("GyroHandler") == nil then
                local bv = Instance.new("BodyVelocity")
                local bg = Instance.new("BodyGyro")
                bv.Name = "VelocityHandler"
                bv.Parent = character.HumanoidRootPart
                bv.MaxForce = Vector3.new(0,0,0)
                bv.Velocity = Vector3.new(0,0,0)
                bg.Name = "GyroHandler"
                bg.Parent = character.HumanoidRootPart
                bg.MaxTorque = Vector3.new(0,0,0)
                bg.P = 1000
                bg.D = 50
            end
            task.wait()
        end
    end
})

playerSection:Divider()

-- Safe Arena & Anti AFK
playerSection:Toggle({
    Title = "Safe Arena",
    Description = "Prevents fall damage",
    Default = false,
    Callback = function(state)
        _G.SafeArena = state
    end
})

playerSection:Toggle({
    Title = "Anti Idle (Anti AFK)",
    Default = false,
    Callback = function(state)
        _G.AntiIdle = state
    end
})

playerSection:Divider()

-- Wave Farm
playerSection:Toggle({
    Title = "Wave Farm (Block Money)",
    Description = "AFK wave farming",
    Default = false,
    Callback = function(state)
        _G.WaveFarm = state
    end
})

-- ============================================
-- SZA FEATURES - VISUAL TAB
-- ============================================
local visualSection = Tabs.VisualTab:Section({ Title = "Visual Modifiers", Icon = "eye" })

-- ESP Toggles
visualSection:Paragraph({ Title = "ESP (Wallhack)", Desc = "See entities through walls" })

visualSection:Toggle({
    Title = "Zombies ESP",
    Default = false,
    Callback = function(state)
        _G.ZombiesESP = state
    end
})

visualSection:Toggle({
    Title = "Players ESP",
    Default = false,
    Callback = function(state)
        _G.PlayersESP = state
    end
})

visualSection:Divider()

-- Lighting (Fullbright & No Fog with new logic)
visualSection:Paragraph({ Title = "Lighting", Desc = "World lighting adjustments" })

visualSection:Toggle({
    Title = "Fullbright",
    Description = "Makes everything bright",
    Default = false,
    Callback = function(state)
        setupFullbright()
        _G.FullBrightEnabled = state
    end
})

visualSection:Toggle({
    Title = "Remove Fog",
    Description = "Removes fog from the game",
    Default = false,
    Callback = function(state)
        if state then
            applyNoFog()
        else
            resetFog()
        end
    end
})

-- Brightness slider (note: will be overridden by Fullbright)
visualSection:Slider({
    Title = "Brightness (Without Fullbright)",
    Value = { Min = 0, Max = 10, Default = 2 },
    Callback = function(value)
        if not _G.FullBrightEnabled then
            Lighting.Brightness = value
        end
    end
})

visualSection:Divider()

-- Camera
visualSection:Paragraph({ Title = "Camera", Desc = "Camera adjustments" })

visualSection:Slider({
    Title = "Field Of View (FOV)",
    Value = { Min = 70, Max = 120, Default = 70 },
    Callback = function(value)
        _G.FOV = value
        Workspace.CurrentCamera.FieldOfView = value
    end
})

-- ============================================
-- SZA FEATURES - WORLD TAB
-- ============================================
local worldSection = Tabs.WorldTab:Section({ Title = "World Settings", Icon = "globe" })

-- Gameplay Settings
worldSection:Paragraph({ Title = "Lobby Settings", Desc = "Auto create ship configuration" })

worldSection:Toggle({
    Title = "Auto Create Ship",
    Default = false,
    Callback = function(state)
        _G.AutoCreateShip = state
    end
})

worldSection:Slider({
    Title = "Players (1-4)",
    Value = { Min = 1, Max = 4, Default = 1 },
    Callback = function(value)
        _G.PlayersShip = value
    end
})

worldSection:Dropdown({
    Title = "Map",
    Values = { "RooftopSiege", "Atlantis" },
    Default = "RooftopSiege",
    Callback = function(value)
        _G.Map = value
    end
})

worldSection:Dropdown({
    Title = "Gameplay Mode",
    Values = { "Normal", "Hardcore", "Nightmare" },
    Default = "Normal",
    Callback = function(value)
        _G.GameplayMode = value
    end
})

worldSection:Divider()

-- FPS Settings
worldSection:Paragraph({ Title = "Performance", Desc = "FPS limiting" })

worldSection:Slider({
    Title = "FPS Limit",
    Value = { Min = 30, Max = 240, Default = 60 },
    Callback = function(value)
        _G.FPSLimit = value
        if setfpscap then
            setfpscap(value)
        end
    end
})

-- ============================================
-- SETTINGS TAB (Server & Utility only)
-- ============================================
local settingsSection = Tabs.SettingsTab:Section({ Title = "Server & Utility", Icon = "cog" })

-- Anti AFK (duplicate for settings tab)
settingsSection:Toggle({
    Title = "Anti-AFK",
    Default = false,
    Callback = function(state)
        _G.AntiIdle = state
    end
})

settingsSection:Divider()

-- Teleport to Hide Zone
settingsSection:Button({
    Title = "Teleport to Safe Zone",
    Callback = function()
        teleportToHidePart()
    end
})

settingsSection:Button({
    Title = "Reset Character",
    Callback = function()
        if player.Character then
            player.Character:BreakJoints()
            Window:Notify("Reset", "Character reset!", 2)
        end
    end
})

settingsSection:Divider()

-- Server Hops
settingsSection:Button({
    Title = "Server Hop",
    Callback = function()
        local req = syn and syn.request or http_request or request or httprequest
        local servers = {}
        local placeId = game.PlaceId

        if req then
            local cursor = ""
            for _ = 1, 3 do
                local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
                if cursor ~= "" then url = url .. "&cursor=" .. cursor end
                local ok, response = pcall(req, { Url = url, Method = "GET" })
                if not ok or not response or not response.Body then break end
                local ok2, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
                if not ok2 or not data or not data.data then break end
                for _, server in ipairs(data.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        table.insert(servers, server.id)
                    end
                end
                local nextCursor = data.nextPageCursor
                if not nextCursor or nextCursor == "" or nextCursor == "null" then break end
                cursor = tostring(nextCursor)
            end
        end

        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], player)
        else
            TeleportService:Teleport(placeId, player)
        end
        Window:Notify("Server Hop", "Joining new server...", 2)
    end
})

settingsSection:Button({
    Title = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, player)
        Window:Notify("Rejoin", "Rejoining server...", 2)
    end
})

-- ============================================
-- COMMUNITY TAB UI (Separate Tab)
-- ============================================
local communitySection = Tabs.CommunityTab:Section({ Title = "Join Community", Icon = "users" })

communitySection:Button({
    Title = "WhatsApp Group",
    Callback = function()
        if set_clipboard then
            set_clipboard("https://chat.whatsapp.com/Cxr7poqqID6Ha6C2MfFOMU")
            Window:Notify("Copied!", "WhatsApp link copied!", 2)
        end
    end
})

communitySection:Button({
    Title = "Discord Server",
    Callback = function()
        if set_clipboard then
            set_clipboard("https://discord.gg/eDbaHKEf7G")
            Window:Notify("Copied!", "Discord link copied!", 2)
        end
    end
})

communitySection:Button({
    Title = "TikTok @viunze",
    Callback = function()
        if set_clipboard then
            set_clipboard("https://tiktok.com/@viunze")
            Window:Notify("Copied!", "TikTok profile copied!", 2)
        end
    end
})

-- ============================================
-- ESP FUNCTIONS (Fixed with Colors & Text)
-- ============================================

-- Fungsi untuk membuat Highlight pada Zombie (Merah)
local function addZombieESP(zombie)
    if not zombie or not zombie.Parent then return end
    
    -- Hapus ESP lama jika ada
    local oldHighlight = zombie:FindFirstChild("Zombie_ESP")
    if oldHighlight then oldHighlight:Destroy() end
    
    -- Buat Highlight merah untuk zombie
    local highlight = Instance.new("Highlight")
    highlight.Name = "Zombie_ESP"
    highlight.Parent = zombie
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Merah
    highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
end

-- Fungsi untuk membuat ESP Player (Highlight Biru + Billboard Nama & Jarak)
local playerESPList = {} -- Untuk menyimpan BillboardGui yang sudah dibuat

local function addPlayerESP(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    
    local char = targetPlayer.Character
    local head = char:FindFirstChild("Head")
    if not head then return end
    
    -- Hapus ESP lama jika ada
    local oldHighlight = char:FindFirstChild("Player_ESP")
    if oldHighlight then oldHighlight:Destroy() end
    
    local oldBillboard = char:FindFirstChild("PlayerBillboard")
    if oldBillboard then oldBillboard:Destroy() end
    
    -- Buat Highlight biru untuk player
    local highlight = Instance.new("Highlight")
    highlight.Name = "Player_ESP"
    highlight.Parent = char
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Color3.fromRGB(0, 120, 255) -- Biru
    highlight.OutlineColor = Color3.fromRGB(100, 180, 255)
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
    
    -- Buat Billboard untuk menampilkan nama dan jarak
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerBillboard"
    billboard.Parent = head
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 300
    billboard.Enabled = true
    
    -- Frame untuk background
    local frame = Instance.new("Frame")
    frame.Name = "Frame"
    frame.Parent = billboard
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 5)
    uiCorner.Parent = frame
    
    -- Label Nama Player
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Parent = frame
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothomBold
    nameLabel.Text = targetPlayer.Name
    
    -- Label Jarak
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Parent = frame
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distanceLabel.TextStrokeTransparency = 0.5
    distanceLabel.TextScaled = true
    distanceLabel.Font = Enum.Font.Gothom
    distanceLabel.Text = "0 studs"
    
    -- Simpan data untuk update jarak
    playerESPList[targetPlayer] = {
        Billboard = billboard,
        DistanceLabel = distanceLabel,
        Character = char
    }
end

-- Fungsi untuk update jarak player ESP
local function updatePlayerDistance()
    local localChar = player.Character
    if not localChar then return end
    
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    
    for targetPlayer, data in pairs(playerESPList) do
        if targetPlayer and targetPlayer.Character and data.Character == targetPlayer.Character then
            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot and data.DistanceLabel then
                local distance = (localRoot.Position - targetRoot.Position).Magnitude
                data.DistanceLabel.Text = string.format("%.1f studs", distance)
            end
        else
            -- Hapus data jika player sudah tidak valid
            playerESPList[targetPlayer] = nil
        end
    end
end

-- Fungsi untuk membersihkan semua ESP
local function clearZombiesESP()
    local zombiesLocal = getZombiesLocal()
    if zombiesLocal then
        for _, v in ipairs(zombiesLocal:GetChildren()) do
            local esp = v:FindFirstChild("Zombie_ESP")
            if esp then esp:Destroy() end
        end
    end
end

local function clearPlayersESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local esp = p.Character:FindFirstChild("Player_ESP")
            if esp then esp:Destroy() end
            local billboard = p.Character:FindFirstChild("PlayerBillboard")
            if billboard then billboard:Destroy() end
        end
    end
    playerESPList = {}
end

-- ============================================
-- ANTI IDLE / AFK
-- ============================================
player.Idled:Connect(function()
    if _G.AntiIdle then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ============================================
-- INFINITE JUMP
-- ============================================
UIS.JumpRequest:Connect(function()
    if _G.Infjump then
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState("Jumping") end
        end
    end
end)

-- ============================================
-- AUTO EXECUTE ON TELEPORT
-- ============================================
player.OnTeleport:Connect(function(State)
    if _G.AutoExecute and (State == Enum.TeleportState.Started or State == Enum.TeleportState.InProgress) then
        local queue_func = queue_on_teleport or (syn and syn.queue_on_teleport)
        if queue_func then
            queue_func([[loadstring(game:HttpGet("https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua"))()]])
        end
    end
end)

-- ============================================
-- UPDATE DISTANCE EVERY FRAME
-- ============================================
RunService.Heartbeat:Connect(function()
    if _G.PlayersESP then
        updatePlayerDistance()
    end
end)

-- ============================================
-- MAIN LOOP (Heartbeat)
-- ============================================
RunService.Heartbeat:Connect(function()
    -- Update character references
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        character = player.Character
        if character then
            humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            humanoid = character:FindFirstChildOfClass("Humanoid")
        end
        return
    end
    
    -- Wave Farm position handling
    if not _G.WaveFarm then
        OldPosition = humanoidRootPart.CFrame
    end
    if _G.WaveFarm then
        humanoidRootPart.CFrame = CFrame.new(500, 0, -500)
        Workspace.Gravity = 0
        WaveFarm = true
    else
        if WaveFarm then
            humanoidRootPart.CFrame = OldPosition
            Workspace.Gravity = 196.2  -- Default gravity
            WaveFarm = false
        end
    end
    
    -- Auto Play Again
    if _G.AutoPlayAgain then
        pcall(function()
            ReplicatedStorage:WaitForChild("GameStateRemotes"):WaitForChild("VotePlayAgain"):FireServer()
        end)
    end
    
    -- Auto Reset After Wave
    if _G.AutoResetAfterWave then
        pcall(function()
            local mainGui = player.PlayerGui:FindFirstChild("MainGui")
            if mainGui then
                local waveLabel = mainGui:FindFirstChild("WaveLabel")
                if waveLabel and waveLabel.Text == "Wave " .. ((_G.ResetAfterWave or 50) + 1) .. " Has Started" then
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid.Health = 0
                    end
                end
            end
        end)
    end
    
    -- Auto Create Ship
    if _G.AutoCreateShip then
        pcall(function()
            local args = {
                _G.PlayersShip or 1,
                _G.GameplayMode or "Normal",
                _G.Map or "RooftopSiege"
            }
            ReplicatedStorage:WaitForChild("QueueRemotes"):WaitForChild("CreateParty"):FireServer(unpack(args))
        end)
    end
    
    -- Auto Void Shard
    if _G.AutoVoidShard and VoidShards then
        for _, v in ipairs(VoidShards:GetChildren()) do
            if v.Name == "VoidShardPart" and character and character:FindFirstChild("Head") then
                v.CFrame = character.Head.CFrame
                v.CanCollide = false
            end
        end
    end
    
    -- Safe Arena (HipHeight)
    if character:FindFirstChild("Humanoid") then
        character.Humanoid.HipHeight = _G.SafeArena and 15 or 0
    end
    
    -- Auto Open Galactic Crate
    if _G.AutoOpenGalacticCrate then
        pcall(function()
            ReplicatedStorage:WaitForChild("EventRemotes"):WaitForChild("GalacticRequestSpin"):InvokeServer()
        end)
    end
    
    -- Auto Skip Wave
    if _G.AutoSkipWave then
        pcall(function()
            ReplicatedStorage:WaitForChild("WaveRemotes"):WaitForChild("SkipVote"):FireServer(true)
        end)
    end
    
    -- ============================================
    -- ZOMBIES ESP (Highlight Merah) - FIXED with dynamic getZombiesLocal
    -- ============================================
    if _G.ZombiesESP then
        local zombiesLocal = getZombiesLocal()
        if zombiesLocal then
            for _, v in ipairs(zombiesLocal:GetChildren()) do
                if v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Head") then
                    addZombieESP(v)
                end
            end
        end
    else
        clearZombiesESP()
    end
    
    -- ============================================
    -- PLAYERS ESP (Highlight Biru + Nama & Jarak)
    -- ============================================
    if _G.PlayersESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                -- Cek apakah ESP sudah ada
                if not p.Character:FindFirstChild("Player_ESP") then
                    addPlayerESP(p)
                end
            end
        end
    else
        clearPlayersESP()
    end
    
    -- Walkspeed & JumpPower
    if character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = _G.WalkSpeed or 16
        character.Humanoid.JumpPower = _G.JumpPower or 50
    end
    
    -- FOV
    Workspace.CurrentCamera.FieldOfView = _G.FOV or 70
end)

-- ============================================
-- INSTANCE KILL THREAD (FIXED - Dynamic Zombies_Local)
-- ============================================
task.spawn(function()
    while task.wait(0.1) do
        if _G.InstanceKill then
            local zombiesLocal = getZombiesLocal()
            if zombiesLocal then
                for _, v in ipairs(zombiesLocal:GetChildren()) do
                    local id = tonumber(string.match(v.Name, "%d+$"))
                    if id then
                        pcall(function()
                            ReplicatedStorage.ZombieRemotes.ZombieDamage:FireServer(id, math.huge)
                        end)
                    end
                end
            end
        end
    end
end)

-- ============================================
-- KILL AURA THREAD (FIXED - Dynamic Zombies_Local + Health Check)
-- ============================================
task.spawn(function()
    while task.wait(0.1) do
        if _G.KillAura and character and character:FindFirstChild("HumanoidRootPart") then
            local zombiesLocal = getZombiesLocal()
            if zombiesLocal then
                for _, v in ipairs(zombiesLocal:GetChildren()) do
                    -- Cek apakah zombie masih hidup (punya HumanoidRootPart dan Health > 0)
                    local zroot = v:FindFirstChild("HumanoidRootPart")
                    local zhumanoid = v:FindFirstChildOfClass("Humanoid")
                    
                    if zroot and zhumanoid and zhumanoid.Health > 0 then
                        local distance = (character.HumanoidRootPart.Position - zroot.Position).Magnitude
                        if distance < (_G.KillAuraDistance or 1000) then
                            local tool = character:FindFirstChildOfClass("Tool")
                            if tool then
                                pcall(function()
                                    local id = tonumber(string.match(v.Name, "%d+$")) or 1
                                    -- Cek remote yang tersedia
                                    local gunRemotes = ReplicatedStorage:FindFirstChild("GunRemotes")
                                    if gunRemotes then
                                        local gunHit = gunRemotes:FindFirstChild("GunHit")
                                        if gunHit then 
                                            gunHit:FireServer(tool.Name, id, zroot.Position)
                                        end
                                        
                                        local meleeSwing = gunRemotes:FindFirstChild("MeleeSwing")
                                        if meleeSwing then 
                                            meleeSwing:FireServer("VoidScythe")
                                        end
                                        
                                        local gunFire = gunRemotes:FindFirstChild("GunFire")
                                        if gunFire then 
                                            gunFire:FireServer(tool.Name, character.HumanoidRootPart.Position)
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================
-- AUTO UPGRADE THREAD
-- ============================================
task.spawn(function()
    while task.wait(_G.SpamDelay or 1) do
        if _G.AutoUpgradeHealth then
            pcall(function()
                ReplicatedStorage:WaitForChild("UpgradeRemotes"):WaitForChild("PurchaseHealthUpgrade"):FireServer()
            end)
        end
        if _G.AutoUpgradeWeapon then
            pcall(function()
                ReplicatedStorage:WaitForChild("UpgradeRemotes"):WaitForChild("PurchaseWeaponUpgrade"):FireServer()
            end)
        end
        if _G.AutoAbilityE then
            pcall(function()
                local mainGui = player.PlayerGui:FindFirstChild("MainGui")
                if mainGui then
                    local controlPanel = mainGui:FindFirstChild("ControlPanel")
                    if controlPanel then
                        local gear1 = controlPanel:FindFirstChild("Gear1")
                        if gear1 then
                            local gearName = gear1:FindFirstChild("GearName")
                            if gearName then
                                local Gear1 = string.gsub(gearName.Text, "%s+", "")
                                ReplicatedStorage:WaitForChild("GearRemotes"):WaitForChild("GearPurchase"):FireServer(Gear1)
                            end
                        end
                    end
                end
            end)
        end
        if _G.AutoAbilityR then
            pcall(function()
                local mainGui = player.PlayerGui:FindFirstChild("MainGui")
                if mainGui then
                    local controlPanel = mainGui:FindFirstChild("ControlPanel")
                    if controlPanel then
                        local gear2 = controlPanel:FindFirstChild("Gear2")
                        if gear2 then
                            local gearName = gear2:FindFirstChild("GearName")
                            if gearName then
                                local Gear2 = string.gsub(gearName.Text, "%s+", "")
                                ReplicatedStorage:WaitForChild("GearRemotes"):WaitForChild("GearPurchase"):FireServer(Gear2)
                                ReplicatedStorage:WaitForChild("GearRemotes"):WaitForChild("GearPurchase"):FireServer("ShockwaveMine")
                            end
                        end
                    end
                end
            end)
        end
        if _G.AutoAbilityQ then
            pcall(function()
                local mainGui = player.PlayerGui:FindFirstChild("MainGui")
                if mainGui then
                    local controlPanel = mainGui:FindFirstChild("ControlPanel")
                    if controlPanel then
                        local gear3 = controlPanel:FindFirstChild("Gear3")
                        if gear3 then
                            local gearName = gear3:FindFirstChild("GearName")
                            if gearName then
                                local Gear3 = string.gsub(gearName.Text, "%s+", "")
                                ReplicatedStorage:WaitForChild("GearRemotes"):WaitForChild("GearPurchase"):FireServer(Gear3)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- WATCHER UNTUK ZOMBIES_LOCAL (Refresh otomatis)
-- ============================================
task.spawn(function()
    while task.wait(1) do
        if _G.KillAura or _G.InstanceKill then
            local zombiesLocal = getZombiesLocal()
            if not zombiesLocal then
                -- Tunggu folder muncul kembali
                repeat
                    task.wait(0.5)
                    zombiesLocal = getZombiesLocal()
                until zombiesLocal or not (_G.KillAura or _G.InstanceKill)
                if Window and zombiesLocal then
                    Window:Notify("Zombies", "Zombies folder detected!", 1)
                end
            end
        end
    end
end)

-- ============================================
-- CHARACTER RESPAWN HANDLER
-- ============================================
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    humanoidRootPart = char:WaitForChild("HumanoidRootPart")
    
    task.wait(0.5)
    pcall(function()
        humanoid.WalkSpeed = _G.WalkSpeed or 16
        humanoid.JumpPower = _G.JumpPower or 50
        humanoid.UseJumpPower = true
    end)
end)

-- ============================================
-- PLAYER ADDED/REMOVED HANDLER untuk ESP
-- ============================================
Players.PlayerAdded:Connect(function(newPlayer)
    if _G.PlayersESP and newPlayer ~= player then
        newPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if _G.PlayersESP and newPlayer.Character then
                addPlayerESP(newPlayer)
            end
        end)
    end
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
    if playerESPList[leavingPlayer] then
        playerESPList[leavingPlayer] = nil
    end
end)

-- ============================================
-- CREATE INITIAL HIDE PART
-- ============================================
createHidePart()

-- ============================================
-- INITIAL NOTIFICATION
-- ============================================
task.wait(1)
Window:Notify("PinatHub", "Loaded!", 3)
