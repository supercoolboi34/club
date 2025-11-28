local club = {}
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")
local players = game:GetService("Players")

local killSwitchId = "Club_UI_Instance"
if _G[killSwitchId] then
    pcall(function()
        _G[killSwitchId]:Destroy()
    end)
    _G[killSwitchId] = nil
    task.wait(0.2)
end

local isMobile = userInputService.TouchEnabled and not userInputService.KeyboardEnabled

local function getExecutor()
    if identifyexecutor then
        return identifyexecutor()
    end
    return "Unknown"
end

local themes = {
    dark = {
        background = Color3.fromRGB(17, 17, 20),
        foreground = Color3.fromRGB(22, 22, 26),
        elevated = Color3.fromRGB(28, 28, 32),
        accent = Color3.fromRGB(119, 131, 255),
        accentDark = Color3.fromRGB(95, 105, 204),
        text = Color3.fromRGB(240, 240, 245),
        textDark = Color3.fromRGB(150, 150, 160),
        border = Color3.fromRGB(35, 35, 40),
        success = Color3.fromRGB(106, 192, 143),
        warning = Color3.fromRGB(255, 184, 108),
        error = Color3.fromRGB(237, 94, 94)
    }
}

local function create(class, properties)
    local instance = Instance.new(class)
    for prop, val in pairs(properties) do
        instance[prop] = val
    end
    return instance
end

local function tween(obj, props, duration, style, direction)
    tweenService:Create(
        obj,
        TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
        props
    ):Play()
end

local function addCorner(parent, radius)
    return create("UICorner", {
        Parent = parent,
        CornerRadius = UDim.new(0, radius or 6)
    })
end

local function addStroke(parent, color, thickness)
    return create("UIStroke", {
        Parent = parent,
        Color = color,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Transparency = 0
    })
end

function club:createWindow(config)
    config = config or {}
    local windowName = config.name or "club"
    local theme = themes.dark
    local configFile = config.configFile or "club_config.json"
    local savedConfig = {}
    local executorName = getExecutor()

    local screenGui = create("ScreenGui", {
        Name = "club_" .. httpService:GenerateGUID(false),
        Parent = game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })
    
    _G[killSwitchId] = screenGui

    local notificationHolder = create("Frame", {
        Name = "notifications",
        Parent = screenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -310, 1, -20),
        Size = UDim2.new(0, 300, 0, 500),
        AnchorPoint = Vector2.new(0, 1),
        ZIndex = 200
    })
    
    create("UIListLayout", {
        Parent = notificationHolder,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 8)
    })

    local main = create("Frame", {
        Name = "main",
        Parent = screenGui,
        BackgroundColor3 = theme.background,
        BorderSizePixel = 0,
        Position = isMobile and UDim2.new(0.5, -175, 0.5, -250) or UDim2.new(0.5, -375, 0.5, -275),
        Size = isMobile and UDim2.new(0, 350, 0, 500) or UDim2.new(0, 750, 0, 550),
        ClipsDescendants = false
    })
    
    addCorner(main, 8)
    addStroke(main, theme.border, 1)
    
    local mainShadow = create("ImageLabel", {
        Name = "shadow",
        Parent = main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 50, 1, 50),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ZIndex = 0,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277)
    })

    local topbar = create("Frame", {
        Name = "topbar",
        Parent = main,
        BackgroundColor3 = theme.foreground,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 50)
    })
    
    addCorner(topbar, 8)
    addStroke(topbar, theme.border, 1)
    
    local topbarAccent = create("Frame", {
        Parent = topbar,
        BackgroundColor3 = theme.accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2)
    })

    local title = create("TextLabel", {
        Parent = topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(1, -100, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = windowName,
        TextColor3 = theme.text,
        TextSize = isMobile and 15 or 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local closeBtn = create("TextButton", {
        Parent = topbar,
        BackgroundColor3 = theme.elevated,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -40, 0.5, -15),
        Size = UDim2.new(0, 30, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = theme.textDark,
        TextSize = 20,
        AutoButtonColor = false
    })
    
    addCorner(closeBtn, 6)

    local tabContainer = create("Frame", {
        Name = "tabs",
        Parent = main,
        BackgroundColor3 = theme.foreground,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 50),
        Size = isMobile and UDim2.new(1, 0, 0, 40) or UDim2.new(0, 180, 1, -50)
    })
    
    addStroke(tabContainer, theme.border, 1)
    
    local tabLayout = create(isMobile and "UIListLayout" or "UIListLayout", {
        Parent = tabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = isMobile and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
        Padding = UDim.new(0, isMobile and 4 : 6)
    })
    
    create("UIPadding", {
        Parent = tabContainer,
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8)
    })

    local contentFrame = create("Frame", {
        Name = "content",
        Parent = main,
        BackgroundTransparency = 1,
        Position = isMobile and UDim2.new(0, 0, 0, 90) or UDim2.new(0, 180, 0, 50),
        Size = isMobile and UDim2.new(1, 0, 1, -90) or UDim2.new(1, -180, 1, -50)
    })

    local dragging, dragStart, startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    userInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                main.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tween(main, {BackgroundTransparency = 1}, 0.4)
        wait(0.4)
        screenGui:Destroy()
        _G[killSwitchId] = nil
    end)

    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, {BackgroundColor3 = theme.error, TextColor3 = theme.text}, 0.2)
    end)

    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, {BackgroundColor3 = theme.elevated, TextColor3 = theme.textDark}, 0.2)
    end)

    local window = {}
    window.tabs = {}
    window.currentTab = nil
    window.theme = theme
    window.config = savedConfig
    window.executorName = executorName

    function window:notify(config)
        config = config or {}
        local notifTitle = config.title or "notification"
        local text = config.text or ""
        local duration = config.duration or 4
        local notifType = config.type or "default"
        
        local typeColors = {
            default = theme.accent,
            success = theme.success,
            warning = theme.warning,
            error = theme.error
        }
        
        local typeIcons = {
            default = "ℹ",
            success = "✓",
            warning = "⚠",
            error = "✕"
        }
        
        local notif = create("Frame", {
            Parent = notificationHolder,
            BackgroundColor3 = theme.foreground,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true,
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        })
        
        addCorner(notif, 6)
        addStroke(notif, theme.border, 1)
        
        local notifShadow = create("ImageLabel", {
            Name = "shadow",
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 30, 1, 30),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image = "rbxassetid://5554236805",
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.7,
            ZIndex = 0,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(23, 23, 277, 277)
        })
        
        local accentBar = create("Frame", {
            Parent = notif,
            BackgroundColor3 = typeColors[notifType],
            BorderSizePixel = 0,
            Size = UDim2.new(0, 3, 1, 0)
        })
        
        local iconLabel = create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0.5, -12),
            Size = UDim2.new(0, 24, 0, 24),
            Font = Enum.Font.GothamBold,
            Text = typeIcons[notifType],
            TextColor3 = typeColors[notifType],
            TextSize = 16
        })
        
        local titleLabel = create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 48, 0, 8),
            Size = UDim2.new(1, -58, 0, 18),
            Font = Enum.Font.GothamBold,
            Text = notifTitle,
            TextColor3 = theme.text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd
        })
        
        local textLabel = create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 48, 0, 28),
            Size = UDim2.new(1, -58, 0, 40),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = theme.textDark,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        })
        
        local progressBar = create("Frame", {
            Parent = notif,
            BackgroundColor3 = typeColors[notifType],
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -2),
            Size = UDim2.new(1, 0, 0, 2)
        })
        
        tween(notif, {Size = UDim2.new(1, 0, 0, 76), BackgroundTransparency = 0}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tween(progressBar, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)
        
        task.delay(duration, function()
            tween(notif, {BackgroundTransparency = 1}, 0.3)
            for _, child in ipairs(notif:GetChildren()) do
                if child:IsA("TextLabel") or child:IsA("Frame") then
                    if child:IsA("TextLabel") then
                        tween(child, {TextTransparency = 1}, 0.3)
                    end
                    if child:IsA("Frame") and child.Name ~= "shadow" then
                        tween(child, {BackgroundTransparency = 1}, 0.3)
                    end
                end
            end
            task.wait(0.3)
            notif:Destroy()
        end)
    end

    function window:saveConfig()
        if not writefile then return end
        writefile(configFile, httpService:JSONEncode(savedConfig))
    end

    function window:loadConfig()
        if not readfile or not isfile or not isfile(configFile) then return end
        local success, data = pcall(function()
            return httpService:JSONDecode(readfile(configFile))
        end)
        if success and data then
            savedConfig = data
            window.config = savedConfig
            for _, tab in pairs(window.tabs) do
                tab:loadValues()
            end
        end
    end

    function window:createTab(name)
        local tab = {}
        tab.name = name
        tab.sections = {}
        tab.container = nil
        
        local tabButton = create("TextButton", {
            Name = name,
            Parent = tabContainer,
            BackgroundColor3 = theme.elevated,
            BorderSizePixel = 0,
            Size = isMobile and UDim2.new(0, 90, 1, -16) or UDim2.new(1, 0, 0, 36),
            Font = Enum.Font.GothamSemibold,
            Text = name,
            TextColor3 = theme.textDark,
            TextSize = isMobile and 12 or 13,
            AutoButtonColor = false
        })
        
        addCorner(tabButton, 6)
        
        local tabContent = create("ScrollingFrame", {
            Name = name .. "Content",
            Parent = contentFrame,
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = theme.accent,
            ScrollBarImageTransparency = 0.5,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        
        create("UIListLayout", {
            Parent = tabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12)
        })
        
        create("UIPadding", {
            Parent = tabContent,
            PaddingTop = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12)
        })
        
        tab.container = tabContent
        
        tabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(window.tabs) do
                t.container.Visible = false
                local btn = tabContainer:FindFirstChild(t.name)
                if btn then
                    tween(btn, {BackgroundColor3 = theme.elevated, TextColor3 = theme.textDark}, 0.2)
                end
            end
            
            tabContent.Visible = true
            tween(tabButton, {BackgroundColor3 = theme.accent, TextColor3 = theme.text}, 0.2)
            window.currentTab = tab
        end)
        
        tabButton.MouseEnter:Connect(function()
            if tabContent.Visible == false then
                tween(tabButton, {BackgroundColor3 = theme.border}, 0.2)
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if tabContent.Visible == false then
                tween(tabButton, {BackgroundColor3 = theme.elevated}, 0.2)
            end
        end)
        
        if not window.currentTab then
            tabContent.Visible = true
            tabButton.BackgroundColor3 = theme.accent
            tabButton.TextColor3 = theme.text
            window.currentTab = tab
        end
        
        function tab:loadValues()
            for _, section in pairs(tab.sections) do
                if section.loadValues then
                    section:loadValues()
                end
            end
        end
        
        function tab:addSection(name)
            local section = {}
            section.name = name
            section.elements = {}
            
            local sectionFrame = create("Frame", {
                Parent = tabContent,
                BackgroundColor3 = theme.foreground,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            addCorner(sectionFrame, 6)
            addStroke(sectionFrame, theme.border, 1)
            
            local sectionHeader = create("TextLabel", {
                Parent = sectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 12),
                Size = UDim2.new(1, -32, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = name,
                TextColor3 = theme.text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local sectionContent = create("Frame", {
                Parent = sectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 40),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            create("UIListLayout", {
                Parent = sectionContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6)
            })
            
            create("UIPadding", {
                Parent = sectionContent,
                PaddingTop = UDim.new(0, 0),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 12)
            })
            
            section.container = sectionContent
            
            function section:loadValues()
                for _, element in pairs(section.elements) do
                    if element.loadValue then
                        element:loadValue()
                    end
                end
            end
            
            function section:addToggle(config)
                config = config or {}
                local toggleName = config.name or "toggle"
                local default = config.default or false
                local callback = config.callback or function() end
                local flag = config.flag or toggleName
                
                if savedConfig[flag] ~= nil then
                    default = savedConfig[flag]
                end
                
                local toggled = default
                
                local toggleFrame = create("Frame", {
                    Parent = sectionContent,
                    BackgroundColor3 = theme.elevated,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 40)
                })
                
                addCorner(toggleFrame, 6)
                
                local toggleLabel = create("TextLabel", {
                    Parent = toggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 0),
                    Size = UDim2.new(1, -70, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = toggleName,
                    TextColor3 = theme.text,
                    TextSize = isMobile and 12 or 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local toggleOuter = create("Frame", {
                    Parent = toggleFrame,
                    BackgroundColor3 = toggled and theme.accent or theme.border,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -50, 0.5, -10),
                    Size = UDim2.new(0, 40, 0, 20)
                })
                
                addCorner(toggleOuter, 10)
                
                local toggleInner = create("Frame", {
                    Parent = toggleOuter,
                    BackgroundColor3 = theme.text,
                    BorderSizePixel = 0,
                    Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16)
                })
                
                addCorner(toggleInner, 8)
                
                local button = create("TextButton", {
                    Parent = toggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })
                
                local toggle = {}
                
                function toggle:set(value)
                    toggled = value
                    savedConfig[flag] = value
                    
                    tween(toggleOuter, {BackgroundColor3 = toggled and theme.accent or theme.border}, 0.2)
                    tween(toggleInner, {Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.25, Enum.EasingStyle.Quint)
                    
                    callback(toggled)
                end
                
                function toggle:loadValue()
                    if savedConfig[flag] ~= nil then
                        toggle:set(savedConfig[flag])
                    end
                end
                
                button.MouseButton1Click:Connect(function()
                    toggle:set(not toggled)
                end)
                
                button.MouseEnter:Connect(function()
                    tween(toggleFrame, {BackgroundColor3 = Color3.fromRGB(
                        theme.elevated.R * 255 + 5,
                        theme.elevated.G * 255 + 5,
                        theme.elevated.B * 255 + 5
                    )}, 0.2)
                end)
                
                button.MouseLeave:Connect(function()
                    tween(toggleFrame, {BackgroundColor3 = theme.elevated}, 0.2)
                end)
                
                table.insert(section.elements, toggle)
                callback(toggled)
                
                return toggle
            end
            
            function section:addSlider(config)
                config = config or {}
                local sliderName = config.name or "slider"
                local min = config.min or 0
                local max = config.max or 100
                local default = config.default or min
                local increment = config.increment or 1
                local callback = config.callback or function() end
                local flag = config.flag or sliderName
                
                if savedConfig[flag] ~= nil then
                    default = savedConfig[flag]
                end
                
                local value = default
                
                local sliderFrame = create("Frame", {
                    Parent = sectionContent,
                    BackgroundColor3 = theme.elevated,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 50)
                })
                
                addCorner(sliderFrame, 6)
                
                local sliderLabel = create("TextLabel", {
                    Parent = sliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 8),
                    Size = UDim2.new(1, -80, 0, 16),
                    Font = Enum.Font.GothamMedium,
                    Text = sliderName,
                    TextColor3 = theme.text,
                    TextSize = isMobile and 12 or 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local valueLabel = create("TextLabel", {
                    Parent = sliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -70, 0, 8),
                    Size = UDim2.new(0, 56, 0, 16),
                    Font = Enum.Font.GothamBold,
                    Text = tostring(value),
                    TextColor3 = theme.accent,
                    TextSize = isMobile and 12 or 13,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local sliderTrack = create("Frame", {
                    Parent = sliderFrame,
                    BackgroundColor3 = theme.border,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 14, 1, -18),
                    Size = UDim2.new(1, -28, 0, 4)
                })
                
                addCorner(sliderTrack, 2)
                
                local sliderFill = create("Frame", {
                    Parent = sliderTrack,
                    BackgroundColor3 = theme.accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                })
                
                addCorner(sliderFill, 2)
                
                local sliderButton = create("TextButton", {
                    Parent = sliderTrack,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 12),
                    Position = UDim2.new(0, 0, 0, -6),
                    Text = ""
                })
                
                local dragging = false
                
                local slider = {}
                
                function slider:set(val)
                    value = math.clamp(math.floor((val - min) / increment + 0.5) * increment + min, min, max)
                    savedConfig[flag] = value
                    
                    local percent = (value - min) / (max - min)
                    tween(sliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.15, Enum.EasingStyle.Quint)
                    valueLabel.Text = tostring(value)
                    
                    callback(value)
                end
                
                function slider:loadValue()
                    if savedConfig[flag] ~= nil then
                        slider:set(savedConfig[flag])
                    end
                end
                
                sliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        
                        local function update()
                            local mouse = isMobile and input.Position or userInputService:GetMouseLocation()
                            local percent = math.clamp((mouse.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                            slider:set(min + (max - min) * percent)
                        end
                        
                        update()
                        
                        local moveConnection
                        moveConnection = userInputService.InputChanged:Connect(function(input2)
                            if (input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch) and dragging then
                                update()
                            end
                        end)
                        
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                dragging = false
                                moveConnection:Disconnect()
                            end
                        end)
                    end
                end)
                
                sliderButton.MouseEnter:Connect(function()
                    if not isMobile then
                        tween(sliderFrame, {BackgroundColor3 = Color3.fromRGB(
                            theme.elevated.R * 255 + 5,
                            theme.elevated.G * 255 + 5,
                            theme.elevated.B * 255 + 5
                        )}, 0.2)
                    end
                end)
                
                sliderButton.MouseLeave:Connect(function()
                    if not isMobile then
                        tween(sliderFrame, {BackgroundColor3 = theme.elevated}, 0.2)
                    end
                end)
                
                table.insert(section.elements, slider)
                callback(value)
                
                return slider
            end
            
            function section:addButton(config)
                config = config or {}
                local buttonName = config.name or "button"
                local callback = config.callback or function() end
                
                local buttonFrame = create("TextButton", {
                    Parent = sectionContent,
                    BackgroundColor3 = theme.accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 36),
                    Font = Enum.Font.GothamSemibold,
                    Text = buttonName,
                    TextColor3 = theme.text,
                    TextSize = isMobile and 12 or 13,
                    AutoButtonColor = false
                })
                
                addCorner(buttonFrame, 6)
                
                local button = {}
                
                buttonFrame.MouseButton1Click:Connect(callback)
                
                buttonFrame.MouseEnter:Connect(function()
                    if not isMobile then
                        tween(buttonFrame, {BackgroundColor3 = theme.accentDark}, 0.2)
                    end
                end)
                
                buttonFrame.MouseLeave:Connect(function()
                    if not isMobile then
                        tween(buttonFrame, {BackgroundColor3 = theme.accent}, 0.2)
                    end
                end)
                
                table.insert(section.elements, button)
                
                return button
            end
            
            function section:addTextbox(config)
                config = config or {}
                local textboxName = config.name or "textbox"
                local default = config.default or ""
                local placeholder = config.placeholder or "enter text..."
                local callback = config.callback or function() end
                local flag = config.flag or textboxName
                
                if savedConfig[flag] ~= nil then
                    default = savedConfig[flag]
                end
                
                local textboxFrame = create("Frame", {
                    Parent = sectionContent,
                    BackgroundColor3 = theme.elevated,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 40)
                })
                
                addCorner(textboxFrame, 6)
                
                local textboxLabel = create("TextLabel", {
                    Parent = textboxFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 0),
                    Size = UDim2.new(0.35, 0, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = textboxName,
                    TextColor3 = theme.text,
                    TextSize = isMobile and 11 or 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local inputBox = create("TextBox", {
                    Parent = textboxFrame,
                    BackgroundColor3 = theme.border,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.37, 0, 0.5, -12),
                    Size = UDim2.new(0.63, -20, 0, 24),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = theme.textDark,
                    Text = default,
                    TextColor3 = theme.text,
                    TextSize = isMobile and 11 or 12,
                    ClearTextOnFocus = false
                })
                
                addCorner(inputBox, 4)
                
                create("UIPadding", {
                    Parent = inputBox,
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10)
                })
                
                local textbox = {}
                
                function textbox:set(text)
                    inputBox.Text = text
                    savedConfig[flag] = text
                    callback(text)
                end
                
                function textbox:loadValue()
                    if savedConfig[flag] ~= nil then
                        textbox:set(savedConfig[flag])
                    end
                end
                
                inputBox.FocusLost:Connect(function()
                    textbox:set(inputBox.Text)
                end)
                
                inputBox.Focused:Connect(function()
                    tween(inputBox, {BackgroundColor3 = theme.accent}, 0.2)
                end)
                
                inputBox.FocusLost:Connect(function()
                    tween(inputBox, {BackgroundColor3 = theme.border}, 0.2)
                end)
                
                table.insert(section.elements, textbox)
                callback(default)
                
                return textbox
            end
            
            function section:addDropdown(config)
                config = config or {}
                local dropdownName = config.name or "dropdown"
                local options = config.options or {}
                local default = config.default or options[1]
                local callback = config.callback or function() end
                local flag = config.flag or dropdownName
                
                if savedConfig[flag] ~= nil then
                    default = savedConfig[flag]
                end
                
                local selected = default
                local opened = false
                
                local dropdownFrame = create("Frame", {
                    Parent = sectionContent,
                    BackgroundColor3 = theme.elevated,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 40),
                    ClipsDescendants = true
                })
                
                addCorner(dropdownFrame, 6)
                
                local dropdownLabel = create("TextLabel", {
                    Parent = dropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 0),
                    Size = UDim2.new(1, -40, 0, 40),
                    Font = Enum.Font.GothamMedium,
                    Text = dropdownName .. ": " .. tostring(selected),
                    TextColor3 = theme.text,
                    TextSize = isMobile and 11 or 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local arrow = create("TextLabel", {
                    Parent = dropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -30, 0, 0),
                    Size = UDim2.new(0, 20, 0, 40),
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = theme.accent,
                    TextSize = 10
                })
                
                local dropdownButton = create("TextButton", {
                    Parent = dropdownFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40),
                    Text = ""
                })
                
                local optionsContainer = create("Frame", {
                    Parent = dropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 40),
                    Size = UDim2.new(1, 0, 0, 0)
                })
                
                create("UIListLayout", {
                    Parent = optionsContainer,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 4)
                })
                
                create("UIPadding", {
                    Parent = optionsContainer,
                    PaddingTop = UDim.new(0, 6),
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 6)
                })
                
                local dropdown = {}
                
                function dropdown:set(option)
                    selected = option
                    savedConfig[flag] = option
                    dropdownLabel.Text = dropdownName .. ": " .. tostring(option)
                    callback(option)
                end
                
                function dropdown:loadValue()
                    if savedConfig[flag] ~= nil then
                        dropdown:set(savedConfig[flag])
                    end
                end
                
                for _, option in ipairs(options) do
                    local optionButton = create("TextButton", {
                        Parent = optionsContainer,
                        BackgroundColor3 = theme.border,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 28),
                        Font = Enum.Font.Gotham,
                        Text = tostring(option),
                        TextColor3 = theme.text,
                        TextSize = isMobile and 11 or 12,
                        AutoButtonColor = false
                    })
                    
                    addCorner(optionButton, 4)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        dropdown:set(option)
                        opened = false
                        tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.25, Enum.EasingStyle.Quint)
                        tween(arrow, {Rotation = 0}, 0.25, Enum.EasingStyle.Quint)
                    end)
                    
                    optionButton.MouseEnter:Connect(function()
                        if not isMobile then
                            tween(optionButton, {BackgroundColor3 = theme.accent}, 0.2)
                        end
                    end)
                    
                    optionButton.MouseLeave:Connect(function()
                        if not isMobile then
                            tween(optionButton, {BackgroundColor3 = theme.border}, 0.2)
                        end
                    end)
                end
                
                dropdownButton.MouseButton1Click:Connect(function()
                    opened = not opened
                    local newSize = opened and (40 + 12 + (#options * 32)) or 40
                    tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, newSize)}, 0.25, Enum.EasingStyle.Quint)
                    tween(arrow, {Rotation = opened and 180 or 0}, 0.25, Enum.EasingStyle.Quint)
                end)
                
                table.insert(section.elements, dropdown)
                callback(selected)
                
                return dropdown
            end
            
            function section:addLabel(text)
                local labelFrame = create("Frame", {
                    Parent = sectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20)
                })
                
                local label = create("TextLabel", {
                    Parent = labelFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 4, 0, 0),
                    Size = UDim2.new(1, -8, 1, 0),
                    Font = Enum.Font.GothamSemibold,
                    Text = text,
                    TextColor3 = theme.textDark,
                    TextSize = isMobile and 11 or 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local labelObj = {}
                
                function labelObj:set(newText)
                    label.Text = newText
                end
                
                table.insert(section.elements, labelObj)
                
                return labelObj
            end
            
            table.insert(tab.sections, section)
            return section
        end
        
        table.insert(window.tabs, tab)
        return tab
    end
    
    window:loadConfig()
    
    main.Size = UDim2.new(0, 0, 0, 0)
    main.BackgroundTransparency = 1
    tween(main, {Size = isMobile and UDim2.new(0, 350, 0, 500) or UDim2.new(0, 750, 0, 550), BackgroundTransparency = 0}, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    
    return window
end

return club
