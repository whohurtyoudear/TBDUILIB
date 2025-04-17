local Library = {}

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local TopBar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local CloseButton = Instance.new("TextButton")
    
    -- Main GUI Setup
    ScreenGui.Name = "UILibrary"
    ScreenGui.Parent = game.CoreGui
    
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    MainFrame.Size = UDim2.new(0, 300, 0, 200)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    UICorner.Parent = MainFrame
    UICorner.CornerRadius = UDim.new(0, 6)
    
    -- Top Bar
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    
    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.Parent = TopBar
    TopBarCorner.CornerRadius = UDim.new(0, 6)
    
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TopBar
    CloseButton.BackgroundTransparency = 1
    CloseButton.Position = UDim2.new(1, -25, 0, 5)
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    
    -- Container for elements
    local Container = Instance.new("ScrollingFrame")
    Container.Name = "Container"
    Container.Parent = MainFrame
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 5, 0, 35)
    Container.Size = UDim2.new(1, -10, 1, -40)
    Container.ScrollBarThickness = 4
    Container.ScrollingDirection = Enum.ScrollingDirection.Y
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    -- Close button functionality
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    local Window = {}
    
    function Window:AddButton(text, callback)
        local Button = Instance.new("TextButton")
        local ButtonCorner = Instance.new("UICorner")
        
        Button.Name = "Button"
        Button.Parent = Container
        Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Button.Size = UDim2.new(1, -10, 0, 30)
        Button.Position = UDim2.new(0, 5, 0, #Container:GetChildren() * 35)
        Button.Font = Enum.Font.Gotham
        Button.Text = text
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 14
        
        ButtonCorner.Parent = Button
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        
        Button.MouseButton1Click:Connect(callback)
        
        Container.CanvasSize = UDim2.new(0, 0, 0, #Container:GetChildren() * 35 + 5)
    end
    
    function Window:AddToggle(text, callback)
        local Toggle = Instance.new("Frame")
        local ToggleCorner = Instance.new("UICorner")
        local ToggleButton = Instance.new("TextButton")
        local ToggleLabel = Instance.new("TextLabel")
        local Enabled = false
        
        Toggle.Name = "Toggle"
        Toggle.Parent = Container
        Toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Toggle.Size = UDim2.new(1, -10, 0, 30)
        Toggle.Position = UDim2.new(0, 5, 0, #Container:GetChildren() * 35)
        
        ToggleCorner.Parent = Toggle
        ToggleCorner.CornerRadius = UDim.new(0, 4)
        
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Parent = Toggle
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Position = UDim2.new(0, 5, 0.5, -10)
        ToggleButton.Size = UDim2.new(0, 20, 0, 20)
        ToggleButton.Font = Enum.Font.SourceSans
        ToggleButton.Text = ""
        
        local ToggleButtonCorner = Instance.new("UICorner")
        ToggleButtonCorner.Parent = ToggleButton
        ToggleButtonCorner.CornerRadius = UDim.new(0, 4)
        
        ToggleLabel.Name = "ToggleLabel"
        ToggleLabel.Parent = Toggle
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Position = UDim2.new(0, 30, 0, 0)
        ToggleLabel.Size = UDim2.new(1, -35, 1, 0)
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.Text = text
        ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleLabel.TextSize = 14
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        ToggleButton.MouseButton1Click:Connect(function()
            Enabled = not Enabled
            ToggleButton.BackgroundColor3 = Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            callback(Enabled)
        end)
        
        Container.CanvasSize = UDim2.new(0, 0, 0, #Container:GetChildren() * 35 + 5)
    end
    
    return Window
end

return Library
