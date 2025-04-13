--[[
    TBD UI Library - V8 Example
    
    This example demonstrates all UI elements available in the TBD UI Library V8,
    including the new Label and Paragraph components.
    
    Features demonstrated:
    - Complete Window and Tab creation
    - All UI elements including Label and Paragraph
    - Theme system integration
    - Dynamic icon selection
    - Notification system
]]

-- Load the TBD UI Library V8 final version with theme fixes
local TBD = loadstring(game:HttpGet('https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/refs/heads/main/tbd.lua'))()

-- Create a window
local Window = TBD:CreateWindow({
    Title = "TBD UI Library",
    Subtitle = "V8 Enhanced Example",
    LoadingEnabled = true,
    Size = {600, 500}, -- Wider layout following HoHo design
    Theme = "HoHo",    -- Available themes: Default, Midnight, Neon, Aqua, HoHo
    ShowHomePage = true -- Show the home page with player info
})

-- Create tabs using icons from the dynamic icon library
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "Home" -- Using string icon name instead of direct asset ID
})

local ElementsTab = Window:CreateTab({
    Name = "Elements",
    Icon = "Button"
})

local TextTab = Window:CreateTab({
    Name = "Text Elements",
    Icon = "Book" -- For demonstrating Label and Paragraph
})

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "Settings"
})

-- MAIN TAB
MainTab:CreateSection("Library Information")

-- Label element - new in V8
MainTab:CreateLabel({
    Text = "TBD UI Library v" .. TBD.Version .. " - Enhanced Edition"
})

-- Paragraph element - new in V8
MainTab:CreateParagraph({
    Title = "About This Example",
    Content = "This example demonstrates all UI elements available in the TBD UI Library, including the new Label and Paragraph components. The library is designed for script hubs and executors with a modern, user-friendly interface."
})

MainTab:CreateButton({
    Name = "Show Welcome Notification",
    Description = "Display a welcome notification",
    Callback = function()
        TBD:Notification({
            Title = "Welcome!",
            Message = "Thanks for using the TBD UI Library V8.",
            Duration = 5,
            Type = "Success"
        })
    end
})

MainTab:CreateSection("New Features")

MainTab:CreateButton({
    Name = "Text Elements (New in V8)",
    Description = "See new Label and Paragraph elements",
    Callback = function()
        TBD:Notification({
            Title = "New Text Elements",
            Message = "Check out the Text Elements tab to see Label and Paragraph components in action!",
            Duration = 5,
            Type = "Info"
        })
    end
})

-- ELEMENTS TAB
ElementsTab:CreateSection("Basic Elements")

ElementsTab:CreateButton({
    Name = "Standard Button",
    Description = "Click to trigger an action",
    Callback = function()
        print("Button clicked!")
    end
})

ElementsTab:CreateToggle({
    Name = "Toggle Feature",
    Description = "Enable or disable a feature",
    CurrentValue = false,
    Callback = function(value)
        print("Toggle set to:", value)
    end,
    Flag = "testToggle" -- Optional flag for accessing this value globally
})

ElementsTab:CreateSection("Input Elements")

ElementsTab:CreateSlider({
    Name = "Adjustment Slider",
    Description = "Adjust a value within a range",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(value)
        print("Slider value:", value)
    end,
    Flag = "testSlider"
})

ElementsTab:CreateTextbox({
    Name = "Text Input",
    Description = "Enter a custom value",
    PlaceholderText = "Enter text here...",
    Text = "", -- Initial text
    Callback = function(text)
        print("Input text:", text)
    end
})

-- Using CreateInput (alias for CreateTextbox) - new in V8
ElementsTab:CreateInput({
    Name = "Alternative Input",
    Description = "This uses the CreateInput alias",
    PlaceholderText = "Type something...",
    Callback = function(text)
        print("Alternative input:", text)
    end
})

ElementsTab:CreateSection("Selection Elements")

ElementsTab:CreateDropdown({
    Name = "Options Dropdown",
    Description = "Select from multiple options",
    Options = {"Option 1", "Option 2", "Option 3", "Option 4"},
    CurrentOption = "Option 1",
    Callback = function(option)
        print("Selected option:", option)
    end,
    Flag = "testDropdown"
})

ElementsTab:CreateColorPicker({
    Name = "Color Selection",
    Description = "Choose a custom color",
    CurrentColor = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        print("Selected color:", color)
    end,
    Flag = "testColor"
})

ElementsTab:CreateKeybind({
    Name = "Action Keybind",
    Description = "Set a key to trigger an action",
    CurrentKeybind = "F",
    Callback = function()
        print("Keybind triggered!")
    end,
    Flag = "testKeybind"
})

-- TEXT ELEMENTS TAB (Showcasing new Label and Paragraph)
TextTab:CreateSection("Label Examples")

-- Simple label
TextTab:CreateLabel({
    Text = "This is a basic label"
})

-- Informational label
TextTab:CreateLabel({
    Text = "Labels are great for displaying static information"
})

-- Dynamic label example
local statusLabel = TextTab:CreateLabel({
    Text = "Current Status: Waiting..."
})

-- Button to update label
TextTab:CreateButton({
    Name = "Update Status",
    Callback = function()
        statusLabel:SetText("Current Status: Active")
        
        -- Revert after 3 seconds
        task.wait(3)
        statusLabel:SetText("Current Status: Waiting...")
    end
})

TextTab:CreateSection("Paragraph Examples")

-- Basic paragraph
TextTab:CreateParagraph({
    Title = "Basic Paragraph",
    Content = "This is a simple paragraph that demonstrates how to display longer text content with a title."
})

-- Multi-line paragraph
TextTab:CreateParagraph({
    Title = "Instructions",
    Content = "1. First, select your target from the dropdown menu\n2. Adjust the settings using the sliders\n3. Click the 'Apply' button to execute\n4. Check the console for results"
})

-- Detailed paragraph
TextTab:CreateParagraph({
    Title = "About Paragraphs",
    Content = "Paragraphs are perfect for displaying detailed information, instructions, or explanations to users. They automatically adjust their size based on content length and provide better visual organization than simple labels. Use paragraphs when you need to present complex information in a readable format."
})

-- Combined with other elements
TextTab:CreateSection("Combining Elements")

TextTab:CreateLabel({
    Text = "Color Selection Example"
})

TextTab:CreateParagraph({
    Title = "How to Use",
    Content = "Select a color from the color picker below. The selected color will be applied to various UI elements in your game."
})

TextTab:CreateColorPicker({
    Name = "UI Element Color",
    CurrentColor = Color3.fromRGB(0, 120, 255),
    Callback = function(color)
        print("Selected UI color:", color)
    end
})

-- SETTINGS TAB
SettingsTab:CreateSection("Theme Settings")

local themes = {"Default", "Midnight", "Neon", "Aqua", "HoHo"}
SettingsTab:CreateDropdown({
    Name = "UI Theme",
    Description = "Change the appearance of the interface",
    Options = themes,
    CurrentOption = "HoHo",
    Callback = function(theme)
        TBD:SetTheme(theme)
        TBD:Notification({
            Title = "Theme Changed",
            Message = "Applied the " .. theme .. " theme to the interface.",
            Duration = 3,
            Type = "Success"
        })
    end
})

SettingsTab:CreateSection("Custom Theme")

SettingsTab:CreateColorPicker({
    Name = "Accent Color",
    Description = "Change the primary accent color",
    CurrentColor = TBD.Themes.HoHo.Accent,
    Callback = function(color)
        TBD:CustomTheme({
            Accent = color,
            DarkAccent = color:Lerp(Color3.fromRGB(0, 0, 0), 0.2)
        })
    end
})

SettingsTab:CreateColorPicker({
    Name = "Background Color",
    Description = "Change the background color",
    CurrentColor = TBD.Themes.HoHo.Background,
    Callback = function(color)
        TBD:CustomTheme({
            Background = color,
            Primary = color:Lerp(Color3.fromRGB(255, 255, 255), 0.1),
            Secondary = color:Lerp(Color3.fromRGB(255, 255, 255), 0.05)
        })
    end
})

SettingsTab:CreateSection("Notifications")

SettingsTab:CreateButton({
    Name = "Test Notification",
    Callback = function()
        TBD:Notification({
            Title = "Test Notification",
            Message = "This is a sample notification from TBD UI Library.",
            Duration = 5,
            Type = "Info" 
        })
    end
})

SettingsTab:CreateDropdown({
    Name = "Notification Type",
    Options = {"Info", "Success", "Warning", "Error"},
    CurrentOption = "Info",
    Callback = function(option)
        TBD:Notification({
            Title = option .. " Notification",
            Message = "This is a " .. string.lower(option) .. " notification example.",
            Duration = 5,
            Type = option
        })
    end
})

-- Show initial notification
TBD:Notification({
    Title = "UI Loaded",
    Message = "TBD UI Library V8 with Label and Paragraph support has been loaded!",
    Duration = 5,
    Type = "Success"
})
