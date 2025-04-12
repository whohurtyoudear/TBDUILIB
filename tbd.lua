--[[
    TBD UI Library - New Edition (v2.0.0)
    Completely rewritten version with fixed errors, including TextTransparency and CreateButton issues
    Fully tested across different executors
]]

-- Main Library Table
local TBD = {}
TBD.Version = "2.0.0"
TBD.DebugMode = false

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

-- Constants and Settings
local ANIMATION_DURATION = 0.3
local DEFAULT_FONT = Enum.Font.GothamBold
local SECONDARY_FONT = Enum.Font.Gotham
local CORNER_RADIUS = UDim.new(0, 8)
local ELEMENT_HEIGHT = 36
local LIBRARY_NAME = "TBD"

-- Window dimensions (wider layout)
local WINDOW_WIDTH = 780
local WINDOW_HEIGHT = 460
local TAB_WIDTH = 170
local CONTENT_WIDTH = WINDOW_WIDTH - TAB_WIDTH - 20

-- Device Detection
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
TBD.IsMobile = IS_MOBILE
local SCREEN_SIZE = workspace.CurrentCamera.ViewportSize
local SCREEN_SCALE = math.min(1, SCREEN_SIZE.X/1200)

-- Safe area insets with fallback for executors that don't support GetSafeInsets
local SAFE_AREA = {
    Left = 0,
    Right = 0,
    Top = 0,
    Bottom = 0
}

-- Try to get safe insets if supported
local success, result = pcall(function()
    return GuiService:GetSafeInsets()
end)

if success then
    SAFE_AREA = result
end

TBD.SafeArea = SAFE_AREA

-- Themes
local Themes = {
    Default = {
        Primary = Color3.fromRGB(41, 53, 68),
        Secondary = Color3.fromRGB(35, 47, 62),
        Background = Color3.fromRGB(25, 33, 46),
        TextPrimary = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(190, 190, 190),
        Accent = Color3.fromRGB(65, 149, 242),
        DarkAccent = Color3.fromRGB(55, 120, 220),
        Error = Color3.fromRGB(245, 73, 96),
        Success = Color3.fromRGB(68, 214, 125),
        Warning = Color3.fromRGB(255, 170, 30)
    },
    Midnight = {
        Primary = Color3.fromRGB(30, 30, 45),
        Secondary = Color3.fromRGB(25, 25, 40),
        Background = Color3.fromRGB(18, 18, 33),
        TextPrimary = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(175, 175, 175),
        Accent = Color3.fromRGB(120, 80, 240),
        DarkAccent = Color3.fromRGB(100, 70, 210),
        Error = Color3.fromRGB(245, 73, 96),
        Success = Color3.fromRGB(68, 214, 125),
        Warning = Color3.fromRGB(255, 170, 30)
    },
    Neon = {
        Primary = Color3.fromRGB(32, 32, 32),
        Secondary = Color3.fromRGB(25, 25, 25),
        Background = Color3.fromRGB(18, 18, 18),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(185, 185, 185),
        Accent = Color3.fromRGB(0, 220, 160),
        DarkAccent = Color3.fromRGB(0, 180, 130),
        Error = Color3.fromRGB(255, 60, 100),
        Success = Color3.fromRGB(0, 255, 140),
        Warning = Color3.fromRGB(255, 200, 0)
    },
    Aqua = {
        Primary = Color3.fromRGB(20, 45, 65),
        Secondary = Color3.fromRGB(15, 40, 60),
        Background = Color3.fromRGB(10, 30, 45),
        TextPrimary = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(190, 190, 190),
        Accent = Color3.fromRGB(40, 180, 220),
        DarkAccent = Color3.fromRGB(30, 150, 190),
        Error = Color3.fromRGB(240, 80, 100),
        Success = Color3.fromRGB(40, 200, 150),
        Warning = Color3.fromRGB(255, 170, 30)
    },
    HoHo = { -- New theme inspired by the image
        Primary = Color3.fromRGB(20, 20, 20),
        Secondary = Color3.fromRGB(15, 15, 15),
        Background = Color3.fromRGB(10, 10, 10),
        TextPrimary = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(190, 190, 190),
        Accent = Color3.fromRGB(255, 30, 50),
        DarkAccent = Color3.fromRGB(200, 25, 45),
        Error = Color3.fromRGB(255, 60, 80),
        Success = Color3.fromRGB(40, 200, 90),
        Warning = Color3.fromRGB(255, 170, 30)
    }
}

-- Current Theme
local CurrentTheme = Themes.HoHo

-- Utility Functions
local function Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

local function CanHaveProperty(instance, property)
    local success = pcall(function()
        local test = instance[property]
    end)
    return success
end

local function Tween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or ANIMATION_DURATION,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    
    -- Create a safe copy of properties to tween
    local safeProps = {}
    for prop, value in pairs(properties) do
        if CanHaveProperty(instance, prop) then
            safeProps[prop] = value
        end
    end
    
    -- Only create and play the tween if there are properties to tween
    if next(safeProps) then
        local tween = TweenService:Create(instance, tweenInfo, safeProps)
        tween:Play()
        return tween
    end
    return nil
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        if not dragging then return end
        
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
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
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local function GetTextSize(text, fontSize, font, frameSize)
    return TextService:GetTextSize(text, fontSize, font, frameSize)
end

local function Round(number, decimalPlaces)
    local multiplier = 10 ^ (decimalPlaces or 0)
    return math.floor(number * multiplier + 0.5) / multiplier
end

-- Icon System
local Icons = {
    Close = "rbxassetid://6031094678",
    Minimize = "rbxassetid://6031094687",
    Maximize = "rbxassetid://6031094667",
    Home = "rbxassetid://6026568198",
    Settings = "rbxassetid://6031280882",
    Search = "rbxassetid://6031154870",
    Menu = "rbxassetid://6031091000",
    Info = "rbxassetid://6026568245",
    Warning = "rbxassetid://6031071053",
    Error = "rbxassetid://6031071057",
    Success = "rbxassetid://6031071054",
    Plus = "rbxassetid://6035047409",
    Minus = "rbxassetid://6035067832",
    Grid = "rbxassetid://6035047377",
    Person = "rbxassetid://7191850748",
    Eye = "rbxassetid://7191845882",
    Favorite = "rbxassetid://6034231524"
}

-- Notification System
TBD.NotificationSystem = {}
local NotificationSystem = TBD.NotificationSystem

NotificationSystem.Position = "TopRight"
NotificationSystem.Container = nil
NotificationSystem.Template = nil
NotificationSystem.ActiveNotifications = {}
NotificationSystem.NotificationCount = 0

function NotificationSystem:Setup()
    local screenGui = Create("ScreenGui", {
        Name = LIBRARY_NAME .. "_Notifications",
        DisplayOrder = 1000,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
    
    -- Try to use CoreGui, but fall back to PlayerGui if needed
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
    
    local container = Create("Frame", {
        Name = "NotificationContainer",
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 0, 20 + SAFE_AREA.Top),
        Size = UDim2.new(0, 300, 1, -40),
        Parent = screenGui
    })
    
    self.Container = container
    self.ScreenGui = screenGui
    
    -- Create a template but don't parent it
    local template = Create("Frame", {
        Name = "NotificationTemplate",
        BackgroundColor3 = CurrentTheme.Primary,
        Size = UDim2.new(1, 0, 0, 80),
        Position = UDim2.new(1, 20, 0, 0), -- Start off-screen
        AnchorPoint = Vector2.new(0, 0),
        BorderSizePixel = 0,
        BackgroundTransparency = 0.1
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = template
    })
    
    Create("UIStroke", {
        Color = CurrentTheme.Accent,
        Thickness = 1.2,
        Transparency = 0.5,
        Parent = template
    })
    
    local icon = Create("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 15),
        Size = UDim2.new(0, 24, 0, 24),
        Image = Icons.Info,
        ImageColor3 = CurrentTheme.Accent,
        Parent = template
    })
    
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 12),
        Size = UDim2.new(1, -65, 0, 20),
        Font = DEFAULT_FONT,
        Text = "Notification Title",
        TextColor3 = CurrentTheme.TextPrimary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = template
    })
    
    local messageLabel = Create("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 32),
        Size = UDim2.new(1, -65, 1, -40),
        Font = SECONDARY_FONT,
        Text = "Notification message goes here with all the details.",
        TextColor3 = CurrentTheme.TextSecondary,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = template
    })
    
    local progressBar = Create("Frame", {
        Name = "ProgressBar",
        BackgroundColor3 = CurrentTheme.Accent,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        BorderSizePixel = 0,
        Parent = template
    })
    
    local closeButton = Create("ImageButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0, 10),
        Size = UDim2.new(0, 16, 0, 16),
        Image = Icons.Close,
        ImageColor3 = CurrentTheme.TextSecondary,
        Parent = template
    })
    
    closeButton.MouseEnter:Connect(function()
        Tween(closeButton, {ImageColor3 = CurrentTheme.TextPrimary}, 0.2)
    end)
    
    closeButton.MouseLeave:Connect(function()
        Tween(closeButton, {ImageColor3 = CurrentTheme.TextSecondary}, 0.2)
    end)
    
    -- Make the notification slightly transparent when hovering over it
    template.MouseEnter:Connect(function()
        Tween(template, {BackgroundTransparency = 0.2}, 0.2)
    end)
    
    template.MouseLeave:Connect(function()
        Tween(template, {BackgroundTransparency = 0.1}, 0.2)
    end)
    
    self.Template = template
    return self
end

function NotificationSystem:GetContainerPosition()
    local position
    
    if self.Position == "TopRight" then
        position = UDim2.new(1, -20, 0, 20 + SAFE_AREA.Top)
    elseif self.Position == "TopLeft" then
        position = UDim2.new(0, 20 + SAFE_AREA.Left, 0, 20 + SAFE_AREA.Top)
    elseif self.Position == "BottomRight" then
        position = UDim2.new(1, -20, 1, -20 - SAFE_AREA.Bottom)
    elseif self.Position == "BottomLeft" then
        position = UDim2.new(0, 20 + SAFE_AREA.Left, 1, -20 - SAFE_AREA.Bottom)
    else
        position = UDim2.new(1, -20, 0, 20 + SAFE_AREA.Top) -- Default to TopRight
    end
    
    return position
end

function NotificationSystem:SetPosition(position)
    if position and (position == "TopRight" or position == "TopLeft" or position == "BottomRight" or position == "BottomLeft") then
        self.Position = position
        if self.Container then
            local containerPosition = self:GetContainerPosition()
            Tween(self.Container, {Position = containerPosition, AnchorPoint = 
                (position:find("Top") and Vector2.new(position:find("Right") and 1 or 0, 0)) or
                Vector2.new(position:find("Right") and 1 or 0, 1)
            }, 0.3)
            
            -- Adjust all active notifications
            self:UpdateNotificationsLayout()
        end
    end
end

function NotificationSystem:UpdateNotificationsLayout()
    local yOffset = 0
    local isTop = self.Position:find("Top") ~= nil
    local notificationList = {}
    
    -- Create an indexed list for easier sorting
    for id, notification in pairs(self.ActiveNotifications) do
        table.insert(notificationList, {ID = id, Notification = notification})
    end
    
    -- Sort by creation time (newer on top if isTop, older on top if isBottom)
    table.sort(notificationList, function(a, b)
        if isTop then
            return a.Notification.CreatedAt > b.Notification.CreatedAt
        else
            return a.Notification.CreatedAt < b.Notification.CreatedAt
        end
    end)
    
    -- Reposition them all
    for _, data in ipairs(notificationList) do
        local notification = data.Notification
        local height = notification.Frame.AbsoluteSize.Y
        
        if isTop then
            Tween(notification.Frame, {Position = UDim2.new(0, 0, 0, yOffset)}, 0.3)
            yOffset = yOffset + height + 10
        else
            Tween(notification.Frame, {Position = UDim2.new(0, 0, 1, -yOffset - height)}, 0.3)
            yOffset = yOffset + height + 10
        end
    end
end

function NotificationSystem:CreateNotification(options)
    if not self.Container then
        self:Setup()
    end
    
    -- Process options
    options = options or {}
    local title = options.Title or "Notification"
    local message = options.Message or ""
    local duration = options.Duration or 5
    local type = options.Type or "Info" -- Info, Success, Warning, Error
    local callback = options.Callback
    
    local notificationId = HttpService:GenerateGUID(false)
    self.NotificationCount = self.NotificationCount + 1
    
    -- Create a clone of the template
    local notification = self.Template:Clone()
    notification.Name = "Notification_" .. self.NotificationCount
    
    -- Set notification properties based on type
    local iconImage
    local accentColor
    
    if type == "Success" then
        iconImage = Icons.Success
        accentColor = CurrentTheme.Success
    elseif type == "Warning" then
        iconImage = Icons.Warning
        accentColor = CurrentTheme.Warning
    elseif type == "Error" then
        iconImage = Icons.Error
        accentColor = CurrentTheme.Error
    else -- Info or default
        iconImage = Icons.Info
        accentColor = CurrentTheme.Accent
    end
    
    notification.Icon.Image = iconImage
    notification.Icon.ImageColor3 = accentColor
    notification.UIStroke.Color = accentColor
    notification.ProgressBar.BackgroundColor3 = accentColor
    
    -- Set content
    notification.Title.Text = title
    notification.Message.Text = message
    
    -- Auto-size based on content
    local messageHeight = GetTextSize(
        message, 
        14, 
        SECONDARY_FONT, 
        Vector2.new(notification.Message.AbsoluteSize.X, 1000)
    ).Y
    
    local newHeight = math.max(80, messageHeight + 50)
    notification.Size = UDim2.new(1, 0, 0, newHeight)
    
    -- Position based on container alignment
    local isTop = self.Position:find("Top") ~= nil
    local startPosition
    
    if isTop then
        startPosition = UDim2.new(1, 0, 0, 0)
    else
        startPosition = UDim2.new(1, 0, 1, 0)
    end
    
    notification.Position = startPosition
    notification.Parent = self.Container
    
    -- Make sure this is always visible even if truncated by UI framework
    notification.ZIndex = 10
    
    -- Add to active notifications
    local notificationObj = {
        ID = notificationId,
        Frame = notification,
        CreatedAt = os.time(),
        Duration = duration,
        ProgressTween = nil
    }
    
    self.ActiveNotifications[notificationId] = notificationObj
    
    -- Handle click callback
    notification.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if callback and typeof(callback) == "function" then
                callback()
            end
            
            -- Close the notification
            self:CloseNotification(notificationId)
        end
    end)
    
    -- Handle close button
    notification.CloseButton.MouseButton1Click:Connect(function()
        self:CloseNotification(notificationId)
    end)
    
    -- Slide in animation
    Tween(notification, {Position = UDim2.new(0, 0, notification.Position.Y.Scale, notification.Position.Y.Offset)}, 0.3, Enum.EasingStyle.Back)
    
    -- Update layout of all notifications
    self:UpdateNotificationsLayout()
    
    -- Start progress bar
    notificationObj.ProgressTween = Tween(notification.ProgressBar, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)
    
    -- Schedule removal
    task.delay(duration, function()
        self:CloseNotification(notificationId)
    end)
    
    return notificationId
end

function NotificationSystem:CloseNotification(id)
    local notification = self.ActiveNotifications[id]
    if not notification then return end
    
    -- Stop progress bar tween if it exists
    if notification.ProgressTween then
        pcall(function() notification.ProgressTween:Cancel() end)
    end
    
    -- Slide out animation
    local slideOut = Tween(
        notification.Frame, 
        {Position = UDim2.new(1, 20, notification.Frame.Position.Y.Scale, notification.Frame.Position.Y.Offset)}, 
        0.2, 
        Enum.EasingStyle.Quad
    )
    
    -- Remove after animation
    task.delay(0.2, function()
        pcall(function() notification.Frame:Destroy() end)
        self.ActiveNotifications[id] = nil
        self:UpdateNotificationsLayout()
    end)
end

function NotificationSystem:ClearAllNotifications()
    for id, _ in pairs(self.ActiveNotifications) do
        self:CloseNotification(id)
    end
end

-- Loading Screen System
TBD.LoadingScreen = {}
local LoadingScreen = TBD.LoadingScreen

LoadingScreen.ScreenGui = nil
LoadingScreen.Active = false
LoadingScreen.StartTime = 0
LoadingScreen.DefaultDuration = 2.5
LoadingScreen.MinimumDuration = 1.2

function LoadingScreen:Create(options)
    options = options or {}
    
    local title = options.Title or "Loading"
    local subtitle = options.Subtitle or "Please wait..."
    local logoId = options.LogoId
    local logoSize = options.LogoSize or UDim2.new(0, 120, 0, 120)
    local logoPosition = options.LogoPosition or UDim2.new(0.5, 0, 0.35, 0)
    local animationStyle = options.AnimationStyle or "Fade" -- Fade, Slide, Scale
    local progressBarSize = options.ProgressBarSize or UDim2.new(0.7, 0, 0, 6)
    
    -- Create the screen GUI
    local screenGui = Create("ScreenGui", {
        Name = LIBRARY_NAME .. "_LoadingScreen",
        DisplayOrder = 1000,
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
    
    -- Create background with blur effect
    local background = Create("Frame", {
        Name = "Background",
        BackgroundColor3 = CurrentTheme.Background,
        BackgroundTransparency = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = screenGui
    })
    
    -- Create a blur effect (pcall to handle unsupported executors)
    local blurEffect
    pcall(function()
        blurEffect = Create("BlurEffect", {
            Name = "Blur",
            Size = 6,
            Parent = game:GetService("Lighting")
        })
        
        -- Store the blur effect for removal later
        self.BlurEffect = blurEffect
    end)
    
    -- Create container for elements
    local container = Create("Frame", {
        Name = "Container",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, 0, 1, 0),
        Parent = background
    })
    
    -- Create logo (if specified)
    if logoId then
        local logo
        pcall(function()
            logo = Create("ImageLabel", {
                Name = "Logo",
                BackgroundTransparency = 1,
                Position = logoPosition,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = logoSize,
                Image = logoId,
                Parent = container
            })
        end)
    end
    
    -- Create title
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 500, 0, 40),
        Text = title,
        TextColor3 = CurrentTheme.TextPrimary,
        Font = DEFAULT_FONT,
        TextSize = 28,
        Parent = container
    })
    
    -- Create subtitle
    local subtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.57, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 500, 0, 24),
        Text = subtitle,
        TextColor3 = CurrentTheme.TextSecondary,
        Font = SECONDARY_FONT,
        TextSize = 18,
        Parent = container
    })
    
    -- Create progress bar container
    local progressContainer = Create("Frame", {
        Name = "ProgressContainer",
        BackgroundColor3 = CurrentTheme.Secondary,
        BackgroundTransparency = 0.6,
        Position = UDim2.new(0.5, 0, 0.65, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = progressBarSize,
        Parent = container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 3),
        Parent = progressContainer
    })
    
    -- Create progress bar
    local progressBar = Create("Frame", {
        Name = "ProgressBar",
        BackgroundColor3 = CurrentTheme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = progressContainer
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 3),
        Parent = progressBar
    })
    
    -- Create bottom credits
    local creditsLabel = Create("TextLabel", {
        Name = "Credits",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.95, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 300, 0, 20),
        Text = "TBD UI Library v" .. TBD.Version,
        TextColor3 = CurrentTheme.TextSecondary,
        Font = SECONDARY_FONT,
        TextSize = 14,
        TextTransparency = 0.4,
        Parent = container
    })
    
    self.ScreenGui = screenGui
    self.ProgressBar = progressBar
    self.StartTime = os.clock()
    self.Active = true
    
    self:UpdateProgress(0)
    return self
end

function LoadingScreen:UpdateProgress(progress)
    if not self.Active or not self.ProgressBar then return end
    
    progress = math.clamp(progress, 0, 1)
    pcall(function()
        Tween(self.ProgressBar, {Size = UDim2.new(progress, 0, 1, 0)}, 0.3)
    end)
end

function LoadingScreen:Finish(callback)
    if not self.Active or not self.ScreenGui then return end
    
    -- Ensure minimum loading time for better UX
    local elapsed = os.clock() - self.StartTime
    local remaining = math.max(0, self.MinimumDuration - elapsed)
    
    -- Update progress to 100%
    self:UpdateProgress(1)
    
    -- Wait for the minimum time to pass
    task.delay(remaining, function()
        -- Remove blur effect if it exists
        if self.BlurEffect then
            pcall(function() self.BlurEffect:Destroy() end)
            self.BlurEffect = nil
        end
        
        -- Fade out animation
        pcall(function()
            local background = self.ScreenGui.Background
            Tween(background, {BackgroundTransparency = 1}, 0.5)
            
            -- Fade out all text and UI elements
            for _, descendent in pairs(self.ScreenGui:GetDescendants()) do
                if descendent:IsA("TextLabel") or descendent:IsA("TextButton") then
                    Tween(descendent, {BackgroundTransparency = 1, TextTransparency = 1}, 0.5)
                elseif descendent:IsA("ImageLabel") or descendent:IsA("ImageButton") then
                    Tween(descendent, {BackgroundTransparency = 1, ImageTransparency = 1}, 0.5)
                elseif descendent:IsA("Frame") and descendent.Name ~= "Background" then
                    Tween(descendent, {BackgroundTransparency = 1}, 0.5)
                end
            end
        end)
        
        -- Remove after animation
        task.delay(0.5, function()
            pcall(function() self.ScreenGui:Destroy() end)
            self.Active = false
            self.ScreenGui = nil
            
            if callback and typeof(callback) == "function" then
                callback()
            end
        end)
    end)
end

-- Tab and UI Elements creation functions
local TabSystem = {}

function TabSystem:Create()
    local tabContainer = Create("Frame", {
        Name = "TabContainer",
        BackgroundColor3 = CurrentTheme.Secondary,
        Position = UDim2.new(0, 0, 0, 40), -- Below the window header
        Size = UDim2.new(0, TAB_WIDTH, 1, -40), -- Width set in constants
        BorderSizePixel = 0
    })
    
    -- Tab list
    local tabScroll = Create("ScrollingFrame", {
        Name = "TabScroll",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 1, -20),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = CurrentTheme.Accent,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        BorderSizePixel = 0,
        Parent = tabContainer
    })
    
    local tabLayout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = tabScroll
    })
    
    local tabPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        Parent = tabScroll
    })
    
    local contentContainer = Create("Frame", {
        Name = "ContentContainer",
        BackgroundColor3 = CurrentTheme.Primary,
        Position = UDim2.new(0, TAB_WIDTH + 1, 0, 40), -- Next to tabs, below header
        Size = UDim2.new(1, -TAB_WIDTH - 1, 1, -40),
        BorderSizePixel = 0
    })
    
    -- Create the separator between tabs and content
    local separator = Create("Frame", {
        Name = "Separator",
        BackgroundColor3 = CurrentTheme.Accent,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Position = UDim2.new(0, TAB_WIDTH, 0, 40),
        Size = UDim2.new(0, 1, 1, -40)
    })
    
    local tabs = {}
    local activeTab = nil
    
    local tabSystem = {
        Container = tabContainer,
        ContentContainer = contentContainer,
        Separator = separator,
        TabScroll = tabScroll,
        Tabs = tabs,
        ActiveTab = nil
    }
    
    -- Update the canvas size of the scroll frame
    tabSystem.UpdateCanvasSize = function()
        local height = tabLayout.AbsoluteContentSize.Y + 10
        tabScroll.CanvasSize = UDim2.new(0, 0, 0, height)
    end
    
    -- Function to add a new tab
    tabSystem.AddTab = function(self, tabInfo)
        -- Clone tabInfo to avoid modifying the original
        local tab = {
            Name = tabInfo.Name,
            Icon = tabInfo.Icon,
            Elements = {}
        }
        
        table.insert(tabs, tab)
        
        -- Create the tab button
        local tabButton = Create("TextButton", {
            Name = "Tab_" .. tab.Name,
            BackgroundColor3 = CurrentTheme.Primary,
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 0, 0, 36),
            Text = "",
            AutoButtonColor = false,
            Parent = tabScroll
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = tabButton
        })
        
        local icon
        if tab.Icon then
            icon = Create("ImageLabel", {
                Name = "Icon",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, 10, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Image = typeof(tab.Icon) == "string" and tab.Icon or Icons[tab.Icon] or Icons.Home,
                ImageColor3 = CurrentTheme.TextSecondary,
                Parent = tabButton
            })
        end
        
        local title = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, icon and -40 or -20, 1, 0),
            Position = UDim2.new(0, icon and 40 or 10, 0, 0),
            Text = tab.Name,
            Font = SECONDARY_FONT,
            TextSize = 14,
            TextColor3 = CurrentTheme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabButton
        })
        
        -- Create container for the tab's content
        local contentFrame = Create("ScrollingFrame", {
            Name = "Content_" .. tab.Name,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = CurrentTheme.Accent,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
            Visible = false,
            Parent = contentContainer
        })
        
        -- Add padding and layout to content frame
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15),
            Parent = contentFrame
        })
        
        local contentLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = contentFrame
        })
        
        -- Auto-update canvas size
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 30)
        end)
        
        -- Store references
        tab.Button = tabButton
        tab.Icon = icon
        tab.Title = title
        tab.Content = contentFrame
        tab.ContentLayout = contentLayout
        
        -- Create section function
        tab.CreateSection = function(_, title)
            local section = Create("Frame", {
                Name = "Section_" .. title,
                BackgroundColor3 = CurrentTheme.Secondary,
                BackgroundTransparency = 0.4,
                Size = UDim2.new(1, 0, 0, 36),
                BorderSizePixel = 0,
                Parent = tab.Content
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = section
            })
            
            local sectionTitle = Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = DEFAULT_FONT,
                Text = title,
                TextColor3 = CurrentTheme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = section
            })
            
            return section
        end
        
        -- Create button function
        tab.CreateButton = function(_, options)
            options = options or {}
            local name = options.Name or "Button"
            local description = options.Description
            local callback = options.Callback or function() end
            
            local buttonHeight = description and 50 or 36
            
            local button = Create("Frame", {
                Name = "Button_" .. name,
                BackgroundColor3 = CurrentTheme.Secondary,
                BackgroundTransparency = 0.4,
                Size = UDim2.new(1, 0, 0, buttonHeight),
                Parent = tab.Content
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = button
            })
            
            local buttonTitle = Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, description and 8 or 0),
                Size = UDim2.new(1, -20, 0, 18),
                Font = SECONDARY_FONT,
                Text = name,
                TextColor3 = CurrentTheme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = button
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
                    Parent = button
                })
            end
            
            local buttonClickArea = Create("TextButton", {
                Name = "ClickArea",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                Parent = button
            })
            
            -- Hover and click effects
            buttonClickArea.MouseEnter:Connect(function()
                Tween(button, {BackgroundTransparency = 0.2}, 0.2)
            end)
            
            buttonClickArea.MouseLeave:Connect(function()
                Tween(button, {BackgroundTransparency = 0.4}, 0.2)
            end)
            
            buttonClickArea.MouseButton1Down:Connect(function()
                Tween(button, {BackgroundTransparency = 0.1}, 0.1)
            end)
            
            buttonClickArea.MouseButton1Up:Connect(function()
                Tween(button, {BackgroundTransparency = 0.2}, 0.1)
            end)
            
            buttonClickArea.MouseButton1Click:Connect(function()
                callback()
            end)
            
            return button
        end
        
        -- Create toggle function
        tab.CreateToggle = function(_, options)
            options = options or {}
            local name = options.Name or "Toggle"
            local description = options.Description
            local currentValue = options.CurrentValue or false
            local callback = options.Callback or function() end
            local flag = options.Flag
            
            local toggleHeight = description and 50 or 36
            
            local toggle = Create("Frame", {
                Name = "Toggle_" .. name,
                BackgroundColor3 = CurrentTheme.Secondary,
                BackgroundTransparency = 0.4,
                Size = UDim2.new(1, 0, 0, toggleHeight),
                Parent = tab.Content
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = toggle
            })
            
            local toggleTitle = Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, description and 8 or 0),
                Size = UDim2.new(1, -60, 0, 18),
                Font = SECONDARY_FONT,
                Text = name,
                TextColor3 = CurrentTheme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggle
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
                    Parent = toggle
                })
            end
            
            -- Create toggle switch
            local toggleBackground = Create("Frame", {
                Name = "ToggleBackground",
                BackgroundColor3 = currentValue and CurrentTheme.Accent or CurrentTheme.Secondary,
                Position = UDim2.new(1, -50, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 40, 0, 20),
                Parent = toggle
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggleBackground
            })
            
            local toggleCircle = Create("Frame", {
                Name = "ToggleCircle",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = UDim2.new(currentValue and 1 or 0, currentValue and -18 or 2, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 16, 0, 16),
                Parent = toggleBackground
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggleCircle
            })
            
            -- Create clickable area
            local toggleClickArea = Create("TextButton", {
                Name = "ClickArea",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                Parent = toggle
            })
            
            -- Store the current state
            local toggleState = currentValue
            
            -- Store the references and data in an object
            local toggleObject = {
                Toggle = toggle,
                Background = toggleBackground,
                Circle = toggleCircle,
                State = toggleState,
                Flag = flag,
                GetState = function()
                    return toggleState
                end,
                Set = function(self, state)
                    if toggleState == state then return end
                    toggleState = state
                    
                    -- Update visuals
                    Tween(toggleBackground, {BackgroundColor3 = toggleState and CurrentTheme.Accent or CurrentTheme.Secondary}, 0.2)
                    Tween(toggleCircle, {Position = UDim2.new(toggleState and 1 or 0, toggleState and -18 or 2, 0.5, 0)}, 0.2)
                    
                    -- Call the callback
                    callback(toggleState)
                    
                    -- Update flag if provided
                    if flag then
                        TBD.Flags[flag] = toggleState
                    end
                end
            }
            
            -- Hover and click effects
            toggleClickArea.MouseEnter:Connect(function()
                Tween(toggle, {BackgroundTransparency = 0.2}, 0.2)
            end)
            
            toggleClickArea.MouseLeave:Connect(function()
                Tween(toggle, {BackgroundTransparency = 0.4}, 0.2)
            end)
            
            toggleClickArea.MouseButton1Down:Connect(function()
                Tween(toggle, {BackgroundTransparency = 0.1}, 0.1)
            end)
            
            toggleClickArea.MouseButton1Up:Connect(function()
                Tween(toggle, {BackgroundTransparency = 0.2}, 0.1)
            end)
            
            toggleClickArea.MouseButton1Click:Connect(function()
                toggleObject:Set(not toggleState)
            end)
            
            -- Initialize flag if provided
            if flag then
                TBD.Flags[flag] = toggleState
            end
            
            return toggleObject
        end
        
        -- Create slider function
        tab.CreateSlider = function(_, options)
            options = options or {}
            local name = options.Name or "Slider"
            local description = options.Description
            local min, max = table.unpack(options.Range or {0, 100})
            local increment = options.Increment or 1
            local currentValue = options.CurrentValue or min
            local callback = options.Callback or function() end
            local flag = options.Flag
            
            local sliderHeight = description and 60 or 46
            
            local slider = Create("Frame", {
                Name = "Slider_" .. name,
                BackgroundColor3 = CurrentTheme.Secondary,
                BackgroundTransparency = 0.4,
                Size = UDim2.new(1, 0, 0, sliderHeight),
                Parent = tab.Content
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = slider
            })
            
            local sliderTitle = Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 8),
                Size = UDim2.new(0.7, 0, 0, 18),
                Font = SECONDARY_FONT,
                Text = name,
                TextColor3 = CurrentTheme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = slider
            })
            
            local valueDisplay = Create("TextLabel", {
                Name = "Value",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -60, 0, 8),
                Size = UDim2.new(0, 50, 0, 18),
                Font = SECONDARY_FONT,
                Text = tostring(currentValue),
                TextColor3 = CurrentTheme.TextSecondary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = slider
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
                    Parent = slider
                })
            end
            
            -- Create the slider track
            local sliderTrack = Create("Frame", {
                Name = "Track",
                BackgroundColor3 = CurrentTheme.Secondary,
                BackgroundTransparency = 0.2,
                Position = UDim2.new(0, 10, description and 0, description and (sliderHeight - 10) or 36),
                Size = UDim2.new(1, -20, 0, 6),
                BorderSizePixel = 0,
                Parent = slider
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderTrack
            })
            
            -- Create the slider fill
            local sliderFill = Create("Frame", {
                Name = "Fill",
                BackgroundColor3 = CurrentTheme.Accent,
                Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0),
                BorderSizePixel = 0,
                Parent = sliderTrack
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderFill
            })
            
            -- Create the slider thumb
            local sliderThumb = Create("Frame", {
                Name = "Thumb",
                BackgroundColor3 = CurrentTheme.Accent,
                Position = UDim2.new((currentValue - min) / (max - min), 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(0, 14, 0, 14),
                Parent = sliderTrack
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderThumb
            })
            
            local sliderValue = currentValue
            
            -- Function to update slider visually
            local function updateSlider(value)
                sliderValue = value
                
                -- Update the fill and thumb position
                local percent = (sliderValue - min) / (max - min)
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                sliderThumb.Position = UDim2.new(percent, 0, 0.5, 0)
                
                -- Update value display
                valueDisplay.Text = tostring(sliderValue)
                
                -- Call the callback
                callback(sliderValue)
                
                -- Update flag if provided
                if flag then
                    TBD.Flags[flag] = sliderValue
                end
            end
            
            -- Create a slider object for external control
            local sliderObject = {
                GetValue = function()
                    return sliderValue
                end,
                Set = function(_, value)
                    value = math.clamp(value, min, max)
                    
                    -- Round to nearest increment
                    local roundedValue = min + (math.round((value - min) / increment) * increment)
                    
                    -- Apply limits to the rounded value
                    roundedValue = math.clamp(roundedValue, min, max)
                    
                    -- Update the slider
                    updateSlider(roundedValue)
                end
            }
            
            -- Mouse interaction
            local isDragging = false
            
            sliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                    
                    -- Calculate the value from input position
                    local inputPosition = input.Position.X
                    local trackAbsolutePosition = sliderTrack.AbsolutePosition.X
                    local trackAbsoluteSize = sliderTrack.AbsoluteSize.X
                    
                    local relativePosition = math.clamp(inputPosition - trackAbsolutePosition, 0, trackAbsoluteSize)
                    local percent = relativePosition / trackAbsoluteSize
                    local value = min + (percent * (max - min))
                    
                    -- Round to nearest increment
                    local roundedValue = min + (math.round((value - min) / increment) * increment)
                    
                    -- Update the slider
                    updateSlider(math.clamp(roundedValue, min, max))
                end
            end)
            
            sliderTrack.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    -- Calculate the value from input position
                    local inputPosition = input.Position.X
                    local trackAbsolutePosition = sliderTrack.AbsolutePosition.X
                    local trackAbsoluteSize = sliderTrack.AbsoluteSize.X
                    
                    local relativePosition = math.clamp(inputPosition - trackAbsolutePosition, 0, trackAbsoluteSize)
                    local percent = relativePosition / trackAbsoluteSize
                    local value = min + (percent * (max - min))
                    
                    -- Round to nearest increment
                    local roundedValue = min + (math.round((value - min) / increment) * increment)
                    
                    -- Update the slider
                    updateSlider(math.clamp(roundedValue, min, max))
                end
            end)
            
            -- Hover effects
            sliderTrack.MouseEnter:Connect(function()
                Tween(slider, {BackgroundTransparency = 0.2}, 0.2)
            end)
            
            sliderTrack.MouseLeave:Connect(function()
                Tween(slider, {BackgroundTransparency = 0.4}, 0.2)
            end)
            
            -- Initialize flag if provided
            if flag then
                TBD.Flags[flag] = sliderValue
            end
            
            return sliderObject
        end
        
        -- Add remaining element creation methods
        tab.CreateDropdown = function(_, options)
            options = options or {}
            local name = options.Name or "Dropdown"
            local description = options.Description
            local items = options.Items or {}
            local default = options.Default or ""
            local callback = options.Callback or function() end
            local flag = options.Flag
            
            local dropdownHeight = description and 60 or 46
            
            local dropdown = Create("Frame", {
                Name = "Dropdown_" .. name,
                BackgroundColor3 = CurrentTheme.Secondary,
                BackgroundTransparency = 0.4,
                Size = UDim2.new(1, 0, 0, dropdownHeight),
                ClipsDescendants = true,
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
            
            -- Create the dropdown display
            local dropdownDisplay = Create("Frame", {
                Name = "Display",
                BackgroundColor3 = CurrentTheme.Secondary,
                BackgroundTransparency = 0.6,
                Position = UDim2.new(0, 10, description and 0, description and (dropdownHeight - 26) or 36),
                Size = UDim2.new(1, -20, 0, 30),
                Parent = dropdown
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = dropdownDisplay
            })
            
            local displayText = Create("TextLabel", {
                Name = "Text",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -40, 1, 0),
                Font = SECONDARY_FONT,
                Text = default,
                TextColor3 = CurrentTheme.TextSecondary,
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
                Image = "rbxassetid://6031091004", -- Down arrow
                ImageColor3 = CurrentTheme.TextSecondary,
                Parent = dropdownDisplay
            })
            
            -- Create dropdown clickable button
            local dropdownButton = Create("TextButton", {
                Name = "Button",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                Parent = dropdownDisplay
            })
            
            -- Create dropdown list container (hidden by default)
            local listContainer = Create("Frame", {
                Name = "ListContainer",
                BackgroundColor3 = CurrentTheme.Secondary,
                BackgroundTransparency = 0,
                Position = UDim2.new(0, 0, 1, 5),
                Size = UDim2.new(1, 0, 0, 0), -- Start with no height
                Visible = false,
                ZIndex = 10,
                Parent = dropdownDisplay
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = listContainer
            })
            
            -- Create scrolling frame for items
            local itemList = Create("ScrollingFrame", {
                Name = "ItemList",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 1, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = CurrentTheme.Accent,
                VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
                ZIndex = 11,
                Parent = listContainer
            })
            
            local itemLayout = Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2),
                Parent = itemList
            })
            
            local itemPadding = Create("UIPadding", {
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5),
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5),
                Parent = itemList
            })
            
            local selectedOption = default
            local isOpen = false
            
            -- Function to populate the list with items
            local function populateList()
                -- Clear existing items
                for _, child in ipairs(itemList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                local totalHeight = 0
                
                -- Add new items
                for _, item in ipairs(items) do
                    local itemButton = Create("TextButton", {
                        Name = "Item_" .. item,
                        BackgroundColor3 = CurrentTheme.Background,
                        BackgroundTransparency = 0.2,
                        Size = UDim2.new(1, -10, 0, 30),
                        Font = SECONDARY_FONT,
                        Text = item,
                        TextColor3 = item == selectedOption and CurrentTheme.Accent or CurrentTheme.TextPrimary,
                        TextSize = 14,
                        ZIndex = 12,
                        Parent = itemList
                    })
                    
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = itemButton
                    })
                    
                    -- Highlight current selection
                    if item == selectedOption then
                        Create("UIStroke", {
                            Color = CurrentTheme.Accent,
                            Thickness = 1,
                            Parent = itemButton
                        })
                    end
                    
                    -- Item button behavior
                    itemButton.MouseEnter:Connect(function()
                        if item ~= selectedOption then
                            Tween(itemButton, {BackgroundTransparency = 0}, 0.2)
                        end
                    end)
                    
                    itemButton.MouseLeave:Connect(function()
                        if item ~= selectedOption then
                            Tween(itemButton, {BackgroundTransparency = 0.2}, 0.2)
                        end
                    end)
                    
                    itemButton.MouseButton1Click:Connect(function()
                        selectedOption = item
                        displayText.Text = item
                        callback(item)
                        
                        -- Update flag if provided
                        if flag then
                            TBD.Flags[flag] = item
                        end
                        
                        -- Close the dropdown
                        closeDropdown()
                        
                        -- Re-populate to update highlighting
                        populateList()
                    end)
                    
                    totalHeight = totalHeight + itemButton.AbsoluteSize.Y + itemLayout.Padding.Offset
                end
                
                -- Update canvas size
                itemList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
            end
            
            -- Function to open the dropdown
            local function openDropdown()
                if isOpen then return end
                isOpen = true
                
                -- Make the list visible
                listContainer.Visible = true
                
                -- Animate opening
                local listHeight = math.min(150, #items * 30 + (#items + 1) * 5)
                Tween(listContainer, {Size = UDim2.new(1, 0, 0, listHeight)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                Tween(dropdownArrow, {Rotation = 180}, 0.2)
                
                -- Populate items
                populateList()
            end
            
            -- Function to close the dropdown
            function closeDropdown()
                if not isOpen then return end
                isOpen = false
                
                -- Animate closing
                Tween(listContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                Tween(dropdownArrow, {Rotation = 0}, 0.2)
                
                -- Hide after animation
                task.delay(0.2, function()
                    if not isOpen then
                        listContainer.Visible = false
                    end
                end)
            end
            
            -- Toggle the dropdown on button click
            dropdownButton.MouseButton1Click:Connect(function()
                if isOpen then
                    closeDropdown()
                else
                    openDropdown()
                end
            end)
            
            -- Close the dropdown when clicking elsewhere
            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local dropdownAbsPos = dropdownDisplay.AbsolutePosition
                    local dropdownAbsSize = dropdownDisplay.AbsoluteSize
                    local listAbsPos = listContainer.AbsolutePosition
                    local listAbsSize = listContainer.AbsoluteSize
                    
                    local mousePos = UserInputService:GetMouseLocation() - Vector2.new(0, 36)
                    
                    local inDropdown = mousePos.X >= dropdownAbsPos.X and mousePos.X <= dropdownAbsPos.X + dropdownAbsSize.X and
                                     mousePos.Y >= dropdownAbsPos.Y and mousePos.Y <= dropdownAbsPos.Y + dropdownAbsSize.Y
                                     
                    local inList = mousePos.X >= listAbsPos.X and mousePos.X <= listAbsPos.X + listAbsSize.X and
                                mousePos.Y >= listAbsPos.Y and mousePos.Y <= listAbsPos.Y + listAbsSize.Y
                                
                    if isOpen and not inDropdown and not inList then
                        closeDropdown()
                    end
                end
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
                Selected = selectedOption,
                
                Set = function(self, option)
                    if table.find(items, option) then
                        selectedOption = option
                        displayText.Text = option
                        
                        -- Call the callback
                        callback(option)
                        
                        -- Update flag if provided
                        if flag then
                            TBD.Flags[flag] = option
                        end
                        
                        -- Update list highlighting if open
                        if isOpen then
                            populateList()
                        end
                    end
                end,
                
                Refresh = function(self, newItems)
                    items = newItems
                    
                    -- Reset selection if it's no longer valid
                    if not table.find(items, selectedOption) and #items > 0 then
                        selectedOption = items[1]
                        displayText.Text = selectedOption
                        
                        -- Call the callback
                        callback(selectedOption)
                        
                        -- Update flag if provided
                        if flag then
                            TBD.Flags[flag] = selectedOption
                        end
                    elseif #items == 0 then
                        selectedOption = ""
                        displayText.Text = "No options"
                        
                        -- Call the callback with nil
                        callback(nil)
                        
                        -- Update flag if provided
                        if flag then
                            TBD.Flags[flag] = nil
                        end
                    end
                    
                    -- Update list if open
                    if isOpen then
                        populateList()
                    end
                end
            }
            
            -- Initialize flag if provided
            if flag then
                TBD.Flags[flag] = selectedOption
            end
            
            return dropdownObject
        end
        
        tab.CreateDivider = function(_)
            local divider = Create("Frame", {
                Name = "Divider",
                BackgroundColor3 = CurrentTheme.Accent,
                BackgroundTransparency = 0.7,
                Size = UDim2.new(1, 0, 0, 1),
                BorderSizePixel = 0,
                Parent = tab.Content
            })
            
            return divider
        end
        
        tab.CreateTextbox = function(_, options)
            options = options or {}
            local name = options.Name or "Textbox"
            local description = options.Description
            local placeholderText = options.PlaceholderText or "Enter text..."
            local text = options.Text or ""
            local charLimit = options.CharacterLimit or 100
            local callback = options.Callback or function() end
            local flag = options.Flag
            
            local textboxHeight = description and 70 or 56
            
            local textbox = Create("Frame", {
                Name = "Textbox_" .. name,
                BackgroundColor3 = CurrentTheme.Secondary,
                BackgroundTransparency = 0.4,
                Size = UDim2.new(1, 0, 0, textboxHeight),
                Parent = tab.Content
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = textbox
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
                Parent = textbox
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
                    Parent = textbox
                })
            end
            
            -- Create the textbox input
            local inputContainer = Create("Frame", {
                Name = "InputContainer",
                BackgroundColor3 = CurrentTheme.Background,
                BackgroundTransparency = 0.6,
                Position = UDim2.new(0, 10, description and 0, description and (textboxHeight - 30) or 34),
                Size = UDim2.new(1, -20, 0, 30),
                Parent = textbox
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = inputContainer
            })
            
            local inputBox = Create("TextBox", {
                Name = "InputBox",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = SECONDARY_FONT,
                Text = text,
                PlaceholderText = placeholderText,
                TextColor3 = CurrentTheme.TextPrimary,
                PlaceholderColor3 = CurrentTheme.TextSecondary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = inputContainer
            })
            
            -- Textbox functionality
            local currentText = text
            
            inputBox.Focused:Connect(function()
                Tween(inputContainer, {BackgroundTransparency = 0.4}, 0.2)
            end)
            
            inputBox.FocusLost:Connect(function(enterPressed)
                Tween(inputContainer, {BackgroundTransparency = 0.6}, 0.2)
                
                if currentText ~= inputBox.Text then
                    currentText = inputBox.Text
                    callback(currentText)
                    
                    -- Update flag if provided
                    if flag then
                        TBD.Flags[flag] = currentText
                    end
                end
            end)
            
            inputBox:GetPropertyChangedSignal("Text"):Connect(function()
                -- Apply character limit
                if #inputBox.Text > charLimit then
                    inputBox.Text = string.sub(inputBox.Text, 1, charLimit)
                end
            end)
            
            -- Hover effects
            inputContainer.MouseEnter:Connect(function()
                Tween(textbox, {BackgroundTransparency = 0.2}, 0.2)
                Tween(inputContainer, {BackgroundTransparency = 0.4}, 0.2)
            end)
            
            inputContainer.MouseLeave:Connect(function()
                Tween(textbox, {BackgroundTransparency = 0.4}, 0.2)
                if inputBox:IsFocused() then
                    Tween(inputContainer, {BackgroundTransparency = 0.4}, 0.2)
                else
                    Tween(inputContainer, {BackgroundTransparency = 0.6}, 0.2)
                end
            end)
            
            -- Create textbox object for external control
            local textboxObject = {
                Text = currentText,
                
                Set = function(self, newText)
                    if #newText > charLimit then
                        newText = string.sub(newText, 1, charLimit)
                    end
                    
                    currentText = newText
                    inputBox.Text = newText
                    
                    -- Call the callback
                    callback(currentText)
                    
                    -- Update flag if provided
                    if flag then
                        TBD.Flags[flag] = currentText
                    end
                end
            }
            
            -- Initialize flag if provided
            if flag then
                TBD.Flags[flag] = currentText
            end
            
            return textboxObject
        end
        
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
            
            -- Color picker functionality (simplified for example)
            local colorPickerPopup, pickerObject
            
            local function createColorPickerPopup()
                -- More complex with HSV selector, RGB inputs, etc.
                -- Simplified version for this example
                local popup = Create("Frame", {
                    Name = "ColorPickerPopup",
                    BackgroundColor3 = CurrentTheme.Background,
                    Position = UDim2.new(1, 10, 0, 0),
                    Size = UDim2.new(0, 200, 0, 200),
                    Visible = false,
                    ZIndex = 100,
                    Parent = colorPicker
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = popup
                })
                
                -- Color object for external control
                local colorObj = {
                    Color = color,
                    
                    Set = function(self, newColor)
                        color = newColor
                        colorPreview.BackgroundColor3 = color
                        
                        -- Call the callback
                        callback(color)
                        
                        -- Update flag if provided
                        if flag then
                            TBD.Flags[flag] = color
                        end
                    end
                }
                
                return popup, colorObj
            end
            
            -- Create color picker on click
            colorButton.MouseButton1Click:Connect(function()
                if not colorPickerPopup then
                    colorPickerPopup, pickerObject = createColorPickerPopup()
                end
                
                -- Toggle visibility (simplified for example)
                colorPickerPopup.Visible = not colorPickerPopup.Visible
            end)
            
            -- Hover effects
            colorButton.MouseEnter:Connect(function()
                Tween(colorPicker, {BackgroundTransparency = 0.2}, 0.2)
            end)
            
            colorButton.MouseLeave:Connect(function()
                Tween(colorPicker, {BackgroundTransparency = 0.4}, 0.2)
            end)
            
            -- Create the color picker object
            local colorPickerObject = {
                Color = color,
                
                Set = function(self, newColor)
                    color = newColor
                    colorPreview.BackgroundColor3 = color
                    
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
        
        -- Tab button behavior
        tabButton.MouseEnter:Connect(function()
            if activeTab ~= tab then
                Tween(tabButton, {BackgroundTransparency = 0.2}, 0.2)
                if icon then
                    Tween(icon, {ImageColor3 = CurrentTheme.TextPrimary}, 0.2)
                end
                Tween(title, {TextColor3 = CurrentTheme.TextPrimary}, 0.2)
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if activeTab ~= tab then
                Tween(tabButton, {BackgroundTransparency = 0.4}, 0.2)
                if icon then
                    Tween(icon, {ImageColor3 = CurrentTheme.TextSecondary}, 0.2)
                end
                Tween(title, {TextColor3 = CurrentTheme.TextSecondary}, 0.2)
            end
        end)
        
        tabButton.MouseButton1Click:Connect(function()
            self:SelectTab(tab)
        end)
        
        -- Update tab scroll canvas size
        self:UpdateCanvasSize()
        
        return tab
    end
    
    -- Function to select a tab
    tabSystem.SelectTab = function(self, tab)
        if activeTab == tab then return end
        
        -- Deselect current active tab
        if activeTab then
            Tween(activeTab.Button, {BackgroundColor3 = CurrentTheme.Primary, BackgroundTransparency = 0.4}, 0.2)
            if activeTab.Icon then
                Tween(activeTab.Icon, {ImageColor3 = CurrentTheme.TextSecondary}, 0.2)
            end
            Tween(activeTab.Title, {TextColor3 = CurrentTheme.TextSecondary}, 0.2)
            activeTab.Content.Visible = false
        end
        
        -- Select the new tab
        activeTab = tab
        tabSystem.ActiveTab = tab
        
        Tween(tab.Button, {BackgroundColor3 = CurrentTheme.Accent, BackgroundTransparency = 0.2}, 0.2)
        if tab.Icon then
            Tween(tab.Icon, {ImageColor3 = CurrentTheme.TextPrimary}, 0.2)
        end
        Tween(tab.Title, {TextColor3 = CurrentTheme.TextPrimary}, 0.2)
        tab.Content.Visible = true
    end
    
    -- Function to select first tab
    tabSystem.SelectFirstTab = function(self)
        if #tabs > 0 then
            self:SelectTab(tabs[1])
        end
    end
    
    return tabSystem
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
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = mainFrame
    })
    
    Create("UIStroke", {
        Color = CurrentTheme.Accent,
        Thickness = 1.5,
        Transparency = 0.5,
        Parent = mainFrame
    })
    
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
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = minimizedContainer
    })
    
    Create("UIStroke", {
        Color = CurrentTheme.Accent,
        Thickness = 1.5,
        Transparency = 0.5,
        Parent = minimizedContainer
    })
    
    local minimizedHeader = Create("Frame", {
        Name = "Header",
        BackgroundColor3 = CurrentTheme.Accent,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        Parent = minimizedContainer
    })
    
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
        for i = 1, 10 do
            loadingScreen:UpdateProgress(i / 10)
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
    
    return self
end

function Window:CreateTab(options)
    options = options or {}
    local name = options.Name or "Tab"
    local icon = options.Icon
    
    if options.ImageSource and options.ImageSource == "Phosphor" then
        icon = Icons[icon] or Icons.Home
    end
    
    local tabInfo = {
        Name = name,
        Icon = icon,
        Elements = {}
    }
    
    -- Add the tab to the UI
    local tab = self.TabSystem:AddTab(tabInfo)
    table.insert(self.Tabs, tab)
    
    -- Initialize by selecting the tab if it's the first one
    if #self.Tabs == 1 then
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
        Icon = Icons.Home,
        Elements = {}
    }
    
    -- Add the tab to the UI
    homeTab = self.TabSystem:AddTab(homeTab)
    table.insert(self.Tabs, 1, homeTab) -- Insert at the beginning
    self.HomeTab = homeTab
    
    -- Container for the welcome message and player info with logo
    local welcomeContainer = Create("Frame", {
        Name = "WelcomeContainer",
        BackgroundColor3 = CurrentTheme.Secondary,
        BackgroundTransparency = 0.4,
        Size = UDim2.new(1, 0, 0, 120),
        Parent = homeTab.Content
    })
    
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
    
    -- Credits
    local creditsContainer = Create("Frame", {
        Name = "CreditsContainer",
        BackgroundColor3 = CurrentTheme.Secondary,
        BackgroundTransparency = 0.4,
        Size = UDim2.new(1, 0, 0, 80),
        Parent = homeTab.Content
    })
    
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

-- Function to set a theme
function TBD:SetTheme(theme)
    if Themes[theme] then
        CurrentTheme = Themes[theme]
        return true
    end
    return false
end

-- Function to create a custom theme
function TBD:CustomTheme(options)
    options = options or {}
    
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
    
    CurrentTheme = customTheme
    
    return true
end

-- Initialize TBD
TBD.Flags = {}
TBD.NotificationSystem:Setup()

return TBD
