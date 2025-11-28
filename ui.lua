local club = {}

local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local rs = game:GetService("RunService")
local http = game:GetService("HttpService")

local kill = "club_ui"
if _G[kill] then
    pcall(function() _G[kill]:Destroy() end)
    _G[kill] = nil
    task.wait(0.1)
end

local mobile = uis.TouchEnabled and not uis.KeyboardEnabled
local executor = (identifyexecutor and identifyexecutor()) or "unknown"

local theme = {
    bg = Color3.fromRGB(12, 12, 15),
    surface = Color3.fromRGB(18, 18, 22),
    raised = Color3.fromRGB(24, 24, 28),
    overlay = Color3.fromRGB(30, 30, 35),
    accent = Color3.fromRGB(120, 85, 255),
    accentDim = Color3.fromRGB(95, 65, 200),
    text = Color3.fromRGB(240, 240, 245),
    subtext = Color3.fromRGB(150, 150, 160),
    dimtext = Color3.fromRGB(110, 110, 120),
    border = Color3.fromRGB(35, 35, 40),
    success = Color3.fromRGB(80, 190, 120),
    warning = Color3.fromRGB(245, 190, 80),
    error = Color3.fromRGB(245, 90, 90)
}

local keyNames = {
    [Enum.KeyCode.LeftControl] = "LCTRL",
    [Enum.KeyCode.RightControl] = "RCTRL",
    [Enum.KeyCode.LeftShift] = "LSHIFT",
    [Enum.KeyCode.RightShift] = "RSHIFT",
    [Enum.KeyCode.LeftAlt] = "LALT",
    [Enum.KeyCode.RightAlt] = "RALT",
    [Enum.UserInputType.MouseButton1] = "MOUSE1",
    [Enum.UserInputType.MouseButton2] = "MOUSE2",
    [Enum.UserInputType.MouseButton3] = "MOUSE3",
    ["MB4"] = "MOUSE4",
    ["MB5"] = "MOUSE5"
}

local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function tween(obj, props, time, style, dir)
    return ts:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end

local function corner(parent, radius)
    return create("UICorner", {Parent = parent, CornerRadius = UDim.new(0, radius or 4)})
end

local function stroke(parent, color, thickness)
    return create("UIStroke", {
        Parent = parent,
        Color = color or theme.border,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
end

local function shadow(parent, size, trans)
    return create("ImageLabel", {
        Name = "shadow",
        Parent = parent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, size or 40, 1, size or 40),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = trans or 0.6,
        ZIndex = 0,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277)
    })
end

function club:window(cfg)
    cfg = cfg or {}
    local name = cfg.name or "club"
    local size = cfg.size or {700, 560}
    local config = {}
    local configFile = cfg.configFile or "club.json"
    local keybinds = {}
    local currentAccent = theme.accent

    local gui = create("ScreenGui", {
        Name = http:GenerateGUID(false),
        Parent = game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
    _G[kill] = gui

    local notifs = create("Frame", {
        Name = "notifs",
        Parent = gui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 1, -20),
        Size = UDim2.new(0, 310, 0, 600),
        AnchorPoint = Vector2.new(0, 1),
        ZIndex = 999
    })
    create("UIListLayout", {
        Parent = notifs,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 6)
    })

    local main = create("Frame", {
        Name = "main",
        Parent = gui,
        BackgroundColor3 = theme.bg,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -size[1]/2, 0.5, -size[2]/2),
        Size = UDim2.new(0, size[1], 0, size[2])
    })
    corner(main, 6)
    stroke(main, theme.border, 1)
    shadow(main, 60, 0.7)

    local holder = create("Frame", {
        Parent = main,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0)
    })

    local topbar = create("Frame", {
        Parent = holder,
        BackgroundColor3 = theme.surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36)
    })
    corner(topbar, 6)
    stroke(topbar, theme.border, 1)

    local accentLine = create("Frame", {
        Parent = topbar,
        BackgroundColor3 = currentAccent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1)
    })

    local titleText = create("TextLabel", {
        Parent = topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -28, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = theme.text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local sidebar = create("Frame", {
        Parent = holder,
        BackgroundColor3 = theme.surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 36),
        Size = UDim2.new(0, 140, 1, -36)
    })
    stroke(sidebar, theme.border, 1)

    local tabHolder = create("Frame", {
        Parent = sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0)
    })
    create("UIListLayout", {
        Parent = tabHolder,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })
    create("UIPadding", {
        Parent = tabHolder,
        PaddingTop = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6)
    })

    local container = create("Frame", {
        Parent = holder,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 140, 0, 36),
        Size = UDim2.new(1, -140, 1, -36)
    })

    local dragging, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    uis.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local window = {
        tabs = {},
        currentTab = nil,
        config = config,
        executor = executor,
        accent = currentAccent,
        keybinds = keybinds
    }

    function window:setAccent(color)
        currentAccent = color
        window.accent = color
        accentLine.BackgroundColor3 = color
        for _, tab in pairs(window.tabs) do
            if tab.updateAccent then tab:updateAccent(color) end
        end
    end

    function window:notify(cfg)
        cfg = cfg or {}
        local nTitle = cfg.title or "notification"
        local nText = cfg.text or ""
        local nTime = cfg.time or 4
        local nType = cfg.type or "info"

        local colors = {info = currentAccent, success = theme.success, warning = theme.warning, error = theme.error}

        local notif = create("Frame", {
            Parent = notifs,
            BackgroundColor3 = theme.surface,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        })
        corner(notif, 4)
        stroke(notif, theme.border, 1)
        shadow(notif, 25, 0.75)

        create("Frame", {
            Parent = notif,
            BackgroundColor3 = colors[nType],
            BorderSizePixel = 0,
            Size = UDim2.new(0, 2, 1, 0)
        })

        create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 16, 0, 8),
            Size = UDim2.new(1, -24, 0, 14),
            Font = Enum.Font.GothamBold,
            Text = nTitle,
            TextColor3 = theme.text,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd
        })

        create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 16, 0, 24),
            Size = UDim2.new(1, -24, 0, 28),
            Font = Enum.Font.Gotham,
            Text = nText,
            TextColor3 = theme.subtext,
            TextSize = 10,
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

        tween(notif, {Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Back)
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
        if writefile then writefile(configFile, http:JSONEncode(config)) end
    end

    function window:load()
        if readfile and isfile and isfile(configFile) then
            local success, data = pcall(function() return http:JSONDecode(readfile(configFile)) end)
            if success and data then
                config = data
                window.config = config
                for _, tab in pairs(window.tabs) do
                    if tab.load then tab:load() end
                end
            end
        end
    end

    function window:tab(tabName)
        local tab = {name = tabName, sections = {}, container = nil, accentObjects = {}}

        local btn = create("TextButton", {
            Parent = tabHolder,
            BackgroundColor3 = theme.raised,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 32),
            Font = Enum.Font.GothamSemibold,
            Text = tabName,
            TextColor3 = theme.subtext,
            TextSize = 11,
            AutoButtonColor = false
        })
        corner(btn, 4)

        local indicator = create("Frame", {
            Parent = btn,
            BackgroundColor3 = currentAccent,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 0, 1, 0),
            Visible = false
        })

        local content = create("ScrollingFrame", {
            Parent = container,
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = currentAccent,
            ScrollBarImageTransparency = 0.7,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })

        local columns = create("Frame", {
            Parent = content,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        })

        local leftCol = create("Frame", {
            Parent = columns,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(0.5, -12, 1, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        })
        create("UIListLayout", {Parent = leftCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})

        local rightCol = create("Frame", {
            Parent = columns,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 4, 0, 8),
            Size = UDim2.new(0.5, -12, 1, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        })
        create("UIListLayout", {Parent = rightCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})

        tab.container = content
        tab.leftCol = leftCol
        tab.rightCol = rightCol
        table.insert(tab.accentObjects, indicator)
        table.insert(tab.accentObjects, content.ScrollBarImageColor3)

        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(window.tabs) do
                t.container.Visible = false
                local b = tabHolder:FindFirstChild(t.name)
                if b then
                    tween(b, {BackgroundColor3 = theme.raised, TextColor3 = theme.subtext}, 0.15)
                    local ind = b:FindFirstChild("Frame")
                    if ind then
                        ind.Visible = false
                        tween(ind, {Size = UDim2.new(0, 0, 1, 0)}, 0.2)
                    end
                end
            end
            content.Visible = true
            tween(btn, {BackgroundColor3 = theme.overlay, TextColor3 = theme.text}, 0.15)
            indicator.Visible = true
            tween(indicator, {Size = UDim2.new(0, 2, 1, 0)}, 0.2, Enum.EasingStyle.Quad)
            window.currentTab = tab
        end)

        btn.MouseEnter:Connect(function()
            if content.Visible == false then tween(btn, {BackgroundColor3 = theme.overlay}, 0.15) end
        end)
        btn.MouseLeave:Connect(function()
            if content.Visible == false then tween(btn, {BackgroundColor3 = theme.raised}, 0.15) end
        end)

        if not window.currentTab then
            content.Visible = true
            btn.BackgroundColor3 = theme.overlay
            btn.TextColor3 = theme.text
            indicator.Visible = true
            indicator.Size = UDim2.new(0, 2, 1, 0)
            window.currentTab = tab
        end

        function tab:updateAccent(color)
            indicator.BackgroundColor3 = color
            content.ScrollBarImageColor3 = color
            for _, section in pairs(tab.sections) do
                if section.updateAccent then section:updateAccent(color) end
            end
        end

        function tab:load()
            for _, section in pairs(tab.sections) do
                if section.load then section:load() end
            end
        end

        function tab:section(sName, side)
            local section = {name = sName, elements = {}, accentObjects = {}}
            local parent = (side == "right") and rightCol or leftCol

            local frame = create("Frame", {
                Parent = parent,
                BackgroundColor3 = theme.surface,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            corner(frame, 4)
            stroke(frame, theme.border, 1)

            create("TextLabel", {
                Parent = frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 6),
                Size = UDim2.new(1, -20, 0, 16),
                Font = Enum.Font.GothamBold,
                Text = sName,
                TextColor3 = theme.text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            create("Frame", {
                Parent = frame,
                BackgroundColor3 = theme.border,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 8, 0, 26),
                Size = UDim2.new(1, -16, 0, 1)
            })

            local sContent = create("Frame", {
                Parent = frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 31),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            create("UIListLayout", {Parent = sContent, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
            create("UIPadding", {Parent = sContent, PaddingTop = UDim.new(0, 0), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8)})

            function section:updateAccent(color)
                for _, obj in pairs(section.accentObjects) do
                    if typeof(obj) == "Instance" then
                        obj.BackgroundColor3 = color
                    end
                end
                for _, element in pairs(section.elements) do
                    if element.updateAccent then element:updateAccent(color) end
                end
            end

            function section:load()
                for _, element in pairs(section.elements) do
                    if element.load then element:load() end
                end
            end

            function section:toggle(cfg)
                cfg = cfg or {}
                local tName = cfg.name or "toggle"
                local default = cfg.default or false
                local callback = cfg.callback or function() end
                local flag = cfg.flag or tName

                if config[flag] ~= nil then default = config[flag] end
                local toggled = default

                local tFrame = create("Frame", {
                    Parent = sContent,
                    BackgroundColor3 = theme.raised,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32)
                })
                corner(tFrame, 4)

                create("TextLabel", {
                    Parent = tFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = tName,
                    TextColor3 = theme.text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local switch = create("Frame", {
                    Parent = tFrame,
                    BackgroundColor3 = toggled and currentAccent or theme.border,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -38, 0.5, -8),
                    Size = UDim2.new(0, 32, 0, 16)
                })
                corner(switch, 8)

                local knob = create("Frame", {
                    Parent = switch,
                    BackgroundColor3 = theme.text,
                    BorderSizePixel = 0,
                    Position = toggled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12)
                })
                corner(knob, 6)

                local btn = create("TextButton", {Parent = tFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = ""})

                local toggle = {}
                table.insert(section.accentObjects, switch)

                function toggle:set(value)
                    toggled = value
                    config[flag] = value
                    tween(switch, {BackgroundColor3 = toggled and currentAccent or theme.border}, 0.2)
                    tween(knob, {Position = toggled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}, 0.2)
                    callback(toggled)
                end

                function toggle:updateAccent(color)
                    if toggled then switch.BackgroundColor3 = color end
                end

                function toggle:load()
                    if config[flag] ~= nil then toggle:set(config[flag]) end
                end

                btn.MouseButton1Click:Connect(function() toggle:set(not toggled) end)
                btn.MouseEnter:Connect(function() tween(tFrame, {BackgroundColor3 = theme.overlay}, 0.15) end)
                btn.MouseLeave:Connect(function() tween(tFrame, {BackgroundColor3 = theme.raised}, 0.15) end)

                table.insert(section.elements, toggle)
                callback(toggled)
                return toggle
            end

            function section:slider(cfg)
                cfg = cfg or {}
                local sName = cfg.name or "slider"
                local min = cfg.min or 0
                local max = cfg.max or 100
                local default = cfg.default or min
                local increment = cfg.increment or 1
                local callback = cfg.callback or function() end
                local flag = cfg.flag or sName
                local suffix = cfg.suffix or ""

                if config[flag] ~= nil then default = config[flag] end
                local value = default

                local sFrame = create("Frame", {
                    Parent = sContent,
                    BackgroundColor3 = theme.raised,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 40)
                })
                corner(sFrame, 4)

                create("TextLabel", {
                    Parent = sFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 4),
                    Size = UDim2.new(1, -60, 0, 12),
                    Font = Enum.Font.GothamMedium,
                    Text = sName,
                    TextColor3 = theme.text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local valueLabel = create("TextLabel", {
                    Parent = sFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -54, 0, 4),
                    Size = UDim2.new(0, 46, 0, 12),
                    Font = Enum.Font.GothamBold,
                    Text = tostring(value) .. suffix,
                    TextColor3 = currentAccent,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local track = create("Frame", {
                    Parent = sFrame,
                    BackgroundColor3 = theme.border,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 8, 1, -12),
                    Size = UDim2.new(1, -16, 0, 3)
                })
                corner(track, 2)

                local fill = create("Frame", {
                    Parent = track,
                    BackgroundColor3 = currentAccent,
                    BorderSizePixel = 0,
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                })
                corner(fill, 2)

                local knob = create("Frame", {
                    Parent = track,
                    BackgroundColor3 = theme.text,
                    BorderSizePixel = 0,
                    Position = UDim2.new((value - min) / (max - min), -4, 0.5, -4),
                    Size = UDim2.new(0, 8, 0, 8),
                    ZIndex = 2
                })
                corner(knob, 4)

                local btn = create("TextButton", {Parent = track, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 8), Position = UDim2.new(0, 0, 0, -4), Text = ""})

                local dragging = false
                local slider = {}
                table.insert(section.accentObjects, fill)
                table.insert(section.accentObjects, valueLabel)

                function slider:set(val)
                    value = math.clamp(math.floor((val - min) / increment + 0.5) * increment + min, min, max)
                    config[flag] = value
                    local percent = (value - min) / (max - min)
                    tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                    tween(knob, {Position = UDim2.new(percent, -4, 0.5, -4)}, 0.1)
                    valueLabel.Text = tostring(value) .. suffix
                    callback(value)
                end

                function slider:updateAccent(color)
                    fill.BackgroundColor3 = color
                    valueLabel.TextColor3 = color
                end

                function slider:load()
                    if config[flag] ~= nil then slider:set(config[flag]) end
                end

                btn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        local function update()
                            local mouse = uis:GetMouseLocation()
                            local percent = math.clamp((mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                            slider:set(min + (max - min) * percent)
                        end
                        update()
                        local conn = uis.InputChanged:Connect(function(input2)
                            if (input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch) and dragging then update() end
                        end)
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then dragging = false conn:Disconnect() end
                        end)
                    end
                end)

                btn.MouseEnter:Connect(function() tween(sFrame, {BackgroundColor3 = theme.overlay}, 0.15) tween(knob, {Size = UDim2.new(0, 10, 0, 10)}, 0.15) end)
                btn.MouseLeave:Connect(function() tween(sFrame, {BackgroundColor3 = theme.raised}, 0.15) tween(knob, {Size = UDim2.new(0, 8, 0, 8)}, 0.15) end)

                table.insert(section.elements, slider)
                callback(value)
                return slider
            end

            function section:button(cfg)
                cfg = cfg or {}
                local bName = cfg.name or "button"
                local callback = cfg.callback or function() end

                local bFrame = create("TextButton", {
                    Parent = sContent,
                    BackgroundColor3 = currentAccent,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.GothamSemibold,
                    Text = bName,
                    TextColor3 = theme.text,
                    TextSize = 11,
                    AutoButtonColor = false
                })
                corner(bFrame, 4)

                local button = {}
                table.insert(section.accentObjects, bFrame)

                function button:updateAccent(color) bFrame.BackgroundColor3 = color end

                bFrame.MouseButton1Click:Connect(callback)
                bFrame.MouseEnter:Connect(function() tween(bFrame, {BackgroundColor3 = Color3.fromRGB(currentAccent.R * 255 * 0.85, currentAccent.G * 255 * 0.85, currentAccent.B * 255 * 0.85)}, 0.15) end)
                bFrame.MouseLeave:Connect(function() tween(bFrame, {BackgroundColor3 = currentAccent}, 0.15) end)

                table.insert(section.elements, button)
                return button
            end

            function section:textbox(cfg)
                cfg = cfg or {}
                local tName = cfg.name or "textbox"
                local default = cfg.default or ""
                local placeholder = cfg.placeholder or "..."
                local callback = cfg.callback or function() end
                local flag = cfg.flag or tName

                if config[flag] ~= nil then default = config[flag] end

                local tFrame = create("Frame", {
                    Parent = sContent,
                    BackgroundColor3 = theme.raised,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32)
                })
                corner(tFrame, 4)

                create("TextLabel", {
                    Parent = tFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(0.4, 0, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = tName,
                    TextColor3 = theme.text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local input = create("TextBox", {
                    Parent = tFrame,
                    BackgroundColor3 = theme.border,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.4, 4, 0.5, -10),
                    Size = UDim2.new(0.6, -12, 0, 20),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = theme.dimtext,
                    Text = default,
                    TextColor3 = theme.text,
                    TextSize = 10,
                    ClearTextOnFocus = false
                })
                corner(input, 3)
                create("UIPadding", {Parent = input, PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)})

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
                local dName = cfg.name or "dropdown"
                local options = cfg.options or {}
                local default = cfg.default or options[1]
                local callback = cfg.callback or function() end
                local flag = cfg.flag or dName

                if config[flag] ~= nil then default = config[flag] end
                local selected = default
                local opened = false

                local dFrame = create("Frame", {
                    Parent = sContent,
                    BackgroundColor3 = theme.raised,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    ClipsDescendants = true
                })
                corner(dFrame, 4)

                local label = create("TextLabel", {
                    Parent = dFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -30, 0, 32),
                    Font = Enum.Font.GothamMedium,
                    Text = dName .. ": " .. tostring(selected),
                    TextColor3 = theme.text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd
                })

                local arrow = create("TextLabel", {
                    Parent = dFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -22, 0, 0),
                    Size = UDim2.new(0, 14, 0, 32),
                    Font = Enum.Font.GothamBold,
                    Text = "V",
                    TextColor3 = currentAccent,
                    TextSize = 8
                })

                local btn = create("TextButton", {Parent = dFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), Text = ""})

                local optHolder = create("Frame", {
                    Parent = dFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 32),
                    Size = UDim2.new(1, 0, 0, 0)
                })
                create("UIListLayout", {Parent = optHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
                create("UIPadding", {Parent = optHolder, PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 4)})

                local dropdown = {}
                table.insert(section.accentObjects, arrow)

                function dropdown:set(option)
                    selected = option
                    config[flag] = option
                    label.Text = dName .. ": " .. tostring(option)
                    callback(option)
                end

                function dropdown:updateAccent(color) arrow.TextColor3 = color end

                function dropdown:load()
                    if config[flag] ~= nil then dropdown:set(config[flag]) end
                end

                for _, option in ipairs(options) do
                    local optBtn = create("TextButton", {
                        Parent = optHolder,
                        BackgroundColor3 = theme.border,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 24),
                        Font = Enum.Font.Gotham,
                        Text = tostring(option),
                        TextColor3 = theme.text,
                        TextSize = 10,
                        AutoButtonColor = false
                    })
                    corner(optBtn, 3)

                    optBtn.MouseButton1Click:Connect(function()
                        dropdown:set(option)
                        opened = false
                        tween(dFrame, {Size = UDim2.new(1, 0, 0, 32)}, 0.2)
                        tween(arrow, {Rotation = 0}, 0.2)
                    end)

                    optBtn.MouseEnter:Connect(function() tween(optBtn, {BackgroundColor3 = currentAccent}, 0.15) end)
                    optBtn.MouseLeave:Connect(function() tween(optBtn, {BackgroundColor3 = theme.border}, 0.15) end)
                end

                btn.MouseButton1Click:Connect(function()
                    opened = not opened
                    local newSize = opened and (32 + 8 + (#options * 26)) or 32
                    tween(dFrame, {Size = UDim2.new(1, 0, 0, newSize)}, 0.2)
                    tween(arrow, {Rotation = opened and 180 or 0}, 0.2)
                end)

                table.insert(section.elements, dropdown)
                callback(selected)
                return dropdown
            end

            function section:multi(cfg)
                cfg = cfg or {}
                local mName = cfg.name or "multi"
                local options = cfg.options or {}
                local default = cfg.default or {}
                local callback = cfg.callback or function() end
                local flag = cfg.flag or mName

                if config[flag] ~= nil then default = config[flag] end
                local selected = default
                local opened = false

                local mFrame = create("Frame", {
                    Parent = sContent,
                    BackgroundColor3 = theme.raised,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    ClipsDescendants = true
                })
                corner(mFrame, 4)

                local function getSelectedText()
                    local count = 0
                    for _ in pairs(selected) do count = count + 1 end
                    return count > 0 and count .. " selected" or "none"
                end

                local label = create("TextLabel", {
                    Parent = mFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -30, 0, 32),
                    Font = Enum.Font.GothamMedium,
                    Text = mName .. ": " .. getSelectedText(),
                    TextColor3 = theme.text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd
                })

                local arrow = create("TextLabel", {
                    Parent = mFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -22, 0, 0),
                    Size = UDim2.new(0, 14, 0, 32),
                    Font = Enum.Font.GothamBold,
                    Text = "V",
                    TextColor3 = currentAccent,
                    TextSize = 8
                })

                local btn = create("TextButton", {Parent = mFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), Text = ""})

                local optHolder = create("Frame", {
                    Parent = mFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 32),
                    Size = UDim2.new(1, 0, 0, 0)
                })
                create("UIListLayout", {Parent = optHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
                create("UIPadding", {Parent = optHolder, PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 4)})

                local multi = {}
                table.insert(section.accentObjects, arrow)

                function multi:set(tbl)
                    selected = tbl
                    config[flag] = selected
                    label.Text = mName .. ": " .. getSelectedText()
                    callback(selected)
                end

                function multi:updateAccent(color) arrow.TextColor3 = color end

                function multi:load()
                    if config[flag] ~= nil then multi:set(config[flag]) end
                end

                for _, option in ipairs(options) do
                    local isSelected = selected[option] or false

                    local optBtn = create("TextButton", {
                        Parent = optHolder,
                        BackgroundColor3 = isSelected and currentAccent or theme.border,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 24),
                        Font = Enum.Font.Gotham,
                        Text = tostring(option),
                        TextColor3 = theme.text,
                        TextSize = 10,
                        AutoButtonColor = false
                    })
                    corner(optBtn, 3)

                    optBtn.MouseButton1Click:Connect(function()
                        isSelected = not isSelected
                        selected[option] = isSelected or nil
                        tween(optBtn, {BackgroundColor3 = isSelected and currentAccent or theme.border}, 0.2)
                        label.Text = mName .. ": " .. getSelectedText()
                        config[flag] = selected
                        callback(selected)
                    end)

                    optBtn.MouseEnter:Connect(function()
                        if not isSelected then tween(optBtn, {BackgroundColor3 = theme.overlay}, 0.15) end
                    end)
                    optBtn.MouseLeave:Connect(function()
                        if not isSelected then tween(optBtn, {BackgroundColor3 = theme.border}, 0.15) end
                    end)
                end

                btn.MouseButton1Click:Connect(function()
                    opened = not opened
                    local newSize = opened and (32 + 8 + (#options * 26)) or 32
                    tween(mFrame, {Size = UDim2.new(1, 0, 0, newSize)}, 0.2)
                    tween(arrow, {Rotation = opened and 180 or 0}, 0.2)
                end)

                table.insert(section.elements, multi)
                callback(selected)
                return multi
            end

            function section:keybind(cfg)
                cfg = cfg or {}
                local kName = cfg.name or "keybind"
                local default = cfg.default or Enum.KeyCode.E
                local callback = cfg.callback or function() end
                local flag = cfg.flag or kName

                if config[flag] ~= nil then default = config[flag] end
                local key = default
                local binding = false

                local kFrame = create("Frame", {
                    Parent = sContent,
                    BackgroundColor3 = theme.raised,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32)
                })
                corner(kFrame, 4)

                create("TextLabel", {
                    Parent = kFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(0.55, 0, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = kName,
                    TextColor3 = theme.text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local keyBtn = create("TextButton", {
                    Parent = kFrame,
                    BackgroundColor3 = theme.border,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.55, 4, 0.5, -10),
                    Size = UDim2.new(0.45, -12, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = (typeof(key) == "string" and keyNames[key]) or keyNames[key] or (typeof(key) == "EnumItem" and key.Name or "NONE"),
                    TextColor3 = theme.text,
                    TextSize = 9,
                    AutoButtonColor = false
                })
                corner(keyBtn, 3)

                local keybind = {}

                function keybind:set(newKey)
                    key = newKey
                    config[flag] = key
                    keyBtn.Text = (typeof(key) == "string" and keyNames[key]) or keyNames[key] or (typeof(key) == "EnumItem" and key.Name or "NONE")
                    window.keybinds[flag].key = key
                    callback(key)
                end

                function keybind:load()
                    if config[flag] ~= nil then keybind:set(config[flag]) end
                end

                keyBtn.MouseButton1Click:Connect(function()
                    binding = true
                    keyBtn.Text = "..."
                    tween(keyBtn, {BackgroundColor3 = currentAccent}, 0.15)
                end)

                local inputConn
                inputConn = uis.InputBegan:Connect(function(input)
                    if binding then
                        local newKey = nil
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            newKey = input.KeyCode
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                            newKey = Enum.UserInputType.MouseButton1
                        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                            newKey = Enum.UserInputType.MouseButton2
                        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                            newKey = Enum.UserInputType.MouseButton3
                        elseif input.UserInputType.Name:match("MouseButton") then
                            local btnNum = tonumber(input.UserInputType.Name:match("%d+"))
                            if btnNum == 4 then newKey = "MB4"
                            elseif btnNum == 5 then newKey = "MB5"
                            end
                        end
                        
                        if newKey then
                            keybind:set(newKey)
                            binding = false
                            tween(keyBtn, {BackgroundColor3 = theme.border}, 0.15)
                        end
                    end
                end)

                table.insert(section.elements, keybind)
                window.keybinds[flag] = {key = key, callback = callback}
                callback(key)
                return keybind
            end

            function section:colorpicker(cfg)
                cfg = cfg or {}
                local cName = cfg.name or "color"
                local default = cfg.default or Color3.fromRGB(255, 255, 255)
                local callback = cfg.callback or function() end
                local flag = cfg.flag or cName
                local syncAccent = cfg.syncAccent or false

                if config[flag] ~= nil then default = config[flag] end
                local color = default
                local opened = false

                local cFrame = create("Frame", {
                    Parent = sContent,
                    BackgroundColor3 = theme.raised,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    ClipsDescendants = true
                })
                corner(cFrame, 4)

                create("TextLabel", {
                    Parent = cFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -40, 0, 32),
                    Font = Enum.Font.GothamMedium,
                    Text = cName,
                    TextColor3 = theme.text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local preview = create("TextButton", {
                    Parent = cFrame,
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -26, 0.5, -10),
                    Size = UDim2.new(0, 20, 0, 20),
                    Text = "",
                    AutoButtonColor = false
                })
                corner(preview, 4)
                stroke(preview, theme.border, 1)

                local pickerHolder = create("Frame", {
                    Parent = cFrame,
                    BackgroundColor3 = theme.overlay,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 6, 0, 36),
                    Size = UDim2.new(1, -12, 0, 120)
                })
                corner(pickerHolder, 4)
                stroke(pickerHolder, theme.border, 1)

                local hue, sat, val = color:ToHSV()
                
                local satVal = create("Frame", {
                    Parent = pickerHolder,
                    BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 6, 0, 6),
                    Size = UDim2.new(1, -50, 0, 80)
                })
                corner(satVal, 3)
                stroke(satVal, theme.border, 1)

                local whiteness = create("ImageLabel", {
                    Parent = satVal,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Image = "rbxassetid://4155801252",
                    ImageColor3 = Color3.fromRGB(255, 255, 255)
                })
                corner(whiteness, 3)

                local blackness = create("ImageLabel", {
                    Parent = satVal,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Image = "rbxassetid://4155801252",
                    ImageColor3 = Color3.fromRGB(0, 0, 0),
                    Rotation = 180
                })
                corner(blackness, 3)

                local svCursor = create("Frame", {
                    Parent = satVal,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(sat, -3, 1 - val, -3),
                    Size = UDim2.new(0, 6, 0, 6)
                })
                corner(svCursor, 3)
                stroke(svCursor, Color3.fromRGB(0, 0, 0), 1)

                local hueSlider = create("Frame", {
                    Parent = pickerHolder,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -38, 0, 6),
                    Size = UDim2.new(0, 32, 0, 80)
                })
                corner(hueSlider, 3)
                stroke(hueSlider, theme.border, 1)

                create("UIGradient", {
                    Parent = hueSlider,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                    }),
                    Rotation = 90
                })

                local hueCursor = create("Frame", {
                    Parent = hueSlider,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.5, -1, hue, -1),
                    Size = UDim2.new(1, 0, 0, 2)
                })
                stroke(hueCursor, Color3.fromRGB(0, 0, 0), 1)

                local hexBox = create("TextBox", {
                    Parent = pickerHolder,
                    BackgroundColor3 = theme.border,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 6, 1, -26),
                    Size = UDim2.new(1, -12, 0, 20),
                    Font = Enum.Font.GothamMedium,
                    Text = string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255),
                    TextColor3 = theme.text,
                    TextSize = 10,
                    ClearTextOnFocus = false
                })
                corner(hexBox, 3)
                create("UIPadding", {Parent = hexBox, PaddingLeft = UDim.new(0, 6)})

                local colorpicker = {}

                function colorpicker:set(newColor)
                    color = newColor
                    config[flag] = color
                    preview.BackgroundColor3 = color
                    hue, sat, val = color:ToHSV()
                    satVal.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    svCursor.Position = UDim2.new(sat, -3, 1 - val, -3)
                    hueCursor.Position = UDim2.new(0.5, -1, hue, -1)
                    hexBox.Text = string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255)
                    if syncAccent then window:setAccent(color) end
                    callback(color)
                end

                function colorpicker:load()
                    if config[flag] ~= nil then colorpicker:set(config[flag]) end
                end

                preview.MouseButton1Click:Connect(function()
                    opened = not opened
                    tween(cFrame, {Size = UDim2.new(1, 0, 0, opened and 168 or 32)}, 0.2)
                end)

                local svDragging = false
                satVal.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = true
                        local function update()
                            local mouse = uis:GetMouseLocation()
                            sat = math.clamp((mouse.X - satVal.AbsolutePosition.X) / satVal.AbsoluteSize.X, 0, 1)
                            val = 1 - math.clamp((mouse.Y - satVal.AbsolutePosition.Y) / satVal.AbsoluteSize.Y, 0, 1)
                            colorpicker:set(Color3.fromHSV(hue, sat, val))
                        end
                        update()
                        local conn = uis.InputChanged:Connect(function(input2)
                            if input2.UserInputType == Enum.UserInputType.MouseMovement and svDragging then update() end
                        end)
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then svDragging = false conn:Disconnect() end
                        end)
                    end
                end)

                local hueDragging = false
                hueSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = true
                        local function update()
                            local mouse = uis:GetMouseLocation()
                            hue = math.clamp((mouse.Y - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y, 0, 1)
                            colorpicker:set(Color3.fromHSV(hue, sat, val))
                        end
                        update()
                        local conn = uis.InputChanged:Connect(function(input2)
                            if input2.UserInputType == Enum.UserInputType.MouseMovement and hueDragging then update() end
                        end)
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then hueDragging = false conn:Disconnect() end
                        end)
                    end
                end)

                hexBox.FocusLost:Connect(function()
                    local hex = hexBox.Text:gsub("#", "")
                    if #hex == 6 then
                        local r = tonumber(hex:sub(1, 2), 16) or 255
                        local g = tonumber(hex:sub(3, 4), 16) or 255
                        local b = tonumber(hex:sub(5, 6), 16) or 255
                        colorpicker:set(Color3.fromRGB(r, g, b))
                    end
                end)

                table.insert(section.elements, colorpicker)
                callback(color)
                return colorpicker
            end

            function section:label(text)
                local lFrame = create("Frame", {Parent = sContent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16)})
                local label = create("TextLabel", {
                    Parent = lFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 4, 0, 0),
                    Size = UDim2.new(1, -8, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = text,
                    TextColor3 = theme.dimtext,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                return {set = function(_, t) label.Text = t end}
            end

            table.insert(tab.sections, section)
            return section
        end

        table.insert(window.tabs, tab)
        return tab
    end

    local function getMouseButton(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            return Enum.UserInputType.MouseButton1
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            return Enum.UserInputType.MouseButton2
        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
            return Enum.UserInputType.MouseButton3
        end
        
        if input.UserInputType.Name:match("MouseButton") then
            local btnNum = tonumber(input.UserInputType.Name:match("%d+"))
            if btnNum == 4 then return "MB4"
            elseif btnNum == 5 then return "MB5"
            end
        end
        
        return nil
    end

    uis.InputBegan:Connect(function(input)
        for flag, data in pairs(window.keybinds) do
            local isMatch = false
            if typeof(data.key) == "EnumItem" then
                if data.key.EnumType == Enum.KeyCode then
                    isMatch = input.KeyCode == data.key
                elseif data.key.EnumType == Enum.UserInputType then
                    isMatch = input.UserInputType == data.key
                end
            elseif typeof(data.key) == "string" then
                local mouseBtn = getMouseButton(input)
                isMatch = mouseBtn == data.key
            end
            if isMatch then
                data.callback(true)
            end
        end
    end)

    window:load()
    main.Size = UDim2.new(0, 0, 0, 0)
    tween(main, {Size = UDim2.new(0, size[1], 0, size[2])}, 0.4, Enum.EasingStyle.Back)

    return window
end

return club
