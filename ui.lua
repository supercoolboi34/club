local Club = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local KILL_SWITCH_ID = "Club_UI_Instance"
if _G[KILL_SWITCH_ID] then
    pcall(function()
        _G[KILL_SWITCH_ID]:Destroy()
    end)
    _G[KILL_SWITCH_ID] = nil
    task.wait(0.2)
end

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function GetExecutor()
    local executors = {
        {check = function() return identifyexecutor end, name = function() return identifyexecutor() end},
        {check = function() return KRNL_LOADED end, name = function() return "KRNL" end},
        {check = function() return syn end, name = function() return "Synapse X" end},
        {check = function() return SONA_LOADED end, name = function() return "Sona" end},
        {check = function() return getexecutorname end, name = function() return getexecutorname() end},
        {check = function() return issentinelclosure end, name = function() return "Sentinel" end},
        {check = function() return OXYGEN_LOADED end, name = function() return "Oxygen U" end},
        {check = function() return fluxus end, name = function() return "Fluxus" end},
        {check = function() return getscriptenvs end, name = function() return "Arceus X" end}
    }
    
    for _, executor in ipairs(executors) do
        if executor.check() then
            local success, name = pcall(executor.name)
            if success and name then
                return name
            end
        end
    end
    
    return "Unknown"
end

local Themes = {
    Dark = {
        Primary = Color3.fromRGB(20, 20, 25),
        Secondary = Color3.fromRGB(28, 28, 35),
        Tertiary = Color3.fromRGB(35, 35, 42),
        Section = Color3.fromRGB(25, 25, 30),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentDark = Color3.fromRGB(71, 82, 196),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(160, 160, 170),
        Border = Color3.fromRGB(50, 50, 60),
        Glow = Color3.fromRGB(88, 101, 242),
        Success = Color3.fromRGB(67, 181, 129),
        Error = Color3.fromRGB(240, 71, 71),
        GradientStart = Color3.fromRGB(88, 101, 242),
        GradientEnd = Color3.fromRGB(155, 89, 182)
    },
    Light = {
        Primary = Color3.fromRGB(245, 245, 250),
        Secondary = Color3.fromRGB(255, 255, 255),
        Tertiary = Color3.fromRGB(240, 240, 245),
        Section = Color3.fromRGB(250, 250, 252),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentDark = Color3.fromRGB(71, 82, 196),
        Text = Color3.fromRGB(20, 20, 30),
        TextDim = Color3.fromRGB(100, 100, 110),
        Border = Color3.fromRGB(220, 220, 230),
        Glow = Color3.fromRGB(88, 101, 242),
        Success = Color3.fromRGB(67, 181, 129),
        Error = Color3.fromRGB(240, 71, 71),
        GradientStart = Color3.fromRGB(88, 101, 242),
        GradientEnd = Color3.fromRGB(155, 89, 182)
    },
    Purple = {
        Primary = Color3.fromRGB(25, 15, 35),
        Secondary = Color3.fromRGB(32, 22, 42),
        Tertiary = Color3.fromRGB(40, 28, 50),
        Section = Color3.fromRGB(28, 18, 38),
        Accent = Color3.fromRGB(155, 89, 182),
        AccentDark = Color3.fromRGB(128, 70, 156),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(180, 170, 190),
        Border = Color3.fromRGB(60, 45, 75),
        Glow = Color3.fromRGB(155, 89, 182),
        Success = Color3.fromRGB(67, 181, 129),
        Error = Color3.fromRGB(240, 71, 71),
        GradientStart = Color3.fromRGB(155, 89, 182),
        GradientEnd = Color3.fromRGB(88, 101, 242)
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

local function AddGlow(frame, color, size, transparency)
    local glow = CreateInstance("ImageLabel", {
        Name = "Glow",
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, size or 30, 1, size or 30),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://5028857084",
        ImageColor3 = color,
        ImageTransparency = transparency or 0.6,
        ZIndex = 0
    })
    return glow
end

local function AddStroke(frame, color, thickness)
    local stroke = CreateInstance("UIStroke", {
        Parent = frame,
        Color = color,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
    return stroke
end

local function AddGradient(frame, startColor, endColor, rotation)
    local gradient = CreateInstance("UIGradient", {
        Parent = frame,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, startColor),
            ColorSequenceKeypoint.new(1, endColor)
        }),
        Rotation = rotation or 90
    })
    return gradient
end

function Club:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "Club"
    local themeName = config.Theme or "Dark"
    local currentTheme = Themes[themeName]
    local configFile = config.ConfigFile or "Club_Config.json"
    local savedConfig = {}
    local executorName = GetExecutor()

    local ScreenGui = CreateInstance("ScreenGui", {
        Name = "Club_" .. HttpService:GenerateGUID(false),
        Parent = game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })
    
    _G[KILL_SWITCH_ID] = ScreenGui

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
        Position = IsMobile and UDim2.new(0.5, -175, 0.5, -250) or UDim2.new(0.5, -350, 0.5, -250),
        Size = IsMobile and UDim2.new(0, 350, 0, 500) or UDim2.new(0, 700, 0, 500),
        ClipsDescendants = true
    })
    
    AddGlow(MainFrame, currentTheme.Glow, 40, 0.7)
    AddStroke(MainFrame, currentTheme.Border, 1)
    
    CreateInstance("UICorner", {
        Parent = MainFrame,
        CornerRadius = UDim.new(0, 10)
    })

    local TopBar = CreateInstance("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundColor3 = currentTheme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 45)
    })
    
    AddGradient(TopBar, currentTheme.GradientStart, currentTheme.GradientEnd, 45)
    AddStroke(TopBar, currentTheme.Border, 1)
    
    CreateInstance("UICorner", {
        Parent = TopBar,
        CornerRadius = UDim.new(0, 10)
    })

    local Title = CreateInstance("TextLabel", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "🎮 " .. windowName,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = IsMobile and 14 or 17,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextStrokeTransparency = 0.8
    })

    local MinimizeBtn = CreateInstance("TextButton", {
        Parent = TopBar,
        BackgroundColor3 = currentTheme.Tertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -70, 0.5, -13),
        Size = UDim2.new(0, 26, 0, 26),
        Font = Enum.Font.GothamBold,
        Text = "−",
        TextColor3 = currentTheme.Text,
        TextSize = 16
    })
    
    CreateInstance("UICorner", {
        Parent = MinimizeBtn,
        CornerRadius = UDim.new(0, 6)
    })
    AddStroke(MinimizeBtn, currentTheme.Border, 1)

    local CloseBtn = CreateInstance("TextButton", {
        Parent = TopBar,
        BackgroundColor3 = currentTheme.Tertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -35, 0.5, -13),
        Size = UDim2.new(0, 26, 0, 26),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = currentTheme.Text,
        TextSize = 18
    })
    
    CreateInstance("UICorner", {
        Parent = CloseBtn,
        CornerRadius = UDim.new(0, 6)
    })
    AddStroke(CloseBtn, currentTheme.Border, 1)

    local TabContainer = CreateInstance("Frame", {
        Name = "Tabs",
        Parent = MainFrame,
        BackgroundColor3 = currentTheme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 45),
        Size = IsMobile and UDim2.new(1, 0, 0, 45) or UDim2.new(0, 150, 1, -45)
    })
    
    AddStroke(TabContainer, currentTheme.Border, 1)
    
    local tabLayout = CreateInstance(IsMobile and "UIListLayout" or "UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = IsMobile and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
        Padding = UDim.new(0, IsMobile and 5 or 8)
    })
    
    CreateInstance("UIPadding", {
        Parent = TabContainer,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
    })

    local ContentFrame = CreateInstance("Frame", {
        Name = "Content",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = IsMobile and UDim2.new(0, 0, 0, 90) or UDim2.new(0, 150, 0, 45),
        Size = IsMobile and UDim2.new(1, 0, 1, -90) or UDim2.new(1, -150, 1, -45)
    })

    local ResizeHandle
    if not IsMobile then
        ResizeHandle = CreateInstance("Frame", {
            Name = "ResizeHandle",
            Parent = MainFrame,
            BackgroundColor3 = currentTheme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -18, 1, -18),
            Size = UDim2.new(0, 18, 0, 18),
            ZIndex = 10
        })
        
        CreateInstance("UICorner", {
            Parent = ResizeHandle,
            CornerRadius = UDim.new(0, 4)
        })
        AddGlow(ResizeHandle, currentTheme.Glow, 10, 0.5)
    end

    local dragging, dragInput, dragStart, startPos
    local resizing, resizeStart, startSize
    local minimized = false

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

    if not IsMobile and ResizeHandle then
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
    end

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            elseif resizing and not IsMobile then
                local delta = input.Position - resizeStart
                local newSizeX = math.max(500, startSize.X.Offset + delta.X)
                local newSizeY = math.max(400, startSize.Y.Offset + delta.Y)
                MainFrame.Size = UDim2.new(0, newSizeX, 0, newSizeY)
            end
        end
    end)

    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(MainFrame, {Size = UDim2.new(MainFrame.Size.X.Scale, MainFrame.Size.X.Offset, 0, 45)}, 0.3)
            MinimizeBtn.Text = "+"
        else
            Tween(MainFrame, {Size = IsMobile and UDim2.new(0, 350, 0, 500) or UDim2.new(0, 700, 0, 500)}, 0.3)
            MinimizeBtn.Text = "−"
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        wait(0.3)
        ScreenGui:Destroy()
        _G[KILL_SWITCH_ID] = nil
    end)

    MinimizeBtn.MouseEnter:Connect(function()
        Tween(MinimizeBtn, {BackgroundColor3 = currentTheme.Accent}, 0.2)
    end)

    MinimizeBtn.MouseLeave:Connect(function()
        Tween(MinimizeBtn, {BackgroundColor3 = currentTheme.Tertiary}, 0.2)
    end)

    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = currentTheme.Error}, 0.2)
    end)

    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = currentTheme.Tertiary}, 0.2)
    end)

    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Theme = currentTheme
    Window.Config = savedConfig
    Window.ExecutorName = executorName

    function Window:Notify(config)
        config = config or {}
        local title = config.Title or "Notification"
        local text = config.Text or ""
        local duration = config.Duration or 3
        local notifType = config.Type or "Default"
        
        local typeColors = {
            Default = currentTheme.Accent,
            Success = currentTheme.Success,
            Error = currentTheme.Error
        }
        
        local notif = CreateInstance("Frame", {
            Parent = NotificationContainer,
            BackgroundColor3 = currentTheme.Secondary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 85),
            ClipsDescendants = true,
            Position = UDim2.new(1, 0, 0, 0)
        })
        
        CreateInstance("UICorner", {
            Parent = notif,
            CornerRadius = UDim.new(0, 8)
        })
        
        AddGlow(notif, typeColors[notifType], 20, 0.7)
        AddStroke(notif, currentTheme.Border, 1)
        
        local accent = CreateInstance("Frame", {
            Parent = notif,
            BackgroundColor3 = typeColors[notifType],
            BorderSizePixel = 0,
            Size = UDim2.new(0, 4, 1, 0)
        })
        
        AddGradient(accent, typeColors[notifType], currentTheme.GradientEnd, 0)
        
        local titleLabel = CreateInstance("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 18, 0, 10),
            Size = UDim2.new(1, -36, 0, 22),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = currentTheme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local textLabel = CreateInstance("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 18, 0, 38),
            Size = UDim2.new(1, -36, 0, 40),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = currentTheme.TextDim,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        })
        
        Tween(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.4)
        
        task.delay(duration, function()
            Tween(notif, {Position = UDim2.new(1, 0, 0, 0)}, 0.4)
            task.wait(0.4)
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
        
        for _, child in ipairs(TopBar:GetChildren()) do
            if child:IsA("UIGradient") then
                child.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, currentTheme.GradientStart),
                    ColorSequenceKeypoint.new(1, currentTheme.GradientEnd)
                })
            end
        end
        
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
        Tab.Sections = {}
        Tab.Container = nil
        
        local TabButton = CreateInstance("TextButton", {
            Name = name,
            Parent = TabContainer,
            BackgroundColor3 = currentTheme.Tertiary,
            BorderSizePixel = 0,
            Size = IsMobile and UDim2.new(0, 80, 1, -20) or UDim2.new(1, 0, 0, 38),
            Font = Enum.Font.GothamSemibold,
            Text = name,
            TextColor3 = currentTheme.TextDim,
            TextSize = IsMobile and 11 or 13
        })
        
        CreateInstance("UICorner", {
            Parent = TabButton,
            CornerRadius = UDim.new(0, 7)
        })
        AddStroke(TabButton, currentTheme.Border, 1)
        
        local TabContent = CreateInstance("ScrollingFrame", {
            Name = name .. "Content",
            Parent = ContentFrame,
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 5,
            ScrollBarImageColor3 = currentTheme.Accent,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        
        CreateInstance("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12)
        })
        
        CreateInstance("UIPadding", {
            Parent = TabContent,
            PaddingTop = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12)
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
            Tween(TabButton, {BackgroundColor3 = currentTheme.Accent, TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
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
            TabContent.Visible = true
            TabButton.BackgroundColor3 = currentTheme.Accent
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            Window.CurrentTab = Tab
        end
        
        function Tab:Refresh()
            TabButton.BackgroundColor3 = TabContent.Visible and currentTheme.Accent or currentTheme.Tertiary
            TabButton.TextColor3 = TabContent.Visible and Color3.fromRGB(255, 255, 255) or currentTheme.TextDim
            
            for _, section in pairs(Tab.Sections) do
                if section.Refresh then
                    section:Refresh()
                end
            end
        end
        
        function Tab:LoadValues()
            for _, section in pairs(Tab.Sections) do
                if section.LoadValues then
                    section:LoadValues()
                end
            end
        end
        
        function Tab:AddSection(name)
            local Section = {}
            Section.Name = name
            Section.Elements = {}
            
            local SectionFrame = CreateInstance("Frame", {
                Parent = TabContent,
                BackgroundColor3 = currentTheme.Section,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            CreateInstance("UICorner", {
                Parent = SectionFrame,
                CornerRadius = UDim.new(0, 8)
            })
            
            AddStroke(SectionFrame, currentTheme.Border, 1)
            AddGradient(SectionFrame, currentTheme.Section, Color3.fromRGB(
                currentTheme.Section.R * 255 * 0.95,
                currentTheme.Section.G * 255 * 0.95,
                currentTheme.Section.B * 255 * 0.95
            ), 135)
            
            local SectionHeader = CreateInstance("Frame", {
                Parent = SectionFrame,
                BackgroundColor3 = currentTheme.Tertiary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 35)
            })
            
            CreateInstance("UICorner", {
                Parent = SectionHeader,
                CornerRadius = UDim.new(0, 8)
            })
            
            AddGradient(SectionHeader, currentTheme.Tertiary, Color3.fromRGB(
                currentTheme.Tertiary.R * 255 * 0.92,
                currentTheme.Tertiary.G * 255 * 0.92,
                currentTheme.Tertiary.B * 255 * 0.92
            ), 90)
            
            local SectionTitle = CreateInstance("TextLabel", {
                Parent = SectionHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = name,
                TextColor3 = currentTheme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local SectionContent = CreateInstance("Frame", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 35),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            CreateInstance("UIListLayout", {
                Parent = SectionContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })
            
            CreateInstance("UIPadding", {
                Parent = SectionContent,
                PaddingTop = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 10)
            })
            
            Section.Container = SectionContent
            Section.Frame = SectionFrame
            
            function Section:Refresh()
                SectionFrame.BackgroundColor3 = currentTheme.Section
                SectionHeader.BackgroundColor3 = currentTheme.Tertiary
                SectionTitle.TextColor3 = currentTheme.Text
                
                for _, element in pairs(Section.Elements) do
                    if element.Refresh then
                        element:Refresh()
                    end
                end
            end
            
            function Section:LoadValues()
                for _, element in pairs(Section.Elements) do
                    if element.LoadValue then
                        element:LoadValue()
                    end
                end
            end
            
            function Section:AddToggle(config)
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
                    Parent = SectionContent,
                    BackgroundColor3 = currentTheme.Secondary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 42)
                })
                
                CreateInstance("UICorner", {
                    Parent = ToggleFrame,
                    CornerRadius = UDim.new(0, 7)
                })
                AddStroke(ToggleFrame, currentTheme.Border, 1)
                
                local ToggleLabel = CreateInstance("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0),
                    Size = UDim2.new(1, -75, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = name,
                    TextColor3 = currentTheme.Text,
                    TextSize = IsMobile and 12 or 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ToggleButton = CreateInstance("Frame", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = toggled and currentTheme.Accent or currentTheme.Tertiary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -52, 0.5, -11),
                    Size = UDim2.new(0, 44, 0, 22)
                })
                
                CreateInstance("UICorner", {
                    Parent = ToggleButton,
                    CornerRadius = UDim.new(1, 0)
                })
                AddStroke(ToggleButton, currentTheme.Border, 1)
                
                if toggled then
                    AddGlow(ToggleButton, currentTheme.Accent, 15, 0.5)
                end
                
                local ToggleCircle = CreateInstance("Frame", {
                    Parent = ToggleButton,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                    Size = UDim2.new(0, 18, 0, 18)
                })
                
                CreateInstance("UICorner", {
                    Parent = ToggleCircle,
                    CornerRadius = UDim.new(1, 0)
                })
                AddStroke(ToggleCircle, Color3.fromRGB(200, 200, 200), 1)
                
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
                    Tween(ToggleCircle, {Position = toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.25)
                    
                    local existingGlow = ToggleButton:FindFirstChild("Glow")
                    if toggled and not existingGlow then
                        AddGlow(ToggleButton, currentTheme.Accent, 15, 0.5)
                    elseif not toggled and existingGlow then
                        existingGlow:Destroy()
                    end
                    
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
                
                table.insert(Section.Elements, Toggle)
                callback(toggled)
                
                return Toggle
            end
            
            function Section:AddSlider(config)
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
                    Parent = SectionContent,
                    BackgroundColor3 = currentTheme.Secondary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 55)
                })
                
                CreateInstance("UICorner", {
                    Parent = SliderFrame,
                    CornerRadius = UDim.new(0, 7)
                })
                AddStroke(SliderFrame, currentTheme.Border, 1)
                
                local SliderLabel = CreateInstance("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 8),
                    Size = UDim2.new(1, -30, 0, 18),
                    Font = Enum.Font.GothamMedium,
                    Text = name,
                    TextColor3 = currentTheme.Text,
                    TextSize = IsMobile and 12 or 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ValueLabel = CreateInstance("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -65, 0, 8),
                    Size = UDim2.new(0, 50, 0, 18),
                    Font = Enum.Font.GothamBold,
                    Text = tostring(value),
                    TextColor3 = currentTheme.Accent,
                    TextSize = IsMobile and 12 or 13,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local SliderBack = CreateInstance("Frame", {
                    Parent = SliderFrame,
                    BackgroundColor3 = currentTheme.Tertiary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 15, 1, -22),
                    Size = UDim2.new(1, -30, 0, 7)
                })
                
                CreateInstance("UICorner", {
                    Parent = SliderBack,
                    CornerRadius = UDim.new(1, 0)
                })
                AddStroke(SliderBack, currentTheme.Border, 1)
                
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
                AddGradient(SliderFill, currentTheme.GradientStart, currentTheme.GradientEnd, 45)
                
                local SliderDot = CreateInstance("Frame", {
                    Parent = SliderBack,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new((value - min) / (max - min), -6, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12),
                    ZIndex = 2
                })
                
                CreateInstance("UICorner", {
                    Parent = SliderDot,
                    CornerRadius = UDim.new(1, 0)
                })
                AddStroke(SliderDot, currentTheme.Accent, 2)
                AddGlow(SliderDot, currentTheme.Accent, 10, 0.4)
                
                local SliderButton = CreateInstance("TextButton", {
                    Parent = SliderBack,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 15),
                    Position = UDim2.new(0, 0, 0, -7),
                    Text = ""
                })
                
                local dragging = false
                
                local Slider = {}
                
                function Slider:Set(val)
                    value = math.clamp(math.floor((val - min) / increment + 0.5) * increment + min, min, max)
                    savedConfig[flag] = value
                    
                    local percent = (value - min) / (max - min)
                    Tween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.15)
                    Tween(SliderDot, {Position = UDim2.new(percent, -6, 0.5, -6)}, 0.15)
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
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        
                        local function update()
                            local mouse = IsMobile and input.Position or UserInputService:GetMouseLocation()
                            local percent = math.clamp((mouse.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
                            Slider:Set(min + (max - min) * percent)
                        end
                        
                        update()
                        
                        local moveConnection
                        moveConnection = UserInputService.InputChanged:Connect(function(input2)
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
                
                SliderButton.MouseEnter:Connect(function()
                    if not IsMobile then
                        Tween(SliderFrame, {BackgroundColor3 = currentTheme.Tertiary}, 0.2)
                        Tween(SliderDot, {Size = UDim2.new(0, 14, 0, 14)}, 0.2)
                    end
                end)
                
                SliderButton.MouseLeave:Connect(function()
                    if not IsMobile then
                        Tween(SliderFrame, {BackgroundColor3 = currentTheme.Secondary}, 0.2)
                        Tween(SliderDot, {Size = UDim2.new(0, 12, 0, 12)}, 0.2)
                    end
                end)
                
                table.insert(Section.Elements, Slider)
                callback(value)
                
                return Slider
            end
            
            function Section:AddButton(config)
                config = config or {}
                local name = config.Name or "Button"
                local callback = config.Callback or function() end
                
                local ButtonFrame = CreateInstance("TextButton", {
                    Parent = SectionContent,
                    BackgroundColor3 = currentTheme.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 38),
                    Font = Enum.Font.GothamSemibold,
                    Text = name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = IsMobile and 12 or 13
                })
                
                CreateInstance("UICorner", {
                    Parent = ButtonFrame,
                    CornerRadius = UDim.new(0, 7)
                })
                AddGradient(ButtonFrame, currentTheme.GradientStart, currentTheme.GradientEnd, 45)
                AddStroke(ButtonFrame, currentTheme.Border, 1)
                AddGlow(ButtonFrame, currentTheme.Glow, 12, 0.6)
                
                local Button = {}
                
                function Button:Refresh()
                    ButtonFrame.BackgroundColor3 = currentTheme.Accent
                end
                
                ButtonFrame.MouseButton1Click:Connect(callback)
                
                ButtonFrame.MouseEnter:Connect(function()
                    if not IsMobile then
                        Tween(ButtonFrame, {BackgroundColor3 = currentTheme.AccentDark}, 0.2)
                    end
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    if not IsMobile then
                        Tween(ButtonFrame, {BackgroundColor3 = currentTheme.Accent}, 0.2)
                    end
                end)
                
                table.insert(Section.Elements, Button)
                
                return Button
            end
            
            function Section:AddLabel(text)
                local LabelFrame = CreateInstance("Frame", {
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 22)
                })
                
                local Label = CreateInstance("TextLabel", {
                    Parent = LabelFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 0),
                    Size = UDim2.new(1, -10, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = text,
                    TextColor3 = currentTheme.Accent,
                    TextSize = IsMobile and 12 or 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local LabelObj = {}
                
                function LabelObj:Set(newText)
                    Label.Text = newText
                end
                
                function LabelObj:Refresh()
                    Label.TextColor3 = currentTheme.Accent
                end
                
                table.insert(Section.Elements, LabelObj)
                
                return LabelObj
            end
            
            function Section:AddTextbox(config)
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
                    Parent = SectionContent,
                    BackgroundColor3 = currentTheme.Secondary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 42)
                })
                
                CreateInstance("UICorner", {
                    Parent = TextboxFrame,
                    CornerRadius = UDim.new(0, 7)
                })
                AddStroke(TextboxFrame, currentTheme.Border, 1)
                
                local TextboxLabel = CreateInstance("TextLabel", {
                    Parent = TextboxFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0),
                    Size = UDim2.new(0.35, 0, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = name,
                    TextColor3 = currentTheme.Text,
                    TextSize = IsMobile and 11 or 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local InputBox = CreateInstance("TextBox", {
                    Parent = TextboxFrame,
                    BackgroundColor3 = currentTheme.Tertiary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.37, 0, 0.5, -13),
                    Size = UDim2.new(0.63, -20, 0, 26),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = currentTheme.TextDim,
                    Text = default,
                    TextColor3 = currentTheme.Text,
                    TextSize = IsMobile and 11 or 12,
                    ClearTextOnFocus = false
                })
                
                CreateInstance("UICorner", {
                    Parent = InputBox,
                    CornerRadius = UDim.new(0, 5)
                })
                AddStroke(InputBox, currentTheme.Border, 1)
                
                CreateInstance("UIPadding", {
                    Parent = InputBox,
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10)
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
                
                InputBox.Focused:Connect(function()
                    Tween(InputBox, {BackgroundColor3 = currentTheme.Border}, 0.2)
                end)
                
                InputBox.FocusLost:Connect(function()
                    Tween(InputBox, {BackgroundColor3 = currentTheme.Tertiary}, 0.2)
                end)
                
                table.insert(Section.Elements, Textbox)
                callback(default)
                
                return Textbox
            end
            
            function Section:AddDropdown(config)
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
                    Parent = SectionContent,
                    BackgroundColor3 = currentTheme.Secondary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 42),
                    ClipsDescendants = true
                })
                
                CreateInstance("UICorner", {
                    Parent = DropdownFrame,
                    CornerRadius = UDim.new(0, 7)
                })
                AddStroke(DropdownFrame, currentTheme.Border, 1)
                
                local DropdownLabel = CreateInstance("TextLabel", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0),
                    Size = UDim2.new(1, -40, 0, 42),
                    Font = Enum.Font.GothamMedium,
                    Text = name .. ": " .. tostring(selected),
                    TextColor3 = currentTheme.Text,
                    TextSize = IsMobile and 11 or 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Arrow = CreateInstance("TextLabel", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -30, 0, 0),
                    Size = UDim2.new(0, 20, 0, 42),
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = currentTheme.Accent,
                    TextSize = 10
                })
                
                local DropdownButton = CreateInstance("TextButton", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 42),
                    Text = ""
                })
                
                local OptionsContainer = CreateInstance("Frame", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 42),
                    Size = UDim2.new(1, 0, 0, 0)
                })
                
                CreateInstance("UIListLayout", {
                    Parent = OptionsContainer,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 3)
                })
                
                CreateInstance("UIPadding", {
                    Parent = OptionsContainer,
                    PaddingTop = UDim.new(0, 5),
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 5)
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
                    Arrow.TextColor3 = currentTheme.Accent
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
                        Size = UDim2.new(1, 0, 0, 32),
                        Font = Enum.Font.Gotham,
                        Text = tostring(option),
                        TextColor3 = currentTheme.Text,
                        TextSize = IsMobile and 11 or 12
                    })
                    
                    CreateInstance("UICorner", {
                        Parent = OptionButton,
                        CornerRadius = UDim.new(0, 5)
                    })
                    AddStroke(OptionButton, currentTheme.Border, 1)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        Dropdown:Set(option)
                        opened = false
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 42)}, 0.3)
                        Tween(Arrow, {Rotation = 0}, 0.3)
                    end)
                    
                    OptionButton.MouseEnter:Connect(function()
                        if not IsMobile then
                            Tween(OptionButton, {BackgroundColor3 = currentTheme.Border}, 0.2)
                        end
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        if not IsMobile then
                            Tween(OptionButton, {BackgroundColor3 = currentTheme.Tertiary}, 0.2)
                        end
                    end)
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    opened = not opened
                    local newSize = opened and (42 + 10 + (#options * 35)) or 42
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, newSize)}, 0.3)
                    Tween(Arrow, {Rotation = opened and 180 or 0}, 0.3)
                end)
                
                table.insert(Section.Elements, Dropdown)
                callback(selected)
                
                return Dropdown
            end
            
            table.insert(Tab.Sections, Section)
            return Section
        end
        
        table.insert(Window.Tabs, Tab)
        return Tab
    end
    
    Window:LoadConfig()
    
    return Window
end

return Club
