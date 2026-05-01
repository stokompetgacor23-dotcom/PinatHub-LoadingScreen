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

-- FAKE GRAIN (pakai dots kecil)
for i = 1,120 do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,1,0,1)
    dot.Position = UDim2.new(math.random(),0,math.random(),0)
    dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
    dot.BackgroundTransparency = 0.9
    dot.BorderSizePixel = 0
    dot.Parent = bg
end

-- VIGNETTE FAKE (frame besar transparan)
local vignette = Instance.new("Frame")
vignette.Size = UDim2.new(1.2,0,1.2,0)
vignette.Position = UDim2.new(-0.1,0,-0.1,0)
vignette.BackgroundColor3 = Color3.fromRGB(0,0,0)
vignette.BackgroundTransparency = 0.6
vignette.Parent = bg

-- LOGO (PAKE ID LU)
local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0,140,0,140)
logo.Position = UDim2.new(0.5,-70,0.47,-70)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://76217515412796"
logo.ImageTransparency = 1
logo.Parent = bg

TweenService:Create(logo, TweenInfo.new(1.2), {
    ImageTransparency = 0
}):Play()

-- TEXT FRAME (MEPET)
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

-- LINE LOADING
local line = Instance.new("Frame")
line.Size = UDim2.new(0,0,0,2)
line.Position = UDim2.new(0.5,0,0.68,0)
line.AnchorPoint = Vector2.new(0.5,0)
line.BackgroundColor3 = Color3.fromRGB(200,200,200)
line.BorderSizePixel = 0
line.Parent = bg

TweenService:Create(line, TweenInfo.new(2), {
    Size = UDim2.new(0.35,0,0,2)
}):Play()

-- LINE ANIMATION
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
        TweenService:Create(lineGrad, TweenInfo.new(2, Enum.EasingStyle.Linear), {
            Offset = Vector2.new(1,0)
        }):Play()
        task.wait(2)
    end
end)

-- CREATE LETTER (NEON TAJEM)
local function createLetter(char)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0,34,1,0)
    label.BackgroundTransparency = 1
    label.Text = char
    label.TextScaled = true
    label.Font = Enum.Font.Antique
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextTransparency = 1

    -- STROKE
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(120,120,120)
    stroke.Parent = label

    -- NEON TAJEM
    local glow = Instance.new("UIStroke")
    glow.Thickness = 3
    glow.Color = Color3.fromRGB(255,255,255)
    glow.Transparency = 0.6
    glow.Parent = label

    -- GRADIENT
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120,120,120)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(220,220,220))
    }
    g.Rotation = 90
    g.Parent = label

    label.Parent = textFrame

    TweenService:Create(label, TweenInfo.new(0.8), {
        TextTransparency = 0
    }):Play()

    task.wait(0.6)
end

task.wait(1)

local text = {"P","I","N","A","T","H","U","B"}
for _, c in ipairs(text) do
    createLetter(c)
end

-- FAKE LOADING TEXT
local loading = Instance.new("TextLabel")
loading.Size = UDim2.new(1,0,0,30)
loading.Position = UDim2.new(0,0,0.75,0)
loading.BackgroundTransparency = 1
loading.Text = "loading module..."
loading.Font = Enum.Font.Code
loading.TextScaled = true
loading.TextColor3 = Color3.fromRGB(140,140,140)
loading.TextTransparency = 1
loading.Parent = bg

TweenService:Create(loading, TweenInfo.new(1), {
    TextTransparency = 0
}):Play()

task.wait(2)

-- FADE OUT
TweenService:Create(bg, TweenInfo.new(1.5), {
    BackgroundTransparency = 1
}):Play()

task.wait(1.5)

screenGui:Destroy()

-- ENABLE GUI BALIK
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
