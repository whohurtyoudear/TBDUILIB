--[[
    Bills Lib
    A comprehensive, modern UI Library for Roblox
    Version 1.0.1
    
    Features:
    - Retro/neon synthwave aesthetic
    - Full component support (toggles, buttons, dropdowns, sliders, etc.)
    - Notification system
    - Window controls (minimize, close, drag)
    - Responsive design for both PC and mobile
    - Theme customization
    - Proper Z-index management
    - Memory leak prevention
    
    Created by Bill
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")

-- Constants
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera

-- Utility Functions
local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function CreateTween(instance, duration, properties, easingStyle, easingDirection)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out),
        properties
    )
    return tween
end

local function RoundNumber(number, decimalPlaces)
    local mult = 10 ^ (decimalPlaces or 0)
    return math.floor(number * mult + 0.5) / mult
end

local function GetTextBounds(text, font, size)
    return TextService:GetTextSize(text, size, font, Vector2.new(1000, 1000))
end

-- Core Library
local BillsLib = {
    Version = "1.0.1",
    Windows = {},
    Initialized = false,
    Theme = {
        -- Retro/synthwave color scheme
        Primary = Color3.fromRGB(20, 20, 40),
        Secondary = Color3.fromRGB(15, 15, 30),
        Accent = Color3.fromRGB(0, 200, 255),      -- Cyan
        AccentGradient1 = Color3.fromRGB(0, 200, 255), -- Cyan
        AccentGradient2 = Color3.fromRGB(255, 0, 200), -- Pink
        TextColor = Color3.fromRGB(255, 255, 255),
        InputBackground = Color3.fromRGB(30, 30, 50),
        NotificationBackground = Color3.fromRGB(20, 20, 40),
        Success = Color3.fromRGB(0, 255, 170),
        Warning = Color3.fromRGB(255, 191, 0),
        Error = Color3.fromRGB(255, 0, 128),
        Info = Color3.fromRGB(0, 170, 255),
        DropdownBackground = Color3.fromRGB(30, 30, 50),
        SliderBackground = Color3.fromRGB(40, 40, 60),
        SliderFill = Color3.fromRGB(0, 200, 255),
        ToggleBackground = Color3.fromRGB(40, 40, 60),
        ToggleFill = Color3.fromRGB(0, 200, 255),
        BorderColor = Color3.fromRGB(0, 200, 255),
        PlaceholderColor = Color3.fromRGB(180, 180, 180),
        TabBackground = Color3.fromRGB(25, 25, 45),
        TabBackgroundSelected = Color3.fromRGB(35, 35, 60),
        SectionBackground = Color3.fromRGB(25, 25, 45),
        DividerColor = Color3.fromRGB(0, 200, 255),
        Glow = Color3.fromRGB(0, 200, 255)
    },
    Icons = {
        Close = "rbxassetid://11570895459", -- X icon
        Minimize = "rbxassetid://11570886801", -- Minus icon
        Settings = "rbxassetid://11571010545", -- Gear icon
        Dashboard = "rbxassetid://11571269542", -- Home icon
        Components = "rbxassetid://11571124882", -- Puzzle icon
        Help = "rbxassetid://11571346458", -- Question mark
        Logo = "rbxassetid://11571379977", -- Logo placeholder
        Notification = {
            Success = "rbxassetid://11571356503", -- Checkmark
            Warning = "rbxassetid://11571352731", -- Warning triangle
            Error = "rbxassetid://11571344309", -- Error X
            Info = "rbxassetid://11571349138" -- Info i
        },
        Dropdown = "rbxassetid://11571320677", -- Arrow down
        Toggle = {
            On = "rbxassetid://11571441859", -- Toggle on
            Off = "rbxassetid://11571434310" -- Toggle off
        },
        Slider = "rbxassetid://11571438678", -- Slider circle
        ColorPicker = "rbxassetid://11571283892" -- Color palette
    },
    Notifications = {},
    ToggleKey = Enum.KeyCode.RightShift,
    Objects = {}
}

-- Create main ScreenGui container
function BillsLib:CreateGui()
    local success, result = pcall(function()
        if RunService:IsStudio() then
            return Player:WaitForChild("PlayerGui")
        else
            return CoreGui
        end
    end)
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BillsLib"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if success then
        screenGui.Parent = result
    else
        screenGui.Parent = Player:WaitForChild("PlayerGui")
    end
    
    self.ScreenGui = screenGui
    
    -- Create notification container
    local notificationContainer = Instance.new("Frame")
    notificationContainer.Name = "NotificationContainer"
    notificationContainer.AnchorPoint = Vector2.new(1, 0)
    notificationContainer.BackgroundTransparency = 1
    notificationContainer.Position = UDim2.new(1, -20, 0, 20)
    notificationContainer.Size = UDim2.new(0, 300, 1, -40)
    notificationContainer.Parent = screenGui
    
    local notificationLayout = Instance.new("UIListLayout")
    notificationLayout.Padding = UDim.new(0, 10)
    notificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notificationLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    notificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    notificationLayout.Parent = notificationContainer
    
    self.NotificationContainer = notificationContainer
    
    return screenGui
end

-- Create rounded frame utility function
function BillsLib:CreateRoundFrame(name, size, position, color, parent, cornerRadius)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 6)
    corner.Parent = frame
    
    return frame
end

-- Create text label utility function
function BillsLib:CreateLabel(name, text, size, position, textColor, font, parent, textSize, textXAlign, textYAlign)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = textColor or self.Theme.TextColor
    label.Font = font or Enum.Font.SourceSansSemibold
    label.TextSize = textSize or 14
    label.TextXAlignment = textXAlign or Enum.TextXAlignment.Left
    label.TextYAlignment = textYAlign or Enum.TextYAlignment.Center
    label.Parent = parent
    
    return label
end

-- Create button utility function
function BillsLib:CreateTextButton(name, text, size, position, bgColor, textColor, callback, parent, cornerRadius, font, textSize)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = bgColor or self.Theme.Accent
    button.TextColor3 = textColor or self.Theme.TextColor
    button.Text = text
    button.Font = font or Enum.Font.SourceSansSemibold
    button.TextSize = textSize or 14
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 6)
    corner.Parent = button
    
    button.MouseEnter:Connect(function()
        CreateTween(button, 0.2, {BackgroundColor3 = bgColor:Lerp(Color3.fromRGB(255, 255, 255), 0.2)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        CreateTween(button, 0.2, {BackgroundColor3 = bgColor}):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        callback()
    end)
    
    return button
end

-- Create shadow utility
function BillsLib:AddShadow(frame, transparency, spread)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, spread or 24, 1, spread or 24)
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = frame.ZIndex - 1
    shadow.Parent = frame
    
    return shadow
end

-- Build a window
function BillsLib:CreateWindow(title, size)
    if not self.Initialized then
        self:CreateGui()
        self.Initialized = true
    end
    
    local windowSize = size or UDim2.new(0, 550, 0, 400)
    
    -- Main window frame
    local window = self:CreateRoundFrame("Window", windowSize, UDim2.new(0.5, -windowSize.X.Offset / 2, 0.5, -windowSize.Y.Offset / 2), self.Theme.Primary, self.ScreenGui, 8)
    window.ClipsDescendants = true
    window.ZIndex = 10
    
    -- Add shadow
    self:AddShadow(window, 0.5, 30)
    
    -- Title bar
    local titleBar = self:CreateRoundFrame("TitleBar", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), self.Theme.Secondary, window, 8)
    titleBar.ZIndex = 11
    
    -- Only round the top corners of title bar
    if titleBar then
        local titleBarCorner = titleBar:FindFirstChild("UICorner")
        if titleBarCorner then
            titleBarCorner.CornerRadius = UDim.new(0, 8)
        end
    end
    
    -- Make title bar draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Title text
    local titleText = self:CreateLabel("TitleText", title or "Bills Lib", UDim2.new(1, -130, 1, 0), UDim2.new(0, 15, 0, 0), self.Theme.TextColor, Enum.Font.SourceSansBold, titleBar, 18)
    
    -- Window controls (minimize, close)
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "CloseButton"
    closeButton.BackgroundTransparency = 1
    closeButton.Position = UDim2.new(1, -35, 0.5, -10)
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Image = self.Icons.Close
    closeButton.ImageColor3 = self.Theme.TextColor
    closeButton.ZIndex = 12
    closeButton.Parent = titleBar
    
    closeButton.MouseEnter:Connect(function()
        CreateTween(closeButton, 0.2, {ImageColor3 = self.Theme.Error}):Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        CreateTween(closeButton, 0.2, {ImageColor3 = self.Theme.TextColor}):Play()
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        window.Visible = false
    end)
    
    local minimizeButton = Instance.new("ImageButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Position = UDim2.new(1, -65, 0.5, -10)
    minimizeButton.Size = UDim2.new(0, 20, 0, 20)
    minimizeButton.Image = self.Icons.Minimize
    minimizeButton.ImageColor3 = self.Theme.TextColor
    minimizeButton.ZIndex = 12
    minimizeButton.Parent = titleBar
    
    minimizeButton.MouseEnter:Connect(function()
        CreateTween(minimizeButton, 0.2, {ImageColor3 = self.Theme.Accent}):Play()
    end)
    
    minimizeButton.MouseLeave:Connect(function()
        CreateTween(minimizeButton, 0.2, {ImageColor3 = self.Theme.TextColor}):Play()
    end)
    
    -- Logo in title bar
    local logo = Instance.new("ImageLabel")
    logo.Name = "Logo"
    logo.BackgroundTransparency = 1
    logo.Size = UDim2.new(0, 24, 0, 24)
    logo.Position = UDim2.new(0, 10, 0.5, -12)
    logo.Image = self.Icons.Logo
    logo.ZIndex = 12
    logo.Parent = titleBar
    
    -- Content area
    local contentContainer = self:CreateRoundFrame("ContentContainer", UDim2.new(1, 0, 1, -80), UDim2.new(0, 0, 0, 70), self.Theme.Secondary, window, 8)
    contentContainer.ClipsDescendants = true
    contentContainer.ZIndex = 11
    
    -- Tab container
    local tabContainer = self:CreateRoundFrame("TabContainer", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 40), self.Theme.Secondary, window, 0)
    tabContainer.ZIndex = 12
    
    -- Tab container layout
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabContainer
    
    -- Tab container padding
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingLeft = UDim.new(0, 10)
    tabPadding.Parent = tabContainer
    
    -- Window object for returning
    local windowObj = {
        Instance = window,
        Title = titleText,
        ContentContainer = contentContainer,
        TabContainer = tabContainer,
        Tabs = {},
        TabButtons = {},
        ActiveTab = nil
    }
    
    -- Add default dashboard tab
    local dashboardTab = self:CreateTab(windowObj, "Dashboard")
    dashboardTab.Instance.Visible = true
    windowObj.ActiveTab = "Dashboard"
    
    -- Welcome label in dashboard
    local welcomeLabel = self:CreateLabel(
        "WelcomeLabel", 
        "Welcome to Bills Lib", 
        UDim2.new(1, -40, 0, 40), 
        UDim2.new(0, 20, 0, 20), 
        self.Theme.TextColor, 
        Enum.Font.SourceSansBold, 
        dashboardTab.Instance, 
        24
    )
    
    -- Description text
    local descLabel = self:CreateLabel(
        "DescriptionLabel", 
        "A comprehensive UI Library for Roblox with a retro/neon style.", 
        UDim2.new(1, -40, 0, 20), 
        UDim2.new(0, 20, 0, 70), 
        self.Theme.TextColor, 
        Enum.Font.SourceSans, 
        dashboardTab.Instance, 
        16
    )
    
    -- Version text
    local versionLabel = self:CreateLabel(
        "VersionLabel", 
        "Version " .. self.Version, 
        UDim2.new(1, -40, 0, 20), 
        UDim2.new(0, 20, 0, 100), 
        self.Theme.AccentGradient1, 
        Enum.Font.SourceSans, 
        dashboardTab.Instance, 
        14
    )
    
    -- Add to windows table
    table.insert(self.Windows, windowObj)
    
    return windowObj
end

-- Create tab
function BillsLib:CreateTab(window, name)
    -- Tab button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = "Tab_" .. name
    tabButton.Text = name
    tabButton.Font = Enum.Font.SourceSansSemibold
    tabButton.TextSize = 14
    tabButton.TextColor3 = self.Theme.TextColor
    tabButton.Size = UDim2.new(0, 100, 1, 0)
    tabButton.BackgroundColor3 = window.ActiveTab == name and self.Theme.TabBackgroundSelected or self.Theme.TabBackground
    tabButton.BorderSizePixel = 0
    tabButton.ZIndex = 13
    tabButton.Parent = window.TabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabButton
    
    -- Tab content container
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = name
    tabContent.Size = UDim2.new(1, -20, 1, -20)
    tabContent.Position = UDim2.new(0, 10, 0, 10)
    tabContent.BackgroundTransparency = 1
    tabContent.ScrollBarThickness = 5
    tabContent.ScrollBarImageColor3 = self.Theme.Accent
    tabContent.BorderSizePixel = 0
    tabContent.ZIndex = 12
    tabContent.Visible = window.ActiveTab == name
    tabContent.Parent = window.ContentContainer
    
    -- Content layout
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = tabContent
    
    -- Auto-size content
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Click to switch tabs
    tabButton.MouseButton1Click:Connect(function()
        -- Hide all tabs
        for _, tab in pairs(window.Tabs) do
            tab.Visible = false
        end
        
        -- Update tab button colors
        for tabName, button in pairs(window.TabButtons) do
            if tabName == name then
                CreateTween(button, 0.2, {BackgroundColor3 = self.Theme.TabBackgroundSelected}):Play()
            else
                CreateTween(button, 0.2, {BackgroundColor3 = self.Theme.TabBackground}):Play()
            end
        end
        
        -- Show selected tab
        tabContent.Visible = true
        window.ActiveTab = name
    end)
    
    -- Store references
    window.Tabs[name] = tabContent
    window.TabButtons[name] = tabButton
    
    -- Tab object for API
    local tabObj = {
        Instance = tabContent,
        Name = name,
        Sections = {}
    }
    
    return tabObj
end

-- Create section
function BillsLib:CreateSection(tab, title)
    local sectionContainer = Instance.new("Frame")
    sectionContainer.Name = "Section_" .. title
    sectionContainer.Size = UDim2.new(1, 0, 0, 36) -- Initial height, will grow
    sectionContainer.BackgroundColor3 = self.Theme.SectionBackground
    sectionContainer.BorderSizePixel = 0
    sectionContainer.ZIndex = 13
    sectionContainer.LayoutOrder = #tab.Instance:GetChildren()
    sectionContainer.Parent = tab.Instance
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 6)
    sectionCorner.Parent = sectionContainer
    
    local sectionTitle = self:CreateLabel("Title", title, UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 3), self.Theme.TextColor, Enum.Font.SourceSansBold, sectionContainer, 16)
    
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -20, 0, 0) -- Will be resized based on content
    contentContainer.Position = UDim2.new(0, 10, 0, 36)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ZIndex = 14
    contentContainer.Parent = sectionContainer
    
    local elementLayout = Instance.new("UIListLayout")
    elementLayout.Padding = UDim.new(0, 8)
    elementLayout.SortOrder = Enum.SortOrder.LayoutOrder
    elementLayout.Parent = contentContainer
    
    -- Auto-size content and update section height
    elementLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentContainer.Size = UDim2.new(1, -20, 0, elementLayout.AbsoluteContentSize.Y)
        sectionContainer.Size = UDim2.new(1, 0, 0, 36 + elementLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Section object for API
    local sectionObj = {
        Instance = sectionContainer,
        ContentContainer = contentContainer,
        Title = title,
        ElementCount = 0
    }
    
    -- Add to tab's sections
    tab.Sections[title] = sectionObj
    
    -- Section API methods
    
    -- AddLabel
    function sectionObj:AddLabel(text)
        self.ElementCount = self.ElementCount + 1
        
        local labelContainer = Instance.new("Frame")
        labelContainer.Name = "Label_" .. self.ElementCount
        labelContainer.Size = UDim2.new(1, 0, 0, 24)
        labelContainer.BackgroundTransparency = 1
        labelContainer.LayoutOrder = self.ElementCount
        labelContainer.Parent = self.ContentContainer
        
        local label = BillsLib:CreateLabel("TextLabel", text, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), BillsLib.Theme.TextColor, Enum.Font.SourceSans, labelContainer, 14)
        
        -- Label API
        local labelObj = {}
        labelObj.Instance = labelContainer
        
        function labelObj:SetText(newText)
            label.Text = newText
        end
        
        return labelObj
    end
    
    -- AddButton
    function sectionObj:AddButton(text, callback)
        self.ElementCount = self.ElementCount + 1
        callback = callback or function() end
        
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Name = "Button_" .. self.ElementCount
        buttonContainer.Size = UDim2.new(1, 0, 0, 32)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.LayoutOrder = self.ElementCount
        buttonContainer.Parent = self.ContentContainer
        
        local button = BillsLib:CreateTextButton("Button", text, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), BillsLib.Theme.Accent, BillsLib.Theme.TextColor, callback, buttonContainer, 4)
        
        -- Button ripple effect
        button.MouseButton1Down:Connect(function()
            local ripple = Instance.new("Frame")
            ripple.Name = "Ripple"
            ripple.AnchorPoint = Vector2.new(0.5, 0.5)
            ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
            ripple.BorderSizePixel = 0
            ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ripple.BackgroundTransparency = 0.8
            ripple.ZIndex = button.ZIndex + 1
            ripple.Parent = button
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0) -- Circle
            corner.Parent = ripple
            
            -- Animate ripple
            ripple.Size = UDim2.new(0, 0, 0, 0)
            local targetSize = UDim2.new(0, button.AbsoluteSize.X * 1.5, 0, button.AbsoluteSize.X * 1.5)
            
            local growTween = CreateTween(ripple, 0.5, {Size = targetSize, BackgroundTransparency = 1})
            growTween:Play()
            
            growTween.Completed:Connect(function()
                ripple:Destroy()
            end)
        end)
        
        -- Button API
        local buttonObj = {}
        buttonObj.Instance = buttonContainer
        
        function buttonObj:SetText(newText)
            button.Text = newText
        end
        
        return buttonObj
    end
    
    -- AddToggle
    function sectionObj:AddToggle(text, default, callback)
        self.ElementCount = self.ElementCount + 1
        default = default or false
        callback = callback or function() end
        
        local toggleContainer = Instance.new("Frame")
        toggleContainer.Name = "Toggle_" .. self.ElementCount
        toggleContainer.Size = UDim2.new(1, 0, 0, 32)
        toggleContainer.BackgroundTransparency = 1
        toggleContainer.LayoutOrder = self.ElementCount
        toggleContainer.Parent = self.ContentContainer
        
        local toggleLabel = BillsLib:CreateLabel("ToggleLabel", text, UDim2.new(1, -54, 1, 0), UDim2.new(0, 5, 0, 0), BillsLib.Theme.TextColor, Enum.Font.SourceSans, toggleContainer, 14)
        
        local toggleButton = BillsLib:CreateRoundFrame("ToggleButton", UDim2.new(0, 44, 0, 24), UDim2.new(1, -49, 0.5, -12), BillsLib.Theme.ToggleBackground, toggleContainer, 12)
        
        local toggleCircle = Instance.new("Frame")
        toggleCircle.Name = "ToggleCircle"
        toggleCircle.Size = UDim2.new(0, 18, 0, 18)
        toggleCircle.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        toggleCircle.BackgroundColor3 = BillsLib.Theme.TextColor
        toggleCircle.BorderSizePixel = 0
        toggleCircle.ZIndex = toggleButton.ZIndex + 1
        toggleCircle.Parent = toggleButton
        
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = toggleCircle
        
        -- Toggle state
        local enabled = default
        
        -- Update toggle appearance based on state
        local function updateToggle()
            CreateTween(toggleCircle, 0.2, {
                Position = enabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            }):Play()
            
            CreateTween(toggleButton, 0.2, {
                BackgroundColor3 = enabled and BillsLib.Theme.ToggleFill or BillsLib.Theme.ToggleBackground
            }):Play()
            
            callback(enabled)
        end
        
        -- Toggle interaction
        toggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                enabled = not enabled
                updateToggle()
            end
        end)
        
        -- Toggle API
        local toggleObj = {}
        toggleObj.Instance = toggleContainer
        
        function toggleObj:SetValue(value)
            if type(value) == "boolean" and value ~= enabled then
                enabled = value
                updateToggle()
            end
        end
        
        function toggleObj:GetValue()
            return enabled
        end
        
        function toggleObj:Toggle()
            enabled = not enabled
            updateToggle()
        end
        
        return toggleObj
    end
    
    -- AddSlider
    function sectionObj:AddSlider(text, min, max, default, decimals, callback)
        self.ElementCount = self.ElementCount + 1
        min = min or 0
        max = max or 100
        default = math.clamp(default or min, min, max)
        decimals = decimals or 0
        callback = callback or function() end
        
        local sliderContainer = Instance.new("Frame")
        sliderContainer.Name = "Slider_" .. self.ElementCount
        sliderContainer.Size = UDim2.new(1, 0, 0, 50)
        sliderContainer.BackgroundTransparency = 1
        sliderContainer.LayoutOrder = self.ElementCount
        sliderContainer.Parent = self.ContentContainer
        
        local sliderLabel = BillsLib:CreateLabel("SliderLabel", text, UDim2.new(1, 0, 0, 20), UDim2.new(0, 5, 0, 0), BillsLib.Theme.TextColor, Enum.Font.SourceSans, sliderContainer, 14)
        
        local valueLabel = BillsLib:CreateLabel("ValueLabel", tostring(RoundNumber(default, decimals)), UDim2.new(0, 50, 0, 20), UDim2.new(1, -55, 0, 0), BillsLib.Theme.TextColor, Enum.Font.SourceSansSemibold, sliderContainer, 14, Enum.TextXAlignment.Right)
        
        local sliderBar = BillsLib:CreateRoundFrame("SliderBar", UDim2.new(1, 0, 0, 6), UDim2.new(0, 0, 0, 32), BillsLib.Theme.SliderBackground, sliderContainer, 3)
        
        local sliderFill = BillsLib:CreateRoundFrame("SliderFill", UDim2.new((default - min) / (max - min), 0, 1, 0), UDim2.new(0, 0, 0, 0), BillsLib.Theme.SliderFill, sliderBar, 3)
        
        local sliderKnob = Instance.new("Frame")
        sliderKnob.Name = "SliderKnob"
        sliderKnob.Size = UDim2.new(0, 12, 0, 12)
        sliderKnob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
        sliderKnob.BackgroundColor3 = BillsLib.Theme.TextColor
        sliderKnob.BorderSizePixel = 0
        sliderKnob.ZIndex = sliderBar.ZIndex + 1
        sliderKnob.Parent = sliderBar
        
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = sliderKnob
        
        -- Slider state
        local value = default
        
        -- Update slider visuals and value
        local function updateSlider(newValue)
            value = math.clamp(newValue, min, max)
            local scaledValue = (value - min) / (max - min)
            
            CreateTween(sliderFill, 0.1, {Size = UDim2.new(scaledValue, 0, 1, 0)}):Play()
            CreateTween(sliderKnob, 0.1, {Position = UDim2.new(scaledValue, -6, 0.5, -6)}):Play()
            
            valueLabel.Text = tostring(RoundNumber(value, decimals))
            callback(value)
        end
        
        -- Slider interaction
        sliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local dragging = true
                
                local function updateFromMouse()
                    local relativeX = math.clamp((Mouse.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                    local newValue = min + (relativeX * (max - min))
                    updateSlider(newValue)
                end
                
                updateFromMouse()
                
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    if dragging then
                        updateFromMouse()
                    else
                        connection:Disconnect()
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(endInput)
                    if (endInput.UserInputType == Enum.UserInputType.MouseButton1 or 
                        endInput.UserInputType == Enum.UserInputType.Touch) then
                        dragging = false
                    end
                end)
            end
        end)
        
        -- Slider API
        local sliderObj = {}
        sliderObj.Instance = sliderContainer
        
        function sliderObj:SetValue(newValue)
            updateSlider(newValue)
        end
        
        function sliderObj:GetValue()
            return value
        end
        
        return sliderObj
    end
    
    -- AddDropdown
    function sectionObj:AddDropdown(text, options, default, callback)
        self.ElementCount = self.ElementCount + 1
        options = options or {}
        default = default or (options[1] or "")
        callback = callback or function() end
        
        local dropdownContainer = Instance.new("Frame")
        dropdownContainer.Name = "Dropdown_" .. self.ElementCount
        dropdownContainer.Size = UDim2.new(1, 0, 0, 52)
        dropdownContainer.BackgroundTransparency = 1
        dropdownContainer.LayoutOrder = self.ElementCount
        dropdownContainer.Parent = self.ContentContainer
        
        local dropdownLabel = BillsLib:CreateLabel("DropdownLabel", text, UDim2.new(1, 0, 0, 20), UDim2.new(0, 5, 0, 0), BillsLib.Theme.TextColor, Enum.Font.SourceSans, dropdownContainer, 14)
        
        local dropdownButton = BillsLib:CreateRoundFrame("DropdownButton", UDim2.new(1, 0, 0, 32), UDim2.new(0, 0, 0, 20), BillsLib.Theme.DropdownBackground, dropdownContainer, 4)
        
        local selectedText = BillsLib:CreateLabel("SelectedText", default, UDim2.new(1, -30, 1, 0), UDim2.new(0, 10, 0, 0), BillsLib.Theme.TextColor, Enum.Font.SourceSans, dropdownButton, 14)
        
        local dropdownArrow = Instance.new("ImageLabel")
        dropdownArrow.Name = "DropdownArrow"
        dropdownArrow.Size = UDim2.new(0, 16, 0, 16)
        dropdownArrow.Position = UDim2.new(1, -24, 0.5, -8)
        dropdownArrow.BackgroundTransparency = 1
        dropdownArrow.Image = BillsLib.Icons.Dropdown
        dropdownArrow.ImageColor3 = BillsLib.Theme.TextColor
        dropdownArrow.ZIndex = dropdownButton.ZIndex + 1
        dropdownArrow.Parent = dropdownButton
        
        -- Dropdown menu
        local dropdownMenu = Instance.new("Frame")
        dropdownMenu.Name = "DropdownMenu"
        dropdownMenu.Size = UDim2.new(1, 0, 0, 0) -- Will be sized based on options
        dropdownMenu.Position = UDim2.new(0, 0, 1, 2)
        dropdownMenu.BackgroundColor3 = BillsLib.Theme.DropdownBackground
        dropdownMenu.BorderSizePixel = 0
        dropdownMenu.ZIndex = dropdownButton.ZIndex + 2
        dropdownMenu.Visible = false
        dropdownMenu.Parent = dropdownButton
        
        local menuCorner = Instance.new("UICorner")
        menuCorner.CornerRadius = UDim.new(0, 4)
        menuCorner.Parent = dropdownMenu
        
        local menuLayout = Instance.new("UIListLayout")
        menuLayout.Padding = UDim.new(0, 2)
        menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
        menuLayout.Parent = dropdownMenu
        
        -- Dropdown state
        local selected = default
        local menuOpen = false
        
        -- Create option buttons
        local function createOptions()
            -- Clear existing options
            for _, child in ipairs(dropdownMenu:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            -- Create new options
            for i, option in ipairs(options) do
                local optionButton = Instance.new("TextButton")
                optionButton.Name = "Option_" .. i
                optionButton.Size = UDim2.new(1, 0, 0, 28)
                optionButton.BackgroundColor3 = BillsLib.Theme.DropdownBackground
                optionButton.Text = option
                optionButton.TextColor3 = BillsLib.Theme.TextColor
                optionButton.TextSize = 14
                optionButton.Font = Enum.Font.SourceSans
                optionButton.BorderSizePixel = 0
                optionButton.ZIndex = dropdownMenu.ZIndex
                optionButton.Parent = dropdownMenu
                
                -- Option hovering
                optionButton.MouseEnter:Connect(function()
                    CreateTween(optionButton, 0.2, {BackgroundColor3 = BillsLib.Theme.Accent}):Play()
                end)
                
                optionButton.MouseLeave:Connect(function()
                    CreateTween(optionButton, 0.2, {BackgroundColor3 = BillsLib.Theme.DropdownBackground}):Play()
                end)
                
                -- Option selection
                optionButton.MouseButton1Click:Connect(function()
                    selected = option
                    selectedText.Text = option
                    
                    menuOpen = false
                    dropdownMenu.Visible = false
                    callback(selected)
                end)
            end
            
            -- Update menu size
            dropdownMenu.Size = UDim2.new(1, 0, 0, math.min(#options * 30, 150))
            dropdownMenu.CanvasSize = UDim2.new(0, 0, 0, #options * 30)
        end
        
        -- Initialize options
        createOptions()
        
        -- Toggle dropdown menu
        dropdownButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                menuOpen = not menuOpen
                dropdownMenu.Visible = menuOpen
                
                -- Animate arrow
                local rotation = menuOpen and 180 or 0
                CreateTween(dropdownArrow, 0.2, {Rotation = rotation}):Play()
            end
        end)
        
        -- Close menu when clicking elsewhere
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if menuOpen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local dropdownPos = dropdownButton.AbsolutePosition
                    local dropdownSize = dropdownButton.AbsoluteSize
                    local menuPos = dropdownMenu.AbsolutePosition
                    local menuSize = dropdownMenu.AbsoluteSize
                    
                    local inDropdown = 
                        mousePos.X >= dropdownPos.X and 
                        mousePos.X <= dropdownPos.X + dropdownSize.X and 
                        mousePos.Y >= dropdownPos.Y and 
                        mousePos.Y <= dropdownPos.Y + dropdownSize.Y
                        
                    local inMenu = 
                        mousePos.X >= menuPos.X and 
                        mousePos.X <= menuPos.X + menuSize.X and 
                        mousePos.Y >= menuPos.Y and 
                        mousePos.Y <= menuPos.Y + menuSize.Y
                        
                    if not inDropdown and not inMenu then
                        menuOpen = false
                        dropdownMenu.Visible = false
                        CreateTween(dropdownArrow, 0.2, {Rotation = 0}):Play()
                    end
                end
            end
        end)
        
        -- Dropdown API
        local dropdownObj = {}
        dropdownObj.Instance = dropdownContainer
        
        function dropdownObj:SetValue(option)
            if table.find(options, option) then
                selected = option
                selectedText.Text = option
                callback(selected)
            end
        end
        
        function dropdownObj:GetValue()
            return selected
        end
        
        function dropdownObj:SetOptions(newOptions, newValue)
            options = newOptions
            createOptions()
            
            if newValue and table.find(options, newValue) then
                self:SetValue(newValue)
            elseif not table.find(options, selected) and options[1] then
                self:SetValue(options[1])
            end
        end
        
        function dropdownObj:Refresh(newOptions)
            self:SetOptions(newOptions)
        end
        
        return dropdownObj
    end
    
    -- AddTextbox
    function sectionObj:AddTextbox(text, default, callback)
        self.ElementCount = self.ElementCount + 1
        default = default or ""
        callback = callback or function() end
        
        local textboxContainer = Instance.new("Frame")
        textboxContainer.Name = "Textbox_" .. self.ElementCount
        textboxContainer.Size = UDim2.new(1, 0, 0, 52)
        textboxContainer.BackgroundTransparency = 1
        textboxContainer.LayoutOrder = self.ElementCount
        textboxContainer.Parent = self.ContentContainer
        
        local textboxLabel = BillsLib:CreateLabel("TextboxLabel", text, UDim2.new(1, 0, 0, 20), UDim2.new(0, 5, 0, 0), BillsLib.Theme.TextColor, Enum.Font.SourceSans, textboxContainer, 14)
        
        local textboxFrame = BillsLib:CreateRoundFrame("TextboxFrame", UDim2.new(1, 0, 0, 32), UDim2.new(0, 0, 0, 20), BillsLib.Theme.InputBackground, textboxContainer, 4)
        
        local textbox = Instance.new("TextBox")
        textbox.Name = "Textbox"
        textbox.Size = UDim2.new(1, -10, 1, 0)
        textbox.Position = UDim2.new(0, 5, 0, 0)
        textbox.BackgroundTransparency = 1
        textbox.Text = default
        textbox.PlaceholderText = "Enter text..."
        textbox.PlaceholderColor3 = BillsLib.Theme.PlaceholderColor
        textbox.TextColor3 = BillsLib.Theme.TextColor
        textbox.Font = Enum.Font.SourceSans
        textbox.TextSize = 14
        textbox.TextXAlignment = Enum.TextXAlignment.Left
        textbox.ClearTextOnFocus = false
        textbox.ZIndex = textboxFrame.ZIndex + 1
        textbox.Parent = textboxFrame
        
        -- Focus visual effect
        textbox.Focused:Connect(function()
            CreateTween(textboxFrame, 0.2, {BackgroundColor3 = BillsLib.Theme.Accent}):Play()
        end)
        
        textbox.FocusLost:Connect(function(enterPressed)
            CreateTween(textboxFrame, 0.2, {BackgroundColor3 = BillsLib.Theme.InputBackground}):Play()
            callback(textbox.Text, enterPressed)
        end)
        
        -- Textbox API
        local textboxObj = {}
        textboxObj.Instance = textboxContainer
        
        function textboxObj:SetValue(value)
            textbox.Text = value
        end
        
        function textboxObj:GetValue()
            return textbox.Text
        end
        
        return textboxObj
    end
    
    -- AddColorPicker
    function sectionObj:AddColorPicker(text, default, callback)
        self.ElementCount = self.ElementCount + 1
        default = default or Color3.fromRGB(255, 255, 255)
        callback = callback or function() end
        
        local colorPickerContainer = Instance.new("Frame")
        colorPickerContainer.Name = "ColorPicker_" .. self.ElementCount
        colorPickerContainer.Size = UDim2.new(1, 0, 0, 52)
        colorPickerContainer.BackgroundTransparency = 1
        colorPickerContainer.LayoutOrder = self.ElementCount
        colorPickerContainer.Parent = self.ContentContainer
        
        local colorLabel = BillsLib:CreateLabel("ColorLabel", text, UDim2.new(1, -60, 0, 20), UDim2.new(0, 5, 0, 0), BillsLib.Theme.TextColor, Enum.Font.SourceSans, colorPickerContainer, 14)
        
        local colorButton = BillsLib:CreateRoundFrame("ColorButton", UDim2.new(0, 50, 0, 32), UDim2.new(1, -55, 0, 20), default, colorPickerContainer, 4)
        
        -- Create color picker popup (hidden initially)
        local pickerPopup = Instance.new("Frame")
        pickerPopup.Name = "PickerPopup"
        pickerPopup.Size = UDim2.new(0, 200, 0, 240)
        pickerPopup.Position = UDim2.new(1, 5, 0, 0)
        pickerPopup.BackgroundColor3 = BillsLib.Theme.Secondary
        pickerPopup.BorderSizePixel = 0
        pickerPopup.ZIndex = 100
        pickerPopup.Visible = false
        pickerPopup.Parent = colorButton
        
        local popupCorner = Instance.new("UICorner")
        popupCorner.CornerRadius = UDim.new(0, 6)
        popupCorner.Parent = pickerPopup
        
        -- Add shadow to popup
        BillsLib:AddShadow(pickerPopup, 0.5, 15)
        
        -- Color preview
        local colorPreview = BillsLib:CreateRoundFrame("ColorPreview", UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 10), default, pickerPopup, 4)
        colorPreview.ZIndex = 101
        
        -- Color grid (saturation/value)
        local colorGrid = BillsLib:CreateRoundFrame("ColorGrid", UDim2.new(1, -20, 0, 100), UDim2.new(0, 10, 0, 60), Color3.fromRGB(255, 0, 0), pickerPopup, 4)
        colorGrid.ZIndex = 101
        
        -- Color grid gradient (white to transparent)
        local whiteGradient = Instance.new("UIGradient")
        whiteGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        }
        whiteGradient.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        }
        whiteGradient.Rotation = 90
        whiteGradient.Parent = colorGrid
        
        -- Color grid gradient (black to transparent)
        local blackGradient = Instance.new("UIGradient")
        blackGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
        }
        blackGradient.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        }
        blackGradient.Rotation = 0
        blackGradient.Parent = colorGrid
        
        -- Color grid selector
        local gridSelector = Instance.new("Frame")
        gridSelector.Name = "GridSelector"
        gridSelector.Size = UDim2.new(0, 10, 0, 10)
        gridSelector.Position = UDim2.new(1, -15, 0, 5)
        gridSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        gridSelector.BorderSizePixel = 1
        gridSelector.BorderColor3 = Color3.fromRGB(20, 20, 20)
        gridSelector.ZIndex = 102
        gridSelector.Parent = colorGrid
        
        local gridCorner = Instance.new("UICorner")
        gridCorner.CornerRadius = UDim.new(1, 0) -- Circle
        gridCorner.Parent = gridSelector
        
        -- Hue slider
        local hueSlider = BillsLib:CreateRoundFrame("HueSlider", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 170), Color3.fromRGB(255, 255, 255), pickerPopup, 4)
        hueSlider.ZIndex = 101
        
        -- Hue gradient
        local hueGradient = Instance.new("UIGradient")
        hueGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        }
        hueGradient.Parent = hueSlider
        
        -- Hue selector
        local hueSelector = Instance.new("Frame")
        hueSelector.Name = "HueSelector"
        hueSelector.Size = UDim2.new(0, 5, 1, 0)
        hueSelector.Position = UDim2.new(0, 0, 0, 0)
        hueSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hueSelector.BorderSizePixel = 1
        hueSelector.BorderColor3 = Color3.fromRGB(20, 20, 20)
        hueSelector.ZIndex = 102
        hueSelector.Parent = hueSlider
        
        -- Alpha slider
        local alphaSlider = BillsLib:CreateRoundFrame("AlphaSlider", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 200), Color3.fromRGB(255, 255, 255), pickerPopup, 4)
        alphaSlider.ZIndex = 101
        
        -- Create alpha gradient
        local alphaGradient = Instance.new("UIGradient")
        alphaGradient.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        }
        alphaGradient.Parent = alphaSlider
        
        -- Alpha selector
        local alphaSelector = Instance.new("Frame")
        alphaSelector.Name = "AlphaSelector"
        alphaSelector.Size = UDim2.new(0, 5, 1, 0)
        alphaSelector.Position = UDim2.new(0, 0, 0, 0)
        alphaSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        alphaSelector.BorderSizePixel = 1
        alphaSelector.BorderColor3 = Color3.fromRGB(20, 20, 20)
        
        -- Apply button
        local applyButton = BillsLib:CreateTextButton("ApplyButton", "Apply", UDim2.new(0, 80, 0, 30), UDim2.new(0.5, -40, 1, -35), BillsLib.Theme.Accent, BillsLib.Theme.TextColor, function()
            pickerPopup.Visible = false
        end, pickerPopup, 6)
        applyButton.ZIndex = 101
        
        -- Variables for color state
        local hue, sat, val = Color3.toHSV(default)
        local alpha = 0 -- 0 to 1, 0 being fully opaque
        
        -- Update color preview based on HSV
        local function updateColor()
            local color = Color3.fromHSV(hue, sat, val)
            colorPreview.BackgroundColor3 = color
            colorGrid.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            
            -- Set alpha gradient color
            local colorSequence = ColorSequence.new(color)
            alphaGradient.Color = colorSequence
            
            -- Update selectors
            gridSelector.Position = UDim2.new(sat, -5, 1 - val, -5)
            hueSelector.Position = UDim2.new(hue, -2.5, 0, 0)
            alphaSelector.Position = UDim2.new(alpha, -2.5, 0, 0)
            
            -- Update color button
            colorButton.BackgroundColor3 = color
            
            -- Call callback
            callback(color, alpha)
        end
        
        -- Initial update
        updateColor()
        
        -- Toggle picker popup
        colorButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                pickerPopup.Visible = not pickerPopup.Visible
            end
        end)
        
        -- Color grid interaction
        colorGrid.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local dragging = true
                
                local function updateGridSelection()
                    local relativeX = math.clamp((Mouse.X - colorGrid.AbsolutePosition.X) / colorGrid.AbsoluteSize.X, 0, 1)
                    local relativeY = math.clamp((Mouse.Y - colorGrid.AbsolutePosition.Y) / colorGrid.AbsoluteSize.Y, 0, 1)
                    
                    sat = relativeX
                    val = 1 - relativeY
                    
                    updateColor()
                end
                
                -- Initial update
                updateGridSelection()
                
                -- Update while dragging
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    if dragging then
                        updateGridSelection()
                    else
                        connection:Disconnect()
                    end
                end)
                
                -- Stop dragging
                UserInputService.InputEnded:Connect(function(endInput)
                    if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
            end
        end)
        
        -- Hue slider interaction
        hueSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local dragging = true
                
                local function updateHueSelection()
                    local relativeX = math.clamp((Mouse.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
                    
                    hue = relativeX
                    
                    updateColor()
                end
                
                -- Initial update
                updateHueSelection()
                
                -- Update while dragging
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    if dragging then
                        updateHueSelection()
                    else
                        connection:Disconnect()
                    end
                end)
                
                -- Stop dragging
                UserInputService.InputEnded:Connect(function(endInput)
                    if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
            end
        end)
        
        -- Alpha slider interaction
        alphaSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local dragging = true
                
                local function updateAlphaSelection()
                    local relativeX = math.clamp((Mouse.X - alphaSlider.AbsolutePosition.X) / alphaSlider.AbsoluteSize.X, 0, 1)
                    
                    alpha = relativeX
                    
                    updateColor()
                end
                
                -- Initial update
                updateAlphaSelection()
                
                -- Update while dragging
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    if dragging then
                        updateAlphaSelection()
                    else
                        connection:Disconnect()
                    end
                end)
                
                -- Stop dragging
                UserInputService.InputEnded:Connect(function(endInput)
                    if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
            end
        end)
        
        -- Close picker when clicking elsewhere
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if pickerPopup.Visible then
                    local mousePos = UserInputService:GetMouseLocation()
                    
                    -- Check if click is within picker popup area
                    local popupAbsPos = pickerPopup.AbsolutePosition
                    local popupAbsSize = pickerPopup.AbsoluteSize
                    
                    local inPopup = 
                        mousePos.X >= popupAbsPos.X and 
                        mousePos.X <= popupAbsPos.X + popupAbsSize.X and 
                        mousePos.Y >= popupAbsPos.Y and 
                        mousePos.Y <= popupAbsPos.Y + popupAbsSize.Y
                    
                    -- Check if click is within color button area
                    local buttonAbsPos = colorButton.AbsolutePosition
                    local buttonAbsSize = colorButton.AbsoluteSize
                    
                    local inButton = 
                        mousePos.X >= buttonAbsPos.X and 
                        mousePos.X <= buttonAbsPos.X + buttonAbsSize.X and 
                        mousePos.Y >= buttonAbsPos.Y and 
                        mousePos.Y <= buttonAbsPos.Y + buttonAbsSize.Y
                    
                    if not inPopup and not inButton then
                        pickerPopup.Visible = false
                    end
                end
            end
        end)
        
        -- ColorPicker API
        local colorPickerObj = {}
        colorPickerObj.Instance = colorPickerContainer
        
        function colorPickerObj:SetValue(color, newAlpha)
            if typeof(color) == "Color3" then
                hue, sat, val = Color3.toHSV(color)
                if newAlpha ~= nil then
                    alpha = math.clamp(newAlpha, 0, 1)
                end
                updateColor()
            end
        end
        
        function colorPickerObj:GetValue()
            return Color3.fromHSV(hue, sat, val), alpha
        end
        
        return colorPickerObj
    end
    
    -- AddKeybind
    function sectionObj:AddKeybind(text, default, callback)
        self.ElementCount = self.ElementCount + 1
        default = default or Enum.KeyCode.Unknown
        
        local keybindContainer = Instance.new("Frame")
        keybindContainer.Name = "Keybind_" .. self.ElementCount
        keybindContainer.Size = UDim2.new(1, 0, 0, 32)
        keybindContainer.BackgroundTransparency = 1
        keybindContainer.LayoutOrder = self.ElementCount
        keybindContainer.Parent = self.ContentContainer
        
        local keybindLabel = BillsLib:CreateLabel("KeybindLabel", text, UDim2.new(1, -90, 1, 0), UDim2.new(0, 5, 0, 0), BillsLib.Theme.TextColor, Enum.Font.SourceSans, keybindContainer, 14)
        
        local keybindButton = BillsLib:CreateRoundFrame("KeybindButton", UDim2.new(0, 80, 0, 24), UDim2.new(1, -85, 0.5, -12), BillsLib.Theme.InputBackground, keybindContainer, 4)
        
        local keybindText = BillsLib:CreateLabel("KeybindText", default.Name, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), BillsLib.Theme.TextColor, Enum.Font.SourceSans, keybindButton, 14, Enum.TextXAlignment.Center)
        
        -- State tracking
        local currentKey = default
        local listening = false
        
        -- Update visuals when listening for key
        local function updateListeningState()
            if listening then
                keybindText.Text = "Press a key..."
                CreateTween(keybindButton, 0.2, {BackgroundColor3 = BillsLib.Theme.Accent}):Play()
            else
                keybindText.Text = currentKey.Name
                CreateTween(keybindButton, 0.2, {BackgroundColor3 = BillsLib.Theme.InputBackground}):Play()
            end
        end
        
        -- Handle click to start listening
        keybindButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                listening = true
                updateListeningState()
            end
        end)
        
        -- Listen for key press
        UserInputService.InputBegan:Connect(function(input)
            if listening then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    -- Capture the key
                    currentKey = input.KeyCode
                    listening = false
                    updateListeningState()
                    
                    -- Call callback
                    callback(currentKey)
                end
            elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                -- Key was pressed
                callback(currentKey)
            end
        end)
        
        -- Stop listening if mouse clicked elsewhere
        UserInputService.InputBegan:Connect(function(input)
            if listening and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                -- Check if mouse is outside button
                local mousePos = UserInputService:GetMouseLocation()
                local buttonAbsPos = keybindButton.AbsolutePosition
                local buttonAbsSize = keybindButton.AbsoluteSize
                
                local inButton = 
                    mousePos.X >= buttonAbsPos.X and 
                    mousePos.X <= buttonAbsPos.X + buttonAbsSize.X and 
                    mousePos.Y >= buttonAbsPos.Y and 
                    mousePos.Y <= buttonAbsPos.Y + buttonAbsSize.Y
                
                if not inButton then
                    listening = false
                    updateListeningState()
                end
            end
        end)
        
        -- Keybind API
        local keybindObj = {}
        keybindObj.Instance = keybindContainer
        
        function keybindObj:SetValue(key)
            if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
                currentKey = key
                keybindText.Text = key.Name
                callback(key)
            end
        end
        
        function keybindObj:GetValue()
            return currentKey
        end
        
        return keybindObj
    end
    
    return sectionObj
end

-- Notification system
function BillsLib:Notify(title, message, notifType, duration)
    notifType = notifType or "info"  -- info, success, warning, error
    duration = duration or 3  -- duration in seconds
    
    -- Create notification frame
    local notification = self:CreateRoundFrame("Notification", UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 0, 0), self.Theme.NotificationBackground, self.NotificationContainer, 6)
    notification.Size = UDim2.new(1, 0, 0, 0)  -- Start with 0 height for animation
    notification.ClipsDescendants = true
    notification.ZIndex = 1000
    
    -- Add shadow
    self:AddShadow(notification, 0.3, 15)
    
    -- Calculate required height based on text
    local messageLines = #string.split(message, "\n")
    local requiredHeight = 40 + (messageLines * 18)
    
    -- Set notification type color
    local typeColor
    local iconId
    
    if notifType == "success" then
        typeColor = self.Theme.Success
        iconId = self.Icons.Notification.Success
    elseif notifType == "warning" then
        typeColor = self.Theme.Warning
        iconId = self.Icons.Notification.Warning
    elseif notifType == "error" then
        typeColor = self.Theme.Error
        iconId = self.Icons.Notification.Error
    else
        typeColor = self.Theme.Info
        iconId = self.Icons.Notification.Info
    end
    
    -- Notification header with color
    local header = self:CreateRoundFrame("Header", UDim2.new(1, 0, 0, 4), UDim2.new(0, 0, 0, 0), typeColor, notification, 0)
    header.ZIndex = 1001
    
    -- Notification icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 10, 0, 14)
    icon.BackgroundTransparency = 1
    icon.Image = iconId
    icon.ZIndex = 1001
    icon.Parent = notification
    
    -- Notification title
    local titleLabel = self:CreateLabel("Title", title, UDim2.new(1, -50, 0, 20), UDim2.new(0, 40, 0, 14), self.Theme.TextColor, Enum.Font.SourceSansBold, notification, 15)
    titleLabel.ZIndex = 1001
    
    -- Notification message
    local messageLabel = self:CreateLabel("Message", message, UDim2.new(1, -20, 0, 20 + (messageLines * 18)), UDim2.new(0, 10, 0, 34), self.Theme.TextColor, Enum.Font.SourceSans, notification, 14, Enum.TextXAlignment.Left, Enum.TextYAlignment.Top)
    messageLabel.TextWrapped = true
    messageLabel.ZIndex = 1001
    
    -- Close button
    local closeButton = self:CreateTextButton("CloseButton", "✕", UDim2.new(0, 24, 0, 24), UDim2.new(1, -30, 0, 12), self.Theme.NotificationBackground, self.Theme.TextColor, function()
        -- Remove notification
        self:RemoveNotification(notification)
    end, notification, 4)
    closeButton.ZIndex = 1001
    
    -- Animation - Appear
    notification.Size = UDim2.new(1, 0, 0, 0)
    CreateTween(notification, 0.3, {Size = UDim2.new(1, 0, 0, requiredHeight)}):Play()
    
    -- Add to notifications table
    table.insert(self.Notifications, notification)
    
    -- Set the layout order
    notification.LayoutOrder = #self.Notifications
    
    -- Auto-dismiss after duration
    spawn(function()
        wait(duration)
        if notification and notification.Parent then
            self:RemoveNotification(notification)
        end
    end)
    
    return notification
end

-- Remove notification
function BillsLib:RemoveNotification(notification)
    -- Animation - Disappear
    local disappearTween = CreateTween(notification, 0.3, {Size = UDim2.new(1, 0, 0, 0)})
    
    disappearTween.Completed:Connect(function()
        -- Find and remove from notifications table
        for i, notif in pairs(self.Notifications) do
            if notif == notification then
                table.remove(self.Notifications, i)
                break
            end
        end
        
        -- Destroy the notification
        notification:Destroy()
        
        -- Update layout orders
        for i, notif in pairs(self.Notifications) do
            notif.LayoutOrder = i
        end
    end)
    
    disappearTween:Play()
end

-- Set theme
function BillsLib:SetTheme(theme)
    -- Merge theme with default
    for key, value in pairs(theme) do
        if self.Theme[key] ~= nil then
            self.Theme[key] = value
        end
    end
    
    -- Update all UI elements to new theme
    -- This would require tracking all created elements and updating them
    -- For simplicity we're just covering the basics
    
    -- Update notification container
    for _, notification in pairs(self.Notifications) do
        notification.BackgroundColor3 = self.Theme.NotificationBackground
    end
    
    -- Update all windows
    for _, window in pairs(self.Windows) do
        if window.Instance then
            -- Main window
            window.Instance.BackgroundColor3 = self.Theme.Primary
            
            -- Title bar
            local titleBar = window.Instance:FindFirstChild("TitleBar")
            if titleBar then
                titleBar.BackgroundColor3 = self.Theme.Secondary
            end
            
            -- Tab container
            local tabContainer = window.Instance:FindFirstChild("TabContainer")
            if tabContainer then
                tabContainer.BackgroundColor3 = self.Theme.Secondary
            end
            
            -- Content container
            local contentContainer = window.Instance:FindFirstChild("ContentContainer")
            if contentContainer then
                contentContainer.BackgroundColor3 = self.Theme.Secondary
            end
            
            -- Update tabs
            for _, tabButton in pairs(window.TabButtons) do
                if tabButton then
                    if window.ActiveTab == tabButton.Name:sub(5) then
                        tabButton.BackgroundColor3 = self.Theme.TabBackgroundSelected
                    else
                        tabButton.BackgroundColor3 = self.Theme.TabBackground
                    end
                end
            end
        end
    end
end

-- Set toggle key
function BillsLib:SetToggleKey(key)
    if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
        self.ToggleKey = key
    end
end

-- Toggle UI visibility
function BillsLib:ToggleUIVisibility()
    if self.ScreenGui then
        self.ScreenGui.Enabled = not self.ScreenGui.Enabled
    end
end

-- Toggle key listener
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == BillsLib.ToggleKey then
        BillsLib:ToggleUIVisibility()
    end
end)

-- Return the library
return BillsLib
