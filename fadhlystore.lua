-- ==========================================================
-- 🚀 RUSUHx FADHLYSTORE 🚀 - ULTIMATE SLIM LUXE + LT2 LOGIC
-- ==========================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Bersihkan UI lama jika ada
if CoreGui:FindFirstChild("RusuhHubGUI") then
    CoreGui.RusuhHubGUI:Destroy()
end

-- ==========================================================
-- 🛠️ MODULE LOGIC: LT2 BRING PARTS & NETWORK BYPASS
-- ==========================================================

local selectedTargetPlayer = nil
local blackHoleActive = false
local descendantAddedConn = nil

local LogicFolder = Workspace:FindFirstChild("NovaLogicFolder") or Instance.new("Folder", Workspace)
LogicFolder.Name = "NovaLogicFolder"

local AnchorPart = LogicFolder:FindFirstChild("LogicAnchor") or Instance.new("Part", LogicFolder)
AnchorPart.Name = "LogicAnchor"
AnchorPart.Anchored = true
AnchorPart.CanCollide = false
AnchorPart.Transparency = 1

local AnchorAttachment = AnchorPart:FindFirstChild("Attachment") or Instance.new("Attachment", AnchorPart)

-- Setup Network Bypass
if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(35, 35, 35)
    }

    Network.RetainPart = function(part)
        if part:IsA("BasePart") and part:IsDescendantOf(Workspace) then
            table.insert(Network.BaseParts, part)
            pcall(function()
                part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                part.CanCollide = false
            end)
        end
    end

    local function InitNetworkBypass()
        pcall(function() LocalPlayer.ReplicationFocus = Workspace end)
        RunService.Heartbeat:Connect(function()
            pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
            for _, part in pairs(Network.BaseParts) do
                if part:IsDescendantOf(Workspace) then
                    part.Velocity = Network.Velocity
                end
            end
        end)
    end

    InitNetworkBypass()
end

local function ForcePart(v)
    if v:IsA("BasePart") and not v.Anchored and not v.Parent:FindFirstChildOfClass("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name ~= "Handle" then
        for _, x in ipairs(v:GetChildren()) do
            if x:IsA("BodyMover") or x:IsA("RocketPropulsion") then
                x:Destroy()
            end
        end
        pcall(function()
            if v:FindFirstChild("Attachment") then v:FindFirstChild("Attachment"):Destroy() end
            if v:FindFirstChild("AlignPosition") then v:FindFirstChild("AlignPosition"):Destroy() end
            if v:FindFirstChild("Torque") then v:FindFirstChild("Torque"):Destroy() end
        end)
        v.CanCollide = false
        
        local Torque = Instance.new("Torque", v)
        Torque.Torque = Vector3.new(1000000, 1000000, 1000000)
        
        local AlignPosition = Instance.new("AlignPosition", v)
        local PartAttachment = Instance.new("Attachment", v)
        
        Torque.Attachment0 = PartAttachment
        AlignPosition.MaxForce = math.huge
        AlignPosition.MaxVelocity = math.huge
        AlignPosition.Responsiveness = 500
        AlignPosition.Attachment0 = PartAttachment
        AlignPosition.Attachment1 = AnchorAttachment
        
        if Network and Network.RetainPart then
            Network.RetainPart(v)
        end
    end
end

local function SetBringState(state, customPlayer)
    blackHoleActive = state
    selectedTargetPlayer = customPlayer
    
    if blackHoleActive then
        for _, v in ipairs(Workspace:GetDescendants()) do
            ForcePart(v)
        end

        descendantAddedConn = Workspace.DescendantAdded:Connect(function(v)
            if blackHoleActive then ForcePart(v) end
        end)

        task.spawn(function()
            while blackHoleActive and RunService.RenderStepped:Wait() do
                local targetHrp = nil
                if selectedTargetPlayer and selectedTargetPlayer.Character then
                    targetHrp = selectedTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
                end
                
                if targetHrp then
                    AnchorAttachment.WorldCFrame = targetHrp.CFrame
                elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    AnchorAttachment.WorldCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                end
            end
        end)
    else
        if descendantAddedConn then
            descendantAddedConn:Disconnect()
            descendantAddedConn = nil
        end
    end
end

getgenv().LT2Logic = {
    Toggle = SetBringState,
    GetStatus = function() return blackHoleActive end
}

-- ==========================================================
-- 🎨 GUI CREATION
-- ==========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RusuhHubGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Toggle Floating Button
local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.BackgroundColor3 = Color3.fromRGB(10, 16, 28)
ToggleButton.Position = UDim2.new(0, 15, 0, 150)
ToggleButton.Size = UDim2.new(0, 70, 0, 28)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "⚡ FADHLY"
ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
ToggleButton.TextSize = 10
ToggleButton.BorderSizePixel = 0
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 6)
local tbStroke = Instance.new("UIStroke", ToggleButton)
tbStroke.Color = Color3.fromRGB(0, 180, 255)
tbStroke.Thickness = 1.2

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -135)
MainFrame.Size = UDim2.new(0, 280, 0, 270)
MainFrame.Visible = true
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local mfStroke = Instance.new("UIStroke", MainFrame)
mfStroke.Color = Color3.fromRGB(0, 150, 255)
mfStroke.Thickness = 1.5

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.BackgroundColor3 = Color3.fromRGB(15, 22, 34)
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local TitleText = Instance.new("TextLabel", Header)
TitleText.BackgroundTransparency = 1
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "🚀RUSUHx FADHLYSTORE🚀"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 11

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 45, 65)
CloseBtn.Position = UDim2.new(1, -26, 0.5, -8)
CloseBtn.Size = UDim2.new(0, 16, 0, 16)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Draggable
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.BackgroundColor3 = Color3.fromRGB(13, 18, 28)
Sidebar.Position = UDim2.new(0, 6, 0, 42)
Sidebar.Size = UDim2.new(0, 75, 0, 222)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)

local function createNavButton(name, posY)
    local btn = Instance.new("TextButton", Sidebar)
    btn.BackgroundColor3 = Color3.fromRGB(18, 25, 40)
    btn.Position = UDim2.new(0, 4, 0, posY)
    btn.Size = UDim2.new(1, -8, 0, 28)
    btn.Font = Enum.Font.GothamMedium
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(130, 150, 180)
    btn.TextSize = 8
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    return btn
end

local btnKill = createNavButton("KILLPLAYER", 6)
local btnRusuh = createNavButton("RUSUH TP", 38)
local btnBRING = createNavButton("BRING PARTS", 70)
local btnWall = createNavButton("WALLHACK", 102)

-- Content Area
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.BackgroundColor3 = Color3.fromRGB(14, 20, 32)
ContentArea.Position = UDim2.new(0, 85, 0, 42)
ContentArea.Size = UDim2.new(0, 189, 0, 222)
ContentArea.BorderSizePixel = 0
Instance.new("UICorner", ContentArea).CornerRadius = UDim.new(0, 6)

local function setActiveTab(selectedBtn)
    for _, btn in ipairs({btnKill, btnRusuh, btnBRING, btnWall}) do
        btn.BackgroundColor3 = Color3.fromRGB(18, 25, 40)
        btn.TextColor3 = Color3.fromRGB(130, 150, 180)
    end
    selectedBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    selectedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

-- PAGE 1: KILLPLAYER
local pageKill = Instance.new("Frame", ContentArea)
pageKill.Size = UDim2.new(1, 0, 1, 0)
pageKill.BackgroundTransparency = 1

local vipBox = Instance.new("Frame", pageKill)
vipBox.BackgroundColor3 = Color3.fromRGB(18, 26, 42)
vipBox.Position = UDim2.new(0, 8, 0, 8)
vipBox.Size = UDim2.new(1, -16, 0, 90)
Instance.new("UICorner", vipBox).CornerRadius = UDim.new(0, 6)
local vipStroke = Instance.new("UIStroke", vipBox)
vipStroke.Color = Color3.fromRGB(0, 140, 255)

local infoLabel = Instance.new("TextLabel", vipBox)
infoLabel.BackgroundTransparency = 1
infoLabel.Size = UDim2.new(1, 0, 1, 0)
infoLabel.Font = Enum.Font.GothamMedium
infoLabel.Text = "👑 VIP FEATURE\n\nHubungi fadhlystore\nuntuk unlock fitur ini."
infoLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
infoLabel.TextSize = 9

-- PAGE 2: RUSUH TP
local pageRusuh = Instance.new("ScrollingFrame", ContentArea)
pageRusuh.Size = UDim2.new(1, 0, 1, 0)
pageRusuh.BackgroundTransparency = 1
pageRusuh.Visible = false
pageRusuh.ScrollBarThickness = 2
pageRusuh.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)

local function refreshPlayerList()
    for _, child in ipairs(pageRusuh:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local yPos = 6
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local pFrame = Instance.new("Frame", pageRusuh)
            pFrame.BackgroundColor3 = Color3.fromRGB(20, 28, 44)
            pFrame.Position = UDim2.new(0, 6, 0, yPos)
            pFrame.Size = UDim2.new(1, -12, 0, 28)
            Instance.new("UICorner", pFrame).CornerRadius = UDim.new(0, 5)
            
            local pName = Instance.new("TextLabel", pFrame)
            pName.BackgroundTransparency = 1
            pName.Position = UDim2.new(0, 6, 0, 0)
            pName.Size = UDim2.new(0.6, 0, 1, 0)
            pName.Font = Enum.Font.GothamBold
            pName.Text = plr.Name
            pName.TextColor3 = Color3.fromRGB(230, 240, 255)
            pName.TextSize, pName.TextXAlignment = 9, Enum.TextXAlignment.Left
            
            local tpBtn = Instance.new("TextButton", pFrame)
            tpBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
            tpBtn.Position = UDim2.new(0.68, 0, 0.15, 0)
            tpBtn.Size = UDim2.new(0, 36, 0, 19)
            tpBtn.Font = Enum.Font.GothamBold
            tpBtn.Text = "TP"
            tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tpBtn.TextSize = 8
            Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 4)
            
            tpBtn.MouseButton1Click:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
                end
            end)
            
            yPos = yPos + 32
        end
    end
    pageRusuh.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
refreshPlayerList()

-- PAGE 3: BRING PARTS (LT2 LOGIC INTEGRATED)
local pageBring = Instance.new("Frame", ContentArea)
pageBring.Size = UDim2.new(1, 0, 1, 0)
pageBring.BackgroundTransparency = 1
pageBring.Visible = false

local bringCard = Instance.new("Frame", pageBring)
bringCard.BackgroundColor3 = Color3.fromRGB(20, 28, 44)
bringCard.Position = UDim2.new(0, 6, 0, 6)
bringCard.Size = UDim2.new(1, -12, 0, 36)
Instance.new("UICorner", bringCard).CornerRadius = UDim.new(0, 5)

local bringTitle = Instance.new("TextLabel", bringCard)
bringTitle.BackgroundTransparency = 1
bringTitle.Position = UDim2.new(0, 8, 0, 0)
bringTitle.Size = UDim2.new(0.6, 0, 1, 0)
bringTitle.Font = Enum.Font.GothamBold
bringTitle.Text = "BRING PARTS LOGIC"
bringTitle.TextColor3 = Color3.fromRGB(200, 220, 255)
bringTitle.TextSize = 8
bringTitle.TextXAlignment = Enum.TextXAlignment.Left

local bringToggle = Instance.new("TextButton", bringCard)
bringToggle.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
bringToggle.Position = UDim2.new(0.68, 0, 0.2, 0)
bringToggle.Size = UDim2.new(0, 38, 0, 20)
bringToggle.Font = Enum.Font.GothamBold
bringToggle.Text = "OFF"
bringToggle.TextColor3 = Color3.fromRGB(150, 170, 200)
bringToggle.TextSize = 8
Instance.new("UICorner", bringToggle).CornerRadius = UDim.new(0, 10)

local targetStatusLabel = Instance.new("TextLabel", pageBring)
targetStatusLabel.BackgroundTransparency = 1
targetStatusLabel.Position = UDim2.new(0, 8, 0, 46)
targetStatusLabel.Size = UDim2.new(1, -16, 0, 14)
targetStatusLabel.Font = Enum.Font.GothamMedium
targetStatusLabel.Text = "TARGET: LOCALPLAYER (ME)"
targetStatusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
targetStatusLabel.TextSize = 7
targetStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local bringList = Instance.new("ScrollingFrame", pageBring)
bringList.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
bringList.Position = UDim2.new(0, 6, 0, 64)
bringList.Size = UDim2.new(1, -12, 0, 150)
bringList.ScrollBarThickness = 2
bringList.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
Instance.new("UICorner", bringList).CornerRadius = UDim.new(0, 5)

local function refreshBringTargetList()
    for _, child in ipairs(bringList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local yPos = 4
    -- Option: Target Self
    local meFrame = Instance.new("Frame", bringList)
    meFrame.BackgroundColor3 = Color3.fromRGB(24, 34, 52)
    meFrame.Position = UDim2.new(0, 4, 0, yPos)
    meFrame.Size = UDim2.new(1, -8, 0, 24)
    Instance.new("UICorner", meFrame).CornerRadius = UDim.new(0, 4)
    
    local meBtn = Instance.new("TextButton", meFrame)
    meBtn.Size = UDim2.new(1, 0, 1, 0)
    meBtn.BackgroundTransparency = 1
    meBtn.Font = Enum.Font.GothamBold
    meBtn.Text = "[ TARGET DIRI SENDIRI ]"
    meBtn.TextColor3 = Color3.fromRGB(0, 210, 255)
    meBtn.TextSize = 8
    
    meBtn.MouseButton1Click:Connect(function()
        selectedTargetPlayer = nil
        targetStatusLabel.Text = "TARGET: LOCALPLAYER (ME)"
        if blackHoleActive then
            SetBringState(true, nil)
        end
    end)
    
    yPos = yPos + 28
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local pFrame = Instance.new("Frame", bringList)
            pFrame.BackgroundColor3 = Color3.fromRGB(20, 28, 44)
            pFrame.Position = UDim2.new(0, 4, 0, yPos)
            pFrame.Size = UDim2.new(1, -8, 0, 24)
            Instance.new("UICorner", pFrame).CornerRadius = UDim.new(0, 4)
            
            local selectBtn = Instance.new("TextButton", pFrame)
            selectBtn.Size = UDim2.new(1, 0, 1, 0)
            selectBtn.BackgroundTransparency = 1
            selectBtn.Font = Enum.Font.GothamMedium
            selectBtn.Text = "TARIK KE: " .. plr.Name
            selectBtn.TextColor3 = Color3.fromRGB(200, 220, 255)
            selectBtn.TextSize = 8
            
            selectBtn.MouseButton1Click:Connect(function()
                selectedTargetPlayer = plr
                targetStatusLabel.Text = "TARGET: " .. plr.Name
                if blackHoleActive then
                    SetBringState(true, plr)
                end
            end)
            
            yPos = yPos + 28
        end
    end
    bringList.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

Players.PlayerAdded:Connect(refreshBringTargetList)
Players.PlayerRemoving:Connect(refreshBringTargetList)
refreshBringTargetList()

bringToggle.MouseButton1Click:Connect(function()
    local newState = not blackHoleActive
    SetBringState(newState, selectedTargetPlayer)
    
    bringToggle.Text = newState and "ON" or "OFF"
    bringToggle.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(30, 40, 60)
    bringToggle.TextColor3 = newState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 170, 200)
end)

-- PAGE 4: WALLHACK & LIGHTING & WALKSPEED
local pageWall = Instance.new("ScrollingFrame", ContentArea)
pageWall.Size = UDim2.new(1, 0, 1, 0)
pageWall.BackgroundTransparency = 1
pageWall.Visible = false
pageWall.ScrollBarThickness = 2
pageWall.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
pageWall.CanvasSize = UDim2.new(0, 0, 0, 240)

local function createToggleCard(title, posY)
    local card = Instance.new("Frame", pageWall)
    card.BackgroundColor3 = Color3.fromRGB(20, 28, 44)
    card.Position = UDim2.new(0, 6, 0, posY)
    card.Size = UDim2.new(1, -12, 0, 32)
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 5)
    
    local txt = Instance.new("TextLabel", card)
    txt.BackgroundTransparency = 1
    txt.Position = UDim2.new(0, 8, 0, 0)
    txt.Size = UDim2.new(0.6, 0, 1, 0)
    txt.Font = Enum.Font.GothamBold
    txt.Text = title
    txt.TextColor3 = Color3.fromRGB(200, 220, 255)
    txt.TextSize = 8
    txt.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", card)
    btn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    btn.Position = UDim2.new(0.68, 0, 0.17, 0)
    btn.Size = UDim2.new(0, 38, 0, 20)
    btn.Font = Enum.Font.GothamBold
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(150, 170, 200)
    btn.TextSize = 8
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    
    return btn
end

local btnTengkorak = createToggleCard("ESP TENGKORAK", 6)
local btnEspName   = createToggleCard("ESP NAME", 43)
local btnAlwaysDay = createToggleCard("ALWAYS DAY", 80)
local btnNoShadow  = createToggleCard("NO SHADOW", 117)

-- WalkSpeed Slider
local speedCard = Instance.new("Frame", pageWall)
speedCard.BackgroundColor3 = Color3.fromRGB(20, 28, 44)
speedCard.Position = UDim2.new(0, 6, 0, 154)
speedCard.Size = UDim2.new(1, -12, 0, 48)
Instance.new("UICorner", speedCard).CornerRadius = UDim.new(0, 5)

local speedTitle = Instance.new("TextLabel", speedCard)
speedTitle.BackgroundTransparency = 1
speedTitle.Position = UDim2.new(0, 8, 0, 4)
speedTitle.Size = UDim2.new(1, -16, 0, 16)
speedTitle.Font = Enum.Font.GothamBold
speedTitle.Text = "WALKSPEED: 16"
speedTitle.TextColor3 = Color3.fromRGB(200, 220, 255)
speedTitle.TextSize = 8
speedTitle.TextXAlignment = Enum.TextXAlignment.Left

local sliderBar = Instance.new("Frame", speedCard)
sliderBar.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
sliderBar.Position = UDim2.new(0, 8, 0, 26)
sliderBar.Size = UDim2.new(1, -16, 0, 10)
Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 5)

local sliderFill = Instance.new("Frame", sliderBar)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
sliderFill.Size = UDim2.new(0, 0, 1, 0)
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 5)

local minSpeed, maxSpeed = 16, 150
local currentSpeed = 16
local sliderDragging = false

local function updateSlider(input)
    local absolutePosition = sliderBar.AbsolutePosition.X
    local absoluteSize = sliderBar.AbsoluteSize.X
    local inputX = input.Position.X
    local percentage = math.clamp((inputX - absolutePosition) / absoluteSize, 0, 1)
    currentSpeed = math.floor(minSpeed + (maxSpeed - minSpeed) * percentage)
    
    sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    speedTitle.Text = "WALKSPEED: " .. currentSpeed
end

sliderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
        updateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = currentSpeed
        end
    end
end)

-- Always Day Logic
local alwaysDayActive = false
local originalClockTime = Lighting.ClockTime

btnAlwaysDay.MouseButton1Click:Connect(function()
    alwaysDayActive = not alwaysDayActive
    btnAlwaysDay.Text = alwaysDayActive and "ON" or "OFF"
    btnAlwaysDay.BackgroundColor3 = alwaysDayActive and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(30, 40, 60)
    btnAlwaysDay.TextColor3 = alwaysDayActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 170, 200)
    
    if alwaysDayActive then originalClockTime = Lighting.ClockTime else Lighting.ClockTime = originalClockTime end
end)

RunService.RenderStepped:Connect(function()
    if alwaysDayActive then Lighting.ClockTime = 12 end
end)

-- No Shadow Logic
local noShadowActive = false
local originalShadows = Lighting.GlobalShadows

btnNoShadow.MouseButton1Click:Connect(function()
    noShadowActive = not noShadowActive
    btnNoShadow.Text = noShadowActive and "ON" or "OFF"
    btnNoShadow.BackgroundColor3 = noShadowActive and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(30, 40, 60)
    btnNoShadow.TextColor3 = noShadowActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 170, 200)
    
    if noShadowActive then
        originalShadows = Lighting.GlobalShadows
        Lighting.GlobalShadows = false
    else
        Lighting.GlobalShadows = originalShadows
    end
end)

-- ESP Tengkorak
local tengkorakActive = false
btnTengkorak.MouseButton1Click:Connect(function()
    tengkorakActive = not tengkorakActive
    btnTengkorak.Text = tengkorakActive and "ON" or "OFF"
    btnTengkorak.BackgroundColor3 = tengkorakActive and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(30, 40, 60)
    btnTengkorak.TextColor3 = tengkorakActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 170, 200)
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            for _, part in ipairs(p.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Color = tengkorakActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(163, 162, 165)
                end
            end
        end
    end
end)

-- ESP Name
local espNameActive = false
btnEspName.MouseButton1Click:Connect(function()
    espNameActive = not espNameActive
    btnEspName.Text = espNameActive and "ON" or "OFF"
    btnEspName.BackgroundColor3 = espNameActive and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(30, 40, 60)
    btnEspName.TextColor3 = espNameActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 170, 200)
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            if espNameActive then
                if not p.Character.Head:FindFirstChild("FadhlyEspTag") then
                    local bill = Instance.new("BillboardGui", p.Character.Head)
                    bill.Name = "FadhlyEspTag"
                    bill.Size = UDim2.new(0, 100, 0, 40)
                    bill.StudsOffset = Vector3.new(0, 2, 0)
                    bill.AlwaysOnTop = true
                    
                    local txt = Instance.new("TextLabel", bill)
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Text = p.Name
                    txt.TextColor3 = Color3.fromRGB(0, 210, 255)
                    txt.TextSize = 11
                    txt.Font = Enum.Font.GothamBold
                end
            else
                if p.Character.Head:FindFirstChild("FadhlyEspTag") then
                    p.Character.Head.FadhlyEspTag:Destroy()
                end
            end
        end
    end
end)

-- Navigation Controller
setActiveTab(btnKill)

btnKill.MouseButton1Click:Connect(function()
    setActiveTab(btnKill)
    pageKill.Visible = true; pageRusuh.Visible = false; pageBring.Visible = false; pageWall.Visible = false
end)
btnRusuh.MouseButton1Click:Connect(function()
    setActiveTab(btnRusuh)
    pageKill.Visible = false; pageRusuh.Visible = true; pageBring.Visible = false; pageWall.Visible = false
end)
btnBRING.MouseButton1Click:Connect(function()
    setActiveTab(btnBRING)
    pageKill.Visible = false; pageRusuh.Visible = false; pageBring.Visible = true; pageWall.Visible = false
end)
btnWall.MouseButton1Click:Connect(function()
    setActiveTab(btnWall)
    pageKill.Visible = false; pageRusuh.Visible = false; pageBring.Visible = false; pageWall.Visible = true
end)

print("RUSUHx FADHLYSTORE + Integrated LT2 Bring Logic Ready!")
