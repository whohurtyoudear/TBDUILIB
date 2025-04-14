--[[
    TBD UI Library
    
    A comprehensive Lua-based UI library for Roblox with an 80s retro aesthetic theme
    Created with cross-executor compatibility in mind
    
    Features:
    - Sleek 80s Retro Design with VHS aesthetics
    - Comprehensive UI Components
    - Smooth Animations and Transitions
    - Universal Compatibility with all Roblox executors/injectors
    - Easy Implementation with intuitive API
    - Fully Customizable theme and settings
    - Responsive Layout and automatic sizing
    
    Version: 1.0.0
]]

-- Services
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local ASSETS = {
    -- You can replace these with your own assets
    Logo = "rbxassetid://12646095864",
    Checkbox = "rbxassetid://3926309567",
    DropdownArrow = "rbxassetid://6031091004",
    Close = "rbxassetid://3926305904",
    Settings = "rbxassetid://3926307971",
    Search = "rbxassetid://3926305904",
    VHSOverlay = "rbxassetid://13916763326", -- VHS static overlay
}

-- Sound effects for UI interactions
local SOUNDS = {
    Click = "rbxassetid://6895079853",
    Toggle = "rbxassetid://6895079572",
    Hover = "rbxassetid://6895079603",
    Notification = "rbxassetid://6895079649",
    Open = "rbxassetid://6895079734",
    Close = "rbxassetid://6895079689",
}

-- Library table
local TBDLib = {
    Windows = {},
    Theme = {
        Background = Color3.fromRGB(15, 15, 15),      -- Dark background
        Accent = Color3.fromRGB(255, 0, 60),          -- Neon red accent
        SecondaryAccent = Color3.fromRGB(0, 170, 255),-- Neon blue secondary accent
        LightContrast = Color3.fromRGB(30, 30, 30),   -- Lighter background
        DarkContrast = Color3.fromRGB(20, 20, 20),    -- Darker background
        TextColor = Color3.fromRGB(255, 255, 255),    -- White text
        PlaceholderColor = Color3.fromRGB(155, 155, 155), -- Gray placeholder text
        VHSOpacity = 0.03,                            -- VHS overlay opacity
    },
    Flags = {},                        -- For storing toggle/setting values
    UISettings = {
        Sounds = true,                 -- Enable/disable sounds
        Animations = true,             -- Enable/disable animations
        VHSEffect = true,              -- Enable/disable VHS overlay effect
        ScanLines = true,              -- Enable/disable scan lines
        BlurEffect = true,             -- Enable/disable blur effect
        NotificationDuration = 3,      -- Default notification duration in seconds
        CornerRadius = UDim.new(0, 6), -- Default corner radius
    },
    ToggleKey = Enum.KeyCode.RightShift, -- Default key to toggle UI visibility
    NotifyQueue = {},                  -- Queue for notifications
    Version = "1.0.0"                  -- Current version
}

-- Utility Functions
local Utility = {}

-- Create instances with properties and children
function Utility:Create(instanceType, properties, children)
    local instance = Instance.new(instanceType)
    
    for property, value in pairs(properties or {}) do
        instance[property] = value
    end
    
    for _, child in ipairs(children or {}) do
        child.Parent = instance
    end
    
    return instance
end

-- Create a tween for animating properties
function Utility:Tween(instance, properties, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.2, 
        style or Enum.EasingStyle.Quad, 
        direction or Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    
    return tween
end

-- Create a ripple effect on button press
function Utility:Ripple(instance)
    if not TBDLib.UISettings.Animations then return end
    
    local ripple = Utility:Create("Frame", {
        Name = "Ripple",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0)
    })
    
    local corner = Utility:Create("UICorner", {
        CornerRadius = TBDLib.UISettings.CornerRadius,
        Parent = ripple
    })
    
    ripple.Parent = instance
    
    local size = math.max(instance.AbsoluteSize.X, instance.AbsoluteSize.Y) * 2
    local tween = Utility:Tween(ripple, {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1
    }, 0.5)
    
    tween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

-- Make an object draggable
function Utility:DragObject(object, dragInput, dragStart, startPos)
    if not TBDLib.UISettings.Animations then return end
    
    local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (dragInput.Position.X - dragStart.X), startPos.Y.Scale, startPos.Y.Offset + (dragInput.Position.Y - dragStart.Y))
    Utility:Tween(object, {Position = position}, 0.1)
end

-- Enable dragging for a frame
function Utility:EnableDragging(frame)
    local dragging, dragInput, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
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
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput) then
            Utility:DragObject(frame, input, dragStart, startPos)
        end
    end)
end

-- Get text size
function Utility:GetTextSize(text, font, size, bounds)
    return TextService:GetTextSize(text, size, font, bounds)
end

-- Play UI sound
function Utility:PlaySound(id)
    if not TBDLib.UISettings.Sounds then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. id
    sound.Volume = 0.5
    sound.Parent = CoreGui
    sound:Play()
    
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

-- Detect executor for compatibility
function Utility:GetExecutor()
    local executor =
        (syn and "Synapse X") or
        (KRNL_LOADED and "KRNL") or
        (secure_load and "Sentinel") or
        (SONA_LOADED and "Sona") or
        (isexecutorclosure and "Script-Ware") or
        (getexecutorname and getexecutorname()) or
        (Fluxus and "Fluxus") or
        (identifyexecutor and identifyexecutor()) or
        ("Unknown")
    
    return executor
end

-- Create scan lines effect
function Utility:CreateScanLines(parent, transparency)
    if not TBDLib.UISettings.ScanLines then return end
    
    local scanLines = Utility:Create("Frame", {
        Name = "ScanLines",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 100,
        Parent = parent
    })
    
    -- Create horizontal scan lines
    for i = 1, parent.AbsoluteSize.Y / 2 do
        local line = Utility:Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = transparency or 0.7,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, i * 2 - 1),
            Size = UDim2.new(1, 0, 0, 1),
            ZIndex = 100,
            Parent = scanLines
        })
    end
    
    return scanLines
end

-- Create VHS overlay effect
function Utility:CreateVHSOverlay(parent)
    if not TBDLib.UISettings.VHSEffect then return end

    local overlay = Utility:Create("ImageLabel", {
        Name = "VHSOverlay",
        BackgroundTransparency = 1,
        Image = ASSETS.VHSOverlay,
        ImageTransparency = 1 - TBDLib.Theme.VHSOpacity,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 99,
        Parent = parent
    })
    
    -- Animate the overlay slightly for a more authentic feel
    RunService.RenderStepped:Connect(function()
        overlay.Position = UDim2.new(0, math.random(-1, 1), 0, math.random(-1, 1))
    end)
    
    return overlay
end

-- Create glitch effect
function Utility:CreateGlitchEffect(element, intensity, duration)
    if not TBDLib.UISettings.Animations then return end
    
    intensity = intensity or 0.5
    duration = duration or 0.2
    local originalPos = element.Position
    
    -- Random position offsets to simulate glitch
    for i = 1, 5 do
        delay(i * 0.05, function()
            element.Position = originalPos + UDim2.new(0, math.random(-5, 5) * intensity, 0, math.random(-3, 3) * intensity)
            wait(0.05)
            element.Position = originalPos
        end)
    end
end

-- Format numbers with commas
function Utility:FormatNumber(number)
    local formatted = tostring(number)
    local k = formatted:len() % 3
    
    if k == 0 then k = 3 end
    
    local result = formatted:sub(1, k)
    local i = k + 1
    
    while i <= formatted:len() do
        result = result .. "," .. formatted:sub(i, i + 2)
        i = i + 3
    end
    
    return result
end

-- Main Library Functions
-- Set theme colors
function TBDLib:SetTheme(theme)
    for key, value in pairs(theme) do
        if self.Theme[key] then
            self.Theme[key] = value
        end
    end
    
    -- Update all UI elements with new theme
    for _, window in pairs(self.Windows) do
        window:UpdateTheme()
    end
end

-- Set toggle key
function TBDLib:SetToggleKey(key)
    self.ToggleKey = key
end

-- Show notification
function TBDLib:Notify(title, message, duration)
    title = title or "Notification"
    message = message or ""
    duration = duration or self.UISettings.NotificationDuration
    
    local notificationCount = #self.NotifyQueue + 1
    local notification = {}
    
    -- Notification container
    notification.Container = Utility:Create("Frame", {
        Name = "Notification" .. notificationCount,
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -20, 1, -20 - ((notificationCount - 1) * 80)),
        Size = UDim2.new(0, 260, 0, 70),
        ZIndex = 200
    })
    
    -- Add corner radius
    Utility:Create("UICorner", {
        CornerRadius = self.UISettings.CornerRadius,
        Parent = notification.Container
    })
    
    -- Accent bar
    Utility:Create("Frame", {
        Name = "AccentBar",
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 5, 1, 0),
        ZIndex = 201,
        Parent = notification.Container
    }, {
        Utility:Create("UICorner", {
            CornerRadius = UDim.new(0, 2)
        })
    })
    
    -- Title
    Utility:Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 5),
        Size = UDim2.new(1, -40, 0, 24),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = self.Theme.Accent,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 201,
        Parent = notification.Container
    })
    
    -- Message
    Utility:Create("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 30),
        Size = UDim2.new(1, -40, 0, 36),
        Font = Enum.Font.Gotham,
        Text = message,
        TextColor3 = self.Theme.TextColor,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 201,
        Parent = notification.Container
    })
    
    -- Close button
    local closeButton = Utility:Create("ImageButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -24, 0, 4),
        Size = UDim2.new(0, 20, 0, 20),
        Image = ASSETS.Close,
        ImageRectOffset = Vector2.new(284, 4),
        ImageRectSize = Vector2.new(24, 24),
        ImageColor3 = self.Theme.Accent,
        ZIndex = 201,
        Parent = notification.Container
    })
    
    -- Progress bar
    local progressBar = Utility:Create("Frame", {
        Name = "ProgressBar",
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 5, 1, -2),
        Size = UDim2.new(1, -10, 0, 2),
        ZIndex = 201,
        Parent = notification.Container
    })
    
    -- Add VHS effect
    Utility:CreateVHSOverlay(notification.Container)
    
    -- Add notification to screen
    notification.Container.Parent = CoreGui:FindFirstChild("TBDNotifications") or Utility:Create("ScreenGui", {
        Name = "TBDNotifications",
        DisplayOrder = 1000,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    -- Play notification sound
    Utility:PlaySound(SOUNDS.Notification)
    
    -- Animate notification in
    notification.Container.Position = UDim2.new(1, 20, 1, -20 - ((notificationCount - 1) * 80))
    Utility:Tween(notification.Container, {Position = UDim2.new(1, -20, 1, -20 - ((notificationCount - 1) * 80))}, 0.3)
    
    -- Animate progress bar
    Utility:Tween(progressBar, {Size = UDim2.new(0, 0, 0, 2)}, duration)
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        Utility:PlaySound(SOUNDS.Click)
        Utility:Tween(notification.Container, {Position = UDim2.new(1, 20, 1, notification.Container.Position.Y.Offset)}, 0.3)
        
        delay(0.3, function()
            notification.Container:Destroy()
            table.remove(self.NotifyQueue, table.find(self.NotifyQueue, notification))
            
            -- Reposition remaining notifications
            for i, notif in ipairs(self.NotifyQueue) do
                Utility:Tween(notif.Container, {Position = UDim2.new(1, -20, 1, -20 - ((i - 1) * 80))}, 0.3)
            end
        end)
    end)
    
    -- Auto close after duration
    delay(duration, function()
        if notification.Container and notification.Container.Parent then
            Utility:Tween(notification.Container, {Position = UDim2.new(1, 20, 1, notification.Container.Position.Y.Offset)}, 0.3)
            
            delay(0.3, function()
                notification.Container:Destroy()
                table.remove(self.NotifyQueue, table.find(self.NotifyQueue, notification))
                
                -- Reposition remaining notifications
                for i, notif in ipairs(self.NotifyQueue) do
                    Utility:Tween(notif.Container, {Position = UDim2.new(1, -20, 1, -20 - ((i - 1) * 80))}, 0.3)
                end
            end)
        end
    end)
    
    -- Add to queue
    table.insert(self.NotifyQueue, notification)
    
    return notification
end

-- Create window
function TBDLib:CreateWindow(title)
    local window = {}
    window.Tabs = {}
    window.TabButtons = {}
    window.ActiveTab = nil
    window.Dragging = false
    window.Title = title or "TBD UI Library"
    
    -- Main GUI Container
    window.Main = Utility:Create("ScreenGui", {
        Name = "TBDLibrary",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 100,
        ResetOnSpawn = false
    })
    
    -- Try to use CoreGui if possible for better persistence
    local success, err = pcall(function()
        if (syn and syn.protect_gui) then
            syn.protect_gui(window.Main)
            window.Main.Parent = CoreGui
        elseif get_hidden_gui or gethui then
            local hiddenUI = get_hidden_gui or gethui
            window.Main.Parent = hiddenUI()
        elseif (getgenv().protect_gui) then
            getgenv().protect_gui(window.Main)
            window.Main.Parent = CoreGui
        else
            window.Main.Parent = CoreGui
        end
    end)
    
    if not success then
        window.Main.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Shadow effect
    window.Shadow = Utility:Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 4),
        Size = UDim2.new(1, 8, 1, 8),
        Image = "rbxassetid://7912134082",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(80, 80, 80, 80),
        SliceScale = 0.02
    })
    
    -- Main Frame
    window.Frame = Utility:Create("Frame", {
        Name = "MainFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = TBDLib.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 650, 0, 400)
    }, {
        Utility:Create("UICorner", {
            CornerRadius = TBDLib.UISettings.CornerRadius
        }),
        window.Shadow
    })
    
    window.Shadow.Parent = window.Frame
    window.Frame.Parent = window.Main
    
    -- Title Bar
    window.TitleBar = Utility:Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = TBDLib.Theme.DarkContrast,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 34)
    }, {
        Utility:Create("UICorner", {
            CornerRadius = TBDLib.UISettings.CornerRadius
        })
    })
    
    -- Fix corners for title bar
    Utility:Create("Frame", {
        Name = "CornerFix",
        BackgroundColor3 = TBDLib.Theme.DarkContrast,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -6),
        Size = UDim2.new(1, 0, 0, 6),
        Parent = window.TitleBar
    })
    
    -- Logo
    window.Logo = Utility:Create("ImageLabel", {
        Name = "Logo",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 4),
        Size = UDim2.new(0, 26, 0, 26),
        Image = ASSETS.Logo,
        Parent = window.TitleBar
    })
    
    -- Title text
    window.TitleText = Utility:Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 44, 0, 0),
        Size = UDim2.new(1, -120, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = window.Title,
        TextColor3 = TBDLib.Theme.TextColor,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = window.TitleBar
    })
    
    -- Red-blue separator line (80s aesthetic)
    local redBlueAccent = Utility:Create("Frame", {
        Name = "RedBlueAccent",
        BackgroundColor3 = TBDLib.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 2,
        Parent = window.TitleBar
    })
    
    -- Create a gradient for the red-blue accent
    local accentGradient = Utility:Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, TBDLib.Theme.Accent),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, TBDLib.Theme.SecondaryAccent)
        }),
        Parent = redBlueAccent
    })
    
    -- Navigation arrows (») aesthetic from HoHo Hub
    window.NavArrows = Utility:Create("TextLabel", {
        Name = "NavArrows",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 200, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "» » » »",
        TextColor3 = TBDLib.Theme.Accent,
        TextSize = 16,
        Parent = window.TitleBar
    })
    
    -- Version label
    window.VersionLabel = Utility:Create("TextLabel", {
        Name = "Version",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -150, 0, 0),
        Size = UDim2.new(0, 80, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "v" .. TBDLib.Version,
        TextColor3 = TBDLib.Theme.Accent,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = window.TitleBar
    })
    
    -- Close button
    window.CloseButton = Utility:Create("ImageButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -32, 0, 4),
        Size = UDim2.new(0, 26, 0, 26),
        Image = ASSETS.Close,
        ImageRectOffset = Vector2.new(284, 4),
        ImageRectSize = Vector2.new(24, 24),
        ImageColor3 = TBDLib.Theme.Accent,
        Parent = window.TitleBar
    })
    
    window.CloseButton.MouseEnter:Connect(function()
        Utility:Tween(window.CloseButton, {ImageColor3 = Color3.fromRGB(255, 60, 60)}, 0.2)
    end)
    
    window.CloseButton.MouseLeave:Connect(function()
        Utility:Tween(window.CloseButton, {ImageColor3 = TBDLib.Theme.Accent}, 0.2)
    end)
    
    window.CloseButton.MouseButton1Click:Connect(function()
        Utility:PlaySound(SOUNDS.Close)
        Utility:Tween(window.Frame, {
            Size = UDim2.new(0, window.Frame.AbsoluteSize.X, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, window.Frame.AbsoluteSize.Y / 2)
        }, 0.25)
        
        delay(0.25, function()
            window.Main:Destroy()
        end)
    end)
    
    window.TitleBar.Parent = window.Frame
    
    -- Tab Container
    window.TabContainer = Utility:Create("Frame", {
        Name = "TabContainer",
        BackgroundColor3 = TBDLib.Theme.LightContrast,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 34),
        Size = UDim2.new(0, 140, 1, -34)
    })
    
    -- Fix corners for tab container
    Utility:Create("Frame", {
        Name = "CornerFix",
        BackgroundColor3 = TBDLib.Theme.LightContrast,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -6, 0, 0),
        Size = UDim2.new(0, 6, 1, 0),
        Parent = window.TabContainer
    })
    
    Utility:Create("UICorner", {
        CornerRadius = TBDLib.UISettings.CornerRadius,
        Parent = window.TabContainer
    })
    
    -- Tab Buttons
    window.TabButtonContainer = Utility:Create("ScrollingFrame", {
        Name = "TabButtons",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 1, -10),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = TBDLib.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = window.TabContainer
    })
    
    -- HoHo Hub Style Logo
    window.BrandingLogo = Utility:Create("Frame", {
        Name = "BrandingLogo",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 90),
        Parent = window.TabButtonContainer
    })
    
    window.LogoText = Utility:Create("TextLabel", {
        Name = "LogoText",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0, 5),
        Size = UDim2.new(1, -10, 0, 30),
        Font = Enum.Font.GothamBold, 
        Text = "TBD",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 24,
        Parent = window.BrandingLogo
    })
    
    window.LogoTextAccent = Utility:Create("TextLabel", {
        Name = "LogoTextAccent",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0, 35),
        Size = UDim2.new(1, -10, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "UI LIB",
        TextColor3 = TBDLib.Theme.Accent,
        TextSize = 24,
        Parent = window.BrandingLogo
    })
    
    window.LogoSubtitle = Utility:Create("TextLabel", {
        Name = "LogoSubtitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0, 65),
        Size = UDim2.new(1, -10, 0, 20),
        Font = Enum.Font.Gotham,
        Text = "#1 FREE UI LIB",
        TextColor3 = TBDLib.Theme.Accent,
        TextSize = 12,
        Parent = window.BrandingLogo
    })
    
    -- Tab Content
    window.TabContent = Utility:Create("Frame", {
        Name = "TabContent",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 140, 0, 34),
        Size = UDim2.new(1, -140, 1, -34),
        Parent = window.Frame
    })
    
    -- UI List Layout for tab buttons
    Utility:Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = window.TabButtonContainer
    })
    
    -- VHS Overlay effect
    Utility:CreateVHSOverlay(window.Frame)
    
    -- Scan lines effect
    Utility:CreateScanLines(window.Frame, 0.9)
    
    -- Make the window draggable
    Utility:EnableDragging(window.Frame)
    
    -- Window intro animation
    window.Frame.Size = UDim2.new(0, 0, 0, 0)
    Utility:Tween(window.Frame, {
        Size = UDim2.new(0, 650, 0, 400),
    }, 0.3, Enum.EasingStyle.Back)
    
    -- Toggle window visibility with the toggle key
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == TBDLib.ToggleKey then
            window.Main.Enabled = not window.Main.Enabled
        end
    end)
    
    -- Window methods
    function window:UpdateTheme()
        window.Frame.BackgroundColor3 = TBDLib.Theme.Background
        window.TitleBar.BackgroundColor3 = TBDLib.Theme.DarkContrast
        window.TitleBar.CornerFix.BackgroundColor3 = TBDLib.Theme.DarkContrast
        window.TitleText.TextColor3 = TBDLib.Theme.TextColor
        window.TabContainer.BackgroundColor3 = TBDLib.Theme.LightContrast
        window.TabContainer.CornerFix.BackgroundColor3 = TBDLib.Theme.LightContrast
        window.LogoTextAccent.TextColor3 = TBDLib.Theme.Accent
        window.LogoSubtitle.TextColor3 = TBDLib.Theme.Accent
        window.NavArrows.TextColor3 = TBDLib.Theme.Accent
        window.VersionLabel.TextColor3 = TBDLib.Theme.Accent
        
        -- Update tabs and their elements
        for _, tab in pairs(window.Tabs) do
            tab:UpdateTheme()
        end
    end
    
    function window:CreateTab(name, icon)
        local tab = {}
        tab.Name = name
        tab.Icon = icon
        tab.Sections = {}
        tab.Elements = {}
        tab.Events = {}
        
        -- Tab button with icon (HoHo Hub style)
        tab.Button = Utility:Create("Frame", {
            Name = name,
            BackgroundColor3 = TBDLib.Theme.DarkContrast,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 36),
            Parent = window.TabButtonContainer
        })
        
        -- Tab button background (for hover and selection)
        tab.ButtonBG = Utility:Create("Frame", {
            Name = "Background",
            BackgroundColor3 = TBDLib.Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 2,
            Parent = tab.Button
        })
        
        Utility:Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = tab.ButtonBG
        })
        
        -- Tab icon (if provided)
        if icon then
            tab.Icon = Utility:Create("ImageLabel", {
                Name = "Icon",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0, 8),
                Size = UDim2.new(0, 20, 0, 20),
                Image = icon,
                ImageColor3 = TBDLib.Theme.TextColor,
                ZIndex = 3,
                Parent = tab.Button
            })
            
            tab.Label = Utility:Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 36, 0, 0),
                Size = UDim2.new(1, -44, 1, 0),
                Font = Enum.Font.Gotham,
                Text = name,
                TextColor3 = TBDLib.Theme.TextColor,
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 3,
                Parent = tab.Button
            })
        else
            tab.Label = Utility:Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = Enum.Font.Gotham,
                Text = name,
                TextColor3 = TBDLib.Theme.TextColor,
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 3,
                Parent = tab.Button
            })
        end
        
        -- Red indicator on the left (HoHo Hub style)
        tab.Indicator = Utility:Create("Frame", {
            Name = "Indicator",
            BackgroundColor3 = TBDLib.Theme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 8),
            Size = UDim2.new(0, 4, 0, 20),
            Visible = false,
            ZIndex = 3,
            Parent = tab.Button
        })
        
        Utility:Create("UICorner", {
            CornerRadius = UDim.new(0, 2),
            Parent = tab.Indicator
        })
        
        -- Tab button hover effect
        tab.Button.MouseEnter:Connect(function()
            if window.ActiveTab ~= tab then
                Utility:PlaySound(SOUNDS.Hover)
                Utility:Tween(tab.ButtonBG, {BackgroundTransparency = 0.9}, 0.2)
                Utility:Tween(tab.Label, {TextTransparency = 0.2}, 0.2)
                if tab.Icon then
                    Utility:Tween(tab.Icon, {ImageTransparency = 0.2}, 0.2)
                end
            end
        end)
        
        tab.Button.MouseLeave:Connect(function()
            if window.ActiveTab ~= tab then
                Utility:Tween(tab.ButtonBG, {BackgroundTransparency = 1}, 0.2)
                Utility:Tween(tab.Label, {TextTransparency = 0.5}, 0.2)
                if tab.Icon then
                    Utility:Tween(tab.Icon, {ImageTransparency = 0.5}, 0.2)
                end
            end
        end)
        
        -- Tab button click
        tab.Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                window:SelectTab(tab)
            end
        end)
        
        -- Tab container
        tab.Container = Utility:Create("ScrollingFrame", {
            Name = "Container",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = TBDLib.Theme.Accent,
            Visible = false,
            Parent = window.TabContent
        })
        
        -- UI Padding
        Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            Parent = tab.Container
        })
        
        -- UI List Layout
        tab.ContainerLayout = Utility:Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = tab.Container
        })
        
        -- Update canvas size when elements are added
        tab.ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tab.Container.CanvasSize = UDim2.new(0, 0, 0, tab.ContainerLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Tab methods
        function tab:UpdateTheme()
            tab.ButtonBG.BackgroundColor3 = TBDLib.Theme.Accent
            tab.Label.TextColor3 = TBDLib.Theme.TextColor
            tab.Indicator.BackgroundColor3 = TBDLib.Theme.Accent
            if tab.Icon then
                tab.Icon.ImageColor3 = TBDLib.Theme.TextColor
            end
            
            -- Update sections
            for _, section in pairs(tab.Sections) do
                section:UpdateTheme()
            end
            
            -- Update elements
            for _, element in pairs(tab.Elements) do
                if element.UpdateTheme then
                    element:UpdateTheme()
                end
            end
            
            tab.Container.ScrollBarImageColor3 = TBDLib.Theme.Accent
        end
        
        -- Create a section in the tab
        function tab:CreateSection(name)
            local section = {}
            section.Name = name
            section.Elements = {}
            
            -- Section container
            section.Container = Utility:Create("Frame", {
                Name = name,
                BackgroundColor3 = TBDLib.Theme.LightContrast,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40), -- Will auto-resize based on content
                Parent = tab.Container
            })
            
            Utility:Create("UICorner", {
                CornerRadius = TBDLib.UISettings.CornerRadius,
                Parent = section.Container
            })
            
            -- Section title with neon 80s style
            section.Title = Utility:Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 8),
                Size = UDim2.new(1, -24, 0, 24),
                Font = Enum.Font.GothamBold,
                Text = name,
                TextColor3 = TBDLib.Theme.Accent,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = section.Container
            })
            
            -- Section content
            section.Content = Utility:Create("Frame", {
                Name = "Content",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 32),
                Size = UDim2.new(1, 0, 0, 0), -- Will be resized as elements are added
                Parent = section.Container
            })
            
            -- Content padding
            Utility:Create("UIPadding", {
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                PaddingTop = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 6),
                Parent = section.Content
            })
            
            -- List layout for content
            section.ContentLayout = Utility:Create("UIListLayout", {
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = section.Content
            })
            
            -- Update section size as elements are added
            section.ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                section.Content.Size = UDim2.new(1, 0, 0, section.ContentLayout.AbsoluteContentSize.Y)
                section.Container.Size = UDim2.new(1, 0, 0, section.Content.AbsoluteSize.Y + 38)
            end)
            
            -- Section methods
            function section:UpdateTheme()
                section.Container.BackgroundColor3 = TBDLib.Theme.LightContrast
                section.Title.TextColor3 = TBDLib.Theme.Accent
                
                -- Update elements
                for _, element in pairs(section.Elements) do
                    if element.UpdateTheme then
                        element:UpdateTheme()
                    end
                end
            end
            
            -- Add a button
            function section:AddButton(text, callback)
                local button = {}
                button.Text = text
                button.Callback = callback or function() end
                
                -- Button container
                button.Container = Utility:Create("Frame", {
                    Name = text .. "Button",
                    BackgroundColor3 = TBDLib.Theme.DarkContrast,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    Parent = section.Content
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = button.Container
                })
                
                -- Button
                button.Button = Utility:Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = TBDLib.Theme.Accent,
                    BackgroundTransparency = 0.9,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = TBDLib.Theme.TextColor,
                    TextSize = 14,
                    Parent = button.Container
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = button.Button
                })
                
                -- 80s style accent stripe for the button (HoHo Hub style)
                button.AccentStripe = Utility:Create("Frame", {
                    Name = "AccentStripe",
                    BackgroundColor3 = TBDLib.Theme.Accent,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 6, 0.5, -1),
                    Size = UDim2.new(0, 18, 0, 2),
                    Parent = button.Button
                })
                
                -- Button click effect
                button.Button.MouseButton1Click:Connect(function()
                    Utility:PlaySound(SOUNDS.Click)
                    Utility:Ripple(button.Button)
                    Utility:Tween(button.Button, {BackgroundTransparency = 0.8}, 0.1)
                    
                    delay(0.1, function()
                        Utility:Tween(button.Button, {BackgroundTransparency = 0.9}, 0.1)
                    end)
                    
                    pcall(callback)
                end)
                
                -- Button hover effect
                button.Button.MouseEnter:Connect(function()
                    Utility:PlaySound(SOUNDS.Hover)
                    Utility:Tween(button.Button, {BackgroundTransparency = 0.8}, 0.2)
                    Utility:Tween(button.AccentStripe, {Size = UDim2.new(0, 22, 0, 2)}, 0.2)
                end)
                
                button.Button.MouseLeave:Connect(function()
                    Utility:Tween(button.Button, {BackgroundTransparency = 0.9}, 0.2)
                    Utility:Tween(button.AccentStripe, {Size = UDim2.new(0, 18, 0, 2)}, 0.2)
                end)
                
                function button:UpdateTheme()
                    button.Container.BackgroundColor3 = TBDLib.Theme.DarkContrast
                    button.Button.BackgroundColor3 = TBDLib.Theme.Accent
                    button.Button.TextColor3 = TBDLib.Theme.TextColor
                    button.AccentStripe.BackgroundColor3 = TBDLib.Theme.Accent
                end
                
                function button:SetText(newText)
                    button.Button.Text = newText
                end
                
                table.insert(section.Elements, button)
                table.insert(tab.Elements, button)
                
                return button
            end
            
            -- Add a toggle
            function section:AddToggle(text, default, callback)
                local toggle = {}
                toggle.Text = text
                toggle.Default = default or false
                toggle.Callback = callback or function() end
                toggle.Value = toggle.Default
                
                -- Toggle container
                toggle.Container = Utility:Create("Frame", {
                    Name = text .. "Toggle",
                    BackgroundColor3 = TBDLib.Theme.DarkContrast,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    Parent = section.Content
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = toggle.Container
                })
                
                -- Toggle label
                toggle.Label = Utility:Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 42, 0, 0),
                    Size = UDim2.new(1, -72, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = TBDLib.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = toggle.Container
                })
                
                -- Toggle indicator background
                toggle.Background = Utility:Create("Frame", {
                    Name = "Background",
                    BackgroundColor3 = TBDLib.Theme.LightContrast,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0.5, -8),
                    Size = UDim2.new(0, 24, 0, 16),
                    Parent = toggle.Container
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = toggle.Background
                })
                
                -- Toggle indicator
                toggle.Indicator = Utility:Create("Frame", {
                    Name = "Indicator",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = TBDLib.Theme.TextColor,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 2, 0.5, 0),
                    Size = UDim2.new(0, 12, 0, 12),
                    Parent = toggle.Background
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = toggle.Indicator
                })
                
                -- Toggle button (invisible, full container area for better UX)
                toggle.Button = Utility:Create("TextButton", {
                    Name = "ToggleButton",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = toggle.Container
                })
                
                -- Toggle function
                function toggle:Set(value)
                    toggle.Value = value
                    TBDLib.Flags[toggle.Text] = value
                    
                    if value then
                        Utility:Tween(toggle.Indicator, {
                            Position = UDim2.new(0, 10, 0.5, 0),
                            BackgroundColor3 = TBDLib.Theme.Accent
                        }, 0.2)
                        Utility:Tween(toggle.Background, {
                            BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                        }, 0.2)
                    else
                        Utility:Tween(toggle.Indicator, {
                            Position = UDim2.new(0, 2, 0.5, 0),
                            BackgroundColor3 = TBDLib.Theme.TextColor
                        }, 0.2)
                        Utility:Tween(toggle.Background, {
                            BackgroundColor3 = TBDLib.Theme.LightContrast
                        }, 0.2)
                    end
                    
                    pcall(toggle.Callback, toggle.Value)
                end
                
                -- Set initial state
                toggle:Set(toggle.Default)
                
                -- Toggle click handler
                toggle.Button.MouseButton1Click:Connect(function()
                    Utility:PlaySound(SOUNDS.Toggle)
                    toggle:Set(not toggle.Value)
                end)
                
                -- Hover effect
                toggle.Button.MouseEnter:Connect(function()
                    Utility:PlaySound(SOUNDS.Hover)
                    Utility:Tween(toggle.Container, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.2)
                end)
                
                toggle.Button.MouseLeave:Connect(function()
                    Utility:Tween(toggle.Container, {BackgroundColor3 = TBDLib.Theme.DarkContrast}, 0.2)
                end)
                
                function toggle:UpdateTheme()
                    toggle.Container.BackgroundColor3 = TBDLib.Theme.DarkContrast
                    toggle.Label.TextColor3 = TBDLib.Theme.TextColor
                    
                    if toggle.Value then
                        toggle.Indicator.BackgroundColor3 = TBDLib.Theme.Accent
                    else
                        toggle.Indicator.BackgroundColor3 = TBDLib.Theme.TextColor
                    end
                    
                    toggle.Background.BackgroundColor3 = toggle.Value and Color3.fromRGB(50, 50, 50) or TBDLib.Theme.LightContrast
                end
                
                table.insert(section.Elements, toggle)
                table.insert(tab.Elements, toggle)
                
                return toggle
            end
            
            -- Add a slider
            function section:AddSlider(text, min, max, default, callback)
                local slider = {}
                slider.Text = text
                slider.Min = min or 0
                slider.Max = max or 100
                slider.Default = default or slider.Min
                slider.Callback = callback or function() end
                slider.Value = slider.Default
                
                -- Slider container
                slider.Container = Utility:Create("Frame", {
                    Name = text .. "Slider",
                    BackgroundColor3 = TBDLib.Theme.DarkContrast,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 50),
                    Parent = section.Content
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = slider.Container
                })
                
                -- Slider label
                slider.Label = Utility:Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 6),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = TBDLib.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = slider.Container
                })
                
                -- Value display
                slider.ValueLabel = Utility:Create("TextLabel", {
                    Name = "Value",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -40, 0, 6),
                    Size = UDim2.new(0, 30, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = tostring(slider.Value),
                    TextColor3 = TBDLib.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = slider.Container
                })
                
                -- Slider background
                slider.Background = Utility:Create("Frame", {
                    Name = "Background",
                    BackgroundColor3 = TBDLib.Theme.LightContrast,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 6),
                    Parent = slider.Container
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = slider.Background
                })
                
                -- Slider fill
                slider.Fill = Utility:Create("Frame", {
                    Name = "Fill",
                    BackgroundColor3 = TBDLib.Theme.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 0, 1, 0),
                    Parent = slider.Background
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = slider.Fill
                })
                
                -- Slider button (invisible, for better UX)
                slider.Button = Utility:Create("TextButton", {
                    Name = "SliderButton",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = slider.Container
                })
                
                -- Set slider value
                function slider:Set(value)
                    value = math.clamp(value, slider.Min, slider.Max)
                    value = math.floor(value * 10) / 10 -- Round to 1 decimal place
                    slider.Value = value
                    TBDLib.Flags[slider.Text] = value
                    
                    local percent = (value - slider.Min) / (slider.Max - slider.Min)
                    Utility:Tween(slider.Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                    slider.ValueLabel.Text = tostring(value)
                    
                    pcall(slider.Callback, value)
                end
                
                -- Set initial value
                slider:Set(slider.Default)
                
                -- Slider interaction
                local dragging = false
                
                slider.Button.MouseButton1Down:Connect(function()
                    dragging = true
                    Utility:PlaySound(SOUNDS.Click)
                    
                    repeat
                        local mousePos = UserInputService:GetMouseLocation()
                        local relPos = mousePos.X - slider.Background.AbsolutePosition.X
                        local sliderSize = slider.Background.AbsoluteSize.X
                        local percent = math.clamp(relPos / sliderSize, 0, 1)
                        local value = slider.Min + (slider.Max - slider.Min) * percent
                        
                        slider:Set(value)
                        RunService.RenderStepped:Wait()
                    until not dragging
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
                        dragging = false
                    end
                end)
                
                -- Hover effect
                slider.Button.MouseEnter:Connect(function()
                    Utility:PlaySound(SOUNDS.Hover)
                    Utility:Tween(slider.Container, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.2)
                end)
                
                slider.Button.MouseLeave:Connect(function()
                    Utility:Tween(slider.Container, {BackgroundColor3 = TBDLib.Theme.DarkContrast}, 0.2)
                end)
                
                function slider:UpdateTheme()
                    slider.Container.BackgroundColor3 = TBDLib.Theme.DarkContrast
                    slider.Label.TextColor3 = TBDLib.Theme.TextColor
                    slider.ValueLabel.TextColor3 = TBDLib.Theme.TextColor
                    slider.Background.BackgroundColor3 = TBDLib.Theme.LightContrast
                    slider.Fill.BackgroundColor3 = TBDLib.Theme.Accent
                end
                
                table.insert(section.Elements, slider)
                table.insert(tab.Elements, slider)
                
                return slider
            end
            
            -- Add a dropdown
            function section:AddDropdown(text, options, default, callback)
                local dropdown = {}
                dropdown.Text = text
                dropdown.Options = options or {}
                dropdown.Default = default or (options[1] or "")
                dropdown.Callback = callback or function() end
                dropdown.Value = dropdown.Default
                dropdown.Open = false
                
                -- Dropdown container
                dropdown.Container = Utility:Create("Frame", {
                    Name = text .. "Dropdown",
                    BackgroundColor3 = TBDLib.Theme.DarkContrast,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Size = UDim2.new(1, 0, 0, 40),
                    Parent = section.Content
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = dropdown.Container
                })
                
                -- Dropdown label
                dropdown.Label = Utility:Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 0, 40),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = TBDLib.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = dropdown.Container
                })
                
                -- Selected value
                dropdown.Selected = Utility:Create("TextLabel", {
                    Name = "Selected",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -50, 0, 40),
                    Font = Enum.Font.Gotham,
                    Text = dropdown.Value,
                    TextColor3 = TBDLib.Theme.Accent,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = dropdown.Container
                })
                
                -- Dropdown arrow
                dropdown.Arrow = Utility:Create("ImageLabel", {
                    Name = "Arrow",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -30, 0, 5),
                    Size = UDim2.new(0, 30, 0, 30),
                    Rotation = 0,
                    Image = ASSETS.DropdownArrow,
                    ImageColor3 = TBDLib.Theme.TextColor,
                    Parent = dropdown.Container
                })
                
                -- Option container
                dropdown.OptionContainer = Utility:Create("Frame", {
                    Name = "Options",
                    BackgroundColor3 = TBDLib.Theme.LightContrast,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 40),
                    Size = UDim2.new(1, 0, 0, 0), -- Will be resized based on options
                    Visible = false,
                    Parent = dropdown.Container
                })
                
                -- Options list
                dropdown.OptionList = Utility:Create("ScrollingFrame", {
                    Name = "OptionList",
                    Active = true,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = TBDLib.Theme.Accent,
                    Parent = dropdown.OptionContainer
                })
                
                -- List layout for options
                dropdown.OptionListLayout = Utility:Create("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = dropdown.OptionList
                })
                
                -- Dropdown button (invisible, for better UX)
                dropdown.Button = Utility:Create("TextButton", {
                    Name = "DropdownButton",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40),
                    Text = "",
                    Parent = dropdown.Container
                })
                
                -- Toggle dropdown state
                function dropdown:Toggle()
                    dropdown.Open = not dropdown.Open
                    
                    if dropdown.Open then
                        Utility:PlaySound(SOUNDS.Open)
                        -- Open dropdown
                        local optionCount = #dropdown.Options
                        local containerSize = math.min(optionCount * 30, 150) -- Max height of 150 pixels
                        
                        dropdown.OptionList.CanvasSize = UDim2.new(0, 0, 0, optionCount * 30)
                        
                        dropdown.OptionContainer.Visible = true
                        dropdown.Container.ClipsDescendants = false
                        
                        Utility:Tween(dropdown.Arrow, {Rotation = 180}, 0.2)
                        Utility:Tween(dropdown.Container, {Size = UDim2.new(1, 0, 0, 40 + containerSize)}, 0.2)
                        Utility:Tween(dropdown.OptionContainer, {Size = UDim2.new(1, 0, 0, containerSize)}, 0.2)
                    else
                        Utility:PlaySound(SOUNDS.Close)
                        -- Close dropdown
                        Utility:Tween(dropdown.Arrow, {Rotation = 0}, 0.2)
                        Utility:Tween(dropdown.Container, {Size = UDim2.new(1, 0, 0, 40)}, 0.2)
                        Utility:Tween(dropdown.OptionContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        
                        delay(0.2, function()
                            if not dropdown.Open then
                                dropdown.OptionContainer.Visible = false
                                dropdown.Container.ClipsDescendants = true
                            end
                        end)
                    end
                end
                
                -- Update available options
                function dropdown:UpdateOptions(newOptions)
                    dropdown.Options = newOptions
                    
                    -- Clear existing options
                    for _, child in pairs(dropdown.OptionList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Rebuild options
                    for i, option in ipairs(dropdown.Options) do
                        local optionButton = Utility:Create("TextButton", {
                            Name = option,
                            BackgroundColor3 = TBDLib.Theme.DarkContrast,
                            BackgroundTransparency = 0.5,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 30),
                            Font = Enum.Font.Gotham,
                            Text = "  " .. option,
                            TextColor3 = TBDLib.Theme.TextColor,
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Parent = dropdown.OptionList
                        })
                        
                        -- Highlight selected option
                        if option == dropdown.Value then
                            optionButton.BackgroundTransparency = 0.2
                            optionButton.TextColor3 = TBDLib.Theme.Accent
                        end
                        
                        -- Option button hover effect
                        optionButton.MouseEnter:Connect(function()
                            Utility:PlaySound(SOUNDS.Hover)
                            if option ~= dropdown.Value then
                                Utility:Tween(optionButton, {BackgroundTransparency = 0.2}, 0.2)
                            end
                        end)
                        
                        optionButton.MouseLeave:Connect(function()
                            if option ~= dropdown.Value then
                                Utility:Tween(optionButton, {BackgroundTransparency = 0.5}, 0.2)
                            end
                        end)
                        
                        -- Option selection
                        optionButton.MouseButton1Click:Connect(function()
                            Utility:PlaySound(SOUNDS.Click)
                            dropdown:Select(option)
                            dropdown:Toggle()
                        end)
                    end
                    
                    -- Update canvas size
                    dropdown.OptionList.CanvasSize = UDim2.new(0, 0, 0, #dropdown.Options * 30)
                end
                
                -- Select an option
                function dropdown:Select(option)
                    for _, child in pairs(dropdown.OptionList:GetChildren()) do
                        if child:IsA("TextButton") then
                            if child.Text == "  " .. option then
                                child.BackgroundTransparency = 0.2
                                child.TextColor3 = TBDLib.Theme.Accent
                            else
                                child.BackgroundTransparency = 0.5
                                child.TextColor3 = TBDLib.Theme.TextColor
                            end
                        end
                    end
                    
                    dropdown.Value = option
                    dropdown.Selected.Text = option
                    TBDLib.Flags[dropdown.Text] = option
                    
                    pcall(dropdown.Callback, option)
                end
                
                -- Handle dropdown button click
                dropdown.Button.MouseButton1Click:Connect(function()
                    dropdown:Toggle()
                end)
                
                -- Hover effect
                dropdown.Button.MouseEnter:Connect(function()
                    Utility:PlaySound(SOUNDS.Hover)
                    Utility:Tween(dropdown.Container, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.2)
                end)
                
                dropdown.Button.MouseLeave:Connect(function()
                    Utility:Tween(dropdown.Container, {BackgroundColor3 = TBDLib.Theme.DarkContrast}, 0.2)
                end)
                
                -- Initialize options
                dropdown:UpdateOptions(dropdown.Options)
                
                -- Set initial selected option
                if dropdown.Default and table.find(dropdown.Options, dropdown.Default) then
                    dropdown:Select(dropdown.Default)
                elseif #dropdown.Options > 0 then
                    dropdown:Select(dropdown.Options[1])
                end
                
                function dropdown:UpdateTheme()
                    dropdown.Container.BackgroundColor3 = TBDLib.Theme.DarkContrast
                    dropdown.Label.TextColor3 = TBDLib.Theme.TextColor
                    dropdown.Selected.TextColor3 = TBDLib.Theme.Accent
                    dropdown.Arrow.ImageColor3 = TBDLib.Theme.TextColor
                    dropdown.OptionContainer.BackgroundColor3 = TBDLib.Theme.LightContrast
                    dropdown.OptionList.ScrollBarImageColor3 = TBDLib.Theme.Accent
                    
                    for _, child in pairs(dropdown.OptionList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.BackgroundColor3 = TBDLib.Theme.DarkContrast
                            if child.Text == "  " .. dropdown.Value then
                                child.TextColor3 = TBDLib.Theme.Accent
                            else
                                child.TextColor3 = TBDLib.Theme.TextColor
                            end
                        end
                    end
                end
                
                table.insert(section.Elements, dropdown)
                table.insert(tab.Elements, dropdown)
                
                return dropdown
            end
            
            -- Add a textbox
            function section:AddTextbox(text, default, placeholder, callback)
                local textbox = {}
                textbox.Text = text
                textbox.Default = default or ""
                textbox.Placeholder = placeholder or "Enter text..."
                textbox.Callback = callback or function() end
                textbox.Value = textbox.Default
                
                -- Textbox container
                textbox.Container = Utility:Create("Frame", {
                    Name = text .. "Textbox",
                    BackgroundColor3 = TBDLib.Theme.DarkContrast,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 40),
                    Parent = section.Content
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = textbox.Container
                })
                
                -- Textbox label
                textbox.Label = Utility:Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = TBDLib.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = textbox.Container
                })
                
                -- Textbox input background
                textbox.Background = Utility:Create("Frame", {
                    Name = "Background",
                    BackgroundColor3 = TBDLib.Theme.LightContrast,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 20),
                    Size = UDim2.new(1, -20, 0, 16),
                    Parent = textbox.Container
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = textbox.Background
                })
                
                -- Textbox input
                textbox.Input = Utility:Create("TextBox", {
                    Name = "Input",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 0),
                    Size = UDim2.new(1, -10, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = textbox.Default,
                    PlaceholderText = textbox.Placeholder,
                    PlaceholderColor3 = TBDLib.Theme.PlaceholderColor,
                    TextColor3 = TBDLib.Theme.TextColor,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    Parent = textbox.Background
                })
                
                -- Input complete on lost focus
                textbox.Input.FocusLost:Connect(function(enterPressed)
                    textbox.Value = textbox.Input.Text
                    TBDLib.Flags[textbox.Text] = textbox.Value
                    
                    pcall(textbox.Callback, textbox.Value)
                    
                    if enterPressed then
                        Utility:PlaySound(SOUNDS.Click)
                    end
                end)
                
                -- Focus effects
                textbox.Input.Focused:Connect(function()
                    Utility:PlaySound(SOUNDS.Click)
                    Utility:Tween(textbox.Background, {BackgroundColor3 = Color3.fromRGB(65, 65, 65)}, 0.2)
                end)
                
                textbox.Input.FocusLost:Connect(function()
                    Utility:Tween(textbox.Background, {BackgroundColor3 = TBDLib.Theme.LightContrast}, 0.2)
                end)
                
                -- Container hover effect
                textbox.Container.MouseEnter:Connect(function()
                    Utility:PlaySound(SOUNDS.Hover)
                    Utility:Tween(textbox.Container, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.2)
                end)
                
                textbox.Container.MouseLeave:Connect(function()
                    Utility:Tween(textbox.Container, {BackgroundColor3 = TBDLib.Theme.DarkContrast}, 0.2)
                end)
                
                function textbox:UpdateTheme()
                    textbox.Container.BackgroundColor3 = TBDLib.Theme.DarkContrast
                    textbox.Label.TextColor3 = TBDLib.Theme.TextColor
                    textbox.Background.BackgroundColor3 = TBDLib.Theme.LightContrast
                    textbox.Input.TextColor3 = TBDLib.Theme.TextColor
                    textbox.Input.PlaceholderColor3 = TBDLib.Theme.PlaceholderColor
                end
                
                function textbox:SetText(newText)
                    textbox.Input.Text = newText
                    textbox.Value = newText
                    TBDLib.Flags[textbox.Text] = newText
                    
                    pcall(textbox.Callback, newText)
                end
                
                table.insert(section.Elements, textbox)
                table.insert(tab.Elements, textbox)
                
                return textbox
            end
            
            -- Add a keybind
            function section:AddKeybind(text, default, callback, changedCallback)
                local keybind = {}
                keybind.Text = text
                keybind.Default = default or Enum.KeyCode.Unknown
                keybind.Callback = callback or function() end
                keybind.ChangedCallback = changedCallback or function() end
                keybind.Value = keybind.Default
                keybind.Listening = false
                
                -- Keybind container
                keybind.Container = Utility:Create("Frame", {
                    Name = text .. "Keybind",
                    BackgroundColor3 = TBDLib.Theme.DarkContrast,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    Parent = section.Content
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = keybind.Container
                })
                
                -- Keybind label
                keybind.Label = Utility:Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -90, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = TBDLib.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = keybind.Container
                })
                
                -- Keybind button
                keybind.Button = Utility:Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = TBDLib.Theme.LightContrast,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -80, 0.5, -12),
                    Size = UDim2.new(0, 70, 0, 24),
                    Font = Enum.Font.Gotham,
                    Text = keybind.Value.Name,
                    TextColor3 = TBDLib.Theme.TextColor,
                    TextSize = 12,
                    Parent = keybind.Container
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = keybind.Button
                })
                
                -- Set keybind
                function keybind:Set(key)
                    keybind.Value = key or Enum.KeyCode.Unknown
                    keybind.Button.Text = keybind.Value.Name
                    TBDLib.Flags[keybind.Text] = keybind.Value
                    
                    pcall(keybind.ChangedCallback, keybind.Value)
                end
                
                -- Set initial keybind
                keybind:Set(keybind.Default)
                
                -- Toggle listening mode
                function keybind:ToggleListening()
                    keybind.Listening = not keybind.Listening
                    
                    if keybind.Listening then
                        keybind.Button.Text = "..."
                        Utility:PlaySound(SOUNDS.Click)
                    else
                        keybind.Button.Text = keybind.Value.Name
                    end
                end
                
                -- Keybind button click
                keybind.Button.MouseButton1Click:Connect(function()
                    keybind:ToggleListening()
                end)
                
                -- Listen for key press
                UserInputService.InputBegan:Connect(function(input)
                    if keybind.Listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            keybind:Set(input.KeyCode)
                            keybind:ToggleListening()
                        end
                    elseif input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == keybind.Value then
                            pcall(keybind.Callback, keybind.Value)
                        end
                    end
                end)
                
                -- Button hover effect
                keybind.Button.MouseEnter:Connect(function()
                    Utility:PlaySound(SOUNDS.Hover)
                    Utility:Tween(keybind.Button, {BackgroundColor3 = Color3.fromRGB(65, 65, 65)}, 0.2)
                end)
                
                keybind.Button.MouseLeave:Connect(function()
                    Utility:Tween(keybind.Button, {BackgroundColor3 = TBDLib.Theme.LightContrast}, 0.2)
                end)
                
                -- Container hover effect
                keybind.Container.MouseEnter:Connect(function()
                    Utility:Tween(keybind.Container, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.2)
                end)
                
                keybind.Container.MouseLeave:Connect(function()
                    Utility:Tween(keybind.Container, {BackgroundColor3 = TBDLib.Theme.DarkContrast}, 0.2)
                end)
                
                function keybind:UpdateTheme()
                    keybind.Container.BackgroundColor3 = TBDLib.Theme.DarkContrast
                    keybind.Label.TextColor3 = TBDLib.Theme.TextColor
                    keybind.Button.BackgroundColor3 = TBDLib.Theme.LightContrast
                    keybind.Button.TextColor3 = TBDLib.Theme.TextColor
                end
                
                table.insert(section.Elements, keybind)
                table.insert(tab.Elements, keybind)
                
                return keybind
            end
            
            -- Add a color picker
            function section:AddColorPicker(text, default, callback)
                local colorPicker = {}
                colorPicker.Text = text
                colorPicker.Default = default or Color3.fromRGB(255, 255, 255)
                colorPicker.Callback = callback or function() end
                colorPicker.Value = colorPicker.Default
                colorPicker.Open = false
                
                -- Color picker container
                colorPicker.Container = Utility:Create("Frame", {
                    Name = text .. "ColorPicker",
                    BackgroundColor3 = TBDLib.Theme.DarkContrast,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    Parent = section.Content
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = colorPicker.Container
                })
                
                -- Color picker label
                colorPicker.Label = Utility:Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -80, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = TBDLib.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = colorPicker.Container
                })
                
                -- Color display
                colorPicker.Display = Utility:Create("Frame", {
                    Name = "Display",
                    BackgroundColor3 = colorPicker.Value,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -70, 0.5, -10),
                    Size = UDim2.new(0, 60, 0, 20),
                    Parent = colorPicker.Container
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = colorPicker.Display
                })
                
                -- Color picker dropdown
                colorPicker.Dropdown = Utility:Create("Frame", {
                    Name = "Dropdown",
                    BackgroundColor3 = TBDLib.Theme.LightContrast,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, 4),
                    Size = UDim2.new(1, 0, 0, 0),
                    Visible = false,
                    ZIndex = 10,
                    Parent = colorPicker.Container
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = colorPicker.Dropdown
                })
                
                -- Color picker content
                colorPicker.Content = Utility:Create("Frame", {
                    Name = "Content",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 10,
                    Parent = colorPicker.Dropdown
                })
                
                -- H, S, V inputs
                local hsvInputs = {}
                local inputLabels = {"H", "S", "V"}
                
                for i, label in ipairs(inputLabels) do
                    local input = Utility:Create("Frame", {
                        Name = label .. "Input",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 10 + (i - 1) * 25),
                        Size = UDim2.new(1, -20, 0, 20),
                        ZIndex = 11,
                        Parent = colorPicker.Content
                    })
                    
                    Utility:Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(0, 20, 0, 20),
                        Font = Enum.Font.GothamBold,
                        Text = label,
                        TextColor3 = TBDLib.Theme.TextColor,
                        TextSize = 14,
                        ZIndex = 11,
                        Parent = input
                    })
                    
                    local inputBG = Utility:Create("Frame", {
                        Name = "InputBG",
                        BackgroundColor3 = TBDLib.Theme.DarkContrast,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 25, 0, 0),
                        Size = UDim2.new(1, -25, 1, 0),
                        ZIndex = 11,
                        Parent = input
                    })
                    
                    Utility:Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = inputBG
                    })
                    
                    local inputBox = Utility:Create("TextBox", {
                        Name = "InputBox",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 5, 0, 0),
                        Size = UDim2.new(1, -10, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = "0",
                        TextColor3 = TBDLib.Theme.TextColor,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 11,
                        Parent = inputBG
                    })
                    
                    table.insert(hsvInputs, {label = label, input = inputBox})
                end
                
                -- Color preview
                colorPicker.Preview = Utility:Create("Frame", {
                    Name = "Preview",
                    BackgroundColor3 = colorPicker.Value,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 95),
                    Size = UDim2.new(1, -20, 0, 40),
                    ZIndex = 11,
                    Parent = colorPicker.Content
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = colorPicker.Preview
                })
                
                -- Apply button
                colorPicker.ApplyButton = Utility:Create("TextButton", {
                    Name = "ApplyButton",
                    BackgroundColor3 = TBDLib.Theme.Accent,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 145),
                    Size = UDim2.new(1, -20, 0, 30),
                    Font = Enum.Font.GothamBold,
                    Text = "Apply",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    ZIndex = 11,
                    Parent = colorPicker.Content
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = colorPicker.ApplyButton
                })
                
                -- Button for toggling the picker
                colorPicker.Button = Utility:Create("TextButton", {
                    Name = "Button",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = colorPicker.Container
                })
                
                -- Convert RGB to HSV
                local function rgbToHsv(r, g, b)
                    r, g, b = r / 255, g / 255, b / 255
                    local max, min = math.max(r, g, b), math.min(r, g, b)
                    local h, s, v
                    v = max
                    
                    local d = max - min
                    if max == 0 then s = 0 else s = d / max end
                    
                    if max == min then
                        h = 0
                    else
                        if max == r then
                            h = (g - b) / d
                            if g < b then h = h + 6 end
                        elseif max == g then
                            h = (b - r) / d + 2
                        elseif max == b then
                            h = (r - g) / d + 4
                        end
                        h = h / 6
                    end
                    
                    return h * 360, s * 100, v * 100
                end
                
                -- Convert HSV to RGB
                local function hsvToRgb(h, s, v)
                    h, s, v = h / 360, s / 100, v / 100
                    local r, g, b
                    
                    if s == 0 then
                        r, g, b = v, v, v
                    else
                        local i = math.floor(h * 6)
                        local f = h * 6 - i
                        local p = v * (1 - s)
                        local q = v * (1 - f * s)
                        local t = v * (1 - (1 - f) * s)
                        
                        i = i % 6
                        
                        if i == 0 then r, g, b = v, t, p
                        elseif i == 1 then r, g, b = q, v, p
                        elseif i == 2 then r, g, b = p, v, t
                        elseif i == 3 then r, g, b = p, q, v
                        elseif i == 4 then r, g, b = t, p, v
                        elseif i == 5 then r, g, b = v, p, q
                        end
                    end
                    
                    return r * 255, g * 255, b * 255
                end
                
                -- Update displayed color
                function colorPicker:UpdateColor()
                    local h = tonumber(hsvInputs[1].input.Text) or 0
                    local s = tonumber(hsvInputs[2].input.Text) or 0
                    local v = tonumber(hsvInputs[3].input.Text) or 0
                    
                    h = math.clamp(h, 0, 360)
                    s = math.clamp(s, 0, 100)
                    v = math.clamp(v, 0, 100)
                    
                    hsvInputs[1].input.Text = tostring(math.floor(h))
                    hsvInputs[2].input.Text = tostring(math.floor(s))
                    hsvInputs[3].input.Text = tostring(math.floor(v))
                    
                    local r, g, b = hsvToRgb(h, s, v)
                    local color = Color3.fromRGB(r, g, b)
                    
                    colorPicker.Preview.BackgroundColor3 = color
                end
                
                -- Set a color
                function colorPicker:Set(color, updateInputs)
                    colorPicker.Value = color
                    colorPicker.Display.BackgroundColor3 = color
                    
                    if updateInputs then
                        local h, s, v = rgbToHsv(color.R * 255, color.G * 255, color.B * 255)
                        
                        hsvInputs[1].input.Text = tostring(math.floor(h))
                        hsvInputs[2].input.Text = tostring(math.floor(s))
                        hsvInputs[3].input.Text = tostring(math.floor(v))
                        
                        colorPicker.Preview.BackgroundColor3 = color
                    end
                    
                    TBDLib.Flags[colorPicker.Text] = color
                    
                    pcall(colorPicker.Callback, color)
                end
                
                -- Initialize with default color
                colorPicker:Set(colorPicker.Default, true)
                
                -- Toggle color picker dropdown
                function colorPicker:Toggle()
                    colorPicker.Open = not colorPicker.Open
                    
                    if colorPicker.Open then
                        Utility:PlaySound(SOUNDS.Open)
                        -- Resize dropdown
                        colorPicker.Dropdown.Size = UDim2.new(1, 0, 0, 185)
                        colorPicker.Dropdown.Visible = true
                        colorPicker.Container.ZIndex = 100
                    else
                        Utility:PlaySound(SOUNDS.Close)
                        -- Close dropdown
                        colorPicker.Dropdown.Size = UDim2.new(1, 0, 0, 0)
                        delay(0.2, function()
                            if not colorPicker.Open then
                                colorPicker.Dropdown.Visible = false
                                colorPicker.Container.ZIndex = 1
                            end
                        end)
                    end
                end
                
                -- Button click handler
                colorPicker.Button.MouseButton1Click:Connect(function()
                    colorPicker:Toggle()
                end)
                
                -- Apply button click handler
                colorPicker.ApplyButton.MouseButton1Click:Connect(function()
                    Utility:PlaySound(SOUNDS.Click)
                    colorPicker:Set(colorPicker.Preview.BackgroundColor3, false)
                    colorPicker:Toggle()
                end)
                
                -- Update preview on input changes
                for _, input in ipairs(hsvInputs) do
                    input.input.FocusLost:Connect(function()
                        colorPicker:UpdateColor()
                    end)
                end
                
                -- Button hover effect
                colorPicker.ApplyButton.MouseEnter:Connect(function()
                    Utility:PlaySound(SOUNDS.Hover)
                    Utility:Tween(colorPicker.ApplyButton, {BackgroundColor3 = Color3.fromRGB(255, 60, 60)}, 0.2)
                end)
                
                colorPicker.ApplyButton.MouseLeave:Connect(function()
                    Utility:Tween(colorPicker.ApplyButton, {BackgroundColor3 = TBDLib.Theme.Accent}, 0.2)
                end)
                
                -- Container hover effect
                colorPicker.Container.MouseEnter:Connect(function()
                    Utility:PlaySound(SOUNDS.Hover)
                    Utility:Tween(colorPicker.Container, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.2)
                end)
                
                colorPicker.Container.MouseLeave:Connect(function()
                    Utility:Tween(colorPicker.Container, {BackgroundColor3 = TBDLib.Theme.DarkContrast}, 0.2)
                end)
                
                function colorPicker:UpdateTheme()
                    colorPicker.Container.BackgroundColor3 = TBDLib.Theme.DarkContrast
                    colorPicker.Label.TextColor3 = TBDLib.Theme.TextColor
                    colorPicker.Dropdown.BackgroundColor3 = TBDLib.Theme.LightContrast
                    colorPicker.ApplyButton.BackgroundColor3 = TBDLib.Theme.Accent
                    
                    for _, input in ipairs(hsvInputs) do
                        input.input.TextColor3 = TBDLib.Theme.TextColor
                        input.input.Parent.BackgroundColor3 = TBDLib.Theme.DarkContrast
                    end
                end
                
                table.insert(section.Elements, colorPicker)
                table.insert(tab.Elements, colorPicker)
                
                return colorPicker
            end
            
            -- Add a label
            function section:AddLabel(text)
                local label = {}
                label.Text = text
                
                -- Label container
                label.Container = Utility:Create("Frame", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24),
                    Parent = section.Content
                })
                
                -- Label text
                label.Label = Utility:Create("TextLabel", {
                    Name = "Text",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = TBDLib.Theme.TextColor,
                    TextSize = 14,
                    TextWrapped = true,
                    Parent = label.Container
                })
                
                function label:UpdateTheme()
                    label.Label.TextColor3 = TBDLib.Theme.TextColor
                end
                
                function label:SetText(newText)
                    label.Text = newText
                    label.Label.Text = newText
                end
                
                table.insert(section.Elements, label)
                table.insert(tab.Elements, label)
                
                return label
            end
            
            -- Add a separator line
            function section:AddSeparator(color)
                local separator = {}
                separator.Color = color or TBDLib.Theme.Accent
                
                -- Separator container
                separator.Container = Utility:Create("Frame", {
                    Name = "Separator",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 12),
                    Parent = section.Content
                })
                
                -- Line
                separator.Line = Utility:Create("Frame", {
                    Name = "Line",
                    BackgroundColor3 = separator.Color,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.new(1, 0, 0, 1),
                    Parent = separator.Container
                })
                
                function separator:UpdateTheme()
                    separator.Line.BackgroundColor3 = TBDLib.Theme.Accent
                end
                
                function separator:SetColor(color)
                    separator.Color = color
                    separator.Line.BackgroundColor3 = color
                end
                
                table.insert(section.Elements, separator)
                table.insert(tab.Elements, separator)
                
                return separator
            end
            
            -- Add an image label
            function section:AddImage(imageId, size)
                local image = {}
                image.ImageId = imageId
                image.Size = size or UDim2.new(0, 100, 0, 100)
                
                -- Image container
                image.Container = Utility:Create("Frame", {
                    Name = "ImageContainer",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, image.Size.Y.Offset + 10),
                    Parent = section.Content
                })
                
                -- Image display
                image.Image = Utility:Create("ImageLabel", {
                    Name = "Image",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0, 5),
                    AnchorPoint = Vector2.new(0.5, 0),
                    Size = image.Size,
                    Image = imageId,
                    Parent = image.Container
                })
                
                function image:UpdateTheme()
                    -- No theme updates needed for image
                end
                
                function image:SetImage(newImageId)
                    image.ImageId = newImageId
                    image.Image.Image = newImageId
                end
                
                function image:Resize(newSize)
                    image.Size = newSize
                    image.Image.Size = newSize
                    image.Container.Size = UDim2.new(1, 0, 0, newSize.Y.Offset + 10)
                end
                
                table.insert(section.Elements, image)
                table.insert(tab.Elements, image)
                
                return image
            end
            
            table.insert(tab.Sections, section)
            
            return section
        end
        
        -- Event to run when tab is shown
        function tab:OnTabShown(callback)
            table.insert(tab.Events, callback)
        end
        
        table.insert(window.Tabs, tab)
        table.insert(window.TabButtons, tab.Button)
        
        return tab
    end
    
    -- Function to select a tab
    function window:SelectTab(tab)
        if window.ActiveTab == tab then return end
        
        -- Play sound
        Utility:PlaySound(SOUNDS.Click)
        
        -- Visual updates for previously active tab
        if window.ActiveTab then
            Utility:Tween(window.ActiveTab.ButtonBG, {BackgroundTransparency = 1}, 0.2)
            Utility:Tween(window.ActiveTab.Label, {TextTransparency = 0.5}, 0.2)
            Utility:Tween(window.ActiveTab.Indicator, {BackgroundTransparency = 1}, 0.2)
            window.ActiveTab.Indicator.Visible = false
            window.ActiveTab.Container.Visible = false
            
            if window.ActiveTab.Icon then
                Utility:Tween(window.ActiveTab.Icon, {ImageTransparency = 0.5}, 0.2)
            end
        end
        
        -- Activate the new tab
        window.ActiveTab = tab
        
        -- Update visual appearance
        Utility:Tween(tab.ButtonBG, {BackgroundTransparency = 0.8}, 0.2)
        Utility:Tween(tab.Label, {TextTransparency = 0}, 0.2)
        tab.Indicator.BackgroundTransparency = 1
        tab.Indicator.Visible = true
        Utility:Tween(tab.Indicator, {BackgroundTransparency = 0}, 0.2)
        
        if tab.Icon then
            Utility:Tween(tab.Icon, {ImageTransparency = 0}, 0.2)
        end
        
        tab.Container.Visible = true
        
        -- Apply a visual glitch effect (80s VHS aesthetics)
        Utility:CreateGlitchEffect(tab.Container, 0.3, 0.2)
        
        -- Run tab shown event callbacks
        for _, callback in ipairs(tab.Events) do
            pcall(callback)
        end
    end
    
    -- Destroy the window and clean up
    function window:Destroy()
        window.Main:Destroy()
        table.remove(TBDLib.Windows, table.find(TBDLib.Windows, window))
    end
    
    -- Add the window to the library's window list
    table.insert(TBDLib.Windows, window)
    
    -- Automatically select the first tab if available
    if #window.Tabs > 0 then
        window:SelectTab(window.Tabs[1])
    end
    
    -- Display a welcome notification
    TBDLib:Notify("TBD UI Library", "Welcome to TBD UI Library v" .. TBDLib.Version, 5)
    
    return window
end

-- Return the library
return TBDLib
