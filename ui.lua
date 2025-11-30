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

function Util:Resize(frame)
    local resizing, startPos, startSize
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 10, 0, 10)
    handle.Position = UDim2.new(1, -10, 1, -10)
    handle.BackgroundTransparency = 1
    handle.Parent = frame
    
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
            frame.Size = UDim2.new(0, math.max(500, startSize.X.Offset + delta.X), 0, math.max(400, startSize.Y.Offset + delta.Y))
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

function Library:Notify(title, text, duration)
    local gui = Instance.new("ScreenGui")
    gui.Name = "Notification"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 0)
    frame.Position = UDim2.new(1, -290, 1, 10)
    frame.BackgroundColor3 = BG2
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = gui
    
    Util:AddCorner(frame, 6)
    Util:AddStroke(frame, BORDER)
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.BackgroundColor3 = ACCENT
    accent.BorderSizePixel = 0
    accent.Parent = frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = TEXT
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 0, 30)
    textLabel.Position = UDim2.new(0, 10, 0, 30)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = TEXT_DIM
    textLabel.TextSize = 11
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Parent = frame
    
    Util:Tween(frame, {Size = UDim2.new(0, 280, 0, 70), Position = UDim2.new(1, -290, 1, -80)}, 0.3)
    
    task.delay(duration or 3, function()
        Util:Tween(frame, {Position = UDim2.new(1, -290, 1, 10)}, 0.3)
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
    frame.Size = UDim2.new(0, 200, 0, 25)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = BG2
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    Util:AddCorner(frame, 4)
    Util:AddStroke(frame, BORDER)
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.BackgroundColor3 = ACCENT
    accent.BorderSizePixel = 0
    accent.Parent = frame
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -10, 1, -2)
    text.Position = UDim2.new(0, 5, 0, 2)
    text.BackgroundTransparency = 1
    text.TextColor3 = TEXT
    text.TextSize = 11
    text.Font = Enum.Font.GothamBold
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = frame
    
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
        
        local parts = {}
        if options.ShowFPS ~= false then table.insert(parts, "FPS: " .. fps) end
        if options.ShowPing ~= false then 
            local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            table.insert(parts, "PING: " .. ping .. "ms")
        end
        if options.ShowTime ~= false then table.insert(parts, os.date("%H:%M:%S")) end
        
        text.Text = table.concat(parts, " | ")
    end)
    
    return {
        SetVisible = function(v) frame.Visible = v end,
        SetOptions = function(o) options = o end
    }
end

function Library:CreateKeybindList()
    local gui = Instance.new("ScreenGui")
    gui.Name = "KeybindList"
    gui.Parent = CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 180, 0, 30)
    frame.Position = UDim2.new(1, -190, 0, 50)
    frame.BackgroundColor3 = BG2
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = gui
    
    Util:AddCorner(frame, 6)
    Util:AddStroke(frame, BORDER)
    Util:Drag(frame, frame)
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.BackgroundColor3 = ACCENT
    accent.BorderSizePixel = 0
    accent.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "Keybinds"
    title.TextColor3 = TEXT
    title.TextSize = 12
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 3)
    list.Parent = frame
    
    return {Frame = frame, Keybinds = {}}
end

function Library:Create(options)
    options = options or {}
    local name = options.Name or "Club Penguin"
    
    if options.AccentColor then
        ACCENT = options.AccentColor
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "MillenniumUI"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 650, 0, 450)
    main.Position = UDim2.new(0.5, -325, 0.5, -225)
    main.BackgroundColor3 = BG1
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    
    Util:AddCorner(main, 8)
    Util:AddStroke(main, BORDER, 1.5)
    Util:AddShadow(main)
    
    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, 0, 0, 40)
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
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = TEXT
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topbar
    
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 150, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = BG2
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    
    local sideStroke = Util:AddStroke(sidebar, BORDER)
    sideStroke.Transparency = 0.5
    
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 1, -10)
    tabContainer.Position = UDim2.new(0, 0, 0, 5)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = sidebar
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 2)
    tabLayout.Parent = tabContainer
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -150, 1, -40)
    content.Position = UDim2.new(0, 150, 0, 40)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    Util:Drag(main, topbar)
    Util:Resize(main)
    
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
    button.Size = UDim2.new(1, -10, 0, 35)
    button.BackgroundColor3 = BG3
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = self.Sidebar
    
    Util:AddCorner(button, 5)
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 2, 1, -8)
    indicator.Position = UDim2.new(0, 4, 0, 4)
    indicator.BackgroundColor3 = ACCENT
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.Parent = button
    
    Util:AddCorner(indicator, 2)
    
    local iconLabel = Instance.new("ImageLabel")
    iconLabel.Size = UDim2.new(0, 18, 0, 18)
    iconLabel.Position = UDim2.new(0, 12, 0.5, -9)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Image = icon or ""
    iconLabel.ImageColor3 = TEXT_DIM
    iconLabel.Parent = button
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -45, 1, 0)
    label.Position = UDim2.new(0, 40, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TEXT_DIM
    label.TextSize = 12
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button
    
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -20, 1, -20)
    container.Position = UDim2.new(0, 10, 0, 10)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 3
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
    leftLayout.Padding = UDim.new(0, 8)
    leftLayout.Parent = leftColumn
    
    local rightColumn = Instance.new("Frame")
    rightColumn.Size = UDim2.new(0.5, -5, 1, 0)
    rightColumn.Position = UDim2.new(0.5, 5, 0, 0)
    rightColumn.BackgroundTransparency = 1
    rightColumn.Parent = container
    
    local rightLayout = Instance.new("UIListLayout")
    rightLayout.Padding = UDim.new(0, 8)
    rightLayout.Parent = rightColumn
    
    local function updateCanvasSize()
        local leftHeight = leftLayout.AbsoluteContentSize.Y
        local rightHeight = rightLayout.AbsoluteContentSize.Y
        local maxHeight = math.max(leftHeight, rightHeight)
        container.CanvasSize = UDim2.new(0, 0, 0, maxHeight + 10)
    end
    
    leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
    rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
    
    button.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Tabs) do
            tab.Button.BackgroundColor3 = BG3
            tab.Indicator.Visible = false
            tab.Icon.ImageColor3 = TEXT_DIM
            tab.Label.TextColor3 = TEXT_DIM
            tab.Container.Visible = false
        end
        
        button.BackgroundColor3 = BG1
        indicator.Visible = true
        iconLabel.ImageColor3 = ACCENT
        label.TextColor3 = TEXT
        container.Visible = true
        self.CurrentTab = name
    end)
    
    button.MouseEnter:Connect(function()
        if self.CurrentTab ~= name then
            Util:Tween(button, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}, 0.1)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if self.CurrentTab ~= name then
            Util:Tween(button, {BackgroundColor3 = BG3}, 0.1)
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
        CurrentColumn = "left"
    }
    
    self.Tabs[name] = tab
    
    if not self.CurrentTab then
        button.BackgroundColor3 = BG1
        indicator.Visible = true
        iconLabel.ImageColor3 = ACCENT
        label.TextColor3 = TEXT
        container.Visible = true
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
    section.Size = UDim2.new(1, 0, 0, 40)
    section.BackgroundColor3 = BG2
    section.BorderSizePixel = 0
    section.Parent = targetColumn
    
    Util:AddCorner(section, 6)
    Util:AddStroke(section, BORDER)
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundTransparency = 1
    header.Parent = section
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TEXT
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = header
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 20, 0, 20)
    toggle.Position = UDim2.new(1, -28, 0, 5)
    toggle.BackgroundTransparency = 1
    toggle.Text = "▼"
    toggle.TextColor3 = TEXT_DIM
    toggle.TextSize = 10
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = header
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, -30)
    container.Position = UDim2.new(0, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
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
    
    local open = true
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        section.Size = UDim2.new(1, 0, 0, open and (layout.AbsoluteContentSize.Y + 46) or 40)
    end)
    
    toggle.MouseButton1Click:Connect(function()
        open = not open
        toggle.Text = open and "▼" or "▶"
        Util:Tween(section, {Size = UDim2.new(1, 0, 0, open and (layout.AbsoluteContentSize.Y + 46) or 40)}, 0.15)
    end)
    
    return {
        Frame = section,
        Container = container
    }
end

function Library:AddToggle(options)
    options = options or {}
    local name = options.Name or "Toggle"
    local flag = options.Flag
    local default = options.Default or false
    local callback = options.Callback or function() end
    local tooltip = options.Tooltip
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundColor3 = BG3
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    
    Util:AddCorner(frame, 5)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TEXT
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 36, 0, 18)
    toggle.Position = UDim2.new(1, -42, 0.5, -9)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.Parent = frame
    
    Util:AddCorner(toggle, 9)
    Util:AddStroke(toggle, BORDER)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    
    Util:AddCorner(knob, 7)
    
    local state = default
    
    if flag then
        Library.Flags[flag] = state
        Library.Callbacks[flag] = callback
    end
    
    local function set(v)
        state = v
        
        if state then
            Util:Tween(toggle, {BackgroundColor3 = ACCENT}, 0.15)
            Util:Tween(knob, {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.15)
        else
            Util:Tween(toggle, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.15)
            Util:Tween(knob, {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(200, 200, 200)}, 0.15)
        end
        
        if flag then
            Library.Flags[flag] = state
        end
        
        callback(state)
    end
    
    set(default)
    
    toggle.MouseButton1Click:Connect(function()
        set(not state)
    end)
    
    if tooltip then
        local info = Instance.new("TextButton")
        info.Size = UDim2.new(0, 14, 0, 14)
        info.Position = UDim2.new(1, -56, 0.5, -7)
        info.BackgroundColor3 = BG1
        info.BorderSizePixel = 0
        info.Text = "i"
        info.TextColor3 = TEXT_DIM
        info.TextSize = 10
        info.Font = Enum.Font.GothamBold
        info.Parent = frame
        
        Util:AddCorner(info, 7)
        Util:AddStroke(info, BORDER)
    end
    
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
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = BG3
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    
    Util:AddCorner(frame, 5)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 18)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TEXT_DIM
    label.TextSize = 10
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 24)
    button.Position = UDim2.new(0, 10, 0, 22)
    button.BackgroundColor3 = BG1
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = frame
    
    Util:AddCorner(button, 4)
    Util:AddStroke(button, BORDER)
    
    local selected = Instance.new("TextLabel")
    selected.Size = UDim2.new(1, -30, 1, 0)
    selected.Position = UDim2.new(0, 8, 0, 0)
    selected.BackgroundTransparency = 1
    selected.Text = default or "Select..."
    selected.TextColor3 = TEXT
    selected.TextSize = 11
    selected.Font = Enum.Font.Gotham
    selected.TextXAlignment = Enum.TextXAlignment.Left
    selected.TextTruncate = Enum.TextTruncate.AtEnd
    selected.Parent = button
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = TEXT_DIM
    arrow.TextSize = 9
    arrow.Font = Enum.Font.GothamBold
    arrow.Parent = button
    
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(1, -20, 0, 0)
    dropdown.Position = UDim2.new(0, 10, 1, 4)
    dropdown.BackgroundColor3 = BG1
    dropdown.BorderSizePixel = 0
    dropdown.Visible = false
    dropdown.ZIndex = 10
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
            option.Size = UDim2.new(1, 0, 0, 22)
            option.BackgroundColor3 = BG1
            option.BorderSizePixel = 0
            option.Text = item
            option.TextColor3 = TEXT
            option.TextSize = 10
            option.Font = Enum.Font.Gotham
            option.AutoButtonColor = false
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
                Util:Tween(dropdown, {Size = UDim2.new(1, -20, 0, 0)}, 0.15)
                task.wait(0.15)
                dropdown.Visible = false
                arrow.Text = "▼"
            end)
        end
        
        local height = math.min(#newList * 23, 130)
        if open then
            dropdown.Size = UDim2.new(1, -20, 0, height)
        end
    end
    
    button.MouseButton1Click:Connect(function()
        open = not open
        
        if open then
            dropdown.Visible = true
            local height = math.min(#list * 23, 130)
            Util:Tween(dropdown, {Size = UDim2.new(1, -20, 0, height)}, 0.15)
            arrow.Text = "▲"
        else
            Util:Tween(dropdown, {Size = UDim2.new(1, -20, 0, 0)}, 0.15)
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
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = BG3
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    
    Util:AddCorner(frame, 5)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 18)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TEXT_DIM
    label.TextSize = 10
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 24)
    button.Position = UDim2.new(0, 10, 0, 22)
    button.BackgroundColor3 = BG1
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = frame
    
    Util:AddCorner(button, 4)
    Util:AddStroke(button, BORDER)
    
    local selected = Instance.new("TextLabel")
    selected.Size = UDim2.new(1, -30, 1, 0)
    selected.Position = UDim2.new(0, 8, 0, 0)
    selected.BackgroundTransparency = 1
    selected.Text = "Select..."
    selected.TextColor3 = TEXT
    selected.TextSize = 11
    selected.Font = Enum.Font.Gotham
    selected.TextXAlignment = Enum.TextXAlignment.Left
    selected.TextTruncate = Enum.TextTruncate.AtEnd
    selected.Parent = button
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = TEXT_DIM
    arrow.TextSize = 9
    arrow.Font = Enum.Font.GothamBold
    arrow.Parent = button
    
    local dropdown = Instance.new("ScrollingFrame")
    dropdown.Size = UDim2.new(1, -20, 0, 0)
    dropdown.Position = UDim2.new(0, 10, 1, 4)
    dropdown.BackgroundColor3 = BG1
    dropdown.BorderSizePixel = 0
    dropdown.Visible = false
    dropdown.ZIndex = 10
    dropdown.ClipsDescendants = true
    dropdown.ScrollBarThickness = 3
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
            option.Size = UDim2.new(1, 0, 0, 22)
            option.BackgroundColor3 = BG1
            option.BorderSizePixel = 0
            option.Parent = dropdown
            
            local optButton = Instance.new("TextButton")
            optButton.Size = UDim2.new(1, -25, 1, 0)
            optButton.BackgroundTransparency = 1
            optButton.Text = item
            optButton.TextColor3 = TEXT
            optButton.TextSize = 10
            optButton.Font = Enum.Font.Gotham
            optButton.TextXAlignment = Enum.TextXAlignment.Left
            optButton.AutoButtonColor = false
            optButton.Parent = option
            
            local check = Instance.new("Frame")
            check.Size = UDim2.new(0, 12, 0, 12)
            check.Position = UDim2.new(1, -18, 0.5, -6)
            check.BackgroundColor3 = BG3
            check.BorderSizePixel = 0
            check.Parent = option
            
            Util:AddCorner(check, 3)
            Util:AddStroke(check, BORDER)
            
            local checkmark = Instance.new("TextLabel")
            checkmark.Size = UDim2.new(1, 0, 1, 0)
            checkmark.BackgroundTransparency = 1
            checkmark.Text = "✓"
            checkmark.TextColor3 = ACCENT
            checkmark.TextSize = 10
            checkmark.Font = Enum.Font.GothamBold
            checkmark.Visible = values[item] or false
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
            local height = math.min(dropLayout.AbsoluteContentSize.Y, 130)
            Util:Tween(dropdown, {Size = UDim2.new(1, -20, 0, height)}, 0.15)
            arrow.Text = "▲"
        else
            Util:Tween(dropdown, {Size = UDim2.new(1, -20, 0, 0)}, 0.15)
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
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundColor3 = BG3
    frame.BorderSizePixel = 0
    frame.Parent = self.Container
    
    Util:AddCorner(frame, 5)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -90, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = TEXT
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 70, 0, 20)
    button.Position = UDim2.new(1, -76, 0.5, -10)
    button.BackgroundColor3 = BG1
    button.BorderSizePixel = 0
    button.Text = default and default.Name or "None"
    button.TextColor3 = TEXT
    button.TextSize = 10
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
        if not isfolder("ClubPenguinConfigs") then
            makefolder("ClubPenguinConfigs")
        end
        writefile("ClubPenguinConfigs/" .. name .. ".json", HttpService:JSONEncode(config))
    end)
    
    if success then
        Library:Notify("Config Saved", "Configuration saved successfully", 2)
    else
        Library:Notify("Error", "Failed to save config", 2)
    end
end

function Library:LoadConfig(name)
    local success = pcall(function()
        local data = readfile("ClubPenguinConfigs/" .. name .. ".json")
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
        Library:Notify("Config Loaded", "Configuration loaded successfully", 2)
    else
        Library:Notify("Error", "Failed to load config", 2)
    end
end

function Library:AddConfigTab()
    local tab = self:AddTab("Config", "")
    
    local saveSection = tab:AddSection("Save Configuration")
    
    local nameBox = Instance.new("Frame")
    nameBox.Size = UDim2.new(1, 0, 0, 50)
    nameBox.BackgroundColor3 = BG3
    nameBox.BorderSizePixel = 0
    nameBox.Parent = saveSection.Container
    
    Util:AddCorner(nameBox, 5)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -20, 0, 18)
    nameLabel.Position = UDim2.new(0, 10, 0, 4)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Config Name"
    nameLabel.TextColor3 = TEXT_DIM
    nameLabel.TextSize = 10
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = nameBox
    
    local nameInput = Instance.new("TextBox")
    nameInput.Size = UDim2.new(1, -20, 0, 24)
    nameInput.Position = UDim2.new(0, 10, 0, 22)
    nameInput.BackgroundColor3 = BG1
    nameInput.BorderSizePixel = 0
    nameInput.Text = ""
    nameInput.PlaceholderText = "Enter config name..."
    nameInput.TextColor3 = TEXT
    nameInput.PlaceholderColor3 = TEXT_DIM
    nameInput.TextSize = 11
    nameInput.Font = Enum.Font.Gotham
    nameInput.ClearTextOnFocus = false
    nameInput.Parent = nameBox
    
    Util:AddCorner(nameInput, 4)
    Util:AddStroke(nameInput, BORDER)
    
    local configName = ""
    nameInput:GetPropertyChangedSignal("Text"):Connect(function()
        configName = nameInput.Text
    end)
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(1, 0, 0, 32)
    saveBtn.BackgroundColor3 = ACCENT
    saveBtn.BorderSizePixel = 0
    saveBtn.Text = "Save Config"
    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.TextSize = 12
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.AutoButtonColor = false
    saveBtn.Parent = saveSection.Container
    
    Util:AddCorner(saveBtn, 5)
    
    saveBtn.MouseButton1Click:Connect(function()
        if configName ~= "" then
            Library:SaveConfig(configName)
        else
            Library:Notify("Error", "Please enter a config name", 2)
        end
    end)
    
    local loadSection = tab:AddSection("Load Configuration")
    
    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(1, 0, 0, 32)
    loadBtn.BackgroundColor3 = ACCENT
    loadBtn.BorderSizePixel = 0
    loadBtn.Text = "Load Config"
    loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadBtn.TextSize = 12
    loadBtn.Font = Enum.Font.GothamBold
    loadBtn.AutoButtonColor = false
    loadBtn.Parent = loadSection.Container
    
    Util:AddCorner(loadBtn, 5)
    
    loadBtn.MouseButton1Click:Connect(function()
        if configName ~= "" then
            Library:LoadConfig(configName)
        else
            Library:Notify("Error", "Please enter a config name", 2)
        end
    end)
    
    return tab
end

return Library
