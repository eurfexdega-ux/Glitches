local Players = game:GetService("Players")​
local RunService = game:GetService("RunService")​
local UIS = game:GetService("UserInputService")​
local TweenService = game:GetService("TweenService")​
local Lighting = game:GetService("Lighting")​
​
local player = Players.LocalPlayer​
local camera = workspace.CurrentCamera​
​
local states = { glitch = false, perfect = false, macro = false }​
local isNoclipping = false​
local IS_GLOBAL_LOCKED = true ​
local IS_ADJUSTING = false ​
​
local isMainSpeedGlitchEnabled = false​
local isLegitSpeedEnabled = false​
local isMacroEnabled = false​
​
-- Configs Core​
local targetSpeed = 800​
local accelTime = 3 ​
local camSpinSpeed = 270​
local spinWaitMs = 15 ​
local noclipPower = 180​
local noclipTime = 0.5​
local globalBtnSize = 60 ​
local offsetGlitch = -25 -- Giá trị mặc định theo core mới của bạn​
​
local ScreenGui = Instance.new("ScreenGui")​
ScreenGui.Name = "seekit.glitch.v0.1.1"​
ScreenGui.Parent = player:WaitForChild("PlayerGui")​
ScreenGui.ResetOnSpawn = false​
ScreenGui.IgnoreGuiInset = false​
​
-- ==========================================​

-- TWEEN HELPERS​
-- ==========================================​
local function tweenObj(obj, properties, time)​
local info = TweenInfo.new(time or 0.35, Enum.EasingStyle.Quart,
Enum.EasingDirection.Out)​
local tween = TweenService:Create(obj, info, properties)​
tween:Play()​
return tween​
end​
​
-- ==========================================​
-- BLUR & DIM BACKGROUND (EDIT MODE)​
-- ==========================================​
local DimBackground = Instance.new("Frame")​
DimBackground.Size = UDim2.new(1, 0, 1, 0)​
DimBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)​
DimBackground.BackgroundTransparency = 1​
DimBackground.ZIndex = 0​
DimBackground.Visible = false​
DimBackground.Parent = ScreenGui​
​
local BlurEffect = Instance.new("BlurEffect")​
BlurEffect.Size = 0​
BlurEffect.Parent = Lighting​
​
-- ==========================================​
-- LIVE RAINBOW WATERMARK​
-- ==========================================​
local Watermark = Instance.new("TextLabel")​
Watermark.Position = UDim2.new(0, 20, 0, 50) ​
Watermark.Size = UDim2.new(0, 0, 0, 26)​
Watermark.AutomaticSize = Enum.AutomaticSize.X​
Watermark.Text = " seekit.glitch | FPS: -- | Ping: --ms "​
Watermark.BackgroundColor3 = Color3.fromRGB(0, 0, 0)​
Watermark.BackgroundTransparency = 0.2​
Watermark.Font = Enum.Font.GothamBold​
Watermark.TextSize = 11​
Watermark.Parent = ScreenGui​
​
local wmPadding = Instance.new("UIPadding", Watermark)​
wmPadding.PaddingLeft = UDim.new(0, 12); wmPadding.PaddingRight =
UDim.new(0, 12)​
Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 6)​
​
local wmStroke = Instance.new("UIStroke", Watermark)​
wmStroke.Color = Color3.fromRGB(255, 255, 255)​
wmStroke.Transparency = 0.8​
wmStroke.Thickness = 1​

​
local frameCount, currentFPS, lastTick = 0, 60, tick()​
RunService.RenderStepped:Connect(function()​
frameCount = frameCount + 1​
if tick() - lastTick >= 1 then​
currentFPS = frameCount​
frameCount = 0​
lastTick = tick()​
end​
end)​
​
task.spawn(function()​
while task.wait(0.5) do​
local ping = math.floor(player:GetNetworkPing() * 1000)​
Watermark.Text = " seekit.glitch | FPS: " ..
tostring(currentFPS) .. " | Ping: " .. tostring(ping) .. "ms "​
end​
end)​
​
-- ==========================================​
-- ACTION BUTTONS​
-- ==========================================​
local actionButtons = {}​
local function createActionButton(name, posScaleY)​
local btn = Instance.new("TextButton")​
btn.Size = UDim2.new(0, globalBtnSize, 0, globalBtnSize)​
btn.Position = UDim2.new(0.85, 0, posScaleY, 0)​
btn.Text = name​
btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)​
btn.BackgroundTransparency = 0.3​
btn.TextColor3 = Color3.fromRGB(255, 255, 255)​
btn.Font = Enum.Font.GothamBold​
btn.TextSize = 10​
btn.Visible = false ​
btn.Parent = ScreenGui​
​
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)​
local st = Instance.new("UIStroke", btn)​
st.Color = Color3.fromRGB(255, 255, 255)​
st.Thickness = 1​
st.Transparency = 0.7​
​
btn.InputBegan:Connect(function(input)​
if not IS_GLOBAL_LOCKED and (input.UserInputType ==
Enum.UserInputType.MouseButton1 or input.UserInputType ==
Enum.UserInputType.Touch) then​
local dragging = true; local dragStart = input.Position;
local startPos = btn.Position​

tweenObj(btn, {Size = UDim2.new(0, globalBtnSize + 6, 0,
globalBtnSize + 6)}, 0.15)​
​
local moveCon​
moveCon = UIS.InputChanged:Connect(function(moveInput)​
if dragging and (moveInput.UserInputType ==
Enum.UserInputType.MouseMovement or moveInput.UserInputType ==
Enum.UserInputType.Touch) then​
local delta = moveInput.Position - dragStart​
btn.Position = UDim2.new(startPos.X.Scale,
startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset +
delta.Y)​
end​
end)​
​
local endCon​
endCon = UIS.InputEnded:Connect(function(endInput)​
if endInput.UserInputType ==
Enum.UserInputType.MouseButton1 or endInput.UserInputType ==
Enum.UserInputType.Touch then​
dragging = false​
moveCon:Disconnect()​
endCon:Disconnect()​
tweenObj(btn, {Size = UDim2.new(0, globalBtnSize,
0, globalBtnSize)}, 0.15)​
end​
end)​
end​
end)​
​
table.insert(actionButtons, btn)​
return btn​
end​
​
local btnGlitch = createActionButton("GLITCH", 0.25)​
local btnMacro = createActionButton("MACRO", 0.35) ​
local btnFlick = createActionButton("FLICK", 0.45)​
local btnPerfect = createActionButton("LADDER", 0.55)​
local btnUltra = createActionButton("ULTRA", 0.65)​
​
-- ==========================================​
-- MAIN MENU ​
-- ==========================================​
local MenuFrame = Instance.new("Frame")​
MenuFrame.Size = UDim2.new(0, 420, 0, 400) ​
MenuFrame.Position = UDim2.new(0.5, -210, 0.5, -200)​
MenuFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)​
MenuFrame.BackgroundTransparency = 0.1​

MenuFrame.Parent = ScreenGui​
Instance.new("UICorner", MenuFrame).CornerRadius = UDim.new(0, 10)​
local menuStroke = Instance.new("UIStroke", MenuFrame)​
menuStroke.Color = Color3.fromRGB(255, 255, 255)​
menuStroke.Transparency = 0.5​
menuStroke.Thickness = 1​
​
local MenuTitle = Instance.new("TextLabel")​
MenuTitle.Size = UDim2.new(1, -40, 0, 40)​
MenuTitle.Position = UDim2.new(0, 20, 0, 5)​
MenuTitle.Text = "seekit.glitch"​
MenuTitle.Font = Enum.Font.GothamBold​
MenuTitle.TextSize = 16​
MenuTitle.TextXAlignment = Enum.TextXAlignment.Left​
MenuTitle.BackgroundTransparency = 1​
MenuTitle.Parent = MenuFrame​
​
local Divider = Instance.new("Frame")​
Divider.Size = UDim2.new(1, 0, 0, 1)​
Divider.Position = UDim2.new(0, 0, 0, 45)​
Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)​
Divider.BackgroundTransparency = 0.8​
Divider.BorderSizePixel = 0​
Divider.Parent = MenuFrame​
​
local ContentFrame = Instance.new("ScrollingFrame")​
ContentFrame.Size = UDim2.new(1, -30, 1, -60)​
ContentFrame.Position = UDim2.new(0, 15, 0, 55)​
ContentFrame.BackgroundTransparency = 1​
ContentFrame.ScrollBarThickness = 2​
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)​
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)​
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y ​
ContentFrame.ScrollingDirection = Enum.ScrollingDirection.Y ​
ContentFrame.BorderSizePixel = 0​
ContentFrame.Parent = MenuFrame​
​
local UIList = Instance.new("UIListLayout", ContentFrame)​
UIList.Padding = UDim.new(0, 12)​
UIList.SortOrder = Enum.SortOrder.LayoutOrder​
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center​
​
RunService.RenderStepped:Connect(function() ​
local hue = (tick() % 4) / 4​
local rainbowColor = Color3.fromHSV(hue, 1, 1)​
MenuTitle.TextColor3 = rainbowColor​
Watermark.TextColor3 = rainbowColor​
end)​

​
-- ==========================================​
-- UI COMPONENTS (SLIDERS, TOGGLES, ETC)​
-- ==========================================​
local function createSlider(parent, text, min, max, default, step,
varName)​
local val = default​
local container = Instance.new("Frame")​
container.Size = UDim2.new(1, 0, 0, 0) ​
container.BackgroundTransparency = 1​
container.ClipsDescendants = true ​
container.Visible = false​
container.Parent = parent​
​
local label = Instance.new("TextLabel")​
label.Size = UDim2.new(1, -10, 0, 18)​
label.Position = UDim2.new(0, 5, 0, 0)​
label.Text = text​
label.TextColor3 = Color3.fromRGB(255, 255, 255)​
label.Font = Enum.Font.GothamMedium​
label.TextSize = 11​
label.TextXAlignment = Enum.TextXAlignment.Left​
label.BackgroundTransparency = 1​
label.Parent = container​
​
local valLabel = Instance.new("TextLabel")​
valLabel.Size = UDim2.new(0, 50, 0, 18)​
valLabel.Position = UDim2.new(1, -55, 0, 0)​
valLabel.Text = (step and step < 1) and string.format((step ==
0.01 and "%.2f" or "%.1f"), default) or tostring(default)​
valLabel.TextColor3 = Color3.fromRGB(255, 255, 255)​
valLabel.Font = Enum.Font.GothamBold​
valLabel.TextSize = 11​
valLabel.TextXAlignment = Enum.TextXAlignment.Right​
valLabel.BackgroundTransparency = 1​
valLabel.Parent = container​
​
local bg = Instance.new("Frame")​
bg.Size = UDim2.new(1, -10, 0, 3) ​
bg.Position = UDim2.new(0, 5, 0, 24)​
bg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)​
bg.Parent = container​
Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)​
​
local fill = Instance.new("Frame")​
local startRel = (default-min)/(max-min)​
fill.Size = UDim2.new(startRel, 0, 1, 0)​
fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)​

​

fill.Parent = bg​
Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)​
​
local knob = Instance.new("Frame")​
knob.Size = UDim2.new(0, 12, 0, 12)​
knob.Position = UDim2.new(1, -6, 0.5, -6)​
knob.BackgroundColor3 = Color3.new(1, 1, 1)​
knob.Parent = fill​
Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)​

local dragging = false​
bg.InputBegan:Connect(function(i) ​
if i.UserInputType == Enum.UserInputType.MouseButton1 or
i.UserInputType == Enum.UserInputType.Touch then ​
dragging = true; IS_ADJUSTING = true ​
tweenObj(knob, {Size = UDim2.new(0, 16, 0, 16), Position =
UDim2.new(1, -8, 0.5, -8)}, 0.15)​
end ​
end)​
UIS.InputEnded:Connect(function(i) ​
if i.UserInputType == Enum.UserInputType.MouseButton1 or
i.UserInputType == Enum.UserInputType.Touch then ​
dragging = false; IS_ADJUSTING = false ​
tweenObj(knob, {Size = UDim2.new(0, 12, 0, 12), Position =
UDim2.new(1, -6, 0.5, -6)}, 0.15)​
end ​
end)​
UIS.InputChanged:Connect(function(i)​
if dragging and (i.UserInputType ==
Enum.UserInputType.MouseMovement or i.UserInputType ==
Enum.UserInputType.Touch) then​
local rel = math.clamp((i.Position.X bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)​
fill.Size = UDim2.new(rel, 0, 1, 0) ​
​
val = min + (rel * (max - min))​
if step then val = math.floor(val / step + 0.5) * step end​
​
valLabel.Text = (step and step < 1) and
string.format((step == 0.01 and "%.2f" or "%.1f"), val) or
tostring(val)​
​
if varName == "targetSpeed" then targetSpeed = val​
elseif varName == "accelTime" then accelTime = val​
elseif varName == "camSpinSpeed" then camSpinSpeed = val​
elseif varName == "spinWaitMs" then spinWaitMs = val​
elseif varName == "noclipPower" then noclipPower = val​
elseif varName == "noclipTime" then noclipTime = val​

elseif varName == "offsetGlitch" then offsetGlitch = val
end​
end​
end)​
return container​
end​
​
-- ==========================================​
-- MINI EDIT MENU (SIZE CHANGER)​
-- ==========================================​
local SizeMenu = Instance.new("Frame")​
SizeMenu.Size = UDim2.new(0, 240, 0, 70)​
SizeMenu.Position = UDim2.new(0.5, -120, 0.5, -35)​
SizeMenu.BackgroundColor3 = Color3.fromRGB(0, 0, 0)​
SizeMenu.Visible = false​
SizeMenu.ZIndex = 100 ​
SizeMenu.Parent = ScreenGui​
Instance.new("UICorner", SizeMenu).CornerRadius = UDim.new(0, 10)​
Instance.new("UIStroke", SizeMenu).Color = Color3.fromRGB(255, 255,
255); Instance.new("UIStroke", SizeMenu).Transparency = 0.5​
​
local smTitle = Instance.new("TextLabel")​
smTitle.Size = UDim2.new(1, -20, 0, 25); smTitle.Position =
UDim2.new(0, 10, 0, 5)​
smTitle.Text = "Button Size"​
smTitle.TextColor3 = Color3.new(1,1,1); smTitle.Font =
Enum.Font.GothamBold; smTitle.TextSize = 11​
smTitle.TextXAlignment = Enum.TextXAlignment.Left;
smTitle.BackgroundTransparency = 1; smTitle.Parent = SizeMenu​
​
local smVal = Instance.new("TextLabel")​
smVal.Size = UDim2.new(0, 50, 0, 25); smVal.Position = UDim2.new(1,
-60, 0, 5)​
smVal.Text = tostring(globalBtnSize); smVal.TextColor3 =
Color3.fromRGB(255, 255, 255)​
smVal.Font = Enum.Font.GothamBold; smVal.TextSize = 11;
smVal.TextXAlignment = Enum.TextXAlignment.Right​
smVal.BackgroundTransparency = 1; smVal.Parent = SizeMenu​
​
local smBg = Instance.new("Frame")​
smBg.Size = UDim2.new(1, -20, 0, 3); smBg.Position = UDim2.new(0, 10,
0, 42)​
smBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50); smBg.Parent =
SizeMenu​
Instance.new("UICorner", smBg).CornerRadius = UDim.new(1, 0)​
local smFill = Instance.new("Frame"); smFill.Size =
UDim2.new((globalBtnSize-40)/(120-40), 0, 1, 0)​
smFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255); smFill.Parent

= smBg​
Instance.new("UICorner", smFill).CornerRadius = UDim.new(1, 0)​
local smKnob = Instance.new("Frame"); smKnob.Size = UDim2.new(0, 12,
0, 12); smKnob.Position = UDim2.new(1, -6, 0.5, -6)​
smKnob.BackgroundColor3 = Color3.new(1, 1, 1); smKnob.Parent = smFill​
Instance.new("UICorner", smKnob).CornerRadius = UDim.new(1, 0)​
​
local smDragging = false​
smBg.InputBegan:Connect(function(i) if i.UserInputType ==
Enum.UserInputType.MouseButton1 or i.UserInputType ==
Enum.UserInputType.Touch then smDragging = true; IS_ADJUSTING = true
end end)​
UIS.InputEnded:Connect(function(i) if i.UserInputType ==
Enum.UserInputType.MouseButton1 or i.UserInputType ==
Enum.UserInputType.Touch then smDragging = false; IS_ADJUSTING = false
end end)​
UIS.InputChanged:Connect(function(i)​
if smDragging and (i.UserInputType ==
Enum.UserInputType.MouseMovement or i.UserInputType ==
Enum.UserInputType.Touch) then​
local rel = math.clamp((i.Position.X smBg.AbsolutePosition.X) / smBg.AbsoluteSize.X, 0, 1)​
smFill.Size = UDim2.new(rel, 0, 1, 0)​
globalBtnSize = math.floor(40 + (rel * (120 - 40)))​
smVal.Text = tostring(globalBtnSize)​
for _, btn in pairs(actionButtons) do btn.Size = UDim2.new(0,
globalBtnSize, 0, globalBtnSize) end​
end​
end)​
​
-- ==========================================​
-- FEATURE SYSTEM (WITH GROUP LOGIC)​
-- ==========================================​
local function createFeature(text, linkedBtn, layoutOrder,
slidersConfig, subTogglesConfig)​
local group = Instance.new("Frame")​
group.BackgroundTransparency = 1​
group.Size = UDim2.new(1, 0, 0, 0)​
group.AutomaticSize = Enum.AutomaticSize.Y​
group.LayoutOrder = layoutOrder​
group.Parent = ContentFrame​
​
local list = Instance.new("UIListLayout", group)​
list.Padding = UDim.new(0, 10); list.SortOrder =
Enum.SortOrder.LayoutOrder​
​
local row = Instance.new("Frame")​
row.Size = UDim2.new(1, 0, 0, 26); row.BackgroundTransparency = 1;

row.Parent = group; row.LayoutOrder = 1​
​
local lb = Instance.new("TextLabel")​
lb.Size = UDim2.new(1, -50, 1, 0); lb.Position = UDim2.new(0, 5,
0, 0)​
lb.Text = text; lb.TextColor3 = Color3.fromRGB(255, 255, 255);
lb.Font = Enum.Font.GothamMedium; lb.TextSize = 12​
lb.TextXAlignment = Enum.TextXAlignment.Left;
lb.BackgroundTransparency = 1; lb.Parent = row​
​
local switchBg = Instance.new("TextButton")​
switchBg.Text = ""; switchBg.Size = UDim2.new(0, 40, 0, 22);
switchBg.Position = UDim2.new(1, -45, 0.5, -11)​
switchBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
switchBg.Parent = row​
Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)​
​
local knob = Instance.new("Frame")​
knob.Size = UDim2.new(0, 16, 0, 16); knob.Position = UDim2.new(0,
3, 0.5, -8)​
knob.BackgroundColor3 = Color3.fromRGB(150, 150, 150); knob.Parent
= switchBg​
Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)​
​
local visualItems = {}​
​
local function setVis(item, show)​
if item.isShowing == show then return end​
item.isShowing = show​
if show then​
item.frame.Visible = true​
tweenObj(item.frame, {Size = UDim2.new(1, 0, 0,
item.targetHeight)}, 0.3)​
else​
local tw = tweenObj(item.frame, {Size = UDim2.new(1, 0, 0,
0)}, 0.3)​
tw.Completed:Connect(function() if not item.isShowing then
item.frame.Visible = false end end)​
end​
end​
​
if slidersConfig then​
for i, cfg in ipairs(slidersConfig) do​
local sl = createSlider(group, cfg.text, cfg.min, cfg.max,
cfg.default, cfg.step, cfg.var)​
sl.LayoutOrder = i + 1​
table.insert(visualItems, {frame = sl, type = cfg.type or
"main", targetHeight = 40, isShowing = false})​

end​
​

end​

if subTogglesConfig then​
for i, cfg in ipairs(subTogglesConfig) do​
local stContainer = Instance.new("Frame")​
stContainer.Size = UDim2.new(1, 0, 0, 0);
stContainer.BackgroundTransparency = 1; stContainer.ClipsDescendants =
true ​
stContainer.Visible = false; stContainer.LayoutOrder = 100
+ i; stContainer.Parent = group​
​
local stLb = Instance.new("TextLabel")​
stLb.Size = UDim2.new(1, -50, 1, 0); stLb.Position =
UDim2.new(0, 15, 0, 0)​
stLb.Text = cfg.text; stLb.TextColor3 =
Color3.fromRGB(220, 220, 220)​
stLb.Font = Enum.Font.GothamMedium; stLb.TextSize = 11;
stLb.TextXAlignment = Enum.TextXAlignment.Left;
stLb.BackgroundTransparency = 1; stLb.Parent = stContainer​
​
local stBg = Instance.new("TextButton")​
stBg.Text = ""; stBg.Size = UDim2.new(0, 34, 0, 18);
stBg.Position = UDim2.new(1, -42, 0.5, -9); stBg.BackgroundColor3 =
Color3.fromRGB(40, 40, 40); stBg.Parent = stContainer​
Instance.new("UICorner", stBg).CornerRadius = UDim.new(1,
0)​
local stKnob = Instance.new("Frame")​
stKnob.Size = UDim2.new(0, 12, 0, 12); stKnob.Position =
UDim2.new(0, 3, 0.5, -6); stKnob.BackgroundColor3 =
Color3.fromRGB(150, 150, 150); stKnob.Parent = stBg​
Instance.new("UICorner", stKnob).CornerRadius =
UDim.new(1, 0)​
​
local stActive = false​
table.insert(visualItems, {frame = stContainer, type =
"subToggle", targetHeight = 24, isShowing = false})​
​
stBg.MouseButton1Click:Connect(function()​
stActive = not stActive​
if stActive then​
tweenObj(stBg, {BackgroundColor3 =
Color3.fromRGB(255, 255, 255)})​
tweenObj(stKnob, {Position = UDim2.new(1, -15,
0.5, -6), BackgroundColor3 = Color3.fromRGB(0, 0, 0)})​
else​
tweenObj(stBg, {BackgroundColor3 =
Color3.fromRGB(40, 40, 40)})​

tweenObj(stKnob, {Position = UDim2.new(0, 3, 0.5,
-6), BackgroundColor3 = Color3.fromRGB(150, 150, 150)})​
end​
if cfg.callback then cfg.callback(stActive) end​
​
-- Dynamic Visibility update​
if isMainSpeedGlitchEnabled then​
for _, item in ipairs(visualItems) do​
if item.type == "main" then setVis(item, not
isLegitSpeedEnabled)​
elseif item.type == "legit" then setVis(item,
isLegitSpeedEnabled)​
elseif item.type == "macroToggle" then
setVis(item, isLegitSpeedEnabled) end​
end​
end​
end)​
end​
end​
​
local isActive = false​
switchBg.MouseButton1Click:Connect(function()​
isActive = not isActive​
if text == "Speed Glitch" then isMainSpeedGlitchEnabled =
isActive end​
​
if isActive then​
tweenObj(switchBg, {BackgroundColor3 = Color3.fromRGB(255,
255, 255)})​
tweenObj(knob, {Position = UDim2.new(1, -19, 0.5, -8),
BackgroundColor3 = Color3.fromRGB(0, 0, 0)})​
if linkedBtn and not isLegitSpeedEnabled then
linkedBtn.Visible = true end​
for _, item in ipairs(visualItems) do​
if item.type == "subToggle" then setVis(item, true)​
elseif item.type == "main" then setVis(item, not
isLegitSpeedEnabled)​
elseif item.type == "legit" or item.type ==
"macroToggle" then setVis(item, isLegitSpeedEnabled) end​
end​
else​
tweenObj(switchBg, {BackgroundColor3 = Color3.fromRGB(40,
40, 40)})​
tweenObj(knob, {Position = UDim2.new(0, 3, 0.5, -8),
BackgroundColor3 = Color3.fromRGB(150, 150, 150)})​
if linkedBtn then linkedBtn.Visible = false end​
btnMacro.Visible = false​
for _, item in ipairs(visualItems) do setVis(item, false)

end​
end​
end)​
end​
​
-- ==========================================​
-- EDIT MODE BUTTON​
-- ==========================================​
local EditModeFrame = Instance.new("Frame")​
EditModeFrame.Size = UDim2.new(1, 0, 0, 50);
EditModeFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
EditModeFrame.BackgroundTransparency = 0.5; EditModeFrame.Parent =
ContentFrame; EditModeFrame.LayoutOrder = 0; Instance.new("UICorner",
EditModeFrame).CornerRadius = UDim.new(0, 8)​
local EditBtn = Instance.new("TextButton")​
EditBtn.Size = UDim2.new(0, 85, 0, 28); EditBtn.Position =
UDim2.new(1, -100, 0.5, -14); EditBtn.Text = "COMBAT";
EditBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0); EditBtn.TextColor3
= Color3.fromRGB(255, 255, 255); EditBtn.Font = Enum.Font.GothamBold;
EditBtn.TextSize = 11; EditBtn.Parent = EditModeFrame;
Instance.new("UICorner", EditBtn).CornerRadius = UDim.new(0, 6)​
​
EditBtn.MouseButton1Click:Connect(function()​
IS_GLOBAL_LOCKED = not IS_GLOBAL_LOCKED​
if not IS_GLOBAL_LOCKED then​
EditBtn.Text = "EDITING"; DimBackground.Visible = true;
SizeMenu.Visible = true​
tweenObj(DimBackground, {BackgroundTransparency = 0.5}, 0.3);
tweenObj(BlurEffect, {Size = 15}, 0.3)​
else​
EditBtn.Text = "COMBAT"; SizeMenu.Visible = false​
tweenObj(DimBackground, {BackgroundTransparency = 1},
0.3).Completed:Connect(function() if IS_GLOBAL_LOCKED then
DimBackground.Visible = false end end)​
tweenObj(BlurEffect, {Size = 0}, 0.3)​
end​
end)​
​
-- Inject Data​
createFeature("Speed Glitch", btnGlitch, 1, {​
{text = "Speed", min = 150, max = 24000, default = 800, step = 10,
var = "targetSpeed", type = "main"},​
{text = "Speed Time (s)", min = 0.1, max = 10, default = 3, step =
0.1, var = "accelTime", type = "main"},​
{text = "Cam Spin Angle (°)", min = 10, max = 360, default = 270,
step = 5, var = "camSpinSpeed", type = "main"},​
{text = "Cam Spin Delay (ms)", min = 1, max = 100, default = 15,
step = 1, var = "spinWaitMs", type = "main"},​

{text = "Offset Glitch (Studs)", min = -50, max = 50, default =
-25, step = 1, var = "offsetGlitch", type = "legit"}​
}, {​
{​
text = "Speed Glitch (Legit)",​
callback = function(state)​
isLegitSpeedEnabled = state​
btnGlitch.Visible = (isMainSpeedGlitchEnabled and not
state)​
if not state then btnMacro.Visible = false end​
if state and isMacroEnabled and isMainSpeedGlitchEnabled
then btnMacro.Visible = true end​
end​
},​
{​
text = "Macro (Spin Camera)",​
callback = function(state)​
isMacroEnabled = state​
btnMacro.Visible = (state and isLegitSpeedEnabled and
isMainSpeedGlitchEnabled)​
end​
}​
})​
​
createFeature("Wall Hop (Flick)", btnFlick, 2)​
createFeature("Ladder Flick (Perfect)", btnPerfect, 3)​
createFeature("Noclip Push (Ultra)", btnUltra, 4, {​
{text = "Push Power", min = 1, max = 300, default = 180, step = 1,
var = "noclipPower", type = "main"},​
{text = "Push Time (s)", min = 0.01, max = 1, default = 0.5, step
= 0.01, var = "noclipTime", type = "main"}​
})​
​
-- ==========================================​
-- MENU TOGGLE LOGIC​
-- ==========================================​
local OpenMenuBtn = Instance.new("TextButton")​
OpenMenuBtn.Size = UDim2.new(0, 42, 0, 42); OpenMenuBtn.Position =
UDim2.new(0, 20, 0.15, 0); OpenMenuBtn.Text = "S";
OpenMenuBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
OpenMenuBtn.BackgroundTransparency = 0.2; OpenMenuBtn.TextColor3 =
Color3.fromRGB(255, 255, 255); OpenMenuBtn.Font =
Enum.Font.GothamBlack; OpenMenuBtn.TextSize = 18; OpenMenuBtn.Parent =
ScreenGui; Instance.new("UICorner", OpenMenuBtn).CornerRadius =
UDim.new(0, 10)​
​
OpenMenuBtn.MouseButton1Click:Connect(function() ​
MenuFrame.Visible = not MenuFrame.Visible​

end)​
​
-- ==========================================​
-- CORE LOGIC​
-- ==========================================​
​
-- CORE MỚI: LEGIT SPEED (VALWARE) - Dùng RenderStepped để mượt nhất​
RunService.RenderStepped:Connect(function()​
if isMainSpeedGlitchEnabled and isLegitSpeedEnabled and
player.Character then​
local tool = player.Character:FindFirstChildOfClass("Tool")​
if tool then​
local targetGrip = Vector3.new(0, 0, offsetGlitch)​
if tool.GripPos ~= targetGrip then​
tool.GripPos = targetGrip​
end​
end​
end​
end)​
​
-- Nút Macro Action​
btnMacro.InputBegan:Connect(function(i) if IS_GLOBAL_LOCKED and
(i.UserInputType == Enum.UserInputType.Touch or i.UserInputType ==
Enum.UserInputType.MouseButton1) then states.macro = true end end)​
btnMacro.InputEnded:Connect(function() states.macro = false end)​
​
-- Vòng lặp chính cho Glitch thường và Macro Spin​
RunService.Heartbeat:Connect(function()​
-- Glitch Thường​
if states.glitch and not isLegitSpeedEnabled and player.Character
then​
local root =
player.Character:FindFirstChild("HumanoidRootPart")​
local hum = player.Character:FindFirstChildOfClass("Humanoid")​
if root and hum and hum.MoveDirection.Magnitude > 0 then​
local elapsed = tick() - speedStartTime​
local currentRunSpeed = (elapsed / accelTime) *
targetSpeed​
root.AssemblyLinearVelocity =
Vector3.new(hum.MoveDirection.X * currentRunSpeed,
root.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * currentRunSpeed)​
​
local cf = camera.CFrame​
camera.CFrame = cf * CFrame.Angles(0,
math.rad(-camSpinSpeed), 0)​
task.wait(spinWaitMs / 1000)​
camera.CFrame = cf​
end​

end​
​
-- Macro Spin khi dùng Legit​
if states.macro and isLegitSpeedEnabled and player.Character then​
local cf = camera.CFrame​
camera.CFrame = cf * CFrame.Angles(0, math.rad(-270), 0)​
task.wait(0.02) ​
camera.CFrame = cf​
end​
end)​
​
-- Cài đặt Speed Start Time​
btnGlitch.InputBegan:Connect(function(i) ​
if IS_GLOBAL_LOCKED and (i.UserInputType ==
Enum.UserInputType.Touch or i.UserInputType ==
Enum.UserInputType.MouseButton1) then ​
states.glitch = true; speedStartTime = tick() ​
end ​
end)​
btnGlitch.InputEnded:Connect(function() states.glitch = false end)​
​
-- Copy các logic Flick, Ultra, Ladder từ bản cũ qua...​
btnFlick.MouseButton1Click:Connect(function()​
if not IS_GLOBAL_LOCKED then return end ​
local hum = player.Character and
player.Character:FindFirstChildOfClass("Humanoid")​
local root = player.Character and
player.Character:FindFirstChild("HumanoidRootPart")​
if hum and root then​
hum:ChangeState(Enum.HumanoidStateType.Jumping)​
root.AssemblyLinearVelocity =
Vector3.new(root.AssemblyLinearVelocity.X, 60,
root.AssemblyLinearVelocity.Z)​
local o = camera.CFrame​
camera.CFrame = o * CFrame.Angles(0, math.rad(-90), 0)​
task.wait(0.01); camera.CFrame = o​
end​
end)​
​
btnUltra.MouseButton1Click:Connect(function()​
if not IS_GLOBAL_LOCKED or isNoclipping or not player.Character
then return end​
isNoclipping = true​
local startTick = tick()​
local connection​
connection = RunService.Stepped:Connect(function(_, dt)​
if tick() - startTick >= noclipTime then
connection:Disconnect(); isNoclipping = false; return end​

for _, p in pairs(player.Character:GetDescendants()) do if
p:IsA("BasePart") then p.CanCollide = false end end​
local hrp =
player.Character:FindFirstChild("HumanoidRootPart")​
if hrp then hrp.CFrame *= CFrame.new(0, 0, noclipPower * dt)
end​
end)​
end)​
​
print("Seekit.glitch v0.1.1 Loaded | Valware Core Integrated")​

semblyLinearVelocity =
Vector3.new(root.AssemblyLinearVelocity.X, 60,
root.AssemblyLinearVelocity.Z)​
local o = camera.CFrame​
camera.CFrame = o * CFrame.Angles(0, math.rad(-90), 0)​
task.wait(0.01); camera.CFrame = o​
end​
end)​
​
btnUltra.MouseButton1Click:Connect(function()​
if not IS_GLOBAL_LOCKED or isNoclipping or not player.Character
then return end​
isNoclipping = true​
local startTick = tick()​
local connection​
connection = RunService.Stepped:Connect(function(_, dt)​
if tick() - startTick >= noclipTime then
connection:Disconnect(); isNoclipping = false; return end​

for _, p in pairs(player.Character:GetDescendants()) do if
p:IsA("BasePart") then p.CanCollide = false end end​
local hrp =
player.Character:FindFirstChild("HumanoidRootPart")​
if hrp then hrp.CFrame *= CFrame.new(0, 0, noclipPower * dt)
end​
end)​
end)​
​
print("Seekit.glitch v0.1.1 Loaded | Valware Core Integrated")​

-- AUTO FIX (khỏi chỉnh tay)
task.wait(1)

-- Bật hết feature
isNormalGlitchEnabled = true
isLegitGlitchEnabled = false
isMacroEnabled = true

-- Hiện toàn bộ nút
for _, v in pairs(game.Players.LocalPlayer.PlayerGui:GetDescendants()) do
    if v:IsA("TextButton") then
        v.Visible = true
    end
end

print("AUTO FIX LOADED")

