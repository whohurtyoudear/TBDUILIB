--[[
    TBD UI Library V13 - Final Release
    
    A modern, robust Roblox UI library for script hubs and executors
    Version 3.0.0-V13
    
    Enhanced with improved dragging functionality and UI refinements
    Incorporates fixes for all known issues from previous versions
]]

-- Library setup with error handling
local TBD = {
    Version = "3.0.0-V13",
    _initialized = false,
    _theme = nil,
    Windows = {},
    Notifications = {},
    SafeIndex = function(t, k)
        if t and typeof(t) == "table" then
            return t[k]
        end
        return nil
    end
}

-- Services with safe fetching
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
    
    -- Return a mock service with fallback functionality if needed
    return setmetatable({}, {
        __index = function(_, key)
            if key == "GetTextSize" then
                return function(_, text, size)
                    return Vector2.new(#text * size * 0.5, size)
                end
            elseif key == "Create" then
                return function() return "" end
            end
            return function() end
        end
    })
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
    
    -- Return a dummy instance if creation failed
    return {
        Name = instanceType .. "_Dummy",
        Parent = nil,
        Destroy = function() end,
        Clone = function() return {} end,
        FindFirstChild = function() return nil end,
        GetChildren = function() return {} end
    }
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
    if not success then
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
        
        -- Close button
        local closeButton = Create("ImageButton", {
            Name = "CloseButton",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -20, 0, 10),
            Size = UDim2.new(0, 16, 0, 16),
            Image = Icons.close,
            ImageColor3 = theme.TextSecondary,
            Parent = notification
        })
        
        -- Calculate message height based on text wrapping
        local messagePadding = 15
        local messageHeight = 0
        pcall(function()
            local textSize = GetTextSize(message, 14, Enum.Font.Gotham, Vector2.new(notification.AbsoluteSize.X - 30, 1000))
            messageHeight = textSize.Y
        end)
        
        -- Update sizes
        messageLabel.Size = UDim2.new(1, -30, 0, messageHeight)
        notification.Size = UDim2.new(1, 0, 0, 42 + messageHeight)
        
        -- Setup progress bar
        local progressBar = Create("Frame", {
            Name = "ProgressBar",
            BackgroundColor3 = typeColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -2),
            Size = UDim2.new(1, 0, 0, 2),
            Parent = notification
        })
        
        -- Animate in
        notification.BackgroundTransparency = 1
        notification.Position = UDim2.new(1, 20, 0, notification.Position.Y.Offset)
        
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint)
        local tween = services.TweenService:Create(notification, tweenInfo, {
            BackgroundTransparency = 0,
            Position = UDim2.new(0, 0, 0, notification.Position.Y.Offset)
        })
        tween:Play()
        
        -- Setup close button
        ConnectTouchInput(closeButton, function()
            self:CloseNotification(notification)
        end)
        
        -- Make notification clickable if callback provided
        if typeof(callback) == "function" then
            notification.Selectable = true
            ConnectTouchInput(notification, function()
                pcall(callback)
                self:CloseNotification(notification)
            end)
        end
        
        -- Progress bar animation
        local progressTween = services.TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 0, 2)
        })
        progressTween:Play()
        
        -- Auto close after duration
        local function close()
            self:CloseNotification(notification)
        end
        
        -- Using a safe delay approach
        task.delay(duration, function()
            pcall(close)
        end)
        
        return notification
    end,
    
    CloseNotification = function(self, notification)
        -- Animate out
        pcall(function()
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint)
            local tween = services.TweenService:Create(notification, tweenInfo, {
                BackgroundTransparency = 1,
                Position = UDim2.new(1, 20, 0, notification.Position.Y.Offset)
            })
            tween:Play()
            
            tween.Completed:Connect(function()
                notification:Destroy()
            end)
        end)
    end
}

-- Loading screen system
TBD.LoadingScreen = {
    Create = function(self, options)
        local theme = TBD._theme
        local title = options.Title or "Loading"
        local subtitle = options.Subtitle or "Please wait..."
        local logoId = options.LogoId -- Optional
        
        -- Create the loading screen
        local gui = Create("ScreenGui", {
            Name = "TBDLoadingScreen",
            DisplayOrder = 10000,
            ResetOnSpawn = false
        })
        
        -- Apply safe parenting with fallbacks
        SafeParent(gui)
        
        -- Create background
        local background = Create("Frame", {
            Name = "Background",
            BackgroundColor3 = theme.Background,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = gui
        })
        
        -- Create container
        local container = Create("Frame", {
            Name = "Container",
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 300, 0, 200),
            Parent = background
        })
        
        -- Create logo if provided
        if logoId then
            local logo = Create("ImageLabel", {
                Name = "Logo",
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 0),
                Size = UDim2.new(0, 80, 0, 80),
                Image = logoId,
                Parent = container
            })
            
            -- Adjust container for logo
            container.Size = UDim2.new(0, 300, 0, 250)
        end
        
        -- Create title
        local titleLabel = Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, logoId and 0.4 or 0.2, 0),
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = theme.TextPrimary,
            TextSize = 22,
            Parent = container
        })
        
        -- Create subtitle
        local subtitleLabel = Create("TextLabel", {
            Name = "Subtitle",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, logoId and 0.5 or 0.3, 0),
            Size = UDim2.new(1, 0, 0, 20),
            Font = Enum.Font.Gotham,
            Text = subtitle,
            TextColor3 = theme.TextSecondary,
            TextSize = 16,
            Parent = container
        })
        
        -- Create progress bar background
        local progressBackground = Create("Frame", {
            Name = "ProgressBackground",
            BackgroundColor3 = theme.Secondary,
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, logoId and 0.65 or 0.5, 0),
            Size = UDim2.new(0.8, 0, 0, 6),
            Parent = container
        })
        
        -- Add corner radius to progress background
        local progressBgCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 3),
            Parent = progressBackground
        })
        
        -- Create progress bar
        local progressBar = Create("Frame", {
            Name = "ProgressBar",
            BackgroundColor3 = theme.Accent,
            Size = UDim2.new(0, 0, 1, 0),
            Parent = progressBackground
        })
        
        -- Add corner radius to progress bar
        local progressBarCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 3),
            Parent = progressBar
        })
        
        -- Create loading object
        local loadingScreen = {
            Gui = gui,
            Title = titleLabel,
            Subtitle = subtitleLabel,
            ProgressBar = progressBar,
            
            UpdateProgress = function(self, progress)
                -- Validate and clamp progress
                progress = typeof(progress) == "number" and math.clamp(progress, 0, 1) or 0
                
                -- Update progress bar
                pcall(function()
                    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint)
                    local tween = services.TweenService:Create(self.ProgressBar, tweenInfo, {
                        Size = UDim2.new(progress, 0, 1, 0)
                    })
                    tween:Play()
                end)
                
                return self
            end,
            
            UpdateTitle = function(self, newTitle)
                pcall(function()
                    self.Title.Text = newTitle or self.Title.Text
                end)
                return self
            end,
            
            UpdateSubtitle = function(self, newSubtitle)
                pcall(function()
                    self.Subtitle.Text = newSubtitle or self.Subtitle.Text
                end)
                return self
            end,
            
            Finish = function(self, callback)
                -- Fade out animation
                pcall(function()
                    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint)
                    local tween = services.TweenService:Create(background, tweenInfo, {
                        BackgroundTransparency = 1
                    })
                    tween:Play()
                    
                    -- Set all text elements to transparent
                    for _, v in pairs(container:GetChildren()) do
                        if v:IsA("TextLabel") or v:IsA("ImageLabel") then
                            services.TweenService:Create(v, tweenInfo, {
                                BackgroundTransparency = 1,
                                TextTransparency = 1,
                                ImageTransparency = 1
                            }):Play()
                        elseif v:IsA("Frame") then
                            services.TweenService:Create(v, tweenInfo, {
                                BackgroundTransparency = 1
                            }):Play()
                        end
                    end
                    
                    -- Clean up after animation
                    task.delay(0.5, function()
                        self.Gui:Destroy()
                        if typeof(callback) == "function" then
                            pcall(callback)
                        end
                    end)
                end)
                
                return self
            end
        }
        
        return loadingScreen
    end
}

-- Apply theme function
function TBD:ApplyTheme(themeName)
    if Themes[themeName] then
        self._theme = Themes[themeName]
    end
    
    -- Update all active windows with the new theme
    for _, window in pairs(self.Windows) do
        pcall(function()
            window:_updateTheme()
        end)
    end
    
    return self
end

-- Create custom theme
function TBD:CustomTheme(themeColors)
    -- Create a new theme by merging with default
    local newTheme = {}
    
    -- Start with HoHo theme as base
    for k, v in pairs(Themes.HoHo) do
        newTheme[k] = v
    end
    
    -- Override with provided colors
    for k, v in pairs(themeColors) do
        newTheme[k] = v
    end
    
    -- Set as current theme
    self._theme = newTheme
    
    -- Update all active windows
    for _, window in pairs(self.Windows) do
        pcall(function()
            window:_updateTheme()
        end)
    end
    
    return self
end

-- Create a notification
function TBD:Notification(options)
    self:_EnsureInitialized()
    
    return self.NotificationSystem:CreateNotification(options)
end

-- Improved draggable function to fix the dragging issue
local function MakeDraggable(element, handle, constraint)
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    handle = handle or element
    constraint = constraint or element.Parent
    
    -- Function to safely get values that could be nil in some environments
    local function GetAbsoluteSize(instance)
        return (typeof(instance) == "Instance" and instance:IsA("GuiObject")) and 
            instance.AbsoluteSize or Vector2.new(800, 600)
    end
    
    local function GetAbsolutePosition(instance)
        return (typeof(instance) == "Instance" and instance:IsA("GuiObject")) and 
            instance.AbsolutePosition or Vector2.new(0, 0)
    end
    
    -- Improved update function with better validation
    local function Update(input)
        if not dragging then return end
        
        -- Ensure values are valid
        if not dragStart or not startPos or not input or not input.Position then return end
        
        local delta = input.Position - dragStart
        
        -- Get constraint bounds safely
        local constraintSize = GetAbsoluteSize(constraint)
        local elementSize = GetAbsoluteSize(element)
        local maxX = constraintSize.X - elementSize.X
        local maxY = constraintSize.Y - elementSize.Y
        
        -- Calculate new position with improved clamping
        local newPosition = UDim2.new(
            startPos.X.Scale, 
            math.clamp(startPos.X.Offset + delta.X, 0, maxX > 0 and maxX or 500),
            startPos.Y.Scale,
            math.clamp(startPos.Y.Offset + delta.Y, 0, maxY > 0 and maxY or 300)
        )
        
        -- Only use tweens for smooth small movements, use direct positioning for dragging
        -- This prevents the UI from getting stuck
        element.Position = newPosition
    end
    
    -- Connect drag events with additional error handling
    pcall(function()
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = element.Position
                
                -- Capture input to prevent losing track if mouse moves too fast
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        handle.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        handle.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        
        services.UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                Update(input)
            end
        end)
    end)
end

-- Ensure library is initialized
function TBD:_EnsureInitialized()
    if not self._initialized then
        -- Initialize notification system
        self.NotificationSystem:Setup()
        self.NotificationSystem:SetPosition("TopRight")
        
        self._initialized = true
    end
    
    return self
end

-- Create window
function TBD:CreateWindow(options)
    self:_EnsureInitialized()
    
    local theme = self._theme
    
    -- Default options
    options = options or {}
    options.Title = options.Title or "TBD UI Library"
    options.Subtitle = options.Subtitle or ""
    options.Size = options.Size or 550
    options.Theme = options.Theme or "HoHo"
    options.MinimizeKey = options.MinimizeKey or Enum.KeyCode.RightShift
    options.ShowHomePage = options.ShowHomePage ~= nil and options.ShowHomePage or true
    
    -- Apply theme if specified
    if options.Theme and Themes[options.Theme] then
        self:ApplyTheme(options.Theme)
        theme = self._theme
    end
    
    -- Create ScreenGui
    local gui = Create("ScreenGui", {
        Name = "TBDUI_" .. options.Title:gsub("%s+", "_"),
        DisplayOrder = 100,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Safe parenting with fallbacks
    SafeParent(gui)
    
    -- Calculate window dimensions
    local windowWidth = options.Size
    local windowHeight = windowWidth * 0.6 -- 5:3 aspect ratio
    
    -- Create main window frame
    local window = Create("Frame", {
        Name = "Window",
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2),
        Size = UDim2.new(0, windowWidth, 0, windowHeight),
        Parent = gui
    })
    
    -- Add corner radius
    local windowCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = window
    })
    
    -- Create window shadow
    local windowShadow = Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 40, 1, 40),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        Parent = window
    })
    
    -- Create header
    local header = Create("Frame", {
        Name = "Header",
        BackgroundColor3 = theme.Primary,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = window
    })
    
    -- Add corner radius to header
    local headerCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = header
    })
    
    -- Add bottom cover to fix corner radius overlap
    local headerCover = Create("Frame", {
        Name = "Cover",
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 8),
        Parent = header
    })
    
    -- Create title
    local title = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0.5, -10),
        Size = UDim2.new(0.5, 0, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = options.Title,
        TextColor3 = theme.TextPrimary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    -- Create subtitle
    local subtitle = Create("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0.5, 10),
        Size = UDim2.new(0.5, 0, 0, 14),
        Font = Enum.Font.Gotham,
        Text = options.Subtitle,
        TextColor3 = theme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    -- Create close button
    local closeButton = Create("ImageButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0.5, -9),
        Size = UDim2.new(0, 18, 0, 18),
        Image = Icons.close,
        ImageColor3 = theme.TextSecondary,
        Parent = header
    })
    
    -- Create minimize button
    local minimizeButton = Create("ImageButton", {
        Name = "MinimizeButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -60, 0.5, -9),
        Size = UDim2.new(0, 18, 0, 18),
        Image = Icons.minimize,
        ImageColor3 = theme.TextSecondary,
        Parent = header
    })
    
    -- Create content container
    local contentContainer = Create("Frame", {
        Name = "ContentContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 1, -40),
        ClipsDescendants = true,
        Parent = window
    })
    
    -- Create sidebar
    local sidebar = Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = theme.Primary,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 50, 1, 0),
        Parent = contentContainer
    })
    
    -- Add corner radius to sidebar
    local sidebarCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = sidebar
    })
    
    -- Add right cover to fix corner radius overlap
    local sidebarCover = Create("Frame", {
        Name = "Cover",
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -8, 0, 0),
        Size = UDim2.new(0, 8, 1, 0),
        Parent = sidebar
    })
    
    -- Create tab buttons container
    local tabButtons = Create("ScrollingFrame", {
        Name = "TabButtons",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 50), -- Start below home button
        Size = UDim2.new(1, 0, 1, -50),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        Parent = sidebar
    })
    
    -- Create tab button layout
    local tabButtonLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabButtons
    })
    
    -- Create home button
    local homeButton = Create("ImageButton", {
        Name = "HomeButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 15),
        Size = UDim2.new(0, 24, 0, 24),
        AnchorPoint = Vector2.new(0.5, 0),
        Image = Icons.home,
        ImageColor3 = theme.Accent,
        Parent = sidebar
    })
    
    -- Create tab content container
    local tabContent = Create("Frame", {
        Name = "TabContent",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 60, 0, 10),
        Size = UDim2.new(1, -70, 1, -20),
        Parent = contentContainer
    })
    
    -- Create tab pages container
    local tabPages = Create("Frame", {
        Name = "TabPages",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = tabContent
    })
    
    -- Create home page
    local homePage = Create("ScrollingFrame", {
        Name = "HomePage",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = theme.Accent,
        Visible = false,
        Parent = tabPages
    })
    
    -- Add padding to home page
    local homePagePadding = Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        Parent = homePage
    })
    
    -- Add list layout to home page
    local homePageLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = homePage
    })
    
    -- Create home page content if enabled
    if options.ShowHomePage then
        -- Welcome header
        local welcomeHeader = Create("Frame", {
            Name = "WelcomeHeader",
            BackgroundColor3 = theme.Primary,
            Size = UDim2.new(1, 0, 0, 100),
            Parent = homePage
        })
        
        -- Add corner radius to welcome header
        local welcomeHeaderCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = welcomeHeader
        })
        
        -- Player icon
        local playerIcon = Create("ImageLabel", {
            Name = "PlayerIcon",
            BackgroundColor3 = theme.Secondary,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 15, 0.5, 0),
            Size = UDim2.new(0, 60, 0, 60),
            Image = "rbxassetid://7962146544",
            Parent = welcomeHeader
        })
        
        -- Add corner radius to player icon
        local playerIconCorner = Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = playerIcon
        })
        
        -- Player name label
        local playerName = Create("TextLabel", {
            Name = "PlayerName",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 90, 0, 30),
            Size = UDim2.new(1, -100, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = "Welcome!",
            TextColor3 = theme.TextPrimary,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = welcomeHeader
        })
        
        -- Try to get player name safely
        pcall(function()
            if services.Players and services.Players.LocalPlayer then
                playerName.Text = "Welcome, " .. services.Players.LocalPlayer.DisplayName .. "!"
                playerIcon.Image = "rbxthumb://type=AvatarHeadShot&id=" .. services.Players.LocalPlayer.UserId .. "&w=60&h=60"
            end
        end)
        
        -- Game name label
        local gameName = Create("TextLabel", {
            Name = "GameName",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 90, 0, 55),
            Size = UDim2.new(1, -100, 0, 20),
            Font = Enum.Font.Gotham,
            Text = "Game: Unknown",
            TextColor3 = theme.TextSecondary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = welcomeHeader
        })
        
        -- Try to get game name safely
        pcall(function()
            local marketplaceService = GetService("MarketplaceService")
            local success, info = pcall(function()
                return marketplaceService:GetProductInfo(game.PlaceId)
            end)
            
            if success and info and info.Name then
                gameName.Text = "Game: " .. info.Name
            end
        end)
        
        -- Add info section
        local infoSection = Create("Frame", {
            Name = "InfoSection",
            BackgroundColor3 = theme.Primary,
            Size = UDim2.new(1, 0, 0, 120),
            Parent = homePage
        })
        
        -- Add corner radius to info section
        local infoSectionCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = infoSection
        })
        
        -- Section title
        local sectionTitle = Create("TextLabel", {
            Name = "SectionTitle",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 10),
            Size = UDim2.new(1, -30, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = "TBD UI Library",
            TextColor3 = theme.TextPrimary,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = infoSection
        })
        
        -- Version label
        local versionLabel = Create("TextLabel", {
            Name = "VersionLabel",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 35),
            Size = UDim2.new(1, -30, 0, 20),
            Font = Enum.Font.Gotham,
            Text = "Version: " .. TBD.Version,
            TextColor3 = theme.TextSecondary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = infoSection
        })
        
        -- Information text
        local infoText = Create("TextLabel", {
            Name = "InfoText",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 60),
            Size = UDim2.new(1, -30, 0, 50),
            Font = Enum.Font.Gotham,
            Text = "Customize your experience using the tabs on the left side. Each tab contains different features and settings.",
            TextColor3 = theme.TextSecondary,
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = infoSection
        })
    end
    
    -- Create window object
    local windowObj = {
        GUI = gui,
        Window = window,
        Header = header,
        ContentContainer = contentContainer,
        TabButtons = tabButtons,
        TabPages = tabPages,
        HomePage = homePage,
        Size = {
            Width = windowWidth,
            Height = windowHeight
        },
        Tabs = {},
        ActiveTab = nil,
        _tabButtonConnections = {},
        _minimized = false,
        _minimizeKey = options.MinimizeKey,
        _theme = theme
    }
    
    -- Setup close button
    ConnectTouchInput(closeButton, function()
        -- Destroy window with animation
        pcall(function()
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint)
            local tween = services.TweenService:Create(window, tweenInfo, {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1
            })
            tween:Play()
            
            tween.Completed:Connect(function()
                gui:Destroy()
                
                -- Remove from windows table
                for i, win in pairs(TBD.Windows) do
                    if win == windowObj then
                        table.remove(TBD.Windows, i)
                        break
                    end
                end
            end)
        end)
    end)
    
    -- Setup minimize button
    ConnectTouchInput(minimizeButton, function()
        windowObj:Minimize()
    end)
    
    -- Make window draggable with improved function
    MakeDraggable(window, header, gui)
    
    -- Handle home button
    ConnectTouchInput(homeButton, function()
        windowObj:SetActiveTab("HomePage")
    end)
    
    -- Handle minimize keybind
    pcall(function()
        services.UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == options._minimizeKey then
                windowObj:Minimize()
            end
        end)
    end)
    
    -- Maximize/minimize function
    function windowObj:Minimize()
        if self._minimized then
            -- Maximize
            pcall(function()
                local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint)
                local tween = services.TweenService:Create(self.Window, tweenInfo, {
                    Size = UDim2.new(0, self.Size.Width, 0, self.Size.Height)
                })
                tween:Play()
            end)
            self._minimized = false
        else
            -- Minimize
            pcall(function()
                local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint)
                local tween = services.TweenService:Create(self.Window, tweenInfo, {
                    Size = UDim2.new(0, self.Size.Width, 0, 40)
                })
                tween:Play()
            end)
            self._minimized = true
        end
    end
    
    -- Set active tab function
    function windowObj:SetActiveTab(tabName)
        -- Disable all tabs
        for name, tab in pairs(self.Tabs) do
            pcall(function()
                tab.Button.ImageColor3 = self._theme.TextSecondary
                tab.Page.Visible = false
            end)
        end
        
        -- Disable home page
        self.HomePage.Visible = false
        homeButton.ImageColor3 = self._theme.TextSecondary
        
        -- If it's the home page
        if tabName == "HomePage" then
            self.HomePage.Visible = true
            homeButton.ImageColor3 = self._theme.Accent
            self.ActiveTab = "HomePage"
            return
        end
        
        -- Enable selected tab
        local tab = self.Tabs[tabName]
        if tab then
            tab.Button.ImageColor3 = self._theme.Accent
            tab.Page.Visible = true
            self.ActiveTab = tabName
        end
    end
    
    -- Create tab function
    function windowObj:CreateTab(options)
        options = options or {}
        options.Name = options.Name or "Tab"
        options.Icon = options.Icon or "home"
        
        -- Determine icon (string name or direct asset id)
        local iconId = Icons[options.Icon] or options.Icon
        
        -- Create tab button
        local tabButton = Create("ImageButton", {
            Name = options.Name .. "Button",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 24, 0, 24),
            Image = iconId,
            ImageColor3 = self._theme.TextSecondary,
            LayoutOrder = #self.Tabs + 1,
            Parent = self.TabButtons
        })
        
        -- Create tab page
        local tabPage = Create("ScrollingFrame", {
            Name = options.Name .. "Page",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = self._theme.Accent,
            Visible = false,
            Parent = self.TabPages
        })
        
        -- Add padding to tab page
        local tabPagePadding = Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
            Parent = tabPage
        })
        
        -- Add list layout to tab page
        local tabPageLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = tabPage
        })
        
        -- Store tab info
        local tab = {
            Name = options.Name,
            Button = tabButton,
            Page = tabPage,
            Elements = {}
        }
        
        -- Connect button
        local connection = ConnectTouchInput(tabButton, function()
            self:SetActiveTab(options.Name)
        end)
        
        -- Store connection for cleanup
        table.insert(self._tabButtonConnections, connection)
        
        -- Add tab to tabs table
        self.Tabs[options.Name] = tab
        
        -- If this is the first tab, set it as active
        if #self.Tabs == 1 and not options.ShowHomePage then
            self:SetActiveTab(options.Name)
        end
        
        -- Tab methods
        
        -- Create button
        function tab:CreateButton(options)
            options = options or {}
            options.Name = options.Name or "Button"
            options.Callback = options.Callback or function() end
            
            -- Create button
            local button = Create("Frame", {
                Name = options.Name .. "Button",
                BackgroundColor3 = windowObj._theme.Primary,
                Size = UDim2.new(1, 0, 0, 40),
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
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Font = Enum.Font.Gotham,
                Text = options.Name,
                TextColor3 = windowObj._theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = button
            })
            
            -- Add button icon
            local buttonIcon = Create("ImageLabel", {
                Name = "Icon",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -30, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                AnchorPoint = Vector2.new(0, 0.5),
                Image = "rbxassetid://7733964530",
                ImageColor3 = windowObj._theme.TextSecondary,
                Parent = button
            })
            
            -- Create ripple effect container
            local rippleContainer = Create("Frame", {
                Name = "RippleContainer",
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 2,
                Parent = button
            })
            
            -- Add corner radius to ripple container
            local rippleContainerCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = rippleContainer
            })
            
            -- Make button interactive
            ConnectTouchInput(button, function()
                -- Create ripple effect
                local ripple = Create("Frame", {
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.8,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BorderSizePixel = 0,
                    Parent = rippleContainer
                })
                
                -- Add corner radius to ripple
                local rippleCorner = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ripple
                })
                
                -- Animate ripple
                pcall(function()
                    local targetSize = UDim2.new(0, button.AbsoluteSize.X * 1.5, 0, button.AbsoluteSize.X * 1.5)
                    
                    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                    local tween = services.TweenService:Create(ripple, tweenInfo, {
                        Size = targetSize,
                        BackgroundTransparency = 1
                    })
                    tween:Play()
                    
                    tween.Completed:Connect(function()
                        ripple:Destroy()
                    end)
                end)
                
                -- Call callback with error handling
                local success, result = pcall(options.Callback)
                if not success then
                    -- Print error but don't interrupt execution
                    print("TBD UI Library | Button Callback Error: " .. tostring(result))
                end
            end)
            
            -- Store button
            local buttonObj = {
                Frame = button,
                Label = buttonLabel,
                Icon = buttonIcon
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
            
            -- Create toggle
            local toggle = Create("Frame", {
                Name = options.Name .. "Toggle",
                BackgroundColor3 = windowObj._theme.Primary,
                Size = UDim2.new(1, 0, 0, 40),
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
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Font = Enum.Font.Gotham,
                Text = options.Name,
                TextColor3 = windowObj._theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggle
            })
            
            -- Create toggle indicator background
            local toggleBackground = Create("Frame", {
                Name = "Background",
                BackgroundColor3 = windowObj._theme.Secondary,
                Position = UDim2.new(1, -45, 0.5, 0),
                Size = UDim2.new(0, 30, 0, 16),
                AnchorPoint = Vector2.new(0, 0.5),
                Parent = toggle
            })
            
            -- Add corner radius to toggle background
            local toggleBackgroundCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggleBackground
            })
            
            -- Create toggle indicator
            local toggleIndicator = Create("Frame", {
                Name = "Indicator",
                BackgroundColor3 = windowObj._theme.TextSecondary,
                Position = UDim2.new(0, 3, 0.5, 0),
                Size = UDim2.new(0, 10, 0, 10),
                AnchorPoint = Vector2.new(0, 0.5),
                Parent = toggleBackground
            })
            
            -- Add corner radius to toggle indicator
            local toggleIndicatorCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggleIndicator
            })
            
            -- Create toggle state variable
            local state = options.Default
            
            -- Function to update toggle state
            local function updateToggle(newState)
                state = newState
                
                pcall(function()
                    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint)
                    
                    if state then
                        -- Toggle on
                        services.TweenService:Create(toggleBackground, tweenInfo, {
                            BackgroundColor3 = windowObj._theme.Accent
                        }):Play()
                        
                        services.TweenService:Create(toggleIndicator, tweenInfo, {
                            Position = UDim2.new(1, -13, 0.5, 0),
                            BackgroundColor3 = Color3.new(1, 1, 1)
                        }):Play()
                    else
                        -- Toggle off
                        services.TweenService:Create(toggleBackground, tweenInfo, {
                            BackgroundColor3 = windowObj._theme.Secondary
                        }):Play()
                        
                        services.TweenService:Create(toggleIndicator, tweenInfo, {
                            Position = UDim2.new(0, 3, 0.5, 0),
                            BackgroundColor3 = windowObj._theme.TextSecondary
                        }):Play()
                    end
                end)
                
                -- Call callback with error handling
                pcall(function()
                    options.Callback(state)
                end)
            end
            
            -- Initialize toggle to default state
            updateToggle(options.Default)
            
            -- Make toggle interactive
            ConnectTouchInput(toggle, function()
                updateToggle(not state)
            end)
            
            -- Store toggle object
            local toggleObj = {
                Frame = toggle,
                Label = toggleLabel,
                Background = toggleBackground,
                Indicator = toggleIndicator,
                Value = state,
                
                -- Set toggle externally
                Set = function(self, newState)
                    updateToggle(newState)
                    self.Value = newState
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
            
            -- Validate and adjust options
            options.Default = math.clamp(options.Default, options.Min, options.Max)
            
            -- Create slider
            local slider = Create("Frame", {
                Name = options.Name .. "Slider",
                BackgroundColor3 = windowObj._theme.Primary,
                Size = UDim2.new(1, 0, 0, 50),
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
                Position = UDim2.new(0, 15, 0, 8),
                Size = UDim2.new(1, -30, 0, 14),
                Font = Enum.Font.Gotham,
                Text = options.Name,
                TextColor3 = windowObj._theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = slider
            })
            
            -- Add slider value
            local sliderValue = Create("TextLabel", {
                Name = "Value",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -60, 0, 8),
                Size = UDim2.new(0, 50, 0, 14),
                Font = Enum.Font.Gotham,
                Text = options.Default .. options.ValueSuffix,
                TextColor3 = windowObj._theme.TextSecondary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = slider
            })
            
            -- Create slider bar container
            local sliderBar = Create("Frame", {
                Name = "SliderBar",
                BackgroundColor3 = windowObj._theme.Secondary,
                Position = UDim2.new(0, 15, 0, 32),
                Size = UDim2.new(1, -30, 0, 6),
                Parent = slider
            })
            
            -- Add corner radius to slider bar
            local sliderBarCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderBar
            })
            
            -- Create slider fill
            local sliderFill = Create("Frame", {
                Name = "Fill",
                BackgroundColor3 = windowObj._theme.Accent,
                Size = UDim2.new(0, 0, 1, 0),
                Parent = sliderBar
            })
            
            -- Add corner radius to slider fill
            local sliderFillCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderFill
            })
            
            -- Create slider knob
            local sliderKnob = Create("Frame", {
                Name = "Knob",
                BackgroundColor3 = Color3.new(1, 1, 1),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(0, 14, 0, 14),
                Parent = sliderBar
            })
            
            -- Add corner radius to slider knob
            local sliderKnobCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderKnob
            })
            
            -- Create current value variable
            local value = options.Default
            
            -- Function to update slider value
            local function updateSlider(newValue)
                -- Clamp and increment value
                local range = options.Max - options.Min
                local steps = range / options.Increment
                local stepSize = 1 / steps
                
                -- Calculate nearest step
                local relativeValue = (newValue - options.Min) / range
                local nearestStep = math.floor(relativeValue / stepSize + 0.5) * stepSize
                
                -- Calculate actual value from step
                newValue = options.Min + nearestStep * range
                
                -- Clamp between min and max
                newValue = math.clamp(newValue, options.Min, options.Max)
                
                -- Round to avoid floating point issues
                local decimals = 0
                if options.Increment < 1 then
                    decimals = math.floor(math.log10(1 / options.Increment) + 0.5)
                end
                newValue = math.floor(newValue * 10^decimals + 0.5) / 10^decimals
                
                -- Update value
                value = newValue
                
                -- Update UI
                pcall(function()
                    -- Update text
                    sliderValue.Text = value .. options.ValueSuffix
                    
                    -- Update fill and knob position
                    local fillSize = (value - options.Min) / (options.Max - options.Min)
                    sliderFill.Size = UDim2.new(fillSize, 0, 1, 0)
                    sliderKnob.Position = UDim2.new(fillSize, 0, 0.5, 0)
                    
                    -- Call callback
                    options.Callback(value)
                end)
            end
            
            -- Initialize slider to default value
            updateSlider(options.Default)
            
            -- Helper function to get value from slider position
            local function getValueFromPosition(posX)
                -- Safely get slider bar position and size
                local sliderBarPos = 0
                local sliderBarWidth = 100
                
                pcall(function()
                    sliderBarPos = sliderBar.AbsolutePosition.X
                    sliderBarWidth = sliderBar.AbsoluteSize.X
                end)
                
                local relativePos = math.clamp((posX - sliderBarPos) / sliderBarWidth, 0, 1)
                local newValue = options.Min + relativePos * (options.Max - options.Min)
                return newValue
            end
            
            -- Handle slider interaction - with direct position updates for better drag response
            local isDragging = false
            
            -- Handle slider click
            ConnectTouchInput(sliderBar, function(input)
                -- Get value from input position
                local newValue = getValueFromPosition(input.Position.X)
                updateSlider(newValue)
                
                -- Start dragging
                isDragging = true
                
                -- Ensure we handle input ending
                pcall(function()
                    local dragConnection
                    dragConnection = services.UserInputService.InputChanged:Connect(function(dragInput)
                        if isDragging and (dragInput.UserInputType == Enum.UserInputType.MouseMovement or 
                                         dragInput.UserInputType == Enum.UserInputType.Touch) then
                            local newValue = getValueFromPosition(dragInput.Position.X)
                            updateSlider(newValue)
                        end
                    end)
                    
                    -- Connect a one-time use ended event
                    local endConnection
                    endConnection = services.UserInputService.InputEnded:Connect(function(inputEnd)
                        if inputEnd == input then
                            isDragging = false
                            endConnection:Disconnect()
                            dragConnection:Disconnect()
                        end
                    end)
                end)
            end)
            
            -- Connect to knob as well for better usability
            ConnectTouchInput(sliderKnob, function(input)
                -- Get value from input position
                local newValue = getValueFromPosition(input.Position.X)
                updateSlider(newValue)
                
                -- Start dragging
                isDragging = true
                
                -- Ensure we handle input ending
                pcall(function()
                    local dragConnection
                    dragConnection = services.UserInputService.InputChanged:Connect(function(dragInput)
                        if isDragging and (dragInput.UserInputType == Enum.UserInputType.MouseMovement or 
                                         dragInput.UserInputType == Enum.UserInputType.Touch) then
                            local newValue = getValueFromPosition(dragInput.Position.X)
                            updateSlider(newValue)
                        end
                    end)
                    
                    -- Connect a one-time use ended event
                    local endConnection
                    endConnection = services.UserInputService.InputEnded:Connect(function(inputEnd)
                        if inputEnd == input then
                            isDragging = false
                            endConnection:Disconnect()
                            dragConnection:Disconnect()
                        end
                    end)
                end)
            end)
            
            -- Store slider object
            local sliderObj = {
                Frame = slider,
                Label = sliderLabel,
                Value = value,
                
                -- Set slider externally
                Set = function(self, newValue)
                    updateSlider(newValue)
                    self.Value = value
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
            
            -- Create dropdown
            local dropdown = Create("Frame", {
                Name = options.Name .. "Dropdown",
                BackgroundColor3 = windowObj._theme.Primary,
                Size = UDim2.new(1, 0, 0, 40),
                ClipsDescendants = true,
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
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -30, 0, 40),
                Font = Enum.Font.Gotham,
                Text = options.Name,
                TextColor3 = windowObj._theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdown
            })
            
            -- Current selection display
            local dropdownSelected = Create("TextLabel", {
                Name = "Selected",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -130, 0, 0),
                Size = UDim2.new(0, 100, 0, 40),
                Font = Enum.Font.Gotham,
                Text = options.Default,
                TextColor3 = windowObj._theme.TextSecondary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = dropdown
            })
            
            -- Dropdown arrow icon
            local dropdownArrow = Create("ImageLabel", {
                Name = "Arrow",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -15, 0.5, 0),
                Size = UDim2.new(0, 12, 0, 12),
                AnchorPoint = Vector2.new(1, 0.5),
                Image = "rbxassetid://7734010105",
                ImageColor3 = windowObj._theme.TextSecondary,
                Parent = dropdown
            })
            
            -- Options container
            local optionsContainer = Create("Frame", {
                Name = "OptionsContainer",
                BackgroundColor3 = windowObj._theme.Secondary,
                Position = UDim2.new(0, 0, 0, 40),
                Size = UDim2.new(1, 0, 0, 0), -- Will be updated based on options
                Parent = dropdown
            })
            
            -- Add corner radius to options container
            local optionsContainerCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = optionsContainer
            })
            
            -- Options list
            local optionsList = Create("ScrollingFrame", {
                Name = "OptionsList",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 5),
                Size = UDim2.new(1, 0, 1, -10),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = windowObj._theme.Accent,
                Parent = optionsContainer
            })
            
            -- Add list layout to options list
            local optionsListLayout = Create("UIListLayout", {
                Padding = UDim.new(0, 5),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = optionsList
            })
            
            -- Add padding to options list
            local optionsListPadding = Create("UIPadding", {
                PaddingTop = UDim.new(0, 2),
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                Parent = optionsList
            })
            
            -- Create dropdown state variables
            local isOpen = false
            local selected = options.Default
            
            -- Function to update selection
            local function updateSelection(newSelection)
                selected = newSelection
                dropdownSelected.Text = selected
                pcall(function()
                    options.Callback(selected)
                end)
            end
            
            -- Function to toggle dropdown
            local function toggleDropdown()
                isOpen = not isOpen
                
                pcall(function()
                    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint)
                    
                    if isOpen then
                        -- Open dropdown
                        services.TweenService:Create(dropdown, tweenInfo, {
                            Size = UDim2.new(1, 0, 0, 40 + optionsContainer.Size.Y.Offset)
                        }):Play()
                        
                        services.TweenService:Create(dropdownArrow, tweenInfo, {
                            Rotation = 180
                        }):Play()
                    else
                        -- Close dropdown
                        services.TweenService:Create(dropdown, tweenInfo, {
                            Size = UDim2.new(1, 0, 0, 40)
                        }):Play()
                        
                        services.TweenService:Create(dropdownArrow, tweenInfo, {
                            Rotation = 0
                        }):Play()
                    end
                end)
            end
            
            -- Add options to dropdown
            for i, option in ipairs(options.Options) do
                local optionButton = Create("TextButton", {
                    Name = "Option" .. i,
                    BackgroundColor3 = windowObj._theme.Primary,
                    Size = UDim2.new(1, -10, 0, 30),
                    Text = "",
                    Parent = optionsList
                })
                
                -- Add corner radius to option button
                local optionButtonCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = optionButton
                })
                
                -- Add option text
                local optionText = Create("TextLabel", {
                    Name = "Text",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = option,
                    TextColor3 = windowObj._theme.TextSecondary,
                    TextSize = 14,
                    Parent = optionButton
                })
                
                -- Handle option selection
                ConnectTouchInput(optionButton, function()
                    updateSelection(option)
                    toggleDropdown()
                end)
            end
            
            -- Update options container size
            local optionsHeight = math.min(#options.Options * 35, 150)
            optionsContainer.Size = UDim2.new(1, 0, 0, optionsHeight)
            
            -- Handle dropdown toggle
            ConnectTouchInput(dropdown, function()
                if not isOpen then
                    toggleDropdown()
                end
            end)
            
            -- Store dropdown object
            local dropdownObj = {
                Frame = dropdown,
                Label = dropdownLabel,
                Selected = dropdownSelected,
                Value = selected,
                
                -- Set dropdown selection externally
                Set = function(self, newSelection)
                    if table.find(options.Options, newSelection) then
                        updateSelection(newSelection)
                        self.Value = newSelection
                    end
                end,
                
                -- Add option to dropdown
                AddOption = function(self, optionText)
                    if not table.find(options.Options, optionText) then
                        table.insert(options.Options, optionText)
                        
                        -- Create option button
                        local optionButton = Create("TextButton", {
                            Name = "Option" .. #options.Options,
                            BackgroundColor3 = windowObj._theme.Primary,
                            Size = UDim2.new(1, -10, 0, 30),
                            Text = "",
                            Parent = optionsList
                        })
                        
                        -- Add corner radius to option button
                        local optionButtonCorner = Create("UICorner", {
                            CornerRadius = UDim.new(0, 4),
                            Parent = optionButton
                        })
                        
                        -- Add option text
                        local optionText = Create("TextLabel", {
                            Name = "Text",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            Font = Enum.Font.Gotham,
                            Text = optionText,
                            TextColor3 = windowObj._theme.TextSecondary,
                            TextSize = 14,
                            Parent = optionButton
                        })
                        
                        -- Handle option selection
                        ConnectTouchInput(optionButton, function()
                            updateSelection(optionText)
                            toggleDropdown()
                        end)
                        
                        -- Update options container size
                        local optionsHeight = math.min(#options.Options * 35, 150)
                        optionsContainer.Size = UDim2.new(1, 0, 0, optionsHeight)
                    end
                end,
                
                -- Remove option from dropdown
                RemoveOption = function(self, optionText)
                    local index = table.find(options.Options, optionText)
                    if index then
                        table.remove(options.Options, index)
                        
                        -- Remove option button
                        for _, child in pairs(optionsList:GetChildren()) do
                            if child:IsA("TextButton") and child.Text.Text == optionText then
                                child:Destroy()
                                break
                            end
                        end
                        
                        -- Update options container size
                        local optionsHeight = math.min(#options.Options * 35, 150)
                        optionsContainer.Size = UDim2.new(1, 0, 0, optionsHeight)
                        
                        -- If selected option was removed, select the first option
                        if selected == optionText and #options.Options > 0 then
                            updateSelection(options.Options[1])
                        end
                    end
                end
            }
            
            table.insert(self.Elements, dropdownObj)
            return dropdownObj
        end
        
        -- Create color picker
        function tab:CreateColorPicker(options)
            options = options or {}
            options.Name = options.Name or "Color Picker"
            options.Default = options.Default or Color3.fromRGB(255, 0, 0)
            options.Callback = options.Callback or function() end
            
            -- Create container
            local colorPicker = Create("Frame", {
                Name = options.Name .. "ColorPicker",
                BackgroundColor3 = windowObj._theme.Primary,
                Size = UDim2.new(1, 0, 0, 40),
                ClipsDescendants = true,
                Parent = self.Page
            })
            
            -- Add corner radius
            local colorPickerCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = colorPicker
            })
            
            -- Add label
            local colorPickerLabel = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -70, 0, 40),
                Font = Enum.Font.Gotham,
                Text = options.Name,
                TextColor3 = windowObj._theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = colorPicker
            })
            
            -- Color display
            local colorDisplay = Create("Frame", {
                Name = "ColorDisplay",
                BackgroundColor3 = options.Default,
                Position = UDim2.new(1, -35, 0.5, 0),
                Size = UDim2.new(0, 25, 0, 25),
                AnchorPoint = Vector2.new(0, 0.5),
                Parent = colorPicker
            })
            
            -- Add corner radius to color display
            local colorDisplayCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = colorDisplay
            })
            
            -- Color picker expanded container
            local expandedContainer = Create("Frame", {
                Name = "ExpandedContainer",
                BackgroundColor3 = windowObj._theme.Secondary,
                Position = UDim2.new(0, 0, 0, 40),
                Size = UDim2.new(1, 0, 0, 120),
                Parent = colorPicker
            })
            
            -- Add corner radius to expanded container
            local expandedContainerCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = expandedContainer
            })
            
            -- Color saturation/value picker
            local saturationPicker = Create("ImageLabel", {
                Name = "SaturationPicker",
                BackgroundColor3 = Color3.fromRGB(255, 0, 0), -- Will be set to current hue
                Position = UDim2.new(0, 10, 0, 10),
                Size = UDim2.new(0, 160, 0, 100),
                Image = "rbxassetid://4155801252",
                Parent = expandedContainer
            })
            
            -- Add corner radius to saturation picker
            local saturationPickerCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = saturationPicker
            })
            
            -- Saturation selector
            local saturationSelector = Create("Frame", {
                Name = "Selector",
                BackgroundColor3 = Color3.new(1, 1, 1),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(1, 0, 0, 0), -- Will be updated based on selected color
                Size = UDim2.new(0, 8, 0, 8),
                Parent = saturationPicker
            })
            
            -- Add corner radius to saturation selector
            local saturationSelectorCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = saturationSelector
            })
            
            -- Hue picker
            local huePicker = Create("Frame", {
                Name = "HuePicker",
                BackgroundColor3 = Color3.new(1, 1, 1),
                Position = UDim2.new(1, -30, 0, 10),
                Size = UDim2.new(0, 20, 0, 100),
                Parent = expandedContainer
            })
            
            -- Add corner radius to hue picker
            local huePickerCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = huePicker
            })
            
            -- Create hue gradient
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
                Rotation = 90,
                Parent = huePicker
            })
            
            -- Hue selector
            local hueSelector = Create("Frame", {
                Name = "Selector",
                BackgroundColor3 = Color3.new(1, 1, 1),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0, 0), -- Will be updated based on selected hue
                Size = UDim2.new(1, 4, 0, 5),
                Parent = huePicker
            })
            
            -- Add corner radius to hue selector
            local hueSelectorCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 2),
                Parent = hueSelector
            })
            
            -- Create color state variables
            local isOpen = false
            local selectedColor = options.Default
            local h, s, v = 0, 0, 0
            
            -- Function to convert HSV to RGB
            local function HSVToRGB(h, s, v)
                local r, g, b
                
                local i = math.floor(h * 6)
                local f = h * 6 - i
                local p = v * (1 - s)
                local q = v * (1 - f * s)
                local t = v * (1 - (1 - f) * s)
                
                i = i % 6
                
                if i == 0 then
                    r, g, b = v, t, p
                elseif i == 1 then
                    r, g, b = q, v, p
                elseif i == 2 then
                    r, g, b = p, v, t
                elseif i == 3 then
                    r, g, b = p, q, v
                elseif i == 4 then
                    r, g, b = t, p, v
                elseif i == 5 then
                    r, g, b = v, p, q
                end
                
                return Color3.new(r, g, b)
            end
            
            -- Function to convert RGB to HSV
            local function RGBToHSV(color)
                local r, g, b = color.R, color.G, color.B
                local max, min = math.max(r, g, b), math.min(r, g, b)
                local h, s, v
                
                v = max
                
                if max == 0 then
                    s = 0
                else
                    s = (max - min) / max
                end
                
                if max == min then
                    h = 0
                else
                    if max == r then
                        h = (g - b) / (max - min)
                        if g < b then
                            h = h + 6
                        end
                    elseif max == g then
                        h = (b - r) / (max - min) + 2
                    elseif max == b then
                        h = (r - g) / (max - min) + 4
                    end
                    h = h / 6
                end
                
                return h, s, v
            end
            
            -- Initialize color picker with default color
            h, s, v = RGBToHSV(options.Default)
            
            -- Update selectors position based on HSV
            local function updateSelectors()
                saturationPicker.BackgroundColor3 = HSVToRGB(h, 1, 1)
                saturationSelector.Position = UDim2.new(s, 0, 1 - v, 0)
                hueSelector.Position = UDim2.new(0.5, 0, h, 0)
            end
            
            -- Update color based on HSV
            local function updateColor()
                selectedColor = HSVToRGB(h, s, v)
                colorDisplay.BackgroundColor3 = selectedColor
                options.Callback(selectedColor)
            end
            
            -- Initial update
            updateSelectors()
            updateColor()
            
            -- Function to toggle color picker
            local function toggleColorPicker()
                isOpen = not isOpen
                
                pcall(function()
                    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint)
                    
                    if isOpen then
                        -- Open color picker
                        services.TweenService:Create(colorPicker, tweenInfo, {
                            Size = UDim2.new(1, 0, 0, 170)
                        }):Play()
                    else
                        -- Close color picker
                        services.TweenService:Create(colorPicker, tweenInfo, {
                            Size = UDim2.new(1, 0, 0, 40)
                        }):Play()
                    end
                end)
            end
            
            -- Handle color display click to toggle
            ConnectTouchInput(colorDisplay, function()
                toggleColorPicker()
            end)
            
            -- Improved touch/mouse handling for hue selection
            local hueSelecting = false
            
            ConnectTouchInput(huePicker, function(input)
                hueSelecting = true
                
                -- Calculate hue from input position
                local yOffset = math.clamp(input.Position.Y - huePicker.AbsolutePosition.Y, 0, huePicker.AbsoluteSize.Y)
                h = yOffset / huePicker.AbsoluteSize.Y
                
                -- Update color without tweening for immediate feedback
                updateSelectors()
                updateColor()
                
                -- Add mouse movement tracking
                local moveConnection
                moveConnection = services.UserInputService.InputChanged:Connect(function(changeInput)
                    if hueSelecting and (changeInput.UserInputType == Enum.UserInputType.MouseMovement or 
                                     changeInput.UserInputType == Enum.UserInputType.Touch) then
                        local yOffset = math.clamp(changeInput.Position.Y - huePicker.AbsolutePosition.Y, 0, huePicker.AbsoluteSize.Y)
                        h = yOffset / huePicker.AbsoluteSize.Y
                        updateSelectors()
                        updateColor()
                    end
                end)
                
                -- Add one-time end connection
                local endConnection
                endConnection = services.UserInputService.InputEnded:Connect(function(endInput)
                    if endInput == input then
                        hueSelecting = false
                        if moveConnection then moveConnection:Disconnect() end
                        endConnection:Disconnect()
                    end
                end)
            end)
            
            -- Improved touch/mouse handling for saturation/value selection
            local saturationSelecting = false
            
            ConnectTouchInput(saturationPicker, function(input)
                saturationSelecting = true
                
                -- Calculate saturation and value from input position
                local xOffset = math.clamp(input.Position.X - saturationPicker.AbsolutePosition.X, 0, saturationPicker.AbsoluteSize.X)
                local yOffset = math.clamp(input.Position.Y - saturationPicker.AbsolutePosition.Y, 0, saturationPicker.AbsoluteSize.Y)
                
                s = xOffset / saturationPicker.AbsoluteSize.X
                v = 1 - (yOffset / saturationPicker.AbsoluteSize.Y)
                
                -- Update color without tweening for immediate feedback
                updateSelectors()
                updateColor()
                
                -- Add mouse movement tracking
                local moveConnection
                moveConnection = services.UserInputService.InputChanged:Connect(function(changeInput)
                    if saturationSelecting and (changeInput.UserInputType == Enum.UserInputType.MouseMovement or 
                                           changeInput.UserInputType == Enum.UserInputType.Touch) then
                        local xOffset = math.clamp(changeInput.Position.X - saturationPicker.AbsolutePosition.X, 0, saturationPicker.AbsoluteSize.X)
                        local yOffset = math.clamp(changeInput.Position.Y - saturationPicker.AbsolutePosition.Y, 0, saturationPicker.AbsoluteSize.Y)
                        
                        s = xOffset / saturationPicker.AbsoluteSize.X
                        v = 1 - (yOffset / saturationPicker.AbsoluteSize.Y)
                        
                        updateSelectors()
                        updateColor()
                    end
                end)
                
                -- Add one-time end connection
                local endConnection
                endConnection = services.UserInputService.InputEnded:Connect(function(endInput)
                    if endInput == input then
                        saturationSelecting = false
                        if moveConnection then moveConnection:Disconnect() end
                        endConnection:Disconnect()
                    end
                end)
            end)
            
            -- Store color picker object
            local colorPickerObj = {
                Frame = colorPicker,
                Label = colorPickerLabel,
                Display = colorDisplay,
                Value = selectedColor,
                
                -- Set color externally
                Set = function(self, newColor)
                    h, s, v = RGBToHSV(newColor)
                    updateSelectors()
                    updateColor()
                    self.Value = selectedColor
                end
            }
            
            table.insert(self.Elements, colorPickerObj)
            return colorPickerObj
        end
        
        -- Create text box
        function tab:CreateTextBox(options)
            options = options or {}
            options.Name = options.Name or "Text Box"
            options.PlaceholderText = options.PlaceholderText or "Enter text..."
            options.DefaultText = options.DefaultText or ""
            options.ClearOnFocus = options.ClearOnFocus ~= nil and options.ClearOnFocus or true
            options.Callback = options.Callback or function() end
            
            -- Create container
            local textBox = Create("Frame", {
                Name = options.Name .. "TextBox",
                BackgroundColor3 = windowObj._theme.Primary,
                Size = UDim2.new(1, 0, 0, 40),
                Parent = self.Page
            })
            
            -- Add corner radius
            local textBoxCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = textBox
            })
            
            -- Add label
            local textBoxLabel = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(0.5, -20, 1, 0),
                Font = Enum.Font.Gotham,
                Text = options.Name,
                TextColor3 = windowObj._theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = textBox
            })
            
            -- Input field background
            local inputBackground = Create("Frame", {
                Name = "InputBackground",
                BackgroundColor3 = windowObj._theme.Secondary,
                Position = UDim2.new(1, -150, 0.5, 0),
                Size = UDim2.new(0, 140, 0, 30),
                AnchorPoint = Vector2.new(0, 0.5),
                Parent = textBox
            })
            
            -- Add corner radius to input background
            local inputBackgroundCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = inputBackground
            })
            
            -- Create text box
            local inputBox = Create("TextBox", {
                Name = "InputBox",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0, 0),
                Size = UDim2.new(1, -16, 1, 0),
                Font = Enum.Font.Gotham,
                PlaceholderText = options.PlaceholderText,
                Text = options.DefaultText,
                TextColor3 = windowObj._theme.TextPrimary,
                PlaceholderColor3 = windowObj._theme.TextSecondary,
                TextSize = 14,
                ClearTextOnFocus = options.ClearOnFocus,
                Parent = inputBackground
            })
            
            -- Handle input box events
            pcall(function()
                inputBox.FocusLost:Connect(function(enterPressed)
                    options.Callback(inputBox.Text)
                end)
            end)
            
            -- Store text box object
            local textBoxObj = {
                Frame = textBox,
                Label = textBoxLabel,
                Input = inputBox,
                Value = inputBox.Text,
                
                -- Set text externally
                Set = function(self, newText)
                    inputBox.Text = newText
                    self.Value = newText
                end
            }
            
            table.insert(self.Elements, textBoxObj)
            return textBoxObj
        end
        
        -- Create keybind
        function tab:CreateKeybind(options)
            options = options or {}
            options.Name = options.Name or "Keybind"
            options.Default = options.Default or Enum.KeyCode.F
            options.Callback = options.Callback or function() end
            options.ChangedCallback = options.ChangedCallback or function() end
            
            -- Create container
            local keybind = Create("Frame", {
                Name = options.Name .. "Keybind",
                BackgroundColor3 = windowObj._theme.Primary,
                Size = UDim2.new(1, 0, 0, 40),
                Parent = self.Page
            })
            
            -- Add corner radius
            local keybindCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = keybind
            })
            
            -- Add label
            local keybindLabel = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(0.5, -20, 1, 0),
                Font = Enum.Font.Gotham,
                Text = options.Name,
                TextColor3 = windowObj._theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = keybind
            })
            
            -- Keybind button
            local keybindButton = Create("TextButton", {
                Name = "KeybindButton",
                BackgroundColor3 = windowObj._theme.Secondary,
                Position = UDim2.new(1, -100, 0.5, 0),
                Size = UDim2.new(0, 90, 0, 30),
                AnchorPoint = Vector2.new(0, 0.5),
                Font = Enum.Font.Gotham,
                Text = options.Default.Name,
                TextColor3 = windowObj._theme.TextSecondary,
                TextSize = 13,
                Parent = keybind
            })
            
            -- Add corner radius to keybind button
            local keybindButtonCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = keybindButton
            })
            
            -- Create keybind state variables
            local selectedKey = options.Default
            local isBinding = false
            
            -- Function to update keybind
            local function updateKeybind(newKey)
                selectedKey = newKey
                keybindButton.Text = selectedKey.Name
                options.ChangedCallback(selectedKey)
            end
            
            -- Connect button
            ConnectTouchInput(keybindButton, function()
                if isBinding then return end
                
                isBinding = true
                keybindButton.Text = "..."
                
                -- Handle key press
                local connection
                connection = services.UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        updateKeybind(input.KeyCode)
                        isBinding = false
                        connection:Disconnect()
                    end
                end)
            end)
            
            -- Connect key press to callback
            pcall(function()
                services.UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == selectedKey and not isBinding then
                        options.Callback()
                    end
                end)
            end)
            
            -- Store keybind object
            local keybindObj = {
                Frame = keybind,
                Label = keybindLabel,
                Button = keybindButton,
                Value = selectedKey,
                
                -- Set keybind externally
                Set = function(self, newKey)
                    updateKeybind(newKey)
                    self.Value = selectedKey
                end
            }
            
            table.insert(self.Elements, keybindObj)
            return keybindObj
        end
        
        -- Create label
        function tab:CreateLabel(options)
            options = options or {}
            options.Text = options.Text or "Label"
            
            -- Create label
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
        
        -- Create paragraph
        function tab:CreateParagraph(options)
            options = options or {}
            options.Title = options.Title or "Title"
            options.Content = options.Content or "Content"
            
            -- Calculate height based on content
            local titleHeight = 22
            local contentLines = 1
            local contentHeight = 0
            
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
        
        -- Create separator
        function tab:CreateSeparator()
            -- Create separator
            local separator = Create("Frame", {
                Name = "Separator",
                BackgroundColor3 = windowObj._theme.Secondary,
                Size = UDim2.new(1, 0, 0, 1),
                Parent = self.Page
            })
            
            -- Store separator object
            local separatorObj = {
                Frame = separator
            }
            
            table.insert(self.Elements, separatorObj)
            return separatorObj
        end
        
        -- For compatibility with both CreateColorPicker and CreateColorpicker names
        tab.CreateColorpicker = tab.CreateColorPicker
        
        return tab
    end
    
    -- Update theme for window and all components
    function windowObj:_updateTheme()
        local theme = TBD._theme
        
        pcall(function()
            -- Update window elements
            self.Window.BackgroundColor3 = theme.Background
            self.Header.BackgroundColor3 = theme.Primary
            self.Header.Cover.BackgroundColor3 = theme.Primary
            self.ContentContainer.Sidebar.BackgroundColor3 = theme.Primary
            self.ContentContainer.Sidebar.Cover.BackgroundColor3 = theme.Primary
            
            -- Update text elements
            self.Header.Title.TextColor3 = theme.TextPrimary
            self.Header.Subtitle.TextColor3 = theme.TextSecondary
            
            -- Update home button
            if self.ActiveTab == "HomePage" then
                self.ContentContainer.Sidebar.HomeButton.ImageColor3 = theme.Accent
            else
                self.ContentContainer.Sidebar.HomeButton.ImageColor3 = theme.TextSecondary
            end
            
            -- Update tab buttons
            for name, tab in pairs(self.Tabs) do
                if name == self.ActiveTab then
                    tab.Button.ImageColor3 = theme.Accent
                else
                    tab.Button.ImageColor3 = theme.TextSecondary
                end
                
                -- Update tab page scrollbar
                tab.Page.ScrollBarImageColor3 = theme.Accent
                
                -- Update elements
                for _, element in ipairs(tab.Elements) do
                    if element.Frame then
                        -- Common properties
                        if element.Frame.BackgroundTransparency <= 0 then
                            element.Frame.BackgroundColor3 = theme.Primary
                        end
                        
                        -- Update text colors
                        if element.Label then
                            element.Label.TextColor3 = theme.TextPrimary
                        end
                        
                        if element.Text then
                            element.Text.TextColor3 = theme.TextPrimary
                        end
                        
                        -- Update specialized elements
                        if element.Frame.Name:find("Toggle") then
                            element.Background.BackgroundColor3 = theme.Secondary
                            
                            if element.Value then
                                element.Background.BackgroundColor3 = theme.Accent
                                element.Indicator.BackgroundColor3 = Color3.new(1, 1, 1)
                            else
                                element.Indicator.BackgroundColor3 = theme.TextSecondary
                            end
                        elseif element.Frame.Name:find("Slider") then
                            element.Frame.SliderBar.BackgroundColor3 = theme.Secondary
                            element.Frame.SliderBar.Fill.BackgroundColor3 = theme.Accent
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
                    end
                end
            end
        end)
    end
    
    -- Add window to windows table
    table.insert(TBD.Windows, windowObj)
    
    -- Initialize home page
    windowObj:SetActiveTab(options.ShowHomePage and "HomePage" or nil)
    
    return windowObj
end

-- Add Notification convenience method
function TBD:Notification(options)
    self:_EnsureInitialized()
    
    return self.NotificationSystem:CreateNotification(options)
end

return TBD
