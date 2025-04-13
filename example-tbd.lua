--[[
    TBD UI Library V9 Example - Perfect Match
    
    This example script is designed to look exactly like the reference image
    with proper styling, color scheme, and functionality.
]]

-- Load the TBD UI Library with proper error handling
local TBD
local success, errorMsg = pcall(function()
    -- Use the new V9 Perfect version
    TBD = loadstring(game:HttpGet('https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/refs/heads/main/tbd.lua'))()
    
    if type(TBD) ~= "table" or not TBD.Version then
        error("Failed to initialize TBD UI Library")
    end
    
    return true
end)

if not success then
    -- Better error reporting
    warn("Error loading TBD UI Library: " .. tostring(errorMsg))
    return
end

-- Print version info
print("TBD UI Library V9 loaded successfully!")
print("Version: " .. TBD.Version)

-- Create a window matching the reference image style
local Window = TBD:CreateWindow({
    Title = "TBD Script Hub",
    Subtitle = "v2.0.0 Edition",
    Theme = "HoHo", -- Red theme from reference image
    Size = {650, 400}, -- Width matches reference
    LoadingEnabled = true, -- Show loading screen
    ShowHomePage = true
})

-- Create tabs that match the reference image
local HomeTab = Window:CreateTab({
    Name = "Home",
    Icon = "Home"
})

local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "Script"
})

local PlayerTab = Window:CreateTab({
    Name = "Player",
    Icon = "Player"
})

local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = "Eye"
})

local ThemesTab = Window:CreateTab({
    Name = "Themes",
    Icon = "Palette"
})

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "Settings"
})

-- Welcome section in the Home tab
HomeTab:CreateSection("Welcome")

-- Welcome message
HomeTab:CreateParagraph({
    Title = "Welcome to TBD UI Library V9",
    Content = "This UI library has been completely rebuilt to work with all Roblox executors while maintaining the beautiful visual style from previous versions. Use the tabs on the left to explore features."
})

-- Notification demo buttons (exactly like reference image)
HomeTab:CreateButton({
    Name = "Show Notification",
    Description = "Display a sample notification",
    Callback = function()
        TBD:Notification({
            Title = "Information",
            Message = "This is an informational message with details about something important.",
            Time = 5,
            Type = "Info"
        })
    end
})

HomeTab:CreateButton({
    Name = "Show All Notifications",
    Description = "Demonstrate notification system",
    Callback = function()
        -- Show all notification types in sequence
        TBD:Notification({
            Title = "Error",
            Message = "Something went wrong. Please try again later.",
            Time = 5,
            Type = "Error"
        })
        
        wait(0.5)
        
        TBD:Notification({
            Title = "Warning",
            Message = "Please be careful! This action might have consequences.",
            Time = 5,
            Type = "Warning"
        })
        
        wait(0.5)
        
        TBD:Notification({
            Title = "Information",
            Message = "This is an informational message with details about something important.",
            Time = 5,
            Type = "Info"
        })
        
        wait(0.5)
        
        TBD:Notification({
            Title = "Success",
            Message = "Operation completed successfully!",
            Time = 5,
            Type = "Success"
        })
    end
})

-- Script Status section (matching reference image)
HomeTab:CreateSection("Script Status")

-- Anti AFK toggle (matching reference image)
HomeTab:CreateToggle({
    Name = "Anti AFK",
    Description = "Prevents being kicked for inactivity",
    CurrentValue = false,
    Callback = function(value)
        print("Anti AFK toggled:", value)
    end
})

-- Music Volume slider (matching reference image)
HomeTab:CreateSlider({
    Name = "Music Volume",
    Description = "Adjust the background music volume",
    Min = 0,
    Max = 100,
    Increment = 1,
    CurrentValue = 80,
    Callback = function(value)
        print("Music volume adjusted to:", value)
    end
})

-- Main tab content (simple examples of each component)
MainTab:CreateSection("Buttons")

MainTab:CreateButton({
    Name = "Simple Button",
    Callback = function()
        print("Simple button clicked!")
    end
})

MainTab:CreateButton({
    Name = "Button with Description",
    Description = "This button has additional information",
    Callback = function()
        print("Button with description clicked!")
        TBD:Notification({
            Title = "Button Clicked",
            Message = "You clicked a button with a description",
            Time = 3,
            Type = "Success"
        })
    end
})

MainTab:CreateSection("Toggles")

MainTab:CreateToggle({
    Name = "Toggle Feature",
    CurrentValue = false,
    Callback = function(value)
        print("Feature toggled:", value)
    end
})

MainTab:CreateToggle({
    Name = "Toggle with Description",
    Description = "This toggle includes additional details",
    CurrentValue = true,
    Callback = function(value)
        print("Described toggle changed to:", value)
    end
})

MainTab:CreateSection("Sliders")

MainTab:CreateSlider({
    Name = "Basic Slider",
    Min = 0,
    Max = 100,
    Increment = 1,
    CurrentValue = 50,
    Callback = function(value)
        print("Slider value:", value)
    end
})

MainTab:CreateSection("Dropdowns")

local fruitDropdown = MainTab:CreateDropdown({
    Name = "Fruit Selection",
    Items = {"Apple", "Banana", "Orange", "Grape", "Watermelon"},
    CurrentOption = "Apple",
    Callback = function(option)
        print("Selected fruit:", option)
    end
})

-- Player tab content
PlayerTab:CreateSection("Player Modifications")

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 200,
    Increment = 1,
    CurrentValue = 16,
    Callback = function(value)
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        end)
    end
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 300,
    Increment = 1,
    CurrentValue = 50,
    Callback = function(value)
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
        end)
    end
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(value)
        print("Infinite Jump:", value)
    end
})

-- Visuals tab content
VisualsTab:CreateSection("Visual Options")

VisualsTab:CreateToggle({
    Name = "ESP",
    Description = "See players through walls",
    CurrentValue = false,
    Callback = function(value)
        print("ESP toggled:", value)
    end
})

VisualsTab:CreateToggle({
    Name = "Tracers",
    Description = "Draw lines to players",
    CurrentValue = false,
    Callback = function(value)
        print("Tracers toggled:", value)
    end
})

VisualsTab:CreateColorPicker({
    Name = "ESP Color",
    Description = "Change the ESP highlighting color",
    CurrentColor = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        print("ESP color changed to:", color)
    end
})

-- Themes tab content
ThemesTab:CreateSection("Theme Selection")

local themes = {"HoHo", "Default", "Midnight", "Neon", "Aqua"}
ThemesTab:CreateDropdown({
    Name = "Select Theme",
    Items = themes,
    CurrentOption = "HoHo",
    Callback = function(theme)
        TBD:SetTheme(theme)
        TBD:Notification({
            Title = "Theme Changed",
            Message = "Applied the " .. theme .. " theme",
            Time = 3,
            Type = "Success"
        })
    end
})

ThemesTab:CreateSection("Custom Theme")

ThemesTab:CreateColorPicker({
    Name = "Accent Color",
    Description = "Main highlight color",
    CurrentColor = Color3.fromRGB(255, 30, 50),
    Callback = function(color)
        print("Custom accent color:", color)
    end
})

ThemesTab:CreateButton({
    Name = "Apply Custom Theme",
    Callback = function()
        TBD:Notification({
            Title = "Custom Theme",
            Message = "Custom theme would be applied here",
            Time = 3,
            Type = "Info"
        })
    end
})

-- Settings tab content
SettingsTab:CreateSection("UI Settings")

SettingsTab:CreateToggle({
    Name = "Show Keybinds",
    CurrentValue = true,
    Callback = function(value)
        print("Show keybinds toggled:", value)
    end
})

SettingsTab:CreateDropdown({
    Name = "Menu Key",
    Items = {"RightShift", "RightControl", "LeftAlt", "F4"},
    CurrentOption = "RightControl",
    Callback = function(key)
        print("Menu key set to:", key)
    end
})

SettingsTab:CreateSection("Miscellaneous")

SettingsTab:CreateButton({
    Name = "Reset All Settings",
    Description = "Restore default configuration",
    Callback = function()
        TBD:Notification({
            Title = "Settings Reset",
            Message = "All settings have been restored to their default values",
            Time = 3,
            Type = "Warning"
        })
    end
})

-- Show a welcome notification
wait(1) -- Wait a moment after UI loads
TBD:Notification({
    Title = "Welcome",
    Message = "TBD UI Library V9 has been loaded successfully!",
    Time = 5,
    Type = "Success"
})
