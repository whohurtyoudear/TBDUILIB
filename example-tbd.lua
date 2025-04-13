--[[
    AWP.GG Example for TBD UI Library V8
    This example demonstrates the V8 version working perfectly in AWP.GG
    No design changes, just compatibility fixes
]]

-- Load TBD UI Library
local TBD = loadstring(game:HttpGet('https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/refs/heads/main/tbd.lua'))()

-- Create a window with the HoHo theme
local Window = TBD:CreateWindow({
    Title = "TBD UI Library",
    Subtitle = "V8 HoHo Edition",
    Theme = "HoHo",
    ShowHomePage = true
})

-- Create a main tab
local MainTab = Window:CreateTab({
    Name = "Main Features",
    Icon = "Home"
})

-- Create a section header
MainTab:CreateSection("Buttons")

-- Create a button with click effect
MainTab:CreateButton({
    Name = "Simple Button",
    Description = "A basic button with click effect",
    Callback = function()
        TBD:Notification({
            Title = "Button Clicked",
            Message = "You clicked the simple button!",
            Type = "Info",
            Duration = 3
        })
    end
})

-- Create a toggle
MainTab:CreateSection("Toggles")

local toggle1 = MainTab:CreateToggle({
    Name = "Feature Toggle",
    Description = "Enables or disables a feature",
    Default = false,
    Callback = function(Value)
        TBD:Notification({
            Title = "Toggle Changed",
            Message = "Feature is now " .. (Value and "Enabled" or "Disabled"),
            Type = Value and "Success" or "Error",
            Duration = 3
        })
    end
})

-- Create a slider
MainTab:CreateSection("Sliders")

local slider1 = MainTab:CreateSlider({
    Name = "Walkspeed Slider",
    Description = "Adjusts player walkspeed",
    Range = {16, 250},
    Increment = 1,
    Default = 16,
    Callback = function(Value)
        -- Set the player's walkspeed (safely)
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end)
    end
})

-- Create a second tab for other features
local CustomizationTab = Window:CreateTab({
    Name = "Customization",
    Icon = "Settings"
})

-- Create a dropdown for theme selection
CustomizationTab:CreateSection("Theme Selection")

local themes = {"HoHo", "Default", "Midnight", "Neon", "Aqua"}
local dropdown1 = CustomizationTab:CreateDropdown({
    Name = "UI Theme",
    Description = "Change the look of the interface",
    Items = themes,
    Default = "HoHo",
    Callback = function(Value)
        TBD:SetTheme(Value)
        TBD:Notification({
            Title = "Theme Changed",
            Message = "Applied the " .. Value .. " theme",
            Type = "Success",
            Duration = 3
        })
    end
})

-- Create a color picker for custom theming
CustomizationTab:CreateSection("Custom Colors")

local colorPicker1 = CustomizationTab:CreateColorPicker({
    Name = "Accent Color",
    Description = "Change the accent color of the UI",
    Default = Color3.fromRGB(255, 30, 50), -- HoHo red
    Callback = function(Value)
        TBD:CustomTheme({
            Accent = Value,
            DarkAccent = Value:Lerp(Color3.new(0,0,0), 0.2)
        })
    end
})

-- Create a third tab for notifications
local NotificationsTab = Window:CreateTab({
    Name = "Notifications",
    Icon = "Notification"
})

-- Add notification examples
NotificationsTab:CreateSection("Notification Types")

NotificationsTab:CreateButton({
    Name = "Success Notification",
    Callback = function()
        TBD:Notification({
            Title = "Success",
            Message = "Operation completed successfully!",
            Type = "Success",
            Duration = 3
        })
    end
})

NotificationsTab:CreateButton({
    Name = "Info Notification",
    Callback = function()
        TBD:Notification({
            Title = "Information",
            Message = "Here's some useful information for you.",
            Type = "Info",
            Duration = 3
        })
    end
})

NotificationsTab:CreateButton({
    Name = "Warning Notification",
    Callback = function()
        TBD:Notification({
            Title = "Warning",
            Message = "Please be careful with this action!",
            Type = "Warning",
            Duration = 3
        })
    end
})

NotificationsTab:CreateButton({
    Name = "Error Notification",
    Callback = function()
        TBD:Notification({
            Title = "Error",
            Message = "Something went wrong! Please try again.",
            Type = "Error",
            Duration = 3
        })
    end
})

-- Show a welcome notification
TBD:Notification({
    Title = "Welcome",
    Message = "TBD UI Library V8 loaded successfully!",
    Type = "Success",
    Duration = 5
})
