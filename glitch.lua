-- ==========================================
-- seekit.glitch v0.2.0 - Clean UI Redo
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Trạng thái
local states = { glitch = false, perfect = false, macro = false }
local isNoclipping = false
local IS_GLOBAL_LOCKED = true 
local IS_ADJUSTING = false 

-- Biến Logic
local isNormalGlitchEnabled = false
local isLegitGlitchEnabled = false
local isMacroEnabled = false

local targetSpeed = 800
local accelTime = 3 
local camSpinSpeed = 270
local spinWaitMs = 15 
local offsetGlitch = -35 
local noclipPower = 180
local noclipTime = 0.5
local globalBtnSize = 60 

-- ==========================================
-- KHỞI TẠO GUI CƠ BẢN
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "seekit.glitch.v0.2.0"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = false

local function tween(obj, props, time)
    local tw = TweenService:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local DimBackground = Instance.new("Frame")
DimBackground.Size = UDim2.new(1, 0, 1, 0); DimBackground.BackgroundColor3 = Color3.new(0,0,0)
DimBackground.BackgroundTransparency = 1; DimBackground.ZIndex = 0; DimBackground.Visible = false
DimBackground.Parent = ScreenGui

local BlurEffect = Instance.new("BlurEffect"); BlurEffect.Size = 0; BlurEffect.Parent = Lighting

-- Watermark
local Watermark = Instance.new("TextLabel")
Watermark.Position = UDim2.new(0, 20, 0, 50); Watermark.Size = UDim2.new(0, 0, 0, 26)
Watermark.AutomaticSize = Enum.AutomaticSize.X
Watermark.Text = " seekit.glitch | FPS: -- | Ping: --ms "
Watermark.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Watermark.BackgroundTransparency = 0.2
Watermark.Font = Enum.Font.GothamBold; Watermark.TextSize = 11; Watermark.Parent = ScreenGui
local wmPad = Instance.new("UIPadding", Watermark); wmPad.PaddingLeft = UDim.new(0, 12); wmPad.PaddingRight = UDim.new(0, 12)
Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 6)
local wmStroke = Instance.new("UIStroke", Watermark); wmStroke.Color = Color3.new(1,1,1); wmStroke.Transparency = 0.8

local frameCount, currentFPS, lastTick = 0, 60, tick()
RunService.RenderStepped:Connect(function()
    frameCount += 1
    if tick() - lastTick >= 1 then currentFPS = frameCount; frameCount = 0; lastTick = tick() end
end)
task.spawn(function()
    while task.wait(0.5) do
        Watermark.Text = " seekit.glitch | FPS: " .. currentFPS .. " | Ping: " .. math.floor(player:GetNetworkPing() * 1000) .. "ms "
    end
end)

-- ==========================================
-- FLOATING ACTION BUTTONS
-- ==========================================
local actionButtons = {}
local function createFloatingBtn(name, posScaleY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, globalBtnSize, 0, globalBtnSize)
    btn.Position = UDim2.new(0.85, 0, posScaleY, 0)
    btn.Text = name; btn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    btn.BackgroundTransparency = 0.3; btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 10; btn.Visible = false; btn.Parent = ScreenGui
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    local st = Instance.new("UIStroke", btn); st.Color = Color3.new(1,1,1); st.Transparency = 0.7; st.Thickness = 1

    local drag, ds, sp
    btn.InputBegan:Connect(function(i)
        if not IS_GLOBAL_LOCKED and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            drag = true; ds = i.Position; sp = btn.Position
            tween(btn, {Size = UDim2.new(0, globalBtnSize + 6, 0, globalBtnSize + 6)}, 0.15)
        end
    end)
    btn.InputEnded:Connect(function() 
        drag = false; if not IS_GLOBAL_LOCKED then tween(btn, {Size = UDim2.new(0, globalBtnSize, 0, globalBtnSize)}, 0.15) end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and not IS_GLOBAL_LOCKED and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds; btn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    table.insert(actionButtons, btn); return btn
end

local btnGlitch = createFloatingBtn("GLITCH", 0.25)
local btnMacro  = createFloatingBtn("MACRO", 0.35) 
local btnFlick  = createFloatingBtn("FLICK", 0.45)
local btnLadder = createFloatingBtn("LADDER", 0.55)
local btnUltra  = createFloatingBtn("ULTRA", 0.65)

-- ==========================================
-- MENU FRAME
-- ==========================================
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 420, 0, 420) 
MenuFrame.Position = UDim2.new(0.5, -210, 0.5, -210)
MenuFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MenuFrame.BackgroundTransparency = 0.05
MenuFrame.Parent = ScreenGui
Instance.new("UICorner", MenuFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MenuFrame).Color = Color3.new(1,1,1); Instance.new("UIStroke", MenuFrame).Transparency = 0.6

local MenuTitle = Instance.new("TextLabel")
MenuTitle.Size = UDim2.new(1, -40, 0, 40); MenuTitle.Position = UDim2.new(0, 20, 0, 5)
MenuTitle.Text = "seekit.glitch"
MenuTitle.Font = Enum.Font.GothamBold; MenuTitle.TextSize = 16
MenuTitle.TextXAlignment = Enum.TextXAlignment.Left; MenuTitle.BackgroundTransparency = 1; MenuTitle.Parent = MenuFrame

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -30, 1, -55); ScrollFrame.Position = UDim2.new(0, 15, 0, 45)
ScrollFrame.BackgroundTransparency = 1; ScrollFrame.ScrollBarThickness = 2
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0); ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.BorderSizePixel = 0; ScrollFrame.Parent = MenuFrame
local UIList = Instance.new("UIListLayout", ScrollFrame); UIList.Padding = UDim.new(0, 8); UIList.SortOrder = Enum.SortOrder.LayoutOrder

RunService.RenderStepped:Connect(function() 
    local hue = (tick() % 4) / 4; local c = Color3.fromHSV(hue, 1, 1)
    MenuTitle.TextColor3 = c; Watermark.TextColor3 = c
end)

-- Drag Menu
local dM, dS, sP
MenuFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dM = true; dS = i.Position; sP = MenuFrame.Position end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dM = false end end)
UIS.InputChanged:Connect(function(i) if dM and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
    MenuFrame.Position = UDim2.new(sP.X.Scale, sP.X.Offset + (i.Position - dS).X, sP.Y.Scale, sP.Y.Offset + (i.Position - dS).Y)
end end)

-- ==========================================
-- UI LIBRARY (CLEAN REDO)
-- ==========================================
local UI = {}
local layoutOrderCount = 0

function UI.CreateSection(title)
    layoutOrderCount += 1
    local sec = Instance.new("Frame")
    sec.Size = UDim2.new(1, 0, 0, 30); sec.BackgroundTransparency = 1; sec.LayoutOrder = layoutOrderCount; sec.Parent = ScrollFrame
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, 0, 1, 0); lb.Position = UDim2.new(0, 5, 0, 5)
    lb.Text = title:upper(); lb.TextColor3 = Color3.fromRGB(150, 150, 255)
    lb.Font = Enum.Font.GothamBold; lb.TextSize = 11; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.BackgroundTransparency = 1; lb.Parent = sec
end

function UI.CreateToggle(text, default, callback)
    layoutOrderCount += 1
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36); btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.LayoutOrder = layoutOrderCount; btn.AutoButtonColor = false; btn.Text = ""; btn.Parent = ScrollFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -60, 1, 0); lb.Position = UDim2.new(0, 15, 0, 0)
    lb.Text = text; lb.TextColor3 = Color3.new(1,1,1); lb.Font = Enum.Font.GothamMedium; lb.TextSize = 12
    lb.TextXAlignment = Enum.TextXAlignment.Left; lb.BackgroundTransparency = 1; lb.Parent = btn

    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 40, 0, 20); switch.Position = UDim2.new(1, -55, 0.5, -10)
    switch.BackgroundColor3 = default and Color3.new(1,1,1) or Color3.fromRGB(50, 50, 50); switch.Parent = btn
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14); knob.Position = UDim2.new(default and 1 or 0, default and -17 or 3, 0.5, -7)
    knob.BackgroundColor3 = default and Color3.new(0,0,0) or Color3.fromRGB(150, 150, 150); knob.Parent = switch
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            tween(switch, {BackgroundColor3 = Color3.new(1,1,1)}, 0.2)
            tween(knob, {Position = UDim2.new(1, -17, 0.5, -7), BackgroundColor3 = Color3.new(0,0,0)}, 0.2)
        else
            tween(switch, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.2)
            tween(knob, {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}, 0.2)
        end
        callback(state)
    end)
end

function UI.CreateSlider(text, min, max, default, step, callback)
    layoutOrderCount += 1
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 45); frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); frame.LayoutOrder = layoutOrderCount; frame.Parent = ScrollFrame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -60, 0, 20); lb.Position = UDim2.new(0, 15, 0, 5)
    lb.Text = text; lb.TextColor3 = Color3.fromRGB(200, 200, 200); lb.Font = Enum.Font.Gotham; lb.TextSize = 11
    lb.TextXAlignment = Enum.TextXAlignment.Left; lb.BackgroundTransparency = 1; lb.Parent = frame

    local valLb = Instance.new("TextLabel")
    valLb.Size = UDim2.new(0, 50, 0, 20); valLb.Position = UDim2.new(1, -65, 0, 5)
    valLb.Text = tostring(default); valLb.TextColor3 = Color3.new(1,1,1); valLb.Font = Enum.Font.GothamBold; valLb.TextSize = 11
    valLb.TextXAlignment = Enum.TextXAlignment.Right; valLb.BackgroundTransparency = 1; valLb.Parent = frame

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -30, 0, 3); bg.Position = UDim2.new(0, 15, 0, 30); bg.BackgroundColor3 = Color3.fromRGB(60, 60, 60); bg.Parent = frame
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.new(1,1,1); fill.Parent = bg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12); knob.Position = UDim2.new(1, -6, 0.5, -6); knob.BackgroundColor3 = Color3.new(1,1,1); knob.Parent = fill
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    bg.InputBegan:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
            dragging = true; IS_ADJUSTING = true; tween(knob, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -8, 0.5, -8)}, 0.15)
        end 
    end)
    UIS.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
            dragging = false; IS_ADJUSTING = false; tween(knob, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -6, 0.5, -6)}, 0.15)
        end 
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            local val = min + (rel * (max - min))
            if step then val = math.floor(val / step + 0.5) * step end
            valLb.Text = (step and step < 1) and string.format((step == 0.01 and "%.2f" or "%.1f"), val) or tostring(val)
            callback(val)
        end
    end)
end

function UI.CreateButton(text, color, callback)
    layoutOrderCount += 1
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36); btn.BackgroundColor3 = color or Color3.fromRGB(30, 30, 30)
    btn.Text = text; btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
    btn.LayoutOrder = layoutOrderCount; btn.Parent = ScrollFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ==========================================
-- BUILD THE MENU (ĐỔ DỮ LIỆU)
-- ==========================================

UI.CreateSection("Normal Speed Glitch")
UI.CreateToggle("Enable Normal Glitch", false, function(s) isNormalGlitchEnabled = s; btnGlitch.Visible = s end)
UI.CreateSlider("Target Speed", 150, 24000, 800, 10, function(v) targetSpeed = v end)
UI.CreateSlider("Accel Time (s)", 0.1, 10, 3, 0.1, function(v) accelTime = v end)
UI.CreateSlider("Cam Spin Angle (°)", 10, 360, 270, 5, function(v) camSpinSpeed = v end)
UI.CreateSlider("Cam Spin Delay (ms)", 1, 100, 15, 1, function(v) spinWaitMs = v end)

UI.CreateSection("Legit Speed Glitch")
UI.CreateToggle("Enable Legit Glitch (GripPos)", false, function(s) isLegitGlitchEnabled = s end)
UI.CreateToggle("Show Macro Button (Cam Spin)", false, function(s) isMacroEnabled = s; btnMacro.Visible = s end)
UI.CreateSlider("Grip Offset (Studs)", -50, 50, -35, 1, function(v) offsetGlitch = v end)

UI.CreateSection("Movement Exploits")
UI.CreateToggle("Wall Hop (Flick)", false, function(s) btnFlick.Visible = s end)
UI.CreateToggle("Ladder Flick (Perfect)", false, function(s) btnLadder.Visible = s end)
UI.CreateToggle("Noclip Push (Ultra)", false, function(s) btnUltra.Visible = s end)
UI.CreateSlider("Push Power", 1, 300, 180, 1, function(v) noclipPower = v end)
UI.CreateSlider("Push Time (s)", 0.01, 1, 0.5, 0.01, function(v) noclipTime = v end)

UI.CreateSection("HUD Settings")
local editBtnLabel = "UNLOCK HUD (EDIT MODE)"
UI.CreateButton(editBtnLabel, Color3.fromRGB(30, 30, 80), function()
    IS_GLOBAL_LOCKED = not IS_GLOBAL_LOCKED
    if not IS_GLOBAL_LOCKED then
        DimBackground.Visible = true; tween(DimBackground, {BackgroundTransparency = 0.5})
        tween(BlurEffect, {Size = 15})
        for _, b in pairs(actionButtons) do tween(b, {BackgroundTransparency = 0.1}); b:FindFirstChild("UIStroke").Color = Color3.fromRGB(255, 50, 50) end
    else
        tween(DimBackground, {BackgroundTransparency = 1}).Completed:Connect(function() DimBackground.Visible = false end)
        tween(BlurEffect, {Size = 0})
        for _, b in pairs(actionButtons) do tween(b, {BackgroundTransparency = 0.3}); b:FindFirstChild("UIStroke").Color = Color3.new(1,1,1) end
    end
end)
UI.CreateSlider("Floating Button Size", 40, 120, 60, 1, function(v)
    globalBtnSize = v
    for _, b in pairs(actionButtons) do b.Size = UDim2.new(0, v, 0, v) end
end)

-- ==========================================
-- OPEN/CLOSE MENU BUTTON ("S")
-- ==========================================
local OpenMenuBtn = Instance.new("TextButton")
OpenMenuBtn.Size = UDim2.new(0, 42, 0, 42); OpenMenuBtn.Position = UDim2.new(0, 20, 0.15, 0)
OpenMenuBtn.Text = "S"; OpenMenuBtn.BackgroundColor3 = Color3.new(0,0,0); OpenMenuBtn.BackgroundTransparency = 0.2
OpenMenuBtn.TextColor3 = Color3.new(1,1,1); OpenMenuBtn.Font = Enum.Font.GothamBlack; OpenMenuBtn.TextSize = 18
OpenMenuBtn.Parent = ScreenGui
Instance.new("UICorner", OpenMenuBtn).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", OpenMenuBtn).Color = Color3.new(1,1,1); Instance.new("UIStroke", OpenMenuBtn).Transparency = 0.5

local isMenuOpen = true
local dbBtn, dsBtn, spBtn
OpenMenuBtn.InputBegan:Connect(function(i) 
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
        dbBtn = true; dsBtn = i.Position; spBtn = OpenMenuBtn.Position; tween(OpenMenuBtn, {Size = UDim2.new(0, 46, 0, 46)}, 0.15)
    end 
end)
UIS.InputEnded:Connect(function(i) 
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
        dbBtn = false; tween(OpenMenuBtn, {Size = UDim2.new(0, 42, 0, 42)}, 0.15)
    end 
end)
UIS.InputChanged:Connect(function(i) 
    if dbBtn and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        OpenMenuBtn.Position = UDim2.new(spBtn.X.Scale, spBtn.X.Offset + (i.Position - dsBtn).X, spBtn.Y.Scale, spBtn.Y.Offset + (i.Position - dsBtn).Y)
    end 
end)

OpenMenuBtn.MouseButton1Click:Connect(function() 
    isMenuOpen = not isMenuOpen
    if isMenuOpen then
        MenuFrame.Visible = true; tween(MenuFrame, {Size = UDim2.new(0, 420, 0, 420)}, 0.3)
    else
        tween(MenuFrame, {Size = UDim2.new(0, 420, 0, 0)}, 0.2).Completed:Connect(function() if not isMenuOpen then MenuFrame.Visible = false end end)
    end
end)

-- ==========================================
-- CORE LOGIC (VẬN HÀNH)
-- ==========================================

-- Vòng lặp cho Speed Glitch Legit
task.spawn(function()
    while task.wait() do
        if isLegitGlitchEnabled and player.Character then
            local tool = player.Character:FindFirstChildOfClass("Tool")
            if tool then
                tool.GripPos = Vector3.new(0, 0, offsetGlitch)
                task.wait() 
                tool.GripPos = Vector3.new(0, 0, 0)
            end
        end
    end
end)

local currentRunSpeed = 0
local speedStartTime = 0

btnGlitch.InputBegan:Connect(function(i) if IS_GLOBAL_LOCKED and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1) then states.glitch = true; speedStartTime = tick() end end)
btnGlitch.InputEnded:Connect(function() states.glitch = false end)

btnMacro.InputBegan:Connect(function(i) if IS_GLOBAL_LOCKED and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1) then states.macro = true end end)
btnMacro.InputEnded:Connect(function() states.macro = false end)

RunService.Heartbeat:Connect(function()
    -- Normal Glitch
    if states.glitch and isNormalGlitchEnabled and player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.MoveDirection.Magnitude > 0 then
            local elapsed = tick() - speedStartTime
            currentRunSpeed = (elapsed / accelTime) * targetSpeed
            if elapsed > accelTime then currentRunSpeed = currentRunSpeed + (elapsed * 10) end
            root.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X * currentRunSpeed, root.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * currentRunSpeed)
            
            local cf = camera.CFrame
            camera.CFrame = cf * CFrame.Angles(0, math.rad(-camSpinSpeed), 0)
            task.wait(spinWaitMs / 1000)
            camera.CFrame = cf
        end
    end
 
-- Macro Spin
    if states.macro and isMacroEnabled then
        local cf = camera.CFrame
        camera.CFrame = cf * CFrame.Angles(0, math.rad(camSpinSpeed), 0)
    end
end)
