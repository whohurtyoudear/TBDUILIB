--[[
    TBD UI Library - HoHo Edition
    A modern, customizable Roblox UI library for script hubs and executors
    Version: 2.0.0-V7
    
    Fixed in v7:
    - Dropdown positioning issues
    - Color picker functionality
    - Theme system now properly updates all UI elements when changed
    - All UI components parented correctly to avoid rendering issues
    - Fixed RGB slider functionality in color picker
    - Added UI element tracking system for theme changes
    - Fixed dropdown list syntax error
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Constants
local LIBRARY_NAME = "TBD"
local DEFAULT_FONT = Enum.Font.GothamBold
local SECONDARY_FONT = Enum.Font.Gotham
local TEXT_SIZE = 14
local WINDOW_WIDTH = 600
local WINDOW_HEIGHT = 350
local CORNER_RADIUS = 8
local TOGGLE_SPEED = 0.15
local TWEEN_TIME = 0.25

local LocalPlayer = Players.LocalPlayer

-- Detect if the device is mobile
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Library table
local TBD = {
    Version = "2.0.0-V7", -- Version string
    IsMobile = IS_MOBILE, -- Mobile detection
    Flags = {}, -- Flags for configuration system
    Windows = {}, -- List of created windows
    Themes = {}, -- Available themes
    Font = DEFAULT_FONT,
    SecondaryFont = SECONDARY_FONT,
    SafeArea = {
        Top = 0,
        Bottom = 0,
        Left = 0,
        Right = 0
    },
    NotificationSystem = {}, -- Notification system
    LoadingScreen = {}, -- Loading screen system
    ConfigSystem = {}, -- Configuration system
    ThemeableInstances = {} -- Track instances for theme updates (NEW)
}

-- Icon set (Phosphor Icons)
-- Enhanced Dynamic Icon Library
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
    Grid = "rbxassetid://7734141275",
    List = "rbxassetid://7734055829",
    
    -- Game Elements
    Player = "rbxassetid://7743878152",
    Target = "rbxassetid://7734061145",
    Crown = "rbxassetid://7734130516",
    Flag = "rbxassetid://7733965207",
    Trophy = "rbxassetid://7734064876",
    Heart = "rbxassetid://7734142266",
    Gem = "rbxassetid://7734064308",
    Coin = "rbxassetid://7743868936",
    
    -- Actions
    Play = "rbxassetid://7734063280",
    Pause = "rbxassetid://7734063056",
    Stop = "rbxassetid://7734064628",
    Next = "rbxassetid://7734058022",
    Previous = "rbxassetid://7734061507",
    Upload = "rbxassetid://7734064994",
    Download = "rbxassetid://7734137056",
    Refresh = "rbxassetid://7734062381",
    Trash = "rbxassetid://7734064813",
    Save = "rbxassetid://7734052844",
    Edit = "rbxassetid://7734136858",
    
    -- Communication
    Chat = "rbxassetid://7733971931",
    Mail = "rbxassetid://7734056641",
    Share = "rbxassetid://7734063691",
    Phone = "rbxassetid://7734059095",
    Video = "rbxassetid://7734065011",
    Camera = "rbxassetid://7733970940",
    
    -- Navigation
    Compass = "rbxassetid://7734057821",
    Location = "rbxassetid://7734056377",
    Map = "rbxassetid://7734056734",
    Route = "rbxassetid://7734062696",
    
    -- User Interface
    Slider = "rbxassetid://7734064085",
    Toggle = "rbxassetid://7734064757",
    Button = "rbxassetid://7734055078",
    Dropdown = "rbxassetid://7744077761",
    ColorPicker = "rbxassetid://7734056047",
    
    -- Categories
    Folder = "rbxassetid://7734139505",
    File = "rbxassetid://7734138954",
    Image = "rbxassetid://7734141937",
    Audio = "rbxassetid://7734131319",
    Script = "rbxassetid://7743870318",
    Book = "rbxassetid://7733964960",
    
    -- Tools
    Sword = "rbxassetid://7734064681",
    Shield = "rbxassetid://7734063638",
    Magic = "rbxassetid://7734056549",
    Key = "rbxassetid://7734055447",
    Lock = "rbxassetid://7734056453",
    Unlock = "rbxassetid://7734064966",
    
    -- Social
    User = "rbxassetid://7743879125",
    Users = "rbxassetid://7734061249",
    AddUser = "rbxassetid://7734136412",
    RemoveUser = "rbxassetid://7734062517",
    UserCheck = "rbxassetid://7734131789",
    
    -- Devices & Tech
    Desktop = "rbxassetid://7734137056",
    Laptop = "rbxassetid://7734055567",
    Mobile = "rbxassetid://7734057383",
    Tablet = "rbxassetid://7734064711",
    Controller = "rbxassetid://7734130380",
    Keyboard = "rbxassetid://7734141631",
    
    -- Weather
    Sun = "rbxassetid://7734064652",
    Moon = "rbxassetid://7734057507",
    Cloud = "rbxassetid://7734130269",
    Rain = "rbxassetid://7734062109",
    Snow = "rbxassetid://7734064137",
    Thunder = "rbxassetid://7734138067",
    
    -- Misc
    Brush = "rbxassetid://7733966841",
    Palette = "rbxassetid://7734058963",
    Chart = "rbxassetid://7733972491",
    Graph = "rbxassetid://7733974603",
    Calendar = "rbxassetid://7733970808",
    Clock = "rbxassetid://7733976252",
    Tag = "rbxassetid://7734064742",
    Gift = "rbxassetid://7734054896",
    ChevronDown = "rbxassetid://7734063248",
    ChevronUp = "rbxassetid://7734063094",
    ChevronLeft = "rbxassetid://7734063497",
    ChevronRight = "rbxassetid://7734063865",
    ArrowDown = "rbxassetid://7734132312",
    ArrowUp = "rbxassetid://7734127890",
    ArrowLeft = "rbxassetid://7734133327",
    ArrowRight = "rbxassetid://7734130687",
    User = "rbxassetid://7743880442",
    Person = "rbxassetid://7734136490",
    Eye = "rbxassetid://7734051934",
    Favorite = "rbxassetid://7743879274"
}

-- Get screen safe area
local function GetSafeInsets()
    -- Try to get GuiService safe insets
    local success, result = pcall(function()
        local insets = GuiService:GetGuiInset()
        return {
            Top = insets.Y,
            Bottom = 0,
            Left = insets.X,
            Right = 0
        }
    end)
    
    if success then
        return result
    else
        -- Fallback values
        return {
            Top = 36,
            Bottom = 0,
            Left = 0,
            Right = 0
        }
    end
end

TBD.SafeArea = GetSafeInsets()

-- Available themes
local Themes = {
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

TBD.Themes = Themes
local CurrentTheme = Themes.HoHo

-- Function to register an instance for theme updates (NEW)
function TBD:RegisterThemeable(instance, properties)
    if instance and properties then
        table.insert(self.ThemeableInstances, {
            Instance = instance,
            Properties = properties
        })
    end
end

-- Utility functions
local function Create(className, properties)
    local instance = Instance.new(className)
    
    -- Track themeable properties
    local themeProperties = {}
    
    for property, value in pairs(properties or {}) do
        -- Only set properties that exist for the instance type
        if typeof(instance[property]) ~= "nil" then
            -- Handle TextTransparency separately since Images don't have it
            if property == "TextTransparency" then
                if className ~= "ImageLabel" and className ~= "ImageButton" then
                    instance[property] = value
                end
            else
                instance[property] = value
            end
            
            -- Check if this is a color property that matches a theme color (NEW)
            if (property == "BackgroundColor3" or property == "TextColor3" or 
                property == "BorderColor3" or property == "ImageColor3" or
                property == "Color") then
                -- Find which theme color this matches
                for colorName, colorValue in pairs(CurrentTheme) do
                    if value == colorValue then
                        themeProperties[property] = colorName
                        break
                    end
                end
            end
        end
    end
    
    -- Register for theme updates if themeable properties were found (NEW)
    if next(themeProperties) then
        TBD:RegisterThemeable(instance, themeProperties)
    end
    
    return instance
end

local function Tween(instance, properties, duration, style, direction)
    -- Check if instance is valid
    if not instance or typeof(instance) ~= "Instance" then
        return
    end
    
    -- Create a safe properties table
    local safeProperties = {}
    
    for prop, value in pairs(properties) do
        if typeof(instance[prop]) ~= "nil" then
            safeProperties[prop] = value
        end
    end
    
    -- Only create the tween if we have valid properties to tween
    if next(safeProperties) then
        local tween = TweenService:Create(
            instance,
            TweenInfo.new(
                duration or TWEEN_TIME,
                style or Enum.EasingStyle.Quad,
                direction or Enum.EasingDirection.Out
            ),
            safeProperties
        )
        
        tween:Play()
        return tween
    end
    
    return nil
end

local function MakeDraggable(draggableFrame, handle)
    local isDragging = false
    local dragInput
    local startPos
    local dragStart
    
    handle = handle or draggableFrame
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = draggableFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
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
        if input == dragInput and isDragging then
            local delta = input.Position - dragStart
            draggableFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Helper function to get icon by name or create a custom icon
function TBD:GetIcon(iconNameOrId)
    if not iconNameOrId then return nil end
    
    -- If it's already an asset ID, return it
    if typeof(iconNameOrId) == "string" and string.match(iconNameOrId, "^rbxassetid://") then
        return iconNameOrId
    end
    
    -- If it's an icon name in our library, return the asset ID
    if typeof(iconNameOrId) == "string" and Icons[iconNameOrId] then
        return Icons[iconNameOrId]
    end
    
    -- If it's a numeric asset ID without rbxassetid:// prefix, add it
    if typeof(iconNameOrId) == "number" or (typeof(iconNameOrId) == "string" and tonumber(iconNameOrId)) then
        return "rbxassetid://" .. tostring(iconNameOrId)
    end
    
    -- Default to home icon if not found
    return Icons.Home
end

-- Enhanced SetTheme function that updates UI (NEW)
function TBD:SetTheme(theme)
    if not Themes[theme] then
        return false
    end
    
    -- Update current theme
    CurrentTheme = Themes[theme]
    
    -- Update all registered instances
    for _, themeable in ipairs(self.ThemeableInstances) do
        local instance = themeable.Instance
        if instance and instance.Parent then -- Check if instance still exists
            for property, colorType in pairs(themeable.Properties) do
                -- Only update if the instance has this property
                if typeof(instance[property]) ~= "nil" then
                    -- Update the property with the new theme color
                    Tween(instance, {[property] = CurrentTheme[colorType]}, 0.3)
                end
            end
        end
    end
    
    return true
end

-- Enhanced CustomTheme function that updates UI (NEW)
function TBD:CustomTheme(options)
    options = options or {}
    
    -- Create custom theme by extending current theme
    local customTheme = {
        Primary = options.Primary or CurrentTheme.Primary,
        Secondary = options.Secondary or CurrentTheme.Secondary,
        Background = options.Background or CurrentTheme.Background,
        TextPrimary = options.TextPrimary or CurrentTheme.TextPrimary,
        TextSecondary = options.TextSecondary or CurrentTheme.TextSecondary,
        Accent = options.Accent or CurrentTheme.Accent,
        DarkAccent = options.DarkAccent or CurrentTheme.DarkAccent,
        Error = options.Error or CurrentTheme.Error,
        Success = options.Success or CurrentTheme.Success,
        Warning = options.Warning or CurrentTheme.Warning
    }
    
    -- Set the new theme
    CurrentTheme = customTheme
    
    -- Update all registered instances
    for _, themeable in ipairs(self.ThemeableInstances) do
        local instance = themeable.Instance
        if instance and instance.Parent then -- Check if instance still exists
            for property, colorType in pairs(themeable.Properties) do
                -- Only update if the instance has this property
                if typeof(instance[property]) ~= "nil" then
                    -- Update the property with the new theme color
                    Tween(instance, {[property] = CurrentTheme[colorType]}, 0.3)
                end
            end
        end
    end
    
    return true
end

-- Notifications System
local NotificationSystem = {}

function NotificationSystem:Setup()
    -- Create notification container
    local notificationGui = Create("ScreenGui", {
        Name = LIBRARY_NAME .. "_Notifications",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 100
    })
    
    -- Try to parent to CoreGui
    local success, result = pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(notificationGui)
            notificationGui.Parent = CoreGui
        else
            notificationGui.Parent = CoreGui
        end
        return true
    end)
    
    if not success then
        notificationGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local container = Create("Frame", {
        Name = "NotificationContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 0, 20 + TBD.SafeArea.Top), -- Top right
        AnchorPoint = Vector2.new(1, 0),
        Size = UDim2.new(0, 300, 1, -40),
        Parent = notificationGui
    })
    
    local listLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Parent = container
    })
    
    self.Container = container
    self.Position = "TopRight"
    self.Gui = notificationGui -- Store reference to the ScreenGui
    
    return self
end

function NotificationSystem:SetPosition(position)
    if not self.Container then
        self:Setup()
    end
    
    self.Position = position
    
    -- Update the container position based on notification position
    if position == "TopRight" then
        self.Container.Position = UDim2.new(1, -20, 0, 20 + TBD.SafeArea.Top)
        self.Container.AnchorPoint = Vector2.new(1, 0)
    elseif position == "TopLeft" then
        self.Container.Position = UDim2.new(0, 20 + TBD.SafeArea.Left, 0, 20 + TBD.SafeArea.Top)
        self.Container.AnchorPoint = Vector2.new(0, 0)
    elseif position == "BottomRight" then
        self.Container.Position = UDim2.new(1, -20, 1, -20 - TBD.SafeArea.Bottom)
        self.Container.AnchorPoint = Vector2.new(1, 1)
    elseif position == "BottomLeft" then
        self.Container.Position = UDim2.new(0, 20 + TBD.SafeArea.Left, 1, -20 - TBD.SafeArea.Bottom)
        self.Container.AnchorPoint = Vector2.new(0, 1)
    end
    
    -- Update list layout direction
    local listLayout = self.Container:FindFirstChildOfClass("UIListLayout")
    if listLayout then
        if position == "BottomRight" or position == "BottomLeft" then
            listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
            listLayout.HorizontalAlignment = (position == "BottomRight") and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left
        else
            listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
            listLayout.HorizontalAlignment = (position == "TopRight") and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left
        end
    end
end

function NotificationSystem:CreateNotification(options)
    if not self.Container then
        self:Setup()
    end
    
    options = options or {}
    local title = options.Title or "Notification"
    local message = options.Message or ""
    local duration = options.Duration or 5
    local type = options.Type or "Info"
    local callback = options.Callback
    
    -- Create notification frame
    local notification = Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = CurrentTheme.Background,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 50, 0, 0), -- Start offscreen to the right
        Size = UDim2.new(1, 0, 0, 80),
        ZIndex = 100,
        Parent = self.Container
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(notification, {BackgroundColor3 = "Background"})
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = notification
    })
    
    local stroke = Create("UIStroke", {
        Color = CurrentTheme.Accent,
        Thickness = 1.5,
        Transparency = 0.5,
        Parent = notification
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(stroke, {Color = "Accent"})
    
    -- Add drop shadow
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, 20, 1, 20),
        ZIndex = 99,
        Image = "rbxassetid://6014054326",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.6,
        Parent = notification
    })
    
    -- Get the corresponding icon and color for notification type
    local typeInfo = {
        Info = {
            Icon = Icons.Info,
            Color = CurrentTheme.Accent
        },
        Success = {
            Icon = Icons.Success,
            Color = CurrentTheme.Success
        },
        Warning = {
            Icon = Icons.Warning,
            Color = CurrentTheme.Warning
        },
        Error = {
            Icon = Icons.Error,
            Color = CurrentTheme.Error
        }
    }
    
    local iconData = typeInfo[type] or typeInfo.Info
    
    -- Create colored bar on the left
    local colorBar = Create("Frame", {
        Name = "ColorBar",
        BackgroundColor3 = iconData.Color,
        Size = UDim2.new(0, 5, 1, 0),
        ZIndex = 101,
        Parent = notification
    })
    
    -- Register for theme updates if using a theme color (NEW)
    if type == "Info" then
        TBD:RegisterThemeable(colorBar, {BackgroundColor3 = "Accent"})
    elseif type == "Success" then
        TBD:RegisterThemeable(colorBar, {BackgroundColor3 = "Success"})
    elseif type == "Warning" then
        TBD:RegisterThemeable(colorBar, {BackgroundColor3 = "Warning"})
    elseif type == "Error" then
        TBD:RegisterThemeable(colorBar, {BackgroundColor3 = "Error"})
    end
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = colorBar
    })
    
    -- Fix the color bar corners - only round the left side
    local colorBarFix = Create("Frame", {
        Name = "ColorBarFix",
        BackgroundColor3 = iconData.Color,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        ZIndex = 101,
        Parent = colorBar
    })
    
    -- Register for theme updates if using a theme color (NEW)
    if type == "Info" then
        TBD:RegisterThemeable(colorBarFix, {BackgroundColor3 = "Accent"})
    elseif type == "Success" then
        TBD:RegisterThemeable(colorBarFix, {BackgroundColor3 = "Success"})
    elseif type == "Warning" then
        TBD:RegisterThemeable(colorBarFix, {BackgroundColor3 = "Warning"})
    elseif type == "Error" then
        TBD:RegisterThemeable(colorBarFix, {BackgroundColor3 = "Error"})
    end
    
    -- Icon
    local icon = Create("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 15),
        Size = UDim2.new(0, 20, 0, 20),
        Image = iconData.Icon,
        ImageColor3 = iconData.Color,
        ZIndex = 101,
        Parent = notification
    })
    
    -- Register for theme updates if using a theme color (NEW)
    if type == "Info" then
        TBD:RegisterThemeable(icon, {ImageColor3 = "Accent"})
    elseif type == "Success" then
        TBD:RegisterThemeable(icon, {ImageColor3 = "Success"})
    elseif type == "Warning" then
        TBD:RegisterThemeable(icon, {ImageColor3 = "Warning"})
    elseif type == "Error" then
        TBD:RegisterThemeable(icon, {ImageColor3 = "Error"})
    end
    
    -- Title
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 45, 0, 10),
        Size = UDim2.new(1, -60, 0, 20),
        Font = DEFAULT_FONT,
        Text = title,
        TextColor3 = CurrentTheme.TextPrimary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101,
        Parent = notification
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(titleLabel, {TextColor3 = "TextPrimary"})
    
    -- Message
    local messageLabel = Create("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 45, 0, 32),
        Size = UDim2.new(1, -60, 0, 40),
        Font = SECONDARY_FONT,
        Text = message,
        TextColor3 = CurrentTheme.TextSecondary,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 101,
        Parent = notification
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(messageLabel, {TextColor3 = "TextSecondary"})
    
    -- Close button
    local closeButton = Create("ImageButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0, 15),
        Size = UDim2.new(0, 15, 0, 15),
        Image = Icons.Close,
        ImageColor3 = CurrentTheme.TextSecondary,
        ZIndex = 101,
        Parent = notification
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(closeButton, {ImageColor3 = "TextSecondary"})
    
    -- Progress bar
    local progressBarContainer = Create("Frame", {
        Name = "ProgressBarContainer",
        BackgroundColor3 = CurrentTheme.Secondary,
        BackgroundTransparency = 0.7,
        Position = UDim2.new(0, 0, 1, -5),
        Size = UDim2.new(1, 0, 0, 3),
        ZIndex = 101,
        Parent = notification
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(progressBarContainer, {BackgroundColor3 = "Secondary"})
    
    local progressBar = Create("Frame", {
        Name = "ProgressBar",
        BackgroundColor3 = iconData.Color,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 102,
        Parent = progressBarContainer
    })
    
    -- Register for theme updates if using a theme color (NEW)
    if type == "Info" then
        TBD:RegisterThemeable(progressBar, {BackgroundColor3 = "Accent"})
    elseif type == "Success" then
        TBD:RegisterThemeable(progressBar, {BackgroundColor3 = "Success"})
    elseif type == "Warning" then
        TBD:RegisterThemeable(progressBar, {BackgroundColor3 = "Warning"})
    elseif type == "Error" then
        TBD:RegisterThemeable(progressBar, {BackgroundColor3 = "Error"})
    end
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = progressBarContainer
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = progressBar
    })
    
    -- Animate in notification
    Tween(notification, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quint)
    
    -- Set up progress animation
    Tween(progressBar, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)
    
    -- Make notification interactive (clickable)
    notification.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if callback then
                callback()
            end
            
            -- Immediately dismiss
            Tween(notification, {Position = UDim2.new(1, 50, 0, 0)}, 0.3, Enum.EasingStyle.Quint).Completed:Connect(function()
                notification:Destroy()
            end)
        end
    end)
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        Tween(notification, {Position = UDim2.new(1, 50, 0, 0)}, 0.3, Enum.EasingStyle.Quint).Completed:Connect(function()
            notification:Destroy()
        end)
    end)
    
    -- Auto dismiss after duration
    task.delay(duration, function()
        -- Check if notification still exists
        if notification and notification.Parent then
            Tween(notification, {Position = UDim2.new(1, 50, 0, 0)}, 0.3, Enum.EasingStyle.Quint).Completed:Connect(function()
                notification:Destroy()
            end)
        end
    end)
    
    return notification
end

TBD.NotificationSystem = NotificationSystem

-- Loading Screen System
local LoadingScreen = {}

function LoadingScreen:Create(options)
    options = options or {}
    
    local title = options.Title or "TBD UI Library"
    local subtitle = options.Subtitle or "Loading..."
    local logoId = options.LogoId
    local logoSize = options.LogoSize or UDim2.new(0, 100, 0, 100)
    local logoPosition = options.LogoPosition or UDim2.new(0.5, 0, 0.4, 0)
    local progressBarSize = options.ProgressBarSize or UDim2.new(0.5, 0, 0, 6)
    local animationStyle = options.AnimationStyle or "Fade" -- Fade, Scale, Slide
    
    -- Create loading screen gui
    local loadingGui = Create("ScreenGui", {
        Name = LIBRARY_NAME .. "_LoadingScreen",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000
    })
    
    -- Try to parent to CoreGui
    local success, result = pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(loadingGui)
            loadingGui.Parent = CoreGui
        else
            loadingGui.Parent = CoreGui
        end
        return true
    end)
    
    if not success then
        loadingGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Create loading screen background with blur
    local background = Create("Frame", {
        Name = "Background",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.4,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 1000,
        Parent = loadingGui
    })
    
    -- Try to add blur effect (works in most but not all executors)
    pcall(function()
        local blur = Create("BlurEffect", {
            Name = "LoadingBlur",
            Size = 10,
            Parent = game:GetService("Lighting")
        })
        
        self.BlurEffect = blur
    end)
    
    -- Create loading container
    local container = Create("Frame", {
        Name = "LoadingContainer",
        BackgroundColor3 = CurrentTheme.Background,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 300, 0, 300),
        ZIndex = 1001,
        Parent = loadingGui
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(container, {BackgroundColor3 = "Background"})
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 16),
        Parent = container
    })
    
    local containerStroke = Create("UIStroke", {
        Color = CurrentTheme.Accent,
        Thickness = 2,
        Transparency = 0.5,
        Parent = container
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(containerStroke, {Color = "Accent"})
    
    -- Add logo if provided
    if logoId then
        local logo = Create("ImageLabel", {
            Name = "Logo",
            BackgroundTransparency = 1,
            Position = logoPosition,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = logoSize,
            Image = logoId,
            ZIndex = 1002,
            Parent = container
        })
    end
    
    -- Create title text
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, logoId and 0.65 or 0.4, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(0.8, 0, 0, 30),
        Font = DEFAULT_FONT,
        Text = title,
        TextColor3 = CurrentTheme.TextPrimary,
        TextSize = 24,
        ZIndex = 1002,
        Parent = container
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(titleLabel, {TextColor3 = "TextPrimary"})
    
    -- Create subtitle text
    local subtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, titleLabel.Position.Y.Scale + 0.12, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(0.8, 0, 0, 20),
        Font = SECONDARY_FONT,
        Text = subtitle,
        TextColor3 = CurrentTheme.TextSecondary,
        TextSize = 16,
        ZIndex = 1002,
        Parent = container
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(subtitleLabel, {TextColor3 = "TextSecondary"})
    
    -- Create progress bar container
    local progressContainer = Create("Frame", {
        Name = "ProgressContainer",
        BackgroundColor3 = CurrentTheme.Secondary,
        BackgroundTransparency = 0.7,
        Position = UDim2.new(0.5, 0, 0.85, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        Size = progressBarSize,
        ZIndex = 1002,
        Parent = container
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(progressContainer, {BackgroundColor3 = "Secondary"})
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = progressContainer
    })
    
    -- Create progress bar
    local progressBar = Create("Frame", {
        Name = "ProgressBar",
        BackgroundColor3 = CurrentTheme.Accent,
        Size = UDim2.new(0, 0, 1, 0),
        ZIndex = 1003,
        Parent = progressContainer
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(progressBar, {BackgroundColor3 = "Accent"})
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = progressBar
    })
    
    -- Apply initial animation based on style
    if animationStyle == "Fade" then
        container.BackgroundTransparency = 1
        titleLabel.TextTransparency = 1
        subtitleLabel.TextTransparency = 1
        progressContainer.BackgroundTransparency = 1
        
        Tween(container, {BackgroundTransparency = 0}, 0.5)
        Tween(titleLabel, {TextTransparency = 0}, 0.5)
        Tween(subtitleLabel, {TextTransparency = 0}, 0.5)
        Tween(progressContainer, {BackgroundTransparency = 0.7}, 0.5)
    elseif animationStyle == "Scale" then
        container.Size = UDim2.new(0, 0, 0, 0)
        
        Tween(container, {Size = UDim2.new(0, 300, 0, 300)}, 0.5, Enum.EasingStyle.Back)
    elseif animationStyle == "Slide" then
        container.Position = UDim2.new(0.5, 0, 1.5, 0)
        
        Tween(container, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.5, Enum.EasingStyle.Quint)
    end
    
    -- Store references
    self.LoadingGui = loadingGui
    self.ProgressBar = progressBar
    self.ProgressContainer = progressContainer
    self.Container = container
    self.Title = titleLabel
    self.Subtitle = subtitleLabel
    self.AnimationStyle = animationStyle
    
    return self
end

function LoadingScreen:UpdateProgress(progress)
    if not self.ProgressBar then return end
    
    progress = math.clamp(progress, 0, 1)
    Tween(self.ProgressBar, {Size = UDim2.new(progress, 0, 1, 0)}, 0.3)
    
    return self
end

function LoadingScreen:SetStatus(status)
    if not self.Subtitle then return end
    
    self.Subtitle.Text = status
    
    return self
end

function LoadingScreen:Finish(callback)
    if not self.Container then return end
    
    -- Complete the progress bar
    self:UpdateProgress(1)
    
    -- Wait a moment before closing
    task.delay(0.5, function()
        -- Apply exit animation based on style
        if self.AnimationStyle == "Fade" then
            Tween(self.Container, {BackgroundTransparency = 1}, 0.5)
            
            if self.Title then
                Tween(self.Title, {TextTransparency = 1}, 0.5)
            end
            
            if self.Subtitle then
                Tween(self.Subtitle, {TextTransparency = 1}, 0.5)
            end
            
            if self.ProgressContainer then
                Tween(self.ProgressContainer, {BackgroundTransparency = 1}, 0.5)
            end
        elseif self.AnimationStyle == "Scale" then
            Tween(self.Container, {Size = UDim2.new(0, 0, 0, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        elseif self.AnimationStyle == "Slide" then
            Tween(self.Container, {Position = UDim2.new(0.5, 0, 1.5, 0)}, 0.5, Enum.EasingStyle.Quint)
        end
        
        -- Clean up after animation
        task.delay(0.5, function()
            if self.BlurEffect then
                self.BlurEffect:Destroy()
            end
            
            if self.LoadingGui then
                self.LoadingGui:Destroy()
            end
            
            if callback then
                callback()
            end
        end)
    end)
    
    return self
end

TBD.LoadingScreen = LoadingScreen

-- Tab System Class
local TabSystem = {}
TabSystem.__index = TabSystem

function TabSystem:Create()
    local self = setmetatable({
        Tabs = {},
        ActiveTab = nil
    }, TabSystem)
    
    -- Create tab container
    local tabContainer = Create("ScrollingFrame", {
        Name = "TabContainer",
        BackgroundColor3 = CurrentTheme.Primary,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 40), -- Below header
        Size = UDim2.new(0, 190, 1, -40),
        ScrollBarThickness = 0,
        ScrollingEnabled = true,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ClipsDescendants = true
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(tabContainer, {BackgroundColor3 = "Primary"})
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 0),
        Parent = tabContainer
    })
    
    -- Create padding and layout for tab container
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = tabContainer
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabContainer
    })
    
    -- Create separator between tabs and content
    local separator = Create("Frame", {
        Name = "Separator",
        BackgroundColor3 = CurrentTheme.Accent,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 190, 0, 40),
        Size = UDim2.new(0, 1, 1, -40)
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(separator, {BackgroundColor3 = "Accent"})
    
    -- Create content container
    local contentContainer = Create("Frame", {
        Name = "ContentContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 190, 0, 40), -- Right of tab container, below header
        Size = UDim2.new(1, -190, 1, -40),
        ClipsDescendants = true
    })
    
    -- Store references
    self.Container = tabContainer
    self.ContentContainer = contentContainer
    self.Separator = separator
    
    return self
end

function TabSystem:UpdateCanvasSize()
    -- Adjust the canvas size of the tab container based on its children
    local listLayout = self.Container:FindFirstChildOfClass("UIListLayout")
    
    if listLayout then
        self.Container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
    end
end

function TabSystem:AddTab(tabInfo)
    local tabs = self.Tabs
    local activeTab = self.ActiveTab
    
    local name = tabInfo.Name or "Tab"
    local icon = tabInfo.Icon
    
    -- Create tab button container (frame)
    local tabButtonContainer = Create("Frame", {
        Name = name .. "ButtonContainer",
        BackgroundColor3 = CurrentTheme.Primary,
        BackgroundTransparency = 0.4,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = self.Container
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(tabButtonContainer, {BackgroundColor3 = "Primary"})
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = tabButtonContainer
    })
    
    -- Create the clickable button that will be inside the container
    local tabButton = Create("TextButton", {
        Name = name .. "Button",
        BackgroundTransparency = 1, -- Transparent background
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",  -- No text because we'll use a TextLabel for that
        Parent = tabButtonContainer
    })
    
    -- Add icon if provided
    local title
    if icon then
        local iconImage = Create("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.new(0, 20, 0, 20),
            Image = icon,
            ImageColor3 = CurrentTheme.TextSecondary,
            Parent = tabButton
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(iconImage, {ImageColor3 = "TextSecondary"})
        
        title = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 40, 0, 0),
            Size = UDim2.new(1, -50, 1, 0),
            Font = DEFAULT_FONT,
            Text = name,
            TextColor3 = CurrentTheme.TextSecondary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabButton
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(title, {TextColor3 = "TextSecondary"})
    else
        title = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -20, 1, 0),
            Font = DEFAULT_FONT,
            Text = name,
            TextColor3 = CurrentTheme.TextSecondary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabButton
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(title, {TextColor3 = "TextSecondary"})
    end
    
    -- Create tab content container
    local tabContent = Create("ScrollingFrame", {
        Name = name .. "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 6,
        ScrollingEnabled = true,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
        Visible = false,
        Parent = self.ContentContainer
    })
    
    -- Create padding and list layout for tab content
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 15),
        PaddingBottom = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        Parent = tabContent
    })
    
    local contentListLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabContent
    })
    
    -- Update canvas size when content changes
    contentListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, contentListLayout.AbsoluteContentSize.Y + 30)
    end)
    
    -- Create tab object
    local tab = {
        Name = name,
        Button = tabButton,
        ButtonContainer = tabButtonContainer, -- Store reference to the ButtonContainer for theme tweens
        Icon = icon and tabButton:FindFirstChild("Icon") or nil,
        Title = title,
        Content = tabContent,
        Elements = {}
    }
    
    -- Add methods to the tab
    tab.CreateSection = function(_, sectionName)
        local section = Create("Frame", {
            Name = "Section_" .. sectionName,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            Parent = tab.Content
        })
        
        local sectionTitle = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Font = DEFAULT_FONT,
            Text = sectionName,
            TextColor3 = CurrentTheme.Accent,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = section
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(sectionTitle, {TextColor3 = "Accent"})
        
        local sectionLine = Create("Frame", {
            Name = "Line",
            BackgroundColor3 = CurrentTheme.Accent,
            BackgroundTransparency = 0.5,
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 1),
            Parent = section
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(sectionLine, {BackgroundColor3 = "Accent"})
        
        return section
    end
    
    tab.CreateDivider = function(_)
        local divider = Create("Frame", {
            Name = "Divider",
            BackgroundColor3 = CurrentTheme.Secondary,
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, 0, 0, 2),
            Parent = tab.Content
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(divider, {BackgroundColor3 = "Secondary"})
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 1),
            Parent = divider
        })
        
        return divider
    end
    
    -- CREATE BUTTON METHOD
    tab.CreateButton = function(_, options)
        options = options or {}
        local name = options.Name or "Button"
        local description = options.Description
        local callback = options.Callback or function() end
        
        local buttonHeight = description and 60 or 46
        
        -- Create the button container (frame)
        local buttonContainer = Create("Frame", {
            Name = "ButtonContainer_" .. name,
            BackgroundColor3 = CurrentTheme.Secondary,
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 0, 0, buttonHeight),
            Parent = tab.Content
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(buttonContainer, {BackgroundColor3 = "Secondary"})
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = buttonContainer
        })
        
        -- Create the actual clickable button
        local buttonObj = Create("TextButton", {
            Name = "Button",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            Parent = buttonContainer
        })
        
        local buttonTitle = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 8),
            Size = UDim2.new(1, -20, 0, 18),
            Font = SECONDARY_FONT,
            Text = name,
            TextColor3 = CurrentTheme.TextPrimary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = buttonContainer -- Changed from button to buttonContainer
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(buttonTitle, {TextColor3 = "TextPrimary"})
        
        if description then
            local descriptionLabel = Create("TextLabel", {
                Name = "Description",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 26),
                Size = UDim2.new(1, -20, 0, 16),
                Font = SECONDARY_FONT,
                Text = description,
                TextColor3 = CurrentTheme.TextSecondary,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = buttonContainer -- Changed from button to buttonContainer
            })
            
            -- Register for theme updates (NEW)
            TBD:RegisterThemeable(descriptionLabel, {TextColor3 = "TextSecondary"})
        end
        
        buttonObj.MouseButton1Click:Connect(function()
            callback()
        end)
        
        buttonObj.MouseEnter:Connect(function()
            -- Enhanced button hover effect
            Tween(buttonContainer, {
                BackgroundTransparency = 0.2,
                BackgroundColor3 = CurrentTheme.Secondary:Lerp(CurrentTheme.Accent, 0.2),
                Size = UDim2.new(1, 6, 0, buttonHeight + 2)
            }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            
            -- Adjust position to keep centered during size change
            Tween(buttonContainer, {
                Position = UDim2.new(0, -3, 0, -1)
            }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            
            -- Scale title text slightly
            buttonContainer:FindFirstChild("Title").TextSize = buttonContainer:FindFirstChild("Title").TextSize + 1
            
            -- Add a subtle glow effect
            local glowEffect = buttonContainer:FindFirstChild("GlowEffect")
            if not glowEffect then
                glowEffect = Create("ImageLabel", {
                    Name = "GlowEffect",
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(1, 20, 1, 20),
                    ZIndex = 0,
                    Image = "rbxassetid://6014054326", -- Soft glow
                    ImageColor3 = CurrentTheme.Accent,
                    ImageTransparency = 1, -- Start fully transparent
                    Parent = buttonContainer
                })
            end
            
            -- Animate the glow appearing
            Tween(glowEffect, {ImageTransparency = 0.8}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end)
        
        buttonObj.MouseLeave:Connect(function()
            -- Restore original appearance
            Tween(buttonContainer, {
                BackgroundTransparency = 0.4, 
                BackgroundColor3 = CurrentTheme.Secondary,
                Size = UDim2.new(1, 0, 0, buttonHeight),
                Position = UDim2.new(0, 0, 0, 0)
            }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            
            -- Restore original text size
            if buttonContainer:FindFirstChild("Title") then
                buttonContainer:FindFirstChild("Title").TextSize = buttonContainer:FindFirstChild("Title").TextSize - 1
            end
            
            -- Fade out glow
            local glowEffect = buttonContainer:FindFirstChild("GlowEffect")
            if glowEffect then
                Tween(glowEffect, {ImageTransparency = 1}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            end
        end)
        
        -- Return the container for compatibility with existing code
        return buttonContainer
    end
    
    -- CREATE TOGGLE METHOD
    tab.CreateToggle = function(_, options)
        options = options or {}
        local name = options.Name or "Toggle"
        local description = options.Description
        local currValue = options.CurrentValue or false
        local callback = options.Callback or function() end
        local flag = options.Flag
        
        local toggleHeight = description and 60 or 46
        
        local toggle = Create("Frame", {
            Name = "Toggle_" .. name,
            BackgroundColor3 = CurrentTheme.Secondary,
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 0, 0, toggleHeight),
            Parent = tab.Content
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(toggle, {BackgroundColor3 = "Secondary"})
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = toggle
        })
        
        local toggleTitle = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 8),
            Size = UDim2.new(1, -60, 0, 18),
            Font = SECONDARY_FONT,
            Text = name,
            TextColor3 = CurrentTheme.TextPrimary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = toggle
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(toggleTitle, {TextColor3 = "TextPrimary"})
        
        if description then
            local descriptionLabel = Create("TextLabel", {
                Name = "Description",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 26),
                Size = UDim2.new(1, -60, 0, 16),
                Font = SECONDARY_FONT,
                Text = description,
                TextColor3 = CurrentTheme.TextSecondary,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggle
            })
            
            -- Register for theme updates (NEW)
            TBD:RegisterThemeable(descriptionLabel, {TextColor3 = "TextSecondary"})
        end
        
        -- Create toggle indicator
        local toggleIndicator = Create("Frame", {
            Name = "Indicator",
            BackgroundColor3 = currValue and CurrentTheme.Accent or CurrentTheme.Secondary,
            Position = UDim2.new(1, -50, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.new(0, 40, 0, 20),
            Parent = toggle
        })
        
        -- Register for theme updates (NEW)
        if currValue then
            TBD:RegisterThemeable(toggleIndicator, {BackgroundColor3 = "Accent"})
        else
            TBD:RegisterThemeable(toggleIndicator, {BackgroundColor3 = "Secondary"})
        end
        
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = toggleIndicator
        })
        
        -- Create the knob
        local knob = Create("Frame", {
            Name = "Knob",
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Position = UDim2.new(currValue and 1 or 0, currValue and -18 or 2, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.new(0, 16, 0, 16),
            Parent = toggleIndicator
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = knob
        })
        
        -- Create button for interaction
        local toggleButton = Create("TextButton", {
            Name = "Button",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            Parent = toggle
        })
        
        -- Function to toggle state
        local function updateToggle(value)
            currValue = value
            
            -- Animate toggle knob
            Tween(knob, {Position = UDim2.new(currValue and 1 or 0, currValue and -18 or 2, 0.5, 0)}, TOGGLE_SPEED)
            
            -- Change background color
            if currValue then
                Tween(toggleIndicator, {BackgroundColor3 = CurrentTheme.Accent}, TOGGLE_SPEED)
                -- Update theme registration
                TBD:RegisterThemeable(toggleIndicator, {BackgroundColor3 = "Accent"})
            else
                Tween(toggleIndicator, {BackgroundColor3 = CurrentTheme.Secondary}, TOGGLE_SPEED)
                -- Update theme registration
                TBD:RegisterThemeable(toggleIndicator, {BackgroundColor3 = "Secondary"})
            end
            
            -- Call callback
            callback(currValue)
            
            -- Update flag
            if flag then
                TBD.Flags[flag] = currValue
            end
        end
        
        toggleButton.MouseButton1Click:Connect(function()
            updateToggle(not currValue)
        end)
        
        toggleButton.MouseEnter:Connect(function()
            Tween(toggle, {BackgroundTransparency = 0.2}, 0.2)
        end)
        
        toggleButton.MouseLeave:Connect(function()
            Tween(toggle, {BackgroundTransparency = 0.4}, 0.2)
        end)
        
        -- Create toggle object for external control
        local toggleObject = {
            Value = currValue,
            
            Set = function(self, value)
                updateToggle(value)
            end,
            
            GetState = function(self)
                return currValue
            end
        }
        
        -- Initialize flag if provided
        if flag then
            TBD.Flags[flag] = currValue
        end
        
        return toggleObject
    end
    
    -- CREATE SLIDER METHOD
    tab.CreateSlider = function(_, options)
        options = options or {}
        local name = options.Name or "Slider"
        local description = options.Description
        local range = options.Range or {0, 100}
        local increment = options.Increment or 1
        local currValue = options.CurrentValue or range[1]
        local callback = options.Callback or function() end
        local flag = options.Flag
        
        local min, max = range[1], range[2]
        currValue = math.clamp(currValue, min, max)
        
        -- Round to increment
        currValue = math.floor(currValue / increment) * increment
        
        local sliderHeight = description and 60 or 46
        
        local slider = Create("Frame", {
            Name = "Slider_" .. name,
            BackgroundColor3 = CurrentTheme.Secondary,
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 0, 0, sliderHeight),
            Parent = tab.Content
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(slider, {BackgroundColor3 = "Secondary"})
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = slider
        })
        
        local sliderTitle = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 8),
            Size = UDim2.new(1, -20, 0, 18),
            Font = SECONDARY_FONT,
            Text = name,
            TextColor3 = CurrentTheme.TextPrimary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = slider
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(sliderTitle, {TextColor3 = "TextPrimary"})
        
        if description then
            local descriptionLabel = Create("TextLabel", {
                Name = "Description",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 26),
                Size = UDim2.new(1, -20, 0, 16),
                Font = SECONDARY_FONT,
                Text = description,
                TextColor3 = CurrentTheme.TextSecondary,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = slider
            })
            
            -- Register for theme updates (NEW)
            TBD:RegisterThemeable(descriptionLabel, {TextColor3 = "TextSecondary"})
        end
        
        -- Create slider value display
        local valueDisplay = Create("TextLabel", {
            Name = "Value",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -50, 0, 8),
            Size = UDim2.new(0, 40, 0, 18),
            Font = SECONDARY_FONT,
            Text = tostring(currValue),
            TextColor3 = CurrentTheme.TextPrimary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = slider
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(valueDisplay, {TextColor3 = "TextPrimary"})
        
        -- Create slider track
        local sliderTrack = Create("Frame", {
            Name = "Track",
            BackgroundColor3 = CurrentTheme.Background,
            BackgroundTransparency = 0.5,
            Position = UDim2.new(0, 10, 0, description and 45 or 30),
            Size = UDim2.new(1, -20, 0, 4),
            Parent = slider
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(sliderTrack, {BackgroundColor3 = "Background"})
        
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = sliderTrack
        })
        
        -- Create slider fill
        local percentFill = (currValue - min) / (max - min)
        
        local sliderFill = Create("Frame", {
            Name = "Fill",
            BackgroundColor3 = CurrentTheme.Accent,
            Size = UDim2.new(percentFill, 0, 1, 0),
            Parent = sliderTrack
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(sliderFill, {BackgroundColor3 = "Accent"})
        
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = sliderFill
        })
        
        -- Create slider knob
        local sliderKnob = Create("Frame", {
            Name = "Knob",
            BackgroundColor3 = CurrentTheme.Accent,
            Position = UDim2.new(percentFill, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, 12, 0, 12),
            Parent = sliderTrack
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(sliderKnob, {BackgroundColor3 = "Accent"})
        
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = sliderKnob
        })
        
        -- Create the interactive area
        local sliderArea = Create("TextButton", {
            Name = "Area",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, description and 40 or 25),
            Size = UDim2.new(1, 0, 0, 15),
            Text = "",
            Parent = slider
        })
        
        -- Slider functionality
        local isDragging = false
        
        -- Function to update the slider value
        local function updateSlider(value)
            -- Clamp and round value
            value = math.clamp(value, min, max)
            value = math.floor((value - min) / increment + 0.5) * increment + min
            
            -- Ensure value is within range after rounding
            value = math.clamp(value, min, max)
            
            currValue = value
            valueDisplay.Text = tostring(value)
            
            -- Update visuals
            local newPercentFill = (value - min) / (max - min)
            Tween(sliderFill, {Size = UDim2.new(newPercentFill, 0, 1, 0)}, 0.1)
            Tween(sliderKnob, {Position = UDim2.new(newPercentFill, 0, 0.5, 0)}, 0.1)
            
            -- Call callback
            callback(value)
            
            -- Update flag
            if flag then
                TBD.Flags[flag] = value
            end
        end
        
        sliderArea.MouseButton1Down:Connect(function()
            isDragging = true
        end)
        
        sliderTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                
                -- Calculate value on initial click
                local trackAbsPos = sliderTrack.AbsolutePosition
                local trackAbsSize = sliderTrack.AbsoluteSize
                local mousePos = UserInputService:GetMouseLocation() - Vector2.new(0, 36)
                
                local relativeX = math.clamp((mousePos.X - trackAbsPos.X) / trackAbsSize.X, 0, 1)
                local value = min + relativeX * (max - min)
                
                updateSlider(value)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local trackAbsPos = sliderTrack.AbsolutePosition
                local trackAbsSize = sliderTrack.AbsoluteSize
                local mousePos = UserInputService:GetMouseLocation() - Vector2.new(0, 36)
                
                local relativeX = math.clamp((mousePos.X - trackAbsPos.X) / trackAbsSize.X, 0, 1)
                local value = min + relativeX * (max - min)
                
                updateSlider(value)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
            end
        end)
        
        -- Hover effect
        sliderArea.MouseEnter:Connect(function()
            Tween(slider, {BackgroundTransparency = 0.2}, 0.2)
        end)
        
        sliderArea.MouseLeave:Connect(function()
            Tween(slider, {BackgroundTransparency = 0.4}, 0.2)
        end)
        
        -- Create slider object for external control
        local sliderObject = {
            Value = currValue,
            
            Set = function(self, value)
                updateSlider(value)
            end,
            
            GetValue = function(self)
                return currValue
            end
        }
        
        -- Initialize flag if provided
        if flag then
            TBD.Flags[flag] = currValue
        end
        
        return sliderObject
    end
    
    -- CREATE TEXTBOX METHOD
    tab.CreateTextbox = function(_, options)
        options = options or {}
        local name = options.Name or "Textbox"
        local description = options.Description
        local placeholderText = options.PlaceholderText or "Enter text..."
        local defaultText = options.Text or ""
        local charLimit = options.CharacterLimit or 0
        local clearOnFocus = options.ClearTextOnFocus
        local callback = options.Callback or function() end
        local flag = options.Flag
        
        if clearOnFocus == nil then
            clearOnFocus = true
        end
        
        local textboxHeight = description and 60 or 46
        
        local textboxFrame = Create("Frame", {
            Name = "Textbox_" .. name,
            BackgroundColor3 = CurrentTheme.Secondary,
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 0, 0, textboxHeight),
            Parent = tab.Content
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(textboxFrame, {BackgroundColor3 = "Secondary"})
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = textboxFrame
        })
        
        local textboxTitle = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 8),
            Size = UDim2.new(1, -20, 0, 18),
            Font = SECONDARY_FONT,
            Text = name,
            TextColor3 = CurrentTheme.TextPrimary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = textboxFrame
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(textboxTitle, {TextColor3 = "TextPrimary"})
        
        if description then
            local descriptionLabel = Create("TextLabel", {
                Name = "Description",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 26),
                Size = UDim2.new(1, -20, 0, 16),
                Font = SECONDARY_FONT,
                Text = description,
                TextColor3 = CurrentTheme.TextSecondary,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = textboxFrame
            })
            
            -- Register for theme updates (NEW)
            TBD:RegisterThemeable(descriptionLabel, {TextColor3 = "TextSecondary"})
        end
        
        -- Create textbox container
        local textboxContainer = Create("Frame", {
            Name = "TextboxContainer",
            BackgroundColor3 = CurrentTheme.Primary,
            BackgroundTransparency = 0.2,
            Position = UDim2.new(0, 10, 0, description and 45 or 32),
            Size = UDim2.new(1, -20, 0, 24),
            Parent = textboxFrame
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(textboxContainer, {BackgroundColor3 = "Primary"})
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = textboxContainer
        })
        
        -- Create actual textbox
        local textbox = Create("TextBox", {
            Name = "Textbox",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 0),
            Size = UDim2.new(1, -16, 1, 0),
            Font = SECONDARY_FONT,
            Text = defaultText,
            PlaceholderText = placeholderText,
            TextColor3 = CurrentTheme.TextPrimary,
            PlaceholderColor3 = CurrentTheme.TextSecondary,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = clearOnFocus,
            Parent = textboxContainer
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(textbox, {
            TextColor3 = "TextPrimary",
            PlaceholderColor3 = "TextSecondary"
        })
        
        -- Limit character input if specified
        textbox:GetPropertyChangedSignal("Text"):Connect(function()
            if charLimit > 0 and #textbox.Text > charLimit then
                textbox.Text = string.sub(textbox.Text, 1, charLimit)
            end
        end)
        
        -- Fire callback on focus lost
        textbox.FocusLost:Connect(function(enterPressed)
            callback(textbox.Text)
            
            if flag then
                TBD.Flags[flag] = textbox.Text
            end
        end)
        
        -- Hover effect
        textboxFrame.MouseEnter:Connect(function()
            Tween(textboxFrame, {BackgroundTransparency = 0.2}, 0.2)
            Tween(textboxContainer, {BackgroundTransparency = 0}, 0.2)
        end)
        
        textboxFrame.MouseLeave:Connect(function()
            Tween(textboxFrame, {BackgroundTransparency = 0.4}, 0.2)
            Tween(textboxContainer, {BackgroundTransparency = 0.2}, 0.2)
        end)
        
        -- Create textbox object for external control
        local textboxObject = {
            Text = defaultText,
            
            Set = function(self, text)
                textbox.Text = text
                callback(text)
                
                if flag then
                    TBD.Flags[flag] = text
                end
            end
        }
        
        -- Initialize flag if provided
        if flag then
            TBD.Flags[flag] = defaultText
        end
        
        return textboxObject
    end
-- FIXED DROPDOWN IMPLEMENTATION FOR TBD-COMPLETE-FIXED-V5.lua

-- CREATE DROPDOWN METHOD - Completely revised positioning
tab.CreateDropdown = function(_, options)
    options = options or {}
    local name = options.Name or "Dropdown"
    local description = options.Description
    local items = options.Items or {}
    local default = options.Default
    local callback = options.Callback or function() end
    local flag = options.Flag
    
    local dropdownHeight = description and 60 or 46
    
    -- Find default index
    local defaultIndex = 1
    if default then
        for i, item in pairs(items) do
            if item == default then
                defaultIndex = i
                break
            end
        end
    end
    
    local selected = items[defaultIndex] or "None"
    
    local dropdown = Create("Frame", {
        Name = "Dropdown_" .. name,
        BackgroundColor3 = CurrentTheme.Secondary,
        BackgroundTransparency = 0.4,
        Size = UDim2.new(1, 0, 0, dropdownHeight),
        Parent = tab.Content
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = dropdown
    })
    
    local dropdownTitle = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 8),
        Size = UDim2.new(1, -20, 0, 18),
        Font = SECONDARY_FONT,
        Text = name,
        TextColor3 = CurrentTheme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdown
    })
    
    if description then
        local descriptionLabel = Create("TextLabel", {
            Name = "Description",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 26),
            Size = UDim2.new(1, -20, 0, 16),
            Font = SECONDARY_FONT,
            Text = description,
            TextColor3 = CurrentTheme.TextSecondary,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = dropdown
        })
    end
    
    -- Create dropdown display
    local dropdownDisplay = Create("Frame", {
        Name = "Display",
        BackgroundColor3 = CurrentTheme.Primary,
        BackgroundTransparency = 0.3,
        Position = UDim2.new(1, -160, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 150, 0, 30),
        Parent = dropdown
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = dropdownDisplay
    })
    
    local selectedText = Create("TextLabel", {
        Name = "SelectedText",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        Font = SECONDARY_FONT,
        Text = selected,
        TextColor3 = CurrentTheme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdownDisplay
    })
    
    local dropdownArrow = Create("ImageLabel", {
        Name = "Arrow",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 16, 0, 16),
        Image = Icons.ChevronDown,
        ImageColor3 = CurrentTheme.TextSecondary,
        Parent = dropdownDisplay
    })
    
    -- Create dropdown button
    local dropdownButton = Create("TextButton", {
        Name = "Button",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = dropdownDisplay
    })
    
    -- Create dropdown list container - Parent to ScreenGui directly to avoid clipping
    local screenGui = dropdown:FindFirstAncestorOfClass("ScreenGui")
    local dropdownListOuterContainer = Create("Frame", {
        Name = "DropdownListOuterContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        ZIndex = 100,
        Parent = screenGui
    })
    
    -- Create dropdown list
    local dropdownList = Create("Frame", {
        Name = "DropdownList",
        BackgroundColor3 = CurrentTheme.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 150, 0, #items * 30 + 4), -- Height based on number of items
        Position = UDim2.new(0, 0, 0, 0), -- Will be set when opened
        ZIndex = 101,
        Visible = true,
        Parent = dropdownListOuterContainer
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = dropdownList
    })
    
    Create("UIStroke", {
        Color = CurrentTheme.Accent,
        Thickness = 1,
        Transparency = 0.5,
        Parent = dropdownList
    })
    
    -- Create dropdown items
    local maxItemWidth = 0
    for i, item in ipairs(items) do
        local itemButton = Create("TextButton", {
            Name = "Item_" .. i,
            BackgroundColor3 = (i == defaultIndex) and CurrentTheme.Accent or CurrentTheme.Primary,
            BackgroundTransparency = (i == defaultIndex) and 0.7 or 1,
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 0, (i - 1) * 30 + 2),
            Font = SECONDARY_FONT,
            Text = "",
            ZIndex = 102,
            Parent = dropdownList
        })
        
        local itemText = Create("TextLabel", {
            Name = "Text",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -15, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Font = SECONDARY_FONT,
            Text = item,
            TextColor3 = (i == defaultIndex) and CurrentTheme.TextPrimary or CurrentTheme.TextSecondary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 103,
            Parent = itemButton
        })
        
        -- Calculate item width for dropdown sizing
        local textSize = TextService:GetTextSize(item, 14, SECONDARY_FONT, Vector2.new(math.huge, 30))
        maxItemWidth = math.max(maxItemWidth, textSize.X + 20) -- 20 for padding
        
        -- Item button events
        itemButton.MouseEnter:Connect(function()
            if selected ~= item then
                Tween(itemButton, {BackgroundTransparency = 0.7}, 0.2)
                Tween(itemText, {TextColor3 = CurrentTheme.TextPrimary}, 0.2)
            end
        end)
        
        itemButton.MouseLeave:Connect(function()
            if selected ~= item then
                Tween(itemButton, {BackgroundTransparency = 1}, 0.2)
                Tween(itemText, {TextColor3 = CurrentTheme.TextSecondary}, 0.2)
            end
        end)
        
        itemButton.MouseButton1Click:Connect(function()
            selectedText.Text = item
            selected = item
            
            callback(item)
            
            if flag then
                TBD.Flags[flag] = item
            end
            
            -- Close dropdown
            dropdownListOuterContainer.Visible = false
            
            -- Update selected item visual
            for _, child in ipairs(dropdownList:GetChildren()) do
                if child:IsA("TextButton") then
                    Tween(child, {BackgroundColor3 = CurrentTheme.Primary, BackgroundTransparency = 1}, 0.2)
                    local childText = child:FindFirstChild("Text")
                    if childText then
                        Tween(childText, {TextColor3 = CurrentTheme.TextSecondary}, 0.2)
                    end
                end
            end
            
            Tween(itemButton, {BackgroundColor3 = CurrentTheme.Accent, BackgroundTransparency = 0.7}, 0.2)
            Tween(itemText, {TextColor3 = CurrentTheme.TextPrimary}, 0.2)
        end)
    end
    
    -- Adjust dropdown list width if needed
    maxItemWidth = math.max(maxItemWidth, 150) -- Minimum width
    dropdownList.Size = UDim2.new(0, maxItemWidth, 0, #items * 30 + 4)
    
    -- Add a scrolling frame for many items
    if #items > 8 then
        dropdownList.Size = UDim2.new(0, maxItemWidth, 0, 8 * 30 + 4)
        
        local scrollingFrame = Create("ScrollingFrame", {
            Name = "ScrollingItems",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, #items * 30 + 4),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = CurrentTheme.Accent,
            BorderSizePixel = 0,
            ZIndex = 102,
            Parent = dropdownList
        })
        
        -- Move all items to the scrolling frame
        for _, child in ipairs(dropdownList:GetChildren()) do
            if child:IsA("TextButton") then
                child.Parent = scrollingFrame
            end
        end
    end
    
    -- Toggle dropdown visibility
    local dropdownOpen = false
    
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        
        if dropdownOpen then
            -- Position the dropdown based on the button's position
            local buttonAbsPos = dropdownDisplay.AbsolutePosition
            local buttonAbsSize = dropdownDisplay.AbsoluteSize
            
            -- IMPORTANT: Position dropdown in the screen space, not relative to the button
            local screenSize = workspace.CurrentCamera.ViewportSize
            local dropdownAbsSize = dropdownList.AbsoluteSize
            
            -- Try to position below the button
            local posY = buttonAbsPos.Y + buttonAbsSize.Y + 5
            
            -- Check if it would go off the bottom of the screen
            if posY + dropdownAbsSize.Y > screenSize.Y - 10 then
                -- Position above the button instead
                posY = buttonAbsPos.Y - dropdownAbsSize.Y - 5
            end
            
            -- Ensure it doesn't go off screen horizontally
            local posX = buttonAbsPos.X
            if posX + dropdownAbsSize.X > screenSize.X - 10 then
                posX = screenSize.X - dropdownAbsSize.X - 10
            end
            
            -- Set the dropdown position
            dropdownList.Position = UDim2.new(0, posX, 0, posY)
            dropdownListOuterContainer.Visible = true
            
            -- Rotate arrow
            Tween(dropdownArrow, {Rotation = 180}, 0.2)
        else
            dropdownListOuterContainer.Visible = false
            
            -- Reset arrow rotation
            Tween(dropdownArrow, {Rotation = 0}, 0.2)
        end
    end)
    
    -- Close dropdown when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dropdownOpen then
                local mousePos = UserInputService:GetMouseLocation() - Vector2.new(0, 36)
                local dropdownAbsPos = dropdownList.AbsolutePosition
                local dropdownAbsSize = dropdownList.AbsoluteSize
                
                local inDropdown = mousePos.X >= dropdownAbsPos.X and 
                                   mousePos.X <= dropdownAbsPos.X + dropdownAbsSize.X and
                                   mousePos.Y >= dropdownAbsPos.Y and 
                                   mousePos.Y <= dropdownAbsPos.Y + dropdownAbsSize.Y
                
                local buttonAbsPos = dropdownDisplay.AbsolutePosition
                local buttonAbsSize = dropdownDisplay.AbsoluteSize
                
                local inButton = mousePos.X >= buttonAbsPos.X and 
                                mousePos.X <= buttonAbsPos.X + buttonAbsSize.X and
                                mousePos.Y >= buttonAbsPos.Y and 
                                mousePos.Y <= buttonAbsPos.Y + buttonAbsSize.Y
                
                if not inDropdown and not inButton then
                    dropdownOpen = false
                    dropdownListOuterContainer.Visible = false
                    Tween(dropdownArrow, {Rotation = 0}, 0.2)
                end
            end
        end
    end)
    
    -- Hover effect for dropdown button
    dropdownButton.MouseEnter:Connect(function()
        Tween(dropdown, {BackgroundTransparency = 0.2}, 0.2)
        Tween(dropdownDisplay, {BackgroundTransparency = 0.1}, 0.2)
    end)
    
    dropdownButton.MouseLeave:Connect(function()
        Tween(dropdown, {BackgroundTransparency = 0.4}, 0.2)
        Tween(dropdownDisplay, {BackgroundTransparency = 0.3}, 0.2)
    end)
    
    -- Create dropdown object for external control
    local dropdownObject = {
        Selected = selected,
        
        Set = function(self, item)
            -- Check if item exists
            local exists = false
            for _, v in ipairs(items) do
                if v == item then
                    exists = true
                    break
                end
            end
            
            if not exists then return end
            
            selectedText.Text = item
            selected = item
            
            -- Call the callback
            callback(item)
            
            -- Update flag if provided
            if flag then
                TBD.Flags[flag] = item
            end
            
            -- Update visual selection in dropdown list
            for _, child in ipairs(dropdownList:GetChildren()) do
                if child:IsA("TextButton") or child:IsA("ScrollingFrame") then
                    local buttons = child:IsA("ScrollingFrame") and child:GetChildren() or {child}
                    
                    for _, button in ipairs(buttons) do
                        if button:IsA("TextButton") then
                            local btnText = button:FindFirstChild("Text")
                            if btnText then
                                if btnText.Text == item then
                                    Tween(button, {BackgroundColor3 = CurrentTheme.Accent, BackgroundTransparency = 0.7}, 0.2)
                                    Tween(btnText, {TextColor3 = CurrentTheme.TextPrimary}, 0.2)
                                else
                                    Tween(button, {BackgroundColor3 = CurrentTheme.Primary, BackgroundTransparency = 1}, 0.2)
                                    Tween(btnText, {TextColor3 = CurrentTheme.TextSecondary}, 0.2)
                                end
                            end
                        end
                    end
                end
            end
        end,
        
        Refresh = function(self, newItems, newValue)
            items = newItems or items
            
            -- Clear old items
            for _, child in ipairs(dropdownList:GetChildren()) do
                if child:IsA("TextButton") or child:IsA("ScrollingFrame") then
                    child:Destroy()
                end
            end
            
            -- Add new items
            local maxItemWidth = 0
            for i, item in ipairs(items) do
                local itemButton = Create("TextButton", {
                    Name = "Item_" .. i,
                    BackgroundColor3 = (item == selected) and CurrentTheme.Accent or CurrentTheme.Primary,
                    BackgroundTransparency = (item == selected) and 0.7 or 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0, (i - 1) * 30 + 2),
                    Font = SECONDARY_FONT,
                    Text = "",
                    ZIndex = 102,
                    Parent = dropdownList
                })
                
                local itemText = Create("TextLabel", {
                    Name = "Text",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -15, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    Font = SECONDARY_FONT,
                    Text = item,
                    TextColor3 = (item == selected) and CurrentTheme.TextPrimary or CurrentTheme.TextSecondary,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 103,
                    Parent = itemButton
                })
                
                -- Calculate item width for dropdown sizing
                local textSize = TextService:GetTextSize(item, 14, SECONDARY_FONT, Vector2.new(math.huge, 30))
                maxItemWidth = math.max(maxItemWidth, textSize.X + 20) -- 20 for padding
                
                -- Item button events
                itemButton.MouseEnter:Connect(function()
                    if selected ~= item then
                        Tween(itemButton, {BackgroundTransparency = 0.7}, 0.2)
                        Tween(itemText, {TextColor3 = CurrentTheme.TextPrimary}, 0.2)
                    end
                end)
                
                itemButton.MouseLeave:Connect(function()
                    if selected ~= item then
                        Tween(itemButton, {BackgroundTransparency = 1}, 0.2)
                        Tween(itemText, {TextColor3 = CurrentTheme.TextSecondary}, 0.2)
                    end
                end)
                
                itemButton.MouseButton1Click:Connect(function()
                    selectedText.Text = item
                    selected = item
                    
                    callback(item)
                    
                    if flag then
                        TBD.Flags[flag] = item
                    end
                    
                    -- Close dropdown
                    dropdownListOuterContainer.Visible = false
                    dropdownOpen = false
                    
                    -- Reset arrow rotation
                    Tween(dropdownArrow, {Rotation = 0}, 0.2)
                    
                    -- Update selected item visual
                    for _, btn in ipairs(dropdownList:GetChildren()) do
                        if btn:IsA("TextButton") then
                            Tween(btn, {BackgroundColor3 = CurrentTheme.Primary, BackgroundTransparency = 1}, 0.2)
                            local childText = btn:FindFirstChild("Text")
                            if childText then
                                Tween(childText, {TextColor3 = CurrentTheme.TextSecondary}, 0.2)
                            end
                        end
                    end
                    
                    Tween(itemButton, {BackgroundColor3 = CurrentTheme.Accent, BackgroundTransparency = 0.7}, 0.2)
                    Tween(itemText, {TextColor3 = CurrentTheme.TextPrimary}, 0.2)
                end)
            end
            
            -- Adjust dropdown list size
            maxItemWidth = math.max(maxItemWidth, 150) -- Minimum width
            dropdownList.Size = UDim2.new(0, maxItemWidth, 0, math.min(#items, 8) * 30 + 4)
            
            -- Add scrolling frame for many items
            if #items > 8 then
                local scrollingFrame = Create("ScrollingFrame", {
                    Name = "ScrollingItems",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, #items * 30 + 4),
                    ScrollBarThickness = 4,
                    ScrollBarImageColor3 = CurrentTheme.Accent,
                    BorderSizePixel = 0,
                    ZIndex = 102,
                    Parent = dropdownList
                })
                
                -- Move all items to the scrolling frame
                for _, child in ipairs(dropdownList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.Parent = scrollingFrame
                    end
                end
            end
            
            -- Set new selected value if provided
            if newValue then
                self:Set(newValue)
            else
                -- If the previously selected item no longer exists
                local exists = false
                for _, item in ipairs(items) do
                    if item == selected then
                        exists = true
                        break
                    end
                end
                
                if not exists and #items > 0 then
                    self:Set(items[1])
                end
            end
        end
    }
    
    -- Initialize flag if provided
    if flag then
        TBD.Flags[flag] = selected
    end
    
    return dropdownObject
end
-- FIXED COLOR PICKER IMPLEMENTATION FOR TBD-COMPLETE-FIXED-V5.lua

-- CREATE COLOR PICKER METHOD - Fixed positioning and functionality
tab.CreateColorPicker = function(_, options)
    options = options or {}
    local name = options.Name or "Color Picker"
    local description = options.Description
    local color = options.Color or Color3.fromRGB(255, 255, 255)
    local callback = options.Callback or function() end
    local flag = options.Flag
    
    local colorPickerHeight = description and 60 or 46
    
    local colorPicker = Create("Frame", {
        Name = "ColorPicker_" .. name,
        BackgroundColor3 = CurrentTheme.Secondary,
        BackgroundTransparency = 0.4,
        Size = UDim2.new(1, 0, 0, colorPickerHeight),
        Parent = tab.Content
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = colorPicker
    })
    
    local colorPickerTitle = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 8),
        Size = UDim2.new(1, -60, 0, 18),
        Font = SECONDARY_FONT,
        Text = name,
        TextColor3 = CurrentTheme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = colorPicker
    })
    
    if description then
        local descriptionLabel = Create("TextLabel", {
            Name = "Description",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 26),
            Size = UDim2.new(1, -60, 0, 16),
            Font = SECONDARY_FONT,
            Text = description,
            TextColor3 = CurrentTheme.TextSecondary,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = colorPicker
        })
    end
    
    -- Create the color preview
    local colorPreview = Create("Frame", {
        Name = "ColorPreview",
        BackgroundColor3 = color,
        Position = UDim2.new(1, -50, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 40, 0, 24),
        Parent = colorPicker
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = colorPreview
    })
    
    Create("UIStroke", {
        Color = CurrentTheme.TextSecondary,
        Thickness = 1,
        Transparency = 0.5,
        Parent = colorPreview
    })
    
    -- Create clickable button
    local colorButton = Create("TextButton", {
        Name = "Button",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = colorPicker
    })
    
    -- Create color picker popup container - Parent to ScreenGui directly to avoid clipping
    local screenGui = colorPicker:FindFirstAncestorOfClass("ScreenGui")
    local colorPickerPopupContainer = Create("Frame", {
        Name = "ColorPickerPopupContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        ZIndex = 200, -- Higher z-index to appear above everything else
        Parent = screenGui
    })
    
    -- Create the actual color picker popup
    local colorPickerPopup = Create("Frame", {
        Name = "ColorPickerPopup",
        BackgroundColor3 = CurrentTheme.Background,
        Size = UDim2.new(0, 220, 0, 260),
        Position = UDim2.new(0, 0, 0, 0), -- Will be set when opened
        ZIndex = 201,
        Parent = colorPickerPopupContainer
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = colorPickerPopup
    })
    
    Create("UIStroke", {
        Color = CurrentTheme.Accent,
        Thickness = 1.5,
        Transparency = 0.5,
        Parent = colorPickerPopup
    })
    
    -- Color picker header
    local popupHeader = Create("Frame", {
        Name = "Header",
        BackgroundColor3 = CurrentTheme.Secondary,
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = 202,
        Parent = colorPickerPopup
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = popupHeader
    })
    
    -- Only round top corners of header
    local popupHeaderFix = Create("Frame", {
        Name = "HeaderFix",
        BackgroundColor3 = CurrentTheme.Secondary,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0),
        ZIndex = 202,
        Parent = popupHeader
    })
    
    local popupTitle = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Font = DEFAULT_FONT,
        Text = "Color Picker",
        TextColor3 = CurrentTheme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 203,
        Parent = popupHeader
    })
    
    local popupClose = Create("ImageButton", {
        Name = "Close",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 16, 0, 16),
        Image = Icons.Close,
        ImageColor3 = CurrentTheme.TextSecondary,
        ZIndex = 203,
        Parent = popupHeader
    })
    
    -- Color display
    local currentColorDisplay = Create("Frame", {
        Name = "CurrentColor",
        BackgroundColor3 = color,
        Position = UDim2.new(0.5, 0, 0, 45),
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(0, 180, 0, 30),
        ZIndex = 202,
        Parent = colorPickerPopup
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = currentColorDisplay
    })
    
    Create("UIStroke", {
        Color = CurrentTheme.TextSecondary,
        Thickness = 1,
        Transparency = 0.5,
        Parent = currentColorDisplay
    })
    
    -- RGB Sliders
    local rgbContainer = Create("Frame", {
        Name = "RGBContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 90),
        Size = UDim2.new(1, -20, 0, 100),
        ZIndex = 202,
        Parent = colorPickerPopup
    })
    
    -- RGB Values for sliders
    local rValue = math.floor(color.R * 255)
    local gValue = math.floor(color.G * 255)
    local bValue = math.floor(color.B * 255)
    
    -- Create RGB sliders
    local function createColorSlider(name, value, color, yPos)
        local slider = Create("Frame", {
            Name = name .. "Slider",
            BackgroundColor3 = CurrentTheme.Secondary,
            BackgroundTransparency = 0.4,
            Position = UDim2.new(0, 0, 0, yPos),
            Size = UDim2.new(1, 0, 0, 20),
            ZIndex = 203,
            Parent = rgbContainer
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = slider
        })
        
        local sliderLabel = Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 5, 0, 0),
            Size = UDim2.new(0, 15, 1, 0),
            Font = SECONDARY_FONT,
            Text = name,
            TextColor3 = color,
            TextSize = 14,
            ZIndex = 204,
            Parent = slider
        })
        
        local sliderValue = Create("TextLabel", {
            Name = "Value",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -40, 0, 0),
            Size = UDim2.new(0, 35, 1, 0),
            Font = SECONDARY_FONT,
            Text = tostring(value),
            TextColor3 = CurrentTheme.TextSecondary,
            TextSize = 14,
            ZIndex = 204,
            Parent = slider
        })
        
        local sliderTrack = Create("Frame", {
            Name = "Track",
            BackgroundColor3 = CurrentTheme.Secondary,
            BackgroundTransparency = 0.2,
            Position = UDim2.new(0, 25, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.new(1, -70, 0, 6),
            ZIndex = 204,
            Parent = slider
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = sliderTrack
        })
        
        local sliderFill = Create("Frame", {
            Name = "Fill",
            BackgroundColor3 = color,
            Size = UDim2.new(value/255, 0, 1, 0),
            ZIndex = 205,
            Parent = sliderTrack
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = sliderFill
        })
        
        local sliderThumb = Create("Frame", {
            Name = "Thumb",
            BackgroundColor3 = color,
            Position = UDim2.new(value/255, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, 10, 0, 10),
            ZIndex = 206,
            Parent = sliderTrack
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = sliderThumb
        })
        
        -- Make the thumb draggable
        local isDragging = false
        
        sliderThumb.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
            end
        end)
        
        sliderTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                
                -- Update on click
                local trackAbsPos = sliderTrack.AbsolutePosition
                local trackAbsSize = sliderTrack.AbsoluteSize
                local mousePos = UserInputService:GetMouseLocation() - Vector2.new(0, 36)
                
                local relativeX = math.clamp((mousePos.X - trackAbsPos.X) / trackAbsSize.X, 0, 1)
                local newValue = math.floor(relativeX * 255)
                
                -- Update slider
                sliderValue.Text = tostring(newValue)
                sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                sliderThumb.Position = UDim2.new(relativeX, 0, 0.5, 0)
                
                -- Update color display
                local newColor = Color3.new(
                    name == "R" and newValue/255 or rValue/255,
                    name == "G" and newValue/255 or gValue/255,
                    name == "B" and newValue/255 or bValue/255
                )
                currentColorDisplay.BackgroundColor3 = newColor
                
                -- Update color value
                if name == "R" then rValue = newValue
                elseif name == "G" then gValue = newValue
                elseif name == "B" then bValue = newValue end
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local trackAbsPos = sliderTrack.AbsolutePosition
                local trackAbsSize = sliderTrack.AbsoluteSize
                local mousePos = UserInputService:GetMouseLocation() - Vector2.new(0, 36)
                
                local relativeX = math.clamp((mousePos.X - trackAbsPos.X) / trackAbsSize.X, 0, 1)
                local newValue = math.floor(relativeX * 255)
                
                -- Update slider
                sliderValue.Text = tostring(newValue)
                sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                sliderThumb.Position = UDim2.new(relativeX, 0, 0.5, 0)
                
                -- Update color display
                local newColor = Color3.new(
                    name == "R" and newValue/255 or rValue/255,
                    name == "G" and newValue/255 or gValue/255,
                    name == "B" and newValue/255 or bValue/255
                )
                currentColorDisplay.BackgroundColor3 = newColor
                
                -- Update color value
                if name == "R" then rValue = newValue
                elseif name == "G" then gValue = newValue
                elseif name == "B" then bValue = newValue end
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
            end
        end)
        
        return {
            Slider = slider,
            Track = sliderTrack,
            Fill = sliderFill,
            Thumb = sliderThumb,
            ValueLabel = sliderValue
        }
    end
    
    local rSlider = createColorSlider("R", rValue, Color3.fromRGB(255, 50, 50), 0)
    local gSlider = createColorSlider("G", gValue, Color3.fromRGB(50, 255, 50), 30)
    local bSlider = createColorSlider("B", bValue, Color3.fromRGB(50, 50, 255), 60)
    
    -- Apply button
    local applyButton = Create("TextButton", {
        Name = "ApplyButton",
        BackgroundColor3 = CurrentTheme.Accent,
        Position = UDim2.new(0.5, 0, 1, -40),
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(0, 100, 0, 30),
        Font = DEFAULT_FONT,
        Text = "Apply",
        TextColor3 = CurrentTheme.TextPrimary,
        ZIndex = 202,
        Parent = colorPickerPopup
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = applyButton
    })
    
    -- Function to update color display
    local function updateColorDisplay(newColor)
        currentColorDisplay.BackgroundColor3 = newColor
    end
    
    -- Function to update color preview
    local function updateColorPreview(newColor)
        colorPreview.BackgroundColor3 = newColor
    end
    
    -- Function to open color picker
    local isColorPickerOpen = false
    local function openColorPicker()
        isColorPickerOpen = true
        
        -- IMPORTANT: Position in the screen space, not relative to the preview
        local previewAbsPos = colorPreview.AbsolutePosition
        local previewAbsSize = colorPreview.AbsoluteSize
        local screenSize = workspace.CurrentCamera.ViewportSize
        local popupWidth = colorPickerPopup.AbsoluteSize.X
        local popupHeight = colorPickerPopup.AbsoluteSize.Y
        
        -- Try to position it to the right of the preview first
        local posX = previewAbsPos.X + previewAbsSize.X + 10
        
        -- If it would go off the right side of the screen, position it to the left
        if posX + popupWidth > screenSize.X - 10 then
            posX = previewAbsPos.X - popupWidth - 10
        end
        
        -- Ensure it doesn't go off the left side either
        posX = math.clamp(posX, 10, screenSize.X - popupWidth - 10)
        
        -- Vertical position - try to align with the middle of the preview
        local posY = previewAbsPos.Y - (popupHeight - previewAbsSize.Y) / 2
        
        -- Make sure it doesn't go off the top or bottom
        posY = math.clamp(posY, 10, screenSize.Y - popupHeight - 10)
        
        -- Set the position and show the popup
        colorPickerPopup.Position = UDim2.new(0, posX, 0, posY)
        colorPickerPopupContainer.Visible = true
        
        -- Update the color display with current color
        updateColorDisplay(color)
        
        -- Set RGB slider values from current color
        rValue = math.floor(color.R * 255)
        gValue = math.floor(color.G * 255)
        bValue = math.floor(color.B * 255)
        
        rSlider.ValueLabel.Text = tostring(rValue)
        rSlider.Fill.Size = UDim2.new(rValue/255, 0, 1, 0)
        rSlider.Thumb.Position = UDim2.new(rValue/255, 0, 0.5, 0)
        
        gSlider.ValueLabel.Text = tostring(gValue)
        gSlider.Fill.Size = UDim2.new(gValue/255, 0, 1, 0)
        gSlider.Thumb.Position = UDim2.new(gValue/255, 0, 0.5, 0)
        
        bSlider.ValueLabel.Text = tostring(bValue)
        bSlider.Fill.Size = UDim2.new(bValue/255, 0, 1, 0)
        bSlider.Thumb.Position = UDim2.new(bValue/255, 0, 0.5, 0)
    end
    
    -- Function to close color picker
    local function closeColorPicker()
        isColorPickerOpen = false
        colorPickerPopupContainer.Visible = false
    end
    
    -- Apply button functionality
    applyButton.MouseButton1Click:Connect(function()
        -- Get the color from RGB values
        local newColor = Color3.new(rValue/255, gValue/255, bValue/255)
        color = newColor
        
        updateColorPreview(color)
        callback(color)
        
        if flag then
            TBD.Flags[flag] = color
        end
        
        closeColorPicker()
    end)
    
    -- Button hover effect
    applyButton.MouseEnter:Connect(function()
        Tween(applyButton, {BackgroundColor3 = CurrentTheme.DarkAccent}, 0.2)
    end)
    
    applyButton.MouseLeave:Connect(function()
        Tween(applyButton, {BackgroundColor3 = CurrentTheme.Accent}, 0.2)
    end)
    
    -- Close button functionality
    popupClose.MouseButton1Click:Connect(closeColorPicker)
    
    -- Open color picker on click
    colorButton.MouseButton1Click:Connect(function()
        if isColorPickerOpen then
            closeColorPicker()
        else
            openColorPicker()
        end
    end)
    
    -- Hover effects
    colorButton.MouseEnter:Connect(function()
        Tween(colorPicker, {BackgroundTransparency = 0.2}, 0.2)
    end)
    
    colorButton.MouseLeave:Connect(function()
        Tween(colorPicker, {BackgroundTransparency = 0.4}, 0.2)
    end)
    
    -- Close color picker when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isColorPickerOpen then
                local mousePos = UserInputService:GetMouseLocation() - Vector2.new(0, 36)
                
                -- Check if click is within color picker popup
                local inPopup = false
                local popupAbsPos = colorPickerPopup.AbsolutePosition
                local popupAbsSize = colorPickerPopup.AbsoluteSize
                
                inPopup = mousePos.X >= popupAbsPos.X and 
                          mousePos.X <= popupAbsPos.X + popupAbsSize.X and
                          mousePos.Y >= popupAbsPos.Y and 
                          mousePos.Y <= popupAbsPos.Y + popupAbsSize.Y
                
                -- Check if click is within color preview
                local inPreview = false
                local previewAbsPos = colorPreview.AbsolutePosition
                local previewAbsSize = colorPreview.AbsoluteSize
                
                inPreview = mousePos.X >= previewAbsPos.X and 
                           mousePos.X <= previewAbsPos.X + previewAbsSize.X and
                           mousePos.Y >= previewAbsPos.Y and 
                           mousePos.Y <= previewAbsPos.Y + previewAbsSize.Y
                
                if not inPopup and not inPreview then
                    closeColorPicker()
                end
            end
        end
    end)
    
    -- Create the color picker object
    local colorPickerObject = {
        Color = color,
        
        Set = function(self, newColor)
            color = newColor
            updateColorPreview(color)
            
            -- Update RGB values for sliders
            rValue = math.floor(color.R * 255)
            gValue = math.floor(color.G * 255)
            bValue = math.floor(color.B * 255)
            
            -- If the color picker is open, update the display and sliders
            if isColorPickerOpen then
                updateColorDisplay(color)
                
                rSlider.ValueLabel.Text = tostring(rValue)
                rSlider.Fill.Size = UDim2.new(color.R, 0, 1, 0)
                rSlider.Thumb.Position = UDim2.new(color.R, 0, 0.5, 0)
                
                gSlider.ValueLabel.Text = tostring(gValue)
                gSlider.Fill.Size = UDim2.new(color.G, 0, 1, 0)
                gSlider.Thumb.Position = UDim2.new(color.G, 0, 0.5, 0)
                
                bSlider.ValueLabel.Text = tostring(bValue)
                bSlider.Fill.Size = UDim2.new(color.B, 0, 1, 0)
                bSlider.Thumb.Position = UDim2.new(color.B, 0, 0.5, 0)
            end
            
            -- Call the callback
            callback(color)
            
            -- Update flag if provided
            if flag then
                TBD.Flags[flag] = color
            end
        end
    }
    
    -- Initialize flag if provided
    if flag then
        TBD.Flags[flag] = color
    end
    
    return colorPickerObject
end
    -- CREATE DROPDOWN METHOD
    tab.CreateDropdown = function(_, options)
        options = options or {}
        local name = options.Name or "Dropdown"
        local description = options.Description
        local items = options.Items or {}
        local defaultItem = options.Default or items[1] or "Select..."
        local callback = options.Callback or function() end
        local flag = options.Flag
        
        local dropdownHeight = description and 60 or 46
        
        local dropdown = Create("Frame", {
            Name = "Dropdown_" .. name,
            BackgroundColor3 = CurrentTheme.Secondary,
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 0, 0, dropdownHeight),
            Parent = tab.Content
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(dropdown, {BackgroundColor3 = "Secondary"})
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = dropdown
        })
        
        local dropdownTitle = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 8),
            Size = UDim2.new(1, -20, 0, 18),
            Font = SECONDARY_FONT,
            Text = name,
            TextColor3 = CurrentTheme.TextPrimary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = dropdown
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(dropdownTitle, {TextColor3 = "TextPrimary"})
        
        if description then
            local descriptionLabel = Create("TextLabel", {
                Name = "Description",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 26),
                Size = UDim2.new(1, -20, 0, 16),
                Font = SECONDARY_FONT,
                Text = description,
                TextColor3 = CurrentTheme.TextSecondary,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdown
            })
            
            -- Register for theme updates (NEW)
            TBD:RegisterThemeable(descriptionLabel, {TextColor3 = "TextSecondary"})
        end
        
        -- Create dropdown display
        local dropdownDisplay = Create("Frame", {
            Name = "DropdownDisplay",
            BackgroundColor3 = CurrentTheme.Background,
            BackgroundTransparency = 0.6,
            Position = UDim2.new(0, 10, 0, description and 45 or 30),
            Size = UDim2.new(1, -20, 0, 30),
            Parent = dropdown
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(dropdownDisplay, {BackgroundColor3 = "Background"})
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = dropdownDisplay
        })
        
        local selectedItem = Create("TextLabel", {
            Name = "SelectedItem",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -40, 1, 0),
            Font = SECONDARY_FONT,
            Text = defaultItem,
            TextColor3 = CurrentTheme.TextSecondary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = dropdownDisplay
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(selectedItem, {TextColor3 = "TextSecondary"})
        
        local dropdownArrow = Create("ImageLabel", {
            Name = "Arrow",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -25, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, 16, 0, 16),
            Image = Icons.ChevronDown,
            ImageColor3 = CurrentTheme.TextSecondary,
            Parent = dropdownDisplay
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(dropdownArrow, {ImageColor3 = "TextSecondary"})
        
        -- Create dropdown button
        local dropdownButton = Create("TextButton", {
            Name = "Button",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            Parent = dropdownDisplay
        })
        
        -- FIXED DROPDOWN IMPLEMENTATION
        local isOpen = false
        local dropdownMenu -- Will store the dropdown menu frame
        local currentSelectedItem = defaultItem
        
        -- Function to update selected item
        local function updateSelection(item)
            selectedItem.Text = item
            currentSelectedItem = item
            
            -- Call callback
            callback(item)
            
            -- Update flag if provided
            if flag then
                TBD.Flags[flag] = item
            end
        end
        
        -- Function to find the ScreenGui parent to properly position dropdown
        local function findScreenGuiParent()
            local currentParent = dropdown.Parent
            while currentParent and not (currentParent:IsA("ScreenGui") or currentParent:IsA("PlayerGui")) do
                currentParent = currentParent.Parent
            end
            return currentParent
        end
        
        -- Function to close dropdown menu
        local function closeDropdown()
            if isOpen and dropdownMenu then
                isOpen = false
                
                -- Reset arrow rotation
                Tween(dropdownArrow, {Rotation = 0}, 0.2)
                
                -- Destroy dropdown menu
                if dropdownMenu and dropdownMenu.Parent then
                    dropdownMenu:Destroy()
                    dropdownMenu = nil
                end
            end
        end
        
        -- Function to open dropdown menu
        local function openDropdown()
            -- Close if already open
            if isOpen then
                closeDropdown()
                return
            end
            
            isOpen = true
            
            -- Rotate arrow
            Tween(dropdownArrow, {Rotation = 180}, 0.2)
            
            -- Find the ScreenGui to parent the dropdown menu to
            local screenGui = findScreenGuiParent()
            if not screenGui then
                warn("TBD UI: Could not find ScreenGui parent for dropdown menu")
                screenGui = game:GetService("CoreGui")
                
                -- If we still can't get a parent, try player's PlayerGui
                if not pcall(function() local _ = screenGui.Parent end) then
                    screenGui = Players.LocalPlayer:WaitForChild("PlayerGui")
                end
            end
            
            -- If there's still no valid parent, use the dropdown's parent
            if not screenGui then
                screenGui = dropdown.Parent
            end
            
            -- Get absolute position for dropdown menu
            local dropdownAbsPos = dropdownDisplay.AbsolutePosition
            local dropdownAbsSize = dropdownDisplay.AbsoluteSize
            
            -- Calculate maximum height based on screen size and position
            local maxItems = math.min(7, #items) -- Show max 7 items at once
            local itemHeight = 28
            local menuHeight = math.min(maxItems * itemHeight, #items * itemHeight)
            
            -- Create dropdown menu container
            dropdownMenu = Create("Frame", {
                Name = "DropdownMenu",
                BackgroundColor3 = CurrentTheme.Secondary,
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, dropdownAbsPos.X, 0, dropdownAbsPos.Y + dropdownAbsSize.Y + 5),
                Size = UDim2.new(0, dropdownAbsSize.X, 0, menuHeight),
                ZIndex = 100,
                Visible = true,
                Parent = screenGui
            })
            
            -- Register for theme updates (NEW)
            TBD:RegisterThemeable(dropdownMenu, {BackgroundColor3 = "Secondary"})
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = dropdownMenu
            })
            
            -- Add a stroke
            local menuStroke = Create("UIStroke", {
                Color = CurrentTheme.Accent,
                Thickness = 1,
                Transparency = 0.5,
                Parent = dropdownMenu
            })
            
            -- Register for theme updates (NEW)
            TBD:RegisterThemeable(menuStroke, {Color = "Accent"})
            
            -- Create scrolling frame for items
            local menuScroll = Create("ScrollingFrame", {
                Name = "MenuScroll",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                CanvasSize = UDim2.new(0, 0, 0, #items * itemHeight),
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = CurrentTheme.Accent,
                VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
                ZIndex = 101,
                Parent = dropdownMenu
            })
            
            -- Register for theme updates (NEW)
            TBD:RegisterThemeable(menuScroll, {ScrollBarImageColor3 = "Accent"})
            
            Create("UIPadding", {
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5),
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5),
                Parent = menuScroll
            })
            
            Create("UIListLayout", {
                Padding = UDim.new(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = menuScroll
            })
            
            -- Add items to the dropdown menu
            for i, item in ipairs(items) do
                local itemBtn = Create("TextButton", {
                    Name = "Item_" .. i,
                    BackgroundColor3 = (item == currentSelectedItem) and CurrentTheme.Accent or CurrentTheme.Background,
                    BackgroundTransparency = (item == currentSelectedItem) and 0.5 or 0.8,
                    Size = UDim2.new(1, -10, 0, itemHeight - 4),
                    Font = SECONDARY_FONT,
                    Text = item,
                    TextColor3 = (item == currentSelectedItem) and CurrentTheme.TextPrimary or CurrentTheme.TextSecondary,
                    TextSize = 14,
                    ZIndex = 102,
                    Parent = menuScroll
                })
                
                -- Determine which theme colors to register based on selection state
                if item == currentSelectedItem then
                    -- Register for theme updates (NEW)
                    TBD:RegisterThemeable(itemBtn, {
                        BackgroundColor3 = "Accent",
                        TextColor3 = "TextPrimary"
                    })
                else
                    -- Register for theme updates (NEW)
                    TBD:RegisterThemeable(itemBtn, {
                        BackgroundColor3 = "Background",
                        TextColor3 = "TextSecondary"
                    })
                end
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = itemBtn
                })
                
                -- Hover effect
                itemBtn.MouseEnter:Connect(function()
                    if item ~= currentSelectedItem then
                        Tween(itemBtn, {BackgroundTransparency = 0.6}, 0.2)
                    end
                end)
                
                itemBtn.MouseLeave:Connect(function()
                    if item ~= currentSelectedItem then
                        Tween(itemBtn, {BackgroundTransparency = 0.8}, 0.2)
                    end
                end)
                
                -- Selection
                itemBtn.MouseButton1Click:Connect(function()
                    updateSelection(item)
                    closeDropdown()
                end)
            end
            
            -- Close dropdown when clicking outside
            local function closeOnOutsideClick(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if dropdownMenu and isOpen then
                        local mousePos = UserInputService:GetMouseLocation() - Vector2.new(0, 36)
                        local menuPos = dropdownMenu.AbsolutePosition
                        local menuSize = dropdownMenu.AbsoluteSize
                        
                        -- Check if click is outside the dropdown menu
                        if mousePos.X < menuPos.X or 
                           mousePos.X > menuPos.X + menuSize.X or 
                           mousePos.Y < menuPos.Y or 
                           mousePos.Y > menuPos.Y + menuSize.Y then
                            closeDropdown()
                            maid:Remove("dropdownConnection")
                        end
                    end
                end
            end
            
            -- Create a simple maid for cleanup
            local maid = {
                _tasks = {}
            }
            
            function maid:Add(key, task)
                if self._tasks[key] then
                    self:Remove(key)
                end
                self._tasks[key] = task
                return task
            end
            
            function maid:Remove(key)
                if self._tasks[key] then
                    local connection = self._tasks[key]
                    if typeof(connection) == "RBXScriptConnection" then
                        connection:Disconnect()
                    elseif typeof(connection) == "function" then
                        connection()
                    end
                    self._tasks[key] = nil
                end
            end
            
            function maid:Destroy()
                for key, _ in pairs(self._tasks) do
                    self:Remove(key)
                end
                self._tasks = {}
            end
            
            maid:Add("dropdownConnection", UserInputService.InputBegan:Connect(closeOnOutsideClick))
            
            -- Make dropdown menu destroy itself when dropdown is destroyed
            if dropdown and dropdown.AncestryChanged then
                maid:Add("ancestryChanged", dropdown.AncestryChanged:Connect(function(_, parent)
                    if not parent then
                        closeDropdown()
                        maid:Destroy()
                    end
                end))
            end
        end
        
        dropdownButton.MouseButton1Click:Connect(function()
            dropdownButton:Blur() -- Remove focus from button
            openDropdown()
        end)
        
        -- Hover effects
        dropdownButton.MouseEnter:Connect(function()
            Tween(dropdown, {BackgroundTransparency = 0.2}, 0.2)
            Tween(dropdownDisplay, {BackgroundTransparency = 0.4}, 0.2)
        end)
        
        dropdownButton.MouseLeave:Connect(function()
            Tween(dropdown, {BackgroundTransparency = 0.4}, 0.2)
            Tween(dropdownDisplay, {BackgroundTransparency = 0.6}, 0.2)
        end)
        
        -- Create dropdown object for external control
        local dropdownObject = {
            Value = currentSelectedItem,
            
            Set = function(self, item)
                if table.find(items, item) then
                    updateSelection(item)
                end
            end,
            
            Refresh = function(self, newItems, newDefault)
                items = newItems or items
                
                -- Update default if provided
                if newDefault and table.find(items, newDefault) then
                    updateSelection(newDefault)
                elseif not table.find(items, currentSelectedItem) and #items > 0 then
                    -- If current selection is no longer in the items list, reset to first item
                    updateSelection(items[1])
                end
                
                -- Close dropdown if open
                closeDropdown()
            end,
            
            GetItems = function(self)
                return items
            end
        }
        
        -- Initialize flag if provided
        if flag then
            TBD.Flags[flag] = currentSelectedItem
        end
        
        return dropdownObject
    end
    -- CREATE COLOR PICKER METHOD
    tab.CreateColorPicker = function(_, options)
        options = options or {}
        local name = options.Name or "Color Picker"
        local description = options.Description
        local defaultColor = options.Color or Color3.fromRGB(255, 0, 0)
        local callback = options.Callback or function() end
        local flag = options.Flag
        
        local colorPickerHeight = description and 60 or 46
        
        local colorPicker = Create("Frame", {
            Name = "ColorPicker_" .. name,
            BackgroundColor3 = CurrentTheme.Secondary,
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 0, 0, colorPickerHeight),
            Parent = tab.Content
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(colorPicker, {BackgroundColor3 = "Secondary"})
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = colorPicker
        })
        
        local colorPickerTitle = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 8),
            Size = UDim2.new(1, -60, 0, 18),
            Font = SECONDARY_FONT,
            Text = name,
            TextColor3 = CurrentTheme.TextPrimary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = colorPicker
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(colorPickerTitle, {TextColor3 = "TextPrimary"})
        
        if description then
            local descriptionLabel = Create("TextLabel", {
                Name = "Description",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 26),
                Size = UDim2.new(1, -60, 0, 16),
                Font = SECONDARY_FONT,
                Text = description,
                TextColor3 = CurrentTheme.TextSecondary,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = colorPicker
            })
            
            -- Register for theme updates (NEW)
            TBD:RegisterThemeable(descriptionLabel, {TextColor3 = "TextSecondary"})
        end
        
        -- Create color preview
        local colorPreview = Create("Frame", {
            Name = "ColorPreview",
            BackgroundColor3 = defaultColor,
            Position = UDim2.new(1, -50, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, 30, 0, 30),
            Parent = colorPicker
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = colorPreview
        })
        
        local previewStroke = Create("UIStroke", {
            Color = Color3.fromRGB(100, 100, 100),
            Thickness = 1,
            Transparency = 0.5,
            Parent = colorPreview
        })
        
        -- Create button for interaction
        local colorPickerButton = Create("TextButton", {
            Name = "Button",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            Parent = colorPicker
        })
        
        -- Variables for color picker
        local currentColor = defaultColor
        local colorPickerGui -- Will store the color picker frame
        local isOpen = false
        
        -- Function to update color
        local function updateColor(color)
            currentColor = color
            colorPreview.BackgroundColor3 = color
            
            -- Call callback
            callback(color)
            
            -- Update flag if provided
            if flag then
                TBD.Flags[flag] = color
            end
        end
        
        -- Function to find the ScreenGui parent
        local function findScreenGuiParent()
            local current = colorPicker.Parent
            while current and not (current:IsA("ScreenGui") or current:IsA("PlayerGui")) do
                current = current.Parent
            end
            return current
        end
        
        -- Function to close color picker
        local function closeColorPicker()
            if isOpen and colorPickerGui then
                isOpen = false
                
                if colorPickerGui and colorPickerGui.Parent then
                    colorPickerGui:Destroy()
                    colorPickerGui = nil
                end
            end
        end
        
        -- Function to open color picker
        local function openColorPicker()
            -- Close if already open
            if isOpen then
                closeColorPicker()
                return
            end
            
            isOpen = true
            
            -- Find the ScreenGui to parent the color picker to
            local screenGui = findScreenGuiParent()
            if not screenGui then
                warn("TBD UI: Could not find ScreenGui parent for color picker")
                screenGui = game:GetService("CoreGui")
                
                -- If we still can't get a parent, try player's PlayerGui
                if not pcall(function() local _ = screenGui.Parent end) then
                    screenGui = Players.LocalPlayer:WaitForChild("PlayerGui")
                end
            end
            
            -- If there's still no valid parent, use the color picker's parent
            if not screenGui then
                screenGui = colorPicker.Parent
            end
            
            -- Get absolute position for color picker
            local pickerAbsPos = colorPreview.AbsolutePosition
            local pickerAbsSize = colorPreview.AbsoluteSize
            local screenSize = screenGui.AbsoluteSize
            
            -- Decide whether to show to the left or right of the color preview
            local showLeft = (pickerAbsPos.X + pickerAbsSize.X + 180 > screenSize.X)
            
            -- Create color picker container
            colorPickerGui = Create("Frame", {
                Name = "ColorPickerGui",
                BackgroundColor3 = CurrentTheme.Background,
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                Position = UDim2.new(
                    0, 
                    showLeft and (pickerAbsPos.X - 180 - 10) or (pickerAbsPos.X + pickerAbsSize.X + 10), 
                    0, 
                    pickerAbsPos.Y - 100
                ),
                Size = UDim2.new(0, 180, 0, 200),
                ZIndex = 100,
                Visible = true,
                Parent = screenGui
            })
            
            -- Register for theme updates (NEW)
            TBD:RegisterThemeable(colorPickerGui, {BackgroundColor3 = "Background"})
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = colorPickerGui
            })
            
            local pickerStroke = Create("UIStroke", {
                Color = CurrentTheme.Accent,
                Thickness = 1,
                Transparency = 0.5,
                Parent = colorPickerGui
            })
            
            -- Register for theme updates (NEW)
            TBD:RegisterThemeable(pickerStroke, {Color = "Accent"})
            
            -- Create title for color picker
            local pickerTitle = Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -20, 0, 20),
                Font = DEFAULT_FONT,
                Text = "Color Picker",
                TextColor3 = CurrentTheme.TextPrimary,
                TextSize = 14,
                ZIndex = 101,
                Parent = colorPickerGui
            })
            
            -- Register for theme updates (NEW)
            TBD:RegisterThemeable(pickerTitle, {TextColor3 = "TextPrimary"})
            
            -- Create RGB sliders
            local function createSlider(title, color, value, yPos)
                local sliderContainer = Create("Frame", {
                    Name = title .. "Slider",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, yPos),
                    Size = UDim2.new(1, -20, 0, 30),
                    ZIndex = 101,
                    Parent = colorPickerGui
                })
                
                local sliderTitle = Create("TextLabel", {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(0, 15, 1, 0),
                    Font = SECONDARY_FONT,
                    Text = title,
                    TextColor3 = CurrentTheme.TextSecondary,
                    TextSize = 14,
                    ZIndex = 102,
                    Parent = sliderContainer
                })
                
                -- Register for theme updates (NEW)
                TBD:RegisterThemeable(sliderTitle, {TextColor3 = "TextSecondary"})
                
                local sliderTrack = Create("Frame", {
                    Name = "Track",
                    BackgroundColor3 = CurrentTheme.Secondary,
                    Position = UDim2.new(0, 20, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(1, -50, 0, 4),
                    ZIndex = 102,
                    Parent = sliderContainer
                })
                
                -- Register for theme updates (NEW)
                TBD:RegisterThemeable(sliderTrack, {BackgroundColor3 = "Secondary"})
                
                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = sliderTrack
                })
                
                local sliderFill = Create("Frame", {
                    Name = "Fill",
                    BackgroundColor3 = color,
                    Size = UDim2.new(value/255, 0, 1, 0),
                    ZIndex = 103,
                    Parent = sliderTrack
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = sliderFill
                })
                
                local sliderKnob = Create("Frame", {
                    Name = "Knob",
                    BackgroundColor3 = color,
                    Position = UDim2.new(value/255, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Size = UDim2.new(0, 12, 0, 12),
                    ZIndex = 104,
                    Parent = sliderTrack
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = sliderKnob
                })
                
                local valueDisplay = Create("TextLabel", {
                    Name = "Value",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0, 0),
                    Size = UDim2.new(0, 25, 1, 0),
                    Font = SECONDARY_FONT,
                    Text = tostring(value),
                    TextColor3 = CurrentTheme.TextSecondary,
                    TextSize = 14,
                    ZIndex = 102,
                    Parent = sliderContainer
                })
                
                -- Register for theme updates (NEW)
                TBD:RegisterThemeable(valueDisplay, {TextColor3 = "TextSecondary"})
                
                -- Create slider button
                local sliderButton = Create("TextButton", {
                    Name = "Button",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 105,
                    Parent = sliderTrack
                })
                
                -- Variable to track if we're dragging this slider
                local isDragging = false
                
                -- Function to update slider value
                local function updateSlider(newValue)
                    -- Clamp between 0 and 255
                    newValue = math.clamp(newValue, 0, 255)
                    
                    -- Update slider visuals
                    Tween(sliderFill, {Size = UDim2.new(newValue/255, 0, 1, 0)}, 0.1)
                    Tween(sliderKnob, {Position = UDim2.new(newValue/255, 0, 0.5, 0)}, 0.1)
                    
                    -- Update value display
                    valueDisplay.Text = tostring(math.floor(newValue))
                    
                    return newValue
                end
                
                sliderButton.MouseButton1Down:Connect(function()
                    isDragging = true
                    
                    -- Update on initial click
                    local mousePos = UserInputService:GetMouseLocation() - Vector2.new(0, 36)
                    local relativeX = (mousePos.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
                    local newValue = math.clamp(relativeX * 255, 0, 255)
                    
                    -- Return the updated value
                    return updateSlider(newValue)
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
                        local mousePos = UserInputService:GetMouseLocation() - Vector2.new(0, 36)
                        local relativeX = (mousePos.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
                        local newValue = math.clamp(relativeX * 255, 0, 255)
                        
                        -- Return the updated value
                        return updateSlider(newValue)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                    end
                end)
                
                return {
                    Container = sliderContainer,
                    Track = sliderTrack,
                    Fill = sliderFill,
                    Knob = sliderKnob,
                    Value = valueDisplay,
                    UpdateSlider = updateSlider,
                    IsDragging = function() return isDragging end
                }
            end
            
            -- Create RGB sliders
            local rSlider = createSlider("R", Color3.fromRGB(255, 0, 0), math.floor(currentColor.R * 255), 30)
            local gSlider = createSlider("G", Color3.fromRGB(0, 255, 0), math.floor(currentColor.G * 255), 70)
            local bSlider = createSlider("B", Color3.fromRGB(0, 0, 255), math.floor(currentColor.B * 255), 110)
            
            -- Create preview of the color
            local colorPreviewBig = Create("Frame", {
                Name = "ColorPreview",
                BackgroundColor3 = currentColor,
                Position = UDim2.new(0.5, 0, 0, 150),
                AnchorPoint = Vector2.new(0.5, 0),
                Size = UDim2.new(0, 50, 0, 30),
                ZIndex = 101,
                Parent = colorPickerGui
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = colorPreviewBig
            })
            
            local previewBigStroke = Create("UIStroke", {
                Color = Color3.fromRGB(100, 100, 100),
                Thickness = 1,
                Transparency = 0.5,
                Parent = colorPreviewBig
            })
            
            -- Create Apply button
            local applyButton = Create("TextButton", {
                Name = "ApplyButton",
                BackgroundColor3 = CurrentTheme.Accent,
                Position = UDim2.new(0.5, 0, 0, 190),
                AnchorPoint = Vector2.new(0.5, 0),
                Size = UDim2.new(0, 80, 0, 25),
                Font = DEFAULT_FONT,
                Text = "Apply",
                TextColor3 = CurrentTheme.TextPrimary,
                TextSize = 14,
                ZIndex = 101,
                Parent = colorPickerGui
            })
            
            -- Register for theme updates (NEW)
            TBD:RegisterThemeable(applyButton, {
                BackgroundColor3 = "Accent",
                TextColor3 = "TextPrimary"
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = applyButton
            })
            
            -- Function to update color when sliders change
            local function updateFromSliders()
                local r = tonumber(rSlider.Value.Text) / 255
                local g = tonumber(gSlider.Value.Text) / 255
                local b = tonumber(bSlider.Value.Text) / 255
                
                local color = Color3.new(r, g, b)
                colorPreviewBig.BackgroundColor3 = color
                
                return color
            end
            
            -- Update color preview when sliders change
            local isUpdating = false
            
            UserInputService.InputChanged:Connect(function()
                if not colorPickerGui or not colorPickerGui.Parent then return end
                if isUpdating then return end
                
                -- Check if any slider is being dragged
                if rSlider.IsDragging() or gSlider.IsDragging() or bSlider.IsDragging() then
                    isUpdating = true
                    local color = updateFromSliders()
                    colorPreviewBig.BackgroundColor3 = color
                    isUpdating = false
                end
            end)
            
            -- Apply button
            applyButton.MouseButton1Click:Connect(function()
                local color = updateFromSliders()
                updateColor(color)
                closeColorPicker()
            end)
            
            -- Close when clicking outside
            local function closeOnOutsideClick(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if colorPickerGui and isOpen then
                        local mousePos = UserInputService:GetMouseLocation() - Vector2.new(0, 36)
                        local guiPos = colorPickerGui.AbsolutePosition
                        local guiSize = colorPickerGui.AbsoluteSize
                        
                        -- Check if click is outside the picker
                        if mousePos.X < guiPos.X or 
                           mousePos.X > guiPos.X + guiSize.X or 
                           mousePos.Y < guiPos.Y or 
                           mousePos.Y > guiPos.Y + guiSize.Y then
                            
                            -- Also check if it's not on the color preview
                            local previewPos = colorPreview.AbsolutePosition
                            local previewSize = colorPreview.AbsoluteSize
                            
                            if mousePos.X < previewPos.X or
                               mousePos.X > previewPos.X + previewSize.X or
                               mousePos.Y < previewPos.Y or
                               mousePos.Y > previewPos.Y + previewSize.Y then
                                closeColorPicker()
                                maid:Remove("pickerConnection")
                            end
                        end
                    end
                end
            end
            
            -- Create a simple maid for cleanup
            local maid = {
                _tasks = {}
            }
            
            function maid:Add(key, task)
                if self._tasks[key] then
                    self:Remove(key)
                end
                self._tasks[key] = task
                return task
            end
            
            function maid:Remove(key)
                if self._tasks[key] then
                    local connection = self._tasks[key]
                    if typeof(connection) == "RBXScriptConnection" then
                        connection:Disconnect()
                    elseif typeof(connection) == "function" then
                        connection()
                    end
                    self._tasks[key] = nil
                end
            end
            
            function maid:Destroy()
                for key, _ in pairs(self._tasks) do
                    self:Remove(key)
                end
                self._tasks = {}
            end
            
            maid:Add("pickerConnection", UserInputService.InputBegan:Connect(closeOnOutsideClick))
            
            -- Make picker destroy itself when color picker is destroyed
            if colorPicker and colorPicker.AncestryChanged then
                maid:Add("ancestryChanged", colorPicker.AncestryChanged:Connect(function(_, parent)
                    if not parent then
                        closeColorPicker()
                        maid:Destroy()
                    end
                end))
            end
        end
        
        -- Open color picker on button click
        colorPickerButton.MouseButton1Click:Connect(function()
            openColorPicker()
        end)
        
        -- Hover effects
        colorPickerButton.MouseEnter:Connect(function()
            Tween(colorPicker, {BackgroundTransparency = 0.2}, 0.2)
            Tween(previewStroke, {Transparency = 0.2}, 0.2)
        end)
        
        colorPickerButton.MouseLeave:Connect(function()
            Tween(colorPicker, {BackgroundTransparency = 0.4}, 0.2)
            Tween(previewStroke, {Transparency = 0.5}, 0.2)
        end)
        
        -- Create color picker object for external control
        local colorPickerObject = {
            Color = currentColor,
            
            Set = function(self, color)
                updateColor(color)
            end,
            
            GetColor = function(self)
                return currentColor
            end
        }
        
        -- Initialize flag if provided
        if flag then
            TBD.Flags[flag] = currentColor
        end
        
        return colorPickerObject
    end
    -- CREATE KEYBIND METHOD
    tab.CreateKeybind = function(_, options)
        options = options or {}
        local name = options.Name or "Keybind"
        local description = options.Description
        local defaultKeybind = options.CurrentKeybind or "None"
        local callback = options.Callback or function() end
        local flag = options.Flag
        
        local keybindHeight = description and 60 or 46
        
        local keybind = Create("Frame", {
            Name = "Keybind_" .. name,
            BackgroundColor3 = CurrentTheme.Secondary,
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 0, 0, keybindHeight),
            Parent = tab.Content
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(keybind, {BackgroundColor3 = "Secondary"})
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = keybind
        })
        
        local keybindTitle = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 8),
            Size = UDim2.new(1, -110, 0, 18),
            Font = SECONDARY_FONT,
            Text = name,
            TextColor3 = CurrentTheme.TextPrimary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = keybind
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(keybindTitle, {TextColor3 = "TextPrimary"})
        
        if description then
            local descriptionLabel = Create("TextLabel", {
                Name = "Description",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 26),
                Size = UDim2.new(1, -110, 0, 16),
                Font = SECONDARY_FONT,
                Text = description,
                TextColor3 = CurrentTheme.TextSecondary,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = keybind
            })
            
            -- Register for theme updates (NEW)
            TBD:RegisterThemeable(descriptionLabel, {TextColor3 = "TextSecondary"})
        end
        
        -- Create the keybind display
        local keybindDisplay = Create("Frame", {
            Name = "KeybindDisplay",
            BackgroundColor3 = CurrentTheme.Background,
            BackgroundTransparency = 0.6,
            Position = UDim2.new(1, -100, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.new(0, 90, 0, 28),
            Parent = keybind
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(keybindDisplay, {BackgroundColor3 = "Background"})
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = keybindDisplay
        })
        
        local keybindText = Create("TextLabel", {
            Name = "Text",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = SECONDARY_FONT,
            Text = defaultKeybind,
            TextColor3 = CurrentTheme.TextSecondary,
            TextSize = 14,
            Parent = keybindDisplay
        })
        
        -- Register for theme updates (NEW)
        TBD:RegisterThemeable(keybindText, {TextColor3 = "TextSecondary"})
        
        -- Create clickable button
        local keybindButton = Create("TextButton", {
            Name = "Button",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            Parent = keybindDisplay
        })
        
        -- Keybind functionality
        local currentKeybind = defaultKeybind
        local listeningForKey = false
        
        local function updateKeybindDisplay()
            keybindText.Text = currentKeybind
        end
        
        keybindButton.MouseButton1Click:Connect(function()
            listeningForKey = true
            keybindText.Text = "..."
            
            -- Highlight the button
            Tween(keybindDisplay, {BackgroundColor3 = CurrentTheme.Accent, BackgroundTransparency = 0.4}, 0.2)
        end)
        
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if listeningForKey then
                -- Get the key name
                local keyName = "None"
                
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    keyName = string.sub(tostring(input.KeyCode), 14)
                    listeningForKey = false
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                    keyName = "MB1"
                    listeningForKey = false
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                    keyName = "MB2"
                    listeningForKey = false
                elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                    keyName = "MB3"
                    listeningForKey = false
                end
                
                -- Update the keybind
                if not listeningForKey then
                    currentKeybind = keyName
                    updateKeybindDisplay()
                    
                    -- Call the callback
                    callback(currentKeybind)
                    
                    -- Update flag if provided
                    if flag then
                        TBD.Flags[flag] = currentKeybind
                    end
                    
                    -- Reset the button
                    Tween(keybindDisplay, {BackgroundColor3 = CurrentTheme.Background, BackgroundTransparency = 0.6}, 0.2)
                end
            elseif not gameProcessed and not listeningForKey and currentKeybind ~= "None" then
                -- Check if the key is pressed when not listening
                local keyName = "None"
                
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    keyName = string.sub(tostring(input.KeyCode), 14)
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                    keyName = "MB1"
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                    keyName = "MB2"
                elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                    keyName = "MB3"
                end
                
                -- If the key matches, call the callback
                if keyName == currentKeybind then
                    callback(currentKeybind)
                end
            end
        end)
        
        -- Hover effects
        keybindButton.MouseEnter:Connect(function()
            Tween(keybind, {BackgroundTransparency = 0.2}, 0.2)
            Tween(keybindDisplay, {BackgroundTransparency = 0.4}, 0.2)
        end)
        
        keybindButton.MouseLeave:Connect(function()
            Tween(keybind, {BackgroundTransparency = 0.4}, 0.2)
            if not listeningForKey then
                Tween(keybindDisplay, {BackgroundTransparency = 0.6}, 0.2)
            end
        end)
        
        -- Create keybind object for external control
        local keybindObject = {
            Keybind = currentKeybind,
            
            Set = function(self, newKeybind)
                currentKeybind = newKeybind
                updateKeybindDisplay()
                
                -- Call the callback
                callback(currentKeybind)
                
                -- Update flag if provided
                if flag then
                    TBD.Flags[flag] = currentKeybind
                end
            end
        }
        
        -- Initialize flag if provided
        if flag then
            TBD.Flags[flag] = currentKeybind
        end
        
        return keybindObject
    end
    
    -- Tab button behavior with enhanced hover effects
    tabButton.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            -- Background fade and slight grow effect
            Tween(tabButtonContainer, {
                BackgroundTransparency = 0.2,
                Size = UDim2.new(1, 4, 0, 42) -- Slightly larger
            }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            -- Adjust position to keep centered during size change
            Tween(tabButtonContainer, {
                Position = UDim2.new(0, -2, 0, -1)
            }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            if icon then
                -- Icon glow and color change
                Tween(icon, {
                    ImageColor3 = CurrentTheme.TextPrimary,
                    Size = UDim2.new(0, 22, 0, 22) -- Slightly larger
                }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            end
            
            -- Text brightness effect
            Tween(title, {
                TextColor3 = CurrentTheme.TextPrimary,
                TextSize = 15 -- Slightly larger text
            }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            -- Restore original size and transparency
            Tween(tabButtonContainer, {
                BackgroundTransparency = 0.4,
                Size = UDim2.new(1, 0, 0, 40),
                Position = UDim2.new(0, 0, 0, 0)
            }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            if icon then
                -- Restore icon
                Tween(icon, {
                    ImageColor3 = CurrentTheme.TextSecondary,
                    Size = UDim2.new(0, 20, 0, 20)
                }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            end
            
            -- Restore text
            Tween(title, {
                TextColor3 = CurrentTheme.TextSecondary,
                TextSize = 14
            }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end
    end)
    
    tabButton.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    -- Update tab scroll canvas size
    self:UpdateCanvasSize()
    
    -- Store the tab in our list
    table.insert(self.Tabs, tab)
    
    return tab
end

-- Function to select a tab
function TabSystem:SelectTab(tab)
    local activeTab = self.ActiveTab
    
    if activeTab == tab then return end
    
    -- Deselect current active tab
    if activeTab then
        -- Use ButtonContainer for background tweening instead of Button
        Tween(activeTab.ButtonContainer, {BackgroundColor3 = CurrentTheme.Primary, BackgroundTransparency = 0.4}, 0.2)
        if activeTab.Icon then
            Tween(activeTab.Icon, {ImageColor3 = CurrentTheme.TextSecondary}, 0.2)
        end
        Tween(activeTab.Title, {TextColor3 = CurrentTheme.TextSecondary}, 0.2)
        activeTab.Content.Visible = false
    end
    
    -- Select the new tab
    self.ActiveTab = tab
    
    -- Use ButtonContainer for background tweening instead of Button
    Tween(tab.ButtonContainer, {BackgroundColor3 = CurrentTheme.Accent, BackgroundTransparency = 0.2}, 0.2)
    if tab.Icon then
        Tween(tab.Icon, {ImageColor3 = CurrentTheme.TextPrimary}, 0.2)
    end
    Tween(tab.Title, {TextColor3 = CurrentTheme.TextPrimary}, 0.2)
    tab.Content.Visible = true
end

-- Function to select first tab
function TabSystem:SelectFirstTab()
    if #self.Tabs > 0 then
        self:SelectTab(self.Tabs[1])
    end
end

-- Class for creating a window
local Window = {}
Window.__index = Window

function TBD:CreateWindow(options)
    options = options or {}
    
    local title = options.Title or "TBD UI Library"
    local subtitle = options.Subtitle or "v" .. TBD.Version
    local width = IS_MOBILE and WINDOW_WIDTH * 0.8 or WINDOW_WIDTH
    local height = IS_MOBILE and WINDOW_HEIGHT * 0.8 or WINDOW_HEIGHT
    
    if options.Size then
        width = options.Size[1]
        height = options.Size[2]
    end
    
    local position = options.Position or "Center"
    local theme = options.Theme or "HoHo"
    local logoId = options.LogoId
    local loadingEnabled = options.LoadingEnabled or false
    local showHomePage = options.ShowHomePage or false
    
    -- Set the theme
    if Themes[theme] then
        CurrentTheme = Themes[theme]
    end
    
    -- Create instance
    local self = setmetatable({
        Title = title,
        Subtitle = subtitle,
        Width = width,
        Height = height,
        Position = position,
        Theme = theme,
        LogoId = logoId,
        LoadingEnabled = loadingEnabled,
        Tabs = {},
        Options = options,
        ShowHomePage = showHomePage,
        Minimized = false
    }, Window)
    
    -- Create the main window
    local screenGui = Create("ScreenGui", {
        Name = LIBRARY_NAME .. "_Window",
        DisplayOrder = 100,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
    
    -- Try to parent to CoreGui
    local success, result = pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(screenGui)
            screenGui.Parent = CoreGui
        else
            screenGui.Parent = CoreGui
        end
        return true
    end)
    
    if not success then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Create main frame
    local mainFrame = Create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = CurrentTheme.Background,
        Size = UDim2.new(0, width, 0, height),
        Position = (position == "Center") and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0, position[1], 0, position[2]),
        AnchorPoint = (position == "Center") and Vector2.new(0.5, 0.5) or Vector2.new(0, 0),
        ClipsDescendants = true,
        Parent = screenGui
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(mainFrame, {BackgroundColor3 = "Background"})
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = mainFrame
    })
    
    local mainStroke = Create("UIStroke", {
        Color = CurrentTheme.Accent,
        Thickness = 1.5,
        Transparency = 0.5,
        Parent = mainFrame
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(mainStroke, {Color = "Accent"})
    
    -- Add a shadow
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, 30, 1, 30),
        ZIndex = -1,
        Image = "rbxassetid://6014054326",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.4,
        Parent = mainFrame
    })
    
    -- Create the window header
    local header = Create("Frame", {
        Name = "Header",
        BackgroundColor3 = CurrentTheme.Accent,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(1, 0, 0, 40),
        BorderSizePixel = 0,
        Parent = mainFrame
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(header, {BackgroundColor3 = "Accent"})
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = header
    })
    
    -- Only round the top corners
    local headerCornerFix = Create("Frame", {
        Name = "CornerFix",
        BackgroundColor3 = CurrentTheme.Accent,
        BackgroundTransparency = 0.2,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0),
        BorderSizePixel = 0,
        ZIndex = 0,
        Parent = header
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(headerCornerFix, {BackgroundColor3 = "Accent"})
    
    -- Create title and subtitle
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = DEFAULT_FONT,
        Text = title,
        TextColor3 = CurrentTheme.TextPrimary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(titleLabel, {TextColor3 = "TextPrimary"})
    
    local subtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 220, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        Font = SECONDARY_FONT,
        Text = subtitle or "",
        TextColor3 = CurrentTheme.TextSecondary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(subtitleLabel, {TextColor3 = "TextSecondary"})
    
    -- Create window controls (minimize, close)
    local closeButton = Create("ImageButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 16, 0, 16),
        Image = Icons.Close,
        ImageColor3 = CurrentTheme.TextSecondary,
        Parent = header
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(closeButton, {ImageColor3 = "TextSecondary"})
    
    local minimizeButton = Create("ImageButton", {
        Name = "MinimizeButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -60, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 16, 0, 16),
        Image = Icons.Minimize,
        ImageColor3 = CurrentTheme.TextSecondary,
        Parent = header
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(minimizeButton, {ImageColor3 = "TextSecondary"})
    
    -- Button hover effects
    local function setupButtonHover(button)
        button.MouseEnter:Connect(function()
            Tween(button, {ImageColor3 = CurrentTheme.TextPrimary}, 0.2)
        end)
        
        button.MouseLeave:Connect(function()
            Tween(button, {ImageColor3 = CurrentTheme.TextSecondary}, 0.2)
        end)
    end
    
    setupButtonHover(closeButton)
    setupButtonHover(minimizeButton)
    
    -- Make the window draggable using the header
    MakeDraggable(mainFrame, header)
    
    -- Create the tab system
    local tabSystem = TabSystem:Create()
    tabSystem.Container.Parent = mainFrame
    tabSystem.ContentContainer.Parent = mainFrame
    tabSystem.Separator.Parent = mainFrame
    
    -- Create a container for the minimized state
    local minimizedContainer = Create("Frame", {
        Name = "MinimizedContainer",
        BackgroundColor3 = CurrentTheme.Background,
        Size = UDim2.new(0, 250, 0, 40),
        Position = mainFrame.Position,
        AnchorPoint = mainFrame.AnchorPoint,
        Visible = false,
        Parent = screenGui
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(minimizedContainer, {BackgroundColor3 = "Background"})
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = minimizedContainer
    })
    
    local minimizedStroke = Create("UIStroke", {
        Color = CurrentTheme.Accent,
        Thickness = 1.5,
        Transparency = 0.5,
        Parent = minimizedContainer
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(minimizedStroke, {Color = "Accent"})
    
    local minimizedHeader = Create("Frame", {
        Name = "Header",
        BackgroundColor3 = CurrentTheme.Accent,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        Parent = minimizedContainer
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(minimizedHeader, {BackgroundColor3 = "Accent"})
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = minimizedHeader
    })
    
    local minimizedTitle = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Font = DEFAULT_FONT,
        Text = title,
        TextColor3 = CurrentTheme.TextPrimary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = minimizedHeader
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(minimizedTitle, {TextColor3 = "TextPrimary"})
    
    local expandButton = Create("ImageButton", {
        Name = "ExpandButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 16, 0, 16),
        Image = Icons.Maximize,
        ImageColor3 = CurrentTheme.TextSecondary,
        Parent = minimizedHeader
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(expandButton, {ImageColor3 = "TextSecondary"})
    
    setupButtonHover(expandButton)
    MakeDraggable(minimizedContainer, minimizedHeader)
    
    -- Button event handlers
    closeButton.MouseButton1Click:Connect(function()
        Tween(mainFrame, {Size = UDim2.new(0, width, 0, 0)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        task.delay(0.3, function()
            screenGui:Destroy()
        end)
    end)
    
    minimizeButton.MouseButton1Click:Connect(function()
        self:Minimize()
    end)
    
    expandButton.MouseButton1Click:Connect(function()
        self:Expand()
    end)
    
    -- Store references
    self.ScreenGui = screenGui
    self.MainFrame = mainFrame
    self.Header = header
    self.TabSystem = tabSystem
    self.MinimizedContainer = minimizedContainer
    
    -- Start loading screen if enabled
    if loadingEnabled then
        local loadingOptions = {
            Title = options.LoadingTitle or title,
            Subtitle = options.LoadingSubtitle or "Loading...",
            LogoId = logoId,
            AnimationStyle = options.LoadingScreenCustomization and options.LoadingScreenCustomization.AnimationStyle,
            LogoSize = options.LoadingScreenCustomization and options.LoadingScreenCustomization.LogoSize,
            LogoPosition = options.LoadingScreenCustomization and options.LoadingScreenCustomization.LogoPosition,
            ProgressBarSize = options.LoadingScreenCustomization and options.LoadingScreenCustomization.ProgressBarSize
        }
        
        -- Hide main window until loading is done
        mainFrame.Visible = false
        
        -- Create and show loading screen
        local loadingScreen = TBD.LoadingScreen:Create(loadingOptions)
        
        -- Simulate loading progress
        local totalSteps = 10
        for i = 1, totalSteps do
            loadingScreen:UpdateProgress(i / totalSteps)
            task.wait(0.1)
        end
        
        -- Finish loading and show the main window
        loadingScreen:Finish(function()
            mainFrame.Visible = true
        end)
    end
    
    -- Create a home page if requested
    if showHomePage then
        self:CreateHomePage()
    end
    
    -- Store window for reference
    table.insert(TBD.Windows, self)
    
    return self
end

function Window:CreateTab(options)
    options = options or {}
    local name = options.Name or "Tab"
    local icon = options.Icon
    
    -- Use the more robust GetIcon helper function
    if icon then
        icon = TBD:GetIcon(icon)
    end
    
    local tabInfo = {
        Name = name,
        Icon = icon,
        Elements = {}
    }
    
    -- Add the tab to the UI
    local tab = self.TabSystem:AddTab(tabInfo)
    
    -- Initialize by selecting the tab if it's the first one
    if #self.TabSystem.Tabs == 1 then
        self.TabSystem:SelectTab(tab)
    end
    
    return tab
end

-- Function to minimize the window
function Window:Minimize()
    if self.Minimized then return end
    self.Minimized = true
    
    self.MinimizedContainer.Position = self.MainFrame.Position
    self.MinimizedContainer.Visible = true
    
    -- Animate minimize
    Tween(self.MainFrame, {Size = UDim2.new(0, self.Width, 0, 0)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    task.delay(0.3, function()
        self.MainFrame.Visible = false
    end)
end

-- Function to expand the window
function Window:Expand()
    if not self.Minimized then return end
    self.Minimized = false
    
    self.MainFrame.Position = self.MinimizedContainer.Position
    self.MainFrame.Visible = true
    self.MainFrame.Size = UDim2.new(0, self.Width, 0, 0)
    
    -- Animate expand
    Tween(self.MainFrame, {Size = UDim2.new(0, self.Width, 0, self.Height)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    task.delay(0.3, function()
        self.MinimizedContainer.Visible = false
    end)
end

-- Function to destroy the window
function Window:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

-- Function to create home page with player info
function Window:CreateHomePage()
    local homeTab = {
        Name = "Home",
        Icon = TBD:GetIcon("Home"),
        Elements = {}
    }
    
    -- Add the tab to the UI
    homeTab = self.TabSystem:AddTab(homeTab)
    table.insert(self.TabSystem.Tabs, 1, homeTab) -- Insert at the beginning
    self.HomeTab = homeTab
    
    -- Container for the welcome message and player info with logo
    local welcomeContainer = Create("Frame", {
        Name = "WelcomeContainer",
        BackgroundColor3 = CurrentTheme.Secondary,
        BackgroundTransparency = 0.4,
        Size = UDim2.new(1, 0, 0, 120),
        Parent = homeTab.Content
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(welcomeContainer, {BackgroundColor3 = "Secondary"})
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = welcomeContainer
    })
    
    -- Welcome title
    local welcomeTitle = Create("TextLabel", {
        Name = "WelcomeTitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 15),
        Size = UDim2.new(1, -40, 0, 30),
        Font = DEFAULT_FONT,
        Text = "Welcome, " .. LocalPlayer.DisplayName,
        TextColor3 = CurrentTheme.TextPrimary,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = welcomeContainer
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(welcomeTitle, {TextColor3 = "TextPrimary"})
    
    -- Player info
    local playerInfo = Create("TextLabel", {
        Name = "PlayerInfo",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 50),
        Size = UDim2.new(0.6, 0, 0, 20),
        Font = SECONDARY_FONT,
        Text = "Username: @" .. LocalPlayer.Name,
        TextColor3 = CurrentTheme.TextSecondary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = welcomeContainer
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(playerInfo, {TextColor3 = "TextSecondary"})
    
    local playerID = Create("TextLabel", {
        Name = "PlayerID",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 70),
        Size = UDim2.new(0.6, 0, 0, 20),
        Font = SECONDARY_FONT,
        Text = "User ID: " .. LocalPlayer.UserId,
        TextColor3 = CurrentTheme.TextSecondary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = welcomeContainer
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(playerID, {TextColor3 = "TextSecondary"})
    
    -- Add player avatar
    local avatarContainer = Create("Frame", {
        Name = "AvatarContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -90, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 70, 0, 70),
        Parent = welcomeContainer
    })
    
    -- Try to get user thumbnail
    local success, avatarImage = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    
    local avatar = Create("ImageLabel", {
        Name = "Avatar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Image = success and avatarImage or "",
        Parent = avatarContainer
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = avatar
    })
    
    -- Game Info Container
    local gameContainer = Create("Frame", {
        Name = "GameContainer",
        BackgroundColor3 = CurrentTheme.Secondary,
        BackgroundTransparency = 0.4,
        Size = UDim2.new(1, 0, 0, 100),
        Parent = homeTab.Content
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(gameContainer, {BackgroundColor3 = "Secondary"})
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = gameContainer
    })
    
    -- Try to get game name
    local gameName = "Unknown Game"
    local success, result = pcall(function()
        if MarketplaceService then
            local info = MarketplaceService:GetProductInfo(game.PlaceId)
            return info.Name
        end
        return "Unknown Game"
    end)
    if success then
        gameName = result
    end
    
    -- Game title
    local gameTitle = Create("TextLabel", {
        Name = "GameTitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 15),
        Size = UDim2.new(1, -40, 0, 25),
        Font = DEFAULT_FONT,
        Text = "Game: " .. gameName,
        TextColor3 = CurrentTheme.TextPrimary,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = gameContainer
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(gameTitle, {TextColor3 = "TextPrimary"})
    
    -- Game details
    local gamePlaceID = Create("TextLabel", {
        Name = "GamePlaceID",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 45),
        Size = UDim2.new(1, -40, 0, 20),
        Font = SECONDARY_FONT,
        Text = "Place ID: " .. game.PlaceId,
        TextColor3 = CurrentTheme.TextSecondary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = gameContainer
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(gamePlaceID, {TextColor3 = "TextSecondary"})
    
    local gamePlayerCount = Create("TextLabel", {
        Name = "GamePlayerCount",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 65),
        Size = UDim2.new(1, -40, 0, 20),
        Font = SECONDARY_FONT,
        Text = "Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers,
        TextColor3 = CurrentTheme.TextSecondary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = gameContainer
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(gamePlayerCount, {TextColor3 = "TextSecondary"})
    
    -- Credits
    local creditsContainer = Create("Frame", {
        Name = "CreditsContainer",
        BackgroundColor3 = CurrentTheme.Secondary,
        BackgroundTransparency = 0.4,
        Size = UDim2.new(1, 0, 0, 80),
        Parent = homeTab.Content
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(creditsContainer, {BackgroundColor3 = "Secondary"})
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = creditsContainer
    })
    
    local creditsTitle = Create("TextLabel", {
        Name = "CreditsTitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 15),
        Size = UDim2.new(1, -40, 0, 25),
        Font = DEFAULT_FONT,
        Text = "TBD UI Library",
        TextColor3 = CurrentTheme.TextPrimary,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = creditsContainer
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(creditsTitle, {TextColor3 = "TextPrimary"})
    
    local creditsVersion = Create("TextLabel", {
        Name = "CreditsVersion",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 40),
        Size = UDim2.new(1, -40, 0, 20),
        Font = SECONDARY_FONT,
        Text = "Version " .. TBD.Version .. " - HoHo Edition",
        TextColor3 = CurrentTheme.Accent,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = creditsContainer
    })
    
    -- Register for theme updates (NEW)
    TBD:RegisterThemeable(creditsVersion, {TextColor3 = "Accent"})
    
    -- Select the home tab
    self.TabSystem:SelectTab(homeTab)
    
    return homeTab
end

-- Function to create notification
function TBD:Notification(options)
    if not self.NotificationSystem.Container then
        self.NotificationSystem:Setup()
    end
    
    return self.NotificationSystem:CreateNotification(options)
end

-- Return the library
return TBD
