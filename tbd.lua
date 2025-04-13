--[[
    TBD UI Library V9 - Fixed Version
    
    This version preserves the exact design and visual elements of the previous versions
    while ensuring compatibility with all Roblox executors/injectors including AWP.GG
    
    Version: 2.0.0-V9
]]

-- Library Configuration
local TBD = {
    Name = "TBD UI Library",
    Version = "2.0.0-V9",
    Themes = {},
    Settings = {
        MinimizeKey = Enum.KeyCode.RightControl,
        HideKey = Enum.KeyCode.RightAlt
    },
    WindowCount = 0,
    Windows = {},
    Notifications = {},
    SelectedTheme = nil
}

-- Services with safe fallbacks
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = (function()
    local success, result = pcall(function()
        return game:GetService("CoreGui")
    end)
    
    if success then
        return result
    else
        return game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end)()

-- Local Player with fallback
local LocalPlayer = (function() 
    local success, result = pcall(function()
        return Players.LocalPlayer
    end)
    
    if success then
        return result
    else
        return {
            Name = "Player",
            GetThumbnailAsync = function() return "" end
        }
    end
end)()

-- Safe GuiService GetSafeInsets
local function GetSafeInsets()
    local success, result = pcall(function()
        return game:GetService("GuiService"):GetSafeInsets()
    end)
    
    if success then
        return result
    else
        return { Top = 0, Bottom = 0, Left = 0, Right = 0 }
    end
end

-- Safe TextService GetTextSize with fallback
local function GetTextSize(text, size, font, frameSize)
    local success, result = pcall(function()
        return TextService:GetTextSize(text, size, font, frameSize)
    end)
    
    if success then
        return result
    else
        -- Fallback approximation based on text length
        return Vector2.new(#text * (size / 2), size)
    end
end

-- Constants
local TWEEN_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local SPRING_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)

-- Preset Themes
TBD.Themes.Default = {
    MainFrame = Color3.fromRGB(35, 35, 40),
    TopBar = Color3.fromRGB(30, 30, 35),
    TextColor = Color3.fromRGB(255, 255, 255),
    Menu = Color3.fromRGB(37, 37, 42),
    TabToggled = Color3.fromRGB(43, 43, 48),
    Button = Color3.fromRGB(30, 30, 35),
    ButtonHold = Color3.fromRGB(40, 40, 45),
    Toggle = Color3.fromRGB(30, 30, 35),
    ToggleFrame = Color3.fromRGB(55, 55, 60),
    ToggleToggled = Color3.fromRGB(22, 168, 76),
    Slider = Color3.fromRGB(30, 30, 35),
    SliderInner = Color3.fromRGB(20, 20, 25),
    SliderProgress = Color3.fromRGB(22, 168, 76),
    Dropdown = Color3.fromRGB(30, 30, 35),
    DropdownItem = Color3.fromRGB(30, 30, 35),
    ColorPicker = Color3.fromRGB(30, 30, 35),
    Input = Color3.fromRGB(30, 30, 35),
    Notification = Color3.fromRGB(40, 40, 45),
    NotificationButtons = Color3.fromRGB(25, 25, 30),
    NotificationSuccess = Color3.fromRGB(22, 168, 76),
    NotificationError = Color3.fromRGB(192, 57, 43),
    NotificationWarning = Color3.fromRGB(235, 164, 52),
    NotificationInfo = Color3.fromRGB(52, 152, 219)
}

TBD.Themes.HoHo = {
    MainFrame = Color3.fromRGB(25, 25, 25),
    TopBar = Color3.fromRGB(20, 20, 20),
    TextColor = Color3.fromRGB(255, 255, 255),
    Menu = Color3.fromRGB(20, 20, 20),
    TabToggled = Color3.fromRGB(35, 35, 35),
    Button = Color3.fromRGB(35, 35, 35),
    ButtonHold = Color3.fromRGB(50, 50, 50),
    Toggle = Color3.fromRGB(35, 35, 35),
    ToggleFrame = Color3.fromRGB(65, 65, 65),
    ToggleToggled = Color3.fromRGB(255, 0, 0),
    Slider = Color3.fromRGB(35, 35, 35),
    SliderInner = Color3.fromRGB(25, 25, 25),
    SliderProgress = Color3.fromRGB(255, 0, 0),
    Dropdown = Color3.fromRGB(35, 35, 35),
    DropdownItem = Color3.fromRGB(35, 35, 35),
    ColorPicker = Color3.fromRGB(35, 35, 35),
    Input = Color3.fromRGB(35, 35, 35),
    Notification = Color3.fromRGB(25, 25, 25),
    NotificationButtons = Color3.fromRGB(35, 35, 35),
    NotificationSuccess = Color3.fromRGB(20, 160, 70),
    NotificationError = Color3.fromRGB(190, 55, 40),
    NotificationWarning = Color3.fromRGB(235, 165, 50),
    NotificationInfo = Color3.fromRGB(50, 150, 220)
}

TBD.Themes.Midnight = {
    MainFrame = Color3.fromRGB(25, 30, 45),
    TopBar = Color3.fromRGB(20, 25, 40),
    TextColor = Color3.fromRGB(255, 255, 255),
    Menu = Color3.fromRGB(20, 25, 40),
    TabToggled = Color3.fromRGB(35, 40, 55),
    Button = Color3.fromRGB(30, 35, 50),
    ButtonHold = Color3.fromRGB(40, 45, 60),
    Toggle = Color3.fromRGB(30, 35, 50),
    ToggleFrame = Color3.fromRGB(55, 60, 75),
    ToggleToggled = Color3.fromRGB(90, 120, 255),
    Slider = Color3.fromRGB(30, 35, 50),
    SliderInner = Color3.fromRGB(20, 25, 40),
    SliderProgress = Color3.fromRGB(90, 120, 255),
    Dropdown = Color3.fromRGB(30, 35, 50),
    DropdownItem = Color3.fromRGB(30, 35, 50),
    ColorPicker = Color3.fromRGB(30, 35, 50),
    Input = Color3.fromRGB(30, 35, 50),
    Notification = Color3.fromRGB(30, 35, 50),
    NotificationButtons = Color3.fromRGB(20, 25, 40),
    NotificationSuccess = Color3.fromRGB(22, 168, 76),
    NotificationError = Color3.fromRGB(192, 57, 43),
    NotificationWarning = Color3.fromRGB(235, 164, 52),
    NotificationInfo = Color3.fromRGB(90, 120, 255)
}

TBD.Themes.Neon = {
    MainFrame = Color3.fromRGB(15, 15, 20),
    TopBar = Color3.fromRGB(10, 10, 15),
    TextColor = Color3.fromRGB(255, 255, 255),
    Menu = Color3.fromRGB(10, 10, 15),
    TabToggled = Color3.fromRGB(25, 25, 30),
    Button = Color3.fromRGB(20, 20, 25),
    ButtonHold = Color3.fromRGB(30, 30, 35),
    Toggle = Color3.fromRGB(20, 20, 25),
    ToggleFrame = Color3.fromRGB(45, 45, 50),
    ToggleToggled = Color3.fromRGB(110, 255, 110),
    Slider = Color3.fromRGB(20, 20, 25),
    SliderInner = Color3.fromRGB(10, 10, 15),
    SliderProgress = Color3.fromRGB(110, 255, 110),
    Dropdown = Color3.fromRGB(20, 20, 25),
    DropdownItem = Color3.fromRGB(20, 20, 25),
    ColorPicker = Color3.fromRGB(20, 20, 25),
    Input = Color3.fromRGB(20, 20, 25),
    Notification = Color3.fromRGB(20, 20, 25),
    NotificationButtons = Color3.fromRGB(10, 10, 15),
    NotificationSuccess = Color3.fromRGB(110, 255, 110),
    NotificationError = Color3.fromRGB(255, 80, 80),
    NotificationWarning = Color3.fromRGB(255, 230, 110),
    NotificationInfo = Color3.fromRGB(130, 200, 255)
}

TBD.Themes.Aqua = {
    MainFrame = Color3.fromRGB(30, 40, 45),
    TopBar = Color3.fromRGB(25, 35, 40),
    TextColor = Color3.fromRGB(255, 255, 255),
    Menu = Color3.fromRGB(25, 35, 40),
    TabToggled = Color3.fromRGB(40, 50, 55),
    Button = Color3.fromRGB(35, 45, 50),
    ButtonHold = Color3.fromRGB(45, 55, 60),
    Toggle = Color3.fromRGB(35, 45, 50),
    ToggleFrame = Color3.fromRGB(55, 65, 70),
    ToggleToggled = Color3.fromRGB(60, 180, 210),
    Slider = Color3.fromRGB(35, 45, 50),
    SliderInner = Color3.fromRGB(25, 35, 40),
    SliderProgress = Color3.fromRGB(60, 180, 210),
    Dropdown = Color3.fromRGB(35, 45, 50),
    DropdownItem = Color3.fromRGB(35, 45, 50),
    ColorPicker = Color3.fromRGB(35, 45, 50),
    Input = Color3.fromRGB(35, 45, 50),
    Notification = Color3.fromRGB(35, 45, 50),
    NotificationButtons = Color3.fromRGB(25, 35, 40),
    NotificationSuccess = Color3.fromRGB(22, 168, 76),
    NotificationError = Color3.fromRGB(192, 57, 43),
    NotificationWarning = Color3.fromRGB(235, 164, 52),
    NotificationInfo = Color3.fromRGB(60, 180, 210)
}

-- Create a custom theme
function TBD:CustomTheme(theme)
    self.Themes.Custom = theme
    return theme
end

-- Icons
local Icons = {
    ["Home"] = "rbxassetid://7733960981",
    ["Settings"] = "rbxassetid://7734053495",
    ["Script"] = "rbxassetid://7733978098",
    ["Credit"] = "rbxassetid://7734000121",
    ["Discord"] = "rbxassetid://7734030487",
    ["Globe"] = "rbxassetid://7734063576",
    ["Exit"] = "rbxassetid://7734234941",
    ["Minimize"] = "rbxassetid://7734071918",
    ["Notification"] = "rbxassetid://7734062485",
    ["Arrow"] = "rbxassetid://7734201216"
}

-- Utility functions
local function Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    
    return instance
end

-- Make frame draggable
local function MakeDraggable(frame, handle)
    local dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragStart = nil
                    dragInput = nil
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragStart then
            local delta = input.Position - dragStart
            TweenService:Create(frame, TWEEN_INFO, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
        end
    end)
end

-- Ripple effect for buttons
local function CreateRipple(parent)
    parent.ClipsDescendants = true
    
    local ripple = Create("ImageLabel", {
        Name = "Ripple",
        Parent = parent,
        BackgroundTransparency = 1,
        Image = "rbxassetid://7734041921",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(50, 50, 50, 50),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0)
    })
    
    parent.MouseButton1Down:Connect(function(x, y)
        local relativePosition = Vector2.new(x - parent.AbsolutePosition.X, y - parent.AbsolutePosition.Y)
        local size = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 1.5
        
        ripple.Position = UDim2.new(0, relativePosition.X, 0, relativePosition.Y)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        
        TweenService:Create(ripple, TweenInfo.new(0.5), {
            Size = UDim2.new(0, size, 0, size),
            ImageTransparency = 1
        }):Play()
    end)
end

-- Notification function
function TBD:Notification(options)
    options = options or {}
    options.Title = options.Title or "Notification"
    options.Message = options.Message or "This is a notification"
    options.Time = options.Time or options.Duration or 5
    options.Type = options.Type or "Info"
    
    -- Get the correct color based on notification type
    local theme = self.SelectedTheme
    local typeColors = {
        Success = theme.NotificationSuccess,
        Error = theme.NotificationError,
        Warning = theme.NotificationWarning,
        Info = theme.NotificationInfo
    }
    local typeColor = typeColors[options.Type] or typeColors.Info
    
    -- Create the notification container if it doesn't exist
    if not self.NotificationContainer then
        self.NotificationContainer = Create("ScreenGui", {
            Name = "TBDNotificationContainer",
            Parent = CoreGui,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ResetOnSpawn = false
        })
        
        -- Try to make IgnoreGuiInset = true (might not work in all executors)
        pcall(function()
            self.NotificationContainer.IgnoreGuiInset = true
        end)
        
        local SafeInsets = GetSafeInsets()
        
        local holder = Create("Frame", {
            Name = "NotificationHolder",
            Parent = self.NotificationContainer,
            AnchorPoint = Vector2.new(1, 1),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -20, 1, -20 - SafeInsets.Bottom),
            Size = UDim2.new(0, 300, 1, -40)
        })
        
        local UIListLayout = Create("UIListLayout", {
            Parent = holder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 10)
        })
        
        UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            holder.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
        end)
    end
    
    -- Create notification
    local notification = Create("Frame", {
        Name = "Notification",
        Parent = self.NotificationContainer.NotificationHolder,
        BackgroundColor3 = theme.Notification,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        AnchorPoint = Vector2.new(1, 1),
        LayoutOrder = #self.Notifications + 1
    })
    
    -- Corner and UI elements for Notification
    local UICorner = Create("UICorner", {
        Parent = notification,
        CornerRadius = UDim.new(0, 6)
    })
    
    -- Title part
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = notification,
        BackgroundColor3 = theme.NotificationButtons,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36)
    })
    
    local titleCorner = Create("UICorner", {
        Parent = titleBar,
        CornerRadius = UDim.new(0, 6)
    })
    
    local cornerFix = Create("Frame", {
        Name = "CornerFix",
        Parent = titleBar,
        BackgroundColor3 = theme.NotificationButtons,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -6),
        Size = UDim2.new(1, 0, 0, 6)
    })
    
    local iconHolder = Create("Frame", {
        Name = "IconHolder",
        Parent = titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(0, 20, 0, 20)
    })
    
    local icon = Create("ImageLabel", {
        Name = "Icon",
        Parent = iconHolder,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Image = Icons.Notification,
        ImageColor3 = typeColor
    })
    
    local title = Create("TextLabel", {
        Name = "Title",
        Parent = titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 36, 0, 0),
        Size = UDim2.new(1, -36, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = options.Title,
        TextColor3 = theme.TextColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Content part
    local content = Create("TextLabel", {
        Name = "Content",
        Parent = notification,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 44),
        Size = UDim2.new(1, -24, 0, 0),
        Font = Enum.Font.Gotham,
        Text = options.Message,
        TextColor3 = theme.TextColor,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    -- Size calculation
    local textSize = GetTextSize(options.Message, 14, Enum.Font.Gotham, Vector2.new(notification.AbsoluteSize.X - 24, math.huge))
    local contentHeight = textSize.Y + 20
    
    notification.Size = UDim2.new(1, 0, 0, 44 + contentHeight)
    
    -- Close after timer
    table.insert(self.Notifications, notification)
    
    -- Animation in
    notification.Position = UDim2.new(1.1, 0, 1, 0)
    TweenService:Create(notification, TWEEN_INFO, {Position = UDim2.new(1, 0, 1, 0)}):Play()
    
    -- Auto close 
    task.delay(options.Time, function()
        TweenService:Create(notification, TWEEN_INFO, {Position = UDim2.new(1.1, 0, 1, 0)}):Play()
        wait(0.26)
        notification:Destroy()
        
        -- Remove from table
        for i, notif in pairs(self.Notifications) do
            if notif == notification then
                table.remove(self.Notifications, i)
                break
            end
        end
    end)
    
    -- Return the notification in case the developer wants to do something with it
    return notification
end

-- Window creation
function TBD:CreateWindow(options)
    options = options or {}
    options.Title = options.Title or self.Name
    options.Subtitle = options.Subtitle or self.Version
    options.Theme = options.Theme or "HoHo"
    options.LoadingEnabled = options.LoadingEnabled ~= nil and options.LoadingEnabled or false
    options.ShowHomePage = options.ShowHomePage ~= nil and options.ShowHomePage or true
    options.Size = options.Size or {600, 450} -- Default is now wider

    self.SelectedTheme = self.Themes[options.Theme] or self.Themes.HoHo
    local theme = self.SelectedTheme
    
    self.WindowCount = self.WindowCount + 1
    
    -- Create the main container
    local container = Create("ScreenGui", {
        Name = "TBDLibraryV9_" .. self.WindowCount,
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Try to make IgnoreGuiInset = true (might not work in all executors)
    pcall(function()
        container.IgnoreGuiInset = true
    end)
    
    local loadingScreen
    if options.LoadingEnabled then
        loadingScreen = Create("Frame", {
            Name = "LoadingScreen",
            Parent = container,
            BackgroundColor3 = theme.MainFrame,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, -(options.Size[1] / 2), 0.5, -(options.Size[2] / 2)),
            Size = UDim2.new(0, options.Size[1], 0, options.Size[2]),
            ClipsDescendants = true
        })
        
        local loadingCorner = Create("UICorner", {
            Parent = loadingScreen,
            CornerRadius = UDim.new(0, 6)
        })
        
        -- Shadow under loading screen
        local loadingShadow = Create("ImageLabel", {
            Name = "Shadow",
            Parent = loadingScreen,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 40, 1, 40),
            ZIndex = 0,
            Image = "rbxassetid://6014261993",
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.5,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(49, 49, 450, 450)
        })
        
        local loadingTitle = Create("TextLabel", {
            Name = "Title",
            Parent = loadingScreen,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.4, -30),
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.GothamBold,
            Text = options.Title,
            TextColor3 = theme.TextColor,
            TextSize = 24
        })
        
        local loadingSubtitle = Create("TextLabel", {
            Name = "Subtitle",
            Parent = loadingScreen,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.4, 0),
            Size = UDim2.new(1, 0, 0, 20),
            Font = Enum.Font.Gotham,
            Text = options.Subtitle,
            TextColor3 = theme.TextColor,
            TextSize = 16
        })
        
        local loadingBar = Create("Frame", {
            Name = "LoadingBar",
            Parent = loadingScreen,
            BackgroundColor3 = theme.TopBar,
            BorderSizePixel = 0,
            Position = UDim2.new(0.2, 0, 0.6, 0),
            Size = UDim2.new(0.6, 0, 0, 6)
        })
        
        local loadingBarCorner = Create("UICorner", {
            Parent = loadingBar,
            CornerRadius = UDim.new(0, 3)
        })
        
        local loadingBarFill = Create("Frame", {
            Name = "Fill",
            Parent = loadingBar,
            BackgroundColor3 = options.Theme == "HoHo" and Color3.fromRGB(255, 0, 0) or theme.ToggleToggled,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 0, 1, 0)
        })
        
        local loadingBarFillCorner = Create("UICorner", {
            Parent = loadingBarFill,
            CornerRadius = UDim.new(0, 3)
        })
        
        local loadingStatus = Create("TextLabel", {
            Name = "Status",
            Parent = loadingScreen,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.6, 12),
            Size = UDim2.new(1, 0, 0, 20),
            Font = Enum.Font.Gotham,
            Text = "Initializing...",
            TextColor3 = theme.TextColor,
            TextSize = 14
        })
        
        -- Loading animation
        task.spawn(function()
            local statuses = {
                "Initializing...",
                "Loading assets...",
                "Preparing interface...",
                "Finalizing setup..."
            }
            
            for i = 1, 100 do
                local statusIndex = math.floor((i / 100) * #statuses) + 1
                if statusIndex > #statuses then statusIndex = #statuses end
                
                loadingStatus.Text = statuses[statusIndex]
                loadingBarFill:TweenSize(UDim2.new(i/100, 0, 1, 0), "Out", "Quad", 0.03, true)
                
                if i == 30 or i == 60 or i == 90 or i == 100 then
                    wait(0.3)
                else
                    wait(0.03)
                end
            end
            
            -- Hide loading screen
            TweenService:Create(loadingScreen, TWEEN_INFO, {BackgroundTransparency = 1}):Play()
            TweenService:Create(loadingTitle, TWEEN_INFO, {TextTransparency = 1}):Play()
            TweenService:Create(loadingSubtitle, TWEEN_INFO, {TextTransparency = 1}):Play()
            TweenService:Create(loadingBar, TWEEN_INFO, {BackgroundTransparency = 1}):Play()
            TweenService:Create(loadingBarFill, TWEEN_INFO, {BackgroundTransparency = 1}):Play()
            TweenService:Create(loadingStatus, TWEEN_INFO, {TextTransparency = 1}):Play()
            TweenService:Create(loadingShadow, TWEEN_INFO, {ImageTransparency = 1}):Play()
            
            wait(0.3)
            loadingScreen.Visible = false
        end)
    end
    
    -- Main window
    local main = Create("Frame", {
        Name = "MainFrame",
        Parent = container,
        BackgroundColor3 = theme.MainFrame,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -(options.Size[1] / 2), 0.5, -(options.Size[2] / 2)),
        Size = UDim2.new(0, options.Size[1], 0, options.Size[2]),
        ClipsDescendants = true,
        Visible = not options.LoadingEnabled
    })
    
    local mainCorner = Create("UICorner", {
        Parent = main,
        CornerRadius = UDim.new(0, 6)
    })
    
    -- Shadow under main frame
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = main,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 40, 1, 40),
        ZIndex = 0,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    })
    
    -- Top bar
    local topBar = Create("Frame", {
        Name = "TopBar",
        Parent = main,
        BackgroundColor3 = theme.TopBar,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36)
    })
    
    local topBarCorner = Create("UICorner", {
        Parent = topBar,
        CornerRadius = UDim.new(0, 6)
    })
    
    local topBarFix = Create("Frame", {
        Name = "TopBarFix",
        Parent = topBar,
        BackgroundColor3 = theme.TopBar,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -6),
        Size = UDim2.new(1, 0, 0, 6)
    })
    
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        Parent = topBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = options.Title,
        TextColor3 = theme.TextColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local subtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        Parent = topBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -120, 1, 0),
        Font = Enum.Font.Gotham,
        Text = options.Subtitle,
        TextColor3 = theme.TextColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    -- Close and minimize buttons
    local closeBtn = Create("ImageButton", {
        Name = "CloseButton",
        Parent = topBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 8),
        Size = UDim2.new(0, 20, 0, 20),
        Image = Icons.Exit,
        ImageColor3 = theme.TextColor
    })
    
    local minimizeBtn = Create("ImageButton", {
        Name = "MinimizeButton",
        Parent = topBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -60, 0, 8),
        Size = UDim2.new(0, 20, 0, 20),
        Image = Icons.Minimize,
        ImageColor3 = theme.TextColor
    })
    
    -- Navigation panel on the left
    local navPanel = Create("Frame", {
        Name = "NavigationPanel",
        Parent = main,
        BackgroundColor3 = theme.Menu,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 36),
        Size = UDim2.new(0, 140, 1, -36)
    })
    
    local navPanelCorner = Create("UICorner", {
        Parent = navPanel,
        CornerRadius = UDim.new(0, 6)
    })
    
    local navPanelFixTop = Create("Frame", {
        Name = "NavPanelFixTop",
        Parent = navPanel,
        BackgroundColor3 = theme.Menu,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 6)
    })
    
    local navPanelFixRight = Create("Frame", {
        Name = "NavPanelFixRight",
        Parent = navPanel,
        BackgroundColor3 = theme.Menu,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -6, 0, 0),
        Size = UDim2.new(0, 6, 1, 0)
    })
    
    -- Tabs container in nav panel
    local tabsContainer = Create("ScrollingFrame", {
        Name = "TabsContainer",
        Parent = navPanel,
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 1, -20),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
        ScrollBarImageTransparency = 0.8,
        VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left
    })
    
    local tabsListLayout = Create("UIListLayout", {
        Parent = tabsContainer,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    tabsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabsContainer.CanvasSize = UDim2.new(0, 0, 0, tabsListLayout.AbsoluteContentSize.Y + 20)
    end)
    
    local tabsPadding = Create("UIPadding", {
        Parent = tabsContainer,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 5),
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5)
    })
    
    -- Content container
    local contentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = main,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 140, 0, 36),
        Size = UDim2.new(1, -140, 1, -36),
        ClipsDescendants = true
    })
    
    -- Home page (optional)
    local homeTab = nil
    if options.ShowHomePage then
        homeTab = Create("ScrollingFrame", {
            Name = "HomeTab",
            Parent = contentContainer,
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
            ScrollBarImageTransparency = 0.8,
            Visible = true
        })
        
        local homeTabListLayout = Create("UIListLayout", {
            Parent = homeTab,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        local homeTabPadding = Create("UIPadding", {
            Parent = homeTab,
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15)
        })
        
        -- Player info section
        local playerInfoSection = Create("Frame", {
            Name = "PlayerInfoSection",
            Parent = homeTab,
            BackgroundColor3 = theme.Button,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 100),
            LayoutOrder = 1
        })
        
        local playerInfoCorner = Create("UICorner", {
            Parent = playerInfoSection,
            CornerRadius = UDim.new(0, 6)
        })
        
        -- Player avatar
        local playerAvatarHolder = Create("Frame", {
            Name = "PlayerAvatarHolder",
            Parent = playerInfoSection,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(0, 80, 0, 80)
        })
        
        -- Try to get player avatar
        local avatarImage = "rbxassetid://7733978098" -- Default fallback
        
        local success, result = pcall(function()
            return Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size420x420
            )
        end)
        
        if success then
            avatarImage = result
        end
        
        local playerAvatar = Create("ImageLabel", {
            Name = "PlayerAvatar",
            Parent = playerAvatarHolder,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Image = avatarImage
        })
        
        local playerAvatarCorner = Create("UICorner", {
            Parent = playerAvatar,
            CornerRadius = UDim.new(0, 6)
        })
        
        -- Player name info
        local playerName = Create("TextLabel", {
            Name = "PlayerName",
            Parent = playerInfoSection,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 100, 0, 15),
            Size = UDim2.new(1, -110, 0, 25),
            Font = Enum.Font.GothamBold,
            Text = LocalPlayer.DisplayName or LocalPlayer.Name,
            TextColor3 = theme.TextColor,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local playerSubName = Create("TextLabel", {
            Name = "PlayerSubName",
            Parent = playerInfoSection,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 100, 0, 40),
            Size = UDim2.new(1, -110, 0, 20),
            Font = Enum.Font.Gotham,
            Text = "@" .. LocalPlayer.Name,
            TextColor3 = theme.TextColor,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Game info
        local gameInfo = "Unknown Game"
        
        pcall(function()
            if game.GameId and game.GameId > 0 then
                local success, gameData = pcall(function()
                    return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
                end)
                
                if success and gameData then
                    gameInfo = gameData.Name
                end
            end
        end)
        
        local gameInfoLabel = Create("TextLabel", {
            Name = "GameInfo",
            Parent = playerInfoSection,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 100, 0, 65),
            Size = UDim2.new(1, -110, 0, 20),
            Font = Enum.Font.Gotham,
            Text = "Playing: " .. gameInfo,
            TextColor3 = theme.TextColor,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Welcome message
        local welcomeSection = Create("Frame", {
            Name = "WelcomeSection",
            Parent = homeTab,
            BackgroundColor3 = theme.Button,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 100),
            LayoutOrder = 2
        })
        
        local welcomeCorner = Create("UICorner", {
            Parent = welcomeSection,
            CornerRadius = UDim.new(0, 6)
        })
        
        local welcomeTitle = Create("TextLabel", {
            Name = "WelcomeTitle",
            Parent = welcomeSection,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -20, 0, 30),
            Font = Enum.Font.GothamBold,
            Text = "Welcome to " .. options.Title,
            TextColor3 = theme.TextColor,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local welcomeDescription = Create("TextLabel", {
            Name = "WelcomeDescription",
            Parent = welcomeSection,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 40),
            Size = UDim2.new(1, -20, 0, 50),
            Font = Enum.Font.Gotham,
            Text = "This UI library is designed to be compatible with all Roblox executors. Select a tab from the left menu to begin.",
            TextColor3 = theme.TextColor,
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Update canvas size for home tab
        homeTabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            homeTab.CanvasSize = UDim2.new(0, 0, 0, homeTabListLayout.AbsoluteContentSize.Y + 30)
        end)
    end
    
    -- Make the window draggable
    MakeDraggable(main, topBar)
    
    -- Window functionality
    local minimized = false
    local windowSize = options.Size
    
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        
        if minimized then
            TweenService:Create(main, TWEEN_INFO, {Size = UDim2.new(0, options.Size[1], 0, 36)}):Play()
            
            for _, tab in pairs(contentContainer:GetChildren()) do
                tab.Visible = false
            end
        else
            TweenService:Create(main, TWEEN_INFO, {Size = UDim2.new(0, options.Size[1], 0, options.Size[2])}):Play()
            
            wait(0.25) -- Wait for tween to complete
            
            -- Show the selected tab or home page
            for _, tab in pairs(contentContainer:GetChildren()) do
                if tab.Name == "SelectedTab" then
                    tab.Visible = true
                    return
                end
            end
            
            -- If no tab is selected, show home page
            if homeTab then
                homeTab.Visible = true
            end
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        container:Destroy()
    end)
    
    -- Window object
    local Window = {}
    Window.Container = container
    Window.Main = main
    Window.Tabs = {}
    Window.ActiveTab = nil
    
    -- Create tab function
    function Window:CreateTab(options)
        options = options or {}
        options.Name = options.Name or "Tab"
        options.Icon = options.Icon or "Home"
        
        local iconId = Icons[options.Icon] or options.Icon
        
        -- Tab button
        local tabButton = Create("TextButton", {
            Name = "TabButton",
            Parent = tabsContainer,
            BackgroundColor3 = theme.Button,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 32),
            Font = Enum.Font.Gotham,
            Text = "",
            TextColor3 = theme.TextColor,
            TextSize = 14,
            AutoButtonColor = false
        })
        
        local tabCorner = Create("UICorner", {
            Parent = tabButton,
            CornerRadius = UDim.new(0, 6)
        })
        
        local tabIcon = Create("ImageLabel", {
            Name = "Icon",
            Parent = tabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(0, 16, 0, 16),
            Image = iconId,
            ImageColor3 = theme.TextColor
        })
        
        local tabText = Create("TextLabel", {
            Name = "Text",
            Parent = tabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 32, 0, 0),
            Size = UDim2.new(1, -40, 1, 0),
            Font = Enum.Font.Gotham,
            Text = options.Name,
            TextColor3 = theme.TextColor,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Tab content
        local tabContent = Create("ScrollingFrame", {
            Name = options.Name .. "Tab",
            Parent = contentContainer,
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = theme.TextColor,
            ScrollBarImageTransparency = 0.8,
            Visible = false
        })
        
        local contentListLayout = Create("UIListLayout", {
            Parent = tabContent,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        local contentPadding = Create("UIPadding", {
            Parent = tabContent,
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15)
        })
        
        -- Update the canvas size when content changes
        contentListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentListLayout.AbsoluteContentSize.Y + 30)
        end)
        
        -- Tab selection
        tabButton.MouseButton1Click:Connect(function()
            -- Deselect current tab
            if Window.ActiveTab then
                TweenService:Create(Window.ActiveTab.Button, TWEEN_INFO, {BackgroundColor3 = theme.Button}):Play()
                Window.ActiveTab.Content.Visible = false
                
                if Window.ActiveTab.Content.Name == "SelectedTab" then
                    Window.ActiveTab.Content.Name = Window.ActiveTab.RealName .. "Tab"
                end
            end
            
            -- Hide home page if it exists
            if homeTab then
                homeTab.Visible = false
            end
            
            -- Select new tab
            Window.ActiveTab = {Button = tabButton, Content = tabContent, RealName = options.Name}
            
            TweenService:Create(tabButton, TWEEN_INFO, {BackgroundColor3 = theme.TabToggled}):Play()
            tabContent.Visible = true
            tabContent.Name = "SelectedTab"
        end)
        
        -- Add hover effect
        tabButton.MouseEnter:Connect(function()
            if Window.ActiveTab and Window.ActiveTab.Button == tabButton then return end
            TweenService:Create(tabButton, TWEEN_INFO, {BackgroundColor3 = theme.ButtonHold}):Play()
        end)
        
        tabButton.MouseLeave:Connect(function()
            if Window.ActiveTab and Window.ActiveTab.Button == tabButton then return end
            TweenService:Create(tabButton, TWEEN_INFO, {BackgroundColor3 = theme.Button}):Play()
        end)
        
        -- Tab object
        local Tab = {}
        Tab.Button = tabButton
        Tab.Content = tabContent
        
        -- Add ripple effect
        CreateRipple(tabButton)
        
        -- Section function
        function Tab:CreateSection(title)
            local sectionTitle = title or "Section"
            
            local section = Create("Frame", {
                Name = "Section",
                Parent = self.Content,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 35),
                LayoutOrder = #self.Content:GetChildren()
            })
            
            local sectionLabel = Create("TextLabel", {
                Name = "SectionLabel",
                Parent = section,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 25),
                Font = Enum.Font.GothamBold,
                Text = sectionTitle,
                TextColor3 = theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local sectionLine = Create("Frame", {
                Name = "SectionLine",
                Parent = section,
                BackgroundColor3 = theme.Button,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 25),
                Size = UDim2.new(1, 0, 0, 2)
            })
            
            return section
        end
        
        -- Button function
        function Tab:CreateButton(options)
            options = options or {}
            options.Name = options.Name or "Button"
            options.Description = options.Description or nil
            options.Callback = options.Callback or function() end
            
            local buttonHeight = options.Description and 60 or 36
            
            local button = Create("Frame", {
                Name = "Button",
                Parent = self.Content,
                BackgroundColor3 = theme.Button,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, buttonHeight),
                LayoutOrder = #self.Content:GetChildren()
            })
            
            local buttonCorner = Create("UICorner", {
                Parent = button,
                CornerRadius = UDim.new(0, 6)
            })
            
            local buttonLabel = Create("TextLabel", {
                Name = "ButtonLabel",
                Parent = button,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 36),
                Font = Enum.Font.Gotham,
                Text = options.Name,
                TextColor3 = theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            if options.Description then
                buttonLabel.Size = UDim2.new(1, -20, 0, 25)
                buttonLabel.Position = UDim2.new(0, 10, 0, 5)
                
                local descriptionLabel = Create("TextLabel", {
                    Name = "Description",
                    Parent = button,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = options.Description,
                    TextColor3 = theme.TextColor,
                    TextSize = 12,
                    TextTransparency = 0.3,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            
            local buttonPress = Create("TextButton", {
                Name = "ButtonPress",
                Parent = button,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = "",
                TextColor3 = theme.TextColor,
                TextSize = 14
            })
            
            -- Add ripple effect
            CreateRipple(buttonPress)
            
            -- Button functionality
            buttonPress.MouseButton1Click:Connect(function()
                TweenService:Create(button, SPRING_INFO, {BackgroundColor3 = theme.ButtonHold}):Play()
                options.Callback()
                wait(0.3)
                TweenService:Create(button, TWEEN_INFO, {BackgroundColor3 = theme.Button}):Play()
            end)
            
            buttonPress.MouseEnter:Connect(function()
                TweenService:Create(button, TWEEN_INFO, {BackgroundColor3 = theme.ButtonHold}):Play()
            end)
            
            buttonPress.MouseLeave:Connect(function()
                TweenService:Create(button, TWEEN_INFO, {BackgroundColor3 = theme.Button}):Play()
            end)
            
            return button
        end
        
        -- Toggle function
        function Tab:CreateToggle(options)
            options = options or {}
            options.Name = options.Name or "Toggle"
            options.Description = options.Description or nil
            options.CurrentValue = type(options.CurrentValue) == "boolean" and options.CurrentValue or false
            options.Callback = options.Callback or function() end
            
            local toggleHeight = options.Description and 60 or 36
            
            local toggle = Create("Frame", {
                Name = "Toggle",
                Parent = self.Content,
                BackgroundColor3 = theme.Toggle,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, toggleHeight),
                LayoutOrder = #self.Content:GetChildren()
            })
            
            local toggleCorner = Create("UICorner", {
                Parent = toggle,
                CornerRadius = UDim.new(0, 6)
            })
            
            local toggleLabel = Create("TextLabel", {
                Name = "ToggleLabel",
                Parent = toggle,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -60, 0, 36),
                Font = Enum.Font.Gotham,
                Text = options.Name,
                TextColor3 = theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            if options.Description then
                toggleLabel.Size = UDim2.new(1, -60, 0, 25)
                toggleLabel.Position = UDim2.new(0, 10, 0, 5)
                
                local descriptionLabel = Create("TextLabel", {
                    Name = "Description",
                    Parent = toggle,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -60, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = options.Description,
                    TextColor3 = theme.TextColor,
                    TextSize = 12,
                    TextTransparency = 0.3,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            
            local toggleOuter = Create("Frame", {
                Name = "ToggleOuter",
                Parent = toggle,
                BackgroundColor3 = theme.ToggleFrame,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -50, 0.5, -10),
                Size = UDim2.new(0, 40, 0, 20)
            })
            
            local toggleOuterCorner = Create("UICorner", {
                Parent = toggleOuter,
                CornerRadius = UDim.new(1, 0)
            })
            
            local toggleCircle = Create("Frame", {
                Name = "ToggleCircle",
                Parent = toggleOuter,
                BackgroundColor3 = theme.TextColor,
                BorderSizePixel = 0,
                Position = options.CurrentValue and UDim2.new(1, -19, 0.5, -9) or UDim2.new(0, 1, 0.5, -9),
                Size = UDim2.new(0, 18, 0, 18)
            })
            
            local toggleCircleCorner = Create("UICorner", {
                Parent = toggleCircle,
                CornerRadius = UDim.new(1, 0)
            })
            
            local toggleButton = Create("TextButton", {
                Name = "ToggleButton",
                Parent = toggle,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = "",
                TextColor3 = theme.TextColor,
                TextSize = 14
            })
            
            -- Add ripple effect
            CreateRipple(toggleButton)
            
            -- Set initial state
            if options.CurrentValue then
                toggleOuter.BackgroundColor3 = theme.ToggleToggled
            end
            
            -- Toggle functionality
            local isToggled = options.CurrentValue
            
            toggleButton.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                
                -- Animate toggle
                if isToggled then
                    TweenService:Create(toggleOuter, TWEEN_INFO, {BackgroundColor3 = theme.ToggleToggled}):Play()
                    TweenService:Create(toggleCircle, TWEEN_INFO, {Position = UDim2.new(1, -19, 0.5, -9)}):Play()
                else
                    TweenService:Create(toggleOuter, TWEEN_INFO, {BackgroundColor3 = theme.ToggleFrame}):Play()
                    TweenService:Create(toggleCircle, TWEEN_INFO, {Position = UDim2.new(0, 1, 0.5, -9)}):Play()
                end
                
                options.Callback(isToggled)
            end)
            
            toggleButton.MouseEnter:Connect(function()
                TweenService:Create(toggle, TWEEN_INFO, {BackgroundColor3 = theme.ButtonHold}):Play()
            end)
            
            toggleButton.MouseLeave:Connect(function()
                TweenService:Create(toggle, TWEEN_INFO, {BackgroundColor3 = theme.Toggle}):Play()
            end)
            
            -- Initial callback
            if options.CurrentValue then
                options.Callback(true)
            end
            
            return toggle
        end
        
        -- Slider function
        function Tab:CreateSlider(options)
            options = options or {}
            options.Name = options.Name or "Slider"
            options.Description = options.Description or nil
            options.Min = options.Min or 0
            options.Max = options.Max or 100
            options.Increment = options.Increment or 1
            options.CurrentValue = options.CurrentValue or options.Min
            options.Callback = options.Callback or function() end
            
            -- Ensure valid initial value
            options.CurrentValue = math.clamp(options.CurrentValue, options.Min, options.Max)
            
            local sliderHeight = options.Description and 70 or 50
            
            local slider = Create("Frame", {
                Name = "Slider",
                Parent = self.Content,
                BackgroundColor3 = theme.Slider,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, sliderHeight),
                LayoutOrder = #self.Content:GetChildren()
            })
            
            local sliderCorner = Create("UICorner", {
                Parent = slider,
                CornerRadius = UDim.new(0, 6)
            })
            
            local sliderLabel = Create("TextLabel", {
                Name = "SliderLabel",
                Parent = slider,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 25),
                Font = Enum.Font.Gotham,
                Text = options.Name,
                TextColor3 = theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local sliderValue = Create("TextLabel", {
                Name = "SliderValue",
                Parent = slider,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -40, 0, 0),
                Size = UDim2.new(0, 30, 0, 25),
                Font = Enum.Font.Gotham,
                Text = options.CurrentValue,
                TextColor3 = theme.TextColor,
                TextSize = 14
            })
            
            if options.Description then
                sliderLabel.Position = UDim2.new(0, 10, 0, 5)
                sliderValue.Position = UDim2.new(1, -40, 0, 5)
                
                local descriptionLabel = Create("TextLabel", {
                    Name = "Description",
                    Parent = slider,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = options.Description,
                    TextColor3 = theme.TextColor,
                    TextSize = 12,
                    TextTransparency = 0.3,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            
            local sliderTrack = Create("Frame", {
                Name = "SliderTrack",
                Parent = slider,
                BackgroundColor3 = theme.SliderInner,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, options.Description and 0, options.Description and sliderHeight - 15 or sliderHeight - 35),
                Size = UDim2.new(1, -20, 0, 5)
            })
            
            local sliderTrackCorner = Create("UICorner", {
                Parent = sliderTrack,
                CornerRadius = UDim.new(1, 0)
            })
            
            -- Calculate initial progress
            local initialProgress = (options.CurrentValue - options.Min) / (options.Max - options.Min)
            
            local sliderFill = Create("Frame", {
                Name = "SliderFill",
                Parent = sliderTrack,
                BackgroundColor3 = theme.SliderProgress,
                BorderSizePixel = 0,
                Size = UDim2.new(initialProgress, 0, 1, 0)
            })
            
            local sliderFillCorner = Create("UICorner", {
                Parent = sliderFill,
                CornerRadius = UDim.new(1, 0)
            })
            
            local sliderCircle = Create("Frame", {
                Name = "SliderCircle",
                Parent = sliderFill,
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = theme.TextColor,
                BorderSizePixel = 0,
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, 14, 0, 14)
            })
            
            local sliderCircleCorner = Create("UICorner", {
                Parent = sliderCircle,
                CornerRadius = UDim.new(1, 0)
            })
            
            local sliderButton = Create("TextButton", {
                Name = "SliderButton",
                Parent = slider,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = "",
                TextColor3 = theme.TextColor,
                TextSize = 14
            })
            
            -- Slider functionality
            local function updateSlider(input)
                local sizeX = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                local value = math.floor((((options.Max - options.Min) * sizeX) + options.Min) / options.Increment + 0.5) * options.Increment
                
                value = math.clamp(value, options.Min, options.Max)
                
                sliderValue.Text = value
                sliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
                
                options.Callback(value)
            end
            
            sliderButton.MouseButton1Down:Connect(function()
                local connection
                local released
                
                connection = RunService.RenderStepped:Connect(function()
                    if not released then
                        updateSlider(UserInputService:GetMouseLocation())
                    else
                        connection:Disconnect()
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        released = true
                    end
                end)
            end)
            
            sliderButton.MouseEnter:Connect(function()
                TweenService:Create(slider, TWEEN_INFO, {BackgroundColor3 = theme.ButtonHold}):Play()
            end)
            
            sliderButton.MouseLeave:Connect(function()
                TweenService:Create(slider, TWEEN_INFO, {BackgroundColor3 = theme.Slider}):Play()
            end)
            
            -- Initial callback
            options.Callback(options.CurrentValue)
            
            return slider
        end
        
        -- Dropdown function
        function Tab:CreateDropdown(options)
            options = options or {}
            options.Name = options.Name or "Dropdown"
            options.Description = options.Description or nil
            options.Items = options.Items or {}
            options.CurrentOption = options.CurrentOption or (options.Items[1] or "")
            options.Callback = options.Callback or function() end
            
            local dropdownHeight = options.Description and 60 or 36
            
            local dropdown = Create("Frame", {
                Name = "Dropdown",
                Parent = self.Content,
                BackgroundColor3 = theme.Dropdown,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, dropdownHeight),
                ClipsDescendants = true,
                LayoutOrder = #self.Content:GetChildren()
            })
            
            local dropdownCorner = Create("UICorner", {
                Parent = dropdown,
                CornerRadius = UDim.new(0, 6)
            })
            
            local dropdownLabel = Create("TextLabel", {
                Name = "DropdownLabel",
                Parent = dropdown,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 36),
                Font = Enum.Font.Gotham,
                Text = options.Name,
                TextColor3 = theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            if options.Description then
                dropdownLabel.Size = UDim2.new(1, -20, 0, 25)
                dropdownLabel.Position = UDim2.new(0, 10, 0, 5)
                
                local descriptionLabel = Create("TextLabel", {
                    Name = "Description",
                    Parent = dropdown,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = options.Description,
                    TextColor3 = theme.TextColor,
                    TextSize = 12,
                    TextTransparency = 0.3,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            
            local dropdownDisplay = Create("Frame", {
                Name = "DropdownDisplay",
                Parent = dropdown,
                BackgroundColor3 = theme.Button,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, dropdownHeight + 8),
                Size = UDim2.new(1, -20, 0, 30)
            })
            
            local dropdownDisplayCorner = Create("UICorner", {
                Parent = dropdownDisplay,
                CornerRadius = UDim.new(0, 6)
            })
            
            local selectedOption = Create("TextLabel", {
                Name = "SelectedOption",
                Parent = dropdownDisplay,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -40, 1, 0),
                Font = Enum.Font.Gotham,
                Text = options.CurrentOption,
                TextColor3 = theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local dropdownArrow = Create("ImageLabel", {
                Name = "DropdownArrow",
                Parent = dropdownDisplay,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -25, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Image = Icons.Arrow,
                ImageColor3 = theme.TextColor,
                Rotation = 90
            })
            
            local optionsFrame = Create("Frame", {
                Name = "OptionsFrame",
                Parent = dropdown,
                BackgroundColor3 = theme.Button,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, dropdownHeight + 46),
                Size = UDim2.new(1, -20, 0, 0),
                Visible = false,
                ClipsDescendants = true
            })
            
            local optionsFrameCorner = Create("UICorner", {
                Parent = optionsFrame,
                CornerRadius = UDim.new(0, 6)
            })
            
            local optionsList = Create("ScrollingFrame", {
                Name = "OptionsList",
                Parent = optionsFrame,
                Active = true,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = theme.TextColor,
                ScrollBarImageTransparency = 0.8
            })
            
            local optionsListLayout = Create("UIListLayout", {
                Parent = optionsList,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            })
            
            local optionsListPadding = Create("UIPadding", {
                Parent = optionsList,
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5),
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5)
            })
            
            local dropdownButton = Create("TextButton", {
                Name = "DropdownButton",
                Parent = dropdown,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, dropdownHeight),
                Font = Enum.Font.Gotham,
                Text = "",
                TextColor3 = theme.TextColor,
                TextSize = 14
            })
            
            -- Add ripple effect
            CreateRipple(dropdownButton)
            
            -- Function to refresh options
            local function refreshOptions(items)
                -- Clear existing options
                for _, child in pairs(optionsList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                -- Add options
                for i, item in pairs(items) do
                    local option = Create("TextButton", {
                        Name = "Option",
                        Parent = optionsList,
                        BackgroundColor3 = theme.DropdownItem,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 30),
                        Font = Enum.Font.Gotham,
                        Text = "",
                        TextColor3 = theme.TextColor,
                        TextSize = 14,
                        AutoButtonColor = false
                    })
                    
                    local optionCorner = Create("UICorner", {
                        Parent = option,
                        CornerRadius = UDim.new(0, 6)
                    })
                    
                    local optionText = Create("TextLabel", {
                        Name = "OptionText",
                        Parent = option,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -20, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = tostring(item),
                        TextColor3 = theme.TextColor,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    
                    -- Add hover effect
                    option.MouseEnter:Connect(function()
                        TweenService:Create(option, TWEEN_INFO, {BackgroundColor3 = theme.ButtonHold}):Play()
                    end)
                    
                    option.MouseLeave:Connect(function()
                        TweenService:Create(option, TWEEN_INFO, {BackgroundColor3 = theme.DropdownItem}):Play()
                    end)
                    
                    -- Option selection
                    option.MouseButton1Click:Connect(function()
                        selectedOption.Text = tostring(item)
                        options.Callback(tostring(item))
                        
                        -- Close dropdown
                        TweenService:Create(dropdownArrow, TWEEN_INFO, {Rotation = 90}):Play()
                        optionsFrame.Visible = false
                        TweenService:Create(dropdown, TWEEN_INFO, {Size = UDim2.new(1, 0, 0, dropdownHeight)}):Play()
                    end)
                    
                    -- Add ripple effect to option
                    CreateRipple(option)
                end
                
                -- Update canvas size
                optionsList.CanvasSize = UDim2.new(0, 0, 0, optionsListLayout.AbsoluteContentSize.Y + 10)
            end
            
            -- Refresh initial options
            refreshOptions(options.Items)
            
            -- Dropdown toggle
            local dropdownOpen = false
            
            dropdownButton.MouseButton1Click:Connect(function()
                dropdownOpen = not dropdownOpen
                
                if dropdownOpen then
                    -- Calculate the height based on number of items (max 150)
                    local listHeight = math.min(optionsListLayout.AbsoluteContentSize.Y + 10, 150)
                    
                    -- Show dropdown
                    optionsFrame.Visible = true
                    TweenService:Create(dropdownArrow, TWEEN_INFO, {Rotation = 270}):Play()
                    TweenService:Create(optionsFrame, TWEEN_INFO, {Size = UDim2.new(1, -20, 0, listHeight)}):Play()
                    TweenService:Create(dropdown, TWEEN_INFO, {Size = UDim2.new(1, 0, 0, dropdownHeight + 46 + listHeight)}):Play()
                else
                    -- Hide dropdown
                    TweenService:Create(dropdownArrow, TWEEN_INFO, {Rotation = 90}):Play()
                    TweenService:Create(dropdown, TWEEN_INFO, {Size = UDim2.new(1, 0, 0, dropdownHeight)}):Play()
                    
                    wait(0.25) -- Wait for animation to complete
                    optionsFrame.Visible = false
                end
            end)
            
            dropdownButton.MouseEnter:Connect(function()
                TweenService:Create(dropdown, TWEEN_INFO, {BackgroundColor3 = theme.ButtonHold}):Play()
            end)
            
            dropdownButton.MouseLeave:Connect(function()
                TweenService:Create(dropdown, TWEEN_INFO, {BackgroundColor3 = theme.Dropdown}):Play()
            end)
            
            -- Dropdown object with methods
            local dropdownObject = {}
            
            function dropdownObject:Refresh(items)
                options.Items = items
                refreshOptions(items)
            end
            
            function dropdownObject:SetValue(value)
                selectedOption.Text = value
                options.Callback(value)
            end
            
            -- Initial callback
            options.Callback(options.CurrentOption)
            
            return dropdown, dropdownObject
        end
        
        -- TextBox function
        function Tab:CreateTextBox(options)
            options = options or {}
            options.Name = options.Name or "Input"
            options.Description = options.Description or nil
            options.Placeholder = options.Placeholder or "Type something..."
            options.CurrentValue = options.CurrentValue or ""
            options.Callback = options.Callback or function() end
            
            local textBoxHeight = options.Description and 60 or 36
            
            local textBox = Create("Frame", {
                Name = "TextBox",
                Parent = self.Content,
                BackgroundColor3 = theme.Input,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, textBoxHeight),
                LayoutOrder = #self.Content:GetChildren()
            })
            
            local textBoxCorner = Create("UICorner", {
                Parent = textBox,
                CornerRadius = UDim.new(0, 6)
            })
            
            local textBoxLabel = Create("TextLabel", {
                Name = "TextBoxLabel",
                Parent = textBox,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 36),
                Font = Enum.Font.Gotham,
                Text = options.Name,
                TextColor3 = theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            if options.Description then
                textBoxLabel.Size = UDim2.new(1, -20, 0, 25)
                textBoxLabel.Position = UDim2.new(0, 10, 0, 5)
                
                local descriptionLabel = Create("TextLabel", {
                    Name = "Description",
                    Parent = textBox,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = options.Description,
                    TextColor3 = theme.TextColor,
                    TextSize = 12,
                    TextTransparency = 0.3,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            
            local textBoxContainer = Create("Frame", {
                Name = "TextBoxContainer",
                Parent = textBox,
                BackgroundColor3 = theme.Button,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, textBoxHeight + 8),
                Size = UDim2.new(1, -20, 0, 30)
            })
            
            local textBoxContainerCorner = Create("UICorner", {
                Parent = textBoxContainer,
                CornerRadius = UDim.new(0, 6)
            })
            
            local textInput = Create("TextBox", {
                Name = "TextInput",
                Parent = textBoxContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = Enum.Font.Gotham,
                PlaceholderText = options.Placeholder,
                Text = options.CurrentValue,
                TextColor3 = theme.TextColor,
                TextSize = 14,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false
            })
            
            local textButton = Create("TextButton", {
                Name = "TextButton",
                Parent = textBox,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, textBoxHeight),
                Font = Enum.Font.Gotham,
                Text = "",
                TextColor3 = theme.TextColor,
                TextSize = 14
            })
            
            -- Add ripple effect
            CreateRipple(textButton)
            
            -- Toggle text input visibility
            textButton.MouseButton1Click:Connect(function()
                if textBox.Size == UDim2.new(1, 0, 0, textBoxHeight) then
                    TweenService:Create(textBox, TWEEN_INFO, {Size = UDim2.new(1, 0, 0, textBoxHeight + 46)}):Play()
                    textBoxContainer.Visible = true
                    textInput:CaptureFocus()
                else
                    TweenService:Create(textBox, TWEEN_INFO, {Size = UDim2.new(1, 0, 0, textBoxHeight)}):Play()
                    wait(0.25)
                    textBoxContainer.Visible = false
                end
            end)
            
            textButton.MouseEnter:Connect(function()
                TweenService:Create(textBox, TWEEN_INFO, {BackgroundColor3 = theme.ButtonHold}):Play()
            end)
            
            textButton.MouseLeave:Connect(function()
                TweenService:Create(textBox, TWEEN_INFO, {BackgroundColor3 = theme.Input}):Play()
            end)
            
            -- TextBox functionality
            textInput.FocusLost:Connect(function(enterPressed)
                options.Callback(textInput.Text)
                
                if enterPressed then
                    TweenService:Create(textBox, TWEEN_INFO, {Size = UDim2.new(1, 0, 0, textBoxHeight)}):Play()
                    wait(0.25)
                    textBoxContainer.Visible = false
                end
            end)
            
            -- Initially hide the text box container
            textBoxContainer.Visible = false
            
            -- Initial callback
            if options.CurrentValue ~= "" then
                options.Callback(options.CurrentValue)
            end
            
            return textBox
        end
        
        -- ColorPicker function
        function Tab:CreateColorPicker(options)
            options = options or {}
            options.Name = options.Name or "Color Picker"
            options.Description = options.Description or nil
            options.CurrentColor = options.CurrentColor or Color3.fromRGB(255, 255, 255)
            options.Callback = options.Callback or function() end
            
            local colorPickerHeight = options.Description and 60 or 36
            
            local colorPicker = Create("Frame", {
                Name = "ColorPicker",
                Parent = self.Content,
                BackgroundColor3 = theme.ColorPicker,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, colorPickerHeight),
                ClipsDescendants = true,
                LayoutOrder = #self.Content:GetChildren()
            })
            
            local colorPickerCorner = Create("UICorner", {
                Parent = colorPicker,
                CornerRadius = UDim.new(0, 6)
            })
            
            local colorPickerLabel = Create("TextLabel", {
                Name = "ColorPickerLabel",
                Parent = colorPicker,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -60, 0, 36),
                Font = Enum.Font.Gotham,
                Text = options.Name,
                TextColor3 = theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            if options.Description then
                colorPickerLabel.Size = UDim2.new(1, -60, 0, 25)
                colorPickerLabel.Position = UDim2.new(0, 10, 0, 5)
                
                local descriptionLabel = Create("TextLabel", {
                    Name = "Description",
                    Parent = colorPicker,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -60, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = options.Description,
                    TextColor3 = theme.TextColor,
                    TextSize = 12,
                    TextTransparency = 0.3,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            
            local colorDisplay = Create("Frame", {
                Name = "ColorDisplay",
                Parent = colorPicker,
                BackgroundColor3 = options.CurrentColor,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -50, 0.5, -10),
                Size = UDim2.new(0, 40, 0, 20)
            })
            
            local colorDisplayCorner = Create("UICorner", {
                Parent = colorDisplay,
                CornerRadius = UDim.new(0, 4)
            })
            
            local colorPickerButton = Create("TextButton", {
                Name = "ColorPickerButton",
                Parent = colorPicker,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, colorPickerHeight),
                Font = Enum.Font.Gotham,
                Text = "",
                TextColor3 = theme.TextColor,
                TextSize = 14
            })
            
            -- Add ripple effect
            CreateRipple(colorPickerButton)
            
            -- Color picker UI
            local colorPickerUI = Create("Frame", {
                Name = "ColorPickerUI",
                Parent = colorPicker,
                BackgroundColor3 = theme.Button,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, colorPickerHeight + 8),
                Size = UDim2.new(1, -20, 0, 180),
                Visible = false
            })
            
            local colorPickerUICorner = Create("UICorner", {
                Parent = colorPickerUI,
                CornerRadius = UDim.new(0, 6)
            })
            
            -- Color picker components
            local h, s, v = Color3.toHSV(options.CurrentColor)
            
            -- Hue slider
            local hueFrame = Create("Frame", {
                Name = "HueFrame",
                Parent = colorPickerUI,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 10),
                Size = UDim2.new(1, -20, 0, 20)
            })
            
            local hueFrameCorner = Create("UICorner", {
                Parent = hueFrame,
                CornerRadius = UDim.new(0, 4)
            })
            
            local hueGradient = Create("UIGradient", {
                Parent = hueFrame,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                })
            })
            
            local huePicker = Create("Frame", {
                Name = "HuePicker",
                Parent = hueFrame,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = UDim2.new(h, 0, 0, 0),
                Size = UDim2.new(0, 5, 1, 0)
            })
            
            local huePickerCorner = Create("UICorner", {
                Parent = huePicker,
                CornerRadius = UDim.new(0, 2)
            })
            
            -- Saturation/Value picker
            local saturationFrame = Create("Frame", {
                Name = "SaturationFrame",
                Parent = colorPickerUI,
                BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 40),
                Size = UDim2.new(1, -20, 0, 120)
            })
            
            local saturationFrameCorner = Create("UICorner", {
                Parent = saturationFrame,
                CornerRadius = UDim.new(0, 4)
            })
            
            local saturationGradient = Create("UIGradient", {
                Parent = saturationFrame,
                Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0)),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                }),
                Rotation = 90
            })
            
            local brightnessGradient = Create("UIGradient", {
                Parent = saturationFrame,
                Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0)),
                Transparency = NumberSequence.new(0)
            })
            
            local saturationPicker = Create("Frame", {
                Name = "SaturationPicker",
                Parent = saturationFrame,
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = UDim2.new(s, 0, 1 - v, 0),
                Size = UDim2.new(0, 10, 0, 10)
            })
            
            local saturationPickerCorner = Create("UICorner", {
                Parent = saturationPicker,
                CornerRadius = UDim.new(1, 0)
            })
            
            -- RGB display
            local rgbFrame = Create("Frame", {
                Name = "RGBDisplay",
                Parent = colorPickerUI,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 170),
                Size = UDim2.new(1, -20, 0, 20)
            })
            
            local rgbText = Create("TextLabel", {
                Name = "RGBText",
                Parent = rgbFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = "RGB: " .. math.floor(options.CurrentColor.R * 255) .. ", " .. math.floor(options.CurrentColor.G * 255) .. ", " .. math.floor(options.CurrentColor.B * 255),
                TextColor3 = theme.TextColor,
                TextSize = 12
            })
            
            -- Color picker functions
            local function updateHue(hueX)
                local newHue = math.clamp(hueX, 0, 1)
                h = newHue
                huePicker.Position = UDim2.new(h, 0, 0, 0)
                saturationFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                updateColor()
            end
            
            local function updateSaturationValue(satX, valY)
                local newSat = math.clamp(satX, 0, 1)
                local newVal = math.clamp(1 - valY, 0, 1)
                s = newSat
                v = newVal
                saturationPicker.Position = UDim2.new(s, 0, 1 - v, 0)
                updateColor()
            end
            
            local function updateColor()
                local newColor = Color3.fromHSV(h, s, v)
                colorDisplay.BackgroundColor3 = newColor
                rgbText.Text = "RGB: " .. math.floor(newColor.R * 255) .. ", " .. math.floor(newColor.G * 255) .. ", " .. math.floor(newColor.B * 255)
                options.Callback(newColor)
            end
            
            -- Hue slider interaction
            hueFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local hueX = (input.Position.X - hueFrame.AbsolutePosition.X) / hueFrame.AbsoluteSize.X
                    updateHue(hueX)
                    
                    local connection
                    connection = UserInputService.InputChanged:Connect(function(newInput)
                        if newInput.UserInputType == Enum.UserInputType.MouseMovement or newInput.UserInputType == Enum.UserInputType.Touch then
                            local newHueX = (newInput.Position.X - hueFrame.AbsolutePosition.X) / hueFrame.AbsoluteSize.X
                            updateHue(newHueX)
                        end
                    end)
                    
                    UserInputService.InputEnded:Connect(function(newInput)
                        if newInput.UserInputType == Enum.UserInputType.MouseButton1 or newInput.UserInputType == Enum.UserInputType.Touch then
                            if connection then
                                connection:Disconnect()
                            end
                        end
                    end)
                end
            end)
            
            -- Saturation/Value picker interaction
            saturationFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local satX = (input.Position.X - saturationFrame.AbsolutePosition.X) / saturationFrame.AbsoluteSize.X
                    local valY = (input.Position.Y - saturationFrame.AbsolutePosition.Y) / saturationFrame.AbsoluteSize.Y
                    updateSaturationValue(satX, valY)
                    
                    local connection
                    connection = UserInputService.InputChanged:Connect(function(newInput)
                        if newInput.UserInputType == Enum.UserInputType.MouseMovement or newInput.UserInputType == Enum.UserInputType.Touch then
                            local newSatX = (newInput.Position.X - saturationFrame.AbsolutePosition.X) / saturationFrame.AbsoluteSize.X
                            local newValY = (newInput.Position.Y - saturationFrame.AbsolutePosition.Y) / saturationFrame.AbsoluteSize.Y
                            updateSaturationValue(newSatX, newValY)
                        end
                    end)
                    
                    UserInputService.InputEnded:Connect(function(newInput)
                        if newInput.UserInputType == Enum.UserInputType.MouseButton1 or newInput.UserInputType == Enum.UserInputType.Touch then
                            if connection then
                                connection:Disconnect()
                            end
                        end
                    end)
                end
            end)
            
            -- Toggle color picker visibility
            local pickerOpen = false
            
            colorPickerButton.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                
                if pickerOpen then
                    -- Show color picker
                    colorPickerUI.Visible = true
                    TweenService:Create(colorPicker, TWEEN_INFO, {Size = UDim2.new(1, 0, 0, colorPickerHeight + 196)}):Play()
                else
                    -- Hide color picker
                    TweenService:Create(colorPicker, TWEEN_INFO, {Size = UDim2.new(1, 0, 0, colorPickerHeight)}):Play()
                    wait(0.25)
                    colorPickerUI.Visible = false
                end
            end)
            
            colorPickerButton.MouseEnter:Connect(function()
                TweenService:Create(colorPicker, TWEEN_INFO, {BackgroundColor3 = theme.ButtonHold}):Play()
            end)
            
            colorPickerButton.MouseLeave:Connect(function()
                TweenService:Create(colorPicker, TWEEN_INFO, {BackgroundColor3 = theme.ColorPicker}):Play()
            end)
            
            -- Initial callback
            options.Callback(options.CurrentColor)
            
            return colorPicker
        end
        
        -- Label function
        function Tab:CreateLabel(options)
            options = options or {}
            options.Text = options.Text or "Label"
            options.Color = options.Color or theme.TextColor
            options.Size = options.Size or 14
            
            local label = Create("Frame", {
                Name = "Label",
                Parent = self.Content,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 24),
                LayoutOrder = #self.Content:GetChildren()
            })
            
            local labelText = Create("TextLabel", {
                Name = "LabelText",
                Parent = label,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = options.Text,
                TextColor3 = options.Color,
                TextSize = options.Size,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            return label, labelText
        end
        
        -- Paragraph function
        function Tab:CreateParagraph(options)
            options = options or {}
            options.Title = options.Title or "Title"
            options.Content = options.Content or "Content"
            
            local paragraph = Create("Frame", {
                Name = "Paragraph",
                Parent = self.Content,
                BackgroundColor3 = theme.Button,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = #self.Content:GetChildren()
            })
            
            local paragraphCorner = Create("UICorner", {
                Parent = paragraph,
                CornerRadius = UDim.new(0, 6)
            })
            
            local title = Create("TextLabel", {
                Name = "Title",
                Parent = paragraph,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 10),
                Size = UDim2.new(1, -20, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = options.Title,
                TextColor3 = theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local content = Create("TextLabel", {
                Name = "Content",
                Parent = paragraph,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 30),
                Size = UDim2.new(1, -20, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Font = Enum.Font.Gotham,
                Text = options.Content,
                TextColor3 = theme.TextColor,
                TextSize = 14,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local padding = Create("UIPadding", {
                Parent = paragraph,
                PaddingBottom = UDim.new(0, 10)
            })
            
            return paragraph
        end
        
        -- Return the tab object
        return Tab
    end
    
    -- Add to window collection
    table.insert(self.Windows, Window)
    
    -- Return window object
    return Window
end

-- Return the library
return TBD
