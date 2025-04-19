-- Checkpoint Runner GUI for Roblox
-- This script creates a GUI with buttons to teleport through checkpoints in an obby game.
-- Supports checkpoints 1-60 (First Half) and 61-120 (Second Half) with a 400ms delay between teleports.
-- Features UICorner for rounded edges and a Stop button to interrupt the sequence.
-- Author: [Your Name]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheckpointGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
local success, err = pcall(function()
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 10)
end)
if not success then
    warn("Failed to set ScreenGui parent: " .. tostring(err))
    return
end
print("ScreenGui created!")

-- Основной фрейм (перемещаемый)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 200)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Visible = true
print("Main Frame created!")

-- Добавляем UICorner для основного фрейма
local mainFrameCorner = Instance.new("UICorner")
mainFrameCorner.CornerRadius = UDim.new(0, 10)
mainFrameCorner.Parent = mainFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Checkpoint Runner"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

-- Добавляем UICorner для заголовка
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Кнопка "First Half"
local firstHalfButton = Instance.new("TextButton")
firstHalfButton.Size = UDim2.new(1, -20, 0, 40)
firstHalfButton.Position = UDim2.new(0, 10, 0, 40)
firstHalfButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
firstHalfButton.Text = "First Half (1-60)"
firstHalfButton.TextColor3 = Color3.fromRGB(255, 255, 255)
firstHalfButton.TextSize = 16
firstHalfButton.Font = Enum.Font.SourceSans
firstHalfButton.Parent = mainFrame

-- Добавляем UICorner для кнопки "First Half"
local firstHalfButtonCorner = Instance.new("UICorner")
firstHalfButtonCorner.CornerRadius = UDim.new(0, 8)
firstHalfButtonCorner.Parent = firstHalfButton

-- Кнопка "Second Half"
local secondHalfButton = Instance.new("TextButton")
secondHalfButton.Size = UDim2.new(1, -20, 0, 40)
secondHalfButton.Position = UDim2.new(0, 10, 0, 90)
secondHalfButton.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
secondHalfButton.Text = "Second Half (61-120)"
secondHalfButton.TextColor3 = Color3.fromRGB(255, 255, 255)
secondHalfButton.TextSize = 16
secondHalfButton.Font = Enum.Font.SourceSans
secondHalfButton.Parent = mainFrame

-- Добавляем UICorner для кнопки "Second Half"
local secondHalfButtonCorner = Instance.new("UICorner")
secondHalfButtonCorner.CornerRadius = UDim.new(0, 8)
secondHalfButtonCorner.Parent = secondHalfButton

-- Кнопка "Stop"
local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(1, -20, 0, 40)
stopButton.Position = UDim2.new(0, 10, 0, 140)
stopButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
stopButton.Text = "Stop Sequence"
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.TextSize = 16
stopButton.Font = Enum.Font.SourceSans
stopButton.Parent = mainFrame

-- Добавляем UICorner для кнопки "Stop"
local stopButtonCorner = Instance.new("UICorner")
stopButtonCorner.CornerRadius = UDim.new(0, 8)
stopButtonCorner.Parent = stopButton

-- Функция для перемещения GUI
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Ожидание загрузки персонажа
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
if not humanoidRootPart then
    warn("HumanoidRootPart not found! Cannot proceed.")
    return
end
print("Character loaded!")

-- Обновление персонажа при респавне
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
    if not humanoidRootPart then
        warn("HumanoidRootPart not found after respawn!")
    else
        print("Character reloaded after respawn!")
    end
end)

-- Функция проверки наличия чекпоинтов
local function checkCheckpoints(start, finish)
    local checkpointsFolder = Workspace:FindFirstChild("Checkpoints")
    if not checkpointsFolder then
        warn("Checkpoints folder not found in Workspace!")
        return false
    end

    for i = start, finish do
        local checkpoint = checkpointsFolder:FindFirstChild(tostring(i))
        if not checkpoint then
            warn("Checkpoint " .. i .. " not found!")
            return false
        end
        local targetPart = checkpoint:IsA("BasePart") and checkpoint or checkpoint:FindFirstChildWhichIsA("BasePart")
        if not targetPart then
            warn("No BasePart found in Checkpoint " .. i .. "!")
            return false
        end
    end
    print("All checkpoints from " .. start .. " to " .. finish .. " are valid!")
    return true
end

-- Функция телепортации
local function teleportToCheckpoint(checkpointNumber)
    local checkpointsFolder = Workspace:FindFirstChild("Checkpoints")
    if not checkpointsFolder then
        warn("Checkpoints folder not found in Workspace!")
        return false
    end

    local checkpoint = checkpointsFolder:FindFirstChild(tostring(checkpointNumber))
    if not checkpoint then
        warn("Checkpoint " .. checkpointNumber .. " not found!")
        return false
    end

    local targetPart = checkpoint:IsA("BasePart") and checkpoint or checkpoint:FindFirstChildWhichIsA("BasePart")
    if not targetPart then
        warn("No BasePart found in Checkpoint " .. checkpointNumber .. "!")
        return false
    end

    humanoidRootPart.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 3, 0))
    print("Teleported to Checkpoint " .. checkpointNumber)
    return true
end

-- Функция прохождения чекпоинтов
local isRunning = false
local function runCheckpoints(start, finish)
    if isRunning then
        warn("Already running a checkpoint sequence!")
        return
    end

    if not checkCheckpoints(start, finish) then
        warn("Cannot proceed: Some checkpoints are missing or invalid!")
        return
    end

    isRunning = true
    firstHalfButton.Text = start == 1 and "Running (1-60)..." or "First Half (1-60)"
    secondHalfButton.Text = start == 61 and "Running (61-120)..." or "Second Half (61-120)"

    for i = start, finish do
        if not isRunning then
            break
        end
        if not character or not humanoidRootPart.Parent then
            warn("Character lost during sequence!")
            isRunning = false
            break
        end

        local success = teleportToCheckpoint(i)
        if not success then
            isRunning = false
            break
        end
        wait(0.4) -- Задержка 400 мс
    end

    isRunning = false
    firstHalfButton.Text = "First Half (1-60)"
    secondHalfButton.Text = "Second Half (61-120)"
    print("Finished running checkpoints from " .. start .. " to " .. (isRunning and finish or "interrupted"))
end

-- Обработчики кнопок
firstHalfButton.MouseButton1Click:Connect(function()
    runCheckpoints(1, 60)
end)

secondHalfButton.MouseButton1Click:Connect(function()
    runCheckpoints(61, 120)
end)

-- Кнопка остановки
stopButton.MouseButton1Click:Connect(function()
    if isRunning then
        isRunning = false
        firstHalfButton.Text = "First Half (1-60)"
        secondHalfButton.Text = "Second Half (61-120)"
        print("Checkpoint sequence stopped!")
    end
end)

-- Переключение видимости GUI (RightShift)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
        print("GUI visibility toggled: " .. tostring(mainFrame.Visible))
    end
end)

-- Уведомление о загрузке
print("Checkpoint Runner GUI loaded! Press RightShift to toggle GUI. Use Stop button to interrupt sequence.")
