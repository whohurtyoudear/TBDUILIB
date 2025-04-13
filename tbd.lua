--[[
    TBD UI Library - HoHo Edition V9
    A modern, customizable Roblox UI library for script hubs and executors
    Version: 2.0.0-V9
    
    Features:
    - Beautiful design with HoHo-inspired style
    - Works with ALL Roblox executors/injectors
    - Complete component library
    - Multiple themes including HoHo theme
    - Animated notifications that work properly
    - Robust error handling
]]

-- Services with safe fallbacks
local function getSafely(serviceName)
    local success, service = pcall(function() 
        return game:GetService(serviceName) 
    end)
    
    if success then
        return service
    else
        -- Return mock service with essential functions if needed
        if serviceName == "CoreGui" then
            return game.Players.LocalPlayer:WaitForChild("PlayerGui")
        end
        return {}
    end
end

local Players = getSafely("Players")
local UserInputService = getSafely("UserInputService")
local TweenService = getSafely("TweenService")
local TextService = getSafely("TextService")
local RunService = getSafely("RunService")
local CoreGui = getSafely("CoreGui")
local HttpService = getSafely("HttpService")

-- Get LocalPlayer safely
local LocalPlayer = Players.LocalPlayer

-- Detect if the device is mobile
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Main library table
local TBD = {
    Version = "2.0.0-V9",
    IsMobile = IS_MOBILE,
    Flags = {},
    Windows = {},
    Themes = {},
    Font = Enum.Font.GothamBold,
    SecondaryFont = Enum.Font.Gotham,
    NotificationQueue = {},
    ThemeObjects = {}
}

-- Get screen safe insets
local function getSafeInsets()
    local success, insets = pcall(function()
        return game:GetService("GuiService"):GetGuiInset()
    end)
    
    if success then
        return {
            Top = insets.Y,
            Bottom = 0,
            Left = insets.X,
            Right = 0
        }
    else
        return {
            Top = 36,
            Bottom = 0,
            Left = 0,
            Right = 0
        }
    end
end

local SafeInsets = getSafeInsets()

-- Icon set (Phosphor Icons)
local Icons = {
    -- Essential UI Icons
    Home = "rbxassetid://7733960981",
    Settings = "rbxassetid://7734053495",
    Search = "rbxassetid://7743871002",
    Menu = "rbxassetid://7743878556",
    Close = "rbxassetid://7743878326",
    Minimize = "rbxassetid://7743878857",
    Maximize = "rbxassetid://7734123447",
    Notification = "rbxassetid://7734058599",
    Visible = "rbxassetid://7734042071",
    Hidden = "rbxassetid://7734050471",
    Link = "rbxassetid://7734056474",
    Update = "rbxassetid://7734060820",
    Success = "rbxassetid://7747957564",
    Error = "rbxassetid://7748106991",
    Warning = "rbxassetid://7747958558",
    Info = "rbxassetid://7747959018",
    Plus = "rbxassetid://7743878654",
    Minus = "rbxassetid://7743878772",
    
    -- Game Elements
    Player = "rbxassetid://7743878152",
    Target = "rbxassetid://7734061145",
    Crown = "rbxassetid://7734130516",
    
    -- Actions
    Play = "rbxassetid://7734063280",
    Pause = "rbxassetid://7734063056",
    Refresh = "rbxassetid://7734062381",
    
    -- Communication
    Chat = "rbxassetid://7733971931",
    Mail = "rbxassetid://7734056641",
    
    -- User Interface
    Slider = "rbxassetid://7734064085",
    Toggle = "rbxassetid://7734064757",
    Button = "rbxassetid://7734055078",
    Dropdown = "rbxassetid://7744077761",
    ColorPicker = "rbxassetid://7734056047",
    
    -- Categories
    Folder = "rbxassetid://7734139505",
    File = "rbxassetid://7734138954",
    Script = "rbxassetid://7743870318",
    
    -- Social
    User = "rbxassetid://7743880442",
    
    -- Misc
    ArrowDown = "rbxassetid://7734132312",
    ArrowUp = "rbxassetid://7734127890",
    Check = "rbxassetid://7734136700"
}

-- Available themes
TBD.Themes = {
    Default = {
        Primary = Color3.fromRGB(30, 30, 30),
        Secondary = Color3.fromRGB(25, 25, 25),
        Background = Color3.fromRGB(20, 20, 20),
        TextPrimary = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(175, 175, 175),
        Accent = Color3.fromRGB(15, 175, 235),
        DarkAccent = Color3.fromRGB(10, 150, 200),
        Error = Color3.fromRGB(255, 50, 50),
        Success = Color3.fromRGB(50, 200, 80),
        Warning = Color3.fromRGB(255, 175, 50)
    },
    Midnight = {
        Primary = Color3.fromRGB(25, 27, 35),
        Secondary = Color3.fromRGB(20, 22, 30),
        Background = Color3.fromRGB(15, 17, 25),
        TextPrimary = Color3.fromRGB(230, 230, 250),
        TextSecondary = Color3.fromRGB(160, 160, 190),
        Accent = Color3.fromRGB(90, 100, 240),
        DarkAccent = Color3.fromRGB(80, 90, 220),
        Error = Color3.fromRGB(240, 60, 60),
        Success = Color3.fromRGB(60, 200, 80),
        Warning = Color3.fromRGB(255, 180, 70)
    },
    Neon = {
        Primary = Color3.fromRGB(15, 15, 20),
        Secondary = Color3.fromRGB(10, 10, 15),
        Background = Color3.fromRGB(5, 5, 10),
        TextPrimary = Color3.fromRGB(235, 235, 255),
        TextSecondary = Color3.fromRGB(180, 180, 210),
        Accent = Color3.fromRGB(125, 70, 255),
        DarkAccent = Color3.fromRGB(100, 50, 220),
        Error = Color3.fromRGB(255, 65, 140),
        Success = Color3.fromRGB(55, 240, 155),
        Warning = Color3.fromRGB(255, 170, 55)
    },
    Aqua = {
        Primary = Color3.fromRGB(20, 30, 40),
        Secondary = Color3.fromRGB(15, 25, 35),
        Background = Color3.fromRGB(10, 20, 30),
        TextPrimary = Color3.fromRGB(230, 240, 245),
        TextSecondary = Color3.fromRGB(170, 190, 210),
        Accent = Color3.fromRGB(40, 180, 200),
        DarkAccent = Color3.fromRGB(30, 160, 180),
        Error = Color3.fromRGB(255, 75, 75),
        Success = Color3.fromRGB(50, 210, 120),
        Warning = Color3.fromRGB(255, 190, 60)
    },
    HoHo = {
        Primary = Color3.fromRGB(20, 20, 20),
        Secondary = Color3.fromRGB(15, 15, 15),
        Background = Color3.fromRGB(10, 10, 10),
        TextPrimary = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(190, 190, 190),
        Accent = Color3.fromRGB(255, 30, 50),
        DarkAccent = Color3.fromRGB(200, 25, 45),
        Error = Color3.fromRGB(255, 50, 50),
        Success = Color3.fromRGB(40, 200, 90),
        Warning = Color3.fromRGB(255, 170, 30)
    }
}

-- Set current theme
local CurrentTheme = TBD.Themes.HoHo

-- Helper function to create instances
local function Create(class, properties)
    local instance = Instance.new(class)
    
    -- Set properties
    for prop, value in pairs(properties or {}) do
        -- Handle parenting separately
        if prop ~= "Parent" then
            instance[prop] = value
        end
    end
    
    -- Set parent last
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    
    return instance
end

-- Helper function to create tweens
local function Tween(instance, properties, duration, style, direction)
    if not instance then return nil end
    
    -- Check if properties are valid for this instance
    local validProperties = {}
    for prop, value in pairs(properties) do
        if pcall(function() local _ = instance[prop] end) then
            validProperties[prop] = value
        end
    end
    
    -- Only create tween if valid properties exist
    if next(validProperties) then
        local tween = TweenService:Create(
            instance,
            TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
            validProperties
        )
        
        tween:Play()
        return tween
    end
    
    return nil
end

-- Helper to make frames draggable
local function MakeDraggable(frame, handle)
    local dragToggle = nil
    local dragStart = nil
    local startPos = nil
    
    handle = handle or frame
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                  startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        Tween(frame, {Position = position}, 0.1)
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
            if dragToggle then
                updateInput(input)
            end
        end
    end)
end

-- Helper to get text size safely
local function GetTextSize(text, size, font, frameSize)
    local success, result = pcall(function()
        return TextService:GetTextSize(text, size, font, frameSize)
    end)
    
    if success then
        return result
    else
        -- Fallback calculation (approximate)
        return Vector2.new(#text * (size/2), size)
    end
end

-- Helper to register theme-aware objects
function TBD:AddThemeObject(object, colorType, propertyName)
    if not object or not colorType or not CurrentTheme[colorType] then return end
    
    propertyName = propertyName or "BackgroundColor3"
    
    -- Check if property exists on object
    if not pcall(function() local _ = object[propertyName] end) then
        return
    end
    
    -- Set initial color
    object[propertyName] = CurrentTheme[colorType]
    
    -- Add to theme objects
    table.insert(self.ThemeObjects, {
        Object = object,
        ColorType = colorType,
        Property = propertyName
    })
    
    return object
end

-- Helper to get icon
function TBD:GetIcon(iconNameOrId)
    if not iconNameOrId then return nil end
    
    -- Check if it's already an asset ID
    if typeof(iconNameOrId) == "string" and string.match(iconNameOrId, "^rbxassetid://") then
        return iconNameOrId
    end
    
    -- Check if it's a named icon
    if typeof(iconNameOrId) == "string" and Icons[iconNameOrId] then
        return Icons[iconNameOrId]
    end
    
    -- Add rbxassetid prefix if needed
    if typeof(iconNameOrId) == "number" or (typeof(iconNameOrId) == "string" and tonumber(iconNameOrId)) then
        return "rbxassetid://" .. tostring(iconNameOrId)
    end
    
    -- Default icon
    return Icons.Home
end

-- Custom theme function
function TBD:CustomTheme(theme)
    if not theme then return CurrentTheme end
    
    -- Create custom theme
    local newTheme = {
        Primary = theme.Primary or CurrentTheme.Primary,
        Secondary = theme.Secondary or CurrentTheme.Secondary,
        Background = theme.Background or CurrentTheme.Background,
        TextPrimary = theme.TextPrimary or CurrentTheme.TextPrimary,
        TextSecondary = theme.TextSecondary or CurrentTheme.TextSecondary,
        Accent = theme.Accent or CurrentTheme.Accent,
        DarkAccent = theme.DarkAccent or CurrentTheme.DarkAccent,
        Error = theme.Error or CurrentTheme.Error,
        Success = theme.Success or CurrentTheme.Success,
        Warning = theme.Warning or CurrentTheme.Warning
    }
    
    -- Add to themes
    self.Themes.Custom = newTheme
    
    return newTheme
end

-- Set theme function
function TBD:SetTheme(themeName)
    if not self.Themes[themeName] then return end
    
    -- Update current theme
    CurrentTheme = self.Themes[themeName]
    
    -- Update all theme objects
    for _, obj in ipairs(self.ThemeObjects) do
        if obj.Object and obj.Object.Parent then
            pcall(function()
                Tween(obj.Object, {[obj.Property] = CurrentTheme[obj.ColorType]}, 0.3)
            end)
        end
    end
end

-- Create notification container
local NotificationSystem = {}

function NotificationSystem:Setup()
    -- Create notification container
    local notificationGui = Create("ScreenGui", {
        Name = "TBD_Notifications",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 100
    })
    
    -- Try to parent to CoreGui safely
    pcall(function()
        notificationGui.Parent = CoreGui
    end)
    
    -- Fallback parent
    if not notificationGui.Parent then
        notificationGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Main container
    self.ScreenGui = notificationGui
    
    -- Create notification holder
    local notificationHolder = Create("Frame", {
        Name = "NotificationHolder",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 1, -20),
        AnchorPoint = Vector2.new(1, 1),
        Size = UDim2.new(0, 300, 1, -40),
        Parent = notificationGui
    })
    
    self.NotificationHolder = notificationHolder
    
    -- Create list layout for notifications
    local listLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = notificationHolder
    })
    
    -- Create padding
    local padding = Create("UIPadding", {
        PaddingRight = UDim.new(0, 0),
        PaddingBottom = UDim.new(0, 0),
        Parent = notificationHolder
    })
end

-- Notification function
function NotificationSystem:Notify(options)
    if not self.NotificationHolder then
        self:Setup()
    end
    
    options = options or {}
    local title = options.Title or "Notification"
    local message = options.Message or ""
    local duration = options.Duration or options.Time or 5
    local type = options.Type or "Info"
    
    -- Get appropriate colors
    local typeColors = {
        Success = CurrentTheme.Success,
        Error = CurrentTheme.Error,
        Warning = CurrentTheme.Warning,
        Info = CurrentTheme.Accent
    }
    
    local typeColor = typeColors[type] or typeColors.Info
    
    -- Create notification frame
    local notification = Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 300, 0, 0),
        Size = UDim2.new(0, 300, 0, 80),
        Parent = self.NotificationHolder,
        ZIndex = 10
    })
    
    -- Add corner
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = notification
    })
    
    -- Notification icon and title bar
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = CurrentTheme.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = 11,
        Parent = notification
    })
    
    local titleCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = titleBar
    })
    
    local titleFix = Create("Frame", {
        Name = "TitleFix",
        BackgroundColor3 = CurrentTheme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -6),
        Size = UDim2.new(1, 0, 0, 6),
        ZIndex = 11,
        Parent = titleBar
    })
    
    local icon = Create("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = Icons[type] or Icons.Notification,
        ImageColor3 = typeColor,
        ZIndex = 12,
        Parent = titleBar
    })
    
    local titleText = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Font = TBD.Font,
        Text = title,
        TextColor3 = CurrentTheme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
        Parent = titleBar
    })
    
    local closeButton = Create("ImageButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -24, 0, 8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = Icons.Close,
        ImageColor3 = CurrentTheme.TextPrimary,
        ZIndex = 12,
        Parent = titleBar
    })
    
    -- Message content
    local messageText = Create("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 35),
        Size = UDim2.new(1, -20, 0, 40),
        Font = TBD.SecondaryFont,
        Text = message,
        TextColor3 = CurrentTheme.TextSecondary,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 11,
        Parent = notification
    })
    
    -- Adjust size based on text
    local textSize = GetTextSize(message, 14, TBD.SecondaryFont, Vector2.new(280, math.huge))
    local height = math.max(80, 40 + textSize.Y)
    notification.Size = UDim2.new(0, 300, 0, height)
    
    -- Animation
    notification.Position = UDim2.new(1, 300, 0, 0)
    Tween(notification, {Position = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back)
    
    -- Close button functionality
    local function closeNotification()
        Tween(notification, {Position = UDim2.new(1, 300, 0, 0)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        delay(0.3, function()
            notification:Destroy()
        end)
    end
    
    closeButton.MouseButton1Click:Connect(closeNotification)
    
    -- Auto close after duration
    delay(duration, closeNotification)
    
    return notification
end

-- Add notification method to main library
function TBD:Notification(options)
    return NotificationSystem:Notify(options)
end

-- Create window function
function TBD:CreateWindow(options)
    options = options or {}
    options.Title = options.Title or "TBD Script Hub"
    options.Subtitle = options.Subtitle or ("v" .. self.Version)
    options.Theme = options.Theme or "HoHo"
    options.ShowHomePage = (options.ShowHomePage ~= nil) and options.ShowHomePage or true
    options.LoadingEnabled = (options.LoadingEnabled ~= nil) and options.LoadingEnabled or false
    options.Size = options.Size or {600, 350}
    
    -- Set theme
    if self.Themes[options.Theme] then
        CurrentTheme = self.Themes[options.Theme]
    end
    
    -- Create container
    local screenGui = Create("ScreenGui", {
        Name = "TBD_Window_" .. #self.Windows + 1,
        DisplayOrder = 100,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Try to parent to CoreGui safely
    pcall(function()
        screenGui.Parent = CoreGui
    end)
    
    -- Fallback parent
    if not screenGui.Parent then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Main window frame
    local window = Create("Frame", {
        Name = "Window",
        BackgroundColor3 = CurrentTheme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -(options.Size[1] / 2), 0.5, -(options.Size[2] / 2)),
        Size = UDim2.new(0, options.Size[1], 0, options.Size[2]),
        Parent = screenGui,
        ClipsDescendants = true
    })
    
    -- Register theme object
    self:AddThemeObject(window, "Background")
    
    -- Add corner
    local windowCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = window
    })
    
    -- Window shadow
    local windowShadow = Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 30, 1, 30),
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = window,
        ZIndex = 0
    })
    
    -- Top bar
    local topBar = Create("Frame", {
        Name = "TopBar",
        BackgroundColor3 = CurrentTheme.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35),
        Parent = window,
        ZIndex = 2
    })
    
    -- Register theme object
    self:AddThemeObject(topBar, "Primary")
    
    -- Add corner to top bar
    local topBarCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = topBar
    })
    
    -- Bottom fix for top bar
    local topBarFix = Create("Frame", {
        Name = "Fix",
        BackgroundColor3 = CurrentTheme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -6),
        Size = UDim2.new(1, 0, 0, 6),
        Parent = topBar,
        ZIndex = 2
    })
    
    -- Register theme object
    self:AddThemeObject(topBarFix, "Primary")
    
    -- Title text
    local title = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = TBD.Font,
        Text = options.Title,
        TextColor3 = CurrentTheme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar,
        ZIndex = 3
    })
    
    -- Register theme object
    self:AddThemeObject(title, "TextPrimary", "TextColor3")
    
    -- Subtitle text
    local subtitle = Create("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -200, 0, 0),
        Size = UDim2.new(0, 180, 1, 0),
        Font = TBD.SecondaryFont,
        Text = options.Subtitle,
        TextColor3 = CurrentTheme.TextSecondary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = topBar,
        ZIndex = 3
    })
    
    -- Register theme object
    self:AddThemeObject(subtitle, "TextSecondary", "TextColor3")
    
    -- Close button
    local closeButton = Create("ImageButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0, 8),
        Size = UDim2.new(0, 18, 0, 18),
        Image = Icons.Close,
        ImageColor3 = CurrentTheme.TextPrimary,
        Parent = topBar,
        ZIndex = 3
    })
    
    -- Register theme object
    self:AddThemeObject(closeButton, "TextPrimary", "ImageColor3")
    
    -- Minimize button
    local minimizeButton = Create("ImageButton", {
        Name = "MinimizeButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -50, 0, 8),
        Size = UDim2.new(0, 18, 0, 18),
        Image = Icons.Minimize,
        ImageColor3 = CurrentTheme.TextPrimary,
        Parent = topBar,
        ZIndex = 3
    })
    
    -- Register theme object
    self:AddThemeObject(minimizeButton, "TextPrimary", "ImageColor3")
    
    -- Make window draggable
    MakeDraggable(window, topBar)
    
    -- Sidebar
    local sidebar = Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(0, 150, 1, -35),
        Parent = window,
        ZIndex = 2
    })
    
    -- Register theme object
    self:AddThemeObject(sidebar, "Secondary")
    
    -- Add corner to sidebar
    local sidebarCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = sidebar
    })
    
    -- Fix for sidebar corners
    local sidebarTopFix = Create("Frame", {
        Name = "TopFix",
        BackgroundColor3 = CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 6),
        Parent = sidebar,
        ZIndex = 2
    })
    
    -- Register theme object
    self:AddThemeObject(sidebarTopFix, "Secondary")
    
    local sidebarRightFix = Create("Frame", {
        Name = "RightFix",
        BackgroundColor3 = CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -6, 0, 0),
        Size = UDim2.new(0, 6, 1, 0),
        Parent = sidebar,
        ZIndex = 2
    })
    
    -- Register theme object
    self:AddThemeObject(sidebarRightFix, "Secondary")
    
    -- Tab container
    local tabContainer = Create("ScrollingFrame", {
        Name = "TabContainer",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = CurrentTheme.Accent,
        ScrollBarImageTransparency = 0.5,
        VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left,
        Parent = sidebar,
        ZIndex = 3
    })
    
    -- Tab list layout
    local tabListLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabContainer
    })
    
    local tabPadding = Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = tabContainer
    })
    
    -- Auto-size canvas
    tabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContainer.CanvasSize = UDim2.new(0, 0, 0, tabListLayout.AbsoluteContentSize.Y + 16)
    end)
    
    -- Content area
    local contentArea = Create("Frame", {
        Name = "ContentArea",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 150, 0, 35),
        Size = UDim2.new(1, -150, 1, -35),
        Parent = window,
        ZIndex = 2
    })
    
    -- Home page
    local homePage = nil
    if options.ShowHomePage then
        homePage = Create("ScrollingFrame", {
            Name = "HomePage",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = CurrentTheme.Accent,
            ScrollBarImageTransparency = 0.5,
            Parent = contentArea,
            ZIndex = 3,
            Visible = true
        })
        
        local homeListLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = homePage
        })
        
        local homePadding = Create("UIPadding", {
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            Parent = homePage
        })
        
        -- Auto-size canvas
        homeListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            homePage.CanvasSize = UDim2.new(0, 0, 0, homeListLayout.AbsoluteContentSize.Y + 30)
        end)
        
        -- Player info section
        local playerSection = Create("Frame", {
            Name = "PlayerSection",
            BackgroundColor3 = CurrentTheme.Primary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 90),
            Parent = homePage,
            LayoutOrder = 1,
            ZIndex = 4
        })
        
        -- Register theme object
        self:AddThemeObject(playerSection, "Primary")
        
        local playerSectionCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = playerSection
        })
        
        -- Try to get player avatar image
        local avatarImage = "rbxassetid://7743878152" -- Default avatar
        local playerName = "Player"
        local displayName = "Player"
        
        pcall(function()
            playerName = LocalPlayer.Name
            displayName = LocalPlayer.DisplayName
            
            -- Try to get avatar thumbnail
            local thumbnail = Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size420x420
            )
            
            if thumbnail then
                avatarImage = thumbnail
            end
        end)
        
        -- Avatar image
        local avatar = Create("ImageLabel", {
            Name = "Avatar",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(0, 70, 0, 70),
            Image = avatarImage,
            Parent = playerSection,
            ZIndex = 5
        })
        
        local avatarCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = avatar
        })
        
        -- Player name
        local nameLabel = Create("TextLabel", {
            Name = "Name",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 90, 0, 15),
            Size = UDim2.new(1, -100, 0, 20),
            Font = TBD.Font,
            Text = displayName,
            TextColor3 = CurrentTheme.TextPrimary,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = playerSection,
            ZIndex = 5
        })
        
        -- Register theme object
        self:AddThemeObject(nameLabel, "TextPrimary", "TextColor3")
        
        -- Username
        local usernameLabel = Create("TextLabel", {
            Name = "Username",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 90, 0, 35),
            Size = UDim2.new(1, -100, 0, 20),
            Font = TBD.SecondaryFont,
            Text = "@" .. playerName,
            TextColor3 = CurrentTheme.TextSecondary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = playerSection,
            ZIndex = 5
        })
        
        -- Register theme object
        self:AddThemeObject(usernameLabel, "TextSecondary", "TextColor3")
        
        -- Game name
        local gameName = "Game"
        pcall(function()
            local gameInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
            if gameInfo and gameInfo.Name then
                gameName = gameInfo.Name
            end
        end)
        
        local gameLabel = Create("TextLabel", {
            Name = "Game",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 90, 0, 55),
            Size = UDim2.new(1, -100, 0, 20),
            Font = TBD.SecondaryFont,
            Text = "Playing: " .. gameName,
            TextColor3 = CurrentTheme.TextSecondary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = playerSection,
            ZIndex = 5
        })
        
        -- Register theme object
        self:AddThemeObject(gameLabel, "TextSecondary", "TextColor3")
        
        -- Welcome section
        local welcomeSection = Create("Frame", {
            Name = "WelcomeSection",
            BackgroundColor3 = CurrentTheme.Primary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 80),
            Parent = homePage,
            LayoutOrder = 2,
            ZIndex = 4
        })
        
        -- Register theme object
        self:AddThemeObject(welcomeSection, "Primary")
        
        local welcomeSectionCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = welcomeSection
        })
        
        -- Welcome title
        local welcomeTitle = Create("TextLabel", {
            Name = "Welcome",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -20, 0, 25),
            Font = TBD.Font,
            Text = "Welcome to " .. options.Title,
            TextColor3 = CurrentTheme.TextPrimary,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = welcomeSection,
            ZIndex = 5
        })
        
        -- Register theme object
        self:AddThemeObject(welcomeTitle, "TextPrimary", "TextColor3")
        
        -- Welcome description
        local welcomeDesc = Create("TextLabel", {
            Name = "Description",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 35),
            Size = UDim2.new(1, -20, 0, 40),
            Font = TBD.SecondaryFont,
            Text = "Select a tab from the sidebar to begin using the script hub.",
            TextColor3 = CurrentTheme.TextSecondary,
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = welcomeSection,
            ZIndex = 5
        })
        
        -- Register theme object
        self:AddThemeObject(welcomeDesc, "TextSecondary", "TextColor3")
    end
    
    -- Loading screen
    local loadingScreen = nil
    if options.LoadingEnabled then
        loadingScreen = Create("Frame", {
            Name = "LoadingScreen",
            BackgroundColor3 = CurrentTheme.Background,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 10,
            Parent = window
        })
        
        -- Register theme object
        self:AddThemeObject(loadingScreen, "Background")
        
        local loadingCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = loadingScreen
        })
        
        local loadingTitle = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.3, 0),
            Size = UDim2.new(1, 0, 0, 40),
            Font = TBD.Font,
            Text = options.Title,
            TextColor3 = CurrentTheme.TextPrimary,
            TextSize = 24,
            Parent = loadingScreen,
            ZIndex = 11
        })
        
        -- Register theme object
        self:AddThemeObject(loadingTitle, "TextPrimary", "TextColor3")
        
        local loadingSubtitle = Create("TextLabel", {
            Name = "Subtitle",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.3, 40),
            Size = UDim2.new(1, 0, 0, 20),
            Font = TBD.SecondaryFont,
            Text = options.Subtitle,
            TextColor3 = CurrentTheme.TextSecondary,
            TextSize = 16,
            Parent = loadingScreen,
            ZIndex = 11
        })
        
        -- Register theme object
        self:AddThemeObject(loadingSubtitle, "TextSecondary", "TextColor3")
        
        local loadingBar = Create("Frame", {
            Name = "LoadingBar",
            BackgroundColor3 = CurrentTheme.Secondary,
            BorderSizePixel = 0,
            Position = UDim2.new(0.25, 0, 0.6, 0),
            Size = UDim2.new(0.5, 0, 0, 6),
            Parent = loadingScreen,
            ZIndex = 11
        })
        
        -- Register theme object
        self:AddThemeObject(loadingBar, "Secondary")
        
        local loadingBarCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 3),
            Parent = loadingBar
        })
        
        local loadingFill = Create("Frame", {
            Name = "Fill",
            BackgroundColor3 = CurrentTheme.Accent,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 0, 1, 0),
            Parent = loadingBar,
            ZIndex = 11
        })
        
        -- Register theme object
        self:AddThemeObject(loadingFill, "Accent")
        
        local loadingFillCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 3),
            Parent = loadingFill
        })
        
        local loadingText = Create("TextLabel", {
            Name = "LoadingText",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.6, 15),
            Size = UDim2.new(1, 0, 0, 20),
            Font = TBD.SecondaryFont,
            Text = "Loading...",
            TextColor3 = CurrentTheme.TextSecondary,
            TextSize = 14,
            Parent = loadingScreen,
            ZIndex = 11
        })
        
        -- Register theme object
        self:AddThemeObject(loadingText, "TextSecondary", "TextColor3")
        
        -- Loading animation
        spawn(function()
            local loadingSteps = {
                "Initializing...",
                "Loading assets...",
                "Preparing interface...",
                "Almost ready..."
            }
            
            for i = 1, 100 do
                local step = math.ceil((i/100) * #loadingSteps)
                loadingText.Text = loadingSteps[step]
                Tween(loadingFill, {Size = UDim2.new(i/100, 0, 1, 0)}, 0.03)
                
                if i % 25 == 0 then
                    wait(0.2)
                else
                    wait(0.02)
                end
            end
            
            wait(0.5)
            Tween(loadingScreen, {BackgroundTransparency = 1}, 0.5)
            Tween(loadingTitle, {TextTransparency = 1}, 0.5)
            Tween(loadingSubtitle, {TextTransparency = 1}, 0.5)
            Tween(loadingBar, {BackgroundTransparency = 1}, 0.5)
            Tween(loadingFill, {BackgroundTransparency = 1}, 0.5)
            Tween(loadingText, {TextTransparency = 1}, 0.5)
            
            wait(0.5)
            loadingScreen.Visible = false
        end)
    end
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        Tween(window, {Position = UDim2.new(0.5, -(options.Size[1] / 2), 1.5, 0)}, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        wait(0.5)
        screenGui:Destroy()
    end)
    
    -- Minimize button functionality
    local minimized = false
    local originalSize = window.Size
    
    minimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        
        if minimized then
            Tween(window, {Size = UDim2.new(0, options.Size[1], 0, 35)}, 0.5, Enum.EasingStyle.Quart)
            
            -- Hide content
            for _, child in pairs(contentArea:GetChildren()) do
                child.Visible = false
            end
        else
            Tween(window, {Size = originalSize}, 0.5, Enum.EasingStyle.Quart)
            wait(0.5)
            
            -- Show selected content
            for _, child in pairs(contentArea:GetChildren()) do
                if child.Name == "ActiveTab" then
                    child.Visible = true
                    return
                end
            end
            
            -- If no tab is selected, show home page
            if homePage then
                homePage.Visible = true
            end
        end
    end)
    
    -- Window object
    local windowObj = {}
    windowObj.ScreenGui = screenGui
    windowObj.Window = window
    windowObj.Tabs = {}
    windowObj.TabCount = 0
    windowObj.ActiveTab = nil
    
    -- Add to library windows
    table.insert(self.Windows, windowObj)
    
    -- Create tab function
    function windowObj:CreateTab(options)
        options = options or {}
        options.Name = options.Name or "Tab"
        options.Icon = options.Icon or "Home"
        
        -- Get icon image
        local iconImage = TBD:GetIcon(options.Icon)
        
        -- Create tab button
        local tabButton = Create("TextButton", {
            Name = options.Name .. "Button",
            BackgroundColor3 = CurrentTheme.Secondary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 36),
            Text = "",
            Parent = tabContainer,
            ZIndex = 4,
            LayoutOrder = self.TabCount
        })
        
        -- Register theme object
        TBD:AddThemeObject(tabButton, "Secondary")
        
        local tabButtonCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = tabButton
        })
        
        local tabIcon = Create("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(0, 20, 0, 20),
            Image = iconImage,
            ImageColor3 = CurrentTheme.TextSecondary,
            Parent = tabButton,
            ZIndex = 5
        })
        
        -- Register theme object
        TBD:AddThemeObject(tabIcon, "TextSecondary", "ImageColor3")
        
        local tabName = Create("TextLabel", {
            Name = "Name",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 36, 0, 0),
            Size = UDim2.new(1, -44, 1, 0),
            Font = TBD.Font,
            Text = options.Name,
            TextColor3 = CurrentTheme.TextSecondary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabButton,
            ZIndex = 5
        })
        
        -- Register theme object
        TBD:AddThemeObject(tabName, "TextSecondary", "TextColor3")
        
        -- Create tab content
        local tabContent = Create("ScrollingFrame", {
            Name = options.Name .. "Content",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = CurrentTheme.Accent,
            ScrollBarImageTransparency = 0.5,
            Parent = contentArea,
            ZIndex = 3,
            Visible = false
        })
        
        -- Register theme object
        TBD:AddThemeObject(tabContent, "Accent", "ScrollBarImageColor3")
        
        local contentListLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = tabContent
        })
        
        local contentPadding = Create("UIPadding", {
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            Parent = tabContent
        })
        
        -- Auto-size canvas
        contentListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentListLayout.AbsoluteContentSize.Y + 30)
        end)
        
        -- Tab button functionality
        tabButton.MouseButton1Click:Connect(function()
            -- Deselect current tab
            if self.ActiveTab then
                Tween(self.ActiveTab.Button, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
                Tween(self.ActiveTab.Icon, {ImageColor3 = CurrentTheme.TextSecondary}, 0.2)
                Tween(self.ActiveTab.Name, {TextColor3 = CurrentTheme.TextSecondary}, 0.2)
                self.ActiveTab.Content.Visible = false
                
                if self.ActiveTab.Content.Name == "ActiveTab" then
                    self.ActiveTab.Content.Name = self.ActiveTab.Name .. "Content"
                end
            end
            
            -- Hide home page if visible
            if homePage and homePage.Visible then
                homePage.Visible = false
            end
            
            -- Select new tab
            self.ActiveTab = {
                Button = tabButton,
                Icon = tabIcon,
                Name = tabName,
                Content = tabContent
            }
            
            Tween(tabButton, {BackgroundColor3 = CurrentTheme.Accent}, 0.2)
            Tween(tabIcon, {ImageColor3 = CurrentTheme.TextPrimary}, 0.2)
            Tween(tabName, {TextColor3 = CurrentTheme.TextPrimary}, 0.2)
            tabContent.Visible = true
            tabContent.Name = "ActiveTab"
        end)
        
        -- Tab hover effects
        tabButton.MouseEnter:Connect(function()
            if self.ActiveTab and self.ActiveTab.Button == tabButton then
                return
            end
            
            Tween(tabButton, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
        end)
        
        tabButton.MouseLeave:Connect(function()
            if self.ActiveTab and self.ActiveTab.Button == tabButton then
                return
            end
            
            Tween(tabButton, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
        end)
        
        -- Increment tab count
        self.TabCount = self.TabCount + 1
        
        -- Tab object
        local tab = {}
        tab.Button = tabButton
        tab.Content = tabContent
        tab.Name = options.Name
        
        -- Create section
        function tab:CreateSection(title)
            -- Create section label
            local section = Create("Frame", {
                Name = title .. "Section",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 35),
                Parent = self.Content,
                LayoutOrder = #self.Content:GetChildren(),
                ZIndex = 4
            })
            
            local sectionLabel = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Font = TBD.Font,
                Text = title,
                TextColor3 = CurrentTheme.TextPrimary,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = section,
                ZIndex = 5
            })
            
            -- Register theme object
            TBD:AddThemeObject(sectionLabel, "TextPrimary", "TextColor3")
            
            local sectionDivider = Create("Frame", {
                Name = "Divider",
                BackgroundColor3 = CurrentTheme.Primary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 25),
                Size = UDim2.new(1, 0, 0, 2),
                Parent = section,
                ZIndex = 5
            })
            
            -- Register theme object
            TBD:AddThemeObject(sectionDivider, "Primary")
            
            return section
        end
        
        -- Create button
        function tab:CreateButton(options)
            options = options or {}
            options.Name = options.Name or "Button"
            options.Description = options.Description
            options.Callback = options.Callback or function() end
            
            -- Determine height based on description
            local buttonHeight = options.Description and 60 or 36
            
            -- Create button
            local button = Create("Frame", {
                Name = options.Name .. "Button",
                BackgroundColor3 = CurrentTheme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, buttonHeight),
                Parent = self.Content,
                LayoutOrder = #self.Content:GetChildren(),
                ZIndex = 4
            })
            
            -- Register theme object
            TBD:AddThemeObject(button, "Primary")
            
            local buttonCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = button
            })
            
            local buttonLabel = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 36),
                Font = TBD.Font,
                Text = options.Name,
                TextColor3 = CurrentTheme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = button,
                ZIndex = 5
            })
            
            -- Register theme object
            TBD:AddThemeObject(buttonLabel, "TextPrimary", "TextColor3")
            
            -- Add description if provided
            if options.Description then
                buttonLabel.Size = UDim2.new(1, -20, 0, 25)
                buttonLabel.Position = UDim2.new(0, 10, 0, 8)
                
                local description = Create("TextLabel", {
                    Name = "Description",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = TBD.SecondaryFont,
                    Text = options.Description,
                    TextColor3 = CurrentTheme.TextSecondary,
                    TextSize = 12,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = button,
                    ZIndex = 5
                })
                
                -- Register theme object
                TBD:AddThemeObject(description, "TextSecondary", "TextColor3")
            end
            
            -- Add click functionality
            local clickButton = Create("TextButton", {
                Name = "ClickButton",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                Parent = button,
                ZIndex = 6
            })
            
            clickButton.MouseButton1Click:Connect(function()
                -- Visual feedback
                Tween(button, {BackgroundColor3 = CurrentTheme.Accent}, 0.2)
                
                -- Execute callback
                pcall(options.Callback)
                
                -- Visual reset
                Tween(button, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
            end)
            
            -- Hover effects
            clickButton.MouseEnter:Connect(function()
                Tween(button, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
            end)
            
            clickButton.MouseLeave:Connect(function()
                Tween(button, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
            end)
            
            return button
        end
        
        -- Create toggle
        function tab:CreateToggle(options)
            options = options or {}
            options.Name = options.Name or "Toggle"
            options.Description = options.Description
            options.CurrentValue = type(options.CurrentValue) == "boolean" and options.CurrentValue or false
            options.Callback = options.Callback or function() end
            
            -- Determine height based on description
            local toggleHeight = options.Description and 60 or 36
            
            -- Create toggle
            local toggle = Create("Frame", {
                Name = options.Name .. "Toggle",
                BackgroundColor3 = CurrentTheme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, toggleHeight),
                Parent = self.Content,
                LayoutOrder = #self.Content:GetChildren(),
                ZIndex = 4
            })
            
            -- Register theme object
            TBD:AddThemeObject(toggle, "Primary")
            
            local toggleCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = toggle
            })
            
            local toggleLabel = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -66, 0, 36),
                Font = TBD.Font,
                Text = options.Name,
                TextColor3 = CurrentTheme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggle,
                ZIndex = 5
            })
            
            -- Register theme object
            TBD:AddThemeObject(toggleLabel, "TextPrimary", "TextColor3")
            
            -- Add description if provided
            if options.Description then
                toggleLabel.Size = UDim2.new(1, -66, 0, 25)
                toggleLabel.Position = UDim2.new(0, 10, 0, 8)
                
                local description = Create("TextLabel", {
                    Name = "Description",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -66, 0, 20),
                    Font = TBD.SecondaryFont,
                    Text = options.Description,
                    TextColor3 = CurrentTheme.TextSecondary,
                    TextSize = 12,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = toggle,
                    ZIndex = 5
                })
                
                -- Register theme object
                TBD:AddThemeObject(description, "TextSecondary", "TextColor3")
            end
            
            -- Toggle indicator
            local toggleIndicator = Create("Frame", {
                Name = "Indicator",
                BackgroundColor3 = CurrentTheme.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -56, 0.5, -10),
                Size = UDim2.new(0, 46, 0, 20),
                Parent = toggle,
                ZIndex = 6
            })
            
            -- Register theme object
            TBD:AddThemeObject(toggleIndicator, "Secondary")
            
            local toggleIndicatorCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggleIndicator
            })
            
            local toggleSwitch = Create("Frame", {
                Name = "Switch",
                BackgroundColor3 = CurrentTheme.TextPrimary,
                BorderSizePixel = 0,
                Position = options.CurrentValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Parent = toggleIndicator,
                ZIndex = 7
            })
            
            -- Register theme object
            TBD:AddThemeObject(toggleSwitch, "TextPrimary")
            
            local toggleSwitchCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggleSwitch
            })
            
            -- Update toggle state
            local toggled = options.CurrentValue
            
            -- Initial appearance
            if toggled then
                toggleIndicator.BackgroundColor3 = CurrentTheme.Accent
            end
            
            -- Add click functionality
            local clickButton = Create("TextButton", {
                Name = "ClickButton",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                Parent = toggle,
                ZIndex = 8
            })
            
            clickButton.MouseButton1Click:Connect(function()
                -- Toggle state
                toggled = not toggled
                
                -- Update appearance
                if toggled then
                    Tween(toggleIndicator, {BackgroundColor3 = CurrentTheme.Accent}, 0.2)
                    Tween(toggleSwitch, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.2)
                else
                    Tween(toggleIndicator, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
                    Tween(toggleSwitch, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
                end
                
                -- Execute callback
                pcall(function() options.Callback(toggled) end)
            end)
            
            -- Hover effects
            clickButton.MouseEnter:Connect(function()
                Tween(toggle, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
            end)
            
            clickButton.MouseLeave:Connect(function()
                Tween(toggle, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
            end)
            
            -- Call callback initially if starting as enabled
            if options.CurrentValue then
                pcall(function() options.Callback(true) end)
            end
            
            local toggleObj = {}
            
            function toggleObj:Set(value)
                toggled = value
                
                if toggled then
                    Tween(toggleIndicator, {BackgroundColor3 = CurrentTheme.Accent}, 0.2)
                    Tween(toggleSwitch, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.2)
                else
                    Tween(toggleIndicator, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
                    Tween(toggleSwitch, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
                end
                
                pcall(function() options.Callback(toggled) end)
            end
            
            return toggleObj
        end
        
        -- Create slider
        function tab:CreateSlider(options)
            options = options or {}
            options.Name = options.Name or "Slider"
            options.Description = options.Description
            options.Min = options.Min or 0
            options.Max = options.Max or 100
            options.Increment = options.Increment or 1
            options.CurrentValue = options.CurrentValue or options.Min
            options.Callback = options.Callback or function() end
            
            -- Clamp initial value
            options.CurrentValue = math.clamp(options.CurrentValue, options.Min, options.Max)
            
            -- Determine height based on description
            local sliderHeight = options.Description and 70 or 50
            
            -- Create slider
            local slider = Create("Frame", {
                Name = options.Name .. "Slider",
                BackgroundColor3 = CurrentTheme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, sliderHeight),
                Parent = self.Content,
                LayoutOrder = #self.Content:GetChildren(),
                ZIndex = 4
            })
            
            -- Register theme object
            TBD:AddThemeObject(slider, "Primary")
            
            local sliderCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = slider
            })
            
            local sliderLabel = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -70, 0, 30),
                Font = TBD.Font,
                Text = options.Name,
                TextColor3 = CurrentTheme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = slider,
                ZIndex = 5
            })
            
            -- Register theme object
            TBD:AddThemeObject(sliderLabel, "TextPrimary", "TextColor3")
            
            local valueLabel = Create("TextLabel", {
                Name = "Value",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -60, 0, 0),
                Size = UDim2.new(0, 50, 0, 30),
                Font = TBD.SecondaryFont,
                Text = tostring(options.CurrentValue),
                TextColor3 = CurrentTheme.TextSecondary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = slider,
                ZIndex = 5
            })
            
            -- Register theme object
            TBD:AddThemeObject(valueLabel, "TextSecondary", "TextColor3")
            
            -- Add description if provided
            if options.Description then
                sliderLabel.Size = UDim2.new(1, -70, 0, 25)
                sliderLabel.Position = UDim2.new(0, 10, 0, 5)
                valueLabel.Position = UDim2.new(1, -60, 0, 5)
                valueLabel.Size = UDim2.new(0, 50, 0, 25)
                
                local description = Create("TextLabel", {
                    Name = "Description",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 16),
                    Font = TBD.SecondaryFont,
                    Text = options.Description,
                    TextColor3 = CurrentTheme.TextSecondary,
                    TextSize = 12,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = slider,
                    ZIndex = 5
                })
                
                -- Register theme object
                TBD:AddThemeObject(description, "TextSecondary", "TextColor3")
            end
            
            -- Calculate slider y-position based on description
            local sliderYPos = options.Description and 50 or 32
            
            -- Slider track
            local sliderTrack = Create("Frame", {
                Name = "Track",
                BackgroundColor3 = CurrentTheme.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, sliderYPos),
                Size = UDim2.new(1, -20, 0, 4),
                Parent = slider,
                ZIndex = 5
            })
            
            -- Register theme object
            TBD:AddThemeObject(sliderTrack, "Secondary")
            
            local sliderTrackCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderTrack
            })
            
            -- Calculate initial fill percentage
            local initialPct = (options.CurrentValue - options.Min) / (options.Max - options.Min)
            
            -- Slider fill
            local sliderFill = Create("Frame", {
                Name = "Fill",
                BackgroundColor3 = CurrentTheme.Accent,
                BorderSizePixel = 0,
                Size = UDim2.new(initialPct, 0, 1, 0),
                Parent = sliderTrack,
                ZIndex = 6
            })
            
            -- Register theme object
            TBD:AddThemeObject(sliderFill, "Accent")
            
            local sliderFillCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderFill
            })
            
            -- Slider knob
            local sliderKnob = Create("Frame", {
                Name = "Knob",
                BackgroundColor3 = CurrentTheme.TextPrimary,
                BorderSizePixel = 0,
                Position = UDim2.new(initialPct, -6, 0.5, -6),
                Size = UDim2.new(0, 12, 0, 12),
                Parent = sliderTrack,
                ZIndex = 7
            })
            
            -- Register theme object
            TBD:AddThemeObject(sliderKnob, "TextPrimary")
            
            local sliderKnobCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderKnob
            })
            
            -- Slider interaction
            local sliderButton = Create("TextButton", {
                Name = "SliderButton",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                Parent = slider,
                ZIndex = 8
            })
            
            -- Function to update slider value
            local function updateSlider(posX)
                local sliderLen = sliderTrack.AbsoluteSize.X
                local sliderPos = sliderTrack.AbsolutePosition.X
                local relativePos = math.clamp(posX - sliderPos, 0, sliderLen)
                local percentage = relativePos / sliderLen
                
                -- Calculate new value based on percentage
                local newValue = options.Min + ((options.Max - options.Min) * percentage)
                
                -- Apply increment
                if options.Increment > 0 then
                    newValue = options.Min + (math.floor((newValue - options.Min) / options.Increment + 0.5) * options.Increment)
                end
                
                -- Clamp value
                newValue = math.clamp(newValue, options.Min, options.Max)
                
                -- Calculate new percentage based on value
                percentage = (newValue - options.Min) / (options.Max - options.Min)
                
                -- Update UI
                valueLabel.Text = tostring(newValue)
                sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                sliderKnob.Position = UDim2.new(percentage, -6, 0.5, -6)
                
                -- Execute callback
                pcall(function() options.Callback(newValue) end)
            end
            
            sliderButton.MouseButton1Down:Connect(function()
                local mouseMove, mouseRelease
                
                -- Initial update
                updateSlider(UserInputService:GetMouseLocation().X)
                
                mouseMove = UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        updateSlider(input.Position.X)
                    end
                end)
                
                mouseRelease = UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        mouseMove:Disconnect()
                        mouseRelease:Disconnect()
                    end
                end)
            end)
            
            -- Hover effects
            sliderButton.MouseEnter:Connect(function()
                Tween(slider, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
            end)
            
            sliderButton.MouseLeave:Connect(function()
                Tween(slider, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
            end)
            
            -- Call callback initially
            pcall(function() options.Callback(options.CurrentValue) end)
            
            local sliderObj = {}
            
            function sliderObj:Set(value)
                value = math.clamp(value, options.Min, options.Max)
                local percentage = (value - options.Min) / (options.Max - options.Min)
                
                -- Update UI
                valueLabel.Text = tostring(value)
                sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                sliderKnob.Position = UDim2.new(percentage, -6, 0.5, -6)
                
                pcall(function() options.Callback(value) end)
            end
            
            return sliderObj
        end
        
        -- Create dropdown
        function tab:CreateDropdown(options)
            options = options or {}
            options.Name = options.Name or "Dropdown"
            options.Description = options.Description
            options.Items = options.Items or {}
            options.CurrentOption = options.CurrentOption or (options.Items[1] or "")
            options.Callback = options.Callback or function() end
            
            -- Determine height based on description
            local dropdownHeight = options.Description and 60 or 36
            
            -- Create dropdown
            local dropdown = Create("Frame", {
                Name = options.Name .. "Dropdown",
                BackgroundColor3 = CurrentTheme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, dropdownHeight),
                ClipsDescendants = true,
                Parent = self.Content,
                LayoutOrder = #self.Content:GetChildren(),
                ZIndex = 4
            })
            
            -- Register theme object
            TBD:AddThemeObject(dropdown, "Primary")
            
            local dropdownCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = dropdown
            })
            
            local dropdownLabel = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 36),
                Font = TBD.Font,
                Text = options.Name,
                TextColor3 = CurrentTheme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdown,
                ZIndex = 5
            })
            
            -- Register theme object
            TBD:AddThemeObject(dropdownLabel, "TextPrimary", "TextColor3")
            
            -- Add description if provided
            if options.Description then
                dropdownLabel.Size = UDim2.new(1, -20, 0, 25)
                dropdownLabel.Position = UDim2.new(0, 10, 0, 8)
                
                local description = Create("TextLabel", {
                    Name = "Description",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = TBD.SecondaryFont,
                    Text = options.Description,
                    TextColor3 = CurrentTheme.TextSecondary,
                    TextSize = 12,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = dropdown,
                    ZIndex = 5
                })
                
                -- Register theme object
                TBD:AddThemeObject(description, "TextSecondary", "TextColor3")
            end
            
            -- Selection display
            local yPos = dropdownHeight + 5
            
            local selectionBox = Create("Frame", {
                Name = "SelectionBox",
                BackgroundColor3 = CurrentTheme.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, yPos),
                Size = UDim2.new(1, -20, 0, 30),
                Parent = dropdown,
                ZIndex = 6
            })
            
            -- Register theme object
            TBD:AddThemeObject(selectionBox, "Secondary")
            
            local selectionBoxCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = selectionBox
            })
            
            local selectionText = Create("TextLabel", {
                Name = "SelectedOption",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -40, 1, 0),
                Font = TBD.SecondaryFont,
                Text = options.CurrentOption,
                TextColor3 = CurrentTheme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = selectionBox,
                ZIndex = 7
            })
            
            -- Register theme object
            TBD:AddThemeObject(selectionText, "TextPrimary", "TextColor3")
            
            local dropdownArrow = Create("ImageLabel", {
                Name = "Arrow",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -25, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Image = Icons.ArrowDown,
                ImageColor3 = CurrentTheme.TextPrimary,
                Parent = selectionBox,
                ZIndex = 7
            })
            
            -- Register theme object
            TBD:AddThemeObject(dropdownArrow, "TextPrimary", "ImageColor3")
            
            -- Options list
            local optionsFrame = Create("Frame", {
                Name = "OptionsFrame",
                BackgroundColor3 = CurrentTheme.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, yPos + 35),
                Size = UDim2.new(1, -20, 0, 0),
                ClipsDescendants = true,
                Visible = false,
                Parent = dropdown,
                ZIndex = 8
            })
            
            -- Register theme object
            TBD:AddThemeObject(optionsFrame, "Secondary")
            
            local optionsCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = optionsFrame
            })
            
            local optionsList = Create("ScrollingFrame", {
                Name = "OptionsList",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = CurrentTheme.Accent,
                ScrollBarImageTransparency = 0.5,
                Parent = optionsFrame,
                ZIndex = 9
            })
            
            -- Register theme object
            TBD:AddThemeObject(optionsList, "Accent", "ScrollBarImageColor3")
            
            local optionsListLayout = Create("UIListLayout", {
                Padding = UDim.new(0, 5),
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = optionsList
            })
            
            local optionsListPadding = Create("UIPadding", {
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5),
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5),
                Parent = optionsList
            })
            
            -- Auto-size options list
            optionsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                optionsList.CanvasSize = UDim2.new(0, 0, 0, optionsListLayout.AbsoluteContentSize.Y + 10)
            end)
            
            -- Function to populate options
            local function populateOptions(items)
                -- Clear existing options
                for _, child in pairs(optionsList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                -- Add new options
                for i, item in pairs(items) do
                    local option = Create("TextButton", {
                        Name = "Option",
                        BackgroundColor3 = CurrentTheme.Primary,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 30),
                        Font = TBD.SecondaryFont,
                        Text = "",
                        TextColor3 = CurrentTheme.TextPrimary,
                        TextSize = 14,
                        Parent = optionsList,
                        ZIndex = 10,
                        LayoutOrder = i
                    })
                    
                    -- Register theme object
                    TBD:AddThemeObject(option, "Primary")
                    
                    local optionCorner = Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = option
                    })
                    
                    local optionText = Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -20, 1, 0),
                        Font = TBD.SecondaryFont,
                        Text = tostring(item),
                        TextColor3 = CurrentTheme.TextPrimary,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = option,
                        ZIndex = 11
                    })
                    
                    -- Register theme object
                    TBD:AddThemeObject(optionText, "TextPrimary", "TextColor3")
                    
                    -- Option selection
                    option.MouseButton1Click:Connect(function()
                        selectionText.Text = tostring(item)
                        
                        -- Close dropdown
                        Tween(dropdown, {Size = UDim2.new(1, 0, 0, dropdownHeight)}, 0.3)
                        Tween(dropdownArrow, {Rotation = 0}, 0.3)
                        
                        -- Wait for animation
                        wait(0.3)
                        optionsFrame.Visible = false
                        
                        -- Execute callback
                        pcall(function() options.Callback(tostring(item)) end)
                    end)
                    
                    -- Hover effects
                    option.MouseEnter:Connect(function()
                        Tween(option, {BackgroundColor3 = CurrentTheme.Accent}, 0.2)
                    end)
                    
                    option.MouseLeave:Connect(function()
                        Tween(option, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
                    end)
                end
            end
            
            -- Initial population
            populateOptions(options.Items)
            
            -- Dropdown functionality
            local dropdownOpen = false
            
            local dropdownButton = Create("TextButton", {
                Name = "DropdownButton",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, dropdownHeight),
                Text = "",
                Parent = dropdown,
                ZIndex = 12
            })
            
            dropdownButton.MouseButton1Click:Connect(function()
                dropdownOpen = not dropdownOpen
                
                if dropdownOpen then
                    -- Open dropdown
                    optionsFrame.Visible = true
                    
                    -- Calculate height based on options (max 150px)
                    local contentHeight = math.min(optionsListLayout.AbsoluteContentSize.Y + 10, 150)
                    
                    Tween(dropdown, {Size = UDim2.new(1, 0, 0, dropdownHeight + 35 + contentHeight)}, 0.3)
                    Tween(dropdownArrow, {Rotation = 180}, 0.3)
                    Tween(optionsFrame, {Size = UDim2.new(1, -20, 0, contentHeight)}, 0.3)
                else
                    -- Close dropdown
                    Tween(dropdown, {Size = UDim2.new(1, 0, 0, dropdownHeight)}, 0.3)
                    Tween(dropdownArrow, {Rotation = 0}, 0.3)
                    
                    -- Wait for animation
                    wait(0.3)
                    optionsFrame.Visible = false
                end
            end)
            
            -- Hover effects
            dropdownButton.MouseEnter:Connect(function()
                if not dropdownOpen then
                    Tween(dropdown, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
                end
            end)
            
            dropdownButton.MouseLeave:Connect(function()
                if not dropdownOpen then
                    Tween(dropdown, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
                end
            end)
            
            -- Call callback initially
            pcall(function() options.Callback(options.CurrentOption) end)
            
            local dropdownObj = {}
            
            function dropdownObj:Refresh(items)
                populateOptions(items)
                options.Items = items
                
                -- Update UI if open
                if dropdownOpen then
                    local contentHeight = math.min(optionsListLayout.AbsoluteContentSize.Y + 10, 150)
                    Tween(optionsFrame, {Size = UDim2.new(1, -20, 0, contentHeight)}, 0.3)
                    Tween(dropdown, {Size = UDim2.new(1, 0, 0, dropdownHeight + 35 + contentHeight)}, 0.3)
                end
            end
            
            function dropdownObj:SetValue(value)
                selectionText.Text = tostring(value)
                pcall(function() options.Callback(tostring(value)) end)
            end
            
            return dropdownObj
        end
        
        -- Create color picker
        function tab:CreateColorPicker(options)
            options = options or {}
            options.Name = options.Name or "Color Picker"
            options.Description = options.Description
            options.CurrentColor = options.CurrentColor or Color3.fromRGB(255, 255, 255)
            options.Callback = options.Callback or function() end
            
            -- Determine height based on description
            local pickerHeight = options.Description and 60 or 36
            
            -- Create color picker
            local colorPicker = Create("Frame", {
                Name = options.Name .. "ColorPicker",
                BackgroundColor3 = CurrentTheme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, pickerHeight),
                ClipsDescendants = true,
                Parent = self.Content,
                LayoutOrder = #self.Content:GetChildren(),
                ZIndex = 4
            })
            
            -- Register theme object
            TBD:AddThemeObject(colorPicker, "Primary")
            
            local colorPickerCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = colorPicker
            })
            
            local colorPickerLabel = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -70, 0, 36),
                Font = TBD.Font,
                Text = options.Name,
                TextColor3 = CurrentTheme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = colorPicker,
                ZIndex = 5
            })
            
            -- Register theme object
            TBD:AddThemeObject(colorPickerLabel, "TextPrimary", "TextColor3")
            
            -- Add description if provided
            if options.Description then
                colorPickerLabel.Size = UDim2.new(1, -70, 0, 25)
                colorPickerLabel.Position = UDim2.new(0, 10, 0, 8)
                
                local description = Create("TextLabel", {
                    Name = "Description",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -70, 0, 20),
                    Font = TBD.SecondaryFont,
                    Text = options.Description,
                    TextColor3 = CurrentTheme.TextSecondary,
                    TextSize = 12,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = colorPicker,
                    ZIndex = 5
                })
                
                -- Register theme object
                TBD:AddThemeObject(description, "TextSecondary", "TextColor3")
            end
            
            -- Color display
            local colorDisplay = Create("Frame", {
                Name = "ColorDisplay",
                BackgroundColor3 = options.CurrentColor,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -50, 0.5, -10),
                Size = UDim2.new(0, 40, 0, 20),
                Parent = colorPicker,
                ZIndex = 5
            })
            
            local colorDisplayCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = colorDisplay
            })
            
            -- Color picker expanded UI
            local yPos = pickerHeight + 5
            
            local colorPickerUI = Create("Frame", {
                Name = "ColorPickerUI",
                BackgroundColor3 = CurrentTheme.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, yPos),
                Size = UDim2.new(1, -20, 0, 0),
                ClipsDescendants = true,
                Visible = false,
                Parent = colorPicker,
                ZIndex = 6
            })
            
            -- Register theme object
            TBD:AddThemeObject(colorPickerUI, "Secondary")
            
            local colorPickerUICorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = colorPickerUI
            })
            
            -- Convert RGB to HSV for initial color
            local h, s, v = Color3.toHSV(options.CurrentColor)
            
            -- Create the hue slider
            local hueFrame = Create("Frame", {
                Name = "HueFrame",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 10),
                Size = UDim2.new(1, -20, 0, 20),
                Parent = colorPickerUI,
                ZIndex = 7
            })
            
            local hueFrameCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = hueFrame
            })
            
            -- Hue gradient
            local hueGradient = Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                }),
                Parent = hueFrame
            })
            
            -- Hue slider
            local hueSlider = Create("Frame", {
                Name = "HueSlider",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = UDim2.new(h, -2, 0, 0),
                Size = UDim2.new(0, 4, 1, 0),
                Parent = hueFrame,
                ZIndex = 8
            })
            
            local hueSliderCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 2),
                Parent = hueSlider
            })
            
            -- Saturation/Value picker
            local satValFrame = Create("Frame", {
                Name = "SatValFrame",
                BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 40),
                Size = UDim2.new(1, -20, 0, 150),
                Parent = colorPickerUI,
                ZIndex = 7
            })
            
            local satValFrameCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = satValFrame
            })
            
            -- White to transparent gradient (saturation)
            local satGradient = Create("UIGradient", {
                Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                }),
                Parent = satValFrame
            })
            
            -- Black gradient (value)
            local valGradient = Create("Frame", {
                Name = "ValueGradient",
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                Parent = satValFrame,
                ZIndex = 8
            })
            
            local valGradientCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = valGradient
            })
            
            local valGradientTransparency = Create("UIGradient", {
                Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0)),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0)
                }),
                Rotation = 90,
                Parent = valGradient
            })
            
            -- Sat/Val picker
            local satValPicker = Create("Frame", {
                Name = "SatValPicker",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = UDim2.new(s, -5, 1 - v, -5),
                Size = UDim2.new(0, 10, 0, 10),
                Parent = satValFrame,
                ZIndex = 9
            })
            
            local satValPickerCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = satValPicker
            })
            
            -- RGB display
            local rgbFrame = Create("Frame", {
                Name = "RGBDisplay",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 200),
                Size = UDim2.new(1, -20, 0, 20),
                Parent = colorPickerUI,
                ZIndex = 8
            })
            
            local r, g, b = math.floor(options.CurrentColor.R * 255), math.floor(options.CurrentColor.G * 255), math.floor(options.CurrentColor.B * 255)
            
            local rgbText = Create("TextLabel", {
                Name = "RGBText",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = TBD.SecondaryFont,
                Text = string.format("RGB: %d, %d, %d", r, g, b),
                TextColor3 = CurrentTheme.TextPrimary,
                TextSize = 14,
                Parent = rgbFrame,
                ZIndex = 9
            })
            
            -- Register theme object
            TBD:AddThemeObject(rgbText, "TextPrimary", "TextColor3")
            
            -- Functions to update colors
            local function updateHue(hueX)
                h = math.clamp(hueX, 0, 1)
                satValFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                updateColor()
            end
            
            local function updateSatVal(satX, valY)
                s = math.clamp(satX, 0, 1)
                v = math.clamp(valY, 0, 1)
                updateColor()
            end
            
            local function updateColor()
                local color = Color3.fromHSV(h, s, v)
                colorDisplay.BackgroundColor3 = color
                
                local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
                rgbText.Text = string.format("RGB: %d, %d, %d", r, g, b)
                
                pcall(function() options.Callback(color) end)
            end
            
            -- Hue slider interaction
            local function setupHueSlider()
                hueFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local hueX = (input.Position.X - hueFrame.AbsolutePosition.X) / hueFrame.AbsoluteSize.X
                        
                        hueSlider.Position = UDim2.new(hueX, -2, 0, 0)
                        updateHue(hueX)
                        
                        local mouseMove, mouseRelease
                        
                        mouseMove = UserInputService.InputChanged:Connect(function(moveInput)
                            if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                                local newHueX = (moveInput.Position.X - hueFrame.AbsolutePosition.X) / hueFrame.AbsoluteSize.X
                                newHueX = math.clamp(newHueX, 0, 1)
                                
                                hueSlider.Position = UDim2.new(newHueX, -2, 0, 0)
                                updateHue(newHueX)
                            end
                        end)
                        
                        mouseRelease = UserInputService.InputEnded:Connect(function(endInput)
                            if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                                mouseMove:Disconnect()
                                mouseRelease:Disconnect()
                            end
                        end)
                    end
                end)
            end
            
            -- Sat/Val picker interaction
            local function setupSatValPicker()
                satValFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local satX = (input.Position.X - satValFrame.AbsolutePosition.X) / satValFrame.AbsoluteSize.X
                        local valY = 1 - ((input.Position.Y - satValFrame.AbsolutePosition.Y) / satValFrame.AbsoluteSize.Y)
                        
                        satValPicker.Position = UDim2.new(satX, -5, 1 - valY, -5)
                        updateSatVal(satX, valY)
                        
                        local mouseMove, mouseRelease
                        
                        mouseMove = UserInputService.InputChanged:Connect(function(moveInput)
                            if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                                local newSatX = (moveInput.Position.X - satValFrame.AbsolutePosition.X) / satValFrame.AbsoluteSize.X
                                local newValY = 1 - ((moveInput.Position.Y - satValFrame.AbsolutePosition.Y) / satValFrame.AbsoluteSize.Y)
                                
                                newSatX = math.clamp(newSatX, 0, 1)
                                newValY = math.clamp(newValY, 0, 1)
                                
                                satValPicker.Position = UDim2.new(newSatX, -5, 1 - newValY, -5)
                                updateSatVal(newSatX, newValY)
                            end
                        end)
                        
                        mouseRelease = UserInputService.InputEnded:Connect(function(endInput)
                            if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                                mouseMove:Disconnect()
                                mouseRelease:Disconnect()
                            end
                        end)
                    end
                end)
            end
            
            -- Setup interactions when visible
            colorPickerUI:GetPropertyChangedSignal("Visible"):Connect(function()
                if colorPickerUI.Visible then
                    setupHueSlider()
                    setupSatValPicker()
                end
            end)
            
            -- Color picker button
            local colorPickerButton = Create("TextButton", {
                Name = "ColorPickerButton",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, pickerHeight),
                Text = "",
                Parent = colorPicker,
                ZIndex = 10
            })
            
            -- Color picker functionality
            local pickerOpen = false
            
            colorPickerButton.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                
                if pickerOpen then
                    -- Open color picker
                    colorPickerUI.Visible = true
                    Tween(colorPicker, {Size = UDim2.new(1, 0, 0, pickerHeight + 235)}, 0.3)
                    Tween(colorPickerUI, {Size = UDim2.new(1, -20, 0, 225)}, 0.3)
                    
                    -- Setup interactions
                    setupHueSlider()
                    setupSatValPicker()
                else
                    -- Close color picker
                    Tween(colorPicker, {Size = UDim2.new(1, 0, 0, pickerHeight)}, 0.3)
                    
                    -- Wait for animation
                    wait(0.3)
                    colorPickerUI.Visible = false
                end
            end)
            
            -- Hover effects
            colorPickerButton.MouseEnter:Connect(function()
                if not pickerOpen then
                    Tween(colorPicker, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
                end
            end)
            
            colorPickerButton.MouseLeave:Connect(function()
                if not pickerOpen then
                    Tween(colorPicker, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
                end
            end)
            
            -- Call callback initially
            pcall(function() options.Callback(options.CurrentColor) end)
            
            local colorPickerObj = {}
            
            function colorPickerObj:SetColor(color)
                -- Update display
                colorDisplay.BackgroundColor3 = color
                
                -- Update HSV
                h, s, v = Color3.toHSV(color)
                
                -- Update UI elements
                satValFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                hueSlider.Position = UDim2.new(h, -2, 0, 0)
                satValPicker.Position = UDim2.new(s, -5, 1 - v, -5)
                
                -- Update RGB text
                local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
                rgbText.Text = string.format("RGB: %d, %d, %d", r, g, b)
                
                pcall(function() options.Callback(color) end)
            end
            
            return colorPickerObj
        end
        
        -- Create label
        function tab:CreateLabel(options)
            options = options or {}
            options.Text = options.Text or "Label"
            options.Color = options.Color or CurrentTheme.TextPrimary
            options.Size = options.Size or 14
            
            local label = Create("Frame", {
                Name = "Label",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
                Parent = self.Content,
                LayoutOrder = #self.Content:GetChildren(),
                ZIndex = 4
            })
            
            local labelText = Create("TextLabel", {
                Name = "Text",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = TBD.Font,
                Text = options.Text,
                TextColor3 = options.Color,
                TextSize = options.Size,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = label,
                ZIndex = 5
            })
            
            return labelText
        end
        
        -- Create paragraph
        function tab:CreateParagraph(options)
            options = options or {}
            options.Title = options.Title or "Title"
            options.Content = options.Content or "Content"
            
            local paragraph = Create("Frame", {
                Name = "Paragraph",
                BackgroundColor3 = CurrentTheme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0), -- Auto-size
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = self.Content,
                LayoutOrder = #self.Content:GetChildren(),
                ZIndex = 4
            })
            
            -- Register theme object
            TBD:AddThemeObject(paragraph, "Primary")
            
            local paragraphCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = paragraph
            })
            
            local title = Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 10),
                Size = UDim2.new(1, -20, 0, 20),
                Font = TBD.Font,
                Text = options.Title,
                TextColor3 = CurrentTheme.TextPrimary,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = paragraph,
                ZIndex = 5
            })
            
            -- Register theme object
            TBD:AddThemeObject(title, "TextPrimary", "TextColor3")
            
            local content = Create("TextLabel", {
                Name = "Content",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 35),
                Size = UDim2.new(1, -20, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Font = TBD.SecondaryFont,
                Text = options.Content,
                TextColor3 = CurrentTheme.TextSecondary,
                TextSize = 14,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = paragraph,
                ZIndex = 5
            })
            
            -- Register theme object
            TBD:AddThemeObject(content, "TextSecondary", "TextColor3")
            
            -- Add padding
            local padding = Create("UIPadding", {
                PaddingBottom = UDim.new(0, 10),
                Parent = paragraph
            })
            
            return paragraph
        end
        
        -- Create text input
        function tab:CreateTextBox(options)
            options = options or {}
            options.Name = options.Name or "TextBox"
            options.Description = options.Description
            options.Placeholder = options.Placeholder or "Type here..."
            options.CurrentValue = options.CurrentValue or ""
            options.ClearOnFocus = (options.ClearOnFocus ~= nil) and options.ClearOnFocus or false
            options.Callback = options.Callback or function() end
            
            -- Determine height based on description
            local textBoxHeight = options.Description and 60 or 36
            
            -- Create text box
            local textBox = Create("Frame", {
                Name = options.Name .. "TextBox",
                BackgroundColor3 = CurrentTheme.Primary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, textBoxHeight),
                Parent = self.Content,
                LayoutOrder = #self.Content:GetChildren(),
                ZIndex = 4
            })
            
            -- Register theme object
            TBD:AddThemeObject(textBox, "Primary")
            
            local textBoxCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = textBox
            })
            
            local textBoxLabel = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 36),
                Font = TBD.Font,
                Text = options.Name,
                TextColor3 = CurrentTheme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = textBox,
                ZIndex = 5
            })
            
            -- Register theme object
            TBD:AddThemeObject(textBoxLabel, "TextPrimary", "TextColor3")
            
            -- Add description if provided
            if options.Description then
                textBoxLabel.Size = UDim2.new(1, -20, 0, 25)
                textBoxLabel.Position = UDim2.new(0, 10, 0, 8)
                
                local description = Create("TextLabel", {
                    Name = "Description",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = TBD.SecondaryFont,
                    Text = options.Description,
                    TextColor3 = CurrentTheme.TextSecondary,
                    TextSize = 12,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = textBox,
                    ZIndex = 5
                })
                
                -- Register theme object
                TBD:AddThemeObject(description, "TextSecondary", "TextColor3")
            end
            
            -- Input box
            local inputBox = Create("TextBox", {
                Name = "InputBox",
                BackgroundColor3 = CurrentTheme.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, textBoxHeight + 5),
                Size = UDim2.new(1, -20, 0, 30),
                Font = TBD.SecondaryFont,
                PlaceholderText = options.Placeholder,
                Text = options.CurrentValue,
                TextColor3 = CurrentTheme.TextPrimary,
                TextSize = 14,
                ClearTextOnFocus = options.ClearOnFocus,
                Parent = textBox,
                Visible = false,
                ZIndex = 6
            })
            
            -- Register theme objects
            TBD:AddThemeObject(inputBox, "Secondary")
            TBD:AddThemeObject(inputBox, "TextPrimary", "TextColor3")
            
            local inputBoxCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = inputBox
            })
            
            -- Text box functionality
            local textBoxButton = Create("TextButton", {
                Name = "TextBoxButton",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, textBoxHeight),
                Text = "",
                Parent = textBox,
                ZIndex = 7
            })
            
            local textBoxOpen = false
            
            textBoxButton.MouseButton1Click:Connect(function()
                textBoxOpen = not textBoxOpen
                
                if textBoxOpen then
                    -- Open text box
                    inputBox.Visible = true
                    Tween(textBox, {Size = UDim2.new(1, 0, 0, textBoxHeight + 45)}, 0.3)
                    wait(0.31)
                    inputBox:CaptureFocus()
                else
                    -- Close text box
                    Tween(textBox, {Size = UDim2.new(1, 0, 0, textBoxHeight)}, 0.3)
                    wait(0.3)
                    inputBox.Visible = false
                end
            end)
            
            -- Handle input
            inputBox.FocusLost:Connect(function(enterPressed)
                pcall(function() options.Callback(inputBox.Text) end)
                
                if enterPressed then
                    textBoxOpen = false
                    Tween(textBox, {Size = UDim2.new(1, 0, 0, textBoxHeight)}, 0.3)
                    wait(0.3)
                    inputBox.Visible = false
                end
            end)
            
            -- Hover effects
            textBoxButton.MouseEnter:Connect(function()
                if not textBoxOpen then
                    Tween(textBox, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
                end
            end)
            
            textBoxButton.MouseLeave:Connect(function()
                if not textBoxOpen then
                    Tween(textBox, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
                end
            end)
            
            -- Call callback initially if value exists
            if options.CurrentValue ~= "" then
                pcall(function() options.Callback(options.CurrentValue) end)
            end
            
            local textBoxObj = {}
            
            function textBoxObj:SetValue(value)
                inputBox.Text = value
                pcall(function() options.Callback(value) end)
            end
            
            return textBoxObj
        end
        
        return tab
    end
    
    return windowObj
end

-- Return the library
return TBD
