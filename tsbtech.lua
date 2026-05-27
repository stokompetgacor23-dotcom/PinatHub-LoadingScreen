local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Animation ID Configurations
local DASH_ANIMATIONS = {
	["10503381238"] = true,
	["13379003796"] = true
}

local BURST_ANIMATIONS = {
	["10479335397"] = true,
	["13380255751"] = true
}

-- State Management Variables
local alignPosition = nil
local alignOrientation = nil
local renderConnection = nil
local followPart = nil

local isScriptEnabled = false
local maxTargetDistance = 10
local isProcessingSequence = false

-- Create UI Container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PinatTechGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Create Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 120, 0, 40)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 8)

-- Create Glow Effect
local glowFrame = Instance.new("Frame")
glowFrame.Size = UDim2.new(1, 4, 1, 4)
glowFrame.Position = UDim2.new(0, -2, 0, -2)
glowFrame.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
glowFrame.BackgroundTransparency = 0.7
glowFrame.BorderSizePixel = 0
glowFrame.Parent = mainFrame

local glowCorner = Instance.new("UICorner", glowFrame)
glowCorner.CornerRadius = UDim.new(0, 10)

-- Create Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, 0, 1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
toggleButton.Text = "PINAT TECH"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 12
toggleButton.AutoButtonColor = false
toggleButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner", toggleButton)
buttonCorner.CornerRadius = UDim.new(0, 6)

-- Status Indicator
local statusIndicator = Instance.new("Frame")
statusIndicator.Size = UDim2.new(0, 8, 0, 8)
statusIndicator.Position = UDim2.new(1, -12, 0.5, -4)
statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
statusIndicator.BorderSizePixel = 0
statusIndicator.Parent = toggleButton

local indicatorCorner = Instance.new("UICorner", statusIndicator)
indicatorCorner.CornerRadius = UDim.new(1, 0)

-- Status Text (small)
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 0, 12)
statusText.Position = UDim2.new(0, 0, 1, 4)
statusText.BackgroundTransparency = 1
statusText.Text = "OFF"
statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 10
statusText.TextXAlignment = Enum.TextXAlignment.Center
statusText.Parent = mainFrame

-- Pulse animation for glow
task.spawn(function()
	local pulse = 0
	local increasing = true
	while true do
		if isScriptEnabled then
			pulse = increasing and pulse + 0.05 or pulse - 0.05
			if pulse >= 1 then increasing = false
			elseif pulse <= 0.2 then increasing = true end
			glowFrame.BackgroundTransparency = 0.5 - (pulse * 0.3)
			statusIndicator.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
			statusText.Text = "ACTIVE"
			statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
		else
			glowFrame.BackgroundTransparency = 0.7
			statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
			statusText.Text = "OFF"
			statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
		end
		task.wait(0.1)
	end
end)

-- Make draggable
local dragging = false
local dragStart, startPos

toggleButton.MouseButton1Down:Connect(function()
	dragging = true
	dragStart = Vector2.new(localPlayer:GetMouse().X, localPlayer:GetMouse().Y)
	startPos = mainFrame.Position
end)

local UserInputService = game:GetService("UserInputService")
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = Vector2.new(localPlayer:GetMouse().X, localPlayer:GetMouse().Y) - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Visual Sequence (Progress Bar, Highlights, Particles)
local function playVisualSequence(duration)
	isProcessingSequence = true
	
	local containerFrame = Instance.new("Frame")
	containerFrame.Size = UDim2.new(0, 200, 0, 20)
	containerFrame.Position = UDim2.new(0.5, -100, 0.4, 80)
	containerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	containerFrame.Transparency = 0.1
	containerFrame.BorderSizePixel = 0
	containerFrame.Parent = screenGui
	
	local cornerContainer = Instance.new("UICorner", containerFrame)
	cornerContainer.CornerRadius = UDim.new(0, 10)
	
	local progressBar = Instance.new("Frame")
	progressBar.Size = UDim2.new(0, 0, 1, 0)
	progressBar.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
	progressBar.BorderSizePixel = 0
	progressBar.Parent = containerFrame
	
	local cornerProgress = Instance.new("UICorner", progressBar)
	cornerProgress.CornerRadius = UDim.new(0, 10)
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "PINAT TECH"
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextScaled = true
	textLabel.Parent = containerFrame
	
	local characterHighlight = Instance.new("Highlight")
	characterHighlight.Parent = character
	characterHighlight.FillTransparency = 0.2
	characterHighlight.OutlineTransparency = 0
	characterHighlight.FillColor = Color3.fromRGB(255, 50, 100)
	characterHighlight.OutlineColor = Color3.fromRGB(255, 100, 150)
	
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxassetid://243660364"
	particleEmitter.Rate = 8
	particleEmitter.Lifetime = NumberRange.new(1, 1.5)
	particleEmitter.Speed = NumberRange.new(0, 0)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.Size = NumberSequence.new({ 
		NumberSequenceKeypoint.new(0, 2), 
		NumberSequenceKeypoint.new(0.5, 5), 
		NumberSequenceKeypoint.new(1, 8) 
	})
	particleEmitter.Transparency = NumberSequence.new({ 
		NumberSequenceKeypoint.new(0, 0.2), 
		NumberSequenceKeypoint.new(1, 1) 
	})
	particleEmitter.Color = ColorSequence.new({ 
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 100)), 
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 150)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 100))
	})
	particleEmitter.LightEmission = 0.8
	particleEmitter.Parent = rootPart
	
	TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()
	
	task.delay(duration, function()
		isProcessingSequence = false
		
		if containerFrame then containerFrame:Destroy() end
		if characterHighlight then characterHighlight:Destroy() end
		if particleEmitter then particleEmitter:Destroy() end
	end)
end

-- Clear Clean Up Mechanics
local function clearPhysicsFollow()
	if alignPosition then alignPosition:Destroy() end
	if alignOrientation then alignOrientation:Destroy() end
	if renderConnection then renderConnection:Disconnect() end
	if followPart then followPart:Destroy() end
	
	for _, child in ipairs(rootPart:GetChildren()) do
		if child:IsA("Attachment") or child.Name == "HasSnapped" then
			child:Destroy()
		end
	end
end

-- Initialize Physics Positioning Logic
local function establishPhysicsFollow(targetRoot)
	clearPhysicsFollow()
	
	followPart = Instance.new("Part")
	followPart.Size = Vector3.new(0.5, 0.5, 0.5)
	followPart.Transparency = 1
	followPart.Anchored = true
	followPart.CanCollide = false
	followPart.Name = "FollowPart"
	followPart.Parent = workspace
	
	local att0_Pos = Instance.new("Attachment", rootPart)
	local att1_Pos = Instance.new("Attachment", followPart)
	local att0_Rot = Instance.new("Attachment", rootPart)
	local att1_Rot = Instance.new("Attachment", followPart)
	
	alignPosition = Instance.new("AlignPosition")
	alignPosition.Attachment0 = att0_Pos
	alignPosition.Attachment1 = att1_Pos
	alignPosition.RigidityEnabled = true
	alignPosition.Responsiveness = 200
	alignPosition.MaxForce = math.huge
	alignPosition.Parent = rootPart
	
	alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Attachment0 = att0_Rot
	alignOrientation.Attachment1 = att1_Rot
	alignOrientation.RigidityEnabled = true
	alignOrientation.Responsiveness = 100
	alignOrientation.MaxTorque = math.huge
	alignOrientation.Parent = rootPart
	
	renderConnection = RunService.RenderStepped:Connect(function()
		if targetRoot and targetRoot.Parent then
			local calculatedCFrame = targetRoot.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(55), 0, 0)
			followPart.CFrame = calculatedCFrame
			
			if not rootPart:FindFirstChild("HasSnapped") then
				rootPart.CFrame = calculatedCFrame
				local tag = Instance.new("BoolValue")
				tag.Name = "HasSnapped"
				tag.Parent = rootPart
			end
		end
	end)
end

-- Find Closest Target (Dummy or Player)
local function getClosestTarget()
	local closestDistance = maxTargetDistance
	local targetedRoot = nil
	
	local liveFolder = workspace:FindFirstChild("Live")
	if not liveFolder then return nil end

	for _, characterModel in ipairs(liveFolder:GetChildren()) do
		if characterModel:IsA("Model") and characterModel ~= character then
			local targetRoot = characterModel:FindFirstChild("HumanoidRootPart")
			local targetHumanoid = characterModel:FindFirstChildOfClass("Humanoid")
			
			if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
				local distance = (targetRoot.Position - rootPart.Position).Magnitude
				if distance <= closestDistance then
					if characterModel.Name == "Weakest Dummy" or Players:GetPlayerFromCharacter(characterModel) then
						targetedRoot = targetRoot
						closestDistance = distance
					end
				end
			end
		end
	end
	return targetedRoot
end

-- Hook Handlers to Played Animations
local function onAnimationPlayed(animationTrack)
	if not isScriptEnabled or isProcessingSequence then return end
	
	local animationId = string.match(animationTrack.Animation.AnimationId, "%d+")
	
	if BURST_ANIMATIONS[animationId] then
		isProcessingSequence = true
		task.delay(0.8, function()
			playVisualSequence(4.6)
		end)
		
	elseif DASH_ANIMATIONS[animationId] then
		isProcessingSequence = true
		task.delay(0.32, function()
			local communicationPayload = {
				{
					["Dash"] = Enum.KeyCode.W,
					["Key"] = Enum.KeyCode.Q,
					["Goal"] = "KeyPress"
				}
			}
			pcall(function()
				character:WaitForChild("Communicate"):FireServer(unpack(communicationPayload))
			end)
			
			local priorityTarget = getClosestTarget()
			if priorityTarget then
				establishPhysicsFollow(priorityTarget)
				task.delay(0.5, clearPhysicsFollow)
			end
		end)
		
		task.delay(0.8, function()
			playVisualSequence(4.6)
		end)
	end
end

-- Setup Data Tracking Routines
local function initializeCharacterTracking()
	character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	
	humanoid.AnimationPlayed:Connect(onAnimationPlayed)
end

-- Initialize System Hooks
initializeCharacterTracking()
localPlayer.CharacterAdded:Connect(function()
	task.wait(0.1)
	initializeCharacterTracking()
end)

-- Button Interaction Handling
toggleButton.MouseButton1Click:Connect(function()
	isScriptEnabled = not isScriptEnabled
	toggleButton.Text = isScriptEnabled and "PINAT TECH ✓" or "PINAT TECH"
end)

-- Console print
print("Pinat Tech")
