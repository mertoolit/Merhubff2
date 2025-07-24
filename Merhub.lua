-- MERBETTER FFlag System Full Script with Working Magnet Slider and Features

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Config and state
local config = {
    pullVectorStrength = 20, -- initial magnet strength
    pullVectorActive = true,
    angleEnhancerActive = true,
    qbAimbotActive = true,
    ballPathVisualizerActive = false,
    safeSpeedBoostActive = true,
    speedBoostAmount = 15,
    jumpBoostAmount = 10,
    speedBoostInterval = 2,
    speedBoostRandomize = true,
}

local qbAimbotLocked = false
local qbLockedTarget = nil

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MERBETTER_FFlag_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 200)
mainFrame.Position = UDim2.new(0.05, 0, 0.7, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = ScreenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "MERBETTER FFlag Pro"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.Parent = mainFrame

-- Magnet Strength Label
local magnetLabel = Instance.new("TextLabel")
magnetLabel.Size = UDim2.new(1, -20, 0, 20)
magnetLabel.Position = UDim2.new(0, 10, 0, 40)
magnetLabel.BackgroundTransparency = 1
magnetLabel.Text = "Magnet Strength: " .. config.pullVectorStrength
magnetLabel.TextColor3 = Color3.new(1, 1, 1)
magnetLabel.Font = Enum.Font.Gotham
magnetLabel.TextSize = 16
magnetLabel.TextXAlignment = Enum.TextXAlignment.Left
magnetLabel.Parent = mainFrame

-- Magnet Slider Track
local magnetSlider = Instance.new("Frame")
magnetSlider.Size = UDim2.new(1, -20, 0, 10)
magnetSlider.Position = UDim2.new(0, 10, 0, 65)
magnetSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
magnetSlider.Parent = mainFrame

local magnetFill = Instance.new("Frame")
magnetFill.Size = UDim2.new(config.pullVectorStrength/50, 0, 1, 0) -- Max 50
magnetFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
magnetFill.Parent = magnetSlider

local dragHandle = Instance.new("Frame")
dragHandle.Size = UDim2.new(0, 15, 1, 0)
dragHandle.Position = UDim2.new(config.pullVectorStrength/50 - 0.03, 0, 0, 0)
dragHandle.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
dragHandle.Parent = magnetSlider
dragHandle.Cursor = "PointingHand"

-- Slider Dragging Logic
local dragging = false
dragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)
dragHandle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = magnetSlider.AbsolutePosition
        local size = magnetSlider.AbsoluteSize
        local mouseX = input.Position.X
        local relativeX = math.clamp(mouseX - pos.X, 0, size.X)
        local percent = relativeX / size.X
        local newStrength = math.floor(percent * 50)
        if newStrength < 1 then newStrength = 1 end
        config.pullVectorStrength = newStrength
        magnetFill.Size = UDim2.new(percent, 0, 1, 0)
        dragHandle.Position = UDim2.new(percent - 0.03, 0, 0, 0)
        magnetLabel.Text = "Magnet Strength: " .. newStrength
    end
end)

-- QB Aimbot Lock Button
local qbLockBtn = Instance.new("TextButton")
qbLockBtn.Size = UDim2.new(0, 150, 0, 30)
qbLockBtn.Position = UDim2.new(0, 10, 0, 90)
qbLockBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
qbLockBtn.TextColor3 = Color3.new(1, 1, 1)
qbLockBtn.Text = "QB Aimbot: UNLOCKED"
qbLockBtn.Font = Enum.Font.Gotham
qbLockBtn.TextSize = 16
qbLockBtn.Parent = mainFrame

qbLockBtn.MouseButton1Click:Connect(function()
    if qbAimbotLocked then
        qbAimbotLocked = false
        qbLockedTarget = nil
        qbLockBtn.Text = "QB Aimbot: UNLOCKED"
        qbLockBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    else
        -- Lock nearest teammate
        local closestPlayer = nil
        local closestDist = math.huge
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Team == localPlayer.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (player.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestPlayer = player
                end
            end
        end
        if closestPlayer then
            qbLockedTarget = closestPlayer
            qbAimbotLocked = true
            qbLockBtn.Text = "QB Aimbot: LOCKED -> " .. qbLockedTarget.Name
            qbLockBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        else
            qbLockBtn.Text = "No Teammates Found"
            wait(1)
            qbLockBtn.Text = "QB Aimbot: UNLOCKED"
        end
    end
end)

-- Ball Path Visualizer Toggle Button
local ballPathToggleBtn = Instance.new("TextButton")
ballPathToggleBtn.Size = UDim2.new(0, 150, 0, 30)
ballPathToggleBtn.Position = UDim2.new(0, 10, 0, 130)
ballPathToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ballPathToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ballPathToggleBtn.Text = "Ball Path: OFF"
ballPathToggleBtn.Font = Enum.Font.Gotham
ballPathToggleBtn.TextSize = 16
ballPathToggleBtn.Parent = mainFrame

ballPathToggleBtn.MouseButton1Click:Connect(function()
    config.ballPathVisualizerActive = not config.ballPathVisualizerActive
    ballPathToggleBtn.Text = "Ball Path: " .. (config.ballPathVisualizerActive and "ON" or "OFF")
end)

-- Helper Functions --

local function getPullVector(ballPosition, playerPosition, strength)
    local direction = (ballPosition - playerPosition)
    local distance = direction.Magnitude
    if distance == 0 then return Vector3.new(0,0,0) end
    local pullDir = direction.Unit
    local pullStrength = math.clamp(strength / distance, 0, strength)
    return pullDir * pullStrength
end

local lastBoost = 0
local function safeSpeedJump()
    local now = tick()
    if config.safeSpeedBoostActive and now - lastBoost > config.speedBoostInterval then
        lastBoost = now
        local speedBoost = config.speedBoostAmount
        local jumpBoost = config.jumpBoostAmount
        if config.speedBoostRandomize then
            speedBoost = speedBoost * (0.8 + math.random() * 0.4)
            jumpBoost = jumpBoost * (0.8 + math.random() * 0.4)
        end

        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            local originalSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = originalSpeed + speedBoost
            delay(0.3, function()
                if humanoid then
                    humanoid.WalkSpeed = originalSpeed
                end
            end)
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

local qbAimbot = function()
    if qbAimbotLocked and qbLockedTarget and qbLockedTarget.Character and qbLockedTarget.Character:FindFirstChild("HumanoidRootPart") then
        local targetPos = qbLockedTarget.Character.HumanoidRootPart.Position
        humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, targetPos)
    end
end

local pathParts = {}
local function drawBallPath(ball)
    for _, part in pairs(pathParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    pathParts = {}

    if not config.ballPathVisualizerActive then return end
    if not ball or not ball:IsDescendantOf(game.Workspace) then return end

    local ballPos = ball.Position
    local velocity = ball.Velocity

    local predictionSteps = 20
    local timeStep = 0.1
    local gravity = workspace.Gravity or 196.2

    local pos = ballPos
    local vel = velocity

    for i = 1, predictionSteps do
        vel = vel + Vector3.new(0, -gravity * timeStep, 0)
        pos = pos + vel * timeStep

        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.Size = Vector3.new(0.3,0.3,0.3)
        part.Transparency = 0.6
        part.Color = Color3.fromRGB(0, 150, 255)
        part.Material = Enum.Material.Neon
        part.Position = pos
        part.Parent = workspace
        table.insert(pathParts, part)
    end
end

local function applyPullVector(ball)
    if not config.pullVectorActive then return end
    if not ball or not ball:IsDescendantOf(game.Workspace) then return end
    local ballPos = ball.Position
    local playerPos = humanoidRootPart.Position
    local pull = getPullVector(ballPos, playerPos, config.pullVectorStrength)

    local bodyVel = humanoidRootPart:FindFirstChild("MERPullVector") or Instance.new("BodyVelocity")
    bodyVel.Name = "MERPullVector"
    bodyVel.MaxForce = Vector3.new(1e5, 0, 1e5)
    bodyVel.Velocity = Vector3.new(pull.X, 0, pull.Z)
    bodyVel.Parent = humanoidRootPart

    delay(0.1, function()
        if bodyVel and bodyVel.Parent then
            bodyVel:Destroy()
        end
    end)
end

-- Main Loop
RunService.Heartbeat:Connect(function()
    if not character or not character.Parent then
        character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    end

    local ball = workspace:FindFirstChild("Ball") or workspace:FindFirstChild("Football")

    if ball then
        applyPullVector(ball)
        drawBallPath(ball)
    end

    qbAimbot()
    safeSpeedJump()
end)

print("[MERBETTER] FFlag system loaded. Use the GUI to adjust settings.")
