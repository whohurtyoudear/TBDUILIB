--[[
    TBD UI Library - Enhanced Version
    A modern, feature-rich Roblox UI library for script hubs and executors
    With improved mobile support, better notifications, and enhanced design
    Version 1.1.0
]]

-- Main Library Table
local TBD = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

-- Constants and Settings
local ANIMATION_DURATION = 0.3
local DEFAULT_FONT = Enum.Font.GothamSemibold
local CORNER_RADIUS = UDim.new(0, 8)
local ELEMENT_HEIGHT = 38
local LIBRARY_NAME = "TBD"

-- Device Detection
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local SCREEN_SIZE = workspace.CurrentCamera.ViewportSize
local SCREEN_SCALE = math.min(1, SCREEN_SIZE.X / 1200)
local SAFE_AREA = GuiService:GetSafeInsets()

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
    -- Skip dragging setup on mobile
    if IS_MOBILE then return end
    
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

-- Device-Specific Adjustments
local function ScaleToDevice(value)
    if IS_MOBILE then
        return value * SCREEN_SCALE * 1.2 -- Slightly larger on mobile
    end
    return value
end

local function AdjustForMobile(uiElement)
    if IS_MOBILE then
        -- Make interactive elements larger on mobile
        if uiElement:IsA("TextButton") or uiElement:IsA("ImageButton") then
            uiElement.Size = UDim2.new(
                uiElement.Size.X.Scale,
                uiElement.Size.X.Offset * 1.2,
                uiElement.Size.Y.Scale,
                uiElement.Size.Y.Offset * 1.2
            )
        end
    end
end

-- Icon System with improved sets
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
        minimize = "rbxassetid://8150194957",
        maximize = "rbxassetid://8150151689",
        eye = "rbxassetid://8150188445",
        map = "rbxassetid://8150192356",
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
        minimize = "rbxassetid://9478585791",
        maximize = "rbxassetid://9478583892",
        eye = "rbxassetid://9478584423",
        map = "rbxassetid://9478584590",
    }
}

-- Enhanced Theme System with more modern presets
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
        IconPack = "Phosphor",
        MobileCompatible = true,
        LoadingScreenCustomization = {
            BackgroundColor = nil, -- Uses Background by default
            LogoSize = UDim2.new(0, 100, 0, 100),
            LogoPosition = UDim2.new(0.5, 0, 0.35, 0),
            TitlePosition = UDim2.new(0.5, 0, 0.55, 0),
            SubtitlePosition = UDim2.new(0.5, 0, 0.62, 0),
            ProgressBarPosition = UDim2.new(0.5, 0, 0.75, 0),
            ProgressBarSize = UDim2.new(0.7, 0, 0, 6),
            AnimationStyle = "Fade" -- "Fade", "Slide", "Scale"
        }
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
        IconPack = "Phosphor",
        MobileCompatible = true,
        LoadingScreenCustomization = {
            BackgroundColor = nil,
            LogoSize = UDim2.new(0, 100, 0, 100),
            LogoPosition = UDim2.new(0.5, 0, 0.35, 0),
            TitlePosition = UDim2.new(0.5, 0, 0.55, 0),
            SubtitlePosition = UDim2.new(0.5, 0, 0.62, 0),
            ProgressBarPosition = UDim2.new(0.5, 0, 0.75, 0),
            ProgressBarSize = UDim2.new(0.7, 0, 0, 6),
            AnimationStyle = "Slide"
        }
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
        IconPack = "Phosphor",
        MobileCompatible = true,
        LoadingScreenCustomization = {
            BackgroundColor = nil,
            LogoSize = UDim2.new(0, 120, 0, 120),
            LogoPosition = UDim2.new(0.5, 0, 0.35, 0),
            TitlePosition = UDim2.new(0.5, 0, 0.55, 0),
            SubtitlePosition = UDim2.new(0.5, 0, 0.62, 0),
            ProgressBarPosition = UDim2.new(0.5, 0, 0.75, 0),
            ProgressBarSize = UDim2.new(0.7, 0, 0, 6),
            AnimationStyle = "Scale"
        }
    },
    Aqua = {
        Primary = Color3.fromRGB(0, 210, 255),
        PrimaryDark = Color3.fromRGB(0, 180, 225),
        Background = Color3.fromRGB(16, 24, 30),
        ContainerBackground = Color3.fromRGB(24, 36, 44),
        SecondaryBackground = Color3.fromRGB(30, 44, 55),
        ElementBackground = Color3.fromRGB(38, 54, 65),
        TextPrimary = Color3.fromRGB(240, 245, 255),
        TextSecondary = Color3.fromRGB(170, 190, 210),
        Success = Color3.fromRGB(70, 230, 170),
        Warning = Color3.fromRGB(255, 190, 65),
        Error = Color3.fromRGB(255, 75, 95),
        Info = Color3.fromRGB(60, 200, 255),
        InputBackground = Color3.fromRGB(48, 64, 75),
        Highlight = Color3.fromRGB(0, 210, 255),
        BorderColor = Color3.fromRGB(50, 65, 75),
        DropShadowEnabled = true,
        RoundingEnabled = true,
        CornerRadius = UDim.new(0, 10),
        AnimationSpeed = 0.3,
        GlassEffect = true,
        BlurIntensity = 15,
        Transparency = 0.95,
        Font = Enum.Font.GothamSemibold,
        HeaderSize = 18,
        TextSize = 14,
        IconPack = "Phosphor",
        MobileCompatible = true,
        LoadingScreenCustomization = {
            BackgroundColor = nil,
            LogoSize = UDim2.new(0, 100, 0, 100),
            LogoPosition = UDim2.new(0.5, 0, 0.35, 0),
            TitlePosition = UDim2.new(0.5, 0, 0.55, 0),
            SubtitlePosition = UDim2.new(0.5, 0, 0.62, 0),
            ProgressBarPosition = UDim2.new(0.5, 0, 0.75, 0),
            ProgressBarSize = UDim2.new(0.7, 0, 0, 6),
            AnimationStyle = "Fade"
        }
    }
}

-- Set active theme to Default
local ActiveTheme = table.clone(ThemePresets.Default)

-- Configuration System with improved error handling
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
    
    local success, err = pcall(function()
        local root = self.RootFolder
        local configPath = root .. "/" .. self.ConfigFolder
        
        if not isfolder(root) then
            makefolder(root)
        end
        
        if not isfolder(configPath) then
            makefolder(configPath)
        end
    end)
    
    if not success then
        warn("TBD UI | Failed to create config folders:", err)
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
        local saveSuccess, saveError = pcall(function()
            writefile(path, result)
        end)
        
        if not saveSuccess then
            warn("TBD UI | Failed to save config:", saveError)
            return false
        end
        return true
    end
    
    warn("TBD UI | Failed to encode config data")
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
        
        if success and type(result) == "table" then
            -- Update flags
            for flag, value in pairs(result) do
                self.Flags[flag] = value
            end
            
            self.LoadedConfig = name
            return true
        else
            warn("TBD UI | Failed to load config: Invalid format")
        end
    end
    
    return false
end

function ConfigSystem:ListConfigs()
    if not isfolder or not listfiles then return {} end
    
    local configs = {}
    
    local success, result = pcall(function()
        local path = self.RootFolder .. "/" .. self.ConfigFolder
        if not isfolder(path) then
            self:EnsureFolders()
            return {}
        end
        
        local files = listfiles(path)
        
        for _, file in pairs(files) do
            local name = file:match("([^/\\]+)%.tbd$")
            if name then
                table.insert(configs, name)
            end
        end
        
        return configs
    end)
    
    if success then
        return result
    else
        warn("TBD UI | Failed to list configs:", result)
        return {}
    end
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

-- Enhanced Key System
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
    
    local success, result = pcall(function()
        local path = ConfigSystem.RootFolder .. "/keydata.txt"
        
        if isfile(path) then
            return readfile(path)
        end
        
        return nil
    end)
    
    if success then
        return result
    else
        warn("TBD UI | Failed to load saved key:", result)
        return nil
    end
end

function KeySystem:SaveKeyToFile(key)
    if not writefile then return end
    
    local success, err = pcall(function()
        local path = ConfigSystem.RootFolder .. "/keydata.txt"
        writefile(path, key)
    end)
    
    if not success then
        warn("TBD UI | Failed to save key:", err)
    end
end

function KeySystem:ShowKeyUI()
    -- Create key UI with mobile support
    local screenGui = Create("ScreenGui", {
        Name = "TBDKeySystem",
        DisplayOrder = 1000,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = (RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui")) or CoreGui
    })
    
    local keyFrame = Create("Frame", {
        Name = "KeyFrame",
        Size = UDim2.new(0, IS_MOBILE and 340 or 400, 0, IS_MOBILE and 240 or 200),
        Position = UDim2.new(0.5, -200, 0.5, -100),
        AnchorPoint = Vector2.new(0.5, 0.5),
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
        TextSize = ScaleToDevice(ActiveTheme.HeaderSize),
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
        TextSize = ScaleToDevice(ActiveTheme.TextSize),
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
        TextSize = ScaleToDevice(ActiveTheme.TextSize),
        Font = ActiveTheme.Font,
        TextWrapped = true,
        BackgroundTransparency = 1,
        Parent = keyFrame
    })
    
    -- Key input
    local keyInputFrame = Create("Frame", {
        Name = "KeyInputFrame",
        Size = UDim2.new(1, -20, 0, IS_MOBILE and 40 or 30),
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
        TextSize = ScaleToDevice(ActiveTheme.TextSize),
        Font = ActiveTheme.Font,
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        Parent = keyInputFrame
    })
    
    -- Submit button
    local submitButton = Create("TextButton", {
        Name = "SubmitButton",
        Size = UDim2.new(0, IS_MOBILE and 120 or 100, 0, IS_MOBILE and 40 or 30),
        Position = UDim2.new(0.5, self.SecondaryAction.Enabled and -IS_MOBILE and -130 or -105 or -(IS_MOBILE and 60 or 50), 0, IS_MOBILE and 170 or 150),
        Text = "Submit",
        TextColor3 = ActiveTheme.TextPrimary,
        TextSize = ScaleToDevice(ActiveTheme.TextSize),
        Font = ActiveTheme.Font,
        BackgroundColor3 = ActiveTheme.Primary,
        BorderSizePixel = 0,
        AutoButtonColor = true,
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
            Size = UDim2.new(0, IS_MOBILE and 120 or 100, 0, IS_MOBILE and 40 or 30),
            Position = UDim2.new(0.5, IS_MOBILE and 10 or 5, 0, IS_MOBILE and 170 or 150),
            Text = buttonText,
            TextColor3 = ActiveTheme.TextPrimary,
            TextSize = ScaleToDevice(ActiveTheme.TextSize),
            Font = ActiveTheme.Font,
            BackgroundColor3 = ActiveTheme.ElementBackground,
            BorderSizePixel = 0,
            AutoButtonColor = true,
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
                        Position = UDim2.new(0, 10, 0, IS_MOBILE and 220 or 185),
                        Text = "Discord invite copied to clipboard!",
                        TextColor3 = ActiveTheme.Info,
                        TextSize = ScaleToDevice(ActiveTheme.TextSize - 1),
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
                        Position = UDim2.new(0, 10, 0, IS_MOBILE and 220 or 185),
                        Text = "Key website link copied to clipboard!",
                        TextColor3 = ActiveTheme.Info,
                        TextSize = ScaleToDevice(ActiveTheme.TextSize - 1),
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
                Position = UDim2.new(0, 10, 0, IS_MOBILE and 220 or 185),
                Text = "Key verified successfully!",
                TextColor3 = ActiveTheme.Success,
                TextSize = ScaleToDevice(ActiveTheme.TextSize - 1),
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
                Position = UDim2.new(0, 10, 0, IS_MOBILE and 220 or 185),
                Text = "Invalid key! Please try again.",
                TextColor3 = ActiveTheme.Error,
                TextSize = ScaleToDevice(ActiveTheme.TextSize - 1),
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
    
    -- Make UI draggable (non-mobile only)
    EnableDragging(keyFrame, keyFrame)
    
    -- Wait for key verification
    while screenGui.Parent and not validKey do
        wait()
    end
    
    return validKey
end

-- Improved Notification System with better positioning for all devices
local NotificationSystem = {
    Container = nil,
    Notifications = {},
    MaxVisible = 6,
    DefaultDuration = 5,
    Position = "TopRight",
    Margin = 10,
    Width = 300,
    Height = 80,
    CurrentLayout = nil -- Used to track and update notifications when screen changes
}

function NotificationSystem:Init()
    -- Calculate best position for notifications based on screen size and safe areas
    local screenGui = Create("ScreenGui", {
        Name = "TBDNotifications",
        DisplayOrder = 1000,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = (RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui")) or CoreGui
    })
    
    -- Adjust notification size for mobile
    if IS_MOBILE then
        self.Width = math.min(300, SCREEN_SIZE.X * 0.8)
        self.Height = 100 -- Taller for readability on mobile
    end
    
    -- Determine best position based on screen
    local mobileOffset = IS_MOBILE and 50 or 10
    
    -- Adjust position to account for safe areas on mobile
    local xOffset = (self.Position:match("Right") and -self.Margin - SAFE_AREA.Right) or self.Margin + SAFE_AREA.Left
    local yOffset = (self.Position:match("^Bottom") and -self.Margin - SAFE_AREA.Bottom) or self.Margin + SAFE_AREA.Top + mobileOffset
    
    -- Create notification container with appropriate position
    local frame = Create("Frame", {
        Name = "NotificationContainer",
        Size = UDim2.new(0, self.Width, 1, -mobileOffset * 2),
        Position = self:GetContainerPosition(xOffset, yOffset),
        BackgroundTransparency = 1,
        Parent = screenGui
    })
    
    local layout = Create("UIListLayout", {
        Padding = UDim.new(0, self.Margin),
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = self:GetVerticalAlignment(),
        HorizontalAlignment = self:GetHorizontalAlignment(),
        Parent = frame
    })
    
    -- Save reference to notification container
    self.Container = frame
    self.ScreenGui = screenGui
    
    -- Update notifications when screen size changes
    self.CurrentLayout = {
        Width = SCREEN_SIZE.X,
        Height = SCREEN_SIZE.Y,
        Mobile = IS_MOBILE
    }
    
    -- Listen for screen size changes
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        local newSize = workspace.CurrentCamera.ViewportSize
        if newSize.X ~= self.CurrentLayout.Width or newSize.Y ~= self.CurrentLayout.Height then
            self:UpdateLayout()
        end
    end)
    
    return self
end

function NotificationSystem:UpdateLayout()
    -- This function updates notification container when screen size changes
    
    -- Get new screen size
    local newSize = workspace.CurrentCamera.ViewportSize
    local newMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    
    -- Skip if no significant change
    if math.abs(newSize.X - self.CurrentLayout.Width) < 50 and 
       math.abs(newSize.Y - self.CurrentLayout.Height) < 50 and
       newMobile == self.CurrentLayout.Mobile then
        return
    end
    
    -- Update stored layout
    self.CurrentLayout = {
        Width = newSize.X,
        Height = newSize.Y,
        Mobile = newMobile
    }
    
    -- Adjust notification size
    if newMobile then
        self.Width = math.min(300, newSize.X * 0.8)
        self.Height = 100
    else
        self.Width = 300
        self.Height = 80
    end
    
    -- Adjust for safe areas
    local mobileOffset = newMobile and 50 or 10
    local xOffset = (self.Position:match("Right") and -self.Margin - SAFE_AREA.Right) or self.Margin + SAFE_AREA.Left
    local yOffset = (self.Position:match("^Bottom") and -self.Margin - SAFE_AREA.Bottom) or self.Margin + SAFE_AREA.Top + mobileOffset
    
    -- Update container position and size
    self.Container.Size = UDim2.new(0, self.Width, 1, -mobileOffset * 2)
    self.Container.Position = self:GetContainerPosition(xOffset, yOffset)
    
    -- Update existing notifications
    for _, notification in pairs(self.Notifications) do
        if notification and notification.Parent then
            notification.Size = UDim2.new(1, 0, 0, self.Height)
        end
    end
end

function NotificationSystem:GetContainerPosition(xOffset, yOffset)
    local position = self.Position
    
    -- Default offsets if not provided
    xOffset = xOffset or (position:match("Right") and -self.Margin or self.Margin)
    yOffset = yOffset or (position:match("^Bottom") and -self.Margin or self.Margin)
    
    -- Get anchor points and position based on desired notification position
    local xScale, yScale
    
    if position:match("Right") then
        xScale = 1
    else
        xScale = 0
    end
    
    if position:match("^Bottom") then
        yScale = 1
    else
        yScale = 0
    end
    
    return UDim2.new(xScale, xOffset, yScale, yOffset)
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

function NotificationSystem:SetPosition(position)
    -- Validate position
    if position ~= "TopRight" and position ~= "TopLeft" and 
       position ~= "BottomRight" and position ~= "BottomLeft" then
        position = "TopRight"
    end
    
    -- Update position
    self.Position = position
    
    -- Update layout if container exists
    if self.Container then
        local mobileOffset = IS_MOBILE and 50 or 10
        local xOffset = (position:match("Right") and -self.Margin - SAFE_AREA.Right) or self.Margin + SAFE_AREA.Left
        local yOffset = (position:match("^Bottom") and -self.Margin - SAFE_AREA.Bottom) or self.Margin + SAFE_AREA.Top + mobileOffset
        
        self.Container.Position = self:GetContainerPosition(xOffset, yOffset)
        
        -- Update layout properties
        local layout = self.Container:FindFirstChildOfClass("UIListLayout")
        if layout then
            layout.VerticalAlignment = self:GetVerticalAlignment()
            layout.HorizontalAlignment = self:GetHorizontalAlignment()
        end
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
    
    -- Create notification frame with improved mobile support
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
    
    local iconSize = IS_MOBILE and 36 or 32
    local iconPosition = IS_MOBILE and 18 or 16
    
    if iconId then
        local iconContainer = Create("Frame", {
            Name = "IconContainer",
            Size = UDim2.new(0, iconSize, 0, iconSize),
            Position = UDim2.new(0, iconPosition, 0.5, -iconSize/2),
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
    
    -- Content positions adjusted for mobile
    local textPadding = IS_MOBILE and 64 or 56
    local titleYPos = IS_MOBILE and 20 or 15
    local messageYPos = IS_MOBILE and 42 or 35
    
    -- Add title
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -(textPadding + 14), 0, 20),
        Position = UDim2.new(0, textPadding, 0, titleYPos),
        Text = title,
        TextColor3 = ActiveTheme.TextPrimary,
        TextSize = ScaleToDevice(ActiveTheme.HeaderSize),
        Font = ActiveTheme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = notification
    })
    
    -- Add message
    local messageLabel = Create("TextLabel", {
        Name = "Message",
        Size = UDim2.new(1, -(textPadding + 14), 0, IS_MOBILE and 50 or 40),
        Position = UDim2.new(0, textPadding, 0, messageYPos),
        Text = message,
        TextColor3 = ActiveTheme.TextSecondary,
        TextSize = ScaleToDevice(ActiveTheme.TextSize),
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
        Size = UDim2.new(0, IS_MOBILE and 20 or 16, 0, IS_MOBILE and 20 or 16),
        Position = UDim2.new(1, IS_MOBILE and -30 or -26, 0, IS_MOBILE and 20 or 15),
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
        if notification and notification.Parent then
            self:CloseNotification(notification)
        end
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
    -- Check if notification still exists
    if not notification or not notification.Parent then return end
    
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
        if notification and notification.Parent then
            notification:Destroy()
        end
    end)
end

-- Window Class (Enhanced for mobile)
function TBD:CreateWindow(options)
    options = options or {}
    local window = {}
    
    -- Window settings
    local title = options.Title or "TBD Interface Suite"
    local subtitle = options.Subtitle or nil
    local theme = options.Theme or "Default"
    
    -- Default size for desktop, smaller for mobile
    local defaultSize = IS_MOBILE and {math.min(400, SCREEN_SIZE.X * 0.9), math.min(500, SCREEN_SIZE.Y * 0.8)} or {400, 500}
    local size = options.Size or defaultSize
    
    -- Mobile devices always use center positioning with slight upward offset
    local position = IS_MOBILE and {SCREEN_SIZE.X / 2 - size[1] / 2, SCREEN_SIZE.Y / 2 - size[2] / 2 - 20} or 
                    (options.Position == "Center" and {SCREEN_SIZE.X / 2 - size[1] / 2, SCREEN_SIZE.Y / 2 - size[2] / 2} or options.Position)
    
    local closeCallback = options.OnClose or function() end
    local resizable = not IS_MOBILE and (options.Resizable ~= nil and options.Resizable or false)
    local minimumSize = options.MinimumSize or {300, 350}
    local transparency = options.Transparency or ActiveTheme.Transparency
    local logoId = options.LogoId or nil
    local loadingEnabled = options.LoadingEnabled ~= nil and options.LoadingEnabled or true
    local loadingTitle = options.LoadingTitle or "TBD Interface Suite"
    local loadingSubtitle = options.LoadingSubtitle or "Loading..."
    local loadingCustomization = options.LoadingScreenCustomization or {}
    
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
        -- Merge user customization with theme defaults
        local loadingConfig = ActiveTheme.LoadingScreenCustomization or {}
        for key, value in pairs(loadingCustomization) do
            loadingConfig[key] = value
        end
        
        local loadingScreen = Create("Frame", {
            Name = "LoadingScreen",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = loadingConfig.BackgroundColor or ActiveTheme.Background,
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
                Size = loadingConfig.LogoSize or UDim2.new(0, 80, 0, 80),
                Position = loadingConfig.LogoPosition or UDim2.new(0.5, 0, 0.25, 0),
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundTransparency = 1,
                Image = "rbxassetid://" .. logoId,
                Parent = loadingContainer
            })
        end
        
        local titleLabel = Create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -40, 0, 30),
            Position = loadingConfig.TitlePosition or UDim2.new(0, 20, logo and 0.25 + 0.35 or 0.3, 0),
            Text = loadingTitle,
            TextColor3 = ActiveTheme.TextPrimary,
            TextSize = ScaleToDevice(ActiveTheme.HeaderSize + 2),
            Font = ActiveTheme.Font,
            BackgroundTransparency = 1,
            Parent = loadingContainer
        })
        
        local subtitleLabel = Create("TextLabel", {
            Name = "Subtitle",
            Size = UDim2.new(1, -40, 0, 20),
            Position = loadingConfig.SubtitlePosition or UDim2.new(0, 20, logo and 0.25 + 0.45 or 0.4, 0),
            Text = loadingSubtitle,
            TextColor3 = ActiveTheme.TextSecondary,
            TextSize = ScaleToDevice(ActiveTheme.TextSize),
            Font = ActiveTheme.Font,
            BackgroundTransparency = 1,
            Parent = loadingContainer
        })
        
        local loadingBar = Create("Frame", {
            Name = "LoadingBarBackground",
            Size = loadingConfig.ProgressBarSize or UDim2.new(1, -40, 0, 6),
            Position = loadingConfig.ProgressBarPosition or UDim2.new(0, 20, logo and 0.25 + 0.55 or 0.6, 0),
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
        
        -- Animate loading screen with selected style
        local animationStyle = loadingConfig.AnimationStyle or "Fade"
        
        if animationStyle == "Scale" then
            loadingContainer.Size = UDim2.new(0, 0, 0, 0)
            loadingContainer.AnchorPoint = Vector2.new(0.5, 0.5)
            
            TweenService:Create(loadingContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 300, 0, 200)
            }):Play()
        elseif animationStyle == "Slide" then
            loadingContainer.Position = UDim2.new(0.5, 0, 1.5, 0)
            loadingContainer.AnchorPoint = Vector2.new(0.5, 0.5)
            
            TweenService:Create(loadingContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
        else -- Default: Fade
            loadingContainer.BackgroundTransparency = 1
            titleLabel.TextTransparency = 1
            subtitleLabel.TextTransparency = 1
            loadingBar.BackgroundTransparency = 1
            
            if logo then logo.ImageTransparency = 1 end
            
            -- Fade in animation
            TweenService:Create(loadingContainer, TweenInfo.new(0.5), {
                BackgroundTransparency = 0.1
            }):Play()
            
            TweenService:Create(titleLabel, TweenInfo.new(0.5), {
                TextTransparency = 0
            }):Play()
            
            TweenService:Create(subtitleLabel, TweenInfo.new(0.5), {
                TextTransparency = 0
            }):Play()
            
            TweenService:Create(loadingBar, TweenInfo.new(0.5), {
                BackgroundTransparency = 0
            }):Play()
            
            if logo then
                TweenService:Create(logo, TweenInfo.new(0.5), {
                    ImageTransparency = 0
                }):Play()
            end
        end
        
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
            if animationStyle == "Scale" then
                TweenService:Create(loadingContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 0)
                }):Play()
                
                TweenService:Create(loadingScreen, TweenInfo.new(0.5), {
                    BackgroundTransparency = 1
                }):Play()
            elseif animationStyle == "Slide" then
                TweenService:Create(loadingContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
                    Position = UDim2.new(0.5, 0, -0.5, 0)
                }):Play()
                
                TweenService:Create(loadingScreen, TweenInfo.new(0.5), {
                    BackgroundTransparency = 1
                }):Play()
            else -- Default: Fade
                TweenService:Create(loadingScreen, TweenInfo.new(0.5), {
                    BackgroundTransparency = 1
                }):Play()
                
                TweenService:Create(loadingContainer, TweenInfo.new(0.5), {
                    BackgroundTransparency = 1
                }):Play()
                
                TweenService:Create(titleLabel, TweenInfo.new(0.5), {
                    TextTransparency = 1
                }):Play()
                
                TweenService:Create(subtitleLabel, TweenInfo.new(0.5), {
                    TextTransparency = 1
                }):Play()
                
                if logo then
                    TweenService:Create(logo, TweenInfo.new(0.5), {
                        ImageTransparency = 1
                    }):Play()
                end
            end
            
            -- Wait for animation and destroy
            wait(0.5)
            loadingScreen:Destroy()
        end)
    end
    
    -- Main window container with adjusted size for mobile
    local windowFrame = Create("Frame", {
        Name = "WindowContainer",
        Size = UDim2.new(0, size[1], 0, size[2]),
        BackgroundColor3 = ActiveTheme.Background,
        BorderSizePixel = 0,
        Parent = screenGui
    })
    
    -- Position window
    if type(position) == "table" then
        windowFrame.Position = UDim2.new(0, position[1], 0, position[2])
    else
        windowFrame.Position = UDim2.new(0.5, -size[1]/2, 0.5, -size[2]/2)
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
    
    -- Title bar enhanced for mobile
    local titleBarHeight = IS_MOBILE and 40 or 32
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, titleBarHeight),
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
        local logoSize = IS_MOBILE and 22 or 18
        local logoIcon = Create("ImageLabel", {
            Name = "Logo",
            Size = UDim2.new(0, logoSize, 0, logoSize),
            Position = UDim2.new(0, 12, 0, (titleBarHeight - logoSize) / 2),
            BackgroundTransparency = 1,
            Image = "rbxassetid://" .. logoId,
            Parent = titleBar
        })
    end
    
    -- Title text
    local titleTextSize = IS_MOBILE and (ActiveTheme.TextSize + 4) or (ActiveTheme.TextSize + 2)
    local titleText = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -130, 1, 0),
        Position = UDim2.new(0, logoId and (IS_MOBILE and 40 or 36) or 12, 0, 0),
        Text = title,
        TextColor3 = ActiveTheme.TextPrimary,
        TextSize = ScaleToDevice(titleTextSize),
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
            TextSize = ScaleToDevice(ActiveTheme.TextSize),
            Font = ActiveTheme.Font,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Parent = titleBar
        })
    end
    
    -- Close button
    local buttonSize = IS_MOBILE and 20 or 16
    local buttonOffset = IS_MOBILE and 10 or 8
    local closeButtonOffset = IS_MOBILE and 14 or 28
    
    local closeButton = Create("ImageButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, buttonSize, 0, buttonSize),
        Position = UDim2.new(1, -closeButtonOffset, 0.5, -buttonSize/2),
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
        spawn(function()
            wait(0.4)
            screenGui:Destroy()
        end)
    end)
    
    -- Minimize button
    local minimizeButtonOffset = IS_MOBILE and 44 or 52
    local minimizeButton = Create("ImageButton", {
        Name = "MinimizeButton",
        Size = UDim2.new(0, buttonSize, 0, buttonSize),
        Position = UDim2.new(1, -minimizeButtonOffset, 0.5, -buttonSize/2),
        BackgroundTransparency = 1,
        Image = IconSets[ActiveTheme.IconPack].minimize,
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
                Size = UDim2.new(0, windowFrame.Size.X.Offset, 0, titleBarHeight)
            }):Play()
            
            minimizeButton.Image = IconSets[ActiveTheme.IconPack].maximize
        else
            -- Animate restore
            TweenService:Create(windowFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                Size = UDim2.new(0, window._originalSize[1], 0, window._originalSize[2])
            }):Play()
            
            minimizeButton.Image = IconSets[ActiveTheme.IconPack].minimize
        end
    end)
    
    -- Make window draggable (desktop only)
    EnableDragging(windowFrame, titleBar)
    
    -- Container for tab buttons
    local sidebarWidth = IS_MOBILE and 100 or 120
    local tabButtonsContainer = Create("Frame", {
        Name = "TabButtons",
        Size = UDim2.new(0, sidebarWidth, 1, -titleBarHeight),
        Position = UDim2.new(0, 0, 0, titleBarHeight),
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
        ScrollBarThickness = IS_MOBILE and 6 or 4,
        ScrollBarImageColor3 = ActiveTheme.Primary,
        ScrollBarImageTransparency = 0.5,
        VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
        Parent = tabButtonsContainer
    })
    
    local tabButtonsListLayout = Create("UIListLayout", {
        Padding = UDim.new(0, IS_MOBILE and 6 or 4),
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
        Size = UDim2.new(1, -sidebarWidth, 1, -titleBarHeight),
        Position = UDim2.new(0, sidebarWidth, 0, titleBarHeight),
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
    window.TitleBar = titleBar
    window.IsMobile = IS_MOBILE
    
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
        
        -- Create tab button with adjustments for mobile
        local tabButtonHeight = IS_MOBILE and 38 or 32
        local tabButton = Create("Frame", {
            Name = name .. "Button",
            Size = UDim2.new(1, 0, 0, tabButtonHeight),
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
        
        -- Create tab icon or title with mobile adjustments
        if iconId then
            local iconSize = IS_MOBILE and 20 or 18
            local tabIcon = Create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(0, iconSize, 0, iconSize),
                Position = UDim2.new(0, IS_MOBILE and 10 or 12, 0.5, -iconSize/2),
                BackgroundTransparency = 1,
                Image = iconId,
                ImageColor3 = ActiveTheme.TextSecondary,
                Parent = tabButton
            })
            
            -- Create tab name label
            local tabName = Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -44, 1, 0),
                Position = UDim2.new(0, IS_MOBILE and 34 or 36, 0, 0),
                Text = IS_MOBILE and (string.len(name) > 8 and string.sub(name, 1, 6) .. ".." or name) or name, -- Shorten long names on mobile
                TextColor3 = ActiveTheme.TextSecondary,
                TextSize = ScaleToDevice(ActiveTheme.TextSize),
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
                TextSize = ScaleToDevice(ActiveTheme.TextSize),
                Font = ActiveTheme.Font,
                TextXAlignment = Enum.TextXAlignment.Center,
                BackgroundTransparency = 1,
                Parent = tabButton
            })
            
            -- Store references
            tab.Button = tabButton
            tab.Title = tabName
        end
        
        -- Create tab content container with improved scrolling for mobile
        local tabContainer = Create("ScrollingFrame", {
            Name = tabId,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = IS_MOBILE and 6 or 4,
            ScrollBarImageColor3 = ActiveTheme.Primary,
            ScrollBarImageTransparency = 0.5,
            VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
            CanvasSize = UDim2.new(0, 0, 0, 0), -- Will be updated dynamically
            Visible = false,
            Parent = window.TabContentContainer
        })
        
        -- Add padding with adjustments for mobile
        local containerPadding = Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, IS_MOBILE and 12 or 16),
            PaddingRight = UDim.new(0, IS_MOBILE and 12 or 16),
            Parent = tabContainer
        })
        
        -- Add list layout
        local containerLayout = Create("UIListLayout", {
            Padding = UDim.new(0, IS_MOBILE and 10 or 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = tabContainer
        })
        
        -- Create tab title if showTitle is true
        if showTitle then
            local tabTitleLabel = Create("TextLabel", {
                Name = "TabTitle",
                Size = UDim2.new(1, 0, 0, IS_MOBILE and 46 or 40),
                Text = name,
                TextColor3 = ActiveTheme.TextPrimary,
                TextSize = ScaleToDevice(ActiveTheme.HeaderSize),
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
                
                -- Additional feedback on mobile
                if IS_MOBILE then
                    TweenService:Create(tabButton, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.2
                    }):Play()
                    
                    spawn(function()
                        wait(0.2)
                        if window.ActiveTab ~= tabId then
                            TweenService:Create(tabButton, TweenInfo.new(0.2), {
                                BackgroundTransparency = 0.5
                            }):Play()
                        end
                    end)
                end
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
        -- Create Section and other elements implemented here, with mobile adjustments as needed
        -- For brevity, I've left out the duplicated element creation code since it follows the same pattern
        -- Just adjusting sizes and positions for mobile where needed
        
        function tab:CreateSection(name)
            local section = {}
            
            -- Create section container
            local sectionContainer = Create("Frame", {
                Name = "Section_" .. name,
                Size = UDim2.new(1, 0, 0, IS_MOBILE and 42 or 36),
                BackgroundTransparency = 1,
                Parent = tabContainer
            })
            
            -- Create section label
            local sectionLabel = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, IS_MOBILE and 36 or 30),
                Position = UDim2.new(0, 0, 0, 6),
                Text = name,
                TextColor3 = ActiveTheme.Primary,
                TextSize = ScaleToDevice(ActiveTheme.TextSize + (IS_MOBILE and 1 or 0)),
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
            
            -- Create button container with mobile adjustments
            local height = description and (IS_MOBILE and 62 or 54) or (IS_MOBILE and 44 or 36)
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
                Position = UDim2.new(0, 10, 0, IS_MOBILE and 13 or 9),
                Text = name,
                TextColor3 = ActiveTheme.TextPrimary,
                TextSize = ScaleToDevice(ActiveTheme.TextSize),
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
                    Position = UDim2.new(0, 10, 0, IS_MOBILE and 32 or 26),
                    Text = description,
                    TextColor3 = ActiveTheme.TextSecondary,
                    TextSize = ScaleToDevice(ActiveTheme.TextSize - 2),
                    Font = ActiveTheme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Parent = buttonContainer
                })
                
                button.Description = descriptionLabel
            end
            
            -- Make button interactive with better mobile feedback
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
                        Position = UDim2.new(0, 10, 0, IS_MOBILE and 32 or 26),
                        Text = newDescription,
                        TextColor3 = ActiveTheme.TextSecondary,
                        TextSize = ScaleToDevice(ActiveTheme.TextSize - 2),
                        Font = ActiveTheme.Font,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Parent = buttonContainer
                    })
                    
                    button.Description = descriptionLabel
                    buttonContainer.Size = UDim2.new(1, 0, 0, IS_MOBILE and 62 or 54)
                end
            end
            
            -- Track the button
            table.insert(tab.Elements, button)
            
            return button
        end
        
        -- Other element creation methods would follow the same pattern:
        -- 1. Adjust sizes and positions for mobile
        -- 2. Use ScaleToDevice for text sizes
        -- 3. Add enhanced feedback for touch inputs
        
        -- For brevity, I've omitted the remaining element creation methods
        -- The full implementation would include CreateToggle, CreateSlider, etc.
        -- with similar mobile enhancements
        
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
        spawn(function()
            wait(0.4)
            screenGui:Destroy()
        end)
    end
    
    return window
end

-- Notification System Interface
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
    local success, err = pcall(function()
        -- Clean up all UI elements
        for _, instance in pairs(game:GetDescendants()) do
            if instance:IsA("ScreenGui") and 
              (instance.Name == "TBDInterfaceSuite" or 
               instance.Name == "TBDNotifications" or 
               instance.Name == "TBDKeySystem") then
                instance:Destroy()
            end
        end
    end)
    
    if not success then
        warn("TBD UI | Failed to destroy UI elements:", err)
    end
    
    -- Try alternative method if first method fails
    if not success then
        pcall(function()
            -- Clean up using CoreGui
            if CoreGui:FindFirstChild("TBDInterfaceSuite") then
                CoreGui.TBDInterfaceSuite:Destroy()
            end
            
            if CoreGui:FindFirstChild("TBDNotifications") then
                CoreGui.TBDNotifications:Destroy()
            end
            
            if CoreGui:FindFirstChild("TBDKeySystem") then
                CoreGui.TBDKeySystem:Destroy()
            end
        end)
    end
end

-- Initialize
do
    -- Set up notification position based on device
    if IS_MOBILE then
        NotificationSystem.Position = "TopRight"
    end
end

-- Return the library
return TBD
