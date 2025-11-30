--[[
    Unicore UI Library
    Modern Roblox UI Library with Gradient Design
    Features: Flags, Callbacks, Dropdowns, Toggles, Config System, Notifications, Keybinds, and more
]]

local Library = {}
Library.__index = Library

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Constants
local ACCENT_COLOR = Color3.fromRGB(58, 128, 255)
local PRIMARY_COLOR = Color3.fromRGB(20, 25, 40)
local SECONDARY_COLOR = Color3.fromRGB(25, 30, 45)
local OUTLINE_COLOR = Color3.fromRGB(40, 50, 70)
local TEXT_COLOR = Color3.fromRGB(200, 210, 230)
local GLOW_COLOR = Color3.fromRGB(58, 128, 255)

-- Utility Functions
local Utility = {}

function Utility:Tween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utility:MakeDraggable(frame, handle)
    local dragging = false
    local dragInput, mousePos, framePos
    
    handle = handle or frame
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

function Utility:MakeResizable(frame, minSize)
    minSize = minSize or Vector2.new(500, 400)
    
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.new(0, 15, 0, 15)
    resizeHandle.Position = UDim2.new(1, -15, 1, -15)
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.Parent = frame
    
    local resizing = false
    local startPos, startSize
    
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            startPos = input.Position
            startSize = frame.Size
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startPos
            local newSize = Vector2.new(
                math.max(minSize.X, startSize.X.Offset + delta.X),
                math.max(minSize.Y, startSize.Y.Offset + delta.Y)
            )
            frame.Size = UDim2.new(0, newSize.X, 0, newSize.Y)
        end
    end)
end

-- Keybind Aliases
local KeybindAliases = {
    ["LeftClick"] = Enum.UserInputType.MouseButton1,
    ["RightClick"] = Enum.UserInputType.MouseButton2,
    ["MiddleClick"] = Enum.UserInputType.MouseButton3,
    ["Insert"] = Enum.KeyCode.Insert,
    ["Home"] = Enum.KeyCode.Home,
    ["End"] = Enum.KeyCode.End,
    ["PageUp"] = Enum.KeyCode.PageUp,
    ["PageDown"] = Enum.KeyCode.PageDown
}

-- Flags System
Library.Flags = {}
Library.ConfigFolder = "UnicoreConfigs"

function Library:SaveConfig(name)
    local config = {}
    for flag, value in pairs(self.Flags) do
        config[flag] = value
    end
    
    local success, err = pcall(function()
        if not isfolder(self.ConfigFolder) then
            makefolder(self.ConfigFolder)
        end
        writefile(self.ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(config))
    end)
    
    if success then
        Library:Notify("Config Saved", "Configuration saved successfully!", 3)
    else
        Library:Notify("Error", "Failed to save config!", 3)
    end
end

function Library:LoadConfig(name)
    local success, err = pcall(function()
        local data = readfile(self.ConfigFolder .. "/" .. name .. ".json")
        local config = HttpService:JSONDecode(data)
        
        for flag, value in pairs(config) do
            if self.Flags[flag] ~= nil then
                self.Flags[flag] = value
                if self.FlagCallbacks[flag] then
                    self.FlagCallbacks[flag](value)
                end
            end
        end
    end)
    
    if success then
        Library:Notify("Config Loaded", "Configuration loaded successfully!", 3)
    else
        Library:Notify("Error", "Failed to load config!", 3)
    end
end

-- Notification System
Library.Notifications = {}

function Library:Notify(title, message, duration)
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "UnicoreNotification"
    notifGui.Parent = CoreGui
    notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local notifFrame = Instance.new("Frame")
    notifFrame.Name = "NotificationFrame"
    notifFrame.Size = UDim2.new(0, 300, 0, 0)
    notifFrame.Position = UDim2.new(1, -320, 1, 20)
    notifFrame.BackgroundColor3 = SECONDARY_COLOR
    notifFrame.BorderSizePixel = 0
    notifFrame.ClipsDescendants = true
    notifFrame.Parent = notifGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = notifFrame
    
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1, 30, 1, 30)
    glow.Position = UDim2.new(0, -15, 0, -15)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    glow.ImageColor3 = GLOW_COLOR
    glow.ImageTransparency = 0.7
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(10, 10, 10, 10)
    glow.Parent = notifFrame
    
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.BackgroundColor3 = ACCENT_COLOR
    accent.BorderSizePixel = 0
    accent.Parent = notifFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = TEXT_COLOR
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notifFrame
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0, 40)
    messageLabel.Position = UDim2.new(0, 10, 0, 35)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = TEXT_COLOR
    messageLabel.TextSize = 12
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = notifFrame
    
    Utility:Tween(notifFrame, {Size = UDim2.new(0, 300, 0, 85), Position = UDim2.new(1, -320, 1, -105)}, 0.3)
    
    task.wait(duration or 3)
    
    Utility:Tween(notifFrame, {Position = UDim2.new(1, -320, 1, 20)}, 0.3)
    task.wait(0.3)
    notifGui:Destroy()
end

-- Watermark System
function Library:CreateWatermark(options)
    options = options or {}
    local showFPS = options.ShowFPS ~= false
    local showPing = options.ShowPing ~= false
    local showTime = options.ShowTime ~= false
    
    local watermarkGui = Instance.new("ScreenGui")
    watermarkGui.Name = "UnicoreWatermark"
    watermarkGui.Parent = CoreGui
    watermarkGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local watermarkFrame = Instance.new("Frame")
    watermarkFrame.Name = "Watermark"
    watermarkFrame.Size = UDim2.new(0, 250, 0, 30)
    watermarkFrame.Position = UDim2.new(0, 10, 0, 10)
    watermarkFrame.BackgroundColor3 = SECONDARY_COLOR
    watermarkFrame.BorderSizePixel = 0
    watermarkFrame.Parent = watermarkGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = watermarkFrame
    
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0, -10, 0, -10)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    glow.ImageColor3 = GLOW_COLOR
    glow.ImageTransparency = 0.7
    glow.Parent = watermarkFrame
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, SECONDARY_COLOR),
        ColorSequenceKeypoint.new(1, PRIMARY_COLOR)
    }
    gradient.Rotation = 90
    gradient.Parent = watermarkFrame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "Unicore | Loading..."
    textLabel.TextColor3 = TEXT_COLOR
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = watermarkFrame
    
    local fps = 0
    local lastUpdate = tick()
    local frameCount = 0
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        if tick() - lastUpdate >= 1 then
            fps = frameCount
            frameCount = 0
            lastUpdate = tick()
        end
        
        local parts = {"Unicore"}
        
        if showFPS then
            table.insert(parts, string.format("FPS: %d", fps))
        end
        
        if showPing then
            local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            table.insert(parts, string.format("Ping: %dms", ping))
        end
        
        if showTime then
            table.insert(parts, os.date("%H:%M:%S"))
        end
        
        textLabel.Text = table.concat(parts, " | ")
    end)
    
    return {
        SetVisible = function(visible)
            watermarkFrame.Visible = visible
        end,
        SetOptions = function(newOptions)
            showFPS = newOptions.ShowFPS ~= false
            showPing = newOptions.ShowPing ~= false
            showTime = newOptions.ShowTime ~= false
        end
    }
end

-- Keybind List
function Library:CreateKeybindList()
    local keybindGui = Instance.new("ScreenGui")
    keybindGui.Name = "UnicoreKeybinds"
    keybindGui.Parent = CoreGui
    keybindGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Name = "KeybindList"
    keybindFrame.Size = UDim2.new(0, 200, 0, 25)
    keybindFrame.Position = UDim2.new(1, -210, 0, 50)
    keybindFrame.BackgroundColor3 = SECONDARY_COLOR
    keybindFrame.BorderSizePixel = 0
    keybindFrame.Visible = false
    keybindFrame.Parent = keybindGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = keybindFrame
    
    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 25)
    header.BackgroundTransparency = 1
    header.Text = "Keybinds"
    header.TextColor3 = ACCENT_COLOR
    header.TextSize = 13
    header.Font = Enum.Font.GothamBold
    header.Parent = keybindFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = keybindFrame
    
    Library.KeybindList = {
        Frame = keybindFrame,
        Keybinds = {}
    }
    
    return Library.KeybindList
end

-- Main Library Creation
function Library:Create(options)
    options = options or {}
    local name = options.Name or "Unicore"
    local accentColor = options.AccentColor or ACCENT_COLOR
    
    ACCENT_COLOR = accentColor
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UnicoreLib"
    screenGui.Parent = CoreGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 700, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    mainFrame.BackgroundColor3 = PRIMARY_COLOR
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Glow effect
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1, 40, 1, 40)
    glow.Position = UDim2.new(0, -20, 0, -20)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    glow.ImageColor3 = GLOW_COLOR
    glow.ImageTransparency = 0.5
    glow.ZIndex = 0
    glow.Parent = mainFrame
    
    -- Top gradient bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 3)
    topBar.BackgroundColor3 = ACCENT_COLOR
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    local topGradient = Instance.new("UIGradient")
    topGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, ACCENT_COLOR),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 150, 255)),
        ColorSequenceKeypoint.new(1, ACCENT_COLOR)
    }
    topGradient.Parent = topBar
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 45)
    header.Position = UDim2.new(0, 0, 0, 3)
    header.BackgroundColor3 = SECONDARY_COLOR
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, SECONDARY_COLOR),
        ColorSequenceKeypoint.new(1, PRIMARY_COLOR)
    }
    headerGradient.Rotation = 90
    headerGradient.Parent = header
    
    local logo = Instance.new("TextLabel")
    logo.Name = "Logo"
    logo.Size = UDim2.new(0, 200, 1, 0)
    logo.Position = UDim2.new(0, 15, 0, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "U  " .. name:upper()
    logo.TextColor3 = TEXT_COLOR
    logo.TextSize = 18
    logo.Font = Enum.Font.GothamBold
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Parent = header
    
    -- Tab system
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 130, 1, -48)
    tabContainer.Position = UDim2.new(0, 0, 0, 48)
    tabContainer.BackgroundColor3 = SECONDARY_COLOR
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    
    local tabGradient = Instance.new("UIGradient")
    tabGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 22, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 30, 45))
    }
    tabGradient.Rotation = 90
    tabGradient.Parent = tabContainer
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 2)
    tabLayout.Parent = tabContainer
    
    -- Content area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -130, 1, -48)
    contentArea.Position = UDim2.new(0, 130, 0, 48)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame
    
    Utility:MakeDraggable(mainFrame, header)
    Utility:MakeResizable(mainFrame)
    
    Library.FlagCallbacks = {}
    Library.ScreenGui = screenGui
    Library.MainFrame = mainFrame
    Library.TabContainer = tabContainer
    Library.ContentArea = contentArea
    Library.Tabs = {}
    Library.CurrentTab = nil
    
    return setmetatable({
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        Name = name,
        AccentColor = accentColor
    }, Library)
end

-- Tab Creation
function Library:AddTab(name, icon)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name
    tabButton.Size = UDim2.new(1, -10, 0, 35)
    tabButton.BackgroundColor3 = SECONDARY_COLOR
    tabButton.BorderSizePixel = 0
    tabButton.Text = ""
    tabButton.AutoButtonColor = false
    tabButton.Parent = self.TabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabButton
    
    local iconLabel = Instance.new("ImageLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.new(0, 18, 0, 18)
    iconLabel.Position = UDim2.new(0, 10, 0.5, -9)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Image = icon or "rbxasset://textures/ui/GuiImagePlaceholder.png"
    iconLabel.ImageColor3 = TEXT_COLOR
    iconLabel.Parent = tabButton
    
    local tabLabel = Instance.new("TextLabel")
    tabLabel.Name = "Label"
    tabLabel.Size = UDim2.new(1, -40, 1, 0)
    tabLabel.Position = UDim2.new(0, 35, 0, 0)
    tabLabel.BackgroundTransparency = 1
    tabLabel.Text = name
    tabLabel.TextColor3 = TEXT_COLOR
    tabLabel.TextSize = 13
    tabLabel.Font = Enum.Font.Gotham
    tabLabel.TextXAlignment = Enum.TextXAlignment.Left
    tabLabel.Parent = tabButton
    
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = name .. "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -20)
    contentFrame.Position = UDim2.new(0, 10, 0, 10)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 4
    contentFrame.ScrollBarImageColor3 = ACCENT_COLOR
    contentFrame.Visible = false
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.Parent = self.ContentArea
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = contentFrame
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
    end)
    
    tabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Tabs) do
            tab.Button.BackgroundColor3 = SECONDARY_COLOR
            tab.Label.TextColor3 = TEXT_COLOR
            tab.Icon.ImageColor3 = TEXT_COLOR
            tab.Content.Visible = false
        end
        
        tabButton.BackgroundColor3 = OUTLINE_COLOR
        tabLabel.TextColor3 = ACCENT_COLOR
        iconLabel.ImageColor3 = ACCENT_COLOR
        contentFrame.Visible = true
        self.CurrentTab = name
    end)
    
    local tab = {
        Name = name,
        Button = tabButton,
        Label = tabLabel,
        Icon = iconLabel,
        Content = contentFrame,
        Sections = {}
    }
    
    self.Tabs[name] = tab
    
    if not self.CurrentTab then
        tabButton.BackgroundColor3 = OUTLINE_COLOR
        tabLabel.TextColor3 = ACCENT_COLOR
        iconLabel.ImageColor3 = ACCENT_COLOR
        contentFrame.Visible = true
        self.CurrentTab = name
    end
    
    return setmetatable(tab, {__index = self})
end

-- Section Creation
function Library:AddSection(name)
    local section = Instance.new("Frame")
    section.Name = name
    section.Size = UDim2.new(1, 0, 0, 35)
    section.BackgroundColor3 = SECONDARY_COLOR
    section.BorderSizePixel = 0
    section.Parent = self.Content
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 6)
    sectionCorner.Parent = section
    
    local sectionHeader = Instance.new("Frame")
    sectionHeader.Name = "Header"
    sectionHeader.Size = UDim2.new(1, 0, 0, 30)
    sectionHeader.BackgroundTransparency = 1
    sectionHeader.Parent = section
    
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Name = "Label"
    sectionLabel.Size = UDim2.new(1, -40, 1, 0)
    sectionLabel.Position = UDim2.new(0, 15, 0, 0)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = name
    sectionLabel.TextColor3 = ACCENT_COLOR
    sectionLabel.TextSize = 14
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel.Parent = sectionHeader
    
    local dropdownIcon = Instance.new("TextButton")
    dropdownIcon.Name = "Toggle"
    dropdownIcon.Size = UDim2.new(0, 20, 0, 20)
    dropdownIcon.Position = UDim2.new(1, -30, 0, 5)
    dropdownIcon.BackgroundTransparency = 1
    dropdownIcon.Text = "▼"
    dropdownIcon.TextColor3 = TEXT_COLOR
    dropdownIcon.TextSize = 12
    dropdownIcon.Font = Enum.Font.GothamBold
    dropdownIcon.Parent = sectionHeader
    
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, 0, 1, -30)
    contentContainer.Position = UDim2.new(0, 0, 0, 30)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ClipsDescendants = true
    contentContainer.Parent = section
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 5)
    contentLayout.Parent = contentContainer
    
    local isOpen = true
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        section.Size = UDim2.new(1, 0, 0, isOpen and (contentLayout.AbsoluteContentSize.Y + 40) or 35)
    end)
    
    dropdownIcon.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        dropdownIcon.Text = isOpen and "▼" or "▶"
        Utility:Tween(section, {Size = UDim2.new(1, 0, 0, isOpen and (contentLayout.AbsoluteContentSize.Y + 40) or 35)}, 0.2)
    end)
    
    return {
        Frame = section,
        Container = contentContainer,
        Name = name
    }
end

-- Toggle/Checkbox
function Library:AddToggle(options)
    options = options or {}
    local name = options.Name or "Toggle"
    local flag = options.Flag
    local default = options.Default or false
    local callback = options.Callback or function() end
    local tooltip = options.Tooltip
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = name
    toggleFrame.Size = UDim2.new(1, -20, 0, 30)
    toggleFrame.BackgroundColor3 = OUTLINE_COLOR
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = self.Container or self.Content
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleFrame
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "Label"
    toggleLabel.Size = UDim2.new(1, -50, 1, 0)
    toggleLabel.Position = UDim2.new(0, 10, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = name
    toggleLabel.TextColor3 = TEXT_COLOR
    toggleLabel.TextSize = 12
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Button"
    toggleButton.Size = UDim2.new(0, 40, 0, 18)
    toggleButton.Position = UDim2.new(1, -45, 0.5, -9)
    toggleButton.BackgroundColor3 = SECONDARY_COLOR
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.AutoButtonColor = false
    toggleButton.Parent = toggleFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = toggleButton
    
    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Name = "Indicator"
    toggleIndicator.Size = UDim2.new(0, 14, 0, 14)
    toggleIndicator.Position = UDim2.new(0, 2, 0.5, -7)
    toggleIndicator.BackgroundColor3 = TEXT_COLOR
    toggleIndicator.BorderSizePixel = 0
    toggleIndicator.Parent = toggleButton
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = toggleIndicator
    
    if tooltip then
        local tooltipButton = Instance.new("TextButton")
        tooltipButton.Size = UDim2.new(0, 16, 0, 16)
        tooltipButton.Position = UDim2.new(1, -60, 0.5, -8)
        tooltipButton.BackgroundColor3 = OUTLINE_COLOR
        tooltipButton.Text = "i"
        tooltipButton.TextColor3 = TEXT_COLOR
        tooltipButton.TextSize = 11
        tooltipButton.Font = Enum.Font.GothamBold
        tooltipButton.Parent = toggleFrame
        
        local tooltipCorner = Instance.new("UICorner")
        tooltipCorner.CornerRadius = UDim.new(1, 0)
        tooltipCorner.Parent = tooltipButton
        
        tooltipButton.MouseEnter:Connect(function()
            Library:ShowTooltip(tooltip, tooltipButton)
        end)
        
        tooltipButton.MouseLeave:Connect(function()
            Library:HideTooltip()
        end)
    end
    
    local state = default
    
    if flag then
        Library.Flags[flag] = state
        Library.FlagCallbacks[flag] = callback
    end
    
    local function toggle(newState)
        state = newState
        
        if state then
            Utility:Tween(toggleButton, {BackgroundColor3 = ACCENT_COLOR}, 0.2)
            Utility:Tween(toggleIndicator, {Position = UDim2.new(1, -16, 0.5, -7)}, 0.2)
        else
            Utility:Tween(toggleButton, {BackgroundColor3 = SECONDARY_COLOR}, 0.2)
            Utility:Tween(toggleIndicator, {Position = UDim2.new(0, 2, 0.5, -7)}, 0.2)
        end
        
        if flag then
            Library.Flags[flag] = state
        end
        
        callback(state)
    end
    
    toggle(default)
    
    toggleButton.MouseButton1Click:Connect(function()
        toggle(not state)
    end)
    
    return {
        SetValue = toggle,
        GetValue = function() return state end
    }
end

-- Dropdown
function Library:AddDropdown(options)
    options = options or {}
    local name = options.Name or "Dropdown"
    local list = options.List or {}
    local default = options.Default
    local flag = options.Flag
    local callback = options.Callback or function() end
    local tooltip = options.Tooltip
    
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = name
    dropdownFrame.Size = UDim2.new(1, -20, 0, 35)
    dropdownFrame.BackgroundColor3 = OUTLINE_COLOR
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Parent = self.Container or self.Content
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = dropdownFrame
    
    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.Name = "Label"
    dropdownLabel.Size = UDim2.new(1, -20, 0, 15)
    dropdownLabel.Position = UDim2.new(0, 10, 0, 3)
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Text = name
    dropdownLabel.TextColor3 = TEXT_COLOR
    dropdownLabel.TextSize = 11
    dropdownLabel.Font = Enum.Font.Gotham
    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    dropdownLabel.Parent = dropdownFrame
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "Button"
    dropdownButton.Size = UDim2.new(1, -20, 0, 20)
    dropdownButton.Position = UDim2.new(0, 10, 0, 18)
    dropdownButton.BackgroundColor3 = SECONDARY_COLOR
    dropdownButton.BorderSizePixel = 0
    dropdownButton.Text = ""
    dropdownButton.AutoButtonColor = false
    dropdownButton.Parent = dropdownFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = dropdownButton
    
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Size = UDim2.new(1, -30, 1, 0)
    selectedLabel.Position = UDim2.new(0, 8, 0, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = default or "Select..."
    selectedLabel.TextColor3 = TEXT_COLOR
    selectedLabel.TextSize = 11
    selectedLabel.Font = Enum.Font.Gotham
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
    selectedLabel.Parent = dropdownButton
    
    local dropdownIcon = Instance.new("TextLabel")
    dropdownIcon.Size = UDim2.new(0, 20, 1, 0)
    dropdownIcon.Position = UDim2.new(1, -20, 0, 0)
    dropdownIcon.BackgroundTransparency = 1
    dropdownIcon.Text = "▼"
    dropdownIcon.TextColor3 = TEXT_COLOR
    dropdownIcon.TextSize = 10
    dropdownIcon.Font = Enum.Font.GothamBold
    dropdownIcon.Parent = dropdownButton
    
    local dropdownList = Instance.new("Frame")
    dropdownList.Name = "List"
    dropdownList.Size = UDim2.new(1, -20, 0, 0)
    dropdownList.Position = UDim2.new(0, 10, 1, 5)
    dropdownList.BackgroundColor3 = SECONDARY_COLOR
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.ZIndex = 10
    dropdownList.ClipsDescendants = true
    dropdownList.Parent = dropdownFrame
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 4)
    listCorner.Parent = dropdownList
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = dropdownList
    
    local selectedValue = default
    local isOpen = false
    
    if flag then
        Library.Flags[flag] = selectedValue
        Library.FlagCallbacks[flag] = callback
    end
    
    local function refresh(newList)
        for _, child in pairs(dropdownList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for _, item in pairs(newList) do
            local itemButton = Instance.new("TextButton")
            itemButton.Size = UDim2.new(1, 0, 0, 25)
            itemButton.BackgroundColor3 = SECONDARY_COLOR
            itemButton.BorderSizePixel = 0
            itemButton.Text = item
            itemButton.TextColor3 = TEXT_COLOR
            itemButton.TextSize = 11
            itemButton.Font = Enum.Font.Gotham
            itemButton.AutoButtonColor = false
            itemButton.Parent = dropdownList
            
            itemButton.MouseEnter:Connect(function()
                Utility:Tween(itemButton, {BackgroundColor3 = OUTLINE_COLOR}, 0.1)
            end)
            
            itemButton.MouseLeave:Connect(function()
                Utility:Tween(itemButton, {BackgroundColor3 = SECONDARY_COLOR}, 0.1)
            end)
            
            itemButton.MouseButton1Click:Connect(function()
                selectedValue = item
                selectedLabel.Text = item
                
                if flag then
                    Library.Flags[flag] = selectedValue
                end
                
                callback(selectedValue)
                
                isOpen = false
                Utility:Tween(dropdownList, {Size = UDim2.new(1, -20, 0, 0)}, 0.2)
                task.wait(0.2)
                dropdownList.Visible = false
                dropdownIcon.Text = "▼"
            end)
        end
        
        local contentSize = math.min(#newList * 25, 150)
        if isOpen then
            dropdownList.Size = UDim2.new(1, -20, 0, contentSize)
        end
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        if isOpen then
            dropdownList.Visible = true
            local contentSize = math.min(#list * 25, 150)
            Utility:Tween(dropdownList, {Size = UDim2.new(1, -20, 0, contentSize)}, 0.2)
            dropdownIcon.Text = "▲"
        else
            Utility:Tween(dropdownList, {Size = UDim2.new(1, -20, 0, 0)}, 0.2)
            task.wait(0.2)
            dropdownList.Visible = false
            dropdownIcon.Text = "▼"
        end
    end)
    
    refresh(list)
    
    if default and flag then
        Library.Flags[flag] = default
        callback(default)
    end
    
    return {
        Refresh = refresh,
        SetValue = function(value)
            selectedValue = value
            selectedLabel.Text = value
            if flag then
                Library.Flags[flag] = value
            end
            callback(value)
        end,
        GetValue = function() return selectedValue end
    }
end

-- Multi Dropdown
function Library:AddMultiDropdown(options)
    options = options or {}
    local name = options.Name or "Multi Dropdown"
    local list = options.List or {}
    local default = options.Default or {}
    local flag = options.Flag
    local callback = options.Callback or function() end
    
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = name
    dropdownFrame.Size = UDim2.new(1, -20, 0, 35)
    dropdownFrame.BackgroundColor3 = OUTLINE_COLOR
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Parent = self.Container or self.Content
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = dropdownFrame
    
    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.Name = "Label"
    dropdownLabel.Size = UDim2.new(1, -20, 0, 15)
    dropdownLabel.Position = UDim2.new(0, 10, 0, 3)
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Text = name
    dropdownLabel.TextColor3 = TEXT_COLOR
    dropdownLabel.TextSize = 11
    dropdownLabel.Font = Enum.Font.Gotham
    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    dropdownLabel.Parent = dropdownFrame
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "Button"
    dropdownButton.Size = UDim2.new(1, -20, 0, 20)
    dropdownButton.Position = UDim2.new(0, 10, 0, 18)
    dropdownButton.BackgroundColor3 = SECONDARY_COLOR
    dropdownButton.BorderSizePixel = 0
    dropdownButton.Text = ""
    dropdownButton.AutoButtonColor = false
    dropdownButton.Parent = dropdownFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = dropdownButton
    
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Size = UDim2.new(1, -30, 1, 0)
    selectedLabel.Position = UDim2.new(0, 8, 0, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = "Select..."
    selectedLabel.TextColor3 = TEXT_COLOR
    selectedLabel.TextSize = 11
    selectedLabel.Font = Enum.Font.Gotham
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
    selectedLabel.Parent = dropdownButton
    
    local dropdownIcon = Instance.new("TextLabel")
    dropdownIcon.Size = UDim2.new(0, 20, 1, 0)
    dropdownIcon.Position = UDim2.new(1, -20, 0, 0)
    dropdownIcon.BackgroundTransparency = 1
    dropdownIcon.Text = "▼"
    dropdownIcon.TextColor3 = TEXT_COLOR
    dropdownIcon.TextSize = 10
    dropdownIcon.Font = Enum.Font.GothamBold
    dropdownIcon.Parent = dropdownButton
    
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Name = "List"
    dropdownList.Size = UDim2.new(1, -20, 0, 0)
    dropdownList.Position = UDim2.new(0, 10, 1, 5)
    dropdownList.BackgroundColor3 = SECONDARY_COLOR
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.ZIndex = 10
    dropdownList.ClipsDescendants = true
    dropdownList.ScrollBarThickness = 4
    dropdownList.ScrollBarImageColor3 = ACCENT_COLOR
    dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
    dropdownList.Parent = dropdownFrame
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 4)
    listCorner.Parent = dropdownList
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = dropdownList
    
    local selectedValues = {}
    for _, v in pairs(default) do
        selectedValues[v] = true
    end
    
    local isOpen = false
    
    if flag then
        Library.Flags[flag] = selectedValues
        Library.FlagCallbacks[flag] = callback
    end
    
    local function updateLabel()
        local selected = {}
        for k, v in pairs(selectedValues) do
            if v then table.insert(selected, k) end
        end
        selectedLabel.Text = #selected > 0 and table.concat(selected, ", ") or "Select..."
    end
    
    local function refresh(newList)
        for _, child in pairs(dropdownList:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        for _, item in pairs(newList) do
            local itemFrame = Instance.new("Frame")
            itemFrame.Size = UDim2.new(1, 0, 0, 25)
            itemFrame.BackgroundColor3 = SECONDARY_COLOR
            itemFrame.BorderSizePixel = 0
            itemFrame.Parent = dropdownList
            
            local itemButton = Instance.new("TextButton")
            itemButton.Size = UDim2.new(1, -30, 1, 0)
            itemButton.BackgroundTransparency = 1
            itemButton.Text = item
            itemButton.TextColor3 = TEXT_COLOR
            itemButton.TextSize = 11
            itemButton.Font = Enum.Font.Gotham
            itemButton.TextXAlignment = Enum.TextXAlignment.Left
            itemButton.AutoButtonColor = false
            itemButton.Parent = itemFrame
            
            local checkbox = Instance.new("Frame")
            checkbox.Size = UDim2.new(0, 14, 0, 14)
            checkbox.Position = UDim2.new(1, -20, 0.5, -7)
            checkbox.BackgroundColor3 = OUTLINE_COLOR
            checkbox.BorderSizePixel = 0
            checkbox.Parent = itemFrame
            
            local checkCorner = Instance.new("UICorner")
            checkCorner.CornerRadius = UDim.new(0, 3)
            checkCorner.Parent = checkbox
            
            local checkmark = Instance.new("TextLabel")
            checkmark.Size = UDim2.new(1, 0, 1, 0)
            checkmark.BackgroundTransparency = 1
            checkmark.Text = "✓"
            checkmark.TextColor3 = ACCENT_COLOR
            checkmark.TextSize = 12
            checkmark.Font = Enum.Font.GothamBold
            checkmark.Visible = selectedValues[item] or false
            checkmark.Parent = checkbox
            
            itemButton.MouseEnter:Connect(function()
                Utility:Tween(itemFrame, {BackgroundColor3 = OUTLINE_COLOR}, 0.1)
            end)
            
            itemButton.MouseLeave:Connect(function()
                Utility:Tween(itemFrame, {BackgroundColor3 = SECONDARY_COLOR}, 0.1)
            end)
            
            itemButton.MouseButton1Click:Connect(function()
                selectedValues[item] = not selectedValues[item]
                checkmark.Visible = selectedValues[item]
                
                if flag then
                    Library.Flags[flag] = selectedValues
                end
                
                updateLabel()
                callback(selectedValues)
            end)
        end
        
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            dropdownList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
        end)
        
        local contentSize = math.min(listLayout.AbsoluteContentSize.Y, 150)
        if isOpen then
            dropdownList.Size = UDim2.new(1, -20, 0, contentSize)
        end
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        if isOpen then
            dropdownList.Visible = true
            local contentSize = math.min(listLayout.AbsoluteContentSize.Y, 150)
            Utility:Tween(dropdownList, {Size = UDim2.new(1, -20, 0, contentSize)}, 0.2)
            dropdownIcon.Text = "▲"
        else
            Utility:Tween(dropdownList, {Size = UDim2.new(1, -20, 0, 0)}, 0.2)
            task.wait(0.2)
            dropdownList.Visible = false
            dropdownIcon.Text = "▼"
        end
    end)
    
    refresh(list)
    updateLabel()
    
    return {
        Refresh = refresh,
        SetValue = function(values)
            selectedValues = values
            updateLabel()
            if flag then
                Library.Flags[flag] = values
            end
            callback(values)
        end,
        GetValue = function() return selectedValues end
    }
end

-- Keybind
function Library:AddKeybind(options)
    options = options or {}
    local name = options.Name or "Keybind"
    local default = options.Default
    local mode = options.Mode or "Toggle" -- Toggle or Hold
    local flag = options.Flag
    local callback = options.Callback or function() end
    
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Name = name
    keybindFrame.Size = UDim2.new(1, -20, 0, 30)
    keybindFrame.BackgroundColor3 = OUTLINE_COLOR
    keybindFrame.BorderSizePixel = 0
    keybindFrame.Parent = self.Container or self.Content
    
    local keybindCorner = Instance.new("UICorner")
    keybindCorner.CornerRadius = UDim.new(0, 6)
    keybindCorner.Parent = keybindFrame
    
    local keybindLabel = Instance.new("TextLabel")
    keybindLabel.Name = "Label"
    keybindLabel.Size = UDim2.new(1, -100, 1, 0)
    keybindLabel.Position = UDim2.new(0, 10, 0, 0)
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.Text = name
    keybindLabel.TextColor3 = TEXT_COLOR
    keybindLabel.TextSize = 12
    keybindLabel.Font = Enum.Font.Gotham
    keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    keybindLabel.Parent = keybindFrame
    
    local keybindButton = Instance.new("TextButton")
    keybindButton.Name = "Button"
    keybindButton.Size = UDim2.new(0, 80, 0, 22)
    keybindButton.Position = UDim2.new(1, -85, 0.5, -11)
    keybindButton.BackgroundColor3 = SECONDARY_COLOR
    keybindButton.BorderSizePixel = 0
    keybindButton.Text = default and default.Name or "None"
    keybindButton.TextColor3 = TEXT_COLOR
    keybindButton.TextSize = 11
    keybindButton.Font = Enum.Font.Gotham
    keybindButton.AutoButtonColor = false
    keybindButton.Parent = keybindFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = keybindButton
    
    local currentKey = default
    local listening = false
    local active = false
    
    if flag then
        Library.Flags[flag] = {Key = currentKey, Active = active}
        Library.FlagCallbacks[flag] = callback
    end
    
    keybindButton.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keybindButton.Text = "..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                keybindButton.Text = input.KeyCode.Name
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.MouseButton2 then
                currentKey = input.UserInputType
                keybindButton.Text = input.UserInputType.Name:gsub("MouseButton", "Mouse")
            end
            
            listening = false
            connection:Disconnect()
            
            if flag then
                Library.Flags[flag].Key = currentKey
            end
        end)
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or listening or not currentKey then return end
        
        local inputMatch = false
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
            inputMatch = true
        elseif input.UserInputType == currentKey then
            inputMatch = true
        end
        
        if inputMatch then
            if mode == "Toggle" then
                active = not active
                if flag then
                    Library.Flags[flag].Active = active
                end
                callback(active, currentKey)
            else
                active = true
                if flag then
                    Library.Flags[flag].Active = true
                end
                callback(true, currentKey)
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if mode == "Hold" and currentKey then
            local inputMatch = false
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                inputMatch = true
            elseif input.UserInputType == currentKey then
                inputMatch = true
            end
            
            if inputMatch then
                active = false
                if flag then
                    Library.Flags[flag].Active = false
                end
                callback(false, currentKey)
            end
        end
    end)
    
    return {
        SetKey = function(key)
            currentKey = key
            keybindButton.Text = key and key.Name or "None"
            if flag then
                Library.Flags[flag].Key = key
            end
        end,
        GetKey = function() return currentKey end,
        GetActive = function() return active end
    }
end

-- Tooltip System
Library.TooltipFrame = nil

function Library:ShowTooltip(text, anchor)
    if self.TooltipFrame then
        self.TooltipFrame:Destroy()
    end
    
    local tooltip = Instance.new("Frame")
    tooltip.Name = "Tooltip"
    tooltip.Size = UDim2.new(0, 200, 0, 0)
    tooltip.BackgroundColor3 = SECONDARY_COLOR
    tooltip.BorderSizePixel = 0
    tooltip.ZIndex = 100
    tooltip.Parent = self.ScreenGui or CoreGui:FindFirstChild("UnicoreLib")
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tooltip
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, -10)
    textLabel.Position = UDim2.new(0, 5, 0, 5)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = TEXT_COLOR
    textLabel.TextSize = 11
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.Parent = tooltip
    
    local textSize = game:GetService("TextService"):GetTextSize(
        text, 11, Enum.Font.Gotham, Vector2.new(190, math.huge)
    )
    
    tooltip.Size = UDim2.new(0, 200, 0, textSize.Y + 10)
    
    local anchorPos = anchor.AbsolutePosition
    tooltip.Position = UDim2.new(0, anchorPos.X + anchor.AbsoluteSize.X + 5, 0, anchorPos.Y)
    
    self.TooltipFrame = tooltip
end

function Library:HideTooltip()
    if self.TooltipFrame then
        self.TooltipFrame:Destroy()
        self.TooltipFrame = nil
    end
end

-- Config Tab (Default, cannot be modified)
function Library:AddConfigTab()
    local configTab = self:AddTab("Config", "rbxasset://textures/ui/Settings/MenuBarIcons/SettingsTab.png")
    
    local saveSection = configTab:AddSection("Save Configuration")
    
    local configName = ""
    local configNameBox = Instance.new("Frame")
    configNameBox.Size = UDim2.new(1, -20, 0, 35)
    configNameBox.BackgroundColor3 = OUTLINE_COLOR
    configNameBox.BorderSizePixel = 0
    configNameBox.Parent = saveSection.Container
    
    local nameCorner = Instance.new("UICorner")
    nameCorner.CornerRadius = UDim.new(0, 6)
    nameCorner.Parent = configNameBox
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -20, 0, 15)
    nameLabel.Position = UDim2.new(0, 10, 0, 3)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Config Name"
    nameLabel.TextColor3 = TEXT_COLOR
    nameLabel.TextSize = 11
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = configNameBox
    
    local nameInput = Instance.new("TextBox")
    nameInput.Size = UDim2.new(1, -20, 0, 20)
    nameInput.Position = UDim2.new(0, 10, 0, 18)
    nameInput.BackgroundColor3 = SECONDARY_COLOR
    nameInput.BorderSizePixel = 0
    nameInput.Text = ""
    nameInput.PlaceholderText = "Enter config name..."
    nameInput.TextColor3 = TEXT_COLOR
    nameInput.PlaceholderColor3 = Color3.fromRGB(100, 110, 130)
    nameInput.TextSize = 11
    nameInput.Font = Enum.Font.Gotham
    nameInput.ClearTextOnFocus = false
    nameInput.Parent = configNameBox
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = nameInput
    
    nameInput:GetPropertyChangedSignal("Text"):Connect(function()
        configName = nameInput.Text
    end)
    
    local saveButton = Instance.new("TextButton")
    saveButton.Size = UDim2.new(1, -20, 0, 35)
    saveButton.BackgroundColor3 = ACCENT_COLOR
    saveButton.BorderSizePixel = 0
    saveButton.Text = "Save Config"
    saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveButton.TextSize = 13
    saveButton.Font = Enum.Font.GothamBold
    saveButton.AutoButtonColor = false
    saveButton.Parent = saveSection.Container
    
    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 6)
    saveCorner.Parent = saveButton
    
    saveButton.MouseButton1Click:Connect(function()
        if configName ~= "" then
            Library:SaveConfig(configName)
        else
            Library:Notify("Error", "Please enter a config name!", 3)
        end
    end)
    
    local loadSection = configTab:AddSection("Load Configuration")
    
    local loadButton = Instance.new("TextButton")
    loadButton.Size = UDim2.new(1, -20, 0, 35)
    loadButton.BackgroundColor3 = ACCENT_COLOR
    loadButton.BorderSizePixel = 0
    loadButton.Text = "Load Config"
    loadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadButton.TextSize = 13
    loadButton.Font = Enum.Font.GothamBold
    loadButton.AutoButtonColor = false
    loadButton.Parent = loadSection.Container
    
    local loadCorner = Instance.new("UICorner")
    loadCorner.CornerRadius = UDim.new(0, 6)
    loadCorner.Parent = loadButton
    
    loadButton.MouseButton1Click:Connect(function()
        if configName ~= "" then
            Library:LoadConfig(configName)
        else
            Library:Notify("Error", "Please enter a config name!", 3)
        end
    end)
    
    return configTab
end

return Library
