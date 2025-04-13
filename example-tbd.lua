--[[
    TBD UI Library V9 Example
    This example demonstrates all key features of the V9 library
    Works on all Roblox executors
]]

-- Load the TBD UI Library with proper error handling
local TBD
local success, errorMsg = pcall(function()
    -- Robust loading method to work with all executors
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

-- Print version information
print("TBD UI Library loaded successfully!")
print("Version: " .. TBD.Version)

-- Create a window with a custom theme
local Window = TBD:CreateWindow({
    Title = "TBD UI Library",
    Subtitle = "Universal V9",
    Theme = "HoHo", -- Available themes: Default, HoHo, Midnight, Neon, Aqua
    Size = {650, 450}, -- Wider design as requested
    LoadingEnabled = true, -- Enables the fancy loading screen
    ShowHomePage = true -- Shows a homepage with player info
})

-- Create tabs
local HomeTab = Window:CreateTab({
    Name = "Home",
    Icon = "Home" -- Built-in icon
})

local FeaturesTab = Window:CreateTab({
    Name = "Features",
    Icon = "Script"
})

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "Settings"
})

local CreditsTab = Window:CreateTab({
    Name = "Credits",
    Icon = "Credit"
})

-- Home Tab Content
local HomeSection = HomeTab:CreateSection("Welcome")

HomeTab:CreateParagraph({
    Title = "TBD UI Library V9",
    Content = "Welcome to the TBD UI Library V9 - Universal Edition. This library is designed to work across all Roblox executors and provides a comprehensive set of UI components."
})

HomeTab:CreateButton({
    Name = "Show Notification",
    Description = "Click to test the notification system",
    Callback = function()
        TBD:Notification({
            Title = "TBD UI Library",
            Message = "This is a test notification. The notification system works!",
            Duration = 5,
            Type = "Info" -- Types: Success, Error, Warning, Info
        })
    end
})

-- Features Tab Content
-- Buttons Section
local ButtonsSection = FeaturesTab:CreateSection("Buttons")

FeaturesTab:CreateButton({
    Name = "Simple Button",
    Callback = function()
        print("Simple button clicked!")
    end
})

FeaturesTab:CreateButton({
    Name = "Button with Description",
    Description = "This button has a description that explains what it does",
    Callback = function()
        print("Button with description clicked!")
        TBD:Notification({
            Title = "Button Clicked",
            Message = "You clicked the button with a description",
            Duration = 3,
            Type = "Success"
        })
    end
})

-- Toggles Section
local TogglesSection = FeaturesTab:CreateSection("Toggles")

FeaturesTab:CreateToggle({
    Name = "Simple Toggle",
    CurrentValue = false,
    Callback = function(value)
        print("Simple toggle changed to:", value)
    end
})

FeaturesTab:CreateToggle({
    Name = "Toggle with Description",
    Description = "This toggle has a description that explains what it does",
    CurrentValue = true,
    Callback = function(value)
        print("Described toggle changed to:", value)
    end
})

-- Sliders Section
local SlidersSection = FeaturesTab:CreateSection("Sliders")

FeaturesTab:CreateSlider({
    Name = "Simple Slider",
    Min = 0,
    Max = 100,
    Increment = 1,
    CurrentValue = 50,
    Callback = function(value)
        print("Slider value changed to:", value)
    end
})

FeaturesTab:CreateSlider({
    Name = "Custom Slider",
    Min = 0,
    Max = 200,
    Increment = 5,
    Description = "This slider has a custom range and increment",
    CurrentValue = 100,
    Callback = function(value)
        print("Custom slider value:", value)
    end
})

-- Dropdowns Section
local DropdownsSection = FeaturesTab:CreateSection("Dropdowns")

local fruitDropdown
FeaturesTab:CreateDropdown({
    Name = "Fruit Selection",
    Items = {"Apple", "Banana", "Orange", "Pear", "Grape"},
    CurrentOption = "Apple",
    Callback = function(option)
        print("Selected fruit:", option)
    end
})

local dropdown, dropdownObject = FeaturesTab:CreateDropdown({
    Name = "Dynamic Dropdown",
    Description = "This dropdown's options can be changed dynamically",
    Items = {"Option 1", "Option 2", "Option 3"},
    CurrentOption = "Option 1",
    Callback = function(option)
        print("Selected option:", option)
    end
})

-- Button to refresh dropdown options
FeaturesTab:CreateButton({
    Name = "Refresh Dropdown Options",
    Callback = function()
        local newOptions = {"New Option A", "New Option B", "New Option C", "New Option D"}
        dropdownObject:Refresh(newOptions)
        dropdownObject:SetValue("New Option A")
        TBD:Notification({
            Title = "Dropdown Updated",
            Message = "The dropdown options have been refreshed",
            Duration = 3,
            Type = "Info"
        })
    end
})

-- Text Input Section
local InputSection = FeaturesTab:CreateSection("Text Input")

FeaturesTab:CreateTextBox({
    Name = "Text Input",
    Placeholder = "Type something here...",
    CurrentValue = "",
    Callback = function(text)
        print("Text input:", text)
    end
})

FeaturesTab:CreateTextBox({
    Name = "Username Input",
    Description = "Enter a username to search for",
    Placeholder = "Username",
    CurrentValue = "",
    Callback = function(username)
        print("Username entered:", username)
        TBD:Notification({
            Title = "Username Entered",
            Message = "You entered: " .. username,
            Duration = 3,
            Type = "Info"
        })
    end
})

-- Color Picker Section
local ColorSection = FeaturesTab:CreateSection("Color Selection")

FeaturesTab:CreateColorPicker({
    Name = "Color Picker",
    CurrentColor = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        print("Selected color:", color.R, color.G, color.B)
    end
})

FeaturesTab:CreateColorPicker({
    Name = "UI Color",
    Description = "Select a color for your UI elements",
    CurrentColor = Color3.fromRGB(0, 120, 255),
    Callback = function(color)
        print("UI color selected:", color.R, color.G, color.B)
    end
})

-- Labels and Paragraphs
local InfoSection = FeaturesTab:CreateSection("Information Display")

FeaturesTab:CreateLabel({
    Text = "This is a simple label"
})

FeaturesTab:CreateParagraph({
    Title = "Important Information",
    Content = "This is a paragraph that can contain longer text. Paragraphs are useful for displaying detailed information to users. They automatically size based on content."
})

-- Settings Tab Content
local ThemeSection = SettingsTab:CreateSection("Theme Settings")

local themes = {"Default", "HoHo", "Midnight", "Neon", "Aqua"}
SettingsTab:CreateDropdown({
    Name = "Select Theme",
    Items = themes,
    CurrentOption = "HoHo",
    Callback = function(theme)
        -- Note: Theme switching would normally require recreating the UI
        -- This is just for demonstration
        TBD:Notification({
            Title = "Theme Selected",
            Message = "Selected the " .. theme .. " theme (would normally change theme)",
            Duration = 3,
            Type = "Info"
        })
    end
})

-- Custom theme button
SettingsTab:CreateButton({
    Name = "Create Custom Theme",
    Description = "Shows how to create a custom theme",
    Callback = function()
        -- Create a custom theme (in a real scenario, you'd apply this)
        local customTheme = TBD:CustomTheme({
            Primary = Color3.fromRGB(30, 30, 35),
            Secondary = Color3.fromRGB(25, 25, 30),
            Background = Color3.fromRGB(20, 20, 25),
            TextPrimary = Color3.fromRGB(240, 240, 240),
            TextSecondary = Color3.fromRGB(190, 190, 190),
            Accent = Color3.fromRGB(130, 170, 255),
            DarkAccent = Color3.fromRGB(110, 150, 230),
            Success = Color3.fromRGB(60, 200, 120),
            Warning = Color3.fromRGB(255, 180, 40),
            Error = Color3.fromRGB(255, 50, 50),
        })
        
        TBD:Notification({
            Title = "Custom Theme Created",
            Message = "Custom theme has been created (would normally apply)",
            Duration = 3,
            Type = "Success"
        })
    end
})

local UISettingsSection = SettingsTab:CreateSection("UI Settings")

SettingsTab:CreateToggle({
    Name = "Show Player Avatar",
    CurrentValue = true,
    Callback = function(value)
        print("Show avatar toggled:", value)
    end
})

-- Credits Tab Content
local CreditsSection = CreditsTab:CreateSection("Credits")

CreditsTab:CreateParagraph({
    Title = "TBD UI Library",
    Content = "Version: " .. TBD.Version .. "\nCreated by the TBD Development Team\nUniversal Edition - Compatible with all Roblox executors"
})

CreditsTab:CreateButton({
    Name = "Join Discord",
    Description = "Click to get an invite to our Discord server",
    Callback = function()
        -- This would normally copy a Discord link to clipboard
        TBD:Notification({
            Title = "Discord Invite",
            Message = "Discord invite would be copied to clipboard",
            Duration = 3,
            Type = "Info"
        })
    end
})

-- Final notification to show library is fully loaded
TBD:Notification({
    Title = "TBD UI Library V9",
    Message = "Interface loaded successfully!",
    Duration = 5,
    Type = "Success"
})

-- Note: To create your own script, simply copy the parts you need
-- The TBD UI Library is fully modular, allowing you to use only the components you want
