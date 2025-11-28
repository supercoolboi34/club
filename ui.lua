local library = {}

local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local http = game:GetService("HttpService")
local rs = game:GetService("RunService")

local kill = "linoria_ui"
if _G[kill] then
    pcall(function() _G[kill]:Destroy() end)
    _G[kill] = nil
end

local theme = {
    background = Color3.fromRGB(20, 20, 20),
    element = Color3.fromRGB(30, 30, 30),
    accent = Color3.fromRGB(0, 135, 255),
    text = Color3.fromRGB(255, 255, 255),
    textdark = Color3.fromRGB(180, 180, 180),
    outline = Color3.fromRGB(45, 45, 45),
    inline = Color3.fromRGB(15, 15, 15)
}

local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function tween(obj, props, time)
    ts:Create(obj, TweenInfo.new(time or 0.15), props):Play()
end

function library:create(cfg)
    cfg = cfg or {}
    local title = cfg.title or "linoria"
    local size = cfg.size or Vector2.new(580, 460)
    local config = {}
    local flags = {}
    local accent = theme.accent
    
    local gui = create("ScreenGui", {
        Name = http:GenerateGUID(false),
        Parent = game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    _G[kill] = gui
    
    local main = create("Frame", {
        Name = "main",
        Parent = gui,
        BackgroundColor3 = theme.background,
        BorderColor3 = theme.outline,
        BorderSizePixel = 1,
        Position = UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2),
        Size = UDim2.new(0, size.X, 0, size.Y)
    })
    
    local inline = create("Frame", {
        Parent = main,
        BackgroundColor3 = theme.inline,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2)
    })
    
    local topbar = create("Frame", {
        Parent = inline,
        BackgroundColor3 = theme.element,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 25)
    })
    
    local topinline = create("Frame", {
        Parent = topbar,
        BackgroundColor3 = theme.inline,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 1)
    })
    
    local titlelabel = create("TextLabel", {
        Parent = topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -16, 1, 0),
        Font = Enum.Font.Code,
        Text = title,
        TextColor3 = theme.text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local tabbar = create("Frame", {
        Parent = inline,
        BackgroundColor3 = theme.element,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 26),
        Size = UDim2.new(0, 150, 1, -26)
    })
    
    local tabinline = create("Frame", {
        Parent = tabbar,
        BackgroundColor3 = theme.inline,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0)
    })
    
    local tabholder = create("Frame", {
        Parent = tabbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 6),
        Size = UDim2.new(1, -12, 1, -12)
    })
    create("UIListLayout", {Parent = tabholder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
    
    local container = create("Frame", {
        Parent = inline,
        BackgroundColor3 = theme.background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 151, 0, 26),
        Size = UDim2.new(1, -151, 1, -26)
    })
    
    local dragging, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    
    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    uis.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    local window = {tabs = {}, flags = flags, config = config, accent = accent}
    
    function window:SetAccent(color)
        accent = color
        window.accent = color
        for _, tab in pairs(window.tabs) do
            if tab.UpdateAccent then tab:UpdateAccent(color) end
        end
    end
    
    function window:AddTab(name)
        local tab = {sections = {}, accent = accent, elements = {}}
        
        local button = create("TextButton", {
            Parent = tabholder,
            BackgroundColor3 = theme.element,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 22),
            Font = Enum.Font.Code,
            Text = name,
            TextColor3 = theme.textdark,
            TextSize = 13,
            AutoButtonColor = false
        })
        
        local buttoninline = create("Frame", {
            Parent = button,
            BackgroundColor3 = theme.inline,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1)
        })
        
        local buttoninline2 = create("Frame", {
            Parent = button,
            BackgroundColor3 = theme.inline,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -1),
            Size = UDim2.new(1, 0, 0, 1)
        })
        
        local content = create("ScrollingFrame", {
            Parent = container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = theme.outline,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        
        local left = create("Frame", {
            Parent = content,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 6, 0, 6),
            Size = UDim2.new(0.5, -9, 1, -12),
            AutomaticSize = Enum.AutomaticSize.Y
        })
        create("UIListLayout", {Parent = left, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12)})
        
        local right = create("Frame", {
            Parent = content,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 3, 0, 6),
            Size = UDim2.new(0.5, -9, 1, -12),
            AutomaticSize = Enum.AutomaticSize.Y
        })
        create("UIListLayout", {Parent = right, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12)})
        
        tab.left = left
        tab.right = right
        tab.button = button
        
        local function select()
            for _, t in pairs(window.tabs) do
                t.button.BackgroundColor3 = theme.element
                t.button.TextColor3 = theme.textdark
                if t.content then t.content.Visible = false end
            end
            button.BackgroundColor3 = accent
            button.TextColor3 = theme.text
            content.Visible = true
        end
        
        button.MouseButton1Click:Connect(select)
        
        if not window.selectedTab then
            window.selectedTab = tab
            select()
        end
        
        function tab:UpdateAccent(color)
            accent = color
            if button.BackgroundColor3 == accent or button.BackgroundColor3 == window.accent then
                button.BackgroundColor3 = color
            end
            for _, element in pairs(tab.elements) do
                if element.UpdateAccent then element:UpdateAccent(color) end
            end
        end
        
        function tab:AddLeftGroupbox(name)
            return self:AddGroupbox(name, left)
        end
        
        function tab:AddRightGroupbox(name)
            return self:AddGroupbox(name, right)
        end
        
        function tab:AddGroupbox(name, parent)
            local groupbox = {elements = {}}
            
            local box = create("Frame", {
                Parent = parent,
                BackgroundColor3 = theme.element,
                BorderColor3 = theme.outline,
                BorderSizePixel = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            local inline = create("Frame", {
                Parent = box,
                BackgroundColor3 = theme.inline,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 1, 0, 1),
                Size = UDim2.new(1, -2, 1, -2),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            local label = create("TextLabel", {
                Parent = inline,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 6, 0, 4),
                Size = UDim2.new(1, -12, 0, 16),
                Font = Enum.Font.Code,
                Text = name,
                TextColor3 = theme.text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local labelline = create("Frame", {
                Parent = inline,
                BackgroundColor3 = theme.outline,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 22),
                Size = UDim2.new(1, 0, 0, 1)
            })
            
            local content = create("Frame", {
                Parent = inline,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 4, 0, 25),
                Size = UDim2.new(1, -8, 1, -29),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            create("UIListLayout", {Parent = content, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
            
            groupbox.content = content
            
            function groupbox:AddToggle(name, cfg)
                cfg = cfg or {}
                local flag = cfg.flag
                local callback = cfg.callback or function() end
                local default = cfg.default or false
                
                if flag then flags[flag] = default end
                local toggled = default
                
                local holder = create("Frame", {
                    Parent = content,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14)
                })
                
                local checkbox = create("Frame", {
                    Parent = holder,
                    BackgroundColor3 = theme.background,
                    BorderColor3 = theme.outline,
                    BorderSizePixel = 1,
                    Size = UDim2.new(0, 12, 0, 12)
                })
                
                local checkinline = create("Frame", {
                    Parent = checkbox,
                    BackgroundColor3 = theme.inline,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2)
                })
                
                local checkmark = create("Frame", {
                    Parent = checkinline,
                    BackgroundColor3 = accent,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 2, 0, 2),
                    Size = UDim2.new(1, -4, 1, -4),
                    Visible = toggled
                })
                
                local label = create("TextLabel", {
                    Parent = holder,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 18, 0, -1),
                    Size = UDim2.new(1, -18, 1, 0),
                    Font = Enum.Font.Code,
                    Text = name,
                    TextColor3 = theme.text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local button = create("TextButton", {
                    Parent = holder,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 2
                })
                
                local toggle = {}
                
                function toggle:SetValue(value)
                    toggled = value
                    if flag then flags[flag] = value end
                    checkmark.Visible = value
                    callback(value)
                end
                
                function toggle:UpdateAccent(color)
                    checkmark.BackgroundColor3 = color
                end
                
                button.MouseButton1Click:Connect(function()
                    toggle:SetValue(not toggled)
                end)
                
                table.insert(groupbox.elements, toggle)
                table.insert(tab.elements, toggle)
                callback(toggled)
                return toggle
            end
            
            function groupbox:AddSlider(name, cfg)
                cfg = cfg or {}
                local flag = cfg.flag
                local min = cfg.min or 0
                local max = cfg.max or 100
                local default = cfg.default or min
                local rounding = cfg.rounding or 1
                local callback = cfg.callback or function() end
                local suffix = cfg.suffix or ""
                
                if flag then flags[flag] = default end
                local value = default
                
                local holder = create("Frame", {
                    Parent = content,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34)
                })
                
                local label = create("TextLabel", {
                    Parent = holder,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -40, 0, 14),
                    Font = Enum.Font.Code,
                    Text = name,
                    TextColor3 = theme.text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local valuelabel = create("TextLabel", {
                    Parent = holder,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -40, 0, 0),
                    Size = UDim2.new(0, 40, 0, 14),
                    Font = Enum.Font.Code,
                    Text = tostring(value) .. suffix,
                    TextColor3 = theme.textdark,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local track = create("Frame", {
                    Parent = holder,
                    BackgroundColor3 = theme.background,
                    BorderColor3 = theme.outline,
                    BorderSizePixel = 1,
                    Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 12)
                })
                
                local trackinline = create("Frame", {
                    Parent = track,
                    BackgroundColor3 = theme.inline,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2)
                })
                
                local fill = create("Frame", {
                    Parent = trackinline,
                    BackgroundColor3 = accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                })
                
                local slider = {}
                
                function slider:SetValue(val)
                    value = math.clamp(math.floor(val / rounding + 0.5) * rounding, min, max)
                    if flag then flags[flag] = value end
                    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    valuelabel.Text = tostring(value) .. suffix
                    callback(value)
                end
                
                function slider:UpdateAccent(color)
                    fill.BackgroundColor3 = color
                end
                
                local dragging = false
                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        while dragging do
                            local mouse = uis:GetMouseLocation()
                            local percent = math.clamp((mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                            slider:SetValue(min + (max - min) * percent)
                            rs.RenderStepped:Wait()
                        end
                    end
                end)
                
                uis.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                table.insert(groupbox.elements, slider)
                table.insert(tab.elements, slider)
                callback(value)
                return slider
            end
            
            function groupbox:AddDropdown(name, cfg)
                cfg = cfg or {}
                local flag = cfg.flag
                local options = cfg.options or {}
                local default = cfg.default or options[1]
                local callback = cfg.callback or function() end
                
                if flag then flags[flag] = default end
                local selected = default
                local opened = false
                
                local holder = create("Frame", {
                    Parent = content,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    ClipsDescendants = true
                })
                
                local label = create("TextLabel", {
                    Parent = holder,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Enum.Font.Code,
                    Text = name,
                    TextColor3 = theme.text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local button = create("TextButton", {
                    Parent = holder,
                    BackgroundColor3 = theme.background,
                    BorderColor3 = theme.outline,
                    BorderSizePixel = 1,
                    Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Enum.Font.Code,
                    Text = "",
                    TextColor3 = theme.text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false
                })
                
                local buttoninline = create("Frame", {
                    Parent = button,
                    BackgroundColor3 = theme.inline,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2)
                })
                
                local buttonlabel = create("TextLabel", {
                    Parent = buttoninline,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 4, 0, 0),
                    Size = UDim2.new(1, -8, 1, 0),
                    Font = Enum.Font.Code,
                    Text = tostring(selected),
                    TextColor3 = theme.text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd
                })
                
                local optionsholder = create("Frame", {
                    Parent = holder,
                    BackgroundColor3 = theme.background,
                    BorderColor3 = theme.outline,
                    BorderSizePixel = 1,
                    Position = UDim2.new(0, 0, 0, 33),
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true
                })
                
                local optionsinline = create("Frame", {
                    Parent = optionsholder,
                    BackgroundColor3 = theme.inline,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2)
                })
                
                local optionslist = create("Frame", {
                    Parent = optionsinline,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 2, 0, 2),
                    Size = UDim2.new(1, -4, 1, -4),
                    AutomaticSize = Enum.AutomaticSize.Y
                })
                create("UIListLayout", {Parent = optionslist, SortOrder = Enum.SortOrder.LayoutOrder})
                
                local dropdown = {}
                
                function dropdown:SetValue(value)
                    selected = value
                    if flag then flags[flag] = value end
                    buttonlabel.Text = tostring(value)
                    callback(value)
                end
                
                for _, option in ipairs(options) do
                    local optbutton = create("TextButton", {
                        Parent = optionslist,
                        BackgroundColor3 = theme.element,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 16),
                        Font = Enum.Font.Code,
                        Text = tostring(option),
                        TextColor3 = theme.text,
                        TextSize = 13,
                        AutoButtonColor = false
                    })
                    
                    optbutton.MouseButton1Click:Connect(function()
                        dropdown:SetValue(option)
                        opened = false
                        tween(holder, {Size = UDim2.new(1, 0, 0, 32)})
                        tween(optionsholder, {Size = UDim2.new(1, 0, 0, 0)})
                    end)
                    
                    optbutton.MouseEnter:Connect(function() optbutton.BackgroundColor3 = accent end)
                    optbutton.MouseLeave:Connect(function() optbutton.BackgroundColor3 = theme.element end)
                end
                
                button.MouseButton1Click:Connect(function()
                    opened = not opened
                    local optionheight = math.min(#options * 16 + 4, 160)
                    tween(holder, {Size = UDim2.new(1, 0, 0, opened and (32 + optionheight + 1) or 32)})
                    tween(optionsholder, {Size = UDim2.new(1, 0, 0, opened and optionheight or 0)})
                end)
                
                table.insert(groupbox.elements, dropdown)
                table.insert(tab.elements, dropdown)
                callback(selected)
                return dropdown
            end
            
            function groupbox:AddButton(name, callback)
                callback = callback or function() end
                
                local holder = create("Frame", {
                    Parent = content,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16)
                })
                
                local button = create("TextButton", {
                    Parent = holder,
                    BackgroundColor3 = theme.background,
                    BorderColor3 = theme.outline,
                    BorderSizePixel = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    Font = Enum.Font.Code,
                    Text = name,
                    TextColor3 = theme.text,
                    TextSize = 13,
                    AutoButtonColor = false
                })
                
                local buttoninline = create("Frame", {
                    Parent = button,
                    BackgroundColor3 = theme.inline,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2)
                })
                
                button.MouseButton1Click:Connect(callback)
                button.MouseEnter:Connect(function() button.BackgroundColor3 = accent end)
                button.MouseLeave:Connect(function() button.BackgroundColor3 = theme.background end)
                
                return {}
            end
            
            function groupbox:AddInput(name, cfg)
                cfg = cfg or {}
                local flag = cfg.flag
                local default = cfg.default or ""
                local placeholder = cfg.placeholder or ""
                local callback = cfg.callback or function() end
                
                if flag then flags[flag] = default end
                
                local holder = create("Frame", {
                    Parent = content,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32)
                })
                
                local label = create("TextLabel", {
                    Parent = holder,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Enum.Font.Code,
                    Text = name,
                    TextColor3 = theme.text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local input = create("TextBox", {
                    Parent = holder,
                    BackgroundColor3 = theme.background,
                    BorderColor3 = theme.outline,
                    BorderSizePixel = 1,
                    Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Enum.Font.Code,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = theme.textdark,
                    Text = default,
                    TextColor3 = theme.text,
                    TextSize = 13,
                    ClearTextOnFocus = false
                })
                
                local inputinline = create("Frame", {
                    Parent = input,
                    BackgroundColor3 = theme.inline,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2)
                })
                create("UIPadding", {Parent = input, PaddingLeft = UDim.new(0, 4)})
                
                local textbox = {}
                
                function textbox:SetValue(value)
                    input.Text = value
                    if flag then flags[flag] = value end
                    callback(value)
                end
                
                input.FocusLost:Connect(function()
                    textbox:SetValue(input.Text)
                end)
                
                return textbox
            end
            
            function groupbox:AddColorpicker(name, cfg)
                cfg = cfg or {}
                local flag = cfg.flag
                local default = cfg.default or Color3.fromRGB(255, 255, 255)
                local callback = cfg.callback or function() end
                
                if flag then flags[flag] = default end
                local color = default
                local opened = false
                
                local holder = create("Frame", {
                    Parent = content,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14)
                })
                
                local label = create("TextLabel", {
                    Parent = holder,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -18, 1, 0),
                    Font = Enum.Font.Code,
                    Text = name,
                    TextColor3 = theme.text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local button = create("TextButton", {
                    Parent = holder,
                    BackgroundColor3 = color,
                    BorderColor3 = theme.outline,
                    BorderSizePixel = 1,
                    Position = UDim2.new(1, -14, 0, 0),
                    Size = UDim2.new(0, 14, 0, 14),
                    Text = "",
                    AutoButtonColor = false
                })
                
                local buttoninline = create("Frame", {
                    Parent = button,
                    BackgroundColor3 = theme.inline,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2)
                })
                
                local colorpicker = {}
                
                function colorpicker:SetValue(value)
                    color = value
                    if flag then flags[flag] = value end
                    button.BackgroundColor3 = value
                    callback(value)
                end
                
                return colorpicker
            end
            
            function groupbox:AddLabel(text)
                local label = create("TextLabel", {
                    Parent = content,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Enum.Font.Code,
                    Text = text,
                    TextColor3 = theme.textdark,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    AutomaticSize = Enum.AutomaticSize.Y
                })
                
                return {SetValue = function(_, t) label.Text = t end}
            end
            
            return groupbox
        end
        
        tab.content = content
        table.insert(window.tabs, tab)
        return tab
    end
    
    return window
end

return library
