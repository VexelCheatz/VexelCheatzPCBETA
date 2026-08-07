local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui", 5) or player.PlayerGui
local Characters = Workspace:WaitForChild("Characters", 5) or Workspace

local function notify(title, text)
    task.spawn(function()
        local toast = Instance.new("Frame")
        toast.Size = UDim2.new(0, 260, 0, 52)
        toast.Position = UDim2.new(1, 300, 1, -80)
        toast.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        toast.BorderSizePixel = 0
        toast.Parent = game:GetService("CoreGui") or playerGui

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(35, 35, 35)
        stroke.Thickness = 1
        stroke.Parent = toast

        local tCorner = Instance.new("UICorner")
        tCorner.CornerRadius = UDim.new(0, 0)
        tCorner.Parent = toast

        local tLabel = Instance.new("TextLabel")
        tLabel.Size = UDim2.new(1, -16, 0, 18)
        tLabel.Position = UDim2.new(0, 12, 0, 6)
        tLabel.BackgroundTransparency = 1
        tLabel.Text = title
        tLabel.Font = Enum.Font.GothamBold
        tLabel.TextSize = 12
        tLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
        tLabel.TextXAlignment = Enum.TextXAlignment.Left
        tLabel.Parent = toast

        local dLabel = Instance.new("TextLabel")
        dLabel.Size = UDim2.new(1, -16, 0, 18)
        dLabel.Position = UDim2.new(0, 12, 0, 24)
        dLabel.BackgroundTransparency = 1
        dLabel.Text = text
        dLabel.Font = Enum.Font.Gotham
        dLabel.TextSize = 11
        dLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        dLabel.TextXAlignment = Enum.TextXAlignment.Left
        dLabel.Parent = toast

        toast:TweenPosition(UDim2.new(1, -280, 1, -80), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        task.wait(2.5)
        toast:TweenPosition(UDim2.new(1, 300, 1, -80), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true)
        task.wait(0.3)
        toast:Destroy()
    end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AxonHubUI"
pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = playerGui
end
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true

local keyVerified = true

-- Stealth Background FPS Booster
task.spawn(function()
    pcall(function()
        pcall(function()
            UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualityLevel.Level1
        end)
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") then
                v.Enabled = false
            end
        end
        
        local function optimizePart(part)
            if part:IsA("BasePart") then
                part.CastShadow = false
            elseif part:IsA("ParticleEmitter") or part:IsA("Trail") or part:IsA("Fire") or part:IsA("Smoke") or part:IsA("Sparkles") then
                part.Enabled = false
            end
        end
        
        for _, v in ipairs(Workspace:GetDescendants()) do
            optimizePart(v)
        end
        
        Workspace.DescendantAdded:Connect(optimizePart)
    end)
end)

getgenv().SkinChangerConfig = getgenv().SkinChangerConfig or {
    KnivesEnabled = true,
    TargetKnife = "Karambit",
    TargetKnifeSkin = "Fade",
    GlovesEnabled = true
}

local Config = getgenv().SkinChangerConfig

local successSkins, Skins = pcall(function()
    return require(ReplicatedStorage:WaitForChild("Database", 3).Components.Libraries.Skins)
end)
local successViewmodel, Viewmodel = pcall(function()
    return require(ReplicatedStorage:WaitForChild("Classes", 3).WeaponComponent.Classes.Viewmodel)
end)
local successInventory, InventoryController = pcall(function()
    return require(ReplicatedStorage:WaitForChild("Controllers", 3).InventoryController)
end)

local Checkifbaseknife = {
    "Knife",
    "Default Knife",
    "CT Knife",
    "T Knife"
}

local function Checkknife(weapon)
    if not Config.KnivesEnabled then
        return false
    end
    if type(weapon) == "string" then
        local wLower = weapon:lower()
        if wLower:find("knife") or wLower:find("karambit") or wLower:find("bayonet") or wLower:find("butterfly") or wLower:find("flip") then
            return true
        end
    end
    for _, knife in ipairs(Checkifbaseknife) do
        if weapon == knife then
            return true
        end
    end
    return false
end

if successSkins and Skins then
    pcall(function()
        local oldGetCameraModel = Skins.GetCameraModel
        if oldGetCameraModel then
            Skins.GetCameraModel = function(weapon, skin, ...)
                if Checkknife(weapon) then
                    weapon = Config.TargetKnife
                    skin = Config.TargetKnifeSkin
                end
                return oldGetCameraModel(weapon, skin, ...)
            end
        end
        local oldGetCharacterModel = Skins.GetCharacterModel
        if oldGetCharacterModel then
            Skins.GetCharacterModel = function(weapon, skin, ...)
                if Checkknife(weapon) then
                    weapon = Config.TargetKnife
                    skin = Config.TargetKnifeSkin
                end
                return oldGetCharacterModel(weapon, skin, ...)
            end
        end
    end)
end

if successViewmodel and Viewmodel then
    pcall(function()
        local oldViewmodelNew = Viewmodel.new
        if oldViewmodelNew then
            Viewmodel.new = function(config, weapon, skin, ...)
                if Checkknife(weapon) then
                    weapon = Config.TargetKnife
                    skin = Config.TargetKnifeSkin
                end
                return oldViewmodelNew(config, weapon, skin, ...)
            end
        end
    end)
end

local lastReload = 0
local function reloadvm()
    if tick() - lastReload < 1.2 then
        return
    end
    lastReload = tick()
    pcall(function()
        if not player.Character or player.Character:GetAttribute("Dead") == true then
            return
        end
        if not successInventory or not InventoryController then
            return
        end
        local CurrentViewmodel = InventoryController.getCurrentEquipped()
        local vm = CurrentViewmodel and CurrentViewmodel.Viewmodel
        if not vm then
            return
        end
        local weaponName = CurrentViewmodel.Name or (type(CurrentViewmodel) == "string" and CurrentViewmodel) or ""
        if Checkknife(weaponName) then
            vm.Weapon = Config.TargetKnife
            vm.Skin = Config.TargetKnifeSkin
        end
        local old = vm.Model
        if vm.construct then
            vm:construct(player.Character, CurrentViewmodel)
        end
        if vm.Model and workspace.CurrentCamera then
            vm.Model.Parent = workspace.CurrentCamera
        end
        if old then
            old:Destroy()
        end
    end)
end


local cfg = {
    aimbotEnabled = false,
    aimbotVisCheck = true,
    aimbotTarget = "Head",
    aimbotFov = 10,
    aimbotSmoothness = 5,
    aimbotPrediction = true,
    showFov = true,
    fovFilled = false,
    fovTransparency = 0.05,
    requireKeyPress = false,
    aimbotKey = "MouseButton2",
    aimbotHumanize = false,
    aimbotShakeIntensity = 0.5,
    aimbotDynamicFov = false,
    teamCheck = true,
    recoilControl = false,
    multiBone = false,
    deathmatchMode = false,
    triggerBotEnabled = false,
    triggerBotDelay = 0,
    noRecoil = true,
    noclipEnabled = false,
    bhopEnabled = false,
    bhopJumpPower = 20,
    cameraFovEnabled = false,
    cameraFovValue = 100,
    stretchResEnabled = false,
    
    noFlashEnabled = false,
    noSmokeEnabled = false,
    
    boxEnabled = true,
    cornerBoxes = true,
    boxStyle = "Corner",
    espBoxFilled = false,
    espBoxTransparency = 0.5,
    healthBarEnabled = true,
    armorBarEnabled = true,
    skeletonEnabled = true,
    nameEspEnabled = true,
    distanceEspEnabled = true,
    weaponEspEnabled = true,
    chamsEnabled = true,
    chamsMaterial = "Neon",
    offScreenArrows = false,
    tracersEnabled = true,
    espColor = Color3.fromRGB(235, 235, 235),
    skeletonColor = Color3.fromRGB(235, 235, 235),
    tracerColor = Color3.fromRGB(235, 235, 235),
    nameColor = Color3.fromRGB(255, 255, 255),
    distanceColor = Color3.fromRGB(190, 190, 190),
    
    glassArmsEnabled = false,
    glassArmsMode = "Both",
    silentAimEnabled = false,
    silentAimVisCheck = true,
    hitboxExpanderEnabled = false,
    hitboxSize = 3,
    
    crosshairEnabled = true,
    crosshairStyle = "Cross",
    crosshairSize = 6,
    crosshairGap = 4,
    crosshairThickness = 1.5,
    crosshairDot = true,
    crosshairColor = Color3.fromRGB(235, 235, 235),
    
    hitSoundEnabled = true,
    killEffectEnabled = true,
    watermarkEnabled = true,
    fullbrightEnabled = false,
    ambientEnabled = false,
    ambientBrightness = 2,
    ambientColor = Color3.fromRGB(235, 235, 235),
    timeOfDay = "Default",
}

local watermarkFrame = Instance.new("Frame")
watermarkFrame.Name = "Watermark"
watermarkFrame.Size = UDim2.new(0, 360, 0, 26)
watermarkFrame.Position = UDim2.new(0, 20, 0, 20)
watermarkFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
watermarkFrame.BorderSizePixel = 0
watermarkFrame.Visible = cfg.watermarkEnabled
watermarkFrame.Parent = ScreenGui

local wmStroke = Instance.new("UIStroke")
wmStroke.Color = Color3.fromRGB(35, 35, 35)
wmStroke.Thickness = 1
wmStroke.Parent = watermarkFrame

local wmCorner = Instance.new("UICorner")
wmCorner.CornerRadius = UDim.new(0, 0)
wmCorner.Parent = watermarkFrame

local wmLabel = Instance.new("TextLabel")
wmLabel.Size = UDim2.new(1, -12, 1, 0)
wmLabel.Position = UDim2.new(0, 6, 0, 0)
wmLabel.BackgroundTransparency = 1
wmLabel.Text = "vexelcheatz - beta - v1.0"
wmLabel.Font = Enum.Font.GothamBold
wmLabel.TextSize = 11
wmLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
wmLabel.TextXAlignment = Enum.TextXAlignment.Left
wmLabel.Parent = watermarkFrame

local lastFpsUpdate = 0
RunService.RenderStepped:Connect(function(dt)
    if cfg.watermarkEnabled then
        if tick() - lastFpsUpdate >= 1 then
            local fps = math.floor(1 / math.max(dt, 0.001))
            local ping = 0
            pcall(function()
                ping = math.floor(player:GetNetworkPing() * 1000)
            end)
            local currentTime = os.date("%H:%M:%S")
            local uid = player.UserId
            wmLabel.Text = string.format("vexelcheatz - beta - v1.0 - %d fps - %dms - uid: %d - %s", fps, ping, uid, currentTime)
            lastFpsUpdate = tick()
        end
    end
end)


local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -260)
MainFrame.Size = UDim2.new(0, 500, 0, 520)
MainFrame.Visible = true
MainFrame.Active = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 0)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 35)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame


UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
        notify("UI", MainFrame.Visible and "Menu Opened" or "Menu Closed")
    end
end)


local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 32)

local TopBarStroke = Instance.new("UIStroke")
TopBarStroke.Color = Color3.fromRGB(35, 35, 35)
TopBarStroke.Thickness = 1
TopBarStroke.Parent = TopBar

local BrandLabel = Instance.new("TextLabel")
BrandLabel.Name = "BrandLabel"
BrandLabel.Parent = TopBar
BrandLabel.BackgroundTransparency = 1
BrandLabel.Position = UDim2.new(0, 10, 0, 0)
BrandLabel.Size = UDim2.new(0, 120, 1, 0)
BrandLabel.Font = Enum.Font.GothamBold
BrandLabel.Text = "vexelcheatz    uid: 5 /"
BrandLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
BrandLabel.TextSize = 11
BrandLabel.TextXAlignment = Enum.TextXAlignment.Left

local TabListFrame = Instance.new("Frame")
TabListFrame.Name = "TabList"
TabListFrame.Parent = TopBar
TabListFrame.BackgroundTransparency = 1
TabListFrame.Position = UDim2.new(0, 130, 0, 0)
TabListFrame.Size = UDim2.new(1, -135, 1, 0)

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabListFrame
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 6)

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Parent = MainFrame
ContentArea.BackgroundTransparency = 1
ContentArea.Position = UDim2.new(0, 10, 0, 42)
ContentArea.Size = UDim2.new(1, -20, 1, -52)

local tabNames = {
    "Combat",
    "Visuals",
    "Misc",
    "Skins",
    "settings"
}

local pages = {}
local tabButtons = {}
for i, tabName in ipairs(tabNames) do
    local PageFrame = Instance.new("ScrollingFrame")
    PageFrame.Name = tabName .. "Page"
    PageFrame.Parent = ContentArea
    PageFrame.BackgroundTransparency = 1
    PageFrame.Size = UDim2.new(1, 0, 1, 0)
    PageFrame.CanvasSize = UDim2.new(0, 0, 0, 1600)
    PageFrame.ScrollBarThickness = 2
    PageFrame.Visible = (i == 1)

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Parent = PageFrame
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 10)
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingTop = UDim.new(0, 6)
    PagePadding.Parent = PageFrame

    pages[tabName] = PageFrame

    local TabButton = Instance.new("TextButton")
    TabButton.Name = tabName .. "Button"
    TabButton.Parent = TabListFrame
    TabButton.BackgroundTransparency = 1
    TabButton.Size = UDim2.new(0, 50, 0, 22)
    TabButton.Font = Enum.Font.GothamMedium
    TabButton.Text = tabName
    TabButton.TextColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 140)
    TabButton.TextSize = 10.5

    tabButtons[tabName] = TabButton

    TabButton.MouseButton1Click:Connect(function()
        for name, page in pairs(pages) do
            page.Visible = false
        end
        for name, btn in pairs(tabButtons) do
            btn.TextColor3 = Color3.fromRGB(140, 140, 140)
        end
        PageFrame.Visible = true
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
end


local function createGroupBox(parent, titleText)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 460, 0, 32)
    box.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
    box.BorderSizePixel = 0
    box.Parent = parent

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(35, 35, 35)
    stroke.Thickness = 1
    stroke.Parent = box

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 0)
    corner.Parent = box

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 20)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.Font = Enum.Font.GothamBold
    title.TextSize = 11
    title.TextColor3 = Color3.fromRGB(210, 210, 210)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = box

    local innerLayout = Instance.new("UIListLayout")
    innerLayout.Padding = UDim.new(0, 6)
    innerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    innerLayout.Parent = box

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 28)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.Parent = box

    innerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        box.Size = UDim2.new(0, 460, 0, innerLayout.AbsoluteContentSize.Y + 38)
    end)
    return box
end

local function createToggle(parent, labelText, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 22)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(170, 170, 170)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 14, 0, 14)
    btn.Position = UDim2.new(1, -14, 0.5, -7)
    btn.BackgroundColor3 = default and Color3.fromRGB(45, 45, 45) or Color3.fromRGB(16, 16, 16)
    btn.AutoButtonColor = false
    btn.Text = default and "✓" or ""
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Parent = row

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 0)
    btnCorner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = default and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(38, 38, 38)
    stroke.Thickness = 1
    stroke.Parent = btn

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(45, 45, 45) or Color3.fromRGB(16, 16, 16)
        btn.Text = state and "✓" or ""
        stroke.Color = state and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(38, 38, 38)
        if callback then
            pcall(function()
                callback(state)
            end)
        end
    end)
    return row
end

local activeDropdownPopup = nil
local function closeActiveDropdown()
    if activeDropdownPopup and activeDropdownPopup.Parent then
        activeDropdownPopup:Destroy()
        activeDropdownPopup = nil
    end
end

local DropdownButtons = {}
local function createDropdown(parent, labelText, options, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(170, 170, 170)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local currentValue = default
    for _, opt in ipairs(options) do
        if opt == default then
            currentValue = opt
            break
        end
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 160, 0, 20)
    btn.Position = UDim2.new(1, -160, 0.5, -10)
    btn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    btn.Text = currentValue .. " v"
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 10.5
    btn.TextColor3 = Color3.fromRGB(210, 210, 210)
    btn.AutoButtonColor = true
    btn.Parent = row
    DropdownButtons[labelText] = btn

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 0)
    btnCorner.Parent = btn

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(38, 38, 38)
    bStroke.Thickness = 1
    bStroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if activeDropdownPopup then
            closeActiveDropdown()
            return
        end
        local absPos = btn.AbsolutePosition
        local absSize = btn.AbsoluteSize

        local popup = Instance.new("Frame")
        popup.Name = "DropdownPopup"
        popup.Size = UDim2.new(0, absSize.X, 0, 0)
        popup.AutomaticSize = Enum.AutomaticSize.Y
        popup.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
        popup.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        popup.BorderSizePixel = 0
        popup.Active = true
        popup.ZIndex = 100
        popup.Parent = ScreenGui

        local pStroke = Instance.new("UIStroke")
        pStroke.Color = Color3.fromRGB(38, 38, 38)
        pStroke.Thickness = 1
        pStroke.Parent = popup

        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(0, 0)
        pCorner.Parent = popup

        local pLayout = Instance.new("UIListLayout")
        pLayout.Padding = UDim.new(0, 2)
        pLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        pLayout.Parent = popup

        local pPad = Instance.new("UIPadding")
        pPad.PaddingTop = UDim.new(0, 4)
        pPad.PaddingBottom = UDim.new(0, 4)
        pPad.Parent = popup

        for _, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -8, 0, 20)
            optBtn.BackgroundColor3 = (opt == currentValue) and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(16, 16, 16)
            optBtn.Text = opt
            optBtn.Font = Enum.Font.GothamMedium
            optBtn.TextSize = 10.5
            optBtn.TextColor3 = (opt == currentValue) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
            optBtn.AutoButtonColor = true
            optBtn.Active = true
            optBtn.ZIndex = 101
            optBtn.Parent = popup

            local oCorner = Instance.new("UICorner")
            oCorner.CornerRadius = UDim.new(0, 0)
            oCorner.Parent = optBtn

            optBtn.MouseButton1Click:Connect(function()
                currentValue = opt
                btn.Text = opt .. " v"
                closeActiveDropdown()
                if callback then
                    pcall(function()
                        callback(opt)
                    end)
                end
            end)
        end
        activeDropdownPopup = popup
    end)
    return row
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if activeDropdownPopup then
            local pos = activeDropdownPopup.AbsolutePosition
            local size = activeDropdownPopup.AbsoluteSize
            local inputPos = input.Position
            if inputPos.X < pos.X or inputPos.X > pos.X + size.X or inputPos.Y < pos.Y or inputPos.Y > pos.Y + size.Y then
                closeActiveDropdown()
            end
        end
    end
end)

local function createButtonUI(parent, labelText, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    btn.Text = labelText
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10.5
    btn.TextColor3 = Color3.fromRGB(210, 210, 210)
    btn.AutoButtonColor = true
    btn.Parent = row

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 0)
    btnCorner.Parent = btn

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(38, 38, 38)
    bStroke.Thickness = 1
    bStroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if callback then
            pcall(callback)
        end
    end)
    return row
end

local function createTextbox(parent, labelText, defaultText, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(170, 170, 170)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 160, 0, 20)
    box.Position = UDim2.new(1, -160, 0.5, -10)
    box.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    box.Text = defaultText
    box.Font = Enum.Font.GothamMedium
    box.TextSize = 10.5
    box.TextColor3 = Color3.fromRGB(210, 210, 210)
    box.ClearTextOnFocus = false
    box.Parent = row

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 0)
    bCorner.Parent = box

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(38, 38, 38)
    bStroke.Thickness = 1
    bStroke.Parent = box

    box.FocusLost:Connect(function()
        if callback then
            pcall(function()
                callback(box.Text)
            end)
        end
    end)
    return row
end

local function createSlider(parent, labelText, min, max, decimals, value, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(170, 170, 170)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0.4, 0, 0, 16)
    valLabel.Position = UDim2.new(0.6, 0, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(value)
    valLabel.Font = Enum.Font.GothamMedium
    valLabel.TextSize = 10.5
    valLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = row

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 4)
    bar.Position = UDim2.new(0, 0, 0, 20)
    bar.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    bar.BorderSizePixel = 0
    bar.Parent = row

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 0)
    bCorner.Parent = bar

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(38, 38, 38)
    bStroke.Thickness = 1
    bStroke.Parent = bar

    local pct = math.clamp((value - min) / (max - min), 0, 1)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 0)
    fCorner.Parent = fill

    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 4, 0, 10)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.Position = UDim2.new(pct, 0, 0.5, 0)
    handle.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    handle.BorderSizePixel = 0
    handle.Parent = bar

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 0)
    hCorner.Parent = handle

    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
        local val = min + (max - min) * pos
        val = math.floor(val * (10 ^ decimals) + 0.5) / (10 ^ decimals)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        handle.Position = UDim2.new(pos, 0, 0.5, 0)
        valLabel.Text = tostring(val)
        if callback then
            pcall(function()
                callback(val)
            end)
        end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    return row
end


local boxLegit = createGroupBox(pages["Combat"], "Aim Assist Settings")
createToggle(boxLegit, "Enable Aimbot", cfg.aimbotEnabled, function(v) cfg.aimbotEnabled = v end)
createToggle(boxLegit, "Draw FOV Circle", cfg.showFov, function(v) cfg.showFov = v end)
createToggle(boxLegit, "Require Key Press", cfg.requireKeyPress, function(v) cfg.requireKeyPress = v end)
createDropdown(boxLegit, "Aimbot Key", {"MouseButton2", "E", "Q", "Shift", "LeftAlt"}, cfg.aimbotKey, function(v) cfg.aimbotKey = v end)
createToggle(boxLegit, "Team Check", cfg.teamCheck, function(v) cfg.teamCheck = v end)
createSlider(boxLegit, "FOV", 1, 50, 1, cfg.aimbotFov, function(v) cfg.aimbotFov = v end)
createSlider(boxLegit, "Smoothness (Lower = Slower)", 1, 20, 1, cfg.aimbotSmoothness, function(v) cfg.aimbotSmoothness = v end)
createToggle(boxLegit, "Dynamic FOV Adjustment", cfg.aimbotDynamicFov, function(v) cfg.aimbotDynamicFov = v end)
createToggle(boxLegit, "Humanize / Shake Simulation", cfg.aimbotHumanize, function(v) cfg.aimbotHumanize = v end)
createSlider(boxLegit, "Shake Intensity", 0, 2, 1, cfg.aimbotShakeIntensity, function(v) cfg.aimbotShakeIntensity = v end)
createToggle(boxLegit, "Recoil Control (RCS)", cfg.recoilControl, function(v) cfg.recoilControl = v end)
createToggle(boxLegit, "Multi-Bone Selection", cfg.multiBone, function(v) cfg.multiBone = v end)
createDropdown(boxLegit, "Target Bone", {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}, cfg.aimbotTarget, function(v) cfg.aimbotTarget = v end)

local boxAimAssist = createGroupBox(pages["Combat"], "Combat Options & Triggerbot")
createToggle(boxAimAssist, "Deathmatch Mode (No Team Check)", cfg.deathmatchMode, function(v) cfg.deathmatchMode = v end)
createToggle(boxAimAssist, "Enable TriggerBot (Auto-Fire)", cfg.triggerBotEnabled, function(v) cfg.triggerBotEnabled = v end)
createSlider(boxAimAssist, "TriggerBot Shot Delay", 0, 500, 0, cfg.triggerBotDelay, function(v) cfg.triggerBotDelay = v end)
createToggle(boxAimAssist, "Silent Aim (Raycast Hook)", cfg.silentAimEnabled, function(v) cfg.silentAimEnabled = v end)
createToggle(boxAimAssist, "Silent Aim Wall Check", cfg.silentAimVisCheck, function(v) cfg.silentAimVisCheck = v end)
createToggle(boxAimAssist, "Safe Head Hitbox Expander", cfg.hitboxExpanderEnabled, function(v) cfg.hitboxExpanderEnabled = v end)
createSlider(boxAimAssist, "Hitbox Size (Head)", 1.5, 3, 1, cfg.hitboxSize, function(v) cfg.hitboxSize = v end)

local boxVisuals = createGroupBox(pages["Visuals"], "ESP & Information")
createToggle(boxVisuals, "ESP Boxes", cfg.boxEnabled, function(v) cfg.boxEnabled = v end)
createDropdown(boxVisuals, "Box Style", {"Full", "Corner", "3D"}, cfg.boxStyle, function(v) cfg.boxStyle = v end)
createToggle(boxVisuals, "Filled ESP Boxes", cfg.espBoxFilled, function(v) cfg.espBoxFilled = v end)
createSlider(boxVisuals, "Box Fill Transparency", 0.1, 1, 1, cfg.espBoxTransparency, function(v) cfg.espBoxTransparency = v end)
createToggle(boxVisuals, "Health Bar ESP", cfg.healthBarEnabled, function(v) cfg.healthBarEnabled = v end)
createToggle(boxVisuals, "Armor Bar ESP", cfg.armorBarEnabled, function(v) cfg.armorBarEnabled = v end)
createToggle(boxVisuals, "Skeleton ESP", cfg.skeletonEnabled, function(v) cfg.skeletonEnabled = v end)
createToggle(boxVisuals, "Name ESP", cfg.nameEspEnabled, function(v) cfg.nameEspEnabled = v end)
createToggle(boxVisuals, "Distance ESP", cfg.distanceEspEnabled, function(v) cfg.distanceEspEnabled = v end)
createToggle(boxVisuals, "Weapon / Held Item ESP", cfg.weaponEspEnabled, function(v) cfg.weaponEspEnabled = v end)
createToggle(boxVisuals, "Snapline Tracers", cfg.tracersEnabled, function(v) cfg.tracersEnabled = v end)
createToggle(boxVisuals, "Off-Screen Arrow ESP", cfg.offScreenArrows, function(v) cfg.offScreenArrows = v end)
createToggle(boxVisuals, "Viewmodel Outline (Arms/Gun)", cfg.glassArmsEnabled, function(v) cfg.glassArmsEnabled = v end)
createDropdown(boxVisuals, "Outline Mode", {"Both", "Gun", "Arms"}, cfg.glassArmsMode, function(v) cfg.glassArmsMode = v end)

local boxEspTheme = createGroupBox(pages["Visuals"], "ESP Color Customization")
createDropdown(boxEspTheme, "ESP Color Theme", {"White", "Cyan", "Lime", "Yellow", "Pink", "Red"}, "White", function(v)
    local colorMap = {
        White = Color3.fromRGB(235, 235, 235),
        Cyan = Color3.fromRGB(0, 220, 255),
        Lime = Color3.fromRGB(50, 255, 100),
        Yellow = Color3.fromRGB(255, 230, 50),
        Pink = Color3.fromRGB(255, 105, 180),
        Red = Color3.fromRGB(255, 50, 50)
    }
    if colorMap[v] then
        cfg.espColor = colorMap[v]
        cfg.skeletonColor = colorMap[v]
        cfg.tracerColor = colorMap[v]
    end
end)

local boxCrosshairCustom = createGroupBox(pages["Visuals"], "Custom Crosshair Customization")
createToggle(boxCrosshairCustom, "Custom Crosshair", cfg.crosshairEnabled, function(v) cfg.crosshairEnabled = v end)
createDropdown(boxCrosshairCustom, "Crosshair Style", {"Cross", "Dot", "Circle"}, cfg.crosshairStyle, function(v) cfg.crosshairStyle = v end)
createSlider(boxCrosshairCustom, "Crosshair Size", 2, 20, 0, cfg.crosshairSize, function(v) cfg.crosshairSize = v end)
createSlider(boxCrosshairCustom, "Crosshair Gap", 0, 15, 0, cfg.crosshairGap, function(v) cfg.crosshairGap = v end)
createSlider(boxCrosshairCustom, "Crosshair Thickness", 1, 4, 1, cfg.crosshairThickness, function(v) cfg.crosshairThickness = v end)
createToggle(boxCrosshairCustom, "Center Dot", cfg.crosshairDot, function(v) cfg.crosshairDot = v end)
createDropdown(boxCrosshairCustom, "Crosshair Color", {"White", "Cyan", "Lime", "Yellow", "Pink", "Red"}, "White", function(v)
    local colorMap = {
        White = Color3.fromRGB(235, 235, 235),
        Cyan = Color3.fromRGB(0, 220, 255),
        Lime = Color3.fromRGB(50, 255, 100),
        Yellow = Color3.fromRGB(255, 230, 50),
        Pink = Color3.fromRGB(255, 105, 180),
        Red = Color3.fromRGB(255, 50, 50)
    }
    if colorMap[v] then
        cfg.crosshairColor = colorMap[v]
    end
end)

local boxLighting = createGroupBox(pages["Visuals"], "Lighting & Environment")
createToggle(boxLighting, "Fullbright", cfg.fullbrightEnabled, function(v) cfg.fullbrightEnabled = v end)
createToggle(boxLighting, "Custom Ambient Lighting", cfg.ambientEnabled, function(v) cfg.ambientEnabled = v end)
createSlider(boxLighting, "Ambient Brightness", 0, 5, 1, cfg.ambientBrightness, function(v) cfg.ambientBrightness = v end)
createDropdown(boxLighting, "Ambient Color Theme", {"White", "Blue", "Red", "Green", "Pink"}, "White", function(v)
    if v == "White" then
        cfg.ambientColor = Color3.fromRGB(255, 255, 255)
    elseif v == "Blue" then
        cfg.ambientColor = Color3.fromRGB(50, 150, 255)
    elseif v == "Red" then
        cfg.ambientColor = Color3.fromRGB(255, 50, 50)
    elseif v == "Green" then
        cfg.ambientColor = Color3.fromRGB(50, 255, 100)
    elseif v == "Pink" then
        cfg.ambientColor = Color3.fromRGB(255, 105, 180)
    end
end)
createDropdown(boxLighting, "Time of Day", {"Default", "Day", "Evening", "Night"}, "Default", function(v)
    cfg.timeOfDay = v
end)

local boxChams = createGroupBox(pages["Visuals"], "Chams & Watermark")
createToggle(boxChams, "Enemy Chams / Glow", cfg.chamsEnabled, function(v) cfg.chamsEnabled = v end)
createDropdown(boxChams, "Chams Material", {"Neon", "Glass", "SmoothPlastic", "ForceField"}, cfg.chamsMaterial, function(v) cfg.chamsMaterial = v end)
createToggle(boxChams, "Watermark", cfg.watermarkEnabled, function(v)
    cfg.watermarkEnabled = v
    watermarkFrame.Visible = v
end)

local boxCombatMods = createGroupBox(pages["Misc"], "Weapon Mods")
createToggle(boxCombatMods, "No Recoil & No Spread", cfg.noRecoil, function(v) cfg.noRecoil = v end)
createToggle(boxCombatMods, "Hit Sounds (CS:GO Ding)", cfg.hitSoundEnabled, function(v) cfg.hitSoundEnabled = v end)
createToggle(boxCombatMods, "Kill Effects", cfg.killEffectEnabled, function(v) cfg.killEffectEnabled = v end)

local boxAntiEffects = createGroupBox(pages["Misc"], "Anti-Effects (Flash & Smoke)")
createToggle(boxAntiEffects, "No Flash", cfg.noFlashEnabled, function(v) cfg.noFlashEnabled = v end)
createToggle(boxAntiEffects, "No Smoke", cfg.noSmokeEnabled, function(v) cfg.noSmokeEnabled = v end)

local boxMovement = createGroupBox(pages["Misc"], "Noclip, Bhop & Camera")
createToggle(boxMovement, "Noclip", cfg.noclipEnabled, function(v) cfg.noclipEnabled = v end)
createToggle(boxMovement, "Bunny Hop (BHop)", cfg.bhopEnabled, function(v) cfg.bhopEnabled = v end)
createSlider(boxMovement, "Bhop Jump Power", 10, 20, 0, cfg.bhopJumpPower, function(v) cfg.bhopJumpPower = v end)
createToggle(boxMovement, "Custom Camera FOV", cfg.cameraFovEnabled, function(v) cfg.cameraFovEnabled = v end)
createSlider(boxMovement, "FOV Value", 70, 130, 0, cfg.cameraFovValue, function(v) cfg.cameraFovValue = v end)
createToggle(boxMovement, "Stretch Resolution", cfg.stretchResEnabled, function(v) cfg.stretchResEnabled = v end)

-- Skins Logic
local SkinChangerEnabled = false
local SelectedSkins = {}
local SkinOptions = {}
local CT_ONLY = {
    ["USP-S"] = true,
    ["Five-SeveN"] = true,
    ["MP9"] = true,
    ["FAMAS"] = true,
    ["M4A1-S"] = true,
    ["M4A4"] = true,
    ["AUG"] = true
}
local SHARED = {
    ["P250"] = true,
    ["Desert Eagle"] = true,
    ["Dual Berettas"] = true,
    ["Negev"] = true,
    ["P90"] = true,
    ["Nova"] = true,
    ["XM1014"] = true,
    ["AWP"] = true,
    ["SSG 08"] = true
}
local GLOVES = {
    ["Sports Gloves"] = true
}

local AssetsFolder = ReplicatedStorage:WaitForChild("Assets", 3)
local SkinsFolder = AssetsFolder and AssetsFolder:FindFirstChild("Skins")

local IgnoreFolders = {
    ["HE Grenade"] = true,
    ["Incendiary Grenade"] = true,
    ["Molotov"] = true,
    ["Smoke Grenade"] = true,
    ["Flashbang"] = true,
    ["Decoy Grenade"] = true,
    ["C4"] = true,
    ["CT Glove"] = true,
    ["T Glove"] = true
}

local function isAliveCheck()
    local t = Characters:FindFirstChild("Terrorists")
    local ct = Characters:FindFirstChild("Counter-Terrorists")
    return (t and t:FindFirstChild(player.Name)) or (ct and ct:FindFirstChild(player.Name)) or true
end

local function applyWeaponSkin(model)
    if not model or not SkinChangerEnabled or not SkinsFolder then
        return
    end
    local skinName = SelectedSkins[model.Name]
    if not skinName then
        return
    end
    pcall(function()
        local skinFolder = SkinsFolder:FindFirstChild(model.Name)
        if not skinFolder then
            return
        end
        local skinType = skinFolder:FindFirstChild(skinName)
        local sourceFolder = skinType and skinType:FindFirstChild("Camera") and skinType.Camera:FindFirstChild("Factory New")
        if not sourceFolder then
            return
        end
        if Config.GlovesEnabled then
            for _, obj in ipairs(camera:GetChildren()) do
                local left, right = obj:FindFirstChild("Left Arm"), obj:FindFirstChild("Right Arm")
                if left or right then
                    local gloveFolder = SkinsFolder:FindFirstChild("Sports Gloves")
                    local gloveSkin = gloveFolder and gloveFolder:FindFirstChild(SelectedSkins["Sports Gloves"])
                    local gloveSource = gloveSkin and gloveSkin:FindFirstChild("Camera") and gloveSkin.Camera:FindFirstChild("Factory New")
                    if gloveSource then
                        for _, side in ipairs({"Left Arm", "Right Arm"}) do
                            local arm, src = obj:FindFirstChild(side), gloveSource:FindFirstChild(side)
                            if arm and src then
                                local gloveMesh = arm:FindFirstChild("Glove")
                                if gloveMesh then
                                    local existing = gloveMesh:FindFirstChildOfClass("SurfaceAppearance")
                                    if existing then
                                        existing:Destroy()
                                    end
                                    local clone = src:Clone()
                                    clone.Name, clone.Parent = "SurfaceAppearance", gloveMesh
                                end
                            end
                        end
                    end
                end
            end
        end
        if not GLOVES[model.Name] then
            local weaponFolder = model:FindFirstChild("Weapon")
            if weaponFolder then
                for _, part in ipairs(weaponFolder:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local newSkin = sourceFolder:FindFirstChild(part.Name)
                        if newSkin then
                            local existing = part:FindFirstChildOfClass("SurfaceAppearance")
                            if existing then
                                existing:Destroy()
                            end
                            local clone = newSkin:Clone()
                            clone.Name, clone.Parent = "SurfaceAppearance", part
                        end
                    end
                end
            end
        end
        model:SetAttribute("SkinApplied", skinName)
    end)
end

local boxKnife = createGroupBox(pages["Skins"], "Knife Skin Customizer")
createToggle(boxKnife, "Enable Knife Changer", Config.KnivesEnabled, function(v)
    Config.KnivesEnabled = v
    reloadvm()
end)
createDropdown(boxKnife, "Target Knife", {"Karambit", "Butterfly Knife", "M9 Bayonet", "Flip Knife"}, Config.TargetKnife, function(v)
    Config.TargetKnife = v
    reloadvm()
end)
createDropdown(boxKnife, "Knife Skin", {"Vanilla", "Fade"}, Config.TargetKnifeSkin, function(v)
    Config.TargetKnifeSkin = v
    reloadvm()
end)
createButtonUI(boxKnife, "Refresh / Apply Viewmodel", reloadvm)

local boxGloves = createGroupBox(pages["Skins"], "Glove Skin Customizer")
createToggle(boxGloves, "Enable Glove Changer", Config.GlovesEnabled, function(v)
    Config.GlovesEnabled = v
    for _, obj in ipairs(camera:GetChildren()) do
        obj:SetAttribute("SkinApplied", nil)
        applyWeaponSkin(obj)
    end
end)

local function CreateSkinDropdown(weaponName, targetTab)
    if not SkinsFolder then return end
    targetTab = targetTab or pages["Skins"]
    local folder = SkinsFolder:FindFirstChild(weaponName)
    if not folder then
        return
    end
    local options = {}
    for _, skin in ipairs(folder:GetChildren()) do
        table.insert(options, skin.Name)
    end
    SkinOptions[weaponName] = options
    if not SelectedSkins[weaponName] and #options > 0 then
        SelectedSkins[weaponName] = options[1]
    end
    local boxSec = createGroupBox(targetTab, weaponName .. " Skins")
    createDropdown(boxSec, weaponName, options, SelectedSkins[weaponName] or "", function(opt)
        SelectedSkins[weaponName] = opt
        for _, obj in ipairs(camera:GetChildren()) do
            obj:SetAttribute("SkinApplied", nil)
            applyWeaponSkin(obj)
        end
    end)
end

for name in pairs(GLOVES) do CreateSkinDropdown(name, pages["Skins"]) end

local boxGunSkinsMaster = createGroupBox(pages["Skins"], "Gun Skin Changer Settings")
createToggle(boxGunSkinsMaster, "Enable Gun Skin Changer", SkinChangerEnabled, function(Value)
    SkinChangerEnabled = Value
    if not Value then
        for _, obj in ipairs(camera:GetChildren()) do
            obj:SetAttribute("SkinApplied", nil)
        end
    end
end)
createButtonUI(boxGunSkinsMaster, "Randomize All Gun Skins", function()
    for weaponName, optionsList in pairs(SkinOptions) do
        if #optionsList > 0 then
            local randomSkin = optionsList[math.random(1, #optionsList)]
            SelectedSkins[weaponName] = randomSkin
            if DropdownButtons[weaponName] then
                DropdownButtons[weaponName].Text = randomSkin .. " v"
            end
        end
    end
    for _, obj in ipairs(camera:GetChildren()) do
        obj:SetAttribute("SkinApplied", nil)
        applyWeaponSkin(obj)
    end
    notify("Skin Changer", "Randomized all weapon skins!")
end)

for name in pairs(CT_ONLY) do CreateSkinDropdown(name, pages["Skins"]) end
for name in pairs(SHARED) do CreateSkinDropdown(name, pages["Skins"]) end
if SkinsFolder then
    for _, folder in ipairs(SkinsFolder:GetChildren()) do
        local n = folder.Name
        if not IgnoreFolders[n] and not GLOVES[n] and not CT_ONLY[n] and not SHARED[n] then
            CreateSkinDropdown(n, pages["Skins"])
        end
    end
end

camera.ChildAdded:Connect(function(obj)
    if not SkinChangerEnabled or not isAliveCheck() then
        return
    end
    task.wait(0.1)
    applyWeaponSkin(obj)
end)

task.spawn(function()
    while task.wait(0.5) do
        if SkinChangerEnabled and isAliveCheck() then
            for _, obj in ipairs(camera:GetChildren()) do
                if SelectedSkins[obj.Name] and obj:GetAttribute("SkinApplied") ~= SelectedSkins[obj.Name] then
                    applyWeaponSkin(obj)
                end
            end
        end
    end
end)

-- ==========================================
-- CONFIGURATION SYSTEM
-- ==========================================
local boxConfigs = createGroupBox(pages["settings"], "File Configuration Manager")

local currentConfigName = "default"
createTextbox(boxConfigs, "Config Name", currentConfigName, function(val)
    if val and val ~= "" then
        currentConfigName = val:gsub("[^%w_%-]", "")
    end
end)

local configListContainer = Instance.new("ScrollingFrame")
configListContainer.Name = "ConfigListContainer"
configListContainer.Size = UDim2.new(1, 0, 0, 160)
configListContainer.BackgroundTransparency = 1
configListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
configListContainer.ScrollBarThickness = 2
configListContainer.Parent = boxConfigs

local configListLayout = Instance.new("UIListLayout")
configListLayout.SortOrder = Enum.SortOrder.LayoutOrder
configListLayout.Padding = UDim.new(0, 4)
configListLayout.Parent = configListContainer

configListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    configListContainer.CanvasSize = UDim2.new(0, 0, 0, configListLayout.AbsoluteContentSize.Y)
end)

local function refreshConfigList()
    for _, child in ipairs(configListContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    pcall(function()
        if not isfolder or not isfolder("AxonHubConfigs") then
            return
        end
        for _, file in ipairs(listfiles("AxonHubConfigs")) do
            local name = file:match("([^/]+)$"):gsub("%.json$", "")
            
            local itemRow = Instance.new("Frame")
            itemRow.Size = UDim2.new(1, 0, 0, 24)
            itemRow.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
            itemRow.BorderSizePixel = 0
            itemRow.Parent = configListContainer

            local itemCorner = Instance.new("UICorner")
            itemCorner.CornerRadius = UDim.new(0, 0)
            itemCorner.Parent = itemRow

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
            nameLabel.Position = UDim2.new(0, 8, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = name
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.TextSize = 10.5
            nameLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = itemRow

            local loadBtn = Instance.new("TextButton")
            loadBtn.Size = UDim2.new(0, 45, 0, 18)
            loadBtn.Position = UDim2.new(1, -145, 0.5, -9)
            loadBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            loadBtn.Text = "Load"
            loadBtn.Font = Enum.Font.GothamBold
            loadBtn.TextSize = 9.5
            loadBtn.TextColor3 = Color3.fromRGB(190, 190, 190)
            loadBtn.Parent = itemRow

            local renameBtn = Instance.new("TextButton")
            renameBtn.Size = UDim2.new(0, 45, 0, 18)
            renameBtn.Position = UDim2.new(1, -95, 0.5, -9)
            renameBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            renameBtn.Text = "Rename"
            renameBtn.Font = Enum.Font.GothamBold
            renameBtn.TextSize = 9.5
            renameBtn.TextColor3 = Color3.fromRGB(190, 190, 190)
            renameBtn.Parent = itemRow

            local delBtn = Instance.new("TextButton")
            delBtn.Size = UDim2.new(0, 40, 0, 18)
            delBtn.Position = UDim2.new(1, -45, 0.5, -9)
            delBtn.BackgroundColor3 = Color3.fromRGB(35, 16, 16)
            delBtn.Text = "Del"
            delBtn.Font = Enum.Font.GothamBold
            delBtn.TextSize = 9.5
            delBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            delBtn.Parent = itemRow

            loadBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    local content = readfile("AxonHubConfigs/" .. name .. ".json")
                    local decoded = HttpService:JSONDecode(content)
                    for k, v in pairs(decoded) do
                        if cfg[k] ~= nil then
                            cfg[k] = v
                        end
                    end
                    watermarkFrame.Visible = cfg.watermarkEnabled
                    notify("Config", "Loaded config: " .. name)
                end)
            end)

            renameBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    local newName = currentConfigName ~= "" and currentConfigName or "renamed_config"
                    if newName ~= name then
                        local content = readfile("AxonHubConfigs/" .. name .. ".json")
                        writefile("AxonHubConfigs/" .. newName .. ".json", content)
                        delfile("AxonHubConfigs/" .. name .. ".json")
                        refreshConfigList()
                        notify("Config", "Renamed to: " .. newName)
                    end
                end)
            end)

            delBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    delfile("AxonHubConfigs/" .. name .. ".json")
                    refreshConfigList()
                    notify("Config", "Deleted config: " .. name)
                end)
            end)
        end
    end)
end

local function saveConfig()
    pcall(function()
        if not writefile or not makefolder then
            return
        end
        if not isfolder("AxonHubConfigs") then
            makefolder("AxonHubConfigs")
        end
        local fileName = (currentConfigName ~= "" and currentConfigName or "default") .. ".json"
        local data = HttpService:JSONEncode(cfg)
        writefile("AxonHubConfigs/" .. fileName, data)
        refreshConfigList()
        notify("Config", "Saved config successfully as " .. fileName)
    end)
end

local function loadConfig()
    pcall(function()
        if not readfile or not isfile then
            return
        end
        local fileName = (currentConfigName ~= "" and currentConfigName or "default") .. ".json"
        local filePath = "AxonHubConfigs/" .. fileName
        if isfile(filePath) then
            local content = readfile(filePath)
            local decoded = HttpService:JSONDecode(content)
            for k, v in pairs(decoded) do
                if cfg[k] ~= nil then
                    cfg[k] = v
                end
            end
            watermarkFrame.Visible = cfg.watermarkEnabled
            notify("Config", "Loaded config successfully: " .. fileName)
        else
            notify("Config", "Config file not found!")
        end
    end)
end

createButtonUI(boxConfigs, "Save Configuration", saveConfig)
createButtonUI(boxConfigs, "Load Configuration", loadConfig)

task.spawn(refreshConfigList)

-- Main Frame Dragging (PC Mouse Drag)
local draggingMain, dragInputMain, dragStartMain, startPosMain
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingMain = true
        dragStartMain = input.Position
        startPosMain = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingMain = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInputMain = input
    end
end)

RunService.RenderStepped:Connect(function()
    if draggingMain and dragInputMain then
        local delta = dragInputMain.Position - dragStartMain
        MainFrame.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- AIMBOT & ESP LOOPS
-- ==========================================
local hitSound = Instance.new("Sound")
hitSound.SoundId = "rbxassetid://9060817409"
hitSound.Volume = 1.5
hitSound.Parent = SoundService

local okDrawing, Drawing = pcall(function() return Drawing end)
local hitmarkerLines = {}
local hitmarkerEndTime = 0

if okDrawing and Drawing then
    pcall(function()
        for i = 1, 2 do
            local line = Drawing.new("Line")
            line.Thickness = 2
            line.Color = Color3.fromRGB(255, 255, 255)
            line.Visible = false
            table.insert(hitmarkerLines, line)
        end
    end)
end

local function triggerHitmarker(damage, targetName)
    if cfg.hitSoundEnabled then
        pcall(function()
            hitSound:Play()
        end)
    end
    hitmarkerEndTime = tick() + 0.12
    if #hitmarkerLines == 2 and camera then
        local center = camera.ViewportSize / 2
        local size = 7
        hitmarkerLines[1].From = center - Vector2.new(size, size)
        hitmarkerLines[1].To = center + Vector2.new(size, size)
        hitmarkerLines[1].Visible = true

        hitmarkerLines[2].From = center - Vector2.new(-size, size)
        hitmarkerLines[2].To = center + Vector2.new(-size, size)
        hitmarkerLines[2].Visible = true
    end
    notify("Hitmarker", string.format("Hit %s for -%d HP", targetName, damage))
end

local function getPlayerTeam(plr)
    local t = Characters:FindFirstChild("Terrorists")
    local ct = Characters:FindFirstChild("Counter-Terrorists")
    if t and t:FindFirstChild(plr.Name) then
        return "Terrorists"
    end
    if ct and ct:FindFirstChild(plr.Name) then
        return "Counter-Terrorists"
    end
    return plr.Team and plr.Team.Name or "Unknown"
end

local function isValidTarget(p)
    if not p or p == player then
        return false
    end
    if cfg.deathmatchMode then
        return true
    end
    local myTeam = getPlayerTeam(player)
    local pTeam = getPlayerTeam(p)
    if myTeam ~= "Unknown" and pTeam ~= "Unknown" then
        return myTeam ~= pTeam
    end
    return true
end

local function isVisible(targetPart, character, visCheckEnabled)
    if not visCheckEnabled then
        return true
    end
    local myChar = player.Character
    local origin = camera.CFrame.Position
    local direction = targetPart.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local filterList = {camera}
    if myChar then
        table.insert(filterList, myChar)
    end
    if character and character ~= myChar then
        table.insert(filterList, character)
    end
    raycastParams.FilterDescendantsInstances = filterList
    local result = Workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

local function checkAimbotKeyPressed()
    if not cfg.requireKeyPress then return true end
    local key = cfg.aimbotKey
    if key == "MouseButton2" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif key == "E" then
        return UserInputService:IsKeyDown(Enum.KeyCode.E)
    elseif key == "Q" then
        return UserInputService:IsKeyDown(Enum.KeyCode.Q)
    elseif key == "Shift" then
        return UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
    elseif key == "LeftAlt" then
        return UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt)
    end
    return true
end

local function getAimbotTarget()
    if not camera or not checkAimbotKeyPressed() then
        return nil
    end
    local effectiveFov = cfg.aimbotFov
    if cfg.aimbotDynamicFov then
        effectiveFov = effectiveFov * 1.2
    end
    local maxDist = effectiveFov * 10
    local selected = nil
    local screenCenter = camera.ViewportSize / 2
    for _, v in ipairs(Players:GetPlayers()) do
        if not isValidTarget(v) then
            continue
        end
        local char = v.Character
        if not char or char:GetAttribute("Dead") == true then
            continue
        end
        local targetPart = char:FindFirstChild(cfg.aimbotTarget) or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Head")
        if not targetPart or not isVisible(targetPart, char, cfg.aimbotVisCheck) then
            continue
        end
        local pos, vis = camera:WorldToViewportPoint(targetPart.Position)
        if not vis or pos.Z <= 0 then
            continue
        end
        local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
        if dist <= maxDist then
            maxDist = dist
            selected = targetPart
        end
    end
    return selected
end

-- ==========================================
-- SILENT AIM & WEAPON HOOKS
-- ==========================================
local LocalPlayer = player
local function GetClosestPlayer()
    local closestDistance = math.huge
    local closest = nil
    local lchar = LocalPlayer.Character
    if not lchar then return end
    local lhrp = lchar:FindFirstChild("Head")
    if not lhrp then return end
    for _, v in ipairs(Players:GetPlayers()) do
        if v == LocalPlayer then continue end
        if not isValidTarget(v) then continue end
        local char = v.Character
        if not char then continue end
        if char:GetAttribute("Dead") then continue end
        local hrp = char:FindFirstChild("Head")
        if not hrp then continue end
        if cfg.silentAimVisCheck and not isVisible(hrp, char, true) then continue end
        local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
        if dist < closestDistance then
            closestDistance = dist
            closest = hrp
        end
    end
    return closest
end

_G._silentAimData = {
    target = nil,
    localPlayer = LocalPlayer,
    camera = camera,
    oldCast = nil,
    oldCastThrough = nil,
}

RunService.RenderStepped:Connect(function()
    if cfg.silentAimEnabled then
        _G._silentAimData.target = GetClosestPlayer()
    else
        _G._silentAimData.target = nil
    end
end)

local raycastMODULE
for _, obj in getgc(true) do
    if type(obj) == "table" and rawget(obj, "cast") and rawget(obj, "castThrough") and rawget(obj, "isPartOfHumanoid") then
        raycastMODULE = obj
        break
    end
end

if not raycastMODULE then
    warn("no raycast module found")
else
    local origiENV = getfenv()
    local newENV = {}
    setmetatable(newENV, {
        __index = function(_, key)
            if key == "getgenv" or key == "hookfunction" or key == "hookfunc" or key == "replaceclosure" or key == "oth" or key == "debug" then
                return nil
            end
            return origiENV[key]
        end
    })

    newENV._silentAimData = _G._silentAimData
    newENV.typeof = typeof
    newENV.Vector3 = Vector3
    newENV.warn = warn
    newENV.select = select

    local cast = loadstring([[
        return function(origin, direction, ...)
            local data = _silentAimData
            local t = data.target
            if t and typeof(direction) == "Vector3" then
                local lchar = data.localPlayer.Character
                if lchar and lchar:FindFirstChild("Head") then
                    if (origin - lchar.Head.Position).Magnitude < 12 then
                        direction = (t.Position - origin)
                    end
                end
            end
            return data.oldCast(origin, direction, ...)
        end
    ]])

    local castthrough = loadstring([[
        return function(origin, direction, ...)
            local data = _silentAimData
            local t = data.target
            if t and typeof(direction) == "Vector3" then
                local lchar = data.localPlayer.Character
                if lchar and lchar:FindFirstChild("Head") then
                    if (origin - lchar.Head.Position).Magnitude < 12 then
                        direction = (t.Position - origin)
                    end
                end
            end
            return data.oldCastThrough(origin, direction, ...)
        end
    ]])

    pcall(function() setfenv(cast, newENV) end)
    pcall(function() setfenv(castthrough, newENV) end)

    local castHook = cast()
    local castThroughHook = castthrough()

    _G._silentAimData.oldCast = hookfunction(raycastMODULE.cast, castHook)
    _G._silentAimData.oldCastThrough = hookfunction(raycastMODULE.castThrough, castThroughHook)
end

pcall(function()
    local CameraController = require(ReplicatedStorage.Controllers.CameraController)
    if CameraController then
        CameraController.weaponKick = function() end
        CameraController.setWeaponRecoil = function() end
    end
end)

pcall(function()
    local Bullet = require(ReplicatedStorage.Components.Weapon.Classes.Bullet)
    if Bullet then
        Bullet.getTrueSpread = function() return 0 end
        Bullet.getBaseSpread = function() return 0 end
        Bullet.getSpreadForConfig = function() return 0 end
        local OldCreate = Bullet.create
        if OldCreate then
            Bullet.create = function(self, aimingOptions, isAiming)
                if self.Spread then
                    self.Spread:setPosition(0)
                    self.Spread:setGoal(0)
                end
                return OldCreate(self, aimingOptions, isAiming)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.01) do
        if keyVerified and cfg.triggerBotEnabled and isAliveCheck() then
            local viewportSize = camera.ViewportSize
            local ray = camera:ViewportPointToRay(viewportSize.X / 2, viewportSize.Y / 2)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            local ignoreList = {camera}
            if player.Character then
                table.insert(ignoreList, player.Character)
            end
            raycastParams.FilterDescendantsInstances = ignoreList
            local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
            if result and result.Instance then
                local hitPart = result.Instance
                local model = hitPart:FindFirstAncestorOfClass("Model")
                if model and model:FindFirstChildOfClass("Humanoid") then
                    local targetPlayer = Players:GetPlayerFromCharacter(model)
                    if (targetPlayer and isValidTarget(targetPlayer)) or (cfg.deathmatchMode and model ~= player.Character) then
                        local hum = model:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            if cfg.triggerBotDelay > 0 then
                                task.wait(cfg.triggerBotDelay / 1000)
                            end
                            local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
                            if tool then
                                tool:Activate()
                            end
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
    end
end)

-- Anti-Effects Loop
task.spawn(function()
    while task.wait(0.1) do
        if not keyVerified then continue end
        
        if cfg.noFlashEnabled then
            pcall(function()
                for _, root in ipairs({playerGui, game:GetService("CoreGui")}) do
                    if root then
                        for _, v in ipairs(root:GetDescendants()) do
                            if v:IsA("Frame") or v:IsA("ImageLabel") then
                                local name = v.Name:lower()
                                if name:find("flash") or name:find("blind") or name:find("white") or name:find("flashbang") then
                                    v.Visible = false
                                end
                            end
                        end
                    end
                end
                for _, v in ipairs(Lighting:GetChildren()) do
                    if v:IsA("ColorCorrectionEffect") then
                        v.Enabled = false
                    end
                end
                if player.Character then
                    player.Character:SetAttribute("Flashed", 0)
                end
            end)
        end
        
        if cfg.noSmokeEnabled then
            pcall(function()
                for _, v in ipairs(Workspace:GetDescendants()) do
                    local name = v.Name:lower()
                    local parentName = v.Parent and v.Parent.Name:lower() or ""
                    if name:find("smoke") or parentName:find("smoke") or name:find("cloud") or name:find("fog") then
                        if v:IsA("ParticleEmitter") or v:IsA("Smoke") then
                            v.Enabled = false
                        elseif v:IsA("BasePart") then
                            v.Transparency = 1
                            v.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
end)

local fovCircle = nil
local crosshairLines = {}
local crosshairCircle = nil
local crosshairDotObj = nil

if okDrawing and Drawing then
    pcall(function()
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 1.5
        fovCircle.Color = Color3.fromRGB(235, 235, 235)
        fovCircle.Transparency = 1
        fovCircle.NumSides = 64
        fovCircle.Filled = cfg.fovFilled
        fovCircle.Visible = false

        for i = 1, 4 do
            local line = Drawing.new("Line")
            line.Thickness = cfg.crosshairThickness
            line.Color = cfg.crosshairColor
            line.Visible = false
            table.insert(crosshairLines, line)
        end

        crosshairCircle = Drawing.new("Circle")
        crosshairCircle.Thickness = 1.5
        crosshairCircle.Filled = false
        crosshairCircle.Visible = false

        crosshairDotObj = Drawing.new("Square")
        crosshairDotObj.Filled = true
        crosshairDotObj.Size = Vector2.new(2, 2)
        crosshairDotObj.Visible = false
    end)
end

local skeletonBonePairs = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local espCache = {}
local trackedHealths = {}
local function removeEspForPlayer(plr)
    if espCache[plr] then
        for key, obj in pairs(espCache[plr]) do
            if key == "SkeletonLines" or key == "CornerLines" then
                for _, line in ipairs(obj) do
                    pcall(function() line:Remove() end)
                end
            else
                pcall(function() obj:Remove() end)
            end
        end
        espCache[plr] = nil
    end
    trackedHealths[plr] = nil
    local char = plr.Character
    if char then
        local hl = char:FindFirstChild("AxonHubHighlight")
        if hl then hl:Destroy() end
    end
end

RunService.Stepped:Connect(function()
    if not keyVerified then return end
    if cfg.noclipEnabled then
        pcall(function()
            local myChar = player.Character
            if myChar then
                for _, part in ipairs(myChar:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
    if cfg.hitboxExpanderEnabled then
        pcall(function()
            for _, v in ipairs(Players:GetPlayers()) do
                if v ~= player and isValidTarget(v) then
                    local char = v.Character
                    local head = char and char:FindFirstChild("Head")
                    if head then
                        local safeSize = math.clamp(cfg.hitboxSize, 1.5, 3)
                        head.Size = Vector3.new(safeSize, safeSize, safeSize)
                        head.Transparency = 1
                        head.CanCollide = false
                    end
                end
            end
        end)
    end
end)

RunService.RenderStepped:Connect(function()
    if not keyVerified then return end

    if cfg.glassArmsEnabled then
        pcall(function()
            for _, obj in ipairs(camera:GetChildren()) do
                if obj:IsA("Model") then
                    local mode = cfg.glassArmsMode
                    for _, part in ipairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local nameLower = part.Name:lower()
                            local parentName = part.Parent and part.Parent.Name:lower() or ""
                            
                            local isArm = nameLower:find("arm") or nameLower:find("glove") or nameLower:find("hand") or nameLower:find("sleeve")
                            local isCharm = nameLower:find("charm") or parentName:find("charm")
                            local isGun = not isArm and not isCharm
                            
                            local targetMatch = false
                            if mode == "Both" then
                                targetMatch = true
                            elseif mode == "Gun" then
                                targetMatch = isGun or isCharm
                            elseif mode == "Arms" then
                                targetMatch = isArm or isCharm
                            end
                            
                            local hl = part:FindFirstChild("AxonVMOutline")
                            if targetMatch then
                                if not hl then
                                    hl = Instance.new("Highlight")
                                    hl.Name = "AxonVMOutline"
                                    hl.Adornee = part
                                    hl.FillTransparency = 1
                                    hl.OutlineTransparency = 0
                                    hl.OutlineColor = cfg.espColor
                                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    hl.Parent = part
                                else
                                    hl.OutlineColor = cfg.espColor
                                    hl.Enabled = true
                                end
                            else
                                if hl then hl.Enabled = false end
                            end
                        end
                    end
                end
            end
        end)
    else
        pcall(function()
            for _, obj in ipairs(camera:GetChildren()) do
                if obj:IsA("Model") then
                    for _, part in ipairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local hl = part:FindFirstChild("AxonVMOutline")
                            if hl then hl.Enabled = false end
                        end
                    end
                end
            end
        end)
    end

    if hitmarkerEndTime > 0 and tick() > hitmarkerEndTime then
        hitmarkerEndTime = 0
        for _, l in ipairs(hitmarkerLines) do l.Visible = false end
    end

    if cfg.fullbrightEnabled then
        pcall(function()
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        end)
    elseif cfg.ambientEnabled then
        pcall(function()
            Lighting.Brightness = cfg.ambientBrightness
            Lighting.Ambient = cfg.ambientColor
            Lighting.OutdoorAmbient = cfg.ambientColor
        end)
    end

    if cfg.timeOfDay == "Night" then
        pcall(function() Lighting.ClockTime = 0 end)
    elseif cfg.timeOfDay == "Evening" then
        pcall(function() Lighting.ClockTime = 18 end)
    elseif cfg.timeOfDay == "Day" then
        pcall(function() Lighting.ClockTime = 14 end)
    end

    if cfg.aimbotEnabled then
        pcall(function()
            local targetPart = getAimbotTarget()
            if targetPart and camera then
                local currentCFrame = camera.CFrame
                local targetPos = targetPart.Position
                if cfg.aimbotPrediction and targetPart.AssemblyLinearVelocity then
                    targetPos = targetPos + (targetPart.AssemblyLinearVelocity * 0.05)
                end
                if cfg.aimbotHumanize then
                    local shakeOffset = Vector3.new(
                        (math.random() - 0.5) * cfg.aimbotShakeIntensity,
                        (math.random() - 0.5) * cfg.aimbotShakeIntensity,
                        (math.random() - 0.5) * cfg.aimbotShakeIntensity
                    )
                    targetPos = targetPos + shakeOffset
                end
                local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
                local alpha = math.clamp(1 / (cfg.aimbotSmoothness * 3), 0.005, 0.5)
                camera.CFrame = currentCFrame:Lerp(targetCFrame, alpha)
            end
        end)
    end

    if cfg.bhopEnabled then
        pcall(function()
            local myChar = player.Character
            local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = cfg.bhopJumpPower
                hum.JumpHeight = math.clamp(cfg.bhopJumpPower / 6, 1, 10)
                if hum.FloorMaterial ~= Enum.Material.Air then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end

    if cfg.cameraFovEnabled and camera then
        pcall(function() camera.FieldOfView = cfg.cameraFovValue end)
    end

    if cfg.stretchResEnabled and camera then
        pcall(function() camera.CFrame = camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.67, 0, 0, 0, 1) end)
    end

    if not camera then return end

    if fovCircle then
        if cfg.showFov then
            fovCircle.Position = camera.ViewportSize / 2
            fovCircle.Radius = cfg.aimbotFov * 10
            fovCircle.Visible = true
            fovCircle.Filled = cfg.fovFilled
            fovCircle.Color = cfg.espColor
            fovCircle.Transparency = cfg.fovFilled and cfg.fovTransparency or 1
        else
            fovCircle.Visible = false
        end
    end

    if cfg.crosshairEnabled then
        local center = camera.ViewportSize / 2
        local style = cfg.crosshairStyle
        
        for _, line in ipairs(crosshairLines) do line.Visible = false end
        if crosshairCircle then crosshairCircle.Visible = false end
        if crosshairDotObj then crosshairDotObj.Visible = false end

        if style == "Cross" and #crosshairLines == 4 then
            local size = cfg.crosshairSize
            local gap = cfg.crosshairGap
            for _, l in ipairs(crosshairLines) do
                l.Thickness = cfg.crosshairThickness
                l.Color = cfg.crosshairColor
            end
            crosshairLines[1].From = Vector2.new(center.X, center.Y - gap - size)
            crosshairLines[1].To = Vector2.new(center.X, center.Y - gap)
            crosshairLines[1].Visible = true

            crosshairLines[2].From = Vector2.new(center.X, center.Y + gap)
            crosshairLines[2].To = Vector2.new(center.X, center.Y + gap + size)
            crosshairLines[2].Visible = true

            crosshairLines[3].From = Vector2.new(center.X - gap - size, center.Y)
            crosshairLines[3].To = Vector2.new(center.X - gap, center.Y)
            crosshairLines[3].Visible = true

            crosshairLines[4].From = Vector2.new(center.X + gap, center.Y)
            crosshairLines[4].To = Vector2.new(center.X + gap + size, center.Y)
            crosshairLines[4].Visible = true
        elseif style == "Circle" and crosshairCircle then
            crosshairCircle.Position = center
            crosshairCircle.Radius = cfg.crosshairSize + cfg.crosshairGap
            crosshairCircle.Thickness = cfg.crosshairThickness
            crosshairCircle.Color = cfg.crosshairColor
            crosshairCircle.Visible = true
        end

        if cfg.crosshairDot and crosshairDotObj then
            crosshairDotObj.Position = center - Vector2.new(1, 1)
            crosshairDotObj.Color = cfg.crosshairColor
            crosshairDotObj.Visible = true
        end
    else
        for _, line in ipairs(crosshairLines) do line.Visible = false end
        if crosshairCircle then crosshairCircle.Visible = false end
        if crosshairDotObj then crosshairDotObj.Visible = false end
    end

    for _, v in ipairs(Players:GetPlayers()) do
        if v == player or not isValidTarget(v) then
            removeEspForPlayer(v)
            continue
        end
        local char = v.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not rootPart or not head or not hum or char:GetAttribute("Dead") == true then
            removeEspForPlayer(v)
            continue
        end

        if okDrawing and Drawing then
            if not espCache[v] then
                local skeletonLines = {}
                for i = 1, #skeletonBonePairs do
                    local line = Drawing.new("Line")
                    line.Thickness = 1
                    line.Color = cfg.skeletonColor
                    line.Visible = false
                    table.insert(skeletonLines, line)
                end
                
                local cornerLines = {}
                for i = 1, 16 do
                    local cline = Drawing.new("Line")
                    cline.Thickness = 1.5
                    cline.Color = cfg.espColor
                    cline.Visible = false
                    table.insert(cornerLines, cline)
                end

                espCache[v] = {
                    Box = Drawing.new("Square"),
                    CornerLines = cornerLines,
                    HealthBarBG = Drawing.new("Square"),
                    HealthBar = Drawing.new("Square"),
                    ArmorBarBG = Drawing.new("Square"),
                    ArmorBar = Drawing.new("Square"),
                    Name = Drawing.new("Text"),
                    Distance = Drawing.new("Text"),
                    Weapon = Drawing.new("Text"),
                    Tracer = Drawing.new("Line"),
                    SkeletonLines = skeletonLines
                }
                espCache[v].Box.Filled = false
                espCache[v].Box.Thickness = 1.5
                
                espCache[v].HealthBarBG.Filled = true
                espCache[v].HealthBarBG.Color = Color3.fromRGB(0, 0, 0)
                espCache[v].HealthBar.Filled = true

                espCache[v].ArmorBarBG.Filled = true
                espCache[v].ArmorBarBG.Color = Color3.fromRGB(0, 0, 0)
                espCache[v].ArmorBar.Filled = true

                espCache[v].Name.Size = 11
                espCache[v].Name.Center = true
                espCache[v].Name.Outline = true
                espCache[v].Distance.Size = 12
                espCache[v].Distance.Center = true
                espCache[v].Distance.Outline = true
                espCache[v].Weapon.Size = 11
                espCache[v].Weapon.Center = true
                espCache[v].Weapon.Outline = true
                espCache[v].Tracer.Thickness = 1
            end

            local headPos, headVis = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))
            local rootPos, rootVis = camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3.2, 0))

            if headVis or rootVis then
                local box = espCache[v].Box
                local cornerLines = espCache[v].CornerLines
                local hbBG = espCache[v].HealthBarBG
                local hb = espCache[v].HealthBar
                local abBG = espCache[v].ArmorBarBG
                local ab = espCache[v].ArmorBar
                local name = espCache[v].Name
                local distText = espCache[v].Distance
                local weaponText = espCache[v].Weapon
                local tracer = espCache[v].Tracer

                local height = math.abs(headPos.Y - rootPos.Y) * 1.32
                local width = height * 0.68
                local boxPos = Vector2.new(headPos.X - width / 2, headPos.Y - (height * 0.08))

                if cfg.boxEnabled then
                    if cfg.boxStyle == "Full" then
                        for _, cline in ipairs(cornerLines) do cline.Visible = false end
                        box.Size = Vector2.new(width, height)
                        box.Position = boxPos
                        box.Color = cfg.espColor
                        box.Filled = cfg.espBoxFilled
                        box.Transparency = cfg.espBoxTransparency
                        box.Visible = true
                    elseif cfg.boxStyle == "Corner" then
                        box.Visible = false
                        local x, y, w, h = boxPos.X, boxPos.Y, width, height
                        local lengthX, lengthY = w / 4, h / 4
                        
                        local linesConfig = {
                            {Vector2.new(x, y), Vector2.new(x + lengthX, y)},
                            {Vector2.new(x, y), Vector2.new(x, y + lengthY)},
                            {Vector2.new(x + w, y), Vector2.new(x + w - lengthX, y)},
                            {Vector2.new(x + w, y), Vector2.new(x + w, y + lengthY)},
                            {Vector2.new(x, y + h), Vector2.new(x + lengthX, y + h)},
                            {Vector2.new(x, y + h), Vector2.new(x, y + h - lengthY)},
                            {Vector2.new(x + w, y + h), Vector2.new(x + w - lengthX, y + h)},
                            {Vector2.new(x + w, y + h), Vector2.new(x + w, y + h - lengthY)}
                        }
                        
                        for i = 1, 8 do
                            local cline = cornerLines[i]
                            local data = linesConfig[i]
                            if cline and data then
                                cline.From = data[1]
                                cline.To = data[2]
                                cline.Color = cfg.espColor
                                cline.Visible = true
                            end
                        end
                    elseif cfg.boxStyle == "3D" then
                        box.Visible = false
                        for _, cline in ipairs(cornerLines) do cline.Visible = false end
                        box.Size = Vector2.new(width, height)
                        box.Position = boxPos
                        box.Color = cfg.espColor
                        box.Filled = false
                        box.Visible = true
                    end
                else
                    box.Visible = false
                    for _, cline in ipairs(cornerLines) do cline.Visible = false end
                end

                if cfg.healthBarEnabled then
                    local healthPct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                    local barHeight = height * healthPct
                    hbBG.Size = Vector2.new(2, height + 2)
                    hbBG.Position = boxPos - Vector2.new(5, 1)
                    hbBG.Visible = true

                    hb.Size = Vector2.new(1, barHeight)
                    hb.Position = boxPos - Vector2.new(4, 0) + Vector2.new(0, height - barHeight)
                    hb.Color = Color3.fromRGB(255 * (1 - healthPct), 255 * healthPct, 0)
                    hb.Visible = true
                else
                    hbBG.Visible = false
                    hb.Visible = false
                end

                if cfg.armorBarEnabled then
                    abBG.Size = Vector2.new(2, height + 2)
                    abBG.Position = boxPos + Vector2.new(width + 3, -1)
                    abBG.Visible = true

                    ab.Size = Vector2.new(1, height * 0.75)
                    ab.Position = boxPos + Vector2.new(width + 4, 0) + Vector2.new(0, height * 0.25)
                    ab.Color = Color3.fromRGB(50, 150, 255)
                    ab.Visible = true
                else
                    abBG.Visible = false
                    ab.Visible = false
                end

                if cfg.skeletonEnabled then
                    for i, pair in ipairs(skeletonBonePairs) do
                        local partA = char:FindFirstChild(pair[1])
                        local partB = char:FindFirstChild(pair[2])
                        local skLine = espCache[v].SkeletonLines[i]
                        if partA and partB and skLine then
                            local posA, visA = camera:WorldToViewportPoint(partA.Position)
                            local posB, visB = camera:WorldToViewportPoint(partB.Position)
                            if visA or visB then
                                skLine.From = Vector2.new(posA.X, posA.Y)
                                skLine.To = Vector2.new(posB.X, posB.Y)
                                skLine.Color = cfg.skeletonColor
                                skLine.Visible = true
                            else
                                skLine.Visible = false
                            end
                        else
                            if skLine then skLine.Visible = false end
                        end
                    end
                else
                    for _, skLine in ipairs(espCache[v].SkeletonLines) do
                        skLine.Visible = false
                    end
                end

                if cfg.nameEspEnabled then
                    name.Text = v.Name
                    name.Position = Vector2.new(headPos.X, headPos.Y - 16)
                    name.Color = cfg.nameColor
                    name.Visible = true
                else
                    name.Visible = false
                end

                if cfg.distanceEspEnabled then
                    local distance = math.floor((rootPart.Position - camera.CFrame.Position).Magnitude)
                    distText.Text = tostring(distance) .. "m"
                    distText.Position = Vector2.new(rootPos.X, rootPos.Y + 8)
                    distText.Color = cfg.distanceColor
                    distText.Visible = true
                else
                    distText.Visible = false
                end

                if cfg.weaponEspEnabled then
                    local equippedTool = char:FindFirstChildOfClass("Tool")
                    weaponText.Text = equippedTool and equippedTool.Name or "Fists / Knife"
                    weaponText.Position = Vector2.new(rootPos.X, rootPos.Y + 22)
                    weaponText.Color = Color3.fromRGB(220, 220, 220)
                    weaponText.Visible = true
                else
                    weaponText.Visible = false
                end

                if cfg.tracersEnabled then
                    tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                    tracer.Color = cfg.tracerColor
                    tracer.Visible = true
                else
                    tracer.Visible = false
                end
            else
                for key, obj in pairs(espCache[v]) do
                    if key == "SkeletonLines" or key == "CornerLines" then
                        for _, line in ipairs(obj) do line.Visible = false end
                    elseif typeof(obj) == "Instance" or (typeof(obj) == "table" and obj.Visible ~= nil) then
                        obj.Visible = false
                    end
                end
            end
        end

        local currentHealth = hum.Health
        if trackedHealths[v] then
            if currentHealth < trackedHealths[v] then
                local isShooting = cfg.triggerBotEnabled or cfg.silentAimEnabled or cfg.aimbotEnabled
                if isShooting then
                    local damageDealt = math.floor(trackedHealths[v] - currentHealth)
                    triggerHitmarker(damageDealt, v.Name)
                    if currentHealth <= 0 and cfg.killEffectEnabled then
                        notify("Elimination", "Eliminated target: " .. v.Name)
                    end
                end
            end
        end
        trackedHealths[v] = currentHealth

        if cfg.chamsEnabled then
            local hl = char:FindFirstChild("AxonHubHighlight")
            if not hl then
                hl = Instance.new("Highlight")
                hl.Name = "AxonHubHighlight"
                hl.Adornee = char
                hl.FillColor = cfg.espColor
                hl.OutlineColor = cfg.espColor
                hl.FillTransparency = 0.35
                hl.OutlineTransparency = 0
                hl.Parent = char
            else
                hl.FillColor = cfg.espColor
                hl.OutlineColor = cfg.espColor
                hl.Enabled = true
            end
            
            local matEnum = Enum.Material.Neon
            if cfg.chamsMaterial == "Glass" then
                matEnum = Enum.Material.Glass
            elseif cfg.chamsMaterial == "SmoothPlastic" then
                matEnum = Enum.Material.SmoothPlastic
            elseif cfg.chamsMaterial == "ForceField" then
                matEnum = Enum.Material.ForceField
            end
            
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.Material = matEnum
                end
            end
        else
            local hl = char:FindFirstChild("AxonHubHighlight")
            if hl then hl.Enabled = false end
        end
    end
end)

reloadvm()
print("Axon Hub PC Version Loaded Successfully! Press [INSERT] to toggle menu.")
