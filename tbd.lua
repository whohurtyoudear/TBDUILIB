--[[
    TBD UI Library
    A modern, feature-rich Roblox UI library for script hubs and executors
    Developed by TBD Development Team
    Version 1.0.0
]]

local TBD = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

-- Constants and Settings
local ANIMATION_DURATION = 0.3
local DEFAULT_FONT = Enum.Font.GothamSemibold
local CORNER_RADIUS = UDim.new(0, 8)
local ELEMENT_HEIGHT = 38
local LIBRARY_NAME = "TBD"

-- Utility Functions
local function Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

local function FormatNumber(number, decimals)
    decimals = decimals or 0
    local multiplier = 10 ^ decimals
    return math.floor(number * multiplier + 0.5) / multiplier
end

local function GetTextDimensions(text, size, font, constraints)
    return TextService:GetTextSize(text, size, font, constraints)
end

local function EnableDragging(frame, dragArea)
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    dragArea = dragArea or frame
    
    local function updatePosition(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
    
    dragArea.InputBegan:Connect(function(input)
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
    
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updatePosition(input)
        end
    end)
end

-- Icon System
local IconSets = {
    -- Material Design Icons
    Material = {
        home = "rbxassetid://8150151167",
        settings = "rbxassetid://8150195458",
        search = "rbxassetid://8150196653",
        close = "rbxassetid://8150173955",
        add = "rbxassetid://8150151689",
        remove = "rbxassetid://8150194957",
        warning = "rbxassetid://8150196918",
        info = "rbxassetid://8150191115",
        check = "rbxassetid://8150173757",
        error = "rbxassetid://8150187174",
        notification = "rbxassetid://8150193276",
        folder = "rbxassetid://8150189972",
        person = "rbxassetid://8150193811",
        star = "rbxassetid://8150195767",
        favorite = "rbxassetid://8150188741",
        dashboard = "rbxassetid://8150175730",
        code = "rbxassetid://8150173955",
        games = "rbxassetid://8150190005",
    },
    -- Phosphor Icons (Modern Minimalist)
    Phosphor = {
        home = "rbxassetid://9478584776",
        settings = "rbxassetid://9478586042",
        search = "rbxassetid://9478585913",
        close = "rbxassetid://9478584163",
        add = "rbxassetid://9478583892",
        remove = "rbxassetid://9478585791",
        warning = "rbxassetid://9478586169",
        info = "rbxassetid://9478584545",
        check = "rbxassetid://9478584093",
        error = "rbxassetid://9478584415",
        notification = "rbxassetid://9478584648",
        folder = "rbxassetid://9478584487",
        person = "rbxassetid://9478585025",
        star = "rbxassetid://9478586080",
        favorite = "rbxassetid://9478584455",
        dashboard = "rbxassetid://9478584304",
        code = "rbxassetid://9478584243",
        games = "rbxassetid://9478584518",
    }
}

-- Theme System
local ThemePresets = {
    Default = {
        Primary = Color3.fromRGB(64, 90, 255),
        PrimaryDark = Color3.fromRGB(44, 70, 235),
        Background = Color3.fromRGB(18, 20, 26),
        ContainerBackground = Color3.fromRGB(28, 30, 36),
        SecondaryBackground = Color3.fromRGB(35, 38, 45),
        ElementBackground = Color3.fromRGB(45, 48, 55),
        TextPrimary = Color3.fromRGB(240, 240, 245),
        TextSecondary = Color3.fromRGB(170, 170, 180),
        Success = Color3.fromRGB(70, 230, 130),
        Warning = Color3.fromRGB(255, 185, 65),
        Error = Color3.fromRGB(255, 70, 90),
        Info = Color3.fromRGB(70, 190, 255),
        InputBackground = Color3.fromRGB(55, 58, 65),
        Highlight = Color3.fromRGB(64, 90, 255),
        BorderColor = Color3.fromRGB(50, 53, 60),
        DropShadowEnabled = true,
        RoundingEnabled = true,
        CornerRadius = UDim.new(0, 8),
        AnimationSpeed = 0.3,
        GlassEffect = true,
        BlurIntensity = 15,
        Transparency = 0.95,
        Font = Enum.Font.GothamSemibold,
        HeaderSize = 18,
        TextSize = 14,
        IconPack = "Phosphor"
    },
    Midnight = {
        Primary = Color3.fromRGB(120, 90, 255),
        PrimaryDark = Color3.fromRGB(100, 70, 235),
        Background = Color3.fromRGB(15, 15, 20),
        ContainerBackground = Color3.fromRGB(25, 25, 30),
        SecondaryBackground = Color3.fromRGB(32, 32, 38),
        ElementBackground = Color3.fromRGB(40, 40, 48),
        TextPrimary = Color3.fromRGB(240, 240, 245),
        TextSecondary = Color3.fromRGB(170, 170, 180),
        Success = Color3.fromRGB(80, 220, 130),
        Warning = Color3.fromRGB(255, 185, 65),
        Error = Color3.fromRGB(255, 70, 90),
        Info = Color3.fromRGB(70, 190, 255),
        InputBackground = Color3.fromRGB(48, 48, 56),
        Highlight = Color3.fromRGB(120, 90, 255),
        BorderColor = Color3.fromRGB(45, 45, 55),
        DropShadowEnabled = true,
        RoundingEnabled = true,
        CornerRadius = UDim.new(0, 8),
        AnimationSpeed = 0.3,
        GlassEffect = true,
        BlurIntensity = 15,
        Transparency = 0.95,
        Font = Enum.Font.GothamSemibold,
        HeaderSize = 18,
        TextSize = 14,
        IconPack = "Phosphor"
    },
    Neon = {
        Primary = Color3.fromRGB(0, 255, 170),
        PrimaryDark = Color3.fromRGB(0, 225, 150),
        Background = Color3.fromRGB(15, 15, 20),
        ContainerBackground = Color3.fromRGB(25, 25, 30),
        SecondaryBackground = Color3.fromRGB(32, 32, 38),
        ElementBackground = Color3.fromRGB(40, 40, 48),
        TextPrimary = Color3.fromRGB(240, 240, 245),
        TextSecondary = Color3.fromRGB(170, 170, 180),
        Success = Color3.fromRGB(80, 255, 130),
        Warning = Color3.fromRGB(255, 185, 65),
        Error = Color3.fromRGB(255, 70, 90),
        Info = Color3.fromRGB(70, 190, 255),
        InputBackground = Color3.fromRGB(48, 48, 56),
        Highlight = Color3.fromRGB(0, 255, 170),
        BorderColor = Color3.fromRGB(45, 45, 55),
        DropShadowEnabled = true,
        RoundingEnabled = true,
        CornerRadius = UDim.new(0, 8),
        AnimationSpeed = 0.3,
        GlassEffect = true,
        BlurIntensity = 15,
        Transparency = 0.95,
        Font = Enum.Font.GothamSemibold,
        HeaderSize = 18,
        TextSize = 14,
        IconPack = "Phosphor"
    }
}

-- Current active theme
local ActiveTheme = table.clone(ThemePresets.Default)

-- Configuration System
local ConfigSystem = {
    RootFolder = "TBD",
    ConfigFolder = nil,
    Flags = {},
    LoadedConfig = nil,
    AutoSaveEnabled = true,
    AutoSaveInterval = 60,
    FileExtension = ".tbd"
}

function ConfigSystem:Init(settings)
    settings = settings or {}
    self.RootFolder = settings.RootFolder or self.RootFolder
    self.ConfigFolder = settings.ConfigFolder or "Configs"
    self.AutoSaveEnabled = settings.AutoSaveEnabled ~= nil and settings.AutoSaveEnabled or self.AutoSaveEnabled
    
    -- Create necessary directories
    self:EnsureFolders()
    
    -- Start auto save cycle if enabled
    if self.AutoSaveEnabled then
        spawn(function()
            while true do
                wait(self.AutoSaveInterval)
                self:SaveConfig("autosave")
            end
        end)
    end
end

function ConfigSystem:EnsureFolders()
    if not isfolder then return end -- Only available in supported exploits
    
    local root = self.RootFolder
    local configPath = root .. "/" .. self.ConfigFolder
    
    if not isfolder(root) then
        makefolder(root)
    end
    
    if not isfolder(configPath) then
        makefolder(configPath)
    end
end

function ConfigSystem:SaveConfig(name)
    if not isfolder or not writefile then return false end
    
    name = name or "default"
    local path = self.RootFolder .. "/" .. self.ConfigFolder .. "/" .. name .. self.FileExtension
    
    local success, result = pcall(function()
        return HttpService:JSONEncode(self.Flags)
    end)
    
    if success then
        writefile(path, result)
        return true
    end
    
    return false
end

function ConfigSystem:LoadConfig(name)
    if not isfolder or not readfile or not isfile then return false end
    
    name = name or "default"
    local path = self.RootFolder .. "/" .. self.ConfigFolder .. "/" .. name .. self.FileExtension
    
    if isfile(path) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        
        if success then
            -- Update flags
            for flag, value in pairs(result) do
                self.Flags[flag] = value
            end
            
            self.LoadedConfig = name
            return true
        end
    end
    
    return false
end

function ConfigSystem:ListConfigs()
    if not isfolder or not listfiles then return {} end
    
    local path = self.RootFolder .. "/" .. self.ConfigFolder
    if not isfolder(path) then
        self:EnsureFolders()
        return {}
    end
    
    local files = listfiles(path)
    local configs = {}
    
    for _, file in pairs(files) do
        local name = file:match("([^/\\]+)%.tbd$")
        if name then
            table.insert(configs, name)
        end
    end
    
    return configs
end

function ConfigSystem:SetFlag(flag, value)
    if flag then
        self.Flags[flag] = value
    end
end

function ConfigSystem:GetFlag(flag, default)
    if self.Flags[flag] ~= nil then
        return self.Flags[flag]
    end
    return default
end

-- Key System
local KeySystem = {
    Enabled = false,
    Keys = {},
    Title = "TBD Authentication",
    Subtitle = "Key Required",
    Note = "Enter your key to access this script",
    SaveKey = true,
    KeyFile = "key.txt",
    SecondaryAction = {
        Enabled = false,
        Type = "Link",  -- "Link" or "Discord"
        Value = ""
    }
}

function KeySystem:Init(settings)
    settings = settings or {}
    
    self.Enabled = settings.Enabled or false
    if not self.Enabled then return true end  -- Skip if not enabled
    
    self.Keys = settings.Keys or {}
    self.Title = settings.Title or self.Title
    self.Subtitle = settings.Subtitle or self.Subtitle
    self.Note = settings.Note or self.Note
    self.SaveKey = settings.SaveKey ~= nil and settings.SaveKey or self.SaveKey
    
    if settings.SecondaryAction then
        self.SecondaryAction.Enabled = settings.SecondaryAction.Enabled ~= nil and 
                                     settings.SecondaryAction.Enabled or self.SecondaryAction.Enabled
        self.SecondaryAction.Type = settings.SecondaryAction.Type or self.SecondaryAction.Type
        self.SecondaryAction.Value = settings.SecondaryAction.Value or ""
    end
    
    -- Try to load saved key
    local savedKey = self:LoadSavedKey()
    if savedKey and self:VerifyKey(savedKey) then
        return true
    end
    
    -- Show key UI
    return self:ShowKeyUI()
end

function KeySystem:VerifyKey(key)
    for _, validKey in pairs(self.Keys) do
        if key == validKey then
            if self.SaveKey then
                self:SaveKeyToFile(key)
            end
            return true
        end
    end
    return false
end

function KeySystem:LoadSavedKey()
    if not self.SaveKey or not isfile or not readfile then return nil end
    
    local path = ConfigSystem.RootFolder .. "/keydata.txt"
    
    if isfile(path) then
        return readfile(path)
    end
    
    return nil
end

function KeySystem:SaveKeyToFile(key)
    if not writefile then return end
    
    local path = ConfigSystem.RootFolder .. "/keydata.txt"
    writefile(path, key)
end

function KeySystem:ShowKeyUI()
    -- Create key UI
    local screenGui = Create("ScreenGui", {
        Name = "TBDKeySystem",
        DisplayOrder = 1000,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = (RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui")) or CoreGui
    })
    
    local keyFrame = Create("Frame", {
        Name = "KeyFrame",
        Size = UDim2.new(0, 400, 0, 200),
        Position = UDim2.new(0.5, -200, 0.5, -100),
        BackgroundColor3 = ActiveTheme.Background,
        BorderSizePixel = 0,
        Parent = screenGui
    })
    
    local frameCorner = Create("UICorner", {
        CornerRadius = ActiveTheme.CornerRadius,
        Parent = keyFrame
    })
    
    -- Add shadow
    if ActiveTheme.DropShadowEnabled then
        local shadow = Create("ImageLabel", {
            Name = "Shadow",
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 4),
            Size = UDim2.new(1, 16, 1, 16),
            ZIndex = -1,
            Image = "rbxassetid://6014261993",
            ImageColor3 = Color3.new(0, 0, 0),
            ImageTransparency = 0.6,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(49, 49, 450, 450),
            Parent = keyFrame
        })
    end
    
    -- Title
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 10),
        Text = self.Title,
        TextColor3 = ActiveTheme.TextPrimary,
        TextSize = ActiveTheme.HeaderSize,
        Font = ActiveTheme.Font,
        BackgroundTransparency = 1,
        Parent = keyFrame
    })
    
    -- Subtitle
    local subtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 40),
        Text = self.Subtitle,
        TextColor3 = ActiveTheme.TextSecondary,
        TextSize = ActiveTheme.TextSize,
        Font = ActiveTheme.Font,
        BackgroundTransparency = 1,
        Parent = keyFrame
    })
    
    -- Note
    local noteLabel = Create("TextLabel", {
        Name = "Note",
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 60),
        Text = self.Note,
        TextColor3 = ActiveTheme.TextSecondary,
        TextSize = ActiveTheme.TextSize,
        Font = ActiveTheme.Font,
        TextWrapped = true,
        BackgroundTransparency = 1,
        Parent = keyFrame
    })
    
    -- Key input
    local keyInputFrame = Create("Frame", {
        Name = "KeyInputFrame",
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 110),
        BackgroundColor3 = ActiveTheme.InputBackground,
        BorderSizePixel = 0,
        Parent = keyFrame
    })
    
    local inputCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = keyInputFrame
    })
    
    local keyInput = Create("TextBox", {
        Name = "KeyInput",
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        Text = "",
        PlaceholderText = "Enter key...",
        TextColor3 = ActiveTheme.TextPrimary,
        PlaceholderColor3 = ActiveTheme.TextSecondary,
        TextSize = ActiveTheme.TextSize,
        Font = ActiveTheme.Font,
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        Parent = keyInputFrame
    })
    
    -- Submit button
    local submitButton = Create("TextButton", {
        Name = "SubmitButton",
        Size = UDim2.new(0, 100, 0, 30),
        Position = UDim2.new(0.5, -105, 0, 150),
        Text = "Submit",
        TextColor3 = ActiveTheme.TextPrimary,
        TextSize = ActiveTheme.TextSize,
        Font = ActiveTheme.Font,
        BackgroundColor3 = ActiveTheme.Primary,
        BorderSizePixel = 0,
        Parent = keyFrame
    })
    
    local submitCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = submitButton
    })
    
    -- Secondary action button
    local secondaryButton
    if self.SecondaryAction.Enabled then
        local buttonText = self.SecondaryAction.Type == "Discord" and "Join Discord" or "Get Key"
        
        secondaryButton = Create("TextButton", {
            Name = "SecondaryButton",
            Size = UDim2.new(0, 100, 0, 30),
            Position = UDim2.new(0.5, 5, 0, 150),
            Text = buttonText,
            TextColor3 = ActiveTheme.TextPrimary,
            TextSize = ActiveTheme.TextSize,
            Font = ActiveTheme.Font,
            BackgroundColor3 = ActiveTheme.ElementBackground,
            BorderSizePixel = 0,
            Parent = keyFrame
        })
        
        local secondaryCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = secondaryButton
        })
        
        secondaryButton.MouseButton1Click:Connect(function()
            if self.SecondaryAction.Type == "Discord" then
                local success, result = pcall(function()
                    local discordLink = "https://discord.gg/" .. self.SecondaryAction.Value
                    setclipboard(discordLink)
                    return true
                end)
                
                if success and result then
                    -- Create notification or message
                    local infoLabel = Create("TextLabel", {
                        Name = "InfoLabel",
                        Size = UDim2.new(1, -20, 0, 20),
                        Position = UDim2.new(0, 10, 0, 185),
                        Text = "Discord invite copied to clipboard!",
                        TextColor3 = ActiveTheme.Info,
                        TextSize = ActiveTheme.TextSize - 1,
                        Font = ActiveTheme.Font,
                        BackgroundTransparency = 1,
                        Parent = keyFrame
                    })
                    
                    -- Remove after a few seconds
                    spawn(function()
                        wait(3)
                        infoLabel:Destroy()
                    end)
                end
            elseif self.SecondaryAction.Type == "Link" then
                local success, result = pcall(function()
                    setclipboard(self.SecondaryAction.Value)
                    return true
                end)
                
                if success and result then
                    -- Create notification or message
                    local infoLabel = Create("TextLabel", {
                        Name = "InfoLabel",
                        Size = UDim2.new(1, -20, 0, 20),
                        Position = UDim2.new(0, 10, 0, 185),
                        Text = "Key website link copied to clipboard!",
                        TextColor3 = ActiveTheme.Info,
                        TextSize = ActiveTheme.TextSize - 1,
                        Font = ActiveTheme.Font,
                        BackgroundTransparency = 1,
                        Parent = keyFrame
                    })
                    
                    -- Remove after a few seconds
                    spawn(function()
                        wait(3)
                        infoLabel:Destroy()
                    end)
                end
            end
        end)
    end
    
    -- Handle submit button
    local validKey = false
    submitButton.MouseButton1Click:Connect(function()
        local key = keyInput.Text
        
        if self:VerifyKey(key) then
            validKey = true
            
            -- Create success message
            local successLabel = Create("TextLabel", {
                Name = "SuccessLabel",
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, 185),
                Text = "Key verified successfully!",
                TextColor3 = ActiveTheme.Success,
                TextSize = ActiveTheme.TextSize - 1,
                Font = ActiveTheme.Font,
                BackgroundTransparency = 1,
                Parent = keyFrame
            })
            
            -- Close after delay
            spawn(function()
                wait(1)
                screenGui:Destroy()
            end)
        else
            -- Create error message
            local errorLabel = Create("TextLabel", {
                Name = "ErrorLabel",
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, 185),
                Text = "Invalid key! Please try again.",
                TextColor3 = ActiveTheme.Error,
                TextSize = ActiveTheme.TextSize - 1,
                Font = ActiveTheme.Font,
                BackgroundTransparency = 1,
                Parent = keyFrame
            })
            
            -- Remove error after delay
            spawn(function()
                wait(2)
                if errorLabel and errorLabel.Parent then
                    errorLabel:Destroy()
                end
            end)
        end
    end)
    
    -- Handle key input with enter press
    keyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            submitButton.MouseButton1Click:Fire()
        end
    end)
    
    -- Make UI draggable
    EnableDragging(keyFrame, keyFrame)
    
    -- Wait for key verification
    while screenGui.Parent and not validKey do
        wait()
    end
    
    return validKey
end

-- Notification System
local NotificationSystem = {
    Container = nil,
    Notifications = {},
    MaxVisible = 6,
    DefaultDuration = 5,
    Position = "TopRight",
    Margin = 10,
    Width = 300,
    Height = 80
}

function NotificationSystem:Init()
    self.Container = Create("ScreenGui", {
        Name = "TBDNotifications",
        DisplayOrder = 1000,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = (RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui")) or CoreGui
    })
    
    local frame = Create("Frame", {
        Name = "NotificationContainer",
        Size = UDim2.new(0, self.Width, 1, 0),
        Position = self:GetContainerPosition(),
        BackgroundTransparency = 1,
        Parent = self.Container
    })
    
    local layout = Create("UIListLayout", {
        Padding = UDim.new(0, self.Margin),
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = self:GetVerticalAlignment(),
        HorizontalAlignment = self:GetHorizontalAlignment(),
        Parent = frame
    })
    
    self.Container = frame
    return self
end

function NotificationSystem:GetContainerPosition()
    local position = self.Position
    
    if position == "TopRight" then
        return UDim2.new(1, -self.Margin, 0, self.Margin)
    elseif position == "TopLeft" then
        return UDim2.new(0, self.Margin, 0, self.Margin)
    elseif position == "BottomRight" then
        return UDim2.new(1, -self.Margin, 1, -self.Margin)
    elseif position == "BottomLeft" then
        return UDim2.new(0, self.Margin, 1, -self.Margin)
    else
        return UDim2.new(1, -self.Margin, 0, self.Margin)
    end
end

function NotificationSystem:GetVerticalAlignment()
    if self.Position:sub(1, 3) == "Top" then
        return Enum.VerticalAlignment.Top
    else
        return Enum.VerticalAlignment.Bottom
    end
end

function NotificationSystem:GetHorizontalAlignment()
    if self.Position:sub(-5) == "Right" then
        return Enum.HorizontalAlignment.Right
    else
        return Enum.HorizontalAlignment.Left
    end
end

function NotificationSystem:Notify(options)
    if not self.Container then
        self:Init()
    end
    
    options = options or {}
    local title = options.Title or "Notification"
    local message = options.Message or ""
    local duration = options.Duration or self.DefaultDuration
    local type = options.Type or "Info"  -- Info, Success, Warning, Error
    local icon = options.Icon
    local callback = options.Callback
    
    -- Create notification frame
    local notification = Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(1, 0, 0, self.Height),
        BackgroundColor3 = ActiveTheme.ContainerBackground,
        BorderSizePixel = 0,
        BackgroundTransparency = 0.1,
        ClipsDescendants = true,
        Parent = self.Container
    })
    
    -- Add corner radius
    local corner = Create("UICorner", {
        CornerRadius = ActiveTheme.CornerRadius,
        Parent = notification
    })
    
    -- Add drop shadow if enabled
    if ActiveTheme.DropShadowEnabled then
        local shadow = Create("ImageLabel", {
            Name = "Shadow",
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 4),
            Size = UDim2.new(1, 8, 1, 8),
            ZIndex = -1,
            Image = "rbxassetid://6014261993",
            ImageColor3 = Color3.new(0, 0, 0),
            ImageTransparency = 0.6,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(49, 49, 450, 450),
            Parent = notification
        })
    end
    
    -- Add accent bar based on notification type
    local accentColor = (
        type == "Success" and ActiveTheme.Success or
        type == "Warning" and ActiveTheme.Warning or
        type == "Error" and ActiveTheme.Error or
        ActiveTheme.Info
    )
    
    local accentBar = Create("Frame", {
        Name = "AccentBar",
        Size = UDim2.new(0, 4, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        Parent = notification
    })
    
    -- Add icon
    local iconId = nil
    
    if icon then
        if type(icon) == "string" then
            local iconPack = ActiveTheme.IconPack
            iconId = IconSets[iconPack] and IconSets[iconPack][icon]
        elseif type(icon) == "number" then
            iconId = "rbxassetid://" .. tostring(icon)
        end
    elseif type then
        local iconName = (
            type == "Success" and "check" or
            type == "Warning" and "warning" or
            type == "Error" and "error" or
            "info"
        )
        local iconPack = ActiveTheme.IconPack
        iconId = IconSets[iconPack] and IconSets[iconPack][iconName]
    end
    
    if iconId then
        local iconContainer = Create("Frame", {
            Name = "IconContainer",
            Size = UDim2.new(0, 32, 0, 32),
            Position = UDim2.new(0, 16, 0, 24),
            BackgroundTransparency = 1,
            Parent = notification
        })
        
        local iconImage = Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image = iconId,
            ImageColor3 = accentColor,
            Parent = iconContainer
        })
    end
    
    -- Add title
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -70, 0, 20),
        Position = UDim2.new(0, 56, 0, 15),
        Text = title,
        TextColor3 = ActiveTheme.TextPrimary,
        TextSize = ActiveTheme.HeaderSize,
        Font = ActiveTheme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = notification
    })
    
    -- Add message
    local messageLabel = Create("TextLabel", {
        Name = "Message",
        Size = UDim2.new(1, -70, 0, 40),
        Position = UDim2.new(0, 56, 0, 35),
        Text = message,
        TextColor3 = ActiveTheme.TextSecondary,
        TextSize = ActiveTheme.TextSize,
        Font = ActiveTheme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        BackgroundTransparency = 1,
        Parent = notification
    })
    
    -- Add close button
    local closeButton = Create("ImageButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -26, 0, 15),
        BackgroundTransparency = 1,
        Image = IconSets[ActiveTheme.IconPack].close,
        ImageColor3 = ActiveTheme.TextSecondary,
        Parent = notification
    })
    
    closeButton.MouseEnter:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {ImageColor3 = ActiveTheme.Error}):Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {ImageColor3 = ActiveTheme.TextSecondary}):Play()
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        self:CloseNotification(notification)
    end)
    
    -- Add progress bar
    local progressBar = Create("Frame", {
        Name = "ProgressBar",
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        Parent = notification
    })
    
    -- Make notification clickable
    if callback then
        local button = Create("TextButton", {
            Name = "ClickButton",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = notification,
            ZIndex = 0  -- Below other elements
        })
        
        button.MouseButton1Click:Connect(function()
            callback()
            self:CloseNotification(notification)
        end)
    end
    
    -- Animate entrance
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.BackgroundTransparency = 1
    progressBar.Size = UDim2.new(0, 0, 0, 3)
    
    TweenService:Create(notification, TweenInfo.new(ActiveTheme.AnimationSpeed, Enum.EasingStyle.Quint), {
        Size = UDim2.new(1, 0, 0, self.Height),
        BackgroundTransparency = 0.1
    }):Play()
    
    -- Progress bar animation
    spawn(function()
        wait(ActiveTheme.AnimationSpeed)
        TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 0, 3)
        }):Play()
    end)
    
    -- Auto-close timer
    spawn(function()
        wait(duration + ActiveTheme.AnimationSpeed)
        self:CloseNotification(notification)
    end)
    
    -- Add to notifications list
    table.insert(self.Notifications, notification)
    
    -- Remove excess notifications
    if #self.Notifications > self.MaxVisible then
        self:CloseNotification(self.Notifications[1])
    end
    
    return notification
end

function NotificationSystem:CloseNotification(notification)
    -- Find notification in list
    local index = table.find(self.Notifications, notification)
    if index then
        table.remove(self.Notifications, index)
    end
    
    -- Animate exit
    TweenService:Create(notification, TweenInfo.new(ActiveTheme.AnimationSpeed, Enum.EasingStyle.Quint), {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    
    -- Destroy after animation
    spawn(function()
        wait(ActiveTheme.AnimationSpeed)
        notification:Destroy()
    end)
end

-- Window Class
function TBD:CreateWindow(options)
    options = options or {}
    local window = {}
    
    -- Window settings
    local title = options.Title or "TBD Interface Suite"
    local subtitle = options.Subtitle or nil
    local theme = options.Theme or "Default"
    local size = options.Size or {400, 500}  -- Width, Height
    local position = options.Position or "Center"  -- Center or custom {X, Y} coordinates
    local closeCallback = options.OnClose or function() end
    local resizable = options.Resizable ~= nil and options.Resizable or false
    local minimumSize = options.MinimumSize or {300, 350}
    local transparency = options.Transparency or ActiveTheme.Transparency
    local logoId = options.LogoId or nil
    local loadingEnabled = options.LoadingEnabled ~= nil and options.LoadingEnabled or true
    local loadingTitle = options.LoadingTitle or "TBD Interface Suite"
    local loadingSubtitle = options.LoadingSubtitle or "Loading..."
    
    -- Config and key system settings
    if options.ConfigSettings then
        ConfigSystem:Init(options.ConfigSettings)
    end
    
    if options.KeySystem then
        KeySystem.Enabled = true
        if not KeySystem:Init(options.KeySettings or {}) then
            return nil  -- Failed key validation
        end
    end
    
    -- Set theme
    if theme ~= "Default" and ThemePresets[theme] then
        ActiveTheme = table.clone(ThemePresets[theme])
    end
    
    -- Apply custom theme overrides
    if options.ThemeOverrides then
        for key, value in pairs(options.ThemeOverrides) do
            ActiveTheme[key] = value
        end
    end
    
    -- Screen GUI
    local screenGui = Create("ScreenGui", {
        Name = "TBDInterfaceSuite",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 999,
        Parent = (RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui")) or CoreGui
    })
    
    -- Loading screen
    if loadingEnabled then
        local loadingScreen = Create("Frame", {
            Name = "LoadingScreen",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = ActiveTheme.Background,
            BorderSizePixel = 0,
            Parent = screenGui
        })
        
        local loadingContainer = Create("Frame", {
            Name = "LoadingContainer",
            Size = UDim2.new(0, 300, 0, 200),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = ActiveTheme.ContainerBackground,
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            Parent = loadingScreen
        })
        
        local corner = Create("UICorner", {
            CornerRadius = ActiveTheme.CornerRadius,
            Parent = loadingContainer
        })
        
        if ActiveTheme.DropShadowEnabled then
            local shadow = Create("ImageLabel", {
                Name = "Shadow",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0.5, 4),
                Size = UDim2.new(1, 16, 1, 16),
                ZIndex = -1,
                Image = "rbxassetid://6014261993",
                ImageColor3 = Color3.new(0, 0, 0),
                ImageTransparency = 0.6,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(49, 49, 450, 450),
                Parent = loadingContainer
            })
        end
        
        local logo
        if logoId then
            logo = Create("ImageLabel", {
                Name = "Logo",
                Size = UDim2.new(0, 80, 0, 80),
                Position = UDim2.new(0.5, 0, 0.25, 0),
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundTransparency = 1,
                Image = "rbxassetid://" .. logoId,
                Parent = loadingContainer
            })
        end
        
        local titleLabel = Create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -40, 0, 30),
            Position = UDim2.new(0, 20, logo and 0.25 + 0.35 or 0.3, 0),
            Text = loadingTitle,
            TextColor3 = ActiveTheme.TextPrimary,
            TextSize = ActiveTheme.HeaderSize + 2,
            Font = ActiveTheme.Font,
            BackgroundTransparency = 1,
            Parent = loadingContainer
        })
        
        local subtitleLabel = Create("TextLabel", {
            Name = "Subtitle",
            Size = UDim2.new(1, -40, 0, 20),
            Position = UDim2.new(0, 20, logo and 0.25 + 0.45 or 0.4, 0),
            Text = loadingSubtitle,
            TextColor3 = ActiveTheme.TextSecondary,
            TextSize = ActiveTheme.TextSize,
            Font = ActiveTheme.Font,
            BackgroundTransparency = 1,
            Parent = loadingContainer
        })
        
        local loadingBar = Create("Frame", {
            Name = "LoadingBar",
            Size = UDim2.new(1, -40, 0, 6),
            Position = UDim2.new(0, 20, logo and 0.25 + 0.55 or 0.6, 0),
            BackgroundColor3 = ActiveTheme.ElementBackground,
            BorderSizePixel = 0,
            Parent = loadingContainer
        })
        
        local loadingBarCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 3),
            Parent = loadingBar
        })
        
        local loadingProgress = Create("Frame", {
            Name = "Progress",
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = ActiveTheme.Primary,
            BorderSizePixel = 0,
            Parent = loadingBar
        })
        
        local loadingProgressCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 3),
            Parent = loadingProgress
        })
        
        -- Animate loading bar
        spawn(function()
            for i = 0, 100, 1 do
                TweenService:Create(loadingProgress, TweenInfo.new(0.1), {
                    Size = UDim2.new(i / 100, 0, 1, 0)
                }):Play()
                wait(0.03)
            end
            
            wait(0.5)
            
            -- Animate exit
            TweenService:Create(loadingScreen, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
                BackgroundTransparency = 1
            }):Play()
            
            TweenService:Create(loadingContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
                Position = UDim2.new(0.5, 0, 0.55, 0),
                BackgroundTransparency = 1
            }):Play()
            
            -- Wait for animation and destroy
            wait(0.5)
            loadingScreen:Destroy()
        end)
    end
    
    -- Main window container
    local windowFrame = Create("Frame", {
        Name = "WindowContainer",
        Size = UDim2.new(0, size[1], 0, size[2]),
        BackgroundColor3 = ActiveTheme.Background,
        BorderSizePixel = 0,
        Parent = screenGui
    })
    
    -- Position window
    if position == "Center" then
        windowFrame.Position = UDim2.new(0.5, -size[1]/2, 0.5, -size[2]/2)
    else
        windowFrame.Position = UDim2.new(0, position[1], 0, position[2])
    end
    
    -- Apply corner radius
    local corner = Create("UICorner", {
        CornerRadius = ActiveTheme.CornerRadius,
        Parent = windowFrame
    })
    
    -- Add shadow
    if ActiveTheme.DropShadowEnabled then
        local shadow = Create("ImageLabel", {
            Name = "Shadow",
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 4),
            Size = UDim2.new(1, 16, 1, 16),
            ZIndex = -1,
            Image = "rbxassetid://6014261993",
            ImageColor3 = Color3.new(0, 0, 0),
            ImageTransparency = 0.6,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(49, 49, 450, 450),
            Parent = windowFrame
        })
    end
    
    -- Title bar
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = ActiveTheme.ContainerBackground,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Parent = windowFrame
    })
    
    local titleBarCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = titleBar
    })
    
    -- Only round top corners
    local titleBarBottomFrame = Create("Frame", {
        Name = "BottomFrame",
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = ActiveTheme.ContainerBackground,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ZIndex = 0,
        Parent = titleBar
    })
    
    -- Logo/Icon
    if logoId then
        local logoIcon = Create("ImageLabel", {
            Name = "Logo",
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 12, 0, 7),
            BackgroundTransparency = 1,
            Image = "rbxassetid://" .. logoId,
            Parent = titleBar
        })
    end
    
    -- Title text
    local titleText = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -130, 1, 0),
        Position = UDim2.new(0, logoId and 36 or 12, 0, 0),
        Text = title,
        TextColor3 = ActiveTheme.TextPrimary,
        TextSize = ActiveTheme.TextSize + 2,
        Font = ActiveTheme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = titleBar
    })
    
    -- Subtitle text
    if subtitle then
        titleText.Size = UDim2.new(0, 180, 1, 0)
        
        local subtitleText = Create("TextLabel", {
            Name = "Subtitle",
            Size = UDim2.new(1, -320, 1, 0),
            Position = UDim2.new(0, 190, 0, 0),
            Text = subtitle,
            TextColor3 = ActiveTheme.TextSecondary,
            TextSize = ActiveTheme.TextSize,
            Font = ActiveTheme.Font,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Parent = titleBar
        })
    end
    
    -- Close button
    local closeButton = Create("ImageButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -28, 0, 8),
        BackgroundTransparency = 1,
        Image = IconSets[ActiveTheme.IconPack].close,
        ImageColor3 = ActiveTheme.TextSecondary,
        Parent = titleBar
    })
    
    closeButton.MouseEnter:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {ImageColor3 = ActiveTheme.Error}):Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {ImageColor3 = ActiveTheme.TextSecondary}):Play()
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        closeCallback()
        
        -- Save config on close if configured
        if ConfigSystem.AutoSaveEnabled then
            ConfigSystem:SaveConfig("autosave")
        end
        
        -- Animate close
        TweenService:Create(windowFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, size[1], 0, 0),
            Position = UDim2.new(windowFrame.Position.X.Scale, windowFrame.Position.X.Offset, 
                                 windowFrame.Position.Y.Scale, windowFrame.Position.Y.Offset + size[2]/2)
        }):Play()
        
        -- Destroy after animation
        wait(0.4)
        screenGui:Destroy()
    end)
    
    -- Minimize button
    local minimizeButton = Create("ImageButton", {
        Name = "MinimizeButton",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -52, 0, 8),
        BackgroundTransparency = 1,
        Image = IconSets[ActiveTheme.IconPack].remove,
        ImageColor3 = ActiveTheme.TextSecondary,
        Parent = titleBar
    })
    
    minimizeButton.MouseEnter:Connect(function()
        TweenService:Create(minimizeButton, TweenInfo.new(0.2), {ImageColor3 = ActiveTheme.Warning}):Play()
    end)
    
    minimizeButton.MouseLeave:Connect(function()
        TweenService:Create(minimizeButton, TweenInfo.new(0.2), {ImageColor3 = ActiveTheme.TextSecondary}):Play()
    end)
    
    local minimized = false
    minimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        
        if minimized then
            -- Store original size
            window._originalSize = {windowFrame.Size.X.Offset, windowFrame.Size.Y.Offset}
            
            -- Animate minimize
            TweenService:Create(windowFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                Size = UDim2.new(0, windowFrame.Size.X.Offset, 0, 32)
            }):Play()
            
            minimizeButton.Image = IconSets[ActiveTheme.IconPack].add
        else
            -- Animate restore
            TweenService:Create(windowFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                Size = UDim2.new(0, window._originalSize[1], 0, window._originalSize[2])
            }):Play()
            
            minimizeButton.Image = IconSets[ActiveTheme.IconPack].remove
        end
    end)
    
    -- Make window draggable
    EnableDragging(windowFrame, titleBar)
    
    -- Container for tab buttons
    local tabButtonsContainer = Create("Frame", {
        Name = "TabButtons",
        Size = UDim2.new(0, 120, 1, -32),
        Position = UDim2.new(0, 0, 0, 32),
        BackgroundColor3 = ActiveTheme.SecondaryBackground,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Parent = windowFrame
    })
    
    -- Scrolling Frame for tab buttons (in case of many tabs)
    local tabButtonsScrollFrame = Create("ScrollingFrame", {
        Name = "ScrollFrame",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = ActiveTheme.Primary,
        ScrollBarImageTransparency = 0.5,
        VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
        Parent = tabButtonsContainer
    })
    
    local tabButtonsListLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabButtonsScrollFrame
    })
    
    local tabButtonsPadding = Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = tabButtonsScrollFrame
    })
    
    -- Container for tab content
    local tabContentContainer = Create("Frame", {
        Name = "TabContent",
        Size = UDim2.new(1, -120, 1, -32),
        Position = UDim2.new(0, 120, 0, 32),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = windowFrame
    })
    
    -- Store tabs
    window.Tabs = {}
    window.ActiveTab = nil
    window.ScreenGui = screenGui
    window.Container = windowFrame
    window.TabButtonsContainer = tabButtonsScrollFrame
    window.TabContentContainer = tabContentContainer
    
    -- Create a tab
    function window:CreateTab(options)
        options = options or {}
        local name = options.Name or "Tab"
        local icon = options.Icon
        local showTitle = options.ShowTitle ~= nil and options.ShowTitle or true
        local iconSource = options.ImageSource or ActiveTheme.IconPack
        
        local tab = {}
        local tabId = HttpService:GenerateGUID(false)
        
        -- Get icon ID
        local iconId = nil
        if icon then
            if IconSets[iconSource] and IconSets[iconSource][icon] then
                iconId = IconSets[iconSource][icon]
            elseif type(icon) == "number" or tonumber(icon) then
                iconId = "rbxassetid://" .. tostring(icon)
            end
        end
        
        -- Create tab button
        local tabButton = Create("Frame", {
            Name = name .. "Button",
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = ActiveTheme.ElementBackground,
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Parent = window.TabButtonsContainer
        })
        
        local tabButtonCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = tabButton
        })
        
        -- Tab selection indicator
        local tabSelectedIndicator = Create("Frame", {
            Name = "SelectionIndicator",
            Size = UDim2.new(0, 3, 0.7, 0),
            Position = UDim2.new(0, 0, 0.15, 0),
            BackgroundColor3 = ActiveTheme.Primary,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = tabButton
        })
        
        local indicatorCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 2),
            Parent = tabSelectedIndicator
        })
        
        -- Create tab icon
        if iconId then
            local tabIcon = Create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 12, 0.5, -9),
                BackgroundTransparency = 1,
                Image = iconId,
                ImageColor3 = ActiveTheme.TextSecondary,
                Parent = tabButton
            })
            
            -- Create tab name label
            local tabName = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -44, 1, 0),
                Position = UDim2.new(0, 36, 0, 0),
                Text = name,
                TextColor3 = ActiveTheme.TextSecondary,
                TextSize = ActiveTheme.TextSize,
                Font = ActiveTheme.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = tabButton
            })
            
            -- Store references
            tab.Button = tabButton
            tab.Icon = tabIcon
            tab.Title = tabName
        else
            -- Create tab name label (centered)
            local tabName = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                Text = name,
                TextColor3 = ActiveTheme.TextSecondary,
                TextSize = ActiveTheme.TextSize,
                Font = ActiveTheme.Font,
                TextXAlignment = Enum.TextXAlignment.Center,
                BackgroundTransparency = 1,
                Parent = tabButton
            })
            
            -- Store references
            tab.Button = tabButton
            tab.Title = tabName
        end
        
        -- Create tab content container
        local tabContainer = Create("ScrollingFrame", {
            Name = tabId,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = ActiveTheme.Primary,
            ScrollBarImageTransparency = 0.5,
            VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
            Visible = false,
            Parent = window.TabContentContainer
        })
        
        -- Add padding
        local containerPadding = Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 16),
            Parent = tabContainer
        })
        
        -- Add list layout
        local containerLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = tabContainer
        })
        
        -- Create tab title if showTitle is true
        if showTitle then
            local tabTitleLabel = Create("TextLabel", {
                Name = "TabTitle",
                Size = UDim2.new(1, 0, 0, 40),
                Text = name,
                TextColor3 = ActiveTheme.TextPrimary,
                TextSize = ActiveTheme.HeaderSize,
                Font = ActiveTheme.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                Parent = tabContainer
            })
            
            tab.TitleLabel = tabTitleLabel
        end
        
        -- Handle tab selection
        tabButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                self:SelectTab(tabId)
            end
        end)
        
        -- Store tab data
        tab.Container = tabContainer
        tab.Id = tabId
        tab.Name = name
        tab.Elements = {}
        
        -- Add to window tabs
        window.Tabs[tabId] = tab
        
        -- If this is the first tab, select it
        if not window.ActiveTab then
            self:SelectTab(tabId)
        end
        
        -- Calculate offset for automatic layout
        containerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContainer.CanvasSize = UDim2.new(0, 0, 0, containerLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Methods for adding elements to tab
        function tab:CreateSection(name)
            local section = {}
            
            -- Create section container
            local sectionContainer = Create("Frame", {
                Name = "Section_" .. name,
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                Parent = tabContainer
            })
            
            -- Create section label
            local sectionLabel = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, 6),
                Text = name,
                TextColor3 = ActiveTheme.Primary,
                TextSize = ActiveTheme.TextSize,
                Font = ActiveTheme.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = sectionContainer
            })
            
            -- Create section line
            local sectionLine = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = ActiveTheme.BorderColor,
                BorderSizePixel = 0,
                Transparency = 0.7,
                Parent = sectionContainer
            })
            
            section.Container = sectionContainer
            section.Label = sectionLabel
            section.Line = sectionLine
            
            -- Methods
            function section:Set(newName)
                sectionLabel.Text = newName
            end
            
            function section:Destroy()
                sectionContainer:Destroy()
            end
            
            -- Track the section
            table.insert(tab.Elements, section)
            
            return section
        end
        
        function tab:CreateDivider()
            local divider = Create("Frame", {
                Name = "Divider",
                Size = UDim2.new(1, 0, 0, 8),
                BackgroundTransparency = 1,
                Parent = tabContainer
            })
            
            local dividerLine = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 0.5, 0),
                BackgroundColor3 = ActiveTheme.BorderColor,
                BorderSizePixel = 0,
                Transparency = 0.7,
                Parent = divider
            })
            
            -- Track the divider
            table.insert(tab.Elements, {
                Type = "Divider",
                Instance = divider
            })
            
            return divider
        end
        
        function tab:CreateButton(options)
            options = options or {}
            local name = options.Name or "Button"
            local description = options.Description
            local callback = options.Callback or function() end
            
            local button = {}
            
            -- Create button container
            local height = description and 54 or 36
            local buttonContainer = Create("Frame", {
                Name = "Button_" .. name,
                Size = UDim2.new(1, 0, 0, height),
                BackgroundColor3 = ActiveTheme.ElementBackground,
                BackgroundTransparency = 0.2,
                Parent = tabContainer
            })
            
            local buttonCorner = Create("UICorner", {
                CornerRadius = ActiveTheme.CornerRadius,
                Parent = buttonContainer
            })
            
            -- Create button title
            local buttonTitle = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -20, 0, 18),
                Position = UDim2.new(0, 10, 0, 9),
                Text = name,
                TextColor3 = ActiveTheme.TextPrimary,
                TextSize = ActiveTheme.TextSize,
                Font = ActiveTheme.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = buttonContainer
            })
            
            -- Create description if provided
            if description then
                local descriptionLabel = Create("TextLabel", {
                    Name = "Description",
                    Size = UDim2.new(1, -20, 0, 18),
                    Position = UDim2.new(0, 10, 0, 26),
                    Text = description,
                    TextColor3 = ActiveTheme.TextSecondary,
                    TextSize = ActiveTheme.TextSize - 2,
                    Font = ActiveTheme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Parent = buttonContainer
                })
                
                button.Description = descriptionLabel
            end
            
            -- Make button interactive
            buttonContainer.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    -- Visual feedback
                    TweenService:Create(buttonContainer, TweenInfo.new(0.1), {
                        BackgroundColor3 = ActiveTheme.Primary
                    }):Play()
                    
                    -- Call callback
                    callback()
                    
                    -- Reset after a brief moment
                    spawn(function()
                        wait(0.1)
                        TweenService:Create(buttonContainer, TweenInfo.new(0.1), {
                            BackgroundColor3 = ActiveTheme.ElementBackground
                        }):Play()
                    end)
                end
            end)
            
            button.Container = buttonContainer
            button.Title = buttonTitle
            
            function button:Set(newCallback)
                callback = newCallback
            end
            
            function button:SetName(newName)
                buttonTitle.Text = newName
            end
            
            function button:SetDescription(newDescription)
                if button.Description then
                    button.Description.Text = newDescription
                elseif newDescription then
                    local descriptionLabel = Create("TextLabel", {
                        Name = "Description",
                        Size = UDim2.new(1, -20, 0, 18),
                        Position = UDim2.new(0, 10, 0, 26),
                        Text = newDescription,
                        TextColor3 = ActiveTheme.TextSecondary,
                        TextSize = ActiveTheme.TextSize - 2,
                        Font = ActiveTheme.Font,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Parent = buttonContainer
                    })
                    
                    button.Description = descriptionLabel
                    buttonContainer.Size = UDim2.new(1, 0, 0, 54)
                end
            end
            
            -- Track the button
            table.insert(tab.Elements, button)
            
            return button
        end
        
        function tab:CreateToggle(options, flag)
            options = options or {}
            local name = options.Name or "Toggle"
            local description = options.Description
            local default = options.CurrentValue or false
            local callback = options.Callback or function() end
            flag = flag or name
            
            local toggle = {}
            
            -- Create toggle container
            local height = description and 54 or 36
            local toggleContainer = Create("Frame", {
                Name = "Toggle_" .. name,
                Size = UDim2.new(1, 0, 0, height),
                BackgroundColor3 = ActiveTheme.ElementBackground,
                BackgroundTransparency = 0.2,
                Parent = tabContainer
            })
            
            local toggleCorner = Create("UICorner", {
                CornerRadius = ActiveTheme.CornerRadius,
                Parent = toggleContainer
            })
            
            -- Create toggle title
            local toggleTitle = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -60, 0, 18),
                Position = UDim2.new(0, 10, 0, 9),
                Text = name,
                TextColor3 = ActiveTheme.TextPrimary,
                TextSize = ActiveTheme.TextSize,
                Font = ActiveTheme.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = toggleContainer
            })
            
            -- Create description if provided
            if description then
                local descriptionLabel = Create("TextLabel", {
                    Name = "Description",
                    Size = UDim2.new(1, -60, 0, 18),
                    Position = UDim2.new(0, 10, 0, 26),
                    Text = description,
                    TextColor3 = ActiveTheme.TextSecondary,
                    TextSize = ActiveTheme.TextSize - 2,
                    Font = ActiveTheme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Parent = toggleContainer
                })
                
                toggle.Description = descriptionLabel
            end
            
            -- Create toggle switch
            local toggleSwitch = Create("Frame", {
                Name = "Switch",
                Size = UDim2.new(0, 36, 0, 18),
                Position = UDim2.new(1, -46, 0, description and 18 or 9),
                BackgroundColor3 = default and ActiveTheme.Primary or ActiveTheme.ElementBackground,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = toggleContainer
            })
            
            local switchCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggleSwitch
            })
            
            local toggleIndicator = Create("Frame", {
                Name = "Indicator",
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0, default and 19 or 2, 0, 2),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Parent = toggleSwitch
            })
            
            local indicatorCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggleIndicator
            })
            
            -- Set up toggle state tracking
            local enabled = default
            
            -- Save the initial value to config system
            ConfigSystem:SetFlag(flag, enabled)
            
            -- Update toggle visual state
            local function updateToggle(newState)
                enabled = newState
                
                TweenService:Create(toggleSwitch, TweenInfo.new(0.2), {
                    BackgroundColor3 = enabled and ActiveTheme.Primary or ActiveTheme.ElementBackground
                }):Play()
                
                TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {
                    Position = UDim2.new(0, enabled and 19 or 2, 0, 2)
                }):Play()
                
                ConfigSystem:SetFlag(flag, enabled)
                callback(enabled)
            end
            
            -- Handle toggle interaction
            toggleContainer.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    updateToggle(not enabled)
                end
            end)
            
            -- Toggle methods
            function toggle:Set(newState)
                updateToggle(newState)
            end
            
            function toggle:Toggle()
                updateToggle(not enabled)
            end
            
            function toggle:GetState()
                return enabled
            end
            
            function toggle:SetCallback(newCallback)
                callback = newCallback
            end
            
            function toggle:SetName(newName)
                toggleTitle.Text = newName
            end
            
            function toggle:SetDescription(newDescription)
                if toggle.Description then
                    toggle.Description.Text = newDescription
                elseif newDescription then
                    local descriptionLabel = Create("TextLabel", {
                        Name = "Description",
                        Size = UDim2.new(1, -60, 0, 18),
                        Position = UDim2.new(0, 10, 0, 26),
                        Text = newDescription,
                        TextColor3 = ActiveTheme.TextSecondary,
                        TextSize = ActiveTheme.TextSize - 2,
                        Font = ActiveTheme.Font,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Parent = toggleContainer
                    })
                    
                    toggle.Description = descriptionLabel
                    toggleContainer.Size = UDim2.new(1, 0, 0, 54)
                    toggleSwitch.Position = UDim2.new(1, -46, 0, 18)
                end
            end
            
            -- Track the toggle
            toggle.Type = "Toggle"
            toggle.Flag = flag
            toggle.Container = toggleContainer
            toggle.Title = toggleTitle
            toggle.Switch = toggleSwitch
            toggle.Indicator = toggleIndicator
            
            table.insert(tab.Elements, toggle)
            
            return toggle
        end
        
        function tab:CreateSlider(options, flag)
            options = options or {}
            local name = options.Name or "Slider"
            local description = options.Description
            local min = options.Range and options.Range[1] or 0
            local max = options.Range and options.Range[2] or 100
            local increment = options.Increment or 1
            local default = options.CurrentValue or min
            local callback = options.Callback or function() end
            flag = flag or name
            
            -- Validate default value
            default = math.clamp(default, min, max)
            default = FormatNumber(default, GetDecimalPlaces(increment))
            
            local slider = {}
            
            -- Create slider container
            local height = description and 70 or 52
            local sliderContainer = Create("Frame", {
                Name = "Slider_" .. name,
                Size = UDim2.new(1, 0, 0, height),
                BackgroundColor3 = ActiveTheme.ElementBackground,
                BackgroundTransparency = 0.2,
                Parent = tabContainer
            })
            
            local sliderCorner = Create("UICorner", {
                CornerRadius = ActiveTheme.CornerRadius,
                Parent = sliderContainer
            })
            
            -- Create slider title
            local sliderTitle = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -80, 0, 18),
                Position = UDim2.new(0, 10, 0, 9),
                Text = name,
                TextColor3 = ActiveTheme.TextPrimary,
                TextSize = ActiveTheme.TextSize,
                Font = ActiveTheme.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = sliderContainer
            })
            
            -- Create value display
            local valueDisplay = Create("TextLabel", {
                Name = "Value",
                Size = UDim2.new(0, 60, 0, 18),
                Position = UDim2.new(1, -70, 0, 9),
                Text = tostring(default),
                TextColor3 = ActiveTheme.TextSecondary,
                TextSize = ActiveTheme.TextSize,
                Font = ActiveTheme.Font,
                TextXAlignment = Enum.TextXAlignment.Right,
                BackgroundTransparency = 1,
                Parent = sliderContainer
            })
            
            -- Create description if provided
            if description then
                local descriptionLabel = Create("TextLabel", {
                    Name = "Description",
                    Size = UDim2.new(1, -20, 0, 18),
                    Position = UDim2.new(0, 10, 0, 26),
                    Text = description,
                    TextColor3 = ActiveTheme.TextSecondary,
                    TextSize = ActiveTheme.TextSize - 2,
                    Font = ActiveTheme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Parent = sliderContainer
                })
                
                slider.Description = descriptionLabel
            end
            
            -- Create slider track
            local sliderTrack = Create("Frame", {
                Name = "Track",
                Size = UDim2.new(1, -20, 0, 6),
                Position = UDim2.new(0, 10, 0, description and 48 or 30),
                BackgroundColor3 = ActiveTheme.SecondaryBackground,
                BorderSizePixel = 0,
                Parent = sliderContainer
            })
            
            local trackCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderTrack
            })
            
            -- Create slider fill
            local sliderFill = Create("Frame", {
                Name = "Fill",
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = ActiveTheme.Primary,
                BorderSizePixel = 0,
                Parent = sliderTrack
            })
            
            local fillCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderFill
            })
            
            -- Create slider thumb
            local sliderThumb = Create("Frame", {
                Name = "Thumb",
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = ActiveTheme.Primary,
                BorderSizePixel = 0,
                Parent = sliderTrack
            })
            
            local thumbCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = sliderThumb
            })
            
            -- Helper function to calculate decimal places
            function GetDecimalPlaces(num)
                local str = tostring(num)
                local decimalPos = str:find('%.')
                return decimalPos and #str - decimalPos or 0
            end
            
            -- Helper function to snap value to increment
            local function SnapToIncrement(value)
                local decimalPlaces = GetDecimalPlaces(increment)
                return FormatNumber(math.floor(value / increment + 0.5) * increment, decimalPlaces)
            end
            
            -- Update slider value
            local function updateSlider(newValue)
                -- Clamp and snap to increment
                local snappedValue = SnapToIncrement(math.clamp(newValue, min, max))
                
                -- Update visual elements
                local percent = (snappedValue - min) / (max - min)
                
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                sliderThumb.Position = UDim2.new(percent, 0, 0.5, 0)
                valueDisplay.Text = tostring(snappedValue)
                
                -- Save to config and execute callback
                ConfigSystem:SetFlag(flag, snappedValue)
                callback(snappedValue)
                
                return snappedValue
            end
            
            -- Initial value
            local value = default
            ConfigSystem:SetFlag(flag, value)
            
            -- Slider interaction
            local dragging = false
            
            sliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    
                    -- Update on initial click
                    local percent = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                    value = updateSlider(min + (max - min) * percent)
                end
            end)
            
            sliderTrack.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            sliderThumb.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)
            
            sliderThumb.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local percent = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                    value = updateSlider(min + (max - min) * percent)
                end
            end)
            
            -- Slider methods
            function slider:Set(newValue)
                value = updateSlider(newValue)
            end
            
            function slider:GetValue()
                return value
            end
            
            function slider:SetRange(newMin, newMax)
                min = newMin
                max = newMax
                value = math.clamp(value, min, max)
                updateSlider(value)
            end
            
            function slider:SetIncrement(newIncrement)
                increment = newIncrement
                updateSlider(value)
            end
            
            function slider:SetCallback(newCallback)
                callback = newCallback
            end
            
            -- Track the slider
            slider.Type = "Slider"
            slider.Flag = flag
            slider.Container = sliderContainer
            slider.Title = sliderTitle
            slider.Value = valueDisplay
            slider.Track = sliderTrack
            slider.Fill = sliderFill
            slider.Thumb = sliderThumb
            
            table.insert(tab.Elements, slider)
            
            return slider
        end
        
        function tab:CreateInput(options, flag)
            options = options or {}
            local name = options.Name or "Input"
            local description = options.Description
            local placeholderText = options.PlaceholderText or "Enter text..."
            local default = options.Default or ""
            local callback = options.Callback or function() end
            flag = flag or name
            
            local input = {}
            
            -- Create input container
            local height = description and 70 or 52
            local inputContainer = Create("Frame", {
                Name = "Input_" .. name,
                Size = UDim2.new(1, 0, 0, height),
                BackgroundColor3 = ActiveTheme.ElementBackground,
                BackgroundTransparency = 0.2,
                Parent = tabContainer
            })
            
            local inputCorner = Create("UICorner", {
                CornerRadius = ActiveTheme.CornerRadius,
                Parent = inputContainer
            })
            
            -- Create input title
            local inputTitle = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -20, 0, 18),
                Position = UDim2.new(0, 10, 0, 9),
                Text = name,
                TextColor3 = ActiveTheme.TextPrimary,
                TextSize = ActiveTheme.TextSize,
                Font = ActiveTheme.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = inputContainer
            })
            
            -- Create description if provided
            if description then
                local descriptionLabel = Create("TextLabel", {
                    Name = "Description",
                    Size = UDim2.new(1, -20, 0, 18),
                    Position = UDim2.new(0, 10, 0, 26),
                    Text = description,
                    TextColor3 = ActiveTheme.TextSecondary,
                    TextSize = ActiveTheme.TextSize - 2,
                    Font = ActiveTheme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Parent = inputContainer
                })
                
                input.Description = descriptionLabel
            end
            
            -- Create input field
            local inputField = Create("Frame", {
                Name = "InputField",
                Size = UDim2.new(1, -20, 0, 24),
                Position = UDim2.new(0, 10, 0, description and 44 or 28),
                BackgroundColor3 = ActiveTheme.InputBackground,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Parent = inputContainer
            })
            
            local inputCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = inputField
            })
            
            -- Create text box
            local textBox = Create("TextBox", {
                Name = "TextBox",
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = default,
                PlaceholderText = placeholderText,
                TextColor3 = ActiveTheme.TextPrimary,
                PlaceholderColor3 = ActiveTheme.TextSecondary,
                TextSize = ActiveTheme.TextSize,
                Font = ActiveTheme.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = inputField
            })
            
            -- Save initial value to config
            ConfigSystem:SetFlag(flag, default)
            
            -- Handle text input
            textBox.FocusLost:Connect(function(enterPressed)
                local newValue = textBox.Text
                ConfigSystem:SetFlag(flag, newValue)
                callback(newValue, enterPressed)
            end)
            
            -- Input methods
            function input:Set(value)
                textBox.Text = value
                ConfigSystem:SetFlag(flag, value)
                callback(value, false)
            end
            
            function input:GetValue()
                return textBox.Text
            end
            
            function input:SetCallback(newCallback)
                callback = newCallback
            end
            
            -- Track the input
            input.Type = "Input"
            input.Flag = flag
            input.Container = inputContainer
            input.Title = inputTitle
            input.Field = inputField
            input.TextBox = textBox
            
            table.insert(tab.Elements, input)
            
            return input
        end
        
        function tab:CreateDropdown(options, flag)
            options = options or {}
            local name = options.Name or "Dropdown"
            local description = options.Description
            local items = options.Items or {}
            local callback = options.Callback or function() end
            local default = options.Default
            flag = flag or name
            
            local dropdown = {}
            local isOpen = false
            local selected = default
            
            -- Create dropdown container
            local height = description and 70 or 52
            local dropdownContainer = Create("Frame", {
                Name = "Dropdown_" .. name,
                Size = UDim2.new(1, 0, 0, height),
                BackgroundColor3 = ActiveTheme.ElementBackground,
                BackgroundTransparency = 0.2,
                ClipsDescendants = true,
                Parent = tabContainer
            })
            
            local containerCorner = Create("UICorner", {
                CornerRadius = ActiveTheme.CornerRadius,
                Parent = dropdownContainer
            })
            
            -- Create dropdown title
            local dropdownTitle = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -20, 0, 18),
                Position = UDim2.new(0, 10, 0, 9),
                Text = name,
                TextColor3 = ActiveTheme.TextPrimary,
                TextSize = ActiveTheme.TextSize,
                Font = ActiveTheme.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = dropdownContainer
            })
            
            -- Create description if provided
            if description then
                local descriptionLabel = Create("TextLabel", {
                    Name = "Description",
                    Size = UDim2.new(1, -20, 0, 18),
                    Position = UDim2.new(0, 10, 0, 26),
                    Text = description,
                    TextColor3 = ActiveTheme.TextSecondary,
                    TextSize = ActiveTheme.TextSize - 2,
                    Font = ActiveTheme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Parent = dropdownContainer
                })
                
                dropdown.Description = descriptionLabel
            end
            
            -- Create dropdown button
            local dropdownButton = Create("Frame", {
                Name = "DropdownButton",
                Size = UDim2.new(1, -20, 0, 24),
                Position = UDim2.new(0, 10, 0, description and 44 or 28),
                BackgroundColor3 = ActiveTheme.InputBackground,
                BorderSizePixel = 0,
                Parent = dropdownContainer
            })
            
            local buttonCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = dropdownButton
            })
            
            -- Create selected label
            local selectedLabel = Create("TextLabel", {
                Name = "Selected",
                Size = UDim2.new(1, -36, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                Text = selected or "Select...",
                TextColor3 = selected and ActiveTheme.TextPrimary or ActiveTheme.TextSecondary,
                TextSize = ActiveTheme.TextSize,
                Font = ActiveTheme.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = dropdownButton
            })
            
            -- Create dropdown arrow
            local arrowIcon = Create("ImageLabel", {
                Name = "Arrow",
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(1, -24, 0, 4),
                BackgroundTransparency = 1,
                Image = IconSets[ActiveTheme.IconPack].add,
                ImageColor3 = ActiveTheme.TextSecondary,
                Rotation = 180,
                Parent = dropdownButton
            })
            
            -- Create dropdown list container
            local listContainer = Create("Frame", {
                Name = "ListContainer",
                Size = UDim2.new(1, -20, 0, 0),
                Position = UDim2.new(0, 10, 0, description and 70 or 54),
                BackgroundColor3 = ActiveTheme.InputBackground,
                BorderSizePixel = 0,
                Visible = false,
                Parent = dropdownContainer
            })
            
            local listCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = listContainer
            })
            
            -- Create scrolling list for options
            local optionsList = Create("ScrollingFrame", {
                Name = "OptionsList",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = ActiveTheme.Primary,
                ScrollBarImageTransparency = 0.5,
                Parent = listContainer
            })
            
            local optionsLayout = Create("UIListLayout", {
                Padding = UDim.new(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = optionsList
            })
            
            local optionsPadding = Create("UIPadding", {
                PaddingTop = UDim.new(0, 2),
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                Parent = optionsList
            })
            
            -- Track dropdown items
            local dropdownItems = {}
            
            -- Handle option selection
            local function selectOption(option)
                selectedLabel.Text = option
                selectedLabel.TextColor3 = ActiveTheme.TextPrimary
                selected = option
                
                -- Save to config and execute callback
                ConfigSystem:SetFlag(flag, option)
                callback(option)
                
                -- Close dropdown
                closeDropdown()
            end
            
            -- Populate options
            local function populateOptions()
                -- Clear existing options
                for _, item in pairs(dropdownItems) do
                    item:Destroy()
                end
                dropdownItems = {}
                
                -- Add new options
                for i, option in ipairs(items) do
                    local optionButton = Create("TextButton", {
                        Name = "Option_" .. option,
                        Size = UDim2.new(1, -4, 0, 24),
                        BackgroundColor3 = selected == option and ActiveTheme.Primary or ActiveTheme.ElementBackground,
                        BackgroundTransparency = 0.5,
                        Text = "",
                        Parent = optionsList
                    })
                    
                    local optionCorner = Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = optionButton
                    })
                    
                    local optionLabel = Create("TextLabel", {
                        Name = "Label",
                        Size = UDim2.new(1, -16, 1, 0),
                        Position = UDim2.new(0, 8, 0, 0),
                        Text = option,
                        TextColor3 = selected == option and ActiveTheme.TextPrimary or ActiveTheme.TextSecondary,
                        TextSize = ActiveTheme.TextSize,
                        Font = ActiveTheme.Font,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Parent = optionButton
                    })
                    
                    -- Handle option click
                    optionButton.MouseButton1Click:Connect(function()
                        selectOption(option)
                    end)
                    
                    table.insert(dropdownItems, optionButton)
                end
                
                -- Update dropdown list size
                local optionsHeight = math.min(#items * 26, 150)
                optionsList.CanvasSize = UDim2.new(0, 0, 0, #items * 26)
                return optionsHeight
            end
            
            -- Toggle dropdown
            local function toggleDropdown()
                isOpen = not isOpen
                
                if isOpen then
                    -- Populate options and get height
                    local optionsHeight = populateOptions()
                    
                    -- Show dropdown list
                    listContainer.Visible = true
                    
                    -- Animate opening
                    TweenService:Create(arrowIcon, TweenInfo.new(0.2), {
                        Rotation = 0
                    }):Play()
                    
                    TweenService:Create(listContainer, TweenInfo.new(0.2), {
                        Size = UDim2.new(1, -20, 0, optionsHeight)
                    }):Play()
                    
                    TweenService:Create(dropdownContainer, TweenInfo.new(0.2), {
                        Size = UDim2.new(1, 0, 0, height + optionsHeight + 6)
                    }):Play()
                else
                    closeDropdown()
                end
            end
            
            -- Close dropdown
            function closeDropdown()
                if not isOpen then return end
                isOpen = false
                
                -- Animate closing
                TweenService:Create(arrowIcon, TweenInfo.new(0.2), {
                    Rotation = 180
                }):Play()
                
                TweenService:Create(listContainer, TweenInfo.new(0.2), {
                    Size = UDim2.new(1, -20, 0, 0)
                }):Play()
                
                TweenService:Create(dropdownContainer, TweenInfo.new(0.2), {
                    Size = UDim2.new(1, 0, 0, height)
                }):Play()
                
                -- Hide dropdown list after animation
                spawn(function()
                    wait(0.2)
                    listContainer.Visible = false
                end)
            end
            
            -- Handle dropdown button interaction
            dropdownButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    toggleDropdown()
                end
            end)
            
            -- Close dropdown when clicking elsewhere
            UserInputService.InputBegan:Connect(function(input)
                if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local position = input.Position
                    local inDropdown = 
                        position.X >= dropdownContainer.AbsolutePosition.X and
                        position.X <= dropdownContainer.AbsolutePosition.X + dropdownContainer.AbsoluteSize.X and
                        position.Y >= dropdownContainer.AbsolutePosition.Y and
                        position.Y <= dropdownContainer.AbsolutePosition.Y + dropdownContainer.AbsoluteSize.Y
                    
                    if not inDropdown then
                        closeDropdown()
                    end
                end
            end)
            
            -- Set default option if provided
            if default and table.find(items, default) then
                selectOption(default)
            else
                -- If no default but items exist, select first item
                if #items > 0 then
                    selectOption(items[1])
                end
            end
            
            -- Save to config system
            ConfigSystem:SetFlag(flag, selected)
            
            -- Dropdown methods
            function dropdown:Set(option)
                if table.find(items, option) then
                    selectOption(option)
                end
            end
            
            function dropdown:GetValue()
                return selected
            end
            
            function dropdown:SetItems(newItems)
                items = newItems
                
                -- If selected item no longer exists, select first item
                if not table.find(items, selected) and #items > 0 then
                    selectOption(items[1])
                elseif #items == 0 then
                    selected = nil
                    selectedLabel.Text = "Select..."
                    selectedLabel.TextColor3 = ActiveTheme.TextSecondary
                end
                
                -- Refresh dropdown if open
                if isOpen then
                    populateOptions()
                end
            end
            
            function dropdown:AddItem(item)
                if not table.find(items, item) then
                    table.insert(items, item)
                    
                    -- Select first item if nothing is selected
                    if not selected and #items == 1 then
                        selectOption(item)
                    end
                    
                    -- Refresh dropdown if open
                    if isOpen then
                        populateOptions()
                    end
                end
            end
            
            function dropdown:RemoveItem(item)
                local index = table.find(items, item)
                if index then
                    table.remove(items, index)
                    
                    -- If removed item was selected, select first item
                    if selected == item then
                        if #items > 0 then
                            selectOption(items[1])
                        else
                            selected = nil
                            selectedLabel.Text = "Select..."
                            selectedLabel.TextColor3 = ActiveTheme.TextSecondary
                        end
                    end
                    
                    -- Refresh dropdown if open
                    if isOpen then
                        populateOptions()
                    end
                end
            end
            
            function dropdown:SetCallback(newCallback)
                callback = newCallback
            end
            
            -- Track the dropdown
            dropdown.Type = "Dropdown"
            dropdown.Flag = flag
            dropdown.Container = dropdownContainer
            dropdown.Title = dropdownTitle
            dropdown.Button = dropdownButton
            dropdown.Selected = selectedLabel
            dropdown.List = listContainer
            dropdown.Items = items
            
            table.insert(tab.Elements, dropdown)
            
            return dropdown
        end
        
        function tab:CreateColorPicker(options, flag)
            options = options or {}
            local name = options.Name or "ColorPicker"
            local description = options.Description
            local default = options.Color or Color3.fromRGB(255, 255, 255)
            local callback = options.Callback or function() end
            flag = flag or name
            
            local colorPicker = {}
            local isOpen = false
            
            -- Create color picker container
            local height = description and 70 or 52
            local colorPickerContainer = Create("Frame", {
                Name = "ColorPicker_" .. name,
                Size = UDim2.new(1, 0, 0, height),
                BackgroundColor3 = ActiveTheme.ElementBackground,
                BackgroundTransparency = 0.2,
                ClipsDescendants = true,
                Parent = tabContainer
            })
            
            local containerCorner = Create("UICorner", {
                CornerRadius = ActiveTheme.CornerRadius,
                Parent = colorPickerContainer
            })
            
            -- Create color picker title
            local colorPickerTitle = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -60, 0, 18),
                Position = UDim2.new(0, 10, 0, 9),
                Text = name,
                TextColor3 = ActiveTheme.TextPrimary,
                TextSize = ActiveTheme.TextSize,
                Font = ActiveTheme.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = colorPickerContainer
            })
            
            -- Create description if provided
            if description then
                local descriptionLabel = Create("TextLabel", {
                    Name = "Description",
                    Size = UDim2.new(1, -60, 0, 18),
                    Position = UDim2.new(0, 10, 0, 26),
                    Text = description,
                    TextColor3 = ActiveTheme.TextSecondary,
                    TextSize = ActiveTheme.TextSize - 2,
                    Font = ActiveTheme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Parent = colorPickerContainer
                })
                
                colorPicker.Description = descriptionLabel
            end
            
            -- Create color preview
            local colorPreview = Create("Frame", {
                Name = "ColorPreview",
                Size = UDim2.new(0, 30, 0, 22),
                Position = UDim2.new(1, -44, 0, description and 22 or 6),
                BackgroundColor3 = default,
                BorderSizePixel = 0,
                Parent = colorPickerContainer
            })
            
            local previewCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = colorPreview
            })
            
            -- Create color picker panel
            local colorPickerPanel = Create("Frame", {
                Name = "ColorPickerPanel",
                Size = UDim2.new(1, -20, 0, 0),
                Position = UDim2.new(0, 10, 0, height),
                BackgroundColor3 = ActiveTheme.ContainerBackground,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Visible = false,
                Parent = colorPickerContainer
            })
            
            local panelCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = colorPickerPanel
            })
            
            -- Save initial color to config
            ConfigSystem:SetFlag(flag, {default.R, default.G, default.B})
            
            -- Toggle color picker
            local function toggleColorPicker()
                isOpen = not isOpen
                
                if isOpen then
                    -- TODO: Implement color picker panel UI
                    -- For now, we'll use a simplified version
                    
                    -- Show color picker panel
                    colorPickerPanel.Visible = true
                    
                    -- Animate opening
                    TweenService:Create(colorPickerPanel, TweenInfo.new(0.2), {
                        Size = UDim2.new(1, -20, 0, 120)
                    }):Play()
                    
                    TweenService:Create(colorPickerContainer, TweenInfo.new(0.2), {
                        Size = UDim2.new(1, 0, 0, height + 126)
                    }):Play()
                else
                    closeColorPicker()
                end
            end
            
            -- Close color picker
            function closeColorPicker()
                if not isOpen then return end
                isOpen = false
                
                -- Animate closing
                TweenService:Create(colorPickerPanel, TweenInfo.new(0.2), {
                    Size = UDim2.new(1, -20, 0, 0)
                }):Play()
                
                TweenService:Create(colorPickerContainer, TweenInfo.new(0.2), {
                    Size = UDim2.new(1, 0, 0, height)
                }):Play()
                
                -- Hide panel after animation
                spawn(function()
                    wait(0.2)
                    colorPickerPanel.Visible = false
                end)
            end
            
            -- Handle preview click
            colorPreview.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    toggleColorPicker()
                end
            end)
            
            -- Close when clicking elsewhere
            UserInputService.InputBegan:Connect(function(input)
                if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local position = input.Position
                    local inColorPicker = 
                        position.X >= colorPickerContainer.AbsolutePosition.X and
                        position.X <= colorPickerContainer.AbsolutePosition.X + colorPickerContainer.AbsoluteSize.X and
                        position.Y >= colorPickerContainer.AbsolutePosition.Y and
                        position.Y <= colorPickerContainer.AbsolutePosition.Y + colorPickerContainer.AbsoluteSize.Y
                    
                    if not inColorPicker then
                        closeColorPicker()
                    end
                end
            end)
            
            -- ColorPicker methods
            function colorPicker:Set(color)
                colorPreview.BackgroundColor3 = color
                ConfigSystem:SetFlag(flag, {color.R, color.G, color.B})
                callback(color)
            end
            
            function colorPicker:GetColor()
                return colorPreview.BackgroundColor3
            end
            
            function colorPicker:SetCallback(newCallback)
                callback = newCallback
            end
            
            -- Track the color picker
            colorPicker.Type = "ColorPicker"
            colorPicker.Flag = flag
            colorPicker.Container = colorPickerContainer
            colorPicker.Title = colorPickerTitle
            colorPicker.Preview = colorPreview
            colorPicker.Panel = colorPickerPanel
            
            table.insert(tab.Elements, colorPicker)
            
            return colorPicker
        end
        
        return tab
    end
    
    -- Select a tab by ID
    function window:SelectTab(tabId)
        if not self.Tabs[tabId] then return end
        
        -- Deselect current tab
        if self.ActiveTab then
            local currentTab = self.Tabs[self.ActiveTab]
            
            -- Update tab button styling
            if currentTab.Icon then
                TweenService:Create(currentTab.Icon, TweenInfo.new(0.2), {
                    ImageColor3 = ActiveTheme.TextSecondary
                }):Play()
            end
            
            TweenService:Create(currentTab.Title, TweenInfo.new(0.2), {
                TextColor3 = ActiveTheme.TextSecondary
            }):Play()
            
            TweenService:Create(currentTab.Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.5
            }):Play()
            
            -- Hide selection indicator
            local indicator = currentTab.Button:FindFirstChild("SelectionIndicator")
            if indicator then
                TweenService:Create(indicator, TweenInfo.new(0.2), {
                    BackgroundTransparency = 1
                }):Play()
            end
            
            -- Hide tab content
            currentTab.Container.Visible = false
        end
        
        -- Select new tab
        self.ActiveTab = tabId
        local tab = self.Tabs[tabId]
        
        -- Update tab button styling
        if tab.Icon then
            TweenService:Create(tab.Icon, TweenInfo.new(0.2), {
                ImageColor3 = ActiveTheme.Primary
            }):Play()
        end
        
        TweenService:Create(tab.Title, TweenInfo.new(0.2), {
            TextColor3 = ActiveTheme.Primary
        }):Play()
        
        TweenService:Create(tab.Button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.2
        }):Play()
        
        -- Show selection indicator
        local indicator = tab.Button:FindFirstChild("SelectionIndicator")
        if indicator then
            TweenService:Create(indicator, TweenInfo.new(0.2), {
                BackgroundTransparency = 0
            }):Play()
        end
        
        -- Show tab content
        tab.Container.Visible = true
    end
    
    -- Method to close the window
    function window:Close()
        closeCallback()
        
        -- Save config on close if configured
        if ConfigSystem.AutoSaveEnabled then
            ConfigSystem:SaveConfig("autosave")
        end
        
        -- Animate close
        TweenService:Create(windowFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, size[1], 0, 0),
            Position = UDim2.new(windowFrame.Position.X.Scale, windowFrame.Position.X.Offset, 
                               windowFrame.Position.Y.Scale, windowFrame.Position.Y.Offset + size[2]/2)
        }):Play()
        
        -- Destroy after animation
        wait(0.4)
        screenGui:Destroy()
    end
    
    return window
end

-- Notification System
function TBD:Notification(options)
    return NotificationSystem:Notify(options)
end

-- Config Methods
function TBD:SaveConfig(name)
    return ConfigSystem:SaveConfig(name)
end

function TBD:LoadConfig(name)
    return ConfigSystem:LoadConfig(name)
end

function TBD:ListConfigs()
    return ConfigSystem:ListConfigs()
end

function TBD:LoadAutoloadConfig()
    return ConfigSystem:LoadConfig("autosave")
end

-- Theme Methods
function TBD:SetTheme(theme)
    if ThemePresets[theme] then
        ActiveTheme = table.clone(ThemePresets[theme])
        return true
    end
    return false
end

function TBD:GetTheme()
    return ActiveTheme
end

function TBD:CustomTheme(themeOptions)
    local customTheme = table.clone(ActiveTheme)
    for key, value in pairs(themeOptions) do
        customTheme[key] = value
    end
    ActiveTheme = customTheme
end

-- Destroy the UI
function TBD:Destroy()
    for _, instance in pairs(workspace:GetDescendants()) do
        if instance:IsA("ScreenGui") and instance.Name == "TBDInterfaceSuite" then
            instance:Destroy()
        end
    end
    
    -- Clean up notification container
    if NotificationSystem.Container and NotificationSystem.Container.Parent then
        NotificationSystem.Container.Parent:Destroy()
    end
end

return TBD