local club = {}

local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local http = game:GetService("HttpService")
local players = game:GetService("Players")

local kill = "club_ui"
if _G[kill] then
    pcall(function() _G[kill]:Destroy() end)
    _G[kill] = nil
    task.wait(0.1)
end

local mobile = uis.TouchEnabled and not uis.KeyboardEnabled
local executor = (identifyexecutor and identifyexecutor()) or "unknown"

local theme = {
    bg = Color3.fromRGB(10, 10, 12),
    surface = Color3.fromRGB(16, 16, 19),
    raised = Color3.fromRGB(22, 22, 26),
    overlay = Color3.fromRGB(28, 28, 32),
    accent = Color3.fromRGB(120, 85, 255),
    text = Color3.fromRGB(245, 245, 250),
    subtext = Color3.fromRGB(155, 155, 165),
    dimtext = Color3.fromRGB(100, 100, 110),
    border = Color3.fromRGB(35, 35, 40),
    success = Color3.fromRGB(75, 200, 130),
    error = Color3.fromRGB(235, 85, 85)
}

local icons = {
    combat = "rbxassetid://7733955740",
    visuals = "rbxassetid://7733920644",
    misc = "rbxassetid://7733674079",
    settings = "rbxassetid://7734021200",
    save = "rbxassetid://7734053495",
    load = "rbxassetid://7734042071",
    hide = "rbxassetid://7733674079",
    check = "rbxassetid://7733715400"
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
    [Enum.UserInputType.MouseButton3] = "MOUSE3"
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

function club:window(cfg)
    cfg = cfg or {}
    local name = cfg.name or "club"
    local size = cfg.size or {700, 560}
    local config = {}
    local configFile = cfg.configFile or "club.json"
    local keybinds = {}
    local currentAccent = theme.accent
    local visible = true

    local gui = create("ScreenGui", {
        Name = http:GenerateGUID(false),
        Parent = game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
    _G[kill] = gui

    local cursor = create("ImageLabel", {
        Name = "cursor",
        Parent = gui,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20),
        Image = "rbxassetid://7733674319",
        ImageColor3 = currentAccent,
        ZIndex = 9999,
        Visible = false
    })

    local tooltip = create("Frame", {
        Name = "tooltip",
        Parent = gui,
        BackgroundColor3 = theme.surface,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 0, 28),
        AutomaticSize = Enum.AutomaticSize.X,
        Visible = false,
        ZIndex = 9998
    })
    corner(tooltip, 4)
    stroke(tooltip, theme.border, 1.5)

    local tooltipText = create("TextLabel", {
        Parent = tooltip,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = "",
        TextColor3 = theme.text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center
    })
    create("UIPadding", {Parent = tooltipText, PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})

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
        Padding = UDim.new(0, 8)
    })

    local main = create("Frame", {
        Name = "main",
        Parent = gui,
        BackgroundColor3 = theme.bg,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -size[1]/2, 0.5, -size[2]/2),
        Size = UDim2.new(0, size[1], 0, size[2]),
        ClipsDescendants = true
    })
    corner(main, 6)
    stroke(main, theme.border, 1.5)

    local holder = create("Frame", {
        Parent = main,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0)
    })

    local topbar = create("Frame", {
        Parent = holder,
        BackgroundColor3 = theme.surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 45)
    })
    corner(topbar, 6)
    stroke(topbar, theme.border, 1.5)

    local accentLine = create("Frame", {
        Parent = topbar,
        BackgroundColor3 = currentAccent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2)
    })

    local titleText = create("TextLabel", {
        Parent = topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 0),
        Size = UDim2.new(0, 150, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = theme.text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local hideBtn = create("TextButton", {
        Parent = topbar,
        BackgroundColor3 = theme.raised,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -40, 0.5, -15),
        Size = UDim2.new(0, 30, 0, 30),
        Text = "",
        AutoButtonColor = false
    })
    corner(hideBtn, 4)
    stroke(hideBtn, theme.border, 1.5)

    create("ImageLabel", {
        Parent = hideBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 16, 0, 16),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = icons.hide,
        ImageColor3 = theme.text
    })

    hideBtn.MouseButton1Click:Connect(function()
        visible = not visible
        tween(main, {Size = visible and UDim2.new(0, size[1], 0, size[2]) or UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back)
    end)

    hideBtn.MouseEnter:Connect(function() tween(hideBtn, {BackgroundColor3 = theme.overlay}, 0.15) end)
    hideBtn.MouseLeave:Connect(function() tween(hideBtn, {BackgroundColor3 = theme.raised}, 0.15) end)

    local selectionBar = create("Frame", {
        Parent = holder,
        BackgroundColor3 = theme.surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 45),
        Size = UDim2.new(1, 0, 0, 60)
    })
    stroke(selectionBar, theme.border, 1.5)

    local selectionHolder = create("Frame", {
        Parent = selectionBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 8),
        Size = UDim2.new(1, -20, 1, -16)
    })
    create("UIListLayout", {Parent = selectionHolder, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})

    local container = create("Frame", {
        Parent = holder,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 105),
        Size = UDim2.new(1, 0, 1, -105)
    })

    local dragging, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    uis.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = uis:GetMouseLocation()
            cursor.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y - 36)
        end
    end)

    main.MouseEnter:Connect(function() cursor.Visible = true end)
    main.MouseLeave:Connect(function() cursor.Visible = false tooltip.Visible = false end)

    local window = {
        tabs = {},
        currentTab = nil,
        config = config,
        executor = executor,
        accent = currentAccent,
        keybinds = keybinds,
        cursor = cursor,
        tooltip = tooltip,
        tooltipText = tooltipText
    }

    function window:setAccent(color)
        currentAccent = color
        window.accent = color
        accentLine.BackgroundColor3 = color
        cursor.ImageColor3 = color
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

        local colors = {
            info = {color = currentAccent, icon = "rbxassetid://7733992901"},
            success = {color = theme.success, icon = "rbxassetid://7733993369"},
            error = {color = theme.error, icon = "rbxassetid://7733993390"}
        }
        local typeData = colors[nType] or colors.info

        local notif = create("Frame", {
            Parent = notifs,
            BackgroundColor3 = theme.surface,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        })
        corner(notif, 6)
        stroke(notif, theme.border, 1.5)

        create("Frame", {
            Parent = notif,
            BackgroundColor3 = typeData.color,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 3, 1, 0)
        })

        create("ImageLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 12),
            Size = UDim2.new(0, 20, 0, 20),
            Image = typeData.icon,
            ImageColor3 = typeData.color
        })

        create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 42, 0, 10),
            Size = UDim2.new(1, -50, 0, 16),
            Font = Enum.Font.GothamBold,
            Text = nTitle,
            TextColor3 = theme.text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd
        })

        create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 42, 0, 28),
            Size = UDim2.new(1, -50, 0, 24),
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
            BackgroundColor3 = typeData.color,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -2),
            Size = UDim2.new(1, 0, 0, 2)
        })

        tween(notif, {Size = UDim2.new(1, 0, 0, 64), BackgroundTransparency = 0}, 0.4, Enum.EasingStyle.Back)
        tween(progress, {Size = UDim2.new(0, 0, 0, 2)}, nTime, Enum.EasingStyle.Linear)

        task.delay(nTime, function()
            tween(notif, {BackgroundTransparency = 1}, 0.3)
            for _, v in pairs(notif:GetDescendants()) do
                if v:IsA("TextLabel") then tween(v, {TextTransparency = 1}, 0.3) end
                if v:IsA("ImageLabel") then tween(v, {ImageTransparency = 1}, 0.3) end
                if v:IsA("Frame") then tween(v, {BackgroundTransparency = 1}, 0.3) end
                if v:IsA("UIStroke") then tween(v, {Transparency = 1}, 0.3) end
            end
            task.wait(0.3)
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

    function window:tab(tabName, icon, desc)
        local tab = {name = tabName, sections = {}, container = nil, accentObjects = {}}

        local btn = create("TextButton", {
            Parent = selectionHolder,
            BackgroundColor3 = theme.raised,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 44, 1, 0),
            Text = "",
            AutoButtonColor = false
        })
        corner(btn, 6)
        stroke(btn, theme.border, 1.5)

        if icon then
            create("ImageLabel", {
                Parent = btn,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, 24, 0, 24),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Image = icon,
                ImageColor3 = theme.subtext
            })
        end

        local indicator = create("Frame", {
            Parent = btn,
            BackgroundColor3 = currentAccent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -3),
            Size = UDim2.new(0, 0, 0, 3),
            Visible = false
        })

        local content = create("ScrollingFrame", {
            Parent = container,
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = currentAccent,
            ScrollBarImageTransparency = 0.5,
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
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(0.5, -15, 1, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        })
        create("UIListLayout", {Parent = leftCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})

        local rightCol = create("Frame", {
            Parent = columns,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 5, 0, 10),
            Size = UDim2.new(0.5, -15, 1, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        })
        create("UIListLayout", {Parent = rightCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})

        tab.container = content
        tab.leftCol = leftCol
        tab.rightCol = rightCol
        tab.btn = btn
        table.insert(tab.accentObjects, indicator)

        local function selectTab()
            for _, t in pairs(window.tabs) do
                t.container.Visible = false
                local b = t.btn
                tween(b, {BackgroundColor3 = theme.raised}, 0.15)
                local img = b:FindFirstChildOfClass("ImageLabel")
                if img then tween(img, {ImageColor3 = theme.subtext}, 0.15) end
                local strk = b:FindFirstChildOfClass("UIStroke")
                if strk then tween(strk, {Color = theme.border}, 0.15) end
                local ind = b:FindFirstChild("Frame")
                if ind then
                    ind.Visible = false
                    tween(ind, {Size = UDim2.new(0, 0, 0, 3)}, 0.2)
                end
            end
            content.Visible = true
            tween(btn, {BackgroundColor3 = theme.overlay}, 0.15)
            local img = btn:FindFirstChildOfClass("ImageLabel")
            if img then tween(img, {ImageColor3 = currentAccent}, 0.15) end
            local strk = btn:FindFirstChildOfClass("UIStroke")
            if strk then tween(strk, {Color = currentAccent}, 0.15) end
            indicator.Visible = true
            tween(indicator, {Size = UDim2.new(1, 0, 0, 3)}, 0.2, Enum.EasingStyle.Quad)
            window.currentTab = tab
            window.tooltip.Visible = false
        end

        btn.MouseButton1Click:Connect(selectTab)

        btn.MouseEnter:Connect(function()
            if content.Visible == false then
                tween(btn, {BackgroundColor3 = theme.overlay}, 0.15)
            end
            if desc then
                window.tooltipText.Text = desc
                window.tooltip.Visible = true
                window.tooltip.Position = UDim2.new(0, btn.AbsolutePosition.X + btn.AbsoluteSize.X/2 - window.tooltip.AbsoluteSize.X/2, 0, btn.AbsolutePosition.Y - 36)
            end
        end)
        btn.MouseLeave:Connect(function()
            if content.Visible == false then
                tween(btn, {BackgroundColor3 = theme.raised}, 0.15)
            end
            window.tooltip.Visible = false
        end)

        if not window.currentTab then selectTab() end

        function tab:updateAccent(color)
            indicator.BackgroundColor3 = color
            content.ScrollBarImageColor3 = color
            local img = btn:FindFirstChildOfClass("ImageLabel")
            if img and content.Visible then img.ImageColor3 = color end
            local strk = btn:FindFirstChildOfClass("UIStroke")
            if strk and content.Visible then strk.Color = color end
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
            corner(frame, 6)
            stroke(frame, theme.border, 1.5)

            create("TextLabel", {
                Parent = frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 10),
                Size = UDim2.new(1, -28, 0, 18),
                Font = Enum.Font.GothamBold,
                Text = sName,
                TextColor3 = theme.text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            create("Frame", {
                Parent = frame,
                BackgroundColor3 = theme.border,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 12, 0, 33),
                Size = UDim2.new(1, -24, 0, 1)
            })

            local sContent = create("Frame", {
                Parent = frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 38),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            create("UIListLayout", {Parent = sContent, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
            create("UIPadding", {Parent = sContent, PaddingTop = UDim.new(0, 0), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12)})

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
                    Size = UDim2.new(1, 0, 0, 36)
                })
                corner(tFrame, 5)
                stroke(tFrame, theme.border, 1)

                create("TextLabel", {
                    Parent = tFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -56, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = tName,
                    TextColor3 = theme.text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local checkbox = create("Frame", {
                    Parent = tFrame,
                    BackgroundColor3 = toggled and currentAccent or theme.border,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -32, 0.5, -10),
                    Size = UDim2.new(0, 20, 0, 20)
                })
                corner(checkbox, 4)
                stroke(checkbox, toggled and currentAccent or theme.border, 1.5)

                create("ImageLabel", {
                    Parent = checkbox,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, 14, 0, 14),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Image = icons.check,
                    ImageColor3 = theme.text,
                    ImageTransparency = toggled and 0 or 1
                })

                local btn = create("TextButton", {Parent = tFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 2})

                local toggle = {}
                table.insert(section.accentObjects, checkbox)

                function toggle:set(value)
                    toggled = value
                    config[flag] = value
                    tween(checkbox, {BackgroundColor3 = toggled and currentAccent or theme.border}, 0.2)
                    tween(checkbox:FindFirstChildOfClass("UIStroke"), {Color = toggled and currentAccent or theme.border}, 0.2)
                    tween(checkbox:FindFirstChildOfClass("ImageLabel"), {ImageTransparency = toggled and 0 or 1}, 0.2)
                    callback(toggled)
                end

                function toggle:updateAccent(color)
                    if toggled then
                        checkbox.BackgroundColor3 = color
                        checkbox:FindFirstChildOfClass("UIStroke").Color = color
                    end
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
                    Size = UDim2.new(1, 0, 0, 48)
                })
                corner(sFrame, 5)
                stroke(sFrame, theme.border, 1)

                create("TextLabel", {
                    Parent = sFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 8),
                    Size = UDim2.new(1, -80, 0, 14),
                    Font = Enum.Font.GothamMedium,
                    Text = sName,
                    TextColor3 = theme.text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local valueLabel = create("TextLabel", {
                    Parent = sFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -68, 0, 8),
                    Size = UDim2.new(0, 56, 0, 14),
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
                    Position = UDim2.new(0, 12, 1, -16),
                    Size = UDim2.new(1, -24, 0, 4)
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
                    Position = UDim2.new((value - min) / (max - min), -6, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12),
                    ZIndex = 2
                })
                corner(knob, 6)
                stroke(knob, currentAccent, 2)

                local btn = create("TextButton", {Parent = sFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 3})

                local dragging = false
                local slider = {}
                table.insert(section.accentObjects, fill)
                table.insert(section.accentObjects, valueLabel)

                function slider:set(val)
                    value = math.clamp(math.floor((val - min) / increment + 0.5) * increment + min, min, max)
                    config[flag] = value
                    local percent = (value - min) / (max - min)
                    tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                    tween(knob, {Position = UDim2.new(percent, -6, 0.5, -6)}, 0.1)
                    valueLabel.Text = tostring(value) .. suffix
                    callback(value)
                end

                function slider:updateAccent(color)
                    fill.BackgroundColor3 = color
                    valueLabel.TextColor3 = color
                    knob:FindFirstChildOfClass("UIStroke").Color = color
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
                        local conn2 = uis.InputEnded:Connect(function(input2)
                            if input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch then
                                dragging = false
                                conn:Disconnect()
                                conn2:Disconnect()
                            end
                        end)
                    end
                end)

                btn.MouseEnter:Connect(function() tween(sFrame, {BackgroundColor3 = theme.overlay}, 0.15) end)
                btn.MouseLeave:Connect(function() tween(sFrame, {BackgroundColor3 = theme.raised}, 0.15) end)

                table.insert(section.elements, slider)
                callback(value)
                return slider
            end

            function section:button(cfg)
                cfg = cfg or {}
                local bName = cfg.name or "button"
                local callback = cfg.callback or function() end
                local icon = cfg.icon

                local bFrame = create("TextButton", {
                    Parent = sContent,
                    BackgroundColor3 = currentAccent,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 34),
                    Font = Enum.Font.GothamSemibold,
                    Text = icon and "" or bName,
                    TextColor3 = theme.text,
                    TextSize = 11,
                    AutoButtonColor = false
                })
                corner(bFrame, 5)
                stroke(bFrame, currentAccent, 1.5)

                if icon then
                    create("ImageLabel", {
                        Parent = bFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0.5, -10),
                        Size = UDim2.new(0, 20, 0, 20),
                        Image = icon,
                        ImageColor3 = theme.text
                    })
                    create("TextLabel", {
                        Parent = bFrame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 36, 0, 0),
                        Size = UDim2.new(1, -36, 1, 0),
                        Font = Enum.Font.GothamSemibold,
                        Text = bName,
                        TextColor3 = theme.text,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                end

                local button = {}
                table.insert(section.accentObjects, bFrame)

                function button:updateAccent(color)
                    bFrame.BackgroundColor3 = color
                    bFrame:FindFirstChildOfClass("UIStroke").Color = color
                end

                bFrame.MouseButton1Click:Connect(callback)
                bFrame.MouseEnter:Connect(function() tween(bFrame, {BackgroundColor3 = Color3.fromRGB(currentAccent.R * 200, currentAccent.G * 200, currentAccent.B * 200)}, 0.15) end)
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
                    Size = UDim2.new(1, 0, 0, 36)
                })
                corner(tFrame, 5)
                stroke(tFrame, theme.border, 1)

                create("TextLabel", {
                    Parent = tFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
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
                    Position = UDim2.new(0.4, 8, 0.5, -12),
                    Size = UDim2.new(0.6, -20, 0, 24),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = theme.dimtext,
                    Text = default,
                    TextColor3 = theme.text,
                    TextSize = 10,
                    ClearTextOnFocus = false
                })
                corner(input, 4)
                stroke(input, theme.border, 1)
                create("UIPadding", {Parent = input, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})

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
                input.Focused:Connect(function()
                    tween(input, {BackgroundColor3 = theme.overlay}, 0.15)
                    tween(input:FindFirstChildOfClass("UIStroke"), {Color = currentAccent}, 0.15)
                end)
                input.FocusLost:Connect(function()
                    tween(input, {BackgroundColor3 = theme.border}, 0.15)
                    tween(input:FindFirstChildOfClass("UIStroke"), {Color = theme.border}, 0.15)
                end)

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
                    Size = UDim2.new(1, 0, 0, 36),
                    ClipsDescendants = true,
                    ZIndex = 1
                })
                corner(dFrame, 5)
                stroke(dFrame, theme.border, 1)

                local label = create("TextLabel", {
                    Parent = dFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -40, 0, 36),
                    Font = Enum.Font.GothamMedium,
                    Text = dName .. ": " .. tostring(selected),
                    TextColor3 = theme.text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 2
                })

                local arrow = create("ImageLabel", {
                    Parent = dFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -30, 0, 10),
                    Size = UDim2.new(0, 16, 0, 16),
                    Image = "rbxassetid://7733674079",
                    ImageColor3 = currentAccent,
                    ZIndex = 2
                })

                local btn = create("TextButton", {Parent = dFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Text = "", ZIndex = 3})

                local optHolder = create("ScrollingFrame", {
                    Parent = dFrame,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 36),
                    Size = UDim2.new(1, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = currentAccent,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ZIndex = 2
                })
                create("UIListLayout", {Parent = optHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
                create("UIPadding", {Parent = optHolder, PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 8)})

                local dropdown = {}
                table.insert(section.accentObjects, arrow)

                function dropdown:set(option)
                    selected = option
                    config[flag] = option
                    label.Text = dName .. ": " .. tostring(option)
                    callback(option)
                end

                function dropdown:updateAccent(color) arrow.ImageColor3 = color optHolder.ScrollBarImageColor3 = color end

                function dropdown:load()
                    if config[flag] ~= nil then dropdown:set(config[flag]) end
                end

                for _, option in ipairs(options) do
                    local optBtn = create("TextButton", {
                        Parent = optHolder,
                        BackgroundColor3 = theme.raised,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 28),
                        Font = Enum.Font.Gotham,
                        Text = tostring(option),
                        TextColor3 = theme.text,
                        TextSize = 10,
                        AutoButtonColor = false,
                        ZIndex = 3
                    })
                    corner(optBtn, 4)
                    stroke(optBtn, theme.border, 1)

                    optBtn.MouseButton1Click:Connect(function()
                        dropdown:set(option)
                        opened = false
                        tween(dFrame, {Size = UDim2.new(1, 0, 0, 36)}, 0.2)
                        tween(arrow, {Rotation = 0}, 0.2)
                    end)

                    optBtn.MouseEnter:Connect(function()
                        tween(optBtn, {BackgroundColor3 = theme.overlay}, 0.15)
                        tween(optBtn:FindFirstChildOfClass("UIStroke"), {Color = currentAccent}, 0.15)
                    end)
                    optBtn.MouseLeave:Connect(function()
                        tween(optBtn, {BackgroundColor3 = theme.raised}, 0.15)
                        tween(optBtn:FindFirstChildOfClass("UIStroke"), {Color = theme.border}, 0.15)
                    end)
                end

                btn.MouseButton1Click:Connect(function()
                    opened = not opened
                    local maxHeight = math.min(#options * 32 + 16, 160)
                    local newSize = opened and (36 + maxHeight) or 36
                    tween(dFrame, {Size = UDim2.new(1, 0, 0, newSize)}, 0.2)
                    tween(arrow, {Rotation = opened and 180 or 0}, 0.2)
                end)

                btn.MouseEnter:Connect(function() tween(dFrame, {BackgroundColor3 = theme.overlay}, 0.15) end)
                btn.MouseLeave:Connect(function() tween(dFrame, {BackgroundColor3 = theme.raised}, 0.15) end)

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
                    Size = UDim2.new(1, 0, 0, 36),
                    ClipsDescendants = true,
                    ZIndex = 1
                })
                corner(mFrame, 5)
                stroke(mFrame, theme.border, 1)

                local function getSelectedText()
                    local names = {}
                    for k, v in pairs(selected) do
                        if v then table.insert(names, k) end
                    end
                    if #names == 0 then return "none"
                    elseif #names == 1 then return names[1]
                    elseif #names == 2 then return names[1] .. ", " .. names[2]
                    else return names[1] .. ", " .. names[2] .. " & " .. (#names - 2) .. " more"
                    end
                end

                local label = create("TextLabel", {
                    Parent = mFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -40, 0, 36),
                    Font = Enum.Font.GothamMedium,
                    Text = mName .. ": " .. getSelectedText(),
                    TextColor3 = theme.text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 2
                })

                local arrow = create("ImageLabel", {
                    Parent = mFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -30, 0, 10),
                    Size = UDim2.new(0, 16, 0, 16),
                    Image = "rbxassetid://7733674079",
                    ImageColor3 = currentAccent,
                    ZIndex = 2
                })

                local btn = create("TextButton", {Parent = mFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Text = "", ZIndex = 3})

                local optHolder = create("ScrollingFrame", {
                    Parent = mFrame,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 36),
                    Size = UDim2.new(1, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = currentAccent,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ZIndex = 2
                })
                create("UIListLayout", {Parent = optHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
                create("UIPadding", {Parent = optHolder, PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 8)})

                local multi = {}
                table.insert(section.accentObjects, arrow)

                function multi:set(tbl)
                    selected = tbl
                    config[flag] = selected
                    label.Text = mName .. ": " .. getSelectedText()
                    callback(selected)
                end

                function multi:updateAccent(color) arrow.ImageColor3 = color optHolder.ScrollBarImageColor3 = color end

                function multi:load()
                    if config[flag] ~= nil then multi:set(config[flag]) end
                end

                for _, option in ipairs(options) do
                    local isSelected = selected[option] or false

                    local optBtn = create("TextButton", {
                        Parent = optHolder,
                        BackgroundColor3 = isSelected and currentAccent or theme.raised,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 28),
                        Font = Enum.Font.Gotham,
                        Text = tostring(option),
                        TextColor3 = theme.text,
                        TextSize = 10,
                        AutoButtonColor = false,
                        ZIndex = 3
                    })
                    corner(optBtn, 4)
                    stroke(optBtn, isSelected and currentAccent or theme.border, 1)

                    optBtn.MouseButton1Click:Connect(function()
                        isSelected = not isSelected
                        selected[option] = isSelected or nil
                        tween(optBtn, {BackgroundColor3 = isSelected and currentAccent or theme.raised}, 0.2)
                        tween(optBtn:FindFirstChildOfClass("UIStroke"), {Color = isSelected and currentAccent or theme.border}, 0.2)
                        label.Text = mName .. ": " .. getSelectedText()
                        config[flag] = selected
                        callback(selected)
                    end)

                    optBtn.MouseEnter:Connect(function()
                        if not isSelected then
                            tween(optBtn, {BackgroundColor3 = theme.overlay}, 0.15)
                            tween(optBtn:FindFirstChildOfClass("UIStroke"), {Color = currentAccent}, 0.15)
                        end
                    end)
                    optBtn.MouseLeave:Connect(function()
                        if not isSelected then
                            tween(optBtn, {BackgroundColor3 = theme.raised}, 0.15)
                            tween(optBtn:FindFirstChildOfClass("UIStroke"), {Color = theme.border}, 0.15)
                        end
                    end)
                end

                btn.MouseButton1Click:Connect(function()
                    opened = not opened
                    local maxHeight = math.min(#options * 32 + 16, 160)
                    local newSize = opened and (36 + maxHeight) or 36
                    tween(mFrame, {Size = UDim2.new(1, 0, 0, newSize)}, 0.2)
                    tween(arrow, {Rotation = opened and 180 or 0}, 0.2)
                end)

                btn.MouseEnter:Connect(function() tween(mFrame, {BackgroundColor3 = theme.overlay}, 0.15) end)
                btn.MouseLeave:Connect(function() tween(mFrame, {BackgroundColor3 = theme.raised}, 0.15) end)

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
                    Size = UDim2.new(1, 0, 0, 36)
                })
                corner(kFrame, 5)
                stroke(kFrame, theme.border, 1)

                create("TextLabel", {
                    Parent = kFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(0.5, 0, 1, 0),
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
                    Position = UDim2.new(0.5, 8, 0.5, -12),
                    Size = UDim2.new(0.5, -20, 0, 24),
                    Font = Enum.Font.GothamBold,
                    Text = keyNames[key] or (typeof(key) == "EnumItem" and key.Name or "NONE"),
                    TextColor3 = theme.text,
                    TextSize = 9,
                    AutoButtonColor = false
                })
                corner(keyBtn, 4)
                stroke(keyBtn, theme.border, 1)

                local keybind = {}

                function keybind:set(newKey)
                    key = newKey
                    config[flag] = key
                    keyBtn.Text = keyNames[key] or (typeof(key) == "EnumItem" and key.Name or "NONE")
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
                    tween(keyBtn:FindFirstChildOfClass("UIStroke"), {Color = currentAccent}, 0.15)
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
                        end
                        
                        if newKey then
                            keybind:set(newKey)
                            binding = false
                            tween(keyBtn, {BackgroundColor3 = theme.border}, 0.15)
                            tween(keyBtn:FindFirstChildOfClass("UIStroke"), {Color = theme.border}, 0.15)
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
                    Size = UDim2.new(1, 0, 0, 36),
                    ClipsDescendants = true,
                    ZIndex = 1
                })
                corner(cFrame, 5)
                stroke(cFrame, theme.border, 1)

                create("TextLabel", {
                    Parent = cFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -50, 0, 36),
                    Font = Enum.Font.GothamMedium,
                    Text = cName,
                    TextColor3 = theme.text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 2
                })

                local preview = create("TextButton", {
                    Parent = cFrame,
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -34, 0.5, -12),
                    Size = UDim2.new(0, 24, 0, 24),
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 3
                })
                corner(preview, 4)
                stroke(preview, theme.border, 1.5)

                local pickerHolder = create("Frame", {
                    Parent = cFrame,
                    BackgroundColor3 = theme.overlay,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 42),
                    Size = UDim2.new(1, -20, 0, 140),
                    ZIndex = 2
                })
                corner(pickerHolder, 6)
                stroke(pickerHolder, theme.border, 1.5)

                local hue, sat, val = color:ToHSV()
                
                local satVal = create("ImageButton", {
                    Parent = pickerHolder,
                    BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -60, 0, 90),
                    Image = "rbxassetid://4155801252",
                    ImageColor3 = Color3.fromRGB(0, 0, 0),
                    AutoButtonColor = false,
                    ZIndex = 3
                })
                corner(satVal, 5)
                stroke(satVal, theme.border, 1)

                create("ImageLabel", {
                    Parent = satVal,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Image = "rbxassetid://4155801252",
                    ImageColor3 = Color3.fromRGB(255, 255, 255),
                    Rotation = 180,
                    ZIndex = 4
                })

                local svCursor = create("Frame", {
                    Parent = satVal,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(sat, -5, 1 - val, -5),
                    Size = UDim2.new(0, 10, 0, 10),
                    ZIndex = 5
                })
                corner(svCursor, 5)
                stroke(svCursor, Color3.fromRGB(0, 0, 0), 2)

                local hueSlider = create("ImageButton", {
                    Parent = pickerHolder,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -44, 0, 10),
                    Size = UDim2.new(0, 34, 0, 90),
                    Image = "rbxassetid://3641079629",
                    ScaleType = Enum.ScaleType.Stretch,
                    AutoButtonColor = false,
                    ZIndex = 3
                })
                corner(hueSlider, 5)
                stroke(hueSlider, theme.border, 1)

                local hueCursor = create("Frame", {
                    Parent = hueSlider,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, -2, hue, -2),
                    Size = UDim2.new(1, 4, 0, 4),
                    ZIndex = 4
                })
                corner(hueCursor, 2)
                stroke(hueCursor, Color3.fromRGB(0, 0, 0), 2)

                local hexBox = create("TextBox", {
                    Parent = pickerHolder,
                    BackgroundColor3 = theme.border,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 1, -32),
                    Size = UDim2.new(1, -20, 0, 24),
                    Font = Enum.Font.GothamMedium,
                    Text = string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255),
                    TextColor3 = theme.text,
                    TextSize = 10,
                    ClearTextOnFocus = false,
                    ZIndex = 3
                })
                corner(hexBox, 4)
                stroke(hexBox, theme.border, 1)
                create("UIPadding", {Parent = hexBox, PaddingLeft = UDim.new(0, 10)})

                local colorpicker = {}

                function colorpicker:set(newColor)
                    color = newColor
                    config[flag] = color
                    preview.BackgroundColor3 = color
                    hue, sat, val = color:ToHSV()
                    satVal.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    svCursor.Position = UDim2.new(sat, -5, 1 - val, -5)
                    hueCursor.Position = UDim2.new(0, -2, hue, -2)
                    hexBox.Text = string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255)
                    if syncAccent then window:setAccent(color) end
                    callback(color)
                end

                function colorpicker:load()
                    if config[flag] ~= nil then colorpicker:set(config[flag]) end
                end

                preview.MouseButton1Click:Connect(function()
                    opened = not opened
                    tween(cFrame, {Size = UDim2.new(1, 0, 0, opened and 190 or 36)}, 0.2)
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
                        local conn2 = uis.InputEnded:Connect(function(input2)
                            if input2.UserInputType == Enum.UserInputType.MouseButton1 then
                                svDragging = false
                                conn:Disconnect()
                                conn2:Disconnect()
                            end
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
                        local conn2 = uis.InputEnded:Connect(function(input2)
                            if input2.UserInputType == Enum.UserInputType.MouseButton1 then
                                hueDragging = false
                                conn:Disconnect()
                                conn2:Disconnect()
                            end
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
                local lFrame = create("Frame", {Parent = sContent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20)})
                local label = create("TextLabel", {
                    Parent = lFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -16, 1, 0),
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

    uis.InputBegan:Connect(function(input)
        for flag, data in pairs(window.keybinds) do
            local isMatch = false
            if typeof(data.key) == "EnumItem" then
                if data.key.EnumType == Enum.KeyCode then
                    isMatch = input.KeyCode == data.key
                elseif data.key.EnumType == Enum.UserInputType then
                    isMatch = input.UserInputType == data.key
                end
            end
            if isMatch then
                data.callback(true)
            end
        end
    end)

    window:load()
    main.Size = UDim2.new(0, 0, 0, 0)
    tween(main, {Size = UDim2.new(0, size[1], 0, size[2])}, 0.5, Enum.EasingStyle.Back)

    return window
end

return club
