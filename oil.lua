repeat task.wait() until game:IsLoaded()

-- =======================================================
-- PINATHUB | OIL EMPIRE (INTEGRATED)
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
local username = LocalPlayer.Name

-- ============================================
-- EXECUTOR COMPATIBILITY
-- ============================================
local function noop() end
local set_clipboard = setclipboard or (syn and syn.setclipboard) or noop

-- ============================================
-- OIL EMPIRE VARIABLES
-- ============================================
local oilEnabled = false
local oilTweenSpeed = 0.1
local oilUseTween = true
local oilFarmThread = nil
local oilAntiAfkOn = false
local oilAntiAfkConn = nil
local oilSellEnabled = false
local oilSellPrice = 10
local oilMinGasoline = 10000
local oilSellThread = nil
local oilSellStore, oilSellPrompt, oilSellRemote

-- ============================================
-- OIL EMPIRE FUNCTIONS
-- ============================================
local function oilSetAntiAfk(on)
    oilAntiAfkOn = on
    if oilAntiAfkConn then
        oilAntiAfkConn:Disconnect()
        oilAntiAfkConn = nil
    end
    if on then
        oilAntiAfkConn = LocalPlayer.Idled:Connect(function()
            local vp = game:GetService("VirtualInputManager")
            vp:SendKeyEvent(true, Enum.KeyCode.W, false, game)
            task.wait(0.1)
            vp:SendKeyEvent(false, Enum.KeyCode.W, false, game)
        end)
    end
end

local function oilGetPlayerPlot()
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then return nil end
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local ok, label = pcall(function()
            return plot.OwnerTag.BillboardGui.Main.TextLabel
        end)
        if ok and label then
            local owner = label.Text:match("^(.+)'s")
            if owner == username then return plot end
        end
    end
    return nil
end

local function oilGetBuildings()
    local plot = oilGetPlayerPlot()
    return plot and plot:FindFirstChild("Buildings") or nil
end

local function oilGetRefineries(buildings)
    local list = {}
    for _, m in ipairs(buildings:GetChildren()) do
        if m:IsA("Model") and m:GetAttribute("Type") == "Refinery" then
            list[#list + 1] = m
        end
    end
    return list
end

local function oilGetValues(model)
    local ok, obj = pcall(function() return model.Primary.Info.Main.Value end)
    if not ok or not obj then return 0, 0 end
    local text = (obj.Text or obj.Value or "")
    local c, m = text:match("^(%d+)/(%d+)$")
    return tonumber(c) or 0, tonumber(m) or 0
end

local function oilGetPrimary(model)
    local p = model:FindFirstChild("Primary")
    if p and p:IsA("BasePart") then return p end
    return model.PrimaryPart
end

local function oilTeleport(targetCF)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    hrp.Anchored = true
    if hum then hum.PlatformStand = true end
    if oilUseTween and oilTweenSpeed > 0.05 then
        local startCF = hrp.CFrame
        local elapsed = 0
        local duration = oilTweenSpeed
        repeat
            local dt = task.wait()
            elapsed = elapsed + dt
            local a = math.min(elapsed / duration, 1)
            hrp.CFrame = startCF:Lerp(targetCF, 1 - (1 - a) ^ 3)
        until elapsed >= duration or not oilEnabled or not hrp.Parent
    end
    if hrp.Parent then hrp.CFrame = targetCF end
    hrp.Anchored = false
    if hum then hum.PlatformStand = false end
end

local function oilFarmLoop()
    while oilEnabled do
        local buildings = oilGetBuildings()
        if not buildings then task.wait(1) end
        local list = oilGetRefineries(buildings)
        if #list == 0 then task.wait(1) end
        table.sort(list, function(a, b)
            local ca, ma = oilGetValues(a)
            local cb, mb = oilGetValues(b)
            local fa = (ma > 0) and (ca / ma) or 0
            local fb = (mb > 0) and (cb / mb) or 0
            return fa > fb
        end)
        local visited = 0
        for _, model in ipairs(list) do
            if not oilEnabled then break end
            if not model.Parent then continue end
            local cur, max = oilGetValues(model)
            if max > 0 and cur == max then
                local primary = oilGetPrimary(model)
                if primary then
                    oilTeleport(primary.CFrame)
                    visited = visited + 1
                    task.wait(0.05)
                end
            end
        end
        if visited == 0 then task.wait(0.5) end
    end
end

local function oilCacheSellAssets()
    local stores = workspace:FindFirstChild("Stores")
    if not stores then return false end
    oilSellStore = stores:FindFirstChild("Sell")
    if not oilSellStore then return false end
    local prompt = oilSellStore:FindFirstChild("SellGas", true)
    if not prompt then
        for _, v in ipairs(oilSellStore:GetDescendants()) do
            if v:IsA("ProximityPrompt") then prompt = v; break end
        end
    end
    oilSellPrompt = prompt
    for _, v in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name:lower():find("sell") then
            oilSellRemote = v
            break
        end
    end
    if not oilSellRemote then
        for _, v in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("gas") or v.Name:lower():find("store") or v.Name:lower():find("shop")) then
                oilSellRemote = v
                break
            end
        end
    end
    return true
end

local function oilVimClick(btn)
    local vp = game:GetService("VirtualInputManager")
    local pos = btn.AbsolutePosition + btn.AbsoluteSize * 0.5
    vp:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
    task.wait(0.08)
    vp:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
end

local function oilTrySell()
    local sellGui = LocalPlayer.PlayerGui.Main.SellGas
    local sellBtn = sellGui.Main.Sell
    if oilSellRemote then
        local ok = pcall(function() oilSellRemote:FireServer() end)
        if ok then return true end
    end
    local ok2 = pcall(function() oilVimClick(sellBtn) end)
    if ok2 then return true end
    return false
end

local function oilSellLoop()
    if not oilSellStore then
        if not oilCacheSellAssets() then
            oilSellEnabled = false
            return
        end
    end
    while oilSellEnabled do
        local okP, price = pcall(function()
            return game:GetService("ReplicatedStorage").GasPrice.Value
        end)
        if not okP or type(price) ~= "number" then
            task.wait(2)
        end
        local okG, gasoline = pcall(function()
            return LocalPlayer.leaderstats.Gasoline.Value
        end)
        local hasEnoughGas = okG and type(gasoline) == "number" and gasoline >= oilMinGasoline
        if price >= oilSellPrice and hasEnoughGas then
            local wasEnabled = oilEnabled
            if wasEnabled then
                oilEnabled = false
                if oilFarmThread then task.cancel(oilFarmThread); oilFarmThread = nil end
            end
            if oilSellPrompt then
                pcall(function() fireproximityprompt(oilSellPrompt) end)
                task.wait(0.6)
            end
            oilTrySell()
            if wasEnabled then
                oilEnabled = true
                oilFarmThread = task.spawn(oilFarmLoop)
            end
            task.wait(5)
        else
            task.wait(1)
        end
    end
end

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
    Folder = "pinathub_oilempire",
    Size = UDim2.fromOffset(450, 550),
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
    farm = window:Tab({Title = "Auto Farm", Icon = "droplet"}),
    sell = window:Tab({Title = "Auto Sell", Icon = "shopping-cart"}),
    settings = window:Tab({Title = "Settings", Icon = "cog"}),
    community = window:Tab({Title = "Community", Icon = "users"}),
}

-- ============================================
-- STATUS UPDATE THREAD
-- ============================================
local statusText = ""
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            local okP, price = pcall(function()
                return game:GetService("ReplicatedStorage").GasPrice.Value
            end)
            local gasPriceStr = (okP and price) and ("$"..tostring(price)) or "$—"
            local tagColor = oilSellEnabled and "#6ED8A8" or "#888888"
            local tagText = oilSellEnabled and "ON" or "OFF"
            
            window:SetSubtitle(string.format("Gas %s | AutoSell %s", gasPriceStr, tagText))
        end)
    end
end)

-- ============================================
-- UI SECTIONS - AUTO FARM TAB
-- ============================================
local farmSection = tabs.farm:Section({Title = "Refinery Auto Pickup"})

-- Status Card
local statusFrame = farmSection:AddFrame({Title = "Status"})
statusFrame:Label("Status: INACTIVE", Enum.Font.GothamSemibold, 14, Color3.fromRGB(120, 220, 170))
local refineryCountLabel = statusFrame:Label("0 refineries found", Enum.Font.Gotham, 12, Color3.fromRGB(120, 120, 120))

-- Auto Pickup Toggle
local pickupFrame = farmSection:AddFrame({Title = "Auto Pickup"})
pickupFrame:Label("Auto Pickup", Enum.Font.GothamSemibold, 13)
pickupFrame:Label("Collects full refineries", Enum.Font.Gotham, 11, Color3.fromRGB(70, 70, 70))
local pickupToggle = pickupFrame:Toggle({
    Title = "",
    Default = false,
    Callback = function(state)
        oilEnabled = state
        if oilEnabled then
            if oilFarmThread then task.cancel(oilFarmThread) end
            oilFarmThread = task.spawn(oilFarmLoop)
            statusFrame:Label("Status: ACTIVE", Enum.Font.GothamSemibold, 14, Color3.fromRGB(120, 220, 170))
        else
            if oilFarmThread then task.cancel(oilFarmThread); oilFarmThread = nil end
            statusFrame:Label("Status: INACTIVE", Enum.Font.GothamSemibold, 14, Color3.fromRGB(220, 80, 80))
        end
        window:Notify("Auto Pickup", state and "Enabled" or "Disabled", 2)
    end
})

-- Tween Speed Slider
local speedFrame = farmSection:AddFrame({Title = "Tween Speed"})
speedFrame:Label("Tween Speed", Enum.Font.GothamSemibold, 13)
speedFrame:Label("Duration per tween", Enum.Font.Gotham, 11, Color3.fromRGB(70, 70, 70))
local speedSlider = speedFrame:Slider({
    Title = "Seconds",
    Value = {Min = 0.1, Max = 1.0, Default = 0.1, Decimals = 1},
    Callback = function(v)
        oilTweenSpeed = v
    end
})

-- Anti AFK
local afkFrame = farmSection:AddFrame({Title = "Anti AFK"})
afkFrame:Label("Anti-AFK", Enum.Font.GothamSemibold, 13)
afkFrame:Label("Prevents idle kick", Enum.Font.Gotham, 11, Color3.fromRGB(70, 70, 70))
local afkToggle = afkFrame:Toggle({
    Title = "",
    Default = false,
    Callback = function(state)
        oilSetAntiAfk(state)
        window:Notify("Anti-AFK", state and "Enabled" or "Disabled", 2)
    end
})

-- ============================================
-- UI SECTIONS - AUTO SELL TAB
-- ============================================
local sellSection = tabs.sell:Section({Title = "Gas Price Monitor"})

-- Price Display Frame
local priceFrame = sellSection:AddFrame({Title = "Current Prices"})
local gasPriceLabel = priceFrame:Label("Gas Price: $--", Enum.Font.GothamBold, 16, Color3.fromRGB(110, 210, 160))
local sellPriceLabel = priceFrame:Label("Sell Price: --", Enum.Font.GothamBold, 16, Color3.fromRGB(110, 210, 160))
local timerLabel = priceFrame:Label("Next Price in: --", Enum.Font.Gotham, 12, Color3.fromRGB(130, 130, 130))

-- Auto Sell Toggle
local autoSellFrame = sellSection:AddFrame({Title = "Auto Sell"})
autoSellFrame:Label("Auto Sell", Enum.Font.GothamSemibold, 13)
autoSellFrame:Label("Sells when price ≥ target", Enum.Font.Gotham, 11, Color3.fromRGB(70, 70, 70))
local sellToggle = autoSellFrame:Toggle({
    Title = "",
    Default = false,
    Callback = function(state)
        oilSellEnabled = state
        if oilSellEnabled then
            if oilSellThread then task.cancel(oilSellThread) end
            oilSellThread = task.spawn(oilSellLoop)
        else
            if oilSellThread then task.cancel(oilSellThread); oilSellThread = nil end
        end
        window:Notify("Auto Sell", state and "Enabled" or "Disabled", 2)
    end
})

-- Min Gas Price Setting
local priceSettingFrame = sellSection:AddFrame({Title = "Min Gas Price"})
priceSettingFrame:Label("Minimum Gas Price", Enum.Font.GothamSemibold, 13)
local priceSlider = priceSettingFrame:Slider({
    Title = "Price ($1-$30)",
    Value = {Min = 1, Max = 30, Default = 10, Decimals = 0},
    Callback = function(v)
        oilSellPrice = v
    end
})

-- Min Gasoline Setting
local gasSettingFrame = sellSection:AddFrame({Title = "Min Gasoline"})
gasSettingFrame:Label("Minimum Gasoline", Enum.Font.GothamSemibold, 13)
gasSettingFrame:Label("Min gas before selling", Enum.Font.Gotham, 11, Color3.fromRGB(70, 70, 70))
local gasSlider = gasSettingFrame:Slider({
    Title = "Amount (1K - 10M)",
    Value = {Min = 1000, Max = 10000000, Default = 10000, Decimals = 0},
    Callback = function(v)
        oilMinGasoline = v
        gasSettingFrame:Label(string.format("Current: %s", formatGas(v)), Enum.Font.Gotham, 11, Color3.fromRGB(110, 210, 160))
    end
})

-- Format gas helper
local function formatGas(v)
    if v >= 1000000 then return string.format("%.1fM", v/1000000)
    elseif v >= 1000 then return string.format("%dK", math.floor(v/1000))
    else return tostring(v) end
end
gasSettingFrame:Label(string.format("Current: %s", formatGas(oilMinGasoline)), Enum.Font.Gotham, 11, Color3.fromRGB(110, 210, 160))

-- ============================================
-- UI SECTIONS - SETTINGS TAB
-- ============================================
local settingsSection = tabs.settings:Section({Title = "General Settings"})

-- Walk Speed Setting
local walkSpeedValue = 16
settingsSection:Slider({
    Title = "Walk Speed (16-250)",
    Value = {Min = 16, Max = 250, Default = 16, Decimals = 0},
    Callback = function(v)
        walkSpeedValue = v
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end
})

-- Jump Power Setting
local jumpPowerValue = 50
settingsSection:Slider({
    Title = "Jump Power (0-500)",
    Value = {Min = 0, Max = 500, Default = 50, Decimals = 0},
    Callback = function(v)
        jumpPowerValue = v
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = v
                hum.UseJumpPower = true
            end
        end
    end
})

settingsSection:Divider()

-- Server Settings
settingsSection:Label("Server Options", Enum.Font.GothamSemibold, 14)

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
            TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], LocalPlayer)
        else
            TeleportService:Teleport(placeId, LocalPlayer)
        end
        window:Notify("Server Hop", "Joining new server...", 2)
    end
})

settingsSection:Button({
    Title = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
        window:Notify("Rejoin", "Rejoining server...", 2)
    end
})

settingsSection:Button({
    Title = "Reset Character",
    Callback = function()
        if LocalPlayer.Character then
            LocalPlayer.Character:BreakJoints()
            window:Notify("Reset", "Character reset!", 2)
        end
    end
})

-- ============================================
-- UI SECTIONS - COMMUNITY TAB
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
-- PRICE MONITOR LOOP
-- ============================================
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            local okP, price = pcall(function()
                return game:GetService("ReplicatedStorage").GasPrice.Value
            end)
            if okP and price then
                local priceAbove = price >= oilSellPrice
                gasPriceLabel:SetText(string.format("Gas Price: $%d", price))
                gasPriceLabel:SetColor(priceAbove and Color3.fromRGB(110, 210, 160) or Color3.fromRGB(220, 80, 80))
            end
            
            local okS, spRaw = pcall(function()
                return LocalPlayer.PlayerGui.Main.SellGas.Main.Sell.TextLabel.Text
            end)
            if okS and spRaw then
                local extracted = spRaw:match("%$[%d,]+") or "$0"
                sellPriceLabel:SetText(string.format("Sell Price: %s", extracted))
                sellPriceLabel:SetColor(Color3.fromRGB(110, 210, 160))
            end
            
            local okT, timerTxt = pcall(function()
                return LocalPlayer.PlayerGui.Main.SellGas.NextStock.Text
            end)
            if okT and timerTxt and tostring(timerTxt) ~= "" then
                timerLabel:SetText(string.format("Next Price in: %s", tostring(timerTxt)))
            else
                timerLabel:SetText("Next Price in: --")
            end
        end)
    end
end)

-- ============================================
-- REFINERY COUNTER LOOP
-- ============================================
task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            local buildings = oilGetBuildings()
            if not buildings then
                refineryCountLabel:SetText("plot not found")
                refineryCountLabel:SetColor(Color3.fromRGB(220, 80, 80))
            else
                local list = oilGetRefineries(buildings)
                local n = #list
                refineryCountLabel:SetText(string.format("%d refiner%s found", n, n == 1 and "y" or "ies"))
                refineryCountLabel:SetColor(Color3.fromRGB(120, 120, 120))
            end
        end)
    end
end)

-- ============================================
-- CHARACTER RESPAWN HANDLER
-- ============================================
LocalPlayer.CharacterAdded:Connect(function(char)
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
