local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local ACCENT = Color3.fromRGB(120, 120, 255)
local BG1 = Color3.fromRGB(15, 15, 15)
local BG2 = Color3.fromRGB(20, 20, 20)
local BG3 = Color3.fromRGB(25, 25, 25)
local TEXT = Color3.fromRGB(240, 240, 240)
local TEXT_DIM = Color3.fromRGB(160, 160, 160)
local BORDER = Color3.fromRGB(40, 40, 40)

local Util = {}

function Util:Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

function Util:Drag(frame, handle)
    local dragging, dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
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
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Util:Resize(frame, glowIndicator)
    local resizing, startPos, startSize
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 25, 0, 25)
    handle.Position = UDim2.new(1, -25, 1, -25)
    handle.BackgroundTransparency = 1
    handle.Parent = frame
    
    handle.MouseEnter:Connect(function()
        if glowIndicator then
            Util:Tween(glowIndicator, {ImageTransparency = 0.2}, 0.2)
        end
    end)
    
    handle.MouseLeave:Connect(function()
        if glowIndicator then
            Util:Tween(glowIndicator, {ImageTransparency = 0.8}, 0.2)
        end
    end)
    
    handle.InputBegan:Connect(function(input)
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
            frame.Size = UDim2.new(0, math.max(650, startSize.X.Offset + delta.X), 0, math.max(500, startSize.Y.Offset + delta.Y))
        end
    end)
end

function Util:AddStroke(obj, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or BORDER
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = obj
    return stroke
end

function Util:AddCorner(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = obj
    return corner
end

function Util:AddShadow(obj)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = obj.ZIndex - 1
    shadow.Parent = obj
    return shadow
end

Library.Flags = {}
Library.Callbacks = {}
Library.ConfigFile = ""

function Library:Notify(title, text, duration)
    local gui = Instance.new("ScreenGui")
    gui.Name = "Notification"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 0)
    frame.Position = UDim2.new(1, -330, 1, 10)
    frame.BackgroundColor3 = BG2
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = gui
    
    Util:AddCorner(frame, 8)
    Util:AddStroke(frame, ACCENT, 1.5)
    
    local innerFrame = Instance.new("Frame")
    innerFrame.Size = UDim2.new(1, -2, 1, -2)
    innerFrame.Position = UDim2.new(0, 1, 0, 1)
    innerFrame.BackgroundColor3 = BG1
    innerFrame.BorderSizePixel = 0
    innerFrame.Parent = frame
    
    Util:AddCorner(innerFrame, 7)
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = ACCENT
    accent.BorderSizePixel = 0
    accent.Parent = innerFrame
    
    local accentGradient = Instance.new("UIGradient")
    accentGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, ACCENT),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 80, 200))
    }
    accentGradient.Rotation = 90
    accentGradient.Parent = accent
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -25, 0, 20)
    titleLabel.Position = UDim2.new(0, 15, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = TEXT
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = innerFrame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -25, 0, 0)
    textLabel.Position = UDim2.new(0, 15, 0, 35)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = TEXT_DIM
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.AutomaticSize = Enum.AutomaticSize.Y
    textLabel.Parent = innerFrame
    
    task.wait()
    local textHeight = textLabel.AbsoluteSize.Y
    local totalHeight = 55 + textHeight
    
    Util:Tween(frame, {Size = UDim2.new(0, 320, 0, totalHeight), Position = UDim2.new(1, -330, 1, -totalHeight - 10)}, 0.4)
    
    task.delay(duration or 3, function()
        Util:Tween(frame, {Position = UDim2.new(1, -330, 1, 10)}, 0.3)
        task.wait(0.3)
        gui:Destroy()
    end)
end

function Library:CreateWatermark(options)
    options = options or {
        ShowFPS = false,
        ShowPing = false,
        ShowTime = false,
        ShowUser = false
    }
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "Watermark"
    gui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 28)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = BG2
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = gui
    
    Util:AddCorner(frame, 6)
    Util:AddStroke(frame, BORDER, 1.5)
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.BackgroundColor3 = ACCENT
    accent.BorderSizePixel = 0
    accent.Parent = frame
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -12, 1, -2)
    container.Position = UDim2.new(0, 6, 0, 2)
    container.BackgroundTransparency = 1
    container.Parent = frame
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 10)
    layout.Parent = container
    
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(0, 60, 1, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: 60"
    fpsLabel.TextColor3 = TEXT
    fpsLabel.TextSize = 12
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Visible = options.ShowFPS or false
    fpsLabel.Parent = container
    
    local pingLabel = Instance.new("TextLabel")
    pingLabel.Size = UDim2.new(0, 85, 1, 0)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "PING: 0ms"
    pingLabel.TextColor3 = TEXT
    pingLabel.TextSize = 12
    pingLabel.Font = Enum.Font.GothamBold
    pingLabel.TextXAlignment = Enum.TextXAlignment.Left
    pingLabel.Visible = options.ShowPing or false
    pingLabel.Parent = container
    
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0, 70, 1, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "00:00:00"
    timeLabel.TextColor3 = TEXT
    timeLabel.TextSize = 12
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.Visible = options.ShowTime or false
    timeLabel.Parent = container
    
    local userLabel = Instance.new("TextLabel")
    userLabel.Size = UDim2.new(0, 100, 1, 0)
    userLabel.BackgroundTransparency = 1
    userLabel.Text = Players.LocalPlayer.Name
    userLabel.TextColor3 = TEXT
    userLabel.TextSize = 12
    userLabel.Font = Enum.Font.GothamBold
    userLabel.TextXAlignment = Enum.TextXAlignment.Left
    userLabel.Visible = options.ShowUser or false
    userLabel.Parent = container
    
    Util:Drag(frame, frame)
    
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
        
        if options.ShowFPS then
            fpsLabel.Text = "FPS: " .. fps
        end
        
        if options.ShowPing then 
            local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            pingLabel.Text = "PING: " .. ping .. "ms"
        end
        
        if options.ShowTime then
            timeLabel.Text = os.date("%H:%M:%S")
        end
    end)
    
    Library.WatermarkFrame = frame
    Library.WatermarkOptions = options
    
    local function updateVisibility()
        local anyVisible = options.ShowFPS or options.ShowPing or options.ShowTime or options.ShowUser
        frame.Visible = anyVisible
    end
    
    updateVisibility()
    
    return {
        SetVisible = function(v) frame.Visible = v end,
        SetOptions = function(o)
            options = o
            fpsLabel.Visible = o.ShowFPS or false
            pingLabel.Visible = o.ShowPing or false
            timeLabel.Visible = o.ShowTime or false
            userLabel.Visible = o.ShowUser or false
            updateVisibility()
        end,
        GetOptions = function() return options end
    }
end

function Library:CreateKeybindList()
    local gui = Instance.new("ScreenGui")
    gui.Name = "KeybindList"
    gui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 35)
    frame.Position = UDim2.new(1, -210, 0, 50)
    frame.BackgroundColor3 = BG2
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    Util:AddCorner(frame, 6)
    Util:AddStroke(frame, BORDER, 1.5)
    Util:Drag(frame, frame)
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.BackgroundColor3 = ACCENT
    accent.BorderSizePixel = 0
    accent.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "Keybinds"
    title.TextColor3 = TEXT
    title.TextSize = 13
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 3)
    list.Parent = frame
    
    return {Frame = frame, Keybinds = {}}
end

function Library:Create(options)
    options = options or {}
    local name = options.Name or "Club"
    
    if options.AccentColor then
        ACCENT = options.AccentColor
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "ClubUI"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 800, 0, 550)
    main.Position = UDim2.new(0.5, -400, 0.5, -275)
    main.BackgroundColor3 = BG1
    main.BorderSizePixel = 0
    main.ClipsDescendants = false
    main.Parent = gui
    
    Util:AddCorner(main, 8)
    Util:AddStroke(main, BORDER, 1.5)
    
    local shadow = Util:AddShadow(main)
    
    local resizeGlow = Instance.new("ImageLabel")
    resizeGlow.Name = "ResizeGlow"
    resizeGlow.Size = UDim2.new(0, 50, 0, 50)
    resizeGlow.Position = UDim2.new(1, -25, 1, -25)
    resizeGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    resizeGlow.BackgroundTransparency = 1
    resizeGlow.Image = "rbxassetid://1316045217"
    resizeGlow.ImageColor3 = ACCENT
    resizeGlow.ImageTransparency = 0.8
    resizeGlow.ScaleType = Enum.ScaleType.Slice
    resizeGlow.SliceCenter = Rect.new(10, 10, 118, 118)
    resizeGlow.ZIndex = 5
    resizeGlow.Parent = main
    
    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, 0, 0, 45)
    topbar.BackgroundColor3 = BG2
    topbar.BorderSizePixel = 0
    topbar.Parent = main
    
    Util:AddCorner(topbar, 8)
    
    local topCover = Instance.new("Frame")
    topCover.Size = UDim2.new(1, 0, 0, 10)
    topCover.Position = UDim2.new(0, 0, 1, -10)
    topCover.BackgroundColor3 = BG2
    topCover.BorderSizePixel = 0
    topCover.Parent = topbar
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.Position = UDim2.new(0, 0, 1, 0)
    accent.BackgroundColor3 = ACCENT
    accent.BorderSizePixel = 0
    accent.Parent = topbar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 18, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = TEXT
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topbar
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, ACCENT),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 200, 255)),
        ColorSequenceKeypoint.new(1, ACCENT)
    }
    gradient.Parent = title
    
    task.spawn(function()
        while true do
            for i = 0, 360, 2 do
                gradient.Rotation = i
                task.wait(0.03)
            end
        end
    end)
    
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 160, 1, -45)
    sidebar.Position = UDim2.new(0, 0, 0, 45)
    sidebar.BackgroundColor3 = BG2
    sidebar.BorderSizePixel = 0
    sidebar.ClipsDescendants = false
    sidebar.Parent = main
    
    local sideStroke = Util:AddStroke(sidebar, BORDER)
    sideStroke.Transparency = 0.5
    
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Size = UDim2.new(1, -5, 1, -10)
    tabContainer.Position = UDim2.new(0, 5, 0, 5)
    tabContainer.BackgroundTransparency = 1
    tabContainer.BorderSizePixel = 0
    tabContainer.ScrollBarThickness = 0
    tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContainer.Parent = sidebar
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabContainer
    
    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContainer.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 10)
    end)
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -165, 1, -50)
    content.Position = UDim2.new(0, 165, 0, 50)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    Util:Drag(main, topbar)
    Util:Resize(main, resizeGlow)
    
    Library.Gui = gui
    Library.Main = main
    Library.Sidebar = tabContainer
    Library.Content = content
    Library.Tabs = {}
    Library.CurrentTab = nil
    
    return setmetatable({
        Gui = gui,
        Main = main,
        Name = name
    }, Library)
end

function Library:AddTab(name, icon)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 38)
    button.BackgroundColor3 = BG1
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = self.Sidebar
    
    Util:AddCorner(button, 6)
    Util:AddStroke(button, Color3.fromRGB(30, 30, 30), 1)
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 1, -10)
    indicator.Position = UDim2.new(0, 5, 0, 5)
    indicator.BackgroundColor3 = ACCENT
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.Parent = button
    
    Util:AddCorner(indicator, 2)
    
    local iconLabel = Instance.new("ImageLabel")
    iconLabel.Size = UDim2.new(0, 20, 0, 20)
    iconLabel.Position = UDim2.new(0, 14, 0.5, -10)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Image = icon or ""
    iconLabel.ImageColor3 = TEXT_DIM
    iconLabel.Parent = button
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 42, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TEXT_DIM
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button
    
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -20, 1, -20)
    container.Position = UDim2.new(0, 10, 0, 10)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 4
    container.ScrollBarImageColor3 = ACCENT
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.Visible = false
    container.Parent = self.Content
    
    local leftColumn = Instance.new("Frame")
    leftColumn.Size = UDim2.new(0.5, -5, 1, 0)
    leftColumn.Position = UDim2.new(0, 0, 0, 0)
    leftColumn.BackgroundTransparency = 1
    leftColumn.Parent = container
    
    local leftLayout = Instance.new("UIListLayout")
    leftLayout.Padding = UDim.new(0, 10)
    leftLayout.Parent = leftColumn
    
    local rightColumn = Instance.new("Frame")
    rightColumn.Size = UDim2.new(0.5, -5, 1, 0)
    rightColumn.Position = UDim2.new(0.5, 5, 0, 0)
    rightColumn.BackgroundTransparency = 1
    rightColumn.Parent = container
    
    local rightLayout = Instance.new("UIListLayout")
    rightLayout.Padding = UDim.new(0, 10)
    rightLayout.Parent = rightColumn
    
    local function updateCanvasSize()
        local leftHeight = leftLayout.AbsoluteContentSize.Y
        local rightHeight = rightLayout.AbsoluteContentSize.Y
        local maxHeight = math.max(leftHeight, rightHeight)
        container.CanvasSize = UDim2.new(0, 0, 0, maxHeight + 20)
    end
    
    leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
    rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
    
    button.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Tabs) do
            tab.Button.BackgroundColor3 = BG1
            tab.Indicator.Visible = false
            tab.Icon.ImageColor3 = TEXT_DIM
            tab.Label.TextColor3 = TEXT_DIM
            tab.Container.Visible = false
            tab.Stroke.Color = Color3.fromRGB(30, 30, 30)
        end
        
        button.BackgroundColor3 = BG2
        indicator.Visible = true
        iconLabel.ImageColor3 = ACCENT
        label.TextColor3 = TEXT
        container.Visible = true
        button.UIStroke.Color = ACCENT
        self.CurrentTab = name
    end)
    
    button.MouseEnter:Connect(function()
        if self.CurrentTab ~= name then
            Util:Tween(button, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}, 0.1)
            Util:Tween(label, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.1)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if self.CurrentTab ~= name then
            Util:Tween(button, {BackgroundColor3 = BG1}, 0.1)
            Util:Tween(label, {TextColor3 = TEXT_DIM}, 0.1)
        end
    end)
    
    local tab = {
        Name = name,
        Button = button,
        Indicator = indicator,
        Icon = iconLabel,
        Label = label,
        Container = container,
        LeftColumn = leftColumn,
        RightColumn = rightColumn,
        CurrentColumn = "left",
        Stroke = button.UIStroke
    }
    
    self.Tabs[name] = tab
    
    if not self.CurrentTab then
        button.BackgroundColor3 = BG2
        indicator.Visible = true
        iconLabel.ImageColor3 = ACCENT
        label.TextColor3 = TEXT
        container.Visible = true
        button.UIStroke.Color = ACCENT
        self.CurrentTab = name
    end
    
    return setmetatable(tab, {__index = self})
end

function Library:AddSection(name, side)
    local targetColumn
    
    if side then
        targetColumn = side == "left" and self.LeftColumn or self.RightColumn
    else
        if self.CurrentColumn == "left" then
            targetColumn = self.LeftColumn
            self.CurrentColumn = "right"
        else
            targetColumn = self.RightColumn
            self.CurrentColumn = "left"
        end
    end
    
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 35)
    section.BackgroundColor3 = BG2
    section.BorderSizePixel = 0
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.Parent = targetColumn
    
    Util:AddCorner(section, 6)
    local sectionStroke = Util:AddStroke(section, BORDER)
    
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -20, 0, 28)
    header.Position = UDim2.new(0, 12, 0, 7)
    header.BackgroundTransparency = 1
    header.Text = name
    header.TextColor3 = TEXT
    header.TextSize = 14
    header.Font = Enum.Font.GothamBold
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = section
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.Position = UDim2.new(0, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = section
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = container
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = container
    
    section.MouseEnter:Connect(function()
        Util:Tween(sectionStroke, {Color = ACCENT}, 0.15)
    end)
    
    section.MouseLeave:Connect(function()
        Util:Tween(sectionStroke, {Color = BORDER}, 0.15)
    end)
    
    return setmetatable({
        Frame = section,
        Container = container,
        Stroke = sectionStroke
    }, {__index = self})
end

function Library:AddLabel(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = TEXT_DIM
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.Parent = self.Container
    
    return {
        SetText = function(t)
            label.Text = t
        end
    }
end

function Library:AddButton(options)
    options = options or {}
    local name = options.Name or "Button"
    local callback = options.Callback or function() end
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 36)
    button.BackgroundColor3 = BG3
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = TEXT
    button.TextSize = 13
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = self.Container
    
    Util:AddCorner(button, 6)
    
    button.MouseEnter:Connect(function()
        Util:Tween(button, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, 0.1)
    end)
    
    button.MouseLeave:Connect(function()
        Util:Tween(button, {BackgroundColor3 = BG3}, 0.1)
    end)
    
    button.MouseButton1Click:Connect(function()
        callback()
    end)
    
    return button
end

function Library:AddInput(options)
    options = options or {}
    local name = options.Name or "Input"
    local default = options.Default or ""
    local placeholder = options.Placeholder or "Enter text..."
    local flag = options.Flag
    local callback = options.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 54)
    frame.BackgroundColor3 = BG3
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    
    Util:AddCorner(frame, 5)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TEXT_DIM
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -24, 0, 26)
    input.Position = UDim2.new(0, 12, 0, 24)
    input.BackgroundColor3 = BG1
    input.BorderSizePixel = 0
    input.Text = default
    input.PlaceholderText = placeholder
    input.TextColor3 = TEXT
    input.PlaceholderColor3 = TEXT_DIM
    input.TextSize = 11
    input.Font = Enum.Font.Gotham
    input.ClearTextOnFocus = false
    input.Parent = frame
    
    Util:AddCorner(input, 4)
    Util:AddStroke(input, BORDER)
    
    if flag then
        Library.Flags[flag] = default
        Library.Callbacks[flag] = callback
    end
    
    input:GetPropertyChangedSignal("Text"):Connect(function()
        if flag then
            Library.Flags[flag] = input.Text
        end
        callback(input.Text)
    end)
    
    return {
        SetValue = function(v)
            input.Text = v
            if flag then Library.Flags[flag] = v end
            callback(v)
        end,
        GetValue = function() return input.Text end
    }
end

function Library:CreateContextMenu(element, options)
    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 120, 0, 0)
    menu.BackgroundColor3 = BG2
    menu.BorderSizePixel = 0
    menu.Visible = false
    menu.ZIndex = 100
    menu.Parent = self.Gui
    
    Util:AddCorner(menu, 5)
    Util:AddStroke(menu, BORDER)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.Parent = menu
    
    for _, option in pairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 24)
        optBtn.BackgroundColor3 = BG2
        optBtn.BorderSizePixel = 0
        optBtn.Text = option.Name
        optBtn.TextColor3 = TEXT
        optBtn.TextSize = 11
        optBtn.Font = Enum.Font.Gotham
        optBtn.AutoButtonColor = false
        optBtn.Parent = menu
        
        optBtn.MouseEnter:Connect(function()
            Util:Tween(optBtn, {BackgroundColor3 = BG3}, 0.1)
        end)
        
        optBtn.MouseLeave:Connect(function()
            Util:Tween(optBtn, {BackgroundColor3 = BG2}, 0.1)
        end)
        
        optBtn.MouseButton1Click:Connect(function()
            option.Callback()
            menu.Visible = false
        end)
    end
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        menu.Size = UDim2.new(0, 120, 0, layout.AbsoluteContentSize.Y + 4)
    end)
    
    element.MouseButton2Click:Connect(function()
        local mouse = UserInputService:GetMouseLocation()
        menu.Position = UDim2.new(0, mouse.X, 0, mouse.Y - 36)
        menu.Visible = not menu.Visible
    end)
    
    return menu
end

function Library:AddColorPicker(options)
    options = options or {}
    local name = options.Name or "Color"
    local default = options.Default or Color3.fromRGB(255, 255, 255)
    local flag = options.Flag
    local callback = options.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundColor3 = BG3
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    
    Util:AddCorner(frame, 5)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -55, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TEXT
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local colorDisplay = Instance.new("TextButton")
    colorDisplay.Size = UDim2.new(0, 38, 0, 20)
    colorDisplay.Position = UDim2.new(1, -44, 0.5, -10)
    colorDisplay.BackgroundColor3 = default
    colorDisplay.BorderSizePixel = 0
    colorDisplay.Text = ""
    colorDisplay.AutoButtonColor = false
    colorDisplay.ZIndex = 5
    colorDisplay.Parent = frame
    
    Util:AddCorner(colorDisplay, 5)
    Util:AddStroke(colorDisplay, BORDER)
    
    local pickerOpen = false
    local currentColor = default
    
    local picker = Instance.new("Frame")
    picker.Size = UDim2.new(0, 200, 0, 180)
    picker.Position = UDim2.new(1, 10, 0, 0)
    picker.BackgroundColor3 = BG2
    picker.BorderSizePixel = 0
    picker.Visible = false
    picker.ZIndex = 200
    picker.Parent = frame
    
    Util:AddCorner(picker, 6)
    Util:AddStroke(picker, ACCENT, 1.5)
    
    local saturationFrame = Instance.new("Frame")
    saturationFrame.Size = UDim2.new(1, -20, 0, 120)
    saturationFrame.Position = UDim2.new(0, 10, 0, 10)
    saturationFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    saturationFrame.BorderSizePixel = 0
    saturationFrame.ZIndex = 201
    saturationFrame.Parent = picker
    
    Util:AddCorner(saturationFrame, 4)
    
    local saturationWhite = Instance.new("ImageLabel")
    saturationWhite.Size = UDim2.new(1, 0, 1, 0)
    saturationWhite.BackgroundTransparency = 1
    saturationWhite.Image = "rbxassetid://4155801252"
    saturationWhite.ImageColor3 = Color3.fromRGB(255, 255, 255)
    saturationWhite.ZIndex = 202
    saturationWhite.Parent = saturationFrame
    
    Util:AddCorner(saturationWhite, 4)
    
    local saturationBlack = Instance.new("ImageLabel")
    saturationBlack.Size = UDim2.new(1, 0, 1, 0)
    saturationBlack.BackgroundTransparency = 1
    saturationBlack.Image = "rbxassetid://4155801252"
    saturationBlack.ImageColor3 = Color3.fromRGB(0, 0, 0)
    saturationBlack.Rotation = 90
    saturationBlack.ZIndex = 203
    saturationBlack.Parent = saturationFrame
    
    Util:AddCorner(saturationBlack, 4)
    
    local saturationPicker = Instance.new("Frame")
    saturationPicker.Size = UDim2.new(0, 6, 0, 6)
    saturationPicker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    saturationPicker.BorderSizePixel = 0
    saturationPicker.ZIndex = 204
    saturationPicker.Parent = saturationFrame
    
    Util:AddCorner(saturationPicker, 3)
    Util:AddStroke(saturationPicker, Color3.fromRGB(0, 0, 0), 2)
    
    local hueFrame = Instance.new("Frame")
    hueFrame.Size = UDim2.new(1, -20, 0, 15)
    hueFrame.Position = UDim2.new(0, 10, 0, 140)
    hueFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueFrame.BorderSizePixel = 0
    hueFrame.ZIndex = 201
    hueFrame.Parent = picker
    
    Util:AddCorner(hueFrame, 4)
    
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    }
    hueGradient.Parent = hueFrame
    
    local huePicker = Instance.new("Frame")
    huePicker.Size = UDim2.new(0, 4, 1, 0)
    huePicker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    huePicker.BorderSizePixel = 0
    huePicker.ZIndex = 202
    huePicker.Parent = hueFrame
    
    Util:AddStroke(huePicker, Color3.fromRGB(0, 0, 0), 2)
    
    local hexFrame = Instance.new("Frame")
    hexFrame.Size = UDim2.new(1, -20, 0, 20)
    hexFrame.Position = UDim2.new(0, 10, 0, 160)
    hexFrame.BackgroundColor3 = BG1
    hexFrame.BorderSizePixel = 0
    hexFrame.ZIndex = 201
    hexFrame.Parent = picker
    
    Util:AddCorner(hexFrame, 4)
    Util:AddStroke(hexFrame, BORDER)
    
    local hexInput = Instance.new("TextBox")
    hexInput.Size = UDim2.new(1, -10, 1, 0)
    hexInput.Position = UDim2.new(0, 5, 0, 0)
    hexInput.BackgroundTransparency = 1
    hexInput.Text = "#FFFFFF"
    hexInput.TextColor3 = TEXT
    hexInput.TextSize = 11
    hexInput.Font = Enum.Font.GothamMedium
    hexInput.ZIndex = 202
    hexInput.Parent = hexFrame
    
    local h, s, v = 0, 0, 1
    
    local function rgbToHsv(color)
        local r, g, b = color.R, color.G, color.B
        local max, min = math.max(r, g, b), math.min(r, g, b)
        local delta = max - min
        
        local hue = 0
        if delta > 0 then
            if max == r then
                hue = ((g - b) / delta) % 6
            elseif max == g then
                hue = (b - r) / delta + 2
            else
                hue = (r - g) / delta + 4
            end
            hue = hue / 6
        end
        
        local sat = max == 0 and 0 or delta / max
        local val = max
        
        return hue, sat, val
    end
    
    local function hsvToRgb(hue, sat, val)
        local c = val * sat
        local x = c * (1 - math.abs((hue * 6) % 2 - 1))
        local m = val - c
        
        local r, g, b
        if hue < 1/6 then
            r, g, b = c, x, 0
        elseif hue < 2/6 then
            r, g, b = x, c, 0
        elseif hue < 3/6 then
            r, g, b = 0, c, x
        elseif hue < 4/6 then
            r, g, b = 0, x, c
        elseif hue < 5/6 then
            r, g, b = x, 0, c
        else
            r, g, b = c, 0, x
        end
        
        return Color3.fromRGB(
            math.floor((r + m) * 255),
            math.floor((g + m) * 255),
            math.floor((b + m) * 255)
        )
    end
    
    local function updateColor()
        currentColor = hsvToRgb(h, s, v)
        colorDisplay.BackgroundColor3 = currentColor
        saturationFrame.BackgroundColor3 = hsvToRgb(h, 1, 1)
        hexInput.Text = string.format("#%02X%02X%02X", 
            math.floor(currentColor.R * 255),
            math.floor(currentColor.G * 255),
            math.floor(currentColor.B * 255)
        )
        
        if flag then
            Library.Flags[flag] = currentColor
        end
        callback(currentColor)
    end
    
    h, s, v = rgbToHsv(default)
    saturationPicker.Position = UDim2.new(s, -3, 1 - v, -3)
    huePicker.Position = UDim2.new(h, -2, 0, 0)
    updateColor()
    
    local satDragging = false
    local hueDragging = false
    
    saturationFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            satDragging = true
        end
    end)
    
    hueFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            satDragging = false
            hueDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if satDragging then
                local pos = input.Position
                local framePos = saturationFrame.AbsolutePosition
                local frameSize = saturationFrame.AbsoluteSize
                
                local x = math.clamp((pos.X - framePos.X) / frameSize.X, 0, 1)
                local y = math.clamp((pos.Y - framePos.Y) / frameSize.Y, 0, 1)
                
                s = x
                v = 1 - y
                
                saturationPicker.Position = UDim2.new(x, -3, y, -3)
                updateColor()
            elseif hueDragging then
                local pos = input.Position
                local framePos = hueFrame.AbsolutePosition
                local frameSize = hueFrame.AbsoluteSize
                
                local x = math.clamp((pos.X - framePos.X) / frameSize.X, 0, 1)
                h = x
                
                huePicker.Position = UDim2.new(x, -2, 0, 0)
                updateColor()
            end
        end
    end)
    
    hexInput.FocusLost:Connect(function()
        local hex = hexInput.Text:gsub("#", "")
        if #hex == 6 then
            local r = tonumber(hex:sub(1, 2), 16)
            local g = tonumber(hex:sub(3, 4), 16)
            local b = tonumber(hex:sub(5, 6), 16)
            if r and g and b then
                currentColor = Color3.fromRGB(r, g, b)
                h, s, v = rgbToHsv(currentColor)
                saturationPicker.Position = UDim2.new(s, -3, 1 - v, -3)
                huePicker.Position = UDim2.new(h, -2, 0, 0)
                updateColor()
            end
        end
    end)
    
    colorDisplay.MouseButton1Click:Connect(function()
        pickerOpen = not pickerOpen
        picker.Visible = pickerOpen
    end)
    
    if flag then
        Library.Flags[flag] = default
        Library.Callbacks[flag] = callback
    end
    
    return {
        SetValue = function(color)
            currentColor = color
            h, s, v = rgbToHsv(color)
            saturationPicker.Position = UDim2.new(s, -3, 1 - v, -3)
            huePicker.Position = UDim2.new(h, -2, 0, 0)
            updateColor()
        end,
        GetValue = function() return currentColor end
    }
end

function Library:AddToggleWithColor(options)
    options = options or {}
    local name = options.Name or "Toggle"
    local flag = options.Flag
    local default = options.Default or false
    local defaultColor = options.DefaultColor or Color3.fromRGB(120, 120, 255)
    local colorFlag = options.ColorFlag
    local callback = options.Callback or function() end
    local colorCallback = options.ColorCallback or function() end
    local mode = "Toggle"
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundColor3 = BG3
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    
    Util:AddCorner(frame, 5)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -90, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TEXT
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local colorDisplay = Instance.new("TextButton")
    colorDisplay.Size = UDim2.new(0, 20, 0, 20)
    colorDisplay.Position = UDim2.new(1, -82, 0.5, -10)
    colorDisplay.BackgroundColor3 = defaultColor
    colorDisplay.BorderSizePixel = 0
    colorDisplay.Text = ""
    colorDisplay.AutoButtonColor = false
    colorDisplay.ZIndex = 5
    colorDisplay.Parent = frame
    
    Util:AddCorner(colorDisplay, 5)
    Util:AddStroke(colorDisplay, BORDER)
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 38, 0, 20)
    toggle.Position = UDim2.new(1, -56, 0.5, -10)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.Parent = frame
    
    Util:AddCorner(toggle, 10)
    Util:AddStroke(toggle, BORDER)
    
    local toggleGradient = Instance.new("UIGradient")
    toggleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
    }
    toggleGradient.Rotation = 90
    toggleGradient.Parent = toggle
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    
    Util:AddCorner(knob, 8)
    
    local pickerOpen = false
    local currentColor = defaultColor
    local state = default
    
    local picker = Instance.new("Frame")
    picker.Size = UDim2.new(0, 200, 0, 180)
    picker.Position = UDim2.new(1, 10, 0, 0)
    picker.BackgroundColor3 = BG2
    picker.BorderSizePixel = 0
    picker.Visible = false
    picker.ZIndex = 200
    picker.Parent = frame
    
    Util:AddCorner(picker, 6)
    Util:AddStroke(picker, ACCENT, 1.5)
    
    local saturationFrame = Instance.new("Frame")
    saturationFrame.Size = UDim2.new(1, -20, 0, 120)
    saturationFrame.Position = UDim2.new(0, 10, 0, 10)
    saturationFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    saturationFrame.BorderSizePixel = 0
    saturationFrame.ZIndex = 201
    saturationFrame.Parent = picker
    
    Util:AddCorner(saturationFrame, 4)
    
    local saturationWhite = Instance.new("ImageLabel")
    saturationWhite.Size = UDim2.new(1, 0, 1, 0)
    saturationWhite.BackgroundTransparency = 1
    saturationWhite.Image = "rbxassetid://4155801252"
    saturationWhite.ImageColor3 = Color3.fromRGB(255, 255, 255)
    saturationWhite.ZIndex = 202
    saturationWhite.Parent = saturationFrame
    
    Util:AddCorner(saturationWhite, 4)
    
    local saturationBlack = Instance.new("ImageLabel")
    saturationBlack.Size = UDim2.new(1, 0, 1, 0)
    saturationBlack.BackgroundTransparency = 1
    saturationBlack.Image = "rbxassetid://4155801252"
    saturationBlack.ImageColor3 = Color3.fromRGB(0, 0, 0)
    saturationBlack.Rotation = 90
    saturationBlack.ZIndex = 203
    saturationBlack.Parent = saturationFrame
    
    Util:AddCorner(saturationBlack, 4)
    
    local saturationPicker = Instance.new("Frame")
    saturationPicker.Size = UDim2.new(0, 6, 0, 6)
    saturationPicker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    saturationPicker.BorderSizePixel = 0
    saturationPicker.ZIndex = 204
    saturationPicker.Parent = saturationFrame
    
    Util:AddCorner(saturationPicker, 3)
    Util:AddStroke(saturationPicker, Color3.fromRGB(0, 0, 0), 2)
    
    local hueFrame = Instance.new("Frame")
    hueFrame.Size = UDim2.new(1, -20, 0, 15)
    hueFrame.Position = UDim2.new(0, 10, 0, 140)
    hueFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueFrame.BorderSizePixel = 0
    hueFrame.ZIndex = 201
    hueFrame.Parent = picker
    
    Util:AddCorner(hueFrame, 4)
    
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    }
    hueGradient.Parent = hueFrame
    
    local huePicker = Instance.new("Frame")
    huePicker.Size = UDim2.new(0, 4, 1, 0)
    huePicker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    huePicker.BorderSizePixel = 0
    huePicker.ZIndex = 202
    huePicker.Parent = hueFrame
    
    Util:AddStroke(huePicker, Color3.fromRGB(0, 0, 0), 2)
    
    local hexFrame = Instance.new("Frame")
    hexFrame.Size = UDim2.new(1, -20, 0, 20)
    hexFrame.Position = UDim2.new(0, 10, 0, 160)
    hexFrame.BackgroundColor3 = BG1
    hexFrame.BorderSizePixel = 0
    hexFrame.ZIndex = 201
    hexFrame.Parent = picker
    
    Util:AddCorner(hexFrame, 4)
    Util:AddStroke(hexFrame, BORDER)
    
    local hexInput = Instance.new("TextBox")
    hexInput.Size = UDim2.new(1, -10, 1, 0)
    hexInput.Position = UDim2.new(0, 5, 0, 0)
    hexInput.BackgroundTransparency = 1
    hexInput.Text = "#FFFFFF"
    hexInput.TextColor3 = TEXT
    hexInput.TextSize = 11
    hexInput.Font = Enum.Font.GothamMedium
    hexInput.ZIndex = 202
    hexInput.Parent = hexFrame
    
    local h, s, v = 0, 0, 1
    
    local function rgbToHsv(color)
        local r, g, b = color.R, color.G, color.B
        local max, min = math.max(r, g, b), math.min(r, g, b)
        local delta = max - min
        
        local hue = 0
        if delta > 0 then
            if max == r then
                hue = ((g - b) / delta) % 6
            elseif max == g then
                hue = (b - r) / delta + 2
            else
                hue = (r - g) / delta + 4
            end
            hue = hue / 6
        end
        
        local sat = max == 0 and 0 or delta / max
        local val = max
        
        return hue, sat, val
    end
    
    local function hsvToRgb(hue, sat, val)
        local c = val * sat
        local x = c * (1 - math.abs((hue * 6) % 2 - 1))
        local m = val - c
        
        local r, g, b
        if hue < 1/6 then
            r, g, b = c, x, 0
        elseif hue < 2/6 then
            r, g, b = x, c, 0
        elseif hue < 3/6 then
            r, g, b = 0, c, x
        elseif hue < 4/6 then
            r, g, b = 0, x, c
        elseif hue < 5/6 then
            r, g, b = x, 0, c
        else
            r, g, b = c, 0, x
        end
        
        return Color3.fromRGB(
            math.floor((r + m) * 255),
            math.floor((g + m) * 255),
            math.floor((b + m) * 255)
        )
    end
    
    local function updateColor()
        currentColor = hsvToRgb(h, s, v)
        colorDisplay.BackgroundColor3 = currentColor
        saturationFrame.BackgroundColor3 = hsvToRgb(h, 1, 1)
        hexInput.Text = string.format("#%02X%02X%02X", 
            math.floor(currentColor.R * 255),
            math.floor(currentColor.G * 255),
            math.floor(currentColor.B * 255)
        )
        
        if colorFlag then
            Library.Flags[colorFlag] = currentColor
        end
        colorCallback(currentColor)
    end
    
    h, s, v = rgbToHsv(defaultColor)
    saturationPicker.Position = UDim2.new(s, -3, 1 - v, -3)
    huePicker.Position = UDim2.new(h, -2, 0, 0)
    updateColor()
    
    local satDragging = false
    local hueDragging = false
    
    saturationFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            satDragging = true
            local pos = input.Position
            local framePos = saturationFrame.AbsolutePosition
            local frameSize = saturationFrame.AbsoluteSize
            
            local x = math.clamp((pos.X - framePos.X) / frameSize.X, 0, 1)
            local y = math.clamp((pos.Y - framePos.Y) / frameSize.Y, 0, 1)
            
            s = x
            v = 1 - y
            
            saturationPicker.Position = UDim2.new(x, -3, y, -3)
            updateColor()
        end
    end)
    
    hueFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = true
            local pos = input.Position
            local framePos = hueFrame.AbsolutePosition
            local frameSize = hueFrame.AbsoluteSize
            
            local x = math.clamp((pos.X - framePos.X) / frameSize.X, 0, 1)
            h = x
            
            huePicker.Position = UDim2.new(x, -2, 0, 0)
            updateColor()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            satDragging = false
            hueDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if satDragging then
                local pos = input.Position
                local framePos = saturationFrame.AbsolutePosition
                local frameSize = saturationFrame.AbsoluteSize
                
                local x = math.clamp((pos.X - framePos.X) / frameSize.X, 0, 1)
                local y = math.clamp((pos.Y - framePos.Y) / frameSize.Y, 0, 1)
                
                s = x
                v = 1 - y
                
                saturationPicker.Position = UDim2.new(x, -3, y, -3)
                updateColor()
            elseif hueDragging then
                local pos = input.Position
                local framePos = hueFrame.AbsolutePosition
                local frameSize = hueFrame.AbsoluteSize
                
                local x = math.clamp((pos.X - framePos.X) / frameSize.X, 0, 1)
                h = x
                
                huePicker.Position = UDim2.new(x, -2, 0, 0)
                updateColor()
            end
        end
    end)
    
    hexInput.FocusLost:Connect(function()
        local hex = hexInput.Text:gsub("#", "")
        if #hex == 6 then
            local r = tonumber(hex:sub(1, 2), 16)
            local g = tonumber(hex:sub(3, 4), 16)
            local b = tonumber(hex:sub(5, 6), 16)
            if r and g and b then
                currentColor = Color3.fromRGB(r, g, b)
                h, s, v = rgbToHsv(currentColor)
                saturationPicker.Position = UDim2.new(s, -3, 1 - v, -3)
                huePicker.Position = UDim2.new(h, -2, 0, 0)
                updateColor()
            end
        end
    end)
    
    colorDisplay.MouseButton1Click:Connect(function()
        pickerOpen = not pickerOpen
        picker.Visible = pickerOpen
    end)
    
    if flag then
        Library.Flags[flag] = state
        Library.Callbacks[flag] = callback
    end
    
    if colorFlag then
        Library.Flags[colorFlag] = defaultColor
    end
    
    local function set(v)
        state = v
        
        if state then
            Util:Tween(toggle, {BackgroundColor3 = ACCENT}, 0.15)
            toggleGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, ACCENT),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 220))
            }
            Util:Tween(knob, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.15)
        else
            Util:Tween(toggle, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.15)
            toggleGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
            }
            Util:Tween(knob, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(200, 200, 200)}, 0.15)
        end
        
        if flag then
            Library.Flags[flag] = state
        end
        
        callback(state)
    end
    
    set(default)
    
    toggle.MouseButton1Click:Connect(function()
        if mode == "Toggle" then
            set(not state)
        elseif mode == "Always" then
            set(true)
        end
    end)
    
    Library:CreateContextMenu(frame, {
        {Name = "Toggle", Callback = function() mode = "Toggle" Library:Notify("Mode", "Set to Toggle", 1) end},
        {Name = "Hold", Callback = function() mode = "Hold" Library:Notify("Mode", "Set to Hold", 1) end},
        {Name = "Always", Callback = function() mode = "Always" set(true) Library:Notify("Mode", "Set to Always", 1) end}
    })
    
    return {
        SetValue = set,
        GetValue = function() return state end,
        SetColor = function(color)
            currentColor = color
            h, s, v = rgbToHsv(color)
            saturationPicker.Position = UDim2.new(s, -3, 1 - v, -3)
            huePicker.Position = UDim2.new(h, -2, 0, 0)
            updateColor()
        end,
        GetColor = function() return currentColor end
    }
end

function Library:AddToggle(options)
    options = options or {}
    local name = options.Name or "Toggle"
    local flag = options.Flag
    local default = options.Default or false
    local callback = options.Callback or function() end
    local tooltip = options.Tooltip
    local mode = "Toggle"
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundColor3 = BG3
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    
    Util:AddCorner(frame, 5)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -55, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TEXT
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 38, 0, 20)
    toggle.Position = UDim2.new(1, -44, 0.5, -10)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.Parent = frame
    
    Util:AddCorner(toggle, 10)
    Util:AddStroke(toggle, BORDER)
    
    local toggleGradient = Instance.new("UIGradient")
    toggleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
    }
    toggleGradient.Rotation = 90
    toggleGradient.Parent = toggle
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    
    Util:AddCorner(knob, 8)
    
    local state = default
    
    if flag then
        Library.Flags[flag] = state
        Library.Callbacks[flag] = callback
    end
    
    local function set(v)
        state = v
        
        if state then
            Util:Tween(toggle, {BackgroundColor3 = ACCENT}, 0.15)
            toggleGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, ACCENT),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 220))
            }
            Util:Tween(knob, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.15)
        else
            Util:Tween(toggle, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.15)
            toggleGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
            }
            Util:Tween(knob, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(200, 200, 200)}, 0.15)
        end
        
        if flag then
            Library.Flags[flag] = state
        end
        
        callback(state)
    end
    
    set(default)
    
    toggle.MouseButton1Click:Connect(function()
        if mode == "Toggle" then
            set(not state)
        elseif mode == "Always" then
            set(true)
        end
    end)
    
    if tooltip then
        local info = Instance.new("TextButton")
        info.Size = UDim2.new(0, 16, 0, 16)
        info.Position = UDim2.new(1, -60, 0.5, -8)
        info.BackgroundColor3 = BG1
        info.BorderSizePixel = 0
        info.Text = "i"
        info.TextColor3 = TEXT_DIM
        info.TextSize = 11
        info.Font = Enum.Font.GothamBold
        info.Parent = frame
        
        Util:AddCorner(info, 8)
        Util:AddStroke(info, BORDER)
    end
    
    Library:CreateContextMenu(frame, {
        {Name = "Toggle", Callback = function() mode = "Toggle" Library:Notify("Mode", "Set to Toggle", 1) end},
        {Name = "Hold", Callback = function() mode = "Hold" Library:Notify("Mode", "Set to Hold", 1) end},
        {Name = "Always", Callback = function() mode = "Always" set(true) Library:Notify("Mode", "Set to Always", 1) end}
    })
    
    return {
        SetValue = set,
        GetValue = function() return state end
    }
end
    options = options or {}
    local name = options.Name or "Toggle"
    local flag = options.Flag
    local default = options.Default or false
    local callback = options.Callback or function() end
    local mode = "Toggle"
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundColor3 = BG3
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    
    Util:AddCorner(frame, 5)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -55, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TEXT
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 38, 0, 20)
    toggle.Position = UDim2.new(1, -44, 0.5, -10)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.Parent = frame
    
    Util:AddCorner(toggle, 10)
    Util:AddStroke(toggle, BORDER)
    
    local toggleGradient = Instance.new("UIGradient")
    toggleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
    }
    toggleGradient.Rotation = 90
    toggleGradient.Parent = toggle
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    
    Util:AddCorner(knob, 8)
    
    local state = default
    
    if flag then
        Library.Flags[flag] = state
        Library.Callbacks[flag] = callback
    end
    
    local function set(v)
        state = v
        
        if state then
            Util:Tween(toggle, {BackgroundColor3 = ACCENT}, 0.15)
            toggleGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, ACCENT),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 220))
            }
            Util:Tween(knob, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.15)
        else
            Util:Tween(toggle, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.15)
            toggleGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
            }
            Util:Tween(knob, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(200, 200, 200)}, 0.15)
        end
        
        if flag then
            Library.Flags[flag] = state
        end
        
        callback(state)
    end
    
    set(default)
    
    toggle.MouseButton1Click:Connect(function()
        if mode == "Toggle" then
            set(not state)
        elseif mode == "Always" then
            set(true)
        end
    end)
    
    Library:CreateContextMenu(frame, {
        {Name = "Toggle", Callback = function() mode = "Toggle" Library:Notify("Mode", "Set to Toggle", 1) end},
        {Name = "Hold", Callback = function() mode = "Hold" Library:Notify("Mode", "Set to Hold", 1) end},
        {Name = "Always", Callback = function() mode = "Always" set(true) Library:Notify("Mode", "Set to Always", 1) end}
    })
    
    return {
        SetValue = set,
        GetValue = function() return state end
    }
end

function Library:AddDropdown(options)
    options = options or {}
    local name = options.Name or "Dropdown"
    local list = options.List or {}
    local default = options.Default
    local flag = options.Flag
    local callback = options.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 54)
    frame.BackgroundColor3 = BG3
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    frame.ZIndex = 5
    
    Util:AddCorner(frame, 5)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TEXT_DIM
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 6
    label.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -24, 0, 26)
    button.Position = UDim2.new(0, 12, 0, 24)
    button.BackgroundColor3 = BG1
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.ZIndex = 7
    button.Parent = frame
    
    Util:AddCorner(button, 4)
    Util:AddStroke(button, BORDER)
    
    local selected = Instance.new("TextLabel")
    selected.Size = UDim2.new(1, -30, 1, 0)
    selected.Position = UDim2.new(0, 10, 0, 0)
    selected.BackgroundTransparency = 1
    selected.Text = default or "Select..."
    selected.TextColor3 = TEXT
    selected.TextSize = 11
    selected.Font = Enum.Font.Gotham
    selected.TextXAlignment = Enum.TextXAlignment.Left
    selected.TextTruncate = Enum.TextTruncate.AtEnd
    selected.ZIndex = 8
    selected.Parent = button
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = TEXT_DIM
    arrow.TextSize = 10
    arrow.Font = Enum.Font.GothamBold
    arrow.ZIndex = 8
    arrow.Parent = button
    
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(1, -24, 0, 0)
    dropdown.Position = UDim2.new(0, 12, 1, 5)
    dropdown.BackgroundColor3 = BG1
    dropdown.BorderSizePixel = 0
    dropdown.Visible = false
    dropdown.ZIndex = 100
    dropdown.ClipsDescendants = true
    dropdown.Parent = frame
    
    Util:AddCorner(dropdown, 4)
    Util:AddStroke(dropdown, BORDER)
    
    local dropLayout = Instance.new("UIListLayout")
    dropLayout.Padding = UDim.new(0, 1)
    dropLayout.Parent = dropdown
    
    local value = default
    local open = false
    
    if flag then
        Library.Flags[flag] = value
        Library.Callbacks[flag] = callback
    end
    
    local function refresh(newList)
        for _, child in pairs(dropdown:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for _, item in pairs(newList) do
            local option = Instance.new("TextButton")
            option.Size = UDim2.new(1, 0, 0, 24)
            option.BackgroundColor3 = BG1
            option.BorderSizePixel = 0
            option.Text = item
            option.TextColor3 = TEXT
            option.TextSize = 11
            option.Font = Enum.Font.Gotham
            option.AutoButtonColor = false
            option.ZIndex = 101
            option.Parent = dropdown
            
            option.MouseEnter:Connect(function()
                Util:Tween(option, {BackgroundColor3 = BG3}, 0.1)
            end)
            
            option.MouseLeave:Connect(function()
                Util:Tween(option, {BackgroundColor3 = BG1}, 0.1)
            end)
            
            option.MouseButton1Click:Connect(function()
                value = item
                selected.Text = item
                
                if flag then
                    Library.Flags[flag] = value
                end
                
                callback(value)
                
                open = false
                Util:Tween(dropdown, {Size = UDim2.new(1, -24, 0, 0)}, 0.15)
                task.wait(0.15)
                dropdown.Visible = false
                arrow.Text = "▼"
            end)
        end
        
        local height = math.min(#newList * 25, 150)
        if open then
            dropdown.Size = UDim2.new(1, -24, 0, height)
        end
    end
    
    button.MouseButton1Click:Connect(function()
        open = not open
        
        if open then
            dropdown.Visible = true
            local height = math.min(#list * 25, 150)
            Util:Tween(dropdown, {Size = UDim2.new(1, -24, 0, height)}, 0.15)
            arrow.Text = "▲"
        else
            Util:Tween(dropdown, {Size = UDim2.new(1, -24, 0, 0)}, 0.15)
            task.wait(0.15)
            dropdown.Visible = false
            arrow.Text = "▼"
        end
    end)
    
    refresh(list)
    
    if default and flag then
        Library.Flags[flag] = default
        callback(default)
    end
    
    return {
        Refresh = refresh,
        SetValue = function(v)
            value = v
            selected.Text = v
            if flag then Library.Flags[flag] = v end
            callback(v)
        end,
        GetValue = function() return value end
    }
end

function Library:AddMultiDropdown(options)
    options = options or {}
    local name = options.Name or "Multi Dropdown"
    local list = options.List or {}
    local default = options.Default or {}
    local flag = options.Flag
    local callback = options.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 54)
    frame.BackgroundColor3 = BG3
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    frame.ZIndex = 5
    
    Util:AddCorner(frame, 5)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TEXT_DIM
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 6
    label.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -24, 0, 26)
    button.Position = UDim2.new(0, 12, 0, 24)
    button.BackgroundColor3 = BG1
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.ZIndex = 7
    button.Parent = frame
    
    Util:AddCorner(button, 4)
    Util:AddStroke(button, BORDER)
    
    local selected = Instance.new("TextLabel")
    selected.Size = UDim2.new(1, -30, 1, 0)
    selected.Position = UDim2.new(0, 10, 0, 0)
    selected.BackgroundTransparency = 1
    selected.Text = "Select..."
    selected.TextColor3 = TEXT
    selected.TextSize = 11
    selected.Font = Enum.Font.Gotham
    selected.TextXAlignment = Enum.TextXAlignment.Left
    selected.TextTruncate = Enum.TextTruncate.AtEnd
    selected.ZIndex = 8
    selected.Parent = button
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = TEXT_DIM
    arrow.TextSize = 10
    arrow.Font = Enum.Font.GothamBold
    arrow.ZIndex = 8
    arrow.Parent = button
    
    local dropdown = Instance.new("ScrollingFrame")
    dropdown.Size = UDim2.new(1, -24, 0, 0)
    dropdown.Position = UDim2.new(0, 12, 1, 5)
    dropdown.BackgroundColor3 = BG1
    dropdown.BorderSizePixel = 0
    dropdown.Visible = false
    dropdown.ZIndex = 100
    dropdown.ClipsDescendants = true
    dropdown.ScrollBarThickness = 4
    dropdown.ScrollBarImageColor3 = ACCENT
    dropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
    dropdown.Parent = frame
    
    Util:AddCorner(dropdown, 4)
    Util:AddStroke(dropdown, BORDER)
    
    local dropLayout = Instance.new("UIListLayout")
    dropLayout.Padding = UDim.new(0, 1)
    dropLayout.Parent = dropdown
    
    local values = {}
    for _, v in pairs(default) do
        values[v] = true
    end
    
    local open = false
    
    if flag then
        Library.Flags[flag] = values
        Library.Callbacks[flag] = callback
    end
    
    local function updateLabel()
        local sel = {}
        for k, v in pairs(values) do
            if v then table.insert(sel, k) end
        end
        selected.Text = #sel > 0 and table.concat(sel, ", ") or "Select..."
    end
    
    local function refresh(newList)
        for _, child in pairs(dropdown:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        for _, item in pairs(newList) do
            local option = Instance.new("Frame")
            option.Size = UDim2.new(1, 0, 0, 24)
            option.BackgroundColor3 = BG1
            option.BorderSizePixel = 0
            option.ZIndex = 101
            option.Parent = dropdown
            
            local optButton = Instance.new("TextButton")
            optButton.Size = UDim2.new(1, -28, 1, 0)
            optButton.BackgroundTransparency = 1
            optButton.Text = item
            optButton.TextColor3 = TEXT
            optButton.TextSize = 11
            optButton.Font = Enum.Font.Gotham
            optButton.TextXAlignment = Enum.TextXAlignment.Left
            optButton.AutoButtonColor = false
            optButton.ZIndex = 102
            optButton.Parent = option
            
            local check = Instance.new("Frame")
            check.Size = UDim2.new(0, 14, 0, 14)
            check.Position = UDim2.new(1, -20, 0.5, -7)
            check.BackgroundColor3 = BG3
            check.BorderSizePixel = 0
            check.ZIndex = 102
            check.Parent = option
            
            Util:AddCorner(check, 3)
            Util:AddStroke(check, BORDER)
            
            local checkmark = Instance.new("TextLabel")
            checkmark.Size = UDim2.new(1, 0, 1, 0)
            checkmark.BackgroundTransparency = 1
            checkmark.Text = "✓"
            checkmark.TextColor3 = ACCENT
            checkmark.TextSize = 11
            checkmark.Font = Enum.Font.GothamBold
            checkmark.Visible = values[item] or false
            checkmark.ZIndex = 103
            checkmark.Parent = check
            
            optButton.MouseEnter:Connect(function()
                Util:Tween(option, {BackgroundColor3 = BG3}, 0.1)
            end)
            
            optButton.MouseLeave:Connect(function()
                Util:Tween(option, {BackgroundColor3 = BG1}, 0.1)
            end)
            
            optButton.MouseButton1Click:Connect(function()
                values[item] = not values[item]
                checkmark.Visible = values[item]
                
                if flag then
                    Library.Flags[flag] = values
                end
                
                updateLabel()
                callback(values)
            end)
        end
        
        dropLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            dropdown.CanvasSize = UDim2.new(0, 0, 0, dropLayout.AbsoluteContentSize.Y)
        end)
    end
    
    button.MouseButton1Click:Connect(function()
        open = not open
        
        if open then
            dropdown.Visible = true
            local height = math.min(dropLayout.AbsoluteContentSize.Y, 150)
            Util:Tween(dropdown, {Size = UDim2.new(1, -24, 0, height)}, 0.15)
            arrow.Text = "▲"
        else
            Util:Tween(dropdown, {Size = UDim2.new(1, -24, 0, 0)}, 0.15)
            task.wait(0.15)
            dropdown.Visible = false
            arrow.Text = "▼"
        end
    end)
    
    refresh(list)
    updateLabel()
    
    return {
        Refresh = refresh,
        SetValue = function(v)
            values = v
            updateLabel()
            if flag then Library.Flags[flag] = v end
            callback(v)
        end,
        GetValue = function() return values end
    }
end

function Library:AddKeybind(options)
    options = options or {}
    local name = options.Name or "Keybind"
    local default = options.Default
    local mode = options.Mode or "Toggle"
    local flag = options.Flag
    local callback = options.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundColor3 = BG3
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    
    Util:AddCorner(frame, 5)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TEXT
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 75, 0, 22)
    button.Position = UDim2.new(1, -82, 0.5, -11)
    button.BackgroundColor3 = BG1
    button.BorderSizePixel = 0
    button.Text = default and default.Name or "None"
    button.TextColor3 = TEXT
    button.TextSize = 11
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = false
    button.Parent = frame
    
    Util:AddCorner(button, 4)
    Util:AddStroke(button, BORDER)
    
    local currentKey = default
    local listening = false
    local active = false
    
    if flag then
        Library.Flags[flag] = {Key = currentKey, Active = active}
        Library.Callbacks[flag] = callback
    end
    
    button.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        button.Text = "..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                button.Text = input.KeyCode.Name
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.MouseButton2 then
                currentKey = input.UserInputType
                button.Text = input.UserInputType.Name:gsub("MouseButton", "M")
            end
            
            listening = false
            connection:Disconnect()
            
            if flag then
                Library.Flags[flag].Key = currentKey
            end
        end)
    end)
    
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp or listening or not currentKey then return end
        
        local match = false
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
            match = true
        elseif input.UserInputType == currentKey then
            match = true
        end
        
        if match then
            if mode == "Toggle" then
                active = not active
                if flag then Library.Flags[flag].Active = active end
                callback(active, currentKey)
            else
                active = true
                if flag then Library.Flags[flag].Active = true end
                callback(true, currentKey)
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if mode == "Hold" and currentKey then
            local match = false
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                match = true
            elseif input.UserInputType == currentKey then
                match = true
            end
            
            if match then
                active = false
                if flag then Library.Flags[flag].Active = false end
                callback(false, currentKey)
            end
        end
    end)
    
    Library:CreateContextMenu(frame, {
        {Name = "Toggle", Callback = function() mode = "Toggle" Library:Notify("Mode", "Set to Toggle", 1) end},
        {Name = "Hold", Callback = function() mode = "Hold" Library:Notify("Mode", "Set to Hold", 1) end}
    })
    
    return {
        SetKey = function(k)
            currentKey = k
            button.Text = k and k.Name or "None"
            if flag then Library.Flags[flag].Key = k end
        end,
        GetKey = function() return currentKey end,
        GetActive = function() return active end
    }
end

function Library:SaveConfig(name)
    local config = {}
    for flag, value in pairs(self.Flags) do
        config[flag] = value
    end
    
    local success = pcall(function()
        if not isfolder("ClubConfigs") then
            makefolder("ClubConfigs")
        end
        writefile("ClubConfigs/" .. name .. ".json", HttpService:JSONEncode(config))
    end)
    
    if success then
        Library:Notify("Success", "Configuration saved successfully", 2)
    else
        Library:Notify("Error", "Failed to save config", 2)
    end
end

function Library:LoadConfig(name)
    local success = pcall(function()
        local data = readfile("ClubConfigs/" .. name .. ".json")
        local config = HttpService:JSONDecode(data)
        
        for flag, value in pairs(config) do
            if self.Flags[flag] ~= nil then
                self.Flags[flag] = value
                if self.Callbacks[flag] then
                    self.Callbacks[flag](value)
                end
            end
        end
    end)
    
    if success then
        Library:Notify("Success", "Configuration loaded successfully", 2)
    else
        Library:Notify("Error", "Failed to load config", 2)
    end
end

function Library:AddConfigTab()
    local tab = self:AddTab("Config", "")
    
    local configSection = tab:AddSection("Configuration", "left")
    
    local function getConfigs()
        local configs = {}
        if isfolder and isfile and listfiles then
            if isfolder("ClubConfigs") then
                for _, file in pairs(listfiles("ClubConfigs")) do
                    local name = file:gsub("ClubConfigs/", ""):gsub(".json", "")
                    table.insert(configs, name)
                end
            end
        end
        return configs
    end
    
    local selectedConfig = ""
    
    local configDropdown = configSection:AddDropdown({
        Name = "Select Config",
        Flag = "SelectedConfig",
        List = getConfigs(),
        Callback = function(value)
            selectedConfig = value
        end
    })
    
    local nameInput = configSection:AddInput({
        Name = "New Config Name",
        Placeholder = "Enter name...",
        Callback = function() end
    })
    
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, 0, 0, 36)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = configSection.Container
    
    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    buttonLayout.Padding = UDim.new(0, 8)
    buttonLayout.Parent = buttonContainer
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.48, 0, 1, 0)
    saveBtn.BackgroundColor3 = BG3
    saveBtn.BorderSizePixel = 0
    saveBtn.Text = "Save"
    saveBtn.TextColor3 = TEXT
    saveBtn.TextSize = 13
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.AutoButtonColor = false
    saveBtn.Parent = buttonContainer
    
    Util:AddCorner(saveBtn, 6)
    
    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(0.48, 0, 1, 0)
    loadBtn.BackgroundColor3 = BG3
    loadBtn.BorderSizePixel = 0
    loadBtn.Text = "Load"
    loadBtn.TextColor3 = TEXT
    loadBtn.TextSize = 13
    loadBtn.Font = Enum.Font.GothamBold
    loadBtn.AutoButtonColor = false
    loadBtn.Parent = buttonContainer
    
    Util:AddCorner(loadBtn, 6)
    
    local deleteBtn = Instance.new("TextButton")
    deleteBtn.Size = UDim2.new(1, 0, 0, 36)
    deleteBtn.BackgroundColor3 = BG3
    deleteBtn.BorderSizePixel = 0
    deleteBtn.Text = "Delete"
    deleteBtn.TextColor3 = TEXT
    deleteBtn.TextSize = 13
    deleteBtn.Font = Enum.Font.GothamBold
    deleteBtn.AutoButtonColor = false
    deleteBtn.Parent = configSection.Container
    
    Util:AddCorner(deleteBtn, 6)
    
    saveBtn.MouseButton1Click:Connect(function()
        local name = nameInput.GetValue()
        if name ~= "" then
            Library:SaveConfig(name)
            configDropdown:Refresh(getConfigs())
            nameInput.SetValue("")
        else
            Library:Notify("Error", "Please enter a config name", 2)
        end
    end)
    
    loadBtn.MouseButton1Click:Connect(function()
        if selectedConfig ~= "" then
            Library:LoadConfig(selectedConfig)
            Library.ConfigFile = selectedConfig
        else
            Library:Notify("Error", "Please select a config to load", 2)
        end
    end)
    
    deleteBtn.MouseButton1Click:Connect(function()
        if selectedConfig ~= "" then
            if isfile and delfile then
                delfile("ClubConfigs/" .. selectedConfig .. ".json")
                Library:Notify("Success", "Config deleted successfully", 2)
                configDropdown:Refresh(getConfigs())
                selectedConfig = ""
            end
        else
            Library:Notify("Error", "Please select a config to delete", 2)
        end
    end)
    
    local settingsSection = tab:AddSection("Settings", "right")
    
    local autoLoadLabel = settingsSection:AddLabel("Auto Load: None")
    
    settingsSection:AddToggle({
        Name = "Auto Load Config",
        Flag = "AutoLoadConfig",
        Default = false,
        Callback = function(value)
            if value and Library.ConfigFile ~= "" then
                autoLoadLabel.SetText("Auto Load: " .. Library.ConfigFile)
            else
                autoLoadLabel.SetText("Auto Load: None")
            end
        end
    })
    
    settingsSection:AddKeybind({
        Name = "Toggle UI",
        Flag = "ToggleUIKeybind",
        Default = Enum.KeyCode.RightShift,
        Mode = "Toggle",
        Callback = function(active, key)
            if active then
                Library.Gui.Enabled = not Library.Gui.Enabled
            end
        end
    })
    
    local watermarkSection = tab:AddSection("Watermark", "left")
    
    watermarkSection:AddToggle({
        Name = "Show FPS",
        Flag = "WatermarkFPS",
        Default = false,
        Callback = function(value)
            if Library.WatermarkOptions then
                Library.WatermarkOptions.ShowFPS = value
                if Library.WatermarkFrame then
                    local anyVisible = Library.WatermarkOptions.ShowFPS or Library.WatermarkOptions.ShowPing or Library.WatermarkOptions.ShowTime or Library.WatermarkOptions.ShowUser
                    Library.WatermarkFrame.Visible = anyVisible
                end
            end
        end
    })
    
    watermarkSection:AddToggle({
        Name = "Show Ping",
        Flag = "WatermarkPing",
        Default = false,
        Callback = function(value)
            if Library.WatermarkOptions then
                Library.WatermarkOptions.ShowPing = value
                if Library.WatermarkFrame then
                    local anyVisible = Library.WatermarkOptions.ShowFPS or Library.WatermarkOptions.ShowPing or Library.WatermarkOptions.ShowTime or Library.WatermarkOptions.ShowUser
                    Library.WatermarkFrame.Visible = anyVisible
                end
            end
        end
    })
    
    watermarkSection:AddToggle({
        Name = "Show Time",
        Flag = "WatermarkTime",
        Default = false,
        Callback = function(value)
            if Library.WatermarkOptions then
                Library.WatermarkOptions.ShowTime = value
                if Library.WatermarkFrame then
                    local anyVisible = Library.WatermarkOptions.ShowFPS or Library.WatermarkOptions.ShowPing or Library.WatermarkOptions.ShowTime or Library.WatermarkOptions.ShowUser
                    Library.WatermarkFrame.Visible = anyVisible
                end
            end
        end
    })
    
    watermarkSection:AddToggle({
        Name = "Show Username",
        Flag = "WatermarkUser",
        Default = false,
        Callback = function(value)
            if Library.WatermarkOptions then
                Library.WatermarkOptions.ShowUser = value
                if Library.WatermarkFrame then
                    local anyVisible = Library.WatermarkOptions.ShowFPS or Library.WatermarkOptions.ShowPing or Library.WatermarkOptions.ShowTime or Library.WatermarkOptions.ShowUser
                    Library.WatermarkFrame.Visible = anyVisible
                end
            end
        end
    })
    
    local themeSection = tab:AddSection("Theme", "right")
    
    themeSection:AddColorPicker({
        Name = "Accent Color",
        Default = ACCENT,
        Flag = "AccentColor",
        Callback = function(color)
            ACCENT = color
        end
    })
    
    themeSection:AddDropdown({
        Name = "Theme",
        Flag = "Theme",
        List = {"Dark", "Darker", "Black"},
        Default = "Dark",
        Callback = function(value)
            if value == "Dark" then
                BG1 = Color3.fromRGB(15, 15, 15)
                BG2 = Color3.fromRGB(20, 20, 20)
                BG3 = Color3.fromRGB(25, 25, 25)
            elseif value == "Darker" then
                BG1 = Color3.fromRGB(10, 10, 10)
                BG2 = Color3.fromRGB(15, 15, 15)
                BG3 = Color3.fromRGB(20, 20, 20)
            elseif value == "Black" then
                BG1 = Color3.fromRGB(0, 0, 0)
                BG2 = Color3.fromRGB(5, 5, 5)
                BG3 = Color3.fromRGB(10, 10, 10)
            end
            Library:Notify("Theme", "Theme changed to " .. value, 2)
        end
    })
    
    local unloadSection = tab:AddSection("Danger Zone", "left")
    
    unloadSection:AddButton({
        Name = "Unload UI",
        Callback = function()
            Library.Gui:Destroy()
            for _, connection in pairs(getconnections(game:GetService("RunService").RenderStepped)) do
                connection:Disable()
            end
            Library:Notify("Unloaded", "UI has been unloaded", 2)
        end
    })
    
    local testSection = tab:AddSection("Test Features", "right")
    
    testSection:AddButton({
        Name = "Test Notification",
        Callback = function()
            Library:Notify("Test", "This is a test notification!", 2)
        end
    })
    
    return tab
end

return Library
