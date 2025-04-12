--[[
    TBD UI Library - Fixed Example Script
    This example demonstrates all features of the fixed TBD UI Library
]]

-- Load the TBD UI Library
local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOURUSERNAME/YOURREPO/main/tbd-enhanced-fixed.lua", true))()

-- Create a Window with enhanced options
local Window = TBD:CreateWindow({
    Title = "TBD Script Hub",
    Subtitle = "v1.1.0",
    Theme = "Aqua", -- Try the new Aqua theme (options: Default, Midnight, Neon, Aqua)
    Size = {500, 550}, -- Automatically adapts for mobile
    Position = "Center",
    LogoId = "12345678", -- Replace with your logo asset ID
    LoadingEnabled = true,
    LoadingTitle = "TBD Script Hub",
    LoadingSubtitle = "Loading awesome features...",
    
    -- Enable the home page feature that shows player info
    ShowHomePage = true,
    
    -- Enhanced loading screen customization
    LoadingScreenCustomization = {
        AnimationStyle = "Slide", -- Options: "Fade", "Slide", "Scale"
        LogoSize = UDim2.new(0, 120, 0, 120),
        LogoPosition = UDim2.new(0.5, 0, 0.35, 0),
        ProgressBarSize = UDim2.new(0.8, 0, 0, 8)
    },
    
    ConfigSettings = {
        ConfigFolder = "TBDScriptHub"
    }
})

-- The Home tab is automatically created when ShowHomePage is true
-- You can access it with Window.HomeTab if you need to add custom elements

-- Create Tabs
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "home",
    ImageSource = "Phosphor",
    ShowTitle = true
})

local PlayerTab = Window:CreateTab({
    Name = "Player",
    Icon = "person",
    ImageSource = "Phosphor"
})

local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = "eye",
    ImageSource = "Phosphor"
})

local ThemesTab = Window:CreateTab({
    Name = "Themes",
    Icon = "favorite",
    ImageSource = "Phosphor"
})

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "settings",
    ImageSource = "Phosphor"
})

-- Main Tab Elements
MainTab:CreateSection("Welcome")

MainTab:CreateButton({
    Name = "Join Discord",
    Description = "Join our community for updates and support",
    Callback = function()
        TBD:Notification({
            Title = "Discord Invite",
            Message = "Opening Discord invite link...",
            Type = "Info",
            Duration = 3
        })
        
        -- Example: setclipboard("https://discord.gg/your-invite")
    end
})

-- Fix position of notifications
TBD.NotificationSystem:SetPosition("TopRight")

-- Show different notification types
local notifyButton = MainTab:CreateButton({
    Name = "Show Notifications",
    Description = "Demonstrate fixed notification system",
    Callback = function()
        -- Success notification
        TBD:Notification({
            Title = "Success",
            Message = "Operation completed successfully!",
            Type = "Success",
            Duration = 4
        })
        
        -- Wait a moment before showing next notification
        task.wait(1)
        
        -- Info notification
        TBD:Notification({
            Title = "Information",
            Message = "This is an informational message with details about something important.",
            Type = "Info",
            Duration = 4
        })
        
        -- Wait a moment before showing next notification
        task.wait(1)
        
        -- Warning notification
        TBD:Notification({
            Title = "Warning",
            Message = "Please be careful! This action might have consequences.",
            Type = "Warning",
            Duration = 4
        })
        
        -- Wait a moment before showing next notification
        task.wait(1)
        
        -- Error notification
        TBD:Notification({
            Title = "Error",
            Message = "Something went wrong. Please try again later.",
            Type = "Error",
            Duration = 4
        })
    end
})

MainTab:CreateDivider()

MainTab:CreateSection("Script Status")

-- Demonstrating the fixed CreateToggle function
MainTab:CreateToggle({
    Name = "Anti AFK",
    Description = "Prevents being kicked for inactivity",
    CurrentValue = true,
    Flag = "AntiAFK", -- Flag for saving in config
    Callback = function(Value)
        -- Implement Anti AFK logic
        if Value then
            TBD:Notification({
                Title = "Anti AFK",
                Message = "Anti AFK is now enabled",
                Type = "Success"
            })
            
            -- Your anti-AFK code here
        else
            TBD:Notification({
                Title = "Anti AFK",
                Message = "Anti AFK is now disabled",
                Type = "Info"
            })
            
            -- Disable anti-AFK
        end
    end
})

-- Player Tab Elements
PlayerTab:CreateSection("Character Modifications")

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Description = "Modify your character's walking speed",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed", -- Flag for saving in config
    Callback = function(Value)
        -- Implement walk speed
        if game.Players.LocalPlayer.Character and 
           game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Description = "Modify your character's jumping ability",
    Range = {50, 500},
    Increment = 5,
    CurrentValue = 50,
    Flag = "JumpPower", -- Flag for saving in config
    Callback = function(Value)
        -- Implement jump power
        if game.Players.LocalPlayer.Character and 
           game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end
})

-- Another example of CreateToggle usage
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    Description = "Jump as many times as you want in the air",
    CurrentValue = false,
    Flag = "InfiniteJump", -- Flag for saving in config
    Callback = function(Value)
        -- Implement infinite jump
        _G.InfiniteJump = Value
        
        if not _G.InfiniteJumpConnected then
            _G.InfiniteJumpConnected = true
            
            game:GetService("UserInputService").JumpRequest:Connect(function()
                if _G.InfiniteJump and 
                   game.Players.LocalPlayer.Character and 
                   game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                    game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end
})

-- Themes Tab Elements - Showcasing the new theme features
ThemesTab:CreateSection("UI Themes")

ThemesTab:CreateDropdown({
    Name = "Select Theme",
    Description = "Choose a pre-built theme for the UI",
    Items = {"Default", "Midnight", "Neon", "Aqua"}, -- Added new Aqua theme
    Default = "Aqua",
    Flag = "UITheme", -- Flag for saving in config
    Callback = function(Theme)
        TBD:SetTheme(Theme)
        
        TBD:Notification({
            Title = "Theme Changed",
            Message = "Applied the " .. Theme .. " theme",
            Type = "Success"
        })
    end
})

-- Settings Tab Elements
SettingsTab:CreateSection("UI Settings")

SettingsTab:CreateDropdown({
    Name = "Notification Position",
    Description = "Where notifications appear on screen",
    Items = {"TopRight", "TopLeft", "BottomRight", "BottomLeft"},
    Default = "TopRight",
    Flag = "NotificationPosition", -- Flag for saving in config
    Callback = function(Position)
        -- Set notification position
        TBD.NotificationSystem:SetPosition(Position)
        
        TBD:Notification({
            Title = "Position Updated",
            Message = "Notifications will now appear in the " .. Position .. " position",
            Type = "Info"
        })
    end
})
