-- MERBETTER Full Script for Football Fusion (Roblox)
-- Features: FFlag system, ESP, Anti-ban, Save System, Draggable Tab GUI, Purple/Black theme
-- Key Prompt: "mer" or "merlok"
-- Author: mer

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Configuration with default values
local config = {
    pullVectorStrength = 20,
    pullVectorActive = true,
    angleEnhancerActive = true,
    qbAimbotActive = true,
    ballPathVisualizerActive = false,
    safeSpeedBoostActive = true,
    speedBoostAmount = 15,
    jumpBoostAmount = 10,
    speedBoostInterval = 2,
    speedBoostRandomize = true,

    espEnabled = false,
    espTeamColor = Color3.fromRGB(0, 255, 255),
    espEnemyColor = Color3.fromRGB(255, 0, 0),

    theme = {
        background = Color3.fromRGB(30, 30, 30),
        accent = Color3.fromRGB(128, 0, 255),
        text = Color3.fromRGB(255, 255, 255),
        toggleOn = Color3.fromRGB(0, 200, 150),
        toggleOff = Color3.fromRGB(120, 120, 120),
    }
}

local savesFilename = "MerhubFF2Config_" .. localPlayer.UserId .. ".json"

-- Save settings to file
local function saveSettings()
    local success, err = pcall(function()
        local json = HttpService:JSONEncode(config)
        writefile(savesFilename, json)
    end)
    if not success then
        warn("Merhub save failed: " .. tostring(err))
    end
end

-- Load settings from file
local function loadSettings()
    if isfile and isfile(savesFilename) then
        local success, data = pcall(function()
            return readfile(savesFilename)
        end)
        if success and data then
            local ok, decoded = pcall(function()
                return HttpService:JSONDecode(data)
            end)
            if ok and decoded then
                for k, v in pairs(decoded) do
                    config[k] = v
                end
            end
        end
    end
end

loadSettings()

-- Anti-Ban Utilities
local function randomDelay(min, max)
    local waitTime = min + math.random() * (max - min)
    task.wait(waitTime)
end

local function cleanupBodyVelocity()
    for _, v in pairs(hrp:GetChildren()) do
        if v:IsA("BodyVelocity") and v.Name == "MERPullVector" then
            v:Destroy()
        end
    end
end

local function cleanupPathParts(parts)
    for _, p in pairs(parts) do
        if p and p.Parent then
            p:Destroy()
        end
    end
end

-- Key Prompt GUI (Free Version)
local function showKeyPrompt()
    local promptGui = Instance.new("ScreenGui")
    promptGui.Name = "MERBETTER_KeyPrompt"
    promptGui.Parent = playerGui
    promptGui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.4, -75)
    frame.BackgroundColor3 = config.theme.background
    frame.BorderSizePixel = 0
    frame.Parent = promptGui
    frame.Active = true
    frame.Draggable = true

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Enter your MERBETTER Key"
    title.TextColor3 = config.theme.text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.Parent = frame

    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(1, -20, 0, 40)
    textbox.Position = UDim2.new(0, 10, 0, 50)
    textbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    textbox.TextColor3 = config.theme.text
    textbox.Font = Enum.Font.Gotham
    textbox.TextSize = 20
    textbox.ClearTextOnFocus = false
    textbox.PlaceholderText = "Enter Key Here"
    textbox.Parent = frame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 20)
    statusLabel.Position = UDim2.new(0, 10, 0, 95)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 16
    statusLabel.Text = ""
    statusLabel.Parent = frame

    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(0, 100, 0, 30)
    submitBtn.Position = UDim2.new(0.5, -50, 1, -40)
    submitBtn.BackgroundColor3 = config.theme.accent
    submitBtn.TextColor3 = config.theme.text
    submitBtn.Text = "Submit"
    submitBtn.Font = Enum.Font.Gotham
    submitBtn.TextSize = 18
    submitBtn.Parent = frame

    local validKeys = {
        mer = true,
        merlok = true,
    }

    local function checkKey(key)
        key = key:lower()
        if validKeys[key] then
            return true
        else
            return false
        end
    end

    local onSuccess = Instance.new("BindableEvent")

    submitBtn.MouseButton1Click:Connect(function()
        local enteredKey = textbox.Text
        if checkKey(enteredKey) then
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
            statusLabel.Text = "Key accepted! Loading..."
            task.wait(1)
            promptGui:Destroy()
            onSuccess:Fire()
        else
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            statusLabel.Text = "Invalid Key! Try again."
        end
    end)

    return onSuccess.Event
end

-- Free/Paid selection prompt GUI
local function showVersionPrompt()
    local promptGui = Instance.new("ScreenGui")
    promptGui.Name = "MERBETTER_VersionPrompt"
    promptGui.Parent = playerGui
    promptGui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.4, -75)
    frame.BackgroundColor3 = config.theme.background
    frame.BorderSizePixel = 0
    frame.Parent = promptGui
    frame.Active = true
    frame.Draggable = true

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Select your version"
    title.TextColor3 = config.theme.text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.Parent = frame

    local freeBtn = Instance.new("TextButton")
    freeBtn.Size = UDim2.new(0, 120, 0, 40)
    freeBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
    freeBtn.BackgroundColor3 = config.theme.accent
    freeBtn.TextColor3 = config.theme.text
    freeBtn.Text = "Free Version"
    freeBtn.Font = Enum.Font.Gotham
    freeBtn.TextSize = 18
    freeBtn.Parent = frame

    local paidBtn = Instance.new("TextButton")
    paidBtn.Size = UDim2.new(0, 120, 0, 40)
    paidBtn.Position = UDim2.new(0.6, 0, 0.6, 0)
    paidBtn.BackgroundColor3 = config.theme.accent
    paidBtn.TextColor3 = config.theme.text
    paidBtn.Text = "Paid Version"
    paidBtn.Font = Enum.Font.Gotham
    paidBtn.TextSize = 18
    paidBtn.Parent = frame

    local selectedVersion = Instance.new("BindableEvent")

    freeBtn.MouseButton1Click:Connect(function()
        promptGui:Destroy()
        selectedVersion:Fire(false) -- false means Free version
    end)

    paidBtn.MouseButton1Click:Connect(function()
        promptGui:Destroy()
        selectedVersion:Fire(true) -- true means Paid version
    end)

    return selectedVersion.Event
end

-- Wait for version then key if needed
local isPaidUser = nil
local versionEvent = showVersionPrompt()
versionEvent:Wait(function(paid)
    isPaidUser = paid
end)

if not isPaidUser then
    local keyEvent = showKeyPrompt()
    keyEvent:Wait()
end

-- Main Hub GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MERBETTER_FFlag_GUI"
ScreenGui.Parent = playerGui
ScreenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 320)
mainFrame.Position = UDim2.new(0.05, 0, 0.6, 0)
mainFrame.BackgroundColor3 = config.theme.background
mainFrame.BorderSizePixel = 0
mainFrame.Parent = ScreenGui
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 32)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "MERBETTER - FF2 Pro Hub"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 22
titleLabel.TextColor3 = config.theme.text
titleLabel.Parent = mainFrame

-- Tab system
local tabs = {"FFlag", "ESP", "Settings"}
local tabButtons = {}
local pages = {}

local function createTabButton(text, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 30)
    btn.Position = UDim2.new(0, (index - 1) * 95 + 5, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = config.theme.text
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Parent = mainFrame
    return btn
end

local function createPage(index)
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, -10, 1, -75)
    page.Position = UDim2.new(0, 5, 0, 70)
    page.BackgroundTransparency = 1
    page.Visible = (index == 1)
    page.Parent = mainFrame
    return page
end

for i, tabName in ipairs(tabs) do
    tabButtons[i] = createTabButton(tabName, i)
    pages[i] = createPage(i)
end

local function switchTab(index)
    for i, page in ipairs(pages) do
        page.Visible = (i == index)
        tabButtons[i].BackgroundColor3 = (i == index) and config.theme.accent or Color3.fromRGB(60, 60, 60)
    end
end

for i, btn in ipairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        switchTab(i)
    end)
end

-- ==== FFlag Tab UI ====

local FFlagPage = pages[1]

-- Magnet Strength Label
local magnetLabel = Instance.new("TextLabel")
magnetLabel.Size = UDim2.new(1, -20, 0, 20)
magnetLabel.Position = UDim2.new(0, 10, 0, 0)
magnetLabel.BackgroundTransparency = 1
magnetLabel.Text = "Magnet Strength: " .. config.pullVectorStrength
magnetLabel.TextColor3 = config.theme.text
magnetLabel.Font = Enum.Font.Gotham
magnetLabel.TextSize = 16
magnetLabel.TextXAlignment = Enum.TextXAlignment.Left
magnetLabel.Parent = FFlagPage

-- Magnet Slider Track
local magnetSlider = Instance.new("Frame")
magnetSlider.Size = UDim2.new(1, -20, 0, 12)
magnetSlider.Position = UDim2.new(0, 10, 0, 30)
magnetSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
magnetSlider.Parent = FFlagPage

local magnetFill = Instance.new("Frame")
magnetFill.Size = UDim2.new(config.pullVectorStrength / 50, 0, 1, 0) -- Max 50
magnetFill.BackgroundColor3 = config.theme.accent
magnetFill.Parent = magnetSlider

local dragHandle = Instance.new("Frame")
dragHandle.Size = UDim2.new(0, 15, 1, 0)
dragHandle.Position = UDim2.new(config.pullVectorStrength / 50 - 0.03, 0, 0, 0)
dragHandle.BackgroundColor3 = config.theme.accent
dragHandle.Parent = magnetSlider
dragHandle.Cursor = "PointingHand"

-- Slider dragging logic
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
        saveSettings()
    end
end)

-- QB Aimbot Toggle Button
local qbAimbotToggle = Instance.new("TextButton")
qbAimbotToggle.Size = UDim2.new(0, 200, 0, 30)
qbAimbotToggle.Position = UDim2.new(0, 10, 0, 60)
qbAimbotToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
qbAimbotToggle.TextColor3 = config.theme.text
qbAimbotToggle.Text = "Toggle QB Aimbot (ON)"
qbAimbotToggle.Font = Enum.Font.Gotham
qbAimbotToggle.TextSize = 16
qbAimbotToggle.Parent = FFlagPage

local qbAimbotEnabled = true
local qbLockedTarget = nil
local qbAimbotLocked = false

qbAimbotToggle.MouseButton1Click:Connect(function()
    qbAimbotEnabled = not qbAimbotEnabled
    qbLockedTarget = nil
    qbAimbotLocked = false
    qbAimbotToggle.Text = "Toggle QB Aimbot (" .. (qbAimbotEnabled and "ON" or "OFF") .. ")"
    saveSettings()
end)

-- QB Lock/Unlock Button
local qbLockBtn = Instance.new("TextButton")
qbLockBtn.Size = UDim2.new(0, 200, 0, 30)
qbLockBtn.Position = UDim2.new(0, 10, 0, 100)
qbLockBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
qbLockBtn.TextColor3 = config.theme.text
qbLockBtn.Text = "Lock QB Aimbot to Nearest"
qbLockBtn.Font = Enum.Font.Gotham
qbLockBtn.TextSize = 16
qbLockBtn.Parent = FFlagPage

qbLockBtn.MouseButton1Click:Connect(function()
    if not qbAimbotEnabled then return end
    if qbAimbotLocked then
        qbAimbotLocked = false
        qbLockedTarget = nil
        qbLockBtn.Text = "Lock QB Aimbot to Nearest"
    else
        local closestPlayer = nil
        local closestDist = math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= localPlayer and p.Team == localPlayer.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestPlayer = p
                end
            end
        end
        if closestPlayer then
            qbLockedTarget = closestPlayer
            qbAimbotLocked = true
            qbLockBtn.Text = "Unlocked from " .. closestPlayer.Name .. " (Click to Unlock)"
        else
            qbLockBtn.Text = "No Teammates Found"
