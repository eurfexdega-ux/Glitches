local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local isGlitching = false
local isSpeeding = false
local isLaddering = false
local isFlinging = false
local speedPower = 180
local uiVisible = true
local isLocked = false

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ValwareHub"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 40, 0, 40)
ToggleBtn.Position = UDim2.new(0.9, -10, 0.1, 0)
ToggleBtn.Text = "ON"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

local LockBtn = Instance.new("TextButton")
LockBtn.Size = UDim2.new(0, 40, 0, 40)
LockBtn.Position = UDim2.new(0.9, -10, 0.1, -50)
LockBtn.Text = "UNLOCK"
LockBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LockBtn.TextScaled = true
LockBtn.Parent = ScreenGui
Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(1, 0)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 150, 0, 450)
MainFrame.Position = UDim2.new(0.85, -50, 0.15, 0)
MainFrame.BackgroundTransparency = 1
MainFrame.Parent = ScreenGui

local function makeDraggable(obj)
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    obj.InputBegan:Connect(function(input)
        if isLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            dragInput = input
            obj:SetAttribute("IsDragging", false)
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            if isLocked then dragging = false return end
            local delta = input.Position - dragStart
            if delta.Magnitude > 5 then
                obj:SetAttribute("IsDragging", true)
            end
            if obj:GetAttribute("IsDragging") then
                obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input == dragInput then
            dragging = false
            task.delay(0.05, function()
                if obj then obj:SetAttribute("IsDragging", false) end
            end)
        end
    end)
end

local function createBtn(text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color or Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = 0.3
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    makeDraggable(btn)
    return btn
end

local flickBtn = createBtn("FLICK", UDim2.new(0, 0, 0, 0))
local ultraBtn = createBtn("ULTRA", UDim2.new(0, 0, 0, 75))
local glitchBtn = createBtn("GLITCH", UDim2.new(0, 0, 0, 150))
local flingBtn = createBtn("FLING", UDim2.new(0, 0, 0, 225), Color3.fromRGB(255, 0, 0))
local ladderBtn = createBtn("PERFECT", UDim2.new(0, 75, 0, 225))

local allButtons = {flickBtn, ultraBtn, glitchBtn, ladderBtn, flingBtn}

local SetToggle = Instance.new("TextButton")
SetToggle.Size = UDim2.new(0, 40, 0, 40)
SetToggle.Position = UDim2.new(0.05, 0, 0.5, 0)
SetToggle.Text = "SIZE"
SetToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
SetToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
SetToggle.Parent = ScreenGui
Instance.new("UICorner", SetToggle).CornerRadius = UDim.new(1, 0)

local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(0, 150, 0, 20)
SliderFrame.Position = UDim2.new(0.05, 50, 0.5, 10)
SliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SliderFrame.Visible = false
SliderFrame.Parent = ScreenGui
Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 5)

local SliderKnob = Instance.new("TextButton")
SliderKnob.Size = UDim2.new(0, 20, 1, 0)
SliderKnob.Position = UDim2.new(0.5, -10, 0, 0)
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.Text = ""
SliderKnob.Parent = SliderFrame
Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(0, 5)

SetToggle.MouseButton1Click:Connect(function()
    SliderFrame.Visible = not SliderFrame.Visible
end)

local draggingSlider = false
SliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local relativeX = math.clamp(input.Position.X - SliderFrame.AbsolutePosition.X, 0, SliderFrame.AbsoluteSize.X)
        local scale = relativeX / SliderFrame.AbsoluteSize.X
        SliderKnob.Position = UDim2.new(0, relativeX - (SliderKnob.AbsoluteSize.X / 2), 0, 0)
        
        local newSize = 30 + (70 * scale)
        for _, btn in pairs(allButtons) do
            btn.Size = UDim2.new(0, newSize, 0, newSize)
        end
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    MainFrame.Visible = uiVisible
    ToggleBtn.Text = uiVisible and "ON" or "OFF"
end)

LockBtn.MouseButton1Click:Connect(function()
    isLocked = not isLocked
    LockBtn.Text = isLocked and "LOCK" or "UNLOCK"
    LockBtn.TextColor3 = isLocked and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)
end)

flickBtn.MouseButton1Click:Connect(function()
    if flickBtn:GetAttribute("IsDragging") then return end
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        local oldCF = camera.CFrame
        camera.CFrame = oldCF * CFrame.Angles(0, math.rad(-90), 0)
        task.wait(0.03)
        camera.CFrame = oldCF
    end
end)

local function handleHoldBtn(btn, onBegin, onEnd)
    local isPressed = false
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            isPressed = true
            task.delay(0.05, function()
                if isPressed and not btn:GetAttribute("IsDragging") then
                    onBegin()
                end
            end)
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            isPressed = false
            onEnd()
        end
    end)
    btn:GetAttributeChangedSignal("IsDragging"):Connect(function()
        if btn:GetAttribute("IsDragging") then
            isPressed = false
            onEnd()
        end
    end)
end

handleHoldBtn(ultraBtn, 
    function() isGlitching = true end, 
    function() isGlitching = false end
)

handleHoldBtn(glitchBtn, 
    function() isSpeeding = true; speedPower = 180 end, 
    function() isSpeeding = false end
)

handleHoldBtn(ladderBtn, 
    function() isLaddering = true end, 
    function() isLaddering = false end
)

handleHoldBtn(flingBtn, 
    function() isFlinging = true end, 
    function() isFlinging = false end
)

task.spawn(function()
    while true do
        if isSpeeding then speedPower = speedPower + 20 end
        task.wait(0.12)
    end
end)

RunService.Heartbeat:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if not hrp or not hum then return end

    if isGlitching then
        for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 3.2)
    end

    if isSpeeding and hum.MoveDirection.Magnitude > 0 then
        hrp.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X * speedPower, hrp.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * speedPower)
        local cf = camera.CFrame
        camera.CFrame = cf * CFrame.Angles(0, math.rad(-120), 0)
        task.wait(0.02)
        camera.CFrame = cf
    end

    if isLaddering and hum:GetState() == Enum.HumanoidStateType.Climbing then
        local oldCam = camera.CFrame
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(90), 0)
        camera.CFrame = camera.CFrame * CFrame.Angles(0, math.rad(90), 0)
        task.wait(0.13)
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 40, 0) + (hrp.CFrame.LookVector * -12)
        camera.CFrame = oldCam
        task.wait(0.1)
    end

    if isFlinging then
        hum.PlatformStand = true
        hrp.Velocity = Vector3.new(0, 150, 0)
        hrp.RotVelocity = Vector3.new(0, 50, 0)
    else
        if not isLaddering then
            hum.PlatformStand = false
        end
    end
end)
