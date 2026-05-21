repeat task.wait() until game:IsLoaded()

-- =======================================================
-- PINATHUB | SOLO HUNTER (INTEGRATED)
-- =======================================================

-- ============================================
-- SERVICES
-- ============================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- EXECUTOR COMPATIBILITY
-- ============================================
local function noop() end
local get_hui = gethui or (syn and syn.gethui) or noop
local set_clipboard = setclipboard or (syn and syn.setclipboard) or noop
local get_connections = getconnections or (syn and syn.getconnections) or noop

-- ============================================
-- PLAYER VARIABLES
-- ============================================
local player = LocalPlayer
local UIS = UserInputService
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local Joined = false

-- ============================================
-- PROTECTION CONSTANTS
-- ============================================
local ProtectName = "Protect by Forge Hub"
local ForgeHub_Image = "rbxassetid://88704482117379"

-- ============================================
-- FLY SYSTEM VARIABLES
-- ============================================
local flying = false
local bv, bg
local keys = {
    W = false, A = false, S = false, D = false,
    Space = false, Ctrl = false
}

-- ============================================
-- COLLECTION UTILITIES (Solo Hunter)
-- ============================================
local Collection = {}
Collection.__index = Collection

function Collection:IsTeleporting()
    if LocalPlayer:GetAttribute("DungeonId") == (nil or "") then
        return false
    else
        return true 
    end
end

function Collection:RewriteSynxtaxe(str)
    return string.lower(str):gsub("%s+", "")
end

function Collection:IsReturnPortal()
    for _, v in pairs(workspace:GetChildren()) do
        if v.Name == "OverworldPortal" then
            print("Is havz for exit")
            return true
        end
    end
    print("not Door exit")
    return false
end

function Collection:CheckDistanceFrom(a, b, distance)
    if (a.Position - b.Position).Magnitude <= distance then
        return true
    else
        return false
    end
end

function Collection:InstantTeleportTo(pos)
    if LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
        LocalPlayer.Character.HumanoidRootPart.CFrame = pos
    end
end

-- Best Equipment Lists
local ListSword = {
    "Shadow Scrythe",
    "Dual Daggers",
    "Thunder Axe",
    "Venom Fang",
    "Carmesi Katana",
    "King's Trident",
    "Link Sword",
    "Demon King Daggers",
    "Diamond Dagger",
    "Pesand Sword"
}
local List_Helmet = {
    "Serpent Helmet",
    "Venomspike Helmet",
    "Astral Helmet",
    "Iron Helmet"
}
local List_Chestplate = {
    "Serpent Chestplate",
    "Venomspike Chestplate",
    "Astral Chestplate",
    "Iron Chestplate"
}
local List_Leggings = {
    "Serpent Leggings",
    "Venomspike Leggings",
    "Astral Leggings",
    "Iron Leggings"
}

function Collection:EquipBestArmor()
    pcall(function()
        for _, v1 in ipairs(List_Helmet) do
            if LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild(v1) then
                ReplicatedStorage.RemoteServices.InventoryService.RF.Equip:InvokeServer("Helmet", v1)
                break
            end
        end
        for _, v2 in ipairs(List_Chestplate) do
            if LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild(v2) then
                ReplicatedStorage.RemoteServices.InventoryService.RF.Equip:InvokeServer("Chestplate", v2)
                break
            end
        end
        for _, v3 in ipairs(List_Leggings) do
            if LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild(v3) then
                ReplicatedStorage.RemoteServices.InventoryService.RF.Equip:InvokeServer("Leggings", v3)
                break
            end
        end
    end)
end

function Collection:EquipBestSword()
    pcall(function()
        for _, v in ipairs(ListSword) do
            if not LocalPlayer.Backpack:FindFirstChild(v) then
                ReplicatedStorage.RemoteServices.InventoryService.RF.Equip:InvokeServer("Weapon", v)
                break
            end
        end
    end)
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
logoButton.Size = UDim2.new(0, 60, 0, 60)
logoButton.Position = UDim2.new(0.5, -30, 0.5, -30)
logoButton.BackgroundTransparency = 1
logoButton.Image = "rbxassetid://118264723961739"
logoButton.ImageColor3 = Color3.fromRGB(180, 0, 255)
logoButton.ScaleType = Enum.ScaleType.Fit
logoButton.Parent = logoGui

local uiCornerLogo = Instance.new("UICorner")
uiCornerLogo.CornerRadius = UDim.new(1, 0)
uiCornerLogo.Parent = logoButton

local hoverTween = TweenService:Create(logoButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 70, 0, 70)})
local unhoverTween = TweenService:Create(logoButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)})

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
        if input.UserInputType == Enum.UserInputType.MouseMovement then
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
local WindUI = loadstring(game:HttpGet('https://github.com/Footagesus/WindUI/releases/latest/download/main.lua'))()

local window = WindUI:CreateWindow({
    Title = "PinatHub",
    Author = "@viunze on tiktok",
    Folder = "pinathub_solohunter",
    Size = UDim2.fromOffset(600, 550),
    Transparent = false,
    Theme = "Dark",
    IsOpenButtonEnabled = false,
    User = {Enabled = true, Anonymous = true},
    SideBarWidth = 150,
})

local guiVisible = true
logoButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    if window then
        pcall(function()
            if guiVisible then
                window:Open()
            else
                window:Minimize()
            end
        end)
    end
end)

-- Create Tabs
local tabs = {
    main = window:Tab({Title = "Main", Icon = "sword"}),
    stats = window:Tab({Title = "Stats", Icon = "bar-chart-2"}),
    items = window:Tab({Title = "Items", Icon = "package"}),
    merchant = window:Tab({Title = "Merchant", Icon = "shopping-cart"}),
    misc = window:Tab({Title = "Misc", Icon = "settings"}),
    community = window:Tab({Title = "Community", Icon = "users"}),
    settings = window:Tab({Title = "Settings", Icon = "cog"}),
}

-- ============================================
-- STATE VARIABLES
-- ============================================
-- Dungeon Settings
local choosendungeon = "Subway"
local choosendungeonrank = "F"
local autofarmdungeon = false
local autojoindungeon = false
local autostartdungeon = false
local autoleavedungeon = false
local AutoOpenChest = false

-- Monster Settings
local AutoFarmMonster = false
local AutoAttackMonster = false
local normalattack = false
local KillAura = false

-- Stats Settings
local PointAmount = 1
local choosenstats = "Strength"
local autostats = false

-- Merchant Settings
local chooseItems = nil
local AutoBuy = false

-- Protection Settings
local enableprotection = false

-- Camera Settings
local Camera_Zoom = 100

-- Fly Settings
local FlySpeed = 50
local enablefly = false

-- Player Settings
local speedchanger = 13
local enablespeed = false
local jumppowerchanger = 13
local enablejumppower = false

-- Item Settings
local choosesword = nil
local AutoEquipSword = false
local AutoEquipArmor = false
local AutoSellLoot = false
local autotakesubwayquest = false

-- Dungeon Map
local DungeonMap = {
    Subway = "Subway",
    Caves = "Cave",
    Desert = "Desert",
    Jungle = "Jungle",
    WolfCave = "Wolf",
    SpiderCave = "Spider"
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function SendClick()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

-- ============================================
-- DUNGEON AUTO FARM LOOP
-- ============================================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if autofarmdungeon then
                local SelectedDungeonIs = choosendungeon
                local SelectRankIs = choosendungeonrank
                local Alrin = false
                local TransformedNameDungeonIs = DungeonMap[SelectedDungeonIs]
                if workspace:FindFirstChild("PortalSpawns") and workspace.PortalSpawns:FindFirstChild("Normal") then
                    for _, PortalSpawns in pairs(workspace.PortalSpawns.Normal:GetChildren()) do
                        local realPortal = Collection:RewriteSynxtaxe(PortalSpawns.Name)
                        local formattedDungeon = Collection:RewriteSynxtaxe(TransformedNameDungeonIs)
                        local rankAttribute = PortalSpawns:GetAttribute("Rank")
                        if string.find(realPortal, formattedDungeon, 1, true) and rankAttribute == SelectRankIs then
                            if not Alrin and LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = PortalSpawns.CFrame
                                Alrin = true
                            end
                            if autojoindungeon and not Joined then
                                task.wait(0.4)
                                local portalId = "N_" .. PortalSpawns.Name
                                ReplicatedStorage.RemoteServices.PortalService.RF.QueuePortal:InvokeServer(portalId)
                                task.wait(0.5)
                                ReplicatedStorage.RemoteServices.PortalService.RF.EnterPortal:InvokeServer(portalId)
                                task.wait(0.2)
                                Joined = true
                                break
                            end
                            task.wait(6)
                        end
                    end
                end
            end
        end)
    end
end)

-- Auto Start Dungeon
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if autostartdungeon then
                local Event = game:GetService("ReplicatedStorage").RemoteServices.DungeonService.RF.StartDungeon
                Event:InvokeServer()
            end
        end)
    end
end)

-- Auto Leave Dungeon
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if autoleavedungeon then
                if Collection:IsReturnPortal() then
                    local Event = game:GetService("ReplicatedStorage").RemoteServices.DungeonService.RF.TeleportToLobby
                    Event:InvokeServer()
                    Joined = false
                end
            end
        end)
    end
end)

-- Auto Open Chest
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if AutoOpenChest then
                for _, v in pairs(workspace:GetChildren()) do
                    if string.find(v.Name, "Chest") and v:IsA("Model") then
                        local OwwnerAttributes = v:GetAttribute("Owner")
                        local KnowChestAttributes = v:GetAttribute("ChestUUID")
                        if OwwnerAttributes == LocalPlayer.Name then
                            local RemoteNameChest = KnowChestAttributes
                            Collection:InstantTeleportTo(v.Part.CFrame + Vector3.new(0, 3, 0))
                            task.wait(0.15)
                            ReplicatedStorage.RemoteServices.BossDropsService.RF.OpenChest:InvokeServer(RemoteNameChest)
                            Joined = false
                        end
                    end
                end
            end
        end)
    end
end)

-- Auto Farm Monster
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if AutoFarmMonster and LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
                if workspace:FindFirstChild("Mobs") then
                    for i, v in pairs(workspace.Mobs:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 350 then
                            repeat task.wait()
                                Collection:InstantTeleportTo(v.HumanoidRootPart.CFrame)
                            until not v or not v.Parent or not AutoFarmMonster
                        end
                    end
                end
            end
        end)
    end
end)

-- Fast Attack Monster
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if AutoAttackMonster and workspace:FindFirstChild("Mobs") then
                local targets = {}
                for i, v in pairs(workspace.Mobs:GetChildren()) do
                    table.insert(targets, v)
                end
                if #targets > 0 then
                    local Event = game:GetService("ReplicatedStorage").RemoteServices.CombatService.RF.UseWeapon
                    Event:InvokeServer(10, targets, 10)
                end
            end
        end)
    end
end)

-- Normal Attack Monster
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if normalattack then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.1)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end)
    end
end)

-- Kill Aura
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if KillAura and workspace:FindFirstChild("Mobs") then
                for i, v in pairs(workspace.Mobs:GetChildren()) do
                    if v:FindFirstChild("Humanoid") then
                        sethiddenproperty(Players.LocalPlayer, "SimulationRadius", 5000)
                        sethiddenproperty(LocalPlayer, "MaxSimulationRadius", 5000)
                        v.Humanoid.Health = 0
                    end
                end
            end
        end)
    end
end)

-- Auto Stats
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if autostats then
                local Event = game:GetService("ReplicatedStorage").RemoteServices.InventoryService.RF.UseSkillPoints
                Event:InvokeServer({ [choosenstats] = PointAmount })
            end
        end)
    end
end)

-- Auto Buy
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            if AutoBuy and chooseItems then
                local Event = game:GetService("ReplicatedStorage").RemoteServices.MerchantService.RF.Buy
                Event:InvokeServer(chooseItems)
            end
        end)
    end
end)

-- Protection System
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if enableprotection then 
                if LocalPlayer.DisplayName ~= ProtectName then
                    LocalPlayer.DisplayName = ProtectName
                end
                local LeaderStats = LocalPlayer:FindFirstChild("leaderstats")
                if LeaderStats then
                    for _, Stats in pairs(LeaderStats:GetChildren()) do
                        if Stats.Name ~= ProtectName then
                            Stats.Name = ProtectName
                        end
                    end
                end
            end
        end)
    end
end)

-- Camera Zoom
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if Camera_Zoom and LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.CameraMaxZoomDistance = Camera_Zoom
                end
            end
        end)
    end
end)

-- Speed Changer
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if enablespeed and LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = speedchanger
                end
            end
        end)
    end
end)

-- Jump Power Changer
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if enablejumppower and LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.JumpPower = jumppowerchanger
                end
            end
        end)
    end
end)

-- Auto Equip Best Sword/Armor
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            if AutoEquipSword then
                Collection:EquipBestSword()
            end
            if AutoEquipArmor then
                Collection:EquipBestArmor()
            end
        end)
    end
end)

-- Auto Sell Loot
task.spawn(function()
    while task.wait(10) do
        pcall(function()
            if AutoSellLoot then
                game:GetService("ReplicatedStorage").RemoteServices.InventoryService.RF.SellAllLootMaterial:FireServer()
            end
        end)
    end
end)

-- Auto Take Quest
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if autotakesubwayquest then
                game:GetService("ReplicatedStorage").RemoteServices.OnboardingService.RF.TalkedToTin:InvokeServer()
                task.wait(0.3)
                game:GetService("ReplicatedStorage").RemoteServices.QuestsV2Service.RF.MarkGiverViewed:InvokeServer("Subway")
                task.wait(0.5)
                game:GetService("ReplicatedStorage").RemoteServices.QuestsV2Service.RF.RequestQuest:InvokeServer("Subway")
            end
        end)
    end
end)

-- ============================================
-- FLY SYSTEM
-- ============================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.W then keys.W = true end
    if input.KeyCode == Enum.KeyCode.A then keys.A = true end
    if input.KeyCode == Enum.KeyCode.S then keys.S = true end
    if input.KeyCode == Enum.KeyCode.D then keys.D = true end
    if input.KeyCode == Enum.KeyCode.Space then keys.Space = true end
    if input.KeyCode == Enum.KeyCode.LeftControl then keys.Ctrl = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then keys.W = false end
    if input.KeyCode == Enum.KeyCode.A then keys.A = false end
    if input.KeyCode == Enum.KeyCode.S then keys.S = false end
    if input.KeyCode == Enum.KeyCode.D then keys.D = false end
    if input.KeyCode == Enum.KeyCode.Space then keys.Space = false end
    if input.KeyCode == Enum.KeyCode.LeftControl then keys.Ctrl = false end
end)

RunService.RenderStepped:Connect(function()
    if enablefly and LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
        if not flying then
            flying = true

            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.zero
            bv.Parent = LocalPlayer.Character.HumanoidRootPart

            bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            bg.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            bg.Parent = LocalPlayer.Character.HumanoidRootPart
        end

        local cam = workspace.CurrentCamera
        local dir = Vector3.zero

        if keys.W then dir += cam.CFrame.LookVector end
        if keys.S then dir -= cam.CFrame.LookVector end
        if keys.A then dir -= cam.CFrame.RightVector end
        if keys.D then dir += cam.CFrame.RightVector end
        if keys.Space then dir += Vector3.new(0,1,0) end
        if keys.Ctrl then dir -= Vector3.new(0,1,0) end

        if dir.Magnitude > 0 then
            dir = dir.Unit * FlySpeed
        end

        bv.Velocity = dir
        bg.CFrame = cam.CFrame
    elseif flying then
        flying = false
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end 
    end
end)

-- ============================================
-- UI SECTIONS - MAIN TAB
-- ============================================
local mainSection = tabs.main:Section({Title = "Dungeon Setup"})

-- Dungeon Dropdown
local dungeons = {"Subway", "Caves", "Desert", "Jungle", "WolfCave", "SpiderCave"}
mainSection:Dropdown({
    Title = "Choose Dungeon",
    Values = dungeons,
    Default = 1,
    Callback = function(value)
        choosendungeon = value
    end
})

-- Rank Dropdown
local ranks = {"F", "F+", "E", "E+", "D", "D+", "C", "C+", "B", "B+", "A", "A+", "S", "S+", "S++", "S+++"}
mainSection:Dropdown({
    Title = "Choose Dungeon Rank",
    Values = ranks,
    Default = 1,
    Callback = function(value)
        choosendungeonrank = value
    end
})

mainSection:Divider()

local dungeonSection = tabs.main:Section({Title = "Dungeon Farm"})

dungeonSection:Toggle({
    Title = "Auto Farm Dungeon",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        autofarmdungeon = state
        window:Notify("Auto Farm Dungeon", state and "Enabled" or "Disabled", 2)
    end
})

dungeonSection:Toggle({
    Title = "Auto Join Dungeon",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        autojoindungeon = state
        window:Notify("Auto Join Dungeon", state and "Enabled" or "Disabled", 2)
    end
})

dungeonSection:Toggle({
    Title = "Auto Start Dungeon",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        autostartdungeon = state
        window:Notify("Auto Start Dungeon", state and "Enabled" or "Disabled", 2)
    end
})

dungeonSection:Toggle({
    Title = "Auto Leave Dungeon",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        autoleavedungeon = state
        window:Notify("Auto Leave Dungeon", state and "Enabled" or "Disabled", 2)
    end
})

dungeonSection:Toggle({
    Title = "Auto Open Chest",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoOpenChest = state
        window:Notify("Auto Open Chest", state and "Enabled" or "Disabled", 2)
    end
})

local monsterSection = tabs.main:Section({Title = "Monster Farm"})

monsterSection:Toggle({
    Title = "Auto Farm Monster",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoFarmMonster = state
        window:Notify("Auto Farm Monster", state and "Enabled" or "Disabled", 2)
    end
})

monsterSection:Toggle({
    Title = "Fast Attack Monster",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoAttackMonster = state
        window:Notify("Fast Attack Monster", state and "Enabled" or "Disabled", 2)
    end
})

monsterSection:Toggle({
    Title = "Normal Attack Monster",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        normalattack = state
        window:Notify("Normal Attack", state and "Enabled" or "Disabled", 2)
    end
})

monsterSection:Toggle({
    Title = "Enable Kill Aura",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        KillAura = state
        window:Notify("Kill Aura", state and "Enabled" or "Disabled", 2)
    end
})

-- ============================================
-- STATS TAB
-- ============================================
local statsSection = tabs.stats:Section({Title = "Stats Manager"})

statsSection:Slider({
    Title = "Point Amount",
    Value = {Min = 0, Max = 10, Default = 1, Decimals = 0},
    Callback = function(v)
        PointAmount = v
    end
})

local statsList = {"Magic", "Strength", "Defense", "Agility", "Energy"}
statsSection:Dropdown({
    Title = "Choose Stats",
    Values = statsList,
    Default = 2,
    Callback = function(value)
        choosenstats = value
    end
})

statsSection:Toggle({
    Title = "Enable Auto Stats",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        autostats = state
        window:Notify("Auto Stats", state and "Enabled" or "Disabled", 2)
    end
})

-- ============================================
-- ITEMS TAB
-- ============================================
local swordSection = tabs.items:Section({Title = "Sword Manager"})

local SwordList = {}
pcall(function()
    if ReplicatedStorage and ReplicatedStorage.ReplicatedStorage and ReplicatedStorage.ReplicatedStorage.Storage and ReplicatedStorage.ReplicatedStorage.Storage.Weapons then
        for i, v in pairs(ReplicatedStorage.ReplicatedStorage.Storage.Weapons:GetChildren()) do
            table.insert(SwordList, v.Name)
        end
    end
end)

if #SwordList > 0 then
    swordSection:Dropdown({
        Title = "Choose Sword To Equip",
        Values = SwordList,
        Default = 1,
        Callback = function(value)
            choosesword = value
        end
    })

    swordSection:Button({
        Title = "Equip Chosen Sword",
        Callback = function()
            if choosesword then
                pcall(function()
                    local Event = game:GetService("ReplicatedStorage").RemoteServices.InventoryService.RF.Equip
                    Event:InvokeServer("Weapon", choosesword)
                    window:Notify("Equip Sword", "Equipped " .. choosesword, 2)
                end)
            end
        end
    })
end

swordSection:Divider()

local sellSection = tabs.items:Section({Title = "Sell Manager"})

sellSection:Button({
    Title = "Sell All Loot Materials",
    Callback = function()
        pcall(function()
            game:GetService("ReplicatedStorage").RemoteServices.InventoryService.RF.SellAllLootMaterial:FireServer()
            window:Notify("Sell", "Sold all loot materials!", 2)
        end)
    end
})

sellSection:Toggle({
    Title = "Auto Sell Loot Materials",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoSellLoot = state
        window:Notify("Auto Sell", state and "Enabled" or "Disabled", 2)
    end
})

local equipSection = tabs.items:Section({Title = "Best Equipment"})

equipSection:Button({
    Title = "Equip Best Sword",
    Callback = function()
        Collection:EquipBestSword()
        window:Notify("Equip", "Equipping best sword...", 2)
    end
})

equipSection:Button({
    Title = "Equip Best Armor",
    Callback = function()
        Collection:EquipBestArmor()
        window:Notify("Equip", "Equipping best armor...", 2)
    end
})

local autoEquipSection = tabs.items:Section({Title = "Auto Equip"})

autoEquipSection:Toggle({
    Title = "Auto Equip Best Sword",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoEquipSword = state
        window:Notify("Auto Equip Sword", state and "Enabled" or "Disabled", 2)
    end
})

autoEquipSection:Toggle({
    Title = "Auto Equip Best Armor",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoEquipArmor = state
        window:Notify("Auto Equip Armor", state and "Enabled" or "Disabled", 2)
    end
})

local questSection = tabs.items:Section({Title = "Quest"})

questSection:Toggle({
    Title = "Auto Take Subway Quest",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        autotakesubwayquest = state
        window:Notify("Auto Quest", state and "Enabled" or "Disabled", 2)
    end
})

-- ============================================
-- MERCHANT TAB
-- ============================================
local shopSection = tabs.merchant:Section({Title = "Shop"})

local TableItemsShop = {}
pcall(function()
    local MerchantItems = require(ReplicatedStorage.ReplicatedStorage.Modules.Shared.Data.MerchantItems)
    for _, item in pairs(MerchantItems.Normal) do
        if type(item) == "table" and item.Base then
            table.insert(TableItemsShop, item.Base)
        end
    end
end)

if #TableItemsShop > 0 then
    shopSection:Dropdown({
        Title = "Choose Items To Buy",
        Values = TableItemsShop,
        Default = 1,
        Callback = function(value)
            chooseItems = value
        end
    })

    shopSection:Button({
        Title = "Buy Item Once",
        Callback = function()
            if chooseItems then
                pcall(function()
                    local Event = game:GetService("ReplicatedStorage").RemoteServices.MerchantService.RF.Buy
                    Event:InvokeServer(chooseItems)
                    window:Notify("Buy", "Bought " .. chooseItems, 2)
                end)
            end
        end
    })
end

local autoBuySection = tabs.merchant:Section({Title = "Auto Buy"})

autoBuySection:Toggle({
    Title = "Auto Buy Selected Item",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoBuy = state
        window:Notify("Auto Buy", state and "Enabled" or "Disabled", 2)
    end
})

-- ============================================
-- MISC TAB
-- ============================================
local protectionSection = tabs.misc:Section({Title = "Protection"})

protectionSection:Toggle({
    Title = "Enable Protection",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        enableprotection = state
        window:Notify("Protection", state and "Enabled" or "Disabled", 2)
    end
})

local cameraSection = tabs.misc:Section({Title = "Camera"})

cameraSection:Slider({
    Title = "Maximum Zoom Distance",
    Value = {Min = 10, Max = 1000, Default = 100, Decimals = 1},
    Callback = function(v)
        Camera_Zoom = v
    end
})

local flySection = tabs.misc:Section({Title = "Fly"})

flySection:Slider({
    Title = "Fly Speed",
    Value = {Min = 10, Max = 500, Default = 50, Decimals = 1},
    Callback = function(v)
        FlySpeed = v
    end
})

flySection:Toggle({
    Title = "Enable Fly",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        enablefly = state
        window:Notify("Fly", state and "Enabled (WASD + Space/Ctrl)" or "Disabled", 3)
    end
})

local playerSectionMisc = tabs.misc:Section({Title = "Player"})

playerSectionMisc:Slider({
    Title = "Speed Changer",
    Value = {Min = 1, Max = 300, Default = 13, Decimals = 1},
    Callback = function(v)
        speedchanger = v
    end
})

playerSectionMisc:Toggle({
    Title = "Enable Speed Changer",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        enablespeed = state
        window:Notify("Speed Changer", state and "Enabled" or "Disabled", 2)
    end
})

playerSectionMisc:Slider({
    Title = "Jump Power Changer",
    Value = {Min = 1, Max = 300, Default = 13, Decimals = 1},
    Callback = function(v)
        jumppowerchanger = v
    end
})

playerSectionMisc:Toggle({
    Title = "Enable Jump Power Changer",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        enablejumppower = state
        window:Notify("Jump Power", state and "Enabled" or "Disabled", 2)
    end
})

-- ============================================
-- COMMUNITY TAB
-- ============================================
local communitySection = tabs.community:Section({Title = "Join Community"})

communitySection:Button({
    Title = "WhatsApp Group",
    Callback = function()
        if set_clipboard then
            set_clipboard("https://chat.whatsapp.com/IxGN8uGjXL74Hwa3sxElLG")
            window:Notify("Copied!", "WhatsApp link copied!", 2)
        end
    end
})

communitySection:Button({
    Title = "Discord Server",
    Callback = function()
        if set_clipboard then
            set_clipboard("https://discord.gg/emK8k3smfk")
            window:Notify("Copied!", "Discord link copied!", 2)
        end
    end
})

communitySection:Button({
    Title = "TikTok @viunze",
    Callback = function()
        if set_clipboard then
            set_clipboard("https://tiktok.com/@viunze")
            window:Notify("Copied!", "TikTok profile copied!", 2)
        end
    end
})

-- ============================================
-- SETTINGS TAB
-- ============================================
local moveSection = tabs.settings:Section({Title = "Character Settings"})

local walkSpeedValue = 16
moveSection:Slider({
    Title = "Walk Speed (16-250)",
    Value = {Min = 16, Max = 250, Default = 16, Decimals = 0},
    Callback = function(v)
        walkSpeedValue = v
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end
})

local jumpPowerValue = 50
moveSection:Slider({
    Title = "Jump Power (0-500)",
    Value = {Min = 0, Max = 500, Default = 50, Decimals = 0},
    Callback = function(v)
        jumpPowerValue = v
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = v
                hum.UseJumpPower = true
            end
        end
    end
})

moveSection:Button({
    Title = "Reset Character",
    Callback = function()
        if player.Character then
            player.Character:BreakJoints()
            window:Notify("Reset", "Character reset!", 2)
        end
    end
})

moveSection:Divider()

local serverSection = tabs.settings:Section({Title = "Server"})

local antiAFKActive = false
serverSection:Toggle({
    Title = "Anti-AFK",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        antiAFKActive = state
        if state then
            task.spawn(function()
                while antiAFKActive do
                    task.wait(60)
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    end)
                end
            end)
        end
    end
})

serverSection:Button({
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
        window:Notify("Server Hop", "Joining new server...", 2)
    end
})

serverSection:Button({
    Title = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, player)
        window:Notify("Rejoin", "Rejoining server...", 2)
    end
})

-- ============================================
-- CHARACTER RESPAWN HANDLER
-- ============================================
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 10)
    task.wait(0.5)
    pcall(function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = walkSpeedValue
            hum.JumpPower = jumpPowerValue
            hum.UseJumpPower = true
        end
    end)
end)

-- ============================================
-- INITIAL NOTIFICATION
-- ============================================
task.wait(1)
window:Notify("PinatHub", "Loaded!", 3)
window:Open()
