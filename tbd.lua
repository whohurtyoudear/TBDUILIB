--[[
    VHSynth UI Library
    A comprehensive VHS-style UI library for Roblox with glitch effects, retro aesthetics, and modern functionality
    Version: 1.2.0
    Author: Anonymous
]]

local VHSynth = {}
VHSynth.__index = VHSynth
VHSynth.Version = "1.2.0"

-- Configuration
local config = {
    DefaultTheme = {
        MainBackground = Color3.fromRGB(10, 5, 20),
        SecondaryBackground = Color3.fromRGB(20, 10, 30),
        Accent = Color3.fromRGB(140, 255, 255),
        TextColor = Color3.fromRGB(220, 220, 220),
        TextShadow = Color3.fromRGB(0, 0, 0),
        BorderColor = Color3.fromRGB(80, 60, 120),
        ErrorColor = Color3.fromRGB(255, 80, 100),
        SuccessColor = Color3.fromRGB(80, 255, 140),
        WarningColor = Color3.fromRGB(255, 180, 60),
        Highlight = Color3.fromRGB(180, 120, 255),
        ScrollBarColor = Color3.fromRGB(100, 80, 150),
        DropShadowOpacity = 0.6,
        GlitchIntensity = 0.1,
        ScanlineIntensity = 0.15,
        NoiseIntensity = 0.05,
        VignetteIntensity = 0.3
    },
    AnimationSpeed = 0.2,
    BlurBackground = true,
    EnableGlitchEffects = true,
    EnableVHSEffects = true,
    EnableCRTEffect = true,
    DefaultFont = Enum.Font.Code,
    TextSize = 14,
    BorderSizePixel = 1,
    CornerRadius = UDim.new(0, 6),
    ElementPadding = 5,
    WindowMinSize = Vector2.new(300, 200),
    WindowMaxSize = Vector2.new(800, 600),
    TooltipDelay = 0.5,
    MaxTooltipWidth = 300
}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Utility functions
local function Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

local function DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            v = DeepCopy(v)
        end
        copy[k] = v
    end
    return copy
end

local function Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function MapValue(value, inMin, inMax, outMin, outMax)
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

local function CreateGradient(color1, color2, rotation)
    local gradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color1),
            ColorSequenceKeypoint.new(1, color2)
        }),
        Rotation = rotation or 90
    })
    return gradient
end

local function AddGlitchEffect(frame, intensity)
    if not config.EnableGlitchEffects then return end
    
    intensity = intensity or config.DefaultTheme.GlitchIntensity
    
    local glitch = Create("Frame", {
        Name = "GlitchEffect",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ClipsDescendants = true,
        ZIndex = frame.ZIndex + 1,
        Parent = frame
    })
    
    local clones = {}
    for i = 1, 3 do
        local clone = frame:Clone()
        clone.Name = "GlitchClone"..i
        clone.Position = UDim2.new(0, 0, 0, 0)
        clone.AnchorPoint = Vector2.new(0, 0)
        clone.BackgroundTransparency = 0.7
        clone.ZIndex = glitch.ZIndex + i
        clone.Parent = glitch
        
        if i == 1 then
            clone.BackgroundColor3 = Color3.new(1, 0, 0)
        elseif i == 2 then
            clone.BackgroundColor3 = Color3.new(0, 1, 0)
        else
            clone.BackgroundColor3 = Color3.new(0, 0, 1)
        end
        
        table.insert(clones, clone)
    end
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not glitch or not glitch.Parent then
            connection:Disconnect()
            return
        end
        
        for i, clone in ipairs(clones) do
            local offsetX = math.random(-5, 5) * intensity
            local offsetY = math.random(-2, 2) * intensity
            clone.Position = UDim2.new(0, offsetX, 0, offsetY)
            clone.Visible = math.random() < (0.2 * intensity)
        end
    end)
    
    return glitch
end

local function AddScanlines(frame, intensity)
    if not config.EnableVHSEffects then return end
    
    intensity = intensity or config.DefaultTheme.ScanlineIntensity
    
    local scanlineContainer = Create("Frame", {
        Name = "Scanlines",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ClipsDescendants = true,
        ZIndex = frame.ZIndex + 1,
        Parent = frame
    })
    
    local lineCount = math.floor(frame.AbsoluteSize.Y / 3)
    for i = 1, lineCount do
        local line = Create("Frame", {
            Name = "Scanline",
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.7 * intensity,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0, (i-1)*3),
            ZIndex = scanlineContainer.ZIndex + 1,
            Parent = scanlineContainer
        })
    end
    
    return scanlineContainer
end

local function AddNoise(frame, intensity)
    if not config.EnableVHSEffects then return end
    
    intensity = intensity or config.DefaultTheme.NoiseIntensity
    
    local noise = Create("ImageLabel", {
        Name = "Noise",
        Image = "rbxassetid://8349656584", -- Default noise texture
        ImageTransparency = 0.7 * (1 - intensity),
        ScaleType = Enum.ScaleType.Tile,
        TileSize = UDim2.new(0, 64, 0, 64),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = frame.ZIndex + 1,
        Parent = frame
    })
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not noise or not noise.Parent then
            connection:Disconnect()
            return
        end
        
        noise.Position = UDim2.new(
            0, math.random(-10, 10) * intensity,
            0, math.random(-10, 10) * intensity
        )
    end)
    
    return noise
end

local function AddVignette(frame, intensity)
    if not config.EnableVHSEffects then return end
    
    intensity = intensity or config.DefaultTheme.VignetteIntensity
    
    local vignette = Create("ImageLabel", {
        Name = "Vignette",
        Image = "rbxassetid://8349657002", -- Default vignette texture
        ImageTransparency = 0.7 * (1 - intensity),
        ScaleType = Enum.ScaleType.Fit,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = frame.ZIndex + 1,
        Parent = frame
    })
    
    return vignette
end

local function AddCRTEffect(frame)
    if not config.EnableCRTEffect then return end
    
    local crt = Create("Frame", {
        Name = "CRTEffect",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ClipsDescendants = true,
        ZIndex = frame.ZIndex + 1,
        Parent = frame
    })
    
    local grid = Create("Frame", {
        Name = "CRTGrid",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = crt.ZIndex + 1,
        Parent = crt
    })
    
    -- Horizontal lines
    local lineCount = math.floor(frame.AbsoluteSize.Y / 2)
    for i = 1, lineCount do
        local line = Create("Frame", {
            Name = "CRTLine",
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.95,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0, (i-1)*2),
            ZIndex = grid.ZIndex + 1,
            Parent = grid
        })
    end
    
    -- Curvature effect
    local curvature = Create("UIGradient", {
        Name = "CRTCurvature",
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.3, 0.1),
            NumberSequenceKeypoint.new(0.5, 0.15),
            NumberSequenceKeypoint.new(0.7, 0.1),
            NumberSequenceKeypoint.new(1, 0)
        }),
        Rotation = 0,
        Parent = crt
    })
    
    return crt
end

local function ApplyVHSEffects(frame)
    AddGlitchEffect(frame)
    AddScanlines(frame)
    AddNoise(frame)
    AddVignette(frame)
    AddCRTEffect(frame)
end

local function CreateTooltip(text, parent)
    local tooltip = Create("Frame", {
        Name = "Tooltip",
        BackgroundColor3 = Color3.fromRGB(20, 10, 30),
        BackgroundTransparency = 0.1,
        BorderColor3 = config.DefaultTheme.BorderColor,
        BorderSizePixel = config.BorderSizePixel,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ZIndex = 1000,
        Parent = parent
    })
    
    local uiCorner = Create("UICorner", {
        CornerRadius = config.CornerRadius,
        Parent = tooltip
    })
    
    local textLabel = Create("TextLabel", {
        Name = "Text",
        BackgroundTransparency = 1,
        Font = config.DefaultFont,
        Text = text,
        TextColor3 = config.DefaultTheme.TextColor,
        TextSize = config.TextSize,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        ZIndex = tooltip.ZIndex + 1,
        Parent = tooltip
    })
    
    local textSize = TextService:GetTextSize(text, config.TextSize, config.DefaultFont, Vector2.new(config.MaxTooltipWidth, math.huge))
    
    tooltip.Size = UDim2.new(0, textSize.X + 10, 0, textSize.Y + 10)
    
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = config.DefaultTheme.DropShadowOpacity,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0, -5, 0, -5),
        ZIndex = tooltip.ZIndex - 1,
        Parent = tooltip
    })
    
    ApplyVHSEffects(tooltip)
    
    return tooltip
end

-- Main UI components
function VHSynth.CreateWindow(options)
    options = options or {}
    local title = options.Title or "VHSynth UI"
    local size = options.Size or Vector2.new(500, 400)
    local position = options.Position or nil
    local theme = options.Theme or DeepCopy(config.DefaultTheme)
    local closable = options.Closable ~= false
    local minimizable = options.Minimizable ~= false
    local savedPosition = options.SavedPosition or nil
    
    -- Clamp size to min/max
    size = Vector2.new(
        math.clamp(size.X, config.WindowMinSize.X, config.WindowMaxSize.X),
        math.clamp(size.Y, config.WindowMinSize.Y, config.WindowMaxSize.Y)
    )
    
    -- Create main window container
    local window = Create("ScreenGui", {
        Name = "VHSynthWindow_"..HttpService:GenerateGUID(false),
        DisplayOrder = 10,
        ResetOnSpawn = false,
        Parent = CoreGui
    })
    
    -- Background blur
    if config.BlurBackground then
        local blur = Create("BlurEffect", {
            Name = "BackgroundBlur",
            Size = 10,
            Parent = window
        })
    end
    
    -- Main window frame
    local mainFrame = Create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = theme.MainBackground,
        BorderColor3 = theme.BorderColor,
        BorderSizePixel = config.BorderSizePixel,
        Position = position or UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2),
        Size = UDim2.new(0, size.X, 0, size.Y),
        Parent = window
    })
    
    -- Apply saved position if available
    if savedPosition then
        mainFrame.Position = savedPosition
    end
    
    -- Corners
    local uiCorner = Create("UICorner", {
        CornerRadius = config.CornerRadius,
        Parent = mainFrame
    })
    
    -- Drop shadow
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = theme.DropShadowOpacity,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0, -5, 0, -5),
        ZIndex = -1,
        Parent = mainFrame
    })
    
    -- Title bar
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = theme.SecondaryBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = mainFrame
    })
    
    local titleBarCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = titleBar
    })
    
    -- Title text
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Font = config.DefaultFont,
        Text = title,
        TextColor3 = theme.TextColor,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Parent = titleBar
    })
    
    -- Title bar gradient
    local titleGradient = CreateGradient(
        theme.SecondaryBackground,
        Color3.new(
            theme.SecondaryBackground.R * 0.8,
            theme.SecondaryBackground.G * 0.8,
            theme.SecondaryBackground.B * 0.8
        ),
        90
    )
    titleGradient.Parent = titleBar
    
    -- Close button
    local closeButton
    if closable then
        closeButton = Create("TextButton", {
            Name = "CloseButton",
            BackgroundColor3 = Color3.fromRGB(255, 80, 80),
            BorderSizePixel = 0,
            Font = Enum.Font.SourceSans,
            Text = "X",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 14,
            Size = UDim2.new(0, 30, 0, 20),
            Position = UDim2.new(1, -35, 0, 5),
            Parent = titleBar
        })
        
        local closeCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = closeButton
        })
        
        closeButton.MouseEnter:Connect(function()
            closeButton.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
        end)
        
        closeButton.MouseLeave:Connect(function()
            closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        end)
        
        closeButton.MouseButton1Click:Connect(function()
            window:Destroy()
        end)
    end
    
    -- Minimize button
    local minimizeButton
    if minimizable then
        minimizeButton = Create("TextButton", {
            Name = "MinimizeButton",
            BackgroundColor3 = Color3.fromRGB(80, 80, 80),
            BorderSizePixel = 0,
            Font = Enum.Font.SourceSans,
            Text = "_",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 14,
            Size = UDim2.new(0, 30, 0, 20),
            Position = UDim2.new(1, -70, 0, 5),
            Parent = titleBar
        })
        
        local minimizeCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = minimizeButton
        })
        
        minimizeButton.MouseEnter:Connect(function()
            minimizeButton.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        end)
        
        minimizeButton.MouseLeave:Connect(function()
            minimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end)
        
        minimizeButton.MouseButton1Click:Connect(function()
            mainFrame.Visible = not mainFrame.Visible
        end)
    end
    
    -- Content frame
    local contentFrame = Create("Frame", {
        Name = "ContentFrame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -35),
        Position = UDim2.new(0, 0, 0, 35),
        Parent = mainFrame
    })
    
    -- Tab container
    local tabContainer = Create("Frame", {
        Name = "TabContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = contentFrame
    })
    
    -- Tab list UIListLayout
    local tabListLayout = Create("UIListLayout", {
        Name = "TabListLayout",
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = tabContainer
    })
    
    -- Tab content container
    local tabContentContainer = Create("Frame", {
        Name = "TabContentContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -35),
        Position = UDim2.new(0, 0, 0, 35),
        Parent = contentFrame
    })
    
    -- Apply VHS effects
    ApplyVHSEffects(mainFrame)
    
    -- Dragging functionality
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        
        -- Keep window within screen bounds
        local absPos = newPos
        local absSize = mainFrame.AbsoluteSize
        
        if absPos.X.Offset < 0 then
            newPos = UDim2.new(absPos.X.Scale, 0, absPos.Y.Scale, absPos.Y.Offset)
        elseif absPos.X.Offset + absSize.X > workspace.CurrentCamera.ViewportSize.X then
            newPos = UDim2.new(absPos.X.Scale, workspace.CurrentCamera.ViewportSize.X - absSize.X, absPos.Y.Scale, absPos.Y.Offset)
        end
        
        if absPos.Y.Offset < 0 then
            newPos = UDim2.new(absPos.X.Scale, absPos.X.Offset, absPos.Y.Scale, 0)
        elseif absPos.Y.Offset + absSize.Y > workspace.CurrentCamera.ViewportSize.Y then
            newPos = UDim2.new(absPos.X.Scale, absPos.X.Offset, absPos.Y.Scale, workspace.CurrentCamera.ViewportSize.Y - absSize.Y)
        end
        
        mainFrame.Position = newPos
    end
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    -- Resize functionality
    local resizeButton = Create("TextButton", {
        Name = "ResizeButton",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 15, 0, 15),
        Position = UDim2.new(1, -15, 1, -15),
        Text = "",
        Parent = mainFrame
    })
    
    local resizeIcon = Create("ImageLabel", {
        Name = "ResizeIcon",
        Image = "rbxassetid://8349657234", -- Diagonal resize icon
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = resizeButton
    })
    
    local resizing
    local resizeStart
    local startSize
    
    resizeButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            startSize = mainFrame.Size
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            local newSize = UDim2.new(
                startSize.X.Scale, 
                math.clamp(startSize.X.Offset + delta.X, config.WindowMinSize.X, config.WindowMaxSize.X),
                startSize.Y.Scale, 
                math.clamp(startSize.Y.Offset + delta.Y, config.WindowMinSize.Y, config.WindowMaxSize.Y)
            )
            
            mainFrame.Size = newSize
        end
    end)
    
    -- Window methods
    local windowMethods = {}
    
    function windowMethods:SetTitle(newTitle)
        titleLabel.Text = newTitle
    end
    
    function windowMethods:GetTitle()
        return titleLabel.Text
    end
    
    function windowMethods:SetTheme(newTheme)
        theme = newTheme or DeepCopy(config.DefaultTheme)
        
        -- Update all colors
        mainFrame.BackgroundColor3 = theme.MainBackground
        mainFrame.BorderColor3 = theme.BorderColor
        titleBar.BackgroundColor3 = theme.SecondaryBackground
        titleLabel.TextColor3 = theme.TextColor
        shadow.ImageTransparency = theme.DropShadowOpacity
        
        -- Update gradient
        titleGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.SecondaryBackground),
            ColorSequenceKeypoint.new(1, Color3.new(
                theme.SecondaryBackground.R * 0.8,
                theme.SecondaryBackground.G * 0.8,
                theme.SecondaryBackground.B * 0.8
            ))
        })
    end
    
    function windowMethods:GetTheme()
        return DeepCopy(theme)
    end
    
    function windowMethods:AddTab(tabName)
        local tabButton = Create("TextButton", {
            Name = tabName.."TabButton",
            BackgroundColor3 = theme.SecondaryBackground,
            BorderSizePixel = 0,
            Font = config.DefaultFont,
            Text = tabName,
            TextColor3 = theme.TextColor,
            TextSize = config.TextSize,
            Size = UDim2.new(0, 80, 1, 0),
            Parent = tabContainer
        })
        
        local tabButtonCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = tabButton
        })
        
        local tabContent = Create("ScrollingFrame", {
            Name = tabName.."TabContent",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 6,
            ScrollBarImageColor3 = theme.ScrollBarColor,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            Parent = tabContentContainer
        })
        
        local tabContentLayout = Create("UIListLayout", {
            Name = "TabContentLayout",
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, config.ElementPadding),
            Parent = tabContent
        })
        
        tabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, tabContentLayout.AbsoluteContentSize.Y + 10)
        end)
        
        -- First tab is visible by default
        if #tabContainer:GetChildren() == 2 then -- 1 for UIListLayout, 1 for this tab
            tabButton.BackgroundColor3 = theme.Accent
            tabContent.Visible = true
        end
        
        tabButton.MouseButton1Click:Connect(function()
            -- Hide all tab contents
            for _, child in ipairs(tabContentContainer:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            
            -- Reset all tab button colors
            for _, child in ipairs(tabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = theme.SecondaryBackground
                end
            end
            
            -- Show this tab content and highlight button
            tabContent.Visible = true
            tabButton.BackgroundColor3 = theme.Accent
        end)
        
        -- Tab methods
        local tabMethods = {}
        
        function tabMethods:AddSection(sectionName)
            local sectionFrame = Create("Frame", {
                Name = sectionName.."Section",
                BackgroundColor3 = theme.SecondaryBackground,
                BorderColor3 = theme.BorderColor,
                BorderSizePixel = config.BorderSizePixel,
                Size = UDim2.new(1, -10, 0, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Parent = tabContent
            })
            
            local sectionCorner = Create("UICorner", {
                CornerRadius = config.CornerRadius,
                Parent = sectionFrame
            })
            
            local sectionTitle = Create("TextLabel", {
                Name = "SectionTitle",
                BackgroundTransparency = 1,
                Font = config.DefaultFont,
                Text = sectionName,
                TextColor3 = theme.TextColor,
                TextSize = config.TextSize + 2,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, -10, 0, 25),
                Position = UDim2.new(0, 10, 0, 5),
                Parent = sectionFrame
            })
            
            local sectionContent = Create("Frame", {
                Name = "SectionContent",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 1, -35),
                Position = UDim2.new(0, 5, 0, 30),
                Parent = sectionFrame
            })
            
            local sectionContentLayout = Create("UIListLayout", {
                Name = "SectionContentLayout",
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, config.ElementPadding),
                Parent = sectionContent
            })
            
            sectionContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectionFrame.Size = UDim2.new(1, -10, 0, sectionContentLayout.AbsoluteContentSize.Y + 40)
            end)
            
            -- Section methods
            local sectionMethods = {}
            
            function sectionMethods:AddLabel(labelText, options)
                options = options or {}
                local textSize = options.TextSize or config.TextSize
                local textColor = options.TextColor or theme.TextColor
                local textAlign = options.TextAlignment or Enum.TextXAlignment.Left
                
                local labelFrame = Create("Frame", {
                    Name = "LabelFrame",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, textSize + 10),
                    Parent = sectionContent
                })
                
                local label = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Font = config.DefaultFont,
                    Text = labelText,
                    TextColor3 = textColor,
                    TextSize = textSize,
                    TextXAlignment = textAlign,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = labelFrame
                })
                
                if options.Tooltip then
                    local tooltip = CreateTooltip(options.Tooltip, labelFrame)
                    
                    labelFrame.MouseEnter:Connect(function()
                        tooltip.Visible = true
                        tooltip.Position = UDim2.new(0, labelFrame.AbsolutePosition.X - sectionContent.AbsolutePosition.X, 
                                                    0, labelFrame.AbsolutePosition.Y - sectionContent.AbsolutePosition.Y + labelFrame.AbsoluteSize.Y)
                    end)
                    
                    labelFrame.MouseLeave:Connect(function()
                        tooltip.Visible = false
                    end)
                end
                
                -- Label methods
                local labelMethods = {}
                
                function labelMethods:SetText(newText)
                    label.Text = newText
                end
                
                function labelMethods:GetText()
                    return label.Text
                end
                
                function labelMethods:SetColor(newColor)
                    label.TextColor3 = newColor
                end
                
                function labelMethods:GetColor()
                    return label.TextColor3
                end
                
                return labelMethods
            end
            
            function sectionMethods:AddButton(buttonText, callback, options)
                options = options or {}
                local buttonHeight = options.Height or 30
                local buttonColor = options.Color or theme.Accent
                local tooltipText = options.Tooltip or nil
                
                local buttonFrame = Create("Frame", {
                    Name = "ButtonFrame",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, buttonHeight + 10),
                    Parent = sectionContent
                })
                
                local button = Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = buttonColor,
                    BorderColor3 = theme.BorderColor,
                    BorderSizePixel = config.BorderSizePixel,
                    Font = config.DefaultFont,
                    Text = buttonText,
                    TextColor3 = theme.TextColor,
                    TextSize = config.TextSize,
                    Size = UDim2.new(1, 0, 0, buttonHeight),
                    Parent = buttonFrame
                })
                
                local buttonCorner = Create("UICorner", {
                    CornerRadius = config.CornerRadius,
                    Parent = button
                })
                
                local buttonShadow = Create("ImageLabel", {
                    Name = "ButtonShadow",
                    Image = "rbxassetid://1316045217",
                    ImageColor3 = Color3.new(0, 0, 0),
                    ImageTransparency = theme.DropShadowOpacity,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(10, 10, 118, 118),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 10, 1, 10),
                    Position = UDim2.new(0, -5, 0, -5),
                    ZIndex = -1,
                    Parent = button
                })
                
                if tooltipText then
                    local tooltip = CreateTooltip(tooltipText, buttonFrame)
                    
                    buttonFrame.MouseEnter:Connect(function()
                        tooltip.Visible = true
                        tooltip.Position = UDim2.new(0, buttonFrame.AbsolutePosition.X - sectionContent.AbsolutePosition.X, 
                                                    0, buttonFrame.AbsolutePosition.Y - sectionContent.AbsolutePosition.Y + buttonFrame.AbsoluteSize.Y)
                    end)
                    
                    buttonFrame.MouseLeave:Connect(function()
                        tooltip.Visible = false
                    end)
                end
                
                -- Button effects
                local originalSize = button.Size
                local originalPos = button.Position
                
                button.MouseEnter:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.new(
                            buttonColor.R * 1.2,
                            buttonColor.G * 1.2,
                            buttonColor.B * 1.2
                        ),
                        Size = originalSize + UDim2.new(0, 5, 0, 5),
                        Position = originalPos - UDim2.new(0, 2.5, 0, 2.5)
                    }):Play()
                end)
                
                button.MouseLeave:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.1), {
                        BackgroundColor3 = buttonColor,
                        Size = originalSize,
                        Position = originalPos
                    }):Play()
                end)
                
                button.MouseButton1Click:Connect(function()
                    if callback then
                        callback()
                    end
                end)
                
                -- Button methods
                local buttonMethods = {}
                
                function buttonMethods:SetText(newText)
                    button.Text = newText
                end
                
                function buttonMethods:GetText()
                    return button.Text
                end
                
                function buttonMethods:SetCallback(newCallback)
                    callback = newCallback
                end
                
                function buttonMethods:SetColor(newColor)
                    buttonColor = newColor
                    button.BackgroundColor3 = newColor
                end
                
                function buttonMethods:GetColor()
                    return buttonColor
                end
                
                return buttonMethods
            end
            
            function sectionMethods:AddToggle(toggleText, defaultState, callback, options)
                options = options or {}
                local toggleHeight = options.Height or 25
                local tooltipText = options.Tooltip or nil
                
                local toggleFrame = Create("Frame", {
                    Name = "ToggleFrame",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, toggleHeight + 10),
                    Parent = sectionContent
                })
                
                local toggleLabel = Create("TextLabel", {
                    Name = "ToggleLabel",
                    BackgroundTransparency = 1,
                    Font = config.DefaultFont,
                    Text = toggleText,
                    TextColor3 = theme.TextColor,
                    TextSize = config.TextSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(0.7, -5, 1, 0),
                    Parent = toggleFrame
                })
                
                local toggleButton = Create("TextButton", {
                    Name = "ToggleButton",
                    BackgroundColor3 = theme.SecondaryBackground,
                    BorderColor3 = theme.BorderColor,
                    BorderSizePixel = config.BorderSizePixel,
                    Font = Enum.Font.SourceSans,
                    Text = "",
                    Size = UDim2.new(0.3, 0, 0, toggleHeight),
                    Position = UDim2.new(0.7, 5, 0, 0),
                    Parent = toggleFrame
                })
                
                local toggleButtonCorner = Create("UICorner", {
                    CornerRadius = config.CornerRadius,
                    Parent = toggleButton
                })
                
                local toggleIndicator = Create("Frame", {
                    Name = "ToggleIndicator",
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0.5, 0, 1, -4),
                    Position = UDim2.new(0, 2, 0, 2),
                    Parent = toggleButton
                })
                
                local toggleIndicatorCorner = Create("UICorner", {
                    CornerRadius = config.CornerRadius,
                    Parent = toggleIndicator
                })
                
                local state = defaultState or false
                
                local function updateToggle()
                    if state then
                        TweenService:Create(toggleIndicator, TweenInfo.new(0.1), {
                            Position = UDim2.new(0.5, -2, 0, 2),
                            BackgroundColor3 = theme.Accent
                        }:Play()
                    else
                        TweenService:Create(toggleIndicator, TweenInfo.new(0.1), {
                            Position = UDim2.new(0, 2, 0, 2),
                            BackgroundColor3 = Color3.fromRGB(150, 150, 150)
                        }:Play()
                    end
                end
                
                updateToggle()
                
                if tooltipText then
                    local tooltip = CreateTooltip(tooltipText, toggleFrame)
                    
                    toggleFrame.MouseEnter:Connect(function()
                        tooltip.Visible = true
                        tooltip.Position = UDim2.new(0, toggleFrame.AbsolutePosition.X - sectionContent.AbsolutePosition.X, 
                                                    0, toggleFrame.AbsolutePosition.Y - sectionContent.AbsolutePosition.Y + toggleFrame.AbsoluteSize.Y)
                    end)
                    
                    toggleFrame.MouseLeave:Connect(function()
                        tooltip.Visible = false
                    end)
                end
                
                toggleButton.MouseButton1Click:Connect(function()
                    state = not state
                    updateToggle()
                    if callback then
                        callback(state)
                    end
                end)
                
                -- Toggle methods
                local toggleMethods = {}
                
                function toggleMethods:SetState(newState)
                    state = newState
                    updateToggle()
                end
                
                function toggleMethods:GetState()
                    return state
                end
                
                function toggleMethods:Toggle()
                    state = not state
                    updateToggle()
                    if callback then
                        callback(state)
                    end
                end
                
                function toggleMethods:SetCallback(newCallback)
                    callback = newCallback
                end
                
                return toggleMethods
            end
            
            function sectionMethods:AddSlider(sliderText, minValue, maxValue, defaultValue, callback, options)
                options = options or {}
                local sliderHeight = options.Height or 25
                local decimalPlaces = options.DecimalPlaces or 0
                local tooltipText = options.Tooltip or nil
                local showValue = options.ShowValue ~= false
                
                local sliderFrame = Create("Frame", {
                    Name = "SliderFrame",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, sliderHeight + 15),
                    Parent = sectionContent
                })
                
                local sliderLabel = Create("TextLabel", {
                    Name = "SliderLabel",
                    BackgroundTransparency = 1,
                    Font = config.DefaultFont,
                    Text = sliderText,
                    TextColor3 = theme.TextColor,
                    TextSize = config.TextSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, 0, 0, 20),
                    Parent = sliderFrame
                })
                
                local sliderContainer = Create("Frame", {
                    Name = "SliderContainer",
                    BackgroundColor3 = theme.SecondaryBackground,
                    BorderColor3 = theme.BorderColor,
                    BorderSizePixel = config.BorderSizePixel,
                    Size = UDim2.new(1, 0, 0, sliderHeight),
                    Position = UDim2.new(0, 0, 0, 20),
                    Parent = sliderFrame
                })
                
                local sliderContainerCorner = Create("UICorner", {
                    CornerRadius = config.CornerRadius,
                    Parent = sliderContainer
                })
                
                local sliderFill = Create("Frame", {
                    Name = "SliderFill",
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 0, 1, 0),
                    Parent = sliderContainer
                })
                
                local sliderFillCorner = Create("UICorner", {
                    CornerRadius = config.CornerRadius,
                    Parent = sliderFill
                })
                
                local sliderHandle = Create("Frame", {
                    Name = "SliderHandle",
                    BackgroundColor3 = theme.Highlight,
                    BorderColor3 = theme.BorderColor,
                    BorderSizePixel = config.BorderSizePixel,
                    Size = UDim2.new(0, 10, 1, 4),
                    Position = UDim2.new(0, 0, 0, -2),
                    ZIndex = 2,
                    Parent = sliderContainer
                })
                
                local sliderHandleCorner = Create("UICorner", {
                    CornerRadius = config.CornerRadius,
                    Parent = sliderHandle
                })
                
                local valueLabel
                if showValue then
                    valueLabel = Create("TextLabel", {
                        Name = "ValueLabel",
                        BackgroundTransparency = 1,
                        Font = config.DefaultFont,
                        Text = tostring(defaultValue or minValue),
                        TextColor3 = theme.TextColor,
                        TextSize = config.TextSize - 2,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Size = UDim2.new(0.3, 0, 0, 20),
                        Position = UDim2.new(0.7, 0, 0, 0),
                        Parent = sliderFrame
                    })
                end
                
                if tooltipText then
                    local tooltip = CreateTooltip(tooltipText, sliderFrame)
                    
                    sliderFrame.MouseEnter:Connect(function()
                        tooltip.Visible = true
                        tooltip.Position = UDim2.new(0, sliderFrame.AbsolutePosition.X - sectionContent.AbsolutePosition.X, 
                                                    0, sliderFrame.AbsolutePosition.Y - sectionContent.AbsolutePosition.Y + sliderFrame.AbsoluteSize.Y)
                    end)
                    
                    sliderFrame.MouseLeave:Connect(function()
                        tooltip.Visible = false
                    end)
                end
                
                local dragging = false
                local currentValue = defaultValue or minValue
                
                local function updateSlider(value)
                    value = math.clamp(value, minValue, maxValue)
                    currentValue = decimalPlaces > 0 and Round(value, decimalPlaces) or math.floor(value)
                    
                    local ratio = (currentValue - minValue) / (maxValue - minValue)
                    sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
                    sliderHandle.Position = UDim2.new(ratio, -5, 0, -2)
                    
                    if valueLabel then
                        valueLabel.Text = tostring(currentValue)
                    end
                    
                    if callback then
                        callback(currentValue)
                    end
                end
                
                updateSlider(currentValue)
                
                sliderContainer.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        local xPos = input.Position.X - sliderContainer.AbsolutePosition.X
                        local value = MapValue(xPos, 0, sliderContainer.AbsoluteSize.X, minValue, maxValue)
                        updateSlider(value)
                    end
                end)
                
                sliderContainer.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local xPos = input.Position.X - sliderContainer.AbsolutePosition.X
                        local value = MapValue(xPos, 0, sliderContainer.AbsoluteSize.X, minValue, maxValue)
                        updateSlider(value)
                    end
                end)
                
                -- Slider methods
                local sliderMethods = {}
                
                function sliderMethods:SetValue(value)
                    updateSlider(value)
                end
                
                function sliderMethods:GetValue()
                    return currentValue
                end
                
                function sliderMethods:SetRange(newMin, newMax)
                    minValue = newMin
                    maxValue = newMax
                    updateSlider(currentValue)
                end
                
                function sliderMethods:SetCallback(newCallback)
                    callback = newCallback
                end
                
                return sliderMethods
            end
            
            function sectionMethods:AddDropdown(dropdownText, optionsList, defaultOption, callback, options)
                options = options or {}
                local dropdownHeight = options.Height or 25
                local tooltipText = options.Tooltip or nil
                local multiSelect = options.MultiSelect or false
                
                local dropdownFrame = Create("Frame", {
                    Name = "DropdownFrame",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, dropdownHeight + 10),
                    Parent = sectionContent
                })
                
                local dropdownLabel = Create("TextLabel", {
                    Name = "DropdownLabel",
                    BackgroundTransparency = 1,
                    Font = config.DefaultFont,
                    Text = dropdownText,
                    TextColor3 = theme.TextColor,
                    TextSize = config.TextSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(0.7, -5, 0, 20),
                    Parent = dropdownFrame
                })
                
                local dropdownButton = Create("TextButton", {
                    Name = "DropdownButton",
                    BackgroundColor3 = theme.SecondaryBackground,
                    BorderColor3 = theme.BorderColor,
                    BorderSizePixel = config.BorderSizePixel,
                    Font = config.DefaultFont,
                    Text = defaultOption or "Select...",
                    TextColor3 = theme.TextColor,
                    TextSize = config.TextSize,
                    Size = UDim2.new(0.3, 0, 0, dropdownHeight),
                    Position = UDim2.new(0.7, 5, 0, 0),
                    Parent = dropdownFrame
                })
                
                local dropdownButtonCorner = Create("UICorner", {
                    CornerRadius = config.CornerRadius,
                    Parent = dropdownButton
                })
                
                local dropdownArrow = Create("ImageLabel", {
                    Name = "DropdownArrow",
                    Image = "rbxassetid://8349657123", -- Down arrow icon
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(1, -20, 0.5, -8),
                    Parent = dropdownButton
                })
                
                local dropdownList = Create("ScrollingFrame", {
                    Name = "DropdownList",
                    BackgroundColor3 = theme.SecondaryBackground,
                    BorderColor3 = theme.BorderColor,
                    BorderSizePixel = config.BorderSizePixel,
                    ScrollBarThickness = 6,
                    ScrollBarImageColor3 = theme.ScrollBarColor,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(0.3, 0, 0, 0),
                    Position = UDim2.new(0.7, 5, 0, dropdownHeight + 5),
                    Visible = false,
                    ZIndex = 10,
                    Parent = dropdownFrame
                })
                
                local dropdownListLayout = Create("UIListLayout", {
                    Name = "DropdownListLayout",
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2),
                    Parent = dropdownList
                })
                
                dropdownListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    dropdownList.CanvasSize = UDim2.new(0, 0, 0, dropdownListLayout.AbsoluteContentSize.Y)
                    dropdownList.Size = UDim2.new(0.3, 0, 0, math.min(dropdownListLayout.AbsoluteContentSize.Y, 150))
                end)
                
                if tooltipText then
                    local tooltip = CreateTooltip(tooltipText, dropdownFrame)
                    
                    dropdownFrame.MouseEnter:Connect(function()
                        tooltip.Visible = true
                        tooltip.Position = UDim2.new(0, dropdownFrame.AbsolutePosition.X - sectionContent.AbsolutePosition.X, 
                                                    0, dropdownFrame.AbsolutePosition.Y - sectionContent.AbsolutePosition.Y + dropdownFrame.AbsoluteSize.Y)
                    end)
                    
                    dropdownFrame.MouseLeave:Connect(function()
                        tooltip.Visible = false
                    end)
                end
                
                local selectedOptions = {}
                if defaultOption and not multiSelect then
                    table.insert(selectedOptions, defaultOption)
                end
                
                local function updateDropdown()
                    if multiSelect then
                        if #selectedOptions > 0 then
                            local text = ""
                            for i, option in ipairs(selectedOptions) do
                                text = text .. option
                                if i < #selectedOptions then
                                    text = text .. ", "
                                end
                            end
                            dropdownButton.Text = text
                        else
                            dropdownButton.Text = "Select..."
                        end
                    else
                        dropdownButton.Text = selectedOptions[1] or "Select..."
                    end
                end
                
                local function createOption(optionText)
                    local optionButton = Create("TextButton", {
                        Name = optionText.."Option",
                        BackgroundColor3 = theme.SecondaryBackground,
                        BorderSizePixel = 0,
                        Font = config.DefaultFont,
                        Text = optionText,
                        TextColor3 = theme.TextColor,
                        TextSize = config.TextSize,
                        Size = UDim2.new(1, 0, 0, dropdownHeight),
                        Parent = dropdownList
                    })
                    
                    optionButton.MouseEnter:Connect(function()
                        optionButton.BackgroundColor3 = Color3.new(
                            theme.SecondaryBackground.R * 1.2,
                            theme.SecondaryBackground.G * 1.2,
                            theme.SecondaryBackground.B * 1.2
                        )
                    end)
                    
                    optionButton.MouseLeave:Connect(function()
                        if not table.find(selectedOptions, optionText) then
                            optionButton.BackgroundColor3 = theme.SecondaryBackground
                        else
                            optionButton.BackgroundColor3 = theme.Accent
                        end
                    end)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        if multiSelect then
                            if table.find(selectedOptions, optionText) then
                                table.remove(selectedOptions, table.find(selectedOptions, optionText))
                                optionButton.BackgroundColor3 = theme.SecondaryBackground
                            else
                                table.insert(selectedOptions, optionText)
                                optionButton.BackgroundColor3 = theme.Accent
                            end
                        else
                            selectedOptions = {optionText}
                            dropdownList.Visible = false
                            TweenService:Create(dropdownArrow, TweenInfo.new(0.1), {
                                Rotation = 0
                            }:Play()
                            
                            for _, child in ipairs(dropdownList:GetChildren()) do
                                if child:IsA("TextButton") then
                                    child.BackgroundColor3 = theme.SecondaryBackground
                                end
                            end
                            
                            optionButton.BackgroundColor3 = theme.Accent
                        end
                        
                        updateDropdown()
                        if callback then
                            if multiSelect then
                                callback(selectedOptions)
                            else
                                callback(optionText)
                            end
                        end
                    end)
                    
                    if table.find(selectedOptions, optionText) then
                        optionButton.BackgroundColor3 = theme.Accent
                    end
                end
                
                for _, option in ipairs(optionsList) do
                    createOption(option)
                end
                
                dropdownButton.MouseButton1Click:Connect(function()
                    dropdownList.Visible = not dropdownList.Visible
                    if dropdownList.Visible then
                        TweenService:Create(dropdownArrow, TweenInfo.new(0.1), {
                            Rotation = 180
                        }):Play()
                    else
                        TweenService:Create(dropdownArrow, TweenInfo.new(0.1), {
                            Rotation = 0
                        }):Play()
                    end
                end)
                
                -- Close dropdown when clicking outside
                local dropdownConnection
                dropdownConnection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if dropdownList.Visible and not dropdownButton:IsDescendantOf(input:GetMouseTarget()) and not dropdownList:IsDescendantOf(input:GetMouseTarget()) then
                            dropdownList.Visible = false
                            TweenService:Create(dropdownArrow, TweenInfo.new(0.1), {
                                Rotation = 0
                            }:Play()
                        end
                    end
                end)
                
                dropdownList.AncestryChanged:Connect(function()
                    if not dropdownList.Parent then
                        dropdownConnection:Disconnect()
                    end
                end)
                
                -- Dropdown methods
                local dropdownMethods = {}
                
                function dropdownMethods:SetOptions(newOptions)
                    -- Clear existing options
                    for _, child in ipairs(dropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Create new options
                    for _, option in ipairs(newOptions) do
                        createOption(option)
                    end
                end
                
                function dropdownMethods:GetOptions()
                    local options = {}
                    for _, child in ipairs(dropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            table.insert(options, child.Text)
                        end
                    end
                    return options
                end
                
                function dropdownMethods:SetSelected(selection)
                    if multiSelect then
                        selectedOptions = {}
                        for _, option in ipairs(selection) do
                            if table.find(optionsList, option) then
                                table.insert(selectedOptions, option)
                            end
                        end
                        
                        -- Update button colors
                        for _, child in ipairs(dropdownList:GetChildren()) do
                            if child:IsA("TextButton") then
                                if table.find(selectedOptions, child.Text) then
                                    child.BackgroundColor3 = theme.Accent
                                else
                                    child.BackgroundColor3 = theme.SecondaryBackground
                                end
                            end
                        end
                    else
                        if table.find(optionsList, selection) then
                            selectedOptions = {selection}
                            
                            -- Update button colors
                            for _, child in ipairs(dropdownList:GetChildren()) do
                                if child:IsA("TextButton") then
                                    if child.Text == selection then
                                        child.BackgroundColor3 = theme.Accent
                                    else
                                        child.BackgroundColor3 = theme.SecondaryBackground
                                    end
                                end
                            end
                        end
                    end
                    
                    updateDropdown()
                end
                
                function dropdownMethods:GetSelected()
                    if multiSelect then
                        return DeepCopy(selectedOptions)
                    else
                        return selectedOptions[1]
                    end
                end
                
                function dropdownMethods:SetCallback(newCallback)
                    callback = newCallback
                end
                
                return dropdownMethods
            end
            
            function sectionMethods:AddTextbox(textboxText, defaultText, callback, options)
                options = options or {}
                local textboxHeight = options.Height or 25
                local tooltipText = options.Tooltip or nil
                local placeholder = options.Placeholder or "Enter text..."
                local clearOnFocus = options.ClearOnFocus or false
                
                local textboxFrame = Create("Frame", {
                    Name = "TextboxFrame",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, textboxHeight + 15),
                    Parent = sectionContent
                })
                
                local textboxLabel = Create("TextLabel", {
                    Name = "TextboxLabel",
                    BackgroundTransparency = 1,
                    Font = config.DefaultFont,
                    Text = textboxText,
                    TextColor3 = theme.TextColor,
                    TextSize = config.TextSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(0.7, -5, 0, 20),
                    Parent = textboxFrame
                })
                
                local textbox = Create("TextBox", {
                    Name = "Textbox",
                    BackgroundColor3 = theme.SecondaryBackground,
                    BorderColor3 = theme.BorderColor,
                    BorderSizePixel = config.BorderSizePixel,
                    Font = config.DefaultFont,
                    PlaceholderText = placeholder,
                    Text = defaultText or "",
                    TextColor3 = theme.TextColor,
                    TextSize = config.TextSize,
                    Size = UDim2.new(0.3, 0, 0, textboxHeight),
                    Position = UDim2.new(0.7, 5, 0, 0),
                    Parent = textboxFrame
                })
                
                local textboxCorner = Create("UICorner", {
                    CornerRadius = config.CornerRadius,
                    Parent = textbox
                })
                
                if tooltipText then
                    local tooltip = CreateTooltip(tooltipText, textboxFrame)
                    
                    textboxFrame.MouseEnter:Connect(function()
                        tooltip.Visible = true
                        tooltip.Position = UDim2.new(0, textboxFrame.AbsolutePosition.X - sectionContent.AbsolutePosition.X, 
                                                    0, textboxFrame.AbsolutePosition.Y - sectionContent.AbsolutePosition.Y + textboxFrame.AbsoluteSize.Y)
                    end)
                    
                    textboxFrame.MouseLeave:Connect(function()
                        tooltip.Visible = false
                    end)
                end
                
                if clearOnFocus then
                    textbox.Focused:Connect(function()
                        textbox.Text = ""
                    end)
                end
                
                textbox.FocusLost:Connect(function(enterPressed)
                    if callback and (enterPressed or not clearOnFocus) then
                        callback(textbox.Text)
                    end
                end)
                
                -- Textbox methods
                local textboxMethods = {}
                
                function textboxMethods:SetText(newText)
                    textbox.Text = newText
                end
                
                function textboxMethods:GetText()
                    return textbox.Text
                end
                
                function textboxMethods:SetPlaceholder(newPlaceholder)
                    textbox.PlaceholderText = newPlaceholder
                end
                
                function textboxMethods:SetCallback(newCallback)
                    callback = newCallback
                end
                
                return textboxMethods
            end
            
            function sectionMethods:AddKeybind(keybindText, defaultKey, callback, options)
                options = options or {}
                local keybindHeight = options.Height or 25
                local tooltipText = options.Tooltip or nil
                
                local keybindFrame = Create("Frame", {
                    Name = "KeybindFrame",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, keybindHeight + 15),
                    Parent = sectionContent
                })
                
                local keybindLabel = Create("TextLabel", {
                    Name = "KeybindLabel",
                    BackgroundTransparency = 1,
                    Font = config.DefaultFont,
                    Text = keybindText,
                    TextColor3 = theme.TextColor,
                    TextSize = config.TextSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(0.7, -5, 0, 20),
                    Parent = keybindFrame
                })
                
                local keybindButton = Create("TextButton", {
                    Name = "KeybindButton",
                    BackgroundColor3 = theme.SecondaryBackground,
                    BorderColor3 = theme.BorderColor,
                    BorderSizePixel = config.BorderSizePixel,
                    Font = config.DefaultFont,
                    Text = defaultKey and defaultKey.Name or "None",
                    TextColor3 = theme.TextColor,
                    TextSize = config.TextSize,
                    Size = UDim2.new(0.3, 0, 0, keybindHeight),
                    Position = UDim2.new(0.7, 5, 0, 0),
                    Parent = keybindFrame
                })
                
                local keybindCorner = Create("UICorner", {
                    CornerRadius = config.CornerRadius,
                    Parent = keybindButton
                })
                
                if tooltipText then
                    local tooltip = CreateTooltip(tooltipText, keybindFrame)
                    
                    keybindFrame.MouseEnter:Connect(function()
                        tooltip.Visible = true
                        tooltip.Position = UDim2.new(0, keybindFrame.AbsolutePosition.X - sectionContent.AbsolutePosition.X, 
                                                    0, keybindFrame.AbsolutePosition.Y - sectionContent.AbsolutePosition.Y + keybindFrame.AbsoluteSize.Y)
                    end)
                    
                    keybindFrame.MouseLeave:Connect(function()
                        tooltip.Visible = false
                    end)
                end
                
                local listening = false
                local currentKey = defaultKey
                
                local function setKey(key)
                    currentKey = key
                    keybindButton.Text = key and key.Name or "None"
                    listening = false
                    
                    if callback then
                        callback(key)
                    end
                end
                
                keybindButton.MouseButton1Click:Connect(function()
                    listening = true
                    keybindButton.Text = "..."
                end)
                
                local connection
                connection = UserInputService.InputBegan:Connect(function(input)
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            setKey(input.KeyCode)
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                            setKey(Enum.KeyCode.MouseButton1)
                        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                            setKey(Enum.KeyCode.MouseButton2)
                        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                            setKey(Enum.KeyCode.MouseButton3)
                        end
                    elseif currentKey and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                        if callback then
                            callback(currentKey, true) -- Second argument indicates the key was pressed
                        end
                    end
                end)
                
                keybindFrame.AncestryChanged:Connect(function()
                    if not keybindFrame.Parent then
                        connection:Disconnect()
                    end
                end)
                
                -- Keybind methods
                local keybindMethods = {}
                
                function keybindMethods:SetKey(key)
                    setKey(key)
                end
                
                function keybindMethods:GetKey()
                    return currentKey
                end
                
                function keybindMethods:SetCallback(newCallback)
                    callback = newCallback
                end
                
                return keybindMethods
            end
            
            function sectionMethods:AddColorPicker(colorPickerText, defaultColor, callback, options)
                options = options or {}
                local colorPickerHeight = options.Height or 25
                local tooltipText = options.Tooltip or nil
                
                local colorPickerFrame = Create("Frame", {
                    Name = "ColorPickerFrame",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, colorPickerHeight + 15),
                    Parent = sectionContent
                })
                
                local colorPickerLabel = Create("TextLabel", {
                    Name = "ColorPickerLabel",
                    BackgroundTransparency = 1,
                    Font = config.DefaultFont,
                    Text = colorPickerText,
                    TextColor3 = theme.TextColor,
                    TextSize = config.TextSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(0.7, -5, 0, 20),
                    Parent = colorPickerFrame
                })
                
                local colorPickerButton = Create("TextButton", {
                    Name = "ColorPickerButton",
                    BackgroundColor3 = defaultColor or theme.Accent,
                    BorderColor3 = theme.BorderColor,
                    BorderSizePixel = config.BorderSizePixel,
                    Font = config.DefaultFont,
                    Text = "",
                    Size = UDim2.new(0.3, 0, 0, colorPickerHeight),
                    Position = UDim2.new(0.7, 5, 0, 0),
                    Parent = colorPickerFrame
                })
                
                local colorPickerCorner = Create("UICorner", {
                    CornerRadius = config.CornerRadius,
                    Parent = colorPickerButton
                })
                
                if tooltipText then
                    local tooltip = CreateTooltip(tooltipText, colorPickerFrame)
                    
                    colorPickerFrame.MouseEnter:Connect(function()
                        tooltip.Visible = true
                        tooltip.Position = UDim2.new(0, colorPickerFrame.AbsolutePosition.X - sectionContent.AbsolutePosition.X, 
                                                    0, colorPickerFrame.AbsolutePosition.Y - sectionContent.AbsolutePosition.Y + colorPickerFrame.AbsoluteSize.Y)
                    end)
                    
                    colorPickerFrame.MouseLeave:Connect(function()
                        tooltip.Visible = false
                    end)
                end
                
                -- Color picker popup
                local colorPickerPopup = Create("Frame", {
                    Name = "ColorPickerPopup",
                    BackgroundColor3 = theme.SecondaryBackground,
                    BorderColor3 = theme.BorderColor,
                    BorderSizePixel = config.BorderSizePixel,
                    Size = UDim2.new(0, 200, 0, 200),
                    Position = UDim2.new(1, 5, 0, 0),
                    Visible = false,
                    ZIndex = 20,
                    Parent = colorPickerButton
                })
                
                local colorPickerPopupCorner = Create("UICorner", {
                    CornerRadius = config.CornerRadius,
                    Parent = colorPickerPopup
                })
                
                local colorPickerPopupShadow = Create("ImageLabel", {
                    Name = "ColorPickerPopupShadow",
                    Image = "rbxassetid://1316045217",
                    ImageColor3 = Color3.new(0, 0, 0),
                    ImageTransparency = theme.DropShadowOpacity,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(10, 10, 118, 118),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 10, 1, 10),
                    Position = UDim2.new(0, -5, 0, -5),
                    ZIndex = colorPickerPopup.ZIndex - 1,
                    Parent = colorPickerPopup
                })
                
                -- Color spectrum
                local colorSpectrum = Create("ImageLabel", {
                    Name = "ColorSpectrum",
                    Image = "rbxassetid://8349657421", -- Color spectrum image
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -60, 1, -30),
                    Position = UDim2.new(0, 5, 0, 5),
                    ZIndex = colorPickerPopup.ZIndex + 1,
                    Parent = colorPickerPopup
                })
                
                -- Brightness slider
                local brightnessSlider = Create("Frame", {
                    Name = "BrightnessSlider",
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderColor3 = theme.BorderColor,
                    BorderSizePixel = config.BorderSizePixel,
                    Size = UDim2.new(0, 20, 1, -30),
                    Position = UDim2.new(1, -25, 0, 5),
                    ZIndex = colorPickerPopup.ZIndex + 1,
                    Parent = colorPickerPopup
                })
                
                local brightnessSliderCorner = Create("UICorner", {
                    CornerRadius = config.CornerRadius,
                    Parent = brightnessSlider
                })
                
                local brightnessGradient = Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
                    }),
                    Rotation = 0,
                    Parent = brightnessSlider
                })
                
                local brightnessHandle = Create("Frame", {
                    Name = "BrightnessHandle",
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderColor3 = theme.BorderColor,
                    BorderSizePixel = config.BorderSizePixel,
                    Size = UDim2.new(1, 4, 0, 6),
                    Position = UDim2.new(0, -2, 0.5, -3),
                    ZIndex = colorPickerPopup.ZIndex + 2,
                    Parent = brightnessSlider
                })
                
                local brightnessHandleCorner = Create("UICorner", {
                    CornerRadius = config.CornerRadius,
                    Parent = brightnessHandle
                })
                
                -- Color preview
                local colorPreview = Create("Frame", {
                    Name = "ColorPreview",
                    BackgroundColor3 = defaultColor or theme.Accent,
                    BorderColor3 = theme.BorderColor,
                    BorderSizePixel = config.BorderSizePixel,
                    Size = UDim2.new(0, 50, 0, 20),
                    Position = UDim2.new(0, 5, 1, -25),
                    ZIndex = colorPickerPopup.ZIndex + 1,
                    Parent = colorPickerPopup
                })
                
                local colorPreviewCorner = Create("UICorner", {
                    CornerRadius = config.CornerRadius,
                    Parent = colorPreview
                })
                
                -- Hex input
                local hexInput = Create("TextBox", {
                    Name = "HexInput",
                    BackgroundColor3 = theme.SecondaryBackground,
                    BorderColor3 = theme.BorderColor,
                    BorderSizePixel = config.BorderSizePixel,
                    Font = config.DefaultFont,
                    PlaceholderText = "Hex Color",
                    Text = "",
                    TextColor3 = theme.TextColor,
                    TextSize = config.TextSize,
                    Size = UDim2.new(0, 120, 0, 20),
                    Position = UDim2.new(0, 60, 1, -25),
                    ZIndex = colorPickerPopup.ZIndex + 1,
                    Parent = colorPickerPopup
                })
                
                local hexInputCorner = Create("UICorner", {
                    CornerRadius = config.CornerRadius,
                    Parent = hexInput
                })
                
                -- Current color values
                local currentHue = 0
                local currentSaturation = 1
                local currentValue = 1
                local currentColor = defaultColor or theme.Accent
                
                local function updateColor()
                    currentColor = Color3.fromHSV(currentHue, currentSaturation, currentValue)
                    colorPickerButton.BackgroundColor3 = currentColor
                    colorPreview.BackgroundColor3 = currentColor
                    hexInput.Text = string.format("#%02X%02X%02X", 
                        math.floor(currentColor.R * 255), 
                        math.floor(currentColor.G * 255), 
                        math.floor(currentColor.B * 255))
                    
                    if callback then
                        callback(currentColor)
                    end
                end
                
                -- Color spectrum selection
                local spectrumDragging = false
                
                colorSpectrum.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        spectrumDragging = true
                        local xPos = (input.Position.X - colorSpectrum.AbsolutePosition.X) / colorSpectrum.AbsoluteSize.X
                        local yPos = (input.Position.Y - colorSpectrum.AbsolutePosition.Y) / colorSpectrum.AbsoluteSize.Y
                        
                        currentHue = math.clamp(xPos, 0, 1)
                        currentSaturation = 1 - math.clamp(yPos, 0, 1)
                        updateColor()
                    end
                end)
                
                colorSpectrum.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        spectrumDragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if spectrumDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local xPos = (input.Position.X - colorSpectrum.AbsolutePosition.X) / colorSpectrum.AbsoluteSize.X
                        local yPos = (input.Position.Y - colorSpectrum.AbsolutePosition.Y) / colorSpectrum.AbsoluteSize.Y
                        
                        currentHue = math.clamp(xPos, 0, 1)
                        currentSaturation = 1 - math.clamp(yPos, 0, 1)
                        updateColor()
                    end
                end)
                
                -- Brightness slider
                local brightnessDragging = false
                
                brightnessSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        brightnessDragging = true
                        local yPos = (input.Position.Y - brightnessSlider.AbsolutePosition.Y) / brightnessSlider.AbsoluteSize.Y
                        currentValue = 1 - math.clamp(yPos, 0, 1)
                        updateColor()
                    end
                end)
                
                brightnessSlider.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        brightnessDragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if brightnessDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local yPos = (input.Position.Y - brightnessSlider.AbsolutePosition.Y) / brightnessSlider.AbsoluteSize.Y
                        currentValue = 1 - math.clamp(yPos, 0, 1)
                        updateColor()
                    end
                end)
                
                -- Hex input
                hexInput.FocusLost:Connect(function()
                    local hex = hexInput.Text:gsub("#", "")
                    if #hex == 3 then
                        hex = hex:gsub("(.)", "%1%1")
                    end
                    
                    if #hex == 6 then
                        local r = tonumber(hex:sub(1, 2), 16) / 255
                        local g = tonumber(hex:sub(3, 4), 16) / 255
                        local b = tonumber(hex:sub(5, 6), 16) / 255
                        
                        if r and g and b then
                            currentColor = Color3.new(r, g, b)
                            currentHue, currentSaturation, currentValue = Color3.toHSV(currentColor)
                            updateColor()
                        end
                    end
                end)
                
                -- Toggle popup
                colorPickerButton.MouseButton1Click:Connect(function()
                    colorPickerPopup.Visible = not colorPickerPopup.Visible
                    
                    -- Initialize color values
                    if colorPickerPopup.Visible then
                        currentHue, currentSaturation, currentValue = Color3.toHSV(currentColor)
                        brightnessHandle.Position = UDim2.new(0, -2, 1 - currentValue, -3)
                        updateColor()
                    end
                end)
                
                -- Close popup when clicking outside
                local colorPickerConnection
                colorPickerConnection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if colorPickerPopup.Visible and not colorPickerButton:IsDescendantOf(input:GetMouseTarget()) and not colorPickerPopup:IsDescendantOf(input:GetMouseTarget()) then
                            colorPickerPopup.Visible = false
                        end
                    end
                end)
                
                colorPickerPopup.AncestryChanged:Connect(function()
                    if not colorPickerPopup.Parent then
                        colorPickerConnection:Disconnect()
                    end
                end)
                
                -- Initialize
                updateColor()
                
                -- Color picker methods
                local colorPickerMethods = {}
                
                function colorPickerMethods:SetColor(color)
                    currentColor = color
                    currentHue, currentSaturation, currentValue = Color3.toHSV(currentColor)
                    updateColor()
                end
                
                function colorPickerMethods:GetColor()
                    return currentColor
                end
                
                function colorPickerMethods:SetCallback(newCallback)
                    callback = newCallback
                end
                
                return colorPickerMethods
            end
            
            function sectionMethods:AddDivider(options)
                options = options or {}
                local dividerHeight = options.Height or 1
                local dividerColor = options.Color or theme.BorderColor
                local dividerPadding = options.Padding or 10
                
                local dividerFrame = Create("Frame", {
                    Name = "DividerFrame",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, dividerHeight + dividerPadding * 2),
                    Parent = sectionContent
                })
                
                local divider = Create("Frame", {
                    Name = "Divider",
                    BackgroundColor3 = dividerColor,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -dividerPadding * 2, 0, dividerHeight),
                    Position = UDim2.new(0, dividerPadding, 0, dividerPadding),
                    Parent = dividerFrame
                })
                
                -- Divider methods
                local dividerMethods = {}
                
                function dividerMethods:SetColor(newColor)
                    divider.BackgroundColor3 = newColor
                end
                
                return dividerMethods
            end
            
            return sectionMethods
        end
        
        return tabMethods
    end
    
    return windowMethods
end

-- Initialize library
function VHSynth.Init()
    -- Create global VHSynth UI folder if it doesn't exist
    if not CoreGui:FindFirstChild("VHSynthUI") then
        Create("Folder", {
            Name = "VHSynthUI",
            Parent = CoreGui
        })
    end
    
    -- Apply VHS effects to existing UI elements
    for _, ui in ipairs(CoreGui.VHSynthUI:GetDescendants()) do
        if ui:IsA("Frame") or ui:IsA("ScrollingFrame") then
            ApplyVHSEffects(ui)
        end
    end
    
    print("VHSynth UI Library v"..VHSynth.Version.." initialized")
end

-- Initialize the library automatically
VHSynth.Init()

return VHSynth
