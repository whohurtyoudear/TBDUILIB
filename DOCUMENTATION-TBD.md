# TBD UI Library Documentation

## Overview

TBD UI Library is a modern, feature-rich UI library for Roblox script hubs and executors. It provides a clean, customizable interface with various UI elements and features to enhance user experience.

## Table of Contents

1. [Installation](#installation)
2. [Getting Started](#getting-started)
3. [Window Creation](#window-creation)
4. [Tabs](#tabs)
5. [UI Elements](#ui-elements)
   - [Section](#section)
   - [Button](#button)
   - [Toggle](#toggle)
   - [Slider](#slider)
   - [Dropdown](#dropdown)
   - [Colorpicker](#colorpicker)
   - [Textbox](#textbox)
   - [Keybind](#keybind)
   - [Divider](#divider)
6. [Notifications](#notifications)
7. [Themes](#themes)
8. [Configuration System](#configuration-system)
9. [Homepage Feature](#homepage-feature)
10. [Executor Compatibility](#executor-compatibility)
11. [Mobile Support](#mobile-support)
12. [Troubleshooting](#troubleshooting)
13. [Advanced Customization](#advanced-customization)
14. [Migration Guide](#migration-guide)

## Installation

Add the following code to your script to load the TBD UI Library:

```lua
local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOURUSERNAME/YOURREPO/main/tbd-enhanced-fixed.lua", true))()
```

## Getting Started

Here's a basic example to get you started:

```lua
-- Load the library
local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOURUSERNAME/YOURREPO/main/tbd-enhanced-fixed.lua", true))()

-- Create a window
local Window = TBD:CreateWindow({
    Title = "My Script Hub",
    Theme = "Default",
    ShowHomePage = true -- Enable the home page feature
})

-- Create a tab
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "home"
})

-- Add elements to the tab
MainTab:CreateButton({
    Name = "Click Me",
    Callback = function()
        print("Button clicked!")
    end
})
```

## Window Creation

Create a window using the `CreateWindow` function:

```lua
local Window = TBD:CreateWindow({
    Title = "My Script Hub",            -- Window title
    Subtitle = "v1.0.0",                -- Optional subtitle
    Theme = "Default",                  -- Default, Midnight, Neon, Aqua or custom
    Size = {500, 400},                  -- Window size {width, height}
    Position = "Center",                -- "Center" or {x, y} position
    LogoId = "rbxassetid://12345678",   -- Optional logo image ID
    LoadingEnabled = true,              -- Show loading screen
    LoadingTitle = "My Script Hub",     -- Loading screen title
    LoadingSubtitle = "Loading...",     -- Loading screen subtitle
    ShowHomePage = true,                -- Enable the home page feature
    
    -- Enhanced loading screen customization
    LoadingScreenCustomization = {
        AnimationStyle = "Slide",       -- "Fade", "Slide", "Scale"
        LogoSize = UDim2.new(0, 120, 0, 120),
        LogoPosition = UDim2.new(0.5, 0, 0.35, 0),
        ProgressBarSize = UDim2.new(0.8, 0, 0, 8)
    },
    
    -- Config system settings
    ConfigSettings = {
        ConfigFolder = "MyScriptHub"
    }
})
```

## Tabs

Create tabs to organize your UI elements:

```lua
local Tab = Window:CreateTab({
    Name = "Tab Name",                -- Tab name
    Icon = "home",                    -- Icon name from the icon pack
    ImageSource = "Phosphor",         -- Icon pack: "Material" or "Phosphor"
    ShowTitle = true                  -- Show tab title next to icon
})
```

## UI Elements

### Section

Create a section to organize elements within a tab:

```lua
Tab:CreateSection("Section Name")
```

### Button

Create a clickable button:

```lua
local Button = Tab:CreateButton({
    Name = "Button Name",               -- Button name
    Description = "Button description", -- Optional description
    Callback = function()               -- Function to call when clicked
        print("Button clicked!")
    end
})
```

### Toggle

Create a toggle switch for boolean settings:

```lua
local Toggle = Tab:CreateToggle({
    Name = "Toggle Name",               -- Toggle name
    Description = "Toggle description", -- Optional description
    CurrentValue = false,               -- Default value
    Flag = "ToggleName",                -- Flag for configuration saving
    Callback = function(Value)          -- Function to call when toggled
        print("Toggle is now:", Value)
    end
})

-- You can get or set the toggle value
local Value = Toggle:GetState()
Toggle:Set(true)
```

### Slider

Create a slider for number inputs:

```lua
local Slider = Tab:CreateSlider({
    Name = "Slider Name",               -- Slider name
    Description = "Slider description", -- Optional description
    Range = {0, 100},                   -- Value range
    Increment = 1,                      -- Step size
    CurrentValue = 50,                  -- Default value
    Flag = "SliderName",                -- Flag for configuration saving
    Callback = function(Value)          -- Function to call when value changes
        print("Slider value:", Value)
    end
})

-- You can get or set the slider value
local Value = Slider:GetValue()
Slider:Set(75)
```

### Dropdown

Create a dropdown menu for selecting from a list:

```lua
local Dropdown = Tab:CreateDropdown({
    Name = "Dropdown Name",               -- Dropdown name
    Description = "Dropdown description", -- Optional description
    Items = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",                 -- Default selected item
    Flag = "DropdownName",                -- Flag for configuration saving
    Callback = function(Item)             -- Function to call when item selected
        print("Selected:", Item)
    end
})

-- You can refresh the dropdown with new items
Dropdown:Refresh({
    "New Option 1",
    "New Option 2",
    "New Option 3"
})

-- Set the selected item
Dropdown:Set("New Option 2")
```

### Colorpicker

Create a color picker:

```lua
local ColorPicker = Tab:CreateColorPicker({
    Name = "Color Picker",               -- Color picker name
    Description = "Pick a color",        -- Optional description
    Color = Color3.fromRGB(255, 0, 0),   -- Default color
    Flag = "ColorPickerName",            -- Flag for configuration saving
    Callback = function(Color)           -- Function to call when color changes
        print("Selected color:", Color)
    end
})

-- Set the color
ColorPicker:Set(Color3.fromRGB(0, 255, 0))
```

### Textbox

Create a text input box:

```lua
local Textbox = Tab:CreateTextbox({
    Name = "Textbox Name",               -- Textbox name
    Description = "Textbox description", -- Optional description
    PlaceholderText = "Enter text...",   -- Placeholder text
    Text = "",                           -- Default text
    CharacterLimit = 50,                 -- Maximum character limit
    Flag = "TextboxName",                -- Flag for configuration saving
    Callback = function(Text)            -- Function to call when text changes
        print("Text entered:", Text)
    end
})

-- Set the text
Textbox:Set("New text")
```

### Keybind

Create a keybind picker:

```lua
local Keybind = Tab:CreateKeybind({
    Name = "Keybind Name",               -- Keybind name
    Description = "Keybind description", -- Optional description
    CurrentKeybind = "E",                -- Default key
    Flag = "KeybindName",                -- Flag for configuration saving
    Callback = function(Key)             -- Function to call when key pressed
        print("Key pressed:", Key)
    end
})

-- Set the keybind
Keybind:Set("F")
```

### Divider

Create a visual divider:

```lua
Tab:CreateDivider()
```

## Notifications

Display notifications to the user:

```lua
TBD:Notification({
    Title = "Notification Title",     -- Notification title
    Message = "Notification message", -- Notification message
    Type = "Info",                    -- Type: "Info", "Success", "Warning", "Error"
    Duration = 5,                     -- Display duration in seconds
    Callback = function()             -- Function to call when notification clicked
        print("Notification clicked!")
    end
})
```

Control notification position:

```lua
-- Set notification position (TopRight, TopLeft, BottomRight, BottomLeft)
TBD.NotificationSystem:SetPosition("TopRight")
```

## Themes

TBD UI Library includes several built-in themes:

```lua
-- Set a pre-built theme
TBD:SetTheme("Default")  -- Options: "Default", "Midnight", "Neon", "Aqua"

-- Or create a custom theme
TBD:CustomTheme({
    Primary = Color3.fromRGB(0, 120, 255),
    Background = Color3.fromRGB(30, 30, 30),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    DropShadowEnabled = true
})
```

## Configuration System

Save and load user configurations:

```lua
-- Save the current configuration
TBD:SaveConfig("MyConfig")

-- Load a saved configuration
TBD:LoadConfig("MyConfig")

-- List all saved configurations
local Configs = TBD:ListConfigs()
```

## Homepage Feature

The library includes a homepage feature that displays player information, game details, and library credits. To enable it, set `ShowHomePage = true` when creating the window:

```lua
local Window = TBD:CreateWindow({
    Title = "My Script Hub",
    ShowHomePage = true
})
```

The homepage includes:
- Player information (name, display name, user ID, account age)
- Game information (game name, place ID)
- Server information (player count)
- UI library credits

You can access the home tab to add additional elements:

```lua
-- Add custom elements to the home tab
Window.HomeTab:CreateButton({
    Name = "Home Button",
    Callback = function()
        print("Home button clicked!")
    end
})
```

## Executor Compatibility

TBD UI Library is designed to work across different Roblox executors. It includes several compatibility features to ensure consistent behavior:

### Safe Area Insets

The library includes a fallback mechanism for executors that don't support the `GuiService:GetSafeInsets()` method:

```lua
-- This is handled automatically, but you can reference the safe area values if needed:
local safeAreaLeft = TBD.SafeArea.Left
local safeAreaTop = TBD.SafeArea.Top
```

### Error Handling

All critical functions include error handling to prevent script termination on executor-specific limitations:

```lua
-- Example of applying protected calls in your own code
local success, result = pcall(function()
    -- Your potentially incompatible code here
    return someResult
end)

if not success then
    -- Fallback behavior
end
```

## Mobile Support

The library automatically detects and adapts to mobile devices:

### Mobile Detection

Mobile detection is performed when the library loads:

```lua
-- You can check if the user is on mobile
if TBD.IsMobile then
    -- Perform mobile-specific adjustments
end
```

### Mobile-Specific Features

The UI automatically adjusts for touch interaction on mobile devices:
- Larger buttons and interactive elements
- Adjusted spacing and padding
- Touch-friendly controls
- Automatic size adjustments for smaller screens

## Troubleshooting

### Common Issues and Solutions

#### Notifications Not Appearing in the Right Position

If notifications appear in unexpected locations, explicitly set the notification position:

```lua
TBD.NotificationSystem:SetPosition("TopRight") -- Options: "TopRight", "TopLeft", "BottomRight", "BottomLeft"
```

#### Toggle Elements Not Working

If toggle elements are not functioning correctly, ensure your element creation follows this pattern:

```lua
local toggle = Tab:CreateToggle({
    Name = "Toggle Name",
    CurrentValue = false, -- Must be a boolean value
    Callback = function(Value) 
        -- Always check the Value parameter, not an external variable
        if Value then
            -- Code for when toggle is on
        else
            -- Code for when toggle is off
        end
    end
})
```

#### UI Not Appearing on Some Executors

If the UI doesn't appear on certain executors, ensure you're using the fixed version of the library with executor compatibility:

```lua
-- Make sure to use the fixed version
local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOURUSERNAME/YOURREPO/main/tbd-enhanced-fixed.lua", true))()
```

#### Scripts Errors on Mobile Devices

If your script encounters errors specifically on mobile devices, ensure mobile compatibility:

```lua
-- Create a window with mobile compatibility in mind
local Window = TBD:CreateWindow({
    Title = "My Script Hub",
    -- Avoid fixed sizes that might be too large for mobile
    Size = IS_MOBILE and {350, 450} or {500, 600}
})
```

### Debugging Tips

1. **Enable Debug Mode**: Enable debug mode to get more detailed error information
   ```lua
   TBD.DebugMode = true
   ```

2. **Check Console Logs**: Monitor the developer console for any error messages

3. **Version Verification**: Ensure you're using the latest version of the library
   ```lua
   print("TBD UI Version:", TBD.Version)
   ```

## Advanced Customization

### Custom Icon Integration

You can use custom icons in your UI elements:

```lua
-- Using a custom icon by asset ID
Tab:CreateButton({
    Name = "Custom Icon Button",
    Icon = 12345678, -- Direct asset ID as a number
    Callback = function() end
})

-- Or with a full asset path
Tab:CreateButton({
    Name = "Custom Icon Button",
    Icon = "rbxassetid://12345678", -- Full asset path
    Callback = function() end
})
```

### Deep Theme Customization

For advanced theme customization, you can modify all theme properties:

```lua
TBD:CustomTheme({
    -- Main colors
    Primary = Color3.fromRGB(0, 120, 255),
    PrimaryDark = Color3.fromRGB(0, 100, 220),
    Background = Color3.fromRGB(30, 30, 35),
    ContainerBackground = Color3.fromRGB(35, 35, 40),
    SecondaryBackground = Color3.fromRGB(40, 40, 45),
    ElementBackground = Color3.fromRGB(45, 45, 50),
    
    -- Text colors
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    
    -- Input element colors
    InputBackground = Color3.fromRGB(55, 55, 60),
    PlaceholderText = Color3.fromRGB(120, 120, 120),
    
    -- Status colors
    Success = Color3.fromRGB(0, 200, 0),
    Warning = Color3.fromRGB(255, 180, 0),
    Error = Color3.fromRGB(255, 0, 60),
    Info = Color3.fromRGB(0, 180, 250),
    
    -- UI properties
    CornerRadius = UDim.new(0, 8),
    Font = Enum.Font.GothamSemibold,
    TextSize = 14,
    HeaderSize = 16,
    
    -- Animations and effects
    AnimationSpeed = 0.2,
    DropShadowEnabled = true,
    Transparency = 0.95,
    
    -- Icon settings
    IconPack = "Phosphor"
})
```

### Custom Element Templates

Create reusable element templates for consistent styling:

```lua
-- Create a template for action buttons
function CreateActionButton(tab, name, callback)
    return tab:CreateButton({
        Name = name,
        Description = "Action Button Template",
        Callback = callback
    })
end

-- Usage
local myButton = CreateActionButton(MainTab, "Perform Action", function()
    print("Action performed!")
end)
```

## Migration Guide

### Migrating from Legacy Version

If you're updating from a previous version of TBD UI Library, follow these steps to ensure compatibility:

1. **Update the library import**:
   ```lua
   -- Old version
   local TBD = loadstring(game:HttpGet("https://old-url/tbd.lua"))()
   
   -- New version (fixed)
   local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOURUSERNAME/YOURREPO/main/tbd-enhanced-fixed.lua", true))()
   ```

2. **Update toggle elements**:
   ```lua
   -- Old version
   local toggle = Tab:CreateToggle("Toggle Name", false, function(Value) end)
   
   -- New version
   local toggle = Tab:CreateToggle({
       Name = "Toggle Name",
       CurrentValue = false,
       Callback = function(Value) end
   })
   ```

3. **Update notification calls**:
   ```lua
   -- Old version
   TBD:Notify("Title", "Message", "Info")
   
   -- New version
   TBD:Notification({
       Title = "Title",
       Message = "Message",
       Type = "Info"
   })
   ```

4. **Enable home page**:
   ```lua
   -- Add this option to your window creation
   local Window = TBD:CreateWindow({
       Title = "My Script Hub",
       ShowHomePage = true -- New feature
   })
   ```

5. **Update theme settings**:
   ```lua
   -- Old version
   TBD:SetTheme("Default")
   
   -- New version (supports more themes)
   TBD:SetTheme("Aqua") -- Try the new Aqua theme
   ```

### Breaking Changes

Be aware of these breaking changes when updating:

1. All UI element creation now uses a table-based parameter system instead of individual parameters
2. Notification system has a new interface and positioning system
3. Theme customization requires a table of properties instead of individual color arguments
