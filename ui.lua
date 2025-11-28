local club = {}

local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")

local killSwitchId = "club_instance"
if _G[killSwitchId] then
    pcall(function() _G[killSwitchId]:Destroy() end)
    _G[killSwitchId] = nil
    task.wait(0.1)
end

local isMobile = userInputService.TouchEnabled and not userInputService.KeyboardEnabled
local executorName = (identifyexecutor and identifyexecutor()) or "unknown"

local theme = {
    background = Color3.fromRGB(15, 15, 17),
    surface = Color3.fromRGB(20, 20, 23),
    raised = Color3.fromRGB(25, 25, 28),
    overlay = Color3.fromRGB(30, 30, 34),
    accent = Color3.fromRGB(130, 95, 255),
    accentDim = Color3.fromRGB(100, 70, 200),
    text = Color3.fromRGB(245, 245, 250),
    subtext = Color3.fromRGB(160, 160, 170),
    dimtext = Color3.fromRGB(120, 120, 130),
    border = Color3.fromRGB(40, 40, 45),
    success = Color3.fromRGB(90, 200, 130),
    warning = Color3.fromRGB(255, 200, 90),
    error = Color3.fromRGB(255, 100, 100)
}

local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function tween(obj, props, time, style, direction)
    return tweenService:Create(obj, TweenInfo.new(
        time or 0.2,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    ), props):Play()
end

local function corner(parent, radius)
    return create("UICorner", {Parent = parent, CornerRadius = UDim.new(0, radius or 4)})
end

local function stroke(parent, color, thickness, transparency)
    return create("UIStroke", {
        Parent = parent,
        Color = color or theme.border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
end

local function shadow(parent, size, transparency)
    return create("ImageLabel", {
        Name = "shadow",
        Parent = parent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, size or 40, 1, size or 40),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = transparency or 0.6,
        ZIndex = 0,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277)
    })
end

function club:window(cfg)
    cfg = cfg or {}
    local name = cfg.name or "club"
    local size = cfg.size or (isMobile and {350, 500} or {680, 520})
    local config = {}
    local configFile = cfg.configFile or "club.json"

    local gui = create("ScreenGui", {
        Name = httpService:GenerateGUID(false),
        Parent = game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
    _G[killSwitchId] = gui

    local notifications = create("Frame", {
        Name = "notifs",
        Parent = gui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 1, -20),
        Size = UDim2.new(0, 310, 0, 600),
        AnchorPoint = Vector2.new(0, 1),
        ZIndex = 999
    })
    create("UIListLayout", {
        Parent = notifications,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 6)
    })

    local main = create("Frame", {
        Name = "main",
        Parent = gui,
        BackgroundColor3 = theme.background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -size[1]/2, 0.5, -size[2]/2),
        Size = UDim2.new(0, size[1], 0, size[2]),
        ClipsDescendants = false
    })
    corner(main, 6)
    stroke(main, theme.border, 1)
    shadow(main, 60, 0.7)

    local holder = create("Frame", {
        Name = "holder",
        Parent = main,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0)
    })

    local topbar = create("Frame", {
        Name = "topbar",
        Parent = holder,
        BackgroundColor3 = theme.surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40)
    })
    corner(topbar, 6)
    stroke(topbar, theme.border, 1)

    local accent = create("Frame", {
        Parent = topbar,
        BackgroundColor3 = theme.accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1)
    })

    local title = create("TextLabel", {
        Parent = topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = theme.text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local close = create("TextButton", {
        Parent = topbar,
        BackgroundColor3 = theme.raised,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -32, 0.5, -12),
        Size = UDim2.new(0, 24, 0, 24),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = theme.subtext,
        TextSize = 16,
        AutoButtonColor = false
    })
    corner(close, 4)

    local sidebar = create("Frame", {
        Name = "sidebar",
        Parent = holder,
        BackgroundColor3 = theme.surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 40),
        Size = isMobile and UDim2.new(1, 0, 0, 36) or UDim2.new(0, 150, 1, -40)
    })
    stroke(sidebar, theme.border, 1)

    local tabHolder = create("Frame", {
        Parent = sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0)
    })
    local tabLayout = create("UIListLayout", {
        Parent = tabHolder,
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = isMobile and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 4)
    })
    create("UIPadding", {
        Parent = tabHolder,
        PaddingTop = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6)
    })

    local container = create("Frame", {
        Name = "container",
        Parent = holder,
        BackgroundTransparency = 1,
        Position = isMobile and UDim2.new(0, 0, 0, 76) or UDim2.new(0, 150, 0, 40),
        Size = isMobile and UDim2.new(1, 0, 1, -76) or UDim2.new(1, -150, 1, -40)
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
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    close.MouseButton1Click:Connect(function()
        tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.3)
        gui:Destroy()
        _G[killSwitchId] = nil
    end)

    close.MouseEnter:Connect(function()
        tween(close, {BackgroundColor3 = theme.error, TextColor3 = theme.text}, 0.15)
    end)
    close.MouseLeave:Connect(function()
        tween(close, {BackgroundColor3 = theme.raised, TextColor3 = theme.subtext}, 0.15)
    end)

    local window = {
        tabs = {},
        currentTab = nil,
        config = config,
        executor = executorName
    }

    function window:notify(cfg)
        cfg = cfg or {}
        local nTitle = cfg.title or "notification"
        local nText = cfg.text or ""
        local nTime = cfg.time or 4
        local nType = cfg.type or "info"

        local colors = {
            info = theme.accent,
            success = theme.success,
            warning = theme.warning,
            error = theme.error
        }
        local icons = {info = "ℹ", success = "✓", warning = "⚠", error = "✕"}

        local notif = create("Frame", {
            Parent = notifications,
            BackgroundColor3 = theme.surface,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        })
        corner(notif, 4)
        stroke(notif, theme.border, 1)
        shadow(notif, 25, 0.75)

        local bar = create("Frame", {
            Parent = notif,
            BackgroundColor3 = colors[nType],
            BorderSizePixel = 0,
            Size = UDim2.new(0, 2, 1, 0)
        })

        local icon = create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0.5, -10),
            Size = UDim2.new(0, 20, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = icons[nType],
            TextColor3 = colors[nType],
            TextSize = 14
        })

        local nTitleLabel = create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 40, 0, 6),
            Size = UDim2.new(1, -48, 0, 16),
            Font = Enum.Font.GothamBold,
            Text = nTitle,
            TextColor3 = theme.text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd
        })

        local nTextLabel = create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 40, 0, 24),
            Size = UDim2.new(1, -48, 0, 32),
            Font = Enum.Font.Gotham,
            Text = nText,
            TextColor3 = theme.subtext,
            TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        })

        local progress = create("Frame", {
            Parent = notif,
            BackgroundColor3 = colors[nType],
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -1),
            Size = UDim2.new(1, 0, 0, 1)
        })

        tween(notif, {Size = UDim2.new(1, 0, 0, 64), BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Back)
        tween(progress, {Size = UDim2.new(0, 0, 0, 1)}, nTime, Enum.EasingStyle.Linear)

        task.delay(nTime, function()
            tween(notif, {BackgroundTransparency = 1}, 0.2)
            for _, v in pairs(notif:GetChildren()) do
                if v:IsA("TextLabel") then tween(v, {TextTransparency = 1}, 0.2) end
                if v:IsA("Frame") then tween(v, {BackgroundTransparency = 1}, 0.2) end
            end
            task.wait(0.2)
            notif:Destroy()
        end)
    end

    function window:save()
        if writefile then
            writefile(configFile, httpService:JSONEncode(config))
        end
    end

    function window:load()
        if readfile and isfile and isfile(configFile) then
            local success, data = pcall(function()
                return httpService:JSONDecode(readfile(configFile))
            end)
            if success and data then
                config = data
                window.config = config
                for _, tab in pairs(window.tabs) do
                    if tab.load then tab:load() end
                end
            end
        end
    end

    function window:tab(name)
        local tab = {name = name, sections = {}, container = nil}

        local btn = create("TextButton", {
            Parent = tabHolder,
            BackgroundColor3 = theme.raised,
            BorderSizePixel = 0,
            Size = isMobile and UDim2.new(0, 75, 1, -12) or UDim2.new(1, 0, 0, 32),
            Font = Enum.Font.GothamSemibold,
            Text = name,
            TextColor3 = theme.subtext,
            TextSize = 12,
            AutoButtonColor = false
        })
        corner(btn, 4)

        local indicator = create("Frame", {
            Parent = btn,
            BackgroundColor3 = theme.accent,
            BorderSizePixel = 0,
            Position = isMobile and UDim2.new(0, 0, 1, -2) or UDim2.new(0, 0, 0, 0),
            Size = isMobile and UDim2.new(0, 0, 0, 2) or UDim2.new(0, 2, 0, 0),
            Visible = false
        })
        if isMobile then corner(indicator, 1) end

        local content = create("ScrollingFrame", {
            Parent = container,
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.accent,
            ScrollBarImageTransparency = 0.7,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        create("UIListLayout", {
            Parent = content,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        create("UIPadding", {
            Parent = content,
            PaddingTop = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8)
        })

        tab.container = content

        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(window.tabs) do
                t.container.Visible = false
                local b = tabHolder:FindFirstChild(t.name)
                if b then
                    tween(b, {BackgroundColor3 = theme.raised, TextColor3 = theme.subtext}, 0.15)
                    local ind = b:FindFirstChild("Frame")
                    if ind then
                        ind.Visible = false
                        tween(ind, {Size = isMobile and UDim2.new(0, 0, 0, 2) or UDim2.new(0, 2, 0, 0)}, 0.2)
                    end
                end
            end
            content.Visible = true
            tween(btn, {BackgroundColor3 = theme.overlay, TextColor3 = theme.text}, 0.15)
            indicator.Visible = true
            tween(indicator, {Size = isMobile and UDim2.new(1, 0, 0, 2) or UDim2.new(0, 2, 1, 0)}, 0.2, Enum.EasingStyle.Quad)
            window.currentTab = tab
        end)

        btn.MouseEnter:Connect(function()
            if content.Visible == false then
                tween(btn, {BackgroundColor3 = theme.overlay}, 0.15)
            end
        end)
        btn.MouseLeave:Connect(function()
            if content.Visible == false then
                tween(btn, {BackgroundColor3 = theme.raised}, 0.15)
            end
        end)

        if not window.currentTab then
            btn.MouseButton1Click:Connect(function() end)
            content.Visible = true
            btn.BackgroundColor3 = theme.overlay
            btn.TextColor3 = theme.text
            indicator.Visible = true
            indicator.Size = isMobile and UDim2.new(1, 0, 0, 2) or UDim2.new(0, 2, 1, 0)
            window.currentTab = tab
        end

        function tab:load()
            for _, section in pairs(tab.sections) do
                if section.load then section:load() end
            end
        end

        function tab:section(name)
            local section = {name = name, elements = {}}

            local frame = create("Frame", {
                Parent = content,
                BackgroundColor3 = theme.surface,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            corner(frame, 4)
            stroke(frame, theme.border, 1)

            local header = create("TextLabel", {
                Parent = frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 8),
                Size = UDim2.new(1, -24, 0, 18),
                Font = Enum.Font.GothamBold,
                Text = name,
                TextColor3 = theme.text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local divider = create("Frame", {
                Parent = frame,
                BackgroundColor3 = theme.border,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 8, 0, 30),
                Size = UDim2.new(1, -16, 0, 1)
            })

            local sectionContent = create("Frame", {
                Parent = frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 35),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            create("UIListLayout", {
                Parent = sectionContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4)
            })
            create("UIPadding", {
                Parent = sectionContent,
                PaddingTop = UDim.new(0, 0),
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8)
            })

            function section:load()
                for _, element in pairs(section.elements) do
                    if element.load then element:load() end
                end
            end

            function section:toggle(cfg)
                cfg = cfg or {}
                local toggleName = cfg.name or "toggle"
                local default = cfg.default or false
                local callback = cfg.callback or function() end
                local flag = cfg.flag or toggleName

                if config[flag] ~= nil then default = config[flag] end
                local toggled = default

                local toggleFrame = create("Frame", {
                    Parent = sectionContent,
                    BackgroundColor3 = theme.raised,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 36)
                })
                corner(toggleFrame, 4)

                local label = create("TextLabel", {
                    Parent = toggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = toggleName,
                    TextColor3 = theme.text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local switch = create("Frame", {
                    Parent = toggleFrame,
                    BackgroundColor3 = toggled and theme.accent or theme.border,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -44, 0.5, -9),
                    Size = UDim2.new(0, 36, 0, 18)
                })
                corner(switch, 9)

                local knob = create("Frame", {
                    Parent = switch,
                    BackgroundColor3 = theme.text,
                    BorderSizePixel = 0,
                    Position = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                    Size = UDim2.new(0, 14, 0, 14)
                })
                corner(knob, 7)

                local btn = create("TextButton", {
                    Parent = toggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })

                local toggle = {}
                function toggle:set(value)
                    toggled = value
                    config[flag] = value
                    tween(switch, {BackgroundColor3 = toggled and theme.accent or theme.border}, 0.2)
                    tween(knob, {Position = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.2, Enum.EasingStyle.Quad)
                    callback(toggled)
                end

                function toggle:load()
                    if config[flag] ~= nil then toggle:set(config[flag]) end
                end

                btn.MouseButton1Click:Connect(function() toggle:set(not toggled) end)
                btn.MouseEnter:Connect(function()
                    tween(toggleFrame, {BackgroundColor3 = theme.overlay}, 0.15)
                end)
                btn.MouseLeave:Connect(function()
                    tween(toggleFrame, {BackgroundColor3 = theme.raised}, 0.15)
                end)

                table.insert(section.elements, toggle)
                callback(toggled)
                return toggle
            end

            function section:slider(cfg)
                cfg = cfg or {}
                local sliderName = cfg.name or "slider"
                local min = cfg.min or 0
                local max = cfg.max or 100
                local default = cfg.default or min
                local increment = cfg.increment or 1
                local callback = cfg.callback or function() end
                local flag = cfg.flag or sliderName

                if config[flag] ~= nil then default = config[flag] end
                local value = default

                local sliderFrame = create("Frame", {
                    Parent = sectionContent,
                    BackgroundColor3 = theme.raised,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 44)
                })
                corner(sliderFrame, 4)

                local label = create("TextLabel", {
                    Parent = sliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 6),
                    Size = UDim2.new(1, -70, 0, 14),
                    Font = Enum.Font.GothamMedium,
                    Text = sliderName,
                    TextColor3 = theme.text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local valueLabel = create("TextLabel", {
                    Parent = sliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -60, 0, 6),
                    Size = UDim2.new(0, 50, 0, 14),
                    Font = Enum.Font.GothamBold,
                    Text = tostring(value),
                    TextColor3 = theme.accent,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local track = create("Frame", {
                    Parent = sliderFrame,
                    BackgroundColor3 = theme.border,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 1, -14),
                    Size = UDim2.new(1, -20, 0, 3)
                })
                corner(track, 2)

                local fill = create("Frame", {
                    Parent = track,
                    BackgroundColor3 = theme.accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                })
                corner(fill, 2)

                local btn = create("TextButton", {
                    Parent = track,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 10),
                    Position = UDim2.new(0, 0, 0, -5),
                    Text = ""
                })

                local dragging = false
                local slider = {}

                function slider:set(val)
                    value = math.clamp(math.floor((val - min) / increment + 0.5) * increment + min, min, max)
                    config[flag] = value
                    local percent = (value - min) / (max - min)
                    tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                    valueLabel.Text = tostring(value)
                    callback(value)
                end

                function slider:load()
                    if config[flag] ~= nil then slider:set(config[flag]) end
                end

                btn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        local function update()
                            local mouse = isMobile and input.Position or userInputService:GetMouseLocation()
                            local percent = math.clamp((mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                            slider:set(min + (max - min) * percent)
                        end
                        update()
                        local conn = userInputService.InputChanged:Connect(function(input2)
                            if (input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch) and dragging then
                                update()
                            end
                        end)
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                dragging = false
                                conn:Disconnect()
                            end
                        end)
                    end
                end)

                btn.MouseEnter:Connect(function()
                    if not isMobile then tween(sliderFrame, {BackgroundColor3 = theme.overlay}, 0.15) end
                end)
                btn.MouseLeave:Connect(function()
                    if not isMobile then tween(sliderFrame, {BackgroundColor3 = theme.raised}, 0.15) end
                end)

                table.insert(section.elements, slider)
                callback(value)
                return slider
            end

            function section:button(cfg)
                cfg = cfg or {}
                local buttonName = cfg.name or "button"
                local callback = cfg.callback or function() end

                local buttonFrame = create("TextButton", {
                    Parent = sectionContent,
                    BackgroundColor3 = theme.accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    Font = Enum.Font.GothamSemibold,
                    Text = buttonName,
                    TextColor3 = theme.text,
                    TextSize = 12,
                    AutoButtonColor = false
                })
                corner(buttonFrame, 4)

                buttonFrame.MouseButton1Click:Connect(callback)
                buttonFrame.MouseEnter:Connect(function()
                    if not isMobile then tween(buttonFrame, {BackgroundColor3 = theme.accentDim}, 0.15) end
                end)
                buttonFrame.MouseLeave:Connect(function()
                    if not isMobile then tween(buttonFrame, {BackgroundColor3 = theme.accent}, 0.15) end
                end)

                return {}
            end

            function section:textbox(cfg)
                cfg = cfg or {}
                local textboxName = cfg.name or "textbox"
                local default = cfg.default or ""
                local placeholder = cfg.placeholder or "..."
                local callback = cfg.callback or function() end
                local flag = cfg.flag or textboxName

                if config[flag] ~= nil then default = config[flag] end

                local textboxFrame = create("Frame", {
                    Parent = sectionContent,
                    BackgroundColor3 = theme.raised,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 36)
                })
                corner(textboxFrame, 4)

                local label = create("TextLabel", {
                    Parent = textboxFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(0.4, -5, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = textboxName,
                    TextColor3 = theme.text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local input = create("TextBox", {
                    Parent = textboxFrame,
                    BackgroundColor3 = theme.border,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.4, 0, 0.5, -11),
                    Size = UDim2.new(0.6, -14, 0, 22),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = theme.dimtext,
                    Text = default,
                    TextColor3 = theme.text,
                    TextSize = 11,
                    ClearTextOnFocus = false
                })
                corner(input, 3)
                create("UIPadding", {Parent = input, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})

                local textbox = {}
                function textbox:set(text)
                    input.Text = text
                    config[flag] = text
                    callback(text)
                end

                function textbox:load()
                    if config[flag] ~= nil then textbox:set(config[flag]) end
                end

                input.FocusLost:Connect(function() textbox:set(input.Text) end)
                input.Focused:Connect(function() tween(input, {BackgroundColor3 = theme.overlay}, 0.15) end)
                input.FocusLost:Connect(function() tween(input, {BackgroundColor3 = theme.border}, 0.15) end)

                table.insert(section.elements, textbox)
                callback(default)
                return textbox
            end

            function section:dropdown(cfg)
                cfg = cfg or {}
                local dropdownName = cfg.name or "dropdown"
                local options = cfg.options or {}
                local default = cfg.default or options[1]
                local callback = cfg.callback or function() end
                local flag = cfg.flag or dropdownName

                if config[flag] ~= nil then default = config[flag] end
                local selected = default
                local opened = false

                local dropdownFrame = create("Frame", {
                    Parent = sectionContent,
                    BackgroundColor3 = theme.raised,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 36),
                    ClipsDescendants = true
                })
                corner(dropdownFrame, 4)

                local label = create("TextLabel", {
                    Parent = dropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -35, 0, 36),
                    Font = Enum.Font.GothamMedium,
                    Text = dropdownName .. ": " .. tostring(selected),
                    TextColor3 = theme.text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local arrow = create("TextLabel", {
                    Parent = dropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -26, 0, 0),
                    Size = UDim2.new(0, 16, 0, 36),
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = theme.accent,
                    TextSize = 9
                })

                local btn = create("TextButton", {
                    Parent = dropdownFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 36),
                    Text = ""
                })

                local optionsHolder = create("Frame", {
                    Parent = dropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 36),
                    Size = UDim2.new(1, 0, 0, 0)
                })
                create("UIListLayout", {Parent = optionsHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
                create("UIPadding", {Parent = optionsHolder, PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 4)})

                local dropdown = {}
                function dropdown:set(option)
                    selected = option
                    config[flag] = option
                    label.Text = dropdownName .. ": " .. tostring(option)
                    callback(option)
                end

                function dropdown:load()
                    if config[flag] ~= nil then dropdown:set(config[flag]) end
                end

                for _, option in ipairs(options) do
                    local optionBtn = create("TextButton", {
                        Parent = optionsHolder,
                        BackgroundColor3 = theme.border,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 26),
                        Font = Enum.Font.Gotham,
                        Text = tostring(option),
                        TextColor3 = theme.text,
                        TextSize = 11,
                        AutoButtonColor = false
                    })
                    corner(optionBtn, 3)

                    optionBtn.MouseButton1Click:Connect(function()
                        dropdown:set(option)
                        opened = false
                        tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 36)}, 0.2)
                        tween(arrow, {Rotation = 0}, 0.2)
                    end)

                    optionBtn.MouseEnter:Connect(function()
                        if not isMobile then tween(optionBtn, {BackgroundColor3 = theme.accent}, 0.15) end
                    end)
                    optionBtn.MouseLeave:Connect(function()
                        if not isMobile then tween(optionBtn, {BackgroundColor3 = theme.border}, 0.15) end
                    end)
                end

                btn.MouseButton1Click:Connect(function()
                    opened = not opened
                    local newSize = opened and (36 + 8 + (#options * 28)) or 36
                    tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, newSize)}, 0.2)
                    tween(arrow, {Rotation = opened and 180 or 0}, 0.2)
                end)

                table.insert(section.elements, dropdown)
                callback(selected)
                return dropdown
            end

            function section:label(text)
                local labelFrame = create("Frame", {
                    Parent = sectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18)
                })

                local label = create("TextLabel", {
                    Parent = labelFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 4, 0, 0),
                    Size = UDim2.new(1, -8, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = text,
                    TextColor3 = theme.dimtext,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                return {set = function(_, newText) label.Text = newText end}
            end

            table.insert(tab.sections, section)
            return section
        end

        table.insert(window.tabs, tab)
        return tab
    end

    window:load()
    main.Size = UDim2.new(0, 0, 0, 0)
    tween(main, {Size = UDim2.new(0, size[1], 0, size[2])}, 0.4, Enum.EasingStyle.Back)

    return window
end

return club
