-- Enhanced Synthwave UI Library
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Library = {
    Elements = {},
    Theme = {
        Primary = Color3.fromRGB(255, 65, 125),
        Secondary = Color3.fromRGB(41, 21, 61),
        Background = Color3.fromRGB(22, 12, 46),
        TextColor = Color3.fromRGB(255, 255, 255),
        AccentColor = Color3.fromRGB(120, 220, 255),
        DarkContrast = Color3.fromRGB(15, 8, 31),
        LightContrast = Color3.fromRGB(33, 17, 52),
        ToggleOn = Color3.fromRGB(255, 65, 125),
        ToggleOff = Color3.fromRGB(41, 21, 61),
        Gradient1 = Color3.fromRGB(255, 0, 255),
        Gradient2 = Color3.fromRGB(0, 255, 255),
        ErrorColor = Color3.fromRGB(255, 0, 0),
        SuccessColor = Color3.fromRGB(0, 255, 0)
    },
    Settings = {
        AnimationDuration = 0.3,
        EasingStyle = Enum.EasingStyle.Quart,
        EasingDirection = Enum.EasingDirection.Out,
        NotificationDuration = 3,
        BlurEffect = true,
        TooltipsEnabled = true,
        SoundEffects = true,
        MinimizeKeybind = Enum.KeyCode.RightControl
    },
    Fonts = {
        Regular = Enum.Font.Gotham,
        Bold = Enum.Font.GothamBold,
        SemiBold = Enum.Font.GothamSemibold,
        Light = Enum.Font.GothamLight
    }
}

-- Utility Functions
local function CreateTween(instance, properties, duration, style, direction)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or Library.Settings.AnimationDuration,
            style or Library.Settings.EasingStyle,
            direction or Library.Settings.EasingDirection
        ),
        properties
    )
    return tween
end

local function CreateElement(elementType, properties)
    local element = Instance.new(elementType)
    for property, value in pairs(properties) do
        element[property] = value
    end
    return element
end

-- Enhanced Notification System
function Library:CreateNotification(title, text, notificationType, duration)
    local NotificationGui = CreateElement("ScreenGui", {
        Name = "EnhancedNotification",
        Parent = CoreGui
    })
    
    local NotificationFrame = CreateElement("Frame", {
        Name = "NotificationFrame",
        BackgroundColor3 = Library.Theme.Background,
        Position = UDim2.new(1, 20, 0.8, 0),
        Size = UDim2.new(0, 300, 0, 100),
        Parent = NotificationGui
    })
    
    -- Add gradient and glow effect
    local UIGradient = CreateElement("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library.Theme.Gradient1),
            ColorSequenceKeypoint.new(1, Library.Theme.Gradient2)
        }),
        Rotation = 45,
        Parent = NotificationFrame
    })
    
    local UIStroke = CreateElement("UIStroke", {
        Color = notificationType == "error" and Library.Theme.ErrorColor or 
                notificationType == "success" and Library.Theme.SuccessColor or
                Library.Theme.Primary,
        Thickness = 2,
        Parent = NotificationFrame
    })
    
    local Corner = CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = NotificationFrame
    })
    
    -- Icon based on notification type
    local Icon = CreateElement("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 24, 0, 24),
        Image = notificationType == "error" and "rbxassetid://6031071057" or
                notificationType == "success" and "rbxassetid://6031071053" or
                "rbxassetid://6031071050",
        Parent = NotificationFrame
    })
    
    local TitleLabel = CreateElement("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 44, 0, 10),
        Size = UDim2.new(1, -54, 0, 24),
        Font = Library.Fonts.Bold,
        Text = title,
        TextColor3 = Library.Theme.TextColor,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = NotificationFrame
    })
    
    local TextLabel = CreateElement("TextLabel", {
        Name = "Text",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 44),
        Size = UDim2.new(1, -20, 0, 46),
        Font = Library.Fonts.Regular,
        Text = text,
        TextColor3 = Library.Theme.TextColor,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = NotificationFrame
    })
    
    -- Progress bar
    local ProgressBar = CreateElement("Frame", {
        Name = "ProgressBar",
        BackgroundColor3 = Library.Theme.Primary,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = NotificationFrame
    })
    
    -- Animations
    local appearTween = CreateTween(NotificationFrame, {
        Position = UDim2.new(1, -320, 0.8, 0)
    })
    
    local disappearTween = CreateTween(NotificationFrame, {
        Position = UDim2.new(1, 20, 0.8, 0)
    })
    
    local progressTween = CreateTween(ProgressBar, {
        Size = UDim2.new(0, 0, 0, 2)
    }, duration or Library.Settings.NotificationDuration)
    
    -- Play sound effect if enabled
    if Library.Settings.SoundEffects then
        local sound = Instance.new("Sound")
        sound.SoundId = notificationType == "error" and "rbxassetid://6031071076" or
                       notificationType == "success" and "rbxassetid://6031071073" or
                       "rbxassetid://6031071070"
        sound.Volume = 0.5
        sound.Parent = NotificationFrame
        sound:Play()
    end
    
    appearTween:Play()
    progressTween:Play()
    
    task.delay(duration or Library.Settings.NotificationDuration, function()
        disappearTween:Play()
        disappearTween.Completed:Connect(function()
            NotificationGui:Destroy()
        end)
    end)
end

-- Enhanced Window Creation with Homepage
function Library:CreateWindow(title, config)
    config = config or {}
    
    local Window = {
        Tabs = {},
        TabCount = 0,
        Toggled = true,
        CurrentTab = nil
    }
    
    -- Main GUI Elements with Blur Effect
    local ScreenGui = CreateElement("ScreenGui", {
        Name = "EnhancedSynthwaveUI",
        Parent = CoreGui
    })
    
    if Library.Settings.BlurEffect then
        local blur = Instance.new("BlurEffect")
        blur.Size = 0
        blur.Parent = game:GetService("Lighting")
        
        CreateTween(blur, {Size = 10}):Play()
        
        ScreenGui:GetPropertyChangedSignal("Parent"):Connect(function()
            if not ScreenGui.Parent then
                CreateTween(blur, {Size = 0}):Play()
                game:GetService("Debris"):AddItem(blur, 0.5)
            end
        end)
    end
    
    -- Main Frame with enhanced design
    local MainFrame = CreateElement("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = Library.Theme.Background,
        Position = UDim2.new(0.5, -400, 0.5, -250),
        Size = UDim2.new(0, 800, 0, 500),
        Parent = ScreenGui
    })
    
    -- Continue with the rest of the window creation...
    -- I'll provide the continuation in the next part due to length limits
    local MainCorner = CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = MainFrame
    })
    
    -- Add gradient and glow effects
    local MainGradient = CreateElement("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library.Theme.Background),
            ColorSequenceKeypoint.new(1, Library.Theme.DarkContrast)
        }),
        Rotation = 45,
        Parent = MainFrame
    })
    
    local GlowEffect = CreateElement("ImageLabel", {
        Name = "Glow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        ZIndex = 0,
        Image = "rbxassetid://5028857084",
        ImageColor3 = Library.Theme.Primary,
        ImageTransparency = 0.6,
        Parent = MainFrame
    })
    
    -- Top Bar with enhanced design
    local TopBar = CreateElement("Frame", {
        Name = "TopBar",
        BackgroundColor3 = Library.Theme.Secondary,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = MainFrame
    })
    
    local TopBarCorner = CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = TopBar
    })
    
    local TopBarGradient = CreateElement("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library.Theme.Secondary),
            ColorSequenceKeypoint.new(1, Library.Theme.DarkContrast)
        }),
        Rotation = 90,
        Parent = TopBar
    })
    
    -- Title with icon
    local TitleContainer = CreateElement("Frame", {
        Name = "TitleContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Parent = TopBar
    })
    
    local Icon = CreateElement("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, -15),
        Size = UDim2.new(0, 30, 0, 30),
        Image = config.icon or "rbxassetid://6031280882",
        Parent = TitleContainer
    })
    
    local TitleLabel = CreateElement("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 40, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Font = Library.Fonts.Bold,
        Text = title,
        TextColor3 = Library.Theme.TextColor,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleContainer
    })
    
    -- Window Controls
    local Controls = CreateElement("Frame", {
        Name = "Controls",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -100, 0, 0),
        Size = UDim2.new(0, 90, 1, 0),
        Parent = TopBar
    })
    
    local MinimizeButton = CreateElement("ImageButton", {
        Name = "Minimize",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0.5, -15),
        Size = UDim2.new(0, 30, 0, 30),
        Image = "rbxassetid://6031082533",
        Parent = Controls
    })
    
    local CloseButton = CreateElement("ImageButton", {
        Name = "Close",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0.5, -15),
        Size = UDim2.new(0, 30, 0, 30),
        Image = "rbxassetid://6031094678",
        Parent = Controls
    })
    
    -- Homepage/Dashboard
    local HomePage = CreateElement("ScrollingFrame", {
        Name = "HomePage",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 50),
        Size = UDim2.new(1, -160, 1, -60),
        ScrollBarThickness = 3,
        Visible = true,
        Parent = MainFrame
    })
    
    -- Player Info Section
    local PlayerSection = CreateElement("Frame", {
        Name = "PlayerSection",
        BackgroundColor3 = Library.Theme.LightContrast,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -20, 0, 150),
        Parent = HomePage
    })
    
    local PlayerSectionCorner = CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = PlayerSection
    })
    
    local PlayerAvatar = CreateElement("ImageLabel", {
        Name = "Avatar",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 130, 0, 130),
        Image = Players.LocalPlayer.UserId and 
            ("rbxthumb://type=AvatarHeadShot&id=" .. Players.LocalPlayer.UserId .. "&w=420&h=420") 
            or "",
        Parent = PlayerSection
    })
    
    local PlayerAvatarCorner = CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 65),
        Parent = PlayerAvatar
    })
    
    local PlayerInfo = CreateElement("Frame", {
        Name = "Info",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 10),
        Size = UDim2.new(1, -160, 1, -20),
        Parent = PlayerSection
    })
    
    -- Player Stats
    local stats = {
        {"Username", Players.LocalPlayer.Name},
        {"Display Name", Players.LocalPlayer.DisplayName},
        {"Account Age", Players.LocalPlayer.AccountAge .. " days"},
        {"User ID", Players.LocalPlayer.UserId}
    }
    
    for i, stat in ipairs(stats) do
        local StatLabel = CreateElement("TextLabel", {
            Name = stat[1],
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, (i-1) * 30),
            Size = UDim2.new(1, 0, 0, 25),
            Font = Library.Fonts.Regular,
            Text = stat[1] .. ": " .. stat[2],
            TextColor3 = Library.Theme.TextColor,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = PlayerInfo
        })
    end
    
    -- Game Info Section
    local GameSection = CreateElement("Frame", {
        Name = "GameSection",
        BackgroundColor3 = Library.Theme.LightContrast,
        Position = UDim2.new(0, 10, 0, 170),
        Size = UDim2.new(1, -20, 0, 150),
        Parent = HomePage
    })
    
    local GameSectionCorner = CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = GameSection
    })
    
    -- Game Stats
    local gameInfo = {
        {"Game", game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name},
        {"Place ID", game.PlaceId},
        {"Job ID", game.JobId},
        {"Server Age", os.date("!%X", os.time() - game:GetService("Stats").ServerStatsItem["Server"]["Time"]:GetValue())},
        {"Players", #Players:GetPlayers() .. "/" .. Players.MaxPlayers}
    }
    
    for i, info in ipairs(gameInfo) do
        local InfoLabel = CreateElement("TextLabel", {
            Name = info[1],
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, (i-1) * 30 + 10),
            Size = UDim2.new(1, -20, 0, 25),
            Font = Library.Fonts.Regular,
            Text = info[1] .. ": " .. info[2],
            TextColor3 = Library.Theme.TextColor,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = GameSection
        })
    end
    -- Performance Stats Section
    local PerformanceSection = CreateElement("Frame", {
        Name = "PerformanceSection",
        BackgroundColor3 = Library.Theme.LightContrast,
        Position = UDim2.new(0, 10, 0, 330),
        Size = UDim2.new(1, -20, 0, 120),
        Parent = HomePage
    })
    
    local PerformanceSectionCorner = CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = PerformanceSection
    })
    
    -- FPS Counter
    local FPSLabel = CreateElement("TextLabel", {
        Name = "FPS",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0.5, -20, 0, 25),
        Font = Library.Fonts.Regular,
        Text = "FPS: Calculating...",
        TextColor3 = Library.Theme.TextColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = PerformanceSection
    })
    
    -- Ping Counter
    local PingLabel = CreateElement("TextLabel", {
        Name = "Ping",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 10, 0, 10),
        Size = UDim2.new(0.5, -20, 0, 25),
        Font = Library.Fonts.Regular,
        Text = "Ping: Calculating...",
        TextColor3 = Library.Theme.TextColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = PerformanceSection
    })
    
    -- Memory Usage
    local MemoryLabel = CreateElement("TextLabel", {
        Name = "Memory",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 45),
        Size = UDim2.new(1, -20, 0, 25),
        Font = Library.Fonts.Regular,
        Text = "Memory Usage: Calculating...",
        TextColor3 = Library.Theme.TextColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = PerformanceSection
    })
    
    -- Performance Monitoring
    local lastTick = tick()
    local frameCount = 0
    local fps = 60
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        local delta = now - lastTick
        
        if delta >= 1 then
            fps = math.floor(frameCount / delta)
            frameCount = 0
            lastTick = now
            
            -- Update performance stats
            FPSLabel.Text = "FPS: " .. fps
            PingLabel.Text = "Ping: " .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms"
            MemoryLabel.Text = "Memory Usage: " .. math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb()) .. "MB"
        end
    end)
    
    -- Tab Container with enhanced design
    local TabContainer = CreateElement("Frame", {
        Name = "TabContainer",
        BackgroundColor3 = Library.Theme.DarkContrast,
        Position = UDim2.new(0, 5, 0, 45),
        Size = UDim2.new(0, 140, 1, -50),
        Parent = MainFrame
    })
    
    local TabContainerCorner = CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = TabContainer
    })
    
    local TabContainerGradient = CreateElement("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library.Theme.DarkContrast),
            ColorSequenceKeypoint.new(1, Library.Theme.Secondary)
        }),
        Rotation = 90,
        Parent = TabContainer
    })
    
    local TabList = CreateElement("ScrollingFrame", {
        Name = "TabList",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 2,
        Parent = TabContainer
    })
    
    local TabListLayout = CreateElement("UIListLayout", {
        Padding = UDim.new(0, 5),
        Parent = TabList
    })
    
    local TabListPadding = CreateElement("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        Parent = TabList
    })
    
    -- Content Container
    local ContentContainer = CreateElement("Frame", {
        Name = "ContentContainer",
        BackgroundColor3 = Library.Theme.DarkContrast,
        Position = UDim2.new(0, 150, 0, 45),
        Size = UDim2.new(1, -155, 1, -50),
        Parent = MainFrame
    })
    
    local ContentContainerCorner = CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = ContentContainer
    })
    
    -- Enhanced Tab Creation Function
    function Window:CreateTab(name, icon)
        local Tab = {
            Elements = {},
            Containers = {},
            Sections = {}
        }
        
        Window.TabCount = Window.TabCount + 1
        
        -- Tab Button with Icon
        local TabButton = CreateElement("TextButton", {
            Name = name,
            BackgroundColor3 = Library.Theme.LightContrast,
            Size = UDim2.new(1, 0, 0, 32),
            Font = Library.Fonts.Regular,
            Text = "",
            TextColor3 = Library.Theme.TextColor,
            TextSize = 14,
            AutoButtonColor = false,
            Parent = TabList
        })
        
        local TabButtonCorner = CreateElement("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = TabButton
        })
        
        local TabButtonPadding = CreateElement("UIPadding", {
            PaddingLeft = UDim.new(0, 30),
            Parent = TabButton
        })
        
        local TabIcon = CreateElement("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, -25, 0.5, -10),
            Size = UDim2.new(0, 20, 0, 20),
            Image = icon or "rbxassetid://6034509993",
            Parent = TabButton
        })
        
        local TabLabel = CreateElement("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Library.Fonts.Regular,
            Text = name,
            TextColor3 = Library.Theme.TextColor,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton
        })
        -- Tab Content
        local TabContent = CreateElement("ScrollingFrame", {
            Name = name .. "Content",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 5, 0, 5),
            Size = UDim2.new(1, -10, 1, -10),
            ScrollBarThickness = 2,
            Visible = false,
            Parent = ContentContainer
        })
        
        local ContentLayout = CreateElement("UIListLayout", {
            Padding = UDim.new(0, 6),
            Parent = TabContent
        })
        
        local ContentPadding = CreateElement("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
            Parent = TabContent
        })
        
        -- Tab Button Animations
        local function UpdateTabVisuals()
            for _, tab in pairs(Window.Tabs) do
                CreateTween(tab.Button, {
                    BackgroundColor3 = tab == Window.CurrentTab and Library.Theme.Primary or Library.Theme.LightContrast
                }):Play()
            end
        end
        
        TabButton.MouseButton1Click:Connect(function()
            if Window.CurrentTab ~= Tab then
                -- Hide current tab content
                if Window.CurrentTab then
                    Window.CurrentTab.Content.Visible = false
                end
                
                -- Show HomePage
                HomePage.Visible = false
                
                -- Show new tab content
                TabContent.Visible = true
                Window.CurrentTab = Tab
                
                -- Update tab visuals
                UpdateTabVisuals()
                
                -- Play click animation
                if Library.Settings.SoundEffects then
                    local sound = Instance.new("Sound")
                    sound.SoundId = "rbxassetid://6026984224"
                    sound.Volume = 0.5
                    sound.Parent = TabButton
                    sound:Play()
                    game:GetService("Debris"):AddItem(sound, 1)
                end
            end
        end)
        
        -- Section Creation Function
        function Tab:CreateSection(name)
            local Section = {
                Elements = {}
            }
            
            local SectionFrame = CreateElement("Frame", {
                Name = name .. "Section",
                BackgroundColor3 = Library.Theme.Secondary,
                Size = UDim2.new(1, 0, 0, 36),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = TabContent
            })
            
            local SectionCorner = CreateElement("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = SectionFrame
            })
            
            local SectionHeader = CreateElement("Frame", {
                Name = "Header",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 36),
                Parent = SectionFrame
            })
            
            local SectionName = CreateElement("TextLabel", {
                Name = "Name",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = Library.Fonts.SemiBold,
                Text = name,
                TextColor3 = Library.Theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionHeader
            })
            
            local SectionContent = CreateElement("Frame", {
                Name = "Content",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 36),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SectionFrame
            })
            
            local SectionLayout = CreateElement("UIListLayout", {
                Padding = UDim.new(0, 5),
                Parent = SectionContent
            })
            
            local SectionPadding = CreateElement("UIPadding", {
                PaddingBottom = UDim.new(0, 5),
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5),
                Parent = SectionContent
            })
            
            -- Enhanced Button Creation
            function Section:AddButton(name, callback)
                local Button = CreateElement("TextButton", {
                    Name = name,
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Size = UDim2.new(1, 0, 0, 32),
                    Font = Library.Fonts.Regular,
                    Text = "",
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    AutoButtonColor = false,
                    Parent = SectionContent
                })
                
                local ButtonCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = Button
                })
                
                local ButtonLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 1, 0),
                    Font = Library.Fonts.Regular,
                    Text = name,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    Parent = Button
                })
                
                -- Button Effects
                local ButtonStroke = CreateElement("UIStroke", {
                    Color = Library.Theme.Primary,
                    Transparency = 0.5,
                    Parent = Button
                })
                
                Button.MouseEnter:Connect(function()
                    CreateTween(Button, {
                        BackgroundColor3 = Library.Theme.Primary
                    }):Play()
                end)
                
                Button.MouseLeave:Connect(function()
                    CreateTween(Button, {
                        BackgroundColor3 = Library.Theme.LightContrast
                    }):Play()
                end)
                
                Button.MouseButton1Down:Connect(function()
                    CreateTween(Button, {
                        BackgroundColor3 = Library.Theme.DarkContrast
                    }):Play()
                end)
                
                Button.MouseButton1Up:Connect(function()
                    CreateTween(Button, {
                        BackgroundColor3 = Library.Theme.Primary
                    }):Play()
                end)
                
                Button.MouseButton1Click:Connect(function()
                    if Library.Settings.SoundEffects then
                        local sound = Instance.new("Sound")
                        sound.SoundId = "rbxassetid://6026984224"
                        sound.Volume = 0.5
                        sound.Parent = Button
                        sound:Play()
                        game:GetService("Debris"):AddItem(sound, 1)
                    end
                    
                    callback()
                end)
                
                return Button
            end
            -- Enhanced Toggle Creation
            function Section:AddToggle(name, default, callback)
                local Toggle = {
                    Value = default or false,
                    Type = "Toggle"
                }
                
                local ToggleFrame = CreateElement("Frame", {
                    Name = name,
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Size = UDim2.new(1, 0, 0, 32),
                    Parent = SectionContent
                })
                
                local ToggleCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = ToggleFrame
                })
                
                local ToggleLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Library.Fonts.Regular,
                    Text = name,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ToggleFrame
                })
                
                local ToggleButton = CreateElement("Frame", {
                    Name = "Button",
                    BackgroundColor3 = Toggle.Value and Library.Theme.Primary or Library.Theme.DarkContrast,
                    Position = UDim2.new(1, -42, 0.5, -10),
                    Size = UDim2.new(0, 32, 0, 20),
                    Parent = ToggleFrame
                })
                
                local ToggleButtonCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleButton
                })
                
                local ToggleCircle = CreateElement("Frame", {
                    Name = "Circle",
                    BackgroundColor3 = Library.Theme.TextColor,
                    Position = Toggle.Value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    Parent = ToggleButton
                })
                
                local ToggleCircleCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleCircle
                })
                
                -- Toggle Functionality
                local function UpdateToggle()
                    CreateTween(ToggleCircle, {
                        Position = Toggle.Value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                    }):Play()
                    
                    CreateTween(ToggleButton, {
                        BackgroundColor3 = Toggle.Value and Library.Theme.Primary or Library.Theme.DarkContrast
                    }):Play()
                    
                    if Library.Settings.SoundEffects then
                        local sound = Instance.new("Sound")
                        sound.SoundId = Toggle.Value and "rbxassetid://6026984224" or "rbxassetid://6026984224"
                        sound.Volume = 0.5
                        sound.Parent = ToggleFrame
                        sound:Play()
                        game:GetService("Debris"):AddItem(sound, 1)
                    end
                    
                    callback(Toggle.Value)
                end
                
                ToggleFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Toggle.Value = not Toggle.Value
                        UpdateToggle()
                    end
                end)
                
                -- Toggle Methods
                function Toggle:Set(value)
                    Toggle.Value = value
                    UpdateToggle()
                end
                
                return Toggle
            end
            
            -- Enhanced Slider Creation
            function Section:AddSlider(name, options)
                local Slider = {
                    Value = options.default or options.min,
                    Min = options.min or 0,
                    Max = options.max or 100,
                    Decimals = options.decimals or 0,
                    Type = "Slider"
                }
                
                local SliderFrame = CreateElement("Frame", {
                    Name = name,
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Size = UDim2.new(1, 0, 0, 50),
                    Parent = SectionContent
                })
                
                local SliderCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = SliderFrame
                })
                
                local SliderLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 0, 30),
                    Font = Library.Fonts.Regular,
                    Text = name,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SliderFrame
                })
                
                local SliderValue = CreateElement("TextBox", {
                    Name = "Value",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -60, 0, 0),
                    Size = UDim2.new(0, 50, 0, 30),
                    Font = Library.Fonts.Regular,
                    Text = tostring(Slider.Value),
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    Parent = SliderFrame
                })
                
                local SliderBar = CreateElement("Frame", {
                    Name = "Bar",
                    BackgroundColor3 = Library.Theme.DarkContrast,
                    Position = UDim2.new(0, 10, 0, 35),
                    Size = UDim2.new(1, -20, 0, 4),
                    Parent = SliderFrame
                })
                
                local SliderBarCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderBar
                })
                
                local SliderFill = CreateElement("Frame", {
                    Name = "Fill",
                    BackgroundColor3 = Library.Theme.Primary,
                    Size = UDim2.new((Slider.Value - Slider.Min)/(Slider.Max - Slider.Min), 0, 1, 0),
                    Parent = SliderBar
                })
                
                local SliderFillCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderFill
                })
                -- Slider Functionality
                local function UpdateSlider(value)
                    value = math.clamp(value, Slider.Min, Slider.Max)
                    if Slider.Decimals > 0 then
                        Slider.Value = math.floor(value * (10 ^ Slider.Decimals)) / (10 ^ Slider.Decimals)
                    else
                        Slider.Value = math.floor(value)
                    end
                    
                    SliderValue.Text = tostring(Slider.Value)
                    CreateTween(SliderFill, {
                        Size = UDim2.new((Slider.Value - Slider.Min)/(Slider.Max - Slider.Min), 0, 1, 0)
                    }):Play()
                    
                    if options.callback then
                        options.callback(Slider.Value)
                    end
                end
                
                local dragging = false
                
                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local position = input.Position.X - SliderBar.AbsolutePosition.X
                        local size = SliderBar.AbsoluteSize.X
                        local percent = math.clamp(position / size, 0, 1)
                        UpdateSlider(Slider.Min + ((Slider.Max - Slider.Min) * percent))
                    end
                end)
                
                SliderValue.FocusLost:Connect(function()
                    local num = tonumber(SliderValue.Text)
                    if num then
                        UpdateSlider(num)
                    else
                        SliderValue.Text = tostring(Slider.Value)
                    end
                end)
                
                -- Slider Methods
                function Slider:Set(value)
                    UpdateSlider(value)
                end
                
                return Slider
            end
            
            -- Enhanced Dropdown Creation
            function Section:AddDropdown(name, options)
                local Dropdown = {
                    Value = options.default or options.options[1],
                    Options = options.options,
                    Type = "Dropdown",
                    Open = false
                }
                
                local DropdownFrame = CreateElement("Frame", {
                    Name = name,
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Size = UDim2.new(1, 0, 0, 32),
                    ClipsDescendants = true,
                    Parent = SectionContent
                })
                
                local DropdownCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = DropdownFrame
                })
                
                local DropdownButton = CreateElement("TextButton", {
                    Name = "Button",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    Font = Library.Fonts.Regular,
                    Text = "",
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    Parent = DropdownFrame
                })
                
                local DropdownLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -40, 0, 32),
                    Font = Library.Fonts.Regular,
                    Text = name .. ": " .. tostring(Dropdown.Value),
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownButton
                })
                
                local DropdownIcon = CreateElement("ImageLabel", {
                    Name = "Icon",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -26, 0, 8),
                    Size = UDim2.new(0, 16, 0, 16),
                    Image = "rbxassetid://6031094670",
                    Parent = DropdownButton
                })
                
                local OptionContainer = CreateElement("Frame", {
                    Name = "Options",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 32),
                    Size = UDim2.new(1, 0, 0, #Dropdown.Options * 32),
                    Parent = DropdownFrame
                })
                
                local OptionList = CreateElement("UIListLayout", {
                    Parent = OptionContainer
                })
                
                -- Create Option Buttons
                for _, option in ipairs(Dropdown.Options) do
                    local OptionButton = CreateElement("TextButton", {
                        Name = option,
                        BackgroundColor3 = Library.Theme.DarkContrast,
                        Size = UDim2.new(1, 0, 0, 32),
                        Font = Library.Fonts.Regular,
                        Text = option,
                        TextColor3 = Library.Theme.TextColor,
                        TextSize = 14,
                        Parent = OptionContainer
                    })
                    
                    local OptionButtonCorner = CreateElement("UICorner", {
                        CornerRadius = UDim.new(0, 6),
                        Parent = OptionButton
                    })
                    
                    OptionButton.MouseEnter:Connect(function()
                        CreateTween(OptionButton, {
                            BackgroundColor3 = Library.Theme.Primary
                        }):Play()
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        CreateTween(OptionButton, {
                            BackgroundColor3 = Library.Theme.DarkContrast
                        }):Play()
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        Dropdown.Value = option
                        DropdownLabel.Text = name .. ": " .. option
                        
                        CreateTween(DropdownFrame, {
                            Size = UDim2.new(1, 0, 0, 32)
                        }):Play()
                        
                        CreateTween(DropdownIcon, {
                            Rotation = 0
                        }):Play()
                        
                        Dropdown.Open = false
                        
                        if options.callback then
                            options.callback(option)
                        end
                    end)
                end
                -- Dropdown Toggle Function
                DropdownButton.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    
                    CreateTween(DropdownFrame, {
                        Size = UDim2.new(1, 0, 0, Dropdown.Open and (32 + (#Dropdown.Options * 32)) or 32)
                    }):Play()
                    
                    CreateTween(DropdownIcon, {
                        Rotation = Dropdown.Open and 180 or 0
                    }):Play()
                    
                    if Library.Settings.SoundEffects then
                        local sound = Instance.new("Sound")
                        sound.SoundId = "rbxassetid://6026984224"
                        sound.Volume = 0.5
                        sound.Parent = DropdownButton
                        sound:Play()
                        game:GetService("Debris"):AddItem(sound, 1)
                    end
                end)
                
                -- Dropdown Methods
                function Dropdown:Set(value)
                    if table.find(Dropdown.Options, value) then
                        Dropdown.Value = value
                        DropdownLabel.Text = name .. ": " .. value
                        
                        if options.callback then
                            options.callback(value)
                        end
                    end
                end
                
                function Dropdown:Refresh(newOptions, keepValue)
                    Dropdown.Options = newOptions
                    if not keepValue then
                        Dropdown.Value = newOptions[1]
                    end
                    
                    -- Clear existing options
                    for _, child in pairs(OptionContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Recreate option buttons
                    for _, option in ipairs(newOptions) do
                        local OptionButton = CreateElement("TextButton", {
                            Name = option,
                            BackgroundColor3 = Library.Theme.DarkContrast,
                            Size = UDim2.new(1, 0, 0, 32),
                            Font = Library.Fonts.Regular,
                            Text = option,
                            TextColor3 = Library.Theme.TextColor,
                            TextSize = 14,
                            Parent = OptionContainer
                        })
                        
                        local OptionButtonCorner = CreateElement("UICorner", {
                            CornerRadius = UDim.new(0, 6),
                            Parent = OptionButton
                        })
                        
                        -- Option button functionality
                        OptionButton.MouseEnter:Connect(function()
                            CreateTween(OptionButton, {
                                BackgroundColor3 = Library.Theme.Primary
                            }):Play()
                        end)
                        
                        OptionButton.MouseLeave:Connect(function()
                            CreateTween(OptionButton, {
                                BackgroundColor3 = Library.Theme.DarkContrast
                            }):Play()
                        end)
                        
                        OptionButton.MouseButton1Click:Connect(function()
                            Dropdown:Set(option)
                            CreateTween(DropdownFrame, {
                                Size = UDim2.new(1, 0, 0, 32)
                            }):Play()
                            Dropdown.Open = false
                        end)
                    end
                    
                    DropdownLabel.Text = name .. ": " .. Dropdown.Value
                end
                
                return Dropdown
            end
            
            -- Enhanced Colorpicker Creation
            function Section:AddColorPicker(name, options)
                local ColorPicker = {
                    Value = options.default or Color3.fromRGB(255, 255, 255),
                    Type = "ColorPicker",
                    Open = false
                }
                
                local ColorPickerFrame = CreateElement("Frame", {
                    Name = name,
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Size = UDim2.new(1, 0, 0, 32),
                    ClipsDescendants = true,
                    Parent = SectionContent
                })
                
                local ColorPickerCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = ColorPickerFrame
                })
                
                local ColorPickerButton = CreateElement("TextButton", {
                    Name = "Button",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    Text = "",
                    Parent = ColorPickerFrame
                })
                
                local ColorPickerLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -60, 0, 32),
                    Font = Library.Fonts.Regular,
                    Text = name,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ColorPickerButton
                })
                
                local ColorDisplay = CreateElement("Frame", {
                    Name = "Display",
                    BackgroundColor3 = ColorPicker.Value,
                    Position = UDim2.new(1, -50, 0.5, -10),
                    Size = UDim2.new(0, 40, 0, 20),
                    Parent = ColorPickerButton
                })
                
                local ColorDisplayCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ColorDisplay
                })
                
                -- Color Picker Interface
                local ColorPickerInterface = CreateElement("Frame", {
                    Name = "Interface",
                    BackgroundColor3 = Library.Theme.DarkContrast,
                    Position = UDim2.new(0, 0, 0, 32),
                    Size = UDim2.new(1, 0, 0, 130),
                    Parent = ColorPickerFrame
                })
                
                local ColorPickerInterfaceCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = ColorPickerInterface
                })
                
                -- Color Gradient
                local ColorGradient = CreateElement("Frame", {
                    Name = "Gradient",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -20, 0, 80),
                    Parent = ColorPickerInterface
                })
                
                local ColorGradientCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = ColorGradient
                })
                -- Color Gradient UIGradient
                local ColorGradientUIGradient = CreateElement("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, ColorPicker.Value)
                    }),
                    Parent = ColorGradient
                })
                
                local BlackGradient = CreateElement("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                    }),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    }),
                    Rotation = 90,
                    Parent = ColorGradient
                })
                
                -- Color Picker Cursor
                local ColorCursor = CreateElement("Frame", {
                    Name = "Cursor",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0, 10, 0, 10),
                    ZIndex = 2,
                    Parent = ColorGradient
                })
                
                local ColorCursorCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ColorCursor
                })
                
                -- Hue Slider
                local HueSlider = CreateElement("Frame", {
                    Name = "HueSlider",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = UDim2.new(0, 10, 0, 100),
                    Size = UDim2.new(1, -20, 0, 20),
                    Parent = ColorPickerInterface
                })
                
                local HueSliderCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = HueSlider
                })
                
                local HueSliderGradient = CreateElement("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                    }),
                    Parent = HueSlider
                })
                
                -- Hue Slider Cursor
                local HueCursor = CreateElement("Frame", {
                    Name = "Cursor",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.new(0, 6, 1, 6),
                    ZIndex = 2,
                    Parent = HueSlider
                })
                
                local HueCursorCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = HueCursor
                })
                
                -- Color Picker Functions
                local function UpdateColor()
                    ColorDisplay.BackgroundColor3 = ColorPicker.Value
                    ColorGradientUIGradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(ColorPicker.Hue, 1, 1))
                    })
                    
                    if options.callback then
                        options.callback(ColorPicker.Value)
                    end
                end
                
                -- Convert RGB to HSV
                local function RGBtoHSV(color)
                    local r, g, b = color.R, color.G, color.B
                    local max, min = math.max(r, g, b), math.min(r, g, b)
                    local h, s, v
                    v = max
                    
                    local d = max - min
                    if max == 0 then
                        s = 0
                    else
                        s = d/max
                    end
                    
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
                        h = h/6
                    end
                    
                    return h, s, v
                end
                
                -- Initialize color picker
                local h, s, v = RGBtoHSV(ColorPicker.Value)
                ColorPicker.Hue = h
                ColorPicker.Sat = s
                ColorPicker.Val = v
                
                -- Update cursor positions
                ColorCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                HueCursor.Position = UDim2.new(h, 0, 0.5, 0)
                
                -- Dragging functionality
                local draggingColor = false
                local draggingHue = false
                
                ColorGradient.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingColor = true
                    end
                end)
                
                HueSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingHue = true
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingColor = false
                        draggingHue = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if draggingColor then
                            local colorPos = Vector2.new(
                                math.clamp(input.Position.X - ColorGradient.AbsolutePosition.X, 0, ColorGradient.AbsoluteSize.X),
                                math.clamp(input.Position.Y - ColorGradient.AbsolutePosition.Y, 0, ColorGradient.AbsoluteSize.Y)
                            )
                            
                            ColorCursor.Position = UDim2.new(
                                colorPos.X / ColorGradient.AbsoluteSize.X,
                                0,
                                colorPos.Y / ColorGradient.AbsoluteSize.Y,
                                0
                            )
                            
                            ColorPicker.Sat = colorPos.X / ColorGradient.AbsoluteSize.X
                            ColorPicker.Val = 1 - (colorPos.Y / ColorGradient.AbsoluteSize.Y)
                            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Val)
                            UpdateColor()
                        elseif draggingHue then
                            local huePos = math.clamp(input.Position.X - HueSlider.AbsolutePosition.X, 0, HueSlider.AbsoluteSize.X)
                            HueCursor.Position = UDim2.new(huePos / HueSlider.AbsoluteSize.X, 0, 0.5, 0)
                            
                            ColorPicker.Hue = huePos / HueSlider.AbsoluteSize.X
                            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Val)
                            UpdateColor()
                        end
                    end
                end)
                -- Toggle Color Picker Interface
                ColorPickerButton.MouseButton1Click:Connect(function()
                    ColorPicker.Open = not ColorPicker.Open
                    
                    CreateTween(ColorPickerFrame, {
                        Size = UDim2.new(1, 0, 0, ColorPicker.Open and 162 or 32)
                    }):Play()
                    
                    if Library.Settings.SoundEffects then
                        local sound = Instance.new("Sound")
                        sound.SoundId = "rbxassetid://6026984224"
                        sound.Volume = 0.5
                        sound.Parent = ColorPickerButton
                        sound:Play()
                        game:GetService("Debris"):AddItem(sound, 1)
                    end
                end)
                
                -- Color Picker Methods
                function ColorPicker:Set(color)
                    ColorPicker.Value = color
                    local h, s, v = RGBtoHSV(color)
                    ColorPicker.Hue = h
                    ColorPicker.Sat = s
                    ColorPicker.Val = v
                    
                    ColorCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                    HueCursor.Position = UDim2.new(h, 0, 0.5, 0)
                    UpdateColor()
                end
                
                return ColorPicker
            end
            
            -- Enhanced Keybind Creation
            function Section:AddKeybind(name, options)
                local Keybind = {
                    Value = options.default or Enum.KeyCode.Unknown,
                    Type = "Keybind",
                    Listening = false
                }
                
                local KeybindFrame = CreateElement("Frame", {
                    Name = name,
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Size = UDim2.new(1, 0, 0, 32),
                    Parent = SectionContent
                })
                
                local KeybindCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = KeybindFrame
                })
                
                local KeybindLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -80, 1, 0),
                    Font = Library.Fonts.Regular,
                    Text = name,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = KeybindFrame
                })
                
                local KeybindButton = CreateElement("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = Library.Theme.DarkContrast,
                    Position = UDim2.new(1, -70, 0.5, -12),
                    Size = UDim2.new(0, 60, 0, 24),
                    Font = Library.Fonts.Regular,
                    Text = options.default and options.default.Name or "None",
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    Parent = KeybindFrame
                })
                
                local KeybindButtonCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = KeybindButton
                })
                
                -- Keybind Functionality
                local function UpdateKeybind()
                    local key = Keybind.Value
                    KeybindButton.Text = key and key.Name or "None"
                    
                    if options.callback then
                        options.callback(key)
                    end
                end
                
                KeybindButton.MouseButton1Click:Connect(function()
                    if Keybind.Listening then return end
                    
                    Keybind.Listening = true
                    KeybindButton.Text = "..."
                    
                    local connection
                    connection = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            Keybind.Value = input.KeyCode
                            UpdateKeybind()
                            Keybind.Listening = false
                            connection:Disconnect()
                        end
                    end)
                end)
                
                -- Keybind Detection
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard and 
                       input.KeyCode == Keybind.Value and 
                       not Keybind.Listening then
                        if options.pressed then
                            options.pressed()
                        end
                    end
                end)
                
                -- Keybind Methods
                function Keybind:Set(key)
                    Keybind.Value = key
                    UpdateKeybind()
                end
                
                return Keybind
            end
            
            -- Enhanced TextBox Creation
            function Section:AddTextbox(name, options)
                local Textbox = {
                    Value = options.default or "",
                    Type = "Textbox"
                }
                
                local TextboxFrame = CreateElement("Frame", {
                    Name = name,
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Size = UDim2.new(1, 0, 0, 32),
                    Parent = SectionContent
                })
                
                local TextboxCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = TextboxFrame
                })
                
                local TextboxLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(0.5, -10, 1, 0),
                    Font = Library.Fonts.Regular,
                    Text = name,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TextboxFrame
                })
                local TextboxInput = CreateElement("TextBox", {
                    Name = "Input",
                    BackgroundColor3 = Library.Theme.DarkContrast,
                    Position = UDim2.new(0.5, 0, 0.5, -12),
                    Size = UDim2.new(0.5, -10, 0, 24),
                    Font = Library.Fonts.Regular,
                    Text = Textbox.Value,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    ClearTextOnFocus = options.clearOnFocus or false,
                    PlaceholderText = options.placeholder or "",
                    Parent = TextboxFrame
                })
                
                local TextboxInputCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = TextboxInput
                })
                
                -- Textbox Functionality
                local function UpdateTextbox()
                    if options.callback then
                        options.callback(Textbox.Value)
                    end
                end
                
                TextboxInput.FocusLost:Connect(function(enterPressed)
                    Textbox.Value = TextboxInput.Text
                    UpdateTextbox()
                    
                    if enterPressed and options.enterPressed then
                        options.enterPressed(Textbox.Value)
                    end
                end)
                
                -- Textbox Methods
                function Textbox:Set(text)
                    Textbox.Value = text
                    TextboxInput.Text = text
                    UpdateTextbox()
                end
                
                return Textbox
            end
            
            -- Enhanced Label Creation
            function Section:AddLabel(text)
                local Label = {}
                
                local LabelFrame = CreateElement("Frame", {
                    Name = "Label",
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Size = UDim2.new(1, 0, 0, 32),
                    Parent = SectionContent
                })
                
                local LabelCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = LabelFrame
                })
                
                local LabelText = CreateElement("TextLabel", {
                    Name = "Text",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 1, 0),
                    Font = Library.Fonts.Regular,
                    Text = text,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    TextWrapped = true,
                    Parent = LabelFrame
                })
                
                -- Label Methods
                function Label:Set(newText)
                    LabelText.Text = newText
                end
                
                return Label
            end
            
            -- Enhanced Divider Creation
            function Section:AddDivider()
                local Divider = CreateElement("Frame", {
                    Name = "Divider",
                    BackgroundColor3 = Library.Theme.Primary,
                    Size = UDim2.new(1, 0, 0, 1),
                    Parent = SectionContent
                })
                
                return Divider
            end
            
            -- Enhanced Progress Bar Creation
            function Section:AddProgressBar(name, options)
                local ProgressBar = {
                    Value = options.default or 0,
                    Min = options.min or 0,
                    Max = options.max or 100,
                    Type = "ProgressBar"
                }
                
                local ProgressBarFrame = CreateElement("Frame", {
                    Name = name,
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Size = UDim2.new(1, 0, 0, 50),
                    Parent = SectionContent
                })
                
                local ProgressBarCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = ProgressBarFrame
                })
                
                local ProgressBarLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 0, 30),
                    Font = Library.Fonts.Regular,
                    Text = name,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ProgressBarFrame
                })
                
                local ProgressBarBackground = CreateElement("Frame", {
                    Name = "Background",
                    BackgroundColor3 = Library.Theme.DarkContrast,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 10),
                    Parent = ProgressBarFrame
                })
                
                local ProgressBarBackgroundCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ProgressBarBackground
                })
                
                local ProgressBarFill = CreateElement("Frame", {
                    Name = "Fill",
                    BackgroundColor3 = Library.Theme.Primary,
                    Size = UDim2.new(ProgressBar.Value / (ProgressBar.Max - ProgressBar.Min), 0, 1, 0),
                    Parent = ProgressBarBackground
                })
                
                local ProgressBarFillCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ProgressBarFill
                })
                
                local ProgressBarValue = CreateElement("TextLabel", {
                    Name = "Value",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -40, 0, 0),
                    Size = UDim2.new(0, 30, 0, 30),
                    Font = Library.Fonts.Regular,
                    Text = tostring(ProgressBar.Value),
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    Parent = ProgressBarFrame
                })
                -- Progress Bar Functionality
                local function UpdateProgressBar()
                    local percent = (ProgressBar.Value - ProgressBar.Min) / (ProgressBar.Max - ProgressBar.Min)
                    
                    CreateTween(ProgressBarFill, {
                        Size = UDim2.new(percent, 0, 1, 0)
                    }):Play()
                    
                    ProgressBarValue.Text = tostring(math.floor(ProgressBar.Value))
                    
                    if options.callback then
                        options.callback(ProgressBar.Value)
                    end
                end
                
                -- Progress Bar Methods
                function ProgressBar:Set(value)
                    ProgressBar.Value = math.clamp(value, ProgressBar.Min, ProgressBar.Max)
                    UpdateProgressBar()
                end
                
                return ProgressBar
            end
            
            -- Enhanced Image Creation
            function Section:AddImage(options)
                local Image = {}
                
                local ImageFrame = CreateElement("Frame", {
                    Name = "Image",
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Size = UDim2.new(1, 0, 0, options.height or 100),
                    Parent = SectionContent
                })
                
                local ImageCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = ImageFrame
                })
                
                local ImageLabel = CreateElement("ImageLabel", {
                    Name = "Image",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 5),
                    Size = UDim2.new(1, -10, 1, -10),
                    Image = options.image or "",
                    ScaleType = options.scaleType or Enum.ScaleType.Fit,
                    Parent = ImageFrame
                })
                
                -- Image Methods
                function Image:Set(imageId)
                    ImageLabel.Image = imageId
                end
                
                return Image
            end
            
            -- Enhanced Graph Creation
            function Section:AddGraph(name, options)
                local Graph = {
                    Values = options.values or {},
                    MaxPoints = options.maxPoints or 100,
                    Min = options.min or 0,
                    Max = options.max or 100,
                    Type = "Graph"
                }
                
                local GraphFrame = CreateElement("Frame", {
                    Name = name,
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Size = UDim2.new(1, 0, 0, 150),
                    Parent = SectionContent
                })
                
                local GraphCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = GraphFrame
                })
                
                local GraphLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 0, 30),
                    Font = Library.Fonts.Regular,
                    Text = name,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = GraphFrame
                })
                
                local GraphContainer = CreateElement("Frame", {
                    Name = "Container",
                    BackgroundColor3 = Library.Theme.DarkContrast,
                    Position = UDim2.new(0, 10, 0, 35),
                    Size = UDim2.new(1, -20, 1, -45),
                    Parent = GraphFrame
                })
                
                local GraphContainerCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = GraphContainer
                })
                
                -- Create grid lines
                for i = 0, 4 do
                    local gridLine = CreateElement("Frame", {
                        Name = "GridLine",
                        BackgroundColor3 = Library.Theme.LightContrast,
                        Position = UDim2.new(0, 0, i/4, 0),
                        Size = UDim2.new(1, 0, 0, 1),
                        Parent = GraphContainer
                    })
                    
                    local gridLabel = CreateElement("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, -25, 0, -10),
                        Size = UDim2.new(0, 20, 0, 20),
                        Font = Library.Fonts.Regular,
                        Text = tostring(math.floor(Graph.Max - (i/4) * (Graph.Max - Graph.Min))),
                        TextColor3 = Library.Theme.TextColor,
                        TextSize = 10,
                        Parent = gridLine
                    })
                end
                
                -- Graph Line
                local GraphLine = CreateElement("Frame", {
                    Name = "Line",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Parent = GraphContainer
                })
                
                -- Graph Points
                local function UpdateGraph()
                    -- Clear existing points
                    for _, point in pairs(GraphLine:GetChildren()) do
                        point:Destroy()
                    end
                    
                    -- Draw new points
                    for i, value in ipairs(Graph.Values) do
                        local normalizedValue = (value - Graph.Min) / (Graph.Max - Graph.Min)
                        local point = CreateElement("Frame", {
                            Name = "Point",
                            BackgroundColor3 = Library.Theme.Primary,
                            Position = UDim2.new((i-1)/(#Graph.Values-1), 0, 1-normalizedValue, 0),
                            Size = UDim2.new(0, 4, 0, 4),
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Parent = GraphLine
                        })
                        
                        local pointCorner = CreateElement("UICorner", {
                            CornerRadius = UDim.new(1, 0),
                            Parent = point
                        })
                        
                        -- Connect points with lines
                        if i > 1 then
                            local prevValue = (Graph.Values[i-1] - Graph.Min) / (Graph.Max - Graph.Min)
                            local line = CreateElement("Frame", {
                                Name = "Line",
                                BackgroundColor3 = Library.Theme.Primary,
                                Position = UDim2.new((i-2)/(#Graph.Values-1), 0, 1-prevValue, 0),
                                Parent = GraphLine
                            })
                            
                            -- Calculate line properties
                            local deltaX = 1/(#Graph.Values-1)
                            local deltaY = prevValue - normalizedValue
                            local distance = math.sqrt(deltaX^2 + deltaY^2)
                            local angle = math.atan2(deltaY, deltaX)
                            
                            line.Size = UDim2.new(0, distance * GraphContainer.AbsoluteSize.X, 0, 2)
                            line.Rotation = math.deg(angle)
                            line.AnchorPoint = Vector2.new(0, 0.5)
                        end
                    end
                end
                -- Graph Methods
                function Graph:AddPoint(value)
                    table.insert(Graph.Values, value)
                    if #Graph.Values > Graph.MaxPoints then
                        table.remove(Graph.Values, 1)
                    end
                    UpdateGraph()
                end
                
                function Graph:SetPoints(values)
                    Graph.Values = values
                    UpdateGraph()
                end
                
                function Graph:Clear()
                    Graph.Values = {}
                    UpdateGraph()
                end
                
                return Graph
            end
            
            -- Enhanced List Creation
            function Section:AddList(name, options)
                local List = {
                    Items = options.items or {},
                    Selected = options.selected or {},
                    MultiSelect = options.multiSelect or false,
                    Type = "List"
                }
                
                local ListFrame = CreateElement("Frame", {
                    Name = name,
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Size = UDim2.new(1, 0, 0, 150),
                    Parent = SectionContent
                })
                
                local ListCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = ListFrame
                })
                
                local ListLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 0, 30),
                    Font = Library.Fonts.Regular,
                    Text = name,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ListFrame
                })
                
                local ListContainer = CreateElement("ScrollingFrame", {
                    Name = "Container",
                    BackgroundColor3 = Library.Theme.DarkContrast,
                    Position = UDim2.new(0, 10, 0, 35),
                    Size = UDim2.new(1, -20, 1, -45),
                    ScrollBarThickness = 3,
                    Parent = ListFrame
                })
                
                local ListContainerCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = ListContainer
                })
                
                local ListLayout = CreateElement("UIListLayout", {
                    Padding = UDim.new(0, 5),
                    Parent = ListContainer
                })
                
                local ListPadding = CreateElement("UIPadding", {
                    PaddingTop = UDim.new(0, 5),
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    Parent = ListContainer
                })
                
                -- Update List Items
                local function UpdateList()
                    -- Clear existing items
                    for _, item in pairs(ListContainer:GetChildren()) do
                        if item:IsA("TextButton") then
                            item:Destroy()
                        end
                    end
                    
                    -- Create new items
                    for _, item in ipairs(List.Items) do
                        local ItemButton = CreateElement("TextButton", {
                            Name = item,
                            BackgroundColor3 = table.find(List.Selected, item) and Library.Theme.Primary or Library.Theme.LightContrast,
                            Size = UDim2.new(1, 0, 0, 30),
                            Font = Library.Fonts.Regular,
                            Text = item,
                            TextColor3 = Library.Theme.TextColor,
                            TextSize = 14,
                            Parent = ListContainer
                        })
                        
                        local ItemCorner = CreateElement("UICorner", {
                            CornerRadius = UDim.new(0, 4),
                            Parent = ItemButton
                        })
                        
                        ItemButton.MouseButton1Click:Connect(function()
                            if List.MultiSelect then
                                local index = table.find(List.Selected, item)
                                if index then
                                    table.remove(List.Selected, index)
                                    CreateTween(ItemButton, {
                                        BackgroundColor3 = Library.Theme.LightContrast
                                    }):Play()
                                else
                                    table.insert(List.Selected, item)
                                    CreateTween(ItemButton, {
                                        BackgroundColor3 = Library.Theme.Primary
                                    }):Play()
                                end
                            else
                                List.Selected = {item}
                                UpdateList()
                            end
                            
                            if options.callback then
                                options.callback(List.Selected)
                            end
                        end)
                        
                        -- Hover Effect
                        ItemButton.MouseEnter:Connect(function()
                            if not table.find(List.Selected, item) then
                                CreateTween(ItemButton, {
                                    BackgroundColor3 = Library.Theme.Primary
                                }):Play()
                            end
                        end)
                        
                        ItemButton.MouseLeave:Connect(function()
                            if not table.find(List.Selected, item) then
                                CreateTween(ItemButton, {
                                    BackgroundColor3 = Library.Theme.LightContrast
                                }):Play()
                            end
                        end)
                    end
                    
                    -- Update ScrollingFrame canvas size
                    ListContainer.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
                end
                
                -- Initial update
                UpdateList()
                
                -- List Methods
                function List:SetItems(items)
                    List.Items = items
                    List.Selected = {}
                    UpdateList()
                end
                
                function List:Select(items)
                    if type(items) == "string" then
                        items = {items}
                    end
                    List.Selected = items
                    UpdateList()
                end
                
                function List:GetSelected()
                    return List.Selected
                end
                
                return List
            end
            
            -- Enhanced Search Bar Creation
            function Section:AddSearchBar(options)
                local SearchBar = {
                    Callback = options.callback,
                    PlaceholderText = options.placeholder or "Search...",
                    Type = "SearchBar"
                }
                local SearchBarFrame = CreateElement("Frame", {
                    Name = "SearchBar",
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Size = UDim2.new(1, 0, 0, 32),
                    Parent = SectionContent
                })
                
                local SearchBarCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = SearchBarFrame
                })
                
                local SearchIcon = CreateElement("ImageLabel", {
                    Name = "Icon",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 8),
                    Size = UDim2.new(0, 16, 0, 16),
                    Image = "rbxassetid://3605509925",
                    ImageColor3 = Library.Theme.TextColor,
                    Parent = SearchBarFrame
                })
                
                local SearchInput = CreateElement("TextBox", {
                    Name = "Input",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 32, 0, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    Font = Library.Fonts.Regular,
                    Text = "",
                    PlaceholderText = SearchBar.PlaceholderText,
                    TextColor3 = Library.Theme.TextColor,
                    PlaceholderColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SearchBarFrame
                })
                
                local ClearButton = CreateElement("ImageButton", {
                    Name = "Clear",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -24, 0, 8),
                    Size = UDim2.new(0, 16, 0, 16),
                    Image = "rbxassetid://3944676352",
                    ImageColor3 = Library.Theme.TextColor,
                    Visible = false,
                    Parent = SearchBarFrame
                })
                
                -- Search Bar Functionality
                SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
                    ClearButton.Visible = SearchInput.Text ~= ""
                    if SearchBar.Callback then
                        SearchBar.Callback(SearchInput.Text)
                    end
                end)
                
                ClearButton.MouseButton1Click:Connect(function()
                    SearchInput.Text = ""
                end)
                
                -- Search Bar Methods
                function SearchBar:SetText(text)
                    SearchInput.Text = text
                end
                
                function SearchBar:GetText()
                    return SearchInput.Text
                end
                
                return SearchBar
            end
            
            -- Enhanced Chip Creation
            function Section:AddChips(name, options)
                local Chips = {
                    Items = options.items or {},
                    Selected = options.selected or {},
                    MultiSelect = options.multiSelect or false,
                    Type = "Chips"
                }
                
                local ChipsFrame = CreateElement("Frame", {
                    Name = name,
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Size = UDim2.new(1, 0, 0, 66),
                    Parent = SectionContent
                })
                
                local ChipsCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = ChipsFrame
                })
                
                local ChipsLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 0, 30),
                    Font = Library.Fonts.Regular,
                    Text = name,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ChipsFrame
                })
                
                local ChipsContainer = CreateElement("ScrollingFrame", {
                    Name = "Container",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 30),
                    ScrollBarThickness = 0,
                    ScrollingDirection = Enum.ScrollingDirection.X,
                    Parent = ChipsFrame
                })
                
                local ChipsLayout = CreateElement("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0, 5),
                    Parent = ChipsContainer
                })
                
                -- Update Chips
                local function UpdateChips()
                    -- Clear existing chips
                    for _, chip in pairs(ChipsContainer:GetChildren()) do
                        if chip:IsA("TextButton") then
                            chip:Destroy()
                        end
                    end
                    
                    -- Create new chips
                    for _, item in ipairs(Chips.Items) do
                        local isSelected = table.find(Chips.Selected, item) ~= nil
                        
                        local ChipButton = CreateElement("TextButton", {
                            Name = item,
                            AutomaticSize = Enum.AutomaticSize.X,
                            BackgroundColor3 = isSelected and Library.Theme.Primary or Library.Theme.DarkContrast,
                            Size = UDim2.new(0, 0, 1, -6),
                            Font = Library.Fonts.Regular,
                            Text = "  " .. item .. "  ",
                            TextColor3 = Library.Theme.TextColor,
                            TextSize = 14,
                            Parent = ChipsContainer
                        })
                        
                        local ChipCorner = CreateElement("UICorner", {
                            CornerRadius = UDim.new(0, 12),
                            Parent = ChipButton
                        })
                        
                        ChipButton.MouseButton1Click:Connect(function()
                            if Chips.MultiSelect then
                                local index = table.find(Chips.Selected, item)
                                if index then
                                    table.remove(Chips.Selected, index)
                                else
                                    table.insert(Chips.Selected, item)
                                end
                            else
                                Chips.Selected = {item}
                            end
                            
                            UpdateChips()
                            
                            if options.callback then
                                options.callback(Chips.Selected)
                            end
                        end)
                    end
                    
                    -- Update ScrollingFrame canvas size
                    ChipsContainer.CanvasSize = UDim2.new(0, ChipsLayout.AbsoluteContentSize.X, 0, 0)
                end
                -- Chip Methods
                function Chips:SetItems(items)
                    Chips.Items = items
                    Chips.Selected = {}
                    UpdateChips()
                end
                
                function Chips:Select(items)
                    if type(items) == "string" then
                        items = {items}
                    end
                    Chips.Selected = items
                    UpdateChips()
                end
                
                function Chips:GetSelected()
                    return Chips.Selected
                end
                
                -- Initial update
                UpdateChips()
                
                return Chips
            end
            
            -- Enhanced Tab Bar Creation
            function Section:AddTabBar(options)
                local TabBar = {
                    Tabs = options.tabs or {},
                    Selected = options.default or options.tabs[1],
                    Type = "TabBar"
                }
                
                local TabBarFrame = CreateElement("Frame", {
                    Name = "TabBar",
                    BackgroundColor3 = Library.Theme.DarkContrast,
                    Size = UDim2.new(1, 0, 0, 35),
                    Parent = SectionContent
                })
                
                local TabBarCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = TabBarFrame
                })
                
                local TabContainer = CreateElement("Frame", {
                    Name = "Container",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 5),
                    Size = UDim2.new(1, -10, 1, -10),
                    Parent = TabBarFrame
                })
                
                local TabLayout = CreateElement("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0, 5),
                    Parent = TabContainer
                })
                
                -- Update Tab Bar
                local function UpdateTabBar()
                    -- Clear existing tabs
                    for _, tab in pairs(TabContainer:GetChildren()) do
                        if tab:IsA("TextButton") then
                            tab:Destroy()
                        end
                    end
                    
                    -- Calculate tab width
                    local tabWidth = (1 / #TabBar.Tabs) - 0.01
                    
                    -- Create new tabs
                    for _, tab in ipairs(TabBar.Tabs) do
                        local TabButton = CreateElement("TextButton", {
                            Name = tab,
                            BackgroundColor3 = tab == TabBar.Selected and Library.Theme.Primary or Library.Theme.LightContrast,
                            Size = UDim2.new(tabWidth, 0, 1, 0),
                            Font = Library.Fonts.Regular,
                            Text = tab,
                            TextColor3 = Library.Theme.TextColor,
                            TextSize = 14,
                            Parent = TabContainer
                        })
                        
                        local TabButtonCorner = CreateElement("UICorner", {
                            CornerRadius = UDim.new(0, 4),
                            Parent = TabButton
                        })
                        
                        -- Add hover effect
                        TabButton.MouseEnter:Connect(function()
                            if tab ~= TabBar.Selected then
                                CreateTween(TabButton, {
                                    BackgroundColor3 = Library.Theme.Primary
                                }):Play()
                            end
                        end)
                        
                        TabButton.MouseLeave:Connect(function()
                            if tab ~= TabBar.Selected then
                                CreateTween(TabButton, {
                                    BackgroundColor3 = Library.Theme.LightContrast
                                }):Play()
                            end
                        end)
                        
                        TabButton.MouseButton1Click:Connect(function()
                            TabBar.Selected = tab
                            UpdateTabBar()
                            
                            if options.callback then
                                options.callback(tab)
                            end
                            
                            -- Play click animation
                            if Library.Settings.SoundEffects then
                                local sound = Instance.new("Sound")
                                sound.SoundId = "rbxassetid://6026984224"
                                sound.Volume = 0.5
                                sound.Parent = TabButton
                                sound:Play()
                                game:GetService("Debris"):AddItem(sound, 1)
                            end
                        end)
                    end
                end
                
                -- Tab Bar Methods
                function TabBar:SetTabs(tabs)
                    TabBar.Tabs = tabs
                    TabBar.Selected = tabs[1]
                    UpdateTabBar()
                end
                
                function TabBar:SelectTab(tab)
                    if table.find(TabBar.Tabs, tab) then
                        TabBar.Selected = tab
                        UpdateTabBar()
                        
                        if options.callback then
                            options.callback(tab)
                        end
                    end
                end
                
                -- Initial update
                UpdateTabBar()
                
                return TabBar
            end
            
            -- Enhanced Tooltip System
            function Section:AddTooltip(element, text)
                if not Library.Settings.TooltipsEnabled then return end
                
                local Tooltip = CreateElement("Frame", {
                    Name = "Tooltip",
                    BackgroundColor3 = Library.Theme.DarkContrast,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(0, 200, 0, 30),
                    Visible = false,
                    ZIndex = 100,
                    Parent = ScreenGui
                })
                
                local TooltipCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = Tooltip
                })
                local TooltipText = CreateElement("TextLabel", {
                    Name = "Text",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 0),
                    Size = UDim2.new(1, -10, 1, 0),
                    Font = Library.Fonts.Regular,
                    Text = text,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    TextWrapped = true,
                    ZIndex = 100,
                    Parent = Tooltip
                })
                
                -- Auto-size tooltip based on text
                local textSize = game:GetService("TextService"):GetTextSize(
                    text,
                    14,
                    Library.Fonts.Regular,
                    Vector2.new(190, math.huge)
                )
                Tooltip.Size = UDim2.new(0, 200, 0, textSize.Y + 10)
                
                -- Tooltip Positioning
                local function UpdateTooltipPosition()
                    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
                    local viewport = workspace.CurrentCamera.ViewportSize
                    local tooltipSize = Tooltip.AbsoluteSize
                    
                    local posX = mouse.X + 20
                    local posY = mouse.Y + 20
                    
                    -- Adjust position if tooltip would go off screen
                    if posX + tooltipSize.X > viewport.X then
                        posX = mouse.X - tooltipSize.X - 20
                    end
                    
                    if posY + tooltipSize.Y > viewport.Y then
                        posY = mouse.Y - tooltipSize.Y - 20
                    end
                    
                    Tooltip.Position = UDim2.new(0, posX, 0, posY)
                end
                
                -- Tooltip Visibility
                element.MouseEnter:Connect(function()
                    Tooltip.Visible = true
                    
                    -- Fade in animation
                    Tooltip.BackgroundTransparency = 1
                    TooltipText.TextTransparency = 1
                    
                    CreateTween(Tooltip, {BackgroundTransparency = 0}):Play()
                    CreateTween(TooltipText, {TextTransparency = 0}):Play()
                end)
                
                element.MouseLeave:Connect(function()
                    -- Fade out animation
                    local fadeOut = CreateTween(Tooltip, {BackgroundTransparency = 1})
                    local textFadeOut = CreateTween(TooltipText, {TextTransparency = 1})
                    
                    fadeOut:Play()
                    textFadeOut:Play()
                    
                    fadeOut.Completed:Connect(function()
                        Tooltip.Visible = false
                    end)
                end)
                
                -- Update position when mouse moves
                element.MouseMoved:Connect(UpdateTooltipPosition)
            end
            
            -- Enhanced Context Menu
            function Section:AddContextMenu(element, options)
                local ContextMenu = CreateElement("Frame", {
                    Name = "ContextMenu",
                    BackgroundColor3 = Library.Theme.DarkContrast,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(0, 150, 0, #options * 30),
                    Visible = false,
                    ZIndex = 100,
                    Parent = ScreenGui
                })
                
                local ContextMenuCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ContextMenu
                })
                
                -- Create menu items
                for i, option in ipairs(options) do
                    local MenuItem = CreateElement("TextButton", {
                        Name = option.text,
                        BackgroundColor3 = Library.Theme.LightContrast,
                        Position = UDim2.new(0, 0, 0, (i-1) * 30),
                        Size = UDim2.new(1, 0, 0, 30),
                        Font = Library.Fonts.Regular,
                        Text = option.text,
                        TextColor3 = Library.Theme.TextColor,
                        TextSize = 14,
                        ZIndex = 100,
                        Parent = ContextMenu
                    })
                    
                    local MenuItemCorner = CreateElement("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = MenuItem
                    })
                    
                    -- Add hover effect
                    MenuItem.MouseEnter:Connect(function()
                        CreateTween(MenuItem, {
                            BackgroundColor3 = Library.Theme.Primary
                        }):Play()
                    end)
                    
                    MenuItem.MouseLeave:Connect(function()
                        CreateTween(MenuItem, {
                            BackgroundColor3 = Library.Theme.LightContrast
                        }):Play()
                    end)
                    
                    MenuItem.MouseButton1Click:Connect(function()
                        ContextMenu.Visible = false
                        if option.callback then
                            option.callback()
                        end
                    end)
                end
                -- Context Menu Positioning and Behavior
                element.MouseButton2Click:Connect(function()
                    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
                    local viewport = workspace.CurrentCamera.ViewportSize
                    local menuSize = ContextMenu.AbsoluteSize
                    
                    local posX = mouse.X
                    local posY = mouse.Y
                    
                    -- Adjust position if menu would go off screen
                    if posX + menuSize.X > viewport.X then
                        posX = posX - menuSize.X
                    end
                    
                    if posY + menuSize.Y > viewport.Y then
                        posY = posY - menuSize.Y
                    end
                    
                    ContextMenu.Position = UDim2.new(0, posX, 0, posY)
                    ContextMenu.Visible = true
                    
                    -- Fade in animation
                    ContextMenu.BackgroundTransparency = 1
                    CreateTween(ContextMenu, {BackgroundTransparency = 0}):Play()
                    
                    -- Fade in menu items
                    for _, item in ipairs(ContextMenu:GetChildren()) do
                        if item:IsA("TextButton") then
                            item.BackgroundTransparency = 1
                            item.TextTransparency = 1
                            CreateTween(item, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
                        end
                    end
                end)
                
                -- Close context menu when clicking outside
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and ContextMenu.Visible then
                        -- Fade out animation
                        local fadeOut = CreateTween(ContextMenu, {BackgroundTransparency = 1})
                        fadeOut:Play()
                        
                        -- Fade out menu items
                        for _, item in ipairs(ContextMenu:GetChildren()) do
                            if item:IsA("TextButton") then
                                CreateTween(item, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
                            end
                        end
                        
                        fadeOut.Completed:Connect(function()
                            ContextMenu.Visible = false
                        end)
                    end
                end)
            end
            
            -- Enhanced Radio Button Group
            function Section:AddRadioGroup(name, options)
                local RadioGroup = {
                    Selected = options.default,
                    Options = options.items or {},
                    Type = "RadioGroup"
                }
                
                local RadioGroupFrame = CreateElement("Frame", {
                    Name = name,
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Size = UDim2.new(1, 0, 0, 30 + (#RadioGroup.Options * 30)),
                    Parent = SectionContent
                })
                
                local RadioGroupCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = RadioGroupFrame
                })
                
                local RadioGroupLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 0, 30),
                    Font = Library.Fonts.Regular,
                    Text = name,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = RadioGroupFrame
                })
                
                -- Create radio buttons
                for i, option in ipairs(RadioGroup.Options) do
                    local RadioButton = CreateElement("Frame", {
                        Name = option,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 30 + (i-1) * 30),
                        Size = UDim2.new(1, -20, 0, 30),
                        Parent = RadioGroupFrame
                    })
                    
                    local RadioCircle = CreateElement("Frame", {
                        Name = "Circle",
                        BackgroundColor3 = Library.Theme.DarkContrast,
                        Position = UDim2.new(0, 0, 0.5, -10),
                        Size = UDim2.new(0, 20, 0, 20),
                        Parent = RadioButton
                    })
                    
                    local RadioCircleCorner = CreateElement("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = RadioCircle
                    })
                    
                    local RadioInnerCircle = CreateElement("Frame", {
                        Name = "Inner",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Library.Theme.Primary,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(0, option == RadioGroup.Selected and 12 or 0, 0, option == RadioGroup.Selected and 12 or 0),
                        Parent = RadioCircle
                    })
                    
                    local RadioInnerCircleCorner = CreateElement("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = RadioInnerCircle
                    })
                    
                    local RadioLabel = CreateElement("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 30, 0, 0),
                        Size = UDim2.new(1, -30, 1, 0),
                        Font = Library.Fonts.Regular,
                        Text = option,
                        TextColor3 = Library.Theme.TextColor,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = RadioButton
                    })
                    -- Radio Button Click Handler
                    RadioButton.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            -- Update selected state
                            RadioGroup.Selected = option
                            
                            -- Update all radio buttons
                            for _, rb in ipairs(RadioGroupFrame:GetChildren()) do
                                if rb:IsA("Frame") and rb.Name ~= "Label" then
                                    local innerCircle = rb:FindFirstChild("Circle"):FindFirstChild("Inner")
                                    if innerCircle then
                                        CreateTween(innerCircle, {
                                            Size = UDim2.new(0, rb.Name == option and 12 or 0, 0, rb.Name == option and 12 or 0)
                                        }):Play()
                                    end
                                end
                            end
                            
                            if options.callback then
                                options.callback(option)
                            end
                            
                            -- Play selection sound
                            if Library.Settings.SoundEffects then
                                local sound = Instance.new("Sound")
                                sound.SoundId = "rbxassetid://6026984224"
                                sound.Volume = 0.5
                                sound.Parent = RadioButton
                                sound:Play()
                                game:GetService("Debris"):AddItem(sound, 1)
                            end
                        end
                    end)
                    
                    -- Hover Effects
                    RadioButton.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            CreateTween(RadioCircle, {
                                BackgroundColor3 = Library.Theme.Primary
                            }):Play()
                        end
                    end)
                    
                    RadioButton.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            CreateTween(RadioCircle, {
                                BackgroundColor3 = Library.Theme.DarkContrast
                            }):Play()
                        end
                    end)
                end
                
                -- Radio Group Methods
                function RadioGroup:Select(option)
                    if table.find(RadioGroup.Options, option) then
                        RadioGroup.Selected = option
                        
                        -- Update radio buttons
                        for _, rb in ipairs(RadioGroupFrame:GetChildren()) do
                            if rb:IsA("Frame") and rb.Name ~= "Label" then
                                local innerCircle = rb:FindFirstChild("Circle"):FindFirstChild("Inner")
                                if innerCircle then
                                    CreateTween(innerCircle, {
                                        Size = UDim2.new(0, rb.Name == option and 12 or 0, 0, rb.Name == option and 12 or 0)
                                    }):Play()
                                end
                            end
                        end
                        
                        if options.callback then
                            options.callback(option)
                        end
                    end
                end
                
                return RadioGroup
            end
            
            -- Enhanced Date/Time Picker
            function Section:AddDateTimePicker(name, options)
                local DateTimePicker = {
                    Value = options.default or os.date("*t"),
                    Type = "DateTimePicker",
                    ShowTime = options.showTime or false
                }
                
                local DateTimeFrame = CreateElement("Frame", {
                    Name = name,
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Size = UDim2.new(1, 0, 0, 32),
                    Parent = SectionContent
                })
                
                local DateTimeCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = DateTimeFrame
                })
                
                local DateTimeLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -120, 1, 0),
                    Font = Library.Fonts.Regular,
                    Text = name,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DateTimeFrame
                })
                
                local DateTimeButton = CreateElement("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = Library.Theme.DarkContrast,
                    Position = UDim2.new(1, -110, 0.5, -12),
                    Size = UDim2.new(0, 100, 0, 24),
                    Font = Library.Fonts.Regular,
                    Text = "",
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 14,
                    Parent = DateTimeFrame
                })
                
                local DateTimeButtonCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = DateTimeButton
                })
                
                -- Update displayed date/time
                local function UpdateDisplay()
                    local format = DateTimePicker.ShowTime and "%Y-%m-%d %H:%M" or "%Y-%m-%d"
                    DateTimeButton.Text = os.date(format, os.time(DateTimePicker.Value))
                end
                
                -- Initial display update
                UpdateDisplay()
                
                -- Create calendar popup
                local CalendarFrame = CreateElement("Frame", {
                    Name = "Calendar",
                    BackgroundColor3 = Library.Theme.DarkContrast,
                    Position = UDim2.new(1, -220, 1, 10),
                    Size = UDim2.new(0, 200, 0, DateTimePicker.ShowTime and 280 or 240),
                    Visible = false,
                    ZIndex = 100,
                    Parent = DateTimeFrame
                })
                
                local CalendarCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = CalendarFrame
                })
-- Mobile Support Detection and Adjustments
local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Mobile UI Adjustments
if isMobile then
    Library.Settings = table.clone(Library.Settings)
    Library.Settings.ElementPadding = 12 -- Increased touch targets
    Library.Settings.FontSize = 16 -- Larger text
    Library.Settings.MinimumWidth = 300 -- Wider UI for touch
    Library.Settings.ButtonHeight = 40 -- Taller buttons
    Library.Settings.ScrollSensitivity = 0.5 -- Adjusted scroll speed
    
    -- Adjust main window size for mobile
    MainFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
end

-- Continuing with the calendar functionality from where we left off:

                -- Calendar Header
                local CalendarHeader = CreateElement("Frame", {
                    Name = "Header",
                    BackgroundColor3 = Library.Theme.Primary,
                    Size = UDim2.new(1, 0, 0, isMobile and 40 or 30),
                    ZIndex = 101,
                    Parent = CalendarFrame
                })
                
                local CalendarHeaderCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = CalendarHeader
                })
                
                local PrevMonthButton = CreateElement("TextButton", {
                    Name = "PrevMonth",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 0),
                    Size = UDim2.new(0, isMobile and 40 or 30, 1, 0),
                    Font = Library.Fonts.Regular,
                    Text = "<",
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = isMobile and 24 or 18,
                    ZIndex = 102,
                    Parent = CalendarHeader
                })
                
                local NextMonthButton = CreateElement("TextButton", {
                    Name = "NextMonth",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -35, 0, 0),
                    Size = UDim2.new(0, isMobile and 40 or 30, 1, 0),
                    Font = Library.Fonts.Regular,
                    Text = ">",
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = isMobile and 24 or 18,
                    ZIndex = 102,
                    Parent = CalendarHeader
                })
                
                local MonthYearLabel = CreateElement("TextLabel", {
                    Name = "MonthYear",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 40, 0, 0),
                    Size = UDim2.new(1, -80, 1, 0),
                    Font = Library.Fonts.Regular,
                    Text = os.date("%B %Y", os.time(DateTimePicker.Value)),
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = isMobile and 18 or 14,
                    ZIndex = 102,
                    Parent = CalendarHeader
                })
                
                -- Calendar Grid
                local CalendarGrid = CreateElement("Frame", {
                    Name = "Grid",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, isMobile and 45 or 35),
                    Size = UDim2.new(1, -10, 0, isMobile and 240 or 200),
                    ZIndex = 101,
                    Parent = CalendarFrame
                })
                
                -- Day of week headers
                local daysOfWeek = {"Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"}
                for i, day in ipairs(daysOfWeek) do
                    local DayLabel = CreateElement("TextLabel", {
                        Name = day,
                        BackgroundTransparency = 1,
                        Position = UDim2.new((i-1)/7, 0, 0, 0),
                        Size = UDim2.new(1/7, 0, 0, isMobile and 30 or 20),
                        Font = Library.Fonts.Regular,
                        Text = day,
                        TextColor3 = Library.Theme.TextColor,
                        TextSize = isMobile and 16 or 12,
                        ZIndex = 102,
                        Parent = CalendarGrid
                    })
                end
                
                -- Calendar day buttons
                local function CreateDayButtons()
                    -- Clear existing day buttons
                    for _, child in pairs(CalendarGrid:GetChildren()) do
                        if child.Name:match("Day_") then
                            child:Destroy()
                        end
                    end
                    
                    local currentDate = os.date("*t", os.time(DateTimePicker.Value))
                    local firstDay = os.date("*t", os.time({year = currentDate.year, month = currentDate.month, day = 1}))
                    local daysInMonth = os.date("*t", os.time({year = currentDate.year, month = currentDate.month + 1, day = 0})).day
                    
                    -- Create day buttons
                    for i = 1, 42 do
                        local row = math.floor((i-1) / 7)
                        local col = (i-1) % 7
                        local dayNum = i - firstDay.wday + 1
                        
                        local DayButton = CreateElement("TextButton", {
                            Name = "Day_" .. i,
                            BackgroundColor3 = Library.Theme.LightContrast,
                            BackgroundTransparency = dayNum < 1 or dayNum > daysInMonth and 0.8 or 0,
                            Position = UDim2.new(col/7, 1, 0, (row + 1) * (isMobile and 35 or 25)),
                            Size = UDim2.new(1/7, -2, 0, isMobile and 30 or 20),
                            Font = Library.Fonts.Regular,
                            Text = dayNum > 0 and dayNum <= daysInMonth and tostring(dayNum) or "",
                            TextColor3 = Library.Theme.TextColor,
                            TextSize = isMobile and 16 or 12,
                            ZIndex = 102,
                            Parent = CalendarGrid
                        })
                        
                        local DayButtonCorner = CreateElement("UICorner", {
                            CornerRadius = UDim.new(0, 4),
                            Parent = DayButton
                        })
                        
                        -- Highlight current selection
                        if dayNum == currentDate.day then
                            DayButton.BackgroundColor3 = Library.Theme.Primary
                        end
                        -- Day Button Click Handler
                        DayButton.MouseButton1Click:Connect(function()
                            if dayNum > 0 and dayNum <= daysInMonth then
                                DateTimePicker.Value.day = dayNum
                                UpdateDisplay()
                                
                                -- Update visual selection
                                for _, btn in pairs(CalendarGrid:GetChildren()) do
                                    if btn:IsA("TextButton") then
                                        btn.BackgroundColor3 = Library.Theme.LightContrast
                                    end
                                end
                                DayButton.BackgroundColor3 = Library.Theme.Primary
                                
                                -- Mobile vibration feedback
                                if isMobile and game:GetService("HapticService") then
                                    game:GetService("HapticService"):SetMotor(
                                        Enum.UserInputType.Gamepad1, 
                                        Enum.VibrationMotor.Small, 
                                        0.2
                                    )
                                end
                                
                                if not DateTimePicker.ShowTime then
                                    CalendarFrame.Visible = false
                                end
                                
                                if options.callback then
                                    options.callback(DateTimePicker.Value)
                                end
                            end
                        end)
                        
                        -- Mobile-friendly hover effects
                        if isMobile then
                            DayButton.TouchEnded:Connect(function()
                                if dayNum > 0 and dayNum <= daysInMonth then
                                    CreateTween(DayButton, {
                                        BackgroundColor3 = Library.Theme.Primary
                                    }, 0.1):Play()
                                end
                            end)
                        else
                            DayButton.MouseEnter:Connect(function()
                                if dayNum > 0 and dayNum <= daysInMonth then
                                    CreateTween(DayButton, {
                                        BackgroundColor3 = Library.Theme.Primary
                                    }):Play()
                                end
                            end)
                            
                            DayButton.MouseLeave:Connect(function()
                                if dayNum > 0 and dayNum <= daysInMonth and dayNum ~= currentDate.day then
                                    CreateTween(DayButton, {
                                        BackgroundColor3 = Library.Theme.LightContrast
                                    }):Play()
                                end
                            end)
                        end
                    end
                end
                
                -- Time Picker (if enabled)
                if DateTimePicker.ShowTime then
                    local TimeContainer = CreateElement("Frame", {
                        Name = "TimeContainer",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 5, 1, -35),
                        Size = UDim2.new(1, -10, 0, 30),
                        ZIndex = 101,
                        Parent = CalendarFrame
                    })
                    
                    local HourInput = CreateElement("TextBox", {
                        Name = "Hour",
                        BackgroundColor3 = Library.Theme.LightContrast,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(0, isMobile and 60 or 40, 1, 0),
                        Font = Library.Fonts.Regular,
                        Text = string.format("%02d", DateTimePicker.Value.hour),
                        TextColor3 = Library.Theme.TextColor,
                        TextSize = isMobile and 18 or 14,
                        ZIndex = 102,
                        Parent = TimeContainer
                    })
                    
                    local HourCorner = CreateElement("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = HourInput
                    })
                    
                    local TimeSeparator = CreateElement("TextLabel", {
                        Name = "Separator",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, isMobile and 65 or 45, 0, 0),
                        Size = UDim2.new(0, 10, 1, 0),
                        Font = Library.Fonts.Regular,
                        Text = ":",
                        TextColor3 = Library.Theme.TextColor,
                        TextSize = isMobile and 18 or 14,
                        ZIndex = 102,
                        Parent = TimeContainer
                    })
                    
                    local MinuteInput = CreateElement("TextBox", {
                        Name = "Minute",
                        BackgroundColor3 = Library.Theme.LightContrast,
                        Position = UDim2.new(0, isMobile and 80 or 60, 0, 0),
                        Size = UDim2.new(0, isMobile and 60 or 40, 1, 0),
                        Font = Library.Fonts.Regular,
                        Text = string.format("%02d", DateTimePicker.Value.min),
                        TextColor3 = Library.Theme.TextColor,
                        TextSize = isMobile and 18 or 14,
                        ZIndex = 102,
                        Parent = TimeContainer
                    })
                    
                    local MinuteCorner = CreateElement("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = MinuteInput
                    })
                    
                    -- Time Input Handlers
                    local function ValidateTimeInput(input, maxValue)
                        local num = tonumber(input.Text)
                        if num then
                            num = math.clamp(num, 0, maxValue)
                            input.Text = string.format("%02d", num)
                            return num
                        else
                            input.Text = "00"
                            return 0
                        end
                    end
                    
                    HourInput.FocusLost:Connect(function()
                        DateTimePicker.Value.hour = ValidateTimeInput(HourInput, 23)
                        UpdateDisplay()
                        if options.callback then
                            options.callback(DateTimePicker.Value)
                        end
                    end)
                    
                    MinuteInput.FocusLost:Connect(function()
                        DateTimePicker.Value.min = ValidateTimeInput(MinuteInput, 59)
                        UpdateDisplay()
                        if options.callback then
                            options.callback(DateTimePicker.Value)
                        end
                    end)
                    
                    -- Mobile-friendly number input
                    if isMobile then
                        local function CreateNumberPad(input, maxValue)
                            local NumberPad = CreateElement("Frame", {
                                Name = "NumberPad",
                                BackgroundColor3 = Library.Theme.DarkContrast,
                                Position = UDim2.new(0.5, -100, 1, 10),
                                Size = UDim2.new(0, 200, 0, 240),
                                Visible = false,
                                ZIndex = 200,
                                Parent = DateTimeFrame
                            })
                            
                            local NumberPadCorner = CreateElement("UICorner", {
                                CornerRadius = UDim.new(0, 6),
                                Parent = NumberPad
                            })
                            -- Create number pad buttons
                            for i = 1, 12 do
                                local number = i <= 9 and i or (i == 10 and 0 or (i == 11 and "Clear" or "Done"))
                                local row = math.floor((i-1) / 3)
                                local col = (i-1) % 3
                                
                                local NumberButton = CreateElement("TextButton", {
                                    Name = tostring(number),
                                    BackgroundColor3 = Library.Theme.LightContrast,
                                    Position = UDim2.new(col/3, 2, row/4, 2),
                                    Size = UDim2.new(1/3 - 0.02, -2, 1/4 - 0.02, -2),
                                    Font = Library.Fonts.Regular,
                                    Text = tostring(number),
                                    TextColor3 = Library.Theme.TextColor,
                                    TextSize = 24,
                                    ZIndex = 201,
                                    Parent = NumberPad
                                })
                                
                                local NumberButtonCorner = CreateElement("UICorner", {
                                    CornerRadius = UDim.new(0, 6),
                                    Parent = NumberButton
                                })
                                
                                -- Button click handler
                                NumberButton.MouseButton1Click:Connect(function()
                                    if number == "Clear" then
                                        input.Text = "00"
                                    elseif number == "Done" then
                                        NumberPad.Visible = false
                                        input:ReleaseFocus()
                                    else
                                        local currentText = input.Text:gsub("^0+", "")
                                        local newText = currentText .. tostring(number)
                                        local num = tonumber(newText)
                                        
                                        if num and num <= maxValue then
                                            input.Text = string.format("%02d", num)
                                        end
                                    end
                                    
                                    -- Haptic feedback
                                    if game:GetService("HapticService") then
                                        game:GetService("HapticService"):SetMotor(
                                            Enum.UserInputType.Gamepad1,
                                            Enum.VibrationMotor.Small,
                                            0.1
                                        )
                                    end
                                end)
                                
                                -- Touch feedback
                                NumberButton.MouseEnter:Connect(function()
                                    CreateTween(NumberButton, {
                                        BackgroundColor3 = Library.Theme.Primary
                                    }):Play()
                                end)
                                
                                NumberButton.MouseLeave:Connect(function()
                                    CreateTween(NumberButton, {
                                        BackgroundColor3 = Library.Theme.LightContrast
                                    }):Play()
                                end)
                            end
                            
                            return NumberPad
                        end
                        
                        local HourNumberPad = CreateNumberPad(HourInput, 23)
                        local MinuteNumberPad = CreateNumberPad(MinuteInput, 59)
                        
                        HourInput.Focused:Connect(function()
                            MinuteNumberPad.Visible = false
                            HourNumberPad.Visible = true
                        end)
                        
                        MinuteInput.Focused:Connect(function()
                            HourNumberPad.Visible = false
                            MinuteNumberPad.Visible = true
                        end)
                    end
                end
                
                -- Month navigation handlers
                PrevMonthButton.MouseButton1Click:Connect(function()
                    local currentDate = DateTimePicker.Value
                    if currentDate.month == 1 then
                        currentDate.month = 12
                        currentDate.year = currentDate.year - 1
                    else
                        currentDate.month = currentDate.month - 1
                    end
                    MonthYearLabel.Text = os.date("%B %Y", os.time(currentDate))
                    CreateDayButtons()
                end)
                
                NextMonthButton.MouseButton1Click:Connect(function()
                    local currentDate = DateTimePicker.Value
                    if currentDate.month == 12 then
                        currentDate.month = 1
                        currentDate.year = currentDate.year + 1
                    else
                        currentDate.month = currentDate.month + 1
                    end
                    MonthYearLabel.Text = os.date("%B %Y", os.time(currentDate))
                    CreateDayButtons()
                end)
                
                -- Toggle calendar visibility
                DateTimeButton.MouseButton1Click:Connect(function()
                    CalendarFrame.Visible = not CalendarFrame.Visible
                    if CalendarFrame.Visible then
                        CreateDayButtons()
                    end
                end)
                
                -- Close calendar when clicking outside
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                       input.UserInputType == Enum.UserInputType.Touch then
                        local position = input.Position
                        local inCalendar = false
                        
                        -- Check if click/touch is within calendar bounds
                        if CalendarFrame.Visible then
                            local calendarPos = CalendarFrame.AbsolutePosition
                            local calendarSize = CalendarFrame.AbsoluteSize
                            
                            inCalendar = position.X >= calendarPos.X and
                                       position.X <= calendarPos.X + calendarSize.X and
                                       position.Y >= calendarPos.Y and
                                       position.Y <= calendarPos.Y + calendarSize.Y
                                       
                            if not inCalendar and position.Y < DateTimeFrame.AbsolutePosition.Y or
                               position.Y > DateTimeFrame.AbsolutePosition.Y + DateTimeFrame.AbsoluteSize.Y then
                                CalendarFrame.Visible = false
                            end
                        end
                    end
                end)
                
                -- DateTimePicker Methods
                function DateTimePicker:SetValue(date)
                    DateTimePicker.Value = type(date) == "table" and date or os.date("*t", date)
                    UpdateDisplay()
                    if CalendarFrame.Visible then
                        CreateDayButtons()
                    end
                end
                
                function DateTimePicker:GetValue()
                    return DateTimePicker.Value
                end
                
                return DateTimePicker
            end
            -- Enhanced Tree View Creation
            function Section:AddTreeView(name, options)
                local TreeView = {
                    Items = options.items or {},
                    Selected = nil,
                    Expanded = {},
                    Type = "TreeView"
                }
                
                local TreeViewFrame = CreateElement("Frame", {
                    Name = name,
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Size = UDim2.new(1, 0, 0, options.height or 200),
                    Parent = SectionContent
                })
                
                local TreeViewCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = TreeViewFrame
                })
                
                local TreeViewLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 0, 30),
                    Font = Library.Fonts.Regular,
                    Text = name,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = isMobile and 16 or 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TreeViewFrame
                })
                
                local TreeViewContainer = CreateElement("ScrollingFrame", {
                    Name = "Container",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 35),
                    Size = UDim2.new(1, -10, 1, -40),
                    ScrollBarThickness = 3,
                    ScrollingDirection = Enum.ScrollingDirection.Y,
                    Parent = TreeViewFrame
                })
                
                local TreeViewLayout = CreateElement("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    Parent = TreeViewContainer
                })
                
                -- Create tree item
                local function CreateTreeItem(item, depth)
                    local ItemFrame = CreateElement("Frame", {
                        Name = item.text,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, isMobile and 40 or 30),
                        Parent = TreeViewContainer
                    })
                    
                    local ItemButton = CreateElement("TextButton", {
                        Name = "Button",
                        BackgroundColor3 = Library.Theme.DarkContrast,
                        Position = UDim2.new(0, depth * (isMobile and 25 or 20), 0, 0),
                        Size = UDim2.new(1, -(depth * (isMobile and 25 or 20)), 1, 0),
                        Font = Library.Fonts.Regular,
                        Text = "",
                        TextColor3 = Library.Theme.TextColor,
                        TextSize = isMobile and 16 or 14,
                        Parent = ItemFrame
                    })
                    
                    local ItemCorner = CreateElement("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = ItemButton
                    })
                    
                    -- Expand/Collapse arrow if item has children
                    if item.children and #item.children > 0 then
                        local ExpandArrow = CreateElement("TextLabel", {
                            Name = "Arrow",
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 5, 0, 0),
                            Size = UDim2.new(0, isMobile and 25 or 20, 1, 0),
                            Font = Library.Fonts.Regular,
                            Text = TreeView.Expanded[item.text] and "▼" or "▶",
                            TextColor3 = Library.Theme.TextColor,
                            TextSize = isMobile and 16 or 14,
                            Parent = ItemButton
                        })
                    end
                    
                    local ItemLabel = CreateElement("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, item.children and (isMobile and 30 or 25) or 5, 0, 0),
                        Size = UDim2.new(1, -(item.children and (isMobile and 35 or 30) or 10), 1, 0),
                        Font = Library.Fonts.Regular,
                        Text = item.text,
                        TextColor3 = Library.Theme.TextColor,
                        TextSize = isMobile and 16 or 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = ItemButton
                    })
                    
                    -- Item icon (if provided)
                    if item.icon then
                        local ItemIcon = CreateElement("ImageLabel", {
                            Name = "Icon",
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, item.children and (isMobile and 30 or 25) or 5, 0.5, -8),
                            Size = UDim2.new(0, 16, 0, 16),
                            Image = item.icon,
                            Parent = ItemButton
                        })
                        
                        ItemLabel.Position = UDim2.new(0, (item.children and (isMobile and 50 or 45) or 25), 0, 0)
                        ItemLabel.Size = UDim2.new(1, -(item.children and (isMobile and 55 or 50) or 30), 1, 0)
                    end
                    
                    -- Item click handler
                    ItemButton.MouseButton1Click:Connect(function()
                        if item.children and #item.children > 0 then
                            TreeView.Expanded[item.text] = not TreeView.Expanded[item.text]
                            UpdateTree()
                        end
                        
                        TreeView.Selected = item
                        
                        -- Update selection visuals
                        for _, child in pairs(TreeViewContainer:GetChildren()) do
                            if child:IsA("Frame") then
                                local button = child:FindFirstChild("Button")
                                if button then
                                    CreateTween(button, {
                                        BackgroundColor3 = child.Name == item.text and 
                                            Library.Theme.Primary or Library.Theme.DarkContrast
                                    }):Play()
                                end
                            end
                        end
                        
                        if options.callback then
                            options.callback(item)
                        end
                        
                        -- Mobile feedback
                        if isMobile then
                            if game:GetService("HapticService") then
                                game:GetService("HapticService"):SetMotor(
                                    Enum.UserInputType.Gamepad1,
                                    Enum.VibrationMotor.Small,
                                    0.2
                                )
                            end
                        end
                    end)
                    
                    -- Hover effects
                    ItemButton.MouseEnter:Connect(function()
                        if TreeView.Selected and TreeView.Selected.text ~= item.text then
                            CreateTween(ItemButton, {
                                BackgroundColor3 = Library.Theme.Primary
                            }):Play()
                        end
                    end)
                    
                    ItemButton.MouseLeave:Connect(function()
                        if TreeView.Selected and TreeView.Selected.text ~= item.text then
                            CreateTween(ItemButton, {
                                BackgroundColor3 = Library.Theme.DarkContrast
                            }):Play()
                        end
                    end)
                    
                    return ItemFrame
                end
                -- Update tree view
                local function UpdateTree(items, depth)
                    items = items or TreeView.Items
                    depth = depth or 0
                    
                    -- Clear existing items if at root level
                    if depth == 0 then
                        for _, child in pairs(TreeViewContainer:GetChildren()) do
                            if child:IsA("Frame") then
                                child:Destroy()
                            end
                        end
                    end
                    
                    -- Create/update items
                    for _, item in ipairs(items) do
                        local ItemFrame = CreateTreeItem(item, depth)
                        
                        -- Handle children if expanded
                        if item.children and #item.children > 0 and TreeView.Expanded[item.text] then
                            UpdateTree(item.children, depth + 1)
                        end
                    end
                    
                    -- Update ScrollingFrame canvas size
                    TreeViewContainer.CanvasSize = UDim2.new(0, 0, 0, TreeViewLayout.AbsoluteContentSize.Y)
                end
                
                -- TreeView Methods
                function TreeView:SetItems(items)
                    TreeView.Items = items
                    TreeView.Selected = nil
                    TreeView.Expanded = {}
                    UpdateTree()
                end
                
                function TreeView:ExpandAll()
                    local function ExpandItems(items)
                        for _, item in ipairs(items) do
                            if item.children and #item.children > 0 then
                                TreeView.Expanded[item.text] = true
                                ExpandItems(item.children)
                            end
                        end
                    end
                    
                    ExpandItems(TreeView.Items)
                    UpdateTree()
                end
                
                function TreeView:CollapseAll()
                    TreeView.Expanded = {}
                    UpdateTree()
                end
                
                -- Initial update
                UpdateTree()
                
                return TreeView
            end
            
            -- Enhanced Data Grid Creation
            function Section:AddDataGrid(name, options)
                local DataGrid = {
                    Columns = options.columns or {},
                    Data = options.data or {},
                    Sort = {
                        Column = nil,
                        Ascending = true
                    },
                    Selected = nil,
                    Type = "DataGrid"
                }
                
                local DataGridFrame = CreateElement("Frame", {
                    Name = name,
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Size = UDim2.new(1, 0, 0, options.height or 300),
                    Parent = SectionContent
                })
                
                local DataGridCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = DataGridFrame
                })
                
                local DataGridLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 0, 30),
                    Font = Library.Fonts.Regular,
                    Text = name,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = isMobile and 16 or 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DataGridFrame
                })
                
                -- Header Container
                local HeaderContainer = CreateElement("Frame", {
                    Name = "Header",
                    BackgroundColor3 = Library.Theme.DarkContrast,
                    Position = UDim2.new(0, 5, 0, 35),
                    Size = UDim2.new(1, -10, 0, isMobile and 40 or 30),
                    Parent = DataGridFrame
                })
                
                local HeaderCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = HeaderContainer
                })
                
                -- Data Container
                local DataContainer = CreateElement("ScrollingFrame", {
                    Name = "Data",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, isMobile and 80 or 70),
                    Size = UDim2.new(1, -10, 1, -(isMobile and 85 or 75)),
                    ScrollBarThickness = 3,
                    ScrollingDirection = Enum.ScrollingDirection.Y,
                    Parent = DataGridFrame
                })
                
                local DataLayout = CreateElement("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    Parent = DataContainer
                })
                
                -- Create column headers
                local totalWeight = 0
                for _, column in ipairs(DataGrid.Columns) do
                    totalWeight = totalWeight + (column.weight or 1)
                end
                
                local currentPosition = 0
                for _, column in ipairs(DataGrid.Columns) do
                    local weight = column.weight or 1
                    local width = weight / totalWeight
                    
                    local HeaderButton = CreateElement("TextButton", {
                        Name = column.name,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(currentPosition, 0, 0, 0),
                        Size = UDim2.new(width, 0, 1, 0),
                        Font = Library.Fonts.Regular,
                        Text = column.name,
                        TextColor3 = Library.Theme.TextColor,
                        TextSize = isMobile and 16 or 14,
                        Parent = HeaderContainer
                    })
                    
                    -- Sort indicator
                    local SortIndicator = CreateElement("TextLabel", {
                        Name = "SortIndicator",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -20, 0, 0),
                        Size = UDim2.new(0, 20, 1, 0),
                        Font = Library.Fonts.Regular,
                        Text = "",
                        TextColor3 = Library.Theme.TextColor,
                        TextSize = isMobile and 16 or 14,
                        Parent = HeaderButton
                    })
                    
                    -- Header click handler for sorting
                    HeaderButton.MouseButton1Click:Connect(function()
                        if DataGrid.Sort.Column == column.name then
                            DataGrid.Sort.Ascending = not DataGrid.Sort.Ascending
                        else
                            DataGrid.Sort.Column = column.name
                            DataGrid.Sort.Ascending = true
                        end
                        
                        -- Update sort indicators
                        for _, header in pairs(HeaderContainer:GetChildren()) do
                            if header:IsA("TextButton") then
                                local indicator = header:FindFirstChild("SortIndicator")
                                if indicator then
                                    indicator.Text = header.Name == DataGrid.Sort.Column and
                                        (DataGrid.Sort.Ascending and "▲" or "▼") or ""
                                end
                            end
                        end
                        
                        UpdateDataGrid()
                    end)
                    
                    currentPosition = currentPosition + width
                end
                -- Update data grid
                local function UpdateDataGrid()
                    -- Clear existing rows
                    for _, child in pairs(DataContainer:GetChildren()) do
                        if child:IsA("Frame") then
                            child:Destroy()
                        end
                    end
                    
                    -- Sort data if needed
                    local sortedData = table.clone(DataGrid.Data)
                    if DataGrid.Sort.Column then
                        table.sort(sortedData, function(a, b)
                            local aValue = a[DataGrid.Sort.Column]
                            local bValue = b[DataGrid.Sort.Column]
                            
                            if DataGrid.Sort.Ascending then
                                if type(aValue) == "string" then
                                    return aValue:lower() < bValue:lower()
                                else
                                    return aValue < bValue
                                end
                            else
                                if type(aValue) == "string" then
                                    return aValue:lower() > bValue:lower()
                                else
                                    return aValue > bValue
                                end
                            end
                        end)
                    end
                    
                    -- Create rows
                    for _, rowData in ipairs(sortedData) do
                        local RowFrame = CreateElement("Frame", {
                            Name = "Row",
                            BackgroundColor3 = Library.Theme.DarkContrast,
                            Size = UDim2.new(1, 0, 0, isMobile and 40 or 30),
                            Parent = DataContainer
                        })
                        
                        local RowCorner = CreateElement("UICorner", {
                            CornerRadius = UDim.new(0, 4),
                            Parent = RowFrame
                        })
                        
                        -- Create cells
                        local currentPosition = 0
                        for _, column in ipairs(DataGrid.Columns) do
                            local weight = column.weight or 1
                            local width = weight / totalWeight
                            
                            local CellFrame = CreateElement("Frame", {
                                Name = column.name,
                                BackgroundTransparency = 1,
                                Position = UDim2.new(currentPosition, 0, 0, 0),
                                Size = UDim2.new(width, 0, 1, 0),
                                Parent = RowFrame
                            })
                            
                            -- Cell content based on column type
                            if column.type == "image" then
                                local ImageLabel = CreateElement("ImageLabel", {
                                    Name = "Image",
                                    BackgroundTransparency = 1,
                                    Position = UDim2.new(0, 5, 0.5, -10),
                                    Size = UDim2.new(0, 20, 0, 20),
                                    Image = rowData[column.name],
                                    Parent = CellFrame
                                })
                            elseif column.type == "button" then
                                local Button = CreateElement("TextButton", {
                                    Name = "Button",
                                    BackgroundColor3 = Library.Theme.Primary,
                                    Position = UDim2.new(0, 5, 0.5, -12),
                                    Size = UDim2.new(1, -10, 0, 24),
                                    Font = Library.Fonts.Regular,
                                    Text = rowData[column.name],
                                    TextColor3 = Library.Theme.TextColor,
                                    TextSize = isMobile and 16 or 14,
                                    Parent = CellFrame
                                })
                                
                                local ButtonCorner = CreateElement("UICorner", {
                                    CornerRadius = UDim.new(0, 4),
                                    Parent = Button
                                })
                                
                                Button.MouseButton1Click:Connect(function()
                                    if column.callback then
                                        column.callback(rowData)
                                    end
                                end)
                            else
                                local TextLabel = CreateElement("TextLabel", {
                                    Name = "Text",
                                    BackgroundTransparency = 1,
                                    Position = UDim2.new(0, 5, 0, 0),
                                    Size = UDim2.new(1, -10, 1, 0),
                                    Font = Library.Fonts.Regular,
                                    Text = tostring(rowData[column.name]),
                                    TextColor3 = Library.Theme.TextColor,
                                    TextSize = isMobile and 16 or 14,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    TextTruncate = Enum.TextTruncate.AtEnd,
                                    Parent = CellFrame
                                })
                            end
                            
                            currentPosition = currentPosition + width
                        end
                        
                        -- Row selection
                        RowFrame.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or
                               input.UserInputType == Enum.UserInputType.Touch then
                                DataGrid.Selected = rowData
                                
                                -- Update selection visuals
                                for _, row in pairs(DataContainer:GetChildren()) do
                                    if row:IsA("Frame") then
                                        CreateTween(row, {
                                            BackgroundColor3 = row == RowFrame and
                                                Library.Theme.Primary or Library.Theme.DarkContrast
                                        }):Play()
                                    end
                                end
                                
                                if options.onSelect then
                                    options.onSelect(rowData)
                                end
                                
                                -- Mobile feedback
                                if isMobile and game:GetService("HapticService") then
                                    game:GetService("HapticService"):SetMotor(
                                        Enum.UserInputType.Gamepad1,
                                        Enum.VibrationMotor.Small,
                                        0.2
                                    )
                                end
                            end
                        end)
                        
                        -- Hover effect
                        RowFrame.MouseEnter:Connect(function()
                            if DataGrid.Selected ~= rowData then
                                CreateTween(RowFrame, {
                                    BackgroundColor3 = Library.Theme.Primary
                                }):Play()
                            end
                        end)
                        
                        RowFrame.MouseLeave:Connect(function()
                            if DataGrid.Selected ~= rowData then
                                CreateTween(RowFrame, {
                                    BackgroundColor3 = Library.Theme.DarkContrast
                                }):Play()
                            end
                        end)
                    end
                    
                    -- Update ScrollingFrame canvas size
                    DataContainer.CanvasSize = UDim2.new(0, 0, 0, DataLayout.AbsoluteContentSize.Y)
                end
                -- DataGrid Methods
                function DataGrid:SetData(data)
                    DataGrid.Data = data
                    DataGrid.Selected = nil
                    UpdateDataGrid()
                end
                
                function DataGrid:GetSelected()
                    return DataGrid.Selected
                end
                
                function DataGrid:RefreshData()
                    UpdateDataGrid()
                end
                
                -- Initial update
                UpdateDataGrid()
                
                return DataGrid
            end
            
            -- Theme Editor Component
            function Section:AddThemeEditor()
                local ThemeEditor = {
                    Type = "ThemeEditor"
                }
                
                local ThemeEditorFrame = CreateElement("Frame", {
                    Name = "ThemeEditor",
                    BackgroundColor3 = Library.Theme.LightContrast,
                    Size = UDim2.new(1, 0, 0, isMobile and 400 or 300),
                    Parent = SectionContent
                })
                
                local ThemeEditorCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = ThemeEditorFrame
                })
                
                local ThemeEditorLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 0, 30),
                    Font = Library.Fonts.Regular,
                    Text = "Theme Editor",
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = isMobile and 16 or 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ThemeEditorFrame
                })
                
                local ThemeContainer = CreateElement("ScrollingFrame", {
                    Name = "Container",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 5, 0, 35),
                    Size = UDim2.new(1, -10, 1, -40),
                    ScrollBarThickness = 3,
                    ScrollingDirection = Enum.ScrollingDirection.Y,
                    Parent = ThemeEditorFrame
                })
                
                local ThemeLayout = CreateElement("UIListLayout", {
                    Padding = UDim.new(0, 5),
                    Parent = ThemeContainer
                })
                
                -- Create color pickers for each theme color
                local colorOptions = {
                    {"Primary", "Main accent color"},
                    {"Secondary", "Secondary accent color"},
                    {"Background", "Background color"},
                    {"TextColor", "Text color"},
                    {"AccentColor", "Highlight color"},
                    {"DarkContrast", "Dark contrast color"},
                    {"LightContrast", "Light contrast color"}
                }
                
                for _, option in ipairs(colorOptions) do
                    local ColorFrame = CreateElement("Frame", {
                        Name = option[1],
                        BackgroundColor3 = Library.Theme.DarkContrast,
                        Size = UDim2.new(1, 0, 0, isMobile and 60 or 50),
                        Parent = ThemeContainer
                    })
                    
                    local ColorCorner = CreateElement("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = ColorFrame
                    })
                    
                    local ColorLabel = CreateElement("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -120, 0, isMobile and 30 or 25),
                        Font = Library.Fonts.Regular,
                        Text = option[1],
                        TextColor3 = Library.Theme.TextColor,
                        TextSize = isMobile and 16 or 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = ColorFrame
                    })
                    
                    local ColorDescription = CreateElement("TextLabel", {
                        Name = "Description",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, isMobile and 30 or 25),
                        Size = UDim2.new(1, -120, 0, isMobile and 30 or 25),
                        Font = Library.Fonts.Regular,
                        Text = option[2],
                        TextColor3 = Library.Theme.TextColor,
                        TextSize = isMobile and 14 or 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTransparency = 0.5,
                        Parent = ColorFrame
                    })
                    local ColorDisplay = CreateElement("Frame", {
                        Name = "Display",
                        BackgroundColor3 = Library.Theme[option[1]],
                        Position = UDim2.new(1, -110, 0.5, -20),
                        Size = UDim2.new(0, 100, 0, 40),
                        Parent = ColorFrame
                    })
                    
                    local ColorDisplayCorner = CreateElement("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = ColorDisplay
                    })
                    
                    -- Color Picker Popup
                    local ColorPicker = CreateElement("Frame", {
                        Name = "ColorPicker",
                        BackgroundColor3 = Library.Theme.DarkContrast,
                        Position = UDim2.new(1, 10, 0, 0),
                        Size = UDim2.new(0, isMobile and 200 or 180, 0, isMobile and 240 or 200),
                        Visible = false,
                        ZIndex = 100,
                        Parent = ColorFrame
                    })
                    
                    local ColorPickerCorner = CreateElement("UICorner", {
                        CornerRadius = UDim.new(0, 6),
                        Parent = ColorPicker
                    })
                    
                    -- Color gradient
                    local ColorGradient = CreateElement("Frame", {
                        Name = "Gradient",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Position = UDim2.new(0, 5, 0, 5),
                        Size = UDim2.new(1, -10, 0, isMobile and 180 or 150),
                        ZIndex = 101,
                        Parent = ColorPicker
                    })
                    
                    local ColorGradientCorner = CreateElement("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = ColorGradient
                    })
                    
                    -- Create color gradient
                    local ColorGradientUIGradient = CreateElement("UIGradient", {
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                            ColorSequenceKeypoint.new(1, Library.Theme[option[1]])
                        }),
                        Parent = ColorGradient
                    })
                    
                    local BlackGradient = CreateElement("UIGradient", {
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                        }),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(1, 1)
                        }),
                        Rotation = 90,
                        Parent = ColorGradient
                    })
                    
                    -- Color picker cursor
                    local ColorCursor = CreateElement("Frame", {
                        Name = "Cursor",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(1, 0, 0, 0),
                        Size = UDim2.new(0, isMobile and 16 or 12, 0, isMobile and 16 or 12),
                        ZIndex = 102,
                        Parent = ColorGradient
                    })
                    
                    local ColorCursorCorner = CreateElement("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = ColorCursor
                    })
                    
                    -- Hue slider
                    local HueSlider = CreateElement("Frame", {
                        Name = "HueSlider",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Position = UDim2.new(0, 5, 1, -(isMobile and 50 or 40)),
                        Size = UDim2.new(1, -10, 0, isMobile and 30 or 20),
                        ZIndex = 101,
                        Parent = ColorPicker
                    })
                    
                    local HueSliderCorner = CreateElement("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = HueSlider
                    })
                    
                    local HueGradient = CreateElement("UIGradient", {
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                            ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                        }),
                        Parent = HueSlider
                    })
                    
                    -- Hue slider cursor
                    local HueCursor = CreateElement("Frame", {
                        Name = "Cursor",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        Size = UDim2.new(0, isMobile and 8 or 6, 1, isMobile and 8 or 6),
                        ZIndex = 102,
                        Parent = HueSlider
                    })
                    
                    local HueCursorCorner = CreateElement("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = HueCursor
                    })
                    
                    -- Color picker functionality
                    local pickerHue, pickerSat, pickerVal = 0, 0, 1
                    local draggingHue, draggingColor = false, false
                    
                    local function UpdateColor()
                        local color = Color3.fromHSV(pickerHue, pickerSat, pickerVal)
                        ColorDisplay.BackgroundColor3 = color
                        Library.Theme[option[1]] = color
                        ColorGradientUIGradient.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromHSV(pickerHue, 1, 1))
                        })
                        
                        -- Update all UI elements using this color
                        for _, element in pairs(Library.Elements) do
                            if element.ThemeColor == option[1] then
                                CreateTween(element.Instance, {
                                    BackgroundColor3 = color
                                }):Play()
                            end
                        end
                    end
                    -- Color picker input handlers
                    ColorGradient.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or
                           input.UserInputType == Enum.UserInputType.Touch then
                            draggingColor = true
                            
                            -- Mobile feedback
                            if isMobile and game:GetService("HapticService") then
                                game:GetService("HapticService"):SetMotor(
                                    Enum.UserInputType.Gamepad1,
                                    Enum.VibrationMotor.Small,
                                    0.1
                                )
                            end
                        end
                    end)
                    
                    HueSlider.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or
                           input.UserInputType == Enum.UserInputType.Touch then
                            draggingHue = true
                            
                            -- Mobile feedback
                            if isMobile and game:GetService("HapticService") then
                                game:GetService("HapticService"):SetMotor(
                                    Enum.UserInputType.Gamepad1,
                                    Enum.VibrationMotor.Small,
                                    0.1
                                )
                            end
                        end
                    end)
                    
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or
                           input.UserInputType == Enum.UserInputType.Touch then
                            draggingColor = false
                            draggingHue = false
                        end
                    end)
                    
                    UserInputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement or
                           input.UserInputType == Enum.UserInputType.Touch then
                            if draggingColor then
                                local colorPos = Vector2.new(
                                    math.clamp(input.Position.X - ColorGradient.AbsolutePosition.X, 0, ColorGradient.AbsoluteSize.X),
                                    math.clamp(input.Position.Y - ColorGradient.AbsolutePosition.Y, 0, ColorGradient.AbsoluteSize.Y)
                                )
                                
                                ColorCursor.Position = UDim2.new(
                                    colorPos.X / ColorGradient.AbsoluteSize.X,
                                    0,
                                    colorPos.Y / ColorGradient.AbsoluteSize.Y,
                                    0
                                )
                                
                                pickerSat = colorPos.X / ColorGradient.AbsoluteSize.X
                                pickerVal = 1 - (colorPos.Y / ColorGradient.AbsoluteSize.Y)
                                UpdateColor()
                            elseif draggingHue then
                                local huePos = math.clamp(input.Position.X - HueSlider.AbsolutePosition.X, 0, HueSlider.AbsoluteSize.X)
                                HueCursor.Position = UDim2.new(huePos / HueSlider.AbsoluteSize.X, 0, 0.5, 0)
                                
                                pickerHue = huePos / HueSlider.AbsoluteSize.X
                                UpdateColor()
                            end
                        end
                    end)
                    
                    -- Toggle color picker visibility
                    ColorDisplay.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or
                           input.UserInputType == Enum.UserInputType.Touch then
                            ColorPicker.Visible = not ColorPicker.Visible
                            
                            -- Close other color pickers
                            for _, frame in pairs(ThemeContainer:GetChildren()) do
                                if frame:IsA("Frame") and frame ~= ColorFrame then
                                    local picker = frame:FindFirstChild("ColorPicker")
                                    if picker then
                                        picker.Visible = false
                                    end
                                end
                            end
                        end
                    end)
                end
                
                -- Configuration System
                local ConfigSystem = {}
                
                function ConfigSystem:SaveConfig(name)
                    local config = {
                        Theme = Library.Theme,
                        Settings = Library.Settings,
                        Elements = {}
                    }
                    
                    -- Save element states
                    for _, element in pairs(Library.Elements) do
                        if element.Type and element.Value ~= nil then
                            config.Elements[element.ID] = {
                                Type = element.Type,
                                Value = element.Value
                            }
                        end
                    end
                    
                    -- Save to file
                    local success, result = pcall(function()
                        return game:GetService("HttpService"):JSONEncode(config)
                    end)
                    
                    if success then
                        writefile("SynthwaveUI/configs/" .. name .. ".json", result)
                        Library:Notify({
                            title = "Configuration Saved",
                            text = "Successfully saved config: " .. name,
                            duration = 3
                        })
                    else
                        Library:Notify({
                            title = "Save Error",
                            text = "Failed to save configuration",
                            duration = 3,
                            type = "error"
                        })
                    end
                end
                
                function ConfigSystem:LoadConfig(name)
                    -- Check if config exists
                    if not isfile("SynthwaveUI/configs/" .. name .. ".json") then
                        Library:Notify({
                            title = "Load Error",
                            text = "Configuration file not found",
                            duration = 3,
                            type = "error"
                        })
                        return
                    end
                    
                    -- Read and parse config
                    local success, config = pcall(function()
                        return game:GetService("HttpService"):JSONDecode(
                            readfile("SynthwaveUI/configs/" .. name .. ".json")
                        )
                    end)
                    
                    if success then
                        -- Apply theme
                        for key, value in pairs(config.Theme) do
                            Library.Theme[key] = Color3.new(value.R, value.G, value.B)
                        end
                        
                        -- Apply settings
                        for key, value in pairs(config.Settings) do
                            Library.Settings[key] = value
                        end
                        
                        -- Apply element states
                        for id, data in pairs(config.Elements) do
                            local element = Library.Elements[id]
                            if element and element.Type == data.Type then
                                element:Set(data.Value)
                            end
                        end
                        
                        Library:Notify({
                            title = "Configuration Loaded",
                            text = "Successfully loaded config: " .. name,
                            duration = 3
                        })
                    else
                        Library:Notify({
                            title = "Load Error",
                            text = "Failed to load configuration",
                            duration = 3,
                            type = "error"
                        })
                    end
                end
                function ConfigSystem:GetConfigs()
                    local configs = {}
                    
                    -- Create config directory if it doesn't exist
                    if not isfolder("SynthwaveUI/configs") then
                        makefolder("SynthwaveUI/configs")
                    end
                    
                    -- List all config files
                    for _, file in pairs(listfiles("SynthwaveUI/configs")) do
                        if file:sub(-5) == ".json" then
                            table.insert(configs, file:sub(19, -6))
                        end
                    end
                    
                    return configs
                end
                
                -- Add config system to Library
                Library.Config = ConfigSystem
                
                -- Notification Queue System
                Library.NotificationQueue = {
                    Notifications = {},
                    MaxNotifications = 5,
                    Padding = isMobile and 20 or 10
                }
                
                function Library:Notify(options)
                    local Notification = {
                        Title = options.title or "Notification",
                        Text = options.text or "",
                        Duration = options.duration or 3,
                        Type = options.type or "info" -- info, success, warning, error
                    }
                    
                    -- Create notification GUI
                    local NotificationGui = CreateElement("ScreenGui", {
                        Name = "Notification",
                        Parent = game:GetService("CoreGui")
                    })
                    
                    local NotificationFrame = CreateElement("Frame", {
                        Name = "Frame",
                        BackgroundColor3 = Library.Theme.DarkContrast,
                        Position = UDim2.new(1, 20, 0.9, 0),
                        Size = UDim2.new(0, isMobile and 300 or 250, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Parent = NotificationGui
                    })
                    
                    local NotificationCorner = CreateElement("UICorner", {
                        CornerRadius = UDim.new(0, 6),
                        Parent = NotificationFrame
                    })
                    
                    -- Add glow effect
                    local Glow = CreateElement("ImageLabel", {
                        Name = "Glow",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, -15, 0, -15),
                        Size = UDim2.new(1, 30, 1, 30),
                        ZIndex = 0,
                        Image = "rbxassetid://5028857084",
                        ImageColor3 = (
                            Notification.Type == "success" and Color3.fromRGB(0, 255, 0) or
                            Notification.Type == "warning" and Color3.fromRGB(255, 255, 0) or
                            Notification.Type == "error" and Color3.fromRGB(255, 0, 0) or
                            Library.Theme.Primary
                        ),
                        ImageTransparency = 0.6,
                        Parent = NotificationFrame
                    })
                    
                    -- Add icon based on type
                    local Icon = CreateElement("ImageLabel", {
                        Name = "Icon",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 10),
                        Size = UDim2.new(0, 20, 0, 20),
                        Image = (
                            Notification.Type == "success" and "rbxassetid://9073052584" or
                            Notification.Type == "warning" and "rbxassetid://9073052899" or
                            Notification.Type == "error" and "rbxassetid://9072448788" or
                            "rbxassetid://9073052697"
                        ),
                        Parent = NotificationFrame
                    })
                    
                    local Title = CreateElement("TextLabel", {
                        Name = "Title",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 40, 0, 10),
                        Size = UDim2.new(1, -50, 0, 20),
                        Font = Library.Fonts.Bold,
                        Text = Notification.Title,
                        TextColor3 = Library.Theme.TextColor,
                        TextSize = isMobile and 16 or 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = NotificationFrame
                    })
                    
                    local Text = CreateElement("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 35),
                        Size = UDim2.new(1, -20, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Font = Library.Fonts.Regular,
                        Text = Notification.Text,
                        TextColor3 = Library.Theme.TextColor,
                        TextSize = isMobile and 14 or 12,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = NotificationFrame
                    })
                    
                    local Padding = CreateElement("UIPadding", {
                        PaddingBottom = UDim.new(0, 10),
                        Parent = NotificationFrame
                    })
                    
                    -- Add to queue
                    table.insert(Library.NotificationQueue.Notifications, {
                        Gui = NotificationGui,
                        Frame = NotificationFrame,
                        StartTime = tick(),
                        Duration = Notification.Duration
                    })
                    
                    -- Update notification positions
                    local function UpdateNotifications()
                        local screenSize = workspace.CurrentCamera.ViewportSize
                        local totalHeight = 0
                        
                        for i = #Library.NotificationQueue.Notifications, 1, -1 do
                            local notif = Library.NotificationQueue.Notifications[i]
                            if notif and notif.Frame then
                                local height = notif.Frame.AbsoluteSize.Y + Library.NotificationQueue.Padding
                                
                                -- Position notification
                                CreateTween(notif.Frame, {
                                    Position = UDim2.new(1, -notif.Frame.AbsoluteSize.X - 20, 1, -totalHeight - height)
                                }):Play()
                                
                                totalHeight = totalHeight + height
                                
                                -- Remove if expired
                                if tick() - notif.StartTime >= notif.Duration then
                                    -- Fade out animation
                                    local fadeOut = CreateTween(notif.Frame, {
                                        Position = UDim2.new(1, 20, 1, -totalHeight + height),
                                        Transparency = 1
                                    }, 0.2)
                                    
                                    fadeOut:Play()
                                    fadeOut.Completed:Connect(function()
                                        notif.Gui:Destroy()
                                        table.remove(Library.NotificationQueue.Notifications, i)
                                    end)
                                end
                            end
                        end
                        
                        -- Remove excess notifications
                        while #Library.NotificationQueue.Notifications > Library.NotificationQueue.MaxNotifications do
                            local notif = table.remove(Library.NotificationQueue.Notifications, 1)
                            if notif and notif.Gui then
                                notif.Gui:Destroy()
                            end
                        end
                    end
                    -- Start notification update loop
                    if not Library.NotificationUpdateLoop then
                        Library.NotificationUpdateLoop = RunService.RenderStepped:Connect(function()
                            UpdateNotifications()
                        end)
                    end
                    
                    -- Initial position animation
                    NotificationFrame.Position = UDim2.new(1, 20, 0.9, 0)
                    CreateTween(NotificationFrame, {
                        Position = UDim2.new(1, -NotificationFrame.AbsoluteSize.X - 20, 0.9, 0)
                    }):Play()
                end
                
                -- Window Management System
                local WindowManager = {
                    MinimizedWindows = {},
                    Dragging = false,
                    DragStart = nil,
                    StartPosition = nil
                }
                
                function WindowManager:SetupWindow(window)
                    local topBar = window:FindFirstChild("TopBar")
                    if not topBar then return end
                    
                    -- Minimize button
                    local MinimizeButton = CreateElement("ImageButton", {
                        Name = "Minimize",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -70, 0.5, -10),
                        Size = UDim2.new(0, 20, 0, 20),
                        Image = "rbxassetid://9147544869",
                        Parent = topBar
                    })
                    
                    -- Pin button
                    local PinButton = CreateElement("ImageButton", {
                        Name = "Pin",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -40, 0.5, -10),
                        Size = UDim2.new(0, 20, 0, 20),
                        Image = "rbxassetid://9147544967",
                        Parent = topBar
                    })
                    
                    -- Window dragging
                    local function UpdateDrag(input)
                        if WindowManager.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement or
                           input.UserInputType == Enum.UserInputType.Touch then
                            local delta = input.Position - WindowManager.DragStart
                            local position = UDim2.new(
                                WindowManager.StartPosition.X.Scale,
                                WindowManager.StartPosition.X.Offset + delta.X,
                                WindowManager.StartPosition.Y.Scale,
                                WindowManager.StartPosition.Y.Offset + delta.Y
                            )
                            
                            -- Smooth dragging with tweening
                            CreateTween(window, {
                                Position = position
                            }, 0.1, Enum.EasingStyle.Linear):Play()
                        end
                    end
                    
                    topBar.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or
                           input.UserInputType == Enum.UserInputType.Touch then
                            WindowManager.Dragging = true
                            WindowManager.DragStart = input.Position
                            WindowManager.StartPosition = window.Position
                            
                            input.Changed:Connect(function()
                                if input.UserInputState == Enum.UserInputState.End then
                                    WindowManager.Dragging = false
                                end
                            end)
                        end
                    end)
                    
                    UserInputService.InputChanged:Connect(UpdateDrag)
                    
                    -- Minimize functionality
                    local minimized = false
                    MinimizeButton.MouseButton1Click:Connect(function()
                        minimized = not minimized
                        
                        if minimized then
                            -- Store current size
                            WindowManager.MinimizedWindows[window] = window.Size
                            
                            -- Minimize animation
                            CreateTween(window, {
                                Size = UDim2.new(window.Size.X.Scale, window.Size.X.Offset, 0, 40)
                            }):Play()
                            
                            -- Update button image
                            MinimizeButton.Image = "rbxassetid://9147545042" -- Maximize icon
                        else
                            -- Restore animation
                            CreateTween(window, {
                                Size = WindowManager.MinimizedWindows[window]
                            }):Play()
                            
                            -- Update button image
                            MinimizeButton.Image = "rbxassetid://9147544869" -- Minimize icon
                        end
                    end)
                    
                    -- Pin functionality
                    local pinned = false
                    PinButton.MouseButton1Click:Connect(function()
                        pinned = not pinned
                        window.Draggable = not pinned
                        
                        -- Update button image
                        PinButton.Image = pinned and 
                            "rbxassetid://9147545152" or -- Pinned icon
                            "rbxassetid://9147544967"     -- Unpinned icon
                    end)
                    
                    -- Mobile-friendly corner resize
                    local ResizeButton = CreateElement("ImageButton", {
                        Name = "Resize",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -20, 1, -20),
                        Size = UDim2.new(0, 20, 0, 20),
                        Image = "rbxassetid://9147545326",
                        Parent = window
                    })
                    
                    local resizing = false
                    local minSize = Vector2.new(400, 300)
                    
                    ResizeButton.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or
                           input.UserInputType == Enum.UserInputType.Touch then
                            resizing = true
                            
                            -- Mobile feedback
                            if isMobile and game:GetService("HapticService") then
                                game:GetService("HapticService"):SetMotor(
                                    Enum.UserInputType.Gamepad1,
                                    Enum.VibrationMotor.Small,
                                    0.2
                                )
                            end
                        end
                    end)
                    
                    UserInputService.InputChanged:Connect(function(input)
                        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or
                           input.UserInputType == Enum.UserInputType.Touch) then
                            local delta = input.Position - window.AbsolutePosition
                            local newSize = Vector2.new(
                                math.max(delta.X, minSize.X),
                                math.max(delta.Y, minSize.Y)
                            )
                            
                            CreateTween(window, {
                                Size = UDim2.new(0, newSize.X, 0, newSize.Y)
                            }, 0.1, Enum.EasingStyle.Linear):Play()
                        end
                    end)
                    
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or
                           input.UserInputType == Enum.UserInputType.Touch then
                            resizing = false
                        end
                    end)
                end
                -- Keyboard Shortcuts System
                Library.Shortcuts = {
                    Binds = {},
                    Enabled = true
                }
                
                function Library.Shortcuts:Add(shortcut)
                    table.insert(self.Binds, {
                        Keys = shortcut.keys,
                        Callback = shortcut.callback,
                        Name = shortcut.name,
                        Description = shortcut.description
                    })
                end
                
                -- Handle keyboard input
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not Library.Shortcuts.Enabled or gameProcessed then return end
                    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    
                    -- Check for matching shortcuts
                    for _, shortcut in ipairs(Library.Shortcuts.Binds) do
                        local allKeysPressed = true
                        
                        for _, key in ipairs(shortcut.Keys) do
                            if not UserInputService:IsKeyDown(key) then
                                allKeysPressed = false
                                break
                            end
                        end
                        
                        if allKeysPressed then
                            shortcut.Callback()
                            
                            -- Show shortcut notification
                            Library:Notify({
                                title = "Shortcut Activated",
                                text = shortcut.Name,
                                duration = 1
                            })
                        end
                    end
                end)
                
                -- Rich Text Display Component
                function Section:AddRichText(options)
                    local RichText = {
                        Type = "RichText",
                        Content = options.text or "",
                        ParseTags = options.parseTags or true
                    }
                    
                    local RichTextFrame = CreateElement("Frame", {
                        Name = "RichText",
                        BackgroundColor3 = Library.Theme.LightContrast,
                        Size = UDim2.new(1, 0, 0, options.height or 100),
                        Parent = SectionContent
                    })
                    
                    local RichTextCorner = CreateElement("UICorner", {
                        CornerRadius = UDim.new(0, 6),
                        Parent = RichTextFrame
                    })
                    
                    local RichTextLabel = CreateElement("TextLabel", {
                        Name = "Content",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 10),
                        Size = UDim2.new(1, -20, 1, -20),
                        Font = Library.Fonts.Regular,
                        Text = RichText.Content,
                        TextColor3 = Library.Theme.TextColor,
                        TextSize = isMobile and 16 or 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        RichText = true,
                        TextWrapped = true,
                        Parent = RichTextFrame
                    })
                    
                    -- Custom tags parser
                    local function ParseCustomTags(text)
                        if not RichText.ParseTags then return text end
                        
                        -- Color tag: [color=#RRGGBB]text[/color]
                        text = text:gsub("%[color=([%w#]+)%](.-)%[/color%]", function(color, content)
                            return string.format('<font color="%s">%s</font>', color, content)
                        end)
                        
                        -- Size tag: [size=number]text[/size]
                        text = text:gsub("%[size=(%d+)%](.-)%[/size%]", function(size, content)
                            return string.format('<font size="%s">%s</font>', size, content)
                        end)
                        
                        -- Font tag: [font=fontname]text[/font]
                        text = text:gsub("%[font=([%w%s]+)%](.-)%[/font%]", function(font, content)
                            return string.format('<font face="%s">%s</font>', font, content)
                        end)
                        
                        -- Link tag: [link]url[/link]
                        text = text:gsub("%[link%](.-)%[/link%]", function(url)
                            return string.format('<u><font color="rgb(0,155,255)">%s</font></u>', url)
                        end)
                        
                        -- Code tag: [code]text[/code]
                        text = text:gsub("%[code%](.-)%[/code%]", function(content)
                            return string.format('<font face="Code">%s</font>', content)
                        end)
                        
                        return text
                    end
                    
                    -- Rich text methods
                    function RichText:SetText(text)
                        RichText.Content = text
                        RichTextLabel.Text = ParseCustomTags(text)
                    end
                    
                    function RichText:AppendText(text)
                        RichText.Content = RichText.Content .. text
                        RichTextLabel.Text = ParseCustomTags(RichText.Content)
                    end
                    
                    function RichText:Clear()
                        RichText.Content = ""
                        RichTextLabel.Text = ""
                    end
                    
                    -- Handle clickable elements
                    RichTextLabel.MouseMoved:Connect(function(x, y)
                        local clickable = string.find(RichTextLabel.Text, "<u>")
                        if clickable then
                            RichTextLabel.SelectionImageObject = CreateElement("Frame", {
                                BackgroundColor3 = Library.Theme.Primary,
                                BackgroundTransparency = 0.8
                            })
                        else
                            RichTextLabel.SelectionImageObject = nil
                        end
                    end)
                    
                    RichTextLabel.MouseButton1Click:Connect(function(x, y)
                        local clickable = string.find(RichTextLabel.Text, "<u>")
                        if clickable and options.linkCallback then
                            options.linkCallback(RichTextLabel.Text)
                        end
                    end)
                    
                    -- Initial text parse
                    RichTextLabel.Text = ParseCustomTags(RichText.Content)
                    
                    return RichText
                end
                
                -- Add some default keyboard shortcuts
                Library.Shortcuts:Add({
                    keys = {Enum.KeyCode.LeftControl, Enum.KeyCode.M},
                    name = "Toggle UI",
                    description = "Show/Hide the UI",
                    callback = function()
                        Library.Toggled = not Library.Toggled
                        MainFrame.Visible = Library.Toggled
                    end
                })
                -- Performance Optimizations
                Library.Performance = {
                    UpdateRate = 1/60,
                    LastUpdate = 0,
                    Elements = {},
                    ActiveAnimations = {}
                }
                
                -- Batch updates for better performance
                function Library.Performance:BatchUpdate()
                    local now = tick()
                    if now - self.LastUpdate < self.UpdateRate then return end
                    self.LastUpdate = now
                    
                    -- Update all registered elements
                    for element, updateFunc in pairs(self.Elements) do
                        if element.Instance and element.Instance.Parent then
                            updateFunc(element)
                        else
                            self.Elements[element] = nil
                        end
                    end
                    
                    -- Clean up finished animations
                    for i = #self.ActiveAnimations, 1, -1 do
                        local anim = self.ActiveAnimations[i]
                        if anim.Status == "Completed" then
                            table.remove(self.ActiveAnimations, i)
                        end
                    end
                end
                
                -- Register element for batch updates
                function Library.Performance:RegisterElement(element, updateFunc)
                    self.Elements[element] = updateFunc
                end
                
                -- Start performance monitoring
                RunService.RenderStepped:Connect(function()
                    Library.Performance:BatchUpdate()
                end)
                
                -- Documentation Generator
                Library.Documentation = {}
                
                function Library.Documentation:Generate()
                    local docs = {
                        Version = "1.0.0",
                        LastUpdated = os.date("%Y-%m-%d"),
                        Components = {},
                        Methods = {},
                        Events = {},
                        Examples = {}
                    }
                    
                    -- Document all components
                    for name, component in pairs(Library) do
                        if type(component) == "table" and component.Type then
                            docs.Components[name] = {
                                Type = component.Type,
                                Properties = {},
                                Methods = {},
                                Events = {}
                            }
                            
                            -- Document properties
                            for prop, value in pairs(component) do
                                if type(value) ~= "function" and prop:sub(1,1) ~= "_" then
                                    docs.Components[name].Properties[prop] = type(value)
                                end
                            end
                            
                            -- Document methods
                            for method, func in pairs(component) do
                                if type(func) == "function" and method:sub(1,1) ~= "_" then
                                    docs.Components[name].Methods[method] = {
                                        Description = "Method of " .. name,
                                        Parameters = {}
                                    }
                                end
                            end
                        end
                    end
                    
                    -- Add example usage
                    docs.Examples = {
                        BasicWindow = [[
                            local UI = Library:CreateWindow({
                                Name = "My Script Hub",
                                Theme = "Synthwave"
                            })
                            
                            local MainTab = UI:AddTab("Main")
                            local Section = MainTab:AddSection("Features")
                            
                            Section:AddButton("Click Me", function()
                                print("Button clicked!")
                            end)
                        ]],
                        
                        CustomTheme = [[
                            Library.Theme = {
                                Primary = Color3.fromRGB(255, 65, 125),
                                Secondary = Color3.fromRGB(41, 21, 61),
                                Background = Color3.fromRGB(22, 12, 46),
                                TextColor = Color3.fromRGB(255, 255, 255)
                            }
                        ]],
                        
                        MobileSupport = [[
                            -- Mobile detection is automatic
                            -- You can override specific settings:
                            Library.Settings.MobileMode = true
                            Library.Settings.TouchScrolling = true
                            Library.Settings.LargerButtons = true
                        ]]
                    }
                    
                    return docs
                end
                
                -- Mobile-specific optimizations
                if isMobile then
                    -- Adjust touch input handling
                    UserInputService.TouchStarted:Connect(function(touch, gameProcessed)
                        if not gameProcessed then
                            -- Handle touch input for scrolling
                            local position = touch.Position
                            local elements = Library.Elements
                            
                            for element, _ in pairs(elements) do
                                if element.Instance and element.Instance:IsA("ScrollingFrame") then
                                    local abs = element.Instance.AbsolutePosition
                                    local size = element.Instance.AbsoluteSize
                                    
                                    if position.X >= abs.X and position.X <= abs.X + size.X and
                                       position.Y >= abs.Y and position.Y <= abs.Y + size.Y then
                                        element.Scrolling = true
                                        element.LastTouch = position
                                    end
                                end
                            end
                        end
                    end)
                    
                    UserInputService.TouchMoved:Connect(function(touch, gameProcessed)
                        if not gameProcessed then
                            local position = touch.Position
                            local elements = Library.Elements
                            
                            for element, _ in pairs(elements) do
                                if element.Scrolling and element.LastTouch then
                                    local delta = position - element.LastTouch
                                    element.Instance.CanvasPosition = element.Instance.CanvasPosition - Vector2.new(0, delta.Y)
                                    element.LastTouch = position
                                end
                            end
                        end
                    end)
                    
                    UserInputService.TouchEnded:Connect(function(touch, gameProcessed)
                        if not gameProcessed then
                            local elements = Library.Elements
                            for element, _ in pairs(elements) do
                                element.Scrolling = false
                                element.LastTouch = nil
                            end
                        end
                    end)
                end
                
                -- Final polish and cleanup
                function Library:Cleanup()
                    -- Remove all GUI elements
                    for _, element in pairs(self.Elements) do
                        if element.Instance then
                            element.Instance:Destroy()
                        end
                    end
                    
                    -- Clear all connections
                    for _, connection in pairs(self.Connections) do
                        connection:Disconnect()
                    end
                    
                    -- Clear notifications
                    if self.NotificationUpdateLoop then
                        self.NotificationUpdateLoop:Disconnect()
                    end
                    
                    -- Clear performance monitoring
                    self.Performance.Elements = {}
                    self.Performance.ActiveAnimations = {}
                    
                    -- Reset state
                    self.Elements = {}
                    self.Connections = {}
                    self.Toggled = false
                end
                -- Return the library
                return Library
            end
            
            return Section
        end
        
        return Tab
    end
    
    -- Initialize library
    if not isfolder("SynthwaveUI") then
        makefolder("SynthwaveUI")
        makefolder("SynthwaveUI/configs")
    end
    
    return SynthwaveUI
end)()
