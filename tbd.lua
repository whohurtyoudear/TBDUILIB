-- Main Library Setup
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

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
        ToggleOff = Color3.fromRGB(41, 21, 61)
    },
    Flags = {},
    Toggled = true,
    Settings = {
        AnimationDuration = 0.3,
        EasingStyle = Enum.EasingStyle.Quart,
        EasingDirection = Enum.EasingDirection.Out
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

local function AddRippleEffect(button)
    button.ClipsDescendants = true
    
    local ripple = CreateElement("Frame", {
        Name = "Ripple",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0)
    })
    
    local corner = CreateElement("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = ripple
    })
    
    button.MouseButton1Down:Connect(function(x, y)
        local rippleClone = ripple:Clone()
        rippleClone.Parent = button
        
        local mousePos = Vector2.new(x, y)
        local buttonPos = button.AbsolutePosition
        local relativePos = mousePos - buttonPos
        
        rippleClone.Position = UDim2.new(0, relativePos.X, 0, relativePos.Y)
        
        local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
        local appearTween = CreateTween(rippleClone, {
            Size = UDim2.new(0, maxSize, 0, maxSize),
            BackgroundTransparency = 1
        }, 0.5)
        
        appearTween:Play()
        appearTween.Completed:Connect(function()
            rippleClone:Destroy()
        end)
    end)
end

-- Notification System
function Library:CreateNotification(title, text, duration)
    local NotificationGui = CreateElement("ScreenGui", {
        Name = "Notification",
        Parent = CoreGui
    })
    
    local NotificationFrame = CreateElement("Frame", {
        Name = "NotificationFrame",
        BackgroundColor3 = Library.Theme.Background,
        Position = UDim2.new(1, 20, 0.8, 0),
        Size = UDim2.new(0, 250, 0, 80),
        Parent = NotificationGui
    })
    
    local Corner = CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = NotificationFrame
    })
    
    local Gradient = CreateElement("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library.Theme.Primary),
            ColorSequenceKeypoint.new(1, Library.Theme.Secondary)
        }),
        Rotation = 45,
        Parent = NotificationFrame
    })
    
    local TitleLabel = CreateElement("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Library.Theme.TextColor,
        TextSize = 14,
        Parent = NotificationFrame
    })
    
    local TextLabel = CreateElement("TextLabel", {
        Name = "Text",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 30),
        Size = UDim2.new(1, -20, 1, -35),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = Library.Theme.TextColor,
        TextSize = 12,
        TextWrapped = true,
        Parent = NotificationFrame
    })
    
    local appearTween = CreateTween(NotificationFrame, {
        Position = UDim2.new(1, -270, 0.8, 0)
    })
    
    local disappearTween = CreateTween(NotificationFrame, {
        Position = UDim2.new(1, 20, 0.8, 0)
    })
    
    appearTween:Play()
    
    task.delay(duration or 3, function()
        disappearTween:Play()
        disappearTween.Completed:Connect(function()
            NotificationGui:Destroy()
        end)
    end)
end

-- Window Creation
function Library:CreateWindow(title)
    local Window = {
        Tabs = {},
        TabCount = 0,
        Toggled = true
    }
    
    -- Main GUI Elements
    local ScreenGui = CreateElement("ScreenGui", {
        Name = "SynthwaveUI",
        Parent = CoreGui
    })
    
    local MainFrame = CreateElement("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = Library.Theme.Background,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        Parent = ScreenGui
    })
    
    local MainCorner = CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = MainFrame
    })
    
    local TopBar = CreateElement("Frame", {
        Name = "TopBar",
        BackgroundColor3 = Library.Theme.Secondary,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = MainFrame
    })
    
    local TopBarCorner = CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = TopBar
    })
    
    local TitleLabel = CreateElement("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Library.Theme.TextColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })
    
    -- Make window draggable
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Tab System
    local TabContainer = CreateElement("Frame", {
        Name = "TabContainer",
        BackgroundColor3 = Library.Theme.DarkContrast,
        Position = UDim2.new(0, 5, 0, 35),
        Size = UDim2.new(0, 140, 1, -40),
        Parent = MainFrame
    })
    
    local TabContainerCorner = CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 6),
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
    
    -- Content Area
    local ContentContainer = CreateElement("Frame", {
        Name = "ContentContainer",
        BackgroundColor3 = Library.Theme.DarkContrast,
        Position = UDim2.new(0, 150, 0, 35),
        Size = UDim2.new(1, -155, 1, -40),
        Parent = MainFrame
    })
    
    local ContentContainerCorner = CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = ContentContainer
    })
    
    -- Tab Creation Function
    function Window:CreateTab(tabName)
        local Tab = {
            Elements = {}
        }
        
        Window.TabCount = Window.TabCount + 1
        
        local TabButton = CreateElement("TextButton", {
            Name = tabName,
            BackgroundColor3 = Library.Theme.LightContrast,
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.new(0, 5, 0, (Window.TabCount - 1) * 35),
            Font = Enum.Font.Gotham,
            Text = tabName,
            TextColor3 = Library.Theme.TextColor,
            TextSize = 12,
            Parent = TabList
        })
        
        local TabButtonCorner = CreateElement("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = TabButton
        })
        
        local TabContent = CreateElement("ScrollingFrame", {
            Name = tabName .. "Content",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 5, 0, 5),
            Size = UDim2.new(1, -10, 1, -10),
            ScrollBarThickness = 2,
            Visible = false,
            Parent = ContentContainer
        })
        
        local ContentLayout = CreateElement("UIListLayout", {
            Padding = UDim.new(0, 5),
            Parent = TabContent
        })
        
        -- Tab Button Click Handler
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = Library.Theme.LightContrast
            end
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Library.Theme.Primary
        end)
        
        -- Element Creation Functions
        function Tab:AddButton(text, callback)
            local Button = CreateElement("TextButton", {
                Name = "Button",
                BackgroundColor3 = Library.Theme.LightContrast,
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Library.Theme.TextColor,
                TextSize = 12,
                Parent = TabContent
            })
            
            local ButtonCorner = CreateElement("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = Button
            })
            
            AddRippleEffect(Button)
            
            Button.MouseButton1Click:Connect(callback)
            
            return Button
        end
        
        function Tab:AddToggle(text, default, callback)
            local Toggle = CreateElement("Frame", {
                Name = "Toggle",
                BackgroundColor3 = Library.Theme.LightContrast,
                Size = UDim2.new(1, 0, 0, 30),
                Parent = TabContent
            })
            
            local ToggleCorner = CreateElement("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = Toggle
            })
            
            local ToggleButton = CreateElement("Frame", {
                Name = "ToggleButton",
                BackgroundColor3 = default and Library.Theme.ToggleOn or Library.Theme.ToggleOff,
                Position = UDim2.new(0, 5, 0.5, -10),
                Size = UDim2.new(0, 40, 0, 20),
                Parent = Toggle
            })
            
            local ToggleButtonCorner = CreateElement("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = ToggleButton
            })
            
            local ToggleCircle = CreateElement("Frame", {
                Name = "Circle",
                BackgroundColor3 = Library.Theme.TextColor,
                Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Parent = ToggleButton
            })
            
            local ToggleCircleCorner = CreateElement("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = ToggleCircle
            })
            
            local ToggleLabel = CreateElement("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 55, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Library.Theme.TextColor,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Toggle
            })
            
            local toggled = default
            
            Toggle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggled = not toggled
                    
                    CreateTween(ToggleCircle, {
                        Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                    }):Play()
                    
                    CreateTween(ToggleButton, {
                        BackgroundColor3 = toggled and Library.Theme.ToggleOn or Library.Theme.ToggleOff
                    }):Play()
                    
                    callback(toggled)
                end
            end)
            
            return Toggle
        end
        
        function Tab:AddSlider(text, min, max, default, callback)
            local Slider = CreateElement("Frame", {
                Name = "Slider",
                BackgroundColor3 = Library.Theme.LightContrast,
                Size = UDim2.new(1, 0, 0, 50),
                Parent = TabContent
            })
            
            local SliderCorner = CreateElement("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = Slider
            })
            
            local SliderLabel = CreateElement("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 5, 0, 5),
                Size = UDim2.new(1, -10, 0, 20),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Library.Theme.TextColor,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Slider
            })
            
            local SliderValue = CreateElement("TextLabel", {
                Name = "Value",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -45, 0, 5),
                Size = UDim2.new(0, 40, 0, 20),
                Font = Enum.Font.Gotham,
                Text = tostring(default),
                TextColor3 = Library.Theme.TextColor,
                TextSize = 12,
                Parent = Slider
            })
            
            local SliderBar = CreateElement("Frame", {
                Name = "Bar",
                BackgroundColor3 = Library.Theme.Secondary,
                Position = UDim2.new(0, 5, 0, 35),
                Size = UDim2.new(1, -10, 0, 4),
                Parent = Slider
            })
            
            local SliderBarCorner = CreateElement("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = SliderBar
            })
            
            local SliderFill = CreateElement("Frame", {
                Name = "Fill",
                BackgroundColor3 = Library.Theme.Primary,
                Size = UDim2.new((default - min)/(max - min), 0, 1, 0),
                Parent = SliderBar
            })
            
            local SliderFillCorner = CreateElement("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = SliderFill
            })
            
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
                    local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + ((max - min) * pos))
                    
                    SliderValue.Text = tostring(value)
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    
                    callback(value)
                end
            end)
            
            return Slider
        end
        
        function Tab:AddDropdown(text, options, callback)
            local Dropdown = CreateElement("Frame", {
                Name = "Dropdown",
                BackgroundColor3 = Library.Theme.LightContrast,
                Size = UDim2.new(1, 0, 0, 30),
                ClipsDescendants = true,
                Parent = TabContent
            })
            
            local DropdownCorner = CreateElement("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = Dropdown
            })
            
            local DropdownButton = CreateElement("TextButton", {
                Name = "Button",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Library.Theme.TextColor,
                TextSize = 12,
                Parent = Dropdown
            })
            
            local DropdownIcon = CreateElement("ImageLabel", {
                Name = "Icon",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -25, 0, 5),
                Size = UDim2.new(0, 20, 0, 20),
                Image = "rbxassetid://6031091004",
                Parent = DropdownButton
            })
            
            local OptionContainer = CreateElement("Frame", {
                Name = "Options",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(1, 0, 0, #options * 25),
                Parent = Dropdown
            })
            
            local OptionList = CreateElement("UIListLayout", {
                Parent = OptionContainer
            })
            
            for i, option in ipairs(options) do
                local OptionButton = CreateElement("TextButton", {
                    Name = option,
                    BackgroundColor3 = Library.Theme.Secondary,
                    Size = UDim2.new(1, 0, 0, 25),
                    Font = Enum.Font.Gotham,
                    Text = option,
                    TextColor3 = Library.Theme.TextColor,
                    TextSize = 12,
                    Parent = OptionContainer
                })
                
                local OptionButtonCorner = CreateElement("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = OptionButton
                })
                
                OptionButton.MouseButton1Click:Connect(function()
                    callback(option)
                    DropdownButton.Text = text .. ": " .. option
                    
                    CreateTween(Dropdown, {
                        Size = UDim2.new(1, 0, 0, 30)
                    }):Play()
                end)
            end
            
            local dropped = false
            
            DropdownButton.MouseButton1Click:Connect(function()
                dropped = not dropped
                
                CreateTween(Dropdown, {
                    Size = UDim2.new(1, 0, 0, dropped and (30 + #options * 25) or 30)
                }):Play()
                
                CreateTween(DropdownIcon, {
                    Rotation = dropped and 180 or 0
                }):Play()
            end)
            
            return Dropdown
        end
        
        -- Store tab information
        Window.Tabs[tabName] = {
            Button = TabButton,
            Content = TabContent
        }
        
        -- Show first tab by default
        if Window.TabCount == 1 then
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Library.Theme.Primary
        end
        
        return Tab
    end
    
    return Window
end

return Library
