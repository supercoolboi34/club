local UILib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local KillSwitch = "UILib_Instance_" .. tostring(math.random(1000000, 9999999))
if _G[KillSwitch] then
    _G[KillSwitch]:Destroy()
    wait(0.1)
end

local Themes = {
    Dark = {
        Primary = Color3.fromRGB(25, 25, 35),
        Secondary = Color3.fromRGB(35, 35, 45),
        Tertiary = Color3.fromRGB(45, 45, 55),
        Accent = Color3.fromRGB(100, 100, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(60, 60, 70),
        Glow = Color3.fromRGB(100, 100, 255)
    },
    Light = {
        Primary = Color3.fromRGB(240, 240, 245),
        Secondary = Color3.fromRGB(250, 250, 255),
        Tertiary = Color3.fromRGB(235, 235, 240),
        Accent = Color3.fromRGB(80, 80, 200),
        Text = Color3.fromRGB(20, 20, 20),
        TextDim = Color3.fromRGB(100, 100, 100),
        Border = Color3.fromRGB(200, 200, 210),
        Glow = Color3.fromRGB(80, 80, 200)
    },
    Purple = {
        Primary = Color3.fromRGB(30, 20, 40),
        Secondary = Color3.fromRGB(40, 30, 50),
        Tertiary = Color3.fromRGB(50, 40, 60),
        Accent = Color3.fromRGB(150, 100, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(180, 180, 200),
        Border = Color3.fromRGB(70, 50, 90),
        Glow = Color3.fromRGB(150, 100, 255)
    }
}

local function CreateInstance(class, properties)
    local instance = Instance.new(class)
    for prop, val in pairs(properties) do
        instance[prop] = val
    end
    return instance
end

local function Tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function AddGlow(frame, color, size)
    local glow = CreateInstance("ImageLabel", {
        Name = "Glow",
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, size or 20, 1, size or 20),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://5028857084",
        ImageColor3 = color,
        ImageTransparency = 0.7,
        ZIndex = 0
    })
    return glow
end

function UILib:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "UI Library"
    local themeName = config.Theme or "Dark"
    local currentTheme = Themes[themeName]
    local configFile = config.ConfigFile or "UILib_Config.json"
    local savedConfig = {}

    local ScreenGui = CreateInstance("ScreenGui", {
        Name = "UILib_" .. HttpService:GenerateGUID(false),
        Parent = game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    _G[KillSwitch] = ScreenGui

    local NotificationContainer = CreateInstance("Frame", {
        Name = "Notifications",
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 0, 20),
        Size = UDim2.new(0, 300, 1, -40),
        ZIndex = 100
    })
    
    CreateInstance("UIListLayout", {
        Parent = NotificationContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })

    local MainFrame = CreateInstance("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        BackgroundColor3 = currentTheme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -350, 0.5, -250),
        Size = UDim2.new(0, 700, 0, 500),
        ClipsDescendants = true
    })
    
    AddGlow(MainFrame, currentTheme.Glow, 30)
    
    CreateInstance("UICorner", {
        Parent = MainFrame,
        CornerRadius = UDim.new(0, 8)
    })

    local TopBar = CreateInstance("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundColor3 = currentTheme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40)
    })
    
    CreateInstance("UICorner", {
        Parent = TopBar,
        CornerRadius = UDim.new(0, 8)
    })

    local Title = CreateInstance("TextLabel", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = windowName,
        TextColor3 = currentTheme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local CloseBtn = CreateInstance("TextButton", {
        Parent = TopBar,
        BackgroundColor3 = currentTheme.Tertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -35, 0.5, -12),
        Size = UDim2.new(0, 24, 0, 24),
        Font = Enum.Font.GothamBold,
        Text = "X",
        TextColor3 = currentTheme.Text,
        TextSize = 14
    })
    
    CreateInstance("UICorner", {
        Parent = CloseBtn,
        CornerRadius = UDim.new(0, 4)
    })

    local TabContainer = CreateInstance("Frame", {
        Name = "Tabs",
        Parent = MainFrame,
        BackgroundColor3 = currentTheme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, 150, 1, -40)
    })
    
    CreateInstance("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    CreateInstance("UIPadding", {
        Parent = TabContainer,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })

    local ContentFrame = CreateInstance("Frame", {
        Name = "Content",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 40),
        Size = UDim2.new(1, -150, 1, -40)
    })

    local ResizeHandle = CreateInstance("Frame", {
        Name = "ResizeHandle",
        Parent = MainFrame,
        BackgroundColor3 = currentTheme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -15, 1, -15),
        Size = UDim2.new(0, 15, 0, 15),
        ZIndex = 10
    })
    
    CreateInstance("UICorner", {
        Parent = ResizeHandle,
        CornerRadius = UDim.new(0, 3)
    })

    local dragging, dragInput, dragStart, startPos
    local resizing, resizeStart, startSize

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            startSize = MainFrame.Size
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            elseif resizing then
                local delta = input.Position - resizeStart
                local newSizeX = math.max(500, startSize.X.Offset + delta.X)
                local newSizeY = math.max(400, startSize.Y.Offset + delta.Y)
                MainFrame.Size = UDim2.new(0, newSizeX, 0, newSizeY)
            end
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        wait(0.3)
        ScreenGui:Destroy()
    end)

    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}, 0.2)
    end)

    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = currentTheme.Tertiary}, 0.2)
    end)

    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Theme = currentTheme
    Window.Config = savedConfig

    function Window:Notify(config)
        config = config or {}
        local title = config.Title or "Notification"
        local text = config.Text or ""
        local duration = config.Duration or 3
        
        local notif = CreateInstance("Frame", {
            Parent = NotificationContainer,
            BackgroundColor3 = currentTheme.Secondary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 80),
            ClipsDescendants = true,
            Position = UDim2.new(1, 0, 0, 0)
        })
        
        CreateInstance("UICorner", {
            Parent = notif,
            CornerRadius = UDim.new(0, 6)
        })
        
        AddGlow(notif, currentTheme.Glow, 15)
        
        local accent = CreateInstance("Frame", {
            Parent = notif,
            BackgroundColor3 = currentTheme.Accent,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 3, 1, 0)
        })
        
        local titleLabel = CreateInstance("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 10),
            Size = UDim2.new(1, -30, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = currentTheme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local textLabel = CreateInstance("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 35),
            Size = UDim2.new(1, -30, 0, 35),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = currentTheme.TextDim,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        })
        
        Tween(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        
        task.delay(duration, function()
            Tween(notif, {Position = UDim2.new(1, 0, 0, 0)}, 0.3)
            task.wait(0.3)
            notif:Destroy()
        end)
    end

    function Window:SetTheme(themeName)
        if not Themes[themeName] then return end
        currentTheme = Themes[themeName]
        Window.Theme = currentTheme
        
        MainFrame.BackgroundColor3 = currentTheme.Primary
        TopBar.BackgroundColor3 = currentTheme.Secondary
        TabContainer.BackgroundColor3 = currentTheme.Secondary
        Title.TextColor3 = currentTheme.Text
        CloseBtn.TextColor3 = currentTheme.Text
        ResizeHandle.BackgroundColor3 = currentTheme.Accent
        
        for _, tab in pairs(Window.Tabs) do
            tab:Refresh()
        end
    end

    function Window:SaveConfig()
        if not writefile then return end
        writefile(configFile, HttpService:JSONEncode(savedConfig))
    end

    function Window:LoadConfig()
        if not readfile or not isfile or not isfile(configFile) then return end
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(configFile))
        end)
        if success and data then
            savedConfig = data
            Window.Config = savedConfig
            for _, tab in pairs(Window.Tabs) do
                tab:LoadValues()
            end
        end
    end

    function Window:CreateTab(name)
        local Tab = {}
        Tab.Name = name
        Tab.Elements = {}
        Tab.Container = nil
        
        local TabButton = CreateInstance("TextButton", {
            Name = name,
            Parent = TabContainer,
            BackgroundColor3 = currentTheme.Tertiary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 35),
            Font = Enum.Font.GothamSemibold,
            Text = name,
            TextColor3 = currentTheme.TextDim,
            TextSize = 13
        })
        
        CreateInstance("UICorner", {
            Parent = TabButton,
            CornerRadius = UDim.new(0, 6)
        })
        
        local TabContent = CreateInstance("ScrollingFrame", {
            Name = name .. "Content",
            Parent = ContentFrame,
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = currentTheme.Accent,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        
        CreateInstance("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        CreateInstance("UIPadding", {
            Parent = TabContent,
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        })
        
        Tab.Container = TabContent
        
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Container.Visible = false
                local btn = TabContainer:FindFirstChild(tab.Name)
                if btn then
                    Tween(btn, {BackgroundColor3 = currentTheme.Tertiary, TextColor3 = currentTheme.TextDim}, 0.2)
                end
            end
            
            TabContent.Visible = true
            Tween(TabButton, {BackgroundColor3 = currentTheme.Accent, TextColor3 = currentTheme.Text}, 0.2)
            Window.CurrentTab = Tab
        end)
        
        TabButton.MouseEnter:Connect(function()
            if TabContent.Visible == false then
                Tween(TabButton, {BackgroundColor3 = currentTheme.Border}, 0.2)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if TabContent.Visible == false then
                Tween(TabButton, {BackgroundColor3 = currentTheme.Tertiary}, 0.2)
            end
        end)
        
        if not Window.CurrentTab then
            TabButton.MouseButton1Click:Connect(function() end)
            TabContent.Visible = true
            TabButton.BackgroundColor3 = currentTheme.Accent
            TabButton.TextColor3 = currentTheme.Text
            Window.CurrentTab = Tab
        end
        
        function Tab:Refresh()
            TabButton.BackgroundColor3 = TabContent.Visible and currentTheme.Accent or currentTheme.Tertiary
            TabButton.TextColor3 = TabContent.Visible and currentTheme.Text or currentTheme.TextDim
            
            for _, element in pairs(Tab.Elements) do
                if element.Refresh then
                    element:Refresh()
                end
            end
        end
        
        function Tab:LoadValues()
            for _, element in pairs(Tab.Elements) do
                if element.LoadValue then
                    element:LoadValue()
                end
            end
        end
        
        function Tab:AddToggle(config)
            config = config or {}
            local name = config.Name or "Toggle"
            local default = config.Default or false
            local callback = config.Callback or function() end
            local flag = config.Flag or name
            
            if savedConfig[flag] ~= nil then
                default = savedConfig[flag]
            end
            
            local toggled = default
            
            local ToggleFrame = CreateInstance("Frame", {
                Parent = TabContent,
                BackgroundColor3 = currentTheme.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40)
            })
            
            CreateInstance("UICorner", {
                Parent = ToggleFrame,
                CornerRadius = UDim.new(0, 6)
            })
            
            local ToggleLabel = CreateInstance("TextLabel", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -70, 1, 0),
                Font = Enum.Font.Gotham,
                Text = name,
                TextColor3 = currentTheme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ToggleButton = CreateInstance("Frame", {
                Parent = ToggleFrame,
                BackgroundColor3 = toggled and currentTheme.Accent or currentTheme.Tertiary,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -50, 0.5, -10),
                Size = UDim2.new(0, 40, 0, 20)
            })
            
            CreateInstance("UICorner", {
                Parent = ToggleButton,
                CornerRadius = UDim.new(1, 0)
            })
            
            local ToggleCircle = CreateInstance("Frame", {
                Parent = ToggleButton,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16)
            })
            
            CreateInstance("UICorner", {
                Parent = ToggleCircle,
                CornerRadius = UDim.new(1, 0)
            })
            
            local Button = CreateInstance("TextButton", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })
            
            local Toggle = {}
            
            function Toggle:Set(value)
                toggled = value
                savedConfig[flag] = value
                
                Tween(ToggleButton, {BackgroundColor3 = toggled and currentTheme.Accent or currentTheme.Tertiary}, 0.2)
                Tween(ToggleCircle, {Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
                
                callback(toggled)
            end
            
            function Toggle:Refresh()
                ToggleFrame.BackgroundColor3 = currentTheme.Secondary
                ToggleLabel.TextColor3 = currentTheme.Text
                ToggleButton.BackgroundColor3 = toggled and currentTheme.Accent or currentTheme.Tertiary
            end
            
            function Toggle:LoadValue()
                if savedConfig[flag] ~= nil then
                    Toggle:Set(savedConfig[flag])
                end
            end
            
            Button.MouseButton1Click:Connect(function()
                Toggle:Set(not toggled)
            end)
            
            Button.MouseEnter:Connect(function()
                Tween(ToggleFrame, {BackgroundColor3 = currentTheme.Tertiary}, 0.2)
            end)
            
            Button.MouseLeave:Connect(function()
                Tween(ToggleFrame, {BackgroundColor3 = currentTheme.Secondary}, 0.2)
            end)
            
            table.insert(Tab.Elements, Toggle)
            callback(toggled)
            
            return Toggle
        end
        
        function Tab:AddSlider(config)
            config = config or {}
            local name = config.Name or "Slider"
            local min = config.Min or 0
            local max = config.Max or 100
            local default = config.Default or min
            local increment = config.Increment or 1
            local callback = config.Callback or function() end
            local flag = config.Flag or name
            
            if savedConfig[flag] ~= nil then
                default = savedConfig[flag]
            end
            
            local value = default
            
            local SliderFrame = CreateInstance("Frame", {
                Parent = TabContent,
                BackgroundColor3 = currentTheme.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 50)
            })
            
            CreateInstance("UICorner", {
                Parent = SliderFrame,
                CornerRadius = UDim.new(0, 6)
            })
            
            local SliderLabel = CreateInstance("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 5),
                Size = UDim2.new(1, -30, 0, 15),
                Font = Enum.Font.Gotham,
                Text = name,
                TextColor3 = currentTheme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ValueLabel = CreateInstance("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -60, 0, 5),
                Size = UDim2.new(0, 45, 0, 15),
                Font = Enum.Font.GothamBold,
                Text = tostring(value),
                TextColor3 = currentTheme.Accent,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right
            })
            
            local SliderBack = CreateInstance("Frame", {
                Parent = SliderFrame,
                BackgroundColor3 = currentTheme.Tertiary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 15, 1, -20),
                Size = UDim2.new(1, -30, 0, 6)
            })
            
            CreateInstance("UICorner", {
                Parent = SliderBack,
                CornerRadius = UDim.new(1, 0)
            })
            
            local SliderFill = CreateInstance("Frame", {
                Parent = SliderBack,
                BackgroundColor3 = currentTheme.Accent,
                BorderSizePixel = 0,
                Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            })
            
            CreateInstance("UICorner", {
                Parent = SliderFill,
                CornerRadius = UDim.new(1, 0)
            })
            
            local SliderButton = CreateInstance("TextButton", {
                Parent = SliderBack,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 10),
                Position = UDim2.new(0, 0, 0, -5),
                Text = ""
            })
            
            local dragging = false
            
            local Slider = {}
            
            function Slider:Set(val)
                value = math.clamp(math.floor((val - min) / increment + 0.5) * increment + min, min, max)
                savedConfig[flag] = value
                
                local percent = (value - min) / (max - min)
                Tween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                ValueLabel.Text = tostring(value)
                
                callback(value)
            end
            
            function Slider:Refresh()
                SliderFrame.BackgroundColor3 = currentTheme.Secondary
                SliderLabel.TextColor3 = currentTheme.Text
                ValueLabel.TextColor3 = currentTheme.Accent
                SliderBack.BackgroundColor3 = currentTheme.Tertiary
                SliderFill.BackgroundColor3 = currentTheme.Accent
            end
            
            function Slider:LoadValue()
                if savedConfig[flag] ~= nil then
                    Slider:Set(savedConfig[flag])
                end
            end
            
            SliderButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    
                    local function update()
                        local mouse = UserInputService:GetMouseLocation()
                        local percent = math.clamp((mouse.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
                        Slider:Set(min + (max - min) * percent)
                    end
                    
                    update()
                    
                    local moveConnection
                    moveConnection = UserInputService.InputChanged:Connect(function(input2)
                        if input2.UserInputType == Enum.UserInputType.MouseMovement and dragging then
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
            
            SliderButton.MouseEnter:Connect(function()
                Tween(SliderFrame, {BackgroundColor3 = currentTheme.Tertiary}, 0.2)
            end)
            
            SliderButton.MouseLeave:Connect(function()
                Tween(SliderFrame, {BackgroundColor3 = currentTheme.Secondary}, 0.2)
            end)
            
            table.insert(Tab.Elements, Slider)
            callback(value)
            
            return Slider
        end
        
        function Tab:AddTextbox(config)
            config = config or {}
            local name = config.Name or "Textbox"
            local default = config.Default or ""
            local placeholder = config.Placeholder or "Enter text..."
            local callback = config.Callback or function() end
            local flag = config.Flag or name
            
            if savedConfig[flag] ~= nil then
                default = savedConfig[flag]
            end
            
            local TextboxFrame = CreateInstance("Frame", {
                Parent = TabContent,
                BackgroundColor3 = currentTheme.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40)
            })
            
            CreateInstance("UICorner", {
                Parent = TextboxFrame,
                CornerRadius = UDim.new(0, 6)
            })
            
            local TextboxLabel = CreateInstance("TextLabel", {
                Parent = TextboxFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(0.4, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = name,
                TextColor3 = currentTheme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local InputBox = CreateInstance("TextBox", {
                Parent = TextboxFrame,
                BackgroundColor3 = currentTheme.Tertiary,
                BorderSizePixel = 0,
                Position = UDim2.new(0.4, 10, 0.5, -12),
                Size = UDim2.new(0.6, -25, 0, 24),
                Font = Enum.Font.Gotham,
                PlaceholderText = placeholder,
                PlaceholderColor3 = currentTheme.TextDim,
                Text = default,
                TextColor3 = currentTheme.Text,
                TextSize = 12,
                ClearTextOnFocus = false
            })
            
            CreateInstance("UICorner", {
                Parent = InputBox,
                CornerRadius = UDim.new(0, 4)
            })
            
            CreateInstance("UIPadding", {
                Parent = InputBox,
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8)
            })
            
            local Textbox = {}
            
            function Textbox:Set(text)
                InputBox.Text = text
                savedConfig[flag] = text
                callback(text)
            end
            
            function Textbox:Refresh()
                TextboxFrame.BackgroundColor3 = currentTheme.Secondary
                TextboxLabel.TextColor3 = currentTheme.Text
                InputBox.BackgroundColor3 = currentTheme.Tertiary
                InputBox.TextColor3 = currentTheme.Text
                InputBox.PlaceholderColor3 = currentTheme.TextDim
            end
            
            function Textbox:LoadValue()
                if savedConfig[flag] ~= nil then
                    Textbox:Set(savedConfig[flag])
                end
            end
            
            InputBox.FocusLost:Connect(function()
                Textbox:Set(InputBox.Text)
            end)
            
            table.insert(Tab.Elements, Textbox)
            callback(default)
            
            return Textbox
        end
        
        function Tab:AddButton(config)
            config = config or {}
            local name = config.Name or "Button"
            local callback = config.Callback or function() end
            
            local ButtonFrame = CreateInstance("TextButton", {
                Parent = TabContent,
                BackgroundColor3 = currentTheme.Accent,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 35),
                Font = Enum.Font.GothamSemibold,
                Text = name,
                TextColor3 = currentTheme.Text,
                TextSize = 13
            })
            
            CreateInstance("UICorner", {
                Parent = ButtonFrame,
                CornerRadius = UDim.new(0, 6)
            })
            
            AddGlow(ButtonFrame, currentTheme.Glow, 10)
            
            local Button = {}
            
            function Button:Refresh()
                ButtonFrame.BackgroundColor3 = currentTheme.Accent
                ButtonFrame.TextColor3 = currentTheme.Text
            end
            
            ButtonFrame.MouseButton1Click:Connect(callback)
            
            ButtonFrame.MouseEnter:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(
                    currentTheme.Accent.R * 255 * 1.2,
                    currentTheme.Accent.G * 255 * 1.2,
                    currentTheme.Accent.B * 255 * 1.2
                )}, 0.2)
            end)
            
            ButtonFrame.MouseLeave:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = currentTheme.Accent}, 0.2)
            end)
            
            table.insert(Tab.Elements, Button)
            
            return Button
        end
        
        function Tab:AddLabel(text)
            local LabelFrame = CreateInstance("Frame", {
                Parent = TabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 25)
            })
            
            local Label = CreateInstance("TextLabel", {
                Parent = LabelFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = text,
                TextColor3 = currentTheme.Accent,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local LabelObj = {}
            
            function LabelObj:Set(newText)
                Label.Text = newText
            end
            
            function LabelObj:Refresh()
                Label.TextColor3 = currentTheme.Accent
            end
            
            table.insert(Tab.Elements, LabelObj)
            
            return LabelObj
        end
        
        function Tab:AddDropdown(config)
            config = config or {}
            local name = config.Name or "Dropdown"
            local options = config.Options or {}
            local default = config.Default or options[1]
            local callback = config.Callback or function() end
            local flag = config.Flag or name
            
            if savedConfig[flag] ~= nil then
                default = savedConfig[flag]
            end
            
            local selected = default
            local opened = false
            
            local DropdownFrame = CreateInstance("Frame", {
                Parent = TabContent,
                BackgroundColor3 = currentTheme.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40),
                ClipsDescendants = true
            })
            
            CreateInstance("UICorner", {
                Parent = DropdownFrame,
                CornerRadius = UDim.new(0, 6)
            })
            
            local DropdownLabel = CreateInstance("TextLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -30, 0, 40),
                Font = Enum.Font.Gotham,
                Text = name .. ": " .. tostring(selected),
                TextColor3 = currentTheme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local DropdownButton = CreateInstance("TextButton", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Text = ""
            })
            
            local OptionsContainer = CreateInstance("Frame", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 40),
                Size = UDim2.new(1, 0, 0, 0)
            })
            
            CreateInstance("UIListLayout", {
                Parent = OptionsContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2)
            })
            
            local Dropdown = {}
            
            function Dropdown:Set(option)
                selected = option
                savedConfig[flag] = option
                DropdownLabel.Text = name .. ": " .. tostring(option)
                callback(option)
            end
            
            function Dropdown:Refresh()
                DropdownFrame.BackgroundColor3 = currentTheme.Secondary
                DropdownLabel.TextColor3 = currentTheme.Text
            end
            
            function Dropdown:LoadValue()
                if savedConfig[flag] ~= nil then
                    Dropdown:Set(savedConfig[flag])
                end
            end
            
            for _, option in ipairs(options) do
                local OptionButton = CreateInstance("TextButton", {
                    Parent = OptionsContainer,
                    BackgroundColor3 = currentTheme.Tertiary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.Gotham,
                    Text = tostring(option),
                    TextColor3 = currentTheme.Text,
                    TextSize = 12
                })
                
                CreateInstance("UICorner", {
                    Parent = OptionButton,
                    CornerRadius = UDim.new(0, 4)
                })
                
                OptionButton.MouseButton1Click:Connect(function()
                    Dropdown:Set(option)
                    opened = false
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.3)
                end)
                
                OptionButton.MouseEnter:Connect(function()
                    Tween(OptionButton, {BackgroundColor3 = currentTheme.Border}, 0.2)
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    Tween(OptionButton, {BackgroundColor3 = currentTheme.Tertiary}, 0.2)
                end)
            end
            
            DropdownButton.MouseButton1Click:Connect(function()
                opened = not opened
                local newSize = opened and (40 + (#options * 32)) or 40
                Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, newSize)}, 0.3)
            end)
            
            table.insert(Tab.Elements, Dropdown)
            callback(selected)
            
            return Dropdown
        end
        
        table.insert(Window.Tabs, Tab)
        return Tab
    end
    
    Window:LoadConfig()
    
    return Window
end

return UILib
