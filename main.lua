-- SERVICES
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- DISABLE ALL GUI
pcall(function()
    for _, v in pairs(Enum.CoreGuiType:GetEnumItems()) do
        StarterGui:SetCoreGuiEnabled(v, false)
    end
end)

for _, v in pairs(playerGui:GetChildren()) do
    if v:IsA("ScreenGui") then
        v.Enabled = false
    end
end

-- MAP LIST DATA
local mapList = {
    "Blade Ball",
    "Blox Fruits",
    "Survive the Apocalypse",
    "Jump Color Block Steal Brainrots",
    "Be a Lucky Block",
    "Bite By Night",
    "Reel a Brainrot",
    "Skateboard for Brainrots",
    "Sailor Piece",
    "Mutate the Brainrot"
}

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999
screenGui.Parent = playerGui

-- BACKGROUND
local bg = Instance.new("Frame")
bg.Size = UDim2.new(1,0,1,0)
bg.BackgroundColor3 = Color3.fromRGB(5,5,5)
bg.Parent = screenGui

-- GRADIENT AMBIENCE
local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15,15,15)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0))
}
grad.Rotation = 90
grad.Parent = bg

-- FAKE GRAIN
for i = 1,120 do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,1,0,1)
    dot.Position = UDim2.new(math.random(),0,math.random(),0)
    dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
    dot.BackgroundTransparency = 0.9
    dot.BorderSizePixel = 0
    dot.Parent = bg
end

-- VIGNETTE
local vignette = Instance.new("Frame")
vignette.Size = UDim2.new(1.2,0,1.2,0)
vignette.Position = UDim2.new(-0.1,0,-0.1,0)
vignette.BackgroundColor3 = Color3.fromRGB(0,0,0)
vignette.BackgroundTransparency = 0.6
vignette.Parent = bg

-- MAP LIST FRAME
local mapFrame = Instance.new("Frame")
mapFrame.Size = UDim2.new(0,250,0,0)
mapFrame.Position = UDim2.new(0.06,0,0.08,0)
mapFrame.BackgroundTransparency = 0.85
mapFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
mapFrame.BorderSizePixel = 0
mapFrame.ClipsDescendants = true
mapFrame.Parent = bg

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,8)
corner.Parent = mapFrame

-- MAP LIST TITLE
local mapTitle = Instance.new("TextLabel")
mapTitle.Size = UDim2.new(1,0,0,28)
mapTitle.Position = UDim2.new(0,0,0,0)
mapTitle.BackgroundTransparency = 1
mapTitle.Text = "MAP LIST"
mapTitle.TextColor3 = Color3.fromRGB(200,200,200)
mapTitle.Font = Enum.Font.GothamBold
mapTitle.TextSize = 14
mapTitle.TextXAlignment = Enum.TextXAlignment.Left
mapTitle.TextTransparency = 0  -- Langsung muncul, ga usah animasi
mapTitle.Parent = mapFrame

local mapLayout = Instance.new("UIListLayout")
mapLayout.Padding = UDim.new(0,6)
mapLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
mapLayout.SortOrder = Enum.SortOrder.LayoutOrder
mapLayout.Parent = mapFrame

-- Create map list items (MUNCUL CEPAT, ga ada delay awal)
for i, gameName in ipairs(mapList) do
    local item = Instance.new("TextLabel")
    item.Size = UDim2.new(1,0,0,22)
    item.BackgroundTransparency = 1
    item.Text = "• " .. gameName
    item.TextColor3 = Color3.fromRGB(220,220,220)
    item.Font = Enum.Font.Gotham
    item.TextSize = 13
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.TextTransparency = 1
    item.Parent = mapFrame
    
    -- Muncul cepet (delay lebih kecil)
    task.spawn(function()
        local delayTime = 0.15 + (i * 0.05) -- Cepet: 0.15, 0.20, 0.25, dst
        task.wait(delayTime)
        TweenService:Create(item, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            TextTransparency = 0
        }):Play()
    end)
end

task.wait(1.2) -- Nunggu bentar aja
local totalHeight = 32 + (#mapList * 28)
mapFrame.Size = UDim2.new(0,260,0,totalHeight)

-- LOGO (LANGSUNG MUNCUL)
local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0,140,0,140)
logo.Position = UDim2.new(0.5,-70,0.47,-70)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://76217515412796"
logo.ImageTransparency = 0 -- Langsung muncul, ga usah animasi
logo.Parent = bg

-- TEXT FRAME
local textFrame = Instance.new("Frame")
textFrame.Size = UDim2.new(1,0,0,50)
textFrame.Position = UDim2.new(0,0,0.60,0)
textFrame.BackgroundTransparency = 1
textFrame.Parent = bg

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Padding = UDim.new(0,2)
layout.Parent = textFrame

-- LINE LOADING (LANGSUNG JALAN)
local line = Instance.new("Frame")
line.Size = UDim2.new(0,0,0,2)
line.Position = UDim2.new(0.5,0,0.68,0)
line.AnchorPoint = Vector2.new(0.5,0)
line.BackgroundColor3 = Color3.fromRGB(200,200,200)
line.BorderSizePixel = 0
line.Parent = bg

TweenService:Create(line, TweenInfo.new(1.5), {
    Size = UDim2.new(0.35,0,0,2)
}):Play()

local lineGrad = Instance.new("UIGradient")
lineGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0))
}
lineGrad.Parent = line

task.spawn(function()
    while true do
        lineGrad.Offset = Vector2.new(-1,0)
        TweenService:Create(lineGrad, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {
            Offset = Vector2.new(1,0)
        }):Play()
        task.wait(1.5)
    end
end)

-- CREATE LETTERS PINATHUB (CEPET)
local function createLetter(char, index)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0,34,1,0)
    label.BackgroundTransparency = 1
    label.Text = char
    label.TextScaled = true
    label.Font = Enum.Font.Antique
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextTransparency = 1

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(120,120,120)
    stroke.Parent = label

    local glow = Instance.new("UIStroke")
    glow.Thickness = 3
    glow.Color = Color3.fromRGB(255,255,255)
    glow.Transparency = 0.6
    glow.Parent = label

    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120,120,120)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(220,220,220))
    }
    g.Rotation = 90
    g.Parent = label

    label.Parent = textFrame

    task.wait(index * 0.08) -- Cepet: 0.08 per huruf
    TweenService:Create(label, TweenInfo.new(0.4), {
        TextTransparency = 0
    }):Play()
end

local text = {"P","I","N","A","T","H","U","B"}
for i, c in ipairs(text) do
    createLetter(c, i)
end

-- LOADING TEXT (MUNCUL CEPET)
local loading = Instance.new("TextLabel")
loading.Size = UDim2.new(1,0,0,30)
loading.Position = UDim2.new(0,0,0.75,0)
loading.BackgroundTransparency = 1
loading.Text = "loading module..."
loading.Font = Enum.Font.Code
loading.TextScaled = true
loading.TextColor3 = Color3.fromRGB(140,140,140)
loading.TextTransparency = 0.6
loading.Parent = bg

task.wait(1.8) -- Total loading cepet

-- FADE OUT
TweenService:Create(bg, TweenInfo.new(1), {
    BackgroundTransparency = 1
}):Play()

task.wait(1)

screenGui:Destroy()

-- ENABLE GUI BACK
pcall(function()
    for _, v in pairs(Enum.CoreGuiType:GetEnumItems()) do
        StarterGui:SetCoreGuiEnabled(v, true)
    end
end)

for _, v in pairs(playerGui:GetChildren()) do
    if v:IsA("ScreenGui") then
        v.Enabled = true
    end
end
