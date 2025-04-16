--[[
    TBD UI Library V13 Final (v5)
    A comprehensive UI library designed for Roblox script hubs and executors
    Version: 3.0.0-V13.5
    
    Debug: Fixed content visibility and layout issues
]]

local TBD = {
    Version = "3.0.0-V13.5",
    Windows = {},
    _initialized = false,
    _theme = nil
}

-- Services
local services = {
    UserInputService = nil,
    TweenService = nil,
    CoreGui = nil,
    Players = nil,
    RunService = nil,
    TextService = nil,
    HttpService = nil,
    ContextActionService = nil,
    GuiService = nil,
}

-- Debug Logs (will appear in Roblox output)
local DEBUG_MODE = false
local function debug_log(...)
    if DEBUG_MODE then
        print("[TBD UI Debug]", ...)
    end
end

-- Safe function to get services
local function GetService(serviceName)
    if services[serviceName] then
        return services[serviceName]
    end
    
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    
    if success and service then
        services[serviceName] = service
        return service
    end
    
    return nil
end

-- Initialize services
services.UserInputService = GetService("UserInputService")
services.TweenService = GetService("TweenService")
services.CoreGui = GetService("CoreGui")
services.Players = GetService("Players")
services.RunService = GetService("RunService")
services.TextService = GetService("TextService")
services.HttpService = GetService("HttpService")
services.ContextActionService = GetService("ContextActionService")
services.GuiService = GetService("GuiService")

-- Safe local player access
local LocalPlayer = nil
pcall(function()
    if services.Players and services.Players.LocalPlayer then
        LocalPlayer = services.Players.LocalPlayer
    end
end)

-- Safe function calling
local function SafeCall(func, ...)
    if typeof(func) == "function" then
        local success, result = pcall(func, ...)
        return success, result
    end
    return false, "Not a function"
end

-- Safe instance creation
local function Create(instanceType, properties)
    local success, instance = pcall(function()
        return Instance.new(instanceType)
    end)
    
    if success and instance then
        if properties then
            for prop, value in pairs(properties) do
                local propSuccess, propError = pcall(function()
                    instance[prop] = value
                end)
                if not propSuccess then
                    -- Handle type errors gracefully
                    if prop == "CornerRadius" and typeof(value) ~= "UDim" then
                        pcall(function()
                            instance[prop] = UDim.new(0, tonumber(value) or 0)
                        end)
                    elseif typeof(value) == "number" and (prop:find("Color") or prop:find("color")) then
                        pcall(function()
                            instance[prop] = Color3.fromRGB(value, value, value)
                        end)
                    end
                end
            end
        end
        return instance
    end
    
    -- Return nil if failed
    return nil
end

-- Helper function for tweening properties
local function CreateTween(instance, propertyTable, easingDirection, easingStyle, duration, delay, callback)
    if not instance or typeof(instance) ~= "Instance" then return end
    
    -- Create TweenInfo
    local tweenInfo = TweenInfo.new(
        duration or 0.2, 
        easingStyle or Enum.EasingStyle.Quad, 
        easingDirection or Enum.EasingDirection.Out,
        0, -- RepeatCount
        false, -- Reverses
        delay or 0 -- DelayTime
    )
    
    -- Create and play tween
    local tween = services.TweenService:Create(instance, tweenInfo, propertyTable)
    tween:Play()
    
    -- Connect to Completed event if callback provided
    if callback and typeof(callback) == "function" then
        tween.Completed:Connect(function()
            pcall(callback)
        end)
    end
    
    return tween
end

-- Safe text size calculation
local function GetTextSize(text, fontSize, font, constraints)
    local success, size = pcall(function()
        return services.TextService:GetTextSize(tostring(text), fontSize, font, constraints)
    end)
    
    if success then
        return size
    else
        -- Fallback text size calculation
        return Vector2.new(string.len(tostring(text)) * (fontSize / 2), fontSize)
    end
end

-- Safe table indexing and operations
local function SafeIndex(t, k)
    if t and typeof(t) == "table" then
        return t[k]
    end
    return nil
end

local function SafeNewIndex(t, k, v)
    if t and typeof(t) == "table" then
        t[k] = v
        return true
    end
    return false
end

local function ProtectTable(t)
    return setmetatable({}, {
        __index = function(_, k)
            return SafeIndex(t, k)
        end,
        __newindex = function(_, k, v)
            SafeNewIndex(t, k, v)
        end
    })
end

-- Safe string operations
local function SafeFormat(str, ...)
    local args = {...}
    local success, result = pcall(function()
        return string.format(str, unpack(args))
    end)
    
    if success then
        return result
    else
        -- Fallback format
        local result = str
        for i, v in ipairs(args) do
            result = string.gsub(result, "%%%d", tostring(v), 1)
        end
        return result
    end
end

local function SafeToString(value)
    if value == nil then
        return "nil"
    end
    
    local success, result = pcall(function()
        return tostring(value)
    end)
    
    if success then
        return result
    else
        return "Value could not be converted to string"
    end
end

-- Safe GUI parenting function with multiple fallbacks
local function SafeParent(gui, preferredParent)
    local success = false
    
    -- If preferred parent is provided, try it first
    if preferredParent then
        success = pcall(function()
            gui.Parent = preferredParent
            return true
        end)
        if success then return true end
    end
    
    -- Method 1: Try CoreGui direct parenting
    if not success then
        success = pcall(function()
            gui.Parent = services.CoreGui
            return true
        end)
    end
    
    -- Method 2: Try gethui() which is available in some executors
    if not success and type(gethui) == "function" then
        success = pcall(function()
            gui.Parent = gethui()
            return true
        end)
    end
    
    -- Method 3: Try CoreGui:FindFirstChild("RobloxGui")
    if not success then
        pcall(function()
            if services.CoreGui:FindFirstChild("RobloxGui") then
                gui.Parent = services.CoreGui:FindFirstChild("RobloxGui")
                success = true
            end
        end)
    end
    
    -- Method 4: Try PlayerGui if available
    if not success then
        pcall(function()
            if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
                gui.Parent = LocalPlayer.PlayerGui
                success = true
            end
        end)
    end
    
    -- Method 5: Last resort, parent to Workspace
    if not success then
        success = pcall(function()
            gui.Parent = workspace
            return true
        end)
    end
    
    return success
end

-- Safe touch event handling
local function ConnectTouchInput(obj, callback)
    local connection = nil
    
    -- Safely connect to input events
    pcall(function()
        connection = obj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or 
               input.UserInputType == Enum.UserInputType.MouseButton1 then
                pcall(callback, input)
            end
        end)
    end)
    
    -- If standard input connection failed, try alternative methods
    if not connection then
        pcall(function()
            connection = obj.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
        end)
    end
    
    return connection or {Disconnect = function() end}
end

-- Theme definitions
local Themes = {
    Default = {
        Primary = Color3.fromRGB(25, 25, 25),
        Secondary = Color3.fromRGB(30, 30, 30),
        Background = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(0, 120, 215),
        DarkAccent = Color3.fromRGB(0, 90, 165),
        TextPrimary = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(175, 175, 175),
        Success = Color3.fromRGB(50, 180, 100),
        Warning = Color3.fromRGB(240, 180, 50),
        Error = Color3.fromRGB(225, 60, 60)
    },
    Midnight = {
        Primary = Color3.fromRGB(30, 30, 45),
        Secondary = Color3.fromRGB(40, 40, 60),
        Background = Color3.fromRGB(25, 25, 35),
        Accent = Color3.fromRGB(120, 130, 240),
        DarkAccent = Color3.fromRGB(90, 100, 190),
        TextPrimary = Color3.fromRGB(240, 240, 245),
        TextSecondary = Color3.fromRGB(175, 175, 190),
        Success = Color3.fromRGB(70, 200, 120),
        Warning = Color3.fromRGB(240, 190, 70),
        Error = Color3.fromRGB(240, 80, 100)
    },
    Neon = {
        Primary = Color3.fromRGB(20, 20, 30),
        Secondary = Color3.fromRGB(30, 30, 40),
        Background = Color3.fromRGB(15, 15, 25),
        Accent = Color3.fromRGB(125, 70, 255),
        DarkAccent = Color3.fromRGB(95, 50, 195),
        TextPrimary = Color3.fromRGB(235, 235, 255),
        TextSecondary = Color3.fromRGB(165, 165, 190),
        Success = Color3.fromRGB(160, 255, 130),
        Warning = Color3.fromRGB(255, 230, 60),
        Error = Color3.fromRGB(255, 60, 140)
    },
    Aqua = {
        Primary = Color3.fromRGB(20, 25, 30),
        Secondary = Color3.fromRGB(30, 35, 40),
        Background = Color3.fromRGB(15, 20, 25),
        Accent = Color3.fromRGB(40, 180, 200),
        DarkAccent = Color3.fromRGB(30, 140, 160),
        TextPrimary = Color3.fromRGB(230, 240, 245),
        TextSecondary = Color3.fromRGB(160, 175, 190),
        Success = Color3.fromRGB(50, 200, 150),
        Warning = Color3.fromRGB(235, 190, 90),
        Error = Color3.fromRGB(230, 90, 100)
    },
    HoHo = {
        Primary = Color3.fromRGB(20, 20, 20),
        Secondary = Color3.fromRGB(15, 15, 15),
        Background = Color3.fromRGB(10, 10, 10),
        Accent = Color3.fromRGB(255, 30, 50),
        DarkAccent = Color3.fromRGB(200, 25, 45),
        TextPrimary = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(190, 190, 190),
        Success = Color3.fromRGB(40, 200, 90),
        Warning = Color3.fromRGB(255, 170, 30),
        Error = Color3.fromRGB(255, 60, 80)
    }
}

-- Default theme
TBD._theme = Themes.HoHo

-- Icon library (common universal icons)
local Icons = {
    home = "rbxassetid://7733960981",
    settings = "rbxassetid://7734053495",
    search = "rbxassetid://7734053495",
    alert = "rbxassetid://7733658133",
    close = "rbxassetid://7743878857",
    minimize = "rbxassetid://7743878556",
    script = "rbxassetid://7733964370",
    credit = "rbxassetid://7733960612",
    info = "rbxassetid://7734021302",
    game = "rbxassetid://7733969292",
    tool = "rbxassetid://7734043543",
    code = "rbxassetid://7733731769",
    rocket = "rbxassetid://7733731769",
    person = "rbxassetid://7733832999",
    lock = "rbxassetid://7733910824",
    globe = "rbxassetid://7733773739",
    plus = "rbxassetid://7733910163",
    minus = "rbxassetid://7733983929",
    shield = "rbxassetid://7734026828",
    clock = "rbxassetid://7734034344",
    menu = "rbxassetid://7734039200",
    palette = "rbxassetid://7733955304",
    heart = "rbxassetid://7734038872",
    list = "rbxassetid://7734033105"
}

-- Notification system
TBD.NotificationSystem = {
    Notifications = {},
    _position = "TopRight",
    _container = nil,
    
    Setup = function(self)
        -- Create notification container
        local gui = Create("ScreenGui", {
            Name = "TBDNotifications",
            DisplayOrder = 9999,
            ResetOnSpawn = false
        })
        
        -- Apply safe parenting with fallbacks
        SafeParent(gui)
        
        -- Create container frame
        local container = Create("Frame", {
            Name = "NotificationContainer",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -20, 0, 20),
            Size = UDim2.new(0, 280, 1, -40),
            AnchorPoint = Vector2.new(1, 0),
            Parent = gui
        })
        
        -- Setup list layout for notifications
        local listLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = container
        })
        
        self._container = container
        self.Gui = gui
        
        return self
    end,
    
    SetPosition = function(self, position)
        position = position or "TopRight"
        local container = self._container
        
        if container then
            -- Update container position and layout based on selected position
            if position == "TopRight" then
                container.Position = UDim2.new(1, -20, 0, 20)
                container.AnchorPoint = Vector2.new(1, 0)
                self:_updateListLayout("Top")
            elseif position == "TopLeft" then
                container.Position = UDim2.new(0, 20, 0, 20)
                container.AnchorPoint = Vector2.new(0, 0)
                self:_updateListLayout("Top")
            elseif position == "BottomRight" then
                container.Position = UDim2.new(1, -20, 1, -20)
                container.AnchorPoint = Vector2.new(1, 1)
                self:_updateListLayout("Bottom")
            elseif position == "BottomLeft" then
                container.Position = UDim2.new(0, 20, 1, -20)
                container.AnchorPoint = Vector2.new(0, 1)
                self:_updateListLayout("Bottom")
            end
            
            self._position = position
        end
        
        return self
    end,
    
    _updateListLayout = function(self, vertAlign)
        local container = self._container
        if container then
            local listLayout = container:FindFirstChildOfClass("UIListLayout")
            if listLayout then
                listLayout.VerticalAlignment = (vertAlign == "Top") 
                    and Enum.VerticalAlignment.Top 
                    or Enum.VerticalAlignment.Bottom
            end
        end
    end,
    
    CreateNotification = function(self, options)
        local theme = TBD._theme
        local title = options.Title or "Notification"
        local message = options.Message or ""
        local duration = options.Duration or 3
        local type = options.Type or "Info"
        local callback = options.Callback
        
        local typeColors = {
            Info = theme.Accent,
            Success = theme.Success,
            Warning = theme.Warning,
            Error = theme.Error
        }
        
        local typeColor = typeColors[type] or theme.Accent
        
        -- Create notification frame
        local notification = Create("Frame", {
            Name = "Notification",
            BackgroundColor3 = theme.Secondary,
            Size = UDim2.new(1, 0, 0, 0), -- Will be updated after calculating content size
            ClipsDescendants = true,
            BackgroundTransparency = 0,
            Parent = self._container
        })
        
        -- Add corner radius
        local corner = Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = notification
        })
        
        -- Add border accent for notification type
        local accent = Create("Frame", {
            Name = "Accent",
            BackgroundColor3 = typeColor,
            Size = UDim2.new(0, 4, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Parent = notification
        })
        
        -- Add corner to accent
        local accentCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = accent
        })
        
        -- Create title
        local titleLabel = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 10),
            Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = theme.TextPrimary,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = notification
        })
        
        -- Create message
        local messageLabel = Create("TextLabel", {
            Name = "Message",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 32),
            Size = UDim2.new(1, -20, 0, 0), -- Height will be updated based on text
            Font = Enum.Font.Gotham,
            Text = message,
            TextColor3 = theme.TextSecondary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Parent = notification
        })
        
        -- Calculate text height
        local textSize = GetTextSize(message, 14, Enum.Font.Gotham, Vector2.new(notification.AbsoluteSize.X - 20, 1000))
        local textHeight = textSize.Y
        
        -- Update message label height
        messageLabel.Size = UDim2.new(1, -20, 0, textHeight)
        
        -- Update notification height
        notification.Size = UDim2.new(1, 0, 0, 42 + textHeight)
        
        -- Create close button
        local closeButton = Create("ImageButton", {
            Name = "CloseButton",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -20, 0, 10),
            Size = UDim2.new(0, 16, 0, 16),
            Image = "rbxassetid://7743878857",
            ImageColor3 = theme.TextSecondary,
            Parent = notification
        })
        
        -- Add click event
        closeButton.MouseButton1Click:Connect(function()
            -- Close notification
            CreateTween(
                notification,
                {Size = UDim2.new(1, 0, 0, 0)},
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.2,
                0,
                function()
                    notification:Destroy()
                end
            )
        end)
        
        -- Add hover effect
        closeButton.MouseEnter:Connect(function()
            closeButton.ImageColor3 = theme.TextPrimary
        end)
        
        closeButton.MouseLeave:Connect(function()
            closeButton.ImageColor3 = theme.TextSecondary
        end)
        
        -- Add click callback
        notification.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if callback then
                    SafeCall(callback)
                end
            end
        end)
        
        -- Add hover effect
        notification.MouseEnter:Connect(function()
            -- Change background color slightly
            CreateTween(
                notification,
                {BackgroundColor3 = theme.Secondary:Lerp(theme.Primary, 0.5)},
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.2
            )
        end)
        
        notification.MouseLeave:Connect(function()
            -- Restore background color
            CreateTween(
                notification,
                {BackgroundColor3 = theme.Secondary},
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.2
            )
        end)
        
        -- Auto close
        task.delay(duration, function()
            -- If notification still exists, close it
            if notification and notification.Parent then
                CreateTween(
                    notification,
                    {Size = UDim2.new(1, 0, 0, 0)},
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2,
                    0,
                    function()
                        if notification and notification.Parent then
                            notification:Destroy()
                        end
                    end
                )
            end
        end)
        
        return self
    end
}

-- Loading screen
TBD.LoadingScreen = {
    Create = function(self, options)
        options = options or {}
        local title = options.Title or "Loading"
        local subtitle = options.Subtitle or "Please wait..."
        local logoId = options.LogoId
        
        local loadingScreenObj = {}
        
        -- Create GUI
        local screenGui = Create("ScreenGui", {
            Name = "TBDLoadingScreen",
            DisplayOrder = 10000,
            ResetOnSpawn = false
        })
        
        -- Apply safe parenting with fallbacks
        SafeParent(screenGui)
        
        -- Create background
        local background = Create("Frame", {
            Name = "Background",
            BackgroundColor3 = TBD._theme.Background,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = screenGui
        })
        
        -- Create container
        local container = Create("Frame", {
            Name = "Container",
            BackgroundColor3 = TBD._theme.Primary,
            Size = UDim2.new(0, 400, 0, 200),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Parent = background
        })
        
        -- Add corner radius
        local containerCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 10),
            Parent = container
        })
        
        -- Add logo if provided
        local logoHeight = 0
        local logo = nil
        if logoId then
            logo = Create("ImageLabel", {
                Name = "Logo",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 80, 0, 80),
                Position = UDim2.new(0.5, 0, 0, 20),
                AnchorPoint = Vector2.new(0.5, 0),
                Image = logoId,
                Parent = container
            })
            
            logoHeight = 90 -- Logo height + padding
        end
        
        -- Add title
        local titleLabel = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 0, 30),
            Position = UDim2.new(0, 20, 0, 20 + logoHeight),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = TBD._theme.TextPrimary,
            TextSize = 24,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = container
        })
        
        -- Add subtitle
        local subtitleLabel = Create("TextLabel", {
            Name = "Subtitle",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 0, 20),
            Position = UDim2.new(0, 20, 0, 55 + logoHeight),
            Font = Enum.Font.Gotham,
            Text = subtitle,
            TextColor3 = TBD._theme.TextSecondary,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = container
        })
        
        -- Add progress bar background
        local progressBarBackground = Create("Frame", {
            Name = "ProgressBarBackground",
            BackgroundColor3 = TBD._theme.Secondary,
            Size = UDim2.new(1, -40, 0, 10),
            Position = UDim2.new(0, 20, 0, 90 + logoHeight),
            Parent = container
        })
        
        -- Add corner radius to progress bar background
        local progressBarBackgroundCorner = Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = progressBarBackground
        })
        
        -- Add progress bar fill
        local progressBarFill = Create("Frame", {
            Name = "ProgressBarFill",
            BackgroundColor3 = TBD._theme.Accent,
            Size = UDim2.new(0, 0, 1, 0),
            Parent = progressBarBackground
        })
        
        -- Add corner radius to progress bar fill
        local progressBarFillCorner = Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = progressBarFill
        })
        
        -- Add progress percentage
        local progressPercent = Create("TextLabel", {
            Name = "ProgressPercent",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 0, 20),
            Position = UDim2.new(0, 20, 0, 105 + logoHeight),
            Font = Enum.Font.Gotham,
            Text = "0%",
            TextColor3 = TBD._theme.TextSecondary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = container
        })
        
        -- Store objects
        loadingScreenObj._screenGui = screenGui
        loadingScreenObj._background = background
        loadingScreenObj._container = container
        loadingScreenObj._titleLabel = titleLabel
        loadingScreenObj._subtitleLabel = subtitleLabel
        loadingScreenObj._progressBarFill = progressBarFill
        loadingScreenObj._progressPercent = progressPercent
        loadingScreenObj._logo = logo
        
        -- Update progress
        function loadingScreenObj:UpdateProgress(progress)
            progress = math.clamp(progress, 0, 1)
            
            -- Update progress bar fill
            self._progressBarFill:TweenSize(
                UDim2.new(progress, 0, 1, 0),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.2,
                true
            )
            
            -- Update progress percentage
            self._progressPercent.Text = math.floor(progress * 100) .. "%"
        end
        
        -- Update title
        function loadingScreenObj:UpdateTitle(newTitle)
            self._titleLabel.Text = newTitle
        end
        
        -- Update subtitle
        function loadingScreenObj:UpdateSubtitle(newSubtitle)
            self._subtitleLabel.Text = newSubtitle
        end
        
        -- Finish with proper property handling for each instance type
        function loadingScreenObj:Finish(callback)
            -- Fade out
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            -- Create tween for background
            local backgroundTween = services.TweenService:Create(self._background, tweenInfo, {
                BackgroundTransparency = 1
            })
            
            -- Create tween for container
            local containerTween = services.TweenService:Create(self._container, tweenInfo, {
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0.6, 0)
            })
            
            -- Fade out all elements with proper property handling for each type
            for _, element in pairs(self._container:GetDescendants()) do
                if element:IsA("TextLabel") then
                    -- For text labels, tween text transparency
                    services.TweenService:Create(element, tweenInfo, {
                        TextTransparency = 1,
                        TextStrokeTransparency = 1
                    }):Play()
                elseif element:IsA("ImageLabel") or element:IsA("ImageButton") then
                    -- For image elements, tween image transparency
                    services.TweenService:Create(element, tweenInfo, {
                        ImageTransparency = 1
                    }):Play()
                elseif element:IsA("Frame") and not element.Name:find("Background") then
                    -- For frames, tween background transparency
                    services.TweenService:Create(element, tweenInfo, {
                        BackgroundTransparency = 1
                    }):Play()
                end
            end
            
            -- Play main tweens
            backgroundTween:Play()
            containerTween:Play()
            
            -- Wait for tweens to finish then destroy
            task.delay(0.6, function()
                -- Safely destroy the screen GUI
                pcall(function()
                    if self._screenGui and self._screenGui.Parent then
                        self._screenGui:Destroy()
                    end
                end)
                
                -- Call callback if provided
                if callback then
                    SafeCall(callback)
                end
            end)
        end
        
        return loadingScreenObj
    end
}

-- Ensure initialized before using
function TBD:_EnsureInitialized()
    if self._initialized then
        return self
    end
    
    -- Initialize notification system
    self.NotificationSystem:Setup()
    
    self._initialized = true
    return self
end

-- Apply theme
function TBD:ApplyTheme(themeName)
    local theme = Themes[themeName]
    if theme then
        self._theme = theme
        
        -- Update all windows
        for _, window in ipairs(self.Windows) do
            window:_updateTheme()
        end
    end
    
    return self
end

-- Custom theme
function TBD:CustomTheme(colors)
    if not colors then return self end
    
    local newTheme = {}
    for k, v in pairs(self._theme) do
        newTheme[k] = colors[k] or v
    end
    
    self._theme = newTheme
    
    -- Update all windows
    for _, window in ipairs(self.Windows) do
        window:_updateTheme()
    end
    
    return self
end

-- Create window
function TBD:CreateWindow(options)
    self:_EnsureInitialized()
    
    options = options or {}
    options.Title = options.Title or "TBD UI Library"
    options.Subtitle = options.Subtitle or ""
    options.Size = options.Size or 550
    options.Theme = options.Theme or "HoHo"
    options.MinimizeKey = options.MinimizeKey or Enum.KeyCode.RightShift
    options.ShowHomePage = options.ShowHomePage ~= false
    
    -- Apply theme
    self:ApplyTheme(options.Theme)
    
    -- Create window object
    local windowObj = {
        Window = nil,
        Header = nil,
        ContentContainer = nil,
        Tabs = {},
        ActiveTab = nil,
        Size = options.Size,
        MinimizeKey = options.MinimizeKey,
        IsMinimized = false,
        _theme = self._theme
    }
    
    -- Initialize window UI
    local screenGui = Create("ScreenGui", {
        Name = "TBDWindowGui",
        DisplayOrder = 100,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Apply safe parenting with fallbacks
    SafeParent(screenGui)
    
    -- Create main window frame
    local window = Create("Frame", {
        Name = "Window",
        BackgroundColor3 = windowObj._theme.Background,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, options.Size, 0, 400),
        ClipsDescendants = true,
        Active = true,
        Parent = screenGui
    })
    
    -- Add corner radius
    local windowCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = window
    })
    
    -- Store the window in windowObj
    windowObj.Window = window
    
    -- Ensure window stays within screen bounds
    local function updateWindowBounds()
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local windowPos = window.AbsolutePosition
        local windowSize = window.AbsoluteSize
        
        -- Ensure the window is always accessible
        local minVisibleSize = 50 -- Minimum visible portion of window
        
        -- Calculate bounds
        local minX = -windowSize.X + minVisibleSize
        local maxX = viewportSize.X - minVisibleSize
        local minY = 0
        local maxY = viewportSize.Y - minVisibleSize
        
        -- Check if window is outside bounds
        local newX = math.clamp(windowPos.X, minX, maxX)
        local newY = math.clamp(windowPos.Y, minY, maxY)
        
        -- If position needs updating
        if newX ~= windowPos.X or newY ~= windowPos.Y then
            window.Position = UDim2.new(0, newX, 0, newY)
            window.AnchorPoint = Vector2.new(0, 0)
        end
    end
    
    -- Create header
    local header = Create("Frame", {
        Name = "Header",
        BackgroundColor3 = windowObj._theme.Primary,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = window
    })
    
    -- Store header in windowObj
    windowObj.Header = header
    
    -- Add corner radius to header
    local headerCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = header
    })
    
    -- Create cover to fix corner radius overlap
    local headerCover = Create("Frame", {
        Name = "Cover",
        BackgroundColor3 = windowObj._theme.Primary,
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BorderSizePixel = 0,
        Parent = header
    })
    
    -- Create drag functionality
    local isDragging = false
    local dragStart = nil
    local startPos = nil
    local dragInput = nil
    
    local function updateDrag(input)
        if not isDragging then return end
        
        local delta = input.Position - dragStart
        
        -- Calculate new position
        local newPosition = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        
        -- Apply new position with tweening for smooth feel
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        services.TweenService:Create(window, tweenInfo, {Position = newPosition}):Play()
    end
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = window.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                    updateWindowBounds()
                end
            end)
        end
    end)
    
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    services.UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and isDragging then
            updateDrag(input)
        end
    end)
    
    services.UserInputService.TouchMoved:Connect(function(touch, gameProcessed)
        if isDragging then
            updateDrag(touch)
        end
    end)
    
    -- Title text
    local title = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 8),
        Size = UDim2.new(0.7, 0, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = options.Title,
        TextColor3 = windowObj._theme.TextPrimary,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    -- Subtitle text
    local subtitle = Create("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 17, 0, 27),
        Size = UDim2.new(0.7, 0, 0, 20),
        Font = Enum.Font.Gotham,
        Text = options.Subtitle,
        TextColor3 = windowObj._theme.TextSecondary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    -- Close button
    local closeButton = Create("ImageButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -35, 0, 10),
        Size = UDim2.new(0, 20, 0, 20),
        Image = Icons.close,
        ImageColor3 = Color3.fromRGB(200, 200, 200), -- More visible gray
        Parent = header
    })
    
    -- Minimize button - Now more visible
    local minimizeButton = Create("ImageButton", {
        Name = "MinimizeButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -65, 0, 10),
        Size = UDim2.new(0, 20, 0, 20),
        Image = Icons.minimize,
        ImageColor3 = Color3.fromRGB(200, 200, 200), -- Same as close button for consistency
        Parent = header
    })
    
    -- Close button events
    closeButton.MouseEnter:Connect(function()
        closeButton.ImageColor3 = windowObj._theme.Error
    end)
    
    closeButton.MouseLeave:Connect(function()
        closeButton.ImageColor3 = Color3.fromRGB(200, 200, 200)
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Minimize functionality
    local function toggleMinimize()
        windowObj.IsMinimized = not windowObj.IsMinimized
        
        if windowObj.IsMinimized then
            -- Minimize window
            window:TweenSize(
                UDim2.new(0, options.Size, 0, 40),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.3,
                true
            )
        else
            -- Restore window
            window:TweenSize(
                UDim2.new(0, options.Size, 0, 400),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.3,
                true
            )
        end
    end
    
    -- Minimize button events
    minimizeButton.MouseEnter:Connect(function()
        minimizeButton.ImageColor3 = windowObj._theme.Accent
    end)
    
    minimizeButton.MouseLeave:Connect(function()
        minimizeButton.ImageColor3 = Color3.fromRGB(200, 200, 200)
    end)
    
    minimizeButton.MouseButton1Click:Connect(toggleMinimize)
    
    -- Add global keybind for minimizing
    services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == options.MinimizeKey then
            toggleMinimize()
        end
    end)
    
    -- Create content container
    local contentContainer = Create("Frame", {
        Name = "ContentContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 1, -40),
        Parent = window
    })
    
    -- Store content container in windowObj
    windowObj.ContentContainer = contentContainer
    
    -- Create sidebar
    local sidebar = Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = windowObj._theme.Primary,
        Size = UDim2.new(0, 50, 1, 0),
        Parent = contentContainer
    })
    
    -- Add corner radius to sidebar
    local sidebarCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = sidebar
    })
    
    -- Create cover to fix corner radius overlap
    local sidebarCover = Create("Frame", {
        Name = "Cover",
        BackgroundColor3 = windowObj._theme.Primary,
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BorderSizePixel = 0,
        Parent = sidebar
    })
    
    -- Create tab button container
    local tabButtonContainer = Create("Frame", {
        Name = "TabButtonContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -50), -- Reserve space for home button
        Position = UDim2.new(0, 0, 0, 50),
        Parent = sidebar
    })
    
    -- Create tab button list layout
    local tabButtonLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 15),
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabButtonContainer
    })
    
    -- Create home button
    local homeButton = Create("ImageButton", {
        Name = "HomeButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 15),
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(0, 25, 0, 25),
        Image = Icons.home,
        ImageColor3 = windowObj._theme.Accent,
        Parent = sidebar
    })
    
    -- Create content section
    local content = Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 60, 0, 10),
        Size = UDim2.new(1, -70, 1, -20),
        Parent = contentContainer
    })
    
    -- DEBUG: Add diagnostic frame to ensure content frame is visible
    local diagnosticFrame = Create("Frame", {
        Name = "DiagnosticBorder",
        BackgroundTransparency = 0.8,
        BackgroundColor3 = Color3.fromRGB(0, 255, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 2,
        BorderColor3 = Color3.fromRGB(0, 255, 0),
        Parent = content
    })
    
    -- Create tabs table to store tabs
    windowObj.Tabs = {}
    
    -- Create home page
    if options.ShowHomePage then
        local homePageFrame = Create("Frame", {
            Name = "HomePage",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Visible = true, -- Start with HomePage visible
            ZIndex = 2,
            Parent = content
        })
        
        -- Home page title
        local homePageTitle = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 40),
            Font = Enum.Font.GothamBold,
            Text = "TBD UI Library V13",
            TextColor3 = windowObj._theme.TextPrimary,
            TextSize = 22,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = homePageFrame
        })
        
        -- Player info
        local playerInfoFrame = Create("Frame", {
            Name = "PlayerInfo",
            BackgroundColor3 = windowObj._theme.Primary,
            Size = UDim2.new(1, 0, 0, 80),
            Position = UDim2.new(0, 0, 0, 50),
            Parent = homePageFrame
        })
        
        -- Add corner radius
        local playerInfoCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 10),
            Parent = playerInfoFrame
        })
        
        -- Try to get player info
        local playerName = "Player"
        local playerDisplayName = "Player"
        local playerAvatar = "rbxassetid://7733658133" -- Default avatar
        
        pcall(function()
            if LocalPlayer then
                playerName = LocalPlayer.Name
                playerDisplayName = LocalPlayer.DisplayName
                
                -- Try to get player avatar
                pcall(function()
                    playerAvatar = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=60&h=60"
                end)
            end
        end)
        
        -- Player avatar
        local playerAvatarImage = Create("ImageLabel", {
            Name = "Avatar",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 60, 0, 60),
            Position = UDim2.new(0, 10, 0, 10),
            Image = playerAvatar,
            Parent = playerInfoFrame
        })
        
        -- Add corner radius to avatar
        local playerAvatarCorner = Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = playerAvatarImage
        })
        
        -- Player name
        local playerNameLabel = Create("TextLabel", {
            Name = "PlayerName",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -90, 0, 25),
            Position = UDim2.new(0, 80, 0, 15),
            Font = Enum.Font.GothamBold,
            Text = playerDisplayName,
            TextColor3 = windowObj._theme.TextPrimary,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = playerInfoFrame
        })
        
        -- Player username
        local playerUsernameLabel = Create("TextLabel", {
            Name = "PlayerUsername",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -90, 0, 20),
            Position = UDim2.new(0, 80, 0, 40),
            Font = Enum.Font.Gotham,
            Text = "@" .. playerName,
            TextColor3 = windowObj._theme.TextSecondary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = playerInfoFrame
        })
        
        -- Game info
        local gameInfoFrame = Create("Frame", {
            Name = "GameInfo",
            BackgroundColor3 = windowObj._theme.Primary,
            Size = UDim2.new(1, 0, 0, 80),
            Position = UDim2.new(0, 0, 0, 140),
            Parent = homePageFrame
        })
        
        -- Add corner radius
        local gameInfoCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 10),
            Parent = gameInfoFrame
        })
        
        -- Try to get game info
        local gameName = "Game"
        local placeId = 0
        
        pcall(function()
            placeId = game.PlaceId
            
            -- Try to get game name
            pcall(function()
                local success, info = pcall(function()
                    return game:GetService("MarketplaceService"):GetProductInfo(placeId)
                end)
                
                if success and info then
                    gameName = info.Name
                end
            end)
        end)
        
        -- Game icon
        local gameIconImage = Create("ImageLabel", {
            Name = "GameIcon",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 60, 0, 60),
            Position = UDim2.new(0, 10, 0, 10),
            Image = "rbxassetid://7733969292",
            Parent = gameInfoFrame
        })
        
        -- Game name
        local gameNameLabel = Create("TextLabel", {
            Name = "GameName",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -90, 0, 25),
            Position = UDim2.new(0, 80, 0, 15),
            Font = Enum.Font.GothamBold,
            Text = gameName,
            TextColor3 = windowObj._theme.TextPrimary,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = gameInfoFrame
        })
        
        -- Game ID
        local gameIdLabel = Create("TextLabel", {
            Name = "GameId",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -90, 0, 20),
            Position = UDim2.new(0, 80, 0, 40),
            Font = Enum.Font.Gotham,
            Text = "ID: " .. placeId,
            TextColor3 = windowObj._theme.TextSecondary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = gameInfoFrame
        })
        
        -- Store home page
        windowObj.Tabs["HomePage"] = {
            Frame = homePageFrame,
            Button = homeButton,
            Name = "HomePage"
        }
        
        -- Home button events
        homeButton.MouseEnter:Connect(function()
            if windowObj.ActiveTab ~= "HomePage" then
                homeButton.ImageColor3 = windowObj._theme.TextPrimary
            end
        end)
        
        homeButton.MouseLeave:Connect(function()
            if windowObj.ActiveTab ~= "HomePage" then
                homeButton.ImageColor3 = windowObj._theme.TextSecondary
            end
        end)
        
        homeButton.MouseButton1Click:Connect(function()
            windowObj:SetActiveTab("HomePage")
        end)

        -- Set HomePage as active tab initially
        windowObj.ActiveTab = "HomePage"
        debug_log("HomePage created and set as active")
    end
    
    -- Function to set active tab
    function windowObj:SetActiveTab(tabName)
        debug_log("Switching to tab:", tabName)
        
        -- If no tab name provided, use the first available
        if not tabName then
            for name, _ in pairs(self.Tabs) do
                tabName = name
                break
            end
            
            -- If still no tab name, return
            if not tabName then
                debug_log("No tabs found to set active")
                return
            end
        end
        
        -- Hide all tabs first
        for name, tab in pairs(self.Tabs) do
            if tab and tab.Frame then
                tab.Frame.Visible = false
                
                -- Update button color
                if name == "HomePage" then
                    if homeButton then
                        homeButton.ImageColor3 = windowObj._theme.TextSecondary
                    end
                elseif tab.Button then
                    tab.Button.ImageColor3 = windowObj._theme.TextSecondary
                end
            end
        end
        
        -- Set active tab
        self.ActiveTab = tabName
        debug_log("Active tab set to:", tabName)
        
        -- Show the active tab
        if tabName and self.Tabs[tabName] then
            debug_log("Showing tab:", tabName)
            
            if self.Tabs[tabName].Frame then
                self.Tabs[tabName].Frame.Visible = true
                
                -- Bring to front
                self.Tabs[tabName].Frame.ZIndex = 10
            end
            
            -- Update button color
            if tabName == "HomePage" then
                if homeButton then
                    homeButton.ImageColor3 = windowObj._theme.Accent
                end
            elseif self.Tabs[tabName].Button then
                self.Tabs[tabName].Button.ImageColor3 = windowObj._theme.Accent
            end
        else
            debug_log("Tab not found:", tabName)
        end
    end
    
    -- Function to minimize window programmatically
    function windowObj:Minimize()
        toggleMinimize()
    end
    
    -- Function to create a tab
    function windowObj:CreateTab(options)
        options = options or {}
        options.Name = options.Name or "Tab"
        options.Icon = options.Icon or "home"
        
        debug_log("Creating tab:", options.Name)
        
        -- Get icon
        local iconId = Icons[options.Icon] or options.Icon
        
        -- Tab button
        local tabButton = Create("ImageButton", {
            Name = options.Name .. "Button",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 25, 0, 25),
            Image = iconId,
            ImageColor3 = windowObj._theme.TextSecondary,
            Parent = tabButtonContainer
        })
        
        -- Add tooltip
        local tabTooltip = Create("Frame", {
            Name = "Tooltip",
            BackgroundColor3 = windowObj._theme.Primary,
            Position = UDim2.new(1, 5, 0, 0),
            Size = UDim2.new(0, 0, 0, 30),
            Visible = false,
            ZIndex = 100,
            Parent = tabButton
        })
        
        -- Add corner radius
        local tabTooltipCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = tabTooltip
        })
        
        -- Add tooltip text
        local tabTooltipText = Create("TextLabel", {
            Name = "Text",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 5, 0, 0),
            Font = Enum.Font.Gotham,
            Text = options.Name,
            TextColor3 = windowObj._theme.TextPrimary,
            TextSize = 14,
            ZIndex = 101,
            Parent = tabTooltip
        })
        
        -- Tab content frame (non-scrolling container)
        local tabContent = Create("Frame", {
            Name = options.Name .. "Content",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = content
        })
        
        -- Tab page (scrolling frame inside content)
        local tabPage = Create("ScrollingFrame", {
            Name = options.Name .. "Page",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = windowObj._theme.Accent,
            BorderSizePixel = 0,
            Parent = tabContent
        })
        
        -- Add padding to tab page
        local tabPagePadding = Create("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
            Parent = tabPage
        })
        
        -- Add list layout
        local tabPageLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = tabPage
        })
        
        -- Update canvas size when children change
        tabPageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabPage.CanvasSize = UDim2.new(0, 0, 0, tabPageLayout.AbsoluteContentSize.Y + 10)
        end)
        
        -- Show tooltip on hover
        tabButton.MouseEnter:Connect(function()
            -- Calculate tooltip width based on text
            local textSize = GetTextSize(options.Name, 14, Enum.Font.Gotham, Vector2.new(1000, 30))
            tabTooltip.Size = UDim2.new(0, textSize.X + 15, 0, 30)
            
            tabTooltip.Visible = true
        end)
        
        tabButton.MouseLeave:Connect(function()
            tabTooltip.Visible = false
        end)
        
        -- Set tab button action
        tabButton.MouseButton1Click:Connect(function()
            windowObj:SetActiveTab(options.Name)
        end)
        
        -- Create tab object
        local tab = {
            Button = tabButton,
            Content = tabContent,
            Page = tabPage,
            Elements = {},
            Name = options.Name
        }
        
        -- Store tab in window
        windowObj.Tabs[options.Name] = tab
        debug_log("Tab created:", options.Name)
        
        -- If it's the first non-homepage tab, make it active if HomePage is not showing
        if (not windowObj.ActiveTab or windowObj.ActiveTab == "HomePage") and not options.ShowHomePage then
            debug_log("First tab - setting active:", options.Name)
            windowObj:SetActiveTab(options.Name)
        end
        
        -- Create UI elements
        function tab:CreateButton(options)
            options = options or {}
            options.Name = options.Name or "Button"
            options.Callback = options.Callback or function() end
            
            debug_log("Creating button:", options.Name)
            
            -- Create button container
            local button = Create("Frame", {
                Name = "Button",
                BackgroundColor3 = windowObj._theme.Primary,
                Size = UDim2.new(1, 0, 0, 40),
                BorderSizePixel = 0,
                Parent = self.Page
            })
            
            -- Add corner radius
            local buttonCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = button
            })
            
            -- Add button label
            local buttonLabel = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = options.Name,
                TextColor3 = windowObj._theme.TextPrimary,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = button
            })
            
            -- Add button functionality
            local buttonClickArea = Create("TextButton", {
                Name = "ClickArea",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.SourceSans,
                Text = "",
                TextColor3 = Color3.fromRGB(0, 0, 0),
                TextSize = 1,
                Parent = button
            })
            
            -- Button click event
            buttonClickArea.MouseButton1Click:Connect(function()
                -- Visual feedback
                local originalColor = button.BackgroundColor3
                
                -- Create ripple effect
                button.BackgroundColor3 = originalColor:Lerp(windowObj._theme.Accent, 0.2)
                
                task.delay(0.2, function()
                    -- Restore original color
                    button.BackgroundColor3 = originalColor
                end)
                
                -- Call callback
                debug_log("Button clicked:", options.Name)
                SafeCall(options.Callback)
            end)
            
            -- Hover effects
            buttonClickArea.MouseEnter:Connect(function()
                CreateTween(
                    button,
                    {BackgroundColor3 = windowObj._theme.Primary:Lerp(windowObj._theme.Accent, 0.1)},
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2
                )
            end)
            
            buttonClickArea.MouseLeave:Connect(function()
                CreateTween(
                    button,
                    {BackgroundColor3 = windowObj._theme.Primary},
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2
                )
            end)
            
            -- Store button object
            local buttonObj = {
                Frame = button,
                Label = buttonLabel,
                
                -- Set button text
                Set = function(self, newText)
                    buttonLabel.Text = newText
                end
            }
            
            table.insert(self.Elements, buttonObj)
            return buttonObj
        end
        
        -- Create toggle
        function tab:CreateToggle(options)
            options = options or {}
            options.Name = options.Name or "Toggle"
            options.Default = options.Default or false
            options.Callback = options.Callback or function() end
            
            debug_log("Creating toggle:", options.Name)
            
            -- Create toggle container
            local toggle = Create("Frame", {
                Name = "Toggle",
                BackgroundColor3 = windowObj._theme.Primary,
                Size = UDim2.new(1, 0, 0, 40),
                BorderSizePixel = 0,
                Parent = self.Page
            })
            
            -- Add corner radius
            local toggleCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = toggle
            })
            
            -- Add toggle label
            local toggleLabel = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = options.Name,
                TextColor3 = windowObj._theme.TextPrimary,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggle
            })
            
            -- Add toggle background
            local toggleBackground = Create("Frame", {
                Name = "Background",
                BackgroundColor3 = options.Default and windowObj._theme.Accent or windowObj._theme.Secondary,
                Position = UDim2.new(1, -50, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 40, 0, 20),
                BorderSizePixel = 0,
                Parent = toggle
            })
            
            -- Add corner radius
            local toggleBackgroundCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggleBackground
            })
            
            -- Add toggle indicator
            local toggleIndicator = Create("Frame", {
                Name = "Indicator",
                BackgroundColor3 = options.Default and Color3.fromRGB(255, 255, 255) or windowObj._theme.TextSecondary,
                Position = UDim2.new(options.Default and 1 or 0, options.Default and -18 or 2, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 16, 0, 16),
                Parent = toggleBackground
            })
            
            -- Add corner radius
            local toggleIndicatorCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggleIndicator
            })
            
            -- Add toggle functionality
            local toggleClickArea = Create("TextButton", {
                Name = "ClickArea",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.SourceSans,
                Text = "",
                TextColor3 = Color3.fromRGB(0, 0, 0),
                TextSize = 1,
                Parent = toggle
            })
            
            -- Toggle state
            local isToggled = options.Default
            
            -- Toggle click event
            toggleClickArea.MouseButton1Click:Connect(function()
                -- Update state
                isToggled = not isToggled
                
                -- Update visuals
                if isToggled then
                    toggleBackground.BackgroundColor3 = windowObj._theme.Accent
                    toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    toggleIndicator:TweenPosition(
                        UDim2.new(1, -18, 0.5, 0),
                        Enum.EasingDirection.Out,
                        Enum.EasingStyle.Quad,
                        0.2,
                        true
                    )
                else
                    toggleBackground.BackgroundColor3 = windowObj._theme.Secondary
                    toggleIndicator.BackgroundColor3 = windowObj._theme.TextSecondary
                    toggleIndicator:TweenPosition(
                        UDim2.new(0, 2, 0.5, 0),
                        Enum.EasingDirection.Out,
                        Enum.EasingStyle.Quad,
                        0.2,
                        true
                    )
                end
                
                -- Call callback
                debug_log("Toggle changed:", options.Name, "Value:", isToggled)
                SafeCall(options.Callback, isToggled)
            end)
            
            -- Hover effects
            toggleClickArea.MouseEnter:Connect(function()
                CreateTween(
                    toggle,
                    {BackgroundColor3 = windowObj._theme.Primary:Lerp(windowObj._theme.Accent, 0.1)},
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2
                )
            end)
            
            toggleClickArea.MouseLeave:Connect(function()
                CreateTween(
                    toggle,
                    {BackgroundColor3 = windowObj._theme.Primary},
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2
                )
            end)
            
            -- Store toggle object
            local toggleObj = {
                Frame = toggle,
                Label = toggleLabel,
                Background = toggleBackground,
                Indicator = toggleIndicator,
                Value = isToggled,
                
                -- Set toggle state
                Set = function(self, value)
                    -- Only update if value is different
                    if value == self.Value then return end
                    
                    -- Update state
                    self.Value = value
                    
                    -- Update visuals
                    if value then
                        toggleBackground.BackgroundColor3 = windowObj._theme.Accent
                        toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        toggleIndicator:TweenPosition(
                            UDim2.new(1, -18, 0.5, 0),
                            Enum.EasingDirection.Out,
                            Enum.EasingStyle.Quad,
                            0.2,
                            true
                        )
                    else
                        toggleBackground.BackgroundColor3 = windowObj._theme.Secondary
                        toggleIndicator.BackgroundColor3 = windowObj._theme.TextSecondary
                        toggleIndicator:TweenPosition(
                            UDim2.new(0, 2, 0.5, 0),
                            Enum.EasingDirection.Out,
                            Enum.EasingStyle.Quad,
                            0.2,
                            true
                        )
                    end
                    
                    -- Call callback
                    SafeCall(options.Callback, value)
                end
            }
            
            table.insert(self.Elements, toggleObj)
            return toggleObj
        end
        
        -- Create slider
        function tab:CreateSlider(options)
            options = options or {}
            options.Name = options.Name or "Slider"
            options.Min = options.Min or 0
            options.Max = options.Max or 100
            options.Default = options.Default or options.Min
            options.Increment = options.Increment or 1
            options.ValueSuffix = options.ValueSuffix or ""
            options.Callback = options.Callback or function() end
            
            debug_log("Creating slider:", options.Name)
            
            -- Validate default value
            options.Default = math.clamp(options.Default, options.Min, options.Max)
            
            -- Create slider container
            local slider = Create("Frame", {
                Name = "Slider",
                BackgroundColor3 = windowObj._theme.Primary,
                Size = UDim2.new(1, 0, 0, 55),
                BorderSizePixel = 0,
                Parent = self.Page
            })
            
            -- Add corner radius
            local sliderCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = slider
            })
            
            -- Add slider label
            local sliderLabel = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -20, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = options.Name,
                TextColor3 = windowObj._theme.TextPrimary,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = slider
            })
            
            -- Add value label
            local valueLabel = Create("TextLabel", {
                Name = "Value",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -110, 0, 5),
                Size = UDim2.new(0, 100, 0, 20),
                Font = Enum.Font.Gotham,
                Text = tostring(options.Default) .. options.ValueSuffix,
                TextColor3 = windowObj._theme.TextSecondary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = slider
            })
            
            -- Add slider bar
            local sliderBar = Create("Frame", {
                Name = "SliderBar",
                BackgroundColor3 = windowObj._theme.Secondary,
                Position = UDim2.new(0, 10, 0, 35),
                Size = UDim2.new(1, -20, 0, 6),
                BorderSizePixel = 0,
                Parent = slider
            })
            
            -- Add corner radius
            local sliderBarCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderBar
            })
            
            -- Add slider fill
            local sliderFill = Create("Frame", {
                Name = "Fill",
                BackgroundColor3 = windowObj._theme.Accent,
                Size = UDim2.new((options.Default - options.Min) / (options.Max - options.Min), 0, 1, 0),
                BorderSizePixel = 0,
                Parent = sliderBar
            })
            
            -- Add corner radius
            local sliderFillCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderFill
            })
            
            -- Add slider thumb
            local sliderThumb = Create("Frame", {
                Name = "Thumb",
                BackgroundColor3 = windowObj._theme.Accent,
                Position = UDim2.new((options.Default - options.Min) / (options.Max - options.Min), 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(0, 14, 0, 14),
                BorderSizePixel = 0,
                Parent = sliderBar
            })
            
            -- Add corner radius
            local sliderThumbCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderThumb
            })
            
            -- Slider value (using options.Default)
            local sliderValue = options.Default
            
            -- Function to update slider visually
            local function updateSlider(value)
                -- Process value using increment
                value = options.Min + (math.round((value - options.Min) / options.Increment) * options.Increment)
                
                -- Clamp value
                value = math.clamp(value, options.Min, options.Max)
                
                -- Update slider value
                sliderValue = value
                
                -- Update visual elements
                local percent = (sliderValue - options.Min) / (options.Max - options.Min)
                
                sliderFill:TweenSize(
                    UDim2.new(percent, 0, 1, 0),
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.1,
                    true
                )
                
                sliderThumb:TweenPosition(
                    UDim2.new(percent, 0, 0.5, 0),
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.1,
                    true
                )
                
                -- Update value label - safely convert to string
                local displayValue = tostring(sliderValue)
                if options.ValueSuffix then
                    displayValue = displayValue .. options.ValueSuffix
                end
                
                valueLabel.Text = displayValue
                
                -- Call callback
                debug_log("Slider changed:", options.Name, "Value:", sliderValue)
                SafeCall(options.Callback, sliderValue)
            end
            
            -- Add slider functionality
            local isDragging = false
            
            -- Mouse events
            sliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                    
                    -- Calculate value from mouse position
                    local mousePos = input.Position.X
                    local sliderPos = sliderBar.AbsolutePosition.X
                    local sliderSize = sliderBar.AbsoluteSize.X
                    local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
                    local value = options.Min + ((options.Max - options.Min) * percent)
                    
                    -- Update slider
                    updateSlider(value)
                end
            end)
            
            sliderBar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end)
            
            services.UserInputService.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    -- Calculate value from mouse position
                    local mousePos = input.Position.X
                    local sliderPos = sliderBar.AbsolutePosition.X
                    local sliderSize = sliderBar.AbsoluteSize.X
                    local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
                    local value = options.Min + ((options.Max - options.Min) * percent)
                    
                    -- Update slider
                    updateSlider(value)
                end
            end)
            
            -- Hover effects
            slider.MouseEnter:Connect(function()
                CreateTween(
                    slider,
                    {BackgroundColor3 = windowObj._theme.Primary:Lerp(windowObj._theme.Accent, 0.1)},
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2
                )
            end)
            
            slider.MouseLeave:Connect(function()
                CreateTween(
                    slider,
                    {BackgroundColor3 = windowObj._theme.Primary},
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2
                )
            end)
            
            -- Store slider object
            local sliderObj = {
                Frame = slider,
                Label = sliderLabel,
                Value = sliderValue,
                
                -- Set slider value
                Set = function(self, value)
                    -- Update slider
                    updateSlider(value)
                end
            }
            
            table.insert(self.Elements, sliderObj)
            return sliderObj
        end
        
        -- Create dropdown
        function tab:CreateDropdown(options)
            options = options or {}
            options.Name = options.Name or "Dropdown"
            options.Options = options.Options or {}
            options.Default = options.Default or (options.Options[1] or "")
            options.Callback = options.Callback or function() end
            
            debug_log("Creating dropdown:", options.Name)
            
            -- Create dropdown container
            local dropdown = Create("Frame", {
                Name = "Dropdown",
                BackgroundColor3 = windowObj._theme.Primary,
                Size = UDim2.new(1, 0, 0, 40),
                ClipsDescendants = true,
                BorderSizePixel = 0,
                Parent = self.Page
            })
            
            -- Add corner radius
            local dropdownCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = dropdown
            })
            
            -- Add dropdown label
            local dropdownLabel = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -60, 0, 40),
                Font = Enum.Font.GothamBold,
                Text = options.Name,
                TextColor3 = windowObj._theme.TextPrimary,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdown
            })
            
            -- Add selection label
            local selectionLabel = Create("TextLabel", {
                Name = "Selection",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 20),
                Size = UDim2.new(1, -60, 0, 20),
                Font = Enum.Font.Gotham,
                Text = options.Default,
                TextColor3 = windowObj._theme.TextSecondary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdown
            })
            
            -- Add dropdown arrow
            local dropdownArrow = Create("ImageLabel", {
                Name = "Arrow",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -30, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 20, 0, 20),
                Rotation = 0,
                Image = "rbxassetid://7733983929",
                ImageColor3 = windowObj._theme.TextSecondary,
                Parent = dropdown
            })
            
            -- Add dropdown options container (initially collapsed)
            local optionsContainer = Create("Frame", {
                Name = "OptionsContainer",
                BackgroundColor3 = windowObj._theme.Secondary,
                Position = UDim2.new(0, 0, 0, 45),
                Size = UDim2.new(1, 0, 0, 0), -- Will be updated based on options
                BorderSizePixel = 0,
                Parent = dropdown
            })
            
            -- Add corner radius
            local optionsContainerCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = optionsContainer
            })
            
            -- Add options list layout
            local optionsLayout = Create("UIListLayout", {
                Padding = UDim.new(0, 5),
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = optionsContainer
            })
            
            -- Add padding to options container
            local optionsPadding = Create("UIPadding", {
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5),
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5),
                Parent = optionsContainer
            })
            
            -- Dropdown state
            local isOpen = false
            local selectedOption = options.Default
            
            -- Function to close dropdown
            local function closeDropdown()
                isOpen = false
                
                -- Animate closure
                dropdown:TweenSize(
                    UDim2.new(1, 0, 0, 40),
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2,
                    true
                )
                
                CreateTween(
                    dropdownArrow,
                    {Rotation = 0},
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2
                )
            end
            
            -- Function to open dropdown
            local function openDropdown()
                isOpen = true
                
                -- Calculate size based on options
                local optionsHeight = optionsLayout.AbsoluteContentSize.Y + 10
                
                -- Animate opening
                dropdown:TweenSize(
                    UDim2.new(1, 0, 0, 50 + optionsHeight),
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2,
                    true
                )
                
                CreateTween(
                    dropdownArrow,
                    {Rotation = 180},
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2
                )
            end
            
            -- Function to toggle dropdown
            local function toggleDropdown()
                if isOpen then
                    closeDropdown()
                else
                    openDropdown()
                end
            end
            
            -- Function to create option button
            local function createOptionButton(optionText)
                local optionButton = Create("TextButton", {
                    Name = optionText,
                    BackgroundColor3 = windowObj._theme.Primary,
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.Gotham,
                    Text = optionText,
                    TextColor3 = windowObj._theme.TextPrimary,
                    TextSize = 14,
                    BorderSizePixel = 0,
                    Parent = optionsContainer
                })
                
                -- Add corner radius
                local optionButtonCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = optionButton
                })
                
                -- Hover effects
                optionButton.MouseEnter:Connect(function()
                    optionButton.BackgroundColor3 = windowObj._theme.Primary:Lerp(windowObj._theme.Accent, 0.2)
                end)
                
                optionButton.MouseLeave:Connect(function()
                    optionButton.BackgroundColor3 = windowObj._theme.Primary
                end)
                
                -- Option click event
                optionButton.MouseButton1Click:Connect(function()
                    -- Update selection
                    selectedOption = optionText
                    selectionLabel.Text = selectedOption
                    
                    -- Close dropdown
                    closeDropdown()
                    
                    -- Call callback
                    debug_log("Dropdown selected:", optionText)
                    SafeCall(options.Callback, selectedOption)
                end)
                
                return optionButton
            end
            
            -- Add option buttons
            local optionButtons = {}
            
            for _, optionText in ipairs(options.Options) do
                table.insert(optionButtons, createOptionButton(optionText))
            end
            
            -- Create dropdown button
            local dropdownButton = Create("TextButton", {
                Name = "DropdownButton",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Font = Enum.Font.SourceSans,
                Text = "",
                TextColor3 = Color3.fromRGB(0, 0, 0),
                TextSize = 1,
                Parent = dropdown
            })
            
            -- Dropdown click event
            dropdownButton.MouseButton1Click:Connect(toggleDropdown)
            
            -- Hover effects
            dropdownButton.MouseEnter:Connect(function()
                CreateTween(
                    dropdown,
                    {BackgroundColor3 = windowObj._theme.Primary:Lerp(windowObj._theme.Accent, 0.1)},
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2
                )
                
                dropdownArrow.ImageColor3 = windowObj._theme.TextPrimary
            end)
            
            dropdownButton.MouseLeave:Connect(function()
                CreateTween(
                    dropdown,
                    {BackgroundColor3 = windowObj._theme.Primary},
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2
                )
                
                dropdownArrow.ImageColor3 = windowObj._theme.TextSecondary
            end)
            
            -- Store dropdown object
            local dropdownObj = {
                Frame = dropdown,
                Label = dropdownLabel,
                Selection = selectionLabel,
                Value = selectedOption,
                
                -- Set selected option
                Set = function(self, value)
                    -- Check if option exists
                    local optionExists = false
                    
                    for _, option in ipairs(options.Options) do
                        if option == value then
                            optionExists = true
                            break
                        end
                    end
                    
                    -- Only update if option exists
                    if optionExists then
                        selectedOption = value
                        selectionLabel.Text = selectedOption
                        self.Value = value
                        
                        -- Call callback
                        SafeCall(options.Callback, value)
                    end
                end,
                
                -- Add option
                AddOption = function(self, value)
                    -- Check if option already exists
                    for _, button in ipairs(optionButtons) do
                        if button.Text == value then
                            return
                        end
                    end
                    
                    -- Add option to list
                    table.insert(options.Options, value)
                    
                    -- Create button
                    table.insert(optionButtons, createOptionButton(value))
                end,
                
                -- Remove option
                RemoveOption = function(self, value)
                    -- Find option index
                    local optionIndex = nil
                    
                    for i, option in ipairs(options.Options) do
                        if option == value then
                            optionIndex = i
                            break
                        end
                    end
                    
                    -- Remove option if found
                    if optionIndex then
                        table.remove(options.Options, optionIndex)
                        
                        -- Find and remove button
                        for i, button in ipairs(optionButtons) do
                            if button.Text == value then
                                button:Destroy()
                                table.remove(optionButtons, i)
                                break
                            end
                        end
                        
                        -- Update selected option if it was removed
                        if selectedOption == value then
                            selectedOption = options.Options[1] or ""
                            selectionLabel.Text = selectedOption
                        end
                    end
                end
            }
            
            table.insert(self.Elements, dropdownObj)
            return dropdownObj
        end
        
        -- Create label
        function tab:CreateLabel(options)
            options = options or {}
            options.Text = options.Text or "Label"
            
            debug_log("Creating label:", options.Text)
            
            -- Create label container
            local label = Create("Frame", {
                Name = "Label",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30),
                Parent = self.Page
            })
            
            -- Add label text
            local labelText = Create("TextLabel", {
                Name = "Text",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = options.Text,
                TextColor3 = windowObj._theme.TextPrimary,
                TextSize = 15,
                Parent = label
            })
            
            -- Store label object
            local labelObj = {
                Frame = label,
                Text = labelText,
                
                -- Set label text
                Set = function(self, newText)
                    labelText.Text = newText
                end
            }
            
            table.insert(self.Elements, labelObj)
            return labelObj
        end
        
        -- Create separator
        function tab:CreateSeparator()
            debug_log("Creating separator")
            
            -- Create separator
            local separator = Create("Frame", {
                Name = "Separator",
                BackgroundColor3 = windowObj._theme.Secondary,
                Size = UDim2.new(1, 0, 0, 1),
                BorderSizePixel = 0,
                Parent = self.Page
            })
            
            -- Store separator object
            local separatorObj = {
                Frame = separator
            }
            
            table.insert(self.Elements, separatorObj)
            return separatorObj
        end
        
        -- Create paragraph
        function tab:CreateParagraph(options)
            options = options or {}
            options.Title = options.Title or "Title"
            options.Content = options.Content or "Content"
            
            debug_log("Creating paragraph:", options.Title)
            
            -- Calculate height based on content
            local titleHeight = 22
            local contentHeight = 40 -- Default height
            
            pcall(function()
                local maxWidth = self.Page.AbsoluteSize.X - 30
                local contentTextSize = services.TextService:GetTextSize(options.Content, 14, Enum.Font.Gotham, Vector2.new(maxWidth, math.huge))
                contentHeight = contentTextSize.Y
            end)
            
            -- Create paragraph
            local paragraph = Create("Frame", {
                Name = "Paragraph",
                BackgroundColor3 = windowObj._theme.Primary,
                Size = UDim2.new(1, 0, 0, titleHeight + contentHeight + 20), -- Padding
                BorderSizePixel = 0,
                Parent = self.Page
            })
            
            -- Add corner radius
            local paragraphCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = paragraph
            })
            
            -- Add title
            local title = Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 10),
                Size = UDim2.new(1, -20, 0, titleHeight),
                Font = Enum.Font.GothamBold,
                Text = options.Title,
                TextColor3 = windowObj._theme.TextPrimary,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = paragraph
            })
            
            -- Add content
            local content = Create("TextLabel", {
                Name = "Content",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, titleHeight + 10),
                Size = UDim2.new(1, -20, 0, contentHeight),
                Font = Enum.Font.Gotham,
                Text = options.Content,
                TextColor3 = windowObj._theme.TextSecondary,
                TextSize = 14,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                Parent = paragraph
            })
            
            -- Store paragraph object
            local paragraphObj = {
                Frame = paragraph,
                Title = title,
                Content = content,
                
                -- Set paragraph content
                Set = function(self, newTitle, newContent)
                    title.Text = newTitle or title.Text
                    
                    if newContent then
                        content.Text = newContent
                        
                        -- Recalculate height
                        pcall(function()
                            local maxWidth = self.Page.AbsoluteSize.X - 30
                            local contentTextSize = services.TextService:GetTextSize(newContent, 14, Enum.Font.Gotham, Vector2.new(maxWidth, math.huge))
                            contentHeight = contentTextSize.Y
                            
                            content.Size = UDim2.new(1, -20, 0, contentHeight)
                            paragraph.Size = UDim2.new(1, 0, 0, titleHeight + contentHeight + 20)
                        end)
                    end
                end
            }
            
            table.insert(self.Elements, paragraphObj)
            return paragraphObj
        end
        
        -- Create color picker (simplified version for now)
        function tab:CreateColorPicker(options)
            options = options or {}
            options.Name = options.Name or "Color Picker"
            options.Default = options.Default or Color3.fromRGB(255, 0, 0)
            options.Callback = options.Callback or function() end
            
            debug_log("Creating color picker:", options.Name)
            
            -- Create color picker container
            local colorPicker = Create("Frame", {
                Name = "ColorPicker",
                BackgroundColor3 = windowObj._theme.Primary,
                Size = UDim2.new(1, 0, 0, 40),
                BorderSizePixel = 0,
                Parent = self.Page
            })
            
            -- Add corner radius
            local colorPickerCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = colorPicker
            })
            
            -- Add color picker label
            local colorPickerLabel = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = options.Name,
                TextColor3 = windowObj._theme.TextPrimary,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = colorPicker
            })
            
            -- Add color display
            local colorDisplay = Create("Frame", {
                Name = "ColorDisplay",
                BackgroundColor3 = options.Default,
                Position = UDim2.new(1, -40, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 30, 0, 30),
                BorderSizePixel = 0,
                Parent = colorPicker
            })
            
            -- Add corner radius
            local colorDisplayCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = colorDisplay
            })
            
            -- Current color value
            local currentColor = options.Default
            
            -- Color picker click functionality (simplified)
            local colorPickerButton = Create("TextButton", {
                Name = "ColorPickerButton",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                Parent = colorPicker
            })
            
            colorPickerButton.MouseButton1Click:Connect(function()
                -- In a real implementation, this would open a color picker UI
                -- For now, just cycle through some colors on click
                local colors = {
                    Color3.fromRGB(255, 0, 0),   -- Red
                    Color3.fromRGB(0, 255, 0),   -- Green
                    Color3.fromRGB(0, 0, 255),   -- Blue
                    Color3.fromRGB(255, 255, 0), -- Yellow
                    Color3.fromRGB(255, 0, 255), -- Magenta
                    Color3.fromRGB(0, 255, 255)  -- Cyan
                }
                
                -- Find current color index
                local currentIndex = 1
                for i, color in ipairs(colors) do
                    if color == currentColor then
                        currentIndex = i
                        break
                    end
                end
                
                -- Move to next color
                currentIndex = currentIndex % #colors + 1
                currentColor = colors[currentIndex]
                
                -- Update display
                colorDisplay.BackgroundColor3 = currentColor
                
                -- Call callback
                debug_log("Color picker changed:", options.Name, "Color:", currentColor)
                SafeCall(options.Callback, currentColor)
            end)
            
            -- Hover effects
            colorPickerButton.MouseEnter:Connect(function()
                CreateTween(
                    colorPicker,
                    {BackgroundColor3 = windowObj._theme.Primary:Lerp(windowObj._theme.Accent, 0.1)},
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2
                )
            end)
            
            colorPickerButton.MouseLeave:Connect(function()
                CreateTween(
                    colorPicker,
                    {BackgroundColor3 = windowObj._theme.Primary},
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2
                )
            end)
            
            -- Store color picker object
            local colorPickerObj = {
                Frame = colorPicker,
                Label = colorPickerLabel,
                Display = colorDisplay,
                Value = currentColor,
                
                -- Set color
                Set = function(self, color)
                    currentColor = color
                    colorDisplay.BackgroundColor3 = color
                    self.Value = color
                    SafeCall(options.Callback, color)
                end
            }
            
            table.insert(self.Elements, colorPickerObj)
            return colorPickerObj
        end
        
        -- For compatibility with both CreateColorPicker and CreateColorpicker names
        tab.CreateColorpicker = tab.CreateColorPicker
        
        return tab
    end
    
    -- Update theme for window and all components
    function windowObj:_updateTheme()
        local theme = TBD._theme
        
        pcall(function()
            -- Safe element access
            local function safeAccess(parent, property, value)
                if parent and typeof(parent) == "Instance" then
                    pcall(function()
                        parent[property] = value
                    end)
                end
            end
            
            -- Update window elements
            safeAccess(self.Window, "BackgroundColor3", theme.Background)
            
            if self.Header then
                safeAccess(self.Header, "BackgroundColor3", theme.Primary)
                
                if self.Header:FindFirstChild("Cover") then
                    safeAccess(self.Header.Cover, "BackgroundColor3", theme.Primary)
                end
                
                safeAccess(self.Header:FindFirstChild("Title"), "TextColor3", theme.TextPrimary)
                safeAccess(self.Header:FindFirstChild("Subtitle"), "TextColor3", theme.TextSecondary)
            end
            
            if self.ContentContainer and self.ContentContainer:FindFirstChild("Sidebar") then
                local sidebar = self.ContentContainer.Sidebar
                safeAccess(sidebar, "BackgroundColor3", theme.Primary)
                
                if sidebar:FindFirstChild("Cover") then
                    safeAccess(sidebar.Cover, "BackgroundColor3", theme.Primary)
                end
                
                -- Update home button if it exists
                if sidebar:FindFirstChild("HomeButton") then
                    if self.ActiveTab == "HomePage" then
                        safeAccess(sidebar.HomeButton, "ImageColor3", theme.Accent)
                    else
                        safeAccess(sidebar.HomeButton, "ImageColor3", theme.TextSecondary)
                    end
                end
            end
            
            -- Update tab buttons
            for name, tab in pairs(self.Tabs) do
                -- Make sure tab and button exist
                if tab and tab.Button then
                    if name == self.ActiveTab then
                        safeAccess(tab.Button, "ImageColor3", theme.Accent)
                    else
                        safeAccess(tab.Button, "ImageColor3", theme.TextSecondary)
                    end
                    
                    -- Update tab page scrollbar if page exists
                    if tab.Page then
                        safeAccess(tab.Page, "ScrollBarImageColor3", theme.Accent)
                    end
                    
                    -- Update elements if they exist
                    if tab.Elements then
                        for _, element in ipairs(tab.Elements) do
                            if element and element.Frame then
                                -- Common properties
                                pcall(function()
                                    if element.Frame.BackgroundTransparency <= 0 then
                                        element.Frame.BackgroundColor3 = theme.Primary
                                    end
                                end)
                                
                                -- Update text colors
                                if element.Label then
                                    safeAccess(element.Label, "TextColor3", theme.TextPrimary)
                                end
                                
                                if element.Text then
                                    safeAccess(element.Text, "TextColor3", theme.TextPrimary)
                                end
                                
                                -- Update specialized elements
                                pcall(function()
                                    if element.Frame.Name:find("Toggle") then
                                        if element.Background then
                                            element.Background.BackgroundColor3 = theme.Secondary
                                            
                                            if element.Value then
                                                element.Background.BackgroundColor3 = theme.Accent
                                                if element.Indicator then
                                                    element.Indicator.BackgroundColor3 = Color3.new(1, 1, 1)
                                                end
                                            else
                                                if element.Indicator then
                                                    element.Indicator.BackgroundColor3 = theme.TextSecondary
                                                end
                                            end
                                        end
                                    elseif element.Frame.Name:find("Slider") then
                                        if element.Frame:FindFirstChild("SliderBar") then
                                            element.Frame.SliderBar.BackgroundColor3 = theme.Secondary
                                            
                                            if element.Frame.SliderBar:FindFirstChild("Fill") then
                                                element.Frame.SliderBar.Fill.BackgroundColor3 = theme.Accent
                                            end
                                        end
                                    elseif element.Frame.Name:find("Dropdown") then
                                        if element.Frame:FindFirstChild("OptionsContainer") then
                                            element.Frame.OptionsContainer.BackgroundColor3 = theme.Secondary
                                        end
                                    elseif element.Frame.Name:find("ColorPicker") or element.Frame.Name:find("Colorpicker") then
                                        if element.Frame:FindFirstChild("ExpandedContainer") then
                                            element.Frame.ExpandedContainer.BackgroundColor3 = theme.Secondary
                                        end
                                    elseif element.Display then  -- For color pickers
                                        -- No specific updates needed
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end)
    end
    
    -- Add window to windows table
    table.insert(TBD.Windows, windowObj)
    
    -- Return the window object
    return windowObj
end

-- Add Notification convenience method
function TBD:Notification(options)
    self:_EnsureInitialized()
    
    return self.NotificationSystem:CreateNotification(options)
end

return TBD
