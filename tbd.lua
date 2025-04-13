--[[
    TBD UI Library V9
    Universal Edition - Compatible with all Roblox executors
    
    Features:
    - Universal compatibility across all executors/injectors
    - Fallback mechanisms for executor-specific functions
    - Optimized loading process
    - Enhanced error handling
    - Modern, HoHo-inspired design
    - Complete component library
    - Customizable themes
    - Animated hover effects
    - Home page with player info
    
    Version: 2.0.0-V9
]]

-- Main Library Table
local TBD = {}
TBD.Version = "2.0.0-V9"
TBD.Windows = {}
TBD.Toggles = {}
TBD.SelectedTheme = nil
TBD.Settings = {
    MinimizeKey = Enum.KeyCode.RightControl,
    HideKey = Enum.KeyCode.RightAlt,
    MinimizeKeybind = nil,
    HideKeybind = nil,
}

-- Services with fallback for different executor environments
local Services = {
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    TextService = game:GetService("TextService"),
    Players = game:GetService("Players"),
    HttpService = (game:GetService("HttpService") or {JSONEncode = function() end, JSONDecode = function() end}),
}

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local CORNER_RADIUS = UDim.new(0, 6)
local FONT = Enum.Font.Gotham
local TEXT_SIZE = 14
local ICONS = {
    Home = "rbxassetid://7733960981",
    Settings = "rbxassetid://7734053495",
    Script = "rbxassetid://7733978098",
    Credit = "rbxassetid://7734000121",
    Discord = "rbxassetid://7734030487",
    Globe = "rbxassetid://7734063576",
    Exit = "rbxassetid://7734234941",
    Minimize = "rbxassetid://7734071918",
    Notification = "rbxassetid://7734062485",
    Arrow = "rbxassetid://7734201216",
}

-- Fallback for CoreGui access (which varies by executor)
local function getScreenGuiParent()
    local success, result = pcall(function()
        return game:GetService("CoreGui")
    end)
    
    if success then
        return result
    end
    
    success, result = pcall(function()
        return game.CoreGui
    end)
    
    if success then
        return result
    end
    
    return game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Fallback for safe insets (varies by executor)
local function getSafeInsets()
    local success, result = pcall(function()
        return game:GetService("GuiService"):GetSafeInsets()
    end)
    
    if success then
        return result
    end
    
    return {
        Top = 0,
        Bottom = 0, 
        Left = 0,
        Right = 0
    }
end

-- Function to create instances with properties
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

-- Get player (with fallback)
local function getPlayer()
    return Services.Players.LocalPlayer or {
        Name = "Player",
        DisplayName = "Player",
        GetThumbnailAsync = function() return "rbxassetid://7733978098" end,
    }
end

-- Get text size (with fallback)
local function getTextSize(text, size, font, frameSize)
    local success, result = pcall(function()
        return Services.TextService:GetTextSize(text, size, font, frameSize)
    end)
    
    if success then
        return result
    end
    
    -- Fallback approximation
    return Vector2.new(#text * (size * 0.5), size * 1.5)
end

-- Themes with HoHo-inspired design
TBD.Themes = {
    Default = {
        Primary = Color3.fromRGB(40, 40, 45),
        Secondary = Color3.fromRGB(30, 30, 35),
        Background = Color3.fromRGB(25, 25, 30),
        TextPrimary = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(190, 190, 190),
        Accent = Color3.fromRGB(0, 120, 255),
        DarkAccent = Color3.fromRGB(0, 90, 210),
        Success = Color3.fromRGB(40, 180, 100),
        Warning = Color3.fromRGB(255, 170, 30),
        Error = Color3.fromRGB(255, 60, 50),
    },
    HoHo = {
        Primary = Color3.fromRGB(25, 25, 30),
        Secondary = Color3.fromRGB(20, 20, 25),
        Background = Color3.fromRGB(15, 15, 20),
        TextPrimary = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(190, 190, 190),
        Accent = Color3.fromRGB(255, 75, 75),
        DarkAccent = Color3.fromRGB(200, 60, 60),
        Success = Color3.fromRGB(40, 180, 100),
        Warning = Color3.fromRGB(255, 170, 30),
        Error = Color3.fromRGB(255, 60, 50),
    },
    Midnight = {
        Primary = Color3.fromRGB(25, 30, 45),
        Secondary = Color3.fromRGB(20, 25, 40),
        Background = Color3.fromRGB(15, 20, 35),
        TextPrimary = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(190, 190, 190),
        Accent = Color3.fromRGB(90, 120, 255),
        DarkAccent = Color3.fromRGB(70, 90, 210),
        Success = Color3.fromRGB(40, 180, 100),
        Warning = Color3.fromRGB(255, 170, 30),
        Error = Color3.fromRGB(255, 60, 50),
    },
    Neon = {
        Primary = Color3.fromRGB(20, 20, 25),
        Secondary = Color3.fromRGB(15, 15, 20),
        Background = Color3.fromRGB(10, 10, 15),
        TextPrimary = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(190, 190, 190),
        Accent = Color3.fromRGB(110, 255, 110),
        DarkAccent = Color3.fromRGB(90, 210, 90),
        Success = Color3.fromRGB(40, 180, 100),
        Warning = Color3.fromRGB(255, 170, 30),
        Error = Color3.fromRGB(255, 60, 50),
    },
    Aqua = {
        Primary = Color3.fromRGB(25, 35, 45),
        Secondary = Color3.fromRGB(20, 30, 40),
        Background = Color3.fromRGB(15, 25, 35),
        TextPrimary = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(190, 190, 190),
        Accent = Color3.fromRGB(60, 180, 210),
        DarkAccent = Color3.fromRGB(50, 150, 180),
        Success = Color3.fromRGB(40, 180, 100),
        Warning = Color3.fromRGB(255, 170, 30),
        Error = Color3.fromRGB(255, 60, 50),
    }
}

-- Custom theme function
function TBD:CustomTheme(theme)
    self.Themes.Custom = theme
    return theme
end

-- Apply theme to elements
function TBD:ApplyTheme(objects)
    local theme = self.SelectedTheme
    
    for object, properties in pairs(objects) do
        if object and typeof(object) == "Instance" then
            for property, value in pairs(properties) do
                local color = theme[value]
                if color then
                    pcall(function()
                        object[property] = color
                    end)
                end
            end
        end
    end
end

-- Create notification
function TBD:Notification(options)
    options = options or {}
    options.Title = options.Title or "Notification"
    options.Message = options.Message or "This is a notification"
    options.Duration = options.Duration or 5
    options.Type = options.Type or "Info"
    
    local theme = self.SelectedTheme
    local typeColors = {
        Success = theme.Success,
        Error = theme.Error,
        Warning = theme.Warning,
        Info = theme.Accent
    }
    
    local NotificationHolder = getScreenGuiParent():FindFirstChild("NotificationHolder")
    if not NotificationHolder then
        NotificationHolder = Create("ScreenGui", {
            Name = "NotificationHolder",
            Parent = getScreenGuiParent(),
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            ResetOnSpawn = false
        })
        
        local UIListLayout = Create("UIListLayout", {
            Parent = NotificationHolder,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        Create("UIPadding", {
            Parent = NotificationHolder,
            PaddingBottom = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10)
        })
    end
    
    local Notification = Create("Frame", {
        Name = "Notification",
        Parent = NotificationHolder,
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 1, 0),
        Size = UDim2.new(0, 300, 0, 0),
        ClipsDescendants = true,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    local UICorner = Create("UICorner", {
        Parent = Notification,
        CornerRadius = CORNER_RADIUS
    })
    
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = Notification,
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30)
    })
    
    local UICorner_2 = Create("UICorner", {
        Parent = TopBar,
        CornerRadius = CORNER_RADIUS
    })
    
    local TopBarBottom = Create("Frame", {
        Name = "TopBarBottom",
        Parent = TopBar,
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0)
    })
    
    local Icon = Create("ImageLabel", {
        Name = "Icon",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0, 5),
        Size = UDim2.new(0, 20, 0, 20),
        Image = ICONS.Notification,
        ImageColor3 = typeColors[options.Type]
    })
    
    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 30, 0, 0),
        Size = UDim2.new(1, -35, 1, 0),
        Font = FONT,
        Text = options.Title,
        TextColor3 = theme.TextPrimary,
        TextSize = TEXT_SIZE,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local Content = Create("Frame", {
        Name = "Content",
        Parent = Notification,
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    local Message = Create("TextLabel", {
        Name = "Message",
        Parent = Content,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0, 5),
        Size = UDim2.new(1, -10, 0, 0),
        Font = FONT,
        Text = options.Message,
        TextColor3 = theme.TextSecondary,
        TextSize = TEXT_SIZE - 1,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    local UIPadding = Create("UIPadding", {
        Parent = Content,
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        PaddingTop = UDim.new(0, 5)
    })
    
    -- Animate in
    Notification.Position = UDim2.new(1, 330, 1, 0)
    local tweenIn = Services.TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, 0, 1, 0)})
    tweenIn:Play()
    
    -- Close timer
    local closeTime = options.Duration
    spawn(function()
        for i = closeTime, 0, -1 do
            wait(1)
        end
        
        local tweenOut = Services.TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 330, 1, 0)})
        tweenOut:Play()
        tweenOut.Completed:Wait()
        Notification:Destroy()
    end)
    
    return Notification
end

-- Make a frame draggable
local function MakeDraggable(frame, handle)
    local dragToggle, dragInput, dragStart, dragPos, startPos
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        Services.TweenService:Create(frame, TweenInfo.new(0.1), {Position = position}):Play()
    end
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    Services.UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            updateInput(input)
        end
    end)
end

-- Create window
function TBD:CreateWindow(options)
    -- Parse options with defaults
    options = options or {}
    options.Title = options.Title or "TBD UI Library"
    options.Subtitle = options.Subtitle or "V9"
    options.Theme = options.Theme or "HoHo"
    options.Size = options.Size or {600, 500}
    options.LoadingEnabled = options.LoadingEnabled ~= nil and options.LoadingEnabled or false
    options.ShowHomePage = options.ShowHomePage ~= nil and options.ShowHomePage or true
    
    self.SelectedTheme = self.Themes[options.Theme] or self.Themes.HoHo
    
    -- Create container
    local Container = Create("ScreenGui", {
        Name = "TBDLibraryV9",
        Parent = getScreenGuiParent(),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Create IgnoreGuiInset if supported
    pcall(function()
        Container.IgnoreGuiInset = true
    end)
    
    -- Create main window
    local Window = Create("Frame", {
        Name = "Window",
        Parent = Container,
        BackgroundColor3 = self.SelectedTheme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -(options.Size[1] / 2), 0.5, -(options.Size[2] / 2)),
        Size = UDim2.new(0, options.Size[1], 0, options.Size[2]),
        Visible = not options.LoadingEnabled,
        ClipsDescendants = true
    })
    
    local UICorner = Create("UICorner", {
        Parent = Window,
        CornerRadius = CORNER_RADIUS
    })
    
    -- Shadow (soft drop shadow)
    local WindowShadow = Create("ImageLabel", {
        Name = "WindowShadow",
        Parent = Window,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 0
    })
    
    -- Navigation sidebar
    local SideNav = Create("Frame", {
        Name = "SideNav",
        Parent = Window,
        BackgroundColor3 = self.SelectedTheme.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 150, 1, 0)
    })
    
    local SideNavCorner = Create("UICorner", {
        Parent = SideNav,
        CornerRadius = CORNER_RADIUS
    })
    
    local SideNavCornerFix = Create("Frame", {
        Name = "SideNavCornerFix",
        Parent = SideNav,
        BackgroundColor3 = self.SelectedTheme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -5, 0, 0),
        Size = UDim2.new(0, 5, 1, 0)
    })
    
    -- Title and subtitle
    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = SideNav,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 15),
        Size = UDim2.new(1, -20, 0, 20),
        Font = FONT,
        Text = options.Title,
        TextColor3 = self.SelectedTheme.TextPrimary,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local Subtitle = Create("TextLabel", {
        Name = "Subtitle",
        Parent = SideNav,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 35),
        Size = UDim2.new(1, -20, 0, 20),
        Font = FONT,
        Text = options.Subtitle,
        TextColor3 = self.SelectedTheme.TextSecondary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Divider
    local Divider = Create("Frame", {
        Name = "Divider",
        Parent = SideNav,
        BackgroundColor3 = self.SelectedTheme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 60),
        Size = UDim2.new(1, -20, 0, 1)
    })
    
    -- Tabs Container
    local TabsContainer = Create("ScrollingFrame", {
        Name = "TabsContainer",
        Parent = SideNav,
        Active = true,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 70),
        Size = UDim2.new(1, 0, 1, -115),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.SelectedTheme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    local TabsListLayout = Create("UIListLayout", {
        Parent = TabsContainer,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    local TabsPadding = Create("UIPadding", {
        Parent = TabsContainer,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5)
    })
    
    -- Content container
    local Content = Create("Frame", {
        Name = "Content",
        Parent = Window,
        BackgroundColor3 = self.SelectedTheme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 150, 0, 0),
        Size = UDim2.new(1, -150, 1, 0)
    })
    
    -- Top Bar for Content
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = Content,
        BackgroundColor3 = self.SelectedTheme.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40)
    })
    
    local TopBarCorner = Create("UICorner", {
        Parent = TopBar,
        CornerRadius = UDim.new(0, 6)
    })
    
    local TopBarCornerFix = Create("Frame", {
        Name = "TopBarCornerFix",
        Parent = TopBar,
        BackgroundColor3 = self.SelectedTheme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -5),
        Size = UDim2.new(1, 0, 0, 5)
    })
    
    -- Add minimize and close buttons
    local CloseButton = Create("ImageButton", {
        Name = "CloseButton",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -35, 0, 5),
        Size = UDim2.new(0, 30, 0, 30),
        Image = ICONS.Exit,
        ImageColor3 = self.SelectedTheme.TextPrimary,
        ScaleType = Enum.ScaleType.Fit,
        SliceCenter = Rect.new(0, 0, 0, 0)
    })
    
    local MinimizeButton = Create("ImageButton", {
        Name = "MinimizeButton",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -65, 0, 5),
        Size = UDim2.new(0, 30, 0, 30),
        Image = ICONS.Minimize,
        ImageColor3 = self.SelectedTheme.TextPrimary,
        ScaleType = Enum.ScaleType.Fit,
        SliceCenter = Rect.new(0, 0, 0, 0)
    })
    
    -- Tab content container
    local TabContentContainer = Create("Frame", {
        Name = "TabContentContainer",
        Parent = Content,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 1, -40)
    })
    
    -- Home page
    local HomePage = nil
    if options.ShowHomePage then
        HomePage = Create("Frame", {
            Name = "HomePage",
            Parent = TabContentContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = true
        })
        
        local HomePageLayout = Create("UIListLayout", {
            Parent = HomePage,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        local HomePagePadding = Create("UIPadding", {
            Parent = HomePage,
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15)
        })
        
        -- Player info
        local PlayerInfo = Create("Frame", {
            Name = "PlayerInfo",
            Parent = HomePage,
            BackgroundColor3 = self.SelectedTheme.Primary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 100),
            LayoutOrder = 1
        })
        
        local PlayerInfoCorner = Create("UICorner", {
            Parent = PlayerInfo,
            CornerRadius = CORNER_RADIUS
        })
        
        -- Get player information
        local player = getPlayer()
        local playerName = player.Name or "Player"
        local displayName = player.DisplayName or playerName
        
        -- Try to get player thumbnail (with fallback)
        local thumbnailUrl = "rbxassetid://7733978098" -- Default fallback
        pcall(function()
            if player and player:IsA("Player") then
                pcall(function()
                    thumbnailUrl = Services.Players:GetUserThumbnailAsync(
                        player.UserId,
                        Enum.ThumbnailType.HeadShot,
                        Enum.ThumbnailSize.Size100x100
                    )
                end)
            end
        end)
        
        local PlayerAvatar = Create("ImageLabel", {
            Name = "PlayerAvatar",
            Parent = PlayerInfo,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(0, 80, 0, 80),
            Image = thumbnailUrl,
            ScaleType = Enum.ScaleType.Fit
        })
        
        local PlayerAvatarCorner = Create("UICorner", {
            Parent = PlayerAvatar,
            CornerRadius = UDim.new(0, 10)
        })
        
        local PlayerName = Create("TextLabel", {
            Name = "PlayerName",
            Parent = PlayerInfo,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 100, 0, 20),
            Size = UDim2.new(1, -110, 0, 25),
            Font = FONT,
            Text = displayName,
            TextColor3 = self.SelectedTheme.TextPrimary,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local PlayerNameSecondary = Create("TextLabel", {
            Name = "PlayerNameSecondary",
            Parent = PlayerInfo,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 100, 0, 45),
            Size = UDim2.new(1, -110, 0, 20),
            Font = FONT,
            Text = "@" .. playerName,
            TextColor3 = self.SelectedTheme.TextSecondary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Game info
        local gameInfo = ""
        pcall(function()
            gameInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        end)
        
        if gameInfo == "" then
            gameInfo = "Game"
        end
        
        local GameName = Create("TextLabel", {
            Name = "GameName",
            Parent = PlayerInfo,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 100, 0, 65),
            Size = UDim2.new(1, -110, 0, 20),
            Font = FONT,
            Text = "Playing: " .. gameInfo,
            TextColor3 = self.SelectedTheme.TextSecondary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Home welcome message
        local WelcomeLabel = Create("TextLabel", {
            Name = "WelcomeLabel",
            Parent = HomePage,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 70),
            Font = FONT,
            Text = "Welcome to " .. options.Title .. " " .. options.Subtitle,
            TextColor3 = self.SelectedTheme.TextPrimary,
            TextSize = 22,
            TextWrapped = true,
            LayoutOrder = 2
        })
        
        -- Description
        local Description = Create("TextLabel", {
            Name = "Description",
            Parent = HomePage,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 70),
            Font = FONT,
            Text = "This UI Library is designed to be compatible with all Roblox executors. Select a tab on the left to begin.",
            TextColor3 = self.SelectedTheme.TextSecondary,
            TextSize = 16,
            TextWrapped = true,
            LayoutOrder = 3
        })
        
        -- Credits
        local Credits = Create("TextLabel", {
            Name = "Credits",
            Parent = HomePage,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Font = FONT,
            Text = "TBD UI Library V9 | Universal Edition",
            TextColor3 = self.SelectedTheme.TextSecondary,
            TextSize = 14,
            TextWrapped = true,
            LayoutOrder = 4
        })
    end
    
    -- Loading screen
    local LoadingScreen
    if options.LoadingEnabled then
        LoadingScreen = Create("Frame", {
            Name = "LoadingScreen",
            Parent = Container,
            BackgroundColor3 = self.SelectedTheme.Background,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, -(options.Size[1] / 2), 0.5, -(options.Size[2] / 2)),
            Size = UDim2.new(0, options.Size[1], 0, options.Size[2]),
            Visible = true
        })
        
        local LoadingCorner = Create("UICorner", {
            Parent = LoadingScreen,
            CornerRadius = CORNER_RADIUS
        })
        
        local LoadingTitle = Create("TextLabel", {
            Name = "LoadingTitle",
            Parent = LoadingScreen,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.4, -20),
            Size = UDim2.new(1, 0, 0, 40),
            Font = FONT,
            Text = options.Title,
            TextColor3 = self.SelectedTheme.TextPrimary,
            TextSize = 24
        })
        
        local LoadingSubtitle = Create("TextLabel", {
            Name = "LoadingSubtitle",
            Parent = LoadingScreen,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.4, 20),
            Size = UDim2.new(1, 0, 0, 40),
            Font = FONT,
            Text = options.Subtitle,
            TextColor3 = self.SelectedTheme.TextSecondary,
            TextSize = 18
        })
        
        local LoadingBar = Create("Frame", {
            Name = "LoadingBar",
            Parent = LoadingScreen,
            BackgroundColor3 = self.SelectedTheme.Secondary,
            BorderSizePixel = 0,
            Position = UDim2.new(0.2, 0, 0.6, 0),
            Size = UDim2.new(0.6, 0, 0, 10)
        })
        
        local LoadingBarCorner = Create("UICorner", {
            Parent = LoadingBar,
            CornerRadius = UDim.new(0, 4)
        })
        
        local LoadingBarFill = Create("Frame", {
            Name = "LoadingBarFill",
            Parent = LoadingBar,
            BackgroundColor3 = self.SelectedTheme.Accent,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 0, 1, 0)
        })
        
        local LoadingBarFillCorner = Create("UICorner", {
            Parent = LoadingBarFill,
            CornerRadius = UDim.new(0, 4)
        })
        
        local LoadingStatus = Create("TextLabel", {
            Name = "LoadingStatus",
            Parent = LoadingScreen,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.6, 20),
            Size = UDim2.new(1, 0, 0, 20),
            Font = FONT,
            Text = "Initializing...",
            TextColor3 = self.SelectedTheme.TextSecondary,
            TextSize = 16
        })
        
        -- Loading animation
        spawn(function()
            local statuses = {
                "Initializing...",
                "Loading assets...",
                "Preparing interface...",
                "Finalizing setup..."
            }
            
            for i = 1, 100 do
                local statusIndex = math.floor((i / 100) * #statuses) + 1
                if statusIndex > #statuses then statusIndex = #statuses end
                
                LoadingStatus.Text = statuses[statusIndex]
                LoadingBarFill:TweenSize(UDim2.new(i/100, 0, 1, 0), "Out", "Quad", 0.1, true)
                wait(0.05)
            end
            
            LoadingScreen.Visible = false
            Window.Visible = true
        end)
    end
    
    -- Make window draggable
    MakeDraggable(Window, TopBar)
    
    -- Window functionality
    local minimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Window:TweenSize(UDim2.new(0, options.Size[1], 0, 40), "Out", "Quad", 0.3, true)
            for _, item in pairs(TabContentContainer:GetChildren()) do
                if item:IsA("Frame") then
                    item.Visible = false
                end
            end
        else
            Window:TweenSize(UDim2.new(0, options.Size[1], 0, options.Size[2]), "Out", "Quad", 0.3, true)
            wait(0.3)
            for _, item in pairs(TabContentContainer:GetChildren()) do
                if item:IsA("Frame") and item.Name == "TabSelected" then
                    item.Visible = true
                end
            end
            
            if HomePage and TabContentContainer:FindFirstChild("TabSelected") == nil then
                HomePage.Visible = true
            end
        end
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        Container:Destroy()
    end)
    
    -- Window object
    local WindowObject = {}
    WindowObject.Container = Container
    WindowObject.Window = Window
    WindowObject.Tabs = {}
    WindowObject.TabsContainer = TabsContainer
    WindowObject.TabContentContainer = TabContentContainer
    WindowObject.SelectedTab = nil
    WindowObject.HomePage = HomePage
    
    -- Create tab function
    function WindowObject:CreateTab(options)
        options = options or {}
        options.Name = options.Name or "Tab"
        options.Icon = options.Icon or "Home"
        
        local iconId = ICONS[options.Icon] or options.Icon
        
        -- Create tab button
        local TabButton = Create("TextButton", {
            Name = "TabButton",
            Parent = self.TabsContainer,
            BackgroundColor3 = TBD.SelectedTheme.Secondary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 40),
            Font = FONT,
            Text = "",
            TextColor3 = TBD.SelectedTheme.TextPrimary,
            TextSize = TEXT_SIZE,
            AutoButtonColor = false
        })
        
        local TabButtonCorner = Create("UICorner", {
            Parent = TabButton,
            CornerRadius = CORNER_RADIUS
        })
        
        local TabIcon = Create("ImageLabel", {
            Name = "TabIcon",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(0, 24, 0, 24),
            Image = iconId,
            ImageColor3 = TBD.SelectedTheme.TextSecondary,
            ScaleType = Enum.ScaleType.Fit,
            SliceCenter = Rect.new(0, 0, 0, 0)
        })
        
        local TabText = Create("TextLabel", {
            Name = "TabText",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 40, 0, 0),
            Size = UDim2.new(1, -40, 1, 0),
            Font = FONT,
            Text = options.Name,
            TextColor3 = TBD.SelectedTheme.TextSecondary,
            TextSize = TEXT_SIZE,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Create tab content
        local TabContent = Create("ScrollingFrame", {
            Name = options.Name .. "Content",
            Parent = self.TabContentContainer,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = TBD.SelectedTheme.Accent,
            Visible = false,
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        
        local ContentListLayout = Create("UIListLayout", {
            Parent = TabContent,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        local ContentPadding = Create("UIPadding", {
            Parent = TabContent,
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15)
        })
        
        -- Tab functionality
        TabButton.MouseEnter:Connect(function()
            if self.SelectedTab ~= TabButton then
                Services.TweenService:Create(TabButton, TWEEN_INFO, {BackgroundColor3 = TBD.SelectedTheme.Primary}):Play()
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if self.SelectedTab ~= TabButton then
                Services.TweenService:Create(TabButton, TWEEN_INFO, {BackgroundColor3 = TBD.SelectedTheme.Secondary}):Play()
            end
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            if self.SelectedTab ~= TabButton then
                if self.SelectedTab then
                    -- Deselect current tab
                    Services.TweenService:Create(self.SelectedTab, TWEEN_INFO, {BackgroundColor3 = TBD.SelectedTheme.Secondary}):Play()
                    Services.TweenService:Create(self.SelectedTab.TabIcon, TWEEN_INFO, {ImageColor3 = TBD.SelectedTheme.TextSecondary}):Play()
                    Services.TweenService:Create(self.SelectedTab.TabText, TWEEN_INFO, {TextColor3 = TBD.SelectedTheme.TextSecondary}):Play()
                    
                    local selectedContent = self.TabContentContainer:FindFirstChild(self.SelectedTab.TabText.Text .. "Content")
                    if selectedContent then
                        selectedContent.Visible = false
                    end
                    
                    if selectedContent then
                        self.TabContentContainer:FindFirstChild("TabSelected").Name = selectedContent.Name
                    end
                end
                
                -- Hide home page
                if self.HomePage then
                    self.HomePage.Visible = false
                end
                
                -- Select new tab
                self.SelectedTab = TabButton
                Services.TweenService:Create(TabButton, TWEEN_INFO, {BackgroundColor3 = TBD.SelectedTheme.Accent}):Play()
                Services.TweenService:Create(TabIcon, TWEEN_INFO, {ImageColor3 = TBD.SelectedTheme.TextPrimary}):Play()
                Services.TweenService:Create(TabText, TWEEN_INFO, {TextColor3 = TBD.SelectedTheme.TextPrimary}):Play()
                
                -- Show tab content
                local content = self.TabContentContainer:FindFirstChild(options.Name .. "Content")
                if content then
                    content.Visible = true
                    content.Name = "TabSelected"
                end
            end
        end)
        
        -- Tab object
        local TabObject = {}
        TabObject.Button = TabButton
        TabObject.Content = TabContent
        
        -- Section function
        function TabObject:CreateSection(title)
            local sectionTitle = title or "Section"
            
            local Section = Create("Frame", {
                Name = "Section",
                Parent = self.Content,
                BackgroundColor3 = TBD.SelectedTheme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            local SectionCorner = Create("UICorner", {
                Parent = Section,
                CornerRadius = CORNER_RADIUS
            })
            
            local SectionTitle = Create("TextLabel", {
                Name = "SectionTitle",
                Parent = Section,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 30),
                Font = FONT,
                Text = sectionTitle,
                TextColor3 = TBD.SelectedTheme.TextPrimary,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local SectionDivider = Create("Frame", {
                Name = "SectionDivider",
                Parent = Section,
                BackgroundColor3 = TBD.SelectedTheme.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 30),
                Size = UDim2.new(1, -20, 0, 1)
            })
            
            local SectionContent = Create("Frame", {
                Name = "SectionContent",
                Parent = Section,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 40),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            local SectionListLayout = Create("UIListLayout", {
                Parent = SectionContent,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })
            
            local SectionPadding = Create("UIPadding", {
                Parent = SectionContent,
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 10)
            })
            
            return Section, SectionContent
        end
        
        -- Button function
        function TabObject:CreateButton(options)
            options = options or {}
            options.Name = options.Name or "Button"
            options.Description = options.Description or nil
            options.Callback = options.Callback or function() end
            
            local buttonHeight = options.Description and 60 or 30
            
            local Button = Create("Frame", {
                Name = "Button",
                Parent = self.Content,
                BackgroundColor3 = TBD.SelectedTheme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, buttonHeight)
            })
            
            local ButtonCorner = Create("UICorner", {
                Parent = Button,
                CornerRadius = CORNER_RADIUS
            })
            
            local ButtonClickArea = Create("TextButton", {
                Name = "ButtonClickArea",
                Parent = Button,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = FONT,
                Text = "",
                TextColor3 = TBD.SelectedTheme.TextPrimary,
                TextSize = TEXT_SIZE
            })
            
            local ButtonLabel = Create("TextLabel", {
                Name = "ButtonLabel",
                Parent = Button,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 30),
                Font = FONT,
                Text = options.Name,
                TextColor3 = TBD.SelectedTheme.TextPrimary,
                TextSize = TEXT_SIZE,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            if options.Description then
                local ButtonDescription = Create("TextLabel", {
                    Name = "ButtonDescription",
                    Parent = Button,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = FONT,
                    Text = options.Description,
                    TextColor3 = TBD.SelectedTheme.TextSecondary,
                    TextSize = TEXT_SIZE - 2,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            
            -- Button functionality
            ButtonClickArea.MouseEnter:Connect(function()
                Services.TweenService:Create(Button, TWEEN_INFO, {BackgroundColor3 = TBD.SelectedTheme.Secondary}):Play()
            end)
            
            ButtonClickArea.MouseLeave:Connect(function()
                Services.TweenService:Create(Button, TWEEN_INFO, {BackgroundColor3 = TBD.SelectedTheme.Primary}):Play()
            end)
            
            ButtonClickArea.MouseButton1Click:Connect(function()
                Services.TweenService:Create(Button, TWEEN_INFO, {BackgroundColor3 = TBD.SelectedTheme.Accent}):Play()
                options.Callback()
                wait(0.2)
                Services.TweenService:Create(Button, TWEEN_INFO, {BackgroundColor3 = TBD.SelectedTheme.Primary}):Play()
            end)
            
            return Button
        end
        
        -- Toggle function
        function TabObject:CreateToggle(options)
            options = options or {}
            options.Name = options.Name or "Toggle"
            options.Description = options.Description or nil
            options.CurrentValue = type(options.CurrentValue) == "boolean" and options.CurrentValue or false
            options.Callback = options.Callback or function() end
            
            local toggleHeight = options.Description and 60 or 30
            
            local Toggle = Create("Frame", {
                Name = "Toggle",
                Parent = self.Content,
                BackgroundColor3 = TBD.SelectedTheme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, toggleHeight)
            })
            
            local ToggleCorner = Create("UICorner", {
                Parent = Toggle,
                CornerRadius = CORNER_RADIUS
            })
            
            local ToggleLabel = Create("TextLabel", {
                Name = "ToggleLabel",
                Parent = Toggle,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -60, 0, 30),
                Font = FONT,
                Text = options.Name,
                TextColor3 = TBD.SelectedTheme.TextPrimary,
                TextSize = TEXT_SIZE,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            if options.Description then
                local ToggleDescription = Create("TextLabel", {
                    Name = "ToggleDescription",
                    Parent = Toggle,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = FONT,
                    Text = options.Description,
                    TextColor3 = TBD.SelectedTheme.TextSecondary,
                    TextSize = TEXT_SIZE - 2,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            
            local ToggleButton = Create("Frame", {
                Name = "ToggleButton",
                Parent = Toggle,
                BackgroundColor3 = options.CurrentValue and TBD.SelectedTheme.Accent or TBD.SelectedTheme.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -50, 0, 5),
                Size = UDim2.new(0, 40, 0, 20)
            })
            
            local ToggleButtonCorner = Create("UICorner", {
                Parent = ToggleButton,
                CornerRadius = UDim.new(0, 10)
            })
            
            local ToggleIndicator = Create("Frame", {
                Name = "ToggleIndicator",
                Parent = ToggleButton,
                BackgroundColor3 = TBD.SelectedTheme.TextPrimary,
                BorderSizePixel = 0,
                Position = options.CurrentValue and UDim2.new(1, -20, 0, 0) or UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 20, 0, 20)
            })
            
            local ToggleIndicatorCorner = Create("UICorner", {
                Parent = ToggleIndicator,
                CornerRadius = UDim.new(0, 10)
            })
            
            local ToggleClickArea = Create("TextButton", {
                Name = "ToggleClickArea",
                Parent = Toggle,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = FONT,
                Text = "",
                TextColor3 = TBD.SelectedTheme.TextPrimary,
                TextSize = TEXT_SIZE
            })
            
            -- Toggle functionality
            local toggled = options.CurrentValue
            
            local function updateToggle()
                toggled = not toggled
                
                if toggled then
                    Services.TweenService:Create(ToggleButton, TWEEN_INFO, {BackgroundColor3 = TBD.SelectedTheme.Accent}):Play()
                    Services.TweenService:Create(ToggleIndicator, TWEEN_INFO, {Position = UDim2.new(1, -20, 0, 0)}):Play()
                else
                    Services.TweenService:Create(ToggleButton, TWEEN_INFO, {BackgroundColor3 = TBD.SelectedTheme.Secondary}):Play()
                    Services.TweenService:Create(ToggleIndicator, TWEEN_INFO, {Position = UDim2.new(0, 0, 0, 0)}):Play()
                end
                
                options.Callback(toggled)
            end
            
            ToggleClickArea.MouseEnter:Connect(function()
                Services.TweenService:Create(Toggle, TWEEN_INFO, {BackgroundColor3 = TBD.SelectedTheme.Secondary}):Play()
            end)
            
            ToggleClickArea.MouseLeave:Connect(function()
                Services.TweenService:Create(Toggle, TWEEN_INFO, {BackgroundColor3 = TBD.SelectedTheme.Primary}):Play()
            end)
            
            ToggleClickArea.MouseButton1Click:Connect(updateToggle)
            
            -- Initial callback
            if options.CurrentValue then
                options.Callback(true)
            end
            
            return Toggle
        end
        
        -- Slider function
        function TabObject:CreateSlider(options)
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
            
            local sliderHeight = options.Description and 70 or 40
            
            local Slider = Create("Frame", {
                Name = "Slider",
                Parent = self.Content,
                BackgroundColor3 = TBD.SelectedTheme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, sliderHeight)
            })
            
            local SliderCorner = Create("UICorner", {
                Parent = Slider,
                CornerRadius = CORNER_RADIUS
            })
            
            local SliderLabel = Create("TextLabel", {
                Name = "SliderLabel",
                Parent = Slider,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 30),
                Font = FONT,
                Text = options.Name,
                TextColor3 = TBD.SelectedTheme.TextPrimary,
                TextSize = TEXT_SIZE,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            if options.Description then
                local SliderDescription = Create("TextLabel", {
                    Name = "SliderDescription",
                    Parent = Slider,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = FONT,
                    Text = options.Description,
                    TextColor3 = TBD.SelectedTheme.TextSecondary,
                    TextSize = TEXT_SIZE - 2,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            
            local SliderValueDisplay = Create("TextLabel", {
                Name = "SliderValueDisplay",
                Parent = Slider,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -50, 0, 0),
                Size = UDim2.new(0, 40, 0, 30),
                Font = FONT,
                Text = tostring(options.CurrentValue),
                TextColor3 = TBD.SelectedTheme.TextPrimary,
                TextSize = TEXT_SIZE
            })
            
            local SliderTrack = Create("Frame", {
                Name = "SliderTrack",
                Parent = Slider,
                BackgroundColor3 = TBD.SelectedTheme.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, sliderHeight - 10),
                Size = UDim2.new(1, -20, 0, 5)
            })
            
            local SliderTrackCorner = Create("UICorner", {
                Parent = SliderTrack,
                CornerRadius = UDim.new(0, 3)
            })
            
            local initialScale = (options.CurrentValue - options.Min) / (options.Max - options.Min)
            
            local SliderFill = Create("Frame", {
                Name = "SliderFill",
                Parent = SliderTrack,
                BackgroundColor3 = TBD.SelectedTheme.Accent,
                BorderSizePixel = 0,
                Size = UDim2.new(initialScale, 0, 1, 0)
            })
            
            local SliderFillCorner = Create("UICorner", {
                Parent = SliderFill,
                CornerRadius = UDim.new(0, 3)
            })
            
            local SliderButton = Create("TextButton", {
                Name = "SliderButton",
                Parent = Slider,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                Font = FONT,
                TextColor3 = TBD.SelectedTheme.TextPrimary,
                TextSize = TEXT_SIZE
            })
            
            -- Slider functionality
            local function updateSlider(input)
                local sizeScale = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                local value = options.Min + ((options.Max - options.Min) * sizeScale)
                
                -- Round to increment
                value = math.floor(value / options.Increment + 0.5) * options.Increment
                value = math.clamp(value, options.Min, options.Max)
                
                -- Update display
                SliderValueDisplay.Text = tostring(value)
                SliderFill.Size = UDim2.new(sizeScale, 0, 1, 0)
                
                -- Call callback
                options.Callback(value)
            end
            
            SliderButton.MouseButton1Down:Connect(function()
                local mouseMoveCon
                local mouseReleaseCon
                
                mouseMoveCon = Services.UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        updateSlider(input)
                    end
                end)
                
                mouseReleaseCon = Services.UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        mouseMoveCon:Disconnect()
                        mouseReleaseCon:Disconnect()
                    end
                end)
                
                updateSlider(Services.UserInputService:GetMouseLocation())
            end)
            
            -- Initial callback
            options.Callback(options.CurrentValue)
            
            return Slider
        end
        
        -- Dropdown function
        function TabObject:CreateDropdown(options)
            options = options or {}
            options.Name = options.Name or "Dropdown"
            options.Description = options.Description or nil
            options.Items = options.Items or {}
            options.CurrentOption = options.CurrentOption or (options.Items[1] or "")
            options.Callback = options.Callback or function() end
            
            local dropdownHeight = options.Description and 70 or 40
            
            local Dropdown = Create("Frame", {
                Name = "Dropdown",
                Parent = self.Content,
                BackgroundColor3 = TBD.SelectedTheme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, dropdownHeight),
                ClipsDescendants = true
            })
            
            local DropdownCorner = Create("UICorner", {
                Parent = Dropdown,
                CornerRadius = CORNER_RADIUS
            })
            
            local DropdownLabel = Create("TextLabel", {
                Name = "DropdownLabel",
                Parent = Dropdown,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 30),
                Font = FONT,
                Text = options.Name,
                TextColor3 = TBD.SelectedTheme.TextPrimary,
                TextSize = TEXT_SIZE,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            if options.Description then
                local DropdownDescription = Create("TextLabel", {
                    Name = "DropdownDescription",
                    Parent = Dropdown,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = FONT,
                    Text = options.Description,
                    TextColor3 = TBD.SelectedTheme.TextSecondary,
                    TextSize = TEXT_SIZE - 2,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            
            local DropdownButton = Create("TextButton", {
                Name = "DropdownButton",
                Parent = Dropdown,
                BackgroundColor3 = TBD.SelectedTheme.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, dropdownHeight - 10),
                Size = UDim2.new(1, -20, 0, 30)
            })
            
            local DropdownButtonCorner = Create("UICorner", {
                Parent = DropdownButton,
                CornerRadius = UDim.new(0, 4)
            })
            
            local DropdownButtonText = Create("TextLabel", {
                Name = "DropdownButtonText",
                Parent = DropdownButton,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -40, 1, 0),
                Font = FONT,
                Text = options.CurrentOption,
                TextColor3 = TBD.SelectedTheme.TextPrimary,
                TextSize = TEXT_SIZE,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local DropdownButtonArrow = Create("ImageLabel", {
                Name = "DropdownButtonArrow",
                Parent = DropdownButton,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -30, 0, 0),
                Size = UDim2.new(0, 20, 0, 30),
                Image = ICONS.Arrow,
                ImageColor3 = TBD.SelectedTheme.TextPrimary,
                Rotation = 90
            })
            
            local DropdownOptions = Create("ScrollingFrame", {
                Name = "DropdownOptions",
                Parent = Dropdown,
                BackgroundColor3 = TBD.SelectedTheme.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, dropdownHeight + 25),
                Size = UDim2.new(1, -20, 0, 0),
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = TBD.SelectedTheme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                Visible = false,
                ClipsDescendants = true,
                AutomaticCanvasSize = Enum.AutomaticSize.Y
            })
            
            local DropdownOptionsCorner = Create("UICorner", {
                Parent = DropdownOptions,
                CornerRadius = UDim.new(0, 4)
            })
            
            local DropdownOptionsList = Create("UIListLayout", {
                Parent = DropdownOptions,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            })
            
            local DropdownOptionsPadding = Create("UIPadding", {
                Parent = DropdownOptions,
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5),
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5)
            })
            
            -- Create dropdown options
            local function createDropdownItems()
                -- Clear existing items
                for _, item in pairs(DropdownOptions:GetChildren()) do
                    if item:IsA("TextButton") then
                        item:Destroy()
                    end
                end
                
                -- Create new items
                for i, item in pairs(options.Items) do
                    local OptionButton = Create("TextButton", {
                        Name = "OptionButton",
                        Parent = DropdownOptions,
                        BackgroundColor3 = TBD.SelectedTheme.Primary,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 30),
                        Font = FONT,
                        Text = item,
                        TextColor3 = TBD.SelectedTheme.TextPrimary,
                        TextSize = TEXT_SIZE,
                        AutoButtonColor = false
                    })
                    
                    local OptionButtonCorner = Create("UICorner", {
                        Parent = OptionButton,
                        CornerRadius = UDim.new(0, 4)
                    })
                    
                    -- Option button functionality
                    OptionButton.MouseEnter:Connect(function()
                        Services.TweenService:Create(OptionButton, TWEEN_INFO, {BackgroundColor3 = TBD.SelectedTheme.Accent}):Play()
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Services.TweenService:Create(OptionButton, TWEEN_INFO, {BackgroundColor3 = TBD.SelectedTheme.Primary}):Play()
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        DropdownButtonText.Text = item
                        options.Callback(item)
                        
                        -- Close dropdown
                        local dropdownTween = Services.TweenService:Create(Dropdown, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, dropdownHeight)})
                        local arrowTween = Services.TweenService:Create(DropdownButtonArrow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 90})
                        dropdownTween:Play()
                        arrowTween:Play()
                        dropdownTween.Completed:Connect(function()
                            DropdownOptions.Visible = false
                        end)
                    end)
                end
            end
            
            createDropdownItems()
            
            -- Dropdown functionality
            local dropdownOpen = false
            
            DropdownButton.MouseButton1Click:Connect(function()
                dropdownOpen = not dropdownOpen
                
                if dropdownOpen then
                    -- Open dropdown
                    DropdownOptions.Visible = true
                    local optionsHeight = math.min(150, #options.Items * 40)
                    local dropdownTween = Services.TweenService:Create(Dropdown, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, dropdownHeight + optionsHeight + 40)})
                    local arrowTween = Services.TweenService:Create(DropdownButtonArrow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 270})
                    dropdownTween:Play()
                    arrowTween:Play()
                else
                    -- Close dropdown
                    local dropdownTween = Services.TweenService:Create(Dropdown, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, dropdownHeight)})
                    local arrowTween = Services.TweenService:Create(DropdownButtonArrow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 90})
                    dropdownTween:Play()
                    arrowTween:Play()
                    dropdownTween.Completed:Connect(function()
                        DropdownOptions.Visible = false
                    end)
                end
            end)
            
            -- Methods to update dropdown
            local dropdownObject = {}
            
            function dropdownObject:Refresh(newItems)
                options.Items = newItems
                createDropdownItems()
            end
            
            function dropdownObject:SetValue(newValue)
                DropdownButtonText.Text = newValue
                options.Callback(newValue)
            end
            
            -- Initial callback
            options.Callback(options.CurrentOption)
            
            return Dropdown, dropdownObject
        end
        
        -- Text input function
        function TabObject:CreateTextBox(options)
            options = options or {}
            options.Name = options.Name or "TextBox"
            options.Description = options.Description or nil
            options.Placeholder = options.Placeholder or "Enter text..."
            options.CurrentValue = options.CurrentValue or ""
            options.Callback = options.Callback or function() end
            
            local textBoxHeight = options.Description and 70 or 40
            
            local TextBox = Create("Frame", {
                Name = "TextBox",
                Parent = self.Content,
                BackgroundColor3 = TBD.SelectedTheme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, textBoxHeight)
            })
            
            local TextBoxCorner = Create("UICorner", {
                Parent = TextBox,
                CornerRadius = CORNER_RADIUS
            })
            
            local TextBoxLabel = Create("TextLabel", {
                Name = "TextBoxLabel",
                Parent = TextBox,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 30),
                Font = FONT,
                Text = options.Name,
                TextColor3 = TBD.SelectedTheme.TextPrimary,
                TextSize = TEXT_SIZE,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            if options.Description then
                local TextBoxDescription = Create("TextLabel", {
                    Name = "TextBoxDescription",
                    Parent = TextBox,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = FONT,
                    Text = options.Description,
                    TextColor3 = TBD.SelectedTheme.TextSecondary,
                    TextSize = TEXT_SIZE - 2,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            
            local TextBoxInput = Create("TextBox", {
                Name = "TextBoxInput",
                Parent = TextBox,
                BackgroundColor3 = TBD.SelectedTheme.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, textBoxHeight - 10),
                Size = UDim2.new(1, -20, 0, 30),
                Font = FONT,
                PlaceholderText = options.Placeholder,
                Text = options.CurrentValue,
                TextColor3 = TBD.SelectedTheme.TextPrimary,
                TextSize = TEXT_SIZE,
                TextWrapped = true,
                ClearTextOnFocus = false
            })
            
            local TextBoxInputCorner = Create("UICorner", {
                Parent = TextBoxInput,
                CornerRadius = UDim.new(0, 4)
            })
            
            -- TextBox functionality
            TextBoxInput.FocusLost:Connect(function(enterPressed)
                options.Callback(TextBoxInput.Text)
            end)
            
            -- Initial callback
            if options.CurrentValue ~= "" then
                options.Callback(options.CurrentValue)
            end
            
            return TextBox
        end
        
        -- Color picker function
        function TabObject:CreateColorPicker(options)
            options = options or {}
            options.Name = options.Name or "Color Picker"
            options.Description = options.Description or nil
            options.CurrentColor = options.CurrentColor or Color3.fromRGB(255, 255, 255)
            options.Callback = options.Callback or function() end
            
            local colorPickerHeight = options.Description and 70 or 40
            
            local ColorPicker = Create("Frame", {
                Name = "ColorPicker",
                Parent = self.Content,
                BackgroundColor3 = TBD.SelectedTheme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, colorPickerHeight),
                ClipsDescendants = true
            })
            
            local ColorPickerCorner = Create("UICorner", {
                Parent = ColorPicker,
                CornerRadius = CORNER_RADIUS
            })
            
            local ColorPickerLabel = Create("TextLabel", {
                Name = "ColorPickerLabel",
                Parent = ColorPicker,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -60, 0, 30),
                Font = FONT,
                Text = options.Name,
                TextColor3 = TBD.SelectedTheme.TextPrimary,
                TextSize = TEXT_SIZE,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            if options.Description then
                local ColorPickerDescription = Create("TextLabel", {
                    Name = "ColorPickerDescription",
                    Parent = ColorPicker,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = FONT,
                    Text = options.Description,
                    TextColor3 = TBD.SelectedTheme.TextSecondary,
                    TextSize = TEXT_SIZE - 2,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            
            local ColorDisplay = Create("Frame", {
                Name = "ColorDisplay",
                Parent = ColorPicker,
                BackgroundColor3 = options.CurrentColor,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -50, 0, 5),
                Size = UDim2.new(0, 40, 0, 20)
            })
            
            local ColorDisplayCorner = Create("UICorner", {
                Parent = ColorDisplay,
                CornerRadius = UDim.new(0, 4)
            })
            
            local ColorPickerButton = Create("TextButton", {
                Name = "ColorPickerButton",
                Parent = ColorPicker,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, colorPickerHeight),
                Text = "",
                Font = FONT,
                TextColor3 = TBD.SelectedTheme.TextPrimary,
                TextSize = TEXT_SIZE
            })
            
            -- Color picker expanded UI
            local ColorPickerExpanded = Create("Frame", {
                Name = "ColorPickerExpanded",
                Parent = ColorPicker,
                BackgroundColor3 = TBD.SelectedTheme.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, colorPickerHeight + 10),
                Size = UDim2.new(1, -20, 0, 200),
                Visible = false
            })
            
            local ColorPickerExpandedCorner = Create("UICorner", {
                Parent = ColorPickerExpanded,
                CornerRadius = UDim.new(0, 4)
            })
            
            -- Create color picker UI components (simplified for compatibility)
            local H, S, V = Color3.toHSV(options.CurrentColor)
            
            local ColorHue = Create("ImageLabel", {
                Name = "ColorHue",
                Parent = ColorPickerExpanded,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 10),
                Size = UDim2.new(1, -20, 0, 20),
                Image = "rbxassetid://6523286724"
            })
            
            local ColorHueCorner = Create("UICorner", {
                Parent = ColorHue,
                CornerRadius = UDim.new(0, 4)
            })
            
            local HueSlider = Create("Frame", {
                Name = "HueSlider",
                Parent = ColorHue,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = UDim2.new(H, 0, 0, 0),
                Size = UDim2.new(0, 5, 1, 0)
            })
            
            local HueSliderCorner = Create("UICorner", {
                Parent = HueSlider,
                CornerRadius = UDim.new(0, 4)
            })
            
            local ColorSaturation = Create("ImageLabel", {
                Name = "ColorSaturation",
                Parent = ColorPickerExpanded,
                BackgroundColor3 = Color3.fromHSV(H, 1, 1),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 40),
                Size = UDim2.new(1, -20, 0, 150),
                Image = "rbxassetid://6523291212"
            })
            
            local ColorSaturationCorner = Create("UICorner", {
                Parent = ColorSaturation,
                CornerRadius = UDim.new(0, 4)
            })
            
            local SaturationSlider = Create("Frame", {
                Name = "SaturationSlider",
                Parent = ColorSaturation,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = UDim2.new(S, 0, 1 - V, 0),
                Size = UDim2.new(0, 10, 0, 10)
            })
            
            local SaturationSliderCorner = Create("UICorner", {
                Parent = SaturationSlider,
                CornerRadius = UDim.new(0, 10)
            })
            
            -- Color picker functionality
            local colorPickerOpen = false
            
            local function updateColor()
                local hue = HueSlider.Position.X.Scale
                local saturation = SaturationSlider.Position.X.Scale
                local value = 1 - SaturationSlider.Position.Y.Scale
                
                -- Update color saturation background based on hue
                ColorSaturation.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                
                -- Calculate final color
                local color = Color3.fromHSV(hue, saturation, value)
                ColorDisplay.BackgroundColor3 = color
                
                options.Callback(color)
            end
            
            -- Hue slider functionality
            ColorHue.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local mousePosition = Services.UserInputService:GetMouseLocation()
                    local sliderPosition = (mousePosition.X - ColorHue.AbsolutePosition.X) / ColorHue.AbsoluteSize.X
                    sliderPosition = math.clamp(sliderPosition, 0, 1)
                    HueSlider.Position = UDim2.new(sliderPosition, 0, 0, 0)
                    updateColor()
                    
                    local dragging
                    dragging = Services.UserInputService.InputChanged:Connect(function(dragInput)
                        if dragInput.UserInputType == Enum.UserInputType.MouseMovement or dragInput.UserInputType == Enum.UserInputType.Touch then
                            local mousePosition = Services.UserInputService:GetMouseLocation()
                            local sliderPosition = (mousePosition.X - ColorHue.AbsolutePosition.X) / ColorHue.AbsoluteSize.X
                            sliderPosition = math.clamp(sliderPosition, 0, 1)
                            HueSlider.Position = UDim2.new(sliderPosition, 0, 0, 0)
                            updateColor()
                        end
                    end)
                    
                    Services.UserInputService.InputEnded:Connect(function(endInput)
                        if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                            if dragging then
                                dragging:Disconnect()
                            end
                        end
                    end)
                end
            end)
            
            -- Saturation slider functionality
            ColorSaturation.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local mousePosition = Services.UserInputService:GetMouseLocation()
                    local xPosition = (mousePosition.X - ColorSaturation.AbsolutePosition.X) / ColorSaturation.AbsoluteSize.X
                    local yPosition = (mousePosition.Y - ColorSaturation.AbsolutePosition.Y) / ColorSaturation.AbsoluteSize.Y
                    xPosition = math.clamp(xPosition, 0, 1)
                    yPosition = math.clamp(yPosition, 0, 1)
                    SaturationSlider.Position = UDim2.new(xPosition, 0, yPosition, 0)
                    updateColor()
                    
                    local dragging
                    dragging = Services.UserInputService.InputChanged:Connect(function(dragInput)
                        if dragInput.UserInputType == Enum.UserInputType.MouseMovement or dragInput.UserInputType == Enum.UserInputType.Touch then
                            local mousePosition = Services.UserInputService:GetMouseLocation()
                            local xPosition = (mousePosition.X - ColorSaturation.AbsolutePosition.X) / ColorSaturation.AbsoluteSize.X
                            local yPosition = (mousePosition.Y - ColorSaturation.AbsolutePosition.Y) / ColorSaturation.AbsoluteSize.Y
                            xPosition = math.clamp(xPosition, 0, 1)
                            yPosition = math.clamp(yPosition, 0, 1)
                            SaturationSlider.Position = UDim2.new(xPosition, 0, yPosition, 0)
                            updateColor()
                        end
                    end)
                    
                    Services.UserInputService.InputEnded:Connect(function(endInput)
                        if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                            if dragging then
                                dragging:Disconnect()
                            end
                        end
                    end)
                end
            end)
            
            -- Toggle color picker
            ColorPickerButton.MouseButton1Click:Connect(function()
                colorPickerOpen = not colorPickerOpen
                
                if colorPickerOpen then
                    -- Open color picker
                    ColorPickerExpanded.Visible = true
                    local expandTween = Services.TweenService:Create(ColorPicker, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, colorPickerHeight + 220)})
                    expandTween:Play()
                else
                    -- Close color picker
                    local collapseTween = Services.TweenService:Create(ColorPicker, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, colorPickerHeight)})
                    collapseTween:Play()
                    collapseTween.Completed:Connect(function()
                        ColorPickerExpanded.Visible = false
                    end)
                end
            end)
            
            -- Initial callback
            options.Callback(options.CurrentColor)
            
            return ColorPicker
        end
        
        -- Label function
        function TabObject:CreateLabel(options)
            options = options or {}
            options.Text = options.Text or "Label"
            options.Color = options.Color or TBD.SelectedTheme.TextPrimary
            
            local labelHeight = 30
            
            local Label = Create("Frame", {
                Name = "Label",
                Parent = self.Content,
                BackgroundColor3 = TBD.SelectedTheme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, labelHeight)
            })
            
            local LabelCorner = Create("UICorner", {
                Parent = Label,
                CornerRadius = CORNER_RADIUS
            })
            
            local LabelText = Create("TextLabel", {
                Name = "LabelText",
                Parent = Label,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = FONT,
                Text = options.Text,
                TextColor3 = options.Color,
                TextSize = TEXT_SIZE,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            return Label, LabelText
        end
        
        -- Paragraph function
        function TabObject:CreateParagraph(options)
            options = options or {}
            options.Title = options.Title or "Title"
            options.Content = options.Content or "Content"
            
            local Paragraph = Create("Frame", {
                Name = "Paragraph",
                Parent = self.Content,
                BackgroundColor3 = TBD.SelectedTheme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            local ParagraphCorner = Create("UICorner", {
                Parent = Paragraph,
                CornerRadius = CORNER_RADIUS
            })
            
            local ParagraphTitle = Create("TextLabel", {
                Name = "ParagraphTitle",
                Parent = Paragraph,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 30),
                Font = FONT,
                Text = options.Title,
                TextColor3 = TBD.SelectedTheme.TextPrimary,
                TextSize = TEXT_SIZE,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ParagraphContent = Create("TextLabel", {
                Name = "ParagraphContent",
                Parent = Paragraph,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 30),
                Size = UDim2.new(1, -20, 0, 0),
                Font = FONT,
                Text = options.Content,
                TextColor3 = TBD.SelectedTheme.TextSecondary,
                TextSize = TEXT_SIZE - 2,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            local ParagraphPadding = Create("UIPadding", {
                Parent = Paragraph,
                PaddingBottom = UDim.new(0, 10)
            })
            
            return Paragraph
        end
        
        return TabObject
    end
    
    return WindowObject
end

-- Keybind handling for minimize/hide
Services.UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == TBD.Settings.MinimizeKey then
            for _, window in pairs(TBD.Windows) do
                window.Minimized = not window.Minimized
                if window.Minimized then
                    window.Window:TweenSize(UDim2.new(0, window.Window.Size.X.Offset, 0, 40), "Out", "Quad", 0.3, true)
                else
                    window.Window:TweenSize(window.FullSize, "Out", "Quad", 0.3, true)
                end
            end
        elseif input.KeyCode == TBD.Settings.HideKey then
            for _, window in pairs(TBD.Windows) do
                window.Container.Enabled = not window.Container.Enabled
            end
        end
    end
end)

-- Return the library
return TBD
