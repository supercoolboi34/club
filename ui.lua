local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Theme System
local Theme = {
    Accent = Color3.fromRGB(120, 120, 255),
    BG1 = Color3.fromRGB(15, 15, 15),
    BG2 = Color3.fromRGB(20, 20, 20),
    BG3 = Color3.fromRGB(25, 25, 25),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(160, 160, 160),
    Border = Color3.fromRGB(40, 40, 40),
    Shadow = Color3.fromRGB(0, 0, 0)
}

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

function Util:Resize(frame, indicator)
    local resizing, startPos, startSize
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 30, 0, 30)
    handle.Position = UDim2.new(1, -30, 1, -30)
    handle.BackgroundTransparency = 1
    handle.Parent = frame
    
    -- Triangle indicator
    local triangle = Instance.new("ImageLabel")
    triangle.Size = UDim2.new(0, 20, 0, 20)
    triangle.Position = UDim2.new(1, -22, 1, -22)
    triangle.BackgroundTransparency = 1
    triangle.Image = "rbxassetid://6031229361"
    triangle.ImageColor3 = Theme.Accent
    triangle.ImageTransparency = 0.7
    triangle.Rotation = 90
    triangle.ZIndex = 10
    triangle.Parent = frame
    
    handle.MouseEnter:Connect(function()
        Util:Tween(triangle, {ImageTransparency = 0.3}, 0.2)
    end)
    
    handle.MouseLeave:Connect(function()
        if not resizing then
            Util:Tween(triangle, {ImageTransparency = 0.7}, 0.2)
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
            Util:Tween(triangle, {ImageTransparency = 0.7}, 0.2)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startPos
            frame.Size = UDim2.new(0, math.max(700, startSize.X.Offset + delta.X), 0, math.max(500, startSize.Y.Offset + delta.Y))
        end
    end)
end

function Util:AddStroke(obj, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
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
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Theme.Shadow
    shadow.ImageTransparency = 0.85
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = obj.ZIndex - 1
    shadow.Parent = obj
    return shadow
end

Library.Flags = {}
Library.Callbacks = {}
Library.ConfigFile = ""
Library.ActiveKeybinds = {}

function Library:Notify(title, text, duration)
    local gui = Instance.new("ScreenGui")
    gui.Name = "Notification"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 0, 0, 0)
    frame.Position = UDim2.new(1, -10, 1, -10)
    frame.AnchorPoint = Vector2.new(1, 1)
    frame.BackgroundColor3 = Theme.BG2
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = false
    frame.Parent = gui
    
    Util:AddCorner(frame, 6)
    Util:AddStroke(frame, Theme.Accent, 1)
    
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, 10, 1, 10)
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://1316045217"
    glow.ImageColor3 = Theme.Accent
    glow.ImageTransparency = 0.9
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(10, 10, 118, 118)
    glow.ZIndex = frame.ZIndex - 1
    glow.Parent = frame
    
    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.new(0, 40, 1, 0)
    iconFrame.BackgroundColor3 = Theme.Accent
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = frame
    
    Util:AddCorner(iconFrame, 6)
    
    local iconCover = Instance.new("Frame")
    iconCover.Size = UDim2.new(0, 10, 1, 0)
    iconCover.Position = UDim2.new(1, -10, 0, 0)
    iconCover.BackgroundColor3 = Theme.Accent
    iconCover.BorderSizePixel = 0
    iconCover.Parent = iconFrame
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "!"
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    icon.TextSize = 18
    icon.Font = Enum.Font.GothamBold
    icon.Parent = iconFrame
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -50, 1, 0)
    content.Position = UDim2.new(0, 45, 0, 0)
    content.BackgroundTransparency = 1
    content.Parent = frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 0, 20)
    titleLabel.Position = UDim2.new(0, 5, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = content
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 0, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 28)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Theme.TextDim
    textLabel.TextSize = 11
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.AutomaticSize = Enum.AutomaticSize.Y
    textLabel.Parent = content
    
    task.wait()
    local textHeight = textLabel.AbsoluteSize.Y
    local totalHeight = math.max(60, 45 + textHeight)
    
    Util:Tween(frame, {Size = UDim2.new(0, 300, 0, totalHeight)}, 0.3)
    
    task.spawn(function()
        for i = 0, 1, 0.05 do
            glow.ImageTransparency = 0.9 - (i * 0.3)
            task.wait(0.02)
        end
        for i = 0, 1, 0.05 do
            glow.ImageTransparency = 0.6 + (i * 0.3)
            task.wait(0.02)
        end
    end)
    
    task.delay(duration or 3, function()
        Util:Tween(frame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        gui:Destroy()
    end)
end

function Library:CreateWatermark(options)
    options = options or {}
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "Watermark"
    gui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 10, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Theme.BG2
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = gui
    
    Util:AddCorner(frame, 5)
    Util:AddStroke(frame, Theme.Border, 1)
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.BackgroundColor3 = Theme.Accent
    accent.BorderSizePixel = 0
    accent.Parent = frame
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 1, -6)
    container.Position = UDim2.new(0, 8, 0, 4)
    container.BackgroundTransparency = 1
    container.Parent = frame
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 12)
    layout.Parent = container
    
    local labels = {}
    
    local function createLabel(text, visible)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 0, 1, 0)
        label.AutomaticSize = Enum.AutomaticSize.X
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Theme.Text
        label.TextSize = 12
        label.Font = Enum.Font.GothamBold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Visible = visible or false
        label.Parent = container
        return label
    end
    
    labels.fps = createLabel("FPS: 60", options.ShowFPS)
    labels.ping = createLabel("PING: 0ms", options.ShowPing)
    labels.time = createLabel("00:00:00", options.ShowTime)
    labels.user = createLabel(Players.LocalPlayer.Name, options.ShowUser)
    
    Util:Drag(frame, frame)
    
    local fps = 60
    local lastUpdate = tick()
    local frameCount = 0
    
    local function updateSize()
        task.wait()
        local totalWidth = layout.AbsoluteContentSize.X + 16
        frame.Size = UDim2.new(0, math.max(totalWidth, 10), 0, 30)
    end
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        if tick() - lastUpdate >= 1 then
            fps = frameCount
            frameCount = 0
            lastUpdate = tick()
        end
        
        if options.ShowFPS then
            labels.fps.Text = "FPS: " .. fps
        end
        
        if options.ShowPing then 
            local success, ping = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            if success then
                labels.ping.Text = "PING: " .. ping .. "ms"
            end
        end
        
        if options.ShowTime then
            labels.time.Text = os.date("%H:%M:%S")
        end
    end)
    
    Library.WatermarkFrame = frame
    Library.WatermarkOptions = options
    Library.WatermarkLabels = labels
    
    local function updateVisibility()
        local anyVisible = options.ShowFPS or options.ShowPing or options.ShowTime or options.ShowUser
        frame.Visible = anyVisible
        if anyVisible then
            updateSize()
        end
    end
    
    updateVisibility()
    
    return {
        SetVisible = function(v) frame.Visible = v end,
        SetOptions = function(o)
            options = o
            labels.fps.Visible = o.ShowFPS or false
            labels.ping.Visible = o.ShowPing or false
            labels.time.Visible = o.ShowTime or false
            labels.user.Visible = o.ShowUser or false
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
    frame.Size = UDim2.new(0, 200, 0, 38)
    frame.Position = UDim2.new(1, -210, 0, 50)
    frame.BackgroundColor3 = Theme.BG2
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = false
    frame.Parent = gui
    
    Util:AddCorner(frame, 5)
    Util:AddStroke(frame, Theme.Border, 1)
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.BackgroundColor3 = Theme.Accent
    accent.BorderSizePixel = 0
    accent.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 28)
    title.Position = UDim2.new(0, 10, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "Keybinds"
    title.TextColor3 = Theme.Text
    title.TextSize = 13
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.Position = UDim2.new(0, 0, 0, 38)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = frame
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 2)
    list.Parent = container
    
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        frame.Size = UDim2.new(0, 200, 0, 38 + list.AbsoluteContentSize.Y)
    end)
    
    Util:Drag(frame, frame)
    
    Library.KeybindListFrame = frame
    Library.KeybindListContainer = container
    
    return {
        Frame = frame,
        Container = container,
        AddKeybind = function(name, key, mode)
            local bind = Instance.new("Frame")
            bind.Size = UDim2.new(1, -10, 0, 24)
            bind.BackgroundColor3 = Theme.BG3
            bind.BorderSizePixel = 0
            bind.Parent = container
            bind.Name = name
            
            Util:AddCorner(bind, 4)
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.6, -10, 1, 0)
            nameLabel.Position = UDim2.new(0, 8, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = name
            nameLabel.TextColor3 = Theme.Text
            nameLabel.TextSize = 11
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            nameLabel.Parent = bind
            
            local keyLabel = Instance.new("TextLabel")
            keyLabel.Size = UDim2.new(0.4, -8, 1, 0)
            keyLabel.Position = UDim2.new(0.6, 0, 0, 0)
            keyLabel.BackgroundTransparency = 1
            keyLabel.Text = "[" .. (key and key.Name or "None") .. "]"
            keyLabel.TextColor3 = Theme.Accent
            keyLabel.TextSize = 11
            keyLabel.Font = Enum.Font.GothamBold
            keyLabel.TextXAlignment = Enum.TextXAlignment.Right
            keyLabel.Parent = bind
            
            return bind
        end,
        RemoveKeybind = function(name)
            local bind = container:FindFirstChild(name)
            if bind then
                bind:Destroy()
            end
        end
    }
end

function Library:Create(options)
    options = options or {}
    local name = options.Name or "Club"
    
    if options.Theme then
        for k, v in pairs(options.Theme) do
            if Theme[k] then
                Theme[k] = v
            end
        end
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "ClubUI"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 750, 0, 550)
    main.Position = UDim2.new(0.5, -375, 0.5, -275)
    main.BackgroundColor3 = Theme.BG1
    main.BorderSizePixel = 0
    main.ClipsDescendants = false
    main.Parent = gui
    
    Util:AddCorner(main, 6)
    Util:AddStroke(main, Theme.Border, 1)
    
    local shadow = Util:AddShadow(main)
    
    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, 0, 0, 40)
    topbar.BackgroundColor3 = Theme.BG2
    topbar.BorderSizePixel = 0
    topbar.Parent = main
    
    Util:AddCorner(topbar, 6)
    
    local topCover = Instance.new("Frame")
    topCover.Size = UDim2.new(1, 0, 0, 8)
    topCover.Position = UDim2.new(0, 0, 1, -8)
    topCover.BackgroundColor3 = Theme.BG2
    topCover.BorderSizePixel = 0
    topCover.Parent = topbar
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.Position = UDim2.new(0, 0, 1, 0)
    accent.BackgroundColor3 = Theme.Accent
    accent.BorderSizePixel = 0
    accent.Parent = topbar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = Theme.Text
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topbar
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 200, 255)),
        ColorSequenceKeypoint.new(1, Theme.Accent)
    }
    gradient.Parent = title
    
    task.spawn(function()
        while gui.Parent do
            for i = 0, 360, 2 do
                if not gui.Parent then break end
                gradient.Rotation = i
                task.wait(0.03)
            end
        end
    end)
    
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 150, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = Theme.BG2
    sidebar.BorderSizePixel = 0
    sidebar.ClipsDescendants = true
    sidebar.Parent = main
    
    local sideStroke = Util:AddStroke(sidebar, Theme.Border)
    sideStroke.Transparency = 0.5
    
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Size = UDim2.new(1, -8, 1, -8)
    tabContainer.Position = UDim2.new(0, 4, 0, 4)
    tabContainer.BackgroundTransparency = 1
    tabContainer.BorderSizePixel = 0
    tabContainer.ScrollBarThickness = 3
    tabContainer.ScrollBarImageColor3 = Theme.Accent
    tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContainer.Parent = sidebar
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = tabContainer
    
    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContainer.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 8)
    end)
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -158, 1, -48)
    content.Position = UDim2.new(0, 154, 0, 44)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = main
    
    Util:Drag(main, topbar)
    Util:Resize(main, nil)
    
    Library.Gui = gui
    Library.Main = main
    Library.Sidebar = tabContainer
    Library.Content = content
    Library.Tabs = {}
    Library.CurrentTab = nil
    Library.Theme = Theme
    
    return setmetatable({
        Gui = gui,
        Main = main,
        Name = name,
        Theme = Theme
    }, Library)
end

function Library:AddTab(name, icon)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -8, 0, 36)
    button.BackgroundColor3 = Theme.BG1
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = self.Sidebar
    
    Util:AddCorner(button, 5)
    local buttonStroke = Util:AddStroke(button, Color3.fromRGB(30, 30, 30), 1)
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 1, -8)
    indicator.Position = UDim2.new(0, 4, 0, 4)
    indicator.BackgroundColor3 = Theme.Accent
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.Parent = button
    
    Util:AddCorner(indicator, 2)
    
    local iconLabel = Instance.new("ImageLabel")
    iconLabel.Size = UDim2.new(0, 18, 0, 18)
    iconLabel.Position = UDim2.new(0, 12, 0.5, -9)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Image = icon or ""
    iconLabel.ImageColor3 = Theme.TextDim
    iconLabel.Parent = button
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 36, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Theme.TextDim
    label.TextSize = 12
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button
    
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -16, 1, -16)
    container.Position = UDim2.new(0, 8, 0, 8)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 3
    container.ScrollBarImageColor3 = Theme.Accent
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.Visible = false
    container.Parent = self.Content
    
    local leftColumn = Instance.new("Frame")
    leftColumn.Size = UDim2.new(0.5, -4, 1, 0)
    leftColumn.Position = UDim2.new(0, 0, 0, 0)
    leftColumn.BackgroundTransparency = 1
    leftColumn.Parent = container
    
    local leftLayout = Instance.new("UIListLayout")
    leftLayout.Padding = UDim.new(0, 8)
    leftLayout.Parent = leftColumn
    
    local rightColumn = Instance.new("Frame")
    rightColumn.Size = UDim2.new(0.5, -4, 1, 0)
    rightColumn.Position = UDim2.new(0.5, 4, 0, 0)
    rightColumn.BackgroundTransparency = 1
    rightColumn.Parent = container
    
    local rightLayout = Instance.new("UIListLayout")
    rightLayout.Padding = UDim.new(0, 8)
    rightLayout.Parent = rightColumn
    
    local function updateCanvasSize()
        local leftHeight = leftLayout.AbsoluteContentSize.Y
        local rightHeight = rightLayout.AbsoluteContentSize.Y
        local maxHeight = math.max(leftHeight, rightHeight)
        container.CanvasSize = UDim2.new(0, 0, 0, maxHeight + 16)
    end
    
    leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
    rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
    
    button.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Tabs) do
            Util:Tween(tab.Button, {BackgroundColor3 = Theme.BG1}, 0.15)
            tab.Indicator.Visible = false
            Util:Tween(tab.Icon, {ImageColor3 = Theme.TextDim}, 0.15)
            Util:Tween(tab.Label, {TextColor3 = Theme.TextDim}, 0.15)
            tab.Container.Visible = false
            Util:Tween(tab.Stroke, {Color = Color3.fromRGB(30, 30, 30), Transparency = 0}, 0.15)
        end
        
        Util:Tween(button, {BackgroundColor3 = Color3.fromRGB(18, 18, 22)}, 0.15)
        indicator.Visible = true
        Util:Tween(iconLabel, {ImageColor3 = Theme.Accent}, 0.15)
        Util:Tween(label, {TextColor3 = Theme.Text}, 0.15)
        container.Visible = true
        Util:Tween(buttonStroke, {Color = Theme.Accent, Transparency = 0}, 0.15)
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
            Util:Tween(button, {BackgroundColor3 = Theme.BG1}, 0.1)
            Util:Tween(label, {TextColor3 = Theme.TextDim}, 0.1)
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
        Stroke = buttonStroke
    }
    
    self.Tabs[name] = tab
    
    if not self.CurrentTab then
        button.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        indicator.Visible = true
        iconLabel.ImageColor3 = Theme.Accent
        label.TextColor3 = Theme.Text
        container.Visible = true
        buttonStroke.Color = Theme.Accent
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
    section.Size = UDim2.new(1, 0, 0, 0)
    section.BackgroundColor3 = Theme.BG2
    section.BorderSizePixel = 0
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.Parent = targetColumn
    
    Util:AddCorner(section, 5)
    local sectionStroke = Util:AddStroke(section, Theme.Border, 1)
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 32)
    header.BackgroundTransparency = 1
    header.Parent = section
    
    local headerLabel = Instance.new("TextLabel")
    headerLabel.Size = UDim2.new(1, -20, 1, 0)
    headerLabel.Position = UDim2.new(0, 10, 0, 0)
    headerLabel.BackgroundTransparency = 1
    headerLabel.Text = name
    headerLabel.TextColor3 = Theme.Text
    headerLabel.TextSize = 13
    headerLabel.Font = Enum.Font.GothamBold
    headerLabel.TextXAlignment = Enum.TextXAlignment.Left
    headerLabel.Parent = header
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.Position = UDim2.new(0, 0, 0, 32)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = section
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = container
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.PaddingTop = UDim.new(0, 4)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = container
    
    section.MouseEnter:Connect(function()
        Util:Tween(sectionStroke, {Color = Theme.Accent}, 0.15)
    end)
    
    section.MouseLeave:Connect(function()
        Util:Tween(sectionStroke, {Color = Theme.Border}, 0.15)
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
    label.TextColor3 = Theme.TextDim
    label.TextSize = 11
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
    button.Size = UDim2.new(1, 0, 0, 34)
    button.BackgroundColor3 = Theme.BG3
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = Theme.Text
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = self.Container
    
    Util:AddCorner(button, 5)
    Util:AddStroke(button, Theme.Border, 1)
    
    button.MouseEnter:Connect(function()
        Util:Tween(button, {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}, 0.1)
    end)
    
    button.MouseLeave:Connect(function()
        Util:Tween(button, {BackgroundColor3 = Theme.BG3}, 0.1)
    end)
    
    button.MouseButton1Click:Connect(function()
        Util:Tween(button, {BackgroundColor3 = Theme.Accent}, 0.05)
        task.wait(0.1)
        Util:Tween(button, {BackgroundColor3 = Theme.BG3}, 0.15)
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
    frame.Size = UDim2.new(1, 0, 0, 52)
    frame.BackgroundColor3 = Theme.BG3
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    
    Util:AddCorner(frame, 5)
    Util:AddStroke(frame, Theme.Border, 1)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 0, 18)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Theme.TextDim
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 0, 24)
    input.Position = UDim2.new(0, 10, 0, 24)
    input.BackgroundColor3 = Theme.BG1
    input.BorderSizePixel = 0
    input.Text = default
    input.PlaceholderText = placeholder
    input.TextColor3 = Theme.Text
    input.PlaceholderColor3 = Theme.TextDim
    input.TextSize = 11
    input.Font = Enum.Font.Gotham
    input.ClearTextOnFocus = false
    input.Parent = frame
    
    local inputPadding = Instance.new("UIPadding")
    inputPadding.PaddingLeft = UDim.new(0, 8)
    inputPadding.PaddingRight = UDim.new(0, 8)
    inputPadding.Parent = input
    
    Util:AddCorner(input, 4)
    Util:AddStroke(input, Theme.Border, 1)
    
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

function Library:AddSlider(options)
    options = options or {}
    local name = options.Name or "Slider"
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local increment = options.Increment or 1
    local flag = options.Flag
    local callback = options.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Theme.BG3
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    
    Util:AddCorner(frame, 5)
    Util:AddStroke(frame, Theme.Border, 1)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 0, 18)
    label.Position = UDim2.new(0, 10, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Theme.TextDim
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 60, 0, 18)
    valueLabel.Position = UDim2.new(1, -65, 0, 6)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Theme.Accent
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local sliderBack = Instance.new("Frame")
    sliderBack.Size = UDim2.new(1, -20, 0, 6)
    sliderBack.Position = UDim2.new(0, 10, 0, 32)
    sliderBack.BackgroundColor3 = Theme.BG1
    sliderBack.BorderSizePixel = 0
    sliderBack.Parent = frame
    
    Util:AddCorner(sliderBack, 3)
    Util:AddStroke(sliderBack, Theme.Border, 1)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBack
    
    Util:AddCorner(sliderFill, 3)
    
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Size = UDim2.new(0, 12, 0, 12)
    sliderKnob.Position = UDim2.new(1, -6, 0.5, -6)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.BorderSizePixel = 0
    sliderKnob.Parent = sliderFill
    
    Util:AddCorner(sliderKnob, 6)
    Util:AddStroke(sliderKnob, Theme.Accent, 2)
    
    local value = default
    local dragging = false
    
    if flag then
        Library.Flags[flag] = value
        Library.Callbacks[flag] = callback
    end
    
    local function set(v)
        v = math.clamp(v, min, max)
        v = math.floor(v / increment + 0.5) * increment
        value = v
        
        local percent = (v - min) / (max - min)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        valueLabel.Text = tostring(v)
        
        if flag then
            Library.Flags[flag] = v
        end
        callback(v)
    end
    
    sliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local mouse = input.Position
            local pos = (mouse.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X
            set(min + (max - min) * math.clamp(pos, 0, 1))
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = input.Position
            local pos = (mouse.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X
            set(min + (max - min) * math.clamp(pos, 0, 1))
        end
    end)
    
    set(default)
    
    return {
        SetValue = set,
        GetValue = function() return value end
    }
end

function Library:AddToggle(options)
    options = options or {}
    local name = options.Name or "Toggle"
    local flag = options.Flag
    local default = options.Default or false
    local callback = options.Callback or function() end
    local mode = "Toggle"
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundColor3 = Theme.BG3
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    
    Util:AddCorner(frame, 5)
    Util:AddStroke(frame, Theme.Border, 1)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Theme.Text
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 18, 0, 18)
    checkbox.Position = UDim2.new(1, -26, 0.5, -9)
    checkbox.BackgroundColor3 = Theme.BG1
    checkbox.BorderSizePixel = 0
    checkbox.Text = ""
    checkbox.AutoButtonColor = false
    checkbox.Parent = frame
    
    Util:AddCorner(checkbox, 4)
    Util:AddStroke(checkbox, Theme.Border, 1)
    
    local check = Instance.new("ImageLabel")
    check.Size = UDim2.new(0, 12, 0, 12)
    check.Position = UDim2.new(0.5, -6, 0.5, -6)
    check.BackgroundTransparency = 1
    check.Image = "rbxassetid://3926305904"
    check.ImageRectOffset = Vector2.new(312, 4)
    check.ImageRectSize = Vector2.new(24, 24)
    check.ImageColor3 = Theme.Accent
    check.Visible = default
    check.Parent = checkbox
    
    local state = default
    
    if flag then
        Library.Flags[flag] = state
        Library.Callbacks[flag] = callback
    end
    
    local function set(v)
        state = v
        check.Visible = state
        
        if state then
            Util:Tween(checkbox, {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}, 0.15)
        else
            Util:Tween(checkbox, {BackgroundColor3 = Theme.BG1}, 0.15)
        end
        
        if flag then
            Library.Flags[flag] = state
        end
        callback(state)
    end
    
    set(default)
    
    checkbox.MouseButton1Click:Connect(function()
        if mode == "Toggle" then
            set(not state)
        elseif mode == "Always" then
            set(true)
        end
    end)
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            local menu = Instance.new("Frame")
            menu.Size = UDim2.new(0, 100, 0, 0)
            menu.Position = UDim2.new(0, frame.AbsolutePosition.X, 0, frame.AbsolutePosition.Y + 35)
            menu.BackgroundColor3 = Theme.BG2
            menu.BorderSizePixel = 0
            menu.ZIndex = 100
            menu.Parent = Library.Gui
            
            Util:AddCorner(menu, 4)
            Util:AddStroke(menu, Theme.Accent, 1)
            
            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 2)
            layout.Parent = menu
            
            local modes = {"Toggle", "Hold", "Always"}
            for _, m in ipairs(modes) do
                local opt = Instance.new("TextButton")
                opt.Size = UDim2.new(1, 0, 0, 22)
                opt.BackgroundColor3 = Theme.BG2
                opt.BorderSizePixel = 0
                opt.Text = m
                opt.TextColor3 = Theme.Text
                opt.TextSize = 11
                opt.Font = Enum.Font.Gotham
                opt.AutoButtonColor = false
                opt.ZIndex = 101
                opt.Parent = menu
                
                opt.MouseEnter:Connect(function()
                    Util:Tween(opt, {BackgroundColor3 = Theme.BG3}, 0.1)
                end)
                
                opt.MouseLeave:Connect(function()
                    Util:Tween(opt, {BackgroundColor3 = Theme.BG2}, 0.1)
                end)
                
                opt.MouseButton1Click:Connect(function()
                    mode = m
                    if m == "Always" then set(true) end
                    Library:Notify("Mode", "Set to " .. m, 1)
                    menu:Destroy()
                end)
            end
            
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                menu.Size = UDim2.new(0, 100, 0, layout.AbsoluteContentSize.Y + 4)
            end)
            
            task.delay(3, function()
                if menu.Parent then menu:Destroy() end
            end)
        end
    end)
    
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
    frame.Size = UDim2.new(1, 0, 0, 52)
    frame.BackgroundColor3 = Theme.BG3
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    frame.ZIndex = 5
    
    Util:AddCorner(frame, 5)
    Util:AddStroke(frame, Theme.Border, 1)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 0, 18)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Theme.TextDim
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 6
    label.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 24)
    button.Position = UDim2.new(0, 10, 0, 24)
    button.BackgroundColor3 = Theme.BG1
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.ZIndex = 7
    button.Parent = frame
    
    Util:AddCorner(button, 4)
    Util:AddStroke(button, Theme.Border, 1)
    
    local selected = Instance.new("TextLabel")
    selected.Size = UDim2.new(1, -32, 1, 0)
    selected.Position = UDim2.new(0, 8, 0, 0)
    selected.BackgroundTransparency = 1
    selected.Text = default or "Select..."
    selected.TextColor3 = Theme.Text
    selected.TextSize = 11
    selected.Font = Enum.Font.Gotham
    selected.TextXAlignment = Enum.TextXAlignment.Left
    selected.TextTruncate = Enum.TextTruncate.AtEnd
    selected.ZIndex = 8
    selected.Parent = button
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -22, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Theme.TextDim
    arrow.TextSize = 9
    arrow.Font = Enum.Font.GothamBold
    arrow.ZIndex = 8
    arrow.Parent = button
    
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(1, -20, 0, 0)
    dropdown.Position = UDim2.new(0, 10, 1, 4)
    dropdown.BackgroundColor3 = Theme.BG1
    dropdown.BorderSizePixel = 0
    dropdown.Visible = false
    dropdown.ZIndex = 150
    dropdown.ClipsDescendants = true
    dropdown.Parent = frame
    
    Util:AddCorner(dropdown, 4)
    Util:AddStroke(dropdown, Theme.Accent, 1)
    
    local dropContainer = Instance.new("ScrollingFrame")
    dropContainer.Size = UDim2.new(1, 0, 1, 0)
    dropContainer.BackgroundTransparency = 1
    dropContainer.BorderSizePixel = 0
    dropContainer.ScrollBarThickness = 3
    dropContainer.ScrollBarImageColor3 = Theme.Accent
    dropContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    dropContainer.ZIndex = 151
    dropContainer.Parent = dropdown
    
    local dropLayout = Instance.new("UIListLayout")
    dropLayout.Padding = UDim.new(0, 1)
    dropLayout.Parent = dropContainer
    
    local value = default
    local open = false
    
    if flag then
        Library.Flags[flag] = value
        Library.Callbacks[flag] = callback
    end
    
    local function refresh(newList)
        for _, child in pairs(dropContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for _, item in pairs(newList) do
            local option = Instance.new("TextButton")
            option.Size = UDim2.new(1, 0, 0, 24)
            option.BackgroundColor3 = Theme.BG1
            option.BorderSizePixel = 0
            option.Text = item
            option.TextColor3 = Theme.Text
            option.TextSize = 11
            option.Font = Enum.Font.Gotham
            option.TextXAlignment = Enum.TextXAlignment.Left
            option.TextPadding = Vector2.new(8, 0)
            option.AutoButtonColor = false
            option.ZIndex = 152
            option.Parent = dropContainer
            
            local optPadding = Instance.new("UIPadding")
            optPadding.PaddingLeft = UDim.new(0, 8)
            optPadding.Parent = option
            
            option.MouseEnter:Connect(function()
                Util:Tween(option, {BackgroundColor3 = Theme.BG3}, 0.1)
            end)
            
            option.MouseLeave:Connect(function()
                Util:Tween(option, {BackgroundColor3 = Theme.BG1}, 0.1)
            end)
            
            option.MouseButton1Click:Connect(function()
                value = item
                selected.Text = item
                
                if flag then
                    Library.Flags[flag] = value
                end
                
                callback(value)
                
                open = false
                Util:Tween(dropdown, {Size = UDim2.new(1, -20, 0, 0)}, 0.15)
                task.wait(0.15)
                dropdown.Visible = false
                arrow.Text = "▼"
            end)
        end
        
        dropLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            dropContainer.CanvasSize = UDim2.new(0, 0, 0, dropLayout.AbsoluteContentSize.Y)
        end)
        
        local height = math.min(#newList * 25, 120)
        if open then
            dropdown.Size = UDim2.new(1, -20, 0, height)
        end
    end
    
    button.MouseButton1Click:Connect(function()
        open = not open
        
        if open then
            dropdown.Visible = true
            local height = math.min(#list * 25, 120)
            Util:Tween(dropdown, {Size = UDim2.new(1, -20, 0, height)}, 0.15)
            arrow.Text = "▲"
            dropdown.ZIndex = 150
            frame.ZIndex = 150
        else
            Util:Tween(dropdown, {Size = UDim2.new(1, -20, 0, 0)}, 0.15)
            task.wait(0.15)
            dropdown.Visible = false
            arrow.Text = "▼"
            dropdown.ZIndex = 5
            frame.ZIndex = 5
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
    frame.Size = UDim2.new(1, 0, 0, 52)
    frame.BackgroundColor3 = Theme.BG3
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    frame.ZIndex = 5
    
    Util:AddCorner(frame, 5)
    Util:AddStroke(frame, Theme.Border, 1)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 0, 18)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Theme.TextDim
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 6
    label.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 24)
    button.Position = UDim2.new(0, 10, 0, 24)
    button.BackgroundColor3 = Theme.BG1
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.ZIndex = 7
    button.Parent = frame
    
    Util:AddCorner(button, 4)
    Util:AddStroke(button, Theme.Border, 1)
    
    local selected = Instance.new("TextLabel")
    selected.Size = UDim2.new(1, -32, 1, 0)
    selected.Position = UDim2.new(0, 8, 0, 0)
    selected.BackgroundTransparency = 1
    selected.Text = "Select..."
    selected.TextColor3 = Theme.Text
    selected.TextSize = 11
    selected.Font = Enum.Font.Gotham
    selected.TextXAlignment = Enum.TextXAlignment.Left
    selected.TextTruncate = Enum.TextTruncate.AtEnd
    selected.ZIndex = 8
    selected.Parent = button
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -22, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Theme.TextDim
    arrow.TextSize = 9
    arrow.Font = Enum.Font.GothamBold
    arrow.ZIndex = 8
    arrow.Parent = button
    
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(1, -20, 0, 0)
    dropdown.Position = UDim2.new(0, 10, 1, 4)
    dropdown.BackgroundColor3 = Theme.BG1
    dropdown.BorderSizePixel = 0
    dropdown.Visible = false
    dropdown.ZIndex = 150
    dropdown.ClipsDescendants = true
    dropdown.Parent = frame
    
    Util:AddCorner(dropdown, 4)
    Util:AddStroke(dropdown, Theme.Accent, 1)
    
    local dropContainer = Instance.new("ScrollingFrame")
    dropContainer.Size = UDim2.new(1, 0, 1, 0)
    dropContainer.BackgroundTransparency = 1
    dropContainer.BorderSizePixel = 0
    dropContainer.ScrollBarThickness = 3
    dropContainer.ScrollBarImageColor3 = Theme.Accent
    dropContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    dropContainer.ZIndex = 151
    dropContainer.Parent = dropdown
    
    local dropLayout = Instance.new("UIListLayout")
    dropLayout.Padding = UDim.new(0, 1)
    dropLayout.Parent = dropContainer
    
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
        for _, child in pairs(dropContainer:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        for _, item in pairs(newList) do
            local option = Instance.new("Frame")
            option.Size = UDim2.new(1, 0, 0, 24)
            option.BackgroundColor3 = Theme.BG1
            option.BorderSizePixel = 0
            option.ZIndex = 152
            option.Parent = dropContainer
            
            local optButton = Instance.new("TextButton")
            optButton.Size = UDim2.new(1, -28, 1, 0)
            optButton.Position = UDim2.new(0, 8, 0, 0)
            optButton.BackgroundTransparency = 1
            optButton.Text = item
            optButton.TextColor3 = Theme.Text
            optButton.TextSize = 11
            optButton.Font = Enum.Font.Gotham
            optButton.TextXAlignment = Enum.TextXAlignment.Left
            optButton.AutoButtonColor = false
            optButton.ZIndex = 153
            optButton.Parent = option
            
            local check = Instance.new("Frame")
            check.Size = UDim2.new(0, 14, 0, 14)
            check.Position = UDim2.new(1, -20, 0.5, -7)
            check.BackgroundColor3 = Theme.BG3
            check.BorderSizePixel = 0
            check.ZIndex = 153
            check.Parent = option
            
            Util:AddCorner(check, 3)
            Util:AddStroke(check, Theme.Border, 1)
            
            local checkmark = Instance.new("ImageLabel")
            checkmark.Size = UDim2.new(0, 10, 0, 10)
            checkmark.Position = UDim2.new(0.5, -5, 0.5, -5)
            checkmark.BackgroundTransparency = 1
            checkmark.Image = "rbxassetid://3926305904"
            checkmark.ImageRectOffset = Vector2.new(312, 4)
            checkmark.ImageRectSize = Vector2.new(24, 24)
            checkmark.ImageColor3 = Theme.Accent
            checkmark.Visible = values[item] or false
            checkmark.ZIndex = 154
            checkmark.Parent = check
            
            optButton.MouseEnter:Connect(function()
                Util:Tween(option, {BackgroundColor3 = Theme.BG3}, 0.1)
            end)
            
            optButton.MouseLeave:Connect(function()
                Util:Tween(option, {BackgroundColor3 = Theme.BG1}, 0.1)
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
            dropContainer.CanvasSize = UDim2.new(0, 0, 0, dropLayout.AbsoluteContentSize.Y)
        end)
    end
    
    button.MouseButton1Click:Connect(function()
        open = not open
        
        if open then
            dropdown.Visible = true
            local height = math.min(dropLayout.AbsoluteContentSize.Y, 120)
            Util:Tween(dropdown, {Size = UDim2.new(1, -20, 0, height)}, 0.15)
            arrow.Text = "▲"
            dropdown.ZIndex = 150
            frame.ZIndex = 150
        else
            Util:Tween(dropdown, {Size = UDim2.new(1, -20, 0, 0)}, 0.15)
            task.wait(0.15)
            dropdown.Visible = false
            arrow.Text = "▼"
            dropdown.ZIndex = 5
            frame.ZIndex = 5
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
    local showInList = options.ShowInList ~= false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundColor3 = Theme.BG3
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    
    Util:AddCorner(frame, 5)
    Util:AddStroke(frame, Theme.Border, 1)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -90, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Theme.Text
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local modeLabel = Instance.new("TextLabel")
    modeLabel.Size = UDim2.new(0, 40, 0, 14)
    modeLabel.Position = UDim2.new(1, -116, 0.5, -7)
    modeLabel.BackgroundColor3 = Theme.BG1
    modeLabel.BorderSizePixel = 0
    modeLabel.Text = mode:sub(1, 1)
    modeLabel.TextColor3 = Theme.Accent
    modeLabel.TextSize = 10
    modeLabel.Font = Enum.Font.GothamBold
    modeLabel.Parent = frame
    
    Util:AddCorner(modeLabel, 3)
    Util:AddStroke(modeLabel, Theme.Border, 1)
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 60, 0, 20)
    button.Position = UDim2.new(1, -68, 0.5, -10)
    button.BackgroundColor3 = Theme.BG1
    button.BorderSizePixel = 0
    button.Text = default and default.Name or "None"
    button.TextColor3 = Theme.Text
    button.TextSize = 10
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = false
    button.Parent = frame
    
    Util:AddCorner(button, 4)
    Util:AddStroke(button, Theme.Border, 1)
    
    local currentKey = default
    local listening = false
    local active = false
    local keybindElement = nil
    
    if flag then
        Library.Flags[flag] = {Key = currentKey, Active = active, Mode = mode}
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
                if input.KeyCode == Enum.KeyCode.Escape then
                    currentKey = nil
                    button.Text = "None"
                    if keybindElement and Library.KeybindListContainer then
                        keybindElement:Destroy()
                        keybindElement = nil
                    end
                else
                    currentKey = input.KeyCode
                    button.Text = input.KeyCode.Name
                end
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
                
                if showInList and Library.KeybindListContainer then
                    if active and not keybindElement then
                        keybindElement = Library:CreateKeybindList().AddKeybind(name, currentKey, mode)
                    elseif not active and keybindElement then
                        keybindElement:Destroy()
                        keybindElement = nil
                    end
                end
            else
                active = true
                if flag then Library.Flags[flag].Active = true end
                callback(true, currentKey)
                
                if showInList and Library.KeybindListContainer and not keybindElement then
                    keybindElement = Library:CreateKeybindList().AddKeybind(name, currentKey, mode)
                end
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
                
                if showInList and keybindElement then
                    keybindElement:Destroy()
                    keybindElement = nil
                end
            end
        end
    end)
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            local menu = Instance.new("Frame")
            menu.Size = UDim2.new(0, 100, 0, 0)
            menu.Position = UDim2.new(0, frame.AbsolutePosition.X, 0, frame.AbsolutePosition.Y + 35)
            menu.BackgroundColor3 = Theme.BG2
            menu.BorderSizePixel = 0
            menu.ZIndex = 100
            menu.Parent = Library.Gui
            
            Util:AddCorner(menu, 4)
            Util:AddStroke(menu, Theme.Accent, 1)
            
            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 2)
            layout.Parent = menu
            
            local modes = {"Toggle", "Hold"}
            for _, m in ipairs(modes) do
                local opt = Instance.new("TextButton")
                opt.Size = UDim2.new(1, 0, 0, 22)
                opt.BackgroundColor3 = Theme.BG2
                opt.BorderSizePixel = 0
                opt.Text = m
                opt.TextColor3 = Theme.Text
                opt.TextSize = 11
                opt.Font = Enum.Font.Gotham
                opt.AutoButtonColor = false
                opt.ZIndex = 101
                opt.Parent = menu
                
                opt.MouseEnter:Connect(function()
                    Util:Tween(opt, {BackgroundColor3 = Theme.BG3}, 0.1)
                end)
                
                opt.MouseLeave:Connect(function()
                    Util:Tween(opt, {BackgroundColor3 = Theme.BG2}, 0.1)
                end)
                
                opt.MouseButton1Click:Connect(function()
                    mode = m
                    modeLabel.Text = m:sub(1, 1)
                    if flag then Library.Flags[flag].Mode = m end
                    Library:Notify("Mode", "Set to " .. m, 1)
                    menu:Destroy()
                end)
            end
            
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                menu.Size = UDim2.new(0, 100, 0, layout.AbsoluteContentSize.Y + 4)
            end)
            
            task.delay(3, function()
                if menu.Parent then menu:Destroy() end
            end)
        end
    end)
    
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

function Library:AddColorPicker(options)
    options = options or {}
    local name = options.Name or "Color"
    local default = options.Default or Color3.fromRGB(255, 255, 255)
    local flag = options.Flag
    local callback = options.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundColor3 = Theme.BG3
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    
    Util:AddCorner(frame, 5)
    Util:AddStroke(frame, Theme.Border, 1)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Theme.Text
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local colorDisplay = Instance.new("TextButton")
    colorDisplay.Size = UDim2.new(0, 32, 0, 18)
    colorDisplay.Position = UDim2.new(1, -40, 0.5, -9)
    colorDisplay.BackgroundColor3 = default
    colorDisplay.BorderSizePixel = 0
    colorDisplay.Text = ""
    colorDisplay.AutoButtonColor = false
    colorDisplay.ZIndex = 5
    colorDisplay.Parent = frame
    
    Util:AddCorner(colorDisplay, 4)
    Util:AddStroke(colorDisplay, Theme.Border, 1)
    
    local pickerOpen = false
    local currentColor = default
    
    local picker = Instance.new("Frame")
    picker.Size = UDim2.new(0, 200, 0, 180)
    picker.Position = UDim2.new(1, 8, 0, 0)
    picker.BackgroundColor3 = Theme.BG2
    picker.BorderSizePixel = 0
    picker.Visible = false
    picker.ZIndex = 200
    picker.Parent = frame
    
    Util:AddCorner(picker, 5)
    Util:AddStroke(picker, Theme.Accent, 1.5)
    
    local saturationFrame = Instance.new("Frame")
    saturationFrame.Size = UDim2.new(1, -20, 0, 120)
    saturationFrame.Position = UDim2.new(0, 10, 0, 10)
    saturationFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    saturationFrame.BorderSizePixel = 0
    saturationFrame.ZIndex = 201
    saturationFrame.Parent = picker
    
    Util:AddCorner(saturationFrame, 4)
    
    local saturationWhite = Instance.new("Frame")
    saturationWhite.Size = UDim2.new(1, 0, 1, 0)
    saturationWhite.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    saturationWhite.BackgroundTransparency = 0
    saturationWhite.BorderSizePixel = 0
    saturationWhite.ZIndex = 202
    saturationWhite.Parent = saturationFrame
    
    Util:AddCorner(saturationWhite, 4)
    
    local whiteGradient = Instance.new("UIGradient")
    whiteGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    }
    whiteGradient.Parent = saturationWhite
    
    local saturationBlack = Instance.new("Frame")
    saturationBlack.Size = UDim2.new(1, 0, 1, 0)
    saturationBlack.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    saturationBlack.BackgroundTransparency = 0
    saturationBlack.BorderSizePixel = 0
    saturationBlack.ZIndex = 203
    saturationBlack.Parent = saturationFrame
    
    Util:AddCorner(saturationBlack, 4)
    
    local blackGradient = Instance.new("UIGradient")
    blackGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    }
    blackGradient.Rotation = 90
    blackGradient.Parent = saturationBlack
    
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
    hexFrame.Size = UDim2.new(1, -20, 0, 18)
    hexFrame.Position = UDim2.new(0, 10, 0, 160)
    hexFrame.BackgroundColor3 = Theme.BG1
    hexFrame.BorderSizePixel = 0
    hexFrame.ZIndex = 201
    hexFrame.Parent = picker
    
    Util:AddCorner(hexFrame, 4)
    Util:AddStroke(hexFrame, Theme.Border, 1)
    
    local hexInput = Instance.new("TextBox")
    hexInput.Size = UDim2.new(1, -10, 1, 0)
    hexInput.Position = UDim2.new(0, 5, 0, 0)
    hexInput.BackgroundTransparency = 1
    hexInput.Text = "#FFFFFF"
    hexInput.TextColor3 = Theme.Text
    hexInput.TextSize = 10
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

function Library:SaveConfig(name)
    local config = {}
    for flag, value in pairs(self.Flags) do
        if type(value) == "table" and value.R then
            config[flag] = {R = value.R, G = value.G, B = value.B}
        elseif type(value) == "userdata" then
            config[flag] = {Name = tostring(value)}
        else
            config[flag] = value
        end
    end
    
    local success = pcall(function()
        if not isfolder("ClubConfigs") then
            makefolder("ClubConfigs")
        end
        writefile("ClubConfigs/" .. name .. ".json", HttpService:JSONEncode(config))
    end)
    
    if success then
        Library:Notify("Success", "Configuration saved", 2)
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
                if type(value) == "table" and value.R then
                    self.Flags[flag] = Color3.new(value.R, value.G, value.B)
                else
                    self.Flags[flag] = value
                end
                if self.Callbacks[flag] then
                    self.Callbacks[flag](self.Flags[flag])
                end
            end
        end
    end)
    
    if success then
        Library:Notify("Success", "Configuration loaded", 2)
    else
        Library:Notify("Error", "Failed to load config", 2)
    end
end

function Library:UpdateTheme(newTheme)
    for k, v in pairs(newTheme) do
        if Theme[k] then
            Theme[k] = v
        end
    end
    Library:Notify("Theme", "Theme updated", 1.5)
end

return Library
