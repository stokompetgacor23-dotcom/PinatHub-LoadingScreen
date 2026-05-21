repeat task.wait() until game:IsLoaded()

-- =======================================================
-- PINATHUB | SLIME RNG
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
-- LOGO LAUNCHER PINATHUB
-- ============================================
local logoGui = Instance.new("ScreenGui")
logoGui.Name = "PinatHubLogo"
logoGui.ResetOnSpawn = false
logoGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5)

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

UserInputService.InputChanged:Connect(function(input)
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
    Folder = "pinathub_slimerng",
    Size = UDim2.fromOffset(650, 600),
    Transparent = false,
    Theme = "Dark",
    IsOpenButtonEnabled = false,
    User = {Enabled = true, Anonymous = true},
    SideBarWidth = 160,
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
    home = window:Tab({Title = "Home", Icon = "house"}),
    main = window:Tab({Title = "Main", Icon = "landmark"}),
    automatic = window:Tab({Title = "Automatic", Icon = "play"}),
    webhook = window:Tab({Title = "Webhook", Icon = "webhook"}),
    misc = window:Tab({Title = "Misc", Icon = "layout-grid"}),
    settings = window:Tab({Title = "Settings", Icon = "cog"}),
    community = window:Tab({Title = "Community", Icon = "users"}),
}

-- ============================================
-- NETWORK REMOTES
-- ============================================
local networker = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("leifstout_networker@0.3.1"):WaitForChild("networker"):WaitForChild("_remotes")
local upgradeRemote = networker:WaitForChild("UpgradeService"):WaitForChild("RemoteFunction")
local rollRemote = networker:WaitForChild("RollService"):WaitForChild("RemoteFunction")
local boostRemote = networker:WaitForChild("BoostService"):WaitForChild("RemoteFunction")
local indexRemote = networker:WaitForChild("IndexService"):WaitForChild("RemoteFunction")
local zonesRemote = networker:WaitForChild("ZonesService"):WaitForChild("RemoteFunction")
local inventoryRemote = networker:WaitForChild("InventoryService"):WaitForChild("RemoteFunction")
local craftingRemote = networker:WaitForChild("CraftingService"):WaitForChild("RemoteFunction")
local offlineRemote = networker:WaitForChild("OfflineEarningsService"):WaitForChild("RemoteFunction")
local codeRemote = networker:WaitForChild("CodeService"):WaitForChild("RemoteFunction")
local lootRemote = networker:WaitForChild("LootService"):WaitForChild("RemoteFunction")

-- ============================================
-- STATE VARIABLES
-- ============================================
local player = LocalPlayer
local clientHRP = nil

-- Home Settings
local walkSpeedValue = 16
local jumpPowerValue = 50

-- Main Settings
local autoRollEnabled = false
local autoRollGamesEnabled = false
local hideRollEnabled = false
local autoIndexEnabled = false
local autoFarmEnabled = false
local autoBestZoneEnabled = false
local autoBestZoneInterval = 30
local autoPotionsEnabled = false
local autoShootEnabled = false
local autoLootEnabled = false
local slimeMagnetEnabled = false
local shootRadius = 17

-- Automatic Settings
local autoUpgradeEnabled = false
local autoUpgradeInterval = 30
local autoBuyZoneEnabled = false
local autoRebirthEnabled = false
local autoEquipBestEnabled = false
local autoClaimOfflineEnabled = false

-- Webhook Settings
local webhookEnabled = false
local webhookUrl = ""
local webhookInterval = 30

-- Misc Settings
local infJumpEnabled = false
local noclipEnabled = false
local antiAFKEnabled = false
local autoReconnectEnabled = false
local afkConnection = nil

-- ============================================
-- HELPER FUNCTIONS
-- ============================================
local function updateCharacter()
    local char = player.Character
    if char then
        clientHRP = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = walkSpeedValue
            hum.JumpPower = jumpPowerValue
            hum.UseJumpPower = true
        end
    end
end

local function getUpgradeTiles()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    local root = playerGui:FindFirstChild("Root")
    if not root then return nil end
    local upgradeScreen = root:FindFirstChild("UpgradeScreen")
    if not upgradeScreen then return nil end
    local upgradeContent = upgradeScreen:FindFirstChild("UpgradeContent")
    if not upgradeContent then return nil end
    local frame = upgradeContent:FindFirstChild("Frame")
    if not frame then return nil end
    return frame:GetChildren()
end

local function Upgrade()
    local upgradeTiles = getUpgradeTiles()
    if upgradeTiles then
        for _, tile in pairs(upgradeTiles) do
            if tile.Name ~= "UIAspectRatioConstraint" and tile.Name ~= "UpgradeHoverInfo" then
                local upgrade = tile.Name:match("^(%S+)Tile")
                if upgrade then
                    pcall(function()
                        upgradeRemote:InvokeServer("requestUnlock", upgrade)
                    end)
                end
            end
        end
    end
end

local function Roll()
    pcall(function()
        rollRemote:InvokeServer("requestRoll")
    end)
end

local function ConsumePotions()
    local boosts = {"luck", "ultraLuck", "currency", "rollSpeed"}
    for _, boost in ipairs(boosts) do
        pcall(function()
            boostRemote:InvokeServer("requestUseBoost", boost)
        end)
        task.wait(0.1)
    end
end

local function ClaimIndex()
    local rewards = {"basic", "big", "huge", "shiny", "inverted"}
    for _, reward in ipairs(rewards) do
        pcall(function()
            indexRemote:InvokeServer("requestClaimReward", reward)
        end)
        task.wait(0.1)
    end
end

local function TeleportBestZone()
    local zones = workspace:FindFirstChild("Zones")
    if not zones then return end
    local zonesList = zones:GetChildren()
    local returnZones = {}
    for _, zone in pairs(zonesList) do
        local blockerName = "ClientGateBlocker_" .. zone.Name
        local gate = zone:FindFirstChild("Gate")
        if gate then
            local blocker = gate:FindFirstChild(blockerName)
            if blocker then
                table.insert(returnZones, blocker)
            end
        end
    end
    local counter = 0
    for _, gateBlocker in pairs(returnZones) do
        if gateBlocker.CanCollide ~= true then
            local zoneParent = gateBlocker.Parent and gateBlocker.Parent.Parent
            if zoneParent and tonumber(zoneParent.Name) and tonumber(zoneParent.Name) > counter then
                counter = tonumber(zoneParent.Name)
            end
        end
    end
    counter = counter + 1
    pcall(function()
        zonesRemote:InvokeServer("requestTeleportZone", counter)
    end)
end

local function getUserTime()
    return os.date(" at %I:%M %p, %m/%d/%Y")
end

local function SendDiscordWebhook(url, data)
    local body = HttpService:JSONEncode({
        username = "PinatHub",
        avatar_url = "https://cdn.discordapp.com/attachments/1429845065752117268/1479099416055906334/Tak_berjudul76_20260203000028.png",
        embeds = {{
            title = "PinatHub | Slime RNG",
            color = 65280,
            fields = {
                { name = "Player", value = player.Name, inline = false },
                { name = "Rolls", value = data.description, inline = false }
            },
            footer = { text = "PinatHub Webhook" .. getUserTime() }
        }}
    })
    pcall(function()
        request({
            Url = url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = body
        })
    end)
end

-- ============================================
-- ANTI AFK
-- ============================================
local function startAntiAFK()
    if afkConnection then
        afkConnection:Disconnect()
        afkConnection = nil
    end
    if antiAFKEnabled then
        afkConnection = player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end

-- ============================================
-- AUTO RECONNECT
-- ============================================
local function setupAutoReconnect()
    if autoReconnectEnabled then
        local ts = TeleportService
        pcall(function()
            local coreGui = game:GetService("CoreGui")
            local promptOverlay = coreGui:FindFirstChild("RobloxPromptGui")
            if promptOverlay then
                local errorPrompt = promptOverlay:FindFirstChild("promptOverlay")
                if errorPrompt then
                    errorPrompt.ChildAdded:Connect(function(child)
                        if autoReconnectEnabled and child.Name == "ErrorPrompt" then
                            task.wait(2)
                            ts:Teleport(game.PlaceId, player)
                        end
                    end)
                end
            end
        end)
    end
end

-- ============================================
-- AUTO ROLL LOOPS
-- ============================================
local function startAutoRoll()
    task.spawn(function()
        while autoRollEnabled do
            local rollSpeedText = "1"
            pcall(function()
                local stat = player.PlayerGui.Root.BottomBarStats.StatsList.RollSpeedStat.Content.Value.TextLabel.Text
                rollSpeedText = stat
            end)
            local delay = tonumber(string.match(rollSpeedText, "[%d%.]+")) or 1
            task.wait(delay)
            Roll()
        end
    end)
end

local function startAutoRollGames()
    task.spawn(function()
        while autoRollGamesEnabled do
            local rollSpeedText = "1"
            pcall(function()
                local stat = player.PlayerGui.Root.BottomBarStats.StatsList.RollSpeedStat.Content.Value.TextLabel.Text
                rollSpeedText = stat
            end)
            local delay = tonumber(string.match(rollSpeedText, "[%d%.]+")) or 1
            task.wait(delay)
            Roll()
        end
    end)
end

-- ============================================
-- AUTO FARM LOOP
-- ============================================
local function startAutoFarm()
    task.spawn(function()
        while autoFarmEnabled do
            pcall(function()
                local lootFolder = workspace:FindFirstChild("Loot")
                if lootFolder then
                    local drops = lootFolder:GetChildren()
                    for _, drop in pairs(drops) do
                        if drop and clientHRP then
                            for _, dropChild in pairs(drop:GetChildren()) do
                                if dropChild.Name ~= "LootHighlight" and dropChild:IsA("BasePart") then
                                    dropChild.CFrame = CFrame.new(clientHRP.Position)
                                    task.wait(0.3)
                                end
                            end
                        end
                    end
                end
            end)
            task.wait()
        end
    end)
end

-- ============================================
-- AUTO LOOT LOOP
-- ============================================
local function startAutoLoot()
    task.spawn(function()
        while autoLootEnabled do
            pcall(function()
                local lootFolder = workspace:FindFirstChild("Loot")
                if lootFolder then
                    for _, loot in ipairs(lootFolder:GetChildren()) do
                        if loot:IsA("Model") then
                            lootRemote:InvokeServer("requestCollect", loot.Name)
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end

-- ============================================
-- AUTO UPGRADE LOOP
-- ============================================
local function startAutoUpgrade()
    task.spawn(function()
        while autoUpgradeEnabled do
            Upgrade()
            task.wait(autoUpgradeInterval)
        end
    end)
end

-- ============================================
-- AUTO BUY ZONE LOOP
-- ============================================
local function startAutoBuyZone()
    task.spawn(function()
        while autoBuyZoneEnabled do
            pcall(function()
                zonesRemote:InvokeServer("requestPurchaseZone")
            end)
            task.wait(5)
        end
    end)
end

-- ============================================
-- AUTO REBIRTH LOOP
-- ============================================
local function startAutoRebirth()
    task.spawn(function()
        while autoRebirthEnabled do
            pcall(function()
                local rebirthRemote = networker:FindFirstChild("RebirthService")
                if rebirthRemote then
                    rebirthRemote:FindFirstChild("RemoteFunction"):InvokeServer("requestRebirth")
                end
            end)
            task.wait(5)
        end
    end)
end

-- ============================================
-- AUTO EQUIP BEST LOOP
-- ============================================
local function startAutoEquipBest()
    task.spawn(function()
        while autoEquipBestEnabled do
            pcall(function()
                inventoryRemote:InvokeServer("requestEquipBest")
            end)
            task.wait(10)
        end
    end)
end

-- ============================================
-- AUTO CLAIM OFFLINE LOOP
-- ============================================
local function startAutoClaimOffline()
    task.spawn(function()
        while autoClaimOfflineEnabled do
            pcall(function()
                offlineRemote:InvokeServer("requestClaim")
            end)
            task.wait(1)
        end
    end)
end

-- ============================================
-- AUTO POTIONS LOOP
-- ============================================
local function startAutoPotions()
    task.spawn(function()
        while autoPotionsEnabled do
            ConsumePotions()
            task.wait(3)
        end
    end)
end

-- ============================================
-- AUTO BEST ZONE LOOP
-- ============================================
local function startAutoBestZone()
    task.spawn(function()
        while autoBestZoneEnabled do
            TeleportBestZone()
            task.wait(autoBestZoneInterval)
        end
    end)
end

-- ============================================
-- AUTO SHOOT LOOP
-- ============================================
local function startAutoShoot()
    task.spawn(function()
        while autoShootEnabled do
            pcall(function()
                local gui = player.PlayerGui:FindFirstChild("ClickToShootIndicator")
                if gui and gui.Enabled then
                    local absSize = gui.AbsoluteSize
                    local absPos = gui.AbsolutePosition
                    local clickPos = Vector2.new(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2)
                    VirtualUser:Button1Down(clickPos)
                    task.wait(0.05)
                    VirtualUser:Button1Up(clickPos)
                end
            end)
            task.wait(0.2)
        end
    end)
end

-- ============================================
-- SLIME MAGNET LOOP
-- ============================================
local function startSlimeMagnet()
    task.spawn(function()
        while slimeMagnetEnabled do
            pcall(function()
                local radius = shootRadius
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                        local plr = Players:GetPlayerFromCharacter(obj)
                        if not plr and clientHRP then
                            local hrp = obj.HumanoidRootPart
                            local offset = Vector3.new(
                                math.random(-radius, radius) / 2,
                                0,
                                math.random(-radius, radius) / 2
                            )
                            hrp.CFrame = CFrame.new(clientHRP.Position + offset)
                        end
                    end
                end
            end)
            task.wait(0.2)
        end
    end)
end

-- ============================================
-- WEBHOOK LOOP
-- ============================================
local function startWebhook()
    task.spawn(function()
        while webhookEnabled do
            pcall(function()
                local numRolls = "0"
                if clientHRP and clientHRP:FindFirstChild("TitleGui") then
                    local titleGui = clientHRP:FindFirstChild("TitleGui")
                    if titleGui:FindFirstChild("NumRolls") then
                        numRolls = titleGui.NumRolls.Text
                    end
                end
                SendDiscordWebhook(webhookUrl, { description = numRolls })
            end)
            task.wait(webhookInterval)
        end
    end)
end

-- ============================================
-- NOCLIP
-- ============================================
local noclipConn = nil
local function setupNoclip()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
    if noclipEnabled then
        noclipConn = RunService.Stepped:Connect(function()
            local char = player.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

-- ============================================
-- INFINITE JUMP
-- ============================================
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState("Jumping")
            end
        end
    end
end)

-- ============================================
-- FPS BOOST
-- ============================================
local function fpsBoost()
    for _, v in pairs(game:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") then
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end)
    end
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
end

-- ============================================
-- UI SECTIONS
-- ============================================

-- HOME TAB

local playerSection = tabs.home:Section({Title = "Local Player"})

playerSection:Slider({
    Title = "Walk Speed",
    Value = {Min = 0, Max = 100, Default = 16, Decimals = 0},
    Callback = function(v)
        walkSpeedValue = v
        updateCharacter()
    end
})

playerSection:Slider({
    Title = "Jump Power",
    Value = {Min = 0, Max = 150, Default = 50, Decimals = 0},
    Callback = function(v)
        jumpPowerValue = v
        updateCharacter()
    end
})

playerSection:Button({
    Title = "Reset Default",
    Callback = function()
        walkSpeedValue = 16
        jumpPowerValue = 50
        updateCharacter()
        window:Notify("Reset", "Walk speed and jump power reset!", 2)
    end
})

-- MAIN TAB
local mainSection = tabs.main:Section({Title = "Rolling"})

mainSection:Toggle({
    Title = "Auto Roll",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        autoRollEnabled = v
        if v then startAutoRoll() end
    end
})

mainSection:Toggle({
    Title = "Auto Roll Games (smooth)",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        autoRollGamesEnabled = v
        if v then startAutoRollGames() end
    end
})

mainSection:Button({
    Title = "Hide Roll Games",
    Callback = function()
        hideRollEnabled = not hideRollEnabled
        pcall(function()
            networker:FindFirstChild("SettingsService"):FindFirstChild("RemoteEvent"):FireServer("set", "hideRoll", hideRollEnabled)
        end)
        window:Notify("Hide Roll", hideRollEnabled and "Enabled" or "Disabled", 2)
    end
})

mainSection:Divider()

local farmingSection = tabs.main:Section({Title = "Farming"})

farmingSection:Toggle({
    Title = "Auto Index",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        autoIndexEnabled = v
        if v then
            task.spawn(function()
                while autoIndexEnabled do
                    ClaimIndex()
                    task.wait(30)
                end
            end)
        end
    end
})

farmingSection:Toggle({
    Title = "Auto Farm",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        autoFarmEnabled = v
        if v then startAutoFarm() end
    end
})

farmingSection:Toggle({
    Title = "Auto Best Zone",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        autoBestZoneEnabled = v
        if v then startAutoBestZone() end
    end
})

farmingSection:Input({
    Title = "Best Zone Interval",
    Placeholder = "30",
    Numeric = true,
    Callback = function(v)
        local num = tonumber(v)
        if num then autoBestZoneInterval = num end
    end
})

farmingSection:Toggle({
    Title = "Auto Potions",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        autoPotionsEnabled = v
        if v then startAutoPotions() end
    end
})

farmingSection:Divider()

local combatSection = tabs.main:Section({Title = "Combat"})

combatSection:Toggle({
    Title = "Auto Shoot",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        autoShootEnabled = v
        if v then startAutoShoot() end
    end
})

combatSection:Toggle({
    Title = "Slime Magnet",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        slimeMagnetEnabled = v
        if v then startSlimeMagnet() end
    end
})

combatSection:Input({
    Title = "Radius Shoot",
    Placeholder = "17",
    Numeric = true,
    Callback = function(v)
        local num = tonumber(v)
        if num then shootRadius = num end
    end
})

combatSection:Divider()

local manualSection = tabs.main:Section({Title = "Manual"})

manualSection:Button({
    Title = "Equip Best",
    Callback = function()
        pcall(function()
            inventoryRemote:InvokeServer("requestEquipBest")
        end)
        window:Notify("Manual", "Equip best requested!", 2)
    end
})

manualSection:Button({
    Title = "Purchase Zone",
    Callback = function()
        pcall(function()
            zonesRemote:InvokeServer("requestPurchaseZone")
        end)
        window:Notify("Manual", "Purchase zone requested!", 2)
    end
})

manualSection:Button({
    Title = "Unlock Machine",
    Callback = function()
        pcall(function()
            craftingRemote:InvokeServer("requestUnlockMachine")
        end)
        window:Notify("Manual", "Unlock machine requested!", 2)
    end
})

manualSection:Button({
    Title = "Claim Offline",
    Callback = function()
        pcall(function()
            offlineRemote:InvokeServer("requestClaim")
        end)
        window:Notify("Manual", "Claim offline requested!", 2)
    end
})

manualSection:Divider()

local codeSection = tabs.main:Section({Title = "Redeem Code"})

local CodeList = {"goingBananas", "test", "gullible", "AATOMORROW", "giveMeLuckNOW"}

codeSection:Button({
    Title = "Redeem All Codes",
    Callback = function()
        for _, code in ipairs(CodeList) do
            pcall(function()
                codeRemote:InvokeServer("redeem", code)
            end)
            task.wait(0.3)
        end
        window:Notify("Codes", "All codes redeemed!", 2)
    end
})

-- AUTOMATIC TAB
local autoUpgradeSection = tabs.automatic:Section({Title = "Upgrades Automatically"})

autoUpgradeSection:Toggle({
    Title = "Auto Upgrade",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        autoUpgradeEnabled = v
        if v then startAutoUpgrade() end
    end
})

autoUpgradeSection:Input({
    Title = "Upgrade Interval",
    Placeholder = "30",
    Numeric = true,
    Callback = function(v)
        local num = tonumber(v)
        if num then autoUpgradeInterval = num end
    end
})

autoUpgradeSection:Toggle({
    Title = "Auto Buy Zone",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        autoBuyZoneEnabled = v
        if v then startAutoBuyZone() end
    end
})

autoUpgradeSection:Toggle({
    Title = "Auto Rebirth",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        autoRebirthEnabled = v
        if v then startAutoRebirth() end
    end
})

autoUpgradeSection:Toggle({
    Title = "Auto Equip Best",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        autoEquipBestEnabled = v
        if v then startAutoEquipBest() end
    end
})

autoUpgradeSection:Divider()

local collectSection = tabs.automatic:Section({Title = "Collect Automatically"})

collectSection:Toggle({
    Title = "Auto Loot",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        autoLootEnabled = v
        if v then startAutoLoot() end
    end
})

collectSection:Toggle({
    Title = "Auto Claim Offline Earnings",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        autoClaimOfflineEnabled = v
        if v then startAutoClaimOffline() end
    end
})

-- WEBHOOK TAB
local webhookSection = tabs.webhook:Section({Title = "Discord Webhook"})

webhookSection:Input({
    Title = "Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(v)
        webhookUrl = v
    end
})

webhookSection:Toggle({
    Title = "Enable Webhook",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        webhookEnabled = v
        if v then startWebhook() end
    end
})

webhookSection:Input({
    Title = "Webhook Interval",
    Placeholder = "30",
    Numeric = true,
    Callback = function(v)
        local num = tonumber(v)
        if num then webhookInterval = num end
    end
})

-- MISC TAB
local miscSection = tabs.misc:Section({Title = "Misc"})

miscSection:Toggle({
    Title = "Infinite Jump",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        infJumpEnabled = v
    end
})

miscSection:Button({
    Title = "FPS Boost",
    Callback = function()
        fpsBoost()
        window:Notify("FPS Boost", "Applied!", 2)
    end
})

miscSection:Toggle({
    Title = "Noclip",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        noclipEnabled = v
        setupNoclip()
    end
})

miscSection:Toggle({
    Title = "Auto Reconnect",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        autoReconnectEnabled = v
        setupAutoReconnect()
    end
})

miscSection:Toggle({
    Title = "Anti AFK",
    Type = "Checkbox",
    Value = false,
    Callback = function(v)
        antiAFKEnabled = v
        startAntiAFK()
    end
})

-- SETTINGS TAB
local settingsSection = tabs.settings:Section({Title = "Server"})

settingsSection:Button({
    Title = "Rejoin",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, player)
        window:Notify("Rejoin", "Rejoining server...", 2)
    end
})

settingsSection:Button({
    Title = "Server Hop",
    Callback = function()
        local req = syn and syn.request or http_request or request or httprequest
        if req then
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            local ok, response = pcall(req, { Url = url, Method = "GET" })
            if ok and response and response.Body then
                local data = HttpService:JSONDecode(response.Body)
                for _, server in ipairs(data.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, player)
                        break
                    end
                end
            end
        end
        window:Notify("Server Hop", "Searching for new server...", 2)
    end
})

settingsSection:Paragraph({
    Title = "Current Server",
    Desc = "Server ID: " .. game.JobId
})

-- COMMUNITY TAB
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
            set_clipboard("https://discord.gg/eDbaHKEf7G")
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
    clientHRP = char:FindFirstChild("HumanoidRootPart")
end)

-- ============================================
-- INITIAL SETUP
-- ============================================
updateCharacter()
setupAutoReconnect()
startAntiAFK()

-- ============================================
-- INITIAL NOTIFICATION
-- ============================================
task.wait(1)
window:Notify("PinatHub", "Loaded!", 3)
window:Open()
