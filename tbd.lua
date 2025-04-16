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
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")
local TextService = game:GetService("TextService")

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
    local titleBarCorner = titleBar:FindFirstChild("UICorner")
    titleBarCorner.CornerRadius = UDim.new(0, 8)
    
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
    local titleText = self:CreateLabel("Title", title, UDim2.new(1, -100, 1, 0), UDim2.new(0, 15, 0, 0), self.Theme.TextColor, Enum.Font.SourceSansBold, titleBar, 16)
    
    -- Close button
    local closeButton = self:CreateTextButton("CloseButton", "✕", UDim2.new(0, 30, 0, 30), UDim2.new(1, -40, 0, 5), self.Theme.Secondary, self.Theme.TextColor, function()
        window:Destroy()
        table.remove(self.Windows, table.find(self.Windows, window))
        
        -- Clean up all objects
        for _, obj in pairs(self.Objects) do
            if obj.Instance and obj.Instance:IsA("Instance") and obj.Window == window then
                pcall(function() obj.Instance:Destroy() end)
            end
        end
    end, titleBar, 6)
    
    -- Style close button on hover
    closeButton.MouseEnter:Connect(function()
        CreateTween(closeButton, 0.2, {BackgroundColor3 = self.Theme.Error}):Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        CreateTween(closeButton, 0.2, {BackgroundColor3 = self.Theme.Secondary}):Play()
    end)
    
    -- Minimize button
    local minimizeButton = self:CreateTextButton("MinimizeButton", "–", UDim2.new(0, 30, 0, 30), UDim2.new(1, -80, 0, 5), self.Theme.Secondary, self.Theme.TextColor, function()
        if window.Size == windowSize then
            CreateTween(window, 0.3, {Size = UDim2.new(windowSize.X.Scale, windowSize.X.Offset, 0, 40)}):Play()
        else
            CreateTween(window, 0.3, {Size = windowSize}):Play()
        end
    end, titleBar, 6)
    
    -- Style minimize button on hover
    minimizeButton.MouseEnter:Connect(function()
        CreateTween(minimizeButton, 0.2, {BackgroundColor3 = self.Theme.Secondary:Lerp(Color3.fromRGB(255, 255, 255), 0.2)}):Play()
    end)
    
    minimizeButton.MouseLeave:Connect(function()
        CreateTween(minimizeButton, 0.2, {BackgroundColor3 = self.Theme.Secondary}):Play()
    end)
    
    -- Container for tabs
    local tabContainer = self:CreateRoundFrame("TabContainer", UDim2.new(0, 120, 1, -50), UDim2.new(0, 10, 0, 50), self.Theme.Secondary, window, 6)
    tabContainer.ZIndex = 11
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.Padding = UDim.new(0, 5)
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Parent = tabContainer
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 10)
    tabPadding.PaddingBottom = UDim.new(0, 10)
    tabPadding.PaddingLeft = UDim.new(0, 10)
    tabPadding.PaddingRight = UDim.new(0, 10)
    tabPadding.Parent = tabContainer
    
    -- Content container
    local contentContainer = self:CreateRoundFrame("ContentContainer", UDim2.new(1, -150, 1, -50), UDim2.new(0, 140, 0, 50), self.Theme.Secondary, window, 6)
    contentContainer.ZIndex = 11
    
    -- Initialize Dashboard (Home tab)
    local dashboardTab, dashboardPage = self:CreateTab(window, tabContainer, contentContainer, "Dashboard", 1)
    
    -- Dashboard content
    local avatarContainer = self:CreateRoundFrame("AvatarContainer", UDim2.new(0, 80, 0, 80), UDim2.new(0, 20, 0, 20), self.Theme.Primary, dashboardPage, 40)
    avatarContainer.ClipsDescendants = true
    
    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Name = "AvatarImage"
    avatarImage.BackgroundTransparency = 1
    avatarImage.Size = UDim2.new(1, 0, 1, 0)
    avatarImage.Position = UDim2.new(0, 0, 0, 0)
    avatarImage.Parent = avatarContainer
    
    -- Load player avatar
    local userId = Player.UserId
    local thumbnailType = Enum.ThumbnailType.HeadShot
    local thumbnailSize = Enum.ThumbnailSize.Size420x420
    
    local success, avatar = pcall(function()
        return Players:GetUserThumbnailAsync(userId, thumbnailType, thumbnailSize)
    end)
    
    if success and avatar then
        avatarImage.Image = avatar
    else
        avatarImage.Image = "rbxassetid://7962146544" -- Default avatar
    end
    
    -- Player info
    local playerNameLabel = self:CreateLabel("PlayerName", Player.DisplayName, UDim2.new(0, 200, 0, 20), UDim2.new(0, 120, 0, 30), self.Theme.TextColor, Enum.Font.SourceSansBold, dashboardPage, 18)
    
    local playerUsernameLabel = self:CreateLabel("PlayerUsername", "@" .. Player.Name, UDim2.new(0, 200, 0, 20), UDim2.new(0, 120, 0, 55), self.Theme.PlaceholderColor, Enum.Font.SourceSans, dashboardPage, 14)
    
    -- Divider
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(1, -40, 0, 1)
    divider.Position = UDim2.new(0, 20, 0, 120)
    divider.BackgroundColor3 = self.Theme.DividerColor
    divider.BorderSizePixel = 0
    divider.Parent = dashboardPage
    
    -- Game info
    local gameInfoContainer = self:CreateRoundFrame("GameInfoContainer", UDim2.new(1, -40, 0, 80), UDim2.new(0, 20, 0, 140), self.Theme.Primary, dashboardPage, 6)
    
    -- Load game info
    local gameNameLabel = self:CreateLabel("GameName", "Loading...", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 10), self.Theme.TextColor, Enum.Font.SourceSansBold, gameInfoContainer, 16)
    
    local playersLabel = self:CreateLabel("PlayersInfo", "Players: Loading...", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 40), self.Theme.TextColor, Enum.Font.SourceSans, gameInfoContainer, 14)
    
    -- Get place name asynchronously
    spawn(function()
        local success, gameInfo = pcall(function()
            return MarketplaceService:GetProductInfo(game.PlaceId)
        end)
        
        if success and gameInfo then
            gameNameLabel.Text = gameInfo.Name
        else
            gameNameLabel.Text = "Game Info Unavailable"
        end
        
        -- Set player count
        playersLabel.Text = "Players: " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers
    end)
    
    -- Create window metatable
    local windowObj = {}
    windowObj.Instance = window
    windowObj.Tabs = {Dashboard = dashboardPage}
    windowObj.TabButtons = {Dashboard = dashboardTab}
    windowObj.ActiveTab = "Dashboard"
    windowObj.TabCount = 1
    
    -- AddTab method
    function windowObj:AddTab(name)
        local tab, page = BillsLib:CreateTab(self.Instance, tabContainer, contentContainer, name, self.TabCount + 1)
        self.Tabs[name] = page
        self.TabButtons[name] = tab
        self.TabCount = self.TabCount + 1
        return page
    end
    
    -- SetActiveTab method
    function windowObj:SetActiveTab(name)
        if self.Tabs[name] then
            -- Hide all tabs
            for tabName, tabPage in pairs(self.Tabs) do
                tabPage.Visible = false
                CreateTween(self.TabButtons[tabName], 0.2, {BackgroundColor3 = BillsLib.Theme.TabBackground}):Play()
            end
            
            -- Show selected tab
            self.Tabs[name].Visible = true
            CreateTween(self.TabButtons[name], 0.2, {BackgroundColor3 = BillsLib.Theme.TabBackgroundSelected}):Play()
            self.ActiveTab = name
        end
    end
    
    -- Initialize first tab as visible
    windowObj:SetActiveTab("Dashboard")
    
    -- Add to windows table
    table.insert(self.Windows, windowObj)
    
    return windowObj
end

-- Create tab method
function BillsLib:CreateTab(window, tabContainer, contentContainer, name, order)
    -- Tab button
    local tabButton = self:CreateRoundFrame("Tab_" .. name, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, ((order - 1) * 35)), self.Theme.TabBackground, tabContainer, 6)
    tabButton.ZIndex = 12
    
    local tabText = self:CreateLabel("TabText", name, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), self.Theme.TextColor, Enum.Font.SourceSansSemibold, tabButton, 14, Enum.TextXAlignment.Center)
    
    -- Content page
    local contentPage = self:CreateRoundFrame("Page_" .. name, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), self.Theme.Secondary, contentContainer, 6)
    contentPage.ZIndex = 12
    contentPage.BackgroundTransparency = 1
    contentPage.Visible = false
    
    -- Scroll frame for content
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.Position = UDim2.new(0, 0, 0, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = self.Theme.Accent
    scrollFrame.BorderSizePixel = 0
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = contentPage
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.Parent = scrollFrame
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.Parent = scrollFrame
    
    -- Update canvas size when content changes
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Add click event to tab button
    tabButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            -- Find parent window object
            for _, windowObj in pairs(self.Windows) do
                if windowObj.Instance == window then
                    windowObj:SetActiveTab(name)
                    break
                end
            end
        end
    end)
    
    return tabButton, contentPage
end

-- Create section
function BillsLib:CreateSection(tab, title)
    local sectionContainer = self:CreateRoundFrame("Section_" .. title, UDim2.new(1, -20, 0, 36), UDim2.new(0, 0, 0, 0), self.Theme.SectionBackground, tab:FindFirstChild("ScrollFrame"), 6)
    sectionContainer.ZIndex = 13
    sectionContainer.ClipsDescendants = true
    sectionContainer.AutomaticSize = Enum.AutomaticSize.Y
    
    -- Section title
    local sectionTitle = self:CreateLabel("SectionTitle", title, UDim2.new(1, -40, 0, 30), UDim2.new(0, 15, 0, 0), self.Theme.TextColor, Enum.Font.SourceSansBold, sectionContainer, 15)
    
    -- Expand/collapse button
    local expandButton = self:CreateTextButton("ExpandButton", "▼", UDim2.new(0, 20, 0, 20), UDim2.new(1, -30, 0, 5), self.Theme.SectionBackground, self.Theme.TextColor, function()
        -- Toggle section content visibility
        local contentContainer = sectionContainer:FindFirstChild("ContentContainer")
        local isExpanded = contentContainer.Visible
        
        if isExpanded then
            -- Collapse
            contentContainer.Visible = false
            expandButton.Text = "▶"
            CreateTween(sectionContainer, 0.3, {Size = UDim2.new(1, -20, 0, 36)}):Play()
        else
            -- Expand
            contentContainer.Visible = true
            expandButton.Text = "▼"
            
            -- Calculate required height
            local contentLayout = contentContainer:FindFirstChildOfClass("UIListLayout")
            local requiredHeight = contentLayout.AbsoluteContentSize.Y + 46 -- 36 + 10 padding
            
            CreateTween(sectionContainer, 0.3, {Size = UDim2.new(1, -20, 0, requiredHeight)}):Play()
        end
    end, sectionContainer, 4)
    
    -- Content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -20, 1, -36)
    contentContainer.Position = UDim2.new(0, 10, 0, 36)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = sectionContainer
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = contentContainer
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 0)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 0)
    contentPadding.PaddingRight = UDim.new(0, 0)
    contentPadding.Parent = contentContainer
    
    -- Update section height when content changes
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if contentContainer.Visible then
            local requiredHeight = contentLayout.AbsoluteContentSize.Y + 46 -- 36 + 10 padding
            sectionContainer.Size = UDim2.new(1, -20, 0, requiredHeight)
        end
    end)
    
    -- Initialize expanded
    contentContainer.Visible = true
    expandButton.Text = "▼"
    
    -- Section functions
    local sectionObj = {}
    sectionObj.Instance = sectionContainer
    sectionObj.ContentContainer = contentContainer
    sectionObj.ElementCount = 0
    
    -- AddLabel
    function sectionObj:AddLabel(text)
        self.ElementCount = self.ElementCount + 1
        
        local labelContainer = Instance.new("Frame")
        labelContainer.Name = "Label_" .. self.ElementCount
        labelContainer.Size = UDim2.new(1, 0, 0, 25)
        labelContainer.BackgroundTransparency = 1
        labelContainer.LayoutOrder = self.ElementCount
        labelContainer.Parent = self.ContentContainer
        
        local labelText = BillsLib:CreateLabel("LabelText", text, UDim2.new(1, 0, 1, 0), UDim2.new(0, 5, 0, 0), BillsLib.Theme.TextColor, Enum.Font.SourceSans, labelContainer, 14)
        
        return labelText
    end
    
    -- AddButton
    function sectionObj:AddButton(text, callback)
        self.ElementCount = self.ElementCount + 1
        
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Name = "Button_" .. self.ElementCount
        buttonContainer.Size = UDim2.new(1, 0, 0, 32)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.LayoutOrder = self.ElementCount
        buttonContainer.Parent = self.ContentContainer
        
        local button = BillsLib:CreateTextButton("Button", text, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), BillsLib.Theme.Accent, BillsLib.Theme.TextColor, callback, buttonContainer, 6)
        
        local buttonObj = {}
        buttonObj.Instance = button
        
        function buttonObj:SetText(newText)
            button.Text = newText
        end
        
        function buttonObj:SetCallback(newCallback)
            -- Remove old connections
            for _, connection in pairs(getconnections(button.MouseButton1Click)) do
                connection:Disconnect()
            end
            
            -- Add new callback
            button.MouseButton1Click:Connect(newCallback)
        end
        
        return buttonObj
    end
    
    -- AddToggle
    function sectionObj:AddToggle(text, default, callback)
        self.ElementCount = self.ElementCount + 1
        
        local toggleContainer = Instance.new("Frame")
        toggleContainer.Name = "Toggle_" .. self.ElementCount
        toggleContainer.Size = UDim2.new(1, 0, 0, 32)
        toggleContainer.BackgroundTransparency = 1
        toggleContainer.LayoutOrder = self.ElementCount
        toggleContainer.Parent = self.ContentContainer
        
        local toggleLabel = BillsLib:CreateLabel("ToggleLabel", text, UDim2.new(1, -50, 1, 0), UDim2.new(0, 5, 0, 0), BillsLib.Theme.TextColor, Enum.Font.SourceSans, toggleContainer, 14)
        
        local toggleButton = BillsLib:CreateRoundFrame("ToggleButton", UDim2.new(0, 40, 0, 20), UDim2.new(1, -45, 0.5, -10), BillsLib.Theme.ToggleBackground, toggleContainer, 10)
        
        local toggleCircle = BillsLib:CreateRoundFrame("ToggleCircle", UDim2.new(0, 16, 0, 16), UDim2.new(0, 2, 0.5, -8), BillsLib.Theme.TextColor, toggleButton, 8)
        
        local toggleState = default or false
        
        -- Set initial state
        if toggleState then
            toggleCircle.Position = UDim2.new(1, -18, 0.5, -8)
            toggleButton.BackgroundColor3 = BillsLib.Theme.ToggleFill
        end
        
        -- Toggle interaction
        toggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                toggleState = not toggleState
                
                -- Animate position
                if toggleState then
                    CreateTween(toggleCircle, 0.2, {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
                    CreateTween(toggleButton, 0.2, {BackgroundColor3 = BillsLib.Theme.ToggleFill}):Play()
                else
                    CreateTween(toggleCircle, 0.2, {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
                    CreateTween(toggleButton, 0.2, {BackgroundColor3 = BillsLib.Theme.ToggleBackground}):Play()
                end
                
                -- Call callback
                callback(toggleState)
            end
        end)
        
        -- Toggle API
        local toggleObj = {}
        toggleObj.Instance = toggleContainer
        toggleObj.Value = toggleState
        
        function toggleObj:SetValue(value)
            if value ~= toggleState then
                toggleState = value
                toggleObj.Value = value
                
                -- Update visuals
                if toggleState then
                    toggleCircle.Position = UDim2.new(1, -18, 0.5, -8)
                    toggleButton.BackgroundColor3 = BillsLib.Theme.ToggleFill
                else
                    toggleCircle.Position = UDim2.new(0, 2, 0.5, -8)
                    toggleButton.BackgroundColor3 = BillsLib.Theme.ToggleBackground
                end
                
                -- Call callback
                callback(toggleState)
            end
        end
        
        function toggleObj:GetValue()
            return toggleState
        end
        
        return toggleObj
    end
    
    -- AddSlider
    function sectionObj:AddSlider(text, min, max, default, decimals, callback)
        self.ElementCount = self.ElementCount + 1
        decimals = decimals or 0
        
        local sliderContainer = Instance.new("Frame")
        sliderContainer.Name = "Slider_" .. self.ElementCount
        sliderContainer.Size = UDim2.new(1, 0, 0, 50)
        sliderContainer.BackgroundTransparency = 1
        sliderContainer.LayoutOrder = self.ElementCount
        sliderContainer.Parent = self.ContentContainer
        
        local sliderLabel = BillsLib:CreateLabel("SliderLabel", text, UDim2.new(1, -50, 0, 20), UDim2.new(0, 5, 0, 0), BillsLib.Theme.TextColor, Enum.Font.SourceSans, sliderContainer, 14)
        
        local sliderValueLabel = BillsLib:CreateLabel("SliderValue", tostring(default), UDim2.new(0, 40, 0, 20), UDim2.new(1, -45, 0, 0), BillsLib.Theme.TextColor, Enum.Font.SourceSans, sliderContainer, 14, Enum.TextXAlignment.Right)
        
        local sliderTrack = BillsLib:CreateRoundFrame("SliderTrack", UDim2.new(1, -10, 0, 6), UDim2.new(0, 5, 0, 30), BillsLib.Theme.SliderBackground, sliderContainer, 3)
        
        local sliderFill = BillsLib:CreateRoundFrame("SliderFill", UDim2.new(0, 0, 1, 0), UDim2.new(0, 0, 0, 0), BillsLib.Theme.SliderFill, sliderTrack, 3)
        
        local sliderButton = BillsLib:CreateRoundFrame("SliderButton", UDim2.new(0, 14, 0, 14), UDim2.new(0, -7, 0.5, -7), BillsLib.Theme.Accent, sliderFill, 7)
        
        -- Calculate initial fill based on default value
        local range = max - min
        local initialFillRatio = (default - min) / range
        sliderFill.Size = UDim2.new(initialFillRatio, 0, 1, 0)
        
        -- Set initial value
        local value = default
        sliderValueLabel.Text = tostring(RoundNumber(value, decimals))
        
        -- Slider interaction
        local dragging = false
        
        -- Mouse down
        sliderTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                
                -- Update on initial click
                local relativePos = input.Position.X - sliderTrack.AbsolutePosition.X
                local percent = math.clamp(relativePos / sliderTrack.AbsoluteSize.X, 0, 1)
                
                -- Update fill
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                
                -- Calculate value
                local newValue = min + (range * percent)
                value = RoundNumber(newValue, decimals)
                sliderValueLabel.Text = tostring(value)
                
                -- Call callback
                callback(value)
            end
        end)
        
        -- Mouse up
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        -- Mouse move
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local relativePos = input.Position.X - sliderTrack.AbsolutePosition.X
                local percent = math.clamp(relativePos / sliderTrack.AbsoluteSize.X, 0, 1)
                
                -- Update fill
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                
                -- Calculate value
                local newValue = min + (range * percent)
                value = RoundNumber(newValue, decimals)
                sliderValueLabel.Text = tostring(value)
                
                -- Call callback
                callback(value)
            end
        end)
        
        -- Slider API
        local sliderObj = {}
        sliderObj.Instance = sliderContainer
        sliderObj.Value = value
        
        function sliderObj:SetValue(newValue)
            -- Clamp and round
            newValue = math.clamp(newValue, min, max)
            value = RoundNumber(newValue, decimals)
            sliderObj.Value = value
            
            -- Update visual
            local percent = (value - min) / range
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            sliderValueLabel.Text = tostring(value)
            
            -- Call callback
            callback(value)
        end
        
        function sliderObj:GetValue()
            return value
        end
        
        return sliderObj
    end
    
    -- AddDropdown
    function sectionObj:AddDropdown(text, options, default, callback)
        self.ElementCount = self.ElementCount + 1
        
        local dropdownContainer = Instance.new("Frame")
        dropdownContainer.Name = "Dropdown_" .. self.ElementCount
        dropdownContainer.Size = UDim2.new(1, 0, 0, 60)
        dropdownContainer.BackgroundTransparency = 1
        dropdownContainer.LayoutOrder = self.ElementCount
        dropdownContainer.Parent = self.ContentContainer
        
        local dropdownLabel = BillsLib:CreateLabel("DropdownLabel", text, UDim2.new(1, 0, 0, 20), UDim2.new(0, 5, 0, 0), BillsLib.Theme.TextColor, Enum.Font.SourceSans, dropdownContainer, 14)
        
        local dropdownButton = BillsLib:CreateRoundFrame("DropdownButton", UDim2.new(1, -10, 0, 32), UDim2.new(0, 5, 0, 25), BillsLib.Theme.InputBackground, dropdownContainer, 6)
        
        -- Add dropdown icon
        local dropdownIcon = Instance.new("ImageLabel")
        dropdownIcon.Name = "DropdownIcon"
        dropdownIcon.Size = UDim2.new(0, 16, 0, 16)
        dropdownIcon.Position = UDim2.new(1, -30, 0.5, -8)
        dropdownIcon.BackgroundTransparency = 1
        dropdownIcon.Image = BillsLib.Icons.Dropdown
        dropdownIcon.ImageColor3 = BillsLib.Theme.Accent
        dropdownIcon.ZIndex = 12
        dropdownIcon.Parent = dropdownButton
        
        -- Add glow effect to button
        local dropdownGlow = Instance.new("ImageLabel")
        dropdownGlow.Name = "DropdownGlow"
        dropdownGlow.Size = UDim2.new(1, 10, 1, 10)
        dropdownGlow.Position = UDim2.new(0, -5, 0, -5)
        dropdownGlow.BackgroundTransparency = 1
        dropdownGlow.Image = "rbxassetid://4996891970" -- Glow asset
        dropdownGlow.ImageColor3 = BillsLib.Theme.Accent
        dropdownGlow.ImageTransparency = 0.9
        dropdownGlow.ScaleType = Enum.ScaleType.Slice
        dropdownGlow.SliceCenter = Rect.new(20, 20, 280, 280)
        dropdownGlow.ZIndex = 11
        dropdownGlow.Parent = dropdownButton
        
        -- Gradient for button
        local dropdownGradient = Instance.new("UIGradient")
        dropdownGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, BillsLib.Theme.InputBackground),
            ColorSequenceKeypoint.new(1, BillsLib.Theme.InputBackground:Lerp(BillsLib.Theme.Accent, 0.1))
        })
        dropdownGradient.Rotation = 90
        dropdownGradient.Parent = dropdownButton
        
        local selectedText = default or "Select an option"
        local dropdownText = BillsLib:CreateLabel("DropdownText", selectedText, UDim2.new(1, -40, 1, 0), UDim2.new(0, 10, 0, 0), BillsLib.Theme.TextColor, Enum.Font.SourceSans, dropdownButton, 14)
        dropdownText.ZIndex = 12
        
        -- Create overlay for the entire UI to catch outside clicks (helping with Z-index issues)
        local dropdownOverlay = Instance.new("Frame")
        dropdownOverlay.Name = "DropdownOverlay"
        dropdownOverlay.Size = UDim2.new(1, 0, 1, 0)
        dropdownOverlay.Position = UDim2.new(0, 0, 0, 0)
        dropdownOverlay.BackgroundTransparency = 1
        dropdownOverlay.Visible = false
        dropdownOverlay.ZIndex = 998 -- Very high z-index to be above everything except dropdown
        dropdownOverlay.Active = true -- Required to capture input
        
        -- Ensure the overlay is a direct child of the ScreenGui to cover everything
        local screenGui = BillsLib.ScreenGui
        if screenGui then
            dropdownOverlay.Parent = screenGui
        end
        
        -- Options menu
        local optionsMenu = Instance.new("Frame")
        optionsMenu.Name = "OptionsMenu"
        optionsMenu.Size = UDim2.new(1, 0, 0, 0)
        optionsMenu.Position = UDim2.new(0, 0, 1, 5)
        optionsMenu.BackgroundColor3 = BillsLib.Theme.DropdownBackground
        optionsMenu.BorderSizePixel = 0
        optionsMenu.Visible = false
        optionsMenu.ZIndex = 999 -- Higher than everything
        optionsMenu.Parent = dropdownButton
        
        local optionsCorner = Instance.new("UICorner")
        optionsCorner.CornerRadius = UDim.new(0, 6)
        optionsCorner.Parent = optionsMenu
        
        -- Add neon border to options menu
        local optionsBorder = Instance.new("UIStroke")
        optionsBorder.Color = BillsLib.Theme.Accent
        optionsBorder.Thickness = 1.5
        optionsBorder.Transparency = 0.5
        optionsBorder.Parent = optionsMenu
        
        local optionsLayout = Instance.new("UIListLayout")
        optionsLayout.Padding = UDim.new(0, 2)
        optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        optionsLayout.Parent = optionsMenu
        
        local optionsPadding = Instance.new("UIPadding")
        optionsPadding.PaddingTop = UDim.new(0, 5)
        optionsPadding.PaddingBottom = UDim.new(0, 5)
        optionsPadding.PaddingLeft = UDim.new(0, 5)
        optionsPadding.PaddingRight = UDim.new(0, 5)
        optionsPadding.Parent = optionsMenu
        
        -- Selected value
        local selectedOption = default or nil
        
        -- Populate options
        local function populateOptions(optionsList)
            -- Clear existing options
            for _, child in pairs(optionsMenu:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            -- Add new options
            for i, option in ipairs(optionsList) do
                local optionButton = Instance.new("TextButton")
                optionButton.Name = "Option_" .. i
                optionButton.Size = UDim2.new(1, -10, 0, 30)
                optionButton.BackgroundColor3 = BillsLib.Theme.DropdownBackground
                optionButton.BackgroundTransparency = 0.5
                optionButton.Text = option
                optionButton.TextColor3 = BillsLib.Theme.TextColor
                optionButton.Font = Enum.Font.SourceSans
                optionButton.TextSize = 14
                optionButton.TextXAlignment = Enum.TextXAlignment.Left
                optionButton.BorderSizePixel = 0
                optionButton.ZIndex = 1000 -- Higher than everything
                optionButton.Parent = optionsMenu
                
                -- Highlight if this is the selected option
                if option == selectedOption then
                    optionButton.BackgroundColor3 = BillsLib.Theme.Accent
                    optionButton.BackgroundTransparency = 0.7
                end
                
                -- Corner
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 4)
                corner.Parent = optionButton
                
                -- Option selection
                optionButton.MouseButton1Click:Connect(function()
                    selectedOption = option
                    if dropdownText then
                        dropdownText.Text = option
                    end
                    
                    -- Hide menu and overlay
                    optionsMenu.Visible = false
                    dropdownOverlay.Visible = false
                    
                    -- Call callback
                    callback(option)
                end)
                
                -- Hover effect
                optionButton.MouseEnter:Connect(function()
                    if option ~= selectedOption then
                        CreateTween(optionButton, 0.2, {BackgroundTransparency = 0.3}):Play()
                    end
                end)
                
                optionButton.MouseLeave:Connect(function()
                    if option ~= selectedOption then
                        CreateTween(optionButton, 0.2, {BackgroundTransparency = 0.5}):Play()
                    else
                        CreateTween(optionButton, 0.2, {BackgroundTransparency = 0.7}):Play()
                    end
                end)
            end
            
            -- Update menu size based on content
            optionsMenu.Size = UDim2.new(1, 0, 0, math.min(200, optionsLayout.AbsoluteContentSize.Y + 10))
        end
        
        -- Initial population
        populateOptions(options)
        
        -- Toggle dropdown
        dropdownButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                -- Toggle menu and overlay
                local isVisible = not optionsMenu.Visible
                optionsMenu.Visible = isVisible
                dropdownOverlay.Visible = isVisible
                
                -- Update button appearance
                if isVisible then
                    -- Rotate dropdown icon
                    CreateTween(dropdownIcon, 0.3, {Rotation = 180}):Play()
                    
                    -- Make glow more visible
                    CreateTween(dropdownGlow, 0.3, {ImageTransparency = 0.7}):Play()
                    
                    -- Position menu properly - check if it needs to go up instead of down
                    local absolutePosition = dropdownButton.AbsolutePosition
                    local screenSize = Camera.ViewportSize
                    
                    -- Convert optionsMenu size to absolute pixels
                    local menuHeight = optionsMenu.AbsoluteSize.Y
                    
                    -- Check if menu would extend below screen
                    if (absolutePosition.Y + dropdownButton.AbsoluteSize.Y + menuHeight) > screenSize.Y then
                        -- Position above button
                        optionsMenu.Position = UDim2.new(0, 0, 0, -menuHeight - 5)
                    else
                        -- Position below button
                        optionsMenu.Position = UDim2.new(0, 0, 1, 5)
                    end
                else
                    -- Reset dropdown icon
                    CreateTween(dropdownIcon, 0.3, {Rotation = 0}):Play()
                    
                    -- Reset glow
                    CreateTween(dropdownGlow, 0.3, {ImageTransparency = 0.9}):Play()
                end
            end
        end)
        
        -- Handle clicking outside the dropdown to close it
        dropdownOverlay.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                optionsMenu.Visible = false
                dropdownOverlay.Visible = false
                CreateTween(dropdownIcon, 0.3, {Rotation = 0}):Play()
                CreateTween(dropdownGlow, 0.3, {ImageTransparency = 0.9}):Play()
            end
        end)
        
        -- Dropdown API
        local dropdownObj = {}
        dropdownObj.Instance = dropdownContainer
        dropdownObj.Options = options
        dropdownObj.Value = selectedOption
        
        function dropdownObj:SetOptions(newOptions)
            self.Options = newOptions
            populateOptions(newOptions)
            
            -- If the previously selected option is no longer available, reset
            local optionExists = false
            for _, option in ipairs(newOptions) do
                if option == selectedOption then
                    optionExists = true
                    break
                end
            end
            
            if not optionExists and #newOptions > 0 then
                selectedOption = newOptions[1]
                if dropdownText then
                    dropdownText.Text = selectedOption
                end
                self.Value = selectedOption
                callback(selectedOption)
            elseif not optionExists then
                selectedOption = nil
                if dropdownText then
                    dropdownText.Text = "Select an option"
                end
                self.Value = nil
            end
        end
        
        function dropdownObj:SetValue(option)
            -- Check if option exists
            local optionExists = false
            for _, opt in ipairs(self.Options) do
                if opt == option then
                    optionExists = true
                    break
                end
            end
            
            if optionExists then
                selectedOption = option
                if dropdownText then
                    dropdownText.Text = option
                end
                self.Value = option
                
                -- Update option buttons
                for _, child in pairs(optionsMenu:GetChildren()) do
                    if child:IsA("TextButton") then
                        if child.Text == option then
                            child.BackgroundColor3 = BillsLib.Theme.Accent
                            child.BackgroundTransparency = 0.7
                        else
                            child.BackgroundColor3 = BillsLib.Theme.DropdownBackground
                            child.BackgroundTransparency = 0.5
                        end
                    end
                end
                
                callback(option)
            end
        end
        
        function dropdownObj:GetValue()
            return selectedOption
        end
        
        return dropdownObj
    end
    
    -- AddTextbox
    function sectionObj:AddTextbox(text, default, callback)
        self.ElementCount = self.ElementCount + 1
        
        local textboxContainer = Instance.new("Frame")
        textboxContainer.Name = "Textbox_" .. self.ElementCount
        textboxContainer.Size = UDim2.new(1, 0, 0, 60)
        textboxContainer.BackgroundTransparency = 1
        textboxContainer.LayoutOrder = self.ElementCount
        textboxContainer.Parent = self.ContentContainer
        
        local textboxLabel = BillsLib:CreateLabel("TextboxLabel", text, UDim2.new(1, 0, 0, 20), UDim2.new(0, 5, 0, 0), BillsLib.Theme.TextColor, Enum.Font.SourceSans, textboxContainer, 14)
        
        local textboxFrame = BillsLib:CreateRoundFrame("TextboxFrame", UDim2.new(1, -10, 0, 32), UDim2.new(0, 5, 0, 25), BillsLib.Theme.InputBackground, textboxContainer, 6)
        
        local textbox = Instance.new("TextBox")
        textbox.Name = "Textbox"
        textbox.Size = UDim2.new(1, -20, 1, 0)
        textbox.Position = UDim2.new(0, 10, 0, 0)
        textbox.BackgroundTransparency = 1
        textbox.Text = default or ""
        textbox.PlaceholderText = "Enter text..."
        textbox.PlaceholderColor3 = BillsLib.Theme.PlaceholderColor
        textbox.TextColor3 = BillsLib.Theme.TextColor
        textbox.Font = Enum.Font.SourceSans
        textbox.TextSize = 14
        textbox.TextXAlignment = Enum.TextXAlignment.Left
        textbox.ClearTextOnFocus = false
        textbox.Parent = textboxFrame
        
        -- Focus outline
        textbox.Focused:Connect(function()
            CreateTween(textboxFrame, 0.2, {BackgroundColor3 = BillsLib.Theme.Accent:Lerp(BillsLib.Theme.InputBackground, 0.5)}):Play()
        end)
        
        textbox.FocusLost:Connect(function(enterPressed)
            CreateTween(textboxFrame, 0.2, {BackgroundColor3 = BillsLib.Theme.InputBackground}):Play()
            callback(textbox.Text, enterPressed)
        end)
        
        -- Textbox API
        local textboxObj = {}
        textboxObj.Instance = textboxContainer
        
        function textboxObj:SetValue(value)
            textbox.Text = value or ""
        end
        
        function textboxObj:GetValue()
            return textbox.Text
        end
        
        return textboxObj
    end
    
    -- AddColorPicker
    function sectionObj:AddColorPicker(text, default, callback)
        self.ElementCount = self.ElementCount + 1
        default = default or Color3.fromRGB(255, 0, 0)
        
        local colorPickerContainer = Instance.new("Frame")
        colorPickerContainer.Name = "ColorPicker_" .. self.ElementCount
        colorPickerContainer.Size = UDim2.new(1, 0, 0, 60)
        colorPickerContainer.BackgroundTransparency = 1
        colorPickerContainer.LayoutOrder = self.ElementCount
        colorPickerContainer.Parent = self.ContentContainer
        
        local colorLabel = BillsLib:CreateLabel("ColorLabel", text, UDim2.new(1, -50, 0, 20), UDim2.new(0, 5, 0, 0), BillsLib.Theme.TextColor, Enum.Font.SourceSans, colorPickerContainer, 14)
        
        local colorPreview = BillsLib:CreateRoundFrame("ColorPreview", UDim2.new(0, 30, 0, 20), UDim2.new(1, -40, 0, 0), default, colorPickerContainer, 4)
        
        local colorButton = BillsLib:CreateRoundFrame("ColorButton", UDim2.new(1, -10, 0, 32), UDim2.new(0, 5, 0, 25), BillsLib.Theme.InputBackground, colorPickerContainer, 6)
        
        -- Color picker popup
        local pickerPopup = BillsLib:CreateRoundFrame("PickerPopup", UDim2.new(0, 200, 0, 230), UDim2.new(0.5, -100, 0, -240), BillsLib.Theme.Secondary, colorPickerContainer, 6)
        pickerPopup.Visible = false
        pickerPopup.ZIndex = 100
        
        -- Add shadow to popup
        BillsLib:AddShadow(pickerPopup, 0.5, 20)
        
        -- Color grid (hue/saturation)
        local colorGrid = Instance.new("ImageLabel")
        colorGrid.Name = "ColorGrid"
        colorGrid.Size = UDim2.new(1, -20, 0, 150)
        colorGrid.Position = UDim2.new(0, 10, 0, 10)
        colorGrid.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        colorGrid.BorderSizePixel = 0
        colorGrid.Image = "rbxassetid://4155801252" -- Saturation/brightness gradient
        colorGrid.ZIndex = 101
        colorGrid.Parent = pickerPopup
        
        local colorGridCorner = Instance.new("UICorner")
        colorGridCorner.CornerRadius = UDim.new(0, 4)
        colorGridCorner.Parent = colorGrid
        
        -- Hue slider
        local hueSlider = BillsLib:CreateRoundFrame("HueSlider", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 170), Color3.fromRGB(255, 255, 255), pickerPopup, 4)
        hueSlider.ZIndex = 101
        
        local hueGradient = Instance.new("UIGradient")
        hueGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        })
        hueGradient.Parent = hueSlider
        
        -- Alpha slider
        local alphaSlider = BillsLib:CreateRoundFrame("AlphaSlider", UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 200), Color3.fromRGB(255, 255, 255), pickerPopup, 4)
        alphaSlider.ZIndex = 101
        
        local alphaGradient = Instance.new("UIGradient")
        alphaGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        alphaGradient.Parent = alphaSlider
        
        -- Grid selector
        local gridSelector = BillsLib:CreateRoundFrame("GridSelector", UDim2.new(0, 10, 0, 10), UDim2.new(0, 0, 0, 0), Color3.fromRGB(255, 255, 255), colorGrid, 5)
        gridSelector.ZIndex = 102
        gridSelector.BorderSizePixel = 1
        gridSelector.BorderColor3 = Color3.fromRGB(20, 20, 20)
        
        -- Hue selector
        local hueSelector = BillsLib:CreateRoundFrame("HueSelector", UDim2.new(0, 5, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(255, 255, 255), hueSlider, 2)
        hueSelector.ZIndex = 102
        hueSelector.BorderSizePixel = 1
        hueSelector.BorderColor3 = Color3.fromRGB(20, 20, 20)
        
        -- Alpha selector
        local alphaSelector = BillsLib:CreateRoundFrame("AlphaSelector", UDim2.new(0, 5, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(255, 255, 255), alphaSlider, 2)
        alphaSelector.ZIndex = 102
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
            alphaGradient.Color = ColorSequence.new(color)
            
            -- Update selectors
            gridSelector.Position = UDim2.new(sat, -5, 1 - val, -5)
            hueSelector.Position = UDim2.new(hue, -2.5, 0, 0)
            alphaSelector.Position = UDim2.new(alpha, -2.5, 0, 0)
            
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
    local messageLines = #message:split("\n")
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
